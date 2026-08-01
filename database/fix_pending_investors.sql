-- ============================================================================
-- FIX: Pending Investors Display Issue
-- Run this in Supabase SQL Editor → New Query → Run
-- ============================================================================

-- 1. Create registration_status enum (if not exists)
DO $$ BEGIN
    CREATE TYPE public.registration_status AS ENUM ('pending', 'approved', 'rejected');
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

-- 2. Add missing columns to profiles (if not exists)
ALTER TABLE public.profiles
    ADD COLUMN IF NOT EXISTS email TEXT,
    ADD COLUMN IF NOT EXISTS phone TEXT,
    ADD COLUMN IF NOT EXISTS national_id TEXT,
    ADD COLUMN IF NOT EXISTS rejection_reason TEXT,
    ADD COLUMN IF NOT EXISTS rejected_at TIMESTAMPTZ,
    ADD COLUMN IF NOT EXISTS status public.registration_status DEFAULT 'pending';

-- 3. Backfill email from auth.users for existing profiles
UPDATE public.profiles p
SET email = u.email
FROM auth.users u
WHERE p.id = u.id
AND p.email IS NULL;

-- 4. Set status = 'approved' for admin/manager/accountant (non-investor) profiles
UPDATE public.profiles p
SET status = 'approved'
FROM public.roles r
WHERE p.role_id = r.id
AND r.slug IN ('admin', 'manager', 'accountant')
AND (p.status IS NULL OR p.status::TEXT != 'pending');

-- 5. Ensure all new investor profiles default to 'pending'
UPDATE public.profiles p
SET status = 'pending'
FROM public.roles r
WHERE p.role_id = r.id
AND r.slug = 'investor'
AND p.status IS NULL;

-- 6. Rebuild the handle_new_user trigger (robust + stores email)
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
DECLARE
    v_role_id UUID;
    v_invitation RECORD;
BEGIN
    -- Try to find an active invitation
    BEGIN
        SELECT * INTO v_invitation
        FROM public.user_invitations
        WHERE email = NEW.email
          AND accepted_at IS NULL
          AND expires_at > NOW()
        LIMIT 1;
    EXCEPTION WHEN OTHERS THEN
        v_invitation.id := NULL;
    END;

    IF v_invitation IS NOT NULL AND v_invitation.id IS NOT NULL THEN
        -- Staff via invitation → approved immediately
        v_role_id := v_invitation.role_id;

        INSERT INTO public.profiles (id, role_id, full_name, email, is_active, status)
        VALUES (
            NEW.id,
            v_role_id,
            COALESCE(NEW.raw_user_meta_data->>'full_name', 'New Staff'),
            NEW.email,
            true,
            'approved'
        )
        ON CONFLICT (id) DO NOTHING;

        UPDATE public.user_invitations
        SET accepted_at = NOW()
        WHERE id = v_invitation.id;
    ELSE
        -- Default: investor → pending review
        BEGIN
            SELECT id INTO v_role_id FROM public.roles WHERE slug = 'investor' LIMIT 1;
        EXCEPTION WHEN OTHERS THEN
            v_role_id := NULL;
        END;

        BEGIN
            INSERT INTO public.profiles (id, role_id, full_name, email, phone, national_id, is_active, status)
            VALUES (
                NEW.id,
                v_role_id,
                COALESCE(NEW.raw_user_meta_data->>'full_name', 'New Investor'),
                NEW.email,
                NEW.raw_user_meta_data->>'phone',
                NEW.raw_user_meta_data->>'national_id',
                true,
                'pending'
            )
            ON CONFLICT (id) DO NOTHING;
        EXCEPTION WHEN OTHERS THEN
            -- Last resort minimal insert
            BEGIN
                INSERT INTO public.profiles (id, full_name, email)
                VALUES (
                    NEW.id,
                    COALESCE(NEW.raw_user_meta_data->>'full_name', 'New Investor'),
                    NEW.email
                )
                ON CONFLICT (id) DO NOTHING;
            EXCEPTION WHEN OTHERS THEN
                NULL; -- Never abort user creation
            END;
        END;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Re-apply trigger
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- 7. Create get_pending_investors() RPC — secure, returns only pending investors
DROP FUNCTION IF EXISTS public.get_pending_investors();

