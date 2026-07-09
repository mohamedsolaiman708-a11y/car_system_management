-- ############################################################################
-- AUTOMATED NOTIFICATION ENGINE (SQL TRIGGERS)
-- ############################################################################

-- 1. وظيفة إرسال تنبيه للمستثمرين عند تحصيل أرباح
CREATE OR REPLACE FUNCTION public.notify_investor_on_profit()
RETURNS TRIGGER AS $$
BEGIN
    IF (NEW.type = 'finance_profit_distribution') THEN
        INSERT INTO public.notifications (profile_id, title, content, type)
        VALUES (
            NEW.investor_id, 
            '💰 إيداع أرباح جديد', 
            'تم إيداع مبلغ ' || NEW.amount || ' ر.س كأرباح في رصيدك المتاح.', 
            'success'
        );
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER tr_notify_investor_profit
AFTER INSERT ON public.investor_transactions
FOR EACH ROW EXECUTE FUNCTION public.notify_investor_on_profit();

-- 2. وظيفة تنبيه الإدارة عند تسجيل مستثمر جديد (Pending Approval)
CREATE OR REPLACE FUNCTION public.notify_admin_on_new_registration()
RETURNS TRIGGER AS $$
DECLARE
    v_admin_id UUID;
BEGIN
    IF (NEW.status = 'pending') THEN
        FOR v_admin_id IN (SELECT p.id FROM public.profiles p JOIN public.roles r ON p.role_id = r.id WHERE r.slug = 'admin') LOOP
            INSERT INTO public.notifications (profile_id, title, content, type)
            VALUES (
                v_admin_id, 
                '👤 طلب انضمام مستثمر', 
                'هناك طلب انضمام جديد من: ' || NEW.full_name || '. يرجى المراجعة والاعتماد.', 
                'info'
            );
        END LOOP;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER tr_notify_admin_registration
AFTER INSERT ON public.profiles
FOR EACH ROW EXECUTE FUNCTION public.notify_admin_on_new_registration();

-- 3. وظيفة تنبيه الإدارة عند تعثر قسط (Overdue)
CREATE OR REPLACE FUNCTION public.notify_admin_on_overdue()
RETURNS TRIGGER AS $$
DECLARE
    v_admin_id UUID;
    v_customer_name TEXT;
BEGIN
    IF (NEW.status = 'overdue' AND OLD.status != 'overdue') THEN
        SELECT c.full_name INTO v_customer_name 
        FROM public.financing_contracts con
        JOIN public.customers c ON con.customer_id = c.id
        WHERE con.id = NEW.contract_id;

        FOR v_admin_id IN (SELECT p.id FROM public.profiles p JOIN public.roles r ON p.role_id = r.id WHERE r.slug = 'admin') LOOP
            INSERT INTO public.notifications (profile_id, title, content, type)
            VALUES (
                v_admin_id, 
                '⚠️ قسط متأخر', 
                'تأخر سداد قسط بقيمة ' || NEW.expected_amount || ' ر.س للعميل: ' || v_customer_name, 
                'warning'
            );
        END LOOP;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER tr_notify_overdue_installment
AFTER UPDATE OF status ON public.installments
FOR EACH ROW EXECUTE FUNCTION public.notify_admin_on_overdue();
