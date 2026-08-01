-- ############################################################################
-- SECURITY HARDENING v2 - PRODUCTION GRADE RLS
-- تطبيق مباشر على Supabase SQL Editor
-- يُكمّل security_logic.sql الموجود — لا يلغيه
-- ############################################################################

-- ============================================================
-- PART 1: إسقاط السياسات المفتوحة التي تسمح بوصول غير محكوم
-- ============================================================

-- العقود (الثغرة الأكبر — لا يوجد RLS عليها)
DROP POLICY IF EXISTS "Authenticated users full access" ON public.financing_contracts;
DROP POLICY IF EXISTS "Staff full access"               ON public.financing_contracts;
DROP POLICY IF EXISTS "contracts: staff view"           ON public.financing_contracts;
DROP POLICY IF EXISTS "contracts: investor view funded" ON public.financing_contracts;
DROP POLICY IF EXISTS "contracts: staff create"         ON public.financing_contracts;
DROP POLICY IF EXISTS "contracts: staff update"         ON public.financing_contracts;

-- الأقساط
DROP POLICY IF EXISTS "Authenticated users full access" ON public.installments;
DROP POLICY IF EXISTS "installments: staff view"        ON public.installments;
DROP POLICY IF EXISTS "installments: investor view"     ON public.installments;
DROP POLICY IF EXISTS "installments: no direct write"   ON public.installments;

-- المدفوعات
DROP POLICY IF EXISTS "Authenticated users full access" ON public.payments;
DROP POLICY IF EXISTS "payments: staff view"            ON public.payments;
DROP POLICY IF EXISTS "payments: investor view"         ON public.payments;
DROP POLICY IF EXISTS "payments: rpc insert only"       ON public.payments;

-- البروفايلات
DROP POLICY IF EXISTS "Authenticated users full access"    ON public.profiles;
DROP POLICY IF EXISTS "Users can view own profile"         ON public.profiles;
DROP POLICY IF EXISTS "Admins/Managers can view all profiles" ON public.profiles;
DROP POLICY IF EXISTS "Admins can update profiles"         ON public.profiles;
DROP POLICY IF EXISTS "profiles: own profile access"       ON public.profiles;
DROP POLICY IF EXISTS "profiles: admin-manager full view"  ON public.profiles;
DROP POLICY IF EXISTS "profiles: admin update"             ON public.profiles;
DROP POLICY IF EXISTS "profiles: admin delete"             ON public.profiles;

-- سجلات التدقيق
DROP POLICY IF EXISTS "Authenticated users full access" ON public.audit_logs;
DROP POLICY IF EXISTS "audit_logs: admin view"          ON public.audit_logs;
DROP POLICY IF EXISTS "audit_logs: no delete"           ON public.audit_logs;

-- المحاسبة
DROP POLICY IF EXISTS "accounts: accounting staff view" ON public.accounts;
DROP POLICY IF EXISTS "accounts: rpc write only"        ON public.accounts;
DROP POLICY IF EXISTS "accounts: rpc update only"       ON public.accounts;
DROP POLICY IF EXISTS "journal_entries: accounting view"     ON public.journal_entries;
DROP POLICY IF EXISTS "journal_entry_lines: accounting view" ON public.journal_entry_lines;

-- المستثمرون (إعادة بناء أفضل)
DROP POLICY IF EXISTS "Permission-based view"       ON public.investors;
DROP POLICY IF EXISTS "Permission-based management" ON public.investors;
DROP POLICY IF EXISTS "investors: staff view"       ON public.investors;
DROP POLICY IF EXISTS "investors: staff manage"     ON public.investors;
DROP POLICY IF EXISTS "investors: own data"         ON public.investors;

-- حركات المستثمرين
DROP POLICY IF EXISTS "investor_transactions: staff view"        ON public.investor_transactions;
DROP POLICY IF EXISTS "investor_transactions: own transactions"  ON public.investor_transactions;
DROP POLICY IF EXISTS "investor_transactions: rpc insert only"   ON public.investor_transactions;

-- طلبات السحب
DROP POLICY IF EXISTS "withdrawals: investor own"    ON public.withdrawal_requests;
DROP POLICY IF EXISTS "withdrawals: investor create" ON public.withdrawal_requests;
DROP POLICY IF EXISTS "withdrawals: admin manage"    ON public.withdrawal_requests;

-- إعدادات النظام
DROP POLICY IF EXISTS "settings: admin only" ON public.system_settings;

-- الإشعارات
DROP POLICY IF EXISTS "notifications: own only" ON public.notifications;

-- تمويل العقود
DROP POLICY IF EXISTS "Authenticated users full access" ON public.contract_funding;

