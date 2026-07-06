-- ############################################################################
-- PHASE 3.2: INVESTOR SERVICE BUSINESS LOGIC (RPCs)
-- ############################################################################

-- 1. تهيئة الحسابات المحاسبية الأساسية
-- ############################################################################
INSERT INTO public.accounts (code, name, type, is_reconcilable)
VALUES 
('1010', 'Cash at Bank', 'asset', true),
('2010', 'Investors Capital', 'liability', true)
ON CONFLICT (code) DO NOTHING;

-- 2. وظيفة معالجة إيداع أموال المستثمر
-- ############################################################################
CREATE OR REPLACE FUNCTION public.process_investor_deposit(
    p_investor_id UUID,
    p_amount DECIMAL(15,2),
    p_description TEXT
)
RETURNS JSONB AS $$
DECLARE
    v_journal_id UUID;
    v_cash_account_id UUID;
    v_capital_account_id UUID;
    v_fiscal_period_id UUID;
BEGIN
    -- 1. التحقق من الصلاحيات (يجب أن يكون موظفاً)
    IF NOT public.has_permission('manage_investors') THEN
        RAISE EXCEPTION 'Unauthorized: Missing manage_investors permission';
    END IF;

    -- 2. جلب الحسابات اللازمة
    SELECT id INTO v_cash_account_id FROM public.accounts WHERE code = '1010';
    SELECT id INTO v_capital_account_id FROM public.accounts WHERE code = '2010';
    
    -- 3. جلب الفترة المالية المفتوحة الحالية
    SELECT id INTO v_fiscal_period_id FROM public.fiscal_periods 
    WHERE is_closed = false AND CURRENT_DATE BETWEEN start_date AND end_date
    LIMIT 1;

    IF v_fiscal_period_id IS NULL THEN
        RAISE EXCEPTION 'No open fiscal period found for current date';
    END IF;

    -- 4. بدء العملية المالية: إضافة سجل في حركة المستثمر
    -- (الـ Trigger tr_investor_ledger سيقوم بتحديث رصيد المستثمر تلقائياً)
    INSERT INTO public.investor_transactions (investor_id, amount, type, description)
    VALUES (p_investor_id, p_amount, 'deposit', p_description);

    -- 5. إنشاء القيد اليومي المحاسبي
    INSERT INTO public.journal_entries (fiscal_period_id, description, source_type, source_id)
    VALUES (v_fiscal_period_id, 'Investor Deposit: ' || p_description, 'investor_transaction', p_investor_id)
    RETURNING id INTO v_journal_id;

    -- سطر القيد المدين: البنك (Asset زيادة)
    INSERT INTO public.journal_entry_lines (journal_entry_id, account_id, debit, credit)
    VALUES (v_journal_id, v_cash_account_id, p_amount, 0);

    -- سطر القيد الدائن: رأس مال المستثمرين (Liability زيادة)
    INSERT INTO public.journal_entry_lines (journal_entry_id, account_id, debit, credit)
    VALUES (v_journal_id, v_capital_account_id, 0, p_amount);

    -- 6. تسجيل العملية في سجل الرقابة
    INSERT INTO public.audit_logs (profile_id, event_type, table_name, record_id, new_values)
    VALUES (auth.uid(), 'INVESTOR_DEPOSIT', 'investor_transactions', p_investor_id, 
            jsonb_build_object('amount', p_amount, 'investor_id', p_investor_id));

    -- 7. إنشاء تنبيه للنظام
    INSERT INTO public.notifications (profile_id, title, content, type)
    VALUES (auth.uid(), 'Capital Deposit Processed', 'Amount: ' || p_amount || ' for investor ' || p_investor_id, 'info');

    RETURN jsonb_build_object('success', true, 'journal_id', v_journal_id);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 3. وظيفة معالجة سحب أموال المستثمر
-- ############################################################################
CREATE OR REPLACE FUNCTION public.process_investor_withdrawal(
    p_investor_id UUID,
    p_amount DECIMAL(15,2),
    p_description TEXT
)
RETURNS JSONB AS $$
DECLARE
    v_available_balance DECIMAL(15,2);
    v_journal_id UUID;
    v_cash_account_id UUID;
    v_capital_account_id UUID;
    v_fiscal_period_id UUID;
BEGIN
    -- 1. التحقق من الصلاحيات
    IF NOT public.has_permission('manage_investors') THEN
        RAISE EXCEPTION 'Unauthorized';
    END IF;

    -- 2. التحقق من سيولة المستثمر (Business Rule: Withdrawal <= Available)
    SELECT available_balance INTO v_available_balance FROM public.investors WHERE id = p_investor_id;
    IF v_available_balance < p_amount THEN
        RAISE EXCEPTION 'Insufficient liquidity: Investor only has % available', v_available_balance;
    END IF;

    -- 3. جلب البيانات المحاسبية
    SELECT id INTO v_cash_account_id FROM public.accounts WHERE code = '1010';
    SELECT id INTO v_capital_account_id FROM public.accounts WHERE code = '2010';
    SELECT id INTO v_fiscal_period_id FROM public.fiscal_periods 
    WHERE is_closed = false AND CURRENT_DATE BETWEEN start_date AND end_date LIMIT 1;

    -- 4. إضافة سجل السحب (الـ Trigger سيقلل رصيد المستثمر)
    INSERT INTO public.investor_transactions (investor_id, amount, type, description)
    VALUES (p_investor_id, p_amount, 'withdrawal', p_description);

    -- 5. إنشاء القيد اليومي (عكس الإيداع)
    INSERT INTO public.journal_entries (fiscal_period_id, description, source_type, source_id)
    VALUES (v_fiscal_period_id, 'Investor Withdrawal: ' || p_description, 'investor_transaction', p_investor_id)
    RETURNING id INTO v_journal_id;

    -- سطر القيد المدين: رأس المال (Liability نقصان)
    INSERT INTO public.journal_entry_lines (journal_entry_id, account_id, debit, credit)
    VALUES (v_journal_id, v_capital_account_id, p_amount, 0);

    -- سطر القيد الدائن: البنك (Asset نقصان)
    INSERT INTO public.journal_entry_lines (journal_entry_id, account_id, debit, credit)
    VALUES (v_journal_id, v_cash_account_id, 0, p_amount);

    -- 6. الرقابة والتنبيهات
    INSERT INTO public.audit_logs (profile_id, event_type, table_name, record_id, new_values)
    VALUES (auth.uid(), 'INVESTOR_WITHDRAWAL', 'investor_transactions', p_investor_id, 
            jsonb_build_object('amount', p_amount, 'investor_id', p_investor_id));

    RETURN jsonb_build_object('success', true, 'journal_id', v_journal_id);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
