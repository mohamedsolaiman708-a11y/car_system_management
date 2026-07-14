-- ############################################################################
-- PHASE 3.5: FINANCING CONTRACT SERVICE LOGIC
-- VERSION: 1.3.1 (Fixing Missing Columns & Enum Casting)
-- ############################################################################

-- 1. ضمان وجود الحسابات والأعمدة المطلوبة
INSERT INTO public.accounts (code, name, type, is_reconcilable)
VALUES 
('1020', 'ذمم عقود التمويل', 'asset', true),
('2020', 'ذمم الممولين - أصل رأس المال', 'liability', true),
('4010', 'أرباح تمويل غير محققة', 'liability', false),
('1101', 'الصندوق / البنك', 'asset', true),
('4101', 'إيرادات تمويل محققة', 'revenue', false)
ON CONFLICT (code) DO NOTHING;

-- تحديث هيكل الجداول لضمان التوافق الشامل
ALTER TABLE public.installments ADD COLUMN IF NOT EXISTS paid_amount DECIMAL(15,2) DEFAULT 0.00;
ALTER TABLE public.installments ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ DEFAULT NOW();
ALTER TABLE public.payments ADD COLUMN IF NOT EXISTS notes TEXT;
ALTER TABLE public.payments ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ DEFAULT NOW();
ALTER TABLE public.payments ADD COLUMN IF NOT EXISTS status TEXT DEFAULT 'completed';
ALTER TABLE public.payments ADD COLUMN IF NOT EXISTS idempotency_key TEXT;

-- 2. وظيفة تخصيص تمويل للعقد (Allocate Funding)
CREATE OR REPLACE FUNCTION public.allocate_contract_funding(
    p_contract_id UUID,
    p_investor_id UUID,
    p_amount DECIMAL(15,2)
)
RETURNS VOID AS $$
DECLARE
    v_available DECIMAL(15,2);
BEGIN
    IF public.is_financial_system_frozen() THEN RAISE EXCEPTION 'Financial operations are frozen'; END IF;
    PERFORM 1 FROM public.financing_contracts WHERE id = p_contract_id FOR UPDATE;
    
    SELECT available_balance INTO v_available FROM public.investors WHERE id = p_investor_id FOR UPDATE;
    IF v_available < p_amount THEN
        RAISE EXCEPTION 'Insufficient investor balance';
    END IF;

    INSERT INTO public.contract_funding (contract_id, investor_id, amount_allocated)
    VALUES (p_contract_id, p_investor_id, p_amount);

    INSERT INTO public.investor_transactions (investor_id, amount, type, reference_id, description, status)
    VALUES (p_investor_id, p_amount, 'contract_allocation', p_contract_id, 'Funding for contract', 'finalized');
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 3. تفعيل العقد (Activate Contract - With Accounting)
CREATE OR REPLACE FUNCTION public.activate_financing_contract(
    p_contract_id UUID
)
RETURNS JSONB AS $$
DECLARE
    v_contract RECORD;
    v_installment_amount DECIMAL(15,2);
    v_principal_per_inst DECIMAL(15,2);
    v_profit_per_inst DECIMAL(15,2);
    v_fiscal_id UUID;
    v_safe_duration INTEGER;
    v_journal_id UUID;
    v_receivable_acc UUID;
    v_unearned_profit_acc UUID;
    v_capital_acc UUID;
