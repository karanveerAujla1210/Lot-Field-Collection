-- =============================================================================
-- LOT FIELD COLLECTION CASE-CENTRIC FRONTEND INTEGRATION
-- Adds activity tables compatible with the existing public.cases dataset
-- =============================================================================

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

ALTER TABLE public.cases
  ADD COLUMN IF NOT EXISTS total_collected_amount NUMERIC(14, 2) NOT NULL DEFAULT 0,
  ADD COLUMN IF NOT EXISTS last_payment_amount NUMERIC(14, 2),
  ADD COLUMN IF NOT EXISTS last_payment_at TIMESTAMP WITH TIME ZONE,
  ADD COLUMN IF NOT EXISTS payment_count INT NOT NULL DEFAULT 0,
  ADD COLUMN IF NOT EXISTS last_visit_at TIMESTAMP WITH TIME ZONE,
  ADD COLUMN IF NOT EXISTS last_visit_status VARCHAR(50),
  ADD COLUMN IF NOT EXISTS visit_count INT NOT NULL DEFAULT 0,
  ADD COLUMN IF NOT EXISTS assigned_executive_id UUID,
  ADD COLUMN IF NOT EXISTS assigned_executive_name VARCHAR(120),
  ADD COLUMN IF NOT EXISTS updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP;

CREATE TABLE IF NOT EXISTS public.case_visits (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    case_id UUID NOT NULL REFERENCES public.cases(id) ON DELETE CASCADE,
    loan_no VARCHAR(50) NOT NULL,
    customer_name VARCHAR(150) NOT NULL,
    executive_id UUID,
    executive_name VARCHAR(120),
    branch_name VARCHAR(100),
    latitude NUMERIC(10, 8) NOT NULL,
    longitude NUMERIC(11, 8) NOT NULL,
    visit_status VARCHAR(50) NOT NULL,
    remarks TEXT NOT NULL,
    promise_date DATE,
    expected_amount NUMERIC(14, 2),
    photos_urls JSONB NOT NULL DEFAULT '[]'::jsonb,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS public.case_payments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    case_id UUID NOT NULL REFERENCES public.cases(id) ON DELETE CASCADE,
    loan_no VARCHAR(50) NOT NULL,
    customer_name VARCHAR(150) NOT NULL,
    executive_id UUID,
    executive_name VARCHAR(120),
    branch_name VARCHAR(100),
    amount_paid NUMERIC(14, 2) NOT NULL CHECK (amount_paid > 0),
    payment_mode VARCHAR(30) NOT NULL,
    payment_reference VARCHAR(120),
    receipt_number VARCHAR(60) NOT NULL UNIQUE,
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_case_visits_case_id_created_at
  ON public.case_visits (case_id, created_at DESC);

CREATE INDEX IF NOT EXISTS idx_case_payments_case_id_created_at
  ON public.case_payments (case_id, created_at DESC);

CREATE OR REPLACE FUNCTION public.touch_case_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = CURRENT_TIMESTAMP;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trigger_cases_touch_updated_at ON public.cases;
CREATE TRIGGER trigger_cases_touch_updated_at
BEFORE UPDATE ON public.cases
FOR EACH ROW
EXECUTE FUNCTION public.touch_case_updated_at();

CREATE OR REPLACE FUNCTION public.sync_case_visit_summary()
RETURNS TRIGGER AS $$
BEGIN
  UPDATE public.cases
  SET
    last_visit_at = NEW.created_at,
    last_visit_status = NEW.visit_status,
    visit_count = COALESCE(visit_count, 0) + 1,
    assigned_executive_id = COALESCE(NEW.executive_id, assigned_executive_id),
    assigned_executive_name = COALESCE(NEW.executive_name, assigned_executive_name),
    loan_status = CASE
      WHEN COALESCE(loan_status, '') IN ('OPEN', 'PART-PAYMENT') THEN 'IN_VISIT'
      ELSE loan_status
    END
  WHERE id = NEW.case_id;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trigger_case_visits_sync_case_summary ON public.case_visits;
CREATE TRIGGER trigger_case_visits_sync_case_summary
AFTER INSERT ON public.case_visits
FOR EACH ROW
EXECUTE FUNCTION public.sync_case_visit_summary();

CREATE OR REPLACE FUNCTION public.sync_case_payment_summary()
RETURNS TRIGGER AS $$
DECLARE
  current_total NUMERIC(14, 2);
  target_total NUMERIC(14, 2);
BEGIN
  SELECT COALESCE(total_collected_amount, 0), COALESCE(loan_repay_amount, 0)
  INTO current_total, target_total
  FROM public.cases
  WHERE id = NEW.case_id;

  UPDATE public.cases
  SET
    total_collected_amount = current_total + NEW.amount_paid,
    last_payment_amount = NEW.amount_paid,
    last_payment_at = NEW.created_at,
    payment_count = COALESCE(payment_count, 0) + 1,
    assigned_executive_id = COALESCE(NEW.executive_id, assigned_executive_id),
    assigned_executive_name = COALESCE(NEW.executive_name, assigned_executive_name),
    loan_status = CASE
      WHEN target_total > 0 AND current_total + NEW.amount_paid >= target_total THEN 'CLOSED'
      ELSE 'PART-PAYMENT'
    END
  WHERE id = NEW.case_id;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trigger_case_payments_sync_case_summary ON public.case_payments;
CREATE TRIGGER trigger_case_payments_sync_case_summary
AFTER INSERT ON public.case_payments
FOR EACH ROW
EXECUTE FUNCTION public.sync_case_payment_summary();

ALTER TABLE public.case_visits DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.case_payments DISABLE ROW LEVEL SECURITY;

DO $$
BEGIN
  BEGIN
    ALTER PUBLICATION supabase_realtime ADD TABLE public.case_visits;
  EXCEPTION
    WHEN duplicate_object THEN NULL;
    WHEN undefined_object THEN NULL;
  END;

  BEGIN
    ALTER PUBLICATION supabase_realtime ADD TABLE public.case_payments;
  EXCEPTION
    WHEN duplicate_object THEN NULL;
    WHEN undefined_object THEN NULL;
  END;

  BEGIN
    ALTER PUBLICATION supabase_realtime ADD TABLE public.cases;
  EXCEPTION
    WHEN duplicate_object THEN NULL;
    WHEN undefined_object THEN NULL;
  END;
END $$;
