-- ############################################################################
-- PHASE 3.2: INVESTOR SERVICE BUSINESS LOGIC (RPCs)
-- VERSION: 1.7.0 (Transparency & UI Optimization)
-- ############################################################################

-- 1. تهيئة الحسابات المحاسبية الأساسية
-- ############################################################################
INSERT INTO public.accounts (code, name, type, is_reconcilable)
VALUES 
('1010', 'Cash at Bank', 'asset', true),
('2010', 'Investors Capital', 'liability', true),
('2030', 'Profit Payable', 'liability', true)
ON CONFLICT (code) DO NOTHING;

-- 2. وظيفة معالجة إيداع أموال المستثمر
-- ############################################################################
CREATE OR REPLACE FUNCTION public.process_investor_deposit(
    p_investor_id UUID,
    p_amount DECIMAL(15,2),
    p_description TEXT,
    p_idempotency_key TEXT DEFAULT NULL
)
RETURNS JSONB AS $$
DECLARE
    v_journal_id UUID;
    v_cash_account_id UUID;
    v_capital_account_id UUID;
    v_fiscal_period_id UUID;
    v_existing_tx_id UUID;
    v_staff_name TEXT;
    v_investor_name TEXT;
BEGIN
    -- [A] جلب الأسماء للشفافية المطلقة
    SELECT full_name INTO v_staff_name FROM public.profiles WHERE id = auth.uid();
    SELECT full_name INTO v_investor_name FROM public.investors WHERE id = p_investor_id;

    -- [B] Idempotency Guard
    IF p_idempotency_key IS NOT NULL THEN
        SELECT id INTO v_existing_tx_id FROM public.investor_transactions WHERE reference_id::text = p_idempotency_key;
        IF v_existing_tx_id IS NOT NULL THEN
            RETURN jsonb_build_object('success', true, 'message', 'Duplicate request ignored', 'tx_id', v_existing_tx_id);
        END IF;
    END IF;

    -- [C] Disaster Recovery Guard
    IF public.is_financial_system_frozen() THEN
        RAISE EXCEPTION 'CRITICAL: Financial operations are currently frozen.';
    END IF;

    -- [D] Permissions & Accounts
    IF NOT public.has_permission('manage_investors') THEN
        RAISE EXCEPTION 'Unauthorized';
    END IF;

    SELECT id INTO v_cash_account_id FROM public.accounts WHERE code = '1010';
    SELECT id INTO v_capital_account_id FROM public.accounts WHERE code = '2010';
    SELECT id INTO v_fiscal_period_id FROM public.fiscal_periods WHERE is_closed = false AND CURRENT_DATE BETWEEN start_date AND end_date LIMIT 1;

    IF v_fiscal_period_id IS NULL THEN RAISE EXCEPTION 'No open fiscal period found'; END IF;

    -- [E] Execution
    INSERT INTO public.investor_transactions (investor_id, amount, type, description, reference_id, recorded_by_name)
    VALUES (p_investor_id, p_amount, 'deposit', p_description, p_idempotency_key::uuid, COALESCE(v_staff_name, 'System'))
    RETURNING id INTO v_existing_tx_id;

    INSERT INTO public.journal_entries (fiscal_period_id, description, source_type, source_id, reference_no)
    VALUES (v_fiscal_period_id, 'Investor Deposit (' || v_investor_name || '): ' || p_description, 'investor_transaction', p_investor_id, p_idempotency_key)
    RETURNING id INTO v_journal_id;

    INSERT INTO public.journal_entry_lines (journal_entry_id, account_id, debit, credit)
    VALUES (v_journal_id, v_cash_account_id, p_amount, 0), (v_journal_id, v_capital_account_id, 0, p_amount);

    -- [F] Enhanced Audit Logging (Important: Includes Investor Name)
    INSERT INTO public.audit_logs (profile_id, event_type, table_name, record_id, new_values)
    VALUES (
        auth.uid(), 
        'INVESTOR_DEPOSIT', 
        'investor_transactions', 
        v_existing_tx_id, 
        jsonb_build_object(
            'المستثمر', v_investor_name,
            'المبلغ', p_amount, 
            'البيان', p_description,
            'الموظف المسؤول', v_staff_name,
            'رقم المستثمر التقني', p_investor_id
        )
    );

    RETURN jsonb_build_object('success', true, 'tx_id', v_existing_tx_id, 'journal_id', v_journal_id);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 3. وظيفة معالجة سحب أموال المستثمر
