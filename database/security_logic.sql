-- ############################################################################
-- PHASE 3.1: AUTHENTICATION & AUTHORIZATION LOGIC - ROBUST RESET (FIXED)
-- ############################################################################

-- 1. Helper Functions (إعادة بناء شاملة باستخدام CASCADE لحل مشكلة التبعيات)
-- ############################################################################

-- HINT: نستخدم CASCADE هنا لأن السياسات (Policies) تعتمد على هذه الدوال
DROP FUNCTION IF EXISTS public.has_permission(TEXT) CASCADE;
DROP FUNCTION IF EXISTS public.get_my_role() CASCADE;

-- جلب "Slug" الدور الخاص بالمستخدم الحالي
CREATE OR REPLACE FUNCTION public.get_my_role()
RETURNS TEXT AS $$
BEGIN
    RETURN (
        SELECT r.slug 
        FROM public.profiles p
        JOIN public.roles r ON p.role_id = r.id
        WHERE p.id = auth.uid()
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- التحقق مما إذا كان المستخدم يملك صلاحية معينة
CREATE OR REPLACE FUNCTION public.has_permission(p_permission_slug TEXT)
RETURNS BOOLEAN AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1 
        FROM public.profiles p
        JOIN public.roles r ON p.role_id = r.id
        JOIN public.role_permissions rp ON r.id = rp.role_id
        JOIN public.permissions perm ON rp.permission_id = perm.id
        WHERE p.id = auth.uid() 
        AND perm.slug = p_permission_slug
        AND p.is_active = true
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 2. Profile Management Triggers
-- ############################################################################

-- وظيفة إنشاء الملف الشخصي تلقائياً عند تسجيل مستخدم جديد
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
DECLARE
    v_role_id UUID;
    v_role_slug TEXT;
BEGIN
    -- استخراج الدور من البيانات الوصفية أو تعيينه كـ 'investor' افتراضياً
    v_role_slug := COALESCE(NEW.raw_user_meta_data->>'role', 'investor');
    
    SELECT id INTO v_role_id FROM public.roles WHERE slug = v_role_slug;
    
    -- في حالة عدم وجود الدور، نستخدم 'investor' كخيار أمان
    IF v_role_id IS NULL THEN
        SELECT id INTO v_role_id FROM public.roles WHERE slug = 'investor';
    END IF;

    INSERT INTO public.profiles (id, role_id, full_name, is_active)
    VALUES (
        NEW.id, 
        v_role_id, 
        COALESCE(NEW.raw_user_meta_data->>'full_name', 'New User'),
        true
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- إعادة ضبط الـ Trigger
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- وظيفة تتبع آخر ظهور للمستخدم
CREATE OR REPLACE FUNCTION public.track_user_login()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE public.profiles 
    SET last_login = NOW() 
    WHERE id = auth.uid();
    RETURN NULL;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 3. Initial Seeding (إعداد البيانات الأساسية للأدوار والصلاحيات)
-- ############################################################################

INSERT INTO public.roles (name, slug) VALUES 
('System Administrator', 'admin'),
('Operations Manager', 'manager'),
('Chief Accountant', 'accountant'),
('Investor', 'investor')
ON CONFLICT (slug) DO NOTHING;

INSERT INTO public.permissions (name, slug) VALUES 
('View Investors', 'view_investors'),
('Manage Investors', 'manage_investors'),
('Manage Inventory', 'manage_inventory'),
('Create Contracts', 'create_contracts'),
('Approve Contracts', 'approve_contracts'),
('Process Payments', 'process_payments'),
('View Audit Logs', 'view_audit_logs'),
('View Accounting', 'view_accounting'),
('View Customers', 'view_customers'),
('Manage Customers', 'manage_customers'),
('View Inventory', 'view_inventory')
ON CONFLICT (slug) DO NOTHING;

-- منح كافة الصلاحيات للمسؤول (Admin)
INSERT INTO public.role_permissions (role_id, permission_id)
SELECT r.id, p.id FROM public.roles r, public.permissions p WHERE r.slug = 'admin'
ON CONFLICT DO NOTHING;

-- منح صلاحيات محاسبية محددة للمحاسب
INSERT INTO public.role_permissions (role_id, permission_id)
SELECT r.id, p.id FROM public.roles r, public.permissions p 
WHERE r.slug = 'accountant' AND p.slug IN ('view_investors', 'process_payments', 'view_accounting', 'view_customers')
ON CONFLICT DO NOTHING;

-- 4. Re-applying Core RLS Policies (إعادة بناء السياسات التي حذفت بسبب CASCADE)
-- ############################################################################

-- سياسات المستثمرين (Investors)
CREATE POLICY "Permission-based view" ON public.investors FOR SELECT 
TO authenticated USING (public.has_permission('view_investors'));

CREATE POLICY "Permission-based management" ON public.investors FOR ALL 
TO authenticated USING (public.has_permission('manage_investors'));

-- سياسات العملاء (Customers)
CREATE POLICY "View Customers" ON public.customers FOR SELECT 
TO authenticated USING (public.has_permission('view_customers'));

CREATE POLICY "Manage Customers" ON public.customers FOR ALL 
TO authenticated USING (public.has_permission('manage_customers'));

-- سياسات المخزون (Inventory)
CREATE POLICY "View Inventory" ON public.inventory_items FOR SELECT 
TO authenticated USING (public.has_permission('view_inventory'));

CREATE POLICY "Manage Inventory" ON public.inventory_items FOR ALL 
TO authenticated USING (public.has_permission('manage_inventory'));

-- سياسة المستندات (Documents)
CREATE POLICY "Manage Documents" ON public.contract_documents FOR ALL
TO authenticated USING (public.has_permission('approve_contracts'));
