-- ############################################################################
-- CRM MODULE SCHEMA (CUSTOMER MANAGEMENT) - UPDATED TO MATCH DESIGN
-- ############################################################################

-- 1. Customers Table
CREATE TABLE IF NOT EXISTS public.customers (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    full_name TEXT NOT NULL,
    national_id TEXT UNIQUE NOT NULL,
    phone TEXT NOT NULL,
    email TEXT,
    address TEXT,
    kyc_data JSONB DEFAULT '{}'::jsonb, -- Includes: birth_date, job, salary, guarantor, etc.
    risk_rating TEXT DEFAULT 'medium',   -- low, medium, high
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 2. RLS Policies
ALTER TABLE public.customers ENABLE ROW LEVEL SECURITY;

-- Permissions based on has_permission helper
CREATE POLICY "View Customers" ON public.customers FOR SELECT 
TO authenticated USING (public.has_permission('view_customers') OR public.has_permission('manage_customers'));

CREATE POLICY "Manage Customers" ON public.customers FOR ALL
TO authenticated USING (public.has_permission('manage_customers'));

-- 3. Trigger for updated_at
CREATE OR REPLACE FUNCTION public.set_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS tr_customers_updated_at ON public.customers;
CREATE TRIGGER tr_customers_updated_at
BEFORE UPDATE ON public.customers
FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