-- ############################################################################
CREATE OR REPLACE FUNCTION public.process_investor_withdrawal(
    p_investor_id UUID,
    p_amount DECIMAL(15,2),
    p_description TEXT,
    p_idempotency_key TEXT DEFAULT NULL
)
RETURNS JSONB AS $$
DECLARE
    v_available_balance DECIMAL(15,2);
    v_journal_id UUID;
    v_existing_tx_id UUID;
    v_cash_account_id UUID;
    v_capital_account_id UUID;
    v_fiscal_period_id UUID;
    v_staff_name TEXT;
    v_investor_name TEXT;
BEGIN
    SELECT full_name INTO v_staff_name FROM public.profiles WHERE id = auth.uid();
    SELECT full_name INTO v_investor_name FROM public.investors WHERE id = p_investor_id;

    -- [A] Idempotency Guard
    IF p_idempotency_key IS NOT NULL THEN
        SELECT id INTO v_existing_tx_id FROM public.investor_transactions WHERE reference_id::text = p_idempotency_key;
        IF v_existing_tx_id IS NOT NULL THEN
            RETURN jsonb_build_object('success', true, 'message', 'Duplicate request ignored', 'tx_id', v_existing_tx_id);
        END IF;
    END IF;

    -- [B] Disaster Recovery Guard
    IF public.is_financial_system_frozen() THEN RAISE EXCEPTION 'CRITICAL: Financial operations are frozen.'; END IF;

    -- [C] Liquidity & Permissions
    SELECT available_balance INTO v_available_balance FROM public.investors WHERE id = p_investor_id FOR UPDATE;
    IF v_available_balance < p_amount THEN
        RAISE EXCEPTION 'Insufficient liquidity: Investor only has % available', v_available_balance;
    END IF;

    SELECT id INTO v_cash_account_id FROM public.accounts WHERE code = '1010';
    SELECT id INTO v_capital_account_id FROM public.accounts WHERE code = '2010';
    SELECT id INTO v_fiscal_period_id FROM public.fiscal_periods WHERE is_closed = false AND CURRENT_DATE BETWEEN start_date AND end_date LIMIT 1;

    IF v_fiscal_period_id IS NULL THEN RAISE EXCEPTION 'No open fiscal period found'; END IF;

    -- [D] Execution
    INSERT INTO public.investor_transactions (investor_id, amount, type, description, reference_id, recorded_by_name)
    VALUES (p_investor_id, p_amount, 'withdrawal', p_description, p_idempotency_key::uuid, COALESCE(v_staff_name, 'System'))
    RETURNING id INTO v_existing_tx_id;

    INSERT INTO public.journal_entries (fiscal_period_id, description, source_type, source_id, reference_no)
    VALUES (v_fiscal_period_id, 'Investor Withdrawal (' || v_investor_name || '): ' || p_description, 'investor_transaction', p_investor_id, p_idempotency_key)
    RETURNING id INTO v_journal_id;

    INSERT INTO public.journal_entry_lines (journal_entry_id, account_id, debit, credit)
    VALUES (v_journal_id, v_capital_account_id, p_amount, 0), (v_journal_id, v_cash_account_id, 0, p_amount);

    -- [E] Enhanced Audit Logging
    INSERT INTO public.audit_logs (profile_id, event_type, table_name, record_id, new_values)
    VALUES (
        auth.uid(), 
        'INVESTOR_WITHDRAWAL', 
        'investor_transactions', 
        v_existing_tx_id, 
        jsonb_build_object(
            'المستثمر', v_investor_name,
            'المبلغ', p_amount, 
            'البيان', p_description,
            'الموظف المسؤول', v_staff_name,
            'رقم المستثمر التقني', p_investor_id
        )
    );

    RETURN jsonb_build_object('success', true, 'tx_id', v_existing_tx_id, 'journal_id', v_journal_id);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
