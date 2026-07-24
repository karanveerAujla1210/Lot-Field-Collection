-- =============================================================================
-- FINCOLLECT ENTERPRISE FIELD COLLECTION PLATFORM
-- Migration: 20260723000000_fincollect_schema.sql
-- Description: Complete normalized PostgreSQL schema, indexes, functions & triggers
-- Target Scale: 100,000 Customers, 5,000 Field Executives, Millions of Transactions
-- =============================================================================

-- Enable required extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- -----------------------------------------------------------------------------
-- 1. ROLES TABLE
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.roles (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(50) NOT NULL UNIQUE,
    code VARCHAR(50) NOT NULL UNIQUE,
    description TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Seed default enterprise roles
INSERT INTO public.roles (id, name, code, description) VALUES
    ('10000000-0000-0000-0000-000000000001', 'Super Admin', 'SUPER_ADMIN', 'System wide full access and tenant control'),
    ('10000000-0000-0000-0000-000000000002', 'Admin', 'ADMIN', 'Administrative access for portfolio management & system settings'),
    ('10000000-0000-0000-0000-000000000003', 'Regional Manager', 'REGIONAL_MANAGER', 'Oversees multiple branches in a geographical region'),
    ('10000000-0000-0000-0000-000000000004', 'Branch Manager', 'BRANCH_MANAGER', 'Manages branch portfolio, allocations, and team targets'),
    ('10000000-0000-0000-0000-000000000005', 'Collection Manager', 'COLLECTION_MANAGER', 'Supervises field collection strategies and recovery targets'),
    ('10000000-0000-0000-0000-000000000006', 'Field Executive', 'FIELD_EXECUTIVE', 'Field execution agent conducting visits and collecting payments'),
    ('10000000-0000-0000-0000-000000000007', 'Finance', 'FINANCE', 'Financial verification, ledger reconciliation, and payment audits'),
    ('10000000-0000-0000-0000-000000000008', 'Auditor', 'AUDITOR', 'Read-only compliance, audit log analysis, and reporting access')
ON CONFLICT (code) DO NOTHING;

-- -----------------------------------------------------------------------------
-- 2. PERMISSIONS & ROLE_PERMISSIONS TABLES
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.permissions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    module VARCHAR(50) NOT NULL,
    action VARCHAR(50) NOT NULL,
    code VARCHAR(100) NOT NULL UNIQUE,
    description TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS public.role_permissions (
    role_id UUID NOT NULL REFERENCES public.roles(id) ON DELETE CASCADE,
    permission_id UUID NOT NULL REFERENCES public.permissions(id) ON DELETE CASCADE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (role_id, permission_id)
);

-- -----------------------------------------------------------------------------
-- 3. BRANCHES TABLE
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.branches (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    branch_code VARCHAR(20) NOT NULL UNIQUE,
    name VARCHAR(100) NOT NULL,
    region VARCHAR(50) NOT NULL,
    city VARCHAR(50) NOT NULL,
    state VARCHAR(50) NOT NULL,
    address TEXT,
    contact_phone VARCHAR(20),
    contact_email VARCHAR(100),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- -----------------------------------------------------------------------------
-- 4. USERS TABLE (Linked with auth.users)
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.users (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    employee_code VARCHAR(30) NOT NULL UNIQUE,
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    phone VARCHAR(20) NOT NULL UNIQUE,
    role_id UUID NOT NULL REFERENCES public.roles(id),
    branch_id UUID REFERENCES public.branches(id),
    avatar_url TEXT,
    status VARCHAR(20) DEFAULT 'ACTIVE' CHECK (status IN ('ACTIVE', 'INACTIVE', 'SUSPENDED')),
    device_id VARCHAR(100),
    device_name VARCHAR(100),
    last_login_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- -----------------------------------------------------------------------------
-- 5. CUSTOMERS TABLE
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.customers (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    customer_code VARCHAR(30) NOT NULL UNIQUE,
    full_name VARCHAR(100) NOT NULL,
    phone_primary VARCHAR(20) NOT NULL,
    phone_secondary VARCHAR(20),
    email VARCHAR(100),
    address_residence TEXT NOT NULL,
    address_office TEXT,
    city VARCHAR(50) NOT NULL,
    state VARCHAR(50) NOT NULL,
    pincode VARCHAR(10) NOT NULL,
    latitude NUMERIC(10, 8),
    longitude NUMERIC(11, 8),
    photo_url TEXT,
    kyc_status VARCHAR(20) DEFAULT 'VERIFIED' CHECK (kyc_status IN ('PENDING', 'VERIFIED', 'REJECTED')),
    risk_category VARCHAR(20) DEFAULT 'MEDIUM' CHECK (risk_category IN ('LOW', 'MEDIUM', 'HIGH', 'CRITICAL')),
    branch_id UUID NOT NULL REFERENCES public.branches(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- -----------------------------------------------------------------------------
-- 6. LOANS TABLE
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.loans (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    loan_account_number VARCHAR(40) NOT NULL UNIQUE,
    customer_id UUID NOT NULL REFERENCES public.customers(id) ON DELETE CASCADE,
    branch_id UUID NOT NULL REFERENCES public.branches(id),
    loan_type VARCHAR(50) NOT NULL, -- Personal, Auto, Two-Wheeler, Home, Microfinance
    disbursed_amount NUMERIC(14, 2) NOT NULL,
    principal_outstanding NUMERIC(14, 2) NOT NULL,
    interest_outstanding NUMERIC(14, 2) DEFAULT 0.00,
    penalty_outstanding NUMERIC(14, 2) DEFAULT 0.00,
    total_outstanding NUMERIC(14, 2) NOT NULL,
    emi_amount NUMERIC(14, 2) NOT NULL,
    disbursed_date DATE NOT NULL,
    maturity_date DATE NOT NULL,
    next_emi_due_date DATE NOT NULL,
    dpd INT DEFAULT 0, -- Days Past Due
    bucket VARCHAR(20) DEFAULT 'CURRENT', -- CURRENT, SMA-0, SMA-1, SMA-2, NPA, NPA-90+
    status VARCHAR(20) DEFAULT 'ACTIVE' CHECK (status IN ('ACTIVE', 'CLOSED', 'SETTLED', 'WRITTEN_OFF', 'LEGAL')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- -----------------------------------------------------------------------------
-- 7. ALLOCATIONS TABLE
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.allocations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    allocation_code VARCHAR(40) NOT NULL UNIQUE,
    loan_id UUID NOT NULL REFERENCES public.loans(id) ON DELETE CASCADE,
    customer_id UUID NOT NULL REFERENCES public.customers(id),
    executive_id UUID NOT NULL REFERENCES public.users(id),
    assigned_by UUID NOT NULL REFERENCES public.users(id),
    branch_id UUID NOT NULL REFERENCES public.branches(id),
    allocated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    due_date DATE NOT NULL,
    target_amount NUMERIC(14, 2) NOT NULL,
    status VARCHAR(20) DEFAULT 'ASSIGNED' CHECK (status IN ('ASSIGNED', 'IN_PROGRESS', 'PARTIALLY_COLLECTED', 'COLLECTED', 'REALLOCATED', 'EXPIRED')),
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- -----------------------------------------------------------------------------
-- 8. VISITS TABLE
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.visits (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    visit_code VARCHAR(40) NOT NULL UNIQUE,
    allocation_id UUID REFERENCES public.allocations(id),
    loan_id UUID NOT NULL REFERENCES public.loans(id),
    customer_id UUID NOT NULL REFERENCES public.customers(id),
    executive_id UUID NOT NULL REFERENCES public.users(id),
    visit_date TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    latitude NUMERIC(10, 8) NOT NULL,
    longitude NUMERIC(11, 8) NOT NULL,
    gps_accuracy NUMERIC(8, 2),
    photos_urls JSONB DEFAULT '[]'::jsonb, -- Store array of house/customer photos
    visit_status VARCHAR(30) NOT NULL CHECK (visit_status IN ('CUSTOMER_MET', 'DOOR_LOCKED', 'ADDRESS_NOT_FOUND', 'REFUSED_TO_PAY', 'THIRD_PARTY_MET', 'PARTIAL_PAYMENT_PROMISE')),
    remarks TEXT NOT NULL,
    promise_date DATE,
    expected_amount NUMERIC(14, 2),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- -----------------------------------------------------------------------------
-- 9. PAYMENTS TABLE
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.payments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    payment_code VARCHAR(40) NOT NULL UNIQUE,
    receipt_number VARCHAR(40) NOT NULL UNIQUE,
    visit_id UUID REFERENCES public.visits(id),
    loan_id UUID NOT NULL REFERENCES public.loans(id),
    customer_id UUID NOT NULL REFERENCES public.customers(id),
    executive_id UUID NOT NULL REFERENCES public.users(id),
    branch_id UUID NOT NULL REFERENCES public.branches(id),
    amount_paid NUMERIC(14, 2) NOT NULL CHECK (amount_paid > 0),
    payment_mode VARCHAR(20) NOT NULL CHECK (payment_mode IN ('CASH', 'UPI', 'CHEQUE', 'NEFT', 'POS_CARD', 'NET_BANKING')),
    payment_reference VARCHAR(100),
    receipt_photo_url TEXT,
    payment_status VARCHAR(20) DEFAULT 'SUCCESS' CHECK (payment_status IN ('SUCCESS', 'PENDING_VERIFICATION', 'REJECTED', 'REFUNDED')),
    collected_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    verified_by UUID REFERENCES public.users(id),
    verified_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- -----------------------------------------------------------------------------
-- 10. FOLLOWUPS TABLE
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.followups (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    followup_code VARCHAR(40) NOT NULL UNIQUE,
    loan_id UUID NOT NULL REFERENCES public.loans(id),
    customer_id UUID NOT NULL REFERENCES public.customers(id),
    executive_id UUID NOT NULL REFERENCES public.users(id),
    scheduled_at TIMESTAMP WITH TIME ZONE NOT NULL,
    followup_type VARCHAR(30) DEFAULT 'FIELD_VISIT' CHECK (followup_type IN ('FIELD_VISIT', 'PHONE_CALL', 'SMS_REMINDER', 'LEGAL_NOTICE')),
    status VARCHAR(20) DEFAULT 'PENDING' CHECK (status IN ('PENDING', 'COMPLETED', 'MISSED', 'CANCELLED')),
    notes TEXT,
    reminder_sent BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- -----------------------------------------------------------------------------
-- 11. ATTENDANCE TABLE
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.attendance (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    attendance_code VARCHAR(40) NOT NULL UNIQUE,
    executive_id UUID NOT NULL REFERENCES public.users(id),
    date DATE NOT NULL,
    check_in_time TIMESTAMP WITH TIME ZONE NOT NULL,
    check_out_time TIMESTAMP WITH TIME ZONE,
    check_in_lat NUMERIC(10, 8) NOT NULL,
    check_in_lng NUMERIC(11, 8) NOT NULL,
    check_out_lat NUMERIC(10, 8),
    check_out_lng NUMERIC(11, 8),
    distance_covered_km NUMERIC(8, 2) DEFAULT 0.00,
    status VARCHAR(20) DEFAULT 'PRESENT' CHECK (status IN ('PRESENT', 'HALF_DAY', 'ABSENT', 'ON_LEAVE')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT unique_executive_date UNIQUE (executive_id, date)
);

-- -----------------------------------------------------------------------------
-- 12. GPS_LOGS TABLE
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.gps_logs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    executive_id UUID NOT NULL REFERENCES public.users(id),
    latitude NUMERIC(10, 8) NOT NULL,
    longitude NUMERIC(11, 8) NOT NULL,
    accuracy NUMERIC(8, 2),
    speed NUMERIC(6, 2),
    battery_level INT,
    device_id VARCHAR(100),
    captured_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- -----------------------------------------------------------------------------
-- 13. NOTIFICATIONS TABLE
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.notifications (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    title VARCHAR(150) NOT NULL,
    body TEXT NOT NULL,
    notification_type VARCHAR(50) NOT NULL, -- ALLOCATION, PAYMENT, FOLLOWUP, REMINDER, BROADCAST
    entity_type VARCHAR(50),
    entity_id UUID,
    is_read BOOLEAN DEFAULT FALSE,
    payload JSONB DEFAULT '{}'::jsonb,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- -----------------------------------------------------------------------------
-- 14. ACTIVITY_LOGS TABLE (AUDIT TRAIL)
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.activity_logs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES public.users(id),
    action VARCHAR(50) NOT NULL, -- LOGIN, LOGOUT, VISIT_CREATED, PAYMENT_COLLECTED, EXCEL_IMPORTED, ROLE_CHANGED
    entity_type VARCHAR(50) NOT NULL,
    entity_id UUID,
    old_state JSONB,
    new_state JSONB,
    ip_address VARCHAR(45),
    user_agent TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- -----------------------------------------------------------------------------
-- 15. DOCUMENTS TABLE
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.documents (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    document_code VARCHAR(40) NOT NULL UNIQUE,
    entity_type VARCHAR(50) NOT NULL, -- CUSTOMER, LOAN, VISIT, PAYMENT
    entity_id UUID NOT NULL,
    document_type VARCHAR(50) NOT NULL, -- AADHAAR, PAN, ELECTRICITY_BILL, LOAN_AGREEMENT, RECEIPT, HOUSE_PHOTO
    file_name VARCHAR(150) NOT NULL,
    file_url TEXT NOT NULL,
    mime_type VARCHAR(50) NOT NULL,
    file_size INT NOT NULL,
    uploaded_by UUID REFERENCES public.users(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- -----------------------------------------------------------------------------
-- 16. SETTINGS TABLE
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.settings (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    setting_key VARCHAR(100) NOT NULL UNIQUE,
    setting_value TEXT NOT NULL,
    category VARCHAR(50) NOT NULL DEFAULT 'SYSTEM',
    description TEXT,
    updated_by UUID REFERENCES public.users(id),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- -----------------------------------------------------------------------------
-- 17. DEVICE_TOKENS TABLE
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.device_tokens (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    fcm_token TEXT NOT NULL,
    device_type VARCHAR(20) NOT NULL CHECK (device_type IN ('ANDROID', 'IOS', 'WEB')),
    device_id VARCHAR(100) NOT NULL,
    app_version VARCHAR(20),
    is_active BOOLEAN DEFAULT TRUE,
    last_seen_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT unique_user_device UNIQUE (user_id, device_id)
);

-- -----------------------------------------------------------------------------
-- 18. SYNC_LOGS TABLE
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.sync_logs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    executive_id UUID NOT NULL REFERENCES public.users(id),
    device_id VARCHAR(100) NOT NULL,
    sync_started_at TIMESTAMP WITH TIME ZONE NOT NULL,
    sync_completed_at TIMESTAMP WITH TIME ZONE,
    records_uploaded INT DEFAULT 0,
    records_downloaded INT DEFAULT 0,
    status VARCHAR(20) DEFAULT 'SUCCESS' CHECK (status IN ('IN_PROGRESS', 'SUCCESS', 'FAILED', 'PARTIAL')),
    conflict_count INT DEFAULT 0,
    error_details JSONB,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- -----------------------------------------------------------------------------
-- 19. IMPORT_JOBS TABLE
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.import_jobs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    job_code VARCHAR(40) NOT NULL UNIQUE,
    file_name VARCHAR(150) NOT NULL,
    uploaded_by UUID NOT NULL REFERENCES public.users(id),
    status VARCHAR(20) DEFAULT 'PENDING' CHECK (status IN ('PENDING', 'PROCESSING', 'COMPLETED', 'FAILED')),
    total_records INT DEFAULT 0,
    processed_records INT DEFAULT 0,
    success_count INT DEFAULT 0,
    error_count INT DEFAULT 0,
    error_log_json JSONB DEFAULT '[]'::jsonb,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    finished_at TIMESTAMP WITH TIME ZONE
);

-- -----------------------------------------------------------------------------
-- 20. RECEIPTS TABLE
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.receipts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    receipt_number VARCHAR(40) NOT NULL UNIQUE,
    payment_id UUID NOT NULL REFERENCES public.payments(id) ON DELETE CASCADE,
    loan_id UUID NOT NULL REFERENCES public.loans(id),
    customer_id UUID NOT NULL REFERENCES public.customers(id),
    executive_id UUID NOT NULL REFERENCES public.users(id),
    amount NUMERIC(14, 2) NOT NULL,
    receipt_date TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    pdf_url TEXT,
    digital_signature TEXT,
    qr_code_data TEXT,
    status VARCHAR(20) DEFAULT 'ISSUED' CHECK (status IN ('ISSUED', 'CANCELLED', 'DUPLICATE')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- -----------------------------------------------------------------------------
-- 21. LEDGER TABLE
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.ledger (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    loan_id UUID NOT NULL REFERENCES public.loans(id),
    customer_id UUID NOT NULL REFERENCES public.customers(id),
    payment_id UUID REFERENCES public.payments(id),
    transaction_type VARCHAR(30) NOT NULL CHECK (transaction_type IN ('COLLECTION_CREDIT', 'DISBURSEMENT_DEBIT', 'PENALTY_DEBIT', 'WAIVER_CREDIT')),
    debit NUMERIC(14, 2) DEFAULT 0.00,
    credit NUMERIC(14, 2) DEFAULT 0.00,
    balance_after NUMERIC(14, 2) NOT NULL,
    transaction_date TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    reference_number VARCHAR(100),
    created_by UUID REFERENCES public.users(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- =============================================================================
-- INDEXES FOR HIGH-PERFORMANCE QUERYING (Targeting 100k customers / 5k Execs)
-- =============================================================================

-- Users & Roles
CREATE INDEX IF NOT EXISTS idx_users_role_id ON public.users(role_id);
CREATE INDEX IF NOT EXISTS idx_users_branch_id ON public.users(branch_id);
CREATE INDEX IF NOT EXISTS idx_users_employee_code ON public.users(employee_code);

-- Customers & Loans
CREATE INDEX IF NOT EXISTS idx_customers_branch_id ON public.customers(branch_id);
CREATE INDEX IF NOT EXISTS idx_customers_code ON public.customers(customer_code);
CREATE INDEX IF NOT EXISTS idx_customers_phone ON public.customers(phone_primary);

CREATE INDEX IF NOT EXISTS idx_loans_customer_id ON public.loans(customer_id);
CREATE INDEX IF NOT EXISTS idx_loans_branch_id ON public.loans(branch_id);
CREATE INDEX IF NOT EXISTS idx_loans_account_no ON public.loans(loan_account_number);
CREATE INDEX IF NOT EXISTS idx_loans_dpd ON public.loans(dpd);
CREATE INDEX IF NOT EXISTS idx_loans_bucket ON public.loans(bucket);
CREATE INDEX IF NOT EXISTS idx_loans_status ON public.loans(status);

-- Allocations
CREATE INDEX IF NOT EXISTS idx_allocations_executive_id ON public.allocations(executive_id);
CREATE INDEX IF NOT EXISTS idx_allocations_loan_id ON public.allocations(loan_id);
CREATE INDEX IF NOT EXISTS idx_allocations_branch_id ON public.allocations(branch_id);
CREATE INDEX IF NOT EXISTS idx_allocations_status ON public.allocations(status);
CREATE INDEX IF NOT EXISTS idx_allocations_due_date ON public.allocations(due_date);

-- Visits
CREATE INDEX IF NOT EXISTS idx_visits_executive_id ON public.visits(executive_id);
CREATE INDEX IF NOT EXISTS idx_visits_loan_id ON public.visits(loan_id);
CREATE INDEX IF NOT EXISTS idx_visits_customer_id ON public.visits(customer_id);
CREATE INDEX IF NOT EXISTS idx_visits_date ON public.visits(visit_date);
CREATE INDEX IF NOT EXISTS idx_visits_status ON public.visits(visit_status);

-- Payments
CREATE INDEX IF NOT EXISTS idx_payments_executive_id ON public.payments(executive_id);
CREATE INDEX IF NOT EXISTS idx_payments_loan_id ON public.payments(loan_id);
CREATE INDEX IF NOT EXISTS idx_payments_customer_id ON public.payments(customer_id);
CREATE INDEX IF NOT EXISTS idx_payments_receipt_number ON public.payments(receipt_number);
CREATE INDEX IF NOT EXISTS idx_payments_collected_at ON public.payments(collected_at);

-- Followups & Attendance & GPS
CREATE INDEX IF NOT EXISTS idx_followups_executive_id ON public.followups(executive_id);
CREATE INDEX IF NOT EXISTS idx_followups_scheduled_at ON public.followups(scheduled_at);
CREATE INDEX IF NOT EXISTS idx_followups_status ON public.followups(status);

CREATE INDEX IF NOT EXISTS idx_attendance_executive_date ON public.attendance(executive_id, date);
CREATE INDEX IF NOT EXISTS idx_gps_logs_exec_time ON public.gps_logs(executive_id, captured_at DESC);

-- Notifications & Activity Logs
CREATE INDEX IF NOT EXISTS idx_notifications_user_read ON public.notifications(user_id, is_read);
CREATE INDEX IF NOT EXISTS idx_activity_logs_user_action ON public.activity_logs(user_id, action);
CREATE INDEX IF NOT EXISTS idx_ledger_loan_id ON public.ledger(loan_id);

-- =============================================================================
-- PL/PGSQL TRIGGERS & FUNCTIONS
-- =============================================================================

-- 1. Auto Create Public User Profile on Supabase Auth Signup
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
DECLARE
    default_role_id UUID;
BEGIN
    SELECT id INTO default_role_id FROM public.roles WHERE code = 'FIELD_EXECUTIVE' LIMIT 1;
    INSERT INTO public.users (id, employee_code, full_name, email, phone, role_id)
    VALUES (
        NEW.id,
        COALESCE(NEW.raw_user_meta_data->>'employee_code', 'EMP-' || SUBSTRING(NEW.id::text, 1, 8)),
        COALESCE(NEW.raw_user_meta_data->>'full_name', 'Field User'),
        NEW.email,
        COALESCE(NEW.phone, NEW.raw_user_meta_data->>'phone', '0000000000'),
        default_role_id
    )
    ON CONFLICT (id) DO NOTHING;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- 2. Update Loan Balance & Allocation Status upon Successful Payment Creation
CREATE OR REPLACE FUNCTION public.update_loan_balances_on_payment()
RETURNS TRIGGER AS $$
DECLARE
    curr_outstanding NUMERIC(14, 2);
    new_outstanding NUMERIC(14, 2);
    v_loan_id UUID;
    v_customer_id UUID;
BEGIN
    v_loan_id := NEW.loan_id;
    v_customer_id := NEW.customer_id;

    -- Fetch current total outstanding
    SELECT total_outstanding INTO curr_outstanding FROM public.loans WHERE id = v_loan_id FOR UPDATE;
    
    new_outstanding := GREATEST(0.00, curr_outstanding - NEW.amount_paid);

    -- Update loan status & balance
    UPDATE public.loans
    SET 
        principal_outstanding = GREATEST(0.00, principal_outstanding - NEW.amount_paid),
        total_outstanding = new_outstanding,
        status = CASE WHEN new_outstanding = 0.00 THEN 'CLOSED' ELSE status END,
        updated_at = CURRENT_TIMESTAMP
    WHERE id = v_loan_id;

    -- Update Allocation status if exists
    UPDATE public.allocations
    SET 
        status = CASE WHEN new_outstanding = 0.00 THEN 'COLLECTED' ELSE 'PARTIALLY_COLLECTED' END,
        updated_at = CURRENT_TIMESTAMP
    WHERE loan_id = v_loan_id AND status IN ('ASSIGNED', 'IN_PROGRESS', 'PARTIALLY_COLLECTED');

    -- Create Ledger Credit Entry
    INSERT INTO public.ledger (
        loan_id, customer_id, payment_id, transaction_type, credit, balance_after, reference_number, created_by
    ) VALUES (
        v_loan_id, v_customer_id, NEW.id, 'COLLECTION_CREDIT', NEW.amount_paid, new_outstanding, NEW.receipt_number, NEW.executive_id
    );

    -- Auto-generate Receipt
    INSERT INTO public.receipts (
        receipt_number, payment_id, loan_id, customer_id, executive_id, amount, qr_code_data
    ) VALUES (
        NEW.receipt_number, NEW.id, v_loan_id, v_customer_id, NEW.executive_id, NEW.amount_paid, 'FINCOLLECT:' || NEW.receipt_number
    ) ON CONFLICT (receipt_number) DO NOTHING;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS trg_payment_post_processing ON public.payments;
CREATE TRIGGER trg_payment_post_processing
    AFTER INSERT ON public.payments
    FOR EACH ROW
    WHEN (NEW.payment_status = 'SUCCESS')
    EXECUTE FUNCTION public.update_loan_balances_on_payment();

-- 3. Automatic Audit Logging Trigger
CREATE OR REPLACE FUNCTION public.audit_log_trigger()
RETURNS TRIGGER AS $$
DECLARE
    v_user_id UUID;
BEGIN
    v_user_id := auth.uid();
    IF TG_OP = 'INSERT' THEN
        INSERT INTO public.activity_logs (user_id, action, entity_type, entity_id, new_state)
        VALUES (v_user_id, TG_TABLE_NAME || '_CREATED', TG_TABLE_NAME, NEW.id, row_to_json(NEW)::jsonb);
    ELSIF TG_OP = 'UPDATE' THEN
        INSERT INTO public.activity_logs (user_id, action, entity_type, entity_id, old_state, new_state)
        VALUES (v_user_id, TG_TABLE_NAME || '_UPDATED', TG_TABLE_NAME, NEW.id, row_to_json(OLD)::jsonb, row_to_json(NEW)::jsonb);
    ELSIF TG_OP = 'DELETE' THEN
        INSERT INTO public.activity_logs (user_id, action, entity_type, entity_id, old_state)
        VALUES (v_user_id, TG_TABLE_NAME || '_DELETED', TG_TABLE_NAME, OLD.id, row_to_json(OLD)::jsonb);
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Attach Audit Log Triggers to Core Financial & Operational Tables
CREATE TRIGGER trg_audit_payments AFTER INSERT OR UPDATE OR DELETE ON public.payments FOR EACH ROW EXECUTE FUNCTION public.audit_log_trigger();
CREATE TRIGGER trg_audit_allocations AFTER INSERT OR UPDATE OR DELETE ON public.allocations FOR EACH ROW EXECUTE FUNCTION public.audit_log_trigger();
CREATE TRIGGER trg_audit_visits AFTER INSERT OR UPDATE OR DELETE ON public.visits FOR EACH ROW EXECUTE FUNCTION public.audit_log_trigger();

-- 4. DPD & Bucket Recalculation Function
CREATE OR REPLACE FUNCTION public.recalculate_dpd_and_buckets()
RETURNS INT AS $$
DECLARE
    updated_count INT := 0;
BEGIN
    UPDATE public.loans
    SET 
        dpd = GREATEST(0, (CURRENT_DATE - next_emi_due_date)::int),
        bucket = CASE 
            WHEN (CURRENT_DATE - next_emi_due_date)::int <= 0 THEN 'CURRENT'
            WHEN (CURRENT_DATE - next_emi_due_date)::int BETWEEN 1 AND 30 THEN 'SMA-0'
            WHEN (CURRENT_DATE - next_emi_due_date)::int BETWEEN 31 AND 60 THEN 'SMA-1'
            WHEN (CURRENT_DATE - next_emi_due_date)::int BETWEEN 61 AND 90 THEN 'SMA-2'
            WHEN (CURRENT_DATE - next_emi_due_date)::int BETWEEN 91 AND 180 THEN 'NPA'
            ELSE 'NPA-90+'
        END,
        updated_at = CURRENT_TIMESTAMP
    WHERE status = 'ACTIVE' AND total_outstanding > 0;
    
    GET DIAGNOSTICS updated_count = ROW_COUNT;
    RETURN updated_count;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
