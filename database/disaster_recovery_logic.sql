-- ############################################################################
-- DISASTER RECOVERY & DATA INTEGRITY LOGIC
-- ############################################################################

-- 1. جدول سجلات فحص النزاهة
CREATE TABLE IF NOT EXISTS public.integrity_checks (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    check_date TIMESTAMPTZ DEFAULT NOW(),
    is_healthy BOOLEAN,
    accounting_imbalance DECIMAL(15,2), 
    investor_imbalance DECIMAL(15,2),   
    issues_found JSONB,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 2. وظيفة الفحص الشامل لسلامة البيانات المالية
CREATE OR REPLACE FUNCTION public.perform_system_integrity_check()
RETURNS JSONB AS $$
DECLARE
    v_debit_total DECIMAL(15,2);
    v_credit_total DECIMAL(15,2);
    v_accounting_gap DECIMAL(15,2);
    v_investor_gap DECIMAL(15,2);
    v_is_healthy BOOLEAN := true;
    v_issues JSONB := '[]'::jsonb;
    v_admin_id UUID;
BEGIN
    SELECT COALESCE(SUM(debit), 0), COALESCE(SUM(credit), 0) 
    INTO v_debit_total, v_credit_total 
    FROM public.journal_entry_lines;

    v_accounting_gap := ABS(v_debit_total - v_credit_total);
    
    IF v_accounting_gap > 0.01 THEN
        v_is_healthy := false;
        v_issues := v_issues || jsonb_build_object('type', 'ACCOUNTING_IMBALANCE', 'gap', v_accounting_gap);
    END IF;

    SELECT SUM(ABS(i.available_balance - COALESCE(tx_sum, 0)))
    INTO v_investor_gap
    FROM public.investors i
    LEFT JOIN (
        SELECT investor_id, 
               SUM(CASE 
                    WHEN type IN ('deposit', 'contract_return', 'finance_profit_distribution') THEN amount 
                    WHEN type IN ('withdrawal', 'contract_allocation') THEN -amount 
                    ELSE 0 END) as tx_sum
        FROM public.investor_transactions
        GROUP BY investor_id
    ) tx ON i.id = tx.investor_id;

    IF COALESCE(v_investor_gap, 0) > 0 THEN
        v_is_healthy := false;
        v_issues := v_issues || jsonb_build_object('type', 'INVESTOR_BALANCE_MISMATCH', 'gap', v_investor_gap);
    END IF;

    INSERT INTO public.integrity_checks (is_healthy, accounting_imbalance, investor_imbalance, issues_found)
    VALUES (v_is_healthy, v_accounting_gap, v_investor_gap, v_issues);

    IF NOT v_is_healthy THEN
        FOR v_admin_id IN (SELECT p.id FROM public.profiles p JOIN public.roles r ON p.role_id = r.id WHERE r.slug = 'admin') LOOP
            INSERT INTO public.notifications (profile_id, title, content, type)
            VALUES (v_admin_id, '⚠️ تحذير: خلل في نزاهة البيانات', 'تم اكتشاف عدم توازن مالي. يرجى المراجعة.', 'error');
        END LOOP;
    END IF;

    RETURN jsonb_build_object('is_healthy', v_is_healthy, 'accounting_gap', v_accounting_gap, 'investor_gap', v_investor_gap, 'issues', v_issues);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 3. ميزة تجميد العمليات المالية (Financial Lockdown)
CREATE OR REPLACE FUNCTION public.is_financial_system_frozen()
RETURNS BOOLEAN AS $$
BEGIN
    RETURN COALESCE((SELECT (value->>'is_frozen')::BOOLEAN FROM public.system_settings WHERE key = 'financial_freeze'), false);
END;
$$ LANGUAGE plpgsql;

-- 4. وظيفة تبديل حالة التجميد
CREATE OR REPLACE FUNCTION public.toggle_financial_freeze(p_is_frozen BOOLEAN)
RETURNS VOID AS $$
BEGIN
    IF NOT public.has_permission('manage_settings') THEN
        RAISE EXCEPTION 'Unauthorized';
    END IF;

    INSERT INTO public.system_settings (key, value)
    VALUES ('financial_freeze', jsonb_build_object('is_frozen', p_is_frozen, 'frozen_at', NOW(), 'frozen_by', auth.uid()))
    ON CONFLICT (key) DO UPDATE SET value = EXCLUDED.value, updated_at = NOW();

    INSERT INTO public.audit_logs (profile_id, event_type, table_name, record_id, new_values)
    VALUES (auth.uid(), 'FINANCIAL_SYSTEM_FREEZE_TOGGLE', 'system_settings', '00000000-0000-0000-0000-000000000000', 
            jsonb_build_object('is_frozen', p_is_frozen));
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 5. وظيفة الإصلاح التلقائي لأرصدة المستثمرين (The Repair Engine)
CREATE OR REPLACE FUNCTION public.repair_investor_balances()
RETURNS JSONB AS $$
DECLARE
    v_updated_count INTEGER := 0;
BEGIN
    IF NOT public.has_permission('manage_settings') THEN
        RAISE EXCEPTION 'Unauthorized';
    END IF;

    UPDATE public.investors i
    SET available_balance = COALESCE((
        SELECT SUM(CASE 
                    WHEN type IN ('deposit', 'contract_return', 'finance_profit_distribution') THEN amount 
                    WHEN type IN ('withdrawal', 'contract_allocation') THEN -amount 
                    ELSE 0 END)
        FROM public.investor_transactions tx
        WHERE tx.investor_id = i.id
    ), 0),
    updated_at = NOW();

    GET DIAGNOSTICS v_updated_count = ROW_COUNT;

    INSERT INTO public.audit_logs (profile_id, event_type, table_name, record_id, new_values)
    VALUES (auth.uid(), 'SYSTEM_REPAIR_BALANCES', 'investors', '00000000-0000-0000-0000-000000000000', 
            jsonb_build_object('repaired_investors', v_updated_count));

    RETURN jsonb_build_object('success', true, 'repaired_count', v_updated_count);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
