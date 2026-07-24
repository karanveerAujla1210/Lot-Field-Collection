-- =============================================================================
-- FINCOLLECT ENTERPRISE FIELD COLLECTION PLATFORM
-- Migration: 20260723000002_storage_and_realtime.sql
-- Description: Storage Bucket Setup, RLS Storage Policies, and Realtime Publications
-- =============================================================================

-- -----------------------------------------------------------------------------
-- 1. SUPABASE STORAGE BUCKET INITIALIZATION
-- -----------------------------------------------------------------------------
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES
    ('customer-photo', 'customer-photo', false, 10485760, ARRAY['image/jpeg', 'image/png', 'image/webp']),
    ('house-photo', 'house-photo', false, 10485760, ARRAY['image/jpeg', 'image/png', 'image/webp']),
    ('receipt-photo', 'receipt-photo', false, 10485760, ARRAY['image/jpeg', 'image/png', 'image/webp']),
    ('kyc', 'kyc', false, 20971520, ARRAY['image/jpeg', 'image/png', 'application/pdf']),
    ('documents', 'documents', false, 20971520, ARRAY['image/jpeg', 'image/png', 'application/pdf', 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet']),
    ('executive-profile', 'executive-profile', true, 5242880, ARRAY['image/jpeg', 'image/png', 'image/webp'])
ON CONFLICT (id) DO NOTHING;

-- -----------------------------------------------------------------------------
-- 2. STORAGE ROW LEVEL SECURITY (RLS) POLICIES
-- -----------------------------------------------------------------------------

-- Executive Profile Photos (Public read, Authenticated write)
CREATE POLICY "Public Read Executive Profiles"
ON storage.objects FOR SELECT TO public
USING (bucket_id = 'executive-profile');

CREATE POLICY "Authenticated Upload Executive Profiles"
ON storage.objects FOR INSERT TO authenticated
WITH CHECK (bucket_id = 'executive-profile');

-- Customer, House, Receipt Photos & KYC/Documents (Authenticated access only)
CREATE POLICY "Authenticated Read Photos and KYC"
ON storage.objects FOR SELECT TO authenticated
USING (bucket_id IN ('customer-photo', 'house-photo', 'receipt-photo', 'kyc', 'documents'));

CREATE POLICY "Authenticated Upload Photos and KYC"
ON storage.objects FOR INSERT TO authenticated
WITH CHECK (bucket_id IN ('customer-photo', 'house-photo', 'receipt-photo', 'kyc', 'documents'));

CREATE POLICY "Authenticated Update Photos and KYC"
ON storage.objects FOR UPDATE TO authenticated
USING (bucket_id IN ('customer-photo', 'house-photo', 'receipt-photo', 'kyc', 'documents'));

-- -----------------------------------------------------------------------------
-- 3. SUPABASE REALTIME CONFIGURATION
-- -----------------------------------------------------------------------------

-- Enable Postgres Changes on core operational tables for instant bi-directional CRM <-> Mobile synchronization
BEGIN;
  -- Drop existing publication if present or add tables to supabase_realtime publication
  DO $$
  BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_publication WHERE pubname = 'supabase_realtime') THEN
      CREATE PUBLICATION supabase_realtime;
    END IF;
  END
  $$;

  ALTER PUBLICATION supabase_realtime ADD TABLE public.allocations;
  ALTER PUBLICATION supabase_realtime ADD TABLE public.visits;
  ALTER PUBLICATION supabase_realtime ADD TABLE public.payments;
  ALTER PUBLICATION supabase_realtime ADD TABLE public.followups;
  ALTER PUBLICATION supabase_realtime ADD TABLE public.notifications;
  ALTER PUBLICATION supabase_realtime ADD TABLE public.attendance;
  ALTER PUBLICATION supabase_realtime ADD TABLE public.gps_logs;
  ALTER PUBLICATION supabase_realtime ADD TABLE public.loans;
COMMIT;
