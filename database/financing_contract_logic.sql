-- ############################################################################
-- PHASE 3.5: FINANCING CONTRACT SERVICE LOGIC
-- VERSION: 1.3.4 (Fixing RLS & Permissions for Funding Visibility)
-- ############################################################################

-- 1. التأكد من صلاحيات الوصول للموظفين والأدمن على جدول التمويل
-- هذا يضمن ظهور "المبلغ الممول" في لوحة تحكم الموظف
DO $$ 
BEGIN
    -- تمكين الـ RLS إذا لم يكن مفعلاً
    ALTER TABLE IF EXISTS public.contract_funding ENABLE ROW LEVEL SECURITY;

    -- حذف السياسات القديمة إن وجدت لتجنب التعارض
    DROP POLICY IF EXISTS "Employees can view all funding" ON public.contract_funding;
    DROP POLICY IF EXISTS "Investors can view their own funding" ON public.contract_funding;

    -- سياسة للموظفين والأدمن: رؤية كل شيء
    CREATE POLICY "Employees can view all funding" 
    ON public.contract_funding FOR SELECT 
    USING (
        EXISTS (
            SELECT 1 FROM public.profiles
            WHERE profiles.id = auth.uid() 
            AND profiles.role_id IN (SELECT id FROM public.roles WHERE slug IN ('admin', 'employee'))
        )
    );

    -- سياسة للمستثمر: رؤية تمويلاته فقط
    CREATE POLICY "Investors can view their own funding" 
    ON public.contract_funding FOR SELECT 
    USING (investor_id = auth.uid());
END $$;

-- 2. تحديث وظيفة تخصيص التمويل لضمان الدقة
DROP FUNCTION IF EXISTS public.allocate_contract_funding(UUID, UUID, DECIMAL);
DROP FUNCTION IF EXISTS public.allocate_contract_funding(UUID, UUID, NUMERIC);

CREATE OR REPLACE FUNCTION public.allocate_contract_funding(
    p_contract_id UUID,
    p_investor_id UUID,
    p_amount DECIMAL(15,2)
)
RETURNS JSONB AS $$
DECLARE
    v_available DECIMAL(15,2);
    v_principal DECIMAL(15,2);
    v_total_funded DECIMAL(15,2);
    v_res JSONB;
BEGIN
    IF public.is_financial_system_frozen() THEN RAISE EXCEPTION 'Financial operations are frozen'; END IF;
    
    -- جلب قيمة أصل العقد المطلوبة
    SELECT principal_amount INTO v_principal FROM public.financing_contracts WHERE id = p_contract_id FOR UPDATE;
    
    -- تحقق من رصيد المستثمر
    SELECT available_balance INTO v_available FROM public.investors WHERE id = p_investor_id FOR UPDATE;
    IF v_available < p_amount THEN
        RAISE EXCEPTION 'Insufficient investor balance';
    END IF;

    -- تسجيل التمويل في الجدول الوسيط
    INSERT INTO public.contract_funding (contract_id, investor_id, amount_allocated)
    VALUES (p_contract_id, p_investor_id, p_amount);

    -- تسجيل المعاملة المالية للمستثمر (خصم من الرصيد المتاح)
    INSERT INTO public.investor_transactions (investor_id, amount, type, reference_id, description, status)
    VALUES (p_investor_id, -p_amount, 'contract_allocation', p_contract_id, 'Funding for contract', 'finalized');

    -- تحديث أرصدة المستثمر (نقل من المتاح إلى المشغل)
    UPDATE public.investors 
    SET available_balance = available_balance - p_amount,
        deployed_capital = deployed_capital + p_amount
    WHERE id = p_investor_id;

    -- حساب إجمالي المبالغ التي تم تخصيصها للعقد حتى الآن
    SELECT COALESCE(SUM(amount_allocated), 0) INTO v_total_funded 
    FROM public.contract_funding 
    WHERE contract_id = p_contract_id;

    -- إذا اكتمل التمويل (أو تجاوزه)، قم بتفعيل العقد تلقائياً
    IF v_total_funded >= v_principal THEN
        v_res := public.activate_financing_contract(p_contract_id);
        RETURN jsonb_build_object(
            'success', true, 
            'activated', true, 
            'activation_details', v_res,
            'message', 'Contract fully funded and activated'
        );
    END IF;

    RETURN jsonb_build_object(
        'success', true, 
        'activated', false, 
        'funded_amount', v_total_funded, 
        'total_required', v_principal,
        'message', 'Funding allocated successfully'
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
