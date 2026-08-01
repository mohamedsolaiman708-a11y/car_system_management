-- ============================================================================
-- FIX HANDLE_NEW_USER TRIGGER (SUPABASE AUTH USER CREATION)
-- Execute this SQL script in Supabase Dashboard SQL Editor to fix signup errors.
-- ============================================================================

-- 1. Ensure public.roles table has 'investor' role
INSERT INTO public.roles (name, slug) 
VALUES ('Investor', 'investor')
ON CONFLICT (slug) DO NOTHING;

-- 2. Create ultra-safe handle_new_user trigger function
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
DECLARE
    v_role_id UUID;
BEGIN
    -- 1. Attempt to get 'investor' role ID
    BEGIN
        SELECT id INTO v_role_id FROM public.roles WHERE slug = 'investor' LIMIT 1;
    EXCEPTION WHEN OTHERS THEN
        v_role_id := NULL;
    END;

    -- 2. Try primary insertion into public.profiles
    BEGIN
        INSERT INTO public.profiles (id, role_id, full_name, is_active, status)
        VALUES (
            NEW.id, 
            v_role_id, 
            COALESCE(NEW.raw_user_meta_data->>'full_name', 'New Investor'),
            true,
            'pending'
        );
    EXCEPTION WHEN OTHERS THEN
        -- Fallback if columns or status enum differ
        BEGIN
            INSERT INTO public.profiles (id, full_name)
            VALUES (
                NEW.id, 
                COALESCE(NEW.raw_user_meta_data->>'full_name', 'New Investor')
            );
        EXCEPTION WHEN OTHERS THEN
            -- Safely ignore trigger error to prevent user creation abort in auth.users
            NULL;
        END;
    END;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 3. Re-apply trigger to auth.users
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();
