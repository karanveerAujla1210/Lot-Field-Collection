-- Generate receipt identifiers in PostgreSQL so concurrent clients cannot reuse
-- a browser-generated value. The UNIQUE constraint on receipt_number remains the
-- final integrity guarantee.

CREATE OR REPLACE FUNCTION public.generate_case_receipt_number()
RETURNS TEXT
LANGUAGE sql
VOLATILE
AS $$
  SELECT 'RCP-' || to_char(CURRENT_DATE, 'YYYYMMDD') || '-' ||
         upper(substring(replace(gen_random_uuid()::text, '-', '') from 1 for 12));
$$;

ALTER TABLE public.case_payments
  ALTER COLUMN receipt_number SET DEFAULT public.generate_case_receipt_number();
