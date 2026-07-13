-- ############################################################################
-- PHASE 3.7: PAYMENT SERVICE BUSINESS LOGIC (CORE FINANCIAL ENGINE)
-- VERSION: 1.8.5 (Enterprise Production Hardened - Final)
-- ############################################################################

-- 1. ضمان وجود جدول العكس (Reversal Tracking)
CREATE TABLE IF NOT EXISTS public.payment_allocation_reversals (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    payment_id UUID REFERENCES public.payments(id) ON DELETE CASCADE,
    installment_id UUID REFERENCES public.installments(id),
    amount_reversed DECIMAL(15,2) NOT NULL CHECK (amount_reversed > 0),
    reason TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 2. المحرك المالي الرئيسي لتحصيل الأقساط
CREATE OR REPLACE FUNCTION public.process_contract_payment(
    p_contract_id UUID,
    p_amount DECIMAL(15,2),
    p_payment_method TEXT,
    p_reference_no TEXT,
    p_idempotency_key TEXT DEFAULT NULL
)
RETURNS JSONB AS $$
DECLARE
    v_fiscal_period_id UUID;
    v_contract RECORD;
    v_payment_id UUID;
    v_remaining_cash DECIMAL(15,2);
    v_inst RECORD;
    v_alloc_amount DECIMAL(15,2);
    v_principal_part DECIMAL(15,2);
    v_profit_part DECIMAL(15,2);
    v_funder RECORD;
    v_funders_count INT;
    v_current_funder_idx INT := 0;
    v_total_principal_paid DECIMAL(15,2) := 0;
    v_total_profit_paid DECIMAL(15,2) := 0;
    v_journal_lines JSONB := '[]'::jsonb;
    v_net_allocated_so_far DECIMAL(15,2);
    v_investor_principal_share DECIMAL(15,2);
    v_investor_profit_share DECIMAL(15,2);
    v_rem_inv_principal DECIMAL(15,2);
    v_rem_inv_profit DECIMAL(15,2);
    v_company_ratio_raw DECIMAL(15,4);
    v_company_ratio DECIMAL(5,4);
    v_company_profit_share DECIMAL(15,2);
    v_distributable_profit DECIMAL(15,2);
BEGIN
    -- [A] الحماية ضد تجميد النظام والصلاحيات
    IF public.is_financial_system_frozen() THEN RAISE EXCEPTION 'Financial operations are frozen'; END IF;
    IF NOT public.has_permission('process_payments') THEN RAISE EXCEPTION 'Unauthorized'; END IF;

    -- [B] Idempotency Check (منع تكرار الطلب)
    IF p_idempotency_key IS NOT NULL THEN
        SELECT id INTO v_payment_id FROM public.payments WHERE idempotency_key = p_idempotency_key;
        IF v_payment_id IS NOT NULL THEN RETURN jsonb_build_object('success', true, 'payment_id', v_payment_id, 'message', 'Duplicate'); END IF;
    END IF;

    -- [C] قفل العقد والتأكد من الفترة المالية
    SELECT * INTO v_contract FROM public.financing_contracts WHERE id = p_contract_id FOR UPDATE;
    IF v_contract.status != 'active' THEN RAISE EXCEPTION 'Contract is not active'; END IF;

    SELECT id INTO v_fiscal_period_id FROM public.fiscal_periods WHERE is_closed = false AND CURRENT_DATE BETWEEN start_date AND end_date LIMIT 1;
    IF v_fiscal_period_id IS NULL THEN RAISE EXCEPTION 'No open fiscal period found'; END IF;

    -- [D] حماية الدفع الزائد (إجمالي المخصص الصافي)
    SELECT 
        (SELECT COALESCE(SUM(amount_allocated), 0) FROM public.payment_allocations pa JOIN public.payments p ON pa.payment_id = p.id WHERE p.contract_id = p_contract_id AND p.status = 'completed') -
        (SELECT COALESCE(SUM(amount_reversed), 0) FROM public.payment_allocation_reversals pr JOIN public.payments p ON pr.payment_id = p.id WHERE p.contract_id = p_contract_id)
    INTO v_net_allocated_so_far;

    IF (v_net_allocated_so_far + p_amount) > v_contract.total_contract_value THEN
        RAISE EXCEPTION 'Overpayment. Max allowed: %', (v_contract.total_contract_value - v_net_allocated_so_far);
    END IF;

    -- [E] استعادة حصة الشركة من الإعدادات
    v_company_ratio_raw := COALESCE((SELECT (value->>'ratio')::DECIMAL FROM public.system_settings WHERE key = 'company_profit_share_ratio'), 20);
    v_company_ratio := CASE WHEN v_company_ratio_raw > 1 THEN v_company_ratio_raw / 100.0 ELSE v_company_ratio_raw END;

    -- [F] تسجيل الدفعة
    INSERT INTO public.payments (contract_id, amount_total, payment_method, reference_no, recorded_by, idempotency_key, status)
    VALUES (p_contract_id, p_amount, p_payment_method, p_reference_no, auth.uid(), p_idempotency_key, 'completed')
    RETURNING id INTO v_payment_id;

    v_remaining_cash := p_amount;

    -- [G] توزيع FIFO على الأقساط والمستثمرين
    FOR v_inst IN (
        SELECT i.*, 
        (i.expected_amount - 
            (SELECT COALESCE(SUM(amount_allocated), 0) FROM public.payment_allocations WHERE installment_id = i.id) + 
            (SELECT COALESCE(SUM(amount_reversed), 0) FROM public.payment_allocation_reversals WHERE installment_id = i.id)
        ) as balance_due
        FROM public.installments i 
        WHERE i.contract_id = p_contract_id AND i.status IN ('unpaid', 'partially_paid') 
        ORDER BY i.due_date ASC FOR UPDATE
    ) LOOP
        EXIT WHEN v_remaining_cash <= 0;
        v_alloc_amount := LEAST(v_remaining_cash, v_inst.balance_due);
        
        IF v_alloc_amount > 0 THEN
            INSERT INTO public.payment_allocations (payment_id, installment_id, amount_allocated, allocation_type)
            VALUES (v_payment_id, v_inst.id, v_alloc_amount, 'installment_payment');
            
            v_principal_part := ROUND((v_inst.principal_component / v_inst.expected_amount) * v_alloc_amount, 2);
            v_profit_part := v_alloc_amount - v_principal_part;
            
            v_company_profit_share := ROUND(v_profit_part * v_company_ratio, 2);
            v_distributable_profit := v_profit_part - v_company_profit_share;

            v_rem_inv_principal := v_principal_part;
            v_rem_inv_profit := v_distributable_profit;
            
            -- جلب الممولين مع الترتيب لضمان قفل السجلات (Prevent Deadlocks)
            SELECT count(*) INTO v_funders_count FROM public.contract_funding WHERE contract_id = p_contract_id;
            v_current_funder_idx := 0;

            FOR v_funder IN (SELECT * FROM public.contract_funding WHERE contract_id = p_contract_id ORDER BY investor_id ASC) LOOP
                v_current_funder_idx := v_current_funder_idx + 1;
                
                IF v_current_funder_idx = v_funders_count THEN
                    v_investor_principal_share := v_rem_inv_principal;
                    v_investor_profit_share := v_rem_inv_profit;
                ELSE
                    v_investor_principal_share := ROUND((v_funder.amount_allocated / v_contract.principal_amount) * v_principal_part, 2);
                    v_investor_profit_share := ROUND((v_funder.amount_allocated / v_contract.principal_amount) * v_distributable_profit, 2);
                END IF;

                -- Lock Investor and Create Transactions
                PERFORM 1 FROM public.investors WHERE id = v_funder.investor_id FOR UPDATE;
                
                IF v_investor_principal_share > 0 THEN
                    INSERT INTO public.investor_transactions (investor_id, amount, type, reference_id, status)
                    VALUES (v_funder.investor_id, v_investor_principal_share, 'contract_return', v_payment_id, 'finalized');
                END IF;
                
                IF v_investor_profit_share > 0 THEN
                    INSERT INTO public.investor_transactions (investor_id, amount, type, reference_id, status)
                    VALUES (v_funder.investor_id, v_investor_profit_share, 'finance_profit_distribution', v_payment_id, 'finalized');
                    -- ملاحظة: لا حاجة لـ UPDATE يدوياً هنا، الـ Trigger سيتكفل بالأرصدة
                END IF;

                v_rem_inv_principal := v_rem_inv_principal - v_investor_principal_share;
                v_rem_inv_profit := v_rem_inv_profit - v_investor_profit_share;
            END LOOP;
            
            v_total_principal_paid := v_total_principal_paid + v_principal_part;
            v_total_profit_paid := v_total_profit_paid + v_profit_part;
            v_remaining_cash := v_remaining_cash - v_alloc_amount;
        END IF;
    END LOOP;

    -- [H] ترحيل القيود المحاسبية
    v_journal_lines := v_journal_lines || jsonb_build_object('account_code', '1101', 'debit', p_amount, 'credit', 0); -- الصندوق مدين
    v_journal_lines := v_journal_lines || jsonb_build_object('account_code', '1020', 'debit', 0, 'credit', p_amount); -- ذمم العقود دائن
    
    -- فصل الأرباح محاسبياً
    v_journal_lines := v_journal_lines || jsonb_build_object('account_code', '4010', 'debit', v_total_profit_paid, 'credit', 0); -- خصم من الأرباح المؤجلة
    v_journal_lines := v_journal_lines || jsonb_build_object('account_code', '2030', 'debit', 0, 'credit', v_total_profit_paid - ROUND(v_total_profit_paid * v_company_ratio, 2)); -- التزام للمستثمر
    v_journal_lines := v_journal_lines || jsonb_build_object('account_code', '4101', 'debit', 0, 'credit', ROUND(v_total_profit_paid * v_company_ratio, 2)); -- إيراد للشركة

    PERFORM public.post_journal_entry(v_fiscal_period_id, 'Payment Received - ' || v_contract.contract_no, p_reference_no, 'payment', v_payment_id, v_journal_lines);

    -- [I] الإغلاق التلقائي للعقد والتدقيق
    IF (v_net_allocated_so_far + p_amount) >= v_contract.total_contract_value THEN
        UPDATE public.financing_contracts SET status = 'closed', updated_at = NOW() WHERE id = p_contract_id;
        PERFORM public.emit_domain_event('ContractClosed', p_contract_id, jsonb_build_object('contract_no', v_contract.contract_no));
    END IF;

    INSERT INTO public.audit_logs (profile_id, event_type, table_name, record_id, new_values)
    VALUES (auth.uid(), 'PAYMENT_PROCESSED', 'payments', v_payment_id, jsonb_build_object('amount', p_amount));

    PERFORM public.emit_domain_event('PaymentReceived', v_payment_id, jsonb_build_object('amount', p_amount));
    RETURN jsonb_build_object('success', true, 'payment_id', v_payment_id);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
