-- ############################################################################
-- AUDIT LOGS AND DOCUMENTS SCHEMA
-- ############################################################################

-- 1. Global Audit Logs Table
CREATE TABLE IF NOT EXISTS public.audit_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    profile_id UUID REFERENCES public.profiles(id),
    event_type TEXT NOT NULL, -- e.g., 'CUSTOMER_CREATED', 'CONTRACT_ACTIVATED'
    table_name TEXT,
    record_id UUID,
    old_values JSONB,
    new_values JSONB,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 2. Contract Documents Table
CREATE TABLE IF NOT EXISTS public.contract_documents (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    contract_id UUID REFERENCES public.financing_contracts(id) ON DELETE CASCADE,
    customer_id UUID REFERENCES public.customers(id) ON DELETE CASCADE,
    document_type TEXT NOT NULL, -- 'NATIONAL_ID', 'SALARY_LETTER', 'CONTRACT_SCAN', etc.
    file_path TEXT NOT NULL, -- Storage path
    file_name TEXT NOT NULL,
    uploaded_by UUID REFERENCES public.profiles(id),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 3. RLS Policies
ALTER TABLE public.audit_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.contract_documents ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Admins/Managers can view audit logs" ON public.audit_logs
FOR SELECT USING (public.has_permission('view_audit_logs'));

CREATE POLICY "Staff can manage documents" ON public.contract_documents
FOR ALL USING (public.has_permission('manage_contracts') OR public.has_permission('manage_customers'));

-- 4. Function to log activity (Helper)
CREATE OR REPLACE FUNCTION public.log_activity(
    p_event_type TEXT,
    p_table_name TEXT,
    p_record_id UUID,
    p_new_values JSONB DEFAULT NULL,
    p_old_values JSONB DEFAULT NULL
) RETURNS VOID AS $$
BEGIN
    INSERT INTO public.audit_logs (profile_id, event_type, table_name, record_id, old_values, new_values)
    VALUES (auth.uid(), p_event_type, p_table_name, p_record_id, p_old_values, p_new_values);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
