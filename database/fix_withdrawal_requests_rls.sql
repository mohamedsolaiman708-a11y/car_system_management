-- ============================================================================
-- FIX: طلبات السحب مش بتظهر للأدمن والموظفين
-- السبب: تعارض سياسات RLS مع صلاحيات role_permissions
-- الحل: إصلاح شامل للسياسات + التحقق من الصلاحيات
-- شغّل هذا الملف في Supabase SQL Editor → New Query → Run
-- ============================================================================

-- ============================================================
-- STEP 1: فحص المشكلة أولاً (قراءة فقط)
-- ============================================================

-- فحص هل السياسات موجودة على الجدول
SELECT schemaname, tablename, policyname, cmd, qual
FROM pg_policies
WHERE tablename = 'withdrawal_requests'
ORDER BY policyname;

-- فحص هل الأدمن يملك صلاحية manage_investors
SELECT r.slug as role, p.slug as permission
FROM public.roles r
JOIN public.role_permissions rp ON r.id = rp.role_id
JOIN public.permissions p ON rp.permission_id = p.id
WHERE r.slug IN ('admin', 'manager', 'accountant')
AND p.slug IN ('manage_investors', 'view_investors')
ORDER BY r.slug, p.slug;

-- ============================================================
-- STEP 2: التأكد من وجود الصلاحيات للأدوار المختلفة
-- ============================================================

-- الأدمن يملك كل الصلاحيات
INSERT INTO public.role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM public.roles r, public.permissions p
WHERE r.slug = 'admin'
ON CONFLICT DO NOTHING;

-- المدير يملك صلاحيات التشغيل
INSERT INTO public.role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM public.roles r, public.permissions p
WHERE r.slug = 'manager'
  AND p.slug IN (
    'view_investors', 'manage_investors',
    'view_customers', 'manage_customers',
    'view_inventory', 'manage_inventory',
    'create_contracts', 'approve_contracts', 'process_payments',
    'view_accounting', 'view_audit_logs'
  )
ON CONFLICT DO NOTHING;

-- المحاسب يشاهد طلبات السحب
INSERT INTO public.role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM public.roles r, public.permissions p
WHERE r.slug = 'accountant'
  AND p.slug IN ('view_investors', 'view_accounting', 'process_payments', 'view_customers')
ON CONFLICT DO NOTHING;

-- ============================================================
-- STEP 3: إعادة بناء سياسات withdrawal_requests بشكل صحيح
-- ============================================================

-- حذف جميع السياسات القديمة المتعارضة
DROP POLICY IF EXISTS "withdrawals: investor own view"      ON public.withdrawal_requests;
DROP POLICY IF EXISTS "withdrawals: investor own create"    ON public.withdrawal_requests;
DROP POLICY IF EXISTS "withdrawals: staff manage"           ON public.withdrawal_requests;
DROP POLICY IF EXISTS "withdrawals: admin manage"           ON public.withdrawal_requests;
DROP POLICY IF EXISTS "Allow authenticated users full access to withdrawal_requests" ON public.withdrawal_requests;

-- التأكد من أن RLS مفعّل
ALTER TABLE public.withdrawal_requests ENABLE ROW LEVEL SECURITY;

-- [1] الأدمن والمدير: وصول كامل لكل الطلبات
CREATE POLICY "withdrawals: admin-manager full"
ON public.withdrawal_requests FOR ALL
TO authenticated
USING      (public.get_my_role() IN ('admin', 'manager'))
WITH CHECK (public.get_my_role() IN ('admin', 'manager'));

-- [2] الموظف صاحب صلاحية manage_investors: يشاهد ويعدّل كل الطلبات
CREATE POLICY "withdrawals: staff view"
ON public.withdrawal_requests FOR SELECT
TO authenticated
USING (public.has_permission('manage_investors') OR public.has_permission('view_investors'));

CREATE POLICY "withdrawals: staff update"
ON public.withdrawal_requests FOR UPDATE
TO authenticated
USING (public.has_permission('manage_investors'));

-- [3] المحاسب: يشاهد فقط
CREATE POLICY "withdrawals: accountant view"
ON public.withdrawal_requests FOR SELECT
TO authenticated
USING (public.get_my_role() = 'accountant');

-- [4] المستثمر: يشاهد ويرسل طلباته الخاصة فقط
CREATE POLICY "withdrawals: investor own view"
ON public.withdrawal_requests FOR SELECT
TO authenticated
USING (investor_id = auth.uid());

CREATE POLICY "withdrawals: investor own create"
ON public.withdrawal_requests FOR INSERT
TO authenticated
WITH CHECK (investor_id = auth.uid());

-- ============================================================
-- STEP 4: التحقق النهائي - هل الطلبات موجودة في قاعدة البيانات؟
-- ============================================================
SELECT 
    wr.id,
    wr.investor_id,
    wr.amount,
    wr.status::TEXT,
    wr.created_at,
    COALESCE(i.full_name, 'غير معروف') as investor_name,
    COALESCE(p.email, '') as investor_email
FROM public.withdrawal_requests wr
LEFT JOIN public.investors i ON wr.investor_id = i.id
LEFT JOIN public.profiles p ON wr.investor_id = p.id
ORDER BY wr.created_at DESC
LIMIT 20;