CREATE OR REPLACE FUNCTION public.get_pending_investors()
RETURNS TABLE (
    id          UUID,
    full_name   TEXT,
    email       TEXT,
    phone       TEXT,
    national_id TEXT,
    status      TEXT,
    created_at  TIMESTAMPTZ
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    RETURN QUERY
    SELECT
        p.id,
        COALESCE(p.full_name, 'مستثمر جديد')::TEXT,
        COALESCE(p.email, u.email, '')::TEXT,
        COALESCE(p.phone, '')::TEXT,
        COALESCE(p.national_id, '')::TEXT,
        COALESCE(p.status::TEXT, 'pending'),
        p.created_at
    FROM public.profiles p
    LEFT JOIN auth.users u ON p.id = u.id
    LEFT JOIN public.roles r ON p.role_id = r.id
    WHERE (
        p.status IS NULL
        OR LOWER(p.status::TEXT) IN ('pending', 'waiting')
    )
    AND (p.status::TEXT IS NULL OR LOWER(p.status::TEXT) NOT IN ('approved', 'rejected'))
    AND (r.slug IS NULL OR r.slug = 'investor')
    ORDER BY p.created_at DESC;
END;
$$;

GRANT EXECUTE ON FUNCTION public.get_pending_investors() TO authenticated;

-- 8. Create approve_investor_profile() RPC
DROP FUNCTION IF EXISTS public.approve_investor_profile(UUID);

CREATE OR REPLACE FUNCTION public.approve_investor_profile(
    p_profile_id UUID
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_profile RECORD;
    v_email TEXT;
BEGIN
    SELECT p.*, COALESCE(p.email, u.email, '') as user_email
    INTO v_profile 
    FROM public.profiles p
    LEFT JOIN auth.users u ON p.id = u.id
    WHERE p.id = p_profile_id;

    IF v_profile.id IS NULL THEN
        RAISE EXCEPTION 'Profile not found';
    END IF;

    -- 1. Update profile status to approved
    UPDATE public.profiles
    SET status = 'approved'::public.registration_status,
        is_active = true,
        updated_at = NOW()
    WHERE id = p_profile_id;

    -- 2. Ensure record exists in public.investors so investor can operate financially
    INSERT INTO public.investors (id, full_name, email, available_balance, deployed_capital, total_profit_earned, created_at, updated_at)
    VALUES (
        p_profile_id,
        COALESCE(v_profile.full_name, 'مستثمر'),
        COALESCE(v_profile.user_email, ''),
        0.00,
        0.00,
        0.00,
        NOW(),
        NOW()
    )
    ON CONFLICT (id) DO UPDATE
    SET full_name = EXCLUDED.full_name,
        email = COALESCE(public.investors.email, EXCLUDED.email),
        updated_at = NOW();

    -- 3. Audit log
    BEGIN
        INSERT INTO public.audit_logs (profile_id, event_type, table_name, record_id, new_values)
        VALUES (
            auth.uid(),
            'APPROVE_INVESTOR',
            'profiles',
            p_profile_id,
            jsonb_build_object('full_name', v_profile.full_name, 'email', v_profile.user_email)
        );
    EXCEPTION WHEN OTHERS THEN
        NULL;
    END;

    RETURN jsonb_build_object('success', true, 'profile_id', p_profile_id);
END;
$$;

GRANT EXECUTE ON FUNCTION public.approve_investor_profile(UUID) TO authenticated;

-- 9. Create reject_investor_profile() RPC
DROP FUNCTION IF EXISTS public.reject_investor_profile(UUID, TEXT);
DROP FUNCTION IF EXISTS public.reject_investor_profile(UUID);

CREATE OR REPLACE FUNCTION public.reject_investor_profile(
    p_profile_id UUID,
    p_reason TEXT DEFAULT NULL
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_profile RECORD;
BEGIN
    SELECT * INTO v_profile FROM public.profiles WHERE id = p_profile_id;
    IF v_profile.id IS NULL THEN
        RAISE EXCEPTION 'Profile not found';
    END IF;

    UPDATE public.profiles
    SET status = 'rejected'::public.registration_status,
        is_active = false,
        rejection_reason = p_reason,
        rejected_at = NOW(),
        updated_at = NOW()
    WHERE id = p_profile_id;

    -- Audit log
    BEGIN
        INSERT INTO public.audit_logs (profile_id, event_type, table_name, record_id, new_values)
        VALUES (
            auth.uid(),
            'REJECT_INVESTOR',
            'profiles',
            p_profile_id,
            jsonb_build_object('full_name', v_profile.full_name, 'reason', p_reason)
        );
    EXCEPTION WHEN OTHERS THEN
        NULL;
    END;

    RETURN jsonb_build_object('success', true, 'profile_id', p_profile_id);
END;
$$;

GRANT EXECUTE ON FUNCTION public.reject_investor_profile(UUID, TEXT) TO authenticated;

-- 10. Ensure withdrawal_requests table exists and permissions are granted
DO $$ BEGIN
    CREATE TYPE public.request_status AS ENUM ('pending', 'approved', 'rejected', 'cancelled');
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

CREATE TABLE IF NOT EXISTS public.withdrawal_requests (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    investor_id UUID REFERENCES public.investors(id),
    amount DECIMAL(15,2) NOT NULL CHECK (amount > 0),
    bank_account_details TEXT,
    status public.request_status DEFAULT 'pending',
    rejection_reason TEXT,
    processed_at TIMESTAMPTZ,
    processed_by UUID REFERENCES public.profiles(id),
    created_at TIMESTAMPTZ DEFAULT NOW()
);

GRANT SELECT, INSERT, UPDATE, DELETE ON public.withdrawal_requests TO authenticated;

-- 10b. Add recorded_by_name column to investor_transactions for staff transparency
ALTER TABLE public.investor_transactions
    ADD COLUMN IF NOT EXISTS recorded_by_name TEXT;

-- 11. Self-Healing process_investor_deposit RPC
DROP FUNCTION IF EXISTS public.process_investor_deposit(UUID, DECIMAL, TEXT, TEXT);

CREATE OR REPLACE FUNCTION public.process_investor_deposit(
    p_investor_id UUID,
    p_amount DECIMAL(15,2),
    p_description TEXT DEFAULT 'Deposit',
    p_idempotency_key TEXT DEFAULT NULL
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_journal_id UUID;
    v_cash_account_id UUID;
    v_capital_account_id UUID;
    v_fiscal_period_id UUID;
    v_existing_tx_id UUID;
    v_staff_name TEXT;
    v_investor_name TEXT;
BEGIN
    -- 1. Ensure investor row exists in public.investors
    IF NOT EXISTS (SELECT 1 FROM public.investors WHERE id = p_investor_id) THEN
        INSERT INTO public.investors (id, full_name, email, available_balance, deployed_capital, total_profit_earned, created_at, updated_at)
        SELECT 
            p.id,
            COALESCE(p.full_name, 'مستثمر'),
            COALESCE(p.email, u.email, ''),
            0.00, 0.00, 0.00, NOW(), NOW()
        FROM public.profiles p
        LEFT JOIN auth.users u ON p.id = u.id
        WHERE p.id = p_investor_id
        ON CONFLICT (id) DO NOTHING;
    END IF;

    -- Fetch staff & investor names
    SELECT COALESCE(full_name, 'Staff') INTO v_staff_name FROM public.profiles WHERE id = auth.uid();
    SELECT COALESCE(full_name, 'Investor') INTO v_investor_name FROM public.investors WHERE id = p_investor_id;

    -- 2. Idempotency Check
    IF p_idempotency_key IS NOT NULL AND p_idempotency_key != '' THEN
        SELECT id INTO v_existing_tx_id FROM public.investor_transactions WHERE reference_id::text = p_idempotency_key;
        IF v_existing_tx_id IS NOT NULL THEN
            RETURN jsonb_build_object('success', true, 'message', 'Duplicate request ignored', 'tx_id', v_existing_tx_id);
        END IF;
    END IF;

    -- 3. Ensure accounting accounts exist
    INSERT INTO public.accounts (code, name, type, is_reconcilable)
    VALUES 
    ('1010', 'Cash at Bank', 'asset', true),
    ('2010', 'Investors Capital', 'liability', true),
    ('2030', 'Profit Payable', 'liability', true)
    ON CONFLICT (code) DO NOTHING;

    SELECT id INTO v_cash_account_id FROM public.accounts WHERE code = '1010' LIMIT 1;
    SELECT id INTO v_capital_account_id FROM public.accounts WHERE code = '2010' LIMIT 1;

    -- 4. Ensure an open fiscal period for current date
    SELECT id INTO v_fiscal_period_id 
    FROM public.fiscal_periods 
    WHERE is_closed = false 
      AND CURRENT_DATE BETWEEN start_date AND end_date 
    LIMIT 1;

    IF v_fiscal_period_id IS NULL THEN
        INSERT INTO public.fiscal_periods (name, start_date, end_date, is_closed)
        VALUES (
            'Fiscal Year ' || EXTRACT(YEAR FROM CURRENT_DATE)::TEXT,
            DATE_TRUNC('year', CURRENT_DATE)::DATE,
            (DATE_TRUNC('year', CURRENT_DATE) + INTERVAL '1 year - 1 day')::DATE,
            false
        )
        RETURNING id INTO v_fiscal_period_id;
    END IF;

    -- 5. Record investor transaction (trigger handle_investor_ledger updates balance automatically)
    INSERT INTO public.investor_transactions (investor_id, amount, type, description, recorded_by_name)
    VALUES (p_investor_id, p_amount, 'deposit', COALESCE(p_description, 'إيداع رأس مال'), COALESCE(v_staff_name, 'System'))
    RETURNING id INTO v_existing_tx_id;

    -- 6. Record Journal Entries (best-effort)
    BEGIN
        IF v_fiscal_period_id IS NOT NULL AND v_cash_account_id IS NOT NULL AND v_capital_account_id IS NOT NULL THEN
            INSERT INTO public.journal_entries (fiscal_period_id, description, source_type, source_id)
            VALUES (v_fiscal_period_id, 'Investor Deposit (' || COALESCE(v_investor_name, '') || '): ' || COALESCE(p_description, ''), 'investor_transaction', p_investor_id)
            RETURNING id INTO v_journal_id;

            INSERT INTO public.journal_entry_lines (journal_entry_id, account_id, debit, credit)
            VALUES 
            (v_journal_id, v_cash_account_id, p_amount, 0), 
            (v_journal_id, v_capital_account_id, 0, p_amount);
        END IF;
    EXCEPTION WHEN OTHERS THEN
        NULL;
    END;

    -- 8. Audit Log
    BEGIN
        INSERT INTO public.audit_logs (profile_id, event_type, table_name, record_id, new_values)
        VALUES (
            auth.uid(), 
            'INVESTOR_DEPOSIT', 
            'investor_transactions', 
            v_existing_tx_id, 
            jsonb_build_object(
                'المستثمر', v_investor_name,
                'المبلغ', p_amount, 
                'البيان', p_description
            )
        );
    EXCEPTION WHEN OTHERS THEN
        NULL;
    END;

    RETURN jsonb_build_object('success', true, 'tx_id', v_existing_tx_id);
END;
$$;

GRANT EXECUTE ON FUNCTION public.process_investor_deposit(UUID, DECIMAL, TEXT, TEXT) TO authenticated;

-- 12. Self-Healing process_investor_withdrawal RPC
DROP FUNCTION IF EXISTS public.process_investor_withdrawal(UUID, DECIMAL, TEXT, TEXT);

CREATE OR REPLACE FUNCTION public.process_investor_withdrawal(
    p_investor_id UUID,
    p_amount DECIMAL(15,2),
    p_description TEXT DEFAULT 'Withdrawal',
    p_idempotency_key TEXT DEFAULT NULL
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_available_balance DECIMAL(15,2);
    v_journal_id UUID;
    v_cash_account_id UUID;
    v_capital_account_id UUID;
    v_fiscal_period_id UUID;
    v_existing_tx_id UUID;
    v_staff_name TEXT;
    v_investor_name TEXT;
BEGIN
    -- 1. Check liquidity
    SELECT COALESCE(available_balance, 0) INTO v_available_balance FROM public.investors WHERE id = p_investor_id FOR UPDATE;
    IF v_available_balance < p_amount THEN
        RAISE EXCEPTION 'Insufficient balance: Investor only has % available', v_available_balance;
    END IF;

    SELECT COALESCE(full_name, 'Staff') INTO v_staff_name FROM public.profiles WHERE id = auth.uid();
    SELECT COALESCE(full_name, 'Investor') INTO v_investor_name FROM public.investors WHERE id = p_investor_id;

    -- 2. Idempotency Check
    IF p_idempotency_key IS NOT NULL AND p_idempotency_key != '' THEN
        SELECT id INTO v_existing_tx_id FROM public.investor_transactions WHERE reference_id::text = p_idempotency_key;
        IF v_existing_tx_id IS NOT NULL THEN
            RETURN jsonb_build_object('success', true, 'message', 'Duplicate request ignored', 'tx_id', v_existing_tx_id);
        END IF;
    END IF;

    -- 3. Ensure accounting accounts & fiscal period exist
    SELECT id INTO v_cash_account_id FROM public.accounts WHERE code = '1010' LIMIT 1;
    SELECT id INTO v_capital_account_id FROM public.accounts WHERE code = '2010' LIMIT 1;

    SELECT id INTO v_fiscal_period_id 
    FROM public.fiscal_periods 
    WHERE is_closed = false 
      AND CURRENT_DATE BETWEEN start_date AND end_date 
    LIMIT 1;

    IF v_fiscal_period_id IS NULL THEN
        INSERT INTO public.fiscal_periods (name, start_date, end_date, is_closed)
        VALUES (
            'Fiscal Year ' || EXTRACT(YEAR FROM CURRENT_DATE)::TEXT,
            DATE_TRUNC('year', CURRENT_DATE)::DATE,
            (DATE_TRUNC('year', CURRENT_DATE) + INTERVAL '1 year - 1 day')::DATE,
            false
        )
        RETURNING id INTO v_fiscal_period_id;
    END IF;

    -- 4. Record transaction (trigger handle_investor_ledger deducts balance automatically)
    INSERT INTO public.investor_transactions (investor_id, amount, type, description, recorded_by_name)
    VALUES (p_investor_id, p_amount, 'withdrawal', COALESCE(p_description, 'سحب رأس مال'), COALESCE(v_staff_name, 'System'))
    RETURNING id INTO v_existing_tx_id;

    -- 5. Journal entry (best-effort)
    BEGIN
        IF v_fiscal_period_id IS NOT NULL AND v_cash_account_id IS NOT NULL AND v_capital_account_id IS NOT NULL THEN
            INSERT INTO public.journal_entries (fiscal_period_id, description, source_type, source_id)
            VALUES (v_fiscal_period_id, 'Investor Withdrawal (' || COALESCE(v_investor_name, '') || '): ' || COALESCE(p_description, ''), 'investor_transaction', p_investor_id)
            RETURNING id INTO v_journal_id;

            INSERT INTO public.journal_entry_lines (journal_entry_id, account_id, debit, credit)
            VALUES 
            (v_journal_id, v_capital_account_id, p_amount, 0),
            (v_journal_id, v_cash_account_id, 0, p_amount);
        END IF;
    EXCEPTION WHEN OTHERS THEN
        NULL;
    END;

    -- 7. Audit Log
    BEGIN
        INSERT INTO public.audit_logs (profile_id, event_type, table_name, record_id, new_values)
        VALUES (
            auth.uid(), 
            'INVESTOR_WITHDRAWAL', 
            'investor_transactions', 
            v_existing_tx_id, 
            jsonb_build_object(
                'المستثمر', v_investor_name,
                'المبلغ', p_amount, 
                'البيان', p_description
            )
        );
    EXCEPTION WHEN OTHERS THEN
        NULL;
    END;

    RETURN jsonb_build_object('success', true, 'tx_id', v_existing_tx_id);
END;
$$;

GRANT EXECUTE ON FUNCTION public.process_investor_withdrawal(UUID, DECIMAL, TEXT, TEXT) TO authenticated;

-- 13. Ensure RLS Policy and Permissions on withdrawal_requests
ALTER TABLE public.withdrawal_requests ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Allow authenticated users full access to withdrawal_requests" ON public.withdrawal_requests;
CREATE POLICY "Allow authenticated users full access to withdrawal_requests" 
ON public.withdrawal_requests FOR ALL TO authenticated USING (true) WITH CHECK (true);

GRANT ALL ON public.withdrawal_requests TO authenticated;

-- 14. RPC for Investor to Request Withdrawal (Creates pending request ONLY - NO IMMEDIATE DEDUCTION)
DROP FUNCTION IF EXISTS public.request_withdrawal(DECIMAL, TEXT);

CREATE OR REPLACE FUNCTION public.request_withdrawal(
    p_amount DECIMAL(15,2),
    p_bank_details TEXT
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_investor_id UUID;
    v_available DECIMAL(15,2);
    v_pending_total DECIMAL(15,2);
    v_request_id UUID;
    v_investor_name TEXT;
BEGIN
    v_investor_id := auth.uid();
    
    -- Ensure investor exists in public.investors
    SELECT available_balance, full_name INTO v_available, v_investor_name 
    FROM public.investors WHERE id = v_investor_id;

    IF v_available IS NULL THEN
        IF EXISTS (SELECT 1 FROM public.profiles WHERE id = v_investor_id) THEN
            INSERT INTO public.investors (id, full_name, email, available_balance, deployed_capital, total_profit_earned, created_at, updated_at)
            SELECT 
                p.id, COALESCE(p.full_name, 'مستثمر'), COALESCE(p.email, u.email, ''), 0.00, 0.00, 0.00, NOW(), NOW()
            FROM public.profiles p
            LEFT JOIN auth.users u ON p.id = u.id
            WHERE p.id = v_investor_id
            ON CONFLICT (id) DO NOTHING;
            v_available := 0.00;
            v_investor_name := 'مستثمر';
        ELSE
            RAISE EXCEPTION 'المستثمر غير موجود في النظام';
        END IF;
    END IF;

    -- Calculate total pending requests for this investor
    SELECT COALESCE(SUM(amount), 0) INTO v_pending_total
    FROM public.withdrawal_requests
    WHERE investor_id = v_investor_id AND status = 'pending';

    -- Validate balance covers pending + requested
    IF (v_available - v_pending_total) < p_amount THEN
        RAISE EXCEPTION 'الرصيد المتاح غير كافٍ. رصيدك المتاح: % ر.س، وطلبات السحب المعلقة: % ر.س', 
            v_available, v_pending_total;
    END IF;

    -- Create Pending Withdrawal Request
    INSERT INTO public.withdrawal_requests (investor_id, amount, bank_account_details, status)
    VALUES (v_investor_id, p_amount, p_bank_details, 'pending')
    RETURNING id INTO v_request_id;

    -- Notify Admins & Managers
    BEGIN
        INSERT INTO public.notifications (profile_id, title, content, type)
        SELECT p.id, '💰 طلب سحب جديد', 
               'قام المستثمر ' || COALESCE(v_investor_name, '') || ' بتقديم طلب سحب بمبلغ ' || p_amount || ' ر.س', 'info'
        FROM public.profiles p 
        JOIN public.roles r ON p.role_id = r.id 
        WHERE r.slug IN ('admin', 'manager', 'accountant');
    EXCEPTION WHEN OTHERS THEN
        NULL;
    END;

    RETURN jsonb_build_object('success', true, 'request_id', v_request_id);
END;
$$;

GRANT EXECUTE ON FUNCTION public.request_withdrawal(DECIMAL, TEXT) TO authenticated;

-- 15. RPC for Admin to Approve Withdrawal Request
DROP FUNCTION IF EXISTS public.approve_withdrawal_request(UUID);

CREATE OR REPLACE FUNCTION public.approve_withdrawal_request(
    p_request_id UUID
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_req RECORD;
    v_res JSONB;
BEGIN
    SELECT * INTO v_req FROM public.withdrawal_requests WHERE id = p_request_id FOR UPDATE;
    
    IF v_req IS NULL THEN
        RAISE EXCEPTION 'طلب السحب غير موجود';
    END IF;

    IF v_req.status != 'pending' THEN
        RAISE EXCEPTION 'تمت معالجة هذا الطلب مسبقاً (الحالة الحالية: %)', v_req.status;
    END IF;

    -- Execute actual financial withdrawal & accounting entries
    v_res := public.process_investor_withdrawal(
        v_req.investor_id,
        v_req.amount,
        COALESCE('اعتماد طلب سحب رقم: ' || p_request_id::text, 'سحب أرباح ونقدية'),
        p_request_id::text
    );

    -- Update request status to approved
    UPDATE public.withdrawal_requests 
    SET status = 'approved',
        processed_at = NOW(),
        processed_by = auth.uid()
    WHERE id = p_request_id;

    -- Notify Investor
    BEGIN
        INSERT INTO public.notifications (profile_id, title, content, type)
        VALUES (
            v_req.investor_id,
            '✅ تم اعتماد طلب السحب',
            'تمت الموافقة على طلب السحب بمبلغ ' || v_req.amount || ' ر.س وتحويله لحسابك البنكي.',
            'info'
        );
    EXCEPTION WHEN OTHERS THEN
        NULL;
    END;

    RETURN jsonb_build_object('success', true, 'request_id', p_request_id);
END;
$$;

GRANT EXECUTE ON FUNCTION public.approve_withdrawal_request(UUID) TO authenticated;

-- 16. RPC for Admin to Reject Withdrawal Request
DROP FUNCTION IF EXISTS public.reject_withdrawal_request(UUID, TEXT);

CREATE OR REPLACE FUNCTION public.reject_withdrawal_request(
    p_request_id UUID,
    p_reason TEXT DEFAULT NULL
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_req RECORD;
BEGIN
    SELECT * INTO v_req FROM public.withdrawal_requests WHERE id = p_request_id FOR UPDATE;

    IF v_req IS NULL THEN
        RAISE EXCEPTION 'طلب السحب غير موجود';
    END IF;

    IF v_req.status != 'pending' THEN
        RAISE EXCEPTION 'تمت معالجة هذا الطلب مسبقاً';
    END IF;

    -- Update status to rejected
    UPDATE public.withdrawal_requests 
    SET status = 'rejected',
        rejection_reason = p_reason,
        processed_at = NOW(),
        processed_by = auth.uid()
    WHERE id = p_request_id;

    -- Notify Investor
    BEGIN
        INSERT INTO public.notifications (profile_id, title, content, type)
        VALUES (
            v_req.investor_id,
            '❌ تم رفض طلب السحب',
            'تم رفض طلب السحب بمبلغ ' || v_req.amount || ' ر.س. السبب: ' || COALESCE(p_reason, 'غير محدد'),
            'alert'
        );
    EXCEPTION WHEN OTHERS THEN
        NULL;
    END;

    RETURN jsonb_build_object('success', true, 'request_id', p_request_id);
END;
$$;

GRANT EXECUTE ON FUNCTION public.reject_withdrawal_request(UUID, TEXT) TO authenticated;

-- 17. Automatically sync investor full names from profiles
UPDATE public.investors i
SET full_name = p.full_name,
    email = COALESCE(NULLIF(p.email, ''), i.email)
FROM public.profiles p
WHERE i.id = p.id
AND p.full_name IS NOT NULL
AND p.full_name != ''
AND (i.full_name IS NULL OR i.full_name = 'مستثمر' OR i.full_name = 'New Investor');





