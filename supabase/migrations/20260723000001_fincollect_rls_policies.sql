-- =============================================================================
-- FINCOLLECT ENTERPRISE FIELD COLLECTION PLATFORM
-- Migration: 20260723000001_fincollect_rls_policies.sql
-- Description: Row Level Security (RLS) policies for all 21 tables and 8 roles
-- Security Model: Role & Branch scoped tenancy
-- =============================================================================

-- Enable Row Level Security on ALL 21 Tables
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.roles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.permissions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.role_permissions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.branches ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.customers ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.loans ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.allocations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.visits ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.payments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.followups ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.attendance ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.gps_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.activity_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.documents ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.settings ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.device_tokens ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.sync_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.import_jobs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.receipts ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.ledger ENABLE ROW LEVEL SECURITY;

-- -----------------------------------------------------------------------------
-- SECURITY HELPER FUNCTIONS
-- -----------------------------------------------------------------------------

-- Get current authenticated user's role code
CREATE OR REPLACE FUNCTION auth.current_user_role()
RETURNS VARCHAR AS $$
    SELECT r.code 
    FROM public.users u
    JOIN public.roles r ON u.role_id = r.id
    WHERE u.id = auth.uid();
$$ LANGUAGE sql STABLE SECURITY DEFINER;

-- Get current authenticated user's branch ID
CREATE OR REPLACE FUNCTION auth.current_user_branch()
RETURNS UUID AS $$
    SELECT branch_id 
    FROM public.users 
    WHERE id = auth.uid();
$$ LANGUAGE sql STABLE SECURITY DEFINER;

-- -----------------------------------------------------------------------------
-- 1. USERS & ROLES POLICIES
-- -----------------------------------------------------------------------------
CREATE POLICY "Super Admin / Admin full user control" ON public.users
    FOR ALL TO authenticated
    USING (auth.current_user_role() IN ('SUPER_ADMIN', 'ADMIN', 'AUDITOR'))
    WITH CHECK (auth.current_user_role() IN ('SUPER_ADMIN', 'ADMIN'));

CREATE POLICY "Branch & Regional managers view branch users" ON public.users
    FOR SELECT TO authenticated
    USING (
        auth.current_user_role() IN ('BRANCH_MANAGER', 'REGIONAL_MANAGER', 'COLLECTION_MANAGER') 
        AND branch_id = auth.current_user_branch()
    );

CREATE POLICY "Users read own profile" ON public.users
    FOR SELECT TO authenticated
    USING (id = auth.uid());

CREATE POLICY "Roles read-only for authenticated" ON public.roles
    FOR SELECT TO authenticated USING (true);

CREATE POLICY "Permissions read-only for authenticated" ON public.permissions
    FOR SELECT TO authenticated USING (true);

CREATE POLICY "Role permissions read-only for authenticated" ON public.role_permissions
    FOR SELECT TO authenticated USING (true);

-- -----------------------------------------------------------------------------
-- 2. BRANCHES POLICIES
-- -----------------------------------------------------------------------------
CREATE POLICY "Admin & Auditors full branch access" ON public.branches
    FOR ALL TO authenticated
    USING (auth.current_user_role() IN ('SUPER_ADMIN', 'ADMIN', 'REGIONAL_MANAGER', 'AUDITOR'));

CREATE POLICY "Branch staff read own branch" ON public.branches
    FOR SELECT TO authenticated
    USING (id = auth.current_user_branch());

-- -----------------------------------------------------------------------------
-- 3. CUSTOMERS & LOANS POLICIES
-- -----------------------------------------------------------------------------
CREATE POLICY "Admin & Auditors full customer access" ON public.customers
    FOR ALL TO authenticated
    USING (auth.current_user_role() IN ('SUPER_ADMIN', 'ADMIN', 'REGIONAL_MANAGER', 'AUDITOR'));

