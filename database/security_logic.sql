-- ############################################################################
-- PHASE 3.1: AUTHENTICATION & AUTHORIZATION LOGIC - ROBUST RESET (FIXED)
-- ############################################################################

-- 1. Helper Functions
-- ############################################################################

DROP FUNCTION IF EXISTS public.has_permission(TEXT) CASCADE;
DROP FUNCTION IF EXISTS public.get_my_role() CASCADE;

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

CREATE OR REPLACE FUNCTION public.has_permission(p_permission_slug TEXT)
RETURNS BOOLEAN AS $$
DECLARE
    v_role_slug TEXT;
BEGIN
    SELECT r.slug INTO v_role_slug
    FROM public.profiles p
    JOIN public.roles r ON p.role_id = r.id
    WHERE p.id = auth.uid() AND p.is_active = true;

    IF v_role_slug = 'admin' THEN
        RETURN true;
    END IF;

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

CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
DECLARE
    v_role_id UUID;
    v_invitation RECORD;
BEGIN
    SELECT * INTO v_invitation 
    FROM public.user_invitations 
    WHERE email = NEW.email 
      AND accepted_at IS NULL 
      AND expires_at > NOW()
    LIMIT 1;

    IF v_invitation.id IS NOT NULL THEN
        v_role_id := v_invitation.role_id;
        
        INSERT INTO public.profiles (id, role_id, full_name, is_active, status)
        VALUES (
            NEW.id, 
            v_role_id, 
            COALESCE(NEW.raw_user_meta_data->>'full_name', 'New Staff'),
            true,
            'approved'::public.registration_status
        );

        UPDATE public.user_invitations 
        SET accepted_at = NOW() 
        WHERE id = v_invitation.id;
    ELSE
        SELECT id INTO v_role_id FROM public.roles WHERE slug = 'investor';
        
        INSERT INTO public.profiles (id, role_id, full_name, is_active, status)
        VALUES (
            NEW.id, 
            v_role_id, 
            COALESCE(NEW.raw_user_meta_data->>'full_name', 'New User'),
            true,
            'pending'::public.registration_status
        );
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- 3. Initial Seeding (تحديث الأدوار لدعم المبيعات والمحاسبة)
-- ############################################################################

INSERT INTO public.roles (name, slug) VALUES 
('المدير العام', 'admin'),
('مسؤول المبيعات', 'sales'),
('المحاسب المالي', 'accountant'),
('مستثمر', 'investor')
ON CONFLICT (slug) DO UPDATE SET name = EXCLUDED.name;

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
('View Inventory', 'view_inventory'),
('Manage Settings', 'manage_settings')
ON CONFLICT (slug) DO NOTHING;

-- منح كافة الصلاحيات للمسؤول
INSERT INTO public.role_permissions (role_id, permission_id)
SELECT r.id, p.id FROM public.roles r, public.permissions p WHERE r.slug = 'admin'
ON CONFLICT DO NOTHING;

-- منح صلاحيات المبيعات
INSERT INTO public.role_permissions (role_id, permission_id)
SELECT r.id, p.id FROM public.roles r, public.permissions p 
WHERE r.slug = 'sales' AND p.slug IN ('view_inventory', 'view_customers', 'manage_customers', 'create_contracts')
ON CONFLICT DO NOTHING;

-- منح صلاحيات المحاسبة
INSERT INTO public.role_permissions (role_id, permission_id)
SELECT r.id, p.id FROM public.roles r, public.permissions p 
WHERE r.slug = 'accountant' AND p.slug IN ('view_investors', 'process_payments', 'view_accounting', 'view_customers')
ON CONFLICT DO NOTHING;