-- ============================================================
-- PART 2: تفعيل RLS على الجداول غير المحمية
-- ============================================================

ALTER TABLE public.financing_contracts   ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.installments          ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.payments              ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.profiles              ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.investors             ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.investor_transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.withdrawal_requests   ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.audit_logs            ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.accounts              ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.journal_entries       ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.journal_entry_lines   ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.contract_funding      ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.system_settings       ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notifications         ENABLE ROW LEVEL SECURITY;

-- ============================================================
-- PART 3: سياسات profiles
-- ============================================================

-- كل مستخدم يشاهد بروفايله فقط
CREATE POLICY "profiles: own access"
ON public.profiles FOR SELECT
TO authenticated
USING (id = auth.uid());

-- الآدمن والمدير يشاهدون الكل
CREATE POLICY "profiles: admin-manager view all"
ON public.profiles FOR SELECT
TO authenticated
USING (public.get_my_role() IN ('admin', 'manager'));

-- فقط الآدمن يعدّل (تفعيل/إيقاف حسابات)
CREATE POLICY "profiles: admin update"
ON public.profiles FOR UPDATE
TO authenticated
USING (public.get_my_role() = 'admin');

-- ============================================================
-- PART 4: سياسات investors
-- ============================================================

-- الموظف المخوّل يشاهد جميع المستثمرين
CREATE POLICY "investors: staff view"
ON public.investors FOR SELECT
TO authenticated
USING (public.has_permission('view_investors'));

-- المستثمر يشاهد بياناته الخاصة
CREATE POLICY "investors: self view"
ON public.investors FOR SELECT
TO authenticated
USING (id = auth.uid());

-- الموظف المخوّل يدير المستثمرين
CREATE POLICY "investors: staff manage"
ON public.investors FOR UPDATE
TO authenticated
USING (public.has_permission('manage_investors'));

-- ============================================================
-- PART 5: سياسات investor_transactions
-- ============================================================

-- الموظف يشاهد جميع الحركات
CREATE POLICY "inv_tx: staff view"
ON public.investor_transactions FOR SELECT
TO authenticated
USING (public.has_permission('view_investors'));

-- المستثمر يشاهد حركاته فقط
CREATE POLICY "inv_tx: own view"
ON public.investor_transactions FOR SELECT
TO authenticated
USING (investor_id = auth.uid());

-- منع الإدراج المباشر — يتم فقط من خلال RPCs (SECURITY DEFINER)
CREATE POLICY "inv_tx: deny direct insert"
ON public.investor_transactions FOR INSERT
TO authenticated
WITH CHECK (false);

-- ============================================================
-- PART 6: سياسات financing_contracts
-- ============================================================

-- الموظف المخوّل يشاهد العقود
CREATE POLICY "contracts: staff view"
ON public.financing_contracts FOR SELECT
TO authenticated
USING (
    public.has_permission('create_contracts') OR
    public.has_permission('approve_contracts') OR
    public.has_permission('process_payments')
);

-- المستثمر يشاهد فقط العقود التي يموّلها
CREATE POLICY "contracts: investor view"
ON public.financing_contracts FOR SELECT
TO authenticated
USING (
    public.get_my_role() = 'investor' AND
    EXISTS (
        SELECT 1 FROM public.contract_funding cf
        WHERE cf.contract_id = id AND cf.investor_id = auth.uid()
    )
);

-- الموظف المخوّل ينشئ عقوداً
CREATE POLICY "contracts: staff create"
ON public.financing_contracts FOR INSERT
TO authenticated
WITH CHECK (public.has_permission('create_contracts'));

-- الموظف المخوّل يعدّل العقود
CREATE POLICY "contracts: staff update"
ON public.financing_contracts FOR UPDATE
TO authenticated
USING (
    public.has_permission('approve_contracts') OR
    public.has_permission('process_payments')
);

-- ============================================================
-- PART 7: سياسات installments
-- ============================================================

-- الموظف المخوّل يشاهد الأقساط
CREATE POLICY "installments: staff view"
ON public.installments FOR SELECT
TO authenticated
USING (
    public.has_permission('create_contracts') OR
    public.has_permission('approve_contracts') OR
    public.has_permission('process_payments')
);

-- المستثمر يشاهد أقساط عقوده فقط
CREATE POLICY "installments: investor view"
ON public.installments FOR SELECT
TO authenticated
USING (
    public.get_my_role() = 'investor' AND
    EXISTS (
        SELECT 1 FROM public.contract_funding cf
        WHERE cf.contract_id = contract_id AND cf.investor_id = auth.uid()
    )
);

