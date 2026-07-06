-- ############################################################################
-- ENTERPRISE FINANCE & INVESTMENT MANAGEMENT SYSTEM - FULL SCHEMA (OVERRIDE)
-- VERSION: 1.1.0 (Production Ready - ERP Grade)
-- ############################################################################

-- 0. CLEANUP (Complete Rebuild)
-- ############################################################################

DROP TRIGGER IF EXISTS tr_investor_ledger ON public.investor_transactions;
DROP TRIGGER IF EXISTS tr_contract_inventory_sync ON public.financing_contracts;
DROP TRIGGER IF EXISTS tr_payment_allocation_sync ON public.payment_allocations;

DROP TABLE IF EXISTS public.audit_logs CASCADE;
DROP TABLE IF EXISTS public.notifications CASCADE;
DROP TABLE IF EXISTS public.system_settings CASCADE;
DROP TABLE IF EXISTS public.journal_entry_lines CASCADE;
DROP TABLE IF EXISTS public.journal_entries CASCADE;
DROP TABLE IF EXISTS public.accounts CASCADE;
DROP TABLE IF EXISTS public.fiscal_periods CASCADE;
DROP TABLE IF EXISTS public.payment_allocations CASCADE;
DROP TABLE IF EXISTS public.payments CASCADE;
DROP TABLE IF EXISTS public.installments CASCADE;
DROP TABLE IF EXISTS public.contract_documents CASCADE;
DROP TABLE IF EXISTS public.contract_funding CASCADE;
DROP TABLE IF EXISTS public.contract_status_history CASCADE;
DROP TABLE IF EXISTS public.financing_contracts CASCADE;
DROP TABLE IF EXISTS public.ownership_transfer_contracts CASCADE;
DROP TABLE IF EXISTS public.investor_transactions CASCADE;
DROP TABLE IF EXISTS public.investors CASCADE;
DROP TABLE IF EXISTS public.maintenance_logs CASCADE;
DROP TABLE IF EXISTS public.inventory_images CASCADE;
DROP TABLE IF EXISTS public.inventory_items CASCADE;
DROP TABLE IF EXISTS public.customers CASCADE;
DROP TABLE IF EXISTS public.profiles CASCADE;
DROP TABLE IF EXISTS public.role_permissions CASCADE;
DROP TABLE IF EXISTS public.permissions CASCADE;
DROP TABLE IF EXISTS public.roles CASCADE;

DROP TYPE IF EXISTS public.asset_status CASCADE;
DROP TYPE IF EXISTS public.contract_status CASCADE;
DROP TYPE IF EXISTS public.transaction_type CASCADE;
DROP TYPE IF EXISTS public.installment_status CASCADE;
DROP TYPE IF EXISTS public.account_type CASCADE;

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ############################################################################
-- 1. ENUMS
-- ############################################################################

CREATE TYPE public.asset_status AS ENUM ('available', 'on_contract', 'maintenance', 'inactive');
CREATE TYPE public.contract_status AS ENUM ('draft', 'pending_funding', 'active', 'closed', 'defaulted');
CREATE TYPE public.transaction_type AS ENUM ('deposit', 'withdrawal', 'contract_allocation', 'contract_return', 'finance_profit_distribution');
CREATE TYPE public.installment_status AS ENUM ('unpaid', 'partially_paid', 'paid', 'overdue', 'waived');
CREATE TYPE public.account_type AS ENUM ('asset', 'liability', 'equity', 'revenue', 'expense');

-- ############################################################################
-- 2. IDENTITY & ACCESS (RBAC)
-- ############################################################################

CREATE TABLE public.roles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT UNIQUE NOT NULL,
    slug TEXT UNIQUE NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE public.permissions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT UNIQUE NOT NULL,
    slug TEXT UNIQUE NOT NULL
);

CREATE TABLE public.role_permissions (
    role_id UUID REFERENCES public.roles(id) ON DELETE CASCADE,
    permission_id UUID REFERENCES public.permissions(id) ON DELETE CASCADE,
    PRIMARY KEY (role_id, permission_id)
);

