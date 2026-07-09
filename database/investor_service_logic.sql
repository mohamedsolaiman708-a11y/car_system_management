-- ############################################################################
-- PHASE 3.2: INVESTOR SERVICE BUSINESS LOGIC (RPCs)
-- VERSION: 1.3.0 (Enterprise Hardened - Idempotency Enabled)
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
    p_idempotency_key TEXT DEFAULT NULL -- حماية ضد التكرار
)
RETURNS JSONB AS $$
DECLARE
    v_journal_id UUID;
    v_cash_account_id UUID;
    v_capital_account_id UUID;
    v_fiscal_period_id UUID;
    v_existing_tx_id UUID;
BEGIN
    -- [A] Idempotency Guard
    IF p_idempotency_key IS NOT NULL THEN
        SELECT id INTO v_existing_tx_id FROM public.investor_transactions WHERE reference_id::text = p_idempotency_key;
        IF v_existing_tx_id IS NOT NULL THEN
            RETURN jsonb_build_object('success', true, 'message', 'Duplicate request ignored', 'tx_id', v_existing_tx_id);
        END IF;
    END IF;

    -- [B] Disaster Recovery Guard
    IF public.is_financial_system_frozen() THEN
        RAISE EXCEPTION 'CRITICAL: Financial operations are currently frozen.';
    END IF;

    -- [C] Permissions & Accounts
    IF NOT public.has_permission('manage_investors') THEN
        RAISE EXCEPTION 'Unauthorized';
    END IF;

    SELECT id INTO v_cash_account_id FROM public.accounts WHERE code = '1010';
    SELECT id INTO v_capital_account_id FROM public.accounts WHERE code = '2010';
    SELECT id INTO v_fiscal_period_id FROM public.fiscal_periods WHERE is_closed = false AND CURRENT_DATE BETWEEN start_date AND end_date LIMIT 1;

    IF v_fiscal_period_id IS NULL THEN RAISE EXCEPTION 'No open fiscal period found'; END IF;

    -- [D] Execution
    INSERT INTO public.investor_transactions (investor_id, amount, type, description, reference_id)
    VALUES (p_investor_id, p_amount, 'deposit', p_description, p_idempotency_key::uuid)
    RETURNING id INTO v_existing_tx_id;

    INSERT INTO public.journal_entries (fiscal_period_id, description, source_type, source_id, reference_no)
    VALUES (v_fiscal_period_id, 'Investor Deposit: ' || p_description, 'investor_transaction', p_investor_id, p_idempotency_key)
    RETURNING id INTO v_journal_id;

    INSERT INTO public.journal_entry_lines (journal_entry_id, account_id, debit, credit)
    VALUES (v_journal_id, v_cash_account_id, p_amount, 0), (v_journal_id, v_capital_account_id, 0, p_amount);

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
BEGIN
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

    -- [D] Execution
    INSERT INTO public.investor_transactions (investor_id, amount, type, description, reference_id)
    VALUES (p_investor_id, p_amount, 'withdrawal', p_description, p_idempotency_key::uuid)
    RETURNING id INTO v_existing_tx_id;

    INSERT INTO public.journal_entries (fiscal_period_id, description, source_type, source_id, reference_no)
    VALUES (v_fiscal_period_id, 'Investor Withdrawal: ' || p_description, 'investor_transaction', p_investor_id, p_idempotency_key)
    RETURNING id INTO v_journal_id;

    INSERT INTO public.journal_entry_lines (journal_entry_id, account_id, debit, credit)
    VALUES (v_journal_id, v_capital_account_id, p_amount, 0), (v_journal_id, v_cash_account_id, 0, p_amount);

    RETURN jsonb_build_object('success', true, 'tx_id', v_existing_tx_id, 'journal_id', v_journal_id);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 4. وظيفة تفعيل ملف المستثمر (Approval Lifecycle)
-- ############################################################################
CREATE OR REPLACE FUNCTION public.approve_investor_profile(p_profile_id UUID)
RETURNS VOID AS $$
DECLARE
    v_full_name TEXT;
    v_email TEXT;
BEGIN
    SELECT p.full_name, u.email INTO v_full_name, v_email FROM public.profiles p JOIN auth.users u ON p.id = u.id WHERE p.id = p_profile_id;
    UPDATE public.profiles SET status = 'approved', approved_at = NOW(), approved_by = auth.uid() WHERE id = p_profile_id;
    INSERT INTO public.investors (id, full_name, email) VALUES (p_profile_id, v_full_name, v_email) ON CONFLICT (id) DO NOTHING;
    INSERT INTO public.audit_logs (profile_id, event_type, table_name, record_id) VALUES (auth.uid(), 'INVESTOR_APPROVED', 'profiles', p_profile_id);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 5. توزيع الأرباح يدوياً (Manual Profit Distribution)
-- ############################################################################
CREATE OR REPLACE FUNCTION public.process_manual_profit_distribution(
    p_investor_id UUID,
    p_amount DECIMAL(15,2),
    p_description TEXT,
    p_idempotency_key TEXT DEFAULT NULL
)
RETURNS JSONB AS $$
DECLARE
    v_journal_id UUID;
    v_existing_tx_id UUID;
    v_payable_account_id UUID;
    v_capital_account_id UUID;
    v_fiscal_id UUID;
BEGIN
    -- [A] Idempotency Guard
    IF p_idempotency_key IS NOT NULL THEN
        SELECT id INTO v_existing_tx_id FROM public.investor_transactions WHERE reference_id::text = p_idempotency_key;
        IF v_existing_tx_id IS NOT NULL THEN
            RETURN jsonb_build_object('success', true, 'message', 'Duplicate request ignored', 'tx_id', v_existing_tx_id);
        END IF;
    END IF;

    IF public.is_financial_system_frozen() THEN RAISE EXCEPTION 'CRITICAL: Financial operations are frozen.'; END IF;

    SELECT id INTO v_payable_account_id FROM public.accounts WHERE code = '2030';
    SELECT id INTO v_capital_account_id FROM public.accounts WHERE code = '2010';
    SELECT id INTO v_fiscal_id FROM public.fiscal_periods WHERE is_closed = false AND CURRENT_DATE BETWEEN start_date AND end_date LIMIT 1;

    IF v_fiscal_id IS NULL THEN RAISE EXCEPTION 'No open fiscal period found'; END IF;

    -- [B] Execution
    INSERT INTO public.investor_transactions (investor_id, amount, type, description, reference_id)
    VALUES (p_investor_id, p_amount, 'finance_profit_distribution', p_description, p_idempotency_key::uuid)
    RETURNING id INTO v_existing_tx_id;

    UPDATE public.investors SET total_profit_earned = total_profit_earned + p_amount WHERE id = p_investor_id;

    INSERT INTO public.journal_entries (fiscal_period_id, description, source_type, source_id, reference_no)
    VALUES (v_fiscal_id, 'Manual Profit Dist: ' || p_description, 'investor_transaction', p_investor_id, p_idempotency_key)
    RETURNING id INTO v_journal_id;

    INSERT INTO public.journal_entry_lines (journal_entry_id, account_id, debit, credit)
    VALUES (v_journal_id, v_payable_account_id, p_amount, 0), (v_journal_id, v_capital_account_id, 0, p_amount);

    RETURN jsonb_build_object('success', true, 'tx_id', v_existing_tx_id, 'journal_id', v_journal_id);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