-- منع الإدراج المباشر — يتم فقط من خلال RPCs
CREATE POLICY "installments: deny direct insert"
ON public.installments FOR INSERT
TO authenticated
WITH CHECK (false);

-- ============================================================
-- PART 8: سياسات payments
-- ============================================================

-- الموظف المخوّل يشاهد المدفوعات
CREATE POLICY "payments: staff view"
ON public.payments FOR SELECT
TO authenticated
USING (public.has_permission('process_payments'));

-- المستثمر يشاهد مدفوعات عقوده فقط
CREATE POLICY "payments: investor view"
ON public.payments FOR SELECT
TO authenticated
USING (
    public.get_my_role() = 'investor' AND
    EXISTS (
        SELECT 1 FROM public.contract_funding cf
        WHERE cf.contract_id = contract_id AND cf.investor_id = auth.uid()
    )
);

-- منع الإدراج المباشر — يتم فقط من خلال RPCs
CREATE POLICY "payments: deny direct insert"
ON public.payments FOR INSERT
TO authenticated
WITH CHECK (false);

-- ============================================================
-- PART 9: سياسات audit_logs
-- ============================================================

-- الآدمن والمدير فقط يشاهدون سجلات التدقيق
CREATE POLICY "audit_logs: admin-manager view"
ON public.audit_logs FOR SELECT
TO authenticated
USING (public.get_my_role() IN ('admin', 'manager'));

-- لا أحد يحذف سجلات التدقيق
CREATE POLICY "audit_logs: deny delete"
ON public.audit_logs FOR DELETE
TO authenticated
USING (false);

-- ============================================================
-- PART 10: سياسات المحاسبة (accounts, journal_entries)
-- ============================================================

-- عرض دليل الحسابات للمحاسبين والآدمن والمدير
CREATE POLICY "accounts: accounting view"
ON public.accounts FOR SELECT
TO authenticated
USING (
    public.has_permission('view_accounting') OR
    public.get_my_role() IN ('admin', 'manager')
);

-- منع التعديل المباشر
CREATE POLICY "accounts: deny direct write"
ON public.accounts FOR INSERT
TO authenticated
WITH CHECK (false);

CREATE POLICY "accounts: deny direct update"
ON public.accounts FOR UPDATE
TO authenticated
USING (false);

-- القيود المحاسبية
CREATE POLICY "journal_entries: accounting view"
ON public.journal_entries FOR SELECT
TO authenticated
USING (
    public.has_permission('view_accounting') OR
    public.get_my_role() IN ('admin', 'manager')
);

CREATE POLICY "journal_entry_lines: accounting view"
ON public.journal_entry_lines FOR SELECT
TO authenticated
USING (
    public.has_permission('view_accounting') OR
    public.get_my_role() IN ('admin', 'manager')
);

-- ============================================================
-- PART 11: سياسات contract_funding
-- ============================================================

-- الموظف المخوّل يشاهد جميع التمويلات
CREATE POLICY "contract_funding: staff view"
ON public.contract_funding FOR SELECT
TO authenticated
USING (public.has_permission('approve_contracts'));

-- المستثمر يشاهد تمويلاته فقط
CREATE POLICY "contract_funding: investor own"
ON public.contract_funding FOR SELECT
TO authenticated
USING (investor_id = auth.uid());

-- منع الإدراج المباشر
CREATE POLICY "contract_funding: deny direct insert"
ON public.contract_funding FOR INSERT
TO authenticated
WITH CHECK (false);

-- ============================================================
-- PART 12: سياسات system_settings
-- ============================================================

-- الآدمن فقط يشاهد ويعدّل الإعدادات
CREATE POLICY "system_settings: admin only"
ON public.system_settings FOR ALL
TO authenticated
USING (public.get_my_role() = 'admin');

-- ============================================================
-- PART 13: سياسات withdrawal_requests
-- ============================================================

-- المستثمر يشاهد ويرسل طلبات السحب الخاصة به فقط
CREATE POLICY "withdrawals: investor own view"
ON public.withdrawal_requests FOR SELECT
TO authenticated
USING (investor_id = auth.uid());

CREATE POLICY "withdrawals: investor own create"
ON public.withdrawal_requests FOR INSERT
TO authenticated
WITH CHECK (investor_id = auth.uid());

-- الموظف المخوّل يدير طلبات السحب (موافقة/رفض)
CREATE POLICY "withdrawals: staff manage"
ON public.withdrawal_requests FOR ALL
TO authenticated
USING (public.has_permission('manage_investors'));

-- ============================================================
-- PART 14: سياسات notifications
-- ============================================================

