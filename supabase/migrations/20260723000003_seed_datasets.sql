-- =============================================================================
-- FINCOLLECT ENTERPRISE FIELD COLLECTION PLATFORM
-- Migration: 20260723000003_seed_datasets.sql
-- Description: Comprehensive Enterprise Seed Dataset for testing & demonstration
-- =============================================================================

-- -----------------------------------------------------------------------------
-- 1. SEED BRANCHES
-- -----------------------------------------------------------------------------
INSERT INTO public.branches (id, branch_code, name, region, city, state, address, contact_phone, contact_email) VALUES
    ('b1000000-0000-0000-0000-000000000001', 'BR-MUM-01', 'Mumbai West Branch', 'WEST', 'Mumbai', 'Maharashtra', '102 Business Park, Andheri West, Mumbai', '+919876543210', 'mumbai.west@lotfieldcollection.app'),
    ('b1000000-0000-0000-0000-000000000002', 'BR-DEL-01', 'Delhi Central Branch', 'NORTH', 'New Delhi', 'Delhi', '45 Connaught Place, New Delhi', '+919876543211', 'delhi.central@lotfieldcollection.app'),
    ('b1000000-0000-0000-0000-000000000003', 'BR-BLR-01', 'Bangalore South Branch', 'SOUTH', 'Bangalore', 'Karnataka', '88 MG Road, Indiranagar, Bangalore', '+919876543212', 'blr.south@lotfieldcollection.app'),
    ('b1000000-0000-0000-0000-000000000004', 'BR-HYD-01', 'Hyderabad Urban Branch', 'SOUTH', 'Hyderabad', 'Telangana', '12 HITEC City Main Rd, Hyderabad', '+919876543213', 'hyd.urban@lotfieldcollection.app')
ON CONFLICT (branch_code) DO NOTHING;

-- Auth-linked user profiles are intentionally not seeded here.  The `users.id`
-- foreign key points to auth.users, so profiles must be created by
-- `handle_new_user` after an actual Supabase Auth signup.

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

-- Operational records need a real authenticated executive. Seed them through an
-- authenticated integration test or after creating the corresponding Auth users.

-- -----------------------------------------------------------------------------
-- 5. SEED SETTINGS
-- -----------------------------------------------------------------------------

INSERT INTO public.settings (setting_key, setting_value, category, description) VALUES
    ('MAX_ALLOCATION_PER_EXEC', '50', 'OPERATIONAL', 'Maximum open customer allocations allowed per Field Executive'),
    ('GPS_PING_INTERVAL_SEC', '300', 'MOBILE_TRACKING', 'Frequency of background GPS breadcrumb logging in seconds'),
    ('RECEIPT_PREFIX', 'RCP', 'FINANCIAL', 'Prefix prefix for official digital receipt generation')
ON CONFLICT (setting_key) DO NOTHING;