BEGIN
    IF public.is_financial_system_frozen() THEN RAISE EXCEPTION 'Financial operations are frozen'; END IF;

    SELECT * INTO v_contract FROM public.financing_contracts WHERE id = p_contract_id FOR UPDATE;
    IF v_contract.status = 'active' THEN RETURN jsonb_build_object('success', true, 'message', 'Already active'); END IF;

    v_safe_duration := GREATEST(COALESCE(v_contract.duration_months, 1), 1);

    SELECT id INTO v_fiscal_id FROM public.fiscal_periods WHERE is_closed = false AND CURRENT_DATE BETWEEN start_date AND end_date LIMIT 1;
    IF v_fiscal_id IS NULL THEN RAISE EXCEPTION 'No open fiscal period found'; END IF;

    -- حسابات القيود
    SELECT id INTO v_receivable_acc FROM public.accounts WHERE code = '1020';
    SELECT id INTO v_unearned_profit_acc FROM public.accounts WHERE code = '4010';
    SELECT id INTO v_capital_acc FROM public.accounts WHERE code = '2020';

    -- حساب مكونات القسط
    v_installment_amount := ROUND(v_contract.total_contract_value / v_safe_duration, 2);
    v_profit_per_inst := ROUND((v_contract.total_contract_value - v_contract.principal_amount) / v_safe_duration, 2);
    v_principal_per_inst := v_installment_amount - v_profit_per_inst;
    
    -- 1. إنشاء الأقساط
    FOR i IN 1..v_safe_duration LOOP
        INSERT INTO public.installments (contract_id, due_date, expected_amount, principal_component, profit_component, status)
        VALUES (p_contract_id, COALESCE(v_contract.start_date, CURRENT_DATE) + (i || ' month')::interval, v_installment_amount, v_principal_per_inst, v_profit_per_inst, 'unpaid');
    END LOOP;

    -- 2. إنشاء القيد المحاسبي لافتتاح العقد
    INSERT INTO public.journal_entries (fiscal_period_id, description, source_type, source_id, reference_no)
    VALUES (v_fiscal_id, 'Activation of Contract: ' || v_contract.contract_no, 'financing_contract', p_contract_id, v_contract.contract_no)
    RETURNING id INTO v_journal_id;

    -- من حـ/ ذمم عقود التمويل (إجمالي العقد)
    INSERT INTO public.journal_entry_lines (journal_entry_id, account_id, debit, credit)
    VALUES (v_journal_id, v_receivable_acc, v_contract.total_contract_value, 0);

    -- إلى حـ/ أرباح تمويل غير محققة
    INSERT INTO public.journal_entry_lines (journal_entry_id, account_id, debit, credit)
    VALUES (v_journal_id, v_unearned_profit_acc, 0, (v_contract.total_contract_value - v_contract.principal_amount));

    -- إلى حـ/ ذمم الممولين (أصل رأس المال)
    INSERT INTO public.journal_entry_lines (journal_entry_id, account_id, debit, credit)
    VALUES (v_journal_id, v_capital_acc, 0, v_contract.principal_amount);

    UPDATE public.financing_contracts SET status = 'active', updated_at = NOW() WHERE id = p_contract_id;
    
    RETURN jsonb_build_object('success', true, 'contract_no', v_contract.contract_no, 'journal_id', v_journal_id);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 4. معالجة سداد الأقساط (Unified V1.3.1 - Fixed Updated_at and Casting)
CREATE OR REPLACE FUNCTION public.process_installment_payment(
    p_contract_id UUID,
    p_amount_paid DECIMAL(15,2),
    p_payment_method TEXT,
    p_reference_no TEXT DEFAULT NULL,
    p_notes TEXT DEFAULT NULL,
    p_idempotency_key TEXT DEFAULT NULL
)
RETURNS JSONB AS $$
DECLARE
    v_remaining DECIMAL(15,2);
    v_inst RECORD;
    v_payment_id UUID;
    v_contract RECORD;
    v_journal_id UUID;
    v_fiscal_id UUID;
    v_cash_acc UUID;
    v_receivable_acc UUID;
    v_unearned_profit_acc UUID;
    v_earned_profit_acc UUID;
    v_total_principal_paid DECIMAL(15,2) := 0;
    v_total_profit_paid DECIMAL(15,2) := 0;
    v_investor RECORD;
    v_investor_share_ratio DECIMAL(10,5);
