-- =============================================================================
-- FINCOLLECT ENTERPRISE FIELD COLLECTION PLATFORM
-- Migration: 20260723000003_seed_datasets.sql
-- Description: Comprehensive Enterprise Seed Dataset for testing & demonstration
-- =============================================================================

-- -----------------------------------------------------------------------------
-- 1. SEED BRANCHES
-- -----------------------------------------------------------------------------
INSERT INTO public.branches (id, branch_code, name, region, city, state, address, contact_phone, contact_email) VALUES
    ('b1000000-0000-0000-0000-000000000001', 'BR-MUM-01', 'Mumbai West Branch', 'WEST', 'Mumbai', 'Maharashtra', '102 Business Park, Andheri West, Mumbai', '+919876543210', 'mumbai.west@fincollect.app'),
    ('b1000000-0000-0000-0000-000000000002', 'BR-DEL-01', 'Delhi Central Branch', 'NORTH', 'New Delhi', 'Delhi', '45 Connaught Place, New Delhi', '+919876543211', 'delhi.central@fincollect.app'),
    ('b1000000-0000-0000-0000-000000000003', 'BR-BLR-01', 'Bangalore South Branch', 'SOUTH', 'Bangalore', 'Karnataka', '88 MG Road, Indiranagar, Bangalore', '+919876543212', 'blr.south@fincollect.app'),
    ('b1000000-0000-0000-0000-000000000004', 'BR-HYD-01', 'Hyderabad Urban Branch', 'SOUTH', 'Hyderabad', 'Telangana', '12 HITEC City Main Rd, Hyderabad', '+919876543213', 'hyd.urban@fincollect.app')
ON CONFLICT (branch_code) DO NOTHING;

-- -----------------------------------------------------------------------------
-- 2. SEED USERS & PROFILES
-- -----------------------------------------------------------------------------
INSERT INTO public.users (id, employee_code, full_name, email, phone, role_id, branch_id, status) VALUES
    ('u1000000-0000-0000-0000-000000000001', 'EMP-ADM-01', 'Vikramaditya Sharma', 'admin@fincollect.app', '+919900000001', '10000000-0000-0000-0000-000000000002', 'b1000000-0000-0000-0000-000000000001', 'ACTIVE'),
    ('u1000000-0000-0000-0000-000000000002', 'EMP-BM-01', 'Rajesh Kulkarni', 'bm.mumbai@fincollect.app', '+919900000002', '10000000-0000-0000-0000-000000000004', 'b1000000-0000-0000-0000-000000000001', 'ACTIVE'),
    ('u1000000-0000-0000-0000-000000000003', 'EMP-FE-01', 'Amit Verma', 'executive@fincollect.app', '+919900000003', '10000000-0000-0000-0000-000000000006', 'b1000000-0000-0000-0000-000000000001', 'ACTIVE'),
    ('u1000000-0000-0000-0000-000000000004', 'EMP-FE-02', 'Priya Sundaram', 'priya.fe@fincollect.app', '+919900000004', '10000000-0000-0000-0000-000000000006', 'b1000000-0000-0000-0000-000000000003', 'ACTIVE'),
    ('u1000000-0000-0000-0000-000000000005', 'EMP-FIN-01', 'Siddharth Mehta', 'finance@fincollect.app', '+919900000005', '10000000-0000-0000-0000-000000000007', 'b1000000-0000-0000-0000-000000000001', 'ACTIVE')
ON CONFLICT (id) DO NOTHING;

