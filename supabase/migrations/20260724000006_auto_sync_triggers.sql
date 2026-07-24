-- =============================================================================
-- FINCOLLECT ENTERPRISE PLATFORM - AUTOMATIC 1-MINUTE SYNC TRIGGERS
-- Target Tables: cases, users, customers, loans, allocations, payments, visits
-- =============================================================================

-- 1. Helper function to update updated_at timestamp on every modification
CREATE OR REPLACE FUNCTION public.update_sync_timestamp()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 2. System Auto-Sync Realtime Notification Trigger Function
CREATE OR REPLACE FUNCTION public.notify_realtime_sync()
RETURNS TRIGGER AS $$
DECLARE
    payload JSON;
BEGIN
    payload = json_build_object(
        'table', TG_TABLE_NAME,
        'action', TG_OP,
        'id', COALESCE(NEW.id, OLD.id),
        'synced_at', CURRENT_TIMESTAMP
    );
    PERFORM pg_notify('fincollect_system_sync', payload::text);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 3. Create Triggers for Cases Table
DROP TRIGGER IF EXISTS trigger_cases_updated_at ON public.cases;
CREATE TRIGGER trigger_cases_updated_at
    BEFORE UPDATE ON public.cases
    FOR EACH ROW EXECUTE FUNCTION public.update_sync_timestamp();

DROP TRIGGER IF EXISTS trigger_cases_realtime_sync ON public.cases;
CREATE TRIGGER trigger_cases_realtime_sync
    AFTER INSERT OR UPDATE OR DELETE ON public.cases
    FOR EACH ROW EXECUTE FUNCTION public.notify_realtime_sync();

-- 4. Create Triggers for Users (Staff) Table
DROP TRIGGER IF EXISTS trigger_users_updated_at ON public.users;
CREATE TRIGGER trigger_users_updated_at
    BEFORE UPDATE ON public.users
    FOR EACH ROW EXECUTE FUNCTION public.update_sync_timestamp();

DROP TRIGGER IF EXISTS trigger_users_realtime_sync ON public.users;
CREATE TRIGGER trigger_users_realtime_sync
    AFTER INSERT OR UPDATE OR DELETE ON public.users
    FOR EACH ROW EXECUTE FUNCTION public.notify_realtime_sync();

-- 5. Create Triggers for Customers Table
DROP TRIGGER IF EXISTS trigger_customers_updated_at ON public.customers;
CREATE TRIGGER trigger_customers_updated_at
    BEFORE UPDATE ON public.customers
    FOR EACH ROW EXECUTE FUNCTION public.update_sync_timestamp();

-- 6. Create Triggers for Loans Table
DROP TRIGGER IF EXISTS trigger_loans_updated_at ON public.loans;
CREATE TRIGGER trigger_loans_updated_at
    BEFORE UPDATE ON public.loans
    FOR EACH ROW EXECUTE FUNCTION public.update_sync_timestamp();

-- 7. Create Triggers for Allocations Table
DROP TRIGGER IF EXISTS trigger_allocations_updated_at ON public.allocations;
CREATE TRIGGER trigger_allocations_updated_at
    BEFORE UPDATE ON public.allocations
    FOR EACH ROW EXECUTE FUNCTION public.update_sync_timestamp();

-- 8. Create Triggers for Payments Table
DROP TRIGGER IF EXISTS trigger_payments_realtime_sync ON public.payments;
CREATE TRIGGER trigger_payments_realtime_sync
    AFTER INSERT OR UPDATE ON public.payments
    FOR EACH ROW EXECUTE FUNCTION public.notify_realtime_sync();

-- 9. Create Triggers for Visits Table
DROP TRIGGER IF EXISTS trigger_visits_realtime_sync ON public.visits;
CREATE TRIGGER trigger_visits_realtime_sync
    AFTER INSERT OR UPDATE ON public.visits
    FOR EACH ROW EXECUTE FUNCTION public.notify_realtime_sync();