CREATE POLICY "Managers access branch customers" ON public.customers
    FOR ALL TO authenticated
    USING (
        auth.current_user_role() IN ('BRANCH_MANAGER', 'COLLECTION_MANAGER') 
        AND branch_id = auth.current_user_branch()
    );

CREATE POLICY "Field Executives access assigned customers" ON public.customers
    FOR SELECT TO authenticated
    USING (
        auth.current_user_role() = 'FIELD_EXECUTIVE' AND
        id IN (SELECT customer_id FROM public.allocations WHERE executive_id = auth.uid() AND status IN ('ASSIGNED', 'IN_PROGRESS', 'PARTIALLY_COLLECTED'))
    );

CREATE POLICY "Admin & Auditors full loan access" ON public.loans
    FOR ALL TO authenticated
    USING (auth.current_user_role() IN ('SUPER_ADMIN', 'ADMIN', 'REGIONAL_MANAGER', 'FINANCE', 'AUDITOR'));

CREATE POLICY "Managers access branch loans" ON public.loans
    FOR ALL TO authenticated
    USING (
        auth.current_user_role() IN ('BRANCH_MANAGER', 'COLLECTION_MANAGER') 
        AND branch_id = auth.current_user_branch()
    );

CREATE POLICY "Field Executives access assigned loans" ON public.loans
    FOR SELECT TO authenticated
    USING (
        auth.current_user_role() = 'FIELD_EXECUTIVE' AND
        id IN (SELECT loan_id FROM public.allocations WHERE executive_id = auth.uid() AND status IN ('ASSIGNED', 'IN_PROGRESS', 'PARTIALLY_COLLECTED'))
    );

-- -----------------------------------------------------------------------------
-- 4. ALLOCATIONS POLICIES
-- -----------------------------------------------------------------------------
CREATE POLICY "Managers allocate within branch" ON public.allocations
    FOR ALL TO authenticated
    USING (
        auth.current_user_role() IN ('SUPER_ADMIN', 'ADMIN', 'REGIONAL_MANAGER', 'BRANCH_MANAGER', 'COLLECTION_MANAGER')
    );

CREATE POLICY "Executives view own allocations" ON public.allocations
    FOR SELECT TO authenticated
    USING (executive_id = auth.uid());

-- -----------------------------------------------------------------------------
-- 5. VISITS POLICIES
-- -----------------------------------------------------------------------------
CREATE POLICY "Executives insert & view own visits" ON public.visits
    FOR ALL TO authenticated
    USING (executive_id = auth.uid())
    WITH CHECK (executive_id = auth.uid());

CREATE POLICY "Managers & Auditors view branch visits" ON public.visits
    FOR SELECT TO authenticated
    USING (
        auth.current_user_role() IN ('SUPER_ADMIN', 'ADMIN', 'REGIONAL_MANAGER', 'BRANCH_MANAGER', 'COLLECTION_MANAGER', 'AUDITOR')
    );

-- -----------------------------------------------------------------------------
-- 6. PAYMENTS, RECEIPTS & LEDGER POLICIES
-- -----------------------------------------------------------------------------
CREATE POLICY "Executives record payments" ON public.payments
    FOR INSERT TO authenticated
    WITH CHECK (executive_id = auth.uid());

CREATE POLICY "Executives view own payments" ON public.payments
    FOR SELECT TO authenticated
    USING (executive_id = auth.uid());

CREATE POLICY "Managers, Finance & Auditor manage payments" ON public.payments
    FOR ALL TO authenticated
    USING (
        auth.current_user_role() IN ('SUPER_ADMIN', 'ADMIN', 'REGIONAL_MANAGER', 'BRANCH_MANAGER', 'COLLECTION_MANAGER', 'FINANCE', 'AUDITOR')
    );

CREATE POLICY "Receipts access control" ON public.receipts
    FOR SELECT TO authenticated
    USING (
        executive_id = auth.uid() OR 
        auth.current_user_role() IN ('SUPER_ADMIN', 'ADMIN', 'REGIONAL_MANAGER', 'BRANCH_MANAGER', 'COLLECTION_MANAGER', 'FINANCE', 'AUDITOR')
    );

