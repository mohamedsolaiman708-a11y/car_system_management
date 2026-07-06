-- ############################################################################
-- PHASE 3.1: AUTHENTICATION & AUTHORIZATION - EXTENDED
-- ############################################################################

-- وظيفة لجلب بروفايل المستخدم الحالي مع صلاحياته
CREATE OR REPLACE FUNCTION public.get_current_user_profile()
RETURNS JSONB AS $$
DECLARE
    v_profile RECORD;
BEGIN
    SELECT 
        p.id,
        p.full_name,
        p.is_active,
        r.name as role_name,
        r.slug as role_slug,
        COALESCE(
            jsonb_agg(perm.slug) FILTER (WHERE perm.slug IS NOT NULL), 
            '[]'::jsonb
        ) as permissions
    INTO v_profile
    FROM public.profiles p
    LEFT JOIN public.roles r ON p.role_id = r.id
    LEFT JOIN public.role_permissions rp ON r.id = rp.role_id
    LEFT JOIN public.permissions perm ON rp.permission_id = perm.id
    WHERE p.id = auth.uid()
    GROUP BY p.id, r.id;

    IF v_profile IS NULL THEN
        RETURN NULL;
    END IF;

    return row_to_json(v_profile)::jsonb;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- تطبيق سياسات الأمان (RLS) المتقدمة بناءً على الصلاحيات
-- ############################################################################

-- 1. العملاء (Customers)
DROP POLICY IF EXISTS "Staff full access" ON public.customers;
CREATE POLICY "View Customers" ON public.customers FOR SELECT 
USING (public.has_permission('view_customers') OR public.has_permission('manage_customers'));

CREATE POLICY "Manage Customers" ON public.customers FOR ALL
USING (public.has_permission('manage_customers'));

-- 2. المخزون (Inventory)
DROP POLICY IF EXISTS "Staff full access" ON public.inventory_items;
CREATE POLICY "View Inventory" ON public.inventory_items FOR SELECT 
USING (public.has_permission('view_inventory') OR public.has_permission('manage_inventory'));

CREATE POLICY "Manage Inventory" ON public.inventory_items FOR ALL
USING (public.has_permission('manage_inventory'));

-- 3. المستندات (Documents)
ALTER TABLE public.contract_documents ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Manage Documents" ON public.contract_documents FOR ALL
USING (public.has_permission('manage_contracts'));
