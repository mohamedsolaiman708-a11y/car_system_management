-- ############################################################################
-- PHASE 24: BACKUP & RESTORE MANAGEMENT
-- ############################################################################

CREATE TABLE IF NOT EXISTS public.backup_history (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    filename TEXT NOT NULL,
    size_bytes BIGINT,
    status TEXT DEFAULT 'completed', -- 'completed', 'failed', 'in_progress'
    backup_type TEXT DEFAULT 'automatic', -- 'manual', 'automatic'
    download_url TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    created_by UUID REFERENCES public.profiles(id)
);

-- Function to log a manual backup request
CREATE OR REPLACE FUNCTION public.request_manual_backup()
RETURNS UUID AS $$
DECLARE
    v_backup_id UUID;
BEGIN
    INSERT INTO public.backup_history (filename, backup_type, status, created_by)
    VALUES ('manual_backup_' || to_char(NOW(), 'YYYYMMDD_HH24MISS') || '.sql', 'manual', 'in_progress', auth.uid())
    RETURNING id INTO v_backup_id;

    -- Note: In a real environment, this would trigger an Edge Function 
    -- or a background worker to perform pg_dump.
    
    RETURN v_backup_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
