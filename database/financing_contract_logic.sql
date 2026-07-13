-- ############################################################################
-- PHASE 3.5: FINANCING CONTRACT SERVICE LOGIC
-- VERSION: 1.2.2 (Enterprise Production Hardened)
-- ############################################################################

-- 1. ضمان وجود الحسابات المحاسبية الأساسية
INSERT INTO public.accounts (code, name, type, is_reconcilable)
VALUES 
('1020', 'ذمم عقود التمويل', 'asset', true),
('2020', 'ذمم الممولين - أصل رأس المال', 'liability', true),
('4010', 'أرباح تمويل غير محققة', 'liability', false),
('1101', 'الصندوق / البنك', 'asset', true),
('4101', 'إيرادات تمويل محققة', 'revenue', false)
ON CONFLICT (code) DO NOTHING;

-- 2. وظيفة تخصيص تمويل للعقد (Allocate Funding)
CREATE OR REPLACE FUNCTION public.allocate_contract_funding(
    p_contract_id UUID,
    p_investor_id UUID,
    p_amount DECIMAL(15,2)
)
RETURNS VOID AS $$
DECLARE
    v_available DECIMAL(15,2);
    v_principal DECIMAL(15,2);
    v_already_funded DECIMAL(15,2);
BEGIN
    IF public.is_financial_system_frozen() THEN RAISE EXCEPTION 'Financial operations are frozen'; END IF;

    -- Concurrency Control: Lock Contract first
    PERFORM 1 FROM public.financing_contracts WHERE id = p_contract_id FOR UPDATE;

    IF p_amount <= 0 THEN RAISE EXCEPTION 'Funding amount must be positive'; END IF;

    SELECT principal_amount INTO v_principal FROM public.financing_contracts WHERE id = p_contract_id;
    SELECT COALESCE(SUM(amount_allocated), 0) INTO v_already_funded FROM public.contract_funding WHERE contract_id = p_contract_id;
    
    IF (v_already_funded + p_amount) > v_principal THEN
        RAISE EXCEPTION 'Total allocation (%) exceeds contract principal (%)', (v_already_funded + p_amount), v_principal;
    END IF;

    -- Lock Investor row to prevent balance race conditions
    SELECT available_balance INTO v_available FROM public.investors WHERE id = p_investor_id FOR UPDATE;
    IF v_available < p_amount THEN
        RAISE EXCEPTION 'Insufficient investor balance. Available: %, Requested: %', v_available, p_amount;
    END IF;

    INSERT INTO public.contract_funding (contract_id, investor_id, amount_allocated)
    VALUES (p_contract_id, p_investor_id, p_amount);

    INSERT INTO public.investor_transactions (investor_id, amount, type, reference_id, description, status)
    VALUES (p_investor_id, p_amount, 'contract_allocation', p_contract_id, 'Funding for contract', 'finalized');

    -- Audit Trail
    INSERT INTO public.audit_logs (profile_id, event_type, table_name, record_id, new_values)
    VALUES (auth.uid(), 'FUNDING_ALLOCATED', 'contract_funding', p_contract_id, jsonb_build_object('investor_id', p_investor_id, 'amount', p_amount));
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 3. تفعيل العقد (Activate Contract)
CREATE OR REPLACE FUNCTION public.activate_financing_contract(
    p_contract_id UUID
)
RETURNS JSONB AS $$
DECLARE
    v_contract RECORD;
    v_total_funded DECIMAL(15,2);
    v_installment_amount DECIMAL(15,2);
    v_principal_per_inst DECIMAL(15,2);
    v_profit_per_inst DECIMAL(15,2);
    v_fiscal_id UUID;
    v_journal_id UUID;
    v_i INTEGER;
    v_remaining_profit DECIMAL(15,2);
    v_remaining_principal DECIMAL(15,2);
BEGIN
    IF public.is_financial_system_frozen() THEN RAISE EXCEPTION 'Financial operations are frozen'; END IF;

    SELECT * INTO v_contract FROM public.financing_contracts WHERE id = p_contract_id FOR UPDATE;
    IF v_contract.status != 'draft' AND v_contract.status != 'pending_funding' THEN
        RAISE EXCEPTION 'Contract is already active or closed';
    END IF;

    SELECT COALESCE(SUM(amount_allocated), 0) INTO v_total_funded FROM public.contract_funding WHERE contract_id = p_contract_id;
    IF v_total_funded != v_contract.principal_amount THEN
        RAISE EXCEPTION 'Funding incomplete: Required %, Found %', v_contract.principal_amount, v_total_funded;
    END IF;

    SELECT id INTO v_fiscal_id FROM public.fiscal_periods WHERE is_closed = false AND CURRENT_DATE BETWEEN start_date AND end_date LIMIT 1;
    IF v_fiscal_id IS NULL THEN RAISE EXCEPTION 'No open fiscal period found'; END IF;

    v_installment_amount := ROUND(v_contract.total_contract_value / v_contract.duration_months, 2);
    v_principal_per_inst := ROUND(v_contract.principal_amount / v_contract.duration_months, 2);
    v_profit_per_inst := v_installment_amount - v_principal_per_inst;
    
    v_remaining_principal := v_contract.principal_amount;
    v_remaining_profit := v_contract.total_contract_value - v_contract.principal_amount;

    FOR v_i IN 1..v_contract.duration_months LOOP
        IF v_i = v_contract.duration_months THEN
            v_principal_per_inst := v_remaining_principal;
            v_profit_per_inst := v_remaining_profit;
            v_installment_amount := v_principal_per_inst + v_profit_per_inst;
        END IF;

        INSERT INTO public.installments (contract_id, due_date, expected_amount, principal_component, profit_component, status)
        VALUES (p_contract_id, COALESCE(v_contract.start_date, CURRENT_DATE) + (v_i || ' month')::interval, v_installment_amount, v_principal_per_inst, v_profit_per_inst, 'unpaid');

        v_remaining_principal := v_remaining_principal - v_principal_per_inst;
        v_remaining_profit := v_remaining_profit - v_profit_per_inst;
    END LOOP;

    INSERT INTO public.journal_entries (fiscal_period_id, description, source_type, source_id)
    VALUES (v_fiscal_id, 'Activation of Contract: ' || v_contract.contract_no, 'financing_contract', p_contract_id)
    RETURNING id INTO v_journal_id;

    INSERT INTO public.journal_entry_lines (journal_entry_id, account_id, debit, credit)
    VALUES 
    (v_journal_id, (SELECT id FROM public.accounts WHERE code = '1020'), v_contract.total_contract_value, 0),
    (v_journal_id, (SELECT id FROM public.accounts WHERE code = '2020'), 0, v_contract.principal_amount),
    (v_journal_id, (SELECT id FROM public.accounts WHERE code = '4010'), 0, (v_contract.total_contract_value - v_contract.principal_amount));

    -- Sync Inventory Status
    UPDATE public.inventory_items SET status = 'on_contract', updated_at = NOW() WHERE id = v_contract.inventory_item_id;

    UPDATE public.financing_contracts SET status = 'active', updated_at = NOW() WHERE id = p_contract_id;

    INSERT INTO public.audit_logs (profile_id, event_type, table_name, record_id, new_values)
    VALUES (auth.uid(), 'CONTRACT_ACTIVATED', 'financing_contracts', p_contract_id, jsonb_build_object('status', 'active'));

    PERFORM public.emit_domain_event('ContractActivated', p_contract_id, jsonb_build_object('contract_no', v_contract.contract_no));

    RETURN jsonb_build_object('success', true, 'contract_no', v_contract.contract_no);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