-- كل مستخدم يشاهد إشعاراته الخاصة فقط
CREATE POLICY "notifications: own access"
ON public.notifications FOR ALL
TO authenticated
USING (profile_id = auth.uid());

-- ============================================================
-- PART 15: تصحيح post_journal_entry من Invoker → Definer
-- هذا يمنع المستخدم المتصل من استغلال صلاحياته على الجداول
-- ============================================================

CREATE OR REPLACE FUNCTION public.post_journal_entry(
    p_fiscal_period_id UUID,
    p_description TEXT,
    p_reference_no TEXT,
    p_source_type TEXT,
    p_source_id UUID,
    p_lines JSONB
)
RETURNS UUID AS $$
DECLARE
    v_entry_id UUID;
    v_line RECORD;
    v_account_id UUID;
    v_debit DECIMAL(15,2);
    v_credit DECIMAL(15,2);
    v_debit_sum  DECIMAL(15,2) := 0;
    v_credit_sum DECIMAL(15,2) := 0;
BEGIN
    -- التحقق من إغلاق الفترة المالية
    IF EXISTS (
        SELECT 1 FROM public.fiscal_periods
        WHERE id = p_fiscal_period_id AND is_closed = true
    ) THEN
        RAISE EXCEPTION 'Cannot post to a closed fiscal period';
    END IF;

    INSERT INTO public.journal_entries (
        fiscal_period_id, description, reference_no, source_type, source_id
    )
    VALUES (
        p_fiscal_period_id, p_description, p_reference_no, p_source_type, p_source_id
    )
    RETURNING id INTO v_entry_id;

    FOR v_line IN (
        SELECT * FROM jsonb_to_recordset(p_lines)
        AS x(account_code TEXT, debit DECIMAL(15,2), credit DECIMAL(15,2))
    ) LOOP
        SELECT id INTO v_account_id
        FROM public.accounts WHERE code = v_line.account_code;

        IF v_account_id IS NULL THEN
            RAISE EXCEPTION 'Account code % not found in chart of accounts', v_line.account_code;
        END IF;

        v_debit  := COALESCE(v_line.debit, 0.00);
        v_credit := COALESCE(v_line.credit, 0.00);

        INSERT INTO public.journal_entry_lines (
            journal_entry_id, account_id, debit, credit
        )
        VALUES (v_entry_id, v_account_id, v_debit, v_credit);

        v_debit_sum  := v_debit_sum  + v_debit;
        v_credit_sum := v_credit_sum + v_credit;
    END LOOP;

    -- الشرط الأساسي: المدين = الدائن
    IF ABS(v_debit_sum - v_credit_sum) > 0.01 THEN
        RAISE EXCEPTION
            'Unbalanced journal entry — Debits: %, Credits: %',
            v_debit_sum, v_credit_sum;
    END IF;

    RETURN v_entry_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;  -- ← تم التغيير من INVOKER إلى DEFINER

-- ============================================================
-- PART 16: سياسات contract_documents
-- ============================================================
ALTER TABLE public.contract_documents ENABLE ROW LEVEL SECURITY;

CREATE POLICY "documents: staff manage"
ON public.contract_documents FOR ALL
TO authenticated
USING (
    public.has_permission('approve_contracts') OR 
    public.has_permission('manage_customers')
);

CREATE POLICY "documents: investor own"
ON public.contract_documents FOR SELECT
TO authenticated
USING (
    public.get_my_role() = 'investor' AND 
    investor_id = auth.uid()
);

CREATE POLICY "documents: customer own"
ON public.contract_documents FOR SELECT
TO authenticated
USING (
    customer_id = auth.uid()
);

-- ============================================================
-- PART 17: سياسات ownership_transfer_contracts
-- ============================================================
ALTER TABLE public.ownership_transfer_contracts ENABLE ROW LEVEL SECURITY;

CREATE POLICY "transfer_contracts: staff view"
ON public.ownership_transfer_contracts FOR SELECT
TO authenticated
USING (
    public.has_permission('create_contracts') OR
    public.has_permission('approve_contracts') OR
    public.has_permission('process_payments')
);

CREATE POLICY "transfer_contracts: customer view"
ON public.ownership_transfer_contracts FOR SELECT
TO authenticated
USING (
    customer_id = auth.uid()
);

CREATE POLICY "transfer_contracts: staff create"
ON public.ownership_transfer_contracts FOR INSERT
TO authenticated
WITH CHECK (public.has_permission('create_contracts'));

CREATE POLICY "transfer_contracts: staff update"
ON public.ownership_transfer_contracts FOR UPDATE
TO authenticated
USING (
    public.has_permission('approve_contracts') OR
    public.has_permission('process_payments')
);

