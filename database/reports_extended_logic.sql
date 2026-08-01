-- ############################################################################
-- EXTENDED REPORTS LOGIC - FINANCIAL & OPERATIONAL ANALYTICS
-- VERSION: 1.0.0
-- ############################################################################

-- 1. تقرير الإيرادات والأرباح (Revenue & Profit Report)
-- ############################################################################
CREATE OR REPLACE FUNCTION public.get_revenue_report(
    p_start_date DATE,
    p_end_date DATE
)
RETURNS TABLE (
    category TEXT,
    total_amount DECIMAL(15,2),
    transaction_count BIGINT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        'Financing Profits'::TEXT as category,
        COALESCE(SUM(credit), 0) as total_amount,
        COUNT(*)::BIGINT as transaction_count
    FROM public.journal_entry_lines l
    JOIN public.journal_entries e ON l.journal_entry_id = e.id
    JOIN public.accounts a ON l.account_id = a.id
    WHERE a.code = '4101' -- حساب أرباح التمويل
    AND e.created_at::DATE BETWEEN p_start_date AND p_end_date
    
    UNION ALL
    
    SELECT 
        'Administrative Fees'::TEXT,
        COALESCE(SUM(credit), 0),
        COUNT(*)::BIGINT
    FROM public.journal_entry_lines l
    JOIN public.journal_entries e ON l.journal_entry_id = e.id
    JOIN public.accounts a ON l.account_id = a.id
    WHERE a.code = '4102' -- حساب الرسوم الإدارية
    AND e.created_at::DATE BETWEEN p_start_date AND p_end_date;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;


-- 2. تقرير المتأخرات والتعثر (Overdue & Delinquency Report)
-- ############################################################################
CREATE OR REPLACE FUNCTION public.get_overdue_report()
RETURNS TABLE (
    contract_no TEXT,
    customer_name TEXT,
    installment_no INT,
    due_date DATE,
    overdue_days INT,
    amount_due DECIMAL(15,2),
    customer_phone TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        c.contract_no,
        cust.full_name as customer_name,
        i.installment_number,
        i.due_date,
        (CURRENT_DATE - i.due_date)::INT as overdue_days,
        (i.expected_amount - COALESCE((SELECT SUM(amount_allocated) FROM public.payment_allocations WHERE installment_id = i.id), 0)) as amount_due,
        cust.phone as customer_phone
    FROM public.installments i
    JOIN public.financing_contracts c ON i.contract_id = c.id
    JOIN public.customers cust ON c.customer_id = cust.id
    WHERE i.status IN ('unpaid', 'partially_paid')
    AND i.due_date < CURRENT_DATE
    ORDER BY i.due_date ASC;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;


-- 3. تقرير أداء المستثمرين (Investors Performance)
-- ############################################################################
CREATE OR REPLACE FUNCTION public.get_investors_performance()
RETURNS TABLE (
    investor_name TEXT,
    deployed_capital DECIMAL(15,2),
    total_profit_earned DECIMAL(15,2),
    roi_percentage DECIMAL(5,2),
    active_contracts_count BIGINT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        inv.full_name,
        inv.deployed_capital,
        inv.total_profit_earned,
        CASE 
            WHEN inv.deployed_capital > 0 THEN (inv.total_profit_earned / inv.deployed_capital) * 100
            ELSE 0.00
        END as roi_percentage,
        (SELECT COUNT(*) FROM public.contract_funding cf WHERE cf.investor_id = inv.id)::BIGINT as active_contracts_count
    FROM public.investors inv
    ORDER BY inv.total_profit_earned DESC;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;


-- 4. تقرير ملخص العقود (Contracts Summary Report)
-- ############################################################################
CREATE OR REPLACE FUNCTION public.get_contracts_summary_report()
RETURNS JSONB AS $$
DECLARE
    v_result JSONB;
BEGIN
    SELECT jsonb_build_object(
        'total_active_contracts', (SELECT COUNT(*) FROM public.financing_contracts WHERE status = 'active'),
        'total_principal_lent', (SELECT COALESCE(SUM(principal_amount), 0) FROM public.financing_contracts WHERE status = 'active'),
        'total_expected_interest', (SELECT COALESCE(SUM(total_contract_value - principal_amount), 0) FROM public.financing_contracts WHERE status = 'active'),
        'collection_rate', (
            SELECT ROUND((SUM(CASE WHEN status = 'paid' THEN expected_amount ELSE 0 END) / SUM(expected_amount)) * 100, 2)
            FROM public.installments
        )
    ) INTO v_result;
    
    RETURN v_result;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
