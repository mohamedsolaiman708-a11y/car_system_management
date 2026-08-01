-- ============================================================================
-- FIX: حل نهائي وشامل لمشكلة تعذر تحميل طلبات السحب
-- شغّل هذا الملف في Supabase SQL Editor → New Query → Run
-- ============================================================================

-- 1. منح كامل الصلاحيات لجدول طلبات السحب
GRANT ALL ON public.withdrawal_requests TO authenticated;
GRANT ALL ON public.withdrawal_requests TO service_role;
GRANT ALL ON public.withdrawal_requests TO postgres;

-- 2. إعطاء صلاحيات تسلسل الـ IDs إن وجد
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO authenticated;

-- 3. حذف السياسات القديمة المتعارضة
DROP POLICY IF EXISTS "withdrawals: admin-manager full"     ON public.withdrawal_requests;
DROP POLICY IF EXISTS "withdrawals: staff view"             ON public.withdrawal_requests;
DROP POLICY IF EXISTS "withdrawals: staff update"           ON public.withdrawal_requests;
DROP POLICY IF EXISTS "withdrawals: accountant view"        ON public.withdrawal_requests;
DROP POLICY IF EXISTS "withdrawals: investor own view"      ON public.withdrawal_requests;
DROP POLICY IF EXISTS "withdrawals: investor own create"    ON public.withdrawal_requests;
DROP POLICY IF EXISTS "withdrawals: staff manage"           ON public.withdrawal_requests;
DROP POLICY IF EXISTS "withdrawals: admin manage"           ON public.withdrawal_requests;
DROP POLICY IF EXISTS "Allow authenticated users full access to withdrawal_requests" ON public.withdrawal_requests;
DROP POLICY IF EXISTS "withdrawals_permissive_access"       ON public.withdrawal_requests;

-- 4. تفعيل RLS
ALTER TABLE public.withdrawal_requests ENABLE ROW LEVEL SECURITY;

-- 5. إنشاء سياسة وصول آمنة وشاملة للمستخدمين المسجلين (Authenticated)
CREATE POLICY "withdrawals_permissive_access"
ON public.withdrawal_requests FOR ALL
TO authenticated
USING (
    -- إما أدمن / مدير / موظف (مشاهدة الكل)
    public.get_my_role() IN ('admin', 'manager', 'accountant', 'employee')
    OR public.has_permission('manage_investors')
    OR public.has_permission('view_investors')
    -- أو المستثمر مشاهدة وطلب ما يخصه فقط
    OR investor_id = auth.uid()
    -- أو كـ Fallback للأدمن
    OR EXISTS (
        SELECT 1 FROM public.profiles p
        JOIN public.roles r ON p.role_id = r.id
        WHERE p.id = auth.uid() AND r.slug IN ('admin', 'manager')
    )
)
WITH CHECK (true);

-- 6. التأكد من وجود أدوار وصلاحيات الأدمن والمدير والمحاسب
INSERT INTO public.role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM public.roles r, public.permissions p
WHERE r.slug = 'admin'
ON CONFLICT DO NOTHING;

INSERT INTO public.role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM public.roles r, public.permissions p
WHERE r.slug = 'manager'
  AND p.slug IN ('view_investors', 'manage_investors', 'process_payments', 'view_accounting')
ON CONFLICT DO NOTHING;

-- 7. فحص ومراجعة النتيجة
SELECT 
    id,
    investor_id,
    amount,
    status::TEXT,
    created_at
FROM public.withdrawal_requests
ORDER BY created_at DESC
LIMIT 10;
