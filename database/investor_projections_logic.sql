-- ############################################################################
-- INVESTOR PROJECTIONS & EXPECTED CASH FLOW
-- ############################################################################

-- وظيفة لحساب التدفقات النقدية المتوقعة للمستثمر بناءً على الأقساط غير المسددة
CREATE OR REPLACE FUNCTION public.get_investor_expected_cashflow(p_investor_id UUID)
RETURNS TABLE (
    due_date DATE,
    expected_principal NUMERIC,
    expected_profit NUMERIC,
    total_expected NUMERIC,
    contract_count BIGINT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        inst.due_date,
        -- حصة المستثمر من أصل القسط
        SUM(inst.principal_component * (cf.amount_allocated / con.principal_amount)) as expected_principal,
        -- حصة المستثمر من ربح القسط (بافتراض توزيع كامل الربح بعد خصم حصة الشركة مستقبلاً)
        -- هنا نحسبها تبسيطياً كنسبة من التمويل
        SUM(inst.profit_component * (cf.amount_allocated / con.principal_amount)) as expected_profit,
        -- المجموع
        SUM(inst.expected_amount * (cf.amount_allocated / con.principal_amount)) as total_expected,
        COUNT(DISTINCT con.id) as contract_count
    FROM public.installments inst
    JOIN public.financing_contracts con ON inst.contract_id = con.id
    JOIN public.contract_funding cf ON con.id = cf.contract_id
    WHERE cf.investor_id = p_investor_id
      AND inst.status != 'paid'
      AND con.status = 'active'
    GROUP BY inst.due_date
    ORDER BY inst.due_date ASC;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
