-- ############################################################################
-- PHASE 3.7: PAYMENT SERVICE BUSINESS LOGIC (CORE FINANCIAL ENGINE)
-- VERSION: 1.6.1 (Fixed Variable Declaration)
-- ############################################################################

CREATE OR REPLACE FUNCTION public.process_contract_payment(
    p_contract_id UUID,
    p_amount DECIMAL(15,2),
    p_payment_method TEXT,
    p_reference_no TEXT,
    p_idempotency_key TEXT DEFAULT NULL
)
RETURNS JSONB AS $$
DECLARE
    v_fiscal_period_id UUID; -- إضافة التعريف المفقود هنا
    v_contract RECORD;
    v_payment_id UUID;
    v_remaining_cash DECIMAL(15,2);
    v_inst RECORD;
    v_alloc_amount DECIMAL(15,2);
    v_principal_part DECIMAL(15,2);
    v_profit_part DECIMAL(15,2);
    v_investor RECORD;
    v_investor_count INT;
    v_current_investor_idx INT := 0;
    v_investor_share_amount DECIMAL(15,2);
    v_investor_profit_share DECIMAL(15,2);
    v_dist_principal_running_total DECIMAL(15,2) := 0;
    v_dist_profit_running_total DECIMAL(15,2) := 0;
    v_company_profit_ratio DECIMAL(5,2);
    v_total_profit_to_distribute DECIMAL(15,2);
    v_company_profit_share DECIMAL(15,2);
    v_total_principal_paid DECIMAL(15,2) := 0;
    v_total_profit_paid DECIMAL(15,2) := 0;
    v_journal_lines JSONB := '[]'::jsonb;
    v_remaining_balance_on_contract DECIMAL(15,2);
BEGIN
    -- [1] التحقق من تجميد النظام
    IF public.is_financial_system_frozen() THEN
        RAISE EXCEPTION 'CRITICAL: Financial operations are frozen.';
    END IF;

    -- [2] منع تكرار الدفع (Idempotency)
    IF p_idempotency_key IS NOT NULL THEN
        SELECT id INTO v_payment_id FROM public.payments WHERE idempotency_key = p_idempotency_key;
        IF v_payment_id IS NOT NULL THEN
            RETURN jsonb_build_object('success', true, 'payment_id', v_payment_id, 'message', 'Duplicate request');
        END IF;
    END IF;

    -- [3] التحقق من الصلاحيات والبيانات الأساسية
    IF NOT public.has_permission('process_payments') THEN RAISE EXCEPTION 'Unauthorized'; END IF;

    SELECT id INTO v_fiscal_period_id FROM public.fiscal_periods WHERE is_closed = false AND CURRENT_DATE BETWEEN start_date AND end_date LIMIT 1;
    IF v_fiscal_period_id IS NULL THEN RAISE EXCEPTION 'No open fiscal period found'; END IF;

    SELECT * INTO v_contract FROM public.financing_contracts WHERE id = p_contract_id FOR UPDATE;
    IF v_contract.status != 'active' THEN RAISE EXCEPTION 'Contract is not active'; END IF;

    -- [4] تسجيل الدفعة
    INSERT INTO public.payments (contract_id, amount_total, payment_method, reference_no, recorded_by, idempotency_key, status)
    VALUES (p_contract_id, p_amount, p_payment_method, p_reference_no, auth.uid(), p_idempotency_key, 'completed')
    RETURNING id INTO v_payment_id;

    v_remaining_cash := p_amount;

    -- [5] توزيع المبلغ على الأقساط (FIFO)
    FOR v_inst IN (SELECT * FROM public.installments WHERE contract_id = p_contract_id AND status IN ('unpaid', 'partially_paid') ORDER BY due_date ASC FOR UPDATE) LOOP
        EXIT WHEN v_remaining_cash <= 0;
        
        v_alloc_amount := LEAST(v_remaining_cash, (v_inst.expected_amount - COALESCE((SELECT SUM(amount_allocated) FROM public.payment_allocations WHERE installment_id = v_inst.id), 0)));
        
        IF v_alloc_amount > 0 THEN
            INSERT INTO public.payment_allocations (payment_id, installment_id, amount_allocated, allocation_type)
            VALUES (v_payment_id, v_inst.id, v_alloc_amount, 'installment_payment');
            
            v_principal_part := ROUND((v_inst.principal_component / v_inst.expected_amount) * v_alloc_amount, 2);
            v_profit_part := v_alloc_amount - v_principal_part;
            
            v_total_principal_paid := v_total_principal_paid + v_principal_part;
            v_total_profit_paid := v_total_profit_paid + v_profit_part;
            v_remaining_cash := v_remaining_cash - v_alloc_amount;
        END IF;
    END LOOP;

    -- [6] بناء القيد المحاسبي (Journal Entry Lines)
    -- مدين: حساب النقدية/البنك
    v_journal_lines := v_journal_lines || jsonb_build_object('account_code', '1101', 'debit', p_amount, 'credit', 0);
    -- دائن: ذمم عقود التمويل (أصل المبلغ)
    v_journal_lines := v_journal_lines || jsonb_build_object('account_code', '1201', 'debit', 0, 'credit', v_total_principal_paid);
    -- دائن: أرباح عقود التمويل المحققة
    v_journal_lines := v_journal_lines || jsonb_build_object('account_code', '4101', 'debit', 0, 'credit', v_total_profit_paid);

    -- [7] ترحيل القيد المحاسبي
    PERFORM public.post_journal_entry(v_fiscal_period_id, 'Payment for Contract: ' || v_contract.contract_no, p_reference_no, 'payment', v_payment_id, v_journal_lines);

    -- [8] إطلاق الأحداث المالية
    PERFORM public.emit_domain_event('PaymentReceived', v_payment_id, jsonb_build_object('amount', p_amount, 'contract_id', p_contract_id));

    RETURN jsonb_build_object('success', true, 'payment_id', v_payment_id);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