-- -----------------------------------------------------------------------------
-- 3. SEED CUSTOMERS
-- -----------------------------------------------------------------------------
INSERT INTO public.customers (id, customer_code, full_name, phone_primary, phone_secondary, email, address_residence, city, state, pincode, latitude, longitude, risk_category, branch_id) VALUES
    ('c1000000-0000-0000-0000-000000000001', 'CUST-1001', 'Ramesh Chandra Joshi', '+919820011223', '+919820011224', 'ramesh.joshi@email.com', 'Flat 402, Shanti Heights, Malad West', 'Mumbai', 'Maharashtra', '400064', 19.1860, 72.8485, 'HIGH', 'b1000000-0000-0000-0000-000000000001'),
    ('c1000000-0000-0000-0000-000000000002', 'CUST-1002', 'Sunita Anand Rao', '+919830022334', NULL, 'sunita.rao@email.com', 'Plot 18, Royal Enclave, Indiranagar', 'Bangalore', 'Karnataka', '560038', 12.9784, 77.6408, 'MEDIUM', 'b1000000-0000-0000-0000-000000000003'),
    ('c1000000-0000-0000-0000-000000000003', 'CUST-1003', 'Deepak Kumar Gupta', '+919840033445', '+919840033446', 'deepak.gupta@email.com', 'H.No 105, Sector 15, Rohini', 'New Delhi', 'Delhi', '110085', 28.7180, 77.1200, 'CRITICAL', 'b1000000-0000-0000-0000-000000000002'),
    ('c1000000-0000-0000-0000-000000000004', 'CUST-1004', 'Ananya Deshmukh', '+919850044556', NULL, 'ananya.d@email.com', 'B-12, Green Meadows, Jubilee Hills', 'Hyderabad', 'Telangana', '500033', 17.4319, 78.4071, 'LOW', 'b1000000-0000-0000-0000-000000000004')
ON CONFLICT (customer_code) DO NOTHING;

-- -----------------------------------------------------------------------------
-- 4. SEED LOANS
-- -----------------------------------------------------------------------------
INSERT INTO public.loans (id, loan_account_number, customer_id, branch_id, loan_type, disbursed_amount, principal_outstanding, interest_outstanding, total_outstanding, emi_amount, disbursed_date, maturity_date, next_emi_due_date, dpd, bucket, status) VALUES
    ('l1000000-0000-0000-0000-000000000001', 'LN-PL-2025-0891', 'c1000000-0000-0000-0000-000000000001', 'b1000000-0000-0000-0000-000000000001', 'Personal Loan', 250000.00, 185000.00, 4500.00, 189500.00, 12500.00, '2025-01-15', '2027-01-15', '2026-06-10', 43, 'SMA-1', 'ACTIVE'),
    ('l1000000-0000-0000-0000-000000000002', 'LN-AL-2025-0412', 'c1000000-0000-0000-0000-000000000002', 'b1000000-0000-0000-0000-000000000003', 'Auto Loan', 600000.00, 420000.00, 8000.00, 428000.00, 21000.00, '2025-03-20', '2028-03-20', '2026-07-05', 18, 'SMA-0', 'ACTIVE'),
    ('l1000000-0000-0000-0000-000000000003', 'LN-TW-2024-1109', 'c1000000-0000-0000-0000-000000000003', 'b1000000-0000-0000-0000-000000000002', 'Two-Wheeler Loan', 85000.00, 54000.00, 6200.00, 60200.00, 4500.00, '2024-10-10', '2026-10-10', '2026-04-01', 113, 'NPA', 'ACTIVE'),
    ('l1000000-0000-0000-0000-000000000004', 'LN-MF-2025-0043', 'c1000000-0000-0000-0000-000000000004', 'b1000000-0000-0000-0000-000000000004', 'Microfinance Loan', 50000.00, 22000.00, 0.00, 22000.00, 3500.00, '2025-05-01', '2026-11-01', '2026-07-25', 0, 'CURRENT', 'ACTIVE')
ON CONFLICT (loan_account_number) DO NOTHING;

