-- ############################################################################
-- SECURITY HARDENING v2 - PRODUCTION GRADE RLS
-- VERSION: 1.0.0
-- ############################################################################

-- 1. إسقاط السياسات المفتوحة والمكررة
-- ############################################################################
DROP POLICY IF EXISTS "Authenticated users full access" ON public.financing_contracts;
DROP POLICY IF EXISTS "Authenticated users full access" ON public.installments;
DROP POLICY IF EXISTS "Authenticated users full access" ON public.payments;
DROP POLICY IF EXISTS "Authenticated users full access" ON public.profiles;
DROP POLICY IF EXISTS "Authenticated users full access" ON public.audit_logs;
DROP POLICY IF EXISTS "Authenticated users full access" ON public.contract_funding;

-- 2. تفعيل RLS على جميع الجداول الحساسة
-- ############################################################################
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

-- 3. سياسات الوصول بناءً على الأدوار (RBAC)
-- ############################################################################

-- البروفايلات: كل مستخدم يرى نفسه، والأدمن يرى الجميع
CREATE POLICY "profiles_view_own" ON public.profiles FOR SELECT TO authenticated USING (id = auth.uid());
CREATE POLICY "profiles_admin_all" ON public.profiles FOR SELECT TO authenticated USING (public.get_my_role() IN ('admin', 'manager'));
CREATE POLICY "profiles_admin_update" ON public.profiles FOR UPDATE TO authenticated USING (public.get_my_role() = 'admin');

-- المستثمرون: حماية البيانات المالية
CREATE POLICY "investors_view_staff" ON public.investors FOR SELECT TO authenticated USING (public.has_permission('view_investors'));
CREATE POLICY "investors_view_self" ON public.investors FOR SELECT TO authenticated USING (id = auth.uid());
CREATE POLICY "investors_manage_staff" ON public.investors FOR UPDATE TO authenticated USING (public.has_permission('manage_investors'));

-- العقود: الموظف يرى الكل، المستثمر يرى ما يموله فقط
CREATE POLICY "contracts_staff_view" ON public.financing_contracts FOR SELECT TO authenticated 
USING (public.has_permission('view_inventory') OR public.has_permission('process_payments'));

CREATE POLICY "contracts_investor_view" ON public.financing_contracts FOR SELECT TO authenticated 
USING (EXISTS (SELECT 1 FROM public.contract_funding cf WHERE cf.contract_id = id AND cf.investor_id = auth.uid()));

-- المحاسبة: قفل الجداول ضد الكتابة المباشرة (Write only via RPC)
CREATE POLICY "accounting_view_staff" ON public.accounts FOR SELECT TO authenticated USING (public.has_permission('view_accounting'));
CREATE POLICY "journal_view_staff" ON public.journal_entries FOR SELECT TO authenticated USING (public.has_permission('view_accounting'));
CREATE POLICY "journal_lines_view_staff" ON public.journal_entry_lines FOR SELECT TO authenticated USING (public.has_permission('view_accounting'));

-- منع الحذف والإضافة اليدوية في جداول اليومية
CREATE POLICY "journal_no_direct_insert" ON public.journal_entries FOR INSERT TO authenticated WITH CHECK (false);
CREATE POLICY "journal_no_direct_update" ON public.journal_entries FOR UPDATE TO authenticated USING (false);

-- 4. تأمين الـ RPCs (Security Definer)
-- ############################################################################
-- تم نقل post_journal_entry لتكون SECURITY DEFINER في ملف financial_engine_rpc.sql
