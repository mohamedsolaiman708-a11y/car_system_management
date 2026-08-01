-- ############################################################################
-- ENTERPRISE FINANCING ERP - FINANCIAL ENGINE & REVERSAL LOGIC
-- VERSION: 1.2.5 (Enterprise Hardened - Single Source of Truth)
-- ############################################################################

-- 1. دالة ترحيل القيود اليومية (Double-Entry Posting Engine)
CREATE OR REPLACE FUNCTION public.post_journal_entry(
    p_fiscal_period_id UUID,
    p_description TEXT,
    p_reference_no TEXT,
    p_source_type TEXT,
    p_source_id UUID,
    p_lines JSONB
)
RETURNS UUID AS $$
DECLARE
    v_entry_id UUID;
    v_line RECORD;
    v_account_id UUID;
    v_debit DECIMAL(15,2);
    v_credit DECIMAL(15,2);
    v_debit_sum DECIMAL(15,2) := 0;
    v_credit_sum DECIMAL(15,2) := 0;
BEGIN
    IF p_lines IS NULL OR jsonb_array_length(p_lines) < 2 THEN
        RAISE EXCEPTION 'Journal entry must have at least two lines';
    END IF;

    IF EXISTS (SELECT 1 FROM public.fiscal_periods WHERE id = p_fiscal_period_id AND is_closed = true) THEN
        RAISE EXCEPTION 'Cannot post to a closed fiscal period';
    END IF;

    INSERT INTO public.journal_entries (fiscal_period_id, description, reference_no, source_type, source_id)
    VALUES (p_fiscal_period_id, p_description, p_reference_no, p_source_type, p_source_id)
    RETURNING id INTO v_entry_id;

    FOR v_line IN (SELECT * FROM jsonb_to_recordset(p_lines) AS x(account_code TEXT, debit DECIMAL(15,2), credit DECIMAL(15,2))) LOOP
        SELECT id INTO v_account_id FROM public.accounts WHERE code = v_line.account_code;
        IF v_account_id IS NULL THEN RAISE EXCEPTION 'Account % not found', v_line.account_code; END IF;

        v_debit := COALESCE(v_line.debit, 0.00);
        v_credit := COALESCE(v_line.credit, 0.00);

        IF v_debit > 0 OR v_credit > 0 THEN
            INSERT INTO public.journal_entry_lines (journal_entry_id, account_id, debit, credit)
            VALUES (v_entry_id, v_account_id, v_debit, v_credit);
            v_debit_sum := v_debit_sum + v_debit;
            v_credit_sum := v_credit_sum + v_credit;
        END IF;
    END LOOP;

    IF ABS(v_debit_sum - v_credit_sum) > 0.00 THEN
        RAISE EXCEPTION 'Unbalanced journal entry: Debits (%) != Credits (%)', v_debit_sum, v_credit_sum;
    END IF;

    RETURN v_entry_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 3. دالة عكس دفعات الأقساط (Reversal Engine)
CREATE OR REPLACE FUNCTION public.reverse_contract_payment(
    p_payment_id UUID,
    p_reason TEXT
)
RETURNS JSONB AS $$
DECLARE
    v_payment RECORD;
    v_alloc RECORD;
    v_inv_tx RECORD;
    v_fiscal_period_id UUID;
    v_orig_journal_entry_id UUID;
    v_reversing_lines JSONB := '[]'::jsonb;
BEGIN
    IF public.is_financial_system_frozen() THEN RAISE EXCEPTION 'System frozen'; END IF;

    SELECT * INTO v_payment FROM public.payments WHERE id = p_payment_id FOR UPDATE;
    IF v_payment.id IS NULL THEN RAISE EXCEPTION 'Payment not found'; END IF;
    IF v_payment.status::TEXT = 'reversed' THEN RAISE EXCEPTION 'Already reversed'; END IF;

    SELECT id INTO v_fiscal_period_id FROM public.fiscal_periods WHERE is_closed = false AND CURRENT_DATE BETWEEN start_date AND end_date LIMIT 1;
    IF v_fiscal_period_id IS NULL THEN RAISE EXCEPTION 'No open fiscal period found'; END IF;

    -- A. Reverse Allocations
    FOR v_alloc IN (SELECT * FROM public.payment_allocations WHERE payment_id = p_payment_id FOR UPDATE) LOOP
        INSERT INTO public.payment_allocation_reversals (payment_id, installment_id, amount_reversed, reason)
        VALUES (p_payment_id, v_alloc.installment_id, v_alloc.amount_allocated, p_reason);
    END LOOP;

    -- B. Reverse Investor Ledger (Handled by Trigger)
    FOR v_inv_tx IN (SELECT * FROM public.investor_transactions WHERE reference_id = p_payment_id ORDER BY investor_id ASC FOR UPDATE) LOOP
        INSERT INTO public.investor_transactions (investor_id, amount, type, reference_id, description, status)
        VALUES (v_inv_tx.investor_id, -v_inv_tx.amount, v_inv_tx.type, p_payment_id, 'REVERSAL: ' || p_reason, 'finalized');
        -- Note: Manual UPDATE of total_profit_earned removed to avoid duplication with trigger
    END LOOP;

    -- C. Reverse Accounting (Storno)
    SELECT id INTO v_orig_journal_entry_id FROM public.journal_entries WHERE source_type = 'payment' AND source_id = p_payment_id LIMIT 1;
    IF v_orig_journal_entry_id IS NOT NULL THEN
        SELECT jsonb_agg(jsonb_build_object('account_code', a.code, 'debit', l.credit, 'credit', l.debit)) INTO v_reversing_lines
        FROM public.journal_entry_lines l JOIN public.accounts a ON l.account_id = a.id
        WHERE l.journal_entry_id = v_orig_journal_entry_id;
        PERFORM public.post_journal_entry(v_fiscal_period_id, 'REVERSAL: ' || p_reason, 'REV-' || v_payment.id, 'payment_reversal', p_payment_id, v_reversing_lines);
    END IF;

    UPDATE public.financing_contracts SET status = 'active' WHERE id = v_payment.contract_id AND status = 'closed';
    UPDATE public.payments SET status = 'reversed' WHERE id = p_payment_id;

    INSERT INTO public.audit_logs (profile_id, event_type, table_name, record_id, new_values)
    VALUES (auth.uid(), 'PAYMENT_REVERSED', 'payments', p_payment_id, jsonb_build_object('reason', p_reason, 'contract_id', v_payment.contract_id));

    PERFORM public.emit_domain_event('PaymentReversed', p_payment_id, jsonb_build_object('amount', v_payment.amount_total));
    RETURN jsonb_build_object('success', true);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
