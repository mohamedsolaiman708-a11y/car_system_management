-- ############################################################################
-- PHASE 3.5: FINANCING CONTRACT SERVICE LOGIC
-- VERSION: 1.2.9 (Senior Guard: Final Clean & Universal Payments)
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

-- تحديث هيكل الجداول لضمان التوافق الشامل
ALTER TABLE public.installments ADD COLUMN IF NOT EXISTS paid_amount DECIMAL(15,2) DEFAULT 0.00;
ALTER TABLE public.payments ADD COLUMN IF NOT EXISTS notes TEXT;
ALTER TABLE public.payments ALTER COLUMN status TYPE TEXT;

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

-- 3. تفعيل العقد (Activate Contract - Smart Duration)
CREATE OR REPLACE FUNCTION public.activate_financing_contract(
    p_contract_id UUID
)
RETURNS JSONB AS $$
DECLARE
    v_contract RECORD;
    v_installment_amount DECIMAL(15,2);
    v_fiscal_id UUID;
    v_safe_duration INTEGER;
BEGIN
    IF public.is_financial_system_frozen() THEN RAISE EXCEPTION 'Financial operations are frozen'; END IF;

    SELECT * INTO v_contract FROM public.financing_contracts WHERE id = p_contract_id FOR UPDATE;
    
    -- [Senior Guard]: حماية القسمة على صفر بجعل الحد الأدنى شهر واحد
    v_safe_duration := GREATEST(COALESCE(v_contract.duration_months, 1), 1);

    SELECT id INTO v_fiscal_id FROM public.fiscal_periods WHERE is_closed = false AND CURRENT_DATE BETWEEN start_date AND end_date LIMIT 1;
    if v_fiscal_id IS NULL THEN RAISE EXCEPTION 'No open fiscal period found'; END IF;

    v_installment_amount := ROUND(v_contract.total_contract_value / v_safe_duration, 2);
    
    FOR i IN 1..v_safe_duration LOOP
        INSERT INTO public.installments (contract_id, due_date, expected_amount, principal_component, profit_component, status)
        VALUES (p_contract_id, COALESCE(v_contract.start_date, CURRENT_DATE) + (i || ' month')::interval, v_installment_amount, 0, 0, 'unpaid');
    END LOOP;

    UPDATE public.financing_contracts SET status = 'active', updated_at = NOW() WHERE id = p_contract_id;
    RETURN jsonb_build_object('success', true, 'contract_no', v_contract.contract_no);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 4. معالجة سداد الأقساط (Process Installment Payment - Unified V1.2.9)
CREATE OR REPLACE FUNCTION public.process_installment_payment(
    p_contract_id UUID,
    p_amount_paid DECIMAL(15,2),
    p_payment_method TEXT,
    p_reference_no TEXT DEFAULT NULL,
    p_notes TEXT DEFAULT NULL
)
RETURNS JSONB AS $$
DECLARE
    v_remaining DECIMAL(15,2);
    v_inst RECORD;
    v_payment_id UUID;
    v_contract_no TEXT;
BEGIN
    SELECT contract_no INTO v_contract_no FROM public.financing_contracts WHERE id = p_contract_id;
    
    INSERT INTO public.payments (contract_id, amount_total, payment_method, reference_no, notes, status)
    VALUES (p_contract_id, p_amount_paid, p_payment_method, p_reference_no, p_notes, 'completed')
    RETURNING id INTO v_payment_id;

    v_remaining := p_amount_paid;
    FOR v_inst IN (SELECT id, expected_amount, COALESCE(paid_amount, 0) as current_paid FROM public.installments WHERE contract_id = p_contract_id AND status != 'paid' ORDER BY due_date ASC) LOOP
        EXIT WHEN v_remaining <= 0;
        
        UPDATE public.installments 
        SET paid_amount = current_paid + LEAST(v_remaining, (expected_amount - current_paid)), 
            status = CASE 
                WHEN (current_paid + LEAST(v_remaining, (expected_amount - current_paid))) >= expected_amount THEN 'paid'::public.installment_status 
                ELSE 'partially_paid'::public.installment_status 
            END,
            updated_at = NOW()
        WHERE id = v_inst.id;

        v_remaining := v_remaining - LEAST(v_remaining, (v_inst.expected_amount - v_inst.current_paid));
    END LOOP;

    RETURN jsonb_build_object('success', true, 'payment_id', v_payment_id);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
