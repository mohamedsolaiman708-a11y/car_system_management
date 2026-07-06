-- ############################################################################
-- UPDATE FINANCING CONTRACTS TO LINK TO CUSTOMERS
-- ############################################################################

-- 1. Add customer_id to financing_contracts
ALTER TABLE public.financing_contracts 
ADD COLUMN IF NOT EXISTS customer_id UUID REFERENCES public.customers(id) ON DELETE SET NULL;

-- 2. Optional: Migrate data from customer_name to customer_id if possible
-- (Skipping for now as this is a new feature)

-- 3. Create view for Customer 360 Timeline
CREATE OR REPLACE VIEW public.customer_timeline_view AS
SELECT 
    customer_id,
    'CONTRACT_CREATED' as event_type,
    created_at,
    jsonb_build_object('contract_id', id) as details
FROM public.financing_contracts
UNION ALL
SELECT 
    c.customer_id,
    'PAYMENT_RECEIVED' as event_type,
    p.created_at,
    jsonb_build_object('payment_id', p.id, 'amount', p.amount_total) as details
FROM public.payments p
JOIN public.financing_contracts c ON p.contract_id = c.id
UNION ALL
SELECT 
    id as customer_id,
    'CUSTOMER_CREATED' as event_type,
    created_at,
    '{}'::jsonb as details
FROM public.customers;