BEGIN
    -- [A] Idempotency Guard
    IF p_idempotency_key IS NOT NULL THEN
        SELECT id INTO v_payment_id FROM public.payments WHERE idempotency_key = p_idempotency_key;
        IF v_payment_id IS NOT NULL THEN RETURN jsonb_build_object('success', true, 'message', 'Duplicate ignored', 'payment_id', v_payment_id); END IF;
    END IF;

    SELECT * INTO v_contract FROM public.financing_contracts WHERE id = p_contract_id FOR UPDATE;
    SELECT id INTO v_fiscal_id FROM public.fiscal_periods WHERE is_closed = false AND CURRENT_DATE BETWEEN start_date AND end_date LIMIT 1;
    
    IF v_fiscal_id IS NULL THEN RAISE EXCEPTION 'No open fiscal period found'; END IF;

    -- جلب الحسابات
    SELECT id INTO v_cash_acc FROM public.accounts WHERE code = '1101';
    SELECT id INTO v_receivable_acc FROM public.accounts WHERE code = '1020';
    SELECT id INTO v_unearned_profit_acc FROM public.accounts WHERE code = '4010';
    SELECT id INTO v_earned_profit_acc FROM public.accounts WHERE code = '4101';

    -- 1. تسجيل الدفعة
    INSERT INTO public.payments (contract_id, amount_total, payment_method, reference_no, notes, status, idempotency_key)
    VALUES (p_contract_id, p_amount_paid, p_payment_method, p_reference_no, p_notes, 'completed', p_idempotency_key)
    RETURNING id INTO v_payment_id;

    -- 2. توزيع المبلغ على الأقساط وحساب المكونات (أصل/ربح)
    v_remaining := p_amount_paid;
    FOR v_inst IN (SELECT * FROM public.installments WHERE contract_id = p_contract_id AND status != 'paid' ORDER BY due_date ASC) LOOP
        EXIT WHEN v_remaining <= 0;
        
        DECLARE
            v_pay_to_inst DECIMAL(15,2) := LEAST(v_remaining, (v_inst.expected_amount - v_inst.paid_amount));
            v_ratio DECIMAL(10,5) := CASE WHEN v_inst.expected_amount > 0 THEN v_pay_to_inst / v_inst.expected_amount ELSE 0 END;
        BEGIN
            UPDATE public.installments 
            SET paid_amount = paid_amount + v_pay_to_inst, 
                status = CASE 
                    WHEN (paid_amount + v_pay_to_inst) >= expected_amount THEN 'paid'::public.installment_status 
                    ELSE 'partially_paid'::public.installment_status 
                END,
                updated_at = NOW()
            WHERE id = v_inst.id;

            v_total_principal_paid := v_total_principal_paid + (v_inst.principal_component * v_ratio);
            v_total_profit_paid := v_total_profit_paid + (v_inst.profit_component * v_ratio);
            v_remaining := v_remaining - v_pay_to_inst;
        END;
    END LOOP;

    -- 3. إنشاء القيد المحاسبي للدفعة
    INSERT INTO public.journal_entries (fiscal_period_id, description, source_type, source_id, reference_no)
    VALUES (v_fiscal_id, 'Payment for Contract: ' || v_contract.contract_no, 'payment', v_payment_id, p_reference_no)
    RETURNING id INTO v_journal_id;

    -- Dr. Cash / Cr. Receivables
    INSERT INTO public.journal_entry_lines (journal_entry_id, account_id, debit, credit)
    VALUES (v_journal_id, v_cash_acc, p_amount_paid, 0), (v_journal_id, v_receivable_acc, 0, p_amount_paid);

    -- تحويل الأرباح (Dr. Unearned / Cr. Earned)
    IF v_total_profit_paid > 0 THEN
        INSERT INTO public.journal_entry_lines (journal_entry_id, account_id, debit, credit)
        VALUES (v_journal_id, v_unearned_profit_acc, v_total_profit_paid, 0), (v_journal_id, v_earned_profit_acc, 0, v_total_profit_paid);
    END IF;

    -- 4. توزيع المبالغ على المستثمرين
    FOR v_investor IN (SELECT * FROM public.contract_funding WHERE contract_id = p_contract_id) LOOP
        IF v_contract.principal_amount > 0 THEN
            v_investor_share_ratio := v_investor.amount_allocated / v_contract.principal_amount;
            
            DECLARE
                v_inv_principal DECIMAL(15,2) := ROUND(v_total_principal_paid * v_investor_share_ratio, 2);
                v_inv_profit DECIMAL(15,2) := ROUND(v_total_profit_paid * v_investor_share_ratio, 2);
            BEGIN
                INSERT INTO public.investor_transactions (investor_id, amount, type, reference_id, description)
                VALUES (v_investor.investor_id, v_inv_principal + v_inv_profit, 'finance_profit_distribution', v_payment_id, 'Installment return for contract ' || v_contract.contract_no);
                
                UPDATE public.investors 
                SET total_profit_earned = total_profit_earned + v_inv_profit,
                    deployed_capital = deployed_capital - v_inv_principal
                WHERE id = v_investor.investor_id;
            END;
        END IF;
    END LOOP;

    RETURN jsonb_build_object('success', true, 'payment_id', v_payment_id, 'journal_id', v_journal_id);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
