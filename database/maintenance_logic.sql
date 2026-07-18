-- ############################################################################
-- SYSTEM MAINTENANCE MODE LOGIC
-- ############################################################################

-- وظيفة للتحقق مما إذا كان النظام في وضع الصيانة
CREATE OR REPLACE FUNCTION public.is_maintenance_mode()
RETURNS BOOLEAN AS $$
BEGIN
    RETURN COALESCE((SELECT (value->>'is_active')::BOOLEAN FROM public.system_settings WHERE key = 'maintenance_mode'), false);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- وظيفة لتبديل وضع الصيانة
CREATE OR REPLACE FUNCTION public.toggle_maintenance_mode(p_is_active BOOLEAN, p_message TEXT)
RETURNS VOID AS $$
BEGIN
    IF NOT public.has_permission('manage_settings') THEN
        RAISE EXCEPTION 'Unauthorized';
    END IF;

    INSERT INTO public.system_settings (key, value)
    VALUES ('maintenance_mode', jsonb_build_object('is_active', p_is_active, 'message', p_message, 'updated_at', NOW()))
    ON CONFLICT (key) DO UPDATE SET value = EXCLUDED.value, updated_at = NOW();

    -- تسجيل في الرقابة
    INSERT INTO public.audit_logs (profile_id, event_type, table_name, record_id, new_values)
    VALUES (auth.uid(), 'SYSTEM_MAINTENANCE_TOGGLE', 'system_settings', '00000000-0000-0000-0000-000000000000', 
            jsonb_build_object('is_active', p_is_active, 'message', p_message));
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