-- ============================================================
-- PART 18: سياسات maintenance_logs
-- ============================================================
ALTER TABLE public.maintenance_logs ENABLE ROW LEVEL SECURITY;

CREATE POLICY "maintenance_logs: staff view"
ON public.maintenance_logs FOR SELECT
TO authenticated
USING (
    public.has_permission('view_inventory') OR
    public.has_permission('manage_inventory')
);

CREATE POLICY "maintenance_logs: staff manage"
ON public.maintenance_logs FOR ALL
TO authenticated
USING (
    public.has_permission('manage_inventory')
);

-- ============================================================
-- PART 19: سياسات inventory_images
-- ============================================================
ALTER TABLE public.inventory_images ENABLE ROW LEVEL SECURITY;

CREATE POLICY "inventory_images: staff view"
ON public.inventory_images FOR SELECT
TO authenticated
USING (
    public.has_permission('view_inventory') OR
    public.has_permission('manage_inventory')
);

CREATE POLICY "inventory_images: staff manage"
ON public.inventory_images FOR ALL
TO authenticated
USING (
    public.has_permission('manage_inventory')
);

-- ============================================================
-- PART 20: سياسات سجلات الحماية (security logs)
-- ============================================================
ALTER TABLE public.security_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.security_events ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.password_history ENABLE ROW LEVEL SECURITY;

-- العرض للأدمن فقط
CREATE POLICY "security_logs: admin view" ON public.security_logs FOR SELECT TO authenticated USING (public.get_my_role() = 'admin');
CREATE POLICY "security_events: admin view" ON public.security_events FOR SELECT TO authenticated USING (public.get_my_role() = 'admin');
CREATE POLICY "password_history: admin view" ON public.password_history FOR SELECT TO authenticated USING (public.get_my_role() = 'admin');

-- السماح بالإدراج للمستخدم الحالي
CREATE POLICY "security_logs: insert own" ON public.security_logs FOR INSERT TO authenticated WITH CHECK (user_id = auth.uid());
CREATE POLICY "security_events: insert own" ON public.security_events FOR INSERT TO authenticated WITH CHECK (user_id = auth.uid());
CREATE POLICY "password_history: insert own" ON public.password_history FOR INSERT TO authenticated WITH CHECK (user_id = auth.uid());

-- منع التعديل والحذف نهائياً
CREATE POLICY "security_logs: deny write" ON public.security_logs FOR UPDATE TO authenticated USING (false);
CREATE POLICY "security_logs: deny delete" ON public.security_logs FOR DELETE TO authenticated USING (false);
CREATE POLICY "security_events: deny write" ON public.security_events FOR UPDATE TO authenticated USING (false);
CREATE POLICY "security_events: deny delete" ON public.security_events FOR DELETE TO authenticated USING (false);
CREATE POLICY "password_history: deny write" ON public.password_history FOR UPDATE TO authenticated USING (false);
CREATE POLICY "password_history: deny delete" ON public.password_history FOR DELETE TO authenticated USING (false);

-- ============================================================
-- PART 21: سياسات background_jobs
-- ============================================================
ALTER TABLE public.background_jobs ENABLE ROW LEVEL SECURITY;

CREATE POLICY "background_jobs: admin only"
ON public.background_jobs FOR ALL
TO authenticated
USING (public.get_my_role() = 'admin');

-- ============================================================
-- PART 22: سياسات backup_history
-- ============================================================
ALTER TABLE public.backup_history ENABLE ROW LEVEL SECURITY;

CREATE POLICY "backup_history: admin only"
ON public.backup_history FOR ALL
TO authenticated
USING (public.get_my_role() = 'admin');

-- ============================================================
-- PART 23: سياسات integrity_checks
-- ============================================================
ALTER TABLE public.integrity_checks ENABLE ROW LEVEL SECURITY;

CREATE POLICY "integrity_checks: admin-manager view"
ON public.integrity_checks FOR SELECT
TO authenticated
USING (public.get_my_role() IN ('admin', 'manager'));

-- لا يسمح بالكتابة اليدوية إلا للأدمن
CREATE POLICY "integrity_checks: admin write"
ON public.integrity_checks FOR ALL
TO authenticated
USING (public.get_my_role() = 'admin');

-- ============================================================
-- PART 24: سياسات user_invitations
-- ============================================================
ALTER TABLE public.user_invitations ENABLE ROW LEVEL SECURITY;

CREATE POLICY "user_invitations: admin-manager manage"
ON public.user_invitations FOR ALL
TO authenticated
USING (public.get_my_role() IN ('admin', 'manager'));