-- -----------------------------------------------------------------------------
-- 5. SEED ALLOCATIONS
-- -----------------------------------------------------------------------------
INSERT INTO public.allocations (id, allocation_code, loan_id, customer_id, executive_id, assigned_by, branch_id, due_date, target_amount, status) VALUES
    ('a1000000-0000-0000-0000-000000000001', 'ALLOC-202607-001', 'l1000000-0000-0000-0000-000000000001', 'c1000000-0000-0000-0000-000000000001', 'u1000000-0000-0000-0000-000000000003', 'u1000000-0000-0000-0000-000000000002', 'b1000000-0000-0000-0000-000000000001', CURRENT_DATE, 12500.00, 'ASSIGNED'),
    ('a1000000-0000-0000-0000-000000000002', 'ALLOC-202607-002', 'l1000000-0000-0000-0000-000000000002', 'c1000000-0000-0000-0000-000000000002', 'u1000000-0000-0000-0000-000000000004', 'u1000000-0000-0000-0000-000000000001', 'b1000000-0000-0000-0000-000000000003', CURRENT_DATE, 21000.00, 'IN_PROGRESS')
ON CONFLICT (allocation_code) DO NOTHING;

-- -----------------------------------------------------------------------------
-- 6. SEED VISITS
-- -----------------------------------------------------------------------------
INSERT INTO public.visits (id, visit_code, allocation_id, loan_id, customer_id, executive_id, latitude, longitude, gps_accuracy, visit_status, remarks, promise_date, expected_amount) VALUES
    ('v1000000-0000-0000-0000-000000000001', 'VIS-20260723-01', 'a1000000-0000-0000-0000-000000000001', 'l1000000-0000-0000-0000-000000000001', 'c1000000-0000-0000-0000-000000000001', 'u1000000-0000-0000-0000-000000000003', 19.1862, 72.8488, 4.5, 'CUSTOMER_MET', 'Customer promised partial payment by 28th July.', CURRENT_DATE + 5, 10000.00)
ON CONFLICT (visit_code) DO NOTHING;

-- -----------------------------------------------------------------------------
-- 7. SEED PAYMENTS & RECEIPTS
-- -----------------------------------------------------------------------------
INSERT INTO public.payments (id, payment_code, receipt_number, visit_id, loan_id, customer_id, executive_id, branch_id, amount_paid, payment_mode, payment_reference, payment_status) VALUES
    ('p1000000-0000-0000-0000-000000000001', 'PAY-20260723-01', 'RCP-884129-01', 'v1000000-0000-0000-0000-000000000001', 'l1000000-0000-0000-0000-000000000001', 'c1000000-0000-0000-0000-000000000001', 'u1000000-0000-0000-0000-000000000003', 'b1000000-0000-0000-0000-000000000001', 5000.00, 'UPI', 'UPI-TXN-9988112233', 'SUCCESS')
ON CONFLICT (payment_code) DO NOTHING;

-- -----------------------------------------------------------------------------
-- 8. SEED FOLLOWUPS & SETTINGS
-- -----------------------------------------------------------------------------
INSERT INTO public.followups (id, followup_code, loan_id, customer_id, executive_id, scheduled_at, followup_type, status, notes) VALUES
    ('f1000000-0000-0000-0000-000000000001', 'FLP-20260723-01', 'l1000000-0000-0000-0000-000000000001', 'c1000000-0000-0000-0000-000000000001', 'u1000000-0000-0000-0000-000000000003', CURRENT_TIMESTAMP + INTERVAL '2 DAYS', 'FIELD_VISIT', 'PENDING', 'Collect balance EMI amount ₹7,500.')
ON CONFLICT (followup_code) DO NOTHING;

INSERT INTO public.settings (setting_key, setting_value, category, description) VALUES
    ('MAX_ALLOCATION_PER_EXEC', '50', 'OPERATIONAL', 'Maximum open customer allocations allowed per Field Executive'),
    ('GPS_PING_INTERVAL_SEC', '300', 'MOBILE_TRACKING', 'Frequency of background GPS breadcrumb logging in seconds'),
    ('RECEIPT_PREFIX', 'RCP', 'FINANCIAL', 'Prefix prefix for official digital receipt generation')
ON CONFLICT (setting_key) DO NOTHING;
