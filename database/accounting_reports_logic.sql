-- ############################################################################
-- ADVANCED ACCOUNTING REPORTS: TRIAL BALANCE
-- ############################################################################

CREATE OR REPLACE FUNCTION public.get_trial_balance()
RETURNS TABLE (
    account_code TEXT,
    account_name TEXT,
    account_type TEXT,
    total_debit DECIMAL(15,2),
    total_credit DECIMAL(15,2),
    net_balance DECIMAL(15,2)
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        a.code,
        a.name,
        a.type::TEXT,
        COALESCE(SUM(l.debit), 0) as total_debit,
        COALESCE(SUM(l.credit), 0) as total_credit,
        -- صافي الرصيد حسب نوع الحساب (الأصول والمصروفات مدين بطبعه)
        CASE 
            WHEN a.type IN ('asset', 'expense') THEN COALESCE(SUM(l.debit), 0) - COALESCE(SUM(l.credit), 0)
            ELSE COALESCE(SUM(l.credit), 0) - COALESCE(SUM(l.debit), 0)
        END as net_balance
    FROM public.accounts a
    LEFT JOIN public.journal_entry_lines l ON a.id = l.account_id
    GROUP BY a.id, a.code, a.name, a.type
    ORDER BY a.code ASC;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
