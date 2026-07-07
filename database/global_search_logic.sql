-- ############################################################################
-- PHASE 15: GLOBAL SEARCH BUSINESS LOGIC (OPTIMIZED & FILTERED)
-- ############################################################################

CREATE OR REPLACE FUNCTION public.global_search(p_query TEXT)
RETURNS TABLE (
    id UUID,
    title TEXT,
    subtitle TEXT,
    entity_type TEXT,
    metadata JSONB
) AS $$
BEGIN
    RETURN QUERY
    -- 1. Search Customers
    SELECT 
        c.id, 
        c.full_name as title, 
        'هوية: ' || c.national_id as subtitle, 
        'customer' as entity_type,
        jsonb_build_object('phone', c.phone) as metadata
    FROM public.customers c
    WHERE c.full_name ILIKE '%' || p_query || '%' 
       OR c.national_id ILIKE '%' || p_query || '%'
       OR c.phone ILIKE '%' || p_query || '%'
    
    UNION ALL

    -- 2. Search Investors
    SELECT 
        i.id, 
        i.full_name as title, 
        i.email as subtitle, 
        'investor' as entity_type,
        jsonb_build_object('balance', i.available_balance) as metadata
    FROM public.investors i
    WHERE i.full_name ILIKE '%' || p_query || '%' 
       OR i.email ILIKE '%' || p_query || '%'

    UNION ALL

    -- 3. Search Financing Contracts
    SELECT 
        f.id, 
        f.contract_no as title, 
        'حالة: ' || f.status::text as subtitle, 
        'contract' as entity_type,
        jsonb_build_object('principal', f.principal_amount) as metadata
    FROM public.financing_contracts f
    WHERE f.contract_no ILIKE '%' || p_query || '%'

    UNION ALL

    -- 4. Search Payments (Linked to Contracts)
    SELECT 
        p.id, 
        'دفعة: ' || p.amount_total::text || ' ر.س' as title, 
        'مرجع: ' || COALESCE(p.reference_no, 'N/A') as subtitle, 
        'payment' as entity_type,
        jsonb_build_object('date', p.payment_date, 'contract_id', p.contract_id) as metadata
    FROM public.payments p
    WHERE p.reference_no ILIKE '%' || p_query || '%'

    UNION ALL

    -- 5. Search Staff (Profiles excluding investors to avoid duplicates)
    SELECT 
        pr.id, 
        pr.full_name as title, 
        'موظف: ' || r.name as subtitle, 
        'staff' as entity_type,
        jsonb_build_object('is_active', pr.is_active) as metadata
    FROM public.profiles pr
    JOIN public.roles r ON pr.role_id = r.id
    WHERE r.slug != 'investor' 
      AND (pr.full_name ILIKE '%' || p_query || '%')
    
    LIMIT 50;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
