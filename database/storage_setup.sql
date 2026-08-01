-- ############################################################################
-- SUPABASE STORAGE SETUP & POLICIES FOR DOCUMENTS
-- ############################################################################

-- 1. Create the bucket 'documents' if it doesn't exist
INSERT INTO storage.buckets (id, name, public)
VALUES ('documents', 'documents', true)
ON CONFLICT (id) DO NOTHING;

-- 2. Enable RLS on storage.objects (Commented out because it is enabled by default on Supabase and causes ownership errors if run from SQL editor)
-- ALTER TABLE storage.objects ENABLE ROW LEVEL SECURITY;

-- 3. Clean up existing policies for 'documents' to prevent conflicts
DROP POLICY IF EXISTS "Allow Public Read Access on documents" ON storage.objects;
DROP POLICY IF EXISTS "Allow Authenticated Upload on documents" ON storage.objects;
DROP POLICY IF EXISTS "Allow Authenticated Update on documents" ON storage.objects;
DROP POLICY IF EXISTS "Allow Authenticated Delete on documents" ON storage.objects;

-- 4. Create RLS policies for storage objects in the 'documents' bucket

-- 4.1 Select (Read) - Allow any user (public) to view/read objects
CREATE POLICY "Allow Public Read Access on documents" ON storage.objects
FOR SELECT
USING (bucket_id = 'documents');

-- 4.2 Insert (Upload) - Allow authenticated users to upload new files
CREATE POLICY "Allow Authenticated Upload on documents" ON storage.objects
FOR INSERT
TO authenticated
WITH CHECK (bucket_id = 'documents');

-- 4.3 Update (Replace) - Allow authenticated users to update/overwrite files
CREATE POLICY "Allow Authenticated Update on documents" ON storage.objects
FOR UPDATE
TO authenticated
USING (bucket_id = 'documents');

-- 4.4 Delete (Remove) - Allow authenticated users to delete files
CREATE POLICY "Allow Authenticated Delete on documents" ON storage.objects
FOR DELETE
TO authenticated
USING (bucket_id = 'documents');
