-- ############################################################################
-- PHASE 3.5: FINANCING CONTRACT SERVICE LOGIC
-- ############################################################################

-- 1. تحديث الحسابات المحاسبية اللازمة لعقود التمويل
-- ############################################################################
INSERT INTO public.accounts (code, name, type, is_reconcilable)
VALUES 
('1020', 'Contracts Receivable', 'asset', true),
('2020', 'Investor Payable - Principal', 'liability', true),
('4010', 'Unearned Finance Profit', 'liability', false)
ON CONFLICT (code) DO NOTHING;

-- 2. تحديث الـ Trigger الخاص بالمخزون لدعم حالة الحجز (Reserved)
-- ############################################################################
CREATE OR REPLACE FUNCTION public.sync_inventory_asset_v2()
RETURNS TRIGGER AS $$
BEGIN
    IF (NEW.status = 'active') THEN
        UPDATE public.inventory_items SET status = 'on_contract' WHERE id = NEW.inventory_item_id;
    ELSIF (NEW.status = 'pending_funding') THEN
        UPDATE public.inventory_items SET status = 'available' WHERE id = NEW.inventory_item_id; -- يمكن تغييرها لـ reserved مستقبلاً
    ELSIF (NEW.status IN ('closed', 'defaulted')) THEN
        UPDATE public.inventory_items SET status = 'available' WHERE id = NEW.inventory_item_id;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 3. وظيفة تخصيص تمويل للعقد (Allocate Funding)
-- ############################################################################
CREATE OR REPLACE FUNCTION public.allocate_contract_funding(
    p_contract_id UUID,
    p_investor_id UUID,
    p_amount DECIMAL(15,2)
)
RETURNS VOID AS $$
DECLARE
    v_available DECIMAL(15,2);
BEGIN
    -- التحقق من السيولة
    SELECT available_balance INTO v_available FROM public.investors WHERE id = p_investor_id;
    IF v_available < p_amount THEN
        RAISE EXCEPTION 'Insufficient investor balance';
    END IF;

    -- إضافة سجل التخصيص
    INSERT INTO public.contract_funding (contract_id, investor_id, amount_allocated)
    VALUES (p_contract_id, p_investor_id, p_amount);

    -- تسجيل حركة مالية للمستثمر (ستقوم الـ Trigger tr_investor_ledger بنقل المبلغ من المتاح إلى المستثمر)
    INSERT INTO public.investor_transactions (investor_id, amount, type, reference_id, description)
    VALUES (p_investor_id, p_amount, 'contract_allocation', p_contract_id, 'Funding for contract: ' || p_contract_id);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 4. الوظيفة الكبرى: تفعيل العقد (Activate Contract)
-- ############################################################################
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
BEGIN
    -- 1. جلب بيانات العقد
    SELECT * INTO v_contract FROM public.financing_contracts WHERE id = p_contract_id;
    IF v_contract.status != 'draft' AND v_contract.status != 'pending_funding' THEN
        RAISE EXCEPTION 'Contract is already active or closed';
    END IF;

    -- 2. التحقق من اكتمال التمويل
    SELECT COALESCE(SUM(amount_allocated), 0) INTO v_total_funded 
    FROM public.contract_funding WHERE contract_id = p_contract_id;
    
    IF v_total_funded != v_contract.principal_amount THEN
        RAISE EXCEPTION 'Funding incomplete: Required %, Found %', v_contract.principal_amount, v_total_funded;
    END IF;

    -- 3. جلب الفترة المالية
    SELECT id INTO v_fiscal_id FROM public.fiscal_periods WHERE is_closed = false AND CURRENT_DATE BETWEEN start_date AND end_date LIMIT 1;
    IF v_fiscal_id IS NULL THEN RAISE EXCEPTION 'No open fiscal period'; END IF;

    -- 4. حساب مبالغ الأقساط (تبسيط: قسط متساوي)
    v_installment_amount := v_contract.total_contract_value / v_contract.duration_months;
    v_principal_per_inst := v_contract.principal_amount / v_contract.duration_months;
    v_profit_per_inst := (v_contract.total_contract_value - v_contract.principal_amount) / v_contract.duration_months;

    -- 5. توليد جدول الأقساط
    FOR v_i IN 1..v_contract.duration_months LOOP
        INSERT INTO public.installments (contract_id, due_date, expected_amount, principal_component, profit_component)
        VALUES (
            p_contract_id, 
            COALESCE(v_contract.start_date, CURRENT_DATE) + (v_i || ' month')::interval,
            v_installment_amount,
            v_principal_per_inst,
            v_profit_per_inst
        );
    END LOOP;

    -- 6. إنشاء القيد المحاسبي المزدوج
    INSERT INTO public.journal_entries (fiscal_period_id, description, source_type, source_id)
    VALUES (v_fiscal_id, 'Activation of Contract: ' || v_contract.contract_no, 'financing_contract', p_contract_id)
    RETURNING id INTO v_journal_id;

    -- مدين: ذمم عقود التمويل (إجمالي القيمة)
    INSERT INTO public.journal_entry_lines (journal_entry_id, account_id, debit, credit)
    VALUES (v_journal_id, (SELECT id FROM public.accounts WHERE code = '1020'), v_contract.total_contract_value, 0);

    -- دائن: التزامات للمستثمرين (أصل المبلغ)
    INSERT INTO public.journal_entry_lines (journal_entry_id, account_id, debit, credit)
    VALUES (v_journal_id, (SELECT id FROM public.accounts WHERE code = '2020'), v_contract.principal_amount, v_contract.principal_amount);

    -- دائن: أرباح مؤجلة (إجمالي الربح)
    INSERT INTO public.journal_entry_lines (journal_entry_id, account_id, debit, credit)
    VALUES (v_journal_id, (SELECT id FROM public.accounts WHERE code = '4010'), 0, (v_contract.total_contract_value - v_contract.principal_amount));

    -- 7. تحديث حالة العقد
    UPDATE public.financing_contracts SET status = 'active', updated_at = NOW() WHERE id = p_contract_id;

    -- 8. الرقابة
    INSERT INTO public.audit_logs (profile_id, event_type, table_name, record_id, new_values)
    VALUES (auth.uid(), 'CONTRACT_ACTIVATED', 'financing_contracts', p_contract_id, jsonb_build_object('status', 'active'));

    RETURN jsonb_build_object('success', true, 'contract_no', v_contract.contract_no);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