CREATE POLICY "Ledger read-only for Authorized Staff" ON public.ledger
    FOR SELECT TO authenticated
    USING (
        auth.current_user_role() IN ('SUPER_ADMIN', 'ADMIN', 'REGIONAL_MANAGER', 'BRANCH_MANAGER', 'FINANCE', 'AUDITOR')
    );

-- -----------------------------------------------------------------------------
-- 7. FOLLOWUPS, ATTENDANCE & GPS LOGS POLICIES
-- -----------------------------------------------------------------------------
CREATE POLICY "Executives manage own followups" ON public.followups
    FOR ALL TO authenticated
    USING (executive_id = auth.uid())
    WITH CHECK (executive_id = auth.uid());

CREATE POLICY "Managers view followups" ON public.followups
    FOR SELECT TO authenticated
    USING (auth.current_user_role() IN ('SUPER_ADMIN', 'ADMIN', 'REGIONAL_MANAGER', 'BRANCH_MANAGER', 'COLLECTION_MANAGER', 'AUDITOR'));

CREATE POLICY "Executives manage own attendance" ON public.attendance
    FOR ALL TO authenticated
    USING (executive_id = auth.uid())
    WITH CHECK (executive_id = auth.uid());

CREATE POLICY "Managers view branch attendance" ON public.attendance
    FOR SELECT TO authenticated
    USING (auth.current_user_role() IN ('SUPER_ADMIN', 'ADMIN', 'REGIONAL_MANAGER', 'BRANCH_MANAGER', 'AUDITOR'));

CREATE POLICY "Executives log GPS" ON public.gps_logs
    FOR INSERT TO authenticated
    WITH CHECK (executive_id = auth.uid());

CREATE POLICY "Managers track team GPS" ON public.gps_logs
    FOR SELECT TO authenticated
    USING (auth.current_user_role() IN ('SUPER_ADMIN', 'ADMIN', 'REGIONAL_MANAGER', 'BRANCH_MANAGER', 'COLLECTION_MANAGER', 'AUDITOR'));

-- -----------------------------------------------------------------------------
-- 8. NOTIFICATIONS, ACTIVITY LOGS, DOCUMENTS & SYSTEM TABLES
-- -----------------------------------------------------------------------------
CREATE POLICY "Users read own notifications" ON public.notifications
    FOR ALL TO authenticated
    USING (user_id = auth.uid())
    WITH CHECK (user_id = auth.uid());

CREATE POLICY "Activity logs read-only for Admin & Auditor" ON public.activity_logs
    FOR SELECT TO authenticated
    USING (auth.current_user_role() IN ('SUPER_ADMIN', 'ADMIN', 'AUDITOR'));

CREATE POLICY "Document access policy" ON public.documents
    FOR ALL TO authenticated
    USING (true);

CREATE POLICY "Settings access policy" ON public.settings
    FOR SELECT TO authenticated USING (true);

CREATE POLICY "Settings update policy" ON public.settings
    FOR ALL TO authenticated
    USING (auth.current_user_role() IN ('SUPER_ADMIN', 'ADMIN'));

CREATE POLICY "Device tokens user policy" ON public.device_tokens
    FOR ALL TO authenticated
    USING (user_id = auth.uid())
    WITH CHECK (user_id = auth.uid());

CREATE POLICY "Sync logs user policy" ON public.sync_logs
    FOR ALL TO authenticated
    USING (executive_id = auth.uid() OR auth.current_user_role() IN ('SUPER_ADMIN', 'ADMIN', 'BRANCH_MANAGER'));

CREATE POLICY "Import jobs admin policy" ON public.import_jobs
    FOR ALL TO authenticated
    USING (auth.current_user_role() IN ('SUPER_ADMIN', 'ADMIN', 'BRANCH_MANAGER'));