CREATE TABLE public.profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    role_id UUID REFERENCES public.roles(id),
    full_name TEXT NOT NULL,
    is_active BOOLEAN DEFAULT true,
    last_login TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ############################################################################
-- 3. CORE BUSINESS ENTITIES
-- ############################################################################

CREATE TABLE public.customers (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    full_name TEXT NOT NULL,
    national_id TEXT UNIQUE NOT NULL,
    phone TEXT NOT NULL,
    email TEXT,
    address TEXT,
    kyc_data JSONB, -- Storage for identity docs/JSON metadata
    risk_rating TEXT DEFAULT 'low',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE public.inventory_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    vin TEXT UNIQUE NOT NULL,
    make TEXT NOT NULL,
    model TEXT NOT NULL,
    year INTEGER NOT NULL,
    color TEXT,
    license_plate TEXT UNIQUE,
    status public.asset_status DEFAULT 'available',
    purchase_price DECIMAL(15,2) NOT NULL,
    estimated_market_value DECIMAL(15,2),
    technical_specs JSONB,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE public.inventory_images (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    inventory_item_id UUID REFERENCES public.inventory_items(id) ON DELETE CASCADE,
    image_url TEXT NOT NULL,
    is_main BOOLEAN DEFAULT false,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE public.maintenance_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    inventory_item_id UUID REFERENCES public.inventory_items(id) ON DELETE CASCADE,
    description TEXT NOT NULL,
    cost DECIMAL(15,2) DEFAULT 0.00,
    performed_at DATE DEFAULT CURRENT_DATE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ############################################################################
-- 4. INVESTORS
-- ############################################################################

CREATE TABLE public.investors (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    full_name TEXT NOT NULL,
    email TEXT UNIQUE NOT NULL,
    available_balance DECIMAL(15,2) DEFAULT 0.00,
    deployed_capital DECIMAL(15,2) DEFAULT 0.00,
    total_profit_earned DECIMAL(15,2) DEFAULT 0.00,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE public.investor_transactions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    investor_id UUID REFERENCES public.investors(id) ON DELETE CASCADE,
    amount DECIMAL(15,2) NOT NULL,
    type public.transaction_type NOT NULL,
    reference_id UUID, -- Links to contract or payment
    description TEXT,
    status TEXT DEFAULT 'finalized',
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ############################################################################
-- 5. CONTRACTS
-- ############################################################################

CREATE SEQUENCE IF NOT EXISTS financing_contract_no_seq START 1;
CREATE SEQUENCE IF NOT EXISTS transfer_contract_no_seq START 1;

CREATE TABLE public.financing_contracts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    contract_no TEXT UNIQUE NOT NULL DEFAULT ('FIN-' || LPAD(nextval('financing_contract_no_seq')::text, 6, '0')),
    customer_id UUID REFERENCES public.customers(id),
    inventory_item_id UUID REFERENCES public.inventory_items(id),
    principal_amount DECIMAL(15,2) NOT NULL,
    finance_profit_rate DECIMAL(5,2) NOT NULL,
    total_contract_value DECIMAL(15,2) NOT NULL,
    duration_months INTEGER NOT NULL,
    start_date DATE,
    status public.contract_status DEFAULT 'draft',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE public.ownership_transfer_contracts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    transfer_no TEXT UNIQUE NOT NULL DEFAULT ('CSH-' || LPAD(nextval('transfer_contract_no_seq')::text, 6, '0')),
    customer_id UUID REFERENCES public.customers(id),
    inventory_item_id UUID REFERENCES public.inventory_items(id),
    sale_price DECIMAL(15,2) NOT NULL,
    transfer_date DATE DEFAULT CURRENT_DATE,
    payment_status TEXT DEFAULT 'pending',
    status TEXT DEFAULT 'active',
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE public.contract_funding (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    contract_id UUID REFERENCES public.financing_contracts(id) ON DELETE CASCADE,
    investor_id UUID REFERENCES public.investors(id),
    amount_allocated DECIMAL(15,2) NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE public.contract_documents (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    contract_id UUID REFERENCES public.financing_contracts(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    document_url TEXT NOT NULL,
    version INTEGER DEFAULT 1,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE public.contract_status_history (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    contract_id UUID REFERENCES public.financing_contracts(id) ON DELETE CASCADE,
    from_status public.contract_status,
    to_status public.contract_status,
    changed_by UUID REFERENCES public.profiles(id),
    reason TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ############################################################################
-- 6. SERVICING
-- ############################################################################

CREATE TABLE public.installments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    contract_id UUID REFERENCES public.financing_contracts(id) ON DELETE CASCADE,
    due_date DATE NOT NULL,
    expected_amount DECIMAL(15,2) NOT NULL,
    principal_component DECIMAL(15,2) NOT NULL,
    profit_component DECIMAL(15,2) NOT NULL,
    status public.installment_status DEFAULT 'unpaid',
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE public.payments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    contract_id UUID REFERENCES public.financing_contracts(id),
    amount_total DECIMAL(15,2) NOT NULL,
    payment_date TIMESTAMPTZ DEFAULT NOW(),
    payment_method TEXT,
    reference_no TEXT,
    recorded_by UUID REFERENCES public.profiles(id),
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE public.payment_allocations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    payment_id UUID REFERENCES public.payments(id) ON DELETE CASCADE,
    installment_id UUID REFERENCES public.installments(id),
    amount_allocated DECIMAL(15,2) NOT NULL,
    allocation_type TEXT, -- 'principal', 'profit', 'penalty'
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ############################################################################
-- 7. ACCOUNTING
-- ############################################################################

CREATE TABLE public.fiscal_periods (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL, -- e.g. 'JAN-2024'
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    is_closed BOOLEAN DEFAULT false,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE public.accounts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    code TEXT UNIQUE NOT NULL, -- e.g. '1001'
    name TEXT NOT NULL,
    type public.account_type NOT NULL,
    is_reconcilable BOOLEAN DEFAULT true,
    current_balance DECIMAL(15,2) DEFAULT 0.00,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE public.journal_entries (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    fiscal_period_id UUID REFERENCES public.fiscal_periods(id),
    entry_date DATE DEFAULT CURRENT_DATE,
    description TEXT,
    reference_no TEXT,
    source_type TEXT, -- 'payment', 'allocation', 'withdrawal', 'funding'
    source_id UUID,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE public.journal_entry_lines (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    journal_entry_id UUID REFERENCES public.journal_entries(id) ON DELETE CASCADE,
    account_id UUID REFERENCES public.accounts(id),
    debit DECIMAL(15,2) DEFAULT 0.00,
    credit DECIMAL(15,2) DEFAULT 0.00,
    CONSTRAINT double_entry_check CHECK (debit >= 0 AND credit >= 0),
    CONSTRAINT unbalanced_line_check CHECK (NOT (debit > 0 AND credit > 0))
);

-- ############################################################################
-- 8. SYSTEM & AUDIT
-- ############################################################################

CREATE TABLE public.notifications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    profile_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    content TEXT NOT NULL,
    type TEXT, -- 'info', 'warning', 'alert'
    is_read BOOLEAN DEFAULT false,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE public.audit_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    profile_id UUID REFERENCES public.profiles(id),
    event_type TEXT NOT NULL,
    table_name TEXT NOT NULL,
    record_id UUID NOT NULL,
    old_values JSONB,
    new_values JSONB,
    ip_address TEXT,
    user_agent TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE public.system_settings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    key TEXT UNIQUE NOT NULL,
    value JSONB NOT NULL,
    description TEXT,
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ############################################################################
-- 9. TRIGGERS & AUTOMATION
-- ############################################################################

-- 9.1 Update Investor Balances
CREATE OR REPLACE FUNCTION public.handle_investor_ledger()
RETURNS TRIGGER AS $$
BEGIN
    IF (NEW.type IN ('deposit', 'contract_return', 'finance_profit_distribution')) THEN
        UPDATE public.investors 
        SET available_balance = available_balance + NEW.amount 
        WHERE id = NEW.investor_id;
    ELSIF (NEW.type = 'withdrawal') THEN
        UPDATE public.investors 
        SET available_balance = available_balance - NEW.amount 
        WHERE id = NEW.investor_id;
    ELSIF (NEW.type = 'contract_allocation') THEN
        UPDATE public.investors 
        SET available_balance = available_balance - NEW.amount,
            deployed_capital = deployed_capital + NEW.amount
        WHERE id = NEW.investor_id;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER tr_investor_ledger 
AFTER INSERT ON public.investor_transactions 
FOR EACH ROW EXECUTE FUNCTION public.handle_investor_ledger();

-- 9.2 Sync Inventory Status with Contract
CREATE OR REPLACE FUNCTION public.sync_inventory_asset()
RETURNS TRIGGER AS $$
BEGIN
    IF (NEW.status = 'active') THEN
        UPDATE public.inventory_items SET status = 'on_contract' WHERE id = NEW.inventory_item_id;
    ELSIF (NEW.status IN ('closed', 'defaulted')) THEN
        UPDATE public.inventory_items SET status = 'available' WHERE id = NEW.inventory_item_id;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER tr_contract_inventory_sync 
AFTER UPDATE OF status ON public.financing_contracts 
FOR EACH ROW EXECUTE FUNCTION public.sync_inventory_asset();

-- 9.3 Update Installment Status on Allocation
CREATE OR REPLACE FUNCTION public.update_installment_state()
RETURNS TRIGGER AS $$
DECLARE
    total_paid DECIMAL(15, 2);
    expected DECIMAL(15, 2);
BEGIN
    SELECT COALESCE(SUM(amount_allocated), 0) INTO total_paid FROM public.payment_allocations WHERE installment_id = NEW.installment_id;
    SELECT expected_amount INTO expected FROM public.installments WHERE id = NEW.installment_id;

    IF total_paid >= expected THEN
        UPDATE public.installments SET status = 'paid' WHERE id = NEW.installment_id;
    ELSIF total_paid > 0 THEN
        UPDATE public.installments SET status = 'partially_paid' WHERE id = NEW.installment_id;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER tr_payment_allocation_sync 
AFTER INSERT ON public.payment_allocations 
FOR EACH ROW EXECUTE FUNCTION public.update_installment_state();

-- ############################################################################
-- 10. INDEXES (Performance)
-- ############################################################################

-- Hard lock: One car in one active contract
CREATE UNIQUE INDEX idx_active_inventory_lock 
ON public.financing_contracts (inventory_item_id) 
WHERE (status = 'active');

CREATE INDEX idx_customers_nat_id ON public.customers(national_id);
CREATE INDEX idx_inventory_vin ON public.inventory_items(vin);
CREATE INDEX idx_investor_transactions_investor ON public.investor_transactions(investor_id);
CREATE INDEX idx_journal_entries_period ON public.journal_entries(fiscal_period_id);
CREATE INDEX idx_audit_logs_record ON public.audit_logs(table_name, record_id);

-- ############################################################################
-- 11. SECURITY (RLS Policies)
-- ############################################################################

ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.investors ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.financing_contracts ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.audit_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.customers ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.inventory_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.installments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.payments ENABLE ROW LEVEL SECURITY;

-- Standard Auth Policy: Full access for authenticated staff
CREATE POLICY "Authenticated users full access" ON public.profiles FOR ALL TO authenticated USING (true);
CREATE POLICY "Authenticated users full access" ON public.investors FOR ALL TO authenticated USING (true);
CREATE POLICY "Authenticated users full access" ON public.financing_contracts FOR ALL TO authenticated USING (true);
CREATE POLICY "Authenticated users full access" ON public.audit_logs FOR ALL TO authenticated USING (true);
CREATE POLICY "Authenticated users full access" ON public.customers FOR ALL TO authenticated USING (true);
CREATE POLICY "Authenticated users full access" ON public.inventory_items FOR ALL TO authenticated USING (true);
CREATE POLICY "Authenticated users full access" ON public.installments FOR ALL TO authenticated USING (true);
CREATE POLICY "Authenticated users full access" ON public.payments FOR ALL TO authenticated USING (true);
