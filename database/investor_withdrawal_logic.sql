-- ############################################################################
-- INVESTOR WITHDRAWAL REQUESTS LOGIC
-- ############################################################################

CREATE TYPE public.request_status AS ENUM ('pending', 'approved', 'rejected', 'cancelled');

CREATE TABLE IF NOT EXISTS public.withdrawal_requests (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    investor_id UUID REFERENCES public.investors(id) NOT NULL,
    amount DECIMAL(15,2) NOT NULL CHECK (amount > 0),
    bank_account_details TEXT, -- تفاصيل الحساب البنكي للتحويل
    status public.request_status DEFAULT 'pending',
    rejection_reason TEXT,
    processed_at TIMESTAMPTZ,
    processed_by UUID REFERENCES public.profiles(id),
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- وظيفة للمستثمر لطلب سحب
CREATE OR REPLACE FUNCTION public.request_withdrawal(
    p_amount DECIMAL(15,2),
    p_bank_details TEXT
) RETURNS UUID AS $$
DECLARE
    v_available DECIMAL(15,2);
    v_request_id UUID;
BEGIN
    -- 1. التحقق من الرصيد المتاح
    SELECT available_balance INTO v_available FROM public.investors WHERE id = auth.uid();
    
    IF v_available < p_amount THEN
        RAISE EXCEPTION 'Insufficient balance: You only have % available', v_available;
    END IF;

    -- 2. إنشاء الطلب
    INSERT INTO public.withdrawal_requests (investor_id, amount, bank_account_details)
    VALUES (auth.uid(), p_amount, p_bank_details)
    RETURNING id INTO v_request_id;

    -- 3. تنبيه الإدارة
    INSERT INTO public.notifications (profile_id, title, content, type)
    SELECT p.id, '💰 طلب سحب جديد', 'المستثمر طلب سحب مبلغ ' || p_amount || ' ر.س', 'info'
    FROM public.profiles p JOIN public.roles r ON p.role_id = r.id WHERE r.slug = 'admin';

    RETURN v_request_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- وظيفة للإدارة للموافقة على السحب وتنفيذه محاسبياً
CREATE OR REPLACE FUNCTION public.approve_withdrawal_request(p_request_id UUID)
RETURNS JSONB AS $$
DECLARE
    v_req RECORD;
BEGIN
    IF NOT public.has_permission('manage_investors') THEN RAISE EXCEPTION 'Unauthorized'; END IF;

    SELECT * INTO v_req FROM public.withdrawal_requests WHERE id = p_request_id FOR UPDATE;
    IF v_req.status != 'pending' THEN RAISE EXCEPTION 'Request already processed'; END IF;

    -- تنفيذ السحب المالي (باستخدام الـ RPC الموحد الذي يدعم المحاسبة والـ Idempotency)
    PERFORM public.process_investor_withdrawal(
        v_req.investor_id, 
        v_req.amount, 
        'Withdrawal Request Approved: ' || p_request_id,
        p_request_id::text
    );

    -- تحديث حالة الطلب
    UPDATE public.withdrawal_requests 
    SET status = 'approved', processed_at = NOW(), processed_by = auth.uid()
    WHERE id = p_request_id;

    RETURN jsonb_build_object('success', true);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
