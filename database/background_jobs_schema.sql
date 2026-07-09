-- ############################################################################
-- PHASE 23: BACKGROUND JOBS & QUEUE MANAGEMENT
-- ############################################################################

DO $$ 
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'job_status') THEN
        CREATE TYPE public.job_status AS ENUM ('pending', 'running', 'completed', 'failed', 'retrying');
    END IF;
END $$;

CREATE TABLE IF NOT EXISTS public.background_jobs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    job_type TEXT NOT NULL, -- e.g., 'EMAIL_NOTIFICATION', 'MONTHLY_REPORT_GEN'
    payload JSONB,
    status public.job_status DEFAULT 'pending',
    attempts INTEGER DEFAULT 0,
    max_attempts INTEGER DEFAULT 3,
    error_message TEXT,
    scheduled_at TIMESTAMPTZ DEFAULT NOW(),
    started_at TIMESTAMPTZ,
    completed_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexing for performance
CREATE INDEX IF NOT EXISTS idx_jobs_status ON public.background_jobs(status);
CREATE INDEX IF NOT EXISTS idx_jobs_scheduled_at ON public.background_jobs(scheduled_at);

-- Function to enqueue a job
CREATE OR REPLACE FUNCTION public.enqueue_job(
    p_job_type TEXT,
    p_payload JSONB,
    p_scheduled_at TIMESTAMPTZ DEFAULT NOW()
) RETURNS UUID AS $$
DECLARE
    v_job_id UUID;
BEGIN
    INSERT INTO public.background_jobs (job_type, payload, scheduled_at)
    VALUES (p_job_type, p_payload, p_scheduled_at)
    RETURNING id INTO v_job_id;
    
    RETURN v_job_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
