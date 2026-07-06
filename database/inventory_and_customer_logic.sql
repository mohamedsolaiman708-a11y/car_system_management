-- ############################################################################
-- PHASE 3.2: INVESTOR SERVICE - EXTENDED (Statement Logic)
-- ############################################################################

-- وظيفة جلب كشف حساب المستثمر (Financial Statement)
CREATE OR REPLACE FUNCTION public.get_investor_statement(
    p_investor_id UUID,
    p_start_date DATE,
    p_end_date DATE
)
RETURNS TABLE (
    transaction_date TIMESTAMPTZ,
    type public.transaction_type,
    amount DECIMAL(15,2),
    description TEXT,
    running_balance DECIMAL(15,2)
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        created_at,
        type,
        amount,
        description,
        SUM(CASE 
            WHEN type IN ('deposit', 'contract_return', 'finance_profit_distribution') THEN amount 
            WHEN type IN ('withdrawal', 'contract_allocation') THEN -amount 
            ELSE 0 END) 
        OVER (ORDER BY created_at) as running_balance
    FROM public.investor_transactions
    WHERE investor_id = p_investor_id
    AND created_at::DATE BETWEEN p_start_date AND p_end_date
    ORDER BY created_at DESC;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ############################################################################
-- PHASE 3.3: INVENTORY SERVICE LOGIC
-- ############################################################################

-- 1. وظيفة تسجيل دخول مركبة للصيانة
CREATE OR REPLACE FUNCTION public.register_vehicle_maintenance(
    p_inventory_item_id UUID,
    p_description TEXT,
    p_cost DECIMAL(15,2)
)
RETURNS VOID AS $$
BEGIN
    -- التحقق من الصلاحيات
    IF NOT public.has_permission('manage_inventory') THEN
        RAISE EXCEPTION 'Unauthorized';
    END IF;

    -- التحقق من حالة المركبة (لا يمكن صيانة مركبة "على عقد")
    IF EXISTS (SELECT 1 FROM public.inventory_items WHERE id = p_inventory_item_id AND status = 'on_contract') THEN
        RAISE EXCEPTION 'Vehicle is currently on contract and cannot be moved to maintenance';
    END IF;

    -- تحديث حالة المركبة
    UPDATE public.inventory_items 
    SET status = 'maintenance', updated_at = NOW()
    WHERE id = p_inventory_item_id;

    -- إضافة سجل صيانة
    INSERT INTO public.maintenance_logs (inventory_item_id, description, cost, performed_at)
    VALUES (p_inventory_item_id, p_description, p_cost, CURRENT_DATE);

    -- تسجيل في الرقابة
    INSERT INTO public.audit_logs (profile_id, event_type, table_name, record_id, new_values)
    VALUES (auth.uid(), 'VEHICLE_MAINTENANCE_START', 'inventory_items', p_inventory_item_id, 
            jsonb_build_object('cost', p_cost, 'status', 'maintenance'));
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 2. وظيفة إتمام الصيانة وإعادة المركبة للخدمة
CREATE OR REPLACE FUNCTION public.complete_vehicle_maintenance(
    p_inventory_item_id UUID
)
RETURNS VOID AS $$
BEGIN
    IF NOT public.has_permission('manage_inventory') THEN
        RAISE EXCEPTION 'Unauthorized';
    END IF;

    UPDATE public.inventory_items 
    SET status = 'available', updated_at = NOW()
    WHERE id = p_inventory_item_id;

    INSERT INTO public.audit_logs (profile_id, event_type, table_name, record_id, new_values)
    VALUES (auth.uid(), 'VEHICLE_MAINTENANCE_COMPLETE', 'inventory_items', p_inventory_item_id, 
            jsonb_build_object('status', 'available'));
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ############################################################################
-- PHASE 3.4: CUSTOMER SERVICE LOGIC
-- ############################################################################

-- وظيفة تحديث تقييم المخاطر للعميل
CREATE OR REPLACE FUNCTION public.update_customer_risk_rating(
    p_customer_id UUID,
    p_risk_rating TEXT
)
RETURNS VOID AS $$
BEGIN
    IF NOT public.has_permission('manage_customers') THEN
        RAISE EXCEPTION 'Unauthorized';
    END IF;

    UPDATE public.customers 
    SET risk_rating = p_risk_rating, updated_at = NOW()
    WHERE id = p_customer_id;

    INSERT INTO public.audit_logs (profile_id, event_type, table_name, record_id, new_values)
    VALUES (auth.uid(), 'CUSTOMER_RISK_UPDATE', 'customers', p_customer_id, 
            jsonb_build_object('risk_rating', p_risk_rating));
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
