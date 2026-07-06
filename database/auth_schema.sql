-- Authentication and User Management Schema
-- Module: Authentication
-- Description: Sets up the profiles table, RBAC, and automated profile creation.

-- 1. Create custom types for RBAC (Role-Based Access Control)
DO $$ 
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'user_role') THEN
        CREATE TYPE public.user_role AS ENUM ('admin', 'manager', 'accountant', 'investor');
    END IF;
END $$;

-- 2. Create the Profiles table (Public Schema)
CREATE TABLE IF NOT EXISTS public.profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    full_name TEXT NOT NULL,
    role public.user_role NOT NULL DEFAULT 'investor',
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 3. Create the Security Logs table
CREATE TABLE IF NOT EXISTS public.security_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    event_type TEXT NOT NULL, -- e.g., 'LOGIN_SUCCESS', 'LOGIN_FAILURE', 'LOGOUT'
    ip_address TEXT,
    user_agent TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 4. Enable Row Level Security (RLS)
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.security_logs ENABLE ROW LEVEL SECURITY;

-- 5. RLS Policies for Profiles

-- Users can view their own profile
DO $$ 
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'Users can view own profile') THEN
        CREATE POLICY "Users can view own profile" 
        ON public.profiles FOR SELECT 
        USING (auth.uid() = id);
    END IF;
END $$;

-- Admins and Managers can view all profiles
DO $$ 
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'Admins/Managers can view all profiles') THEN
        CREATE POLICY "Admins/Managers can view all profiles" 
        ON public.profiles FOR SELECT 
        USING (
          EXISTS (
            SELECT 1 FROM public.profiles 
            WHERE id = auth.uid() AND role IN ('admin', 'manager')
          )
        );
    END IF;
END $$;

-- Only Admins can update roles or activity status
DO $$ 
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'Admins can update profiles') THEN
        CREATE POLICY "Admins can update profiles" 
        ON public.profiles FOR UPDATE 
        USING (
          EXISTS (
            SELECT 1 FROM public.profiles 
            WHERE id = auth.uid() AND role = 'admin'
          )
        );
    END IF;
END $$;

-- 6. RLS Policies for Security Logs

-- Only Admins can view logs
DO $$ 
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'Admins can view security logs') THEN
        CREATE POLICY "Admins can view security logs" 
        ON public.security_logs FOR SELECT 
        USING (
          EXISTS (
            SELECT 1 FROM public.profiles 
            WHERE id = auth.uid() AND role = 'admin'
          )
        );
    END IF;
END $$;

-- 7. Automated Profile Creation Trigger
-- This function runs every time a new user is created in Supabase Auth
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, full_name, role)
  VALUES (
    NEW.id, 
    COALESCE(NEW.raw_user_meta_data->>'full_name', 'New User'),
    COALESCE((NEW.raw_user_meta_data->>'role')::public.user_role, 'investor')
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger for new user creation
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();
