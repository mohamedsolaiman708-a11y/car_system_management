-- ############################################################################
-- PHASE 18 & 19: REPORTS CENTER LOGIC (ADVANCED FILTERING & EXPORT SUPPORT)
-- ############################################################################

-- 1. تقرير التدفق النقدي المتقدم (يدعم الفلترة حسب المستثمر)
CREATE OR REPLACE FUNCTION public.get_cash_flow_report(
    p_start_date DATE, 
    p_end_date DATE,
    p_investor_id UUID DEFAULT NULL
)
RETURNS TABLE (
    month_text TEXT,
    inflow NUMERIC,
    outflow NUMERIC,
    net_cash_flow NUMERIC
) AS $$
BEGIN
    RETURN QUERY
    WITH inflows AS (
        SELECT to_char(p.payment_date, 'YYYY-MM') as m, SUM(p.amount_total) as amt
        FROM public.payments p
        JOIN public.financing_contracts c ON p.contract_id = c.id
        LEFT JOIN public.contract_funding cf ON c.id = cf.contract_id
        WHERE p.payment_date::DATE BETWEEN p_start_date AND p_end_date
          AND (p_investor_id IS NULL OR cf.investor_id = p_investor_id)
        GROUP BY 1
    ),
    outflows AS (
        SELECT to_char(it.created_at, 'YYYY-MM') as m, SUM(it.amount) as amt
        FROM public.investor_transactions it
        WHERE it.type = 'withdrawal' 
          AND it.created_at::DATE BETWEEN p_start_date AND p_end_date
          AND (p_investor_id IS NULL OR it.investor_id = p_investor_id)
        GROUP BY 1
    )
    SELECT 
        COALESCE(i.m, o.m) as month_text,
        COALESCE(i.amt, 0) as inflow,
        COALESCE(o.amt, 0) as outflow,
        (COALESCE(i.amt, 0) - COALESCE(o.amt, 0)) as net_cash_flow
    FROM inflows i
    FULL OUTER JOIN outflows o ON i.m = o.m
    ORDER BY month_text DESC;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 2. تقرير الأرباح المتقدم (يدعم الفلترة حسب المستثمر أو العميل)
CREATE OR REPLACE FUNCTION public.get_profit_report(
    p_start_date DATE, 
    p_end_date DATE,
    p_investor_id UUID DEFAULT NULL,
    p_customer_id UUID DEFAULT NULL
)
RETURNS TABLE (
    period_text TEXT,
    gross_profit NUMERIC,
    investor_share NUMERIC,
    company_net_profit NUMERIC
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        to_char(p.payment_date, 'YYYY-MM') as period_text,
        SUM(pa.amount_allocated * (inst.profit_component / inst.expected_amount)) as gross_profit,
        
        -- حصة المستثمر الموزعة فعلياً في هذه الفترة
        COALESCE((
            SELECT SUM(it.amount) 
            FROM public.investor_transactions it 
            WHERE it.type = 'finance_profit_distribution' 
              AND to_char(it.created_at, 'YYYY-MM') = to_char(p.payment_date, 'YYYY-MM')
              AND (p_investor_id IS NULL OR it.investor_id = p_investor_id)
        ), 0) as investor_share,
        
        SUM(pa.amount_allocated * (inst.profit_component / inst.expected_amount)) - 
        COALESCE((
            SELECT SUM(it.amount) 
            FROM public.investor_transactions it 
            WHERE it.type = 'finance_profit_distribution' 
              AND to_char(it.created_at, 'YYYY-MM') = to_char(p.payment_date, 'YYYY-MM')
              AND (p_investor_id IS NULL OR it.investor_id = p_investor_id)
        ), 0) as company_net_profit

    FROM public.payments p
    JOIN public.payment_allocations pa ON p.id = pa.payment_id
    JOIN public.installments inst ON pa.installment_id = inst.id
    JOIN public.financing_contracts con ON p.contract_id = con.id
    LEFT JOIN public.contract_funding cf ON con.id = cf.contract_id
    WHERE p.payment_date::DATE BETWEEN p_start_date AND p_end_date
      AND (p_customer_id IS NULL OR con.customer_id = p_customer_id)
      AND (p_investor_id IS NULL OR cf.investor_id = p_investor_id)
    GROUP BY 1
    ORDER BY period_text DESC;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 3. تقرير التحصيل التفصيلي (للتصدير إلى Excel/PDF)
CREATE OR REPLACE FUNCTION public.get_detailed_collections_report(
    p_start_date DATE, 
    p_end_date DATE,
    p_customer_id UUID DEFAULT NULL
)
RETURNS TABLE (
    payment_date TIMESTAMPTZ,
    contract_no TEXT,
    customer_name TEXT,
    amount NUMERIC,
    payment_method TEXT,
    reference_no TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        p.payment_date,
        con.contract_no,
        c.full_name as customer_name,
        p.amount_total as amount,
        p.payment_method,
        p.reference_no
    FROM public.payments p
    JOIN public.financing_contracts con ON p.contract_id = con.id
    JOIN public.customers c ON con.customer_id = c.id
    WHERE p.payment_date::DATE BETWEEN p_start_date AND p_end_date
      AND (p_customer_id IS NULL OR con.customer_id = p_customer_id)
    ORDER BY p.payment_date DESC;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
