-- ############################################################################
-- PHASE 16: CONTRACT ACTIVITY TIMELINE VIEW (ENHANCED)
-- ############################################################################

CREATE OR REPLACE VIEW public.contract_timeline_view AS
-- 1. أحداث إنشاء وتعديل العقد
SELECT 
    record_id as contract_id,
    event_type,
    created_at,
    new_values as details,
    profile_id
FROM public.audit_logs
WHERE table_name = 'financing_contracts'

UNION ALL

-- 2. أحداث استلام الدفعات من العملاء
SELECT 
    contract_id,
    'PAYMENT_RECEIVED' as event_type,
    created_at,
    jsonb_build_object('amount', amount_total, 'payment_id', id) as details,
    recorded_by as profile_id
FROM public.payments

UNION ALL

-- 3. أحداث تخصيص التمويل من المستثمرين (الحدث الجديد)
SELECT 
    cf.contract_id,
    'FUNDING_ALLOCATED' as event_type,
    cf.created_at,
    jsonb_build_object('amount', cf.amount_allocated, 'investor_id', cf.investor_id) as details,
    NULL as profile_id
FROM public.contract_funding cf

UNION ALL

-- 4. أحداث عكس الدفعات (Reversals)
SELECT 
    p.contract_id,
    'PAYMENT_REVERSED' as event_type,
    r.created_at,
    jsonb_build_object('amount', r.amount_reversed, 'reason', r.reason) as details,
    p.recorded_by as profile_id
FROM public.payment_allocation_reversals r
JOIN public.payments p ON r.payment_id = p.id;
