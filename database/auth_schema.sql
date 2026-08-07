-- Authentication and User Management Schema
-- Module: Authentication
-- Description: Sets up the profiles table, RBAC, and automated profile creation.

-- 1. Create custom types for RBAC (Role-Based Access Control)
DO $$ 
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'user_role') THEN
        CREATE TYPE public.user_role AS ENUM ('admin', 'sales', 'accountant', 'investor');
    ELSE
        BEGIN
            ALTER TYPE public.user_role ADD VALUE 'sales';
            ALTER TYPE public.user_role ADD VALUE 'accountant';
        EXCEPTION WHEN duplicate_object THEN NULL;
        END;
    END IF;
END $$;

-- 2. Ensure Roles table exists and is accessible
CREATE TABLE IF NOT EXISTS public.roles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    slug TEXT UNIQUE NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable RLS on roles
ALTER TABLE public.roles ENABLE ROW LEVEL SECURITY;

-- Allow all authenticated users to view roles (Important for the dropdown to work)
DO $$ 
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'Allow authenticated users to view roles') THEN
        CREATE POLICY "Allow authenticated users to view roles" 
        ON public.roles FOR SELECT 
        TO authenticated 
        USING (true);
    END IF;
END $$;

-- 3. Create the Profiles table
CREATE TABLE IF NOT EXISTS public.profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    full_name TEXT NOT NULL,
    role_id UUID REFERENCES public.roles(id),
    is_active BOOLEAN NOT NULL DEFAULT true,
    status TEXT DEFAULT 'pending',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 4. Automated Profile Creation Trigger
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
DECLARE
    v_role_id UUID;
BEGIN
  SELECT id INTO v_role_id FROM public.roles WHERE slug = 'investor' LIMIT 1;

  INSERT INTO public.profiles (id, full_name, role_id, status)
  VALUES (
    NEW.id, 
    COALESCE(NEW.raw_user_meta_data->>'full_name', 'مستخدم جديد'),
    v_role_id,
    'pending'
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
