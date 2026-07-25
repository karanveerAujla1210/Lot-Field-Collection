-- Follow-ups for the case-centric workflow. This is separate from the
-- normalized followups table, whose foreign keys require loan/customer records.

CREATE TABLE IF NOT EXISTS public.follow_ups (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    case_id UUID NOT NULL REFERENCES public.cases(id) ON DELETE CASCADE,
    loan_no VARCHAR(50) NOT NULL,
    customer_name VARCHAR(150) NOT NULL,
    executive_id UUID NOT NULL REFERENCES public.users(id),
    follow_up_date TIMESTAMP WITH TIME ZONE NOT NULL,
    notes TEXT,
    status VARCHAR(20) NOT NULL DEFAULT 'PENDING'
      CHECK (status IN ('PENDING', 'COMPLETED', 'RESCHEDULED', 'CANCELLED')),
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_follow_ups_executive_date
  ON public.follow_ups (executive_id, follow_up_date);

ALTER TABLE public.follow_ups ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Executives manage their case follow-ups" ON public.follow_ups
  FOR ALL TO authenticated
  USING (executive_id = auth.uid())
  WITH CHECK (executive_id = auth.uid());

CREATE POLICY "Managers view case follow-ups" ON public.follow_ups
  FOR SELECT TO authenticated
  USING (auth.current_user_role() IN ('SUPER_ADMIN', 'ADMIN', 'REGIONAL_MANAGER', 'BRANCH_MANAGER', 'COLLECTION_MANAGER', 'AUDITOR'));
