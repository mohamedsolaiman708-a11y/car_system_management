-- ############################################################################
-- PHASE 3.7: PAYMENT SERVICE BUSINESS LOGIC (CORE FINANCIAL ENGINE)
-- VERSION: 1.5.0 (Disaster Recovery Hardened)
-- ############################################################################

-- [باقي الكود السابق يظل كما هو، سأقوم فقط بتعديل الوظيفة الرئيسية]

CREATE OR REPLACE FUNCTION public.process_contract_payment(
    p_contract_id UUID,
    p_amount DECIMAL(15,2),
    p_payment_method TEXT,
    p_reference_no TEXT,
    p_idempotency_key TEXT DEFAULT NULL
)
RETURNS JSONB AS $$
DECLARE
    v_fiscal RECORD;
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
    -- [A] Disaster Recovery Guard (Financial Freeze Check)
    IF public.is_financial_system_frozen() THEN
        RAISE EXCEPTION 'CRITICAL: Financial operations are currently frozen by the system administrator due to maintenance or integrity check.';
    END IF;

    -- [B] Idempotency Guard
    IF p_idempotency_key IS NOT NULL THEN
        SELECT id INTO v_payment_id FROM public.payments WHERE idempotency_key = p_idempotency_key;
        IF v_payment_id IS NOT NULL THEN
            RETURN jsonb_build_object('success', true, 'message', 'Duplicate idempotency key', 'payment_id', v_payment_id);
        END IF;
    END IF;

    IF NOT public.has_permission('process_payments') THEN RAISE EXCEPTION 'Unauthorized'; END IF;

    -- [Rest of the payment logic remains same as v1.4.0...]
    -- [B] Transaction Locking
    SELECT * INTO v_fiscal FROM public.fiscal_periods 
    WHERE is_closed = false AND CURRENT_DATE BETWEEN start_date AND end_date FOR UPDATE;
    IF v_fiscal.id IS NULL THEN RAISE EXCEPTION 'No open fiscal period found'; END IF;

    SELECT * INTO v_contract FROM public.financing_contracts WHERE id = p_contract_id FOR UPDATE;
    IF v_contract.status != 'active' THEN RAISE EXCEPTION 'Contract is not active'; END IF;

    -- [C] Initialization
    SELECT (value->>'ratio')::DECIMAL INTO v_company_profit_ratio FROM public.system_settings WHERE key = 'company_profit_share_ratio';
    v_company_profit_ratio := COALESCE(v_company_profit_ratio, 20.00);

    INSERT INTO public.payments (contract_id, amount_total, payment_method, reference_no, recorded_by, idempotency_key, status)
    VALUES (p_contract_id, ROUND(p_amount, 2), p_payment_method, p_reference_no, auth.uid(), p_idempotency_key, 'completed')
    RETURNING id INTO v_payment_id;

    v_remaining_cash := ROUND(p_amount, 2);

    -- [D] FIFO Allocation
    FOR v_inst IN (
        SELECT * FROM public.installments 
        WHERE contract_id = p_contract_id AND status IN ('unpaid', 'partially_paid')
        ORDER BY due_date ASC, id ASC FOR UPDATE
    ) LOOP
        EXIT WHEN v_remaining_cash <= 0;

        SELECT (v_inst.expected_amount - (
            (SELECT COALESCE(SUM(amount_allocated), 0) FROM public.payment_allocations WHERE installment_id = v_inst.id) -
            (SELECT COALESCE(SUM(amount_reversed), 0) FROM public.payment_allocation_reversals WHERE installment_id = v_inst.id)
        )) INTO v_alloc_amount;

        IF v_alloc_amount > v_remaining_cash THEN v_alloc_amount := v_remaining_cash; END IF;
        v_alloc_amount := ROUND(v_alloc_amount, 2);
        
        IF v_alloc_amount > 0 THEN
            v_principal_part := ROUND((v_inst.principal_component / v_inst.expected_amount) * v_alloc_amount, 2);
            v_profit_part := v_alloc_amount - v_principal_part;

            INSERT INTO public.payment_allocations (payment_id, installment_id, amount_allocated, allocation_type)
            VALUES (v_payment_id, v_inst.id, v_alloc_amount, 'installment_payment');

            v_total_principal_paid := v_total_principal_paid + v_principal_part;
            v_total_profit_paid := v_total_profit_paid + v_profit_part;
            v_remaining_cash := v_remaining_cash - v_alloc_amount;
        END IF;
    END LOOP;

    -- [E] Investor Distribution
    SELECT COUNT(*) INTO v_investor_count FROM public.contract_funding WHERE contract_id = p_contract_id;
    v_company_profit_share := ROUND(v_total_profit_paid * (v_company_profit_ratio / 100.0), 2);
    v_total_profit_to_distribute := v_total_profit_paid - v_company_profit_share;

    FOR v_investor IN (
        SELECT cf.investor_id, cf.amount_allocated 
        FROM public.contract_funding cf
        WHERE cf.contract_id = p_contract_id
        ORDER BY cf.investor_id ASC FOR UPDATE
    ) LOOP
        v_current_investor_idx := v_current_investor_idx + 1;
        IF v_current_investor_idx = v_investor_count THEN
            v_investor_share_amount := v_total_principal_paid - v_dist_principal_running_total;
            v_investor_profit_share := v_total_profit_to_distribute - v_dist_profit_running_total;
        ELSE
            v_investor_share_amount := ROUND((v_investor.amount_allocated / v_contract.principal_amount) * v_total_principal_paid, 2);
            v_investor_profit_share := ROUND((v_investor.amount_allocated / v_contract.principal_amount) * v_total_profit_to_distribute, 2);
        END IF;

        IF v_investor_share_amount > 0 THEN
            INSERT INTO public.investor_transactions (investor_id, amount, type, reference_id, description)
            VALUES (v_investor.investor_id, v_investor_share_amount, 'contract_return', v_payment_id, 'Return: ' || v_contract.contract_no);
            v_dist_principal_running_total := v_dist_principal_running_total + v_investor_share_amount;
        END IF;

        IF v_investor_profit_share > 0 THEN
            INSERT INTO public.investor_transactions (investor_id, amount, type, reference_id, description)
            VALUES (v_investor.investor_id, v_investor_profit_share, 'finance_profit_distribution', v_payment_id, 'Profit: ' || v_contract.contract_no);
            UPDATE public.investors SET total_profit_earned = total_profit_earned + v_investor_profit_share WHERE id = v_investor.investor_id;
            v_dist_profit_running_total := v_dist_profit_running_total + v_investor_profit_share;
        END IF;
    END LOOP;

    -- [F] Accounting Service
    PERFORM public.post_journal_entry(v_fiscal.id, 'Payment Receipt: ' || v_contract.contract_no, p_reference_no, 'payment', v_payment_id, v_journal_lines);

    -- [G] Closure Check
    SELECT (v_contract.total_contract_value - (
        (SELECT COALESCE(SUM(pa.amount_allocated), 0) FROM public.payment_allocations pa JOIN public.installments i ON pa.installment_id = i.id WHERE i.contract_id = p_contract_id) -
        (SELECT COALESCE(SUM(r.amount_reversed), 0) FROM public.payment_allocation_reversals r JOIN public.installments i ON r.installment_id = i.id WHERE i.contract_id = p_contract_id)
    )) INTO v_remaining_balance_on_contract;

    IF v_remaining_balance_on_contract <= 0.005 THEN
        UPDATE public.financing_contracts SET status = 'closed', updated_at = NOW() WHERE id = p_contract_id;
        PERFORM public.emit_domain_event('ContractClosed', p_contract_id, jsonb_build_object('payment_id', v_payment_id));
    END IF;

    PERFORM public.emit_domain_event('PaymentReceived', v_payment_id, jsonb_build_object('amount', p_amount));
    
    RETURN jsonb_build_object('success', true, 'payment_id', v_payment_id);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
