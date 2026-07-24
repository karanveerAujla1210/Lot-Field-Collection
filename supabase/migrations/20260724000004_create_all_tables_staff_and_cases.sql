-- =============================================================================
-- FINCOLLECT ENTERPRISE DATABASE MIGRATION & DATA SEEDING
-- Target File: Open & Part Cases till 20th July.xlsx (668 rows) + Staff Data (10 Field Executives)
-- Generated Date: 2026-07-24T14:01:51.382Z
-- =============================================================================

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- 1. ROLES TABLE
CREATE TABLE IF NOT EXISTS public.roles (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(50) NOT NULL UNIQUE,
    code VARCHAR(50) NOT NULL UNIQUE,
    description TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO public.roles (id, name, code, description) VALUES
    ('10000000-0000-0000-0000-000000000001', 'Super Admin', 'SUPER_ADMIN', 'System wide full access'),
    ('10000000-0000-0000-0000-000000000002', 'Admin', 'ADMIN', 'Administrative access'),
    ('10000000-0000-0000-0000-000000000006', 'Field Executive', 'FIELD_EXECUTIVE', 'Field execution agent')
ON CONFLICT (code) DO NOTHING;

-- 2. BRANCHES TABLE
CREATE TABLE IF NOT EXISTS public.branches (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    branch_code VARCHAR(50) NOT NULL UNIQUE,
    name VARCHAR(100) NOT NULL,
    region VARCHAR(50) DEFAULT 'India',
    city VARCHAR(50) NOT NULL,
    state VARCHAR(50) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 3. USERS (STAFF) TABLE
CREATE TABLE IF NOT EXISTS public.users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    employee_code VARCHAR(30) NOT NULL UNIQUE,
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE,
    phone VARCHAR(20) NOT NULL UNIQUE,
    role_id UUID REFERENCES public.roles(id),
    branch_id UUID REFERENCES public.branches(id),
    status VARCHAR(20) DEFAULT 'ACTIVE',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 4. CUSTOMERS TABLE
CREATE TABLE IF NOT EXISTS public.customers (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    customer_code VARCHAR(50) NOT NULL UNIQUE,
    full_name VARCHAR(100) NOT NULL,
    phone_primary VARCHAR(20),
    email VARCHAR(100),
    pan_number VARCHAR(20),
    address_residence TEXT,
    address_office TEXT,
    city VARCHAR(50),
    state VARCHAR(50),
    branch_id UUID REFERENCES public.branches(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 5. LOANS TABLE
CREATE TABLE IF NOT EXISTS public.loans (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    loan_account_number VARCHAR(50) NOT NULL UNIQUE,
    customer_id UUID REFERENCES public.customers(id) ON DELETE CASCADE,
    branch_id UUID REFERENCES public.branches(id),
    loan_type VARCHAR(50) DEFAULT 'Personal Loan',
    disbursed_amount NUMERIC(14, 2) DEFAULT 0,
    principal_outstanding NUMERIC(14, 2) DEFAULT 0,
    total_outstanding NUMERIC(14, 2) DEFAULT 0,
    emi_amount NUMERIC(14, 2) DEFAULT 0,
    disbursed_date DATE,
    repayment_date DATE,
    dpd INT DEFAULT 0,
    bucket VARCHAR(20) DEFAULT 'CURRENT',
    status VARCHAR(20) DEFAULT 'ACTIVE',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 6. ALLOCATIONS TABLE
CREATE TABLE IF NOT EXISTS public.allocations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    allocation_code VARCHAR(50) NOT NULL UNIQUE,
    loan_id UUID REFERENCES public.loans(id) ON DELETE CASCADE,
    customer_id UUID REFERENCES public.customers(id),
    executive_id UUID REFERENCES public.users(id),
    target_amount NUMERIC(14, 2) DEFAULT 0,
    status VARCHAR(20) DEFAULT 'ASSIGNED',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 7. FULL CASES TABLE (Direct map to Open & Part Cases till 20th July.xlsx)
CREATE TABLE IF NOT EXISTS public.cases (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    lead_id INT,
    state_name VARCHAR(100),
    branch_name VARCHAR(100),
    customer_code VARCHAR(50),
    pan_number VARCHAR(20),
    loan_no VARCHAR(50) UNIQUE,
    customer_name VARCHAR(150),
    mobile_number VARCHAR(20),
    email VARCHAR(100),
    loan_amount NUMERIC(14, 2),
    net_disbursed_amount NUMERIC(14, 2),
    admin_fee NUMERIC(14, 2),
    admin_fee_gst NUMERIC(14, 2),
    total_admin_fee NUMERIC(14, 2),
    igst NUMERIC(14, 2),
    cgst NUMERIC(14, 2),
    sgst NUMERIC(14, 2),
    processing NUMERIC(14, 2),
    tenure INT,
    roi NUMERIC(10, 4),
    loan_repay_amount NUMERIC(14, 2),
    disbursement_date DATE,
    repayment_date DATE,
    customer_bank_account VARCHAR(50),
    customer_bank_name VARCHAR(100),
    customer_bank_ifsc VARCHAR(30),
    disbursement_reference VARCHAR(100),
    disbursement_status VARCHAR(50),
    repeat_type VARCHAR(50),
    sanctioned_by VARCHAR(100),
    approved_by VARCHAR(100),
    house_address TEXT,
    office_address TEXT,
    due_days INT,
    bucket VARCHAR(50),
    month VARCHAR(50),
    loan_status VARCHAR(50),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- DISABLE RLS FOR UNRESTRICTED CRM & APP READ/WRITE ACCESS
ALTER TABLE public.roles DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.branches DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.users DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.customers DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.loans DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.allocations DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.cases DISABLE ROW LEVEL SECURITY;

-- SEED BRANCHES
INSERT INTO public.branches (branch_code, name, city, state) VALUES ('BR-001', 'Bangalore', 'Bangalore', 'Bangalore') ON CONFLICT (branch_code) DO NOTHING;
INSERT INTO public.branches (branch_code, name, city, state) VALUES ('BR-002', 'Delhi - Gurugram', 'Delhi', 'Gurugram') ON CONFLICT (branch_code) DO NOTHING;
INSERT INTO public.branches (branch_code, name, city, state) VALUES ('BR-003', 'Noida - Ghaziabad - Faridabad', 'Noida', 'Ghaziabad') ON CONFLICT (branch_code) DO NOTHING;
INSERT INTO public.branches (branch_code, name, city, state) VALUES ('BR-004', 'West bengal - Kolkata', 'West bengal', 'Kolkata') ON CONFLICT (branch_code) DO NOTHING;
INSERT INTO public.branches (branch_code, name, city, state) VALUES ('BR-005', 'Ahemdabad - Gujarat', 'Ahemdabad', 'Gujarat') ON CONFLICT (branch_code) DO NOTHING;
INSERT INTO public.branches (branch_code, name, city, state) VALUES ('BR-007', 'Hyderabad', 'Hyderabad', 'Hyderabad') ON CONFLICT (branch_code) DO NOTHING;
INSERT INTO public.branches (branch_code, name, city, state) VALUES ('BR-008', 'Mumbai', 'Mumbai', 'Mumbai') ON CONFLICT (branch_code) DO NOTHING;
INSERT INTO public.branches (branch_code, name, city, state) VALUES ('BR-009', 'Thane - Raigarh', 'Thane', 'Raigarh') ON CONFLICT (branch_code) DO NOTHING;
INSERT INTO public.branches (branch_code, name, city, state) VALUES ('BR-010', 'Pune', 'Pune', 'Pune') ON CONFLICT (branch_code) DO NOTHING;
INSERT INTO public.branches (branch_code, name, city, state) VALUES ('BR-010', '24 Parganas', '24 Parganas', 'West Bengal') ON CONFLICT (branch_code) DO NOTHING;
INSERT INTO public.branches (branch_code, name, city, state) VALUES ('BR-011', 'Kolkata', 'Kolkata', 'West Bengal') ON CONFLICT (branch_code) DO NOTHING;
INSERT INTO public.branches (branch_code, name, city, state) VALUES ('BR-012', 'Gurgaon', 'Gurgaon', 'Haryana') ON CONFLICT (branch_code) DO NOTHING;
INSERT INTO public.branches (branch_code, name, city, state) VALUES ('BR-013', 'Chennai', 'Chennai', 'Tamil Nadu') ON CONFLICT (branch_code) DO NOTHING;
INSERT INTO public.branches (branch_code, name, city, state) VALUES ('BR-014', 'Thane', 'Thane', 'Maharashtra') ON CONFLICT (branch_code) DO NOTHING;
INSERT INTO public.branches (branch_code, name, city, state) VALUES ('BR-015', 'Rangareddy', 'Rangareddy', 'Telangana') ON CONFLICT (branch_code) DO NOTHING;
INSERT INTO public.branches (branch_code, name, city, state) VALUES ('BR-016', 'Ghaziabad', 'Ghaziabad', 'Uttar Pradesh') ON CONFLICT (branch_code) DO NOTHING;
INSERT INTO public.branches (branch_code, name, city, state) VALUES ('BR-017', 'Surat', 'Surat', 'Gujarat') ON CONFLICT (branch_code) DO NOTHING;
INSERT INTO public.branches (branch_code, name, city, state) VALUES ('BR-018', 'Greater Noida', 'Greater Noida', 'Uttar Pradesh') ON CONFLICT (branch_code) DO NOTHING;
INSERT INTO public.branches (branch_code, name, city, state) VALUES ('BR-019', 'Ahmedabad', 'Ahmedabad', 'Gujarat') ON CONFLICT (branch_code) DO NOTHING;
INSERT INTO public.branches (branch_code, name, city, state) VALUES ('BR-020', 'Coimbatore', 'Coimbatore', 'Tamil Nadu') ON CONFLICT (branch_code) DO NOTHING;
INSERT INTO public.branches (branch_code, name, city, state) VALUES ('BR-021', 'New Delhi', 'New Delhi', 'Delhi') ON CONFLICT (branch_code) DO NOTHING;
INSERT INTO public.branches (branch_code, name, city, state) VALUES ('BR-022', 'Kanchipuram', 'Kanchipuram', 'Tamil Nadu') ON CONFLICT (branch_code) DO NOTHING;
INSERT INTO public.branches (branch_code, name, city, state) VALUES ('BR-023', 'Raigarh', 'Raigarh', 'Maharashtra') ON CONFLICT (branch_code) DO NOTHING;
INSERT INTO public.branches (branch_code, name, city, state) VALUES ('BR-024', 'Faridabad', 'Faridabad', 'Haryana') ON CONFLICT (branch_code) DO NOTHING;
INSERT INTO public.branches (branch_code, name, city, state) VALUES ('BR-025', 'Noida', 'Noida', 'Uttar Pradesh') ON CONFLICT (branch_code) DO NOTHING;
INSERT INTO public.branches (branch_code, name, city, state) VALUES ('BR-026', 'Medak', 'Medak', 'Telangana') ON CONFLICT (branch_code) DO NOTHING;
INSERT INTO public.branches (branch_code, name, city, state) VALUES ('BR-027', 'Howrah', 'Howrah', 'West Bengal') ON CONFLICT (branch_code) DO NOTHING;
INSERT INTO public.branches (branch_code, name, city, state) VALUES ('BR-028', 'Visakhapatnam', 'Visakhapatnam', 'Andhra Pradesh') ON CONFLICT (branch_code) DO NOTHING;
INSERT INTO public.branches (branch_code, name, city, state) VALUES ('BR-029', 'Guntur', 'Guntur', 'Andhra Pradesh') ON CONFLICT (branch_code) DO NOTHING;
INSERT INTO public.branches (branch_code, name, city, state) VALUES ('BR-030', 'Gautam Buddha Nagar', 'Gautam Buddha Nagar', 'Uttar Pradesh') ON CONFLICT (branch_code) DO NOTHING;

-- SEED STAFF / FIELD EXECUTIVES DATA
INSERT INTO public.users (employee_code, full_name, email, phone, role_id, branch_id) VALUES ('EMP001', 'Jitendra', 'jitendra@fincollect.com', '9449477443', '10000000-0000-0000-0000-000000000006', (SELECT id FROM public.branches WHERE branch_code = 'BR-001' LIMIT 1)) ON CONFLICT (phone) DO UPDATE SET full_name = EXCLUDED.full_name;
INSERT INTO public.users (employee_code, full_name, email, phone, role_id, branch_id) VALUES ('EMP002', 'Sushant', 'sushant@fincollect.com', '8700413312', '10000000-0000-0000-0000-000000000006', (SELECT id FROM public.branches WHERE branch_code = 'BR-002' LIMIT 1)) ON CONFLICT (phone) DO UPDATE SET full_name = EXCLUDED.full_name;
INSERT INTO public.users (employee_code, full_name, email, phone, role_id, branch_id) VALUES ('EMP003', 'Rahul', 'rahul@fincollect.com', '7042793573', '10000000-0000-0000-0000-000000000006', (SELECT id FROM public.branches WHERE branch_code = 'BR-003' LIMIT 1)) ON CONFLICT (phone) DO UPDATE SET full_name = EXCLUDED.full_name;
INSERT INTO public.users (employee_code, full_name, email, phone, role_id, branch_id) VALUES ('EMP004', 'Imteyaz', 'imteyaz@fincollect.com', '8100669081', '10000000-0000-0000-0000-000000000006', (SELECT id FROM public.branches WHERE branch_code = 'BR-004' LIMIT 1)) ON CONFLICT (phone) DO UPDATE SET full_name = EXCLUDED.full_name;
INSERT INTO public.users (employee_code, full_name, email, phone, role_id, branch_id) VALUES ('EMP005', 'Anil', 'anil@fincollect.com', '8320109581', '10000000-0000-0000-0000-000000000006', (SELECT id FROM public.branches WHERE branch_code = 'BR-005' LIMIT 1)) ON CONFLICT (phone) DO UPDATE SET full_name = EXCLUDED.full_name;
INSERT INTO public.users (employee_code, full_name, email, phone, role_id, branch_id) VALUES ('EMP006', 'Prince', 'prince@fincollect.com', '6302703146', '10000000-0000-0000-0000-000000000006', (SELECT id FROM public.branches WHERE branch_code = 'BR-007' LIMIT 1)) ON CONFLICT (phone) DO UPDATE SET full_name = EXCLUDED.full_name;
INSERT INTO public.users (employee_code, full_name, email, phone, role_id, branch_id) VALUES ('EMP007', 'Abhishek', 'abhishek@fincollect.com', '9908923165', '10000000-0000-0000-0000-000000000006', (SELECT id FROM public.branches WHERE branch_code = 'BR-007' LIMIT 1)) ON CONFLICT (phone) DO UPDATE SET full_name = EXCLUDED.full_name;
INSERT INTO public.users (employee_code, full_name, email, phone, role_id, branch_id) VALUES ('EMP008', 'Vijay', 'vijay@fincollect.com', '9579527355', '10000000-0000-0000-0000-000000000006', (SELECT id FROM public.branches WHERE branch_code = 'BR-008' LIMIT 1)) ON CONFLICT (phone) DO UPDATE SET full_name = EXCLUDED.full_name;
INSERT INTO public.users (employee_code, full_name, email, phone, role_id, branch_id) VALUES ('EMP009', 'Roshan', 'roshan@fincollect.com', '9321048358', '10000000-0000-0000-0000-000000000006', (SELECT id FROM public.branches WHERE branch_code = 'BR-009' LIMIT 1)) ON CONFLICT (phone) DO UPDATE SET full_name = EXCLUDED.full_name;
INSERT INTO public.users (employee_code, full_name, email, phone, role_id, branch_id) VALUES ('EMP010', 'Ketan', 'ketan@fincollect.com', '7385313114', '10000000-0000-0000-0000-000000000006', (SELECT id FROM public.branches WHERE branch_code = 'BR-010' LIMIT 1)) ON CONFLICT (phone) DO UPDATE SET full_name = EXCLUDED.full_name;

-- SEED EXCEL OPEN & PART CASES DATA (668 RECORDS)
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    7, 'Karnataka', 'Bangalore', 'LOA00001853', 'BLQPS8336B', 'ACGLLLOT00000000033', 'NILAMADHAB  SATAPATHY', 9739232220, 'MADHAB.SATAPATHY@GMAIL.COM',
    50000, 45000, 4237, 763, 5000, 762.71, 0, 0, 4237.29,
    30, 1, 65000, '2025-11-01', '2025-12-01', '''07230030102659', 'KOTAK MAHINDRA BANK LIMITED',
    'KKBK0000723', 'MMT/IMPS/530520472606/Disbrusal/NIKAMADHAB/KKBK0000723', 'DISBURSED', 'NEW', 'PIYUSH', 'NAVEEN',
    'C-445, C, BLOCK, KOEL NAGAR, SUNDERGARH, RAURKELA (M), ROURKELA - 14, ODISHA, 769014, INDIA  560017', 'TRANE TECHNOLOGIES IBC KNOWLEDGE PARK TOWER C, BANNERGHATTA BANGALORE -560029 560029', 231, '181+', 'November, 2025', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    24, 'West Bengal', '24 Parganas', 'LOA00001861', 'AKKPM8696B', 'ACGLLLOT00000000013', 'MINTU  MONDAL', 9832918770, 'MINTU.MONDAL19981@GMAIL.COM',
    35000, 31500, 2966, 534, 3500, 533.9, 0, 0, 2966.1,
    29, 1, 45150, '2025-11-02', '2025-12-01', '''0688010090014', 'PUNJAB NATIONAL BANK',
    'PUNB0068820', 'MMT/IMPS/530618040149/DISBURSAL/MINTUMANDA/PUNB0068820', 'DISBURSED', 'NEW', 'PIYUSH', 'NAVEEN',
    'VASUNDHARA ABAS FLAT 4C, RE62/2 RAGHUNATHPUR, NEW TOWN 700059 WEST BENGAL  700059', 'KANTAPAHARI VIVEKANANDA VIDYAPITH HS KANTAPAHARI VIVEKANANDA VIDYAPITH HS KANTAPAHARI  LANDMARK - SIJUA 8 NO G.P. PIN-721121  721121', 231, '181+', 'November, 2025', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    36, 'West Bengal', '24 Parganas', 'LOA00001869', 'BIUPB6071P', 'ACGLLLOT00000000026', 'URMISH  BASU', 8981328726, 'URMISHUB@GMAIL.COM',
    70000, 63000, 5932, 1068, 7000, 1067.8, 0, 0, 5932.2,
    28, 1, 89600, '2025-11-03', '2025-12-01', '''031829849006', 'HSBC BANK',
    'HSBC0700004', 'MMT/IMPS/530716948261/DISBURSAL/MRURMISHBA/HSBC0700004', 'DISBURSED', 'NEW', 'SANYA', 'NAVEEN',
    '164/F SECTOR A, METROPOLITON, DHAPA DHAPA S.O, DHAPA, SOUTH TWENTY FOUR PARGANAS, WEST BENGAL, 700105  700105', 'DOCONLINE HEALTH INDIA PRIVATE LIMITED 6TH FLOOR UNIT NOS 3 AND 4 VAYUDOOTH CHAMBERS 15 AND 16 TRINITY JUNCTION MAHATMA GANDHI RD, BENGALURU - 560001, KARNATAKA,  560001', 231, '181+', 'November, 2025', 'PART-PAYMENT'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    37, 'West Bengal', 'Kolkata', 'ADV00000385', 'AFCPJ4739E', 'ACGLLLOT00000000025', 'VIKASH  JAIN', 9748178552, 'VIKASHJAIN208@GMAIL.COM',
    80000, 72000, 6780, 1220, 8000, 1220.34, 0, 0, 6779.66,
    35, 0.9, 105200, '2025-11-03', '2025-12-08', '''00081050344986', 'HDFC BANK',
    'HDFC0000028', 'MMT/IMPS/530719364403/DISBURSAL/VIKASHJAIN/HDFC0000028', 'DISBURSED', 'NEW', 'SHIVAM SHARMA', 'NAVEEN',
    'C/O SUBARNABOOMI COMPLEX, KADAMBA,FLAT F301, 3RD FLOOR, 36 GORKHABASI ROAD, NAGER BAZAR,KOLKATA,SOUTH DUMDUM {M}, NORTH 24 PARGANAS,WEST BENGAL,700028 NEAR NAGER BAZAR 700028', 'UNISEVEN ENGINEERING& INFRASTRUCTURE PVT. LIMITED "ESCOSPACE" 4TH FLOOR, BLOCK 3A,2F/11,N EW TOWN, RAJARHAT,KOLKATA,700160 ECOSPACE 700160', 224, '181+', 'November, 2025', 'PART-PAYMENT'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    42, 'Karnataka', 'Bangalore', 'ADV00001801', 'CFXPD5058P', 'ACGLLLOT00000000029', 'DAYANANDA S M', 8904040602, 'DAYANANDASM@GMAIL.COM',
    21000, 18900, 1780, 320, 2100, 320.34, 0, 0, 1779.66,
    26, 1, 26460, '2025-11-03', '2025-11-29', '''1238201700000154', 'PUNJAB NATIONAL BANK',
    'PUNB0123820', 'MMT/IMPS/530722670847/DISBURSAL/DAYABABDAS/PUNB0123820', 'DISBURSED', 'NEW', 'ASHISH', 'NAVEEN',
    '301, JAYAPRAKASH NILAYA GS PALYA KONAPPANA AGRAHARA BENGALURU 560100  560100', 'CLYPEUM ARTIFICIAL  TECH PVT LTD 2ND FLOOR , 577 80 FT RD , GANPATI TEMPLE ROAD KORAMAN GALA 8TH BLOCK BANGLORE  560095', 233, '181+', 'November, 2025', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    68, 'Haryana', 'Gurgaon', 'LOA00001883', 'CLPPK1956H', 'ACGLLLOT00000000043', 'PRANAV  KUMAR', 9205933705, 'PRANAVK81@GMAIL.COM',
    20000, 18000, 1695, 305, 2000, 305.08, 0, 0, 1694.92,
    34, 1, 26800, '2025-11-04', '2025-12-08', '''103101538452', 'ICICI BANK LIMITED',
    'ICIC0001146', 'MMT/IMPS/530818613602/BULD61108114/PRANAVKUMA/FDRL0007777', 'DISBURSED', 'NEW', 'ASHISH', 'NAVEEN',
    '879, GROUND FLOOR, SEC 10A, GURGAON, 122001  122001', 'MAIS INDIA MEDICAL DEVICES PVT. LTD 525P, PACE CITY 2 , SECTOR 37, GURGAON, 122001  122001', 224, '181+', 'November, 2025', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    83, 'Tamil Nadu', 'Chennai', 'LOA00001891', 'BKLPB6060M', 'ACGLLLOT00000000051', 'P  BHUVANESWARAN', 7200234815, 'BHUVAN.CSE94@GMAIL.COM',
    30000, 27000, 2542, 458, 3000, 457.63, 0, 0, 2542.37,
    27, 1, 38100, '2025-11-04', '2025-12-01', '''916010021484163', 'AXIS BANK',
    'UTIB0000006', 'MMT/IMPS/530822132311/BULD61118832/PBHUVANESW/UTIB0000006', 'DISBURSED', 'NEW', 'SANYA', 'NAVEEN',
    '4/29 RAMANUJAKUDAM STREET OLD WASHERMENPET CHENNAI 600021  600021', 'CITIUSTECH HEALTHCARE TECHNOLOGY PRIVATE LIMITED CHENNAI ONE IT SEZ, CHENNAI ONE IT SEZ PHASE-1, TOWER 3, MCN NAGAR, THORAIPAKKAM, TAMIL NADU 600097  600094', 231, '181+', 'November, 2025', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    98, 'West Bengal', 'Kolkata', 'LOA00001903', 'AOVPG7608D', 'ACGLLLOT00000000065', 'SUTIRTHA  GAYEN', 9836904441, 'SUTIZINAUSTRALIA@GMAIL.COM',
    40000, 36000, 3390, 610, 4000, 610.17, 0, 0, 3389.83,
    24, 1, 49600, '2025-11-05', '2025-11-29', '''005010100637428', 'AXIS BANK',
    'UTIB0000005', 'MMT/IMPS/530916505782/BULD61150805/SUTIRTHAGA/UTIB0000005', 'DISBURSED', 'NEW', 'ASHISH', 'NAVEEN',
    'FLAT NO 2B, SARAT RESIDENCY, A74 SREENAGAR WEST, GARIA STATION, KOLKATA 700094  700094', 'COGNIZANT TECHNOLOGY SOLUTIONS INDIA PRIVATE LTD CANDOR TECHSPACE, ACTION AREA I, NEWTOWN, CHAKPACHURIA, NEW TOWN, WEST BENGAL 700135  700135', 233, '181+', 'November, 2025', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    101, 'Maharashtra', 'Thane', 'LOA00001909', 'BMLPJ6765R', 'ACGLLLOT00000000071', 'JAIN ARPIT KUMAR BHAGCHAND', 7023539254, 'ARPITJAINJD@GMAIL.CON',
    20000, 18000, 1695, 305, 2000, 305.08, 0, 0, 1694.92,
    19, 1, 23800, '2025-11-05', '2025-11-24', '''158097861121', 'INDUSIND BANK LTD',
    'INDB0001447', 'MMT/IMPS/530919895842/BULD61170708/JAINARPITK/INDB0001447', 'DISBURSED', 'NEW', 'SHIVAM SHARMA', 'NAVEEN',
    'FLT NO - 106 WING B BLDG 1, THRUPATI DARSHAN, STATION ROAD, BHAYANDER (W), THANE, 401101 BHD UNION BANK, 401101', 'NUVO AEON DIAMOND AND JEWELLERY PVT.LTD DC-3111, BHARAT DIAMOND BOURSE, BKC, BANDRA EAST, MUMBAI-400051  400051', 238, '181+', 'November, 2025', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    143, 'Telangana', 'Rangareddy', 'LOA00001920', 'ATSPL9110H', 'ACGLLLOT00000000083', 'LAXMINGARI RAKSHITH GOUD', 8639640763, 'RAKSHITHLAXMINGARI8898@GMAIL.COM',
    20000, 17000, 2542, 458, 3000, 457.63, 0, 0, 2542.37,
    25, 0.75, 23750, '2025-11-06', '2025-12-01', '''50100380085626', 'HDFC BANK',
    'HDFC0004231', 'MMT/IMPS/531017741377/BULD61222548/LAXMINGARI/HDFC0004231', 'DISBURSED', 'NEW', 'GARISHMA', 'SANYA',
    '1-71/A UDDEMARRI UDDEMARRI BUS STOP, RANGAREDDY, TELANGANA-500078  500078', 'COGNIZANT TECHNOLOGY SOLUTIONS INDIA PRIVATE LTD COGNIZANT TECHNOLOGY SOLUTIONS,FLOOR1-8 PHOENIX AVVANCE H4 FACILITY MADHAPUR KONDAPUR,HYDRABAD, TELANAGANA-500081  500081', 231, '181+', 'November, 2025', 'PART-PAYMENT'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    154, 'Maharashtra', 'Pune', 'LOA00001930', 'DYVPK1473B', 'ACGLLLOT00000000097', 'SHAMMI  KUMAR', 8210037671, 'SHAMMI031994@GMAIL.COM',
    20000, 18000, 1695, 305, 2000, 305.08, 0, 0, 1694.92,
    24, 1, 24800, '2025-11-07', '2025-12-01', '''925010032903062', 'AXIS BANK',
    'UTIB0003831', 'INF/NEFT/ICICN42025110755604119/UTIB0003831/61304839     /                              /SHAMM', 'DISBURSED', 'NEW', 'POOJA', 'NAVEEN',
    'A 206, DHANASHREE AASHIYANA UNDRI PUNE 411060 A 206, DHANASHREE AASHIYANA UNDRI PUNE 411060 PUNE 411060', 'ADP PRIVATE LIMITED OFFICE: THE SQUARE CHAMBER, KARGIL VIJAY NAGAR, VADGAO SHERI PUNE 411014  411014', 231, '181+', 'November, 2025', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    186, 'West Bengal', 'Kolkata', 'LOA00001949', 'AQUPC8497R', 'ACGLLLOT00000000121', 'ANIRBAN  CHAKRABORTY', 9830788792, 'ANIRBAN.CHAKRABORTY.10@GMAIL.COM',
    40000, 34000, 5085, 915, 6000, 915.25, 0, 0, 5084.75,
    21, 0.75, 46300, '2025-11-08', '2025-11-29', '''7914106238', 'INDIAN BANK',
    'IDIB000T548', 'INF/NEFT/ICICN42025110856591395/IDIB000T548/61356014     /                              /ANIRB', 'DISBURSED', 'NEW', 'ASHISH', 'NAVEEN',
    'SYMPHONY TOWERS, TOWER-2, FLAT- 5C, 278, HO-CHI MINH SARANI, BEHALA, KOLKATA-700061. LANDMARK - SHAKUNTALA PARK NURSING HOME  700061', 'BTE-SERV(INDIA)PVT.LTD B2, 7TH FLOOR, DLF2, NEW TOWN, RAJARHAT, KOLKATA-700156. LANDMARK- TATA MEDICAL CENTER 700087', 233, '181+', 'November, 2025', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    201, 'Telangana', 'Hyderabad', 'LOA00001958', 'CWJPM9185R', 'ACGLLLOT00000000131', 'MATTAPARTHI  ASHOK', 8790574582, 'ASHOKMATTAPARTHI999@GMAIL.COM',
    18000, 15300, 2288, 412, 2700, 411.86, 0, 0, 2288.14,
    21, 0.75, 20835, '2025-11-08', '2025-11-29', '''044101001926', 'ICICI BANK LIMITED',
    'ICIC0000441', 'INF/NEFT/ICICN42025110856955470/UTIB0000007/61379572     /                              /PRATE', 'DISBURSED', 'NEW', 'ASHISH', 'NAVEEN',
    'P NO 1259&1260 SWAMY AYYAPPA SOCIETY KHANAMET, MADHAPUR, HYDERABAD,500081  500081', 'MOONRAFT INNOVATION LABS PRIVATE LIMITED :9TH FLOOR BLOCKA CAPITAL LAND, MADHAPUR HYDERABAD 500081  500081', 233, '181+', 'November, 2025', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    205, 'Telangana', 'Rangareddy', 'LOA00001961', 'ARFPA6579E', 'ACGLLLOT00000000134', 'ARUMILLI SRI MAREYYA', 6300562640, 'ARUMILLI.MAREYYA@GMAIL.COM',
    35000, 29750, 4449, 801, 5250, 800.85, 0, 0, 4449.15,
    22, 0.75, 40775, '2025-11-08', '2025-11-29', '''50100835202397', 'ALLWN COLONY ROAD',
    'HDFC0007415', 'INF/NEFT/ICICN42025110856955469/HDFC0007415/61379572     /                              /ARUMI', 'DISBURSED', 'NEW', 'SHIVAM SHARMA', 'NAVEEN',
    'LIG 173/8 1ST FLOOR 4TH PHASE KPHB COLONY MAHADEV HOME APPLIANCES HYDERABABD  500072', 'HCL TECHNOLOGIES LTD L2 & L3, BUILDING NO H08, SURVEY NO 30, 34, 35 & 38, L & T PHOENIX INFOPARKS PVT LTD, SERLINGAMPALLY MANDAL  500081', 233, '181+', 'November, 2025', 'PART-PAYMENT'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    220, 'Uttar Pradesh', 'Ghaziabad', 'LOA00001962', 'BVMPS0710F', 'ACGLLLOT00000000139', 'AKASH  SRIVASTAVA', 9289918172, 'AKASH.SRIVASTAVA2403@GMAIL.COM',
    15000, 12750, 1907, 343, 2250, 343.22, 0, 0, 1906.78,
    28, 0.75, 18150, '2025-11-10', '2025-12-08', '''7711634616', 'KOTAK MAHINDRA BANK LIMITED',
    'KKBK0000351', 'INF/NEFT/ICICN42025111058350065/KKBK0000351/61439604     /                              /AKASH', 'DISBURSED', 'NEW', 'SHIVAM SHARMA', 'NAVEEN',
    '1647 CREMA TOWER MAHAGUN MASCOT CROSSING REPUBLIC  201016', 'IENERGIZER PVT LTD A-40 BLOCK A SECTOR 60  201301', 224, '181+', 'November, 2025', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    231, 'Maharashtra', 'Pune', 'LOA00001971', 'KDVPS5785J', 'ACGLLLOT00000000151', 'SHADAB SHAKIL SHAIKH', 8623818254, 'SHADYBOI852@GMAIL.COM',
    20000, 17000, 2542, 458, 3000, 457.63, 0, 0, 2542.37,
    19, 0.75, 22850, '2025-11-10', '2025-11-29', '''50100800082951', 'HDFC BANK LTD',
    'HDFC0009116', 'INF/NEFT/ICICN42025111058622503/HDFC0009116/61460311     /                              /SHADA', 'DISBURSED', 'NEW', 'SHIVAM SHARMA', 'NAVEEN',
    'BUILDING NO 8 FLAT NO 2 RAILWAY POLICE LINE OPP ASHVINI HOSPITAL KRISHNA NAGAR CHINCHWAD  411019', 'BOHIYAANAM TALENT SOLUTIONS LLP CEREBRUM IT PARK B1 KALYAN NAGAR 2ND FLOORÂ OFFICEÂ NOÂ 227  411014', 233, '181+', 'November, 2025', 'PART-PAYMENT'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    232, 'Maharashtra', 'Thane', 'LOA00001969', 'HGOPS7531H', 'ACGLLLOT00000000147', 'BOKKA  SUDHIR', 9892663142, 'SUDHIRBOKK@GMAIL.COM',
    30000, 25500, 3814, 686, 4500, 686.44, 0, 0, 3813.56,
    19, 0.75, 34275, '2025-11-10', '2025-11-29', '''10215286458', 'IDFC BANK LIMITED',
    'IDFB0040112', 'INF/NEFT/ICICN42025111058622321/IDFB0040112/61460311     /                              /BOKKA', 'DISBURSED', 'NEW', 'SHIVAM SHARMA', 'NAVEEN',
    'FLAT NO 903 9TH FLOOR BUILDING NO B BSUP-DPR4 TULSHIDHAM DHARAMVEER NAG THANE VASANT VIHAR  400601', 'DEXIAN INDIA TECHNOLOGIES PRIVATE LIMITED HIRANDANI LIGHHOUSE BESIDE BHARAT PETROLEUM,Â MAROLÂ 400063 NEAR MAROL METRO STATION 400063', 233, '181+', 'November, 2025', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    237, 'Gujarat', 'Surat', 'LOA00001981', 'CORPB8465D', 'ACGLLLOT00000000162', 'BAROT DAKSHKUMAR BIPINKUMAR', 9016086772, 'DAKSHBAROT007@GMAIL.COM',
    15000, 12750, 1907, 343, 2250, 343.22, 0, 0, 1906.78,
    20, 0.75, 17250, '2025-11-11', '2025-12-01', '''4524010030830447', 'JANA SMALL FINANCE BANK LTD',
    'JSFB0004524', 'INF/NEFT/ICICN42025111159616357/JSFB0004524/61532667     /                              /BAROT', 'DISBURSED', 'NEW', 'ASHISH', 'NAVEEN',
    'C2 802 RAMA RESIDENCY BEHIND DE MART JAHAGIRPURA SURAT 395005 395005', 'RAMKRISHNA PURE FINANCE PRIVATE LIMITED PLOT NO 112 SRK HOUSE OPP KIRAN HOSPITAL KATARAGAM SURAT 395009  394111', 231, '181+', 'November, 2025', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    252, 'Tamil Nadu', 'Chennai', 'LOA00001979', 'FTNPS2812F', 'ACGLLLOT00000000160', 'SUDARSHAN', 9344543094, 'SUDARSHAN.NARAS96@GMAIL.COM',
    20000, 18000, 1695, 305, 2000, 305.08, 0, 0, 1694.92,
    25, 1, 25000, '2025-11-11', '2025-12-06', '''111022010001490', 'UNION BANK OF INDIA',
    'UBIN0911101', 'INF/NEFT/ICICN42025111159616333/UBIN0911101/61532667     /                              /SUDAR', 'DISBURSED', 'NEW', 'POOJA', 'NAVEEN',
    '17/11 MUTHU MOHAMMED STREET STREET PUZHUTHIVAKKAM CHENNAI 91  600090', 'VELAMMAL VIDYALAYA - MEL AYANAMBAKKAM OFFICE KRISHNAVENI NAGAR MOGAPPAIR ERI SCHEME  CHENNAI 37  600094', 226, '181+', 'November, 2025', 'PART-PAYMENT'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    260, 'Maharashtra', 'Thane', 'LOA00001978', 'DILPM9594P', 'ACGLLLOT00000000163', 'DIVYANK SUNIL MHATRE', 8433843995, 'MHATREDIVYANK777@GMAIL.COM',
    20000, 17000, 2542, 458, 3000, 457.63, 0, 0, 2542.37,
    20, 0.75, 23000, '2025-11-11', '2025-12-01', '''10198888006', 'IDFC BANK LIMITED',
    'IDFB0040101', 'INF/NEFT/ICICN42025111159615920/IDFB0040101/61532667     /                              /DIVYA', 'DISBURSED', 'NEW', 'GARISHMA', 'NAVEEN',
    'DHARMA NIWAS BUILDING HOUSE NO 301 PLOT NO 238 TURBHE SEC 22, NEAR KEKIZ CAKE SHOP NAVI MUMBAI -400705  400705', 'CAPGEMINI TECHNOLOGY SERVICES INDIA LIMITED SEZ IT3/IT4 AIROLI KNOWLEDGE PARK THANE BELAPUR ROAD NAVI MUMBAI-400708  400708', 231, '181+', 'November, 2025', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    273, 'West Bengal', 'Kolkata', 'LOA00002010', 'AQKPK1329C', 'ACGLLLOT00000000201', 'BISWANATH  KAR', 6290559150, 'BISWANATH.KAR0109@GMAIL.COM',
    30000, 25500, 3814, 686, 4500, 686.44, 0, 0, 3813.56,
    17, 0.75, 33825, '2025-11-12', '2025-11-29', '''404210110009551', 'BANK OF INDIA',
    'BKID0004042', 'INF/NEFT/ICICN42025111250298655/BKID0004042/61579643     /                              /BISWA', 'DISBURSED', 'NEW', 'VISHAL', 'NAVEEN',
    '30C, RAMCHAND MUKHERJEE LANE, KOLKATA-700036  700034', 'MANAGEMENT STAFF SALARY ADVICE OFFICE ADD- 6, CHURCH LANE, BBDBAGH, KOLKATA-700001  700001', 233, '181+', 'November, 2025', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    294, 'Telangana', 'Hyderabad', 'LOA00002003', 'AYUPP7053N', 'ACGLLLOT00000000188', 'MEERAIAH  PAKALA', 9703086085, 'MEER.PAKALA@GMAIL.COM',
    30000, 25500, 3814, 686, 4500, 686.44, 0, 0, 3813.56,
    19, 0.75, 34275, '2025-11-12', '2025-12-01', '''10090821629', 'IDFC BANK LTD',
    'IDFB0080893', 'INF/NEFT/ICICN42025111250202806/IDFB0080893/61570627     /                              /MEERA', 'DISBURSED', 'NEW', 'GARISHMA', 'NAVEEN',
    'H.NO. 1-59/12/13/14/P, SRINIVASA NILAYAM, NEAR SARDAR  VALHABHAI PATEL PARK, PUPPALGUDA, MANIKONDA , IBRAHIM  BAGH, TELANGANA, IND  HYDERABAD HYDERABAD TELANGANA-500089  500089', 'CAPGEMINI TECHNOLOGY SERVICES INDIA LIMITED CAPGEMINI TECHNOLOGY SERVICES INDIA PVT LTD  GAR BUILDING KOKAPET HYDERABAD TELANGANA 500075 CAPGEMINI TECHNOLOGY SERVICES INDIA PVT LTD  GAR BUILDING KOKAPET HYDERABAD TELANGANA 500075  500074', 231, '181+', 'November, 2025', 'PART-PAYMENT'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    350, 'Uttar Pradesh', 'Greater Noida', 'LOA00002023', 'DLCPS7468Q', 'ACGLLLOT00000000217', 'SATHISHKUMAR  BALASUBRAMANIAN', 8778606808, 'SATKMR2512@GMAIL.COM',
    25000, 21250, 3178, 572, 3750, 572.03, 0, 0, 3177.97,
    39, 0.75, 32312.5, '2025-11-13', '2025-12-22', '''924010067070343', 'AXIS BANK',
    'UTIB0005032', 'INF/NEFT/ICICN42025111350868982/UTIB0005032/61625695     /                              /SATHI', 'DISBURSED', 'NEW', 'GARISHMA', 'NAVEEN',
    'FLAT NO. 1705 TOWER-E JM FLORENCE TECHZONE-4 SECTOR 16C GREATER NOIDA WEST ,UTTAR PRADESH,201009  201308', 'RIO TINTO INDIA PRIVATE LIMITED RIO TINTO INDIA PRIVATE LIMITED (BUILDING NO 7, TOWER B, CYBER CITY, GROUND, FIRST AND SECOND FLOOR, DLF CYBER CITY RD DLF PHASE 3, GURUGRAM, HARYANA 122002  122002', 210, '181+', 'November, 2025', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    371, 'Maharashtra', 'Thane', 'LOA00002036', 'BCFPS5261P', 'ACGLLLOT00000000234', 'SMITA  RODRIGUES', 8291141664, 'SMITAMAR76@GMAIL.COM',
    18000, 15300, 2288, 412, 2700, 411.86, 0, 0, 2288.14,
    21, 0.75, 20835, '2025-11-13', '2025-12-04', '''60390836542', 'BANK OF MAHARASHTRA',
    'MAHB0001209', 'INF/NEFT/ICICN42025111351171430/MAHB0001209/61658729     /                              /SMITA', 'DISBURSED', 'NEW', 'ASHISH', 'NAVEEN',
    '301 LAXMI NAGAR BLDG NO 2 A WING CABIN ROAD, NEAR HAVELI BHAYENDER EAST 401105  401105', 'TULSIDAS KHIMJI HOLIDAYS PVT LTD SLAM BLDG 2ND FLOOR 46VEER NARIMAN ROAD FORT MUMBAI 400001.  400001', 228, '181+', 'November, 2025', 'PART-PAYMENT'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    376, 'Maharashtra', 'Pune', 'LOA00001965', 'ADIPC7209C', 'ACGLLLOT00000000236', 'MOHAN MAHADEO CHAVAN', 8451970569, 'MOHAN.MCHAVAN@GMAIL.COM',
    55000, 46750, 6992, 1258, 8250, 1258.47, 0, 0, 6991.53,
    23, 0.75, 64487.5, '2025-11-13', '2025-12-06', '''2266104000011981', 'IDBI BANK LTD',
    'IBKL0002266', 'INF/NEFT/ICICN42025111351171585/IBKL0002266/61658729     /                              /MOHAN', 'DISBURSED', 'NEW', 'PIYUSH', 'NAVEEN',
    '1101, K VILLE, E WING, ADARSH NAGAR, KIWALE, RAVET, NEAR MUKAI CHOWK, PUNE, 412101  412101', 'GUARDIANS REAL ESTATE ADVISORY PVT LTD SR.NUMBER 33, MENLO JOYWOODS  NEAR PVPIT COLLEGE  BAVDHAN PUNE  411021  411021', 226, '181+', 'November, 2025', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    377, 'Gujarat', 'Ahmedabad', 'LOA00002047', 'ADYPV8763G', 'ACGLLLOT00000000248', 'VIVEK  VASANI', 6357175925, 'VIVEKBHAIVIVEK0099@GMAIL.COM',
    20000, 18000, 1695, 305, 2000, 305.08, 0, 0, 1694.92,
    24, 1, 24800, '2025-11-14', '2025-12-08', '''00000020243629089', 'STATE BANK OF INDIA',
    'SBIN0013925', 'INF/NEFT/ICICN42025111451533534/SBIN0013925/61685596     /                              /VIVEK', 'DISBURSED', 'NEW', 'RACHNA BADIWAL', 'NAVEEN',
    'A/9/33 ORCHID GREEN FIELD , APPLE WOOD TOWENSHIP , S P RING ROAD AHMEDABAD , AHMEDABAD - 380015  380052', 'NANDI PANCHGAVYA PRIVATE LIMITED EKKA CLUB MANINAGAR AHMEDABAD FIRST FLOOR 380001  380001', 224, '181+', 'November, 2025', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    414, 'West Bengal', 'Kolkata', 'ADV00000720', 'ALOPM9291J', 'ACGLLLOT00000000262', 'DEBAJYOTI  MUKHERJEE', 8335886665, 'DEBAJYOTI.MUKHERJEE@GMAIL.COM',
    35000, 29750, 4449, 801, 5250, 800.85, 0, 0, 4449.15,
    17, 0.75, 39462.5, '2025-11-14', '2025-12-01', '''50100069491302', 'HDFC BANK',
    'HDFC0000018', 'INF/NEFT/ICICN42025111451812788/HDFC0000018/61717879     /                              /DEBAJ', 'DISBURSED', 'NEW', 'PIYUSH', 'NAVEEN',
    'FLAT 5D, BLOCK A, ANAND VIHAR PHASE 3, 25 NAGENDRA NATH ROAD, KOLKATA 700028, NEAR SATGACHI AUTO STAND 700028', 'ACCENTURE TOWER B3, CANDOR TECHSPACE, BLOCK DH, ACTION AREA 1, NEW TOWN, RAJARHAT, KOLKATA 700156 OPP. TATA MEDICAL 700156', 231, '181+', 'November, 2025', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    430, 'Maharashtra', 'Thane', 'LOA00002045', 'ASPPG5132L', 'ACGLLLOT00000000274', 'SUNIL KHUSHAL GARIA', 8655652472, 'MINSUG1988@GMAIL.COM',
    20000, 17000, 2542, 458, 3000, 457.63, 0, 0, 2542.37,
    27, 0.75, 24050, '2025-11-15', '2025-12-12', '''50092010133769', 'CANARA BANK',
    'CNRB0015009', 'INF/NEFT/IN42531952409466/CNRB0015009/61765081 /                              /SUNILKHUSHA', 'DISBURSED', 'NEW', 'SHIVAM SHARMA', 'NAVEEN',
    'C-27 FLAT -101 KHADAKPADA ROAD, RADHA NAGAR, KALYAN (W)  421301', 'MAHATMA EDUCATION SOCIETY CHEMBUR NAKA OPP FIRE BRIGADE MUMBAI 400071  400071', 220, '181+', 'November, 2025', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    432, 'Tamil Nadu', 'Chennai', 'LOA00002065', 'BPZPS8841C', 'ACGLLLOT00000000279', 'SRINIVASAN  NAGARAJAN', 9884435033, 'SEENUMAIL50@GMAIL.COM',
    35000, 29750, 4449, 801, 5250, 800.85, 0, 0, 4449.15,
    16, 0.75, 39200, '2025-11-15', '2025-12-01', '''56950100005161', 'BANK OF BARODA',
    'BARB0MEDAVA', 'INF/NEFT/IN42531952279915/BARB0MEDAVA/61751707 /                              /SRINIVASANN', 'DISBURSED', 'NEW', 'POOJA', 'NAVEEN',
    'PLOT NO 11, DIVINE BLISS HOMES, F1 FIRST FLOOR, 24TH SOWMYA NAGAR, PERUMBAKKAM, CHENNAI 600100  600100', 'TECH MAHINDRA LTD NO 138 OLD MAHABALIPURAM ROAD SHOLINGANALLUR, ELCOT SEZ, SEMMANCHERI, CHENNAI, TAMIL NADU 600119  600119', 231, '181+', 'November, 2025', 'PART-PAYMENT'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    454, 'Karnataka', 'Bangalore', 'LOA00002079', 'AUTPM8382L', 'ACGLLLOT00000000299', 'SAGAR  MIMANI', 8618684613, 'SAGAR.MIMANI@GMAIL.COM',
    60000, 54000, 5085, 915, 6000, 915.25, 0, 0, 5084.75,
    14, 1, 68400, '2025-11-17', '2025-12-01', '''50100832455440', 'HDFC BANK',
    'HDFC0004051', 'INF/NEFT/IN42532153380890/HDFC0004051/61825620 /                              /SAGARMIMANI', 'DISBURSED', 'NEW', 'RACHNA BADIWAL', 'NAVEEN',
    'S NO 40, FLAT NO 5 , 1ST FLOOR, NIRMALA BLDG , MUNIREDDY  LAYOUT  DODDAKANNELLI , BANGALORE , -  56003  560035', 'PRICEWATERHOUSECOOPERS SERVICE DELIVERY CENTER PRIVATE LIMITED PWC QUAY BUILDING BAGMANE TECH PARK BANGALORE 560093  560093', 231, '181+', 'November, 2025', 'PART-PAYMENT'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    475, 'Maharashtra', 'Mumbai', 'ADV00000904', 'AZPPS9226A', 'ACGLLLOT00000000303', 'ANAND  SUNDARARAMAN', 9920106448, 'ANAND.S.RAMAN@GMAIL.COM',
    30000, 27000, 2542, 458, 3000, 457.63, 0, 0, 2542.37,
    14, 1, 34200, '2025-11-17', '2025-12-01', '''00000042487404008', 'STATE BANK OF INDIA',
    'SBIN0011670', 'INF/NEFT/IN42532153557234/SBIN0011670/61840005 /                              /ANANDSUNDAR', 'DISBURSED', 'NEW', 'SHIVAM SHARMA', 'NAVEEN',
    '8 PLOT NO 108 - 110, CHEMBUR OM SABRI CHS LTD, CHHEDA NAGAR, CHEMBUR NR TEMPLE COMPLEX, CHEMBUR (W), MUMBAI, 400089 CHEMBUR NR TEMPLE COMPLEX, CHEMBUR (W), MUMBAI, 400089 400089', 'DOOTH INTERNET SERVICES PVT LTD RUPA SOLITAIRE, MILLENIUM BUSINESS PARK, MAHAPE, NAVI MUMBAI  400710', 231, '181+', 'November, 2025', 'PART-PAYMENT'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    516, 'Tamil Nadu', 'Coimbatore', 'LOA00002111', 'BUIPR6491P', 'ACGLLLOT00000000343', 'RAJESH  ARUMUGAM', 8012942112, 'RAJU50.PARK@GMAIL.COM',
    40000, 34000, 5085, 915, 6000, 915.25, 0, 0, 5084.75,
    40, 0.75, 52000, '2025-11-19', '2025-12-29', '''829510110000089', 'BANK OF INDIA',
    'BKID0008295', 'INF/NEFT/IN42532354692654/BKID0008295/61946169 /                              /RAJESHARUMU', 'DISBURSED', 'NEW', 'SHIVAM SHARMA', 'NAVEEN',
    'NO.6, SAI SUPRAJ, BALAMURUGAN NAGAR, KONDAIYAMPAALAYAM ROAD, KEERANATHTHAM OPPOSITE TO SENTHUR GARDEN, 641035', 'LTIMINDTREE LIMITED RATHINAM TECHZONE, POLLACHI ROAD, EACHANARI, COIMBATORE-641021  641021', 203, '181+', 'November, 2025', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    563, 'Karnataka', 'Bangalore', 'LOA00002122', 'EJHPS0749N', 'ACGLLLOT00000000363', 'SARAVANA PRAKASH G', 9566772586, 'SARAVANAPRAKASHECE@GMAIL.COM',
    50000, 42500, 6356, 1144, 7500, 1144.07, 0, 0, 6355.93,
    40, 0.75, 65000, '2025-11-21', '2025-12-30', '''916010015396841', 'AXIS BANK',
    'UTIB0000006', 'INF/NEFT/IN42532555637189/UTIB0000006/62026135 /                              /SARAVANAPRA', 'DISBURSED', 'NEW', 'PIYUSH', 'NAVEEN',
    'A2, FIRST FLOOR, CGR RESIDENCY, 9TH CROSS, BANJARA LAYOUT, HORAMAVU-AGARA, BANGALORE KARNATAKA 560043  560043', 'AIRLINQ TECHNOLOGY PRIVATE LIMITED 3RD FLOOR, GOPALAN SIGNATURE MALL OLD MADRAS ROAD BANGALORE KARNATAKA 560093  560093', 202, '181+', 'November, 2025', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    573, 'Maharashtra', 'Pune', 'LOA00002124', 'AZBPK2566R', 'ACGLLLOT00000000369', 'DHARMENDRA  KUMAR', 7683082633, 'CADHARMENDER86@GMAIL.COM',
    40000, 36000, 3390, 610, 4000, 610.17, 0, 0, 3389.83,
    18, 1, 47200, '2025-11-21', '2025-12-09', '''105539035006', 'HSBC BANK',
    'HSBC0411002', 'INF/NEFT/IN42532555575353/HSBC0411002/62019721 /                              /DHARMENDRAK', 'DISBURSED', 'NEW', 'SHIVAM SHARMA', 'NAVEEN',
    'FLAT NO 707 WING A3, AMITS ASTONIA CLASSIC  411060', 'KBC TECHNOLOGIES GLOBAL PRIVATE LIMITED / WIPRO LIMITED PLOT NO.31 MIDC, HINJAWADI PHASE 2 RD, HINJAWADI RAJIV GANDHI INFOTECH PARK, HINJAWADI,  411057', 223, '181+', 'November, 2025', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    579, 'West Bengal', '24 Parganas', 'ADV00001401', 'AJYPG2774N', 'ACGLLLOT00000000374', 'ABHIJEET  GHOSH', 9836019195, 'GHOSH.ABHIJEET84@GMAIL.COM',
    40000, 34000, 5085, 915, 6000, 915.25, 0, 0, 5084.75,
    17, 0.75, 45100, '2025-11-21', '2025-12-08', '''50100514107422', 'HDFC BANK',
    'HDFC0000028', 'INF/NEFT/IN42532555700701/HDFC0000028/62034878 /                              /ABHIJEETGHO', 'DISBURSED', 'NEW', 'SHIVAM SHARMA', 'NAVEEN',
    'FLAT NO. 1A BLOCK - 9 SRIJAM HERITAGE ENCLAVE, ATGHARA 345 RAJARHAT MAIN ROAD, PS BAGUHATI RAJARHAT ROAD, KOLKATA-700136  700136', 'ZINFI SOFTWARE SYSTEMS PVT LTD GN37/1 ASYST PARK 5TH FLOOR  WEBEL MORE, SALT LAKE SECTOR 5 BIDHAN NAGAR KOLKATA 700091  700091', 224, '181+', 'November, 2025', 'PART-PAYMENT'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    589, 'Maharashtra', 'Thane', 'LOA00002129', 'AAIPF0710A', 'ACGLLLOT00000000377', 'VICTOR MICHAEL FRANCIS', 9920181450, 'VICTORMFRANCIS@GMAIL.COM',
    35000, 29750, 4449, 801, 5250, 800.85, 0, 0, 4449.15,
    40, 0.75, 45500, '2025-11-21', '2025-12-31', '''04241140004214', 'HDFC BANK',
    'HDFC0000424', 'INF/NEFT/IN42532555758498/HDFC0000424/62041582 /                              /VICTORMICHA', 'DISBURSED', 'NEW', 'PIYUSH', 'NAVEEN',
    'FLAT NO 004 3RD FLOOR NEW BLDG GOGRASWADI DOMBIVALLI EAST KALYAN  421201', 'THE TATA POWER COMPANY LIMITED BORIVALI RECEIVING STATION JAY MAHARASHTRA NAGAR BORIVALI EAST  400066', 201, '181+', 'November, 2025', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    607, 'Telangana', 'Hyderabad', 'LOA00002144', 'AXSPB8709J', 'ACGLLLOT00000000395', 'MAHENDER  BODDU', 9703143289, 'MAHENDER7055@GMAIL.COM',
    50000, 42500, 6356, 1144, 7500, 1144.07, 0, 0, 6355.93,
    34, 0.75, 62750, '2025-11-22', '2025-12-26', '''911010022838410', 'AXIS BANK',
    'UTIB0002960', 'INF/NEFT/IN42532656382490/UTIB0002960/62091272 /                              /MAHENDERBOD', 'DISBURSED', 'NEW', 'PIYUSH', 'NAVEEN',
    'HOME ADDRESS FLAT 511 , SAI AHLAADAM, NIZAMPET HYDERABAD 500090  500090', 'WELLS FARGO INTERNATIONAL SOLUTIONS PRIVATE LIMITED OFFICE ADDRESS TRIMONT 8TH FLOOR , PHOENIX EQUINOX HI TECH CITY HYDERABAD 500032  500033', 206, '181+', 'November, 2025', 'PART-PAYMENT'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    608, 'Karnataka', 'Bangalore', 'LOA00002136', 'JLKPS5161Q', 'ACGLLLOT00000000386', 'YASH KUMAR SINGHAL', 8077843470, 'YASH.SINGHAL249@GMAIL.COM',
    45000, 38250, 5720, 1030, 6750, 1029.66, 0, 0, 5720.34,
    33, 0.75, 56137.5, '2025-11-22', '2025-12-25', '''50100397212142', 'HDFC BANK',
    'HDFC0004075', 'INF/NEFT/IN42532656383388/HDFC0004075/62091272 /                              /YASHKUMARSI', 'DISBURSED', 'NEW', 'PIYUSH', 'NAVEEN',
    'NO 29 SRINIDHI BUILDING 2ND FLOUR FLAT NO 206 3RD MAIN 1ST CROSS ANNAYAPPA LAYOUTKONENAGRAHARA MURGESHPALYA 560017 KONENAGRAHARA MURGESHPALYA 560017  560017', 'CISCO SYSTEMS(IND)PVT LTD CISCO, CESSNA BUSINESS PARK, KADUBEESANASHALLI, BANGALORE, 560103 CISCO, CESSNA BUSINESS PARK, KADUBEESANASHALLI, BANGALORE, 560103  560103', 207, '181+', 'November, 2025', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    619, 'West Bengal', 'Kolkata', 'LOA00002147', 'AOBPM2049G', 'ACGLLLOT00000000398', 'SUDEEP  MISHRA', 9163242720, 'SUDIPMISHRA786@GMAIL.COM',
    40000, 34000, 5085, 915, 6000, 915.25, 0, 0, 5084.75,
    36, 0.75, 50800, '2025-11-24', '2025-12-30', '''10144336432', 'IDFC FIRST BANK LTD',
    'IDFB0060115', 'INF/NEFT/IN42532857190606/IDFB0060115/62124902 /                              /SUDEEPMISHR', 'DISBURSED', 'NEW', 'PIYUSH', 'NAVEEN',
    'FLAT NO 407INDRALOK APARTMENT,187 NSC B OSE ROAD PIN CODE : 700040  700040', 'IIFL HOME FINANCE LIMITED 145 BT ROAD KFC BUILDING 4TH FLOOR KOLKATA 700108  700108', 202, '181+', 'November, 2025', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    643, 'Karnataka', 'Bangalore', 'LOA00002159', 'FVRPS7865C', 'ACGLLLOT00000000412', 'SANDEEP  K S', 9620014987, 'SANDYKANDHURI007@GMAIL.COM',
    40000, 34000, 5085, 915, 6000, 915.25, 0, 0, 5084.75,
    38, 0.75, 51400, '2025-11-24', '2026-01-01', '''8926010000036643', 'DBS BANK LTD',
    'DBSS0IN0926', 'INF/NEFT/IN42532857534958/DBSS0IN0926/62162183 /                              /SANDEEPKS', 'DISBURSED', 'NEW', 'POOJA', 'NAVEEN',
    '223, 8TH MAIN, SRINIVASANAGAR, BSK 1S STAGE, B-NGALORE 560050,  560050', 'TECH MAHINDRA ELECTRONIC CITY, BENGALURU, KARNATAKA  560100', 200, '181+', 'November, 2025', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    620, 'Karnataka', 'Bangalore', 'LOA00002160', 'GARPS0250R', 'ACGLLLOT00000000414', 'S  LIKITH', 9886781889, 'LIKITH.INDIA@GMAIL.COM',
    15000, 12750, 1907, 343, 2250, 343.22, 0, 0, 1906.78,
    39, 0.75, 19387.5, '2025-11-25', '2026-01-03', '''00000020237073561', 'STATE BANK OF INDIA',
    'SBIN0016875', 'INF/NEFT/IN42532957746723/SBIN0016875/62176462 /                              /SLIKITH', 'DISBURSED', 'NEW', 'GARISHMA', 'NAVEEN',
    '352, R K NILAYA 1ST FLOOR, 1ST CROSS ROAD, CHIKKA BANASWADI MAIN ROAD, OPP M E S SUBBAIAHNA, PALYA EXTENSION BANGLORE KARNATAKA- 560033  560033', 'MATRIX BUSINESS SERVICES INDIA PRIVATE LIMITED FIRST FLOOR, SALARPURIA SATTVA GALLERIA, 20/1, KASHI NAGAR, BYATARAYANAPURA, (ABOVE SIMPLI NAMDHARI), BELLARY ROAD, BENGALURU 560092 FIRST FLOOR, SALARPURIA SATTVA GALLERIA, 20/1, KASHI NAGAR, BYATARAYANAPURA, (ABOVE SIMPLI NAMDHARI), BELLARY ROAD, BENGALURU 560092  560092', 198, '181+', 'November, 2025', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    649, 'Maharashtra', 'Thane', 'LOA00002162', 'ANEPD2920R', 'ACGLLLOT00000000417', 'VIKASH GAJANAND DADHICH', 9987312511, 'VSLOVE1218@GMAIL.COM',
    45000, 38250, 5720, 1030, 6750, 1029.66, 0, 0, 5720.34,
    36, 0.75, 57150, '2025-11-25', '2025-12-31', '''32384571934', 'STATE BANK OF INDIA',
    'SBIN0011755', 'INF/NEFT/IN42532957845174/SBIN0011755/62188166 /                              /VIKASHGAJAN', 'DISBURSED', 'NEW', 'SHIVAM SHARMA', 'NAVEEN',
    'FLT NO - H/302, URJA CHS LTD, VIJAY PARK, GAURAV GALAXY PHASE -1 NEAR SARSHTI, MIRA ROAD (E), MUMBAI, 401107  401107', 'RIVIPAC POLYMERS PVT LTD 321 3 FLOOR CREATIVE INDUSTRIAL ESTATE NM JOSHI MARG LOWERÂ PAREL  400011', 201, '181+', 'November, 2025', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    690, 'Telangana', 'Hyderabad', 'LOA00002175', 'ANOPK1089L', 'ACGLLLOT00000000439', 'KAKARLA  MURALIDHAR', 9398615969, 'KMKPKG@GMAIL.COM',
    35000, 29750, 4449, 801, 5250, 800.85, 0, 0, 4449.15,
    13, 0.75, 38412.5, '2025-11-26', '2025-12-09', '''119678100004310', 'YES BANK',
    'YESB0001196', 'INF/NEFT/IN42533058472079/YESB0001196/62242590 /                              /KAKARLAMURA', 'DISBURSED', 'NEW', 'POOJA', 'NAVEEN',
    'FLAT NO 4-119/1/6B BLOCK NO 1 JANAPRIYA TOWNSHIP MALLAPUR HYDERABAD 500076 TOWNSHIP MALLAPUR HYDERABAD 500076  500076', 'SAPTAGIR GROUP VAISNAVI''S CYNOSURE 5TH FLOOR, 5 (E&F) UNITS SURVEY NO 18, TELECOM NAGAR GACHIBOWLI HYDERABAD - 500032  500033', 223, '181+', 'November, 2025', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    691, 'Delhi', 'New Delhi', 'ADV00001702', 'BDXPA6254K', 'ACGLLLOT00000000444', 'QUINSY  ARORA', 9599047893, 'PHYSIOQUINSYARORA@GMAIL.COM',
    25000, 21250, 3178, 572, 3750, 0, 286.02, 286.02, 3177.97,
    29, 0.75, 30437.5, '2025-11-26', '2025-12-25', '''919010030371161', 'AXIS BANK',
    'UTIB0004037', 'INF/NEFT/IN42533058562290/UTIB0004037/62252715 /                              /QUINSYARORA', 'DISBURSED', 'NEW', 'PIYUSH', 'NAVEEN',
    'FLAT NO 93 2ND FLOOR BLK-A PKT-1 SEC-17 ROHINI CITY DELHI 110085 LANDMARK NEAR MOTHER DAIRY  110089', 'BARCLAYS GLOBAL SERVICE CENTRE PRIVATE LIMITED UNITECH INFOSPACE PLOT B2 NOIDA SECTOR 62, 201307 UNITECH INFOSPACE PLOT B2 NOIDA SECTOR 62, 201307 UNITECH INFOSPACE PLOT B2 NOIDA SECTOR 62, 201307 201307', 207, '181+', 'November, 2025', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    701, 'Maharashtra', 'Pune', 'LOA00002180', 'ALVPA5894J', 'ACGLLLOT00000000448', 'PARVEEN MUKHTAR AHMED', 9067672948, 'JPARVEEN1176@GMAIL.COM',
    25000, 21250, 3178, 572, 3750, 572.03, 0, 0, 3177.97,
    35, 0.75, 31562.5, '2025-11-26', '2025-12-31', '''007401550736', 'ICICI BANK LIMITED',
    'ICIC0000074', 'INF/INFT/042438618841/62254948     /PARVEENMUKHTARAHMED /', 'DISBURSED', 'NEW', 'GARISHMA', 'NAVEEN',
    'FLAT NO 401 A2 WING,UNDRI, PUNE,NEAR,VTP URBAN  NEST,,PUNE,MAHARASHTRA- 411060 PUNE FLAT NO 401 A2 WING,UNDRI, PUNE,NEAR,VTP URBAN  NEST,,PUNE,MAHARASHTRA-411060 PUNE  411060', 'TATA CONSULTANCY SERVICES QUADRA II, TATA CONSULTANCY SERVICES,  OPP MAGARPATTA MAIN GATE,  NEXT TO KALYAN JEWELLERS,  KESHAV NAGAR, HADAPSAR,  PUNE 411058 QUADRA II, TATA CONSULTANCY SERVICES,  OPP MAGARPATTA MAIN GATE,  NEXT TO KALYAN JEWELLERS,  KESHAV NAGAR, HADAPSAR,  PUNE 411058  411058', 201, '181+', 'November, 2025', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    732, 'Telangana', 'Hyderabad', 'LOA00002188', 'AQQPN9014P', 'ACGLLLOT00000000460', 'NIDAMANURI  RAGHUVEER', 9885863189, 'RAGHUVEERCHOWDHARY79@GMAIL.COM',
    30000, 25500, 3814, 686, 4500, 686.44, 0, 0, 3813.56,
    36, 0.75, 38100, '2025-11-26', '2026-01-01', '''10203967767', 'IDFC BANK',
    'IDFB0080222', 'INF/NEFT/IN42533058736560/IDFB0080222/62268459 /                              /NIDAMANURIR', 'DISBURSED', 'NEW', 'SHIVAM SHARMA', 'NAVEEN',
    'FLAT NO 502, SHALOM VILLA, STREET NUMBER 6, SHANTI NAGAR, UPPAL  500039', 'CBRE SOUTH ASIA PRIVATE LIMITED CBRE, GATE NO. 7, TOWER-A, SATTVA KNOWLEDGE PARK, SILPA GRAM CRAFT VILLAGE, RAI DURG,  500081', 200, '181+', 'November, 2025', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    692, 'Tamil Nadu', 'Kanchipuram', 'LOA00002190', 'AYXPC6139R', 'ACGLLLOT00000000463', 'JAYAKUMAR  CHOCKALINGAM', 9597349224, 'JAYAKUMARCHOCKALINGAM1708@GMAIL.COM',
    40000, 34000, 5085, 915, 6000, 915.25, 0, 0, 5084.75,
    33, 0.75, 49900, '2025-11-28', '2025-12-31', '''923010044923214', 'AXIS BANK',
    'UTIB0000676', 'INF/NEFT/IN42533259532833/UTIB0000676/62340139 /                              /JAYAKUMARCH', 'DISBURSED', 'NEW', 'SHIVAM SHARMA', 'NAVEEN',
    'PLAT 497B FLAT F2 GROUND FLOOR 4TH CROSS,RAJAJI NAGAR, MEENATCHI SUNDARESW ARAR KOIL, SADASIVA NAGAR,,SATHSIVAM NAGAR,497, 4TH CROSS STREET  600091', 'DATAMATICS GLOBAL SERVICES LIMITED KALYANI NEPTUNE KRISHNARAJ LAYOUT BANNERGHATTA ROAD, BANGALORE-560076  600034', 201, '181+', 'November, 2025', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    775, 'Karnataka', 'Bangalore', 'LOA00002210', 'BGTPA5131J', 'ACGLLLOT00000000489', 'AKSHARATHA', 6362688162, 'PAPUASHU143@GMAIL.COM',
    30000, 25500, 3814, 686, 4500, 686.44, 0, 0, 3813.56,
    33, 0.75, 37425, '2025-11-28', '2025-12-31', '''50100799578272', 'HDFC BANK',
    'HDFC0004000', 'INF/NEFT/IN42533259796054/HDFC0004000/62370947 /                              /AKSHARATHA', 'DISBURSED', 'NEW', 'SHIVAM SHARMA', 'NAVEEN',
    'NO.28, 1ST MAIN, J.C.NAGAR, KURUBARAHALLI, MAHALAKSHMIPURAM  560086', 'SAPIENS TECHNOLOGIES (1982) INDIA PRIVATE LIMITED 7TH AND 8TH FLOOR, BUILDING 11, SEZ - CESSNA BUSINESS PARK KADUBEESANAHALLI VILLAGE, VARTHUR HOBLI, OUTER RINGROAD  560103', 201, '181+', 'November, 2025', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    787, 'Haryana', 'Gurgaon', 'LOA00002217', 'BAHPP4568E', 'ACGLLLOT00000000504', 'ADITYA  PUTHRAN', 9953556556, 'ADITYAPUTHRAN@GMAIL.COM',
    70000, 59500, 8898, 1602, 10500, 1601.69, 0, 0, 8898.31,
    31, 0.75, 86275, '2025-11-28', '2025-12-29', '''925010039299012', 'AXIS BANK',
    'UTIB0002456', 'INF/NEFT/IN42533259795129/UTIB0002456/62370947 /                              /ADITYAPUTHR', 'DISBURSED', 'NEW', 'GARISHMA', 'NAVEEN',
    'H-1201, WEMBLEY ESTATE ROSEWOOD CITY  SOUTH CITY -II  HARYANA-122018 H-1201, WEMBLEY ESTATE ROSEWOOD CITY  SOUTH CITY -II  HARYANA-122018  122018', 'JUKIN MEDIA (INDIA) PRIVATE LIMITED JUKIN MEDIA INDIA PVT LTD (TMB), 7TH FLOOR, TOWER C, DLF INFINITY TOWERS, CYBER CITY, DLF PHASE 2, SECTOR 24,  GURUGRAM, HARYANA â€“ 122001. JUKIN MEDIA INDIA PVT LTD (TMB), 7TH FLOOR, TOWER C, DLF INFINITY TOWERS, CYBER CITY, DLF PHASE 2, SECTOR 24,  GURUGRAM, HARYANA â€“ 122001.  122001', 203, '181+', 'November, 2025', 'PART-PAYMENT'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    792, 'Tamil Nadu', 'Chennai', 'LOA00002213', 'DDDPM4921B', 'ACGLLLOT00000000497', 'MUTHUMARI  N', 9994335383, 'MUTHUMARIN16@GMAIL.COM',
    22000, 18700, 2797, 503, 3300, 503.39, 0, 0, 2796.61,
    34, 0.75, 27610, '2025-11-28', '2026-01-01', '''309026500142', 'RATNAKAR BANK LIMITED',
    'RATN0000113', 'INF/NEFT/IN42533259795979/RATN0000113/62370947 /                              /MUTHUMARIN', 'DISBURSED', 'NEW', 'POOJA', 'NAVEEN',
    'O-26 NEW-71, 3RD FLOOR OLD WASHERMENTPET PERAMBALU CHETTY STREET WASHERMENPET CHENNAI - 600021  600021', 'RBL BANK LTD TULASI TOWER 2ND FLOOR,NEW NO 79,OLD NO 40,GN CHETTY STREET,T NAGAR CHENNAI 600017  600017', 200, '181+', 'November, 2025', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    858, 'Maharashtra', 'Pune', 'LOA00001913', 'ASIPP2736N', 'ACGLLLOT00000000532', 'KHAGESH  PURANI', 9624219844, 'KHAGESH.PURANI@GMAIL.COM',
    27000, 22950, 3432, 618, 4050, 617.8, 0, 0, 3432.2,
    32, 0.85, 34344, '2025-11-29', '2025-12-31', '''000301552286', 'ICICI BANK LIMITED',
    'ICIC0000003', 'INF/INFT/042471131051/62407738     /KHAGESHPURANI/', 'DISBURSED', 'REPEAT', 'ASHISH', NULL,
    'B 104 DISHA SKYLINE VIMAN NAGAR PUNE 411014  411014', 'DIGITAL GROUP INFOTECH PVT LTD PYRAMID COMPLEX   PLOT NO 5 RAJIV GANDHI INFOTECH PARK NEAR HCL HINJEWADI PHASE 1 PUNE 41105  411044', 201, '181+', 'November, 2025', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    865, 'Tamil Nadu', 'Chennai', 'LOA00001904', 'AALPE3590L', 'ACGLLLOT00000000534', 'EDWIN MAHESH Y R', 9080062144, 'EDWIN2317@GMAIL.COM',
    40000, 36000, 3390, 610, 4000, 610.17, 0, 0, 3389.83,
    30, 1, 52000, '2025-11-29', '2025-12-29', '''50100416491812', 'HDFC BANK',
    'HDFC0002094', 'INF/NEFT/IN42533350286378/HDFC0002094/62407738 /                              /EDWINMAHESH', 'DISBURSED', 'REPEAT', 'SHIVAM SHARMA', 'NAVEEN',
    '4051, OSIAN CHLOROPHYLL APARTMENTS DEVIPARASHAKTHI NAGAR PORUR LINK ROAD, PORUR 600116  600006', 'JM FINANCIAL SERVICES LIMITED SEETHAKATHI BUSINESS CENTRE 2ND FLOOR UNIT NO 211& 212 , 684-690 ANNA SALAI MOUNT ROAD 600006  600006', 203, '181+', 'November, 2025', 'PART-PAYMENT'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    871, 'Tamil Nadu', 'Chennai', 'LOA00002104', 'AHVPJ6622R', 'ACGLLLOT00000000538', 'J  JAGADISH', 9840184701, 'JAGADISHJTECH@GMAIL.COM',
    51000, 43350, 6483, 1167, 7650, 1166.95, 0, 0, 6483.05,
    33, 0.75, 63622.5, '2025-11-29', '2026-01-01', '''18691610041292', 'HDFC BANK',
    'HDFC0001869', 'INF/NEFT/IN42533350336977/HDFC0001869/62412718 /                              /JJAGADISH', 'DISBURSED', 'REPEAT', 'GARISHMA', 'NAVEEN',
    'NO.A-4 PLOT NO.20, VENKATA VILLA, VENKATESHWARA NAGAR, 4TH STREET, KISHKINTA ROAD, WEST TAMBARAM CHENNAI - 600 045 NO.A-4 PLOT NO.20, VENKATA VILLA, VENKATESHWARA NAGAR, 4TH STREET, KISHKINTA ROAD, WEST TAMBARAM CHENNAI - 600 045  600045', 'INTELLIGENZ IT PVT. LTD. SDB2, CTS BUILDING, MEPZ, TAMBARAM, CHENNAI 600045 SDB2, CTS BUILDING, MEPZ, TAMBARAM, CHENNAI 600045  600042', 200, '181+', 'November, 2025', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    887, 'Karnataka', 'Bangalore', 'LOA00002006', 'AQRPR7681R', 'ACGLLLOT00000000552', 'RAJESH  NARASIMHA', 9177397238, 'RAAJYESHK@GMAIL.COM',
    50000, 42500, 6356, 1144, 7500, 1144.07, 0, 0, 6355.93,
    30, 0.75, 61250, '2025-11-29', '2025-12-29', '''10128097129', 'IDFC BANK LTD',
    'IDFB0080189', 'INF/NEFT/IN42533350508659/IDFB0080189/62428214 /                              /RAJESHNARAS', 'DISBURSED', 'REPEAT', 'SHIVAM SHARMA', 'NAVEEN',
    'NO 204 , VISHALAKSHI MAHAL , VIVEKANANDA NAGAR, KATRIGUPPE  560085', 'MERCK SPECIALITIES PRIVATE LIMITED GODREJ ONE, 8TH FLOOR PIROJSHANAGAR, EASTERN EXPRESS HIGHWAY, VIKHROLI (EAST), MUMBAI - 400079  400079', 203, '181+', 'November, 2025', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    903, 'Delhi', 'New Delhi', 'LOA00001946', 'AOWPC7657K', 'ACGLLLOT00000000562', 'VIKAS  CHHABRA', 9910299870, 'VIKASCHHABRA11@GMAIL.COM',
    19000, 17100, 1610, 290, 1900, 0, 144.92, 144.92, 1610.17,
    32, 1, 25080, '2025-11-29', '2025-12-31', '''3612134309', 'KOTAK MAHINDRA BANK LIMITED',
    'KKBK0000177', 'INF/NEFT/IN42533350588548/KKBK0000177/62432761 /                              /VIKASCHHABR', 'DISBURSED', 'REPEAT', 'SHIVAM SHARMA', 'NAVEEN',
    'CHAMANLAL CHAMAN LAL PL NO-74&75 BLK K-2 MOHAN GARDEN UTTAM NAGAR  110059', 'TELEPERFORMANCE GLOBAL BUSINESS PRIVATE LIMITED PLOT NO 398 PHASE 3 UDHYOG VIHAR SECTOR 19  122016', 201, '181+', 'November, 2025', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    912, 'Tamil Nadu', 'Chennai', 'LOA00002067', 'AWIPM4801H', 'ACGLLLOT00000000569', 'MOHANRAM  CHIRANJEEVI', 9840103640, 'CMR2006@GMAIL.COM',
    22000, 18700, 2797, 503, 3300, 503.39, 0, 0, 2796.61,
    31, 0.85, 27797, '2025-11-30', '2025-12-31', '''42811099039', 'STANDARD CHARTERED BANK',
    'SCBL0036080', 'INF/NEFT/IN42533450893034/SCBL0036080/62440384 /                              /MOHANRAMCHI', 'DISBURSED', 'REPEAT', 'GARISHMA', 'NAVEEN',
    'FLAT NO 28 3RS CROSS STREET SEETHA LAXMI VENGAIVE SAL STREET  SEETHA LAXMI VENGAIVESAL  CHENNAI 600126  TAMIL NADU FLAT NO 28 3RS CROSS STREET SEETHA LAXMI VENGAIVE SAL STREET  SEETHA LAXMI VENGAIVESAL  CHENNAI 600126  TAMIL NADU  600126', 'HCL TECHNOLOGIES LTD HCL TECHNOLOGIES PVT LTD ELCOT-SIPCOT,SDB2 5TH FLOOR SHOLINGANALLUR-600119  600018', 201, '181+', 'November, 2025', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    930, 'Karnataka', 'Bangalore', 'LOA00001857', 'BSQPK7568C', 'ACGLLLOT00000000578', 'KEERTHIPATI  VENKATAIAH', 9703708086, 'KEERTHIPATI1987@GMAIL.COM',
    31000, 26350, 3941, 709, 4650, 709.32, 0, 0, 3940.68,
    30, 0.85, 38905, '2025-12-01', '2025-12-31', '''45210115727', 'STANDARD CHARTERED BANK',
    'SCBL0036106', 'INF/NEFT/IN42533551318213/SCBL0036106/62462612 /                              /KEERTHIPATI', 'DISBURSED', 'REPEAT', 'GARISHMA', 'NAVEEN',
    'NO 8 4TH CROSS NR SRI RADHA ,  KRISHNA TEMPLE , SRIRAMAPURA  BENGALURU BANGALORE , -  560077  560064', 'KYNDRYL SOLUTIONS PRIVATE LIMITED TECH PARK M3 BUILDING  14TH FLOOR THANISANDRA- 560045  560045', 201, '181+', 'December, 2025', 'PART-PAYMENT'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    937, 'Telangana', 'Hyderabad', 'LOA00001912', 'AOTPG5342Q', 'ACGLLLOT00000000583', 'GUDHE MOHAN KRISHNA', 9281444561, 'MOHAN.G.4U@GMAIL.COM',
    26000, 22100, 3305, 595, 3900, 594.92, 0, 0, 3305.08,
    30, 0.85, 32630, '2025-12-01', '2025-12-31', '''569701501708', 'ICICI BANK LTD',
    'ICIC0005697', 'INF/INFT/042486500101/62462612     /GUDHEMOHANKRISHNA   /', 'DISBURSED', 'REPEAT', 'GARISHMA', 'NAVEEN',
    '11-1-402TO408  CHILKALGUDA  MYLARGADDA  SECUNDERABAD TELANGANA HYDRABAD-500061  500061', 'OUTREACH INDIA PRIVATE LIMITED OUT REACH FIRST FLOOR, WE WORK KRISHE EMARALD, GACHIBOWLI HYDERABAD,500082  500082', 201, '181+', 'December, 2025', 'PART-PAYMENT'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    970, 'Karnataka', 'Bangalore', 'LOA00002123', 'ECOPS3204Q', 'ACGLLLOT00000000617', 'SURESH  S', 9606559639, 'S.SURESH721@GMAIL.COM',
    50000, 42500, 6356, 1144, 7500, 1144.07, 0, 0, 6355.93,
    31, 0.85, 63175, '2025-12-02', '2026-01-02', '''923010068114799', 'AXIS BANK',
    'UTIB0003266', 'INF/NEFT/IN42533652141046/UTIB0003266/62535718 /                              /SURESHS', 'DISBURSED', 'REPEAT', 'GARISHMA', 'NAVEEN',
    'NO.48, GROUND FLOOR, 7TH CROSS, AVANISRINGERINAGAR NYANAPANAHALLI BANGALORE 560076 NO.48, GROUND FLOOR, 7TH CROSS, AVANISRINGERINAGAR NYANAPANAHALLI BANGALORE 560076  560076', 'BDO INDIA LLP PRESTIGE NEBULA, 3RD FLOOR, NATIONAL INFORMATICS CENTRE, 143, INFANTRY RD, SHIVAJI NAGAR, BENGALURU, KARNATAKA 560001 PRESTIGE NEBULA, 3RD FLOOR, NATIONAL INFORMATICS CENTRE, 143, INFANTRY RD, SHIVAJI NAGAR, BENGALURU, KARNATAKA 560001  560001', 199, '181+', 'December, 2025', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    1015, 'Maharashtra', 'Pune', 'LOA00002101', 'CMBPS1664R', 'ACGLLLOT00000000634', 'SRINJAY  SARMA', 9987553160, 'SRINJAYSARMA@GMAIL.COM',
    21000, 17850, 2669, 481, 3150, 480.51, 0, 0, 2669.49,
    30, 0.85, 26355, '2025-12-03', '2026-01-02', '''157101000002793', 'INDIAN OVERSEAS BANK',
    'IOBA0001571', 'INF/NEFT/IN42533753030778/IOBA0001571/62614500 /                              /SRINJAYSARM', 'DISBURSED', 'REPEAT', 'GARISHMA', 'NAVEEN',
    '605, C BLOCK, SICILIAA APARTMENTS, B T KAWADE ROAD, GHORPADI, PUNE, MAHARASHTRA - 411001 LANDMARK: NEAR CHITALE BANDHU) 411001 : 605, C BLOCK, SICILIAA APARTMENTS, B T KAWADE ROAD, GHORPADI, PUNE, MAHARASHTRA - 411001 LANDMARK: NEAR CHITALE BANDHU) 411001  411001', 'B G SHIRKE CONSTRUCTION TECH PVT LTD SHIRKE GROUP, 72-76, MUNDHWA INDUSTRIAL AREA SHIRKE ROAD, PUNE, MAHARASHTRA - 411036. (LANDMARK: NEAR BHARAT FORGE) 411036 SHIRKE GROUP, 72-76, MUNDHWA INDUSTRIAL AREA SHIRKE ROAD, PUNE, MAHARASHTRA - 411036. (LANDMARK: NEAR BHARAT FORGE) 411036  411036', 199, '181+', 'December, 2025', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    976, 'Maharashtra', 'Thane', 'LOA00001878', 'AGJPT6602N', 'ACGLLLOT00000000636', 'NITIN N. THUKRUL', 9702230007, 'NITIN.T143@GMAIL.COM',
    19000, 16150, 2415, 435, 2850, 434.75, 0, 0, 2415.25,
    29, 0.75, 23132.5, '2025-12-04', '2026-01-01', '''2912113144', 'KOTAK MAHINDRA BANK LIMITED',
    'KKBK0001370', 'INF/NEFT/IN42533853448082/KKBK0001370/62642243 /                              /NITINNTHUKR', 'DISBURSED', 'REPEAT', 'SHIVAM SHARMA', 'NAVEEN',
    'RITU PLAZA, A WING 704, DESALE PADA, BHOPAR ROAD, NEAR NEW SUNRISE ENGLISH HIGH SCHOOL, DOMBIVLI EAST 421201 OFFICE ADD: OLYMPUS A HIRANANDANI ESTATE, PATLIPADA, GHODBUNDER ROAD, THANE WEST 400607  421201', 'OLYMPUS : OLYMPUS A HIRANANDANI ESTATE, PATLIPADA, GHODBUNDER ROAD, THANE WEST 400607  400607', 200, '181+', 'December, 2025', 'PART-PAYMENT'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    1005, 'Karnataka', 'Bangalore', 'LOA00002239', 'AHSPA5682P', 'ACGLLLOT00000000633', 'ASHWIN MYLANAIKANAHALLI BALAKRISHNA', 9945966676, 'ASHWIN.BALAKRISHNA@GMAIL.COM',
    40000, 34000, 5085, 915, 6000, 915.25, 0, 0, 5084.75,
    26, 0.75, 47800, '2025-12-04', '2025-12-30', '''625301518371', 'ICICI BANK LIMITED',
    'ICIC0002317', 'INF/INFT/042526217611/62644104     /ASHWINMYLANAIKANAHAL/', 'DISBURSED', 'NEW', 'GARISHMA', 'NAVEEN',
    'NO 476,SAPTAGIRI  VINAYAKA LAYOUT 4TH STAGE NAGARABHAVI  10TH CROSS  3RD A MAIN ROAD OPP HANUMAGIRI PARK BANGLORE KARNATAKA- 560072  560072', 'CGI INFORMATION SYSTEMS AND MANAGEMENT CONSULTANTS PRIVATE LIMITED CGI INFORMATION SYSTEMS AND MANAGEMENT CONSULTANTS PRIVATE LIMITED NO.95/1 & 95/2, ELECTRONIC CITY PHASE I (WEST), BANGALORE-560100.  560100', 202, '181+', 'December, 2025', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    1148, 'Maharashtra', 'Mumbai', 'ADV00001574', 'COWPK0271B', 'ACGLLLOT00000000665', 'ANIKET MANOHAR KANSE', 9167488834, 'ANIKETKANSE786@GMAIL.COM',
    25000, 21250, 3178, 572, 3750, 572.03, 0, 0, 3177.97,
    27, 0.75, 30062.5, '2025-12-06', '2026-01-02', '''8547307798', 'KOTAK MAHINDRA BANK',
    'KKBK0001415', 'INF/NEFT/IN42534055731200/KKBK0001415/62818438 /                              /ANIKETMANOH', 'DISBURSED', 'REPEAT', 'ASHISH', 'NAVEEN',
    'A2/20, MALAD HIGHWAY VIEW CHS, OPP. KURAR POLICE STATION, KURAR VILLAGE, MALAD EAST, MUMBAI- 400097 400097', 'PIDILITE INDUSTRIES LIMITED KONDIVITA HOUSE, RAMKRISHNA MANDIR ROAD, NEAR CHAKALA METRO STATION, ANDHERI EAST, MUMBAI- 400059 400059', 199, '181+', 'December, 2025', 'PART-PAYMENT'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    1231, 'Tamil Nadu', 'Kanchipuram', 'ADV00000627', 'AODPT7728M', 'ACGLLLOT00000000680', 'THAMILARASAN  ARASAN', 9600313569, 'THAMILPEC@GMAIL.COM',
    26000, 22100, 3305, 595, 3900, 594.92, 0, 0, 3305.08,
    29, 0.85, 32409, '2025-12-08', '2026-01-06', '''911010032621134', 'AXIS BANK',
    'UTIB0000074', 'INF/NEFT/IN42534256990824/UTIB0000074/62880707 /                              /THAMILARASA', 'DISBURSED', 'REPEAT', 'PIYUSH', NULL,
    'PLOT NO. 81, TEMPLE GREEN PHASE 3 ARUN EXCELLO TEMPLE GREEN MATHUR VILLAGE, SRIPERUMBUDUR TALUK, KANCHEEPURAM DISTRICT,  602105', 'PENNAR INDUSTRIES LIMITED NO 3, MANJOLAI FIRST MAIN ROAD KALAIMAGAL NAGAR EXTENSION, EKKATTUTHANGAL,  600032', 195, '181+', 'December, 2025', 'PART-PAYMENT'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    1256, 'Telangana', 'Hyderabad', 'LOA00001900', 'AJHPV0510G', 'ACGLLLOT00000000698', 'VUTUKURU VENKATESWARLU GUPTA', 9030102489, 'GUPTA.EMBEDDED@GMAIL.COM',
    52000, 46800, 4407, 793, 5200, 793.22, 0, 0, 4406.78,
    22, 1, 63440, '2025-12-09', '2025-12-31', '''0913896721', 'KOTAK MAHINDRA BANK LIMITED',
    'KKBK0000463', 'INF/NEFT/IN42534358144846/KKBK0000463/62961803 /                              /VUTUKURUVEN', 'DISBURSED', 'REPEAT', 'SHIVAM SHARMA', 'NAVEEN',
    'FLOT NO. 404 ANASUYA SADANN, TARAANAGAR, CHANDA NAGAR, TIRUMALAGIRI, HYDERABAD, TELANGANA-500051  500051', 'TESSOLVE SEMICONDUCTOR PRIVATE LIMITED SY 136/2ND 136/4, INDIQUBE PEARL, MINDSPACE RD, BESIDE ROLLING HILLS, ANJAIAH NAGAR, GACHIBOWLI, HYDERABAD, TELANGANA 500032  500031', 201, '181+', 'December, 2025', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    1260, 'Maharashtra', 'Raigarh', 'LOA00002040', 'AIPPD5974K', 'ACGLLLOT00000000697', 'ABHISEK  DAS', 9861044894, 'DAASABHISEK419@GMAIL.COM',
    50000, 42500, 6356, 1144, 7500, 1144.07, 0, 0, 6355.93,
    34, 0.85, 64450, '2025-12-09', '2026-01-12', '''7256772690', 'INDIAN BANK',
    'IDIB000O028', 'INF/NEFT/IN42534358056181/IDIB000O028/62953730 /                              /ABHISEKDAS', 'DISBURSED', 'REPEAT', 'PIYUSH', 'NAVEEN',
    'FLAT NO - 1403 B WING , SAI CRYSTAL SECTOR 35D KHARGHAR NAVI MUMBAI 410210  410210', 'NEELGUND DEVELOPERS LLP 2001, 2002 KAMDHENU COMMERZ SECTOR 14 KHARGHAR 410210 2001, 2002 KAMDHENU COMMERZ SECTOR 14 KHARGHAR 410210  410210', 189, '181+', 'December, 2025', 'PART-PAYMENT'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    1344, 'Karnataka', 'Bangalore', 'LOA00002274', 'FDIPD0772A', 'ACGLLLOT00000000718', 'PRAJWAL P DEVADIGA', 7259499280, 'DEVADIGA949@GMAIL.COM',
    40000, 34000, 5085, 915, 6000, 915.25, 0, 0, 5084.75,
    19, 0.75, 45700, '2025-12-10', '2025-12-29', '''50100712309740', 'HDFC BANK',
    'HDFC0001571', 'INF/NEFT/IN42534459334818/HDFC0001571/63056373 /                              /PRAJWALPDEV', 'DISBURSED', 'NEW', 'POOJA', 'NAVEEN',
    'RAGHAVENDRA SWAMY HOUSE,  GALI NO 18 A ASHIORWAD COLONY HORAMAVU BANGALORE  560043', 'ILLUMINA INDIA BIOTECHNOLOGY PVT LTD 8, BELLARY RD, DENA BANK COLONY, ARMANE NAGAR, BENGALURU, KARNATAKA 560032  560032', 203, '181+', 'December, 2025', 'PART-PAYMENT'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    1258, 'Maharashtra', 'Mumbai', 'ADV00000667', 'DDGPP0662H', 'ACGLLLOT00000000719', 'MANISHA  PANDEY', 7738710163, 'MANISHAPANDEY2312@GMAIL.COM',
    14000, 11900, 1780, 320, 2100, 320.34, 0, 0, 1779.66,
    27, 0.75, 16835, '2025-12-11', '2026-01-07', '''55550106743246', 'FEDERAL BANK',
    'FDRL0005555', 'INF/NEFT/IN42534559668913/FDRL0005555/63077065 /                              /MANISHAPAND', 'DISBURSED', 'REPEAT', 'POOJA', 'NAVEEN',
    '32 /2 B WING GANGA NIWAS V MEHTAROAD JUHU SCHEME NEAR DENA BANK VILE PARLE MUMBAI MAHARASTRA 400056 NEAR DENA BANK 400056', 'SUPER CASSETTES INDUSTRIES PRIVATE LIMITED B-14, TSERIES OFFICE, T TOWER, NEW LINK ROAD, OPP CITI MALL, ANDHERI WEST, MUMBAI 400056 NEW LINK ROAD, 400056', 194, '181+', 'December, 2025', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    1357, 'Maharashtra', 'Mumbai', 'LOA00002279', 'BLTPK7274H', 'ACGLLLOT00000000725', 'ATUL ASHOK KADAM', 9321034803, 'ATULKADAM66@GMAIL.COM',
    12000, 10200, 1525, 275, 1800, 274.58, 0, 0, 1525.42,
    27, 0.75, 14430, '2025-12-11', '2026-01-07', '''50100772312880', 'HDFC BANK',
    'HDFC0000086', 'INF/NEFT/IN42534550440189/HDFC0000086/63143139 /                              /ATULASHOKKA', 'DISBURSED', 'NEW', 'ASHISH', 'NAVEEN',
    'ROOM NO 21 NAGANATH SOCIETY BEHIND DUTT MANDIR NEAR HEMA INDUSTRY SARVODAYA NAGAR MEGHWADI JOGESHWARI EAST 400060  400060', 'CANVAS SALON AND SPA CANVAS SALOON AND SPA CYCRESS CHS LTD HIRANANDANI GARDAN POWAI = 400076 CANVAS SALOON AND SPA CYCRESS CHS LTD HIRANANDANI GARDAN POWAI = 400076  400076', 194, '181+', 'December, 2025', 'PART-PAYMENT'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    1366, 'Maharashtra', 'Pune', 'LOA00002287', 'AFSPH7729E', 'ACGLLLOT00000000736', 'KARTIK RAMESH HONNAVAR', 9940395397, 'KARTIK.HONAVAR@GMAIL.COM',
    50000, 42500, 6356, 1144, 7500, 1144.07, 0, 0, 6355.93,
    20, 0.75, 57500, '2025-12-11', '2025-12-31', '''00000044644484731', 'STATE BANK OF INDIA',
    'SBIN0000865', 'INF/NEFT/IN42534550292475/SBIN0000865/63134682 /                              /KARTIKRAMES', 'DISBURSED', 'NEW', 'SHIVAM SHARMA', 'NAVEEN',
    'C-305, SAVALI SAFFRON,, KESHAV NAGAR MUNDHWA,,  411036', 'RANDSTAD INDIA PRIVATE LIMITED JOHNSON AND JOHNSON , GIGA SPACE IT PARK, CLOVER PARK, VIMAN NAGAR  411014', 201, '181+', 'December, 2025', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    1382, 'Karnataka', 'Bangalore', 'LOA00002289', 'CMWPR8925B', 'ACGLLLOT00000000738', 'B R PRADEEP', 8904363881, 'PRADEEPGOWDA6522@GMAIL.COM',
    30000, 25500, 3814, 686, 4500, 686.44, 0, 0, 3813.56,
    20, 0.75, 34500, '2025-12-11', '2025-12-31', '''923010029099080', 'AXIS BANK',
    'UTIB0001856', 'INF/NEFT/IN42534550292294/UTIB0001856/63134682 /                              /BRPRADEEP', 'DISBURSED', 'NEW', 'SHIVAM SHARMA', 'NAVEEN',
    '4/14 8TH MAIN NEAR CAKES AND SLICES BAKERY SRINIVASA NAGARA  560050', 'ANTHOLOGY INTERNATIONAL PRIVATE LIMITED 2ND AND 6TH FLOOR, â€œPHOENIXâ€ MAGNIFICIA VIJINAPURA, MAHADEVAPURA, WARD, OLD MADRAS RD, DOORAVANI NAGAR, BENGALURU, KARNATAKA 560016  560016', 201, '181+', 'December, 2025', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    1423, 'Maharashtra', 'Mumbai', 'LOA00002296', 'AOKPM1386F', 'ACGLLLOT00000000750', 'SAGAR AVINASH MEHTA', 7506378345, 'MEHTASAGAR240@GMAIL.COM',
    60000, 54000, 5085, 915, 6000, 915.25, 0, 0, 5084.75,
    19, 1, 71400, '2025-12-12', '2025-12-31', '''916010029718446', 'AXIS BANK',
    'UTIB0000508', 'INF/NEFT/IN42534650762069/UTIB0000508/63169764 /                              /SAGARAVINAS', 'DISBURSED', 'NEW', 'PIYUSH', 'NAVEEN',
    'C WING 103, SWAPNA DEEP CHSL A WING, SOC48542_SWAPNA DEEP CHSL, MUMBAI, SAMBHAJI NAGAR, B R ROAD, 27, MAHARASHTRA,  400080', 'NUVAMA WEALTH AND INVESTMENT LIMITED UNIT NO . 1 TO 12 1ST FLOOR, KANAKIA WALL STREET ANDHERI KURLA ROAD CHAKALA ANDHERI EAST- MUMBAI - 400093  400093', 201, '181+', 'December, 2025', 'PART-PAYMENT'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    1432, 'Maharashtra', 'Raigarh', 'LOA00002306', 'ANQPG5722Q', 'ACGLLLOT00000000765', 'SANDESH SURESH GAVANDI', 8356991159, 'SANDESH.GAVANDI@GMAIL.COM',
    50000, 42500, 6356, 1144, 7500, 1144.07, 0, 0, 6355.93,
    20, 0.75, 57500, '2025-12-12', '2026-01-01', '''10073856858', 'IDFC FIRST BANK LTD',
    'IDFB0040142', 'INF/NEFT/IN42534651068889/IDFB0040142/63201441 /                              /SANDESHSURE', 'DISBURSED', 'NEW', 'POOJA', 'NAVEEN',
    'A 104 NEELKANTH KRUPA PLOT 36 SECTOR 4 KARANJADE PANVEL 410206 SECTOR 4 KARANJADE PANVEL 410206  410206', 'IDFC FIRST BANK IDFC FIRST BANK GIGAPLEX TOWER I MINDSPACE AIROLI NAVI MUMBAI 400708 NAVI MUMBAI  400007', 200, '181+', 'December, 2025', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    1446, 'Karnataka', 'Bangalore', 'LOA00002318', 'AKTPR5558D', 'ACGLLLOT00000000779', 'RAJU', 9945693038, 'RSPAWARAJU4153@GMAIL.COM',
    30000, 25500, 3814, 686, 4500, 686.44, 0, 0, 3813.56,
    18, 0.75, 34050, '2025-12-13', '2025-12-31', '''849810110006112', 'BANK OF INDIA',
    'BKID0008498', 'INF/NEFT/IN42534751560390/BKID0008498/63239214 /                              /RAJU', 'DISBURSED', 'NEW', 'DEEPAK KUMAR', 'NAVEEN',
    'SRINIVAS BUILDING 110/3A 1ST FLOOR NAGONDANAHALLI WHITEFIELD BANGALORE 560066  560066', 'FLOWSERVE INDIA CONTROLS PRIVATE LIMITED PLOT NO 4, 1AROAD NO 8,EPIP WHITEFIELD BANGALORE 560066  560066', 201, '181+', 'December, 2025', 'PART-PAYMENT'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    1449, 'Telangana', 'Rangareddy', 'LOA00002312', 'BOJPK9529L', 'ACGLLLOT00000000771', 'KAKANI SRI HARSHA', 8019378727, 'HARSHA.KAKANI@GMAIL.COM',
    20000, 17000, 2542, 458, 3000, 457.63, 0, 0, 2542.37,
    18, 0.75, 22700, '2025-12-13', '2025-12-31', '''925010009119506', 'AXIS BANK LTD',
    'UTIB0003060', 'INF/NEFT/IN42534751407565/UTIB0003060/63222309 /                              /KAKANISRIHA', 'DISBURSED', 'NEW', 'DEEPAK KUMAR', 'ASHISH',
    'HNO: 6-14/3, GHANDHI STATUE LANE, CHANDANAGAR, HYDERABAD:500050  500050', 'TATA ADVANCED SYSTEMS LMT.(HYDERABAD) PLOT NO:1, SYNO: 656, ADITHYA NAGAR, ADIBATLA, HYDERABAD, 501510  501301', 201, '181+', 'December, 2025', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    1457, 'Maharashtra', 'Mumbai', 'LOA00002317', 'BBXPP5155N', 'ACGLLLOT00000000778', 'BANKIM BHUPENDRA PANDYA', 9429782567, 'BANKIM164@GMAIL.COM',
    40000, 34000, 5085, 915, 6000, 915.25, 0, 0, 5084.75,
    18, 0.75, 45400, '2025-12-13', '2025-12-31', '''03950100023312', 'BANK OF BARODA',
    'BARB0GHATKO', 'INF/NEFT/IN42534751560404/BARB0GHATKO/63239214 /                              /BANKIMBHUPE', 'DISBURSED', 'NEW', 'GARISHMA', 'ASHISH',
    'KALPNAGRI COMPLAX A/104 NISHAD BUILDING BR ROAD VAISHALI NAGAR MULUND WEST MUMBAI 400080 KALPNAGRI COMPLAX A/104 NISHAD BUILDING BR ROAD VAISHALI NAGAR MULUND WEST MUMBAI 400080  400080', 'ERGO TECHNOLOGY & SERVICES PRIVATE LIMITED ERGO TECHNOLOGY & SERVICES PRIVATE LIMITED UNIT NO. 201, 2ND FLOOR, KENSINGTON, â€œAâ€ WING BUILDING, FESTUS PROPERTIES PVT. LTD.- SEZ, POWAI, MUMBAI, MAHARASHTRA- 400076 ERGO TECHNOLOGY & SERVICES PRIVATE LIMITED UNIT NO. 201, 2ND FLOOR, KENSINGTON, â€œAâ€ WING BUILDING, FESTUS PROPERTIES PVT. LTD.- SEZ, POWAI, MUMBAI, MAHARASHTRA- 400076  400076', 201, '181+', 'December, 2025', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    1473, 'Telangana', 'Hyderabad', 'LOA00001879', 'AEVPW8691N', 'ACGLLLOT00000000785', 'ABDUL  WASIE', 8247343096, 'DR.ABDUL_WASIE@OUTLOOK.COM',
    15000, 12750, 1907, 343, 2250, 343.22, 0, 0, 1906.78,
    33, 0.85, 19207.5, '2025-12-13', '2026-01-15', '''77770126853270', 'THE FEDERAL BANK LTD',
    'FDRL0007777', 'INF/NEFT/IN42534751691820/FDRL0007777/63251063 /                              /ABDULWASIE', 'DISBURSED', 'REPEAT', 'GARISHMA', 'NAVEEN',
    '9-4-136/75, TAJ HOUSE, BESIDE MADINA CLINIC ,NEXT TO MASJID -E-HABIBIA, BEHIND AZAAN INTERNATIONAL SCHOOL, 7 TOMBS ROAD, TOLICHOWKI ,HYDERABAD, 500008  500008', 'PRACTOPULSE HEALTHCARE SERVICES PRIVATE LIMITED PRACTOPULSE, 1016, 9TH FLOOR , YELLA REDDY GUDA RD, BESIDE METRO STATION AMEERPET, AMEERPET, HYDERABAD, TELANGANA 500073  500073', 186, '181+', 'December, 2025', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    1474, 'Maharashtra', 'Pune', 'LOA00002323', 'ALYPV6056E', 'ACGLLLOT00000000784', 'ABHIJIT  VIJ', 8308004292, 'ABHIJIT_VIJ@HOTMAIL.COM',
    35000, 29750, 4449, 801, 5250, 800.85, 0, 0, 4449.15,
    26, 0.75, 41825, '2025-12-13', '2026-01-08', '''159767539057', 'INDUSIND BANK',
    'INDB0000380', 'INF/NEFT/IN42534751691816/INDB0000380/63251063 /                              /ABHIJITVIJ', 'DISBURSED', 'NEW', 'DEEPAK KUMAR', 'NAVEEN',
    'A2-908, ROHAN ABHILASHA WAGHOLI PUNE 412207  412207', 'CYNBRIX CONSULTING PLOT NO 4 SECTOR 16 NOIDA 201301  201301', 193, '181+', 'December, 2025', 'PART-PAYMENT'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    1371, 'Delhi', 'New Delhi', 'LOA00002087', 'AVCPB5969Q', 'ACGLLLOT00000000795', 'VIPUL  BHATIA', 9971800775, 'VIPULBHATIA1988@GMAIL.COM',
    20000, 17000, 2542, 458, 3000, 0, 228.81, 228.81, 2542.37,
    26, 0.75, 23900, '2025-12-15', '2026-01-10', '''034098700005227', 'YES BANK',
    'YESB0000340', 'INF/NEFT/IN42534952661989/YESB0000340/63309391 /                              /VIPULBHATIA', 'DISBURSED', 'REPEAT', 'POOJA', 'NAVEEN',
    'B 14/2,DOUBLE STOREY RAMESH NAGAR,NEW DELHI 110015 NAGAR,NEW DELHI 110015  110015', 'VMS TRAVEL TECH (I) PVT. LTD. UNIT 203-212,2ND FLOOR HL WING,DWARKA,NEW DELHI 110075 WING,DWARKA,NEW DELHI 110075  110075', 191, '181+', 'December, 2025', 'PART-PAYMENT'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    1441, 'Telangana', 'Hyderabad', 'LOA00002310', 'ESYPA2947E', 'ACGLLLOT00000000769', 'PANGULURI  ANOOHYA', 8247449830, 'PANGULURIANOOHYA18@GMAIL.COM',
    30000, 25500, 3814, 686, 4500, 686.44, 0, 0, 3813.56,
    16, 0.75, 33600, '2025-12-15', '2025-12-31', '''924010009050167', 'AXIS BANK',
    'UTIB0003966', 'INF/NEFT/IN42534952058255/UTIB0003966/63208530 /                              /PANGULURIAN', 'DISBURSED', 'NEW', 'SHIVAM SHARMA', 'NAVEEN',
    'W/O PANGULURI GOPI KRISHNA, FLAT NOA408 SYMANTAKA EMERALD HEIGHTS, SAI BHASKAR PEARL ROAD, NEAR KNEEDY GLOBAL SCHOOL, BACHUPALLY,  500090', 'HCL TECHNOLOGIES LTD SY. NO. 30, 34, AVINASH HITECH CITY 2 SOCIETY, PLOT H-01B, 35 & 38, GACHIBOWLI, SERILINGAMPALLE (M),  500081', 201, '181+', 'December, 2025', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    1494, 'Maharashtra', 'Mumbai', 'LOA00002326', 'BFVPS2401A', 'ACGLLLOT00000000791', 'DHAVAL  SHAH', 9372632385, 'MITR8583@GMAIL.COM',
    45000, 38250, 5720, 1030, 6750, 1029.66, 0, 0, 5720.34,
    17, 0.75, 50737.5, '2025-12-15', '2026-01-01', '''8350755342', 'KOTAK MAHINDRA BANK LIMITED',
    'KKBK0000841', 'INF/NEFT/IN42534952469770/KKBK0000841/63290828 /                              /DHAVALSHAH', 'DISBURSED', 'NEW', 'POOJA', 'NAVEEN',
    'FLAT NO: 602 FLOOR: 6 WING: B PARINEE ADNEY-2-B, BORIVALI (W) EKSAR VILLAGE, HOLYCROSS ROAD, NEAR APEX HOSPITAL,  400103', 'PAUL MASONCONSULTING 6TH FLOOR, CORNER HEIGHTS, GUJARAT  390012', 200, '181+', 'December, 2025', 'PART-PAYMENT'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    1509, 'Delhi', 'New Delhi', 'LOA00002334', 'ALYPL7031K', 'ACGLLLOT00000000801', 'MOHAN  LAL', 8076948929, 'SPDIXIT831993@GMAIL.COM',
    10000, 8500, 1271, 229, 1500, 0, 114.41, 114.41, 1271.19,
    21, 0.75, 11575, '2025-12-15', '2026-01-05', '''50100568951688', 'HDFC BANK',
    'HDFC0001220', 'INF/NEFT/IN42534952662006/HDFC0001220/63309391 /                              /MOHANLAL', 'DISBURSED', 'NEW', 'KISHAN KUMAR', 'NAVEEN',
    'HOUSE NO-L 49, L BLOCK, GALI NO 12, BUDH BAZAR ROAD, RAJIV NAGAR EXTENSION, BEGUMPUR, NORTH WEST DELHI, DELHI, 110086 RAJIV NAGAR EXTENSION, 110086', 'JUST DIAL A - 45 TO 50, A BLOCK, SECTOR 16, NOIDA, UTTAR PRADESH 201301 SECTOR 16 201301', 196, '181+', 'December, 2025', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    1522, 'Karnataka', 'Bangalore', 'LOA00002337', 'CAIPS9774F', 'ACGLLLOT00000000805', 'SWAPNA  M', 8494949400, 'SWAPNA.HARISH06@GMAIL.COM',
    25000, 22500, 2119, 381, 2500, 381.36, 0, 0, 2118.64,
    16, 1, 29000, '2025-12-15', '2025-12-31', '''50100524001252', 'HDFC BANK',
    'HDFC0001569', 'INF/NEFT/IN42534952851445/HDFC0001569/63324247 /                              /SWAPNAM', 'DISBURSED', 'NEW', 'DEEPAK KUMAR', 'NAVEEN',
    '157 KOUSTHUBHAM 3RD CROSS KAMANTH LYT VIDYARANYAPURA BANGALORE 560097  560097', 'DELUXE ENTERTAINMENT DISTRIBUTION INDIA PRIVATE LIMITED SMART WORKS TOWER C BELLANDUR BANGALORE GLOBAL TECH VILLAGE BELLANDUR 560103  560103', 201, '181+', 'December, 2025', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    1490, 'Maharashtra', 'Mumbai', 'LOA00002340', 'FENPS5168M', 'ACGLLLOT00000000810', 'RAJVINDER  SINGH', 9915349195, 'RAJVINDERSINGHH56@GMAIL.COM',
    50000, 42500, 6356, 1144, 7500, 1144.07, 0, 0, 6355.93,
    17, 0.75, 56375, '2025-12-16', '2026-01-02', '''55161798234', 'STATE BANK OF INDIA',
    'SBIN0001540', 'INF/NEFT/IN42535053168840/SBIN0001540/63347640 /                              /RAJVINDERSI', 'DISBURSED', 'NEW', 'POOJA', 'ASHISH',
    'H NO 498, G SAWANT MARG, BADHWAR PARK, APOLLO BANDAR, COLABA, MUMBAI MAHARASHTRA - 400005  400005', 'AKUMS DRUGS & PHARMACEUTICALS LTD 503/504, 5TH FLOOR, HUBTOWN SOLARIS, PROF. N.S. PHADKE MARG, ANDHERI EAST, MUMBAI, MAHARASHTRA 400069  400069', 199, '181+', 'December, 2025', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    1531, 'Maharashtra', 'Mumbai', 'LOA00002346', 'AMNPP9501E', 'ACGLLLOT00000000816', 'VATSAL NATWARLAL PATEL', 9892153337, 'VATSALNPATEL87@YAHOO.IN',
    45000, 38250, 5720, 1030, 6750, 1029.66, 0, 0, 5720.34,
    15, 0.75, 50062.5, '2025-12-16', '2025-12-31', '''50100070953875', 'HDFC BANK',
    'HDFC0000145', 'INF/NEFT/IN42535053286508/HDFC0000145/63360777 /                              /VATSALNATWA', 'DISBURSED', 'NEW', 'KISHAN KUMAR', 'ASHISH',
    '605 NEW KRISHNA NIWAS, ROSHAN NAGAR CHANDAWARKAR ROAD, BORIVALI WEST, MUMBAI, BORIVALI WEST, MAHARASHTRA, 400092 ROSHAN NAGAR CHANDAWARKAR ROAD 400092', 'STATE STREET CORPORATE SERVICES MUMBAI PRIVATE LIMITED EQUINOX BUSINESS PARK, LAL BAHADUR SHASTRI MARG, AMBEDKAR NAGAR, KURLA WEST, KURLA, MUMBAI, MAHARASHTRA 400070 LAL BAHADUR SHASTRI MARG 400070', 201, '181+', 'December, 2025', 'PART-PAYMENT'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    1548, 'Karnataka', 'Bangalore', 'LOA00002361', 'BKBPR5819J', 'ACGLLLOT00000000832', 'A RICHARD DAVID', 9743454600, 'RICHARDDAVID913@GMAIL.COM',
    5000, 4250, 636, 114, 750, 114.41, 0, 0, 635.59,
    15, 0.75, 5562.5, '2025-12-16', '2025-12-31', '''04442010125985', 'CANARA BANK',
    'CNRB0010444', 'INF/NEFT/IN42535053432451/CNRB0010444/63376445 /                              /ARICHARDDAV', 'DISBURSED', 'NEW', 'DEEPAK KUMAR', 'NAVEEN',
    '697 PEENYA PLANTATION JALAHALLI WEST BENGULURU 560015 LANDMARK AYYAPPA TEMPLE 560015', 'AIRFORCE CENTRAL ACCOUNTS OFFICE AIR FORCE TECHNICAL COLLEGE JALAHALLI WEST BENGULURU 560015  560015', 201, '181+', 'December, 2025', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    1550, 'Maharashtra', 'Pune', 'LOA00002353', 'FKIPM9347D', 'ACGLLLOT00000000823', 'DEEPAK MUKTARAM MORE', 7020800532, 'DEEPAKMORE603@GMAIL.COM',
    25000, 21250, 3178, 572, 3750, 572.03, 0, 0, 3177.97,
    15, 0.75, 27812.5, '2025-12-16', '2025-12-31', '''922010037505387', 'AXIS BANK',
    'UTIB0001032', 'INF/NEFT/IN42535053361799/UTIB0001032/63368784 /                              /DEEPAKMUKTA', 'DISBURSED', 'NEW', 'DEEPAK KUMAR', 'ASHISH',
    '187/2/1 NAVNATH NAGAR CHAKRAPANI CHOWK BHOSARI PUNE MAHARASHTRA 411039  411039', 'BNY MELLON INTERNATIONAL OPERATIONS INDIA PRIVATE LIMITED BNY, KHARADI MUNDWA ROAD KHARADI PUNE 411014  411004', 201, '181+', 'December, 2025', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    1581, 'Karnataka', 'Bangalore', 'LOA00002375', 'BFNPG8544N', 'ACGLLLOT00000000868', 'MOULA  G', 9945214073, 'MOULA.G1992@GMAIL.COM',
    35000, 29750, 4449, 801, 5250, 800.85, 0, 0, 4449.15,
    40, 0.75, 45500, '2025-12-17', '2026-01-26', '''231801508346', 'ICICI BANK LIMITED',
    'ICIC0002318', 'INF/INFT/042701446441/63443549     /MOULAG/', 'DISBURSED', 'NEW', 'POOJA', 'NAVEEN',
    '24,BAGALUR MAINROAD HOSUR,BANDE,AA, BANGALORE NORTH BANGALORE KARNATAKA - INDIA - 562149 KARNATAKA  562149', 'BAJAJ LIFE INSURANCE LTD GOLDEN HEIGHTS 4TH M BLOCK RAJAJINAGAR MAIN ROAD BANGALORE -560010 KARNATAKA BANGLORE  560010', 175, '121-180', 'December, 2025', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    1592, 'Telangana', 'Hyderabad', 'LOA00002371', 'FGBPS9602E', 'ACGLLLOT00000000872', 'SIRMANWAR PRUTHVI RAJ', 6303459274, 'SIRMANWARPRUTHVI@GMAIL.COM',
    18000, 15300, 2288, 412, 2700, 411.86, 0, 0, 2288.14,
    13, 0.75, 19755, '2025-12-17', '2025-12-30', '''6346842663', 'KOTAK MAHINDRA BANK LIMITED',
    'KKBK0000560', 'INF/NEFT/IN42535154159133/KKBK0000560/63442532 /                              /SIRMANWARPR', 'DISBURSED', 'NEW', 'DEEPAK KUMAR', 'NAVEEN',
    '9-116/4/A SANJAY GANDHI NAGAR SHAPUR NAGAR HYDERABAD. LAND MARK SAI LATHA MODEL SCHOOL 500057', 'GOC SERVICES INDIA PRIVATE LIMITED FLOOR NO 6 SAR 1 SALLLAPURIA SATTVA FINANCIAL DISTRICT ROAD NO 2 SERILINGAMPALLY HYDERABAD 500032 LAND MARK NVIDIA OFFICE 500031', 202, '181+', 'December, 2025', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    1601, 'Karnataka', 'Bangalore', 'LOA00002388', 'BADPJ7208M', 'ACGLLLOT00000000884', 'JAINI  KRISHNA', 9951218044, 'KRISHNAJAINI1992@GMAIL.COM',
    50000, 42500, 6356, 1144, 7500, 1144.07, 0, 0, 6355.93,
    40, 0.75, 65000, '2025-12-18', '2026-01-27', '''50100262131872', 'HDFC BANK',
    'HDFC0000377', 'INF/NEFT/IN42535254577254/HDFC0000377/63480470 /                              /JAINIKRISHN', 'DISBURSED', 'NEW', 'POOJA', 'NAVEEN',
    '988/1, CHOWDESWARI LAYOUT, THULASI THEATOR ROAD, MARATHAHALLI, BANGALORE, 560037  560037', 'VISA CONSOLIDATED SUPPORT SERVICES (INDIA) PRIVATE LIMITED BAGMANE WORLD TECHNOLOGY CENTRE, MAHADEVPURA, BANGALORE, 560048  560048', 174, '121-180', 'December, 2025', 'PART-PAYMENT'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    1607, 'Maharashtra', 'Mumbai', 'ADV00001540', 'AXMPA0704A', 'ACGLLLOT00000000891', 'AJINKYA ANIL ARADE', 8879488571, 'AJINKYA09ARADE@GMAIL.COM',
    30000, 25500, 3814, 686, 4500, 686.44, 0, 0, 3813.56,
    15, 0.75, 33375, '2025-12-18', '2026-01-02', '''925010029607915', 'AXIS BANK',
    'UTIB0002064', 'INF/NEFT/IN42535254577397/UTIB0002064/63480470 /                              /AJINKYAANIL', 'DISBURSED', 'REPEAT', 'POOJA', 'NAVEEN',
    'FLAT NO. A/802 SAI SUMAN A WING VIKHROLI EAST, MUMBAI 400083, NEAR ICIC BANK 400079', 'LODHA DIVINO PROJECT BULDING NO 122/ 3RD FLOOR MATUNGA MUMBAI NEAR MANAV SEVA SANGH 400018', 199, '181+', 'December, 2025', 'PART-PAYMENT'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    1630, 'Karnataka', 'Bangalore', 'LOA00002396', 'AISPR5642K', 'ACGLLLOT00000000896', 'M ROZARIO RICHARD RAJESH', 9972577338, 'ROZARIO.RAJESH@GMAIL.COM',
    35000, 31500, 2966, 534, 3500, 533.9, 0, 0, 2966.1,
    13, 1, 39550, '2025-12-18', '2025-12-31', '''50100844473372', 'HDFC BANK',
    'HDFC0002870', 'INF/NEFT/IN42535254677228/HDFC0002870/63491781 /                              /MROZARIORIC', 'DISBURSED', 'NEW', 'SHIVAM SHARMA', 'NAVEEN',
    'NO 208 2ND FLOOR , B BLOCK BHANU PRIDE APPTS , 12 TH B CROSS KACHARAKANAHALLI ,  560084', 'US TECHNOLOGY INTERNATIONAL PRIVATE LIMITED 9TH FLOOR PRESTIGE SHANTINIKETAN WHITEFIELD OPPOSITE BIG BAZAAR 560048', 201, '181+', 'December, 2025', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    1640, 'Haryana', 'Faridabad', 'LOA00002401', 'CWIPS1056C', 'ACGLLLOT00000000901', 'MANU PRATAP SINGH', 8527078241, 'MANU18SINGH@GMAIL.COM',
    35000, 29750, 4449, 801, 5250, 800.85, 0, 0, 4449.15,
    13, 0.75, 38412.5, '2025-12-18', '2025-12-31', '''50100765107670', 'HDFC BANK',
    'HDFC0004131', 'INF/NEFT/IN42535254760896/HDFC0004131/63497212 /                              /MANUPRATAPS', 'DISBURSED', 'NEW', 'DEEPAK KUMAR', 'NAVEEN',
    'HOUSE 7 BLOCK 3 SPRINGFIELD COLONY SECTOR 31 FARIDABAD 121003  121003', 'AVERY DENNISON INDIA PVT LTD 11TH FLOOR SPAZE PLATINUM TOWER SECTOR 47 GURGAON 122018  122018', 201, '181+', 'December, 2025', 'PART-PAYMENT'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    1652, 'Karnataka', 'Bangalore', 'LOA00002404', 'BQYPP5934P', 'ACGLLLOT00000000905', 'PRASHOB P J', 8792241864, 'PRASHOBJOSHY@GMAIL.COM',
    65000, 58500, 5508, 992, 6500, 991.53, 0, 0, 5508.47,
    12, 1, 72800, '2025-12-19', '2025-12-31', '''004701589790', 'ICICI BANK LIMITED',
    'ICIC0000047', 'INF/INFT/042715177991/63507041     /PRASHOBPJ/', 'DISBURSED', 'NEW', 'PIYUSH', 'NAVEEN',
    '1A MRH RESIDENCY 6TH CROSS MCEHS LAYOUT RK HEGDE NAGAR BANGALORE 560077  560077', 'TECH SMCSQUARED (GCC) INDIA PRIVATE LIMITED 1ST FLOOR TOWER A, BHARATIYA CITY IT PARK , CHOKKANHALLI  , BANGALORE , KARNATAKA 560077  560077', 201, '181+', 'December, 2025', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    1658, 'Karnataka', 'Bangalore', 'LOA00002410', 'AVSPM2904N', 'ACGLLLOT00000000911', 'LEELA GOPI MANOHAR', 9739277557, 'LEELA_GM@HOTMAIL.COM',
    80000, 72000, 6780, 1220, 8000, 1220.34, 0, 0, 6779.66,
    13, 1, 90400, '2025-12-19', '2026-01-01', '''0791101201187', 'CANARA BANK',
    'CNRB0000791', 'INF/NEFT/IN42535355054854/CNRB0000791/63521485 /                              /LEELAGOPIMA', 'DISBURSED', 'NEW', 'PIYUSH', 'NAVEEN',
    'FLAT NO A-41 LEGACY ESTILO APARTMENT DODDABALLAPURA MAIN ROAD AVALAHALLI OPPOSITE TO B M S COLLAGE AVALAHALLI YELAHANKA JAKKUR BENGALORE KARNATAKA 560064  560064', 'KHATIB & ALAMI EMBASSY HEIGHTS, UNIT 801 & 802 ,MAGRATH ROAD , BANGALORE 560025 EMBASSY HEIGHTS, UNIT 801 & 802 ,MAGRATH ROAD , BANGALORE 560025  560025', 200, '181+', 'December, 2025', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    1693, 'Telangana', 'Hyderabad', 'LOA00002424', 'ABJPO1852A', 'ACGLLLOT00000000930', 'SESHA VAMSI KRISHNA ORUGANTI', 9052656848, 'VAMSHI1248@GMAIL.COM',
    25000, 21250, 3178, 572, 3750, 572.03, 0, 0, 3177.97,
    9, 0.75, 26687.5, '2025-12-20', '2025-12-29', '''000801590226', 'ICICI BANK LIMITED',
    'ICIC0000008', 'INF/INFT/042728568171/63575120     /SESHAVAMSIKRISHNAORU/', 'DISBURSED', 'NEW', 'DEEPAK KUMAR', 'ASHISH',
    'FLAT NO 402, SUNSHINE CUBE, TIRUMALA SHIVAPURI COLONY, SAINIKPURI HYDERABAD -500062  500062', 'CGI INFORMATION SYSTEMS AND MANAGEMENT CONSULTANTS PRIVATE LIMITED 129-132, BLOCK 3 , 2ND FLOOR, DLF CYBER CITY, GACHIBOWLI HYDERABAD -500032  500031', 203, '181+', 'December, 2025', 'PART-PAYMENT'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    1714, 'Karnataka', 'Bangalore', 'LOA00002426', 'APJPR1741R', 'ACGLLLOT00000000934', 'RAJ KIRAN B S', 9538882619, 'RAJKIRANBS@GMAIL.COM',
    35000, 29750, 4449, 801, 5250, 800.85, 0, 0, 4449.15,
    38, 0.75, 44975, '2025-12-20', '2026-01-27', '''50100851109055', 'HDFC BANK',
    'HDFC0001752', 'INF/NEFT/IN42535455774651/HDFC0001752/63591035 /                              /RAJKIRANBS', 'DISBURSED', 'NEW', 'DEEPAK KUMAR', 'ASHISH',
    'SHREYAS RESIDENCY FLAT 301 3RD FLOOR SYNDICATE BANK COLONY OMKAR NAGAR BANNERGHATTA ROAD BANGALORE 560076 OPP EURO KIDS SCHOOL 560076', 'TRANSUNION GLOBAL TECHNOLOGY CENTER LLP PRIME CO TOWERS PANDURANGA NAGAR BANNERGHATTA ROAD BANGALORE 560076  560076', 174, '121-180', 'December, 2025', 'PART-PAYMENT'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    1720, 'Maharashtra', 'Thane', 'LOA00002430', 'BEMPT2787D', 'ACGLLLOT00000000943', 'STEFFAN  TAWARIS', 7715847687, 'STEFFANTAWARIS29@GMAIL.COM',
    18000, 16200, 1525, 275, 1800, 274.58, 0, 0, 1525.42,
    40, 1, 25200, '2025-12-22', '2026-01-31', '''5010992128', 'AXIS BANK',
    'UTIB0005115', 'INF/NEFT/IN42535656567679/UTIB0005115/63638269 /                              /STEFFANTAWA', 'DISBURSED', 'NEW', 'SHIVAM SHARMA', 'NAVEEN',
    'FLAT NO:E1504, FLOOR NO:15TH, BUILDING NAME:LAKESIDE E TALOJA BYPASS ROAD, KHONI, THANE,  421204', 'ACCENTURE SOLUTIONS PVT LTD ACCENTURE MDC2C GODREJ AND BOYCE COMPLEX PL3 LBS MARG AMBEWADI VIKHROLI WEST  400079', 170, '121-180', 'December, 2025', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    1732, 'Telangana', 'Hyderabad', 'LOA00002433', 'AYPPB0131N', 'ACGLLLOT00000000946', 'SHANTI SWARUP BEHERA', 9030105423, 'SHANTISWARUP246@GMAIL.COM',
    25000, 21250, 3178, 572, 3750, 572.03, 0, 0, 3177.97,
    40, 0.75, 32500, '2025-12-22', '2026-01-31', '''30287062998', 'STATE BANK OF INDIA',
    'SBIN0001701', 'INF/NEFT/IN42535656699144/SBIN0001701/63654107 /                              /SHANTISWARU', 'DISBURSED', 'NEW', 'SHIVAM SHARMA', 'NAVEEN',
    'FLAT NO 410 4TH FLOOR BLOCK NO 08 MY HOME MANGALA SERILIGAMAPALLY HYDERABAD KONDAPUR K V RANGAREDDY  500081', 'DXC TECHNOLOGY INDIA PRIVATE LIMITED WING A,25TH FLOOR, SATTVA KNOWLEDGE PARK, PLOT #16, SY NO 83/1, HITECH CITY, RAIDURG, RANGAREDDY,  500081', 170, '121-180', 'December, 2025', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    1734, 'Uttar Pradesh', 'Noida', 'LOA00002197', 'DURPK4938P', 'ACGLLLOT00000000944', 'ANAM  KHAN', 8447111658, 'ANAMK253@GMAIL.COM',
    55000, 46750, 6992, 1258, 8250, 1258.47, 0, 0, 6991.53,
    36, 0.85, 71830, '2025-12-22', '2026-01-27', '''0811884622', 'KOTAK MAHINDRA BANK LIMITED',
    'KKBK0000154', 'INF/NEFT/IN42535656568749/KKBK0000154/63638269 /                              /ANAMKHAN', 'DISBURSED', 'REPEAT', 'GARISHMA', 'NAVEEN',
    'T2-1602,ACE DIVINO, PLOT NO. GH-14A, SECTOR-1 NOIDA EXTENSION GREATER NOIDA WEST, GAUTAM BUDDHA NAGAR UTTAR PRADESH- 201306  201306', 'INDSYSTEMS IT PRIVATE LIMITED FIRST FLOOR, BUILDING NO 3, KH NO 385 PLOT NO-2, 100FT ROAD, GHITORNI, MG ROAD NEW DELHI SOUTH WEST DELHI DL 110030 IN. FIRST FLOOR, BUILDING NO 3, KH NO 385 PLOT NO-2, 100FT ROAD, GHITORNI, MG ROAD NEW DELHI SOUTH WEST DELHI DL 110030 IN.  110030', 174, '121-180', 'December, 2025', 'PART-PAYMENT'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    1735, 'Maharashtra', 'Pune', 'LOA00002438', 'BXEPA4159E', 'ACGLLLOT00000000953', 'ANIL KUMAR K R', 9036924138, 'ANILHLB@GMAIL.COM',
    30000, 25500, 3814, 686, 4500, 686.44, 0, 0, 3813.56,
    33, 0.75, 37425, '2025-12-22', '2026-01-24', '''0552101025777', 'CANARA BANK',
    'CNRB0000552', 'INF/NEFT/IN42535656567759/CNRB0000552/63638269 /                              /ANILKUMARKR', 'DISBURSED', 'NEW', 'DEEPAK KUMAR', 'ASHISH',
    'FLAT 401 MANE SANKALP BUILDING SHEJWAL PARK CHANDAN NAGAR PUNE 411014 (NEAR OLD SAI TEMPLE) 411014', 'CITI CORP SERVICES INDIA PRIVATE LIMITED EON FREE ZONE CLUSTER-E KHARADI CHANDAN NAGAR PUNE 411014  411014', 177, '121-180', 'December, 2025', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    1741, 'Telangana', 'Hyderabad', 'LOA00002439', 'CPMPK4053K', 'ACGLLLOT00000000954', 'KOPPULA NARSI REDDY', 7893054148, 'NARSIREDDYK25@GMAIL.COM',
    35000, 29750, 4449, 801, 5250, 800.85, 0, 0, 4449.15,
    40, 0.75, 45500, '2025-12-22', '2026-01-31', '''1849417912', 'KOTAK MAHINDRA BANK',
    'KKBK0007450', 'INF/NEFT/IN42535656567719/KKBK0007450/63638269 /                              /KOPPULANARS', 'DISBURSED', 'NEW', 'POOJA', 'NAVEEN',
    'F NO 301 H NO 12-11-1342/2 SANKALP CLASSIC APARTMENT BOUDHANAGAR WARASIGUDA SECUNDERABAD HYDERABAD 500061  500061', 'LOCUZ ENTERPRISE SOLUTIONS PRIVATE LIMITED 8TH FLOOR KRISHE SAPPHIRE BUILDING HI-TECH CITY MADHAPUR HYDERABAD 500081  500081', 170, '121-180', 'December, 2025', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    1742, 'Haryana', 'Gurgaon', 'LOA00002387', 'BAEPJ6378P', 'ACGLLLOT00000000945', 'KUNAL  JAIN', 9599614665, 'KUNALJAIN498@GMAIL.COM',
    20000, 17000, 2542, 458, 3000, 457.63, 0, 0, 2542.37,
    39, 0.75, 25850, '2025-12-22', '2026-01-30', '''1445319887', 'KOTAK MAHINDRA BANK LIMITED',
    'KKBK0000289', 'INF/NEFT/IN42535656519315/KKBK0000289/63632472 /                              /KUNALJAIN', 'DISBURSED', 'REPEAT', 'DEEPAK KUMAR', 'NAVEEN',
    'B3 1003 IREO THE CORRIDOR SECTOR 67 GURGAON 122101  122101', 'ACCENTURE SOLUTIONS PVT LTD TOWER 8 CANDOUR BUSINESS PARK SECTOR 21 GURGAON 122001  122001', 171, '121-180', 'December, 2025', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    1757, 'Haryana', 'Gurgaon', 'LOA00002446', 'BQXPS4818J', 'ACGLLLOT00000000963', 'SUNIL  SHARMA', 9999313525, 'SUNILRNKT@GMAIL.COM',
    35000, 29750, 4449, 801, 5250, 800.85, 0, 0, 4449.15,
    38, 0.75, 44975, '2025-12-23', '2026-01-30', '''061001501990', 'ICICI BANK LIMITED',
    'ICIC0000610', 'INF/INFT/042750769731/63666707     /SUNILSHARMA/', 'DISBURSED', 'NEW', 'DEEPAK KUMAR', 'ASHISH',
    'C143A, 2ND FLOOR, SUSHANT LOK 2, SECTOR 56, GURGAON, HARYANA, 122011  122011', 'DLF PHASE 5, SECTOR 43, GURGAON,Â HARYANA,Â 122009 2ND FLOOR, VIPUL TECH SQUARE, GOLF COURSE ROAD, DLF PHASE 5, SECTOR 43, GURGAON,Â HARYANA,Â 122009  122009', 171, '121-180', 'December, 2025', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    1770, 'Delhi', 'New Delhi', 'LOA00002449', 'BPDPS1411N', 'ACGLLLOT00000000969', 'DEPINDRA  SINGH', 7678614029, 'DEPINDRA.SINGH@HOTMAIL.COM',
    40000, 34000, 5085, 915, 6000, 0, 457.63, 457.63, 5084.75,
    39, 0.75, 51700, '2025-12-23', '2026-01-31', '''52510928575', 'STANDARD CHARTERED BANK',
    'SCBL0036027', 'INF/NEFT/IN42535757294973/SCBL0036027/63709438 /                              /DEPINDRASIN', 'DISBURSED', 'NEW', 'PIYUSH', 'NAVEEN',
    ': H. NO. 284, GALI INFRONT OF PARK, MAIN BUS STAND , BAKOLI, NORTH WEST DELHI 110036  110036', 'NTT INDIA PVT LTD NSL TECHZONE, SECTOR 144, NOIDA EXPRESSWAY,  NOIDA 201306  201306', 170, '121-180', 'December, 2025', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    1788, 'Uttar Pradesh', 'Noida', 'ADV00001814', 'AZJPR1518C', 'ACGLLLOT00000000980', 'PRABHAT  RANJAN', 9716993568, 'RANJANPRABHAT2008@GMAIL.COM',
    18000, 16200, 1525, 275, 1800, 274.58, 0, 0, 1525.42,
    39, 1, 25020, '2025-12-23', '2026-01-31', '''32716962991', 'STATE BANK OF INDIA',
    'SBIN0018934', 'INF/NEFT/IN42535757410366/SBIN0018934/63718747 /                              /PRABHATRANJ', 'DISBURSED', 'NEW', 'DEEPAK KUMAR', 'ASHISH',
    '11/132, PALM OLYMPIA GAUR CITY 2, GHAZIABAD, UTTAR PRADESH 201009  201305', 'HINDWARE LIMITED HINDWARE LIMITED PARK CENTRA 3RD FLOOR SECTOR 30 GURGAON HARYANA 122001 NEAR STAR MALL 122001', 170, '121-180', 'December, 2025', 'PART-PAYMENT'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    1760, 'Karnataka', 'Bangalore', 'LOA00002465', 'AGFPV1838E', 'ACGLLLOT00000000998', 'VENKATESH H M', 8618600114, 'VENKATMADHU1988@GMAIL.COM',
    25000, 21250, 3178, 572, 3750, 572.03, 0, 0, 3177.97,
    40, 0.75, 32500, '2025-12-24', '2026-02-02', '''100147183052', 'INDUSIND BANK',
    'INDB0000294', 'INF/NEFT/IN42535857798001/INDB0000294/63753415 /                              /VENKATESHHM', 'DISBURSED', 'NEW', 'GARISHMA', 'NAVEEN',
    'NO 28 VENKATESHWARA THEATRE ROAD DEVASANDRA KR PURAM BANGALORE 560036 NO 28 VENKATESHWARA THEATRE ROAD DEVASANDRA KR PURAM BANGALORE 560036  560036', 'ZERO EFFORT TECHNOLOGIES PRIVATE LIMITED NO BACK GATE 5, MANYATA TECH PARK RACHENAHALLI BANGALORE BANGALORE KARNATAKA-560045  560045', 168, '121-180', 'December, 2025', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    1774, 'Maharashtra', 'Mumbai', 'LOA00002473', 'AULPK8678H', 'ACGLLLOT00000001008', 'DINESH  KUMAR', 7973105538, 'DK5761199@GMAIL.COM',
    40000, 34000, 5085, 915, 6000, 915.25, 0, 0, 5084.75,
    40, 0.75, 52000, '2025-12-24', '2026-02-02', '''42936145373', 'STATE BANK OF INDIA',
    'SBIN0050039', 'INF/NEFT/IN42535858006205/SBIN0050039/63774753 /                              /DINESHKUMAR', 'DISBURSED', 'NEW', 'GARISHMA', 'NAVEEN',
    'H NO 498, G SAWANT MARG, BADHWAR PARK,  APOLLO BANDAR, COLABA, MUMBAI MAHARASHTRA - 400005 H NO 498, G SAWANT MARG, BADHWAR PARK,  APOLLO BANDAR, COLABA, MUMBAI MAHARASHTRA - 400005  400005', 'AKUMS DRUGS & PHARMACEUTICALS LTD. 503/504, 5TH FLOOR, HUBTOWN SOLARIS, PROF N S PHADKE MARG, ANDHERI EAST-400069 503/504, 5TH FLOOR, HUBTOWN SOLARIS, PROF N S PHADKE MARG, ANDHERI EAST-400069  400069', 168, '121-180', 'December, 2025', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    1801, 'Delhi', 'New Delhi', 'LOA00002457', 'DWDPK6981C', 'ACGLLLOT00000000988', 'DEEPAK  KUMAR', 7290040801, 'NEILIGIPESS290@GMAIL.COM',
    25000, 21250, 3178, 572, 3750, 0, 286.02, 286.02, 3177.97,
    38, 0.75, 32125, '2025-12-24', '2026-01-31', '''520101065671763', 'UNION BANK OF INDIA',
    'UBIN0913120', 'INF/NEFT/IN42535857604329/UBIN0913120/63730416 /                              /DEEPAKKUMAR', 'DISBURSED', 'NEW', 'KISHAN KUMAR', 'NAVEEN',
    '94-A FF BLK.K-1-EXTN. MOHAN GARDEN UTTAM NAGAR NEAR BHARDWAJ PROPERTY NEW DELHI 110059 NEAR BHARDWAJ PROPERTY 110059', 'GOVT. BOYS SR. SEC. SCHOOL, PH-II, NANGLOI M3R9+623, KAVITA COLONY, NANGLOI, NEW DELHI, DELHI, 110086 KAVITA COLONY 110086', 170, '121-180', 'December, 2025', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    1806, 'Maharashtra', 'Mumbai', 'LOA00002133', 'AQPPD5687F', 'ACGLLLOT00000000990', 'DIMPLE  DAWRA', 9643063077, 'DIMPLE.DAWRA@GMAIL.COM',
    32000, 27200, 4068, 732, 4800, 732.2, 0, 0, 4067.8,
    38, 0.75, 41120, '2025-12-24', '2026-01-31', '''9246557545', 'KOTAK MAHINDRA BANK LIMITED',
    'KKBK0001351', 'INF/NEFT/IN42535857712838/KKBK0001351/63741112 /                              /DIMPLEDAWRA', 'DISBURSED', 'REPEAT', 'SHIVAM SHARMA', 'NAVEEN',
    'AKRUTI HUBTOWN PHASE 1, ` IVY2, 607, MIRA ROAD EAST 401107  400072', 'ECLINICAL WORKS INDIA - ECLINICAL WORKS INDIA, BOOMERANG BUILDING, 7TH FLOOR, ANDHERI 400072 ECLINICAL WORKS INDIA, BOOMERANG BUILDING, 7TH FLOOR, ANDHERI 400072  400072', 170, '121-180', 'December, 2025', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    1810, 'Telangana', 'Medak', 'LOA00002468', 'JYQPS3069L', 'ACGLLLOT00000001001', 'CHEPATI  SASIKALA', 9036263376, 'CHEPATISASIKALA@GMAIL.COM',
    25000, 21250, 3178, 572, 3750, 572.03, 0, 0, 3177.97,
    38, 0.75, 32125, '2025-12-24', '2026-01-31', '''279501509523', 'ICICI BANK LIMITED',
    'ICIC0002795', 'INF/INFT/042766845601/63753415     /CHEPATISASIKALA     /', 'DISBURSED', 'NEW', 'KISHAN KUMAR', 'NAVEEN',
    'FLAT NO. 103, FIRST FLOOR, SRILATHA ENCLAVE, BANK COLONY, BEERAMGUDA, HYDERABAD, TELANGANA -502032 BANK COLONY, 502032', 'BELCAN INDIA PRIVATE LIMITED 12B RAHEJA MINDSPACE IT PARK, SURVEY NO. 64, APIIC SOFTWARE LAYOUT, MADHAPUR, TELANGANA 500081 APIIC SOFTWARE LAYOUT 500081', 170, '121-180', 'December, 2025', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    1816, 'Karnataka', 'Bangalore', 'LOA00002470', 'BITPR3134E', 'ACGLLLOT00000001005', 'SUDHEER  RAPURI', 7996305383, 'SRAPURI89@GMAIL.COM',
    50000, 42500, 6356, 1144, 7500, 1144.07, 0, 0, 6355.93,
    31, 0.75, 61625, '2025-12-24', '2026-01-24', '''14540100135507', 'FEDERAL BANK',
    'FDRL0001454', 'INF/NEFT/IN42535858006095/FDRL0001454/63774753 /                              /SUDHEERRAPU', 'DISBURSED', 'NEW', 'SHIVAM SHARMA', 'NAVEEN',
    'FLAT NO A 603 6TH FLOOR ASN SRIKARAM APARTMENT NALLURAHALLI SIDDAPURA ROAD WHITEFIELD  560066', 'REFINITIV INDIA SHARED SERVICES PRIVATE LIMITED DIVYASREE TECHNOPOLIS, 6TH FLOOR, EAST WING BLOCK B, BUILDING NO 3, 77 TOWN CENTER VARTHUR, HOBLI  560037', 177, '121-180', 'December, 2025', 'PART-PAYMENT'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    1840, 'Telangana', 'Hyderabad', 'LOA00002482', 'EJPPS9910H', 'ACGLLLOT00000001023', 'SAI SUMANTH  NIMMAGADDA', 9885352036, 'SAISUMANTH.NIMMAGADDA@GMAIL.COM',
    25000, 21250, 3178, 572, 3750, 572.03, 0, 0, 3177.97,
    37, 0.75, 31937.5, '2025-12-25', '2026-01-31', '''569101500369', 'ICICI BANK LTD',
    'ICIC0005691', 'INF/INFT/042773798191/63786022     /SAISUMANTHNIMMAGADDA/', 'DISBURSED', 'NEW', 'KISHAN KUMAR', 'NAVEEN',
    'LIG-226, FLAT-203, III-FLOOR, . PHASE-VII, ???? COLONY. KUKATPALLY, HYDERABAD. 500072 ???? COLONY 500085', 'XSILICA SOFTWARE SOLUTIONS P LTD UNIT NO - 4, KAPIL KAVURI HUB 3RD FLOOR, NANAKRAMGUDA, SERILINGAMPALLE (M), HYDERABAD, TELANGANA 500032 NANAKRAMGUDA 500032', 170, '121-180', 'December, 2025', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    1844, 'Telangana', 'Rangareddy', 'LOA00002487', 'BITPG7150D', 'ACGLLLOT00000001031', 'SIDDHARTH  GUPTA', 9000264839, 'SIDDHARTHGUPTA190@GMAIL.COM',
    50000, 42500, 6356, 1144, 7500, 1144.07, 0, 0, 6355.93,
    37, 0.75, 63875, '2025-12-25', '2026-01-31', '''004001605067', 'ICICI BANK LIMITED',
    'ICIC0000040', 'INF/INFT/042774572841/63790185     /SIDDHARTHGUPTA/', 'DISBURSED', 'NEW', 'GARISHMA', 'NAVEEN',
    '506 AVN RESIDENCY KOTHAGUDA KONDAPUR HYDERABAD 500084 506 AVN RESIDENCY KOTHAGUDA KONDAPUR HYDERABAD 500084  500084', 'DATUM CYBERTECH INDIA PRIVATE LIMITED DATUM CYBERTECH, FLOOR 1 , KTC ILLUMINATION, MADHAPUR ,500081 NEAR WESTIN HOTEL, OUTSIDE OF RAHEJA DATUM CYBERTECH, FLOOR 1 , KTC ILLUMINATION, MADHAPUR ,500081 NEAR WESTIN HOTEL, OUTSIDE OF RAHEJA  500081', 170, '121-180', 'December, 2025', 'PART-PAYMENT'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    1868, 'Tamil Nadu', 'Chennai', 'LOA00001963', 'AZAPM8654P', 'ACGLLLOT00000001039', 'MUHAMMAD RAMEEZ KHAN ZAFARULLAKHAN', 9894914382, 'MR.KHAN2602@GMAIL.COM',
    34000, 28900, 4322, 778, 5100, 777.97, 0, 0, 4322.03,
    37, 0.75, 43435, '2025-12-25', '2026-01-31', '''02601130004209', 'HDFC BANK',
    'HDFC0000260', 'INF/NEFT/IN42535958582972/HDFC0000260/63796875 /                              /MUHAMMADRAM', 'DISBURSED', 'REPEAT', 'POOJA', NULL,
    'FLAT NO-3E, EAST WING, B-BLOCK, 3RD FLOOR, SAI SURYA APTS, 3RD MAIN ROAD, KAMAKOTTI NAGAR, PALLIKARANAI, CHENNAI - 600100  600100', 'DTCC INTERPRISE FLAT NO-3E, EAST WING, B-BLOCK, 3RD FLOOR, SAI SURYA APTS, 3RD MAIN ROAD, KAMAKOTTI NAGAR, PALLIKARANAI, CHENNAI - 600100  600100', 170, '121-180', 'December, 2025', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    1896, 'Telangana', 'Hyderabad', 'LOA00002500', 'BYNPB2578J', 'ACGLLLOT00000001054', 'BHUKYA  NARENDER', 9515714032, 'NARENDER.B1431@GMAIL.COM',
    50000, 45000, 4237, 763, 5000, 762.71, 0, 0, 4237.29,
    33, 1, 66500, '2025-12-26', '2026-01-28', '''44511571987', 'STANDARD CHARTERED BANK',
    'SCBL0036075', 'INF/NEFT/IN42536059043516/SCBL0036075/63820805 /                              /BHUKYANAREN', 'DISBURSED', 'NEW', 'PIYUSH', 'NAVEEN',
    'PLOT NO- 12 ROAD NO - 2 SURYA MEADOW TATTI ANNARAM 500068  500068', 'LTIMINDTREE LIMITED LUMBIN AVEUNE LTIMINDTREE METRO BUILDING, GACHIBOWLI, RAIDURGA 500081, HYDERABAD  500081', 173, '121-180', 'December, 2025', 'PART-PAYMENT'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    1880, 'Karnataka', 'Bangalore', 'LOA00002505', 'AFRPV5349D', 'ACGLLLOT00000001060', 'VENKATESWARAN  VARADHARAJ', 9597685587, 'VMRK_VENKAT1@YAHOO.COM',
    30000, 25500, 3814, 686, 4500, 686.44, 0, 0, 3813.56,
    36, 0.75, 38100, '2025-12-26', '2026-01-31', '''50100362662671', 'HDFC BANK',
    'HDFC0000695', 'INF/NEFT/IN42536059199237/HDFC0000695/63838686 /                              /VENKATESWAR', 'DISBURSED', 'NEW', 'POOJA', 'NAVEEN',
    '19,KAMADHANU LAYOUT, NARAYANA REDDY LAYOUT , KONAAPPA AGRAHARA, ELECTRICCITY , BANGALORE , KARNATAKA - 560100 KAMADHANU LAYOUT, NARAYANA REDDY LAYOU  560100', 'SKF INDIA (INDUSTRIAL)LIMITED PLOT NO 2, BOMMASANDRA INDUSTRIAL AREA, BOMMASANDRA,BANGALORE ,KARNATAKA - 560099 NEXT TO DELTA OFFICE  560099', 170, '121-180', 'December, 2025', 'PART-PAYMENT'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    1900, 'Maharashtra', 'Pune', 'LOA00002511', 'AGCPC4444Q', 'ACGLLLOT00000001069', 'RAVI  CHAWLA', 9999656412, 'RAVICHAWLA2812@GMAIL.COM',
    40000, 34000, 5085, 915, 6000, 915.25, 0, 0, 5084.75,
    35, 0.75, 50500, '2025-12-26', '2026-01-30', '''106624158006', 'HSBC BANK',
    'HSBC0411002', 'INF/NEFT/IN42536059394262/HSBC0411002/63856156 /                              /RAVICHAWLA', 'DISBURSED', 'NEW', 'PIYUSH', 'NAVEEN',
    'T11-1801,BLUERIDGE SOCIETY,,HINJEWADI PH1,,PUNE,MAHARASHTRA ,411057 PUNE, MAHARASHTRA, 411057  411057', 'L & T PVT LTD BUILDING IT 6, QUBIX BUSINESS PARK, , RAJIV GANDHI INFOTECH, BLUERIDGE HINJEWADI PHASE 1 PUNE 411057  411057', 171, '121-180', 'December, 2025', 'PART-PAYMENT'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    1937, 'Delhi', 'New Delhi', 'LOA00002531', 'APRPK2995L', 'ACGLLLOT00000001106', 'MANPREET  SINGH', 7042952518, 'MKHURANA2019@GMAIL.COM',
    25000, 21250, 3178, 572, 3750, 0, 286.02, 286.02, 3177.97,
    40, 0.75, 32500, '2025-12-27', '2026-02-05', '''054236096006', 'HSBC BANK',
    'HSBC0110005', 'INF/NEFT/IN42536159916641/HSBC0110005/63890547 /                              /MANPREETSIN', 'DISBURSED', 'NEW', 'DEEPAK KUMAR', 'NAVEEN',
    'E-54 SARITA VIHAR NEW DELHI 110076 NEAR TO AGGARWAL SWEETS GATE 2 110076', 'ADDRESSOFCHOICE REALTY PVT LTD. A-82, 2ND FLOOR SECTOR 4 NOIDA 201301  201301', 165, '121-180', 'December, 2025', 'PART-PAYMENT'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    1942, 'Karnataka', 'Bangalore', 'LOA00002240', 'AOYPA6129C', 'ACGLLLOT00000001089', 'AJAY  S', 9746998338, 'AJAYSASIDHARAN2211@GMAIL.COM',
    45000, 38250, 5720, 1030, 6750, 1029.66, 0, 0, 5720.34,
    35, 0.75, 56812.5, '2025-12-27', '2026-01-31', '''3651277012', 'KOTAK MAHINDRA BANK LIMITED',
    'KKBK0009288', 'INF/NEFT/IN42536159624905/KKBK0009288/63863541 /                              /AJAYS', 'DISBURSED', 'REPEAT', 'POOJA', NULL,
    'NO 77 /1.77/ 2572101 J - 206 CONFIDENT ATIK SOMPURA GATE SARJAPUR ROAD BENGALURU - 562125  562125', 'ATG BUSINESS SOLUTIONS PRIVATE LIMITED 3RD FLOOR , SNO.20,21 , TOWER B , SATTVA KNOWLEDGE COURT , 7TH CROSS ROAD , KARNATAKA  560048', 170, '121-180', 'December, 2025', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    1972, 'Karnataka', 'Bangalore', 'ADV00000248', 'BVXPM3327H', 'ACGLLLOT00000001113', 'RONIT  MAITY', 9654754455, 'MAITY.RONIT18@GMAIL.COM',
    40000, 34000, 5085, 915, 6000, 915.25, 0, 0, 5084.75,
    37, 0.75, 51100, '2025-12-27', '2026-02-02', '''9654754455', 'KOTAK MAHINDRA BANK',
    'KKBK0009808', 'INF/NEFT/IN42536159916653/KKBK0009808/63890547 /                              /RONITMAITY', 'DISBURSED', 'REPEAT', 'KISHAN KUMAR', 'ASHISH',
    'HOUSSE NO C 606 PURVA BELMONT APARTMENTS, PURVA BELMONT, KANAKAPURA MAIN RD, KANAKANAGAR, YELACHENAHALLI, KUMARASWAMY LAYOUT, BENGALURU, KARNATAKA 560078 JP NAGAR METRO 560078', 'IMPELSYS PRIVATE LIMITED SURVEY.NO.192, IWF CAMPUS, WHITEFIELD MAIN RD, B NARAYANAPURA, MAHADEVAPURA, BENGALURU, KARNATAKA 560016 NARAYANAPURA 560007', 168, '121-180', 'December, 2025', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    1973, 'Maharashtra', 'Thane', 'LOA00002544', 'CRTPM4426J', 'ACGLLLOT00000001133', 'ASHISH  MENON', 7021229180, 'MENONA817@GMAIL.COM',
    20000, 17000, 2542, 458, 3000, 457.63, 0, 0, 2542.37,
    33, 0.75, 24950, '2025-12-29', '2026-01-31', '''038801584789', 'ICICI BANK LIMITED',
    'ICIC0001959', 'INF/INFT/042810109501/63946585     /ASHISHMENON/', 'DISBURSED', 'NEW', 'SHIVAM SHARMA', 'NAVEEN',
    'FLAT,NO2805 28TH FLOOR RIVER,VIEW, LODHA SLPENDORA,NEAR,BHAYANDARPADA GB ROAD  400615', 'TATA CONSULTANCY SERVICES 3RD FLOOR OLYMPUS A NEAR RODAS ENCLAVE HIRANANDANI ESTATE THANE WEST  400607', 170, '121-180', 'December, 2025', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    2000, 'Telangana', 'Hyderabad', 'LOA00001928', 'GGGPP1488D', 'ACGLLLOT00000001130', 'GOURU HARI PRASAD', 6281243356, 'HARIPRASADGOURU2628@GMAIL.COM',
    22000, 18700, 2797, 503, 3300, 503.39, 0, 0, 2796.61,
    33, 0.75, 27445, '2025-12-29', '2026-01-31', '''132001516664', 'ICICI BANK LIMITED',
    'ICIC0001320', 'INF/INFT/042809197321/63941022     /GOURUHARIPRASAD     /', 'DISBURSED', 'REPEAT', 'SHIVAM SHARMA', 'NAVEEN',
    '16-3, GAYATHRI NAGAR, UNNAMED ROAD, PEERZADIGUDA, SRICHAITANYA COLLEGE HYDERABAD 500039', 'COGNIZANT TECHNOLOGY SOLUTIONS INDIA PRIVATE LTD DLF CYBER CITY APHB COLONY,  GACHIBOWLI, HYDERABAD TELANGANA,500019  500019', 170, '121-180', 'December, 2025', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    2004, 'Maharashtra', 'Pune', 'LOA00002542', 'AERPI6599B', 'ACGLLLOT00000001128', 'INDLA RAMAN LAXMAIAH', 9959999653, 'RAMANINDLA04@GMAIL.COM',
    30000, 25500, 3814, 686, 4500, 686.44, 0, 0, 3813.56,
    33, 0.75, 37425, '2025-12-29', '2026-01-31', '''5297215704', 'AXIS BANK',
    'UTIB0005144', 'INF/NEFT/IN42536350612308/UTIB0005144/63918519 /                              /INDLARAMANL', 'DISBURSED', 'NEW', 'POOJA', 'ASHISH',
    'S.NO-46/2 B T KAWADE ROAD BHAGYSHREE NAGAR GHORPUDI GAON PUNE CITY MUNDHVA PUNE MAHARASHTRA 411036 B T KAWADE ROAD BHAGYSHREE NAGAR GHORPUDI GAON PUNE CITY MUNDHVA PUNE MAHARASHTRA 411036  411036', 'TATA CONSULTANCY SERVICES SAHYADRI PARK: PLOT 2 & 3, PHASE III, HINJEWADI, PUNE â€“ 411057, MAHARASHTRA, INDIA  411057', 170, '121-180', 'December, 2025', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    2024, 'Maharashtra', 'Thane', 'LOA00002560', 'BHVPM8951P', 'ACGLLLOT00000001159', 'NITESH NANDKISHOR MURUDKAR', 9324272293, 'NITESH.WEDMANTRAA@GMAIL.COM',
    30000, 25500, 3814, 686, 4500, 686.44, 0, 0, 3813.56,
    40, 0.75, 39000, '2025-12-29', '2026-02-07', '''32668276133', 'STATE BANK OF INDIA',
    'SBIN0005355', 'INF/NEFT/IN42536350895926/SBIN0005355/63951499 /                              /NITESHNANDK', 'DISBURSED', 'NEW', 'KISHAN KUMAR', 'NAVEEN',
    'FLAT NO. D/601 6TH FLOOR  NEAR RK BAJAR, DOMBIVLI EAST 421201 NEAR RK BAJAR, DOMBIVLI 421201', 'SIGMA AVIT INFRA SERVICES PVT LTD G BLOCK BANDRA KURLA COMPLEX GATE NO.7 BANDRA EAST MUMBAI 400098 JIO WORLD CONVENTION CENTRE 400098', 163, '121-180', 'December, 2025', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    2095, 'West Bengal', 'Howrah', 'LOA00001860', 'AXMPC6322N', 'ACGLLLOT00000001198', 'SINCHAN  CHATTERJEE', 9903195203, 'SINCHAN.CHATTERJEE91@GMAIL.COM',
    22000, 18700, 2797, 503, 3300, 503.39, 0, 0, 2796.61,
    32, 0.85, 27984, '2025-12-30', '2026-01-31', '''920010049891470', 'AXIS BANK',
    'UTIB0001355', 'INF/NEFT/IN42536451437987/UTIB0001355/63999980 /                              /SINCHANCHAT', 'DISBURSED', 'REPEAT', 'GARISHMA', 'NAVEEN',
    'SINCHAN CHATTERJEE  GR-FR  65 TANTI PARA LANE  LP-225/14/1 HOWRAH 711104  711104', 'HINDALCO INDUSTRIES LTD HINDALCO INDUSTRIES LIMITED  39 GT ROAD BELURMATH HOWRAH 711202 NEAR BELURMATH 711202', 170, '121-180', 'December, 2025', 'PART-PAYMENT'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    2065, 'West Bengal', '24 Parganas', 'LOA00001994', 'BJJPS4816B', 'ACGLLLOT00000001170', 'SOURAV  SINHA', 8017224682, 'SINHA11SOURAV@GMAIL.COM',
    42000, 35700, 5339, 961, 6300, 961.02, 0, 0, 5338.98,
    32, 0.75, 52080, '2025-12-30', '2026-01-31', '''07341140006153', 'HDFC BANK',
    'HDFC0000734', 'INF/NEFT/IN42536451290675/HDFC0000734/63981993 /                              /SOURAVSINHA', 'DISBURSED', 'REPEAT', 'SHIVAM SHARMA', 'NAVEEN',
    'B 302 AMAR BASHA-1 848 JHILPAR ROAD MAHAMAYATALA GARIA RAJPUR SONARPUR 700103  700103', 'MJUNCTION SERVICES LIMITED GODREJ WATERSIDE TOWER 1, 3RD FLOOR, PLOT NO. 5, BLOCK DP SECTOR V, SALT LAKE CITY  700091', 170, '121-180', 'December, 2025', 'PART-PAYMENT'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    2079, 'Maharashtra', 'Thane', 'LOA00002573', 'BKJPS7880L', 'ACGLLLOT00000001185', 'ANAND ANANT SARANG', 9082786368, 'ANANDSARANG77@GMAIL.COM',
    30000, 25500, 3814, 686, 4500, 686.44, 0, 0, 3813.56,
    32, 0.75, 37200, '2025-12-30', '2026-01-31', '''60525855851', 'BANK OF MAHARASHTRA',
    'MAHB0000016', 'INF/NEFT/IN42536451376834/MAHB0000016/63992787 /                              /ANANDANANTS', 'DISBURSED', 'NEW', 'KISHAN KUMAR', 'NAVEEN',
    'C-26, APARNA SOCIETY, MITH BANDAR ROAD,  CHENDANI KOLIWADA, THANE EAST, THANE, MAHARASHTRA, 400603 NEAR SADGURU GARDEN, 400603', 'BLACK BOX LIMITED 501, BUILDING 09, GIGAPLEX IT PARK, MINDSPACE, WEST, MIDC INDUSTRIAL AREA, AIROLI, NAVI MUMBAI, MAHARASHTRA 400708 GIGAPLEX IT PARK 400708', 170, '121-180', 'December, 2025', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    2082, 'Maharashtra', 'Thane', 'LOA00002575', 'AAZPU2917P', 'ACGLLLOT00000001189', 'ABHISHEK MAHADEV UTTEKAR', 9769845271, 'ABHISHEK.UTEKAR11@GMAIL.COM',
    60000, 51000, 7627, 1373, 9000, 1372.88, 0, 0, 7627.12,
    31, 0.75, 73950, '2025-12-30', '2026-01-30', '''3846052783', 'KOTAK MAHINDRA BANK LIMITED',
    'KKBK0000670', 'INF/NEFT/IN42536451437941/KKBK0000670/63999980 /                              /ABHISHEKMAH', 'DISBURSED', 'NEW', 'PIYUSH', 'NAVEEN',
    '4A/04,KHOPAT ROAD, SINGH NAGAR, THANE WEST, THANE, MAHARASHTRA, IN,THANE,P AREIRA NAGAR CHS KHOPAT,,THANE,MAHARASHTRA ,400601 THANE MAHARASHTRA,  400601', 'KOTAK MAHINDRA BANK KEROM BUILDING ROAD 22 WAGHLE ESTATE THANE WEST 400604  400604', 171, '121-180', 'December, 2025', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    2125, 'Telangana', 'Hyderabad', 'LOA00002589', 'CTTPS2371C', 'ACGLLLOT00000001230', 'SATYANVESH  MUPPANENI', 8885210888, 'SATYANVESH.MUPPANENI@GMAIL.COM',
    50000, 42500, 6356, 1144, 7500, 1144.07, 0, 0, 6355.93,
    31, 0.75, 61625, '2025-12-31', '2026-01-31', '''082194812006', 'HSBC BANK',
    'HSBC0500002', 'INF/NEFT/IN42536551995943/HSBC0500002/64042628 /                              /SATYANVESHM', 'DISBURSED', 'NEW', 'KISHAN KUMAR', 'NAVEEN',
    'FLAT S2 RADHIKA RESIDENCY. PLOT 19 WOMENS CO-OP HOUSING SOCIETY, , JUBILEE HILLS ROAD NUMBER 2, YOUSUFGUDA, PO:YOUSUFGUDA, DIST:HYDERABAD, TELANGANA, 500045 SAI BABA TEMPLE LANE 500045', 'ENDURANCE INTERNATIONAL GROUP (INDIA) PRIVATE LIMITED UNIT NO.401, 4TH FLOOR, IT BUILDING 3, NESCO IT PARK, NESCO COMPLEX, WESTERN EXPRESS HIGHWAY, GOREGAON (EAST),, MUMBAI - 400063 NESCO COMPLEX, 400063', 170, '121-180', 'December, 2025', 'PART-PAYMENT'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    2129, 'Delhi', 'New Delhi', 'ADV00000975', 'BWRPS3364P', 'ACGLLLOT00000001222', 'ABHISHEK  SONI', 9718798880, '0311.ABHISHEK@GMAIL.COM',
    47000, 39950, 5975, 1075, 7050, 0, 537.71, 537.71, 5974.58,
    31, 0.75, 57927.5, '2025-12-31', '2026-01-31', '''50100340761342', 'HDFC BANK',
    'HDFC0000003', 'INF/NEFT/IN42536551995906/HDFC0000003/64042628 /                              /ABHISHEKSON', 'DISBURSED', 'REPEAT', 'POOJA', NULL,
    'MB 63, 3RD FLOOR GALI NO 3 SHAKARPUR DEL,BLOCK S1, NANAKPURA, SHAKARPUR, D ELHI, 110092 NEAR METRO SHAKARPUR 110092', 'MANKIND PHARMA LIMITED 208,OKHLA INDUSTRIAL ESTATE,PHASE-3 NEW DELHI DL 110020 NEAR BHARAT LOAN 110020', 170, '121-180', 'December, 2025', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    2142, 'Karnataka', 'Bangalore', 'LOA00002391', 'KCCPS5219H', 'ACGLLLOT00000001232', 'SHAIK RASHEED BASHA', 8088009120, 'RASHEEDSHAIK.5185@GMAIL.COM',
    38000, 32300, 4831, 869, 5700, 869.49, 0, 0, 4830.51,
    36, 0.75, 48260, '2025-12-31', '2026-02-05', '''50100816630100', 'HDFC BANK',
    'HDFC0003962', 'INF/NEFT/IN42536552382461/HDFC0003962/64080854 /                              /SHAIKRASHEE', 'DISBURSED', 'REPEAT', 'SHIVAM SHARMA', 'NAVEEN',
    'SY. NO, 44/7, KRISHNA NILAYA, 2ND ''A'' MAIN, MUNESHWARA NAGAR, HSR LAYOUT 6TH SECTOR  560068', 'VELANKANI SOFTWARE PRIVATE LTD. VELANKANI TECH PARK, ELECTRONIC CITY PHASE 1,  560100', 165, '121-180', 'December, 2025', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    2153, 'Maharashtra', 'Thane', 'LOA00002593', 'AATPI1380E', 'ACGLLLOT00000001252', 'GIRISH VENKATRAMAN IYER', 8879049404, 'IYERGIRISH@REDIFFMAIL.COM',
    25000, 21250, 3178, 572, 3750, 572.03, 0, 0, 3177.97,
    33, 0.75, 31187.5, '2025-12-31', '2026-02-02', '''5727417119', 'AXIS BANK BRANCH',
    'UTIB0005113', 'INF/NEFT/IN42536552382477/UTIB0005113/64080854 /                              /GIRISHVENKA', 'DISBURSED', 'NEW', 'POOJA', 'NAVEEN',
    '803, CASA PRIMIA E, LAKESHORE GREENS, PALAVA CITY, DOMBIVILLI EAST, MUMBAI -421204  421204', 'TCS TCS, OLYMPUS, OPP RODAS ENCLAVE, HIRANANDANI ESTATE, THANE WEST, MUMBAI- 400060  400060', 168, '121-180', 'December, 2025', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    2175, 'Maharashtra', 'Raigarh', 'LOA00002097', 'KDEPS0808F', 'ACGLLLOT00000001261', 'HANSRAJ  SARAN', 9145945569, 'HANSRAJSARAN7665@GMAIL.COM',
    30000, 25500, 3814, 686, 4500, 686.44, 0, 0, 3813.56,
    31, 0.85, 37905, '2025-12-31', '2026-01-31', '''5120771470', 'CENTRAL BANK OF INDIA',
    'CBIN0283746', 'INF/NEFT/IN42536552481775/CBIN0283746/64088223 /                              /HANSRAJSARA', 'DISBURSED', 'REPEAT', 'GARISHMA', 'NAVEEN',
    'FLAT NO-4O2 PLOT NO-328 BHOSLE COLONE SECTAO 24 UPAHÂ¥EL, RAIGND ULWO-41O206 FLAT NO-4O2 PLOT NO-328 BHOSLE COLONE SECTAO 24 UPAHÂ¥EL, RAIGND ULWO-41O206  410206', 'SNAPMINT CREDIT ADVISORY PRIVATE LIMITED SNAPMINT CREDIT ADVISORY PRIVATE LIMITED 801, TRISHUL GOLDMINES, PALM BEACH RD, SECTOR 15 CBD BELAPUR NAVI MUMBAI - 400614 - 400016 SNAPMINT CREDIT ADVISORY PRIVATE LIMITED 801, TRISHUL GOLDMINES, PALM BEACH RD, SECTOR 15 CBD BELAPUR NAVI MUMBAI - 400614 - 400016  400016', 170, '121-180', 'December, 2025', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    2179, 'Telangana', 'Hyderabad', 'LOA00002195', 'CSMPA3030N', 'ACGLLLOT00000001266', 'SADALA  AKASH', 8341713772, 'AKASHSIDDU45@GMAIL.COM',
    22000, 18700, 2797, 503, 3300, 503.39, 0, 0, 2796.61,
    31, 0.85, 27797, '2025-12-31', '2026-01-31', '''75770100016743', 'BANK OF BARODA',
    'BARB0VJKULY', 'INF/NEFT/IN42536552481777/BARB0VJKULY/64088223 /                              /SADALAAKASH', 'DISBURSED', 'REPEAT', 'ASHISH', NULL,
    'PLOT NO C 179/2 PHASE 2 ALWYN COLONY KUKATPALLY HYDERABAD TELANGANA - 500072  500073', 'CLA INDUS VALUE CONSULTING PRIVATE LIMITED 103 - 104, 10TH FLOOR, MAKER CHAMBER, NARIMAN POINT, MUMBAI MUMBAI - 400021, MAHARASHTRA  400022', 170, '121-180', 'December, 2025', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    2186, 'Karnataka', 'Bangalore', 'LOA00002319', 'ANIPN7302B', 'ACGLLLOT00000001270', 'VENKATA RAGHAVENDRA NICHANAMETLA', 9703123128, 'NVRAGHU40@GMAIL.COM',
    40000, 34000, 5085, 915, 6000, 915.25, 0, 0, 5084.75,
    30, 0.85, 50200, '2026-01-01', '2026-01-31', '''915010037982238', 'AXIS BANK',
    'UTIB0002890', 'INF/NEFT/IN42600152787010/UTIB0002890/64105184 /                              /VENKATARAGH', 'DISBURSED', 'REPEAT', 'PIYUSH', 'NAVEEN',
    '322,DSMAX STARLINE ELECTRONIC CITY PHASE 2 OPP TO TCS, BANGALORE- 560100  560100', 'MSN LABORATORIES PVT LTD. SY NO 119 TO 140 .258, 275 PASHAMYLARAM PATANCHERU RANGAREDDY- TELANGANA 502307  502307', 170, '121-180', 'January, 2026', 'PART-PAYMENT'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    2181, 'Karnataka', 'Bangalore', 'LOA00002024', 'BMBPM3618Q', 'ACGLLLOT00000001267', 'SHANMUK  MADABATTULA', 7671950475, 'SHANMUK@LIVE.COM',
    35000, 29750, 4449, 801, 5250, 800.85, 0, 0, 4449.15,
    30, 0.75, 42875, '2026-01-01', '2026-01-31', '''45210132044', 'STANDARD CHARTERED BANK',
    'SCBL0036106', 'INF/NEFT/IN42600152786755/SCBL0036106/64105184 /                              /SHANMUKMADA', 'DISBURSED', 'REPEAT', 'KISHAN KUMAR', NULL,
    '#47, 1ST FLOOR, 4TH CROSS, NEAR NEW CAMBRIDGE SCHOOL, DODDANAGAMANGALA SHANKARAPPA LAYOUT , KONAPPANA AGRAHARA, ELECTRONIC CITY, BENGALURU, KARNATAKA 560100  560100', 'HCL TECH HCL TECH, BOMMASANDRA JIGANI LINK ROAD, BANGLORE, KARNATAKA, 560105  560105', 170, '121-180', 'January, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    2182, 'Karnataka', 'Bangalore', 'LOA00002356', 'ERXPS9445B', 'ACGLLLOT00000001268', 'SRINIVASULU  MANJULA', 8123318896, 'SEENUMANJULA007@GMAIL.COM',
    15000, 12750, 1907, 343, 2250, 343.22, 0, 0, 1906.78,
    30, 0.75, 18375, '2026-01-01', '2026-01-31', '''55550118181369', 'FEDERAL BANK',
    'FDRL0005555', 'INF/NEFT/IN42600152880536/FDRL0005555/64113024 /                              /SRINIVASULU', 'DISBURSED', 'REPEAT', 'KISHAN KUMAR', NULL,
    '58 MANOJ VILLA 4TH CROSS SBM COLONY MATHIKERE  560054', 'MODER SOLUTIONS INDIA PRIVATE LIMITED 9TH FLOOR VIRGO BUILDING BLK B BAGMANE CONSTELLATION BUSSINESS PARK OUTER RING ROAD DADDANEKUNDI MARATHSHALLL  560048', 170, '121-180', 'January, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    2189, 'Telangana', 'Hyderabad', 'LOA00002054', 'ATAPT1643H', 'ACGLLLOT00000001273', 'TARUNKUMAR  RAMAYANAM', 7989672745, 'RTARUN1253@GMAIL.COM',
    25000, 21250, 3178, 572, 3750, 572.03, 0, 0, 3177.97,
    30, 0.85, 31375, '2026-01-01', '2026-01-31', '''921010013271704', 'AXIS BANK',
    'UTIB0000800', 'INF/NEFT/IN42600152824230/UTIB0000800/64107904 /                              /TARUNKUMARR', 'DISBURSED', 'REPEAT', 'GARISHMA', 'NAVEEN',
    'FLAT NO. 104,SRI VISHNU PARIDISE KVR RAIBOW COLONY,BACHUPALLY  500090', 'QUALITEST INDIA PRIVATE LTD 12TH FLOOR, B WING, M2 BLOCK MANYATA NAGAWARA, BANGALORE 560045 EMBASSY BUSINESS PARK OUTER RING ROAD  560045', 170, '121-180', 'January, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    2193, 'Maharashtra', 'Mumbai', 'LOA00002249', 'EGCPS0792B', 'ACGLLLOT00000001272', 'ASIF ALAUDDIN SHAIKH', 8108752898, 'ASIFIQBALSHAIKH8@GMAIL.COM',
    15000, 12750, 1907, 343, 2250, 343.22, 0, 0, 1906.78,
    32, 0.75, 18600, '2026-01-01', '2026-02-02', '''50100411056925', 'HDFC BANK',
    'HDFC0001204', 'INF/NEFT/IN42600152880554/HDFC0001204/64113024 /                              /ASIFALAUDDI', 'DISBURSED', 'REPEAT', 'POOJA', NULL,
    'PLOT NO 37 INDRA NAGAR BAIGAHWA BHARAT NAGAR MASJID GOVINDI  400043', 'SAPPHIRE FOODS INDIA LIMITED 702, A-WING, PRISM TOWER, MINDSPACE, GOREGAON WEST, MUMBAI - 400 062. MAHARASHTRA  400062', 168, '121-180', 'January, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    2212, 'Karnataka', 'Bangalore', 'LOA00002597', 'ABDPK9156B', 'ACGLLLOT00000001295', 'SRIKANTA SHAMARAO KURANDWAD', 9243700588, 'SRIKANTSK26@GMAIL.COM',
    25000, 21250, 3178, 572, 3750, 572.03, 0, 0, 3177.97,
    29, 0.75, 30437.5, '2026-01-02', '2026-01-31', '''10245008462', 'IDFC FIRST BANK',
    'IDFB0080171', 'INF/NEFT/IN42600253144068/IDFB0080171/64129961 /                              /SRIKANTASHA', 'DISBURSED', 'NEW', 'DEEPAK KUMAR', 'ASHISH',
    'SY.NO# 19/1, DOOR NO.30, (1ST FLOOR), 1ST ''A''  MAIN,   1ST  ''A'' CROSS, HRUSHIKESHA NAGAR, HOSAKERAHALLI, BANASHANKARI 3RD STAGE, BANGALORE  560085  560085', 'TATA ADVANCED SYSTEMS LIMITED(SED) TATA ADVANCED SYSTEMS LIMITED,  NO. 42/43,  ELECTRONIC  CITY, HOSUR ROAD,  PHASE-I, BANGALORE  560100, NEXT TO INFOSYS CAMPUS. 560100', 170, '121-180', 'January, 2026', 'PART-PAYMENT'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    2224, 'Maharashtra', 'Thane', 'LOA00002281', 'APVPG8741A', 'ACGLLLOT00000001300', 'SANDESH DILIP GAIKWAD', 8007039599, 'SANDYGAIKWAD1386@GMAIL.COM',
    26000, 22100, 3305, 595, 3900, 594.92, 0, 0, 3305.08,
    34, 0.75, 32630, '2026-01-02', '2026-02-05', '''50100554845852', 'HDFC BANK',
    'HDFC0000592', 'INF/NEFT/IN42600253537875/HDFC0000592/64170053 /                              /SANDESHDILI', 'DISBURSED', 'REPEAT', 'DEEPAK KUMAR', 'NAVEEN',
    'C-24, MAITRI PARK CHS, SURYANAGAR, VITAWA, THANE, 400605 NEAR SAI BABA TEMPLE 400605', 'BUILD SQUARE BUILD SQUARE,  GROUND FLOOR, SHARDA SANGEET VIDYALAY, KALANAGAR, BANDRA EAST, 400051  400051', 165, '121-180', 'January, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    2237, 'Maharashtra', 'Thane', 'LOA00002294', 'BMNPS0247R', 'ACGLLLOT00000001310', 'SHASHANK  SRIVASTAVA', 7448228698, 'SHASHANK.AMITA12@GMAIL.COM',
    32000, 27200, 4068, 732, 4800, 732.2, 0, 0, 4067.8,
    31, 0.75, 39440, '2026-01-02', '2026-02-02', '''50100204072955', 'HDFC BANK',
    'HDFC0000542', 'INF/NEFT/IN42600253613220/HDFC0000542/64176406 /                              /SHASHANKSRI', 'DISBURSED', 'REPEAT', 'POOJA', NULL,
    'FLAT NO-505, BLDG NO-19, H-AVENUE, RUSTOMJI EVERSHINE GLOBAL CITY, VIRAR WEST, DISTT- THANE, PIN-401303  401303', 'STAR HEALTH & ALLIED INSURANCE CO LTD 1ST FLOOR, POONAM CHAMBERS, SHANTI NAGAR-SECTOR-3, MIRA ROAD-EAST, THANE-401107  401107', 168, '121-180', 'January, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    2216, 'Karnataka', 'Bangalore', 'LOA00002347', 'BKRPP1295C', 'ACGLLLOT00000001315', 'BRAJA KISHORE PRADHAN', 9937021411, 'BRJK88@GMAIL.COM',
    12000, 10800, 1017, 183, 1200, 183.05, 0, 0, 1016.95,
    28, 1.1, 15696, '2026-01-03', '2026-01-31', '''1148991762', 'KOTAK MAHINDRA BANK LIMITED',
    'KKBK0008042', 'INF/NEFT/IN42600354015129/KKBK0008042/64202784 /                              /BRAJAKISHOR', 'DISBURSED', 'REPEAT', 'GARISHMA', NULL,
    'NO. 27, SRI NANJUDESHWARA NILAYA FLAT NO  B-2 1ST FLOOR MUNNEKOLLALA MARATHAHALLI NEAR SOMESHWARA SWAMY TEMPLE 560037', 'TELEPERFORMANCE GLOBAL BUSINESS PRIVATE LIMITED TELEPERFORMANCE, SMARTWORKS, KUNDALAHALLI SQR, I FRONT OF ACIS BANK, MARTHALLI,Â 560037 I FRONT OF AXIS BANK, MARTHALLI,Â 560037  560037', 170, '121-180', 'January, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    2250, 'Delhi', 'New Delhi', 'LOA00002374', 'EDUPR7999E', 'ACGLLLOT00000001319', 'ANKIT  RANA', 7290911707, 'ANKITRANA14JUL.AR@GMAIL.COM',
    16000, 13600, 2034, 366, 2400, 0, 183.05, 183.05, 2033.9,
    33, 0.75, 19960, '2026-01-03', '2026-02-05', '''2401210056230281', 'AU SMALL FINANCE BANK LIMITED',
    'AUBL0002100', 'INF/NEFT/IN42600354015226/AUBL0002100/64202784 /                              /ANKITRANA', 'DISBURSED', 'REPEAT', 'DEEPAK KUMAR', 'NAVEEN',
    'RZG-53 GALI NO 2 RAJ NAGAR 2 PALAM COLONY SOUTH WEST DELHI 110077. NEAR FUN VALLEY PLAY SCHOOL 110077', 'GRAYQUEST EDUCATION FINANCE PVT LTD 202 CENTRE POINT BUILDING, PAREL, MUMBAI 400012  400012', 165, '121-180', 'January, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    2257, 'Telangana', 'Rangareddy', 'LOA00002385', 'AENPV1256J', 'ACGLLLOT00000001326', 'MASANAM  VENU', 8440077188, 'VENUKALYAN81@YAHOO.CO.IN',
    22000, 18700, 2797, 503, 3300, 503.39, 0, 0, 2796.61,
    28, 0.75, 26620, '2026-01-03', '2026-01-31', '''50100789001904', 'HDFC BANK LTD',
    'HDFC0009401', 'INF/NEFT/IN42600354304005/HDFC0009401/64229707 /                              /MASANAMVENU', 'DISBURSED', 'REPEAT', 'DEEPAK KUMAR', 'NAVEEN',
    'PLOT NO 32 B SRINAGAR TOWNSHIP TORROR HAYATNAGAR HYDERABAD 501511  501511', 'HDFC LIFE INSURANCE COMPANY LIMITED 13TH FLOOR , LODHA EXCELUS, APOLLO MILLS COMPOUND, N.M. JOSHI ROAD MAHALAXMI MUMBAI-400011  400011', 170, '121-180', 'January, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    2277, 'Gujarat', 'Ahmedabad', 'ADV00001683', 'BCSPC9140G', 'ACGLLLOT00000001338', 'CHAUDHARI NAYAN LAKHABHAI', 9974462936, 'NAYAN.CHAUDHARI9974@GMAIL.COM',
    20000, 17000, 2542, 458, 3000, 457.63, 0, 0, 2542.37,
    31, 0.85, 25270, '2026-01-06', '2026-02-06', '''2501262385616553', 'AU SMALL FINANCE BANK LIMITED',
    'AUBL0002623', 'INF/NEFT/IN42600656101922/AUBL0002623/64345979 /                              /CHAUDHARINA', 'DISBURSED', 'REPEAT', 'ASHISH', NULL,
    'B 204 FORAM APPARTMENT , NR DHARTI CROSS ROAD ,CHANDLODIA AHMEDABAD B 204 FORAM APPARTMENT , NR DHARTI CROSS ROAD ,CHANDLODIA AHMEDABAD FORAM APPARTMENT 382481', 'ASTRAL LIMITED ASTRAL HOUSE ,SINDHUBHAVAN ROAD ,THALTEJ ASTRAL HOUSE ,SINDHUBHAVAN ROAD ,THALTEJ SINDHYBHAVAN ROAD 380059', 164, '121-180', 'January, 2026', 'PART-PAYMENT'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    2281, 'Maharashtra', 'Mumbai', 'LOA00002329', 'ALSPP8024A', 'ACGLLLOT00000001339', 'RAJESH SHASHIKANT PUJARI', 9769381278, 'RAJESHSPUJARI1981@GMAIL.COM',
    26000, 22100, 3305, 595, 3900, 594.92, 0, 0, 3305.08,
    31, 0.75, 32045, '2026-01-06', '2026-02-06', '''00000010580849796', 'STATE BANK OF INDIA',
    'SBIN0001886', 'INF/NEFT/IN42600656256557/SBIN0001886/64358833 /                              /RAJESHSHASH', 'DISBURSED', 'REPEAT', 'POOJA', NULL,
    '1/14 ICHCHAPURTI COOPERATIVE HOSUING SOCIETY LIMITED WADIA ESTATE KURLA WEST BAILBAZAR  400070', 'MICE AND MEGA SOLUTIONS PRIVATE LIMITED 601, ORION, JAWAHARLAL NEHRU ROAD, SEN NAGAR, SANTACRUZ (EAST)  400055', 164, '121-180', 'January, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    2300, 'Gujarat', 'Ahmedabad', 'LOA00002109', 'CCWPS7018G', 'ACGLLLOT00000001346', 'SONI  SHYAMNARAYAN', 9825524231, 'SONISHYAM2@GMAIL.COM',
    44000, 37400, 5593, 1007, 6600, 1006.78, 0, 0, 5593.22,
    30, 0.75, 53900, '2026-01-07', '2026-02-06', '''50100324483303', 'Hdfc Bank Ltd',
    'HDFC0009326', 'INF/NEFT/IN42600757166339/HDFC0009326/64422177 /                              /SONISHYAMNA', 'DISBURSED', 'REPEAT', 'POOJA', NULL,
    'C706, VRAJDHAM FLATS, NK PATEL ESTATE ROAD, , NR UJALA CIRCLE, SARKHEJ, AHMEDABAD - 382210  382210', 'CHINMAY FINLEASE LTD HOUSE NO 14, TIMES CORPORATE PARK, OPP COPPER STONE FLATS, THALTEJ, AHMEDABAD - 380059  380059', 164, '121-180', 'January, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    2310, 'Karnataka', 'Bangalore', 'LOA00002603', 'DIVPM5355Q', 'ACGLLLOT00000001357', 'MANO VISHWAS REDDY L', 9008528061, 'MANOVISHWAS@GMAIL.COM',
    30000, 25500, 3814, 686, 4500, 686.44, 0, 0, 3813.56,
    34, 0.75, 37650, '2026-01-07', '2026-02-10', '''316801506701', 'ICICI BANK LTD',
    'ICIC0003168', 'INF/INFT/042926633331/64452064     /MANOVISHWASREDDYL   /', 'DISBURSED', 'NEW', 'PIYUSH', 'ASHISH',
    '14, 7TH CROSS NYAYAPANAHALLI MAIN ROAD NEAR SONA VISTAS APARTMENT GATE BANGALORE 560068  560068', 'INFLEXION INFOTECH PRIVATE LIMITED 2ND FLOOR KASTHOORI PLAZA KASTURI NAGAR BANGALORE 560043  560043', 160, '121-180', 'January, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    2339, 'Karnataka', 'Bangalore', 'LOA00002606', 'LLZPS1199H', 'ACGLLLOT00000001369', 'SAKSHATH H S', 9663592574, 'SAKSHATHG@GMAIL.COM',
    15000, 12750, 1907, 343, 2250, 343.22, 0, 0, 1906.78,
    23, 0.75, 17587.5, '2026-01-08', '2026-01-31', '''8749227917', 'KOTAK MAHINDRA BANK LIMITED',
    'KKBK0000431', 'INF/NEFT/IN42600858944692/KKBK0000431/64544743 /                              /SAKSHATHHS', 'DISBURSED', 'NEW', 'DEEPAK KUMAR', 'KISHAN KUMAR',
    'FLAT NO C012 C BLOCK NYDILE RESIDENCY BANNERGHATTA ROAD GOTTIGERE BANGLORE 560083 GOTTIGERE BUS STOP 560083', 'KOTAK MAHINDRA LIFE INSURANCE COMPANY LIMITED 2013, 100 FEET RD, HAL 2ND STAGE, APPAREDDIPALYA, INDIRANAGAR, BENGALURU, KARNATAKA 560038  560083', 170, '121-180', 'January, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    2371, 'Maharashtra', 'Mumbai', 'ADV00001787', 'ATTPJ3107H', 'ACGLLLOT00000001383', 'TRUPTI SHRIKANT JOSHI', 9867493501, 'TRPTJSH@GMAIL.COM',
    35000, 29750, 4449, 801, 5250, 800.85, 0, 0, 4449.15,
    22, 0.75, 40775, '2026-01-09', '2026-01-31', '''50100315253510', 'HDFC BANK',
    'HDFC0001118', 'INF/NEFT/IN42600959588891/HDFC0001118/64591234 /                              /TRUPTISHRIK', 'DISBURSED', 'NEW', 'KISHAN KUMAR', 'NAVEEN',
    '803,FLOOR-8TH,PLOT-165, HIRANYA,D L VAIDYA ROAD,NEAR SWAMI SAMARTHA MATH,DADAR (W),MUMBAI400028 NEAR SWAMI SAMARTHA 400028', 'LOYLTY REWARDZ MANAGEMENT PVT. LTD. 2ND FLOOR CHHIBBER HOUSE SAKINAKA, JUNCTION, ANDHERI - KURLA RD, ANDHERI EAST, MUMBAI, MAHARASHTRA 400072 NEAR AIROLI 400104', 170, '121-180', 'January, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    2376, 'Maharashtra', 'Pune', 'LOA00002617', 'AIFPR1453H', 'ACGLLLOT00000001386', 'VAIBHAV VIJAY RAICH', 9960609369, 'VRAICH@GMAIL.COM',
    50000, 45000, 4237, 763, 5000, 762.71, 0, 0, 4237.29,
    21, 1, 60500, '2026-01-09', '2026-01-30', '''309023118223', 'THE RATNAKAR BANK LTD',
    'RATN0000513', 'INF/NEFT/IN42600959793358/RATN0000513/64609198 /                              /VAIBHAVVIJA', 'DISBURSED', 'NEW', 'PIYUSH', 'NAVEEN',
    'C2-202, MICASAA APT, KESNAND ROAD, OPPOSITE AYURVEDIC COLLEGE, WAGHOLI, PUNE - 412207  412207', 'OPTIVA INDIA OPTIVA INDIA HAS A REGISTERED ADDRESS AT KUMAR SURBHI, BUILDING A, FLAT 1205, SR. NO. 38/4 A/1, OPP. SAIBABA MANDIR, PARVATI, PUNE, 411009 OPTIVA INDIA  411009', 171, '121-180', 'January, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    2428, 'Telangana', 'Hyderabad', 'LOA00002630', 'AJDPT3323K', 'ACGLLLOT00000001406', 'TUMULURI VENKATA SARATH KUMAR', 9502255211, 'TUMULURISARATHKUMAR@GMAIL.COM',
    25000, 21250, 3178, 572, 3750, 572.03, 0, 0, 3177.97,
    21, 0.75, 28937.5, '2026-01-10', '2026-01-31', '''10183896433', 'IDFC BANK',
    'IDFB0080218', 'INF/NEFT/IN42601050898361/IDFB0080218/64683191 /                              /TUMULURIVEN', 'DISBURSED', 'NEW', 'ASHISH', 'NAVEEN',
    'HOUSE ADDRESS  1-5-528/1 SURYA NAGAR COLONY OLD ALWAL APPOLLO PHARMACY ROAD OLD ALWAL SECUNDERABAD 500010 HOUSE ADDRESS  1-5-528/1 SURYA NAGAR COLONY OLD ALWAL APPOLLO PHARMACY ROAD OLD ALWAL SECUNDERABAD 500010  500012', 'OPTUM GLOBAL SOLUTIONS (INDIA) PRIVATE LIMITED 1ST 2ND & 3RD H06 PHOENIX INFOCITY PRIVATE LIMITED SEZ, SIDDIQ NAGAR, HITEC CITY, HYDERABAD, TELANGANA 500081 1ST 2ND & 3RD H06 PHOENIX INFOCITY PRIVATE LIMITED SEZ, SIDDIQ NAGAR, HITEC CITY, HYDERABAD, TELANGANA 500081  500006', 170, '121-180', 'January, 2026', 'PART-PAYMENT'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    2507, 'Telangana', 'Hyderabad', 'LOA00002656', 'CHSPD4282Q', 'ACGLLLOT00000001439', 'DYAVARASHETTY  MANIDEEP', 9550199898, 'MANIDEEPD79@GMAIL.COM',
    30000, 25500, 3814, 686, 4500, 686.44, 0, 0, 3813.56,
    17, 0.75, 33825, '2026-01-13', '2026-01-30', '''110219710373', 'CANARA BANK',
    'CNRB0013302', 'AXISAN0008618270 / DYAVARASHETTY MANIDEEP', 'DISBURSED', 'NEW', 'GARISHMA', 'KISHAN KUMAR',
    'PLOT-75/A,2ND FLOOR, , SRINIVASA COLONY, , NIZAMPET, NHYDERNAGAR HYDERABAD - 500090 PLOT-75/A,2ND FLOOR, , SRINIVASA COLONY, , NIZAMPET, HYDERNAGAR HYDERABAD  -500090  500090', 'LTIMINDTREE LIMITED LT METRO BUILDING  LUMBINI AVENUE  GACHIBOWLI HYDERABAD TELAGANA-500032  500033', 171, '121-180', 'January, 2026', 'PART-PAYMENT'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    2486, 'Telangana', 'Medak', 'LOA00002668', 'CBWPK3635G', 'ACGLLLOT00000001452', 'KOMIRELLY GLORY MARIA REDDY', 8179648351, 'GLORY.VARSHAREDDY89@GMAIL.COM',
    35000, 29750, 4449, 801, 5250, 800.85, 0, 0, 4449.15,
    17, 0.75, 39462.5, '2026-01-14', '2026-01-31', '''50100086872148', 'HDFC BANK',
    'HDFC0002083', 'AXISAN0008646111', 'DISBURSED', 'NEW', 'SANA PARVEEN', 'NAVEEN',
    'PLOT NO Q26, SAIRAM ENCLAVE PHASE 2 AMEENPUR VILLAGE, NEAR LAKSHMI NIVAS, AMEENPUR MANDAL AMEENAPUR, SANGAREDDY, TELANGANA, 502032 NEAR LAKSHMI NIVAS 502032', 'STATE STREET CORPORATE SERVICES MUMBAI PRIVATE LIMITED FLOOR 2 ORWELL BUILDING SALARPURIA SATTVA KNOWLEDGE CITY RAIDURG MADHAPUR HYDERABAD 500080 ORWELL BUILDING 500080', 170, '121-180', 'January, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    2561, 'Telangana', 'Hyderabad', 'LOA00002672', 'BBPPN3594P', 'ACGLLLOT00000001456', 'NALLABATHULA  SURESH', 7032725002, 'SNALLA79@GMAIL.COM',
    65000, 55250, 8263, 1487, 9750, 1487.29, 0, 0, 8262.71,
    22, 0.75, 75725, '2026-01-14', '2026-02-05', '''916010032930297', 'AXIS BANK',
    'UTIB0000425', 'AI0001623229 NALLABATHULA SURESH', 'DISBURSED', 'NEW', 'KISHAN KUMAR', 'NAVEEN',
    'FLAT NO.204 ,NARAYANADRI, TIRUMALA HILLS ,PRAGATHI NAGAR,HYDERABAD,TELANGANA,500000 TIRUMALA HILLS , 500090', 'NMC MANAGED SERVICES UNIT NO 310, HYDERABAD, TELANGANA, 500072 MANJEERA MAJESTIC COMMERCIAL 500072', 165, '121-180', 'January, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    2570, 'Maharashtra', 'Thane', 'LOA00002676', 'HLJPD3213F', 'ACGLLLOT00000001462', 'MAANOJ RAAMEISH DEVARUKAKAR', 8108360307, 'MAANOJRD@GMAIL.COM',
    45000, 38250, 5720, 1030, 6750, 1029.66, 0, 0, 5720.34,
    17, 0.75, 50737.5, '2026-01-14', '2026-01-31', '''110231665079', 'CANARA BANK',
    'CNRB0015480', 'AXISAN0008646109', 'DISBURSED', 'NEW', 'KISHAN KUMAR', 'NAVEEN',
    'FLAT NO 207, 2ND FLOOR ,PRIMEROSE BUILDING, REGENCY ANANTAM BLDG 20, KALYAN SHIL ROAD, DAWADI,DOMBIVALI EAST, ASADE (N.V.), PO: DOMBIVALI I.A., DIST: THANE, MAHARASHTRA - 421203 KALYAN SHIL ROAD, 421203', 'HRIDAY DIGITAL SOLUTIONS PRIVATE LIMITED - 07, GNP GALLERY, NEAR REGENCY ANTAM, VICKO NAKA, DOMBIVLI EAST 421203 NEAR REGENCY ANTAM, 421203', 170, '121-180', 'January, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    2574, 'Delhi', 'New Delhi', 'LOA00002677', 'AJXPR7362N', 'ACGLLLOT00000001463', 'POORNIMA  SREEKUMAR', 9910520369, 'SREEKUMAR.POORNIMA@GMAIL.COM',
    20000, 18000, 1695, 305, 2000, 0, 152.54, 152.54, 1694.92,
    17, 1, 23400, '2026-01-14', '2026-01-31', '''50100768918933', 'HDFC BANK',
    'HDFC0002074', 'AXISAN0008638744 POORNIMA SREEKUMAR', 'DISBURSED', 'NEW', 'GARISHMA', 'NAVEEN',
    '178-M B-2 F/F WARD NO-2  YOGMAYA APARTMENT MEHARAULI   NEW DELHI  110030 178-M B-2 F/F WARD NO-2  YOGMAYA APARTMENT MEHARAULI   NEW DELHI  110030  110030', 'NIRMIT BHARAT NIRMIT BHARAT, GROUND FLOOR, ICCW BUILDING, 4 DEEN DAYAL UPADHYAY MARG, NEW DELHI 110002 NIRMIT BHARAT, GROUND FLOOR, ICCW BUILDING, 4 DEEN DAYAL UPADHYAY MARG, NEW DELHI 110002  110002', 170, '121-180', 'January, 2026', 'PART-PAYMENT'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    2598, 'Karnataka', 'Bangalore', 'LOA00002685', 'ARAPJ7356F', 'ACGLLLOT00000001472', 'JAGADISH  B S', 6366333808, 'JAGDEESHB2@GMAIL.COM',
    70000, 59500, 8898, 1602, 10500, 1601.69, 0, 0, 8898.31,
    17, 0.75, 78925, '2026-01-14', '2026-01-31', '''10123218426', 'Idfc Bank',
    'IDFB0080152', 'AXISAN0008646115', 'DISBURSED', 'NEW', 'POOJA', 'NAVEEN',
    '70, 2ND MAIN, 6TH STAGE 8TH BLOCK BANASHAKARI BANGALORE 560060 70, 2ND MAIN, 6TH STAGE 8TH BLOCK BANASHAKARI BANGALORE 560060  560060', 'GLOBALLOGIC INDIA PRIVATE LIMITED PRITECH PARK SEZ, 4TH FLOOR, BLOCK 12 , RMZ ECOSPACE, MARATHAHALLI SARJAPUR OUTER RING RD, BELLANDUR, BENGALURU, KARNATAKA 560103  560103', 170, '121-180', 'January, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    2621, 'Maharashtra', 'Thane', 'LOA00002689', 'CJLPP7818P', 'ACGLLLOT00000001481', 'PRASAD SUHAS PATIL', 9920610151, 'PRASAD10PATIL@GMAIL.COM',
    18000, 15300, 2288, 412, 2700, 411.86, 0, 0, 2288.14,
    32, 0.75, 22320, '2026-01-15', '2026-02-16', '''319502010053737', 'UNION BANK OF INDIA',
    'UBIN0531952', 'AXISAN0008657952', 'DISBURSED', 'NEW', 'ASHISH', 'NAVEEN',
    '847 AT POST KHARBAV TAL-BHIWANDI DIST-THANE NEAR PETROL PUMP PIN-421302 847 AT POST KHARBAV TAL-BHIWANDI DIST-THANE NEAR PETROL PUMP PIN-421302  421302', 'TALIB AND SHAMSI  CONSTRUCTION  PVT LTD HOH, HIRANANDANI ESTATE, NEAR VIJAY GARDEN ROAD, VAGHBIL, THANE WEST-400615 HOH, HIRANANDANI ESTATE, NEAR VIJAY GARDEN ROAD, VAGHBIL, THANE WEST-400615  400615', 154, '121-180', 'January, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    2640, 'Maharashtra', 'Pune', 'LOA00002705', 'CFUPP5721G', 'ACGLLLOT00000001503', 'ABHINAV SUDHIR PRADHAN', 7350001416, 'ABHINAVPRADHAN007@GMAIL.COM',
    40000, 34000, 5085, 915, 6000, 915.25, 0, 0, 5084.75,
    21, 0.75, 46300, '2026-01-16', '2026-02-06', '''44541370739', 'STATE BANK OF INDIA',
    'SBIN0011701', 'AXISAN0008668569', 'DISBURSED', 'NEW', 'SANA PARVEEN', 'NAVEEN',
    '503 5TH FLOOR B WING GHULE PARK NANDED CITY SINHGAD ROAD PUNE MAHARASHTRA 411041  411041', 'EDENIC ENTERPRISES PVT LTD B 3RD FLOOR, OFFICE, SHRISHTI CHAMBERS, 1196, GHOLE RD, NEAR TUKARAM PADUKA CHOWK, SUD NAGAR, SHIVAJINAGAR, PUNE, MAHARASHTRA 411005  411005', 164, '121-180', 'January, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    2672, 'Karnataka', 'Bangalore', 'LOA00002352', 'AAWPY1339G', 'ACGLLLOT00000001507', 'SURESH  YOGESH', 9986402693, 'SURESH.YOGESH@GMAIL.COM',
    33000, 28050, 4195, 755, 4950, 755.08, 0, 0, 4194.92,
    15, 0.75, 36712.5, '2026-01-16', '2026-01-31', '''2501274785257205', 'AU SMALL FINANCE BANK LIMITED',
    'AUBL0002747', 'AXISAN0008667603', 'DISBURSED', 'REPEAT', 'KISHAN KUMAR', NULL,
    '101/22, SAHAJ ENCLAVE, GROUND FLOOR, RAGHAVENDRA LAYOUT, 22ND MAIN ROAD, PADMANABHA NAGAR BANGALORE KARNATAKA INDIA 560070 PADMANABHA NAGAR 560070', 'MULTIPLIER TECHNOLOGIES INDIA PRIVATE LIMITED REGUS CITYGOLD BUSINESS CENTRE, WORLD TRADE CENTRE, 22ND FLOOR, UNIT NO 2201 , BRIGADE GATEWAY, MALLESHWARAM, BENGALURU, KARNATAKA 560055, INDIA. BRIGADE GATEWAY, MALLESHWARAM, 560055', 170, '121-180', 'January, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    2707, 'Andhra Pradesh', 'Visakhapatnam', 'LOA00002730', 'CPQPM4657E', 'ACGLLLOT00000001537', 'MOHAMMED  SAYEEDULLA', 9030661153, 'SAYEEDMD70@GMAIL.COM',
    30000, 25500, 3814, 686, 4500, 686.44, 0, 0, 3813.56,
    14, 0.75, 33150, '2026-01-17', '2026-01-31', '''110272965054', 'CANARA BANK',
    'CNRB0002500', 'AXISAN0008693928', 'DISBURSED', 'NEW', 'PIYUSH', 'KISHAN KUMAR',
    '13-1224, APSARA COLONY, BESIDE ST ANN''S SCHOOL , ARILOVA, VISAKHAPATNAM 530040  530040', 'RANDSTAD DIGITAL TALENT CENTER PRIVATE LIMITED BUILDING NUMBER 9, MINDSPACE, HYDERABAD, TELANGANA, 500081. BUILDING NUMBER 9, MINDSPACE, HYDERABAD, TELANGANA, 500081.  500081', 170, '121-180', 'January, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    2746, 'Andhra Pradesh', 'Guntur', 'LOA00002735', 'AQYPT6691E', 'ACGLLLOT00000001543', 'CHANDRA SEKHAR TRIPURANENI', 8179294991, 'TRIPURANENI.CHOWDARY31@GMAIL.COM',
    30000, 25500, 3814, 686, 4500, 686.44, 0, 0, 3813.56,
    12, 0.75, 32700, '2026-01-19', '2026-01-31', '''50100687132057', 'HDFC BANK',
    'HDFC0000184', 'AXISAN0008701949', 'DISBURSED', 'NEW', 'ASHISH', 'KISHAN KUMAR',
    'FLAT NO 503 MVR INFRA CAPITAL PRIDE TADEPALLI PRATURU KUNCHANPALLI 522501 - BEHIND AIMEE INTERNATIONAL SCHOOL FLAT NO 503 MVR INFRA CAPITAL PRIDE TADEPALLI PRATURU KUNCHANPALLI 522501 - BEHIND AIMEE INTERNATIONAL SCHOOL  522501', 'HDFC LIFE INSURANCE COMPANY LIMITED 2ND FLR, NO. 38-8-45, SRI VENKATESWARA THEATRE, MG RD, PUNAMMATHOTA, LABBIPET, VIJAYAWADA, ANDHRA PRADESH 520010 2ND FLR, NO. 38-8-45, SRI VENKATESWARA THEATRE, MG RD, PUNAMMATHOTA, LABBIPET, VIJAYAWADA, ANDHRA PRADESH 520010  524003', 170, '121-180', 'January, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    2809, 'Karnataka', 'Bangalore', 'LOA00002378', 'DIVPS2151D', 'ACGLLLOT00000001565', 'N  SRIDHAR', 9620764532, 'SRI.MS.RONALDO07@GMAIL.COM',
    20000, 17000, 2542, 458, 3000, 457.63, 0, 0, 2542.37,
    32, 0.75, 24800, '2026-01-19', '2026-02-20', '''50100683847966', 'HDFC BANK',
    'HDFC0003825', 'AXISAN0008714382', 'DISBURSED', 'REPEAT', 'GARISHMA', NULL,
    'E,188/1, RUDRAPPA  GARDEN,BANGALORE SOUTH,BANGALORE,KARNATAKA  -560047 E,188/1, RUDRAPPA  GARDEN,BANGALORE SOUTH,BANGALORE, KARNATAKA  -560047  560047', 'S2V SAKMAN INDIA SERVICES 531/1, KEMPEGOWDA MAIN RD, OPP. ANJANAIYA TEMPLE, HEBBAL KEMPAPURA, BENGALURU, BYATARAYANAPURA CMC AND OG PART, KARNATAKA 560024 531/1, KEMPEGOWDA MAIN RD, OPP. ANJANAIYA TEMPLE, HEBBAL KEMPAPURA, BENGALURU, BYATARAYANAPURA CMC AND OG PART, KARNATAKA 560024  560024', 150, '121-180', 'January, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    2813, 'Uttar Pradesh', 'Noida', 'LOA00002752', 'DDGPS5765G', 'ACGLLLOT00000001568', 'ANKUSH  SHARMA', 8448874567, 'SHARMAANKUSH@LIVE.COM',
    35000, 29750, 4449, 801, 5250, 800.85, 0, 0, 4449.15,
    40, 0.75, 45500, '2026-01-19', '2026-02-28', '''10222457256', 'IDFC FIRST BANK LTD',
    'IDFB0022143', 'INF/NEFT/IN42601956695669/IDFB0022143/65104737 /                              /ANKUSHSHARM', 'DISBURSED', 'NEW', 'KISHAN KUMAR', 'NAVEEN',
    '402 RG LUXURY HOMES SECTOR 16B GREATER NOIDA WEST PINE CORD 201306 NOIDA . 16B GREATER NOIDA 201301', 'HCL TECH LTD. - IOMC TECHNOLOGY HUB (SEZ, PLOT NO. 3A , SECTOR 126, NOIDA, UTTAR PRADESH 201303 , SECTOR 126 201303', 142, '121-180', 'January, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    2841, 'Karnataka', 'Bangalore', 'LOA00002763', 'BWOPK4230K', 'ACGLLLOT00000001581', 'KARTHICK N G', 9791205065, 'KARTHICKNG19@GMAIL.COM',
    30000, 25500, 3814, 686, 4500, 686.44, 0, 0, 3813.56,
    39, 0.75, 38775, '2026-01-20', '2026-02-28', '''110264566900', 'CANARA BANK',
    'CNRB0001509', 'INF/NEFT/IN42602057334975/CNRB0001509/65163255 /                              /KARTHICKNG', 'DISBURSED', 'NEW', 'DEEPAK KUMAR', 'KISHAN KUMAR',
    'S.NO-1 A-BLOCK FLAT NO-002 , GROUND FLOOR KODICHIKKANAHALLI , SATHYA SAI LAYOUT  BTM 4TH SATGE BANGALORE , BANGALORE , -  560068 NEAR VIJAYA BANK LAYOUT OFF BANNERGHATTA ROAD 560068', 'AU SMALL FINANCE BANK LIMITED 5TH FLOOR, BREN MERCURY, SARJAPUR MAIN RD, KAIKONDRAHALLI, BENGALURU, KARNATAKA 560035  560035', 142, '121-180', 'January, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    2859, 'Tamil Nadu', 'Chennai', 'LOA00002768', 'ATHPR1772J', 'ACGLLLOT00000001587', 'RAJAGOPAL  G', 9087728565, 'RAJ8123@GMAIL.COM',
    30000, 25500, 3814, 686, 4500, 686.44, 0, 0, 3813.56,
    30, 0.75, 36750, '2026-01-21', '2026-02-20', '''924010035956367', 'AXIS BANK',
    'UTIB0005296', 'AI0001666715', 'DISBURSED', 'NEW', 'ASHISH', 'KISHAN KUMAR',
    'C309 ALTIS ASHRAYA KUNDRATHUR MAIN ROAD MANGADU  600122 C309 ALTIS ASHRAYA KUNDRATHUR MAIN ROAD MANGADU  600122  600003', 'EQUINITI INDIA PRIVATE LIMITED BLOCK 10 8TH FLOOR DLF IT SEZ RAMAPURAM CHENNAI  600089 BLOCK 10 8TH FLOOR DLF IT SEZ RAMAPURAM CHENNAI  600089  600086', 150, '121-180', 'January, 2026', 'PART-PAYMENT'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    2890, 'Telangana', 'Hyderabad', 'LOA00002781', 'AINPN6907E', 'ACGLLLOT00000001606', 'NIMMALA  SRINIVASAREDDY', 9100030103, 'PER.SRINI@GMAIL.COM',
    35000, 31500, 2966, 534, 3500, 533.9, 0, 0, 2966.1,
    38, 1, 48300, '2026-01-21', '2026-02-28', '''50100230679982', 'HDFC BANK',
    'HDFC0000076', 'AXISAN0008751975', 'DISBURSED', 'NEW', 'GARISHMA', 'NAVEEN',
    '9-99/17/1,FIRSTFLOOR,PLOT 491FIFTHCROSSNEXTLANEOF RELIANCEMARTLAKSHMINAGAR TELAGANA HYDERABAD- 500092  500092', 'MARATHON ELECTRIC INDIA PRIVATE LIMITED ARATHON ELECTRIC INDIA PRIVATE LIMITED  PURVA SUMMIT BUILDING  7TH FLOOR WHITEFIELDS  HITECH CITY HYDERABAD - 500085 ARATHON ELECTRIC INDIA PRIVATE LIMITED  PURVA SUMMIT BUILDING  7TH FLOOR WHITEFIELDS  HITECH CITY HYDERABAD - 500085  500085', 142, '121-180', 'January, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    2436, 'Telangana', 'Hyderabad', 'LOA00002796', 'BBXPY0516J', 'ACGLLLOT00000001625', 'KATTUBHOINA ACHYUTHA YADAV', 9121080681, 'AJAY1YADAV8@GMAIL.COM',
    15000, 12750, 1907, 343, 2250, 343.22, 0, 0, 1906.78,
    37, 0.75, 19162.5, '2026-01-22', '2026-02-28', '''389201517393', 'ICICI BANK LTD',
    'ICIC0003892', 'INF/INFT/043102845341/65277558     /KATTUBHOINAACHYUTHAY/', 'DISBURSED', 'NEW', 'GARISHMA', 'NAVEEN',
    'H.NO.10-186 MALKAGIRI, HYDERABAD, TELANGANA STATE 500045', 'BROADRIDGE FINANCIAL SOLUTIONS (INDIA) PRIVATE LIMITED CYBER TOWERS HITECH CITY MADHAPUR HYDERABAD TELANGANA 500081', 142, '121-180', 'January, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    2914, 'Maharashtra', 'Thane', 'LOA00002788', 'ADOPL0107G', 'ACGLLLOT00000001614', 'SACHIN PRALHAD LINGE', 7039915737, 'SACHINLINGE@GMAIL.COM',
    50000, 42500, 6356, 1144, 7500, 1144.07, 0, 0, 6355.93,
    37, 0.75, 63875, '2026-01-22', '2026-02-28', '''50100204613467', 'HDFC BANK',
    'HDFC0001027', 'INF/NEFT/IN42602258559261/HDFC0001027/65277558 /                              /SACHINPRALH', 'DISBURSED', 'NEW', 'DEEPAK KUMAR', 'KISHAN KUMAR',
    'FLAT NO 502 SAGAR SIGNATURE BLDG 2 VASANTWADI SANT KALYAN THANE DOMBIVALI  421201  421201', 'LTIMINDTREE LIMITED PLOT NO EL 200 TTC INDUSTRIAL AREA SHILMAHAPE ROAD MAHAPE NAVI MUMBAI 400710  400710', 142, '121-180', 'January, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    2922, 'Andhra Pradesh', 'Visakhapatnam', 'LOA00002793', 'ALGPD0271M', 'ACGLLLOT00000001619', 'MANORANJAN  DHAL', 8076457461, 'MANORANJAN_DHAL@HOTMAIL.COM',
    35000, 29750, 4449, 801, 5250, 800.85, 0, 0, 4449.15,
    37, 0.75, 44712.5, '2026-01-22', '2026-02-28', '''50100581965566', 'HDFC BANK LTD',
    'HDFC0006187', 'INF/NEFT/IN42602258559270/HDFC0006187/65277558 /                              /MANORANJAND', 'DISBURSED', 'NEW', 'GARISHMA', 'KISHAN KUMAR',
    'N FLAT NO 101, INDIA,NEAR VINAYAKA TEMPLE,TPT COLONY, BALAYYA SASTRI LAYOUT, SEETHAMMADARA,,VISAKHA PATNAM,ANDHRA PRADESH,530013 N FLAT NO 101, INDIA,NEAR VINAYAKA TEMPLE,TPT COLONY, BALAYYA SASTRI LAYOUT, SEETHAMMADARA,,VISAKHA PATNAM,ANDHRA PRADESH,530013  530013', 'PRO-VIGIL INC. VIRTUAL GUARD SERVICES PVT LTD  TECH MAHINDRA, PHASE -2, NEAR SATYAM JUNCTION, RESAPUVANIPALEM, VISHAKAPATNAM, ANDHRA PRADESH 530013 VIRTUAL GUARD SERVICES PVT LTD  TECH MAHINDRA, PHASE -2, NEAR SATYAM JUNCTION, RESAPUVANIPALEM, VISHAKAPATNAM, ANDHRA PRADESH 530013  530013', 142, '121-180', 'January, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    2934, 'West Bengal', '24 Parganas', 'LOA00002795', 'BIAPR9716F', 'ACGLLLOT00000001624', 'AYUSH  ROY', 9907301662, 'ROYAYUSH028@GMAIL.COM',
    25000, 21250, 3178, 572, 3750, 572.03, 0, 0, 3177.97,
    37, 0.75, 31937.5, '2026-01-22', '2026-02-28', '''5446373114', 'KOTAK MAHINDRA BANK LIMITED',
    'KKBK0000329', 'INF/NEFT/IN42602258559288/KKBK0000329/65277558 /                              /AYUSHROY', 'DISBURSED', 'NEW', 'PRIYA GUPTA', 'NAVEEN',
    'BLOCK 3 FLAT 2A WHITE MEADOWS 1529 DAKSHIN JAGADDAL RAJPUR DWARIR ROAD 700151', 'GUVI GEEK NETWORK PRIVATE LIMITED MODULE #9, 3RD FLOOR, D BLOCK KANAGAM RD, THARAMANI, CHENNAI, TAMIL NADU IITM RESEARCH PARK - PHASE 2 600113', 142, '121-180', 'January, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    2938, 'Haryana', 'Gurgaon', 'LOA00002800', 'ATMPK4257A', 'ACGLLLOT00000001631', 'TAPAN  KUMAR', 7895981679, 'TAPANMZN@GMAIL.COM',
    50000, 42500, 6356, 1144, 7500, 1144.07, 0, 0, 6355.93,
    36, 0.75, 63500, '2026-01-23', '2026-02-28', '''0148598261', 'KOTAK MAHINDRA BANK',
    'KKBK0005033', 'AXISAN0008785688', 'DISBURSED', 'NEW', 'POOJA', 'NAVEEN',
    'H-35/29-FIRST FLOOR VATIKA XPRESSIONS, DWARKA EXPRESSWAY SECTOR 88B, GURGAON, HARYANA- 122505 H-35/29-FIRST FLOOR VATIKA XPRESSIONS, DWARKA EXPRESSWAY SECTOR 88B, GURGAON, HARYANA- 122505  122505', 'M/S LIFELONG ONLINE RETAIL PRIVATE LIMITED 5TH GOODEARTH BUSINESS BAY II 5TH FLOOR, SECTOR 58, GURGAON HARYANA- 122102 5TH GOODEARTH BUSINESS BAY II 5TH FLOOR, SECTOR 58, GURGAON HARYANA- 122102  122102', 142, '121-180', 'January, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    2957, 'Karnataka', 'Bangalore', 'LOA00002805', 'ASCPN6095N', 'ACGLLLOT00000001636', 'PADALA SAGAR NAIDU', 7090626494, 'SAGAR.NAIDU3989@GMAIL.COM',
    30000, 25500, 3814, 686, 4500, 686.44, 0, 0, 3813.56,
    36, 0.75, 38100, '2026-01-23', '2026-02-28', '''4951372650', 'KOTAK MAHINDRA BANK',
    'KKBK0008335', 'AXISAN0008792854', 'DISBURSED', 'NEW', 'PIYUSH', 'KISHAN KUMAR',
    'FLAT NO-C412 ICONEST -3 APPT GRAND ICON LAYOUT BANGALORE KARNATAKA-560105  560105', 'BRIGHT MONEY TECHNOLOGY PRIVATE LIMITED INDIQUBE CELESTIA KORAMANGALA 1A BLOCK BANGALORE 560034 INDIQUBE CELESTIA KORAMANGALA 1A BLOCK BANGALORE 560034  560034', 142, '121-180', 'January, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    2958, 'Delhi', 'New Delhi', 'LOA00002810', 'ARRPP6341D', 'ACGLLLOT00000001641', 'PANKAJ KUMAR PANCHAL', 9971962963, 'PANKAJKRPANCHAL@GMAIL.COM',
    35000, 29750, 4449, 801, 5250, 0, 400.42, 400.42, 4449.15,
    14, 0.75, 38675, '2026-01-23', '2026-02-06', '''50100016522924', 'HDFC BANK',
    'HDFC0000572', 'AXISAN0008792855', 'DISBURSED', 'NEW', 'DEEPAK KUMAR', 'KISHAN KUMAR',
    'A 98/A GALI NO 5 HARDEVPURI SHAHDARA DELHI 110093  110093', 'ROSMERTA DIGITAL SERVICES LIMITED PLOT NO 66 , SECTOR 44 GURUGRAM HARYANA 122003  122003', 164, '121-180', 'January, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    2994, 'West Bengal', 'Kolkata', 'ADV00001744', 'AJVPB2105M', 'ACGLLLOT00000001650', 'ANANDA SANKAR BHATTACHARYA', 9831200524, 'ASBHATTA75@GMAIL.COM',
    40000, 34000, 5085, 915, 6000, 915.25, 0, 0, 5084.75,
    36, 0.75, 50800, '2026-01-23', '2026-02-28', '''910010016386768', 'AXIS BANK',
    'UTIB0000011', 'AI0001681350', 'DISBURSED', 'REPEAT', 'POOJA', 'NAVEEN',
    'FLAT NO. 7/4D, 4TH FLOOR, RAJWADA LAKE BLISS SONARPUR STATION ROAD 700103 NEAR INDIAN OIL PETROL PUMP 700075', 'INFINITY LABS LIMITED KR SIGNATURE TOWER SECTOR 135 NOIDA UP  201301', 142, '121-180', 'January, 2026', 'PART-PAYMENT'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    2995, 'Karnataka', 'Bangalore', 'LOA00002826', 'BAWPS6276H', 'ACGLLLOT00000001667', 'NAGENDRA  S', 8722292666, 'NAGENDRA.BHAV@GMAIL.COM',
    25000, 21250, 3178, 572, 3750, 572.03, 0, 0, 3177.97,
    35, 0.75, 31562.5, '2026-01-24', '2026-02-28', '''100901518557', 'ICICI BANK LIMITED',
    'ICIC0001009', 'INF/INFT/043117189061/65350942     /NAGENDRAS/', 'DISBURSED', 'NEW', 'ASHISH', 'NAVEEN',
    'NO 35 2ND CROSS 5TH MAIN SRINIDHI LAYOUT JP NAGAR 8TH PHASE BANGALORE 560062 NO 35 2ND CROSS 5TH MAIN SRINIDHI LAYOUT JP NAGAR 8TH PHASE BANGALORE 560062  560062', 'T- SYSTEMS ICT INDIA PVT. LTD A DEUTSCHE TELEKOM GROUP COMPANY, UMIYA BUSINESS BAY TOWER I - 4TH FLOOR, AND TOWER II - 2ND FLOOR, CESSNA BUSINESS PARK, OFF OUTER RING RD, MARATHAHALLI 560103 BENGALURU A DEUTSCHE TELEKOM GROUP COMPANY, UMIYA BUSINESS BAY TOWER I - 4TH FLOOR, AND TOWER II - 2ND FLOOR, CESSNA BUSINESS PARK, OFF OUTER RING RD, MARATHAHALLI 560103 BENGALURU  510036', 142, '121-180', 'January, 2026', 'PART-PAYMENT'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    3013, 'West Bengal', '24 Parganas', 'LOA00002824', 'EAGPD5368N', 'ACGLLLOT00000001665', 'SOUMYADEEP  DUTTA', 9903902946, 'SOUMYADEEPDUTTA1997@GMAIL.COM',
    30000, 25500, 3814, 686, 4500, 686.44, 0, 0, 3813.56,
    35, 0.75, 37875, '2026-01-24', '2026-02-28', '''330601002318', 'ICICI BANK LIMITED',
    'ICIC0003306', 'INF/INFT/043117190291/65350942     /SOUMYADEEPDUTTA     /', 'DISBURSED', 'NEW', 'DEEPAK KUMAR', 'KISHAN KUMAR',
    '61 S.N BANERJEE ROAD MADHUSUDAN COMPLEX BARRACKPORE CHIRIAMORE KOLKATA 700120 BESIDE V BAZAR SHOPPING MALL  700120', 'TATA CONSULTANCY SERVICES TCS NEWTOWN GITANJALI PARK KOLKATA 700160  700141', 142, '121-180', 'January, 2026', 'PART-PAYMENT'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    3023, 'Maharashtra', 'Mumbai', 'LOA00002830', 'AUSPP0749D', 'ACGLLLOT00000001673', 'LINGARAJ S PATIL', 7709995969, 'RAJPATIL81811@GMAIL.COM',
    34000, 30600, 2881, 519, 3400, 518.64, 0, 0, 2881.36,
    17, 1, 39780, '2026-01-24', '2026-02-10', '''2249070653', 'KOTAK MAHINDRA BANK',
    'KKBK0008250', 'INF/NEFT/IN42602459417714/KKBK0008250/65359236 /                              /LINGARAJSPA', 'DISBURSED', 'NEW', 'KISHAN KUMAR', 'NAVEEN',
    'HOUSE NO 34 BENAZIR WELFARE SOCIETY  ANDHERI EAST,MUMBAI MUMBAI-400059, MAHARASHTRA OPPOSIT AYUSHI,MAROL MAROSHI ROAD, 400059', 'SKYRAMS OUTDOOR ADVERTISINGS INDIA PRIVATE LTD MF-7, CIPET HOSTEL ROAD, THIRU-VI-KA INDUSTRIAL ESTATE, EKKATTUTHANGAL,, GUINDY CHENNAI, TAMILNADU INDIA-600032 THIRU-VI-KA INDUSTRIAL ESTATE, 600032', 160, '121-180', 'January, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    3047, 'Telangana', 'Hyderabad', 'LOA00002664', 'AHUPS6005L', 'ACGLLLOT00000001680', 'AVINASH  SARDA', 9391301205, 'AVINASHSARDA@GMAIL.COM',
    35000, 29750, 4449, 801, 5250, 800.85, 0, 0, 4449.15,
    33, 0.75, 43662.5, '2026-01-24', '2026-02-26', '''50100084546450', 'HDFC BANK',
    'HDFC0004064', 'INF/NEFT/IN42602459555496/HDFC0004064/65372079 /                              /AVINASHSARD', 'DISBURSED', 'REPEAT', 'DEEPAK KUMAR', 'KISHAN KUMAR',
    '3-2-372/1, FLAT NO 102N, MAYATRI ANJANI SADAN, KACHIGUDA, HYDERABAD -50027  500027', 'WELLS FARGO INTERNATIONAL SOLUTIONS PRIVATE LIMITED TOWER 4, DIVYA SREE ORION, , RAIDURGAM, HYDERABAD -500081 NEAR RAIDURGAM TRAFFIC POLICE STATION 500081', 144, '121-180', 'January, 2026', 'PART-PAYMENT'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    3048, 'Karnataka', 'Bangalore', 'LOA00002842', 'GFMPS1642H', 'ACGLLLOT00000001688', 'SHYAM  S', 7892010566, 'SHYAMSMSD94@GMAIL.COM',
    15000, 12750, 1907, 343, 2250, 343.22, 0, 0, 1906.78,
    35, 0.75, 18937.5, '2026-01-24', '2026-02-28', '''925010007240088', 'AXIS BANK',
    'UTIB0000559', 'INF/NEFT/IN42602459555505/UTIB0000559/65372079 /                              /SHYAMS', 'DISBURSED', 'NEW', 'POOJA', 'KISHAN KUMAR',
    '2543 NAGARTHAR PETE,WARD NO 21 DOD BALLAPUR,WARD NO 21 DOD BALLAPUR WARD NO 21 DOD BALLAPUR BANGALORE RURAL DOD BALLAPUR, KARNATAKA, 561203  561203', 'BAJAJ LIFE INSURANCE LTD GOLDEN HEIGHTS 4TH FLOOR 59TH CROSS ROAD NEAR LULU MALL RAJAJINAGAR BANGALORE KARNATAKA -560010 GOLDEN HEIGHTS 4TH FLOOR 59TH CROSS ROAD NEAR LULU MALL RAJAJINAGAR BANGALORE KARNATAKA -560010  560010', 142, '121-180', 'January, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    3036, 'Telangana', 'Rangareddy', 'LOA00002838', 'FTZPM6637L', 'ACGLLLOT00000001683', 'RAPAN  MIRHDA', 8543047904, 'RAPANMIRDHA89@GMAIL.COM',
    15000, 12750, 1907, 343, 2250, 343.22, 0, 0, 1906.78,
    34, 0.75, 18825, '2026-01-25', '2026-02-28', '''110289321233', 'CANARA BANK',
    'CNRB0002566', 'INF/NEFT/IN42602559698482/CNRB0002566/65375437 /                              /RAPANMIRHDA', 'DISBURSED', 'NEW', 'ASHISH', 'NAVEEN',
    '6-60 NARSINGI HYDERABAD TELAGANA -500075 6-60 NARSINGI HYDERABAD TELAGANA -500075  500075', 'MONOZYME LIFE SCIENCE PVT LTD PLOT.NO:4A&4B, PHASE:IE. TYPE-III, PRASHANTH NAGAR, BALANAGAR (M), MEDCHAL MALKAJGIRI (DT), HYDERABAD-500072 PLOT.NO:4A&4B, PHASE:IE. TYPE-III, PRASHANTH NAGAR, BALANAGAR (M), MEDCHAL MALKAJGIRI (DT), HYDERABAD-500072  500001', 142, '121-180', 'January, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    3060, 'Karnataka', 'Bangalore', 'LOA00002516', 'BKUPT8224N', 'ACGLLLOT00000001692', 'T E KULASWETH', 7330746728, 'KULASWETH77@GMAIL.COM',
    25000, 21250, 3178, 572, 3750, 572.03, 0, 0, 3177.97,
    31, 0.75, 30812.5, '2026-01-25', '2026-02-25', '''924010070569991', 'AXIS BANK',
    'UTIB0002926', 'INF/NEFT/IN42602559698486/UTIB0002926/65375437 /                              /TEKULASWETH', 'DISBURSED', 'REPEAT', 'DEEPAK KUMAR', 'KISHAN KUMAR',
    '22, SREE SRINIVASA NILAYA, BHUVANESHWARI NAGAR, T DHASARAHALLI, VIJAYA BHARATHI SCHOOL ROAD, 560057  560057', 'IKEA INDIA PRIVATE LIMITED IKEA STORE, TUMKUR ROAD, NAGASANDRA, BEHIND NAGASANDRA METRO, 560073  560073', 145, '121-180', 'January, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    3082, 'Karnataka', 'Bangalore', 'LOA00002851', 'AJSPM3819N', 'ACGLLLOT00000001707', 'GUNASEKARAN  MUNIYAN', 9663926699, 'GUNARBPO18@GMAIL.COM',
    20000, 17000, 2542, 458, 3000, 457.63, 0, 0, 2542.37,
    40, 0.75, 26000, '2026-01-25', '2026-03-06', '''00000020009765698', 'STATE BANK OF INDIA',
    'SBIN0004235', 'INF/NEFT/IN42602559825401/SBIN0004235/65379566 /                              /GUNASEKARAN', 'DISBURSED', 'NEW', 'PIYUSH', 'KISHAN KUMAR',
    '801, GROUND FLOOR, 13TH CROSS, 4TH MAIN, CHANDRALAYOUT BANGALORE 560072  560072', 'TOYOTA KIRLOSKAR MOTOR PRIVATE LIMITED, PLOT NO 1, BIDADI INDUSTRIAL AREA,RAMANAGARA DISTRICT, KARNATAKA, BANGALORE -562109  562107', 136, '121-180', 'January, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    3083, 'Telangana', 'Hyderabad', 'LOA00002850', 'JSNPS6595A', 'ACGLLLOT00000001706', 'SUKTHEA  NAGARJUN', 8096902140, 'ARJUN083108@GMAIL.COM',
    20000, 17000, 2542, 458, 3000, 457.63, 0, 0, 2542.37,
    39, 0.75, 25850, '2026-01-25', '2026-03-05', '''10135808986', 'IDFC BANK LIMITED',
    'IDFB0080203', 'INF/NEFT/IN42602559771426/IDFB0080203/65378063 /                              /SUKTHEANAGA', 'DISBURSED', 'NEW', 'POOJA', 'KISHAN KUMAR',
    'H13-5-347 JOSHIWADI KARWAN ASIFNAGAR HYDERABAD 500048 13-5-347 JOSHIWADI KARWAN ASIFNAGAR HYDERABAD 500048  500048', 'BROWNSTONE EDUCATION PRIVATE LIMITED N CONVENTION BESIDE INFINITY TOWER KOTHAGUDDA HYDERABAD 500082 N CONVENTION BESIDE INFINITY TOWER KOTHAGUDDA HYDERABAD 500082  500082', 137, '121-180', 'January, 2026', 'PART-PAYMENT'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    3050, 'Maharashtra', 'Thane', 'LOA00002840', 'ARCPJ7748P', 'ACGLLLOT00000001685', 'SANDEEP  JALUI', 9699798948, 'SAN.JALVI4@GMAIL.COM',
    40000, 34000, 5085, 915, 6000, 915.25, 0, 0, 5084.75,
    35, 0.75, 50500, '2026-01-27', '2026-02-28', '''2214154968', 'Kotak Mahindra Bank',
    'KKBK0007466', 'INF/NEFT/IN42602750262674/KKBK0007466/65372079 /                              /SANDEEPJALU', 'DISBURSED', 'NEW', 'PIYUSH', 'KISHAN KUMAR',
    '202 KALPANA APARTMENT KISAN NAGAR THANE 400604 202 KALPANA APARTMENT KISAN NAGAR THANE 400604  400604', 'DUN & BRADSTREET INFORMATION SERVICES INDIA PVT.LTD GODREJ BKC 7 FLOOR, KURLA , MUMBAI 400051  400051', 142, '121-180', 'January, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    3129, 'Karnataka', 'Bangalore', 'LOA00002609', 'APAPM2993P', 'ACGLLLOT00000001723', 'MAHESH BANGALORE SHIVANAND', 9916168010, 'BANGLOREMAHESH@GMAIL.COM',
    36000, 30600, 4576, 824, 5400, 823.73, 0, 0, 4576.27,
    32, 0.75, 44640, '2026-01-27', '2026-02-28', '''45511057939', 'STANDARD CHARTERED BANK',
    'SCBL0036073', 'INF/NEFT/IN42602750453150/SCBL0036073/65404646 /                              /MAHESHBANGA', 'DISBURSED', 'REPEAT', 'ASHISH', NULL,
    '#K 105 , 1ST FLR MANTRI ALPHYNE K BLCK , DR VISHNUVARDHAN  RD , BHANASANKARI 5TH STAGE BANGLORE 560061  560061', 'STANDARD CHARTERED GLOBAL BUSINESS SERVICES PRIVATE LIMITED SCB, BUILDING 8 3RD FLOOR RMZ ECOWORLD ORR MARATHAHALLI BELLANDUR BANGALORE 560103 SCB, BUILDING 8 3RD FLOOR RMZ ECOWORLD ORR MARATHAHALLI BELLANDUR BANGALORE 560103  500103', 142, '121-180', 'January, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    3149, 'West Bengal', 'Kolkata', 'LOA00002871', 'COAPP9562A', 'ACGLLLOT00000001747', 'BISWAJIT  PUTI', 8284956163, 'BISWAJITPUTI@GMAIL.COM',
    20000, 17000, 2542, 458, 3000, 457.63, 0, 0, 2542.37,
    34, 0.75, 25100, '2026-01-27', '2026-03-02', '''25080410000021', 'UCO BANK',
    'UCBA0001870', 'INF/NEFT/IN42602750727548/UCBA0001870/65433005 /                              /BISWAJITPUT', 'DISBURSED', 'NEW', 'POOJA', 'NAVEEN',
    'CC 16 KRISHNA ASHIRWAD COOPERATIVE SOCIETY NEW TOWN KOLKATA CC 16 KRISHNA ASHIRWAD COOPERATIVE SOCIETY NEW TOWN KOLKATA  700141', 'UCO BANK PERSONNEL SERVICE DEPARTMENT 3&4 DD BLOCK, SALT LAKE, KOLKATA - 700064 WEST BENGAL INDIA. 3&4 DD BLOCK, SALT LAKE, KOLKATA - 700064 WEST BENGAL INDIA.  700074', 140, '121-180', 'January, 2026', 'PART-PAYMENT'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    3166, 'Telangana', 'Hyderabad', 'LOA00002872', 'BSXPV5913R', 'ACGLLLOT00000001750', 'THUMATI  VINAY', 9550232948, 'VINAYTHUMATI214@GMAIL.COM',
    35000, 29750, 4449, 801, 5250, 800.85, 0, 0, 4449.15,
    31, 0.75, 43137.5, '2026-01-28', '2026-02-28', '''50100496345911', 'HDFC BANK',
    'HDFC0003119', 'INF/NEFT/IN42602850984851/HDFC0003119/65449835 /                              /THUMATIVINA', 'DISBURSED', 'NEW', 'KISHAN KUMAR', 'NAVEEN',
    'HOUSE NO.1-60/21/?, ANJAIAH NAGAR, GACHIBOWLI, SERILINGAMPALLY, RANGA REDDY-500032 ANJAIAH NAGAR 500031', 'TECHASPECT SOLUTIONS PRIVATE LIMITED OMNICOM OFFICE, FLOOR NO -20, RMZ SPIRE, TOWER NO- 110, HITEC CITY, HYDERABAD, TELANGANA-500081 SILPA GRAM CRAFT VILLAGE, 500081', 142, '121-180', 'January, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    3173, 'Telangana', 'Hyderabad', 'LOA00002876', 'DWJPP1809N', 'ACGLLLOT00000001755', 'SRAVAN KUMAR REDDY  PERIKITI', 9652423681, 'SRAVANKUMARREDDYPERIKITI@GMAIL.COM',
    30000, 25500, 3814, 686, 4500, 686.44, 0, 0, 3813.56,
    31, 0.75, 36975, '2026-01-28', '2026-02-28', '''923010064131796', 'AXIS BANK',
    'UTIB0000427', 'INF/NEFT/IN42602850984932/UTIB0000427/65449835 /                              /SRAVANKUMAR', 'DISBURSED', 'NEW', 'PIYUSH', 'NAVEEN',
    'PLOT NO 147 KRISHNA NAGAR COLONY YELLA REDDY GUDA KAPRA HYDERABAD 500103 PLOT NO 147 KRISHNA NAGAR COLONY YELLA REDDY GUDA KAPRA HYDERABAD 500103  500062', 'CES GLOBAL IT SOLUTIONS PRIVATE LIMITED 4TH & 7TH FLOOR, RAMKY SELENIUM, TOWER A, NANAKRAMGUDA RD, FINANCIAL DISTRICT, NANAKRAMGUDA, TELANGANA 500032  500033', 142, '121-180', 'January, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    3175, 'Maharashtra', 'Thane', 'LOA00002887', 'CCYPS4474N', 'ACGLLLOT00000001786', 'VINAY OMPRAKASH SHARMA', 9773689847, 'VINAY.SHARMA894@GMAIL.COM',
    30000, 25500, 3814, 686, 4500, 686.44, 0, 0, 3813.56,
    31, 0.75, 36975, '2026-01-28', '2026-02-28', '''128200100114015', 'SARASWAT COOPERATIVE BANK LIMITED',
    'SRCB0000128', 'INF/NEFT/IN42602851372086/SRCB0000128/65495089 /                              /VINAYOMPRAK', 'DISBURSED', 'NEW', 'POOJA', 'KISHAN KUMAR',
    'BALI VISHNU PRASAD PARK CHS LTD NAVAPADA SUBHASH ROAD DOMBIVLI WEST 421202 BALI VISHNU PRASAD PARK CHS LTD NAVAPADA SUBHASH ROAD DOMBIVLI WEST 421202  421202', 'CORAPLUS INDIA PVT LTD A/13 CORAPLUS INDIA PVT LTD ROAD NO 22 WAGLE INDUSTRIAL AREA THANE WEST 400604 A/13 CORAPLUS INDIA PVT LTD ROAD NO 22 WAGLE INDUSTRIAL AREA THANE WEST 400604  400013', 142, '121-180', 'January, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    3187, 'Karnataka', 'Bangalore', 'LOA00002163', 'APBPN9596E', 'ACGLLLOT00000001759', 'N S  RAJESH', 9900439933, 'VIPRA213@GMAIL.COM',
    55000, 47300, 6525, 1175, 7700, 1174.58, 0, 0, 6525.42,
    38, 0.75, 70675, '2026-01-28', '2026-03-07', '''00000042386361590', 'STATE BANK OF INDIA',
    'SBIN0003357', 'INF/NEFT/IN42602851033425/SBIN0003357/65455604 /                              /NSRAJESH', 'DISBURSED', 'REPEAT', 'POOJA', 'NAVEEN',
    'TF 308, 3RD FLOOR, DURGADEVI ENCLAVE, OPP. HAPPY VALLEY SCHOOL, HAPPY VALLEY LAYOUT, POORNAPRAGNA NAGAR, BANGALORE -560061  560061', 'QREAM SOLUTIONS PVT LTD. NO1, 302, NAVARATHNA GARDENS, DODDAKALLASANDRA, NO1, 302, NAVARATHNA GARDENS, DODDAKALLASANDRA,  560062', 135, '121-180', 'January, 2026', 'PART-PAYMENT'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    3193, 'Karnataka', 'Bangalore', 'LOA00001937', 'AQUPB5026D', 'ACGLLLOT00000001762', 'VIDHYA  BHUSHAN', 9538483909, 'VIDHYA.BHUSHANJOSHI@GMAIL.COM',
    42000, 35700, 5339, 961, 6300, 961.02, 0, 0, 5338.98,
    31, 0.85, 53067, '2026-01-28', '2026-02-28', '''025201525353', 'ICICI BANK LIMITED',
    'ICIC0000601', 'INF/INFT/043145131801/65467542     /VIDHYABHUSHAN/', 'DISBURSED', 'REPEAT', 'ASHISH', NULL,
    'GMR GRAND APARTMENT, G-01, 10TH MAIN , NRI LAYOUT, BANGALORE- 560016  560016', 'TATA COMMUNICATIONS LIMITED PLOT ON-18,20, ROAD NO7, KIADB EXPORT INDUSTRIAL AREA, WHITEFIELD, BANGALORE-560066  560016', 142, '121-180', 'January, 2026', 'PART-PAYMENT'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    3212, 'Uttar Pradesh', 'Greater Noida', 'LOA00002883', 'BDIPK1783J', 'ACGLLLOT00000001780', 'ABHINAV  KASHYAP', 9717213196, 'ABHIONETWO@GMAIL.COM',
    50000, 42500, 6356, 1144, 7500, 1144.07, 0, 0, 6355.93,
    37, 0.75, 63875, '2026-01-28', '2026-03-06', '''385101501224', 'ICICI BANK LTD',
    'ICIC0003851', 'INF/INFT/043148507601/65488566     /ABHINAVKASHYAP/', 'DISBURSED', 'NEW', 'DEEPAK KUMAR', 'KISHAN KUMAR',
    'FLAT NO 002, PRATEEK WISTERIA SECTOR 77 NOIDA -201301 NEAR-NORTH EYE 201310', 'RASNA PRIVATE LIMITED 702, GOPAL TOWER RAJENDRA PLACE DELHI -110008 NEAR TO METRO STATION 110008', 136, '121-180', 'January, 2026', 'PART-PAYMENT'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    3227, 'Telangana', 'Hyderabad', 'LOA00002889', 'AFJPT6088B', 'ACGLLLOT00000001789', 'SUMAN  TUMMALA', 9908445693, 'SUMANTUMMALA9@GMAIL.COM',
    25000, 21250, 3178, 572, 3750, 572.03, 0, 0, 3177.97,
    31, 0.75, 30812.5, '2026-01-28', '2026-02-28', '''919010056679227', 'AXIS BANK',
    'UTIB0000553', 'INF/NEFT/IN42602851450266/UTIB0000553/65499258 /                              /SUMANTUMMAL', 'DISBURSED', 'NEW', 'GARISHMA', 'KISHAN KUMAR',
    '102,SREE MAHALAKSHMI NIVAS RAJEEV GANDHI NAGAR  POOJITHA ENCLAVE ROAD NO6  BACHUPALLY RANGAREDDY TELANGANA -500090  500090', 'MOURI TECH LIMITED 4TH FLOOR, AND UNIT 4A, VAISHNAVIâ€™S ICONIC, SY NO. 62, UNIT 1A, 1ST FLOOR, OPP. DURGAM CHERUVU, MADHAPUR, HYDERABAD, TELANGANA 500081 4TH FLOOR, AND UNIT 4A, VAISHNAVIâ€™S ICONIC, SY NO. 62, UNIT 1A, 1ST FLOOR, OPP. DURGAM CHERUVU, MADHAPUR, HYDERABAD, TELANGANA 500081  500081', 142, '121-180', 'January, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    3108, 'Maharashtra', 'Thane', 'LOA00002900', 'ALYPB2286J', 'ACGLLLOT00000001817', 'ASHISH RAJU BUDITHI', 9833925400, 'ASHISHB.U4@GMAIL.COM',
    40000, 34000, 5085, 915, 6000, 915.25, 0, 0, 5084.75,
    30, 0.75, 49000, '2026-01-29', '2026-02-28', '''038801501880', 'ICICI BANK LIMITED',
    'ICIC0001959', 'INF/INFT/043160642621/65551877     /ASHISHRAJUBUDITHI   /', 'DISBURSED', 'NEW', 'NAVEEN', 'KISHAN KUMAR',
    '101, RUKMINI VAIBHAV BEVERLY PARK BEVARLY PARK, MIRA ROAD, OPP STAR MARKET NEXT TO BANK OF BARODA 401107', 'DUA LIMA RETAIL PRIVATE LIMITED UNIT NO. 4, GROUND FLOOR & FIRST FLOOR, POONAM ESTATE CLUSTER, 2 SRISHTI RD, NEAR MIRA ROAD E, GAURAV GALAXY, MIRA ROAD EAST, THANE, MIRA BHAYANDAR, 401107', 142, '121-180', 'January, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    3259, 'Karnataka', 'Bangalore', 'LOA00002895', 'BTFPS8786Q', 'ACGLLLOT00000001804', 'SHRIDHAR  VERNEKAR', 8197823452, 'SHRIDHARVERNEKAR2012@GMAIL.COM',
    26000, 22100, 3305, 595, 3900, 594.92, 0, 0, 3305.08,
    30, 0.75, 31850, '2026-01-29', '2026-02-28', '''44249343222', 'STATE BANK OF INDIA',
    'SBIN0014962', 'INF/NEFT/IN42602951848392/SBIN0014962/65540641 /                              /SHRIDHARVER', 'DISBURSED', 'NEW', 'DEEPAK KUMAR', 'KISHAN KUMAR',
    '1/2 NISARGA BDA ENCLAVE, 100 FEET RING ROAD, 5TH BLOCK, BSK 3RD STAGE, BEHIND KAMAKYA BUS STOP, BENGALURU, 560085  560085', 'VERINT CES INDIA PVT LTD 5TH FLOOR, EAST WING, NORTH TOWER, ITC GREEN CENTER, 18, DODDA BANASWADI MAIN ROAD, MARUTHI SEVANAGAR, BENGALURU, KARNATAKA 560005  560005', 142, '121-180', 'January, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    3267, 'Telangana', 'Rangareddy', 'ADV00001750', 'AQGPR6412H', 'ACGLLLOT00000001814', 'RANGU NARESH KUMAR', 9966022273, 'RANGU.NARESHKUMAR@GMAIL.COM',
    25000, 21250, 3178, 572, 3750, 572.03, 0, 0, 3177.97,
    30, 0.75, 30625, '2026-01-29', '2026-02-28', '''15541610003179', 'HDFC BANK',
    'HDFC0001554', 'INF/NEFT/IN42602951847552/HDFC0001554/65540641 /                              /RANGUNARESH', 'DISBURSED', 'REPEAT', 'DEEPAK KUMAR', 'NAVEEN',
    '401, SRI LAKSHMI ARCADE, NJR KLR NAGAR, PHASE 3, MEDCHAL, TELANGANA - 501401 PHASE 3, MEDCHAL TELANGANA - 501401 501401', 'IPLACE INDIA PRIVATE LIMITED 2ND FLOOR, AMANORA MALL, AMANORA PARK TOWN, PUNE, MAHARASHTRA- 411028 AMANORA PARK TOWN, PUNE, MAHARASHTRA- 411028 411028', 142, '121-180', 'January, 2026', 'PART-PAYMENT'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    3277, 'Telangana', 'Hyderabad', 'LOA00002901', 'BOBPT0769K', 'ACGLLLOT00000001818', 'THANDRA JOYCE DEBORAH', 9676510426, 'JOYCEDEBORAH97@GMAIL.COM',
    35000, 29750, 4449, 801, 5250, 800.85, 0, 0, 4449.15,
    26, 0.75, 41825, '2026-01-29', '2026-02-24', '''50100288334534', 'HDFC BANK',
    'HDFC0000968', 'INF/NEFT/IN42602951946275/HDFC0000968/65551877 /                              /THANDRAJOYC', 'DISBURSED', 'NEW', 'KISHAN KUMAR', 'NAVEEN',
    'PLOTNO 22 HNO 8-30/S/15/3 SURYAHILLS COLONY HEMANAGAR 500039 BODUPPAL RANGAREDDI ANDHRA PRADESH INDIA SURYAHILLS COLONY 500039', 'BARCLAYS GLOBAL SERVICE CENTRE PRIVATE LIMITED HX35+R55, VITTHAL NAGAR, KHARADI, PUNE, MAHARASHTRA 411014 VITTHAL NAGAR, 411014', 146, '121-180', 'January, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    3304, 'Telangana', 'Hyderabad', 'LOA00002335', 'ABBPU5676L', 'ACGLLLOT00000001830', 'UPPARI  NARASIMULU', 7702262000, 'NARASIMULU24@GMAIL.COM',
    50000, 42500, 6356, 1144, 7500, 1144.07, 0, 0, 6355.93,
    29, 0.75, 60875, '2026-01-30', '2026-02-28', '''2249990982', 'KOTAK MAHINDRA BANK',
    'KKBK0007487', 'INF/NEFT/IN42603052305818/KKBK0007487/65581808 /                              /UPPARINARAS', 'DISBURSED', 'REPEAT', 'POOJA', NULL,
    'HNO-8-1-284/OU /114 OU COLONY HYDERABAD TELANGANA INDIA 500008  500008', 'HONEYWELL TECH SOLUTIONS HONEYWELL TECHNOLOGIES SOLUTIONS LAB.SERVEY NO 116/7 IT PARK NANSKEAMGUDA.GACHIBOWLI HYDERABAD 500032  500031', 142, '121-180', 'January, 2026', 'PART-PAYMENT'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    3312, 'Karnataka', 'Bangalore', 'LOA00002344', 'AWEPJ9394C', 'ACGLLLOT00000001838', 'VIPIN  JOSE', 8861984941, 'VIPINJOSE321@GMAIL.COM',
    68000, 58480, 8068, 1452, 9520, 1452.2, 0, 0, 8067.8,
    29, 0.85, 84762, '2026-01-30', '2026-02-28', '''50100004662253', 'HDFC BANK',
    'HDFC0000065', 'INF/NEFT/IN42603052341338/HDFC0000065/65586384 /                              /VIPINJOSE', 'DISBURSED', 'REPEAT', 'DEEPAK KUMAR', 'KISHAN KUMAR',
    'NORTH HILL GARDENS, 108 6TH MAIN ITI LAYOUT, BENSON TOWN, CHINNAPA GARDEN, BENSON TOWN, PO: BENSON TOWN, DIST: BENGALURU, KARNATAKA - 560046 NEAREST LAND MARK - BESIDE DIVINE SPECIALITY HOSPITAL  560046', 'EMERALD CLINICAL TRIALS INDIA PRIVATE LIMITED EMERALD CLINICAL TRIALS, PLOT NO. 5, PRESTIGE KHODAY TOWERS, 12TH FLOOR, RAJ BHAVAN ROAD, BANGALORE - 560001  560001', 142, '121-180', 'January, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    3322, 'Telangana', 'Hyderabad', 'ADV00001421', 'DCIPM9885C', 'ACGLLLOT00000001846', 'MANUBOLU MADHAVI LATHA', 6302185291, 'MADHAVI.MANUBOLU1998@GMAIL.COM',
    35000, 29750, 4449, 801, 5250, 800.85, 0, 0, 4449.15,
    29, 0.85, 43627.5, '2026-01-30', '2026-02-28', '''069201509401', 'ICICI BANK LIMITED',
    'ICIC0000692', 'INF/INFT/043169824131/65593870     /MANUBOLUMADHAVILATHA/', 'DISBURSED', 'REPEAT', 'DEEPAK KUMAR', 'KISHAN KUMAR',
    'PLOT NO 1228 ROAD NO 8 SIDDIQUI NAGAR GCHIBOWLI HYDERABAD , 500032  500031', 'CGI INFORMATION SYSTEMS AND MANAGEMENT CONSULTANTS PRIVATE LIMITED C9X4+684, DLF CYBER CITY, INDIRA NAGAR, GACHIBOWLI, HYDERABAD, TELANGANA 500032  500081', 142, '121-180', 'January, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    3325, 'Maharashtra', 'Pune', 'LOA00002687', 'AJRPV5197P', 'ACGLLLOT00000001860', 'NATASHA  KAPOOLA', 9021849081, 'NVAKKIL@GMAIL.COM',
    15000, 12750, 1907, 343, 2250, 343.22, 0, 0, 1906.78,
    29, 0.75, 18262.5, '2026-01-30', '2026-02-28', '''560701500322', 'ICICI BANK LTD',
    'ICIC0005607', 'INF/INFT/043172417041/65608328     /NATASHAKAPOOLA/', 'DISBURSED', 'REPEAT', 'PRIYA GUPTA', 'KISHAN KUMAR',
    'S.NO 45:ASHTAVINAYAK SOCIETY SOMNATH NAGAR, 411014', 'MARSH MCLENNAN (INDIA) PRIVATE LIMITED 6TH FLOOR, TOWER A WING 1, BUSINESS BAY, SURVEY NO. 103 HISSA NO. 2, AIRPORT ROAD, YERWADA, 411006', 142, '121-180', 'January, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    3336, 'West Bengal', 'Kolkata', 'LOA00002186', 'AMTPM3104C', 'ACGLLLOT00000001857', 'PRIYANKA  MUKHERJEE', 9830908055, 'BEST.PRIYANKA.BEST@GMAIL.COM',
    23000, 19550, 2924, 526, 3450, 526.27, 0, 0, 2923.73,
    29, 0.85, 28669.5, '2026-01-30', '2026-02-28', '''920010072797475', 'AXIS BANK',
    'UTIB0002683', 'INF/NEFT/IN42603052547248/UTIB0002683/65608328 /                              /PRIYANKAMUK', 'DISBURSED', 'REPEAT', 'DEEPAK KUMAR', 'NAVEEN',
    '75/24  S.N. ROY ROAD SAHAPUR KOLKATA 700038  700038', 'AXIS SECURITIES 50 CHOWRINGHEE ROAD, 2ND FLOOR, ISSCO HOUSE KOLKATA 700071 NEAR SAHARA SADAN 700071', 142, '121-180', 'January, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    3379, 'Karnataka', 'Bangalore', 'LOA00002594', 'CCMPM8648E', 'ACGLLLOT00000001893', 'MANJUNATHA', 8073712435, 'MANJUNATHARTD@GMAIL.COM',
    12000, 10200, 1525, 275, 1800, 274.58, 0, 0, 1525.42,
    28, 0.75, 14520, '2026-01-31', '2026-02-28', '''922010020306922', 'AXIS BANK',
    'UTIB0000077', 'INF/NEFT/IN42603152950850/UTIB0000077/65639580 /                              /MANJUNATHA', 'DISBURSED', 'REPEAT', 'DEEPAK KUMAR', NULL,
    '09 MATRUSHRI NILAYA SAI SILVER WOOD LAYOUT HOSALLI MAINROAD NEAR COUNTRY CLUB YELAHANKA BANGALORE BANGLORE 562149 INDIAN AIR FORCE NEAR LAND MARK 560063', 'BANGALORE INTERNATIONAL AIRPORT LIMITED KEMPEGOWDA INTERNATIONAL AIRPORT DEVANAHALLI BANGALORE  560300  560300', 142, '121-180', 'January, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    3382, 'Telangana', 'Hyderabad', 'LOA00002636', 'BDNPK5065J', 'ACGLLLOT00000001895', 'K RAMA SWAMY', 8978200199, 'BUBBY.RAMA@GMAIL.COM',
    42000, 35700, 5339, 961, 6300, 961.02, 0, 0, 5338.98,
    28, 0.75, 50820, '2026-01-31', '2026-02-28', '''10258160636', 'IDFC FIRST BANK LTD',
    'IDFB0080242', 'INF/NEFT/IN42603152950874/IDFB0080242/65639580 /                              /KRAMASWAMY', 'DISBURSED', 'REPEAT', 'POOJA', NULL,
    'PLOT NO 180, GANESH NAGAR, CHILKA NAGAR RD, UPPAL HYDERABAD - 500039 HYDERABAD - 500039 500039', 'WIPRO , GOPANPALLY SURVEY NO 124 & PART OF 132/P SEZ HYDERABAD - 500019  500018', 142, '121-180', 'January, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    3388, 'Karnataka', 'Bangalore', 'LOA00002719', 'GLNPS4667F', 'ACGLLLOT00000001897', 'HARI BABU  S', 9341141125, 'HRBABU26@GMAIL.COM',
    20000, 17000, 2542, 458, 3000, 457.63, 0, 0, 2542.37,
    28, 0.75, 24200, '2026-01-31', '2026-02-28', '''925010002612624', 'AXIS BANK',
    'UTIB0000300', 'INF/NEFT/IN42603153059916/UTIB0000300/65648025 /                              /HARIBABUS', 'DISBURSED', 'REPEAT', 'PRIYA GUPTA', NULL,
    '460/1 3RD FLOOR MADILU BUILDING 1ST CROSS 2ND MAIN, ,VIBHUTIPURA EXTENSION, R ASANNA COLONY, VIBHUTIPURA, NEAR,2ND  MAIN ROAD 560037', 'ZOLVE INNOVATIONS PRIVATE LIMITED 4TH FLOOR, CAMPUS 31, RMZ ECOWORLD RD, ADARSH PALM RETREAT, BELLANDUR, 560103', 142, '121-180', 'January, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    3402, 'Telangana', 'Hyderabad', 'LOA00002478', 'CDRPB9879B', 'ACGLLLOT00000001920', 'NARASIMHARAO  BATTINA', 9642909895, 'EMAILNARASIMHARAOBATHINA912@GMAIL.COM',
    27000, 22950, 3432, 618, 4050, 617.8, 0, 0, 3432.2,
    28, 0.75, 32670, '2026-01-31', '2026-02-28', '''50100157598130', 'HDFC BANK',
    'HDFC0001128', 'INF/NEFT/IN42603153182746/HDFC0001128/65659214 /                              /NARASIMHARA', 'DISBURSED', 'REPEAT', 'KISHAN KUMAR', NULL,
    'PLOT NO 84,ROAD NO,, REDDY ENCLAVE TEMPLE ALWAL,,HYDERABAD,TELENGANA,500010 HYDERABAD TELANGANA, 500010 TEMPLE ALWAL, 500012', 'SYNGENE SCIENTIFIC SOLUT KNOWLEDGE SQUARE PARK -9000, PLOT NO.7, SURVEY NO.542, MN PARK, SYNERGY SQUARE 2 GENOME VALLEY, KOLTHUR SHAMIRPET, MEDCHAL, HYDERABAD, TELANGANA 500078 MN PARK 500078', 142, '121-180', 'January, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    3415, 'Karnataka', 'Bangalore', 'ADV00000880', 'BUSPM9072K', 'ACGLLLOT00000001922', 'MITHUN  RAJENDIR', 9952666370, 'MITHUN1593@GMAIL.COM',
    40000, 36000, 3390, 610, 4000, 610.17, 0, 0, 3389.83,
    30, 1, 52000, '2026-01-31', '2026-03-02', '''10252470882', 'IDFC FIRST BANK LTD',
    'IDFB0080172', 'INF/NEFT/IN42603153299725/IDFB0080172/65672605 /                              /MITHUNRAJEN', 'DISBURSED', 'REPEAT', 'PRIYA GUPTA', NULL,
    'A-204, TCH GARDEN RESIDENCY BOMMASANDRA, BANGALORE - 560099 560099', 'ALTRA INDUSTRIAL MOTION INDIA PVT LTD PLOT NO A-33, PHASE IV CHAKAN INDUSTRIAL AREA, NIGHOJE TAL KHED TALUK,  PUNE - 410501 410501', 140, '121-180', 'January, 2026', 'PART-PAYMENT'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    3419, 'Karnataka', 'Bangalore', 'ADV00000943', 'BTQPK7876L', 'ACGLLLOT00000001930', 'KARTHICK  DHANABALAN', 9886933282, 'DKARTHI06@GMAIL.COM',
    62000, 52700, 7881, 1419, 9300, 1418.64, 0, 0, 7881.36,
    28, 0.85, 76756, '2026-01-31', '2026-02-28', '''17561140003586', 'HDFC BANK',
    'HDFC0001756', 'INF/NEFT/IN42603153300146/HDFC0001756/65672605 /                              /KARTHICKDHA', 'DISBURSED', 'REPEAT', 'ASHISH', 'NAVEEN',
    'MYNEST APARTMENT B BLOCK 407 SHIKARIPALYA ELECTRONIC CITY PHASE 1 BANGALORE 560100 LANDMARK NEAR MASJID 560100', 'CGI INFORMATION SYSTEMS AND MANAGEMENT CONSULTANTS PRIVATE LIMITED. 95/1 AND 95/2 ECITY TOWER 2 ELECTRONIC CITY PHASE 1 BANGALORE 560100 LANDMARK: NEAR SYMBIOSIS UNIVERSITY 560100', 142, '121-180', 'January, 2026', 'PART-PAYMENT'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    3424, 'Delhi', 'New Delhi', 'LOA00002931', 'AMDPM5265C', 'ACGLLLOT00000001952', 'SUMIT  MATHUR', 8447749512, 'SUMITMATHUR2007@GMAIL.COM',
    30000, 25500, 3814, 686, 4500, 0, 343.22, 343.22, 3813.56,
    27, 0.75, 36075, '2026-01-31', '2026-02-27', '''604410100009691', 'BANK OF INDIA',
    'BKID0006044', 'INF/NEFT/IN42603153447780/BKID0006044/65684751 /                              /SUMITMATHUR', 'DISBURSED', 'NEW', 'PRIYA GUPTA', 'NAVEEN',
    'F.NO- 46,2ND VIKASPURI NEAR E BLOCK LAL MARKET DELHI, FLOOR,MAYA APARTMENT, 110018', 'PAYSQUARE HR SERVICES PVT LTD LANDMARK-MEGAMART, 1537, BHAKTI PREMIUM 3RD & 4TH FLOOR, OLD MUMBAI - PUNE HWY, DAPODI, PUNE,  411012', 143, '121-180', 'January, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    3437, 'West Bengal', '24 Parganas', 'LOA00001892', 'AVKPR0624G', 'ACGLLLOT00000001942', 'JAYANTA  ROY', 9831006522, 'INFO@JAYANTAROY.COM',
    27000, 22950, 3432, 618, 4050, 617.8, 0, 0, 3432.2,
    28, 0.75, 32670, '2026-01-31', '2026-02-28', '''97642610004247', 'CANARA BANK',
    'CNRB0019764', 'INF/NEFT/IN42603153420927/CNRB0019764/65682560 /                              /JAYANTAROY', 'DISBURSED', 'REPEAT', 'POOJA', NULL,
    '10/5/D I C ROAD MADHYAPARA KABIRAJ BARI RAHARA KARDAH  700118', 'TP WESTERN ODISHA DISTRIBUTION LIMITED TECHNOLOGY CENTER POWER HOUSE COLONY BHUBANESWAR,Â 751008  751008', 142, '121-180', 'January, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    3440, 'Karnataka', 'Bangalore', 'LOA00002060', 'BDOPA8737N', 'ACGLLLOT00000001947', 'AKASH B P', 9686247928, 'BP.AKASH.BP@GMAIL.COM',
    52000, 44200, 6610, 1190, 7800, 1189.83, 0, 0, 6610.17,
    28, 0.85, 64376, '2026-01-31', '2026-02-28', '''916010030005711', 'AXIS BANK',
    'UTIB0000009', 'INF/NEFT/IN42603153420932/UTIB0000009/65682560 /                              /AKASHBP', 'DISBURSED', 'REPEAT', 'ASHISH', 'NAVEEN',
    '1412 UK MANSION 4TH CROSS MANORAYANAPALYA RT NAGAR POST BANGALORE 560032 ANAND FOOD CHOICE 560032', 'RANDSTAD ENTERPRISE PRIVATE LIMITED RANDSTAD TOWERS MAIN GURD CROSS ROAD TASKER TOWN SHIVAJINAGAR PO BANGALORE 560001 SAFINA PLAZA 560001', 142, '121-180', 'January, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    3476, 'Haryana', 'Gurgaon', 'ADV00000266', 'BLUPG4003M', 'ACGLLLOT00000001979', 'VIKAS  GIRI', 9098197363, 'VIKASGIRI100@GMAIL.COM',
    25000, 21250, 3178, 572, 3750, 572.03, 0, 0, 3177.97,
    27, 0.75, 30062.5, '2026-02-01', '2026-02-28', '''090322010000772', 'UNION BANK OF INDIA',
    'UBIN0909033', 'INF/NEFT/IN42603253600179/UBIN0909033/65691109 /                              /VIKASGIRI', 'DISBURSED', 'REPEAT', 'DEEPAK KUMAR', NULL,
    'FLAT NO 303, SECTOR 3A, SHREE GANESH APARTMENT, LAXMAN VIHAR PHASE 2 GURGAON, HARYANA-122001 NEAR SHRI RAM SOCIETY, 122001', 'MERIDIAN SOLUTIONS PVT. LTD 1103-04, B4 TOWER, SPAZE I TECH PARK SECTOR 48, GURGAON, 122018  122018', 142, '121-180', 'February, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    3477, 'Telangana', 'Hyderabad', 'LOA00002434', 'BNOPR7025Q', 'ACGLLLOT00000001981', 'BANOTHU  NAGARAJU', 8125861893, 'BANOTHU.NAGARAJ@GMAIL.COM',
    20000, 17000, 2542, 458, 3000, 457.63, 0, 0, 2542.37,
    29, 0.75, 24350, '2026-02-01', '2026-03-02', '''018391900121067', 'YES BANK',
    'YESB0000183', 'INF/NEFT/IN42603253639166/YESB0000183/65693047 /                              /BANOTHUNAGA', 'DISBURSED', 'REPEAT', 'KISHAN KUMAR', NULL,
    '2-3-647/A/169 2-3-647/A/169, PREM NAGAR, AMBERPET , HYDERABAD, TELANGANA, 50 0013  500013', 'DIGITIDE LAL1 BUILDING 4TH FLOOR MG ROAD RANIGUNJ HYDERABAD PINCODE 500003  500003', 140, '121-180', 'February, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    3490, 'Uttar Pradesh', 'Greater Noida', 'LOA00002934', 'AMAPN8760A', 'ACGLLLOT00000001996', 'NISHI', 8506972499, 'SINGHNISHI010@GMAIL.COM',
    30000, 25500, 3814, 686, 4500, 686.44, 0, 0, 3813.56,
    29, 0.75, 36525, '2026-02-01', '2026-03-02', '''125501504771', 'ICICI BANK LIMITED',
    'ICIC0001255', 'INF/INFT/043194357761/65697203     /NISHI/', 'DISBURSED', 'NEW', 'PRIYA GUPTA', 'NAVEEN',
    '107 N1, , NOIDA, AURANGABAD, UTTAR PRADESH, ., SECTOR 151 JAYPEE AMAN, UTTAR PRADESH, NOIDA, 201310', 'SAIFE VETMED PVT LTD TOWER 1, OFFICE NUMBER 107, NOIDA 135  201301', 140, '121-180', 'February, 2026', 'PART-PAYMENT'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    3455, 'Karnataka', 'Bangalore', 'LOA00002571', 'AEKPH9373M', 'ACGLLLOT00000001964', 'GAJENDRA H V', 9611803693, 'GAJENDRAHV@GMAIL.COM',
    20000, 17000, 2542, 458, 3000, 457.63, 0, 0, 2542.37,
    26, 0.75, 23900, '2026-02-02', '2026-02-28', '''0008104000536004', 'IDBI BANK',
    'IBKL0000008', 'INF/NEFT/IN42603353763789/IBKL0000008/65685625 /                              /GAJENDRAHV', 'DISBURSED', 'REPEAT', 'ASHISH', NULL,
    '117, HULIMANGALA, NEAR BASAVANNA TEMPLE JIGANI  560105', 'VIROKA TECHNOLOGY PVT LTD NO.34, 2ND FLOOR, 31A CROSS, 3RD MAIN ROAD, JAYANAGAR 7TH BLOCK,  560082', 142, '121-180', 'February, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    3462, 'Karnataka', 'Bangalore', 'LOA00002398', 'DJMPP8174G', 'ACGLLLOT00000001968', 'S  PRASHANTH', 7829737990, 'PRASHRAMYA@GMAIL.COM',
    40000, 34000, 5085, 915, 6000, 915.25, 0, 0, 5084.75,
    26, 0.75, 47800, '2026-02-02', '2026-02-28', '''157829737990', 'INDUSIND BANK LTD',
    'INDB0001677', 'INF/NEFT/IN42603353762744/INDB0001677/65686015 /                              /SPRASHANTH', 'DISBURSED', 'REPEAT', 'DEEPAK KUMAR', 'KISHAN KUMAR',
    'SRI SAI ASHRITHA NILAYA. #85,3RD FLOOR, 1ST MAIN ROAD, JINNAGARADAMMA LAYOUT , NAGASANDRA POST, BENGALURU -560073  560073', 'GYNOVEDA FEMTECH PVT LTD GYNOVEDA CLINIC JP NAGAR 2ND PHASE, BANGALORE -560078  560078', 142, '121-180', 'February, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    3510, 'Maharashtra', 'Thane', 'LOA00002464', 'AIVPJ2600G', 'ACGLLLOT00000002003', 'SUSHANT MADHUKAR JADHAV', 9323184966, 'SUSHANT.JAD1990@GMAIL.COM',
    18000, 15300, 2288, 412, 2700, 411.86, 0, 0, 2288.14,
    28, 0.75, 21780, '2026-02-02', '2026-03-02', '''4811606734', 'KOTAK MAHINDRA BANK LIMITED',
    'KKBK0000468', 'INF/NEFT/IN42603353961432/KKBK0000468/65712332 /                              /SUSHANTMADH', 'DISBURSED', 'REPEAT', 'GARISHMA', NULL,
    'HOUSE NO 256 GANESH MANDIR ROAD, SIDDHARTH NAGAR, BOUDHWADA, TITWALA EAST  TAL- KALYAN DIST-THANE MUMBAI PIN CODE - 421605 HOUSE NO 256 GANESH MANDIR ROAD, SIDDHARTH NAGAR, BOUDHWADA, TITWALA EAST  TAL- KALYAN DIST-THANE MUMBAI PIN CODE - 421605  421605', 'NOVATEUR ELECTRICAL & DIGITAL SYSTEMS PVT. LTD. C-203 ATUL PROJECT, CORPORATE AVENUE NEAR MIRADOR HOTEL, GHATKOPAR ANDHERI LINK ROAD, CHAKALA, ANDHERI EAST, MUMBAI- 400099 C-203 ATUL PROJECT, CORPORATE AVENUE NEAR MIRADOR HOTEL, GHATKOPAR ANDHERI LINK ROAD, CHAKALA, ANDHERI EAST, MUMBAI- 400099  400099', 140, '121-180', 'February, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    3534, 'Telangana', 'Hyderabad', 'LOA00002616', 'ANLPR9642R', 'ACGLLLOT00000002020', 'D RAJA RAGHAVENDRA REDDY', 7416741888, 'REDDY030205@GMAIL.COM',
    35000, 29750, 4449, 801, 5250, 800.85, 0, 0, 4449.15,
    28, 0.75, 42350, '2026-02-02', '2026-03-02', '''218101519517', 'ICICI BANK LIMITED',
    'ICIC0000069', 'INF/INFT/043204520941/65740019     /DRAJARAGHAVENDRAREDD/', 'DISBURSED', 'REPEAT', 'GARISHMA', NULL,
    'FLAT NO-202 ROYAL GARDEN APPARTMENT RAVINDRA NAGAR NACHARAM OPP TO ESI HOSPITAL MEDCHAL MALKAJGIRI HYDERABAD, TELANGANA, 500076 FLAT NO-202 ROYAL GARDEN APPARTMENT RAVINDRA NAGAR NACHARAM OPP TO ESI HOSPITAL MEDCHAL MALKAJGIRI HYDERABAD, TELANGANA, 500076  500076', 'WAFERWIRE TECHNOLOGY SOLUTIONS PRIVATE LIMITED WESTERN AQUA, 4TH FLOOR, KONDAPUR, HYDERABAD - 500081 WESTERN AQUA, 4TH FLOOR, KONDAPUR, HYDERABAD - 500081  500081', 140, '121-180', 'February, 2026', 'PART-PAYMENT'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    3546, 'Uttar Pradesh', 'Ghaziabad', 'LOA00002471', 'ASGPC2854A', 'ACGLLLOT00000002029', 'SHEFALI  RAJAN', 6393551773, 'SHEFALICHANDRA34@GMAIL.COM',
    17000, 14450, 2161, 389, 2550, 388.98, 0, 0, 2161.02,
    29, 0.75, 20697.5, '2026-02-02', '2026-03-03', '''922010044387242', 'AXIS BANK',
    'UTIB0000723', 'INF/NEFT/IN42603354398422/UTIB0000723/65758336 /                              /SHEFALIRAJA', 'DISBURSED', 'REPEAT', 'PRIYA GUPTA', NULL,
    'FLAT NO UG-02 DWARKA APARTMENT VRINDAVAN COLONY GREATER NOIDA WEST SHAH BERI, GAUTAM BUDDHA NAGAR UTTAR PRADESH 201009  201009', 'IILM UNIVERSITY GREATER NOIDA PLOT NO.16-18, KNOWLEDGE PARK II, GREATER NOIDA,  201306', 139, '121-180', 'February, 2026', 'PART-PAYMENT'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    3566, 'Karnataka', 'Bangalore', 'LOA00002943', 'BSOPA8087J', 'ACGLLLOT00000002053', 'F ALFRED ANTHONY', 9845970186, 'ALFREDANTHONY2611@GMAIL.COM',
    25000, 21250, 3178, 572, 3750, 572.03, 0, 0, 3177.97,
    27, 0.75, 30062.5, '2026-02-03', '2026-03-02', '''9847243335', 'KOTAK MAHINDRA BANK',
    'KKBK0008066', 'INF/NEFT/IN42603455126509/KKBK0008066/65817492 /                              /FALFREDANTH', 'DISBURSED', 'NEW', 'GARISHMA', 'NAVEEN',
    'NO 11 , M G GARDEN NEELASANDRA , VIVEKNAGAR, BANGALORE SOUTH, BENGALURU BANGALORE, KARNATAKA, 560047 NO 11 , M G GARDEN NEELASANDRA , VIVEKNAGAR, BANGALORE SOUTH, BENGALURU BANGALORE, KARNATAKA, 560047  560047', 'ANZ SUPPORT SERVICES INDIA PVT LTD 3J29+4JH, MANYATA RESIDENCY, MANAYATA TECH PARK, THANISANDRA, BENGALURU, KARNATAKA 560045 3J29+4JH, MANYATA RESIDENCY, MANAYATA TECH PARK, THANISANDRA, BENGALURU, KARNATAKA 560045  560045', 140, '121-180', 'February, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    3571, 'Maharashtra', 'Thane', 'LOA00002179', 'BDVPG9353H', 'ACGLLLOT00000002049', 'PRAMILA SHIVNATH GUPTA', 8454080648, 'PRAMILAGUPTA422@GMAIL.COM',
    24000, 20400, 3051, 549, 3600, 549.15, 0, 0, 3050.85,
    27, 0.75, 28860, '2026-02-03', '2026-03-02', '''9046036790', 'KOTAK MAHINDRA BANK LIMITED',
    'KKBK0001244', 'INF/NEFT/IN42603454784481/KKBK0001244/65781605 /                              /PRAMILASHIV', 'DISBURSED', 'REPEAT', 'POOJA', NULL,
    'GAYATRI CHS, C-8/201, SECTOR 7 NEAR POLICE STATION, SANPADA, , NAVI MUMBAI 400705  400705', 'IIFL FINANCE LIMITED CITY POINT, 2ND FLOOR, OPP TELI GALI, ANDHERI EAST, MUMBAI 400069  400069', 140, '121-180', 'February, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    3588, 'Telangana', 'Hyderabad', 'LOA00002948', 'BASPT7664N', 'ACGLLLOT00000002064', 'THUMU SATISH REDDY', 6300993711, 'TSR5653@GMAIL.COM',
    25000, 21250, 3178, 572, 3750, 572.03, 0, 0, 3177.97,
    27, 0.75, 30062.5, '2026-02-03', '2026-03-02', '''448601503224', 'ICICI BANK',
    'ICIC0007829', 'INF/INFT/043221113291/65817492     /THUMUSATISHREDDY    /', 'DISBURSED', 'NEW', 'ASHISH', 'NAVEEN',
    '402, 286/2, SREE RECIDENCY KONDAPUR HYDERABAD RAGHAVENDRA NAGAR COLONY KONDAPUR HYDERABAD 402, 286/2, SREE RECIDENCY KONDAPUR HYDERABAD RAGHAVENDRA NAGAR COLONY KONDAPUR HYDERABAD  500081', 'MATRIX PHARMACORP PRIVATE LIMITE PLOT NO. 1-60/35/A, 6TH TO 9TH FLOOR, HITEC CITY, PHASE II, GACHIBOWLI, SERILINGAMPALLY MANDAL, RANGA REDDY DISTRICT, HYDERABAD, TELANGANA, INDIA - 500081. PLOT NO. 1-60/35/A, 6TH TO 9TH FLOOR, HITEC CITY, PHASE II, GACHIBOWLI, SERILINGAMPALLY MANDAL, RANGA REDDY DISTRICT, HYDERABAD, TELANGANA, INDIA - 500081.  500081', 140, '121-180', 'February, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    3589, 'Telangana', 'Hyderabad', 'LOA00002265', 'CSDPM3817L', 'ACGLLLOT00000002058', 'MENDU  AJAYNATH', 8686311300, 'AJAY.NATH146@GMAIL.COM',
    32000, 27200, 4068, 732, 4800, 732.2, 0, 0, 4067.8,
    27, 0.75, 38480, '2026-02-03', '2026-03-02', '''00000039925901279', 'STATE BANK OF INDIA',
    'SBIN0020536', 'INF/NEFT/IN42603454954710/SBIN0020536/65800441 /                              /MENDUAJAYNA', 'DISBURSED', 'REPEAT', 'PRIYA GUPTA', NULL,
    'PLOT NO 329/C, ROAD NO 17 , C BLOCK, PAPIREDDY NAGAR , JAGATHIRIGUTTA, HYD  500073', 'VILITE TECH SUITE 101, LIFE SHIVA SADHAN, ABIDNAGAR, AKKAYAPALEM, VISAKHAPATNAM 530016 530016', 140, '121-180', 'February, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    3603, 'Maharashtra', 'Raigarh', 'LOA00002718', 'CUKPM4992B', 'ACGLLLOT00000002073', 'PRATHAMESH KASHINATH MANE', 8976299791, 'PRATHAMESHKM@GMAIL.COM',
    20000, 17000, 2542, 458, 3000, 457.63, 0, 0, 2542.37,
    27, 0.75, 24050, '2026-02-03', '2026-03-02', '''50100754527020', 'HDFC BANK LTD',
    'HDFC0006482', 'INF/NEFT/IN42603455237937/HDFC0006482/65826860 /                              /PRATHAMESHK', 'DISBURSED', 'REPEAT', 'KISHAN KUMAR', NULL,
    'C/1/303, HAWARE GREEN PARK J.N.P.T. ROAD,  PLOT NO.15, SECTOR-22, KAMOTHE NAVI MUMBAI, PANVEL, RAIGAD, MAHARASHTRA, 410206 BACK TO MGM HOSPITAL, 410209', 'ADITI ENTERPRISES 3/10, PITAMBAR VILLA, B/H. PRATAP CINEMA, THANE (W) MUMBAI-400099. PRATAP CINEMA, 400099', 140, '121-180', 'February, 2026', 'PART-PAYMENT'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    3612, 'Karnataka', 'Bangalore', 'LOA00002954', 'AJZPA8569N', 'ACGLLLOT00000002091', 'SUJATHA  AGNIHOTRI', 9008399800, 'SUJATHAAGNIHOTRI1007@GMAIL.COM',
    25000, 21250, 3178, 572, 3750, 572.03, 0, 0, 3177.97,
    24, 0.75, 29500, '2026-02-05', '2026-02-28', '''8613010000012908', 'DBS BANK LTD',
    'DBSS0IN0613', 'INF/NEFT/IN42603555868461/DBSS0IN0613/65880835 /                              /SUJATHAAGNI', 'DISBURSED', 'NEW', 'DEEPAK KUMAR', 'NAVEEN',
    'GAGAN SURYA APARTMENT FLAT  101 1ST MAIN ROAD  NEXT TO WILLAMNS INTERNATIONAL COLLEGE BHUVANESHWARI NAGAR MAIN ROAD MANORAYAN PALYA HEBBAL BENGALURU KARNATAKA-560032  560032', 'ACCENTURE SOLUTIONS PVT LTD 8/1 PRESTIGE TECHNOPOLIS DIARY CIRCLE  BANGALORE 560029  560029', 142, '121-180', 'February, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    3659, 'Maharashtra', 'Thane', 'LOA00002962', 'ARCPP7326B', 'ACGLLLOT00000002108', 'DHAVAL SAILESH PATEL', 8104331517, 'DHAVALPATEL234@GMAIL.COM',
    30000, 27000, 2542, 458, 3000, 457.63, 0, 0, 2542.37,
    25, 1, 37500, '2026-02-05', '2026-03-02', '''055501584607', 'ICICI BANK LIMITED',
    'ICIC0000555', 'INF/INFT/043242179441/65912106     /DHAVALSAILESHPATEL  /', 'DISBURSED', 'NEW', 'PRIYA GUPTA', 'NAVEEN',
    'FLAT NO. 1901, 19TH FLOOR VIRAT HEIGHTS CHS LTD SHANTI PARK MIRA ROAD 401107', 'TRUSTPLUTUS WEALTH (INDIA) PRIVATE LIMITED TM  802, NAMAN CENTRE, BKC, BANDRA (E),  400051', 140, '121-180', 'February, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    3719, 'Karnataka', 'Bangalore', 'LOA00002986', 'CTIPP2206C', 'ACGLLLOT00000002143', 'PAVAN KUMAR B G', 7338677870, 'PGOWDA1619@GMAIL.COM',
    25000, 21250, 3178, 572, 3750, 572.03, 0, 0, 3177.97,
    19, 0.75, 28562.5, '2026-02-06', '2026-02-25', '''50100837070911', 'HDFC BANK',
    'HDFC0001039', 'INF/NEFT/IN42603757535885/HDFC0001039/66013524 /                              /PAVANKUMARB', 'DISBURSED', 'NEW', 'DEEPAK KUMAR', 'NAVEEN',
    '31 8TH CROSS 1ST MAIN SHANKRAPPA LAYOUT KENCHENAHALLI RR NAGAR BANGALORE 560098  560098', 'ABBOTT HEALTHCARE PRIVATE LIMITED 94 3RD FLOOR ABBOTT HEALTHCARE PVT LTD TOWERS KENGAL HANUMANTHAIAH ROAD SUDHAMNAGAR BANGALORE 560027  560027', 145, '121-180', 'February, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    3723, 'Gujarat', 'Ahmedabad', 'LOA00002985', 'AOOPV6242F', 'ACGLLLOT00000002141', 'VAGHELA  DIPENDRASINH', 7802844094, 'DIPENDRAVAGHELA123@GMAIL.COM',
    25000, 21250, 3178, 572, 3750, 572.03, 0, 0, 3177.97,
    22, 0.75, 29125, '2026-02-06', '2026-02-28', '''923010007749167', 'AXIS BANK',
    'UTIB0003489', 'INF/NEFT/IN42603757535865/UTIB0003489/66013524 /                              /VAGHELADIPE', 'DISBURSED', 'NEW', 'GARISHMA', 'NAVEEN',
    'B/25-SIKSHAPATRI VILLA SWAMINARAYAN GURUKUL AHMEDABAD GUJARAT- 382430 NR KANBHA BUS STAND 382430', 'LA RENON HEALTHCARE PRIVATE LIMITED LA RENON CORPORATE HOUSE, KENSVILLE ROAD, BEHIND RAJPATH CLUB, OFF SARKHEJ - GANDHINAGAR HIGHWAY, BODAKDEV, AHMEDABAD, GUJARAT 380059 LA RENON CORPORATE HOUSE, KENSVILLE ROAD, BEHIND RAJPATH CLUB, OFF SARKHEJ - GANDHINAGAR HIGHWAY, BODAKDEV, AHMEDABAD, GUJARAT 380059  380059', 142, '121-180', 'February, 2026', 'PART-PAYMENT'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    3739, 'Maharashtra', 'Mumbai', 'LOA00002990', 'AEZPN9023R', 'ACGLLLOT00000002153', 'BHUSHAN ATMARAM NAKTI', 9920448930, 'BHAUMIKBHUSHAN@GMAIL.COM',
    25000, 21250, 3178, 572, 3750, 572.03, 0, 0, 3177.97,
    21, 0.75, 28937.5, '2026-02-07', '2026-02-28', '''3014254773', 'KOTAK MAHINDRA BANK LIMITED',
    'KKBK0001346', 'INF/NEFT/IN42603859134083/KKBK0001346/66105269 /                              /BHUSHANATMA', 'DISBURSED', 'NEW', 'PRIYA GUPTA', 'NAVEEN',
    '1/3 VASUDEO MOURYA CHAWL, BUDHHA NAGAR , P N ROAD , BHANDUP WEST MUMBAI 400078 , NEAR EKTA POLICE CHOWKEY 400078', 'OKI INDIA PRIVATE LIMITED 2ND FLOOR, A-WING, ART GUILD HOUSE, PHOENIX MARKET CITY, LBS MARG,  KURLA WEST MUMBAI,  400070', 142, '121-180', 'February, 2026', 'PART-PAYMENT'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    3749, 'Karnataka', 'Bangalore', 'LOA00002748', 'BKTPD5611G', 'ACGLLLOT00000002151', 'DANIAL  B', 8073543997, 'DANI.ROCKY1@GMAIL.COM',
    25000, 21250, 3178, 572, 3750, 572.03, 0, 0, 3177.97,
    27, 0.75, 30062.5, '2026-02-07', '2026-03-06', '''99980105142470', 'FEDERAL BANK',
    'FDRL0001535', 'INF/NEFT/IN42603858359662/FDRL0001535/66067236 /                              /DANIALB', 'DISBURSED', 'REPEAT', 'DEEPAK KUMAR', NULL,
    'NO 204 SHALOM NILAYA 7TH CROSS MANJUNATH NAGAR BANGALORE 560073 SHANIMAHATHMA TEMPLE. 560073', 'ZERO-SUM WIRELESS SOLUTIONS INDIA PRIVATE LIMITED NO 254 1ST FLOOR INDIRANAGAR 6TH CROSS INDIRANAGAR BANGALORE 560038  560038', 136, '121-180', 'February, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    3775, 'Karnataka', 'Bangalore', 'LOA00002882', 'AUGPP4315D', 'ACGLLLOT00000002169', 'PREM KUMAR G', 9964014246, 'HONNALIPREM@GMAIL.COM',
    16000, 13600, 2034, 366, 2400, 366.1, 0, 0, 2033.9,
    26, 0.85, 19536, '2026-02-09', '2026-03-07', '''333010100118170', 'AXIS BANK',
    'UTIB0000333', 'INF/NEFT/IN42604050104405/UTIB0000333/66155386 /                              /PREMKUMARG', 'DISBURSED', 'REPEAT', 'ASHISH', NULL,
    'KRISHNAPPA BUILDING  NO.3 3 RD FLOOR  BHAVANI ROAD  HEBBGODI  BANGALORE 560099 KRISHNAPPA BUILDING  NO.3 3 RD FLOOR  BHAVANI ROAD  HEBBGODI  BANGALORE 560099  560099', 'EXA THERMOMETRICS NO.73/E ELECTRONIC CITY  BANGALORE 560100 NO.73/E ELECTRONIC CITY  BANGALORE 560100  560100', 135, '121-180', 'February, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    3791, 'Tamil Nadu', 'Chennai', 'LOA00003002', 'ANKPM7148N', 'ACGLLLOT00000002177', 'MOHANRAJ  SADASIVAM', 7738974887, 'MOHANRAJSADASIVAM2004@GMAIL.COM',
    30000, 25500, 3814, 686, 4500, 686.44, 0, 0, 3813.56,
    26, 0.75, 35850, '2026-02-09', '2026-03-07', '''660401075430', 'ICICI BANK LTD',
    'ICIC0003808', 'INF/INFT/043303493691/66175653     /MOHANRAJSADASIVAM   /', 'DISBURSED', 'NEW', 'POOJA', 'NAVEEN',
    'NO.,604,O BLOCK,., THE ROYAL CASTLE APARTMENT THIRUMUDIVAKKAM	CHENNAI  TAMIL NADU	600044 NO.,604,O BLOCK,., THE ROYAL CASTLE APARTMENT THIRUMUDIVAKKAM	CHENNAI  TAMIL NADU	600044  600042', 'STANDARD BELEX INDIA PVT LTD STANDARD BELEX INDIA PVT LTD	BLOCK NO.504 & 506, OPP. JASON DÃ‰COR, AT. VILLAGE VEMARDI, TA : KARJAN, DIST. VADODARA 391210 | GUJARAT | INDIA  391210', 135, '121-180', 'February, 2026', 'PART-PAYMENT'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    3789, 'Telangana', 'Hyderabad', 'LOA00003003', 'ANYPT4368D', 'ACGLLLOT00000002179', 'THEYAGURA PANENDRA REDDY', 7730992911, 'PANENDRAREDDI@GMAIL.COM',
    30000, 25500, 3814, 686, 4500, 686.44, 0, 0, 3813.56,
    18, 0.75, 34050, '2026-02-10', '2026-02-28', '''456801502517', 'ICICI BANK LTD',
    'ICIC0004568', 'INF/INFT/043316567751/66233408     /THEYAGURAPANENDRARED/', 'DISBURSED', 'NEW', 'DEEPAK KUMAR', 'KISHAN KUMAR',
    '16-317/564,KRISHNA REDDY PET, PATANCHERU, HYDERABAD, TELANGANA,502319 NEAR PRANEETH COUNTY 508002', 'EXPELO SOLUTIONS LIMITED II, NO. 283, PRINCE INFOCITY, 6A, SIXTH FLOOR, 3 & 283/4, RAJIV GANDHI SALAI, OMR, KANDANCHAVADI, CHENNAI, TAMIL NADU 600096 LANDMARK. STYLO THE BAG MALL 600094', 142, '121-180', 'February, 2026', 'PART-PAYMENT'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    3841, 'Telangana', 'Hyderabad', 'LOA00003028', 'DWPPK5320F', 'ACGLLLOT00000002223', 'KATTA  SAHITHI', 8919864124, 'KATTASAHITHI946@GMAIL.COM',
    15000, 12750, 1907, 343, 2250, 343.22, 0, 0, 1906.78,
    18, 0.75, 17025, '2026-02-10', '2026-02-28', '''006901569501', 'ICICI BANK LIMITED',
    'ICIC0000069', 'INF/INFT/043328636491/66293110     /KATTASAHITHI/', 'DISBURSED', 'NEW', 'GARISHMA', 'KISHAN KUMAR',
    '2-1-301 2-1-301,PLOT NO 71 NAGOLE  MAMATHA NAGAR COLONY ROAD NO 7C, RANGAREDDY TELANGANA   500068  500068', 'CONCENTRIX CATALYST TECHNOLOGIES PRIVATE LIMITED NSL ARENA TOWERS UPPAL RAMANTHAPUR HYDERABAD 500039 NSL ARENA TOWERS UPPAL RAMANTHAPUR HYDERABAD 500039  500039', 142, '121-180', 'February, 2026', 'PART-PAYMENT'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    3798, 'Tamil Nadu', 'Chennai', 'LOA00003035', 'EJHPS5792H', 'ACGLLLOT00000002233', 'SATHISH  KUMAR', 8925171905, 'MOKSHITHSATHISH18@GMAIL.COM',
    50000, 42500, 6356, 1144, 7500, 1144.07, 0, 0, 6355.93,
    23, 0.75, 58625, '2026-02-11', '2026-03-06', '''50100629195294', 'HDFC BANK',
    'HDFC0000444', 'INF/NEFT/IN42604252583562/HDFC0000444/66356251 /DISBURSE                      /SATHISHKUMA', 'DISBURSED', 'NEW', 'DEEPAK KUMAR', 'KISHAN KUMAR',
    'NO 96 VGP SELVA NAGAR 4TH EXTN STREET VELACHERY CHENNAI 600042  600042', 'TAGORE MEDICAL COLLEGE & HOSPITAL RATHINAMANGALAM, MELAKOTTAIYUR, CHENNAI, TAMIL NADU 600127  600126', 136, '121-180', 'February, 2026', 'PART-PAYMENT'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    3874, 'Maharashtra', 'Thane', 'LOA00003040', 'BMFPS8122R', 'ACGLLLOT00000002239', 'NIKHIL ARUN SARFARE', 9920175291, 'NIKHIL.SARFARE@GMAIL.COM',
    25000, 21250, 3178, 572, 3750, 572.03, 0, 0, 3177.97,
    18, 0.75, 28375, '2026-02-12', '2026-03-02', '''55550130547936', 'FEDERAL BANK',
    'FDRL0005555', 'INF/NEFT/IN42604352954395/FDRL0005555/66383917 /DISBURSE                      /NIKHILARUNS', 'DISBURSED', 'NEW', 'DEEPAK KUMAR', 'KISHAN KUMAR',
    '1/23 UTTAM CHS MITHBUNDER ROAD NEAR SIDDHIVINAYAK TEMPLE THANE EAST 400603  400603', 'TRUST SECURITIES SERVICES PVT. LTD 1101 NAMAN CHAMBERS BANDRA KURLA COMPLEX BANDRA EAST MUMBAI 400051  400051', 140, '121-180', 'February, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    3912, 'Gujarat', 'Ahmedabad', 'LOA00003048', 'FAXPP8268R', 'ACGLLLOT00000002258', 'DHRUV  PATEL', 7405830789, 'DDPP244@GMAIL.COM',
    30000, 25500, 3814, 686, 4500, 686.44, 0, 0, 3813.56,
    17, 0.75, 33825, '2026-02-13', '2026-03-02', '''5513571269', 'KOTAK MAHINDRA BANK LIMITED',
    'KKBK0002572', 'INF/NEFT/IN42604453717868/KKBK0002572/66453173 /DISBURSE                      /DHRUVPATEL', 'DISBURSED', 'NEW', 'DEEPAK KUMAR', 'KISHAN KUMAR',
    'C/101 SHREE EXOTICA  NIKOL NARODA ROAD  AHMEDABAD 382350  382350', 'CODEMAVEN SOLUTION PVT LTD 810 ANTILIA BUSINESS HUB NANA CHILODA CIRCLE AHMEDABAD 382330  382330', 140, '121-180', 'February, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    3923, 'Delhi', 'New Delhi', 'LOA00003050', 'BBJPA7658B', 'ACGLLLOT00000002260', 'AAKASH  AHUJA', 9013385220, 'AAKASHAHUJA52@YAHOO.IN',
    15000, 12750, 1907, 343, 2250, 0, 171.61, 171.61, 1906.78,
    17, 0.75, 16912.5, '2026-02-13', '2026-03-02', '''32982447158', 'STATE BANK OF INDIA',
    'SBIN0013506', 'INF/NEFT/IN42604453808547/SBIN0013506/66462920 /DISBURSE                      /AAKASHAHUJA', 'DISBURSED', 'NEW', 'SHIVANI JOSHI', 'KISHAN KUMAR',
    '215, BHAI PARMANAND COLONY, DR MUHKERJEE NAGAR, NORTH WEST DELHI,110009  110009', 'TRAVELSTACK TECH LIMITED PLOT NO 183 PLATINUM TOWER  UDYOG VIHAR PHASE 1 GURGAON 120003  122003', 140, '121-180', 'February, 2026', 'PART-PAYMENT'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    3960, 'Tamil Nadu', 'Chennai', 'LOA00003054', 'AFTPP7226B', 'ACGLLLOT00000002265', 'PRABHU  KRISHNAMURTHY', 7760355427, 'PRABHU.FERRARI@GMAIL.COM',
    50000, 42500, 6356, 1144, 7500, 1144.07, 0, 0, 6355.93,
    15, 0.75, 55625, '2026-02-13', '2026-02-28', '''000201508712', 'ICICI BANK LIMITED',
    'ICIC0002346', 'INF/INFT/043365741111/66481622     /PRABHUKRISHNAMURTHY /DISBURSE', 'DISBURSED', 'NEW', 'RATNADEEP BIRADAR', 'KISHAN KUMAR',
    'PLOT NO.28 DOOR NO.3, II CROSS STREET, LOGAIAH COLONY, SALIGRAMAM 600086', 'MAERSK GLOBAL SERVICE CENTRES (INDIA) PRIVATE LIMITED MAERSK GLOBAL SERVICES ONE PARAMOUNT MOUNT POONAMALEE HIGH ROAD PORUR CHENNAI 600017', 142, '121-180', 'February, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    3978, 'Delhi', 'New Delhi', 'LOA00002808', 'BBRPC0488F', 'ACGLLLOT00000002272', 'CHANCHAL', 9999872747, '007CHINCH@GMAIL.COM',
    20000, 17000, 2542, 458, 3000, 0, 228.81, 228.81, 2542.37,
    22, 0.75, 23300, '2026-02-13', '2026-03-07', '''20534414700', 'STATE BANK OF INDIA',
    'SBIN0004384', 'INF/NEFT/IN42604454164214/SBIN0004384/66497195 /DISBURSE                      /CHANCHAL', 'DISBURSED', 'REPEAT', 'SHIVANI JOSHI', NULL,
    'A308/B JALAN FARMS CHHATARPUR PHASE 2, CHHATARPUR ENCLAVE PHASE 2, CHATTARPUR ENCLAVE NEW DELHI- 110074  110068', 'VENKATESHWAR HOSPITAL VENKASTESHWAR HOSPITAL DWARKA SECTOR 18A NEW DELHI- 110075  110075', 135, '121-180', 'February, 2026', 'PART-PAYMENT'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    4043, 'Maharashtra', 'Pune', 'LOA00003074', 'AHWPY7592G', 'ACGLLLOT00000002295', 'DIGAMBAR PRAMOD YEOLE', 9765331073, 'DIGAMBARYEOLE777@GMAIL.COM',
    40000, 34000, 5085, 915, 6000, 915.25, 0, 0, 5084.75,
    12, 0.75, 43600, '2026-02-16', '2026-02-28', '''145201503229', 'ICICI BANK LIMITED',
    'ICIC0001452', 'INF/INFT/043390052801/66589497     /DIGAMBARPRAMODYEOLE /DISBURSE', 'DISBURSED', 'NEW', 'SANTOSH KUMAR', 'KISHAN KUMAR',
    'FLAT NO. 302, BUILD -B, GERA ENCLAVE CO-OP HSG SOC VIMAN NAGAR, PUNE - 411 014  411014', 'HEXAWARE TECHNOLOGIES LTD PHASE 3, HINJAWADI RAJIV GANDHI INFOTECH PARK, HINJAWADI, PUNE PIMPRI-CHINCHWAD, MAHARASHTRA 411057  411057', 142, '121-180', 'February, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    4063, 'Haryana', 'Gurgaon', 'LOA00002083', 'AQAPR2342A', 'ACGLLLOT00000002301', 'ROHIT RAJAGOPAL RAMESH', 8879555106, 'SADAYOGI09@GMAIL.COM',
    65000, 55250, 8263, 1487, 9750, 1487.29, 0, 0, 8262.71,
    12, 0.75, 70850, '2026-02-16', '2026-02-28', '''158879555106', 'INDUSIND BANK LTD',
    'INDB0001096', 'INF/NEFT/IN42604755968996/INDB0001096/66613805 /DISBURSE                      /ROHITRAJAGO', 'DISBURSED', 'REPEAT', 'KISHAN KUMAR', NULL,
    'FLAT NO-1106,SUSHANT ESTATE, ARDEE CITY, SECTOR 52, GURUGRAM, HARYANA, IN, NA,TOWER-9,, GURGAON,HARYANA,122003 GURGAON HARYANA, 122003  122002', 'ACME CLEANTECH SOLUTIONS PRIVATE LIMITED PLOT NO - 152,SECTOR - 44, GURGAON - 122002 PLOT NO - 152,SECTOR - 44, GURGAON - 122002  122002', 142, '121-180', 'February, 2026', 'PART-PAYMENT'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    4055, 'Uttar Pradesh', 'Noida', 'LOA00003083', 'BMKPS4715D', 'ACGLLLOT00000002309', 'YASIR ANWAR SIDDIQUI', 9873715709, 'YASIR1986@GMAIL.COM',
    40000, 34000, 5085, 915, 6000, 915.25, 0, 0, 5084.75,
    18, 0.75, 45400, '2026-02-17', '2026-03-07', '''3049912983', 'KOTAK MAHINDRA BANK LIMITED',
    'KKBK0000180', 'INF/NEFT/IN42604856325497/KKBK0000180/66639830 /DISBURSE                      /YASIRANWARS', 'DISBURSED', 'NEW', 'POOJA', 'KISHAN KUMAR',
    '19158 MARVELLA MAHAGUN MYWOODS SEC 16C 201301 HOME 19158 MARVELLA MAHAGUN MYWOODS SEC 16C 201301 HOME  201301', 'INSIGHTS OPINION PRIVATE LIMITED 8TH FLOOR, UNIT - 802, MAJESTIC SIGNIA, A27-A, BLOCK A, INDUSTRIAL AREA, SECTOR 62, NOIDA, UTTAR PRADESH 201309 8TH FLOOR, UNIT - 802, MAJESTIC SIGNIA, A27-A, BLOCK A, INDUSTRIAL AREA, SECTOR 62, NOIDA, UTTAR PRADESH 201309  201309', 135, '121-180', 'February, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    4064, 'Maharashtra', 'Mumbai', 'LOA00003079', 'BMYPS3714E', 'ACGLLLOT00000002304', 'SHAH  KONARK', 9898312142, 'SHAHKONARK123@HOTMAIL.COM',
    30000, 25500, 3814, 686, 4500, 686.44, 0, 0, 3813.56,
    13, 0.75, 32925, '2026-02-17', '2026-03-02', '''50100453830305', 'HDFC BANK',
    'HDFC0001229', 'INF/NEFT/IN42604856325503/HDFC0001229/66639830 /DISBURSE                      /SHAHKONARK', 'DISBURSED', 'NEW', 'RATNADEEP BIRADAR', 'KISHAN KUMAR',
    'FLAT NO:B-WING/1-E, FLOOR NO:1, BUILDING NAME:DHAN RATNA APARTMENTS CHSL BLOCK SECTOR, ANDHERI WEST,JP ROAD 400058', 'ANAND RATHI SHARE AND STOCK BROKERS LIMITED EXPRESS ZONE A WING, 10TH FLOOR OFF WESTERN EXPRESS HIGHWAY GOREGAON EAST,MUMBAI 400063', 140, '121-180', 'February, 2026', 'PART-PAYMENT'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    4087, 'West Bengal', 'Kolkata', 'LOA00003086', 'ATOPB8483D', 'ACGLLLOT00000002312', 'SOUMAVA  BASU', 9748492585, 'SOUMAVABASU13@GMAIL.COM',
    14000, 11900, 1780, 320, 2100, 320.34, 0, 0, 1779.66,
    27, 0.75, 16835, '2026-02-17', '2026-03-16', '''50210038467798', 'BANDHAN BANK LIMITED',
    'BDBL0001347', 'INF/NEFT/IN42604856552482/BDBL0001347/66667958 /DISBURSE                      /SOUMAVABASU', 'DISBURSED', 'NEW', 'PRIYA GUPTA', 'KISHAN KUMAR',
    '146 146,56B-KAILASH GHOSH ROAD PURBA BARISHA GHOSH PARA ROAD 700008 CALCUTTA SOUTH KOLKATTA WEST BENGAL 700008  700008', 'COSCO SHIPPING LINES (INDIA) PRIVATE LIMITED 802, B WING, GODREJ TWO PIROJSHA NAGAR EASTERN EXPRESS HIGHWAY, VIKHR MUMBAI 400079  400079', 126, '121-180', 'February, 2026', 'PART-PAYMENT'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    4088, 'Gujarat', 'Ahmedabad', 'LOA00003084', 'GTKPS2893L', 'ACGLLLOT00000002310', 'SADHU  MAYURKUMAR', 7990193066, 'MAYURSADHU664@GMAIL.COM',
    30000, 25500, 3814, 686, 4500, 686.44, 0, 0, 3813.56,
    13, 0.75, 32925, '2026-02-17', '2026-03-02', '''44915861578', 'STATE BANK OF INDIA',
    'SBIN0003806', 'INF/NEFT/IN42604856427497/SBIN0003806/66652939 /DISBURSE                      /SADHUMAYURK', 'DISBURSED', 'NEW', 'SHIVANI JOSHI', 'KISHAN KUMAR',
    'A/203 DEV KRUPA 2,  B/H NEW D-MART,  NIKOL NARODA ROAD, NEW INDIA COLONY, AHMEDABAD-382350  382350', 'CODEMAVEN SOLUTIONS PVT LTD GROUND FLOOR 1&2, SHALIMAR COMPLEX, NEAR NEW AON  MAHALAXMI ROAD, PALDI AHMEDABAD-380007  380007', 140, '121-180', 'February, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    4101, 'Karnataka', 'Bangalore', 'LOA00003087', 'CFYPV8292L', 'ACGLLLOT00000002313', 'HIMANSHU  VIJAY', 9352094898, 'HIMANSHUVIJAYBANG@GMAIL.COM',
    45000, 38250, 5720, 1030, 6750, 1029.66, 0, 0, 5720.34,
    13, 0.75, 49387.5, '2026-02-17', '2026-03-02', '''00000044893689674', 'STATE BANK OF INDIA',
    'SBIN0003357', 'INF/NEFT/IN42604856427446/SBIN0003357/66652939 /DISBURSE                      /HIMANSHUVIJ', 'DISBURSED', 'NEW', 'POOJA', 'KISHAN KUMAR',
    'HOUSE NO. 54 GOVINDAPPA ROAD BASAVANAGUDI BENGALURU KARNATAKA - 560004 HOUSE NO. 54 GOVINDAPPA ROAD BASAVANAGUDI BENGALURU KARNATAKA - 560004  560004', 'AUTOGRID INDIA PVT LTD (UPLIGHT TECHNOLOGIES INDIA PVT LTD) 256, JFWTC, VIJAYANAGAR, EPIP ZONE, BROOKEFIELD, BENGALURU, KARNATAKA â€“ 560066 256, JFWTC, VIJAYANAGAR, EPIP ZONE, BROOKEFIELD, BENGALURU, KARNATAKA â€“ 560066  560066', 140, '121-180', 'February, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    4151, 'Karnataka', 'Bangalore', 'LOA00003100', 'ANRPT0234D', 'ACGLLLOT00000002337', 'THOLLAMADUGU NAGESWARA RAO', 9986623169, 'NAGESH.THOLL@GMAIL.COM',
    40000, 34000, 5085, 915, 6000, 915.25, 0, 0, 5084.75,
    40, 0.75, 52000, '2026-02-18', '2026-03-30', '''01841140058822', 'HDFC BANK',
    'HDFC0000184', 'INF/NEFT/IN42604957232719/HDFC0000184/66731757 /DISBURSE                      /THOLLAMADUG', 'DISBURSED', 'NEW', 'ASHISH', 'KISHAN KUMAR',
    '252, PURUSHOTTAM REDDY BUILDING, DODDATHOGU, ELECTRONIC CITY, BANGALORE, KARNATAKA, 260100 252, PURUSHOTTAM REDDY BUILDING, DODDATHOGU, ELECTRONIC CITY, BANGALORE, KARNATAKA, 260100  560100', 'TCS : 6TH FLOOR 6TH ODC, VICTOR BUILDING, ITPL, WHITEFIELD, 560066 : 6TH FLOOR 6TH ODC, VICTOR BUILDING, ITPL, WHITEFIELD, 560066  560066', 112, '91-120', 'February, 2026', 'PART-PAYMENT'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    4162, 'Karnataka', 'Bangalore', 'LOA00003110', 'BYIPR9149A', 'ACGLLLOT00000002348', 'RAJEEVA B A', 6362120965, 'RAJIVRAJVII@GMAIL.COM',
    25000, 21250, 3178, 572, 3750, 572.03, 0, 0, 3177.97,
    40, 0.75, 32500, '2026-02-19', '2026-03-31', '''9050490151', 'KOTAK MAHINDRA BANK',
    'KKBK0009807', 'INF/NEFT/IN42605057563209/KKBK0009807/66757936 /DISBURSE                      /RAJEEVABA', 'DISBURSED', 'NEW', 'PAYAL NAINWAL', 'KISHAN KUMAR',
    '102 GREEN VISTA VILLA GUNJUR MULLUR VISTA VILLA BANGLORE KARANATAK INDIA 560103  560035', 'WIPRO LIMITED AMBEDKAR NAGAR SARJAPUR ROAD BANGALORE 560035  560035', 111, '91-120', 'February, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    4170, 'Karnataka', 'Bangalore', 'LOA00003108', 'BCFPR7334L', 'ACGLLLOT00000002346', 'SOURAV  ROY', 8293157827, 'ROY.SOURAV89@GMAIL.COM',
    40000, 34000, 5085, 915, 6000, 915.25, 0, 0, 5084.75,
    35, 0.75, 50500, '2026-02-19', '2026-03-26', '''10223856872', 'IDFC BANK LIMITED',
    'IDFB0080151', 'INF/NEFT/IN42605057563132/IDFB0080151/66757936 /DISBURSE                      /SOURAVROY', 'DISBURSED', 'NEW', 'POOJA', 'KISHAN KUMAR',
    '3RD CROSS ROAD, 41/42 TIPENAHALLY, DODDAIBIDARAKALLU, BANGALORE- 560073 3RD CROSS ROAD, 41/42 TIPENAHALLY, DODDAIBIDARAKALLU, BANGALORE- 560073  560073', 'ARROW ELECTRONICS INDIA PRIVATE LIMITED SKAV BUILDING, KASTHURBAROAD, ARROW ELECTRONICS, BANGALORE- 560001 SKAV BUILDING, KASTHURBAROAD, ARROW ELECTRONICS, BANGALORE- 560001  560001', 116, '91-120', 'February, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    2582, 'Karnataka', 'Bangalore', 'LOA00003127', 'GVTPS5761J', 'ACGLLLOT00000002374', 'SHUBHAM  SINGH', 8428257256, 'SUBHAMSINGH04@GMAIL.COM',
    30000, 25500, 3814, 686, 4500, 686.44, 0, 0, 3813.56,
    38, 0.75, 38550, '2026-02-21', '2026-03-31', '''50100777725667', 'HDFC BANK',
    'HDFC0002010', 'INF/NEFT/IN42605258882820/HDFC0002010/66889855 /DISBURSE                      /SHUBHAMSING', 'DISBURSED', 'NEW', 'DEEPAK KUMAR', 'NAVEEN',
    '204 S N P ARCADE , BOREWELL ROAD , NALLURHALLI WHITEFIELD 560066 BANGALORE  560066', 'CAPGEMINI TECHNOLOGY SERVICES INDIA LIMITED OFFICE ADDRESS  CAPGEMINI , EPIP OFFICE , NALLURHALLI , WHITEFIELD 560066 BANGALORE  560066', 111, '91-120', 'February, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    4207, 'Karnataka', 'Bangalore', 'LOA00003122', 'EGBPK3403A', 'ACGLLLOT00000002367', 'NEETISH  KUMAR', 7976115131, 'NNNNITISH0KUMAR@GMAIL.COM',
    30000, 27000, 2542, 458, 3000, 457.63, 0, 0, 2542.37,
    37, 1, 41100, '2026-02-21', '2026-03-30', '''44762302383', 'STATE BANK OF INDIA',
    'SBIN0032295', 'INF/NEFT/IN42605258676228/SBIN0032295/66867137 /DISBURSE                      /NEETISHKUMA', 'DISBURSED', 'NEW', 'DEEPAK KUMAR', 'KISHAN KUMAR',
    'ASHRAYA APARTMENT, HOUSE NO - 10, MULLUR , BEHIND GOVERNMENT PRIMARY SCHOOL ,KODHATI GATE ,BANGALORE, KARNATAKA - 560035  560035', 'MIRAFRA SOFTWARE TECHNOLOGIES PVT LTD MIRAFRA SOFTWARE TECHNOLOGIES PRIVATE LIMITED-- AKSHAY TECH PARK, 72AND73, EPIP ZONE, WHITEFIELD, BANGLORE ,560066  560066', 112, '91-120', 'February, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    4208, 'Tamil Nadu', 'Chennai', 'LOA00003120', 'ANIPJ2934M', 'ACGLLLOT00000002363', 'SUNDARRAJAN  J', 9884675588, 'sundarrajan.jayasankar@gmail.com',
    15000, 12750, 1907, 343, 2250, 343.22, 0, 0, 1906.78,
    31, 0.75, 18487.5, '2026-02-21', '2026-03-24', '''50100060867031', 'HDFC BANK',
    'HDFC0000847', 'INF/NEFT/IN42605258676212/HDFC0000847/66867137 /DISBURSE                      /SUNDARRAJAN', 'DISBURSED', 'NEW', 'PRIYA GUPTA', 'KISHAN KUMAR',
    'N0.57/73, 1ST FLOOR RAMANUJAM, KUDAM STREET OLD, WASHERMENPET WASHERMENPET CHENNAI 600021  600021', 'HDFC BANK LTD NO 8 L B ROAD THIRUVANMIYUR CHENNAI  600041', 118, '91-120', 'February, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    4303, 'Telangana', 'Hyderabad', 'LOA00003141', 'CCSPP4083N', 'ACGLLLOT00000002405', 'ANISH MARTIN PASUPULETI', 7842610964, 'ANISHMARTIN1215@GMAIL.COM',
    15000, 12750, 1907, 343, 2250, 343.22, 0, 0, 1906.78,
    35, 0.75, 18937.5, '2026-02-24', '2026-03-31', '''50100438479510', 'HDFC BANK',
    'HDFC0002083', 'INF/NEFT/IN42605550170394/HDFC0002083/66994409 /DISBURSE                      /ANISHMARTIN', 'DISBURSED', 'NEW', 'PAYAL NAINWAL', 'KISHAN KUMAR',
    'PLOT NO-177,FNO-101 LST FLR. SURAJ VIDHI HOMES. ANJANEYA NAGAR  MOOOSAPET. 500018  500018', 'COGNIZANT TECHNOLOGY SOLUTIONS INDIA PRIVATE LTD COGNIZANT RAHEJA MIND SPACE BUILDING NO. 20 HYD  , 500081  500081', 111, '91-120', 'February, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    4317, 'Tamil Nadu', 'Coimbatore', 'LOA00002749', 'BPFPP1407K', 'ACGLLLOT00000002406', 'PRADEEPKUMAR  R', 9043883237, 'PRADEEP8742@GMAIL.COM',
    25000, 21250, 3178, 572, 3750, 572.03, 0, 0, 3177.97,
    35, 0.75, 31562.5, '2026-02-24', '2026-03-31', '''922010067767409', 'AXIS BANK',
    'UTIB0000563', 'INF/NEFT/IN42605550140471/UTIB0000563/66989767 /DISBURSE                      /PRADEEPKUMA', 'DISBURSED', 'REPEAT', 'GARISHMA', NULL,
    '1/470A, GN NAGAR THOTTATHUPALAYAM POOLUVAPATTI TIRUPUR TAMIL NADU- 641602  641602', 'ENTERPRISE SYSTEM SOLUTIONS PVT.  LTD. 3RD FLOOR, INDIQUBE TECH PARK DOMLUR STAGE 1 DOMLUR BANGALORE KARNATAKA 560071 3RD FLOOR, INDIQUBE TECH PARK DOMLUR STAGE 1 DOMLUR BANGALORE KARNATAKA 560071  560071', 111, '91-120', 'February, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    4339, 'Maharashtra', 'Thane', 'LOA00003155', 'BHPPM3685N', 'ACGLLLOT00000002439', 'TUSHAR RAMDAS MORE', 9167632016, 'TUSHAR428@GMAIL.COM',
    26000, 22100, 3305, 595, 3900, 594.92, 0, 0, 3305.08,
    40, 0.75, 33800, '2026-02-25', '2026-04-06', '''925010057162666', 'AXIS BANK',
    'UTIB0003802', 'INF/NEFT/IN42605650841018/UTIB0003802/67062026 /DISBURSE                      /TUSHARRAMDA', 'DISBURSED', 'NEW', 'POOJA', 'KISHAN KUMAR',
    'FLAT NO 1005, A WING 10TH FLOOR, CASA REGALIA CHS, LAKESHORE GREEN, PALAVA PHASE 2, TALOJA BYPASS ROAD, DOMBIVALI EAST, THANE MAHARASHTRA 421204 FLAT NO 1005, A WING 10TH FLOOR, CASA REGALIA CHS, LAKESHORE GREEN, PALAVA PHASE 2, TALOJA BYPASS ROAD, DOMBIVALI EAST, THANE MAHARASHTRA 421204  421202', 'TRUBRIDGE HEALTHCARE PRIVATE LIMITED FLAT NO 1005, A WING 10TH FLOOR, CASA REGALIA CHS, LAKESHORE GREEN, PALAVA PHASE 2, TALOJA BYPASS ROAD, DOMBIVALI EAST, THANE MAHARASHTRA 421204 FLAT NO 1005, A WING 10TH FLOOR, CASA REGALIA CHS, LAKESHORE GREEN, PALAVA PHASE 2, TALOJA BYPASS ROAD, DOMBIVALI EAST, THANE MAHARASHTRA 421204  400204', 105, '91-120', 'February, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    4359, 'Maharashtra', 'Thane', 'ADV00001769', 'AEEPV4316G', 'ACGLLLOT00000002427', 'KUNJAN NAVIN VAISHYA', 9833280375, 'KUNJAZZ23@GMAIL.COM',
    73000, 62050, 9280, 1670, 10950, 1670.34, 0, 0, 9279.66,
    34, 0.75, 91615, '2026-02-25', '2026-03-31', '''09600030000339', 'KOTAK MAHINDRA BANK LIMITED',
    'KKBK0000960', 'INF/NEFT/IN42605650611242/KKBK0000960/67034097 /DISBURSE                      /KUNJANNAVIN', 'DISBURSED', 'REPEAT', 'DEEPAK KUMAR', 'KISHAN KUMAR',
    'FLAT NO. 19, PARAG CO.OP.HOUSING SOCIETY PLOT NUMBER :19 ROAD THANE, 400603 OPPOSITE TO JIJAMATA HALL 400603', 'INDEGENE LIMITED 3RD FLOOR,ASPEN G-4 BLOCK,MANYATA EMBASSY BUSINESS PARK,OUTER RING ROAD, MANYATA TECH PARK,NAGWARA,BENGALURU - 560045  560045', 111, '91-120', 'February, 2026', 'PART-PAYMENT'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    4371, 'Maharashtra', 'Thane', 'ADV00001785', 'ALIPJ1305N', 'ACGLLLOT00000002454', 'NILESH SHAMRAO JADHAV', 9768764706, 'NEIL.JADHAV76@GMAIL.COM',
    35000, 29750, 4449, 801, 5250, 800.85, 0, 0, 4449.15,
    33, 0.75, 43662.5, '2026-02-26', '2026-03-31', '''159768764706', 'INDUSIND BANK',
    'INDB0000406', 'INF/NEFT/IN42605751131692/INDB0000406/67084406 /DISBURSE                      /NILESHSHAMR', 'DISBURSED', 'REPEAT', 'POOJA', NULL,
    'ROOM NO 2, CHAWL NO A-125,  TURBHE TURBHE VASHI NAVI MUMBAI THANE THANE NAVI MUMBAI, MAHARASHTRA, 400703 NEAR ICL HIGHSCHOOL S ECTOR 21, 400703', 'NUVAMA CLEARING SERVICE PVT LTD. 3, INSPIRE BKC, G BLOCK, BANDRA KURLA COMPLEX, BANDRA EAST, MUMBAI â€“ 400051 BANDRA KURLA COMPLEX 400051', 111, '91-120', 'February, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    4403, 'Tamil Nadu', 'Chennai', 'LOA00003164', 'BBLPA6225N', 'ACGLLLOT00000002466', 'ASHOK  S', 9940431496, 'SASHOK.2693@GMAIL.COM',
    20000, 17000, 2542, 458, 3000, 457.63, 0, 0, 2542.37,
    33, 0.75, 24950, '2026-02-26', '2026-03-31', '''50100045691589', 'HDFC BANK',
    'HDFC0000880', 'INF/NEFT/IN42605751346043/HDFC0000880/67111706 /DISBURSE                      /ASHOKS', 'DISBURSED', 'NEW', 'POOJA', 'KISHAN KUMAR',
    'NO 407 MUTHAMIL STREET PERIYAR NAGAR VYASARPADI CHENNAI 600039 NO 407 MUTHAMIL STREET PERIYAR NAGAR VYASARPADI CHENNAI 600039  600039', 'CIPLA HOUSE LOWER PAREL NO 95 MADHURAVOYAL HIGH ROAD MADHURAVOYAL CHENNAI 600095 NO 95 MADHURAVOYAL HIGH ROAD MADHURAVOYAL CHENNAI 600095  600094', 111, '91-120', 'February, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    4442, 'Karnataka', 'Bangalore', 'LOA00002780', 'AWBPP5543K', 'ACGLLLOT00000002491', 'PRANEETH  MANYAM', 9590548886, 'MPRANEETHNAIDU@GMAIL.COM',
    54000, 45900, 6864, 1236, 8100, 1235.59, 0, 0, 6864.41,
    32, 0.75, 66960, '2026-02-27', '2026-03-31', '''89570100029781', 'Bank Of Baroda',
    'BARB0VJHALX', 'INF/NEFT/IN42605851870808/BARB0VJHALX/67158286 /DISBURSE                      /PRANEETHMAN', 'DISBURSED', 'REPEAT', 'ASHISH', 'KISHAN KUMAR',
    'PRANEETH MANYAM SAPTHAGIRI NILAYAM, 15-1/2A, 1ST CROSS ROAD, GREENWOOD LAYOUT PHASE 2, VARANASI MAIN ROAD BENGALURU, KARNATAKA 560036 PRANEETH MANYAM SAPTHAGIRI NILAYAM, 15-1/2A, 1ST CROSS ROAD, GREENWOOD LAYOUT PHASE 2, VARANASI MAIN ROAD BENGALURU, KARNATAKA 560036  560036', 'COMPUTACENTER INDIA PRIVATE LIMITE COMPUTACENTER INDIA PRIVATE LIMITED, BREN ARTIMUS, #9/8-1, DR MH MARIGOWDA ROAD, HOSUR ROAD, ADUGODI, BANGALORE, KARNATAKA, 560029, INDIA COMPUTACENTER INDIA PRIVATE LIMITED, BREN ARTIMUS, #9/8-1, DR MH MARIGOWDA ROAD, HOSUR ROAD, ADUGODI, BANGALORE, KARNATAKA, 560029, INDIA  500161', 111, '91-120', 'February, 2026', 'PART-PAYMENT'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    4460, 'Andhra Pradesh', 'Visakhapatnam', 'LOA00003173', 'BJDPS2321H', 'ACGLLLOT00000002507', 'SARIPALLI BALAJI RAO', 9885723423, 'BALAJIRAO.S@GMAIL.COM',
    25000, 21250, 3178, 572, 3750, 572.03, 0, 0, 3177.97,
    34, 0.75, 31375, '2026-02-27', '2026-04-02', '''919010068099534', 'AXIS BANK',
    'UTIB0002943', 'INF/NEFT/IN42605852074872/UTIB0002943/67170027 /DISBURSE                      /SARIPALLIBA', 'DISBURSED', 'NEW', 'VARSHA', 'KISHAN KUMAR',
    'FLAT NO-501 , VAYUPUTRA ELEGANT , ROAD NO-3 SATAVAHANA NAGAR VSP , VISHAKHAPATNAM , - - 530046  530046', 'MULTISOFTNET DOT COM PRIVATE LIMITED FLAT NO 502, NEAR GVK PLAZA, ABOVE VIJAYA MEDICAL CENTER, GURUDWARA JN, VISAKHAPATNAM 530016  530016', 109, '91-120', 'February, 2026', 'PART-PAYMENT'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    4469, 'Maharashtra', 'Pune', 'LOA00003026', 'BOYPB9402C', 'ACGLLLOT00000002504', 'ANKIT  BHUTADA', 7387785349, 'BHUTADAANKIT18@GMAIL.COM',
    65000, 58500, 5508, 992, 6500, 991.53, 0, 0, 5508.47,
    32, 0.85, 82680, '2026-02-27', '2026-03-31', '''098601553870', 'ICICI BANK LIMITED',
    'ICIC0000986', 'INF/INFT/043503985351/67158286     /ANKITBHUTADA/DISBURSE', 'DISBURSED', 'REPEAT', 'KISHAN KUMAR', NULL,
    'ROW HOUSE NO 69, MANJRI BK PUNE, MAHARASHTRA, INDIA PUNE MAHARASHTRA, 412307 RAVI GARDEN, NANDINI TAKLE NAGAR, 412307', 'ALTIMETRIK INDIA PVT LTD, NO. 2A/1, GROUND FLOOR, TOWER B, TECH PARK ONE SURVEY NO, ''1 91, HISSA, 2, AIRPORT RD, YERAWADA, PUNE, MAHARASHTRA 411006 TOWER B, TECH PARK ONE 411006', 111, '91-120', 'February, 2026', 'PART-PAYMENT'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    4472, 'Andhra Pradesh', 'Visakhapatnam', 'LOA00002833', 'BSIPN7719L', 'ACGLLLOT00000002505', 'PHANENDRA KUMAR NETTEM', 7095815047, 'KUMARPHANI115@GMAIL.COM',
    25000, 21250, 3178, 572, 3750, 572.03, 0, 0, 3177.97,
    32, 0.75, 31000, '2026-02-27', '2026-03-31', '''50100578679480', 'HDFC BANK',
    'HDFC0001032', 'INF/NEFT/IN42605852074903/HDFC0001032/67170027 /DISBURSE                      /PHANENDRAKU', 'DISBURSED', 'REPEAT', 'PAYAL NAINWAL', 'KISHAN KUMAR',
    'MAMIDIWADA VILLAGE, RAMBILLI MANDAL, VISHAKAPATNAM DT, ANDHRA PRADESH,531061  CURRENT ADRESS  531061', 'HITACHI RAIL STS INDIA PVT LTD. HITACHI RAIL STS, MARUTHI INFO TECH, DOMLUR, BANGALORE, KARNATAKA 560071  560071', 111, '91-120', 'February, 2026', 'PART-PAYMENT'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    4483, 'Karnataka', 'Bangalore', 'LOA00002777', 'ATCPP3555C', 'ACGLLLOT00000002518', 'RAJIV  PHILIP', 9515871086, 'RAJIVPHIL@GMAIL.COM',
    30000, 25500, 3814, 686, 4500, 686.44, 0, 0, 3813.56,
    32, 0.75, 37200, '2026-02-27', '2026-03-31', '''50100218162266', 'HDFC BANK',
    'HDFC0001555', 'INF/NEFT/IN42605852213055/HDFC0001555/67185217 /DISBURSE                      /RAJIVPHILIP', 'DISBURSED', 'REPEAT', 'PRIYA GUPTA', NULL,
    'FLAT NO. 07, NO. 37, MAYAN''S 1, 3RD FLOOR BTM 4TH STAGE, 4TH CROSS, SIR VISHWESHVARAIYA ROAD, VIJAYA BANK COLONY  560076', 'CALPION SOFTWARE TECHNOLOGIES PRIVATE LIMITED HEAD OFFICE LEXINGTON TOWERS, TAVAREKERE MAIN ROAD, TAVARKERE, S G PALYA BENGALURU  KARNATAKA 560029 INDIA  560029', 111, '91-120', 'February, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    4524, 'Uttar Pradesh', 'Ghaziabad', 'LOA00002484', 'BAYPD9825P', 'ACGLLLOT00000002553', 'VIVEK KUMAR DUBEY', 9999139865, 'VIVEK.ASPIRATIONS@GMAIL.COM',
    78000, 66300, 9915, 1785, 11700, 1784.75, 0, 0, 9915.25,
    31, 0.75, 96135, '2026-02-28', '2026-03-31', '''055801572942', 'ICICI BANK LIMITED',
    'ICIC0000403', 'INF/INFT/043516156751/67216729     /VIVEKKUMARDUBEY     /DISBURSE', 'DISBURSED', 'REPEAT', 'DEEPAK KUMAR', 'KISHAN KUMAR',
    'S/O VIRENDRA KUMAR DUBEY, B7-401, UNINAV BLISS, NEAR AVS CITY PALACE, RAJ NAGAR EXTENSION, GHAZIABAD, UTTAR PRADESH - 201017  201017', 'LTIMINDTREE LIMITED CANDOR TECHSPACE BLOCK B INDUSTRIAL AREA SECTOR 62 NOIDA 201309  201309', 111, '91-120', 'February, 2026', 'PART-PAYMENT'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    4531, 'Telangana', 'Hyderabad', 'LOA00002848', 'FHIPP8590N', 'ACGLLLOT00000002557', 'PEDDINNI JITENDRA SAI', 8466985413, 'JITENDRAPEDDINNI5413@GMAIL.COM',
    20000, 17000, 2542, 458, 3000, 457.63, 0, 0, 2542.37,
    31, 0.75, 24650, '2026-02-28', '2026-03-31', '''5813283893', 'KOTAK MAHINDRA BANK LIMITED',
    'KKBK0000560', 'INF/NEFT/IN42605952697003/KKBK0000560/67227287 /DISBURSE                      /PEDDINNIJIT', 'DISBURSED', 'REPEAT', 'GARISHMA', 'KISHAN KUMAR',
    'FLAT NO- 201,NAGARJUNA CLASSIC SOC98544 NAGARJUNA CLASSIC MNR PURAM  KALYAN NAGAR  PHASE 3 MOTHI NAGAR HYDERABAD TELANGANA - 500018  500018', 'GURU GOWRI KRUPA TECHNOLOGIES PRIVATE LIMITED 14 & 15 FLOOR  GAR LAXMI INFORBHAN  TOWER 1 KOKAPET  NEAR ORR 500075 14 & 15 FLOOR  GAR LAXMI INFORBHAN  TOWER 1 KOKAPET  NEAR ORR 500075  500074', 111, '91-120', 'February, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    4541, 'Karnataka', 'Bangalore', 'LOA00002904', 'BANPG0282J', 'ACGLLLOT00000002561', 'GANGADHAR', 9632787441, 'GANGADHARHIREMATH3@GMAIL.COM',
    30000, 25500, 3814, 686, 4500, 686.44, 0, 0, 3813.56,
    31, 0.75, 36975, '2026-02-28', '2026-03-31', '''309011630829', 'THE RATNAKAR BANK LTD',
    'RATN0000407', 'INF/NEFT/IN42605952593240/RATN0000407/67216729 /DISBURSE                      /GANGADHAR', 'DISBURSED', 'REPEAT', 'GARISHMA', NULL,
    'H NO 33 GROUND FLOOR 1ST MAIN BALAJI LAYOUT VIDYARANAPURA BANGALORE 560097 H NO 33 GROUND FLOOR 1ST MAIN BALAJI LAYOUT VIDYARANAPURA BANGALORE 560097  560097', 'AT & T COMMUNICATION SERVICES INDIA PVT. LTD. 10TH INNOVATOR BUILDING ITPL WHITEFIELD ROAD BANGALORE 560097 10TH INNOVATOR BUILDING ITPL WHITEFIELD ROAD BANGALORE 560097  560097', 111, '91-120', 'February, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    4565, 'Maharashtra', 'Thane', 'LOA00002960', 'BWHPS4024G', 'ACGLLLOT00000002580', 'SHRAVAN AMREJ SINGH', 9370376606, 'SINGHSHRAVAN059@GMAIL.COM',
    25000, 21250, 3178, 572, 3750, 572.03, 0, 0, 3177.97,
    31, 0.75, 30812.5, '2026-02-28', '2026-03-31', '''001101628337', 'ICICI BANK LIMITED',
    'ICIC0000011', 'INF/INFT/043518901791/67233999     /SHRAVANAMREJSINGH   /DISBURSE', 'DISBURSED', 'REPEAT', 'POOJA', NULL,
    'ROYAL AMI PARK B WING ROOM NO 105/106 GOKHIVARE VASAI EAST ROYAL AMI PARK B WING ROOM NO 105/106 GOKHIVARE VASAI EAST  401208', 'MEDIA.NET SOFTWARE SERVICES (INDIA) PVT. LTD. DIRECTIPLEX NEXT TO  ANDHERI SUBWAY OLD NAGARDAS ROAD ANDHERI EAST MUMBAI 400069Directiplex next to  Andheri subway old nagardas road Andheri east mumbai 400069 DIRECTIPLEX NEXT TO  ANDHERI SUBWAY OLD NAGARDAS ROAD ANDHERI EAST MUMBAI 400069  400069', 111, '91-120', 'February, 2026', 'PART-PAYMENT'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    4618, 'Telangana', 'Hyderabad', 'ADV00000724', 'CEOPM1390H', 'ACGLLLOT00000002638', 'ARCHANA  MURUGAN', 9502645006, 'ARCHANAMURUGAN40@GMAIL.COM',
    33000, 28050, 4195, 755, 4950, 755.08, 0, 0, 4194.92,
    30, 0.75, 40425, '2026-03-01', '2026-03-31', '''50100734446124', 'HDFC BANK LTD',
    'HDFC0006157', 'INF/NEFT/IN42606053406617/HDFC0006157/67272191 /DISBURSE                      /ARCHANAMURU', 'DISBURSED', 'REPEAT', 'KISHAN KUMAR', NULL,
    'P,NO 20/1, PUPPALGUDA, 2, MANIKONDA, HYDERABAD TELANGANA - 500089 MANIKONDA 500089', 'TDCX DIGILAB INDIA PVT LTD 1203&1204,12TH FLOOR,SKYVIEW 20,S.NO. 83/1, RAIDURG,(PANMAQTHA)VILLAGESERILINGAMPALL Y MANDAL, , RANGA REDDY HYDERABAD, TELANGANA, INDIA - 500081. RAIDURG 500081', 111, '91-120', 'March, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    4623, 'Maharashtra', 'Mumbai', 'LOA00002974', 'ANWPD6732H', 'ACGLLLOT00000002630', 'CHANDRAMOHAN RAMESH DHONDIYAL', 9769339669, 'CHANDRAMOHAN9187@GMAIL.COM',
    32000, 27200, 4068, 732, 4800, 732.2, 0, 0, 4067.8,
    30, 0.75, 39200, '2026-03-01', '2026-03-31', '''45810100012359', 'BANK OF BARODA',
    'BARB0MIRBHA', 'INF/NEFT/IN42606053408128/BARB0MIRBHA/67272191 /DISBURSE                      /CHANDRAMOHA', 'DISBURSED', 'REPEAT', 'POOJA', NULL,
    'ADDRESS : 129/13 A WING WESTERN RAILWAY COLONY KHERWADI ROAD, BANDRA EAST MUMBAI- 400051. NEAR SIBBU PALACE ADDRESS : 129/13 A WING WESTERN RAILWAY COLONY KHERWADI ROAD, BANDRA EAST MUMBAI- 400051. NEAR SIBBU PALACE  400051', 'ADECCO INDIA PRIVATE LIMITED ALTIMUS TOWER 25TH LANE DR, GM BHOSALE MARG, OPP. MAHINDRA TOWER, B WING, BDD CHAWLS WORLI, WORLI, MUMBAI, MAHARASHTRA 400018 ALTIMUS TOWER 25TH LANE DR, GM BHOSALE MARG, OPP. MAHINDRA TOWER, B WING, BDD CHAWLS WORLI, WORLI, MUMBAI, MAHARASHTRA 400018  400018', 111, '91-120', 'March, 2026', 'PART-PAYMENT'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    4643, 'Karnataka', 'Bangalore', 'LOA00002622', 'EQEPK1214E', 'ACGLLLOT00000002640', 'KEERTHANA  K', 8197607612, 'KEERTHANA9508@GMAIL.COM',
    25000, 21250, 3178, 572, 3750, 572.03, 0, 0, 3177.97,
    30, 0.75, 30625, '2026-03-01', '2026-03-31', '''50100171624294', 'HDFC BANK',
    'HDFC0001300', 'INF/NEFT/IN42606053406576/HDFC0001300/67272191 /DISBURSE                      /KEERTHANAK', 'DISBURSED', 'REPEAT', 'KISHAN KUMAR', NULL,
    '83, 4TH CROSS, 1ST MAIN ROAD, KALIDASA LAYOUT, SRI!LAGARA, BANASHANKARI 1ST STAGE, BANGALORE, KARNATAKA, 560050 NEAR RAGHAVENDRA SWAMY MUTT 560050', 'GALLAGHER SERVICE CENTER LLP GROUND, 1ST & 2ND FLOOR BRIGADE A WING, B WING, YELAHANKA, BENGALURU, KARNATAKA 560092 MAGNUM DEVANAHALLI AIRPOT ROAD 560092', 111, '91-120', 'March, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    4663, 'Karnataka', 'Bangalore', 'LOA00003094', 'CQSPP7367P', 'ACGLLLOT00000002662', 'MOHAMMED NADEEM PASHA', 7846888682, 'NADIMNADIM404@GMAIL.COM',
    10000, 8500, 1271, 229, 1500, 228.81, 0, 0, 1271.19,
    36, 0.75, 12700, '2026-03-01', '2026-04-06', '''0523053000010272', 'SOUTH INDIAN BANK',
    'SIBL0000523', 'INF/NEFT/IN42606053448551/SIBL0000523/67273801 /DISBURSE                      /MOHAMMEDNAD', 'DISBURSED', 'REPEAT', 'PAYAL NAINWAL', 'KISHAN KUMAR',
    '25 1ST MAIN 1ST CROSS KANKANAGAR BENGALURU -560032 25 1ST MAIN 1ST CROSS KANKANAGAR BENGALURU -560032  560032', 'NJK PHARMACY PRIVATE LIMITED 12/2 DEFENCE LAYOUT SAREPALYA THANISANDRA MAIN ROAD BENGALURU -560077 12/2 DEFENCE LAYOUT SAREPALYA THANISANDRA MAIN ROAD BENGALURU -560077  560077', 105, '91-120', 'March, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    4567, 'Maharashtra', 'Thane', 'LOA00003034', 'CRRPB5769H', 'ACGLLLOT00000002591', 'KAUSTUBH SANJAY BORLIKAR', 9004897973, 'KAUSTUBHBORLIKAR@GMAIL.COM',
    30000, 25500, 3814, 686, 4500, 686.44, 0, 0, 3813.56,
    30, 0.75, 36750, '2026-03-02', '2026-03-31', '''925010040640737', 'AXIS BANK',
    'UTIB0004933', 'INF/NEFT/IN42606153732620/UTIB0004933/67243162 /DISBURSE                      /KAUSTUBHSAN', 'DISBURSED', 'REPEAT', 'DEEPAK KUMAR', NULL,
    '75 OMKAR, HARKODI WADI, KIRAVALI, NEAR CROSS,VASAI (WEST) 401201  401201', 'PAYU PAYMENTS PRIVATE LIMITED 1ST FLOOR WALLACE TOWERS, NEXT TO GARWARE POLYFILMS VILEPARLE EAST MUMBAI 400057  400057', 111, '91-120', 'March, 2026', 'PART-PAYMENT'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    4587, 'Telangana', 'Rangareddy', 'LOA00002761', 'ACGPE6343N', 'ACGLLLOT00000002603', 'ESLAVATH  VENKATESH', 8897253646, 'VENKATESH.ESLAVATH1109@GMAIL.COM',
    22000, 18700, 2797, 503, 3300, 503.39, 0, 0, 2796.61,
    29, 0.75, 26785, '2026-03-02', '2026-03-31', '''918010039623316', 'AXIS BANK',
    'UTIB0002744', 'INF/NEFT/IN42606153745080/UTIB0002744/67249835 /DISBURSE                      /ESLAVATHVEN', 'DISBURSED', 'REPEAT', 'DEEPAK KUMAR', NULL,
    '1-112/15 NADIGADDA THANDA MIYAPUR HYDERABAD TELANGANA 500049 TAKE LEFT FROM HANUMAN TEMPLE 500049', 'FOUNDEVER CRM INDIA PRIVATE LIMITED BLOCK B GROUND FLOOR CYBER PEARL BUILDING HITECH CITY HYDERABAD TELANGANA 500081, ADJACENT TO RAIDURG METRO STATION 500081', 111, '91-120', 'March, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    4607, 'Delhi', 'New Delhi', 'LOA00003107', 'BMJPK4144D', 'ACGLLLOT00000002621', 'RAJIV  KUMAR', 9866141400, 'RAJIVJIO2718@GMAIL.COM',
    35000, 29750, 4449, 801, 5250, 0, 400.42, 400.42, 4449.15,
    29, 0.75, 42612.5, '2026-03-02', '2026-03-31', '''8504010000010043', 'DBS BANK LTD',
    'DBSS0IN0504', 'INF/NEFT/IN42606153776752/DBSS0IN0504/67261280 /DISBURSE                      /RAJIVKUMAR', 'DISBURSED', 'REPEAT', 'DEEPAK KUMAR', NULL,
    'PLOT NO 6 B FOURTH FLOOR GALI NO 1 ATUL PROPERTIES MOHAN GARDEN DWARKA MORE NEAR TASTE OF SOUTH RESTAURANT 110059  110059', 'PAISABAZAAR MARKETING AND CONSULTING PRIVATE LIMITED PLOT NO 7 A SHADDIPUR X ROAD NEAR SCB BANK NEW DELHI 110045  110045', 111, '91-120', 'March, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    4615, 'Telangana', 'Hyderabad', 'LOA00002435', 'AJTPP6305R', 'ACGLLLOT00000002672', 'ANIL  POLA', 9912299001, 'ANILHARITHASA@GMAIL.COM',
    50000, 42500, 6356, 1144, 7500, 1144.07, 0, 0, 6355.93,
    29, 0.75, 60875, '2026-03-02', '2026-03-31', '''0312172396', 'Kotak Mahindra Bank',
    'KKBK0007463', 'INF/NEFT/IN42606154211274/KKBK0007463/67310702 /DISBURSE                      /ANILPOLA', 'DISBURSED', 'REPEAT', 'KISHAN KUMAR', NULL,
    'FNO 203 JAYA ENCLAVE, SHYMLALBUILDING ,BASTHI DAVAKHANA,BEGUMPET,,HYDERABAD ,TELENGANA,500016 HYDERABAD TELANGANA, 500016 JAYA ENCLAVE, SHYMLALBUILDING 500016', 'GAC GLOBAL IT SERVICES PRIVATE LIMITED 4TH FLOOR, DSL ABACUS IT PARK, SURVEY COLONY, INDUSTRIAL DEVELOPMENT AREA, UPPAL, HYDERABAD, TELANGANA 500039 SURVEY COLONY, INDUSTRIAL DEVELOPMENT AREA 500039', 111, '91-120', 'March, 2026', 'PART-PAYMENT'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    4616, 'Telangana', 'Hyderabad', 'LOA00003052', 'BTKPJ3720J', 'ACGLLLOT00000002628', 'JAGADEESHWARAN  PC', 7092289871, 'JAGDISH1651995@GMAIL.COM',
    13000, 11050, 1653, 297, 1950, 297.46, 0, 0, 1652.54,
    28, 0.75, 15730, '2026-03-02', '2026-03-30', '''6683081581', 'INDIAN BANK',
    'IDIB000S262', 'INF/NEFT/IN42606153776756/IDIB000S262/67261280 /DISBURSE                      /JAGADEESHWA', 'DISBURSED', 'REPEAT', 'POOJA', NULL,
    'PLOT NO.282/2, NEW HAFEEZPET, SUBHASH CHANDRA BOSE NAGAR, HYDERABAD 500048', 'L&T CONSTRUCTION BUILDING NO 8, K RAHEJA CORPORATION MINDSPACE,HITEC CITY, HYDERABAD 500081', 112, '91-120', 'March, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    4675, 'Karnataka', 'Bangalore', 'ADV00001809', 'ACHPY9451G', 'ACGLLLOT00000002671', 'PRIYANKA  YENDAMURI', 9886732581, 'PRIYANKAYENDAMURI06@GMAIL.COM',
    45000, 38250, 5720, 1030, 6750, 1029.66, 0, 0, 5720.34,
    29, 0.75, 54787.5, '2026-03-02', '2026-03-31', '''100701521804', 'ICICI BANK LIMITED',
    'ICIC0001007', 'INF/INFT/043534921981/67288613     /PRIYANKAYENDAMURI   /DISBURSE', 'DISBURSED', 'REPEAT', 'PRIYA GUPTA', NULL,
    'C305, MANTRI ALPYNE APARTMENTS DR VISHNUVARDHAN ROAD SUBRAMANYAPURA BANGALORE KARNATAKA 560061 VISHNUVARDHAN ROAD SUBRAMANYAPURA BANGALORE KARNATAKA 560061 560061', 'ORCHARD HEALTHCARE PRIVATE LIMITED FLOOR 2, SV TOWERS, 80 FEET RD, NEAR INDIAN OIL, 6TH BLOCK, KORAMANGALA, BENGALURU, KARNATAKA 560095 NEAR INDIAN OIL, 6TH BLOCK, , BENGALURU, KARNATAKA 560095 560095', 111, '91-120', 'March, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    4688, 'Karnataka', 'Bangalore', 'LOA00002852', 'ACPPU8341P', 'ACGLLLOT00000002692', 'UMADEVI  M', 8971282998, 'UMAAIT12@GMAIL.COM',
    50000, 42500, 6356, 1144, 7500, 1144.07, 0, 0, 6355.93,
    29, 0.75, 60875, '2026-03-02', '2026-03-31', '''057301511183', 'ICICI BANK LIMITED',
    'ICIC0000573', 'INF/INFT/043539325061/67310702     /UMADEVIM/DISBURSE', 'DISBURSED', 'REPEAT', 'PRIYA GUPTA', 'KISHAN KUMAR',
    '202, ALPS NORTHBROOK,  16A CROSS, NEELADRI NAGAR, ELECTRONIC CITY PHASE 1, BANGALORE- 560100 202, ALPS NORTHBROOK,  16A CROSS, NEELADRI NAGAR, ELECTRONIC CITY PHASE 1, BANGALORE- 560100  560100', 'IBM IND LTD IBM INDIA LTD, C BLOCK, EMBASSY GOLF LINKS ROAD, EMBASSY GOLF LINKS BUSINESS PARK, DOMLUR, BENGALURU, KARNATAKA 560071 LANMARK - EGL IBM INDIA LTD, C BLOCK, EMBASSY GOLF LINKS ROAD, EMBASSY GOLF LINKS BUSINESS PARK, DOMLUR, BENGALURU, KARNATAKA 560071 LANMARK - EGL  530073', 111, '91-120', 'March, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    4691, 'Telangana', 'Hyderabad', 'LOA00002428', 'CAFPB6613P', 'ACGLLLOT00000002685', 'BANDARU SATYA GOWTHAM RISHI', 8639701110, 'RISHI.BANDARUR@GMAIL.COM',
    17000, 14450, 2161, 389, 2550, 388.98, 0, 0, 2161.02,
    29, 0.75, 20697.5, '2026-03-02', '2026-03-31', '''754801503424', 'ICICI BANK LTD',
    'ICIC0007548', 'INF/INFT/043539316671/67310702     /BANDARUSATYAGOWTHAMR/DISBURSE', 'DISBURSED', 'REPEAT', 'GARISHMA', NULL,
    'H NO 39-69/4/A SANJAY GANDHI NAGAR JAGATHGIRI GUTTA KUKATPALLY  500036', 'FINTRAC GLOBAL SERVICES PRIVATE LIMITED BLOCK C, RMZ FUTURA, PLOT# 14 & 15, PHASE 2, HITECH CITY,  500081', 111, '91-120', 'March, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    4706, 'West Bengal', 'Kolkata', 'LOA00003138', 'AFYPJ1966R', 'ACGLLLOT00000002706', 'RAHUL  JHA', 9331006483, 'RAHUL8321@REDIFFMAIL.COM',
    30000, 25500, 3814, 686, 4500, 686.44, 0, 0, 3813.56,
    35, 0.75, 37875, '2026-03-02', '2026-04-06', '''58950100005250', 'BANK OF BARODA',
    'BARB0RAMBAZ', 'INF/NEFT/IN42606154455120/BARB0RAMBAZ/67329692 /DISBURSE                      /RAHULJHA', 'DISBURSED', 'REPEAT', 'KISHAN KUMAR', NULL,
    'OZONE COMPLEX,FLAT 9C,BLOCK 5, KOLKATA -700103 OZONE COMPLEX,FLAT 9C,BLOCK 5, KOLKATA -700103  700107', 'UBIQUE  SYSTEM PVT LLP UBIQUE HOUSE, 768 PURBANCHAL MAIN ROAD,HALTU,KOLKATA-700078 UBIQUE HOUSE, 768 PURBANCHAL MAIN ROAD,HALTU,KOLKATA-700078  700078', 105, '91-120', 'March, 2026', 'PART-PAYMENT'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    4721, 'Telangana', 'Hyderabad', 'LOA00003044', 'ESCPK6020A', 'ACGLLLOT00000002700', 'ETTUKURI VINEET KUMAR', 8179366217, '788VINEETKUMAR@GMAIL.COM',
    30000, 25500, 3814, 686, 4500, 686.44, 0, 0, 3813.56,
    29, 0.75, 36525, '2026-03-02', '2026-03-31', '''8179366217', 'KOTAK MAHINDRA BANK',
    'KKBK0007502', 'INF/NEFT/IN42606154454979/KKBK0007502/67329692 /DISBURSE                      /ETTUKURIVIN', 'DISBURSED', 'REPEAT', 'PRIYA GUPTA', NULL,
    'SSK PLATINUM BLOCK A FLAT NO 104, SAI KRISHNAJA HILLS, ACHUPALLY,RANGAREDDY,HYDERABAD,TELENGANA,500090 SURYA GLOBAL SCHOOL,B 500090', 'QENTELLI SOLUTIONS PVT LTD SALARPURIA KNOWLEDGE CITY, OCTAVE, 4TH FLR UNIT 2B, PHASE IV SERILINGAMPALLY MANDAL, RAI DURG, HYDERABAD, TELANGANA- 500081  500081', 111, '91-120', 'March, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    4752, 'Tamil Nadu', 'Chennai', 'LOA00003076', 'BJFPP5055H', 'ACGLLLOT00000002730', 'PREMALATHA  RAJU', 9940613230, 'LATHARAJU1708@GMAIL.COM',
    35000, 29750, 4449, 801, 5250, 800.85, 0, 0, 4449.15,
    28, 0.75, 42350, '2026-03-03', '2026-03-31', '''50100168499622', 'HDFC BANK',
    'HDFC0001225', 'INF/NEFT/IN42606255029734/HDFC0001225/67367590 /DISBURSE                      /PREMALATHAR', 'DISBURSED', 'REPEAT', 'POOJA', NULL,
    '26/12 DOOR NO 3 ASHOK VASUDA RAM COLONY WEST MAMBALAM CHENNAI 600033 26/12 DOOR NO 3 ASHOK VASUDA RAM COLONY WEST MAMBALAM CHENNAI 600033  600033', 'ZOHO CORPORATION  ESTANCIA ZOHO CORPORATION  ESTANCIA IT PARK VALLANCHERY VILLAGE , THAILAVARAM , GUDUVANCHERY 603202 GUDUVANCHERY 603202  604202', 111, '91-120', 'March, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    4796, 'Andhra Pradesh', 'Visakhapatnam', 'ADV00000795', 'DOXPK3410L', 'ACGLLLOT00000002744', 'KAKI MANI KUMAR', 8977709810, 'MANIKUMARYADAV7@GMAIL.COM',
    30000, 25500, 3814, 686, 4500, 686.44, 0, 0, 3813.56,
    26, 0.75, 35850, '2026-03-05', '2026-03-31', '''20255182229', 'STATE BANK OF INDIA',
    'SBIN0003060', 'INF/NEFT/IN42606456342688/SBIN0003060/67476053 /DISBURSE                      /KAKIMANIKUM', 'DISBURSED', 'REPEAT', 'DEEPAK KUMAR', NULL,
    '50-65-25-1, KANAKAMMA VARI STREET, SEETHAMMAPETA, VSP -530016 530016', 'TATA CONSULTANCY SERVICES R95Q+F2X, STARTUP VILLAGE, PEDDA RUSHIKONDA, RUSHIKONDA, MADHURAVADA, ANDHRA PRADESH 530045  530045', 111, '91-120', 'March, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    4799, 'Tamil Nadu', 'Coimbatore', 'LOA00002932', 'BNYPB4492F', 'ACGLLLOT00000002756', 'BHARATIRAJA  NILANDURAI', 8973270930, 'BHARATIRAJA1990@GMAIL.COM',
    30000, 25500, 3814, 686, 4500, 686.44, 0, 0, 3813.56,
    28, 0.75, 36300, '2026-03-05', '2026-04-02', '''115601503221', 'ICICI BANK LIMITED',
    'ICIC0001156', 'INF/INFT/043576921471/67476053     /BHARATIRAJANILANDURA/DISBURSE', 'DISBURSED', 'REPEAT', 'KISHAN KUMAR', NULL,
    '11/1,COIMBATORE, TAMIL NADU 641113, INDIA,SIRANANDHAPURAM, SARAVANAMPATTI, SAKTHI NAGAR, SARAVANAMPATTI,,COIMBATORE,TAMIL NADU,641049 SAKTHI NAGAR, 641049', 'HOLISTIC MD LLP KCT TECH PARK, GROUND FLOOR, FORGE BUILDING, THUDIYALUR ROAD, SARAVANAMPATTI, COIMBATORE - 641049 THUDIYALUR ROAD 641049', 109, '91-120', 'March, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    4753, 'Maharashtra', 'Mumbai', 'LOA00002565', 'ALFPR4464H', 'ACGLLLOT00000002766', 'ANANDKRISHNAN  RANGARAJAN', 9819104228, 'R.ANAND.KRISHNAN@GMAIL.COM',
    38000, 32300, 4831, 869, 5700, 869.49, 0, 0, 4830.51,
    25, 0.75, 45125, '2026-03-06', '2026-03-31', '''1314503263', 'KOTAK MAHINDRA BANK',
    'KKBK0001501', 'INF/NEFT/IN42606557072334/KKBK0001501/67532174 /DISBURSE                      /ANANDKRISHN', 'DISBURSED', 'REPEAT', 'POOJA', NULL,
    '301 SAI DHAM CHS B WING SOC433329_SAI DHAM CHSL MULUND WEST ASHA NAGAR P K ROAD 400080 MUMBAI MUMBAI (SUBURBAN) MAHARASHTRA INDIA MAHARASHTRA  400080', 'KOTAK MAHINDRA BANK LTD NEPTUNE ELEMENTS WAGLE ESTATE THANE 400601 MAHARASHTRA MAHARASHTRA 400601', 111, '91-120', 'March, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    4835, 'Telangana', 'Rangareddy', 'ADV00000464', 'BNGPR3228B', 'ACGLLLOT00000002783', 'AJAY KUMAR REDDY  BOJJIREDDY', 9966323607, 'AJAY.BOJJI@GMAIL.COM',
    30000, 25500, 3814, 686, 4500, 686.44, 0, 0, 3813.56,
    31, 0.75, 36975, '2026-03-06', '2026-04-06', '''19971050004739', 'HDFC BANK',
    'HDFC0000126', 'INF/NEFT/IN42606557532719/HDFC0000126/67572479 /DISBURSE                      /AJAYKUMARRE', 'DISBURSED', 'REPEAT', 'KISHAN KUMAR', NULL,
    'H NO 6-134/5/1/1 VENKATESWARA NAGAR NAGARAM MEDCHAL DISTRICT HYDERABAD 500083  500083', 'ENTERDOT TECH SOLUTIONS 14,2ND FLOOR CHANDRA PLAZA , ABOVE ANDHRA BANK NETAJI NAGAR X ROADS ,SAINIKPURI ,SECUNDRABAD -500062  500062', 105, '91-120', 'March, 2026', 'PART-PAYMENT'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    4865, 'West Bengal', '24 Parganas', 'LOA00002038', 'AKNPC2546C', 'ACGLLLOT00000002790', 'KAUSHIK  CHOWDHURY', 9836014140, 'KAUSHIKCHOWDHURY846@GMAIL.COM',
    15000, 12750, 1907, 343, 2250, 343.22, 0, 0, 1906.78,
    31, 0.75, 18487.5, '2026-03-07', '2026-04-07', '''40728390744', 'STATE BANK OF INDIA',
    'SBIN0018118', 'INF/NEFT/IN42606658534094/SBIN0018118/67636081 /DISBURSE                      /KAUSHIKCHOW', 'DISBURSED', 'REPEAT', 'POOJA', NULL,
    '262, MAYA COMPLEX B/1D HEMANTA BOSE SARANI UDAYRAJPUR MADHYAMGRAM  700129', 'CAR CARE MARUTI AUTHORISED SERVICE STATION B.T. ROAD, SODEPUR, P.O. SUKCHAR,  700115', 104, '91-120', 'March, 2026', 'PART-PAYMENT'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    4867, 'West Bengal', '24 Parganas', 'LOA00002972', 'AJKPB6694C', 'ACGLLLOT00000002799', 'NILABJA  BASU', 9831674176, 'NILABJA21@GMAIL.COM',
    25000, 21250, 3178, 572, 3750, 572.03, 0, 0, 3177.97,
    27, 0.75, 30062.5, '2026-03-07', '2026-04-03', '''8187593156', 'INDIAN BANK',
    'IDIB000K759', 'INF/NEFT/IN42606658534226/IDIB000K759/67636081 /DISBURSE                      /NILABJABASU', 'DISBURSED', 'REPEAT', 'GARISHMA', NULL,
    '6,USHARALOY APPARTMENT,37,2ND FLOOR, NORTHERN PARK  BRAMBHAPUR MAJUMDER PUKUR KOLKATA WEST BENGAL- 700070  700070', 'GENIUS HRTECH LIMITED SYNTHESIS BUSINESS PARK CBD BLOCK ACTION AREA II NEWTOWN KOLKATA 700157 SYNTHESIS BUSINESS PARK CBD BLOCK ACTION AREA II NEWTOWN KOLKATA 700157  700141', 108, '91-120', 'March, 2026', 'PART-PAYMENT'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    4977, 'Karnataka', 'Bangalore', 'LOA00003139', 'AIEPA9183E', 'ACGLLLOT00000002818', 'ANNADANAIAH', 9986016956, 'ANNADANAIAH493@GMAIL.COM',
    60000, 54000, 5085, 915, 6000, 915.25, 0, 0, 5084.75,
    27, 1, 76200, '2026-03-17', '2026-04-13', '''1011252500046601', 'KARNATAKA BANK LTD',
    'KARB0001011', 'INF/NEFT/IN42607656341784/KARB0001011/68200252 /DISBURSE                      /ANNADANAIAH', 'DISBURSED', 'REPEAT', 'GARISHMA', 'KISHAN KUMAR',
    '57. KUSHAL NILAYA. 2ND A MAIN 2 ST CROSS CHAWDESHWARI NAGAR KARNATAKA BANGLORE- 560058  560058', 'HERBALIFE ERBALIFE INTERNATIONA INDIA PVT LTD #PC COMPLEX. NO. 46/B-47,1ST MAIN ROAD, 3RD PHASE, JP NAGAR, BAGALORE-78 ERBALIFE INTERNATIONA INDIA PVT LTD #PC COMPLEX. NO. 46/B-47,1ST MAIN ROAD, 3RD PHASE, JP NAGAR, BAGALORE-78  560078', 98, '91-120', 'March, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    4993, 'Karnataka', 'Bangalore', 'LOA00003098', 'BHHPC0588G', 'ACGLLLOT00000002819', 'CHANDRAKANTH S V', 9901753225, 'CHANDRAKANTH_SA@REDIFFMAIL.COM',
    35000, 29750, 4449, 801, 5250, 800.85, 0, 0, 4449.15,
    31, 0.75, 43137.5, '2026-03-17', '2026-04-17', '''292710100014019', 'UNION BANK OF INDIA',
    'UBIN0829277', 'INF/NEFT/IN42607656343988/UBIN0829277/68200252 /DISBURSE                      /CHANDRAKANT', 'DISBURSED', 'REPEAT', 'DEEPAK KUMAR', 'KISHAN KUMAR',
    '71/A, KODICHIKKANAHALLI, BANGALORE - 560076  560076', 'LETS SET DESTINATIONS SEENAPPA LAYOUT, KODICHIKKANAHALLI, BANGALORE - 560076  560076', 94, '91-120', 'March, 2026', 'PART-PAYMENT'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    5018, 'Gujarat', 'Ahmedabad', 'LOA00002779', 'BJSPT7528N', 'ACGLLLOT00000002825', 'MEET  THAKKAR', 9664750770, 'MEETPL3300@GMAIL.COM',
    30000, 25500, 3814, 686, 4500, 686.44, 0, 0, 3813.56,
    22, 0.75, 34950, '2026-03-18', '2026-04-09', '''20518025893', 'STATE BANK OF INDIA',
    'SBIN0061411', 'INF/NEFT/IN42607757371144/SBIN0061411/68299342 /                              /MEETTHAKKAR', 'DISBURSED', 'REPEAT', 'PAYAL NAINWAL', NULL,
    '8 C MADHAV APARTMENT PART 2 OPP KALUPUR BANK BOPAL AHMEDABAD GUJARAT 380058  380058', 'E- ASPIRE TECHNOLABS PVT. LTD GANESH GLORY 11 GODREJ CITY GARDEN ROAD, D-1107 TO 1111, JAGATPUR RD, GOTA, AHMEDABAD, GUJARAT 382470  382470', 102, '91-120', 'March, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    5118, 'Karnataka', 'Bangalore', 'LOA00003183', 'BPBPM6778J', 'ACGLLLOT00000002838', 'MOHAMMAD SHARIQUE MOBIN', 7411379388, 'SHARIQUEMOBIN06@GMAIL.COM',
    30000, 25500, 3814, 686, 4500, 686.44, 0, 0, 3813.56,
    33, 0.75, 37425, '2026-03-28', '2026-04-30', '''50100832088597', 'HDFC BANK',
    'HDFC0004367', 'INF/NEFT/IN42608752522844/HDFC0004367/68781062 /DISBURSE                      /MOHAMMADSHA', 'DISBURSED', 'NEW', 'DEEPAK KUMAR', 'KISHAN KUMAR',
    'HMR PURPLE ELITE, FLAT 201, 3RD FLOOR, HBR LAYOUT , HENNUR, BANGALORE 560043, KARNATAKA  560043', 'BRIGHT MONEY TECHNOLOGY PRIVATE LIMITED SITE NO. 19 & 20, INDIQUBE CELESTIA, 1ST FLOOR, KORAMANGALA 1A BLOCK, SBI COLONY KORMANGALA , 560034 , BANGALORE , KARNATAKA  560034', 81, '61-90', 'March, 2026', 'PART-PAYMENT'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    5155, 'Maharashtra', 'Thane', 'LOA00002870', 'AQPPK8562Q', 'ACGLLLOT00000002857', 'ARNAB  KOLEY', 9650979393, 'ARNABKOLEY50@GMAIL.COM',
    60000, 51000, 7627, 1373, 9000, 1372.88, 0, 0, 7627.12,
    33, 0.75, 74850, '2026-03-29', '2026-05-01', '''142198700000424', 'YES BANK LTD',
    'YESB0001421', 'INF/NEFT/IN42608853256161/YESB0001421/68828630 /DISBURSE                      /ARNABKOLEY', 'DISBURSED', 'REPEAT', 'RATNADEEP BIRADAR', 'KISHAN KUMAR',
    'B-1/702 RUTU ENCLAVE KAVESAR G.B.ROAD THANE 400604 B-1/702 RUTU ENCLAVE KAVESAR G.B.ROAD THANE 400604  400615', 'RELIANCE GENERAL INSURANCE COMPANY LIMITED 6TH FLOOR OBEROI COMMERZE 1 IBP GOREGAO EAST 400063 6TH FLOOR OBEROI COMMERZE 1 IBP GOREGAO EAST 400063  400063', 80, '61-90', 'March, 2026', 'PART-PAYMENT'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    5173, 'Maharashtra', 'Mumbai', 'LOA00002787', 'ALAPG1466D', 'ACGLLLOT00000002866', 'NITIN DATTARAM GOSAVI', 9820304206, 'NITIN.GOSAVI88@GMAIL.COM',
    27000, 22950, 3432, 618, 4050, 617.8, 0, 0, 3432.2,
    31, 0.75, 33277.5, '2026-03-30', '2026-04-30', '''50100502920139', 'HDFC BANK',
    'HDFC0001425', 'INF/NEFT/IN42608953720721/HDFC0001425/68844303 /DISBURSE                      /NITINDATTAR', 'DISBURSED', 'REPEAT', 'DEEPAK KUMAR', 'KISHAN KUMAR',
    '13-A/3, PREM SAMBANDH COLONY BHANDUP EAST,MUMBAI-400042 LANDMARK:- NEAR PANCHAGANGA PATHPEDHI 400042', 'JOHN COCKERILL GLOBAL BUSINESS SERVICES PVT LTD AURUM Q PARC, BUILDING Q2, 19TH FLOOR, THANE BELAPUR ROAD, GHANSOLI, NAVI MUMBAI -400710 LANDMARK - NEXT TO JIO WORLD 400710', 81, '61-90', 'March, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    5185, 'Maharashtra', 'Pune', 'LOA00003113', 'COPPK2323K', 'ACGLLLOT00000002874', 'ALAYKUMAR PRAFULCHANDRA KANKURA', 9607079877, 'ALAYKANKURA@GMAIL.COM',
    30000, 25500, 3814, 686, 4500, 686.44, 0, 0, 3813.56,
    31, 0.75, 36975, '2026-03-30', '2026-04-30', '''10231574172', 'IDFC FIRST BANK LTD',
    'IDFB0041374', 'INF/NEFT/IN42608953981610/IDFB0041374/68871316 /DISBURSE                      /ALAYKUMARPR', 'DISBURSED', 'REPEAT', 'RATNADEEP BIRADAR', 'KISHAN KUMAR',
    'SR NO 65/P 66/1/2B 66AVENUE FLAT NO E-602 PUNE 411027', 'COGNIZANT TECHNOLOGY SOLUTIONS INDIAN PRIVATE LTD COGNIZANT TECHNOLOGY SOLUTIONS, HINJEWADI PHASE 3 PUNE 411057', 81, '61-90', 'March, 2026', 'PART-PAYMENT'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    5203, 'Maharashtra', 'Thane', 'LOA00003099', 'ANWPB1099F', 'ACGLLLOT00000002891', 'POULAMI  BOSE', 9595364968, 'BOSE.POULAMI99@GMAIL.COM',
    20000, 17000, 2542, 458, 3000, 457.63, 0, 0, 2542.37,
    31, 0.75, 24650, '2026-03-30', '2026-04-30', '''794601500542', 'ICICI BANK LTD',
    'ICIC0007946', 'INF/INFT/043877605231/68899837     /POULAMIBOSE/DISBURSE', 'DISBURSED', 'REPEAT', 'PAYAL NAINWAL', 'KISHAN KUMAR',
    'FLAT 1502 TULIP 1 HAWARE ESTATE PURANIK CITY G BRD KASARVADAVALI OWALE THANE W OSCER HOSPITAL MUMBAI, MAHARASHTRA, 400615,  400615', 'ECLERX SERVICES LIMITED BUILDING 11, RAHEJA MINDSPACE, OPPOSITE AIROLI RAILWAY STATION, NAVI MUMBAI 400708 OPPOSITE AIROLI RAILWAY STATION, NAVI MUMBAI 400708  400708', 81, '61-90', 'March, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    5223, 'Maharashtra', 'Mumbai', 'LOA00002818', 'DHUPK1961E', 'ACGLLLOT00000002900', 'AKSHAY ASHOK KULKARNI', 9890864274, 'WARRIORKULKARNI@GMAIL.COM',
    40000, 34000, 5085, 915, 6000, 915.25, 0, 0, 5084.75,
    31, 0.75, 49300, '2026-03-30', '2026-04-30', '''106425697006', 'HSBC BANK',
    'HSBC0411002', 'INF/NEFT/IN42608954527746/HSBC0411002/68921749 /DISBURSE                      /AKSHAYASHOK', 'DISBURSED', 'REPEAT', 'GARISHMA', 'KISHAN KUMAR',
    'FLAT NO.- 505 NEMINATH NEMI BHAVAN, RAILWAY STATION, SOMANI GRAM, GOREGAON WEST, MUMBAI, MAHARASHTRA 400104 RAM MANDIR ROAD, 400104', 'INTELLECT DESIGN ARENA LIMITED 8TH 9TH &10TH FLOOR NESCO GOREGAON EAST MUMBAI  PIN 400063 SILVER METROPOLIS 400063', 81, '61-90', 'March, 2026', 'PART-PAYMENT'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    5234, 'Haryana', 'Faridabad', 'LOA00002313', 'BTKPS8750F', 'ACGLLLOT00000002919', 'SAMEER  SHARMA', 9899514970, 'SAMEER.SPECTRA@GMAIL.COM',
    70000, 59500, 8898, 1602, 10500, 1601.69, 0, 0, 8898.31,
    30, 0.85, 87850, '2026-03-31', '2026-04-30', '''002101625109', 'ICICI BANK LIMITED',
    'ICIC0000021', 'INF/INFT/043894441971/68972316     /SAMEERSHARMA/DISBURSE', 'DISBURSED', 'REPEAT', 'GARISHMA', 'KISHAN KUMAR',
    'B 305 MULBERRY COUNTRY SECTOR 70 FARIDABAD MUJERI 81 FARIDABAD HARYANA 121004  121004', 'CALIX (CALIX INDIA DEVELOPMENT CENTER) CALIX (CALIX INDIA DEVELOPMENT CENTER) UNIT 301, 3RD FLOOR, TOWER B, RMZ INFINITY, NO.3, OLD MADRAS ROAD, BANGALORE, KARNATAKA INDIA - 560016  560016', 81, '61-90', 'March, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    5241, 'Maharashtra', 'Mumbai', 'LOA00002928', 'ASGPJ0860P', 'ACGLLLOT00000002908', 'ALA SHOKET HOSSAIN JAMATI', 9819111212, 'ALA.JAMATI@GMAIL.COM',
    22000, 18700, 2797, 503, 3300, 503.39, 0, 0, 2796.61,
    30, 0.75, 26950, '2026-03-31', '2026-04-30', '''50100043105054', 'HDFC BANK',
    'HDFC0000047', 'INF/NEFT/IN42609054817181/HDFC0000047/68940687 /DISBURSE                      /ALASHOKETHO', 'DISBURSED', 'REPEAT', 'POOJA', 'KISHAN KUMAR',
    '525/20-B, JAMATI HOUSE, BORAN ROAD, BANDRA WEST, MUMBAI-400050 525/20-B, JAMATI HOUSE, BORAN ROAD, BANDRA WEST, MUMBAI-400050  400050', 'JP MORGAN SERVICES INDIA JP MORGAN TOWERS, 7TH FLOOR, NKP, NEAR MRINALTAI GORE FLYOVER, GOREGAON EAST, MUMBAI-400063 JP MORGAN TOWERS, 7TH FLOOR, NKP, NEAR MRINALTAI GORE FLYOVER, GOREGAON EAST, MUMBAI-400063  400063', 81, '61-90', 'March, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    5250, 'Telangana', 'Hyderabad', 'ADV00000416', 'BHXPG3041E', 'ACGLLLOT00000002913', 'AKILA  GUNTUPALLI', 9966133384, 'AKILA.SONY@GMAIL.COM',
    20000, 17000, 2542, 458, 3000, 457.63, 0, 0, 2542.37,
    30, 0.75, 24500, '2026-03-31', '2026-04-30', '''54059242215', 'STATE BANK OF INDIA',
    'SBIN0011081', 'INF/NEFT/IN42609055245717/SBIN0011081/68982730 /DISBURSE                      /AKILAGUNTUP', 'DISBURSED', 'REPEAT', 'HIMANI SINGH', 'KISHAN KUMAR',
    'FT NO 201 RD NO 8 A ASR HOMES SUDERSHAN NAGAR SERILINGAMPALLI 500019 ASR HOMES SUDERSHAN NAGAR 500018', 'SHRI SHAKTI SCHOOLS PVT LTD 3RD ONE OFFICE ADDRESS ONLY SUDHARSHAN NAGAR COLONY KA... 500019 AURBINDO 560019', 81, '61-90', 'March, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    5253, 'Karnataka', 'Bangalore', 'LOA00003105', 'AIEPA4428N', 'ACGLLLOT00000002916', 'SUHAIL  AHMED', 9884051558, 'SUHAILAHMED.CA@GMAIL.COM',
    35000, 29750, 4449, 801, 5250, 800.85, 0, 0, 4449.15,
    30, 0.75, 42875, '2026-03-31', '2026-04-30', '''924010045289398', 'AXIS BANK',
    'UTIB0004163', 'INF/NEFT/IN42609055391818/UTIB0004163/68994498 /DISBURSE                      /SUHAILAHMED', 'DISBURSED', 'REPEAT', 'GARISHMA', 'KISHAN KUMAR',
    'NO 186, 5TH CROSS STREET, SK GARDEN, BILWARDAHALLI, JIGANI HOBLI, BANGALORE 560083  560083', 'INFOSYS BPM LTD ELECTRONIC CITY, HOSUR MAIN ROAD BANGALORE 560100  560100', 81, '61-90', 'March, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    5265, 'Maharashtra', 'Pune', 'LOA00002506', 'AKFPN3572K', 'ACGLLLOT00000002926', 'SATYAJIT EKNATH NIKAM', 9028391919, 'SATYAJITNIKAM@HOTMAIL.COM',
    25000, 21250, 3178, 572, 3750, 572.03, 0, 0, 3177.97,
    30, 0.75, 30625, '2026-03-31', '2026-04-30', '''5266129702', 'AXIS BANK',
    'UTIB0005144', 'INF/NEFT/IN42609055245484/UTIB0005144/68982730 /DISBURSE                      /SATYAJITEKN', 'DISBURSED', 'REPEAT', 'PAYAL NAINWAL', 'KISHAN KUMAR',
    'HOUSE NO-201, SHRI VENKATESH LAKE VISTA, JAMBHULWADI ROAD, NEAR SHANINAGAR, AMBEGAON KHURD, PUNE CITY, PUNE, MAHARASHTRA - 411046 NEAR SHANINAGAR, 411046', 'CONCENTRIX TECHNOLOGIES (INDIA) PRIVATE LIMITED NO-169 , RMZ WESTEND, SURVEY 1, DP RD, HARMONY SOCIETY, WARD NO. 8, WIRELESS COLONY, AUNDH, PUNE, MAHARASHTRA 411007 OPPOSITE CITY INTERNATIONAL SCHOOL 411017', 81, '61-90', 'March, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    5290, 'Maharashtra', 'Thane', 'LOA00002292', 'AOPPS4694M', 'ACGLLLOT00000002950', 'JITESH DILIP SHARMA', 8828360070, 'SJITESH10051982@GMAIL.COM',
    16000, 13600, 2034, 366, 2400, 366.1, 0, 0, 2033.9,
    30, 0.75, 19600, '2026-03-31', '2026-04-30', '''074698700035882', 'Yes Bank Ltd',
    'YESB0000746', 'INF/NEFT/IN42609055594709/YESB0000746/69018557 /DISBURSE                      /JITESHDILIP', 'DISBURSED', 'REPEAT', 'DEEPAK KUMAR', 'KISHAN KUMAR',
    'FLAT NO 4 B15 TOPAZ CHSL GODREJ HILL NXT TO DMART KALYAN WEST  421302  421301', 'RELIANCE GENERAL INSURANCE COMPANY LIMITED 1 ST FLOOR CHINTAMANI AVANUE NXT TO VIRWANI IND ESTATE EASTERN EXP HIGHWAY GOREGOAN EAST MUMBAI 400063  400063', 81, '61-90', 'March, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    5292, 'Maharashtra', 'Thane', 'LOA00003065', 'BUKPS8081E', 'ACGLLLOT00000002952', 'MAGDUM AKTHAR SAYYED', 9545609952, 'MAGAKTH2907@GMAIL.COM',
    25000, 21250, 3178, 572, 3750, 572.03, 0, 0, 3177.97,
    30, 0.75, 30625, '2026-03-31', '2026-04-30', '''10234282597', 'IDFC BANK LTD',
    'IDFB0043391', 'INF/NEFT/IN42609055549924/IDFB0043391/69015249 /DISBURSE                      /MAGDUMAKTHA', 'DISBURSED', 'REPEAT', 'GARISHMA', 'KISHAN KUMAR',
    'E-701 KALPANA GARDENS, VRINDAVAN GARDEN, YASHWANT VIVA TOWNSHIP, VASAI PALGHAR MAHARASHTRA- 401209  401209', 'TATA CONSULTANCY SERVICES OLYMPUS A, ST. REGENT STREET, HIRANDANI ESTATE THANE WEST 400607 OLYMPUS A, ST. REGENT STREET, HIRANDANI ESTATE THANE WEST 400607  400607', 81, '61-90', 'March, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    5294, 'Karnataka', 'Bangalore', 'LOA00002764', 'BEEPR8274N', 'ACGLLLOT00000002960', 'RAGHAVENDRA  N', 9611610657, 'RAGHAVNL156@GMAIL.COM',
    20000, 17000, 2542, 458, 3000, 457.63, 0, 0, 2542.37,
    30, 0.75, 24500, '2026-03-31', '2026-04-30', '''27091930001216', 'HDFC BANK',
    'HDFC0002709', 'INF/NEFT/IN42609055549934/HDFC0002709/69015249 /DISBURSE                      /RAGHAVENDRA', 'DISBURSED', 'REPEAT', 'PAYAL NAINWAL', 'KISHAN KUMAR',
    '#91, 2ND CROSS 3RD BLK, NARAYANANAGAR, DODDAKASHALANDRA 560062', 'JMJ PHARMA 4044 VENKATADRI 12TH CROSS 2ND MAIN ROAD GIRINAGAR 4TH PHASE MANJUNATHA TEMPLE STREET 560050', 81, '61-90', 'March, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    5295, 'Karnataka', 'Bangalore', 'LOA00002829', 'BDWPS4584F', 'ACGLLLOT00000002961', 'RAJESH  S', 9769611559, 'RAJESH.SETHURAMAN@GMAIL.COM',
    50000, 42500, 6356, 1144, 7500, 1144.07, 0, 0, 6355.93,
    32, 0.75, 62000, '2026-03-31', '2026-05-02', '''03681140043707', 'HDFC BANK',
    'HDFC0000368', 'INF/NEFT/IN42609055549947/HDFC0000368/69015249 /DISBURSE                      /RAJESHS', 'DISBURSED', 'REPEAT', 'POOJA', 'KISHAN KUMAR',
    '106, SRI MURARI GRAND, AISHWARYA CRYSTAL LAYOUT, BASAPURA MAIN ROAD, BANGALORE 560068  560068', 'INTERTRUSTVITEOS CORPORATE AND FUND SERVICES PRIVATE LIMITED PRESTIGE BLUESHIP SOFTWARE PARK, ADUGODI, DAIRY CIRCLE, BANGALORE 560029. OPP TO CHRIST UNIVERSITY  560029', 79, '61-90', 'March, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    5299, 'Telangana', 'Hyderabad', 'LOA00003121', 'ATOPP3382P', 'ACGLLLOT00000002956', 'PILLARISETTY RAGHAVENDRA PHANI KIRAN', 8374859410, 'PHANIKIRAN88@GMAIL.COM',
    30000, 25500, 3814, 686, 4500, 686.44, 0, 0, 3813.56,
    30, 0.75, 36750, '2026-03-31', '2026-04-30', '''083132175006', 'HSBC BANK',
    'HSBC0500002', 'INF/NEFT/IN42609055549852/HSBC0500002/69015249 /DISBURSE                      /PILLARISETT', 'DISBURSED', 'REPEAT', 'RATNADEEP BIRADAR', 'KISHAN KUMAR',
    'MR PILLARISHETTY RAGHAVENDRA PHANI KIRAN HNO 4-156 MARUTHI NAGAR , MALKAJGIRI KV RANGAREDDY NEAR LK HOSPITAL , HYDERABAD 500044', 'PRIMERA MEDICAL TECHNOLOGIES PRIVATE LIMITED PLOT NO 1,28&29,98/4/1 TO 13 2ND, 9TH&10TH FLOOR JAIN SADGURU IMAGES CAPITAL PARK, MADHAPUR HYDERABAD 500081', 81, '61-90', 'March, 2026', 'PART-PAYMENT'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    5302, 'Tamil Nadu', 'Chennai', 'LOA00002950', 'AKWPM9851B', 'ACGLLLOT00000002962', 'MARIRAJ  MARIAPPAN', 9940080430, 'MARIRAJ.MARIAPPAN@GMAIL.COM',
    53000, 45050, 6737, 1213, 7950, 1212.71, 0, 0, 6737.29,
    30, 0.75, 64925, '2026-03-31', '2026-04-30', '''5415166445', 'AXIS BANK',
    'UTIB0005145', 'INF/NEFT/IN42609055549937/UTIB0005145/69015249 /DISBURSE                      /MARIRAJMARI', 'DISBURSED', 'REPEAT', 'HIMANI SINGH', 'KISHAN KUMAR',
    'NO C-2-25-3RD FLOOR KENDRIYAVIHAR -2 PONNAMALLEE AVADI ROAD CHENNAI TAMIL NADU-600071 KENDRIYAVIHAR 600078', 'TATA CONSULTANCY SERVICES (TCS) DLF IT PARK, 9A MOUNT POONAMALLEE ROAD, MANAPAKKAM CHENNAI 600125 MOUNT POONAMALLEE ROAD 600125', 81, '61-90', 'March, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    5308, 'Haryana', 'Gurgaon', 'LOA00002661', 'ATIPK1627N', 'ACGLLLOT00000002968', 'NISHANT  KHATRI', 9821150690, 'IAMNKHATRI@GMAIL.COM',
    35000, 29750, 4449, 801, 5250, 800.85, 0, 0, 4449.15,
    30, 0.75, 42875, '2026-03-31', '2026-04-30', '''923010027217912', 'AXIS BANK',
    'UTIB0004908', 'INF/NEFT/IN42609055594679/UTIB0004908/69018557 /DISBURSE                      /NISHANTKHAT', 'DISBURSED', 'REPEAT', 'POOJA', 'KISHAN KUMAR',
    'E1101, SUNCITY AVENUE, SECTOR 102, GURGAON 122505 E1101, SUNCITY AVENUE, SECTOR 102, GURGAON 122505  122505', 'INTERGLOBE AVIATION LIMITED GLOBAL BUSINESS PAEK, SECTOR 26, GURGAON 122002 GLOBAL BUSINESS PAEK, SECTOR 26, GURGAON 122002  122002', 81, '61-90', 'March, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    5310, 'Telangana', 'Hyderabad', 'LOA00002964', 'CDDPG2432G', 'ACGLLLOT00000002965', 'GOPAVARAM VISHNUVARDHAN REDDY', 8179363970, 'GOPAVARAMVISHNUVARDHAN444@GMAIL.COM',
    44000, 37400, 5593, 1007, 6600, 1006.78, 0, 0, 5593.22,
    30, 0.75, 53900, '2026-03-31', '2026-04-30', '''1149235100', 'KOTAK MAHINDRA BANK',
    'KKBK0007511', 'INF/NEFT/IN42609055594678/KKBK0007511/69018557 /DISBURSE                      /GOPAVARAMVI', 'DISBURSED', 'REPEAT', 'DEEPAK KUMAR', 'KISHAN KUMAR',
    '13-9-165, P R NAGAR,ERRAGADDA, HYDERABAD, TELANGANA-500018 NEAR POCHAMMA TEMPLE 500018', 'ACCENTURE SOLUTIONS PVT LTD ACCENTURE, HDC4A,SERILINGAMPALLY MANDAL, M/S. MANTRI DEVELOPERS PVT. LTD., IT/ITES SEZ, NEAR WIPRO CIRCLE,FINANCIAL DISTRICT, NANAKRAMGUDA, TELANGANA 500008  500008', 81, '61-90', 'March, 2026', 'PART-PAYMENT'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    5328, 'West Bengal', 'Kolkata', 'LOA00003174', 'BKIPB8803P', 'ACGLLLOT00000002975', 'ARPAN  BANERJEE', 9938049696, 'KRISHNA936DGP@GMAIL.COM',
    30000, 25500, 3814, 686, 4500, 686.44, 0, 0, 3813.56,
    29, 0.75, 36525, '2026-04-01', '2026-04-30', '''50100551101459', 'HDFC BANK',
    'HDFC0001474', 'INF/NEFT/IN42609155836705/HDFC0001474/69045251 /DISBURSE                      /ARPANBANERJ', 'DISBURSED', 'REPEAT', 'HIMANI SINGH', 'KISHAN KUMAR',
    'PURTI VEDA, TOWER-RIG, FLAT NO. 10A, NEW,ACTION AREA I, NEWTOWN, DHAPA MAN PUR P, WEST BENGAL, INDIA,PURTI VEDA, TOWER-RIG, FLAT NO. 10A, NEWTOWN, AC TION AREA 1,PURTI VEDA, 700108', 'PHONEPE LENDING SERVICES PRIVATE LIMITED OFFICE -2 , FLOOR 4,5,6,7 WING A BLOCK A SALARPURIA SOFTZONE SERIVICE ROAD GREEN GLEN LAYOUT BELLANDUR 560103', 81, '61-90', 'April, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    5344, 'Uttar Pradesh', 'Ghaziabad', 'LOA00001906', 'BBUPM2364P', 'ACGLLLOT00000002989', 'DIXIT  MAHENDRU', 8527008898, 'MOHENDRU.DIXIT@GMAIL.COM',
    23000, 19550, 2924, 526, 3450, 526.27, 0, 0, 2923.73,
    30, 0.85, 28865, '2026-04-01', '2026-05-01', '''158527008898', 'INDUSIND BANK',
    'INDB0000383', 'INF/NEFT/IN42609155957788/INDB0000383/69063931 /DISBURSE                      /DIXITMAHEND', 'DISBURSED', 'REPEAT', 'GARISHMA', 'KISHAN KUMAR',
    'B-504, AHINSAKHAND 2 JAIPURIA SUNRIS INDIRAPURAM AHINSAKHAND WEST GHAZIABAD 201014  201014', 'GROUPM MEDIA INDIA PRIVATE LIMITED 8TH FLOOR,TOWER B, DLF CYBER PARK, SHANKAR CHOWK GURGAON, 122008  122008', 80, '61-90', 'April, 2026', 'PART-PAYMENT'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    5351, 'Telangana', 'Rangareddy', 'LOA00002634', 'BLEPM2301Q', 'ACGLLLOT00000002994', 'TINU  MANILAL', 9618198922, 'URFRIENDTINU555@GMAIL.COM',
    38000, 32300, 4831, 869, 5700, 869.49, 0, 0, 4830.51,
    29, 0.75, 46265, '2026-04-02', '2026-05-01', '''06841610004805', 'HDFC BANK',
    'HDFC0001625', 'INF/NEFT/IN42609256275737/HDFC0001625/69084768 /DISBURSE                      /TINUMANILAL', 'DISBURSED', 'REPEAT', 'RATNADEEP BIRADAR', 'KISHAN KUMAR',
    'H.NO.5-6-66/3, HYDERABAD-500072, FLAT NO.G3, NEAR RAO''S HIGH SCHOOL, SANGEOT NAGAR, KUKATPALLY. FLAT NO.G3, NEAR RAO''S HIGH SCHOOL, SANGEOT NAGAR, KUKATPALLY. HYDERABAD, FLA 500072', 'COGNIZANT TECHNOLOGY SOLUTIONS INDIA PRIVATE LTD GAR TOWER, SHANTHINAGAR RD, KOKAPET, HYDERABAD TELANGANA 500074', 80, '61-90', 'April, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    5359, 'Telangana', 'Hyderabad', 'LOA00002755', 'AOOPB3580N', 'ACGLLLOT00000002998', 'DEV  BAHADUR', 8500243872, 'DEV.BAHADUR087@GMAIL.COM',
    21000, 17850, 2669, 481, 3150, 480.51, 0, 0, 2669.49,
    34, 0.75, 26355, '2026-04-02', '2026-05-06', '''50100833181084', 'HDFC BANK LTD',
    'HDFC0009351', 'INF/NEFT/IN42609256395361/HDFC0009351/69097709 /DISBURSE                      /DEVBAHADUR', 'DISBURSED', 'REPEAT', 'GARISHMA', 'KISHAN KUMAR',
    'PLOT 148 KK NAGAR PHASE 2 SRI VIGNESHWAR ROAD BANDLAGUDA JAGIR, HYDEABAD 500091', 'ADVAIT TECHSERVE INDIA PRIVATE LIMITED BRAMHCOPR 20TH FLOOR ADVAIT TECHSERVE INDIA VITRALVADI WADGAON 411058', 75, '61-90', 'April, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    5360, 'Karnataka', 'Bangalore', 'LOA00003186', 'ANOPB3188P', 'ACGLLLOT00000003002', 'B L KRISHNA', 8073233393, 'KBUDIGIRI@GMAIL.COM',
    20000, 17000, 2542, 458, 3000, 457.63, 0, 0, 2542.37,
    28, 0.75, 24200, '2026-04-02', '2026-04-30', '''015201552465', 'ICICI BANK LIMITED',
    'ICIC0000152', 'INF/INFT/043919788941/69097709     /BLKRISHNA/DISBURSE', 'DISBURSED', 'NEW', 'DEEPAK KUMAR', 'KISHAN KUMAR',
    '1542, 6TH CROSS, CORPORATION COLONY, GOVINDRAJNAGAR, BANGALORE 560079 LM: NEAR SRI SHANIMAHATMA SWAMY TEMPLE 560079', 'CONVERGEONE (C1) INDIA PRIVATE LIMITED SATTVA KNOWLEDGE PARK RAIDURG HYDERABAD 500081 LM: OPP MY HOME BHOOJA 500081', 81, '61-90', 'April, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    5378, 'Karnataka', 'Bangalore', 'LOA00002734', 'CAHPM8839A', 'ACGLLLOT00000003012', 'MAHANTHA  M', 9739111243, 'DRMAHANTHAPPU@GMAIL.COM',
    50000, 42500, 6356, 1144, 7500, 1144.07, 0, 0, 6355.93,
    32, 0.75, 62000, '2026-04-02', '2026-05-04', '''32710110037515', 'UCO BANK',
    'UCBA0003271', 'INF/NEFT/IN42609256778191/UCBA0003271/69133685 /DISBURSE                      /MAHANTHAM', 'DISBURSED', 'REPEAT', 'POOJA', 'KISHAN KUMAR',
    'NO 53 NANDARAMAIAHNAPALYA , , TEACHERS COLONY , ARISHINAKUNTE NELAMANGALA , BANGALORE 562123', 'SRI SIDDHARTHA INSTITUTE OF MEDICAL SCIENCES AND RESEARCH CENTRE T BEGUR NELAMANGALA BENGALURU 562123 562123', 77, '61-90', 'April, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    5381, 'Telangana', 'Hyderabad', 'LOA00002523', 'AICPV5263C', 'ACGLLLOT00000003013', 'S VIKRAM SINDHU', 8792613075, 'VIKRAMSINDHU1983@GMAIL.COM',
    15000, 12750, 1907, 343, 2250, 343.22, 0, 0, 1906.78,
    32, 0.75, 18600, '2026-04-02', '2026-05-04', '''50100633940195', 'HDFC BANK LTD',
    'HDFC0009817', 'INF/NEFT/IN42609256778023/HDFC0009817/69133685 /DISBURSE                      /SVIKRAMSIND', 'DISBURSED', 'REPEAT', 'GARISHMA', 'KISHAN KUMAR',
    '1-14/3/3 RTC COLONY THUMKUNTA SECUNDERABAD TELANGANA 500078 NULL , NULL HYDERABAD TELANGANA INDIA 500700 1-14/3/3 RTC COLONY THUMKUNTA SECUNDERABAD TELANGANA 500078 NULL , NULL HYDERABAD TELANGANA INDIA 500700  500101', 'GEETHANJALI COLLEGE OF ENGINEERING & TECHNOLOGY ( GEETHANJALI COLLEGE OF ENGINEERING AND TECHNOLOGY  CHERYAL KEESARA HYDERABAD TELANAGANA- 501301  501301', 77, '61-90', 'April, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    5385, 'Karnataka', 'Bangalore', 'LOA00002762', 'AETPA8001J', 'ACGLLLOT00000003014', 'KRISHNA MOHAN RAO APPARASU', 9980989873, 'KMRAO12@YAHOO.COM',
    31000, 26350, 3941, 709, 4650, 709.32, 0, 0, 3940.68,
    29, 0.75, 37742.5, '2026-04-03', '2026-05-02', '''110182077338', 'CANARA BANK',
    'CNRB0007328', 'INF/NEFT/IN42609356977442/CNRB0007328/69149062 /DISBURSE                      /KRISHNAMOHA', 'DISBURSED', 'REPEAT', 'GARISHMA', 'KISHAN KUMAR',
    '301/316, DSMAX SENORITA, MUDDINAPALYA, BANGALORE - 560091 301/316, DSMAX SENORITA, MUDDINAPALYA, BANGALORE - 560091 NEAR GOVT SCHOOL 560091', 'FUTURA SURGICARE PVT LTD FUTURA SURGICARE, 86, YESWANTHPUR INDUSTRIAL AREA SUBURB, BANGALORE -560022 FUTURA SURGICARE, 86, YESWANTHPUR INDUSTRIAL AREA SUBURB, BANGALORE -560022  560022', 79, '61-90', 'April, 2026', 'PART-PAYMENT'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    5397, 'Gujarat', 'Ahmedabad', 'ADV00000954', 'AMBPD9969N', 'ACGLLLOT00000003018', 'DESAI KEYUR HEMANTBHAI', 7016017440, 'KEYUR.DESAI25@GMAIL.COM',
    46000, 39100, 5847, 1053, 6900, 1052.54, 0, 0, 5847.46,
    29, 0.75, 56005, '2026-04-03', '2026-05-02', '''915010037600486', 'AXIS BANK',
    'UTIB0000058', 'INF/NEFT/IN42609357094465/UTIB0000058/69163050 /DISBURSE                      /DESAIKEYURH', 'DISBURSED', 'REPEAT', 'POOJA', 'KISHAN KUMAR',
    'B 50, ANUPAM NAGAR OLD PADRA ROAD BEHIND TUBE COMPANY VADODARA 390020 BEHIND TUBE COMPANY 380058', 'VADILAL INDUSTRIES LTD. 2ND FLOOR, SOUTH BLOCK, PUNISKA HOUSE, NEXT TO ONE42, OPPOSITE JAYANTILAL PARK BRTS STOP, AMBLI â€“ BOPAL  AHMEDABAD - 380058 OPPOSITE JAYANTILAL PARK BRTS STOP 380058', 79, '61-90', 'April, 2026', 'PART-PAYMENT'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    5407, 'Maharashtra', 'Mumbai', 'LOA00002202', 'ACBPY7407L', 'ACGLLLOT00000003022', 'BIJENDRA  YADAV', 8652321925, 'BIJENDRAYADAV0206@GMAIL.COM',
    26000, 22100, 3305, 595, 3900, 594.92, 0, 0, 3305.08,
    29, 0.75, 31655, '2026-04-03', '2026-05-02', '''6113104451', 'KOTAK MAHINDRA BANK LIMITED',
    'KKBK0000631', 'INF/NEFT/IN42609357151464/KKBK0000631/69169999 /DISBURSE                      /BIJENDRAYAD', 'DISBURSED', 'REPEAT', 'POOJA', 'KISHAN KUMAR',
    'ROOM NO 464 1/1 SHIVKRUPA HOUSING SOC ANAND GAD PARK SITE VIKHROLI NEAR SHANKAR MANDIR 400079', 'HITACHI PAYMENT SERVICES PRIVATE LIMITED 401 4TH FLOOR SILVER METROPOLIS JAI COACH COMPOUND OFF WESTERN EXPRESS HIGHWAY GOREGAON EAST  400063', 79, '61-90', 'April, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    5413, 'Karnataka', 'Bangalore', 'LOA00003124', 'AVKPR9096G', 'ACGLLLOT00000003025', 'RAJESH  V', 9738477505, 'RAJ.KLUSNER@GMAIL.COM',
    40000, 34000, 5085, 915, 6000, 915.25, 0, 0, 5084.75,
    29, 0.75, 48700, '2026-04-03', '2026-05-02', '''10177505507', 'IDFC FIRST BANK LTD',
    'IDFB0081187', 'INF/NEFT/IN42609357234404/IDFB0081187/69178823 /DISBURSE                      /RAJESHV', 'DISBURSED', 'REPEAT', 'GARISHMA', 'KISHAN KUMAR',
    '1ST FLOOR,98/2 HOSEKEREHALLI  DATTATREYA TEMPLE ROAD ABOVE SUKRUTHI  STORES 560085 BANGLORE KARNATAKA- 560085  560085', 'SHARAAN INFOSYSTEMS Sharaan Infosystems - 147 K, 12th Main Rd, 3rd Block, Koramangala 3 Block, Koramangala, Bengaluru, Karnataka 560034 SHARAAN INFOSYSTEMS - 147 K, 12TH MAIN RD, 3RD BLOCK, KORAMANGALA 3 BLOCK, KORAMANGALA, BENGALURU, KARNATAKA 560034  560034', 79, '61-90', 'April, 2026', 'PART-PAYMENT'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    5442, 'Maharashtra', 'Mumbai', 'LOA00002837', 'AQJPP7862J', 'ACGLLLOT00000003032', 'DEVYANI DILIP JADHAV', 9975617389, 'DEVYANIJ1986@GMAIL.COM',
    18000, 15300, 2288, 412, 2700, 411.86, 0, 0, 2288.14,
    27, 0.75, 21645, '2026-04-04', '2026-05-01', '''344209100000807', 'SARASWAT COOPERATIVE BANK LIMITED',
    'SRCB0000344', 'INF/NEFT/IN42609458134522/SRCB0000344/69244756 /DISBURSE                      /DEVYANIDILI', 'DISBURSED', 'REPEAT', 'GARISHMA', 'KISHAN KUMAR',
    'A 03 SAI BHARANI APARTMENT ALKAPURI ACHOLE ROAD R AJNAGAR NALLASOPARA EAST VASAI PALGHAR NEAR DUBE HOSPITAL THANE NALLASOPARA MAHARASHTRA- 401209  400055', 'PAYSQUARE HR SERVICES PRIVATE LIMITED 404, 4TH FLOOR, ADANI INSPIRE, BKC ROAD, BANDRA EAST, OPP ICICI BANK. 400055 404, 4TH FLOOR, ADANI INSPIRE, BKC ROAD, BANDRA EAST, OPP ICICI BANK. 400055  400055', 80, '61-90', 'April, 2026', 'PART-PAYMENT'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    5476, 'Maharashtra', 'Pune', 'ADV00001672', 'BDGPN4633Q', 'ACGLLLOT00000003038', 'GAURAV DEEPAK NARANG', 9158320960, 'GAURAV09.NARANG@GMAIL.COM',
    36000, 30600, 4576, 824, 5400, 823.73, 0, 0, 4576.27,
    40, 0.75, 46800, '2026-04-06', '2026-05-16', '''50100835813332', 'HDFC BANK LTD',
    'HDFC0008119', 'INF/NEFT/IN42609659062922/HDFC0008119/69295933 /                              /GAURAVDEEPA', 'DISBURSED', 'REPEAT', 'GARISHMA', 'KISHAN KUMAR',
    'SN-2425 PL.NO-52 SHIKSHAK NGR. GHORPADI SOPAN BAUG EMPRESS GARDEN VIEW SOCIETY HAVELI PUNE MAHARASHTRA 411001  411001', 'MAESTRO REALTEK PVT. LTD. OFFICE NO 417, 4TH FLOOR, NYATI EMPRESS, NEXT TO GIGA SPACE IT PARK, CLOVER PARK, VIMAN NAGAR, PUNE, MAHARASHTRA 411014  411014', 65, '61-90', 'April, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    5618, 'Karnataka', 'Bangalore', 'LOA00003133', 'CIGPS5631D', 'ACGLLLOT00000003047', 'HEMANT KUMAR SIDDEGOWDA', 9741020399, 'HEMANTKUMAR1912@GMAIL.COM',
    35000, 29750, 4449, 801, 5250, 800.85, 0, 0, 4449.15,
    23, 0.75, 41037.5, '2026-04-07', '2026-04-30', '''50100699250625', 'HDFC BANK LTD',
    'HDFC0006000', 'INF/NEFT/IN42609750579443/HDFC0006000/69391384 /DISBURSE                      /HEMANTKUMAR', 'DISBURSED', 'REPEAT', 'POOJA', 'KISHAN KUMAR',
    '#1370, 6TH BLOCK, 1ST CROSS, HMT LAYOUT, NELAGADARANHALLI BANGLORE, BENGLURU KARNATKA  560073', 'HDFC LIFE INSURANCE COMPANY LIMITED HDFC LIFE INSURANCE COMPANY LIMITED  NO 18, MICO LAYOUT, BTM LAYOUT 2ND STAGE. BANGALORE KARNATAKA  560076  560076', 81, '61-90', 'April, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    5707, 'Karnataka', 'Bangalore', 'LOA00003199', 'CNXPD7556A', 'ACGLLLOT00000003067', 'DILEEP  A', 7760858535, 'DILEEPREDDY042@GMAIL.COM',
    30000, 25500, 3814, 686, 4500, 686.44, 0, 0, 3813.56,
    22, 0.75, 34950, '2026-04-09', '2026-05-01', '''50100837277059', 'HDFC BANK',
    'HDFC0004052', 'INF/NEFT/IN426099527 02609/HDFC0004052/69 561951 /DISBURSE /D ILEEPA', 'DISBURSED', 'NEW', 'DEEPAK KUMAR', 'KISHAN KUMAR',
    '109, 1ST CROSS 3RD MAIN AMRUTHNAGAR C SECTOR NEAR AMRUTHNAGAR POLICE STATION  560092  560092', 'AVIN SYSTEMS PRIVATE LIMITED NO. 142, ENZYME TECH PARK, HOSUR RD, KORAMANGALA INDUSTRIAL LAYOUT, KORAMANGALA, BENGALURU, KARNATAKA 560095  560095', 80, '61-90', 'April, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    5714, 'Delhi', 'New Delhi', 'LOA00003202', 'DEEPM6349H', 'ACGLLLOT00000003070', 'JITENDER SINGH MAAN', 8383009800, 'JS9470555@GMAIL.COM',
    15000, 12750, 1907, 343, 2250, 0, 171.61, 171.61, 1906.78,
    21, 0.75, 17362.5, '2026-04-09', '2026-04-30', '''8383010000009447', 'DBS BANK LTD',
    'DBSS0IN0383', 'INF/NEFT/IN426099527 02609/HDFC0004052/69 561951 /DISBURSE /D ILEEPA', 'DISBURSED', 'NEW', 'GARISHMA', 'KISHAN KUMAR',
    '187 F/F NEW LAYALPUR COLONY KRISHNA NAGAR DELHI 110051 187 F/F NEW LAYALPUR COLONY KRISHNA NAGAR DELHI 110051  110051', 'AON CONSULTING PRIVATE LIMITED GREEN BOULEVARD SECTOR 62 NOIDA UTTAR PRADESH- 201301  201301', 81, '61-90', 'April, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    5832, 'Maharashtra', 'Mumbai', 'LOA00003041', 'EARPS1081J', 'ACGLLLOT00000003075', 'NAYAN RATANKUMAR SADHWANI', 9867267202, 'NAYAN1135@GMAIL.COM',
    20000, 17000, 2542, 458, 3000, 457.63, 0, 0, 2542.37,
    31, 0.75, 24650, '2026-04-10', '2026-05-11', '''021101543992', 'ICICI BANK LIMITED',
    'ICIC0000211', 'INF/INFT/044037680431/69624902     /NAYANRATANKUMARSADHW/DISBURSE', 'DISBURSED', 'REPEAT', 'POOJA', 'KISHAN KUMAR',
    '82 A 82 SANGEETA BUILDING A SOC260704 SANGITA CHS DR.BABASAHEB AMBEDKER  NAGER  ORTHAR BANDAR ROAD MUMBAI CITY MH 400005 82 A 82 SANGEETA BUILDING A SOC260704 SANGITA CHS DR.BABASAHEB AMBEDKER  NAGER  ORTHAR BANDAR ROAD MUMBAI CITY MH 400005  400005', 'RH EXPERIENCE LLP 502-B/WING, 5TH FLOOR RUSTOMJEE CENTRAL PARK, ANDHERI KURLA ROAD, CHAKALA, ANDHERI EAST -MUMBAI 400 093 502-B/WING, 5TH FLOOR RUSTOMJEE CENTRAL PARK, ANDHERI KURLA ROAD, CHAKALA, ANDHERI EAST -MUMBAI 400 093  400093', 70, '61-90', 'April, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    5885, 'Maharashtra', 'Pune', 'LOA00003213', 'AAMPW0032G', 'ACGLLLOT00000003086', 'RAHUL RAMESH WADODKAR', 9881721154, 'RWADODKAR@GMAIL.COM',
    25000, 21250, 3178, 572, 3750, 572.03, 0, 0, 3177.97,
    21, 0.75, 28937.5, '2026-04-11', '2026-05-02', '''922010043672417', 'AXIS BANK',
    'UTIB0002093', 'INF/NEFT/IN426101544 70082/UTIB0002093/69 683577 /DISBURSE /R AHULRAMESH', 'DISBURSED', 'NEW', 'PAYAL NAINWAL', 'NAVEEN',
    'APARTMENT/FLAT NO. 10 BUILT-UP :780 BUILDING NO.1''  PLOT NUMBER :82/A BANER ROAD, SAKAL NAGAR , PUNE 411007 411007', 'PRICEWATERHOUSECOOPERS PROFESSIONAL SERVICES LLP BUSINESS BAY, TOWER-A, WING-1, AIRPORT ROAD, YERWADA, PUNE 411006  411006', 79, '61-90', 'April, 2026', 'PART-PAYMENT'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    5944, 'Uttar Pradesh', 'Ghaziabad', 'LOA00003218', 'HMMPK3315P', 'ACGLLLOT00000003093', 'KALYAN  R', 8830000173, 'KALYANRAJAN777@GMAIL.COM',
    13000, 11050, 1653, 297, 1950, 297.46, 0, 0, 1652.54,
    16, 0.75, 14560, '2026-04-14', '2026-04-30', '''38587953453', 'STATE BANK OF INDIA',
    'SBIN0007090', 'INF/NEFT/IN426104566 09605/SBIN0007090/69 814305 /DISBURSE /K ALYANR', 'DISBURSED', 'NEW', 'HIMANI SINGH', 'NAVEEN',
    'P8-206 2ND FLOOR TOWER-P8  PRATEEK GRAND CITY  SIDDHARTH VIHAR 201009', 'INDIAN OIL A-26 IBM TOWER NOIDA SECTOR 62  201309', 81, '61-90', 'April, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    5979, 'Maharashtra', 'Mumbai', 'LOA00003221', 'AGJPT6475F', 'ACGLLLOT00000003100', 'VINEET RAMESH THAKKAR', 9967910207, 'VINEET.THAKKAR02@GMAIL.COM',
    25000, 21250, 3178, 572, 3750, 572.03, 0, 0, 3177.97,
    15, 0.75, 27812.5, '2026-04-15', '2026-04-30', '''4613472100', 'KOTAK MAHINDRA BANK',
    'KKBK0001410', 'INF/NEFT/IN42610557151315/KKBK0001410/69866728 /DISBURSE                      /VINEETRAMES', 'DISBURSED', 'NEW', 'DEEPAK KUMAR', 'KISHAN KUMAR',
    'C WING 502 AJOY CHS DAHANUKAR WADI KANDIVLI WEST MUMBAI - 400067  400067', 'FLEXABILITY HR SOLUTIONS PVT LTD B WING - 1602, PARINEE CRESCENZO, 1ST FLOOR, AVENUE 3, G BLOCK BKC, BANDRA KURLA COMPLEX, BANDRA EAST, MUMBAI, MAHARASHTRA 400051  400051', 81, '61-90', 'April, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    6014, 'Telangana', 'Hyderabad', 'LOA00003228', 'DLEPP7252R', 'ACGLLLOT00000003109', 'PONUGUPATI GOPI KRISHNA', 9390837006, 'GKPONUGUPATI@GMAIL.COM',
    15000, 12750, 1907, 343, 2250, 343.22, 0, 0, 1906.78,
    40, 0.75, 19500, '2026-04-15', '2026-05-25', '''920010038255845', 'AXIS BANK',
    'UTIB0002616', 'INF/NEFT/IN42610557287586/UTIB0002616/69878250 /DISBURSE                      /PONUGUPATIG', 'DISBURSED', 'NEW', 'GARISHMA', 'KISHAN KUMAR',
    'PLOT NO 95 ROAD NO 4, JAKKIDI COLONY, SRINIVASA NAGAR  SAHEBNAGAR NAGAR KALAN VANASTHALIPURAM TELANGANA 500070 PLOT NO 95 ROAD NO 4, JAKKIDI COLONY, SRINIVASA NAGAR  SAHEBNAGAR NAGAR KALAN VANASTHALIPURAM TELANGANA 500070  500070', 'SYNIVERSE TECHNOLOGIES SERVICES INDIA PRIVATE  LIMITED ILABS, OPP INORBITMALL, MADHAPUR, HYDERABAD, TG 500081 ILABS, OPP INORBITMALL, MADHAPUR, HYDERABAD, TG 500081  500081', 56, '31-60', 'April, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    6003, 'Maharashtra', 'Thane', 'LOA00003241', 'AKRPG7011J', 'ACGLLLOT00000003123', 'CHANDAN LALMOHAN GUPTA', 9820887888, 'CHANDAN.7888@GMAIL.COM',
    25000, 21250, 3178, 572, 3750, 572.03, 0, 0, 3177.97,
    16, 0.75, 28000, '2026-04-16', '2026-05-02', '''346801000575', 'ICICI BANK',
    'ICIC0003468', 'INF/INFT/044104674381/69954029     /CHANDANLALMOHANGUPTA/DISBURSE', 'DISBURSED', 'NEW', 'DEEPAK KUMAR', 'KISHAN KUMAR',
    'ROOM NO 402 RATNAKAR PATIL BLDG KARAVE SEAWOODS NAVI MUMBAI MAHARASHTRA 400706  400706', 'BEEJAPURI DAIRY PRIVATE LIMITED SHOP NO 06 NIHARIKA MIRAGE PLOT NO 274 SECTOR 10 KHARGHAR NAVI MUMBAI MAHARASHTRA 410210  410210', 79, '61-90', 'April, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    6024, 'Maharashtra', 'Mumbai', 'LOA00003231', 'AHOPN9001F', 'ACGLLLOT00000003113', 'ASHISH ASHOK NINGURKAR', 9082471912, 'ASHISHNINGURKAR@GMAIL.COM',
    40000, 34000, 5085, 915, 6000, 915.25, 0, 0, 5084.75,
    25, 0.75, 47500, '2026-04-16', '2026-05-11', '''8811010007344949', 'DEVELOPMENT BANK OF SINGAPORE',
    'DBSS0IN0811', 'INF/INFT/04409725435 1/69911730 /KURL EPUSRINIVAS /DIS BURSE', 'DISBURSED', 'NEW', 'DEEPAK KUMAR', 'KISHAN KUMAR',
    'B -1/3,SAHAR P AND T COLONY,SAHAR ROAD, ANDHERI EAST,MUMBAI-400099  400099', 'IIM MUMBAI POST OFFICE VIHAR ROAD,NITIE, MUMBAI -400087  400087', 70, '61-90', 'April, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    6048, 'Maharashtra', 'Pune', 'LOA00003234', 'AYWPS9824N', 'ACGLLLOT00000003116', 'AFREEN SHAFIQUE SAYED', 8806137799, 'CONTRACTORTWOC@GMAIL.COM',
    35000, 29750, 4449, 801, 5250, 800.85, 0, 0, 4449.15,
    14, 0.75, 38675, '2026-04-16', '2026-04-30', '''106706310006', 'HSBC BANK',
    'HSBC0411002', 'INF/NEFT/IN426106577 87020/HSBC0411002/69 930255 /DISBURSE /A FREENSHAFI', 'DISBURSED', 'NEW', 'RATNADEEP BIRADAR', 'KISHAN KUMAR',
    'FLAT NO 104,BUILDING P GANGA PLATINO , KHARADI PUNE 411014', 'HEXAWARE SECTOR III, A BLOCK TTC INDUSTRIAL AREA, MAHAPE, NAVI MUMBAI MAHARASHTRA 400093', 81, '61-90', 'April, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    6056, 'Telangana', 'Hyderabad', 'LOA00003235', 'BJDPM9977M', 'ACGLLLOT00000003117', 'MUPPALA  RAKESH', 9963885900, 'RAKESHRAJU.M.9@GMAIL.COM',
    40000, 34000, 5085, 915, 6000, 915.25, 0, 0, 5084.75,
    14, 0.75, 44200, '2026-04-16', '2026-04-30', '''10219742362', 'IDFC FIRST BANK LTD',
    'IDFB0080243', 'INF/NEFT/IN42610657881987/IDFB0080243/69940301 /DISBURSE                      /MUPPALARAKE', 'DISBURSED', 'NEW', 'DEEPAK KUMAR', 'KISHAN KUMAR',
    '1-24-214/2/1, ADARSH NAGAR , VENKATAPURAM, ALWAL, HYDERABAD-500015  500015', 'COGNIZANT TECHNOLOGY SOLUTIONS INDIA PVT. LTD. H-04, VIGNESH HI-TECH CITY-2 SURVEY NO. 30(P), 35(P) & 35(P) GACHIBOWLI, SERILINGAMPALLY MANDAL HYDERABAD â€“ 500019, TELANGANA  500018', 81, '61-90', 'April, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    6073, 'Telangana', 'Hyderabad', 'LOA00003242', 'CTYPS3766C', 'ACGLLLOT00000003124', 'SHANKARAGIRI  SUNDARANEEDI', 9063652032, 'SSHANKARAGIRI@GMAIL.COM',
    40000, 34000, 5085, 915, 6000, 915.25, 0, 0, 5084.75,
    34, 0.75, 50200, '2026-04-16', '2026-05-20', '''058301563887', 'ICICI BANK LIMITED',
    'ICIC0000583', 'INF/INFT/044106420951/69966284     /SHANKARAGIRISUNDARAN/DISBURSE', 'DISBURSED', 'NEW', 'POOJA', 'KISHAN KUMAR',
    '202, SRI POORNANANDA CLASSIC TOWERS, SAIBABA TEMPLE ROAD, BK GUDA, PIN:500038, HYDERABAD 202, SRI POORNANANDA CLASSIC TOWERS, SAIBABA TEMPLE ROAD, BK GUDA, PIN:500038, HYDERABAD  500038', 'EQUINITI INDIA PRIVATE LIMITED WEST TOWER, GOLDHILL SUPREME IT PARK, PHASE II, ELECTRONIC CITY, BENGALURU, KARNATAKA 560100 WEST TOWER, GOLDHILL SUPREME IT PARK, PHASE II, ELECTRONIC CITY, BENGALURU, KARNATAKA 560100  560100', 61, '61-90', 'April, 2026', 'PART-PAYMENT'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    6086, 'West Bengal', '24 Parganas', 'LOA00003250', 'AMPPM2703H', 'ACGLLLOT00000003134', 'ADITYA  MALU', 8420113149, 'ADITMALU@GMAIL.COM',
    60000, 51000, 7627, 1373, 9000, 1372.88, 0, 0, 7627.12,
    13, 0.75, 65850, '2026-04-17', '2026-04-30', '''158420113149', 'INDUSIND BANK',
    'INDB0000526', 'INF/NEFT/IN42610758510847/INDB0000526/70002671 /DISBURSE                      /ADITYAMALU', 'DISBURSED', 'NEW', 'PAYAL NAINWAL', 'KISHAN KUMAR',
    'BD-173, 1ST FLOOR SEC-I,SALTLAKE,KOL-64 KOLKATA-700064  700064', 'INSPIRA ENTERPRISE INDIA LIMITED UNIT NO. 1802, 18TH FLOOR, GODREJ GENESIS, SALT LAKE CITY, SECTOR V, BLOCK EP AND GP, BIDHAN NAGAR, NORTH TWENTY FOUR PARGANAS, WEST BENGAL, 700091.  700091', 81, '61-90', 'April, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    6135, 'Maharashtra', 'Pune', 'LOA00003256', 'CHUPR3348R', 'ACGLLLOT00000003140', 'RAHI DALJEET SINGH PRADEEP SINGH', 9548341943, 'SINGHDILJEET578@GMAIL.COM',
    15000, 12750, 1907, 343, 2250, 343.22, 0, 0, 1906.78,
    14, 0.75, 16575, '2026-04-17', '2026-05-01', '''50100177794130', 'HDFC BANK',
    'HDFC0000039', 'INF/NEFT/IN42610758671779/HDFC0000039/70023068 /DISBURSE                      /RAHIDALJEET', 'DISBURSED', 'NEW', 'POOJA', 'KISHAN KUMAR',
    'SHIV PARK PHASE 1 FLAT 207 OPP SAGAR INN HOTEL HADAPSAR PUNE 412307 SHIV PARK PHASE 1 FLAT 207 OPP SAGAR INN HOTEL HADAPSAR PUNE 412307  412307', 'GALLAGHER SERVICE CENTER LLP GIGA SPACE COMPLEX DELTA 2 4TH FLOOR VIMAN NAGAR PUNE 411011 GIGA SPACE COMPLEX DELTA 2 4TH FLOOR VIMAN NAGAR PUNE 411011  411011', 80, '61-90', 'April, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    6090, 'Telangana', 'Hyderabad', 'LOA00003253', 'ARNPM0079K', 'ACGLLLOT00000003137', 'SURESH  MEKALA', 9642004200, '84.SURESH@GMAIL.COM',
    30000, 25500, 3814, 686, 4500, 686.44, 0, 0, 3813.56,
    43, 0.75, 39675, '2026-04-18', '2026-05-30', '''05451610423410', 'HDFC BANK',
    'HDFC0000545', 'INF/NEFT/IN426108588 72118/HDFC0000545/70 036673 /DISBURSE /S URESHMEKAL', 'DISBURSED', 'NEW', 'POOJA', 'KISHAN KUMAR',
    '3-13-94/49, MADHURA NAGAR, RAMANTHAPUR, HYDERABAD 500013 3-13-94/49, MADHURA NAGAR, RAMANTHAPUR, HYDERABAD 500013  500013', 'VERITY KNOWLEDGE SOLUTIONS PVT LTD 15TH FLOOR, GAR INFOBAHN, TOWER 8, KOKAPET, HYDERABAD 500075 15TH FLOOR, GAR INFOBAHN, TOWER 8, KOKAPET, HYDERABAD 500075  500076', 51, '31-60', 'April, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    6147, 'Maharashtra', 'Mumbai', 'LOA00003261', 'APAPK3329P', 'ACGLLLOT00000003145', 'ATUL RAMESH KASAR', 8850556783, 'ATULKASAR77@GMAIL.COM',
    15000, 12750, 1907, 343, 2250, 343.22, 0, 0, 1906.78,
    23, 0.75, 17587.5, '2026-04-18', '2026-05-11', '''643401509820', 'ICICI BANK LIMITED',
    'ICIC0006434', 'INF/INFT/04412601696 1/70067471 /ATUL RAMESHKASAR /DIS BURSE', 'DISBURSED', 'NEW', 'GARISHMA', 'KISHAN KUMAR',
    'BLDG NO-3, 5TH FLOOR, 505, KRISHNA CHS LTD, GANESH CHOWK ANDHERI (W) MUMBAI MAHARASHTRA- 400053  400053', 'RADISSON BLU MUMBA INTERNATIONAL AIRPORT, MAROL MAROSHI ROAD,MAROL NAKA, ANDHERI-EAST, MUMBAI-400059 MUMBA INTERNATIONAL AIRPORT, MAROL MAROSHI ROAD,MAROL NAKA, ANDHERI-EAST, MUMBAI-400059  400059', 70, '61-90', 'April, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    6164, 'Maharashtra', 'Thane', 'LOA00003263', 'EYRPS9842F', 'ACGLLLOT00000003147', 'MONICA  SHARMA', 9993600992, 'MONICASHARMA1787@GMAIL.COM',
    30000, 25500, 3814, 686, 4500, 686.44, 0, 0, 3813.56,
    42, 0.75, 39450, '2026-04-18', '2026-05-30', '''924010012034402', 'AXIS BANK',
    'UTIB0000373', 'INF/NEFT/IN426108591 90387/UTIB0000373/70 072840 /DISBURSE /M ONICASHARM', 'DISBURSED', 'NEW', 'POOJA', 'KISHAN KUMAR',
    'CIELO F 901, LAKESHORE GREENS, PALAVA, PHASE 2, KHONI, DOMBIVLI EAST THANE, MAHARASHTRA, 421204 CIELO F 901, LAKESHORE GREENS, PALAVA, PHASE 2, KHONI, DOMBIVLI EAST THANE, MAHARASHTRA, 421204  421204', 'ACCENTURE SOLUTIONS PVT LTD OFFICE ADD BUILDING NO 2 THANE BELAPUR ROAD MINDPACE AIROLI 400708 OFFICE ADD BUILDING NO 2 THANE BELAPUR ROAD MINDPACE AIROLI 400708  400708', 51, '31-60', 'April, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    6159, 'Karnataka', 'Bangalore', 'LOA00003277', 'FQOPS0678R', 'ACGLLLOT00000003164', 'DHAVAN KUMAR  S', 9108933007, 'KUMARDHAVAN7@GMAIL.COM',
    20000, 17000, 2542, 458, 3000, 457.63, 0, 0, 2542.37,
    38, 0.75, 25700, '2026-04-20', '2026-05-28', '''923010050057134', 'AXIS BANK',
    'UTIB0000009', 'INF/NEFT/IN42611050060703/UTIB0000009/70131338 /DISBURSE                      /DHAVANKUMAR', 'DISBURSED', 'NEW', 'HIMANI SINGH', 'KISHAN KUMAR',
    '#27/2, RSR COLONY IMMADIHALI NEAR KAVERI BAKERY, IMMADIHALI, WHITEFIELD  560066', 'CAPCO TECHNOLOGIES PRIVATE LIMITED TOWER S2, SURVEY NO 70,77,78/8A, DODDAKANNELLI, SARJAPUR ROAD  560035', 53, '31-60', 'April, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    6200, 'Uttar Pradesh', 'Ghaziabad', 'LOA00003267', 'GYDPS3456F', 'ACGLLLOT00000003151', 'ANUBHAV  SHUKLA', 8287955932, 'ANUBHAVSHUKLA98@GMAIL.COM',
    20000, 17000, 2542, 458, 3000, 457.63, 0, 0, 2542.37,
    15, 0.75, 22250, '2026-04-20', '2026-05-05', '''1914500051', 'KOTAK MAHINDRA BANK',
    'KKBK0004620', 'INF/NEFT/IN42611059807888/KKBK0004620/70103357 /DISBURSE                      /ANUBHAVSHUK', 'DISBURSED', 'NEW', 'PAYAL NAINWAL', 'KISHAN KUMAR',
    'F-1  GRD FLOOR 34/43  FLORA ENCLAVE  GANGAPURAM  GHAZIABAD 201013  201013', 'KALKINE CONSULTANCY INDIA PRIVATE LIMITED A4&A5 LOGIX BUSINESS PARK SECTOR 16 NOIDA 201301  201301', 76, '61-90', 'April, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    6210, 'Telangana', 'Hyderabad', 'LOA00003274', 'BGIPK4263K', 'ACGLLLOT00000003160', 'DUDDI PRADEEP KUMAR', 9908594939, 'PRADEEPDUDDI1319@GMAIL.COM',
    30000, 25500, 3814, 686, 4500, 686.44, 0, 0, 3813.56,
    40, 0.75, 39000, '2026-04-20', '2026-05-30', '''9613783188', 'Kotak Mahindra Bank',
    'KKBK0007466', 'INF/NEFT/IN42611050060581/KKBK0007466/70131338 /DISBURSE                      /DUDDIPRADEE', 'DISBURSED', 'NEW', 'DEEPAK KUMAR', 'KISHAN KUMAR',
    'H.NO.2-1-22/94/A, SAI PRASHANTH NAGAR, KUKATPALLY, HYDERABAD 500072 LANDMARK: TULASI NAGAR COMMUNITY HALL 500071', 'HEXAWARE TECHNOLOGIES PRIVATE LIMITED HINJEWADI, PUNE, MAHARASHTRA 411057  411057', 51, '31-60', 'April, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    6244, 'Maharashtra', 'Pune', 'LOA00003282', 'AAOPW4558M', 'ACGLLLOT00000003169', 'ROHIT  WADHWANI', 9540532073, 'ROHIT.WADHWANI83@GMAIL.COM',
    45000, 38250, 5720, 1030, 6750, 1029.66, 0, 0, 5720.34,
    40, 0.75, 58500, '2026-04-20', '2026-05-30', '''926010000421751', 'AXIS BANK',
    'UTIB0003284', 'INF/NEFT/IN42611050118746/UTIB0003284/70137527 /DISBURSE                      /ROHITWADHWA', 'DISBURSED', 'NEW', 'DEEPAK KUMAR', 'KISHAN KUMAR',
    'B2005 TOWER B R10 UNIVERSE LIFE REPUBLIC MARUNJI PUNE 411033  411033', 'NICE INTERACTIVE SOLUTIONS INDIA PRIVATE LIMITED 8TH FLOOR TOWER B RHINE EMBASSY TECH ZONE HINJEWADI PHASE 2 PUNE 411057  411057', 51, '31-60', 'April, 2026', 'PART-PAYMENT'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    6094, 'Maharashtra', 'Mumbai', 'LOA00003289', 'HUGPK2428K', 'ACGLLLOT00000003176', 'MOHAMMAD FARHAN NASRUDDIN KHAN', 8652746058, 'KHANFARHAN.KF23@GMAIL.COM',
    20000, 17000, 2542, 458, 3000, 457.63, 0, 0, 2542.37,
    39, 0.75, 25850, '2026-04-21', '2026-05-30', '''2501416976689966', 'AU SMALL FINANCE BANK LIMITED',
    'AUBL0004169', 'INF/NEFT/IN42611150663202/AUBL0004169/70191603 /DISBURSE                      /MOHAMMADFAR', 'DISBURSED', 'NEW', 'GARISHMA', 'KISHAN KUMAR',
    'ADDRESS: ROOM NO.603, BUILDING NO.9, SHIVSHAI PRAKALP, SHANTINEKATAN, GENERAL ARUN KUMAR VAIDHYA MARG, GOREGAON EAST, MUMBAI, MAHARASHTRA - 400065  400065', 'AU SMALL FINANCE BANK LIMITED SHOP NO 16, GROUND FLOOR KANAKIA ZILLION, LBS-CST ROAD JUNCTION, BKC ANNEXE, KURLA(W), MUMBAI - 400070, MAHARASHTRA SHOP NO 16, GROUND FLOOR KANAKIA ZILLION, LBS-CST ROAD JUNCTION, BKC ANNEXE, KURLA(W), MUMBAI - 400070, MAHARASHTRA  400070', 51, '31-60', 'April, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    6216, 'Uttar Pradesh', 'Ghaziabad', 'LOA00003285', 'AALPZ4219P', 'ACGLLLOT00000003172', 'TOUSEEF  ZAKI', 9871726990, 'TOUSEEF.ZAKI@YAHOO.COM',
    20000, 17000, 2542, 458, 3000, 457.63, 0, 0, 2542.37,
    39, 0.75, 25850, '2026-04-21', '2026-05-30', '''6245541315', 'KOTAK MAHINDRA BANK LIMITED',
    'KKBK0004624', 'INF/NEFT/IN426111504 48246/KKBK0004624/70 164904 /DISBURSE /T OUSEEFZAKI', 'DISBURSED', 'NEW', 'RATNADEEP BIRADAR', 'KISHAN KUMAR',
    '195 GF 195 SARSWATI VIHAR LONI NA LONI UTTAR PRADESH 201102', 'TATA CONSULTANCY SERVICES ASSOTECH BUISNESS TOWER, SECTOR 135, NOIDA NOIDA 201305', 51, '31-60', 'April, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    6236, 'Telangana', 'Rangareddy', 'LOA00003283', 'CQPPN1921E', 'ACGLLLOT00000003170', 'NEHA', 8639788406, 'NEHA172921@GMAIL.COM',
    35000, 29750, 4449, 801, 5250, 800.85, 0, 0, 4449.15,
    39, 0.75, 45237.5, '2026-04-21', '2026-05-30', '''50100824004978', 'HDFC BANK LTD',
    'HDFC0005790', 'INF/NEFT/IN426111503 89125/HDFC0005790/70 159340 /DISBURSE /N EHA', 'DISBURSED', 'NEW', 'DEEPAK KUMAR', 'KISHAN KUMAR',
    '6-20/2, SHANKERPALLI, RANGAREDDYDIST, TELANGANA,501203  501203', 'OPTUM GLOBAL SOLUTIONS (INDIA) PRIVATE LIMITED 9TH, 10TH, 11TH & 12TH, BUILDING, SURVEY NO. 64 (PART, SUNDEW PROPERTIES SEZ (MINDSPACE, 12B, HITECH CITY RD, A PIIC LAYOUT, MADHAPUR, HYDERABAD, TELANGANA 500081  500081', 51, '31-60', 'April, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    6257, 'Karnataka', 'Bangalore', 'LOA00003286', 'AOKPD0600H', 'ACGLLLOT00000003173', 'M K DINESH', 9686951923, 'DINESH198603@GMAIL.COM',
    15000, 12750, 1907, 343, 2250, 343.22, 0, 0, 1906.78,
    39, 0.75, 19387.5, '2026-04-21', '2026-05-30', '''50100623617962', 'HDFC BANK',
    'HDFC0000133', 'INF/NEFT/IN426111504 48254/HDFC0000133/70 164904 /DISBURSE /M KDINESH', 'DISBURSED', 'NEW', 'PAYAL NAINWAL', 'KISHAN KUMAR',
    '#19 1ST CR YAJAMAN THIMMAIAH LAYOUT. HANUMANTHASAGARA ROAD MADANAYAKANAHALLI. BANGALORE. 562162  562123', 'STRIDES PHARMA SCIENCE LTD STRIDES PHARMA SCIENCE LTD STRIDES HOUSE BILEKAHALLI BANNERGHATTA ROAD OPPOSITE KALAYANI MAGNUM BANGALORE 560076  560076', 51, '31-60', 'April, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    6260, 'Maharashtra', 'Pune', 'LOA00003287', 'BQJPS1986H', 'ACGLLLOT00000003174', 'AMIT PRAMOD SHAH', 8484088940, 'MITSHAH1925@GMAIL.COM',
    25000, 21250, 3178, 572, 3750, 572.03, 0, 0, 3177.97,
    39, 0.75, 32312.5, '2026-04-21', '2026-05-30', '''336301501419', 'ICICI BANK LTD',
    'ICIC0003363', 'INF/INFT/04414759970 1/70164904 /AMIT PRAMODSHAH/DISBURSE', 'DISBURSED', 'NEW', 'PAYAL NAINWAL', 'KISHAN KUMAR',
    'FL-A2-801 AKSHARDHAMSN-46 KONDHWA KD. NR.KUMAR PRITHVI 411048  411048', 'INTERLINK ENGAGE PVT LTD 4TH FLOOR ROHAN MITHILA, MHADA COLONY, VIMAN NAGAR, PUNE, MAHARASHTRA 411014 NEAR SYMBIOSIS LAW COLLEGE. VIMAN NAGAR AIRPORT ROAD  411014', 51, '31-60', 'April, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    6266, 'Maharashtra', 'Thane', 'LOA00003291', 'CYEPS7081P', 'ACGLLLOT00000003178', 'SOHAIL SALIM SHAIKH', 7678034712, 'BEFORU816@GMAIL.COM',
    10000, 8500, 1271, 229, 1500, 228.81, 0, 0, 1271.19,
    39, 0.75, 12925, '2026-04-21', '2026-05-30', '''5645185396', 'KOTAK MAHINDRA BANK',
    'KKBK0001782', 'INF/NEFT/IN42611150663212/KKBK0001782/BULD70191603 /SOHAILSALIMSHAI', 'DISBURSED', 'NEW', 'RATNADEEP BIRADAR', 'KISHAN KUMAR',
    'FLAT NO 902, FLOOR NO 9TH BUILDING NAME SAHIL HEIGHTS CHS, BLOCK SECTOR KILLA GAV PLOT NO 126 TO 137, BELAPUR , THANE 400614', 'Krim Technologies Private Limited UNIT NO. 1042 TOWER A2 10TH FLOOR,SPAZE I TECH PARK SOHNA ROAD SECTGURUGRAM DIST GURGAON 122001', 51, '31-60', 'April, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    6285, 'Maharashtra', 'Mumbai', 'LOA00003293', 'BMSPM4757M', 'ACGLLLOT00000003184', 'PREM DEEPAK MADNANI', 9892913788, 'MADNANIPREM17@GMAIL.COM',
    35000, 29750, 4449, 801, 5250, 800.85, 0, 0, 4449.15,
    39, 0.75, 45237.5, '2026-04-21', '2026-05-30', '''033325222156069', 'NORTH EAST SMALL FINANCE BANK LIMITED',
    'NESF0000333', 'INF/NEFT/IN42611150753815/NESF0000333/70199901 /DISBURSE                      /PREMDEEPAKM', 'DISBURSED', 'NEW', 'RATNADEEP BIRADAR', 'KISHAN KUMAR',
    'DEEPAK V MADNANI 701 A MAHESWAR NO 2 CO OP HSG, BAPU BAGVE ROAD, DAHISAR WEST 400068', 'H K JEWELS PVT. LTD. B-802/803, 8TH FLOOR, THE CAPITAL, BKC, BANDRA (EAST), MUMBAI 400051', 51, '31-60', 'April, 2026', 'PART-PAYMENT'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    6293, 'Telangana', 'Hyderabad', 'LOA00003295', 'BBRPG9441A', 'ACGLLLOT00000003186', 'GARIKAPATI KUMAR PRASANTH', 9513139603, 'PRASANTH.GARIKAPATI522@GMAIL.COM',
    15000, 12750, 1907, 343, 2250, 343.22, 0, 0, 1906.78,
    39, 0.75, 19387.5, '2026-04-21', '2026-05-30', '''055801574088', 'ICICI BANK LIMITED',
    'ICIC0000169', 'INF/INFT/044153253071/70199901     /GARIKAPATIKUMARPRASA/DISBURSE', 'DISBURSED', 'NEW', 'PAYAL NAINWAL', 'KISHAN KUMAR',
    'VIDESI COLONY SAHARA ESTATE AUTO NAGAR HYDERABAD TELANGANA 500068,HYDERABAD,TELANGANA,500068  500070', 'FOUNDEVER CRM INDIA PRIVATE LIMITED FOUNDEVER CRM INDIA PVT LTD, CYBERPEARL, HI-TECH CITY, NEAR RAIDURG METRO STATION, HYDERABAD -500081  500081', 51, '31-60', 'April, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    6302, 'West Bengal', 'Kolkata', 'LOA00003298', 'DPSPS5990K', 'ACGLLLOT00000003192', 'SUMAN  SARKAR', 8240625574, 'SARKAR1992SUMAN@GMAIL.COM',
    10000, 8500, 1271, 229, 1500, 228.81, 0, 0, 1271.19,
    38, 0.75, 12850, '2026-04-22', '2026-05-30', '''50100750450553', 'HDFC BANK',
    'HDFC0000752', 'INF/NEFT/IN42611250995225/HDFC0000752/70218541 /DISBURSE                      /SUMANSARKAR', 'DISBURSED', 'NEW', 'RATNADEEP BIRADAR', 'KISHAN KUMAR',
    'H-125 H-125,39-1C NEW RABINDRA PALLY GARIA PURBA PHOOL BAGAN CALCUTTA SOUTH KOLKATTA WEST BENGAL 700086', 'RELIANCE JIO INFOCOMM LTD - RELIANCE JIO INFOCOMM LTD 30/3 NSC BOSE ROAD NAREDRAPUR KOLKATA 700107', 51, '31-60', 'April, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    6309, 'Telangana', 'Hyderabad', 'LOA00003300', 'JYZPM0989L', 'ACGLLLOT00000003194', 'ARPIT  MATHUR', 8106804658, 'ARPIT.MATHUR247@GMAIL.COM',
    20000, 17000, 2542, 458, 3000, 457.63, 0, 0, 2542.37,
    38, 0.75, 25700, '2026-04-22', '2026-05-30', '''188106804658', 'INDUSIND BANK LTD',
    'INDB0001399', 'INF/NEFT/IN42611250972154/INDB0001399/70216232 /DISBURSE                      /ARPITMATHUR', 'DISBURSED', 'NEW', 'RATNADEEP BIRADAR', 'KISHAN KUMAR',
    'F NO-110 1ST FLOOR CBR ESTATE, BLK-3 MADINAGUDA MIYAPUR 500048', 'APOLLO 2417 INSURANCE SERVICES LIMITED 19, BISHOP GARDENS, RA PURAM, CHENNAI, TAMIL NADU 600007', 51, '31-60', 'April, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    6314, 'Karnataka', 'Bangalore', 'LOA00003306', 'CEOPM0567C', 'ACGLLLOT00000003200', 'SUDHARSHAN REDDY MUKKAMALLA', 8805039300, 'SREDDY.APPS18@GMAIL.COM',
    45000, 38250, 5720, 1030, 6750, 1029.66, 0, 0, 5720.34,
    38, 0.75, 57825, '2026-04-22', '2026-05-30', '''067501509968', 'ICICI BANK LIMITED',
    'ICIC0000675', 'INF/INFT/044160995941/70238798     /SUDHARSHANREDDYMUKKA/DISBURSE', 'DISBURSED', 'NEW', 'DEEPAK KUMAR', 'KISHAN KUMAR',
    '96 2ND FLOOR 5TH CROSS OMKAR NAGAR AREKERE MICO LAYOUT BG RD BANGALORE  560076', 'LKQ INDIA PRIVATE LIMITED 7TH FLOOR, PRIMECO TOWERS, AREKERE GATE, JUNCTION, BANNERGHATTA RD, BENGALURU, KARNATAKA 560076  560076', 51, '31-60', 'April, 2026', 'PART-PAYMENT'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    6325, 'Karnataka', 'Bangalore', 'LOA00003316', 'CUHPA8563P', 'ACGLLLOT00000003211', 'AISHWARYA  VISHWANATH', 7892315880, 'ASHES0993@GMAIL.COM',
    20000, 17000, 2542, 458, 3000, 457.63, 0, 0, 2542.37,
    40, 0.75, 26000, '2026-04-22', '2026-06-01', '''50100772858280', 'HDFC BANK',
    'HDFC0000140', 'INF/NEFT/IN42611251269417/HDFC0000140/70251584 /DISBURSE                      /AISHWARYAVI', 'DISBURSED', 'NEW', 'GARISHMA', 'KISHAN KUMAR',
    '34 2ND CROSS AJJAPPA BLOCK DINNUR RT NAGAR BANGALORE-560032 34 2ND CROSS AJJAPPA BLOCK DINNUR RT NAGAR BANGALORE-560032  560032', 'SAI PRODUCTIONS SAFE VENTURES PANTARAPALYA NAYANDAHALLI RR NAGAR  BANGALORE-560039 SAFE VENTURES PANTARAPALYA NAYANDAHALLI RR NAGAR  BANGALORE-560039  560039', 49, '31-60', 'April, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    6328, 'Uttar Pradesh', 'Noida', 'LOA00003321', 'ANEPP7965Q', 'ACGLLLOT00000003216', 'SACHINDRA KUMAR PANDEY', 9582052777, 'PANDEYSACHINDRA@GMAIL.COM',
    20000, 17000, 2542, 458, 3000, 457.63, 0, 0, 2542.37,
    37, 0.75, 25550, '2026-04-23', '2026-05-30', '''04821140006226', 'HDFC BANK',
    'HDFC0000482', 'INF/NEFT/IN42611351648984/HDFC0000482/70287703 /DISBURSE                      /SACHINDRAKU', 'DISBURSED', 'NEW', 'HIMANI SINGH', 'KISHAN KUMAR',
    'FLAT NO 1822, TOWER F. SAYA ZION, GAUR CITY-1. NOIDA UTTAR PRADESH, 201306  201306', 'CARE HEALTH INSURANCE LIMITED 5TH FLOOR,19 CHAWLA HOUSE, NEHRU PLACE, DELHI - 110019 110019', 51, '31-60', 'April, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    6353, 'Uttar Pradesh', 'Noida', 'LOA00003315', 'EGZPS9976Q', 'ACGLLLOT00000003210', 'VIPUL  SRIVASTAV', 9315850897, 'VIPUL.SRIVASTAV12@GMAIL.COM',
    20000, 17000, 2542, 458, 3000, 457.63, 0, 0, 2542.37,
    37, 0.75, 25550, '2026-04-23', '2026-05-30', '''002101609085', 'ICICI BANK LIMITED',
    'ICIC0000021', 'INF/INFT/04416703968 1/70268654 /VIPU LSRIVASTAV/DISBURSE', 'DISBURSED', 'NEW', 'DEEPAK KUMAR', 'KISHAN KUMAR',
    'FLAT NO. 1048. 1ST FLOOR TOWER-R. SANDALWOOD, MAHAGUN MYWOODS. GAUR CITY-2. GREATER NOIDA WEST. U.P. SECTOR-16C,  201306', 'XL INDIA BUSINESS SERVICES PRIVATE LIMITED SEZ UNIT II, IT/ITES SEZ OF DLF LIMITED, 14TH FLOOR, BLOCK B2 & B3 AND 12TH FLOOR, BLOCK B3 WORLD TECH PARK, SILOKHERA, SECTOR 30, GURUGRAM, HARYANA 122001  122001', 51, '31-60', 'April, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    6387, 'Maharashtra', 'Mumbai', 'LOA00003328', 'ARNPJ7225J', 'ACGLLLOT00000003224', 'DIKSHITA SATISH JADHAV', 9834451397, 'DIKSHITAJADHAV08@GMAIL.COM',
    20000, 17000, 2542, 458, 3000, 457.63, 0, 0, 2542.37,
    37, 0.75, 25550, '2026-04-23', '2026-05-30', '''50100700968948', 'HDFC BANK',
    'HDFC0000002', 'INF/NEFT/IN42611351737244/HDFC0000002/70299075 /DISBURSE                      /DIKSHITASAT', 'DISBURSED', 'NEW', 'GARISHMA', 'KISHAN KUMAR',
    'RACHNA, 33-A, PERRY CROSS ROAD, NEAR JOGGERS PARK, BANDRA WEST, MUMBAI, PIN CODE - 400050 RACHNA, 33-A, PERRY CROSS ROAD, NEAR JOGGERS PARK, BANDRA WEST, MUMBAI, PIN CODE - 400050  400050', 'PUBLICIS GROUPE URMI ESTATE GANPATRAO KADAM MARG LOWER PAREL MUMBAI 400014 URMI ESTATE GANPATRAO KADAM MARG LOWER PAREL MUMBAI 400014  400014', 51, '31-60', 'April, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    6401, 'Delhi', 'New Delhi', 'LOA00003329', 'AYNPS2072D', 'ACGLLLOT00000003225', 'JUBY  SEBASTIAN', 7291949118, 'JUBYSEBASTIAN79@GMAIL.COM',
    30000, 25500, 3814, 686, 4500, 0, 343.22, 343.22, 3813.56,
    14, 0.75, 33150, '2026-04-23', '2026-05-07', '''499279958006', 'HSBC BANK',
    'HSBC0110007', 'INF/NEFT/IN42611351737085/HSBC0110007/70299075 /DISBURSE                      /JUBYSEBASTI', 'DISBURSED', 'NEW', 'PAYAL NAINWAL', 'KISHAN KUMAR',
    'PLOT NO.75 3RD FLOOR, BACK SIDE,77,JINDAL COLONY, SAMALKHA, PUSHPANJALI FAR MS, NEW DELHI, DELHI,KH NO 13/22 SAMALKHA JINDAL COLONY,DELHI,DELHI,110097 110097', 'MODELAMA EXPORTS PVT. LTD. M/S. MODELAMA EXPORTS PVT LTD., PLOT NO. 204, PHASE 1, UDYOG VIHAR GURGAON HARYANA 122016  122016', 74, '61-90', 'April, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    6402, 'West Bengal', 'Kolkata', 'LOA00003338', 'AJGPA8620F', 'ACGLLLOT00000003234', 'PANKAJ KUMAR ADDY', 7003071718, 'ADDYPANKAJ@GMAIL.COM',
    25000, 21250, 3178, 572, 3750, 572.03, 0, 0, 3177.97,
    37, 0.75, 31937.5, '2026-04-23', '2026-05-30', '''099491800000268', 'YES BANK LTD',
    'YESB0000994', 'INF/NEFT/IN42611351736636/YESB0000994/70299075 /DISBURSE                      /PANKAJKUMAR', 'DISBURSED', 'NEW', 'DEEPAK KUMAR', 'KISHAN KUMAR',
    'THAKURPUKUR, BADAMTALA 93/7 KALUA (JOKA) LP-132/4/11 KOLKATA 700104  700107', 'PRAMERICA LIFE INSURANCE LTD. FOURTH FLOOR, KRISHNA BUILDING , PLOT NO . 697, ANANDAPUR , OPP. MANOVIKAS KENDRA KOLKATA, WEST BENGAL - 700107, KOLKATA - 700107, WEST BENGAL, INDIA 700107', 51, '31-60', 'April, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    6411, 'Telangana', 'Hyderabad', 'LOA00003334', 'AVQPV4448L', 'ACGLLLOT00000003230', 'VANDRANGI NAGA VENKATA LAKSHMAN DAS', 9491320590, 'VNVLDAS038@GMAIL.COM',
    30000, 25500, 3814, 686, 4500, 686.44, 0, 0, 3813.56,
    37, 0.75, 38325, '2026-04-23', '2026-05-30', '''814201500086', 'ICICI BANK LTD',
    'ICIC0008142', 'INF/INFT/044171974321/70299075     /VANDRANGINAGAVENKATA/DISBURSE', 'DISBURSED', 'NEW', 'RATNADEEP BIRADAR', 'KISHAN KUMAR',
    'MANSAR ABODE FLAT NO 101 VINAYAK NAGAR COLONY, SHAIKPET,HYDERABAD 500089', 'NIVEUS SOLUTIONS PVT LTD 4TH FLOOR, APARNA CREST, JUBILEE HILLS, HYDERABAD 500015', 51, '31-60', 'April, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    6326, 'Haryana', 'Gurgaon', 'LOA00003165', 'BKAPK2369D', 'ACGLLLOT00000003248', 'MOHIT  KUMAR', 7042133990, 'MOHITKUMAR666@GMAIL.COM',
    20000, 17000, 2542, 458, 3000, 457.63, 0, 0, 2542.37,
    36, 0.75, 25400, '2026-04-24', '2026-05-30', '''509202010101245', 'UNION BANK OF INDIA',
    'UBIN0826685', 'INF/NEFT/IN42611452230850/UBIN0826685/70347210 /DISBURSE                      /MOHITKUMAR', 'DISBURSED', 'REPEAT', 'DEEPAK KUMAR', 'KISHAN KUMAR',
    'B 10 2ND FLOOR SS SOUTHEND FLOORS B BLOCK SECTOR 49 GURGAON HARYANA 122018  122018', 'COMVIVA TECHNOLOGIES LIMITED CAPITAL CYBERSCAPE GOLF COURSE EXTENSION ROAD SECTOR 59 GURGAON HARYANA 122102  122102', 51, '31-60', 'April, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    6413, 'Maharashtra', 'Mumbai', 'ADV00000124', 'ALTPD4936C', 'ACGLLLOT00000003237', 'SACHIN SUDHAKAR DHAWAN', 8097650099, 'SACHINDHAWAN2004@GMAIL.COM',
    25000, 21250, 3178, 572, 3750, 572.03, 0, 0, 3177.97,
    36, 0.75, 31750, '2026-04-24', '2026-05-30', '''552010331292', 'KOTAK MAHINDRA BANK LIMITED',
    'KKBK0001346', 'INF/NEFT/IN42611452116287/UTIB0005070/70333056 /DISBURSE                      /SACHINARVIN', 'DISBURSED', 'REPEAT', 'POOJA', 'KISHAN KUMAR',
    '1701, SHREE SAMRTH VERONICA,SAI VIHAR,TEMBHI PADA ROAD,BHANDUP (WEST) MUMBAI 400078 NEAR PADA ROAD 400078', 'ICA PIDILITE PRIVATE LIMITED 403/404 SATTELITE SILVER BUILDING, ANDHERI KURLA ROAD,MAROL, ANDHERI (EAST),MUMBAI 400059 NEAR MAROL METRO STATION 400059', 51, '31-60', 'April, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    6434, 'Karnataka', 'Bangalore', 'LOA00003351', 'AGZPD8045K', 'ACGLLLOT00000003252', 'SANTANU KUMAR DAS', 9864041362, 'SANTANUDIPDAS@GMAIL.COM',
    40000, 34000, 5085, 915, 6000, 915.25, 0, 0, 5084.75,
    36, 0.75, 50800, '2026-04-24', '2026-05-30', '''50100311542199', 'HDFC BANK',
    'HDFC0003962', 'INF/NEFT/IN42611452116054/HDFC0003962/70333056 /DISBURSE                      /SANTANUKUMA', 'DISBURSED', 'NEW', 'HIMANI SINGH', 'KISHAN KUMAR',
    'PAVAN GARDENS_DML_SRC, PAVAN FANTACY, SITE 618, BEML LAYOUT, BROOKEFIELD,  560066', 'SIX DEE TELECOM SOLUTIONS PVT LTD 6D TECHNOLOGIES 26, WEAVER''S COLONY, J. P. NAGAR,  560076', 51, '31-60', 'April, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    6452, 'Telangana', 'Hyderabad', 'LOA00003341', 'AXDPJ6390C', 'ACGLLLOT00000003239', 'JAKKA  MANI VASU', 6302411616, 'JMANIVASU2@GMAIL.COM',
    45000, 38250, 5720, 1030, 6750, 1029.66, 0, 0, 5720.34,
    36, 0.75, 57150, '2026-04-24', '2026-05-30', '''50100271277188', 'HDFC BANK',
    'HDFC0000050', 'INF/NEFT/IN42611452024287/HDFC0000050/70322849 /DISBURSE                      /JAKKAMANIVA', 'DISBURSED', 'NEW', 'PAYAL NAINWAL', 'KISHAN KUMAR',
    'MIG-28, APHB COLONY,G ACHIBOWLI, HYDERABAD-500031  500031', 'MOURI TECH LIMITED 6-3-83, 3RD FLOOR, LOUKYA TOWERS, MALLAMPET ROAD, BACHUPALLY,HYDERABAD - 500090  500090', 51, '31-60', 'April, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    6453, 'Maharashtra', 'Pune', 'LOA00003352', 'DDCPM3780D', 'ACGLLLOT00000003253', 'MOUNIKA  VASIREDDI', 9873034865, 'MOUNIKA254@GMAIL.COM',
    40000, 34000, 5085, 915, 6000, 915.25, 0, 0, 5084.75,
    36, 0.75, 50800, '2026-04-24', '2026-05-30', '''916010032558167', 'AXIS BANK',
    'UTIB0001034', 'INF/NEFT/IN42611452230831/UTIB0001034/70347210 /DISBURSE                      /MOUNIKAVASI', 'DISBURSED', 'NEW', 'GARISHMA', 'KISHAN KUMAR',
    'E 201 PARK IVORY PARK STREET WAKAD PUNE CITY PUNE WISDOM WORLD SCHOOL PUNE PUNE, MAHARASHTRA, 411057 E 201 PARK IVORY PARK STREET WAKAD PUNE CITY PUNE WISDOM WORLD SCHOOL PUNE PUNE, MAHARASHTRA, 411057  411057', 'UIPATH ROBOTIC PROCESS AUTOMATION INDIA PRIVATE LIMITED UIPATH, 7TH FLOOR PRESTIGE TRADE TOWER PALACE ROAD SAMPANGI RAMA NAGAR BENGALURU KARNATAKA - 560001 UIPATH, 7TH FLOOR PRESTIGE TRADE TOWER PALACE ROAD SAMPANGI RAMA NAGAR BENGALURU KARNATAKA - 560001  560001', 51, '31-60', 'April, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    6464, 'Maharashtra', 'Mumbai', 'LOA00003348', 'AGHPG3446K', 'ACGLLLOT00000003246', 'SUNIL RAJKUMAR GULANI', 9167520255, 'SUNILRAJKUMARGULANI@GMAIL.COM',
    20000, 17000, 2542, 458, 3000, 457.63, 0, 0, 2542.37,
    43, 0.75, 26450, '2026-04-24', '2026-06-06', '''60033316293', 'BANK OF MAHARASHTRA',
    'MAHB0000416', 'INF/NEFT/IN42611452116267/MAHB0000416/70333056 /DISBURSE                      /SUNILRAJKUM', 'DISBURSED', 'NEW', 'DEEPAK KUMAR', 'KISHAN KUMAR',
    'CHOLA BUILDING PLOT NO 111, FLAT NO 34 MODEL TOWN ANDHERI WEST MUMBAI MAHARASHTRA  400053  400053', 'KAILASH MARKETING OFF NO 17 NEAR JANATA COLLEGE BEHIND DR MEHRA HOSPITAL ROAD CHANDRAPUR 442902  442902', 44, '31-60', 'April, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    6475, 'Telangana', 'Hyderabad', 'LOA00003056', 'AJMPC8833G', 'ACGLLLOT00000003250', 'CHINTALA  VENKATESH', 9885229285, 'VENKY.CHINTALA@GMAIL.COM',
    38000, 32300, 4831, 869, 5700, 869.49, 0, 0, 4830.51,
    36, 0.75, 48260, '2026-04-24', '2026-05-30', '''925010004568987', 'AXIS BANK',
    'UTIB0005967', 'INF/NEFT/IN42611452116320/UTIB0005967/70333056 /DISBURSE                      /CHINTALAVEN', 'DISBURSED', 'REPEAT', 'HIMANI SINGH', 'KISHAN KUMAR',
    'FI-501 RISINTA INTELI I FA  MAI KAJGIRIT - HYD OPP KENNEDY SCH MEDCHAL 500090', 'GENPACT INDIA PVT LTD SURVEY NO: 87P AND 88P, PHOENIX TRIVIUM PROJECT, HAFEEZPET VILLAGE, SERILINGAMPALLY MANDAL, HYDERABAD, TELANGANA 500049 HAFEEZPET VILLAGE, SERILINGAMPALLY MANDAL 500049', 51, '31-60', 'April, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    6488, 'Maharashtra', 'Pune', 'LOA00003229', 'AFMPJ1138F', 'ACGLLLOT00000003257', 'SANJAY KISAN JADHAV', 9226802378, 'SANJAYDKGROUP@GMAIL.COM',
    45000, 38250, 5720, 1030, 6750, 1029.66, 0, 0, 5720.34,
    36, 0.75, 57150, '2026-04-24', '2026-05-30', '''106517907006', 'HSBC BANK',
    'HSBC0411002', 'INF/NEFT/IN42611452230839/HSBC0411002/70347210 /DISBURSE                      /SANJAYKISAN', 'DISBURSED', 'REPEAT', 'DEEPAK KUMAR', 'KISHAN KUMAR',
    'S.NO.38 FL.NO.D-601 BASILEO OPP.NARBADA GARDAN HAVELI PUNE PIMPALE GURAV 411061  411061', 'RAZORLEAF IT SOLUTIONS PVT LTD. B103, ICC TRADE TOWER, SENAPATI BAPAT ROAD, PUNE 411016.  411016', 51, '31-60', 'April, 2026', 'PART-PAYMENT'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    6502, 'Delhi', 'New Delhi', 'LOA00003356', 'AWQPA6800Q', 'ACGLLLOT00000003260', 'VIKAS  ATRI', 9716933300, 'VIKASATRI2505@GMAIL.COM',
    48000, 40800, 6102, 1098, 7200, 0, 549.15, 549.15, 6101.69,
    38, 0.75, 61680, '2026-04-24', '2026-06-01', '''001491900013162', 'YES BANK',
    'YESB0000014', 'INF/NEFT/IN42611452230974/YESB0000014/70347210 /DISBURSE                      /VIKASATRI', 'DISBURSED', 'NEW', 'HIMANI SINGH', 'KISHAN KUMAR',
    'K-158, STREET NO 4, MAHIPALPUR, NEW DELHI,  110037', 'GLOBALLOGIC INDIA PRIVATE LIMITED PLOT NO 7, OXYGEN PARK SEZ, SECTOR-144, NOIDA-GREATER NOIDA EXPRESSWAY  201304', 49, '31-60', 'April, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    6483, 'Karnataka', 'Bangalore', 'LOA00003378', 'ARWPT8511A', 'ACGLLLOT00000003282', 'VIGNAN  THOTA', 8801212011, 'THOTA.VIGNAN@GMAIL.COM',
    45000, 38250, 5720, 1030, 6750, 1029.66, 0, 0, 5720.34,
    35, 0.75, 56812.5, '2026-04-25', '2026-05-30', '''50100307460010', 'HDFC BANK',
    'HDFC0002019', 'INF/NEFT/IN42611552998806/HDFC0002019/70395658 /                              /VIGNANTHOTA', 'DISBURSED', 'NEW', 'POOJA', 'KISHAN KUMAR',
    '93, PSR RESIDENCY , FORCE LAYOUT ,RY?AN INTERNATIONAL SCHOOL ROAD ,BROOKFIELD , KUNDANAHALLI , BANGLORE - 560037 93, PSR RESIDENCY , FORCE LAYOUT ,RY?AN INTERNATIONAL SCHOOL ROAD ,BROOKFIELD , KUNDANAHALLI , BANGLORE - 560037  560037', 'ASUX SAFETY COMPONENTS INDIA PRIVATE LIMITED BEE BUILDING, BRIGADE TECH GARDENS, ITPL MAIN ROAD, KUNDHALAHALLI, BANGALORE, 560037 BEE BUILDING, BRIGADE TECH GARDENS, ITPL MAIN ROAD, KUNDHALAHALLI, BANGALORE, 560037  560037', 51, '31-60', 'April, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    6491, 'Telangana', 'Hyderabad', 'LOA00003375', 'ASZPA7981K', 'ACGLLLOT00000003279', 'A PAVAN KUMAR', 9100060688, 'PAVAN.ARUTLA@GMAIL.COM',
    45000, 38250, 5720, 1030, 6750, 1029.66, 0, 0, 5720.34,
    40, 0.75, 58500, '2026-04-25', '2026-06-04', '''0432104000187756', 'IDBI BANK',
    'IBKL0000028', 'INF/NEFT/IN42611552829077/IBKL0000028/70380886 /                              /APAVANKUMAR', 'DISBURSED', 'NEW', 'RATNADEEP BIRADAR', 'KISHAN KUMAR',
    'NMR S DIYA RESIDENCY FLAT NO 401,MANJEERA PIPELINE RD, VINAYAKA NAGAR, HAF EEZPET, HYDERABAD,TELANGANA 500048', 'ILUMEN PRIVATE LIMITED 3RD FLOOR, S.S. PLAZA, PLOT 249, HUDA LAYOUT, NALLAGANDLA, HYDERABAD 500018', 46, '31-60', 'April, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    6509, 'Karnataka', 'Bangalore', 'LOA00003374', 'AYFPH1681K', 'ACGLLLOT00000003278', 'HARSHVARDHAN', 9588805707, 'HARSHVARDHAN.7337@GMAIL.COM',
    40000, 34000, 5085, 915, 6000, 915.25, 0, 0, 5084.75,
    35, 0.75, 50500, '2026-04-25', '2026-05-30', '''159588805707', 'INDUSIND BANK LTD',
    'INDB0002275', 'INF/NEFT/IN42611552897101/INDB0002275/70386460 /                              /HARSHVARDHA', 'DISBURSED', 'NEW', 'PAYAL NAINWAL', 'KISHAN KUMAR',
    'FLAT NO. 101 M,BELLANDUR,BHARANI RESIDENCY,MURALI NILAYA,BANGALORE,KARNATAK A,560103  560103', 'XCALIBER HEALH PRIVATE LIMITED WEWORK VAISHNAVI SIGNATURE , BELLANDUR, BANGALORE, 560103, NEAR CAFE COFFEE DAY  560103', 51, '31-60', 'April, 2026', 'PART-PAYMENT'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    6512, 'Karnataka', 'Bangalore', 'LOA00003380', 'ALCPV9957E', 'ACGLLLOT00000003284', 'VIJAYA  NAIK', 9535379410, 'VIJAY.NAIK4582@GMAIL.COM',
    20000, 17000, 2542, 458, 3000, 457.63, 0, 0, 2542.37,
    41, 0.75, 26150, '2026-04-25', '2026-06-05', '''1350432985', 'KOTAK MAHINDRA BANK',
    'KKBK0008124', 'INF/NEFT/IN42611552897120/KKBK0008124/70386460 /                              /VIJAYANAIK', 'DISBURSED', 'NEW', 'RATNADEEP BIRADAR', 'KISHAN KUMAR',
    'RESIDING AT NO.331, 2ND E CROSS, BASAVESWARANAGAR, BANGALORE 560018', 'KONWERT INDIA MOTORS PRIVATE LIMITED NO 17, 46TH CROSS , JAYNAGAR JAYNAGAR 560070', 45, '31-60', 'April, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    6517, 'Maharashtra', 'Mumbai', 'LOA00003382', 'AOLPJ7040N', 'ACGLLLOT00000003286', 'VINIT SURENDRA JAIN', 9819186106, 'JAINVINIT1212@GMAIL.COM',
    30000, 25500, 3814, 686, 4500, 686.44, 0, 0, 3813.56,
    38, 0.75, 38550, '2026-04-25', '2026-06-02', '''35431546154', 'STATE BANK OF INDIA',
    'SBIN0004666', 'INF/NEFT/IN42611552998795/SBIN0004666/70395658 /                              /VINITSUREND', 'DISBURSED', 'NEW', 'GARISHMA', 'KISHAN KUMAR',
    'C/203 TULJAL CARTER ROAD NO-4, OPP  KRISHNA TOWER BORI VALI EAST MUMBAI  - 400066  400066', 'MEDINOVATION SHIV SURABHI  CHIKHALI WADI  THAKUR VILLAGE  KANDIVALI  EAST  MUMBAI : 400101 SHIV SURABHI  CHIKHALI WADI  THAKUR VILLAGE  KANDIVALI  EAST  MUMBAI : 400101  400101', 48, '31-60', 'April, 2026', 'PART-PAYMENT'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    6519, 'Telangana', 'Medak', 'LOA00003372', 'AWZPV9469K', 'ACGLLLOT00000003276', 'HARISH KUMAR  VARDINENI', 9959819901, 'HARISH995981@GMAIL.COM',
    40000, 34000, 5085, 915, 6000, 915.25, 0, 0, 5084.75,
    35, 0.75, 50500, '2026-04-25', '2026-05-30', '''50100716169432', 'HDFC BANK',
    'HDFC0002513', 'INF/NEFT/IN42611552829063/HDFC0002513/70380886 /                              /HARISHKUMAR', 'DISBURSED', 'NEW', 'HIMANI SINGH', 'KISHAN KUMAR',
    'PLOT NO 44 FLAT NO 301 RR SIGNATURE MYTHRI VALLEY BANDAMKOMMU VILLAGE AMEENPUR MANDAL  502130', 'ALGOLEAP TECHNOLOGIES PVT. LTD 5TH FLOOR, BLOCK B CYBER GATEWAY, HITECH CITY HYDERABAD,  500081', 51, '31-60', 'April, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    6530, 'Maharashtra', 'Thane', 'ADV00000337', 'BXXPS1899A', 'ACGLLLOT00000003273', 'BHARGAV AJAY SHAH', 9307190730, 'BHARGAVSHAH089@GMAIL.COM',
    25000, 21250, 3178, 572, 3750, 572.03, 0, 0, 3177.97,
    30, 0.75, 30625, '2026-04-25', '2026-05-25', '''6750429757', 'KOTAK MAHINDRA BANK LIMITED',
    'KKBK0000629', 'INF/NEFT/IN42611552757308/KKBK0000629/70375692 /                              /BHARGAVAJAY', 'DISBURSED', 'REPEAT', 'HIMANI SINGH', 'KISHAN KUMAR',
    'BLDG NO.1/B/302 PLEASANT PARK TIRUPATI NAGAR PHASE 2 UNITECH ROAD VIRAR WEST  401303', 'CITICORP SERVICES INDIA PRIVATE LIMITED B4/B5 10TH FLOOR NIRLON KNOWLEDGE PARK GOREGAON EAST MUMBAI -400063 NEAR HUB MALL 400063', 56, '31-60', 'April, 2026', 'PART-PAYMENT'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    6532, 'Delhi', 'New Delhi', 'ADV00000646', 'ILPPS9278L', 'ACGLLLOT00000003292', 'SHAGUN  SHARMA', 8178519098, 'SS4183427@GMAIL.COM',
    25000, 21250, 3178, 572, 3750, 0, 286.02, 286.02, 3177.97,
    42, 0.75, 32875, '2026-04-25', '2026-06-06', '''2756101006812', 'CANARA BANK',
    'CNRB0002756', 'INF/NEFT/IN42611552998817/CNRB0002756/70395658 /                              /SHAGUNSHARM', 'DISBURSED', 'NEW', 'PAYAL NAINWAL', 'KISHAN KUMAR',
    'MANDAWALI FAZALPUR DELHI 110092  110092', 'EXTRAMARKS EDUCATION INDIA PRIVATE LIMITED PLOT NO 95-B, BLOCK A, SECTOR 136, NOIDA, UTTAR PRADESH 201304 LANDMARK- URMILA TOWER  201304', 44, '31-60', 'April, 2026', 'PART-PAYMENT'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    6534, 'Maharashtra', 'Pune', 'LOA00003381', 'AFBPY2705E', 'ACGLLLOT00000003285', 'MAYUR PRABHAKAR YANDE', 9028076007, 'YANDE.MP@GMAIL.COM',
    40000, 34000, 5085, 915, 6000, 915.25, 0, 0, 5084.75,
    37, 0.75, 51100, '2026-04-25', '2026-06-01', '''01481140056157', 'HDFC BANK',
    'HDFC0000148', 'INF/NEFT/IN42611552897130/HDFC0000148/70386460 /                              /MAYURPRABHA', 'DISBURSED', 'NEW', 'RATNADEEP BIRADAR', 'KISHAN KUMAR',
    'AWING FLAT NO 503 FIFTH AVENUE, HANDEWADI HANDEWADI,PUNE 411028', 'BMC SOFTWARE INDIA PVT LTD YERAWADA AT WING 1, TOWER B, POONAWALA BUSINESS BAY, SURVEY NO. 103, HISSA NO. 2, AIRPORT ROAD, PUNE 411006', 49, '31-60', 'April, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    6535, 'Karnataka', 'Bangalore', 'LOA00003383', 'ACDPH3417P', 'ACGLLLOT00000003287', 'GIRISH BHASKAR HERLE', 9535044570, 'GIRISH.HERLE@OUTLOOK.COM',
    45000, 38250, 5720, 1030, 6750, 1029.66, 0, 0, 5720.34,
    35, 0.75, 56812.5, '2026-04-25', '2026-05-30', '''50100044201241', 'HDFC BANK',
    'HDFC0000053', 'INF/NEFT/IN42611552997605/HDFC0000053/70395658 /                              /GIRISHBHASK', 'DISBURSED', 'NEW', 'POOJA', 'KISHAN KUMAR',
    'NO 1241 ESHWARI 1ST FLOOR 1ST MAIN BEML LAYOUT RR NAGAR,BANGALORE,KARNATAKA,560098 NO 1241 ESHWARI 1ST FLOOR 1ST MAIN BEML LAYOUT RR NAGAR,BANGALORE,KARNATAKA,560098  560098', 'NI SYSTEMS (INDIA) PVT LTD 81/1 & 82/1, SALARPURIA SOFTZONE, WING B, 5TH FLOOR, BLOCK A BELLANDUR, VARTHUR HOBLI, BENGALURU,KARNATAKA - 560103 81/1 & 82/1, SALARPURIA SOFTZONE, WING B, 5TH FLOOR, BLOCK A BELLANDUR, VARTHUR HOBLI, BENGALURU,KARNATAKA - 560103  560103', 51, '31-60', 'April, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    6513, 'Telangana', 'Hyderabad', 'LOA00003396', 'CBLPK1785J', 'ACGLLLOT00000003305', 'KODURI  PRASAD', 8778284458, 'CANADAPRASAD89@GMAIL.COM',
    30000, 25500, 3814, 686, 4500, 686.44, 0, 0, 3813.56,
    33, 0.75, 37425, '2026-04-27', '2026-05-30', '''99980107837382', 'FEDERAL BANK',
    'FDRL0001569', 'INF/NEFT/IN42611753954948/FDRL0001569/70425592 /DISBURSE                      /KODURIPRASA', 'DISBURSED', 'NEW', 'DEEPAK KUMAR', 'KISHAN KUMAR',
    '301,,SRI BALAJI LAYOUT, PRAKASHAM PANTHULU NAGAR, GAJULARAMARAM,,.,HYDER ABAD,TELANGANA,500055 HYDERABAD, TELANGANA, 500055, NEAR PALLAVI SCHOOL 500053', 'CIGNITI TECHNOLOGIES LTD VBIT PARK, ORION BLOCK , MADHAPUR , 500085  500085', 51, '31-60', 'April, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    6542, 'Karnataka', 'Bangalore', 'LOA00003393', 'FQUPP6213D', 'ACGLLLOT00000003300', 'SUBHASIS  PADHI', 7019037398, 'SUBHASISPADHI0711@GMAIL.COM',
    35000, 29750, 4449, 801, 5250, 800.85, 0, 0, 4449.15,
    33, 0.75, 43662.5, '2026-04-27', '2026-05-30', '''10199181030', 'IDFC BANK LIMITED',
    'IDFB0080154', 'INF/NEFT/IN42611753926831/IDFB0080154/70422427 /DISBURSE                      /SUBHASISPAD', 'DISBURSED', 'NEW', 'PAYAL NAINWAL', 'KISHAN KUMAR',
    '3HH2+MPJ, SRINIDHI LAYOUT, VIDYARANYAPURA, BENGALURU, KARNATAKA 560097  560097', 'NETSMART HEALTHCARE SOLUTIONS INDIA PRIVATE LIMITED BELLARY RD, SAHAKAR NAGAR, BYATARAYANAPURA, BENGALURU, KARNATAKA 560092  560092', 51, '31-60', 'April, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    6549, 'Karnataka', 'Bangalore', 'LOA00003395', 'EDRPS6142F', 'ACGLLLOT00000003302', 'SUNNY  SINGH', 7506948725, 'SUNNY.CUTM.SINGH@GMAIL.COM',
    35000, 29750, 4449, 801, 5250, 800.85, 0, 0, 4449.15,
    33, 0.75, 43662.5, '2026-04-27', '2026-05-30', '''10229282505', 'IDFC FIRST BANK LTD',
    'IDFB0080179', 'INF/NEFT/IN42611753926898/IDFB0080179/70422427 /DISBURSE                      /SUNNYSINGH', 'DISBURSED', 'NEW', 'GARISHMA', 'KISHAN KUMAR',
    'FLAT102, SMA RESIDENCY , XP3H+5RG, WHITEFIELD, PATEL NARAYANSWAMY LAYOUT, SIDDAPURA, BENGALURU, KARNATAKA 560066, FLAT102, SMA RESIDENCY , XP3H+5RG, WHITEFIELD, PATEL NARAYANSWAMY LAYOUT, SIDDAPURA, BENGALURU, KARNATAKA 560066,  560066', 'TATA CONSULTANCY SERVICES TCS H BLOCK, GOPALAN GLOBAL AXIS BLOCK-H, RD NUMBER 9, OPP. SRI SATHYA SAI SUPER SPECIALITY HOSPITAL, KIADB EXPORT PROMOTION INDUSTRIAL AREA, WHITEFIELD, BENGALURU, KARNATAKA 560066 TCS H BLOCK, GOPALAN GLOBAL AXIS BLOCK-H, RD NUMBER 9, OPP. SRI SATHYA SAI SUPER SPECIALITY HOSPITAL, KIADB EXPORT PROMOTION INDUSTRIAL AREA, WHITEFIELD, BENGALURU, KARNATAKA 560066  560066', 51, '31-60', 'April, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    6561, 'Telangana', 'Rangareddy', 'LOA00003397', 'BPPPA4264K', 'ACGLLLOT00000003307', 'GOPIKRISHNA  AKAMBARA', 8074993386, 'GOPIKRISHNA0402@GMAIL.COM',
    35000, 29750, 4449, 801, 5250, 800.85, 0, 0, 4449.15,
    33, 0.75, 43662.5, '2026-04-27', '2026-05-30', '''059801540751', 'ICICI BANK LIMITED',
    'ICIC0000681', 'INF/INFT/044201122681/70439165     /GOPIKRISHNAAKAMBARA /DISBURSE', 'DISBURSED', 'NEW', 'HIMANI SINGH', 'KISHAN KUMAR',
    'H NO 31-875 BHOODEVINAGAR, ALWAL, SECUNDERABAD, TELANGANA 500015,HYDERABAD,TELANGANA,500011  500011', 'F5 NETWORKS INNOVATION PRIVATE LIMITED UNIT NO 801-804, SKYVIEW BLDG 20, SY NO 83/1, PLOT NO 22, 23, 24, 31, 32, 33, RAIDURGAM MADHAPUR, HYDERABAD - 500081  500081', 51, '31-60', 'April, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    6574, 'Maharashtra', 'Thane', 'LOA00003398', 'AMQPB4854M', 'ACGLLLOT00000003308', 'SAURABH ANIL BHADE', 9769987637, 'SAURABHBHADE@GMAIL.COM',
    40000, 34000, 5085, 915, 6000, 915.25, 0, 0, 5084.75,
    36, 0.75, 50800, '2026-04-27', '2026-06-02', '''917010062194251', 'AXIS BANK',
    'UTIB0000061', 'INF/NEFT/IN42611753954893/UTIB0000061/70425592 /DISBURSE                      /SAURABHANIL', 'DISBURSED', 'NEW', 'DEEPAK KUMAR', 'KISHAN KUMAR',
    '2707 VIDIT TOWER, PIRAMAL VAIKUNTH, BALKUM THANE 400608  400608', 'CARE.FI TECHNOLOGICAL SOLUTIONS PRIVATE LIMITED 802 & 802-A, IRIS TECH PARK TOWER A, BADSHAHPUR SOHNA ROAD, SECTOR 48, GURGAON, HARYANA, 122018  122018', 48, '31-60', 'April, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    6579, 'Telangana', 'Hyderabad', 'LOA00003399', 'BBIPP2624P', 'ACGLLLOT00000003309', 'SURYA KIRAN  PATELKHANA', 7799788997, 'PSK1986KKD@GMAIL.COM',
    25000, 21250, 3178, 572, 3750, 572.03, 0, 0, 3177.97,
    33, 0.75, 31187.5, '2026-04-27', '2026-05-30', '''3211435203', 'Kotak Mahindra Bank',
    'KKBK0007466', 'INF/NEFT/IN42611753954884/KKBK0007466/70425592 /DISBURSE                      /SURYAKIRANP', 'DISBURSED', 'NEW', 'PAYAL NAINWAL', 'KISHAN KUMAR',
    '4, 6-3-1090/B, LAKE SHORE TOWERS, RAJBHAVAN ROAD SOMAJIGUDA, HYDERABAD, TELANGANA HYDERABAD TELANGANA 500082  500048', 'TATA CONSULTANCY SERVICES SYNERGY PARK  GACHIBOWLI HYDERABAD-500032  500031', 51, '31-60', 'April, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    6584, 'Uttar Pradesh', 'Noida', 'LOA00003405', 'AJXPC2703N', 'ACGLLLOT00000003319', 'AMIT  CHOUKSEY', 9165080767, 'AMITCHOUKSEY836@GMAIL.COM',
    30000, 25500, 3814, 686, 4500, 686.44, 0, 0, 3813.56,
    33, 0.75, 37425, '2026-04-27', '2026-05-30', '''008590600003742', 'YES BANK',
    'YESB0000085', 'INF/NEFT/IN42611754299174/YESB0000085/70463344 /DISBURSE                      /AMITCHOUKSE', 'DISBURSED', 'NEW', 'PAYAL NAINWAL', 'KISHAN KUMAR',
    'HOME CENTURIAN PARK TRACE HOME TOWER F-7 FLAT NO G-04 GREATER NOIDA WEST 201306  201306', 'YES BANK LIMITED OFFICE 5TH FLOOR MAX TOWER SECTOR 16 NOIDA 201310  201301', 51, '31-60', 'April, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    6586, 'Maharashtra', 'Pune', 'LOA00003402', 'BGHPM8616C', 'ACGLLLOT00000003313', 'SHYAM RAJENDRA MEHTA', 9890252476, 'MANOMEHTA@REDIFFMAIL.COM',
    40000, 34000, 5085, 915, 6000, 915.25, 0, 0, 5084.75,
    33, 0.75, 49900, '2026-04-27', '2026-05-30', '''50100733745803', 'HDFC BANK',
    'HDFC0009332', 'INF/NEFT/IN42611754087191/HDFC0009332/70439165 /DISBURSE                      /SHYAMRAJEND', 'DISBURSED', 'NEW', 'POOJA', 'KISHAN KUMAR',
    'FL NO. E2-1007, ROHAN ABHILASHA, G NO. 1458 TO 65 . TAL- HAVELI, DIST- PUNE 412207 FL NO. E2-1007, ROHAN ABHILASHA, G NO. 1458 TO 65 . TAL- HAVELI, DIST- PUNE 412207  412207', 'LUXOFT INDIA LLP RAJIV GANDHI INFOTECH PARK HINJEWADI PHASE2 HINJEWADI PUNE 411057 RAJIV GANDHI INFOTECH PARK HINJEWADI PHASE2 HINJEWADI PUNE 411057  411057', 51, '31-60', 'April, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    6593, 'Telangana', 'Hyderabad', 'LOA00003187', 'AOVPM6416P', 'ACGLLLOT00000003316', 'MALYALA SRI MADHAVA RAO', 7702001932, 'MADHAVAMALYALA@GMAIL.COM',
    25000, 21250, 3178, 572, 3750, 572.03, 0, 0, 3177.97,
    33, 0.75, 31187.5, '2026-04-27', '2026-05-30', '''925010002794328', 'AXIS BANK',
    'UTIB0005128', 'INF/NEFT/IN42611754224010/UTIB0005128/70454902 /DISBURSE                      /MALYALASRIM', 'DISBURSED', 'REPEAT', 'GARISHMA', 'KISHAN KUMAR',
    'H.NO-13-1-233, PLOT 60, BALAJI SWARNAPURI COLONY, BESIDE CARAMEL PRAYER CHURCH, MOTINAGAR, SANATHNAGAR, HYDERABAD,  TELANGANA - 500018PLOT 60, BALAJI SWARNAPURI COLONY, BESIDE CARAMEL PRAYER CHURCH, MOTINAGAR, SANATHNAGAR, HYDERABAD,  TELANGANA - 500018 H.NO-13-1-233, PLOT 60, BALAJI SWARNAPURI COLONY, BESIDE CARAMEL PRAYER CHURCH, MOTINAGAR, SANATHNAGAR, HYDERABAD,  TELANGANA - 500018PLOT 60, BALAJI SWARNAPURI COLONY, BESIDE CARAMEL PRAYER CHURCH, MOTINAGAR, SANATHNAGAR, HYDERABAD,  TELANGANA - 500018  500018', 'WIPRO LIMITED WIPRO LTD  203/1, SEZ, GACHIBOWLI, MANIKONDA, HYDERABAD, TELANGANA 500032 WIPRO LTD  203/1, SEZ, GACHIBOWLI, MANIKONDA, HYDERABAD, TELANGANA 500032  500033', 51, '31-60', 'April, 2026', 'PART-PAYMENT'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    6599, 'Telangana', 'Hyderabad', 'LOA00003385', 'BVCPG4476Q', 'ACGLLLOT00000003312', 'GOTTUMUKKULA RAKESH', 9000884895, 'RAKESHNANI1992@GMAIL.COM',
    20000, 17000, 2542, 458, 3000, 457.63, 0, 0, 2542.37,
    33, 0.75, 24950, '2026-04-27', '2026-05-30', '''864010110003188', 'BANK OF INDIA',
    'BKID0008640', 'INF/NEFT/IN42611754087227/BKID0008640/70439165 /DISBURSE                      /GOTTUMUKKUL', 'DISBURSED', 'NEW', 'PAYAL NAINWAL', 'KISHAN KUMAR',
    'PLOT - 30 & 37, NIZAMPET, Q PUR, HYDERABAD 500090  500090', 'FULCRUM DIGITAL PRIVATE LIMITED PLOT NO 23/4, RAJIV GANDHI INFOTECK PARK, PHASE III, MIDC HINJEWADI PUNE, MAHARASHTRA Â­ 411057 411057', 51, '31-60', 'April, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    6614, 'Karnataka', 'Bangalore', 'LOA00003410', 'AOGPK8747N', 'ACGLLLOT00000003333', 'SHRAVAN  KUMAR S', 9880671822, 'SHRAVANKMR81@GMAIL.COM',
    25000, 21250, 3178, 572, 3750, 572.03, 0, 0, 3177.97,
    33, 0.75, 31187.5, '2026-04-27', '2026-05-30', '''50100762918071', 'HDFC BANK LTD',
    'HDFC0009489', 'INF/NEFT/IN42611754292058/HDFC0009489/70462833 /DISBURSE                      /SHRAVANKUMA', 'DISBURSED', 'NEW', 'POOJA', 'KISHAN KUMAR',
    '173, 1ST FLOOR BANASHANKARI 6TH STAGE SUBRAMANYAPURA BANGALORE 560061 173, 1ST FLOOR BANASHANKARI 6TH STAGE SUBRAMANYAPURA BANGALORE 560061  560061', 'GENPACT INDIA PRIVATE LIMITED PRESTIGE TECH PARK 5TH FLOOR GRAVITY BUILDING KADUBESANAHALLI BANGALORE 560103 PRESTIGE TECH PARK 5TH FLOOR GRAVITY BUILDING KADUBESANAHALLI BANGALORE 560103  560103', 51, '31-60', 'April, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    6628, 'Telangana', 'Rangareddy', 'LOA00003413', 'AVDPJ5107K', 'ACGLLLOT00000003337', 'JALLEPALLI DURGA MAHESH BABU', 9908373460, 'MAHESH.JALLEPALLI@GMAIL.COM',
    30000, 25500, 3814, 686, 4500, 686.44, 0, 0, 3813.56,
    33, 0.75, 37425, '2026-04-27', '2026-05-30', '''277701511487', 'ICICI BANK LIMITED',
    'ICIC0002777', 'INF/INFT/044204975001/70462833     /JALLEPALLIDURGAMAHES/DISBURSE', 'DISBURSED', 'NEW', 'HIMANI SINGH', 'KISHAN KUMAR',
    'DNO-2-62-117/GR/505 FT NO -505 GREEN RIDGE NEAR PRASHANTHI HILLS PRAGA KKP-HYD MEDCHAL MALKAJGIRI  500072', 'QUALCOMM SKY VIEW BUILDING GACHIBOWLI  500090', 51, '31-60', 'April, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    6635, 'Maharashtra', 'Mumbai', 'LOA00003415', 'BAPPS3054N', 'ACGLLLOT00000003339', 'RITURAJ RAVINDRA SINGH', 7738551393, 'DEVGEEKRAJ@GMAIL.COM',
    90000, 76500, 11441, 2059, 13500, 2059.32, 0, 0, 11440.68,
    33, 0.75, 112275, '2026-04-27', '2026-05-30', '''041401004892', 'ICICI BANK LIMITED',
    'ICIC0000414', 'INF/INFT/044205119261/70463344     /RITURAJRAVINDRASINGH/DISBURSE', 'DISBURSED', 'NEW', 'PAYAL NAINWAL', 'KISHAN KUMAR',
    'K 803, MAYURESH SHRITH, LINK ROAD, G D RD, BHANDUP, 400078  400078', 'ARRISE SOLUTION INDIA PVT LTD DLF CYBERCITY BLOCK-1, 1ST FLOOR, 129-132, GACHIBOWLI, HYDERABAD TELANGANA -500032  500031', 51, '31-60', 'April, 2026', 'PART-PAYMENT'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    6640, 'Telangana', 'Hyderabad', 'ADV00001439', 'AUHPN7655F', 'ACGLLLOT00000003343', 'NAVUDURI VENKATA SURYA SRI HARSHA', 9700911217, 'SRIHARSHANAVUDURI@GMAIL.COM',
    22000, 18700, 2797, 503, 3300, 503.39, 0, 0, 2796.61,
    32, 0.75, 27280, '2026-04-28', '2026-05-30', '''916010065365101', 'AXIS BANK',
    'UTIB0000027', 'INF/NEFT/IN42611854542833/UTIB0000027/70483388 /DISBURSE                      /NAVUDURIVEN', 'DISBURSED', 'NEW', 'DEEPAK KUMAR', 'KISHAN KUMAR',
    '1-10-153 FLAT NO 102  1ST FLOOR HOUSE BESIDES LIFT, STREET NO 8, OPP  SAMPATH KUMAR ADVOCATE, ASHOK NAGAR,  MUSHEERABAD, PO: MUSHEERABAD (DELIVERY),  DIST: HYDERABAD,  TELANGANA - 500020  500020', 'INFOSYS BPM LIMITED INFOSYS BPM LTD MANTRI COSMOS ISB ROAD GACHIBOWLI NANAKRAMGUDA HYDERABAD TELANGANA 500032 NEAR BROADCOM  500031', 51, '31-60', 'April, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    6642, 'Maharashtra', 'Pune', 'LOA00003419', 'BPAPK6064G', 'ACGLLLOT00000003345', 'YOGESH UDAY KULKARNI', 9022469158, 'KULKARNIYOGESH007@GMAIL.COM',
    15000, 12750, 1907, 343, 2250, 343.22, 0, 0, 1906.78,
    32, 0.75, 18600, '2026-04-28', '2026-05-30', '''42520100007975', 'BANK OF BARODA',
    'BARB0VADGAO', 'INF/NEFT/IN42611854542822/BARB0VADGAO/70483388 /DISBURSE                      /YOGESHUDAYK', 'DISBURSED', 'NEW', 'HIMANI SINGH', 'KISHAN KUMAR',
    '31 DWARAKA APT. NR DWARAKA NAGARI RAIKAR MALA PUNE  411041', 'NEW PIG INDIA PRIVATE LIMITED SHOP NO 10 SWAPNIL INDUSTRIES INDRAYANI NAGAR PCMC  411026', 51, '31-60', 'April, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    6663, 'Maharashtra', 'Thane', 'LOA00003116', 'AKBPJ3493M', 'ACGLLLOT00000003347', 'SUMEDH PRAKASH JADHAV', 8898048777, 'JADHAVSUMEDH15@GMAIL.COM',
    25000, 21250, 3178, 572, 3750, 572.03, 0, 0, 3177.97,
    28, 0.75, 30250, '2026-04-28', '2026-05-26', '''50100518684080', 'HDFC BANK',
    'HDFC0000542', 'INF/NEFT/IN42611854542852/HDFC0000542/70483388 /DISBURSE                      /SUMEDHPRAKA', 'DISBURSED', 'REPEAT', 'POOJA', 'KISHAN KUMAR',
    'FLAT NO 2312 AURA MARATHON NEXWORLD BETAWADE ROAD THANE 400612 FLAT NO 2312 AURA MARATHON NEXWORLD BETAWADE ROAD THANE 400612  400612', 'HDFC BANK LTD, HDFC BANK LTD, GROUND FLOOR A WING KAMALA MILLS, LOWER PAREL MUMBAI 400013 HDFC BANK LTD, GROUND FLOOR A WING KAMALA MILLS, LOWER PAREL MUMBAI 400013  400013', 55, '31-60', 'April, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    6667, 'Karnataka', 'Bangalore', 'LOA00003205', 'EPLPK0805M', 'ACGLLLOT00000003356', 'PAVAN  KUMAR', 7026363133, 'PKGOWDA11@GMAIL.COM',
    10000, 8500, 1271, 229, 1500, 228.81, 0, 0, 1271.19,
    32, 0.75, 12400, '2026-04-28', '2026-05-30', '''001101000027343', 'INDIAN OVERSEAS BANK',
    'IOBA0000011', 'INF/NEFT/IN42611854543038/IOBA0000011/70483388 /DISBURSE                      /PAVANKUMAR', 'DISBURSED', 'REPEAT', 'HIMANI SINGH', 'KISHAN KUMAR',
    '36 MUTHKUR VIA KDG B LORE,NA BANGALORE  560067', 'ANALYTICAL INVESTMENTS 74, LRDE HOUSING COLONY KARTHIK NAGAR, MARATHAHALLI  560037', 51, '31-60', 'April, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    6668, 'Karnataka', 'Bangalore', 'LOA00003432', 'BKAPS5222B', 'ACGLLLOT00000003363', 'PRATHEEPAN', 9972333733, 'TSP.DEEP@GMAIL.COM',
    25000, 21250, 3178, 572, 3750, 572.03, 0, 0, 3177.97,
    32, 0.75, 31000, '2026-04-28', '2026-05-30', '''035001522306', 'ICICI BANK LIMITED',
    'ICIC0006149', 'INF/INFT/044213007021/70502764     /PRATHEEPAN/DISBURSE', 'DISBURSED', 'NEW', 'HIMANI SINGH', 'KISHAN KUMAR',
    '1133 5TH B CROSS TRIVENI ROAD YESHWANTHPUR  560022', 'DELL INTERNATIONAL SERVICES INDIA PVT. LTD DELL 10 CRYSTAL DOWNS,INTERMEDIATE RING ROAD, EMBASSY GOLF LINKS BUSINESS PARK, DOMLUR  560071', 51, '31-60', 'April, 2026', 'PART-PAYMENT'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    6684, 'Maharashtra', 'Mumbai', 'LOA00003435', 'AUGPR9043J', 'ACGLLLOT00000003371', 'VIKAS KHASHABA RAVIDHONE', 8652060009, 'VIKAS.RAVIDHONE2512@GMAIL.COM',
    45000, 38250, 5720, 1030, 6750, 1029.66, 0, 0, 5720.34,
    32, 0.75, 55800, '2026-04-28', '2026-05-30', '''02281050115038', 'HDFC BANK',
    'HDFC0001602', 'INF/NEFT/IN42611854792367/HDFC0001602/70514956 /DISBURSE                      /VIKASKHASHA', 'DISBURSED', 'NEW', 'RATNADEEP BIRADAR', 'KISHAN KUMAR',
    'BLDG NO 88, 403, VRUSHALI CHS LTD, TILAK NAGAR, J K ROAD, NEAR AMCHI SHALA, NEAR UNIVERSAL SCHOOL,CHEMBUR 400089', 'DELOITTE CONSULTING INDIA PRIVATE LIMITED FLOOR 4, DELOITTE TOWER 1, SURVEY NO. 41, GACHIBOWLI VILLAGE, RANGA REDDY DISTRICT, HYDERABAD 500006', 51, '31-60', 'April, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    6687, 'Telangana', 'Medak', 'LOA00003441', 'AFMPN9323A', 'ACGLLLOT00000003380', 'NARAHARI  BALACHANDER', 9920530734, 'NARAHARI.BALACHANDER@GMAIL.COM',
    40000, 34000, 5085, 915, 6000, 915.25, 0, 0, 5084.75,
    32, 0.75, 49600, '2026-04-28', '2026-05-30', '''4648212498', 'KOTAK MAHINDRA BANK',
    'KKBK0007489', 'INF/NEFT/IN42611854837895/KKBK0007489/70519791 /DISBURSE                      /NARAHARIBAL', 'DISBURSED', 'NEW', 'DEEPAK KUMAR', 'KISHAN KUMAR',
    'PARK WOOD SIGNATURE  FLAT NUMBER  501 ,BLOCK 1 SRI VANI NAGAR  ROAD NUMBER 13F NEAR SUJATA HOMES AMEENPUR  HYDERABAD  502032  502032', 'QUADRANT IT SERVICES PVT LTD JAIN SADGURU IMAGE CAPITAL PARK IMAGE GARDEN ROAD  MADHAPUR  500018  500018', 51, '31-60', 'April, 2026', 'PART-PAYMENT'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    6707, 'Maharashtra', 'Mumbai', 'LOA00003439', 'AQJPA2355H', 'ACGLLLOT00000003378', 'ABHINAV  ANURAG', 8140851013, 'ABHINAVDBG.ANURAG@GMAIL.COM',
    45000, 38250, 5720, 1030, 6750, 1029.66, 0, 0, 5720.34,
    30, 0.75, 55125, '2026-04-28', '2026-05-28', '''7883425643', 'INDIAN BANK',
    'IDIB000F523', 'INF/NEFT/IN42611854837897/IDIB000F523/70519791 /DISBURSE                      /ABHINAVANUR', 'DISBURSED', 'NEW', 'PAYAL NAINWAL', 'KISHAN KUMAR',
    'B-308 GAUTAM APARTMENT , RAHEJA TOWNSHIP, MALAD EAST, 400097  400097', 'INDIAN BANK INDIAN BANK, TREASURY BRANCH , 1ST FLOOR, FORT MUMBAI 400001  400001', 53, '31-60', 'April, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    6710, 'Maharashtra', 'Thane', 'LOA00003440', 'IKQPS5812C', 'ACGLLLOT00000003379', 'PARAG RAJESH SHIVANKAR', 8446689691, 'PARAG.SHIVANKAR7@GMAIL.COM',
    20000, 17000, 2542, 458, 3000, 457.63, 0, 0, 2542.37,
    32, 0.75, 24800, '2026-04-28', '2026-05-30', '''20516548601', 'STATE BANK OF INDIA',
    'SBIN0001821', 'INF/NEFT/IN42611854837864/SBIN0001821/70519791 /DISBURSE                      /PARAGRAJESH', 'DISBURSED', 'NEW', 'RATNADEEP BIRADAR', 'KISHAN KUMAR',
    'FLAT NO 703 FLOOR 7 WING C SHREE MORYA COMPLEX-C, CHOLEGAON CHOLEGAON, 90 FEET RD, 90 FEET ROAD, 421201', 'HEXAWARE TECHNOLOGIES  LTD A BLOCK, BLDG. NO. 152, MILLENNIUM BUSINESS PARK, T.T.C. INDUSTRIAL AREA, SECTOR - 3, MAHAPE, NAVI MUMBAI 400097', 51, '31-60', 'April, 2026', 'PART-PAYMENT'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    6719, 'Karnataka', 'Bangalore', 'LOA00003442', 'AKJPR2238Q', 'ACGLLLOT00000003382', 'ABHIJEET  RAY', 8861606404, 'RAYABHIJEET@GMAIL.COM',
    45000, 38250, 5720, 1030, 6750, 1029.66, 0, 0, 5720.34,
    32, 0.75, 55800, '2026-04-28', '2026-05-30', '''100701521103', 'ICICI BANK LIMITED',
    'ICIC0001007', 'INF/INFT/044215673911/70519791     /ABHIJEETRAY/DISBURSE', 'DISBURSED', 'NEW', 'PAYAL SHARMA', 'KISHAN KUMAR',
    '3E 305 ARYA HAMSA APARTMENT 80 FEET ,ROAD ROYAL COUNTY PHASE 1 J P NAGAR 8TH PHASE BANGALORE ROYAL COUNTY 560083', 'HEXAWARE TECHNOLOGIES LIMITED BPS HEXAWARE TECHNOLOGIES LIMITED, AURUM Q1, LOMA IT PARK, MIDC INDUSTRIAL AREA, GHANSOLI AURUM Q1, LOMA IT PARK, MIDC INDUSTRIAL AREA, GHANSOLI NAVI MUMBAI LOMA IT PARK 400710', 51, '31-60', 'April, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    6702, 'Delhi', 'New Delhi', 'LOA00003449', 'GCJPS9510J', 'ACGLLLOT00000003389', 'SREEMOL KONGOORPALLY SURESH', 9910941056, 'BIJUSREEMOL98@GMAIL.COM',
    20000, 17000, 2542, 458, 3000, 0, 228.81, 228.81, 2542.37,
    31, 0.75, 24650, '2026-04-29', '2026-05-30', '''50762041003666', 'PUNJAB NATIONAL BANK',
    'PUNB0507610', 'INF/NEFT/IN42611955064508/PUNB0507610/70538665 /DISBURSE                      /SREEMOLKONG', 'DISBURSED', 'NEW', 'GARISHMA', 'KISHAN KUMAR',
    '35-G B7, MAYUR VIHAR PHASE 3 DELHI-110096  110096', 'INDRAPRASTHA MEDICAL CORPORATION LIMITED APOLLO HOSPITAL NOIDA E 2 SECTOR 26 NOIDA GAUTAM BUDDH NAGAR UTTAR PRADESH 201301 APOLLO HOSPITAL NOIDA E 2 SECTOR 26 NOIDA GAUTAM BUDDH NAGAR UTTAR PRADESH 201301  201301', 51, '31-60', 'April, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    6714, 'Maharashtra', 'Mumbai', 'LOA00003450', 'AXFPN3546E', 'ACGLLLOT00000003390', 'UTTKARSHA VILAS NANDOSKAR', 8689943668, 'UVI9696@GMAIL.COM',
    25000, 21250, 3178, 572, 3750, 572.03, 0, 0, 3177.97,
    31, 0.75, 30812.5, '2026-04-29', '2026-05-30', '''3014574772', 'KOTAK MAHINDRA BANK LIMITED',
    'KKBK0001369', 'INF/NEFT/IN42611955064485/KKBK0001369/70538665 /DISBURSE                      /UTTKARSHAVI', 'DISBURSED', 'NEW', 'POOJA', 'KISHAN KUMAR',
    '101 SIDDHI VINAYAK MEHER PLOT 192 SCE 19 PIN CODE 410206 101 SIDDHI VINAYAK MEHER PLOT 192 SCE 19 PIN CODE 410206  400204', 'UNIVERSAL SOMPO GENERAL INSURANCE COMPANY LTD. COMMERZ, OBEROI GARDEN CITY, INTERNATIONAL BUSINESS PARK, 8TH FLOOR AND 9TH FLOOR (PART - SOUTH, OFF WESTERN EXPRESS HIGHWAY, GOREGAON EAST, MAHARASHTRA 400063 COMMERZ, OBEROI GARDEN CITY, INTERNATIONAL BUSINESS PARK, 8TH FLOOR AND 9TH FLOOR (PART - SOUTH, OFF WESTERN EXPRESS HIGHWAY, GOREGAON EAST, MAHARASHTRA 400063  400063', 51, '31-60', 'April, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    6718, 'Maharashtra', 'Thane', 'LOA00003451', 'AITPN3498E', 'ACGLLLOT00000003391', 'ROHIT UDAY NIMBALKAR', 8779535755, 'NIMBALKARROHIT@GMAIL.COM',
    45000, 38250, 5720, 1030, 6750, 1029.66, 0, 0, 5720.34,
    31, 0.75, 55462.5, '2026-04-29', '2026-05-30', '''5839707118', 'AXIS BANK',
    'UTIB0005115', 'INF/NEFT/IN42611955064487/UTIB0005115/70538665 /DISBURSE                      /ROHITUDAYNI', 'DISBURSED', 'NEW', 'RATNADEEP BIRADAR', 'KISHAN KUMAR',
    'L11/1304 MIRA ROAD SWARAJYA CHS LTD NEW MAHDA COMPLEX NR. SHANTI GARDEN, MIRA ROAD (EAST) THANE 401107', 'EDME INSURANCE BROKERS LTD. 6TH FLOOR, VIOS TOWER, OFF EASTERN FREEWAY, NEAR WADALA TRUCK TERMINAL, WADALA (EAST), MUMBAI 400037', 51, '31-60', 'April, 2026', 'PART-PAYMENT'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    6736, 'Maharashtra', 'Pune', 'LOA00003452', 'AVIPT7631D', 'ACGLLLOT00000003393', 'DARSHAN  TANK', 9904494490, 'DTANK7392@GMAIL.COM',
    35000, 29750, 4449, 801, 5250, 800.85, 0, 0, 4449.15,
    31, 0.75, 43137.5, '2026-04-29', '2026-05-30', '''187701514386', 'ICICI BANK LIMITED',
    'ICIC0001877', 'INF/INFT/044220179411/70538665     /DARSHANTANK/DISBURSE', 'DISBURSED', 'NEW', 'PAYAL NAINWAL', 'KISHAN KUMAR',
    'FLAT NO 402 GAGAN RESIDEN YEVLEWADI KONDHVA ROAD,BEHIND DHARMAVAT PETROL PUMP,PISOLI,PUNE PUNE-411048, MAHARASHTRA 411048', 'PERSISTENT SYSTEMS LIMITED BHAGEERATH, 402 E , SENAPATI BAPAT ROAD PUNE , PIN: 411016 411016', 51, '31-60', 'April, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    6754, 'Telangana', 'Rangareddy', 'LOA00003465', 'BZJPK1969H', 'ACGLLLOT00000003412', 'JAYAPRAKASH  KAKARA', 9652022724, 'KJAYAPRAKASH751@GMAIL.COM',
    30000, 25500, 3814, 686, 4500, 686.44, 0, 0, 3813.56,
    31, 0.75, 36975, '2026-04-29', '2026-05-30', '''8847072440', 'Kotak Mahindra Bank',
    'KKBK0007466', 'INF/NEFT/IN42611955261054/KKBK0007466/70562559 /DISBURSE                      /JAYAPRAKASH', 'DISBURSED', 'NEW', 'DEEPAK KUMAR', 'KISHAN KUMAR',
    'PLOT NO 58,ROAD NO -2 MNR HOMES NADERGUL BADANGPET. HYDERABAD 501510 SAVITHA INDRA REDDY COLONY 501510', 'TATA CONSULTANCY SERVICES SURVEY NO. 255, ADIBATLA VILLAGE, IBRAHIMPATNAM MANDAL, RANGA REDDY DISTRICT, HYDERABAD, TELANGANA, 501510  501510', 51, '31-60', 'April, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    6762, 'Karnataka', 'Bangalore', 'LOA00003459', 'JCYPS6745H', 'ACGLLLOT00000003406', 'SANJAYKUMAR  K', 8270081113, 'SANJUEEE05@GMAIL.COM',
    15000, 12750, 1907, 343, 2250, 343.22, 0, 0, 1906.78,
    31, 0.75, 18487.5, '2026-04-29', '2026-05-30', '''606201087147', 'ICICI BANK LIMITED',
    'ICIC0006062', 'INF/INFT/044223952781/70562559     /SANJAYKUMARK/DISBURSE', 'DISBURSED', 'NEW', 'PAYAL SHARMA', 'KISHAN KUMAR',
    'T1 THIRD FLOOR , THILAK GOWDA NILAYA , SATYA NARAYANA SWAMY TEMPLE ROAD CHANNASANDRA K.CHANNASANDRA , PO:KADUGODI DIST:BENGALURU NEAR NIMISHAMBA PROVISION STORE 560067', 'TATA CONSULTANCY SERVICES TATA CONSULTANCY SERVICES LIMITED, EPIP ZONE WHITEFIELD EPIP ZONE 560037', 51, '31-60', 'April, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    6767, 'Maharashtra', 'Pune', 'LOA00003472', 'BGZPM1464Q', 'ACGLLLOT00000003426', 'ASHIS  MONDAL', 8653811111, 'ASHIS1808@GMAIL.COM',
    25000, 21250, 3178, 572, 3750, 572.03, 0, 0, 3177.97,
    31, 0.75, 30812.5, '2026-04-29', '2026-05-30', '''50100044856778', 'HDFC BANK',
    'HDFC0002664', 'INF/NEFT/IN42611955399185/HDFC0002664/70576371 /DISBURSE                      /ASHISMONDAL', 'DISBURSED', 'NEW', 'RATNADEEP BIRADAR', 'KISHAN KUMAR',
    'G.NO. 1204 TO 1208 FL.NO. E-1105 B A VERMOUNT BAITAL HAVELI DIST PUNE WAGHOLI 412207', 'ERICSSON INDIAN PVT LTD B7, INDOSPACE MAHALUNGE ROAD , CHAKAN , PUNE 410402', 51, '31-60', 'April, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    6773, 'Gujarat', 'Ahmedabad', 'LOA00003460', 'AOPPR1199Q', 'ACGLLLOT00000003407', 'RAJPUT DHIRENDRA D', 9664679889, 'JYOTID.4610@GMAIL.COM',
    15000, 12750, 1907, 343, 2250, 343.22, 0, 0, 1906.78,
    33, 0.75, 18712.5, '2026-04-29', '2026-06-01', '''926010000165862', 'AXIS BANK',
    'UTIB0000032', 'INF/NEFT/IN42611955260967/UTIB0000032/70562559 /DISBURSE                      /RAJPUTDHIRE', 'DISBURSED', 'NEW', 'POOJA', 'KISHAN KUMAR',
    '9/A,GAYATRY NAGAR, OPP-CHANDAN PARK, NR.CHANDOLA DHAL, ISANPUR,AHMEDABAD. 9/A,GAYATRY NAGAR, OPP-CHANDAN PARK, NR.CHANDOLA DHAL, ISANPUR,AHMEDABAD.  382443', 'INTAS PHARMACEUTICALS LTD PLOT NO.511/1,OPP.PHARMEZ,MATODA, AHMEDABAD - 382210 PLOT NO.511/1,OPP.PHARMEZ,MATODA, AHMEDABAD - 382210  382210', 49, '31-60', 'April, 2026', 'PART-PAYMENT'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    6778, 'Maharashtra', 'Pune', 'LOA00003467', 'CFIPM3854H', 'ACGLLLOT00000003416', 'NITESH KUMAR MISHRA', 8908751691, 'KUMAR.NITESH703@GMAIL.COM',
    40000, 34000, 5085, 915, 6000, 915.25, 0, 0, 5084.75,
    31, 0.75, 49300, '2026-04-29', '2026-05-30', '''919010033714459', 'AXIS BANK',
    'UTIB0002177', 'INF/NEFT/IN42611955334000/UTIB0002177/70571263 /DISBURSE                      /NITESHKUMAR', 'DISBURSED', 'NEW', 'PAYAL NAINWAL', 'KISHAN KUMAR',
    'A17-1104, MEGAPOLIS SUNWAY, HINJEWADI, PHASE 3, PUNE, MAHARASTRA , 411057 NEAR TCS OFFICE  411057', 'TATA CONSULTANCY SERVICES TCS SP2, RAJIV GANDHI INFOTECH PARK, HINJEWADI, PHASE 3 PUNE MAHARASTRA, 411057 NEAR TECH MAHINDRA OFFICE  411057', 51, '31-60', 'April, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    6797, 'Karnataka', 'Bangalore', 'LOA00002591', 'AUJPP2716P', 'ACGLLLOT00000003419', 'ASHISH  PRIYADARSHI', 9880366794, 'APRIYADARSHI69@GMAIL.COM',
    21000, 17850, 2669, 481, 3150, 480.51, 0, 0, 2669.49,
    31, 0.75, 25882.5, '2026-04-29', '2026-05-30', '''304212010001772', 'UNION BANK OF INDIA',
    'UBIN0830429', 'INF/NEFT/IN42611955334070/UBIN0830429/70571263 /DISBURSE                      /ASHISHPRIYA', 'DISBURSED', 'REPEAT', 'RATNADEEP BIRADAR', 'KISHAN KUMAR',
    'B 3051/TOWER B/BLOCK 3/63 DEGREE EAST, 1ST CROSS ROAD, , VARTHUR HOBLI, KODATHI, PO:CARMELARAM, DIST:BENGALURU, KARNATAKA, 560035 OPPOSITE TO ADARSH SANCTUARY 560035', 'HCL TECH LTD BPO SERVICES SPECIAL ECONOMIC ZONE 129, HCL CAMPUS, BOMMASANDRA JIGANI LINK RD, INDUSTRIAL AREA, BANDE NALLA SANDRA, JIGANI, KARNATAKA 560105 BOMMASANDRA JIGANI LINK RD 560105', 51, '31-60', 'April, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    6801, 'Telangana', 'Hyderabad', 'LOA00003481', 'GMOPK8477H', 'ACGLLLOT00000003438', 'NARASIMHA  KANDUKURI', 9063509767, 'NARSIMHAYADAV1199@GMAIL.COM',
    40000, 34000, 5085, 915, 6000, 915.25, 0, 0, 5084.75,
    34, 0.75, 50200, '2026-04-29', '2026-06-02', '''10232932311', 'IDFC FIRST BANK LTD',
    'IDFB0080223', 'INF/NEFT/IN42611955416095/IDFB0080223/70577122 /DISBURSE                      /NARASIMHAKA', 'DISBURSED', 'NEW', 'HIMANI SINGH', 'KISHAN KUMAR',
    'FLAT NO-402, RANGAREDDY PLOT NO 52, BEHIND BHARAT PETROLEUM, NARSINGI  500045', 'SYNECHRON KI TECHNOLOGY PVT LTD OFFICE ADDRESS-5TH FLOOR, TOWER A AND B, PHASE 1, GLOBAL TECHNOLOGY PARK, OUTER RING ROAD, DEVERABEESANAHALLI VILLAGE,  560103', 48, '31-60', 'April, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    6806, 'Maharashtra', 'Mumbai', 'LOA00003473', 'EQZPR9335A', 'ACGLLLOT00000003427', 'NISHRIN  RAMBHIA', 8097802344, 'NISH57614@GMAIL.COM',
    25000, 21250, 3178, 572, 3750, 572.03, 0, 0, 3177.97,
    34, 0.75, 31375, '2026-04-29', '2026-06-02', '''9947926435', 'KOTAK MAHINDRA BANK LIMITED',
    'KKBK0000674', 'INF/NEFT/IN42611955398000/KKBK0000674/70576371 /DISBURSE                      /NISHRINRAMB', 'DISBURSED', 'NEW', 'DEEPAK KUMAR', 'KISHAN KUMAR',
    'B/4 1ST FLOOR, BHIMCHHAYA SOCIETY, RTO ROAD, FOUR BUNGLOW, ANDHERI WEST, MUMBAI 400053  400053', 'ZELL EDUCATION PVT. LTD. OLD NAGARDAS ROAD, ECO SPACE, ANDHERI EAST, 400069  400069', 48, '31-60', 'April, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    6810, 'Maharashtra', 'Thane', 'LOA00003479', 'BMUPK3927P', 'ACGLLLOT00000003436', 'HITENDRA BHASKAR KHAMKAR', 9867717104, 'HITENKHAMKAR1@GMAIL.COM',
    20000, 17000, 2542, 458, 3000, 457.63, 0, 0, 2542.37,
    31, 0.75, 24650, '2026-04-29', '2026-05-30', '''087301521539', 'ICICI BANK LIMITED',
    'ICIC0000873', 'INF/INFT/044226649951/70577122     /HITENDRABHASKARKHAMK/DISBURSE', 'DISBURSED', 'NEW', 'GARISHMA', 'KISHAN KUMAR',
    'B-202, VARIA FRIENDSHIP COOP SO MARUTI MADHAV NGR DOMBIVALI THANE MAHARASHTRA- 421201  421201', '5PAISA CAPITAL LTD IIFL HOUSE SUN INFOTECH PARK ROAD NO 16V B23 MIDC THANE WAGHLE ESTATE THANE 400604 IIFL HOUSE SUN INFOTECH PARK ROAD NO 16V B23 MIDC THANE WAGHLE ESTATE THANE 400604  400604', 51, '31-60', 'April, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    6787, 'Maharashtra', 'Thane', 'LOA00003498', 'BCIPC5144E', 'ACGLLLOT00000003479', 'ANUP SHARAD CHAMRIA', 9324288436, 'CHAMRIAANUP@GMAIL.COM',
    20000, 17000, 2542, 458, 3000, 457.63, 0, 0, 2542.37,
    30, 0.75, 24500, '2026-04-30', '2026-05-30', '''10209210699', 'IDFC BANK LIMITED',
    'IDFB0040101', 'INF/NEFT/IN42612056137387/IDFB0040101/70641373 /DISBURSE                      /ANUPSHARADC', 'DISBURSED', 'NEW', 'HIMANI SINGH', 'KISHAN KUMAR',
    'NEAR KORUM MALL 71-AARDRA TARANGAN-2 BILDING NO-11 THANE THANE THANE THANE THANE 400606 MAHARASHTRA  400606', 'UPGRAD EDUCATON PVT. LTD. 3RD FLOOR, CTS-796-A, FLEET BUILDING, VLG. MA, OPP. MAROL FIRE STATON, SIR M.V. ROAD, MAROL, ANDHERI (EAST), MUMBAI - 400059  400059', 51, '31-60', 'April, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    6813, 'Maharashtra', 'Pune', 'LOA00003480', 'AVXPC4155A', 'ACGLLLOT00000003437', 'NILESH SHIRISH CHAVAN', 8208668504, 'NILESH.CHAVAN546@GMAIL.COM',
    25000, 21250, 3178, 572, 3750, 572.03, 0, 0, 3177.97,
    31, 0.75, 30812.5, '2026-04-30', '2026-05-30', '''50100122564514', 'HDFC BANK',
    'HDFC0001445', 'INF/NEFT/IN42612055608390/HDFC0001445/70590339 /DISBURSE                      /NILESHSHIRI', 'DISBURSED', 'NEW', 'HIMANI SINGH', 'KISHAN KUMAR',
    'SR NO 637/2B, OMKAR NAGAR POKALE WASTI, NEAR TRANSFORMER, BIBWEWADI, PUNE CITY, PUNE, MAHARASHTRA, 411037  411037', 'POLICYBAZAAR INSURANCE BROKERS PRIVATE LIMITED OFFICE NO 101A 1ST FLOOR RUNWALS SQUARE MUKUND NAGAR PUNE 411037  411037', 51, '31-60', 'April, 2026', 'PART-PAYMENT'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    6823, 'Karnataka', 'Bangalore', 'LOA00002670', 'AZBPR0529H', 'ACGLLLOT00000003444', 'RAVISHA  SADASHIVA', 9164143659, 'RAVISHA400@GMAIL.COM',
    30000, 25500, 3814, 686, 4500, 686.44, 0, 0, 3813.56,
    30, 0.75, 36750, '2026-04-30', '2026-05-30', '''0972500109640001', 'KARNATAKA BANK LIMITED',
    'KARB0000064', 'INF/NEFT/IN42612055685918/KARB0000064/70599791 /DISBURSE                      /RAVISHASADA', 'DISBURSED', 'REPEAT', 'PAYAL NAINWAL', 'KISHAN KUMAR',
    'NO.96/A,2ND CROSS CHAMARAJPET 560019', 'LTI MINDTREE LIMITED GLOBAL VILLAGE TECH PARK MYSORE ROAD BEHIND RV COLLEGE 560059', 51, '31-60', 'April, 2026', 'PART-PAYMENT'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    6829, 'Telangana', 'Hyderabad', 'LOA00003494', 'BEYPC5817E', 'ACGLLLOT00000003473', 'CHITTARI  KRISHNA', 9849209105, 'KITTUKRISHNA7976@GMAIL.COM',
    25000, 21250, 3178, 572, 3750, 572.03, 0, 0, 3177.97,
    37, 0.75, 31937.5, '2026-04-30', '2026-06-06', '''5013564808', 'Kotak Mahindra Bank',
    'KKBK0007466', 'INF/NEFT/IN42612056137170/KKBK0007466/70641373 /DISBURSE                      /CHITTARIKRI', 'DISBURSED', 'NEW', 'HIMANI SINGH', 'KISHAN KUMAR',
    '38-43,SAINIK PURI, AMBEDKAR NAG AR,COMMUNITY HALL,MALKAJGIRI,HYDERABAD  500095', 'NAILBITER RESEARCH PRIVATE LIMITED 10TH FLOOR, NAILBITER RESEARCH PVT LTD, ESPERANZA BUILDING, 1005, LINKING RD, BANDRA WEST, MUMBAI,  400050', 44, '31-60', 'April, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    6834, 'Telangana', 'Hyderabad', 'LOA00003505', 'EUKPK1648N', 'ACGLLLOT00000003504', 'KASETTY  SAINIKETH', 9959295723, 'SAINIKETH74@GMAIL.COM',
    12000, 10200, 1525, 275, 1800, 274.58, 0, 0, 1525.42,
    30, 0.75, 14700, '2026-04-30', '2026-05-30', '''50100652884282', 'HDFC BANK LTD',
    'HDFC0005472', 'INF/NEFT/IN42612056225607/HDFC0005472/70649762 /DISBURSE                      /KASETTYSAIN', 'DISBURSED', 'NEW', 'HIMANI SINGH', 'KISHAN KUMAR',
    'H NO 1-6-33/2 NEAR LAXMI NARASIMHA SWAMY TEMPLE ROAD NO 38 CHAITANYA PURICOLONY SAROORNAGAR  500060', 'NTT MANAGED SERVICES INDIA PRIVATE LIMITED 5TH FLOOR, (EAST WING), BUILDING 5 (VEGA) DIVYASREE ORION, SURVEY NO.66/1, RAIDURG VILLAGE HYDERABAD - 500032  500032', 51, '31-60', 'April, 2026', 'PART-PAYMENT'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    6843, 'Karnataka', 'Bangalore', 'LOA00003488', 'AOQPK0851L', 'ACGLLLOT00000003455', 'SHIVARAJKUMAR  KATTI', 9620389999, 'RAJ3013@GMAIL.COM',
    45000, 38250, 5720, 1030, 6750, 1029.66, 0, 0, 5720.34,
    30, 0.75, 55125, '2026-04-30', '2026-05-30', '''142601507408', 'ICICI BANK LIMITED',
    'ICIC0001850', 'INF/INFT/044231969691/70599791     /SHIVARAJKUMARKATTI  /DISBURSE', 'DISBURSED', 'NEW', 'PAYAL SHARMA', 'KISHAN KUMAR',
    '610 IST FLOOR 2ND CROSS ROAD RBI LAYOUT JP NAGAR 7 TH PHASE BENGALURU BANGALORE  KARNATAKA BEHIND BRAHMIN TIFFINS 560078', 'HONDA POWER PACK ENERGY INDIA PRIVATE LIMITED HONDA POWER PACK ENERGY INDIA PVT LTD NOVA MILLER VASANT NAGAR NOVA MILLER VASANT NAGAR BANGALORE NOVA MILLER VASANT NAGAR 560001', 51, '31-60', 'April, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    6844, 'Karnataka', 'Bangalore', 'LOA00003223', 'AJNPR7030D', 'ACGLLLOT00000003451', 'RAMESHA H M', 7899016655, 'RAMESHAMUNIYAPPA8@GMAIL.COM',
    35000, 29750, 4449, 801, 5250, 800.85, 0, 0, 4449.15,
    30, 0.75, 42875, '2026-04-30', '2026-05-30', '''01331610070863', 'HDFC BANK',
    'HDFC0000133', 'INF/NEFT/IN42612055686160/HDFC0000133/70599791 /DISBURSE                      /RAMESHAHM', 'DISBURSED', 'REPEAT', 'RATNADEEP BIRADAR', 'KISHAN KUMAR',
    '194 HARAPANAHALLI,JIGANI POST, ANEKAL 560105', 'ACCENTURE SOLUTIONS PVT. LTD PRESTIGE RMZ STAR TECH NO. 138 INDUSTRIAL LAYOUT KORAMANGALA,HOSUR ROAD, BANGALORE 560095', 51, '31-60', 'April, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    6852, 'Maharashtra', 'Pune', 'LOA00003240', 'CVNPS7805P', 'ACGLLLOT00000003446', 'AZEEM ABDULSATTAR SHAIKH', 7350904090, 'AZEEM.SHAIKH000@GMAIL.COM',
    15000, 12750, 1907, 343, 2250, 343.22, 0, 0, 1906.78,
    30, 0.75, 18375, '2026-04-30', '2026-05-30', '''922010062506830', 'AXIS BANK',
    'UTIB0005474', 'INF/NEFT/IN42612055685899/UTIB0005474/70599791 /DISBURSE                      /AZEEMABDULS', 'DISBURSED', 'REPEAT', 'DEEPAK KUMAR', NULL,
    'SR.NO. 201/4, SANT DNYANESHWAR NAGAR, BHOSARI ALANDI ROAD, BHOSARI, PUNE 411039  411039', 'INFOSYS BPM LIMITED, BANGALORE ASCENDAS BUILDING, PHASE 3, HINJAWADI RAJIV GANDHI INFOTECH PARK, HINJAWADI, PUNE 411057  411057', 51, '31-60', 'April, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    6853, 'Karnataka', 'Bangalore', 'LOA00003497', 'DTXPS0544C', 'ACGLLLOT00000003477', 'SANAPALA  MANOHAR', 8123378058, 'SANAPALAM@YAHOO.COM',
    35000, 29750, 4449, 801, 5250, 800.85, 0, 0, 4449.15,
    30, 0.75, 42875, '2026-04-30', '2026-05-30', '''50100293658298', 'HDFC BANK',
    'HDFC0003782', 'INF/NEFT/IN42612056137754/HDFC0003782/70641373 /DISBURSE                      /SANAPALAMAN', 'DISBURSED', 'NEW', 'POOJA', 'KISHAN KUMAR',
    '204 A BLOCK 204 A BLOCK ,204 MARKANDHAIHA JAKKURU 560064 BANGALORE EAST BANGALORE KARNATAKA INDIA 204 A BLOCK 204 A BLOCK ,204 MARKANDHAIHA JAKKURU 560064 BANGALORE EAST BANGALORE KARNATAKA INDIA  560064', 'MARELLI (INDIA) PRIVATE LIMITED MANAYATA TECH L4 BANGALORE 560045 MANAYATA TECH L4 BANGALORE 560045  560045', 51, '31-60', 'April, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    6866, 'Maharashtra', 'Pune', 'LOA00002955', 'ACPPU1305H', 'ACGLLLOT00000003456', 'HARSH  UPADHYAY', 8983222338, 'HU5499392@GMAIL.COM',
    40000, 34000, 5085, 915, 6000, 915.25, 0, 0, 5084.75,
    30, 0.75, 49000, '2026-04-30', '2026-05-30', '''10149505226', 'IDFC BANK LIMITED',
    'IDFB0041354', 'INF/NEFT/IN42612055785997/IDFB0041354/70608078 /DISBURSE                      /HARSHUPADHY', 'DISBURSED', 'REPEAT', 'GARISHMA', NULL,
    'FLAT NO. 203, 2ND FLOOR, SIDDHAM PALASHIO KALA KHADAK  411033', 'COGNIZANT COGNIZANT CDC,PHASE 3, PLOT # 26, MIDC, HINJAWADI RAJIV GANDHI INFOTECH PARK, HINJAWADI, PIMPRI-CHINCHWAD,  411057', 51, '31-60', 'April, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    6870, 'West Bengal', 'Kolkata', 'LOA00002920', 'AQQPG1314A', 'ACGLLLOT00000003460', 'NANDINI  GHOSH', 7797309006, 'NANDINIGHOSH2091@GMAIL.COM',
    28000, 23800, 3559, 641, 4200, 640.68, 0, 0, 3559.32,
    30, 0.75, 34300, '2026-04-30', '2026-05-30', '''0412510173', 'KOTAK MAHINDRA BANK LIMITED',
    'KKBK0000326', 'INF/NEFT/IN42612055686231/KKBK0000326/70599791 /DISBURSE                      /NANDINIGHOS', 'DISBURSED', 'REPEAT', 'GARISHMA', NULL,
    'SUNRISE POINT SF 2 FLAT NO 2B, ACTION AREA 2 C NEW TOWN,NORTH 24 PARGANAS,,WEST BENGAL BESIDES AKHANKHA HOUSING COMPLEX 700141', 'TATA CONSULTANCY SERVICES BUILDING NO 1B,ECOSPACE, ACTION AREA 2, RAJARHAT KOLKATA  700157', 51, '31-60', 'April, 2026', 'PART-PAYMENT'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    6875, 'Telangana', 'Hyderabad', 'LOA00002507', 'ANAPM0888P', 'ACGLLLOT00000003463', 'PRASHANTH DEV MYLAMALA', 7893217654, 'PRASHANTHDEVM@GMAIL.COM',
    75000, 63750, 9534, 1716, 11250, 1716.1, 0, 0, 9533.9,
    30, 0.75, 91875, '2026-04-30', '2026-05-30', '''50100498703712', 'HDFC BANK',
    'HDFC0003949', 'INF/NEFT/IN42612055880485/HDFC0003949/70617263 /DISBURSE                      /PRASHANTHDE', 'DISBURSED', 'REPEAT', 'DEEPAK KUMAR', 'KISHAN KUMAR',
    'A701, ADITYA LAGOON, OPPOSITE CRAYONS SCHOOL , NIZAMPET, HYDERABAD, TELANGANA - 500090  500090', 'ENTAIN SOFTWARE DEVELOPMENT SERVICES (INDIA) PRIVATE LIMITED ENTAIN SOFTWARE DEVELOPMENT SERVICES, PRESTIGE SKYTECH, NANAKRAMGUDA, FINANCIAL DISTRICT, HYDERABAD, PINCODE - 500031  500031', 51, '31-60', 'April, 2026', 'PART-PAYMENT'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    6898, 'Delhi', 'New Delhi', 'LOA00003506', 'LPSPS6129E', 'ACGLLLOT00000003505', 'HARSH  SHARMA', 7042022731, 'SHARMA.HARSH19994@GMAIL.COM',
    45000, 38250, 5720, 1030, 6750, 0, 514.83, 514.83, 5720.34,
    34, 0.75, 56475, '2026-04-30', '2026-06-03', '''50100563783431', 'HDFC BANK',
    'HDFC0000933', 'INF/NEFT/IN42612056280947/HDFC0000933/70654286 /DISBURSE                      /HARSHSHARMA', 'DISBURSED', 'NEW', 'PAYAL NAINWAL', 'KISHAN KUMAR',
    'WZ 346 D NANGAL RAYA NEW DELHI 110046  110046', 'MOBILE PROGRAMMING INDIA PRIVATE LIMITED PLOT 46, SECTOR 18 , SARHOL , GURGOAN 122015  122015', 47, '31-60', 'April, 2026', 'PART-PAYMENT'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    6903, 'Karnataka', 'Bangalore', 'LOA00003245', 'AMNPM2281L', 'ACGLLLOT00000003480', 'MADALA  RAVIKANTH', 7330652189, 'MADALA.RAVIKANTH@GMAIL.COM',
    40000, 34000, 5085, 915, 6000, 915.25, 0, 0, 5084.75,
    30, 0.75, 49000, '2026-04-30', '2026-05-30', '''6478729809', 'INDIAN BANK',
    'IDIB000K292', 'INF/NEFT/IN42612056035001/IDIB000K292/70631053 /DISBURSE                      /MADALARAVIK', 'DISBURSED', 'REPEAT', 'DEEPAK KUMAR', NULL,
    'H.NO : 54, SECOND FLOOR, JYOTHI NIVAS, COCOUNUT GARDEN, AYYAPPA NAGAR, KR PURAM, BANGALORE -560036  560036', 'DECISIONMINDS INDIA PVT LTD BRIGADE TECH GARDENS, BROOK FIELD, KUNDALAHALLI, BANGALORE -560037  560037', 51, '31-60', 'April, 2026', 'PART-PAYMENT'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    6912, 'Karnataka', 'Bangalore', 'LOA00003504', 'FZKPD8261G', 'ACGLLLOT00000003502', 'DIVYA', 7619443782, 'DIVYASALIAN20@GMAIL.COM',
    30000, 25500, 3814, 686, 4500, 686.44, 0, 0, 3813.56,
    30, 0.75, 36750, '2026-04-30', '2026-05-30', '''1614295912', 'KOTAK MAHINDRA BANK',
    'KKBK0008072', 'INF/NEFT/IN42612056225600/KKBK0008072/70649762 /DISBURSE                      /DIVYA', 'DISBURSED', 'NEW', 'RATNADEEP BIRADAR', 'KISHAN KUMAR',
    'NO.67, THE HIVE HABITAT, FLAT NO 301, 2ND BLOCK, BTM LAYOUT 4TH STAGE, BANGALORE 560076', 'OMNICOM MEDIA SOLUTIONS BAGMANE SOLARIUM CITY CAMPUS, MANYATA TECH PARK 3, DODDA NEKKUNDI EXTENSION, MAHADEVAPURA, BENGALURU 560004', 51, '31-60', 'April, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    6919, 'Karnataka', 'Bangalore', 'ADV00001237', 'AQIPA9512D', 'ACGLLLOT00000003489', 'ANTIPETA  GANESH', 6281404636, 'ANTIPETAKUSHJOSH@GMAIL.COM',
    53000, 45050, 6737, 1213, 7950, 1212.71, 0, 0, 6737.29,
    30, 0.75, 64925, '2026-04-30', '2026-05-30', '''6247827141', 'KOTAK MAHINDRA BANK',
    'KKBK0008075', 'INF/NEFT/IN42612056137457/KKBK0008075/70641373 /DISBURSE                      /ANTIPETAGAN', 'DISBURSED', 'REPEAT', 'DEEPAK KUMAR', 'KISHAN KUMAR',
    'T4 3RD FLOOR PALOMA RESIDENCY SLIVER SPRINGS LAYOUT MUNNEKOLALA 15TH CROSS ROAD 560037 BACKSTREET OF FRESH TOWN 560037', 'QUALCOMM QUALCOMM CARINA BUILDING BAGAMANE CONSTELLATION PARK OUTER RING ROAD MAHADEVA PURA BANGALORE 560037 NEAR ISTRI HOTEL 560037', 51, '31-60', 'April, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    6926, 'Maharashtra', 'Pune', 'LOA00003209', 'BBCPT6757P', 'ACGLLLOT00000003497', 'THAKUR ROHIT DINESHSINGH', 7020841207, 'ROHITTHAKURAK47@GMAIL.COM',
    15000, 12750, 1907, 343, 2250, 343.22, 0, 0, 1906.78,
    30, 0.75, 18375, '2026-04-30', '2026-05-30', '''4150752789', 'KOTAK MAHINDRA BANK LIMITED',
    'KKBK0001752', 'INF/NEFT/IN42612056225593/KKBK0001752/70649762 /DISBURSE                      /THAKURROHIT', 'DISBURSED', 'REPEAT', 'GARISHMA', NULL,
    'D-1307,MANJARI, PUNE,PUNE SOLAPUR ROAD, SHIV ZEN WORLD,PUNE,PUNE,MAHARASHTR A 412307', 'DIGITRAL PRIVATE LIMITED 2ND FLOOR, SKYVIEW 10, RAIDURGAM, HYDERABAD - 500081, TELANGANA, INDIA  500081', 51, '31-60', 'April, 2026', 'PART-PAYMENT'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    6938, 'Karnataka', 'Bangalore', 'LOA00002595', 'APNPV6371F', 'ACGLLLOT00000003507', 'RUSHIL SHAMKANT VISPUTE', 9714166524, 'RUSHILVISPUTE95@GMAIL.COM',
    87000, 73950, 11059, 1991, 13050, 1990.68, 0, 0, 11059.32,
    33, 0.75, 108532.5, '2026-04-30', '2026-06-02', '''0150379094', 'KOTAK MAHINDRA BANK LIMITED',
    'KKBK0000424', 'INF/NEFT/IN42612056225616/KKBK0000424/70649762 /DISBURSE                      /RUSHILSHAMK', 'DISBURSED', 'REPEAT', 'DEEPAK KUMAR', 'KISHAN KUMAR',
    'D1, ESTEEM SPLENDOR 1, CHIKKI LAKSHMAIAH LAYOUT, OPPOSITE ADUGODI POLICE STATION, ADUGODI, BENGALURU, 560029 OPPOSITE ADUGODI POLICE STATION, 560047', 'SORTING HAT TECHNOLOGIES PRIVATE LIMITED 5TH FLOOR, MARUTHI INFOTECH CENTRE, DOMLUR, BENGALURU, 560071  560071', 48, '31-60', 'April, 2026', 'PART-PAYMENT'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    6939, 'Gujarat', 'Ahmedabad', 'LOA00002238', 'AWVPR6066L', 'ACGLLLOT00000003506', 'AMIT MANGALSINH RATHOD', 9825656561, 'AMITRATHOD8432@GMAIL.COM',
    25000, 21250, 3178, 572, 3750, 572.03, 0, 0, 3177.97,
    32, 0.75, 31000, '2026-04-30', '2026-06-01', '''230801504578', 'ICICI BANK LIMITED',
    'ICIC0002308', 'INF/INFT/044242569451/70654286     /AMITMANGALSINHRATHOD/DISBURSE', 'DISBURSED', 'REPEAT', 'GARISHMA', NULL,
    'B-102, NAVPAD HELIOS BEHIND GANGA RESIDENCY GANDHINAGAR GUJRAT-382421 NEAR ZUNDAL CIRCLE 382421', 'ZYDUS LIFESCIENCES LTD. ZYDUS LIFESCIENCE LIMITED  CORPORATE PARK, NR. VAISHNODEVI CIRCLE, S.G. HIGHWAY AHMEDABAD - 382481  382421', 49, '31-60', 'April, 2026', 'PART-PAYMENT'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    6942, 'Telangana', 'Rangareddy', 'LOA00002638', 'AHNPV7620C', 'ACGLLLOT00000003509', 'VOLETY KRISHNA KIRAN', 8977756143, 'VOLETYKIRAN@GMAIL.COM',
    35000, 29750, 4449, 801, 5250, 800.85, 0, 0, 4449.15,
    32, 0.75, 43400, '2026-04-30', '2026-06-01', '''0031104000325332', 'IDBI BANK',
    'IBKL0000031', 'INF/NEFT/IN42612056280948/IBKL0000031/70654286 /DISBURSE                      /VOLETYKRISH', 'DISBURSED', 'REPEAT', 'POOJA', NULL,
    'FLAT NO 402, SAI SIGNATURE APARTMENTS L, MAYURI NAGAR, MIYAPUR  500049 FLAT NO 402, SAI SIGNATURE APARTMENTS L, MAYURI NAGAR, MIYAPUR  500049  500049', 'CBRE SOUTH ASIA PVT LTD L, SALARPURUA SATTVA BUILDING L, KNOWLEDGE CITY, RAIDURG, HYDERABAD  500081 L, SALARPURUA SATTVA BUILDING L, KNOWLEDGE CITY, RAIDURG, HYDERABAD  500081  500081', 49, '31-60', 'April, 2026', 'PART-PAYMENT'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    6960, 'Haryana', 'Gurgaon', 'LOA00002906', 'DGTPA5458Q', 'ACGLLLOT00000003533', 'SARVESH  AHUJA', 9814444092, 'SARVESHAHUJA45@GMAIL.COM',
    22000, 18700, 2797, 503, 3300, 503.39, 0, 0, 2796.61,
    29, 0.75, 26785, '2026-05-01', '2026-05-30', '''924010025134959', 'AXIS BANK',
    'UTIB0005599', 'INF/NEFT/IN42612156710348/UTIB0005599/70681818 /DISBURSE                      /SARVESHAHUJ', 'DISBURSED', 'REPEAT', 'DEEPAK KUMAR', NULL,
    'FLAT NO 302 PLOT NO 12 CIVIL LINES GURGAON 122001 PEER BABA WALI GALI 122001', 'GENPACT INDIA PRIVATE LIMITED GENPACT SECTOR 69, BADHSHAPUR GURGAON 122001 LANDMARK - NEAR VATIKA CHOWNK 122001', 51, '31-60', 'May, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    6963, 'Karnataka', 'Bangalore', 'LOA00002669', 'BEOPC0832D', 'ACGLLLOT00000003535', 'CHIDANANDA  P', 9632838794, 'SANTU.VERSION@GMAIL.COM',
    14000, 11900, 1780, 320, 2100, 320.34, 0, 0, 1779.66,
    29, 0.75, 17045, '2026-05-01', '2026-05-30', '''4712312024', 'KOTAK MAHINDRA BANK LIMITED',
    'KKBK0008045', 'INF/NEFT/IN42612156573238/KKBK0008045/70669719 /DISBURSE                      /CHIDANANDAP', 'DISBURSED', 'REPEAT', 'GARISHMA', NULL,
    '07 SAPTHAGIRI NILAYA BUDMANAHALLI KAKOLU BANGALORE 560089 07 SAPTHAGIRI NILAYA BUDMANAHALLI KAKOLU BANGALORE 560089  560064', 'BISLERI INTERNATIONAL PRIVATE LIMITED NO.07 RAJMAHAL VILLAS ROAD MEKRI CIRCLE NEXT TO MAGNUM HONDA BANGALORE 560080 NO.07 RAJMAHAL VILLAS ROAD MEKRI CIRCLE NEXT TO MAGNUM HONDA BANGALORE 560080  560080', 51, '31-60', 'May, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    6982, 'Karnataka', 'Bangalore', 'LOA00003118', 'AOVPB1716R', 'ACGLLLOT00000003554', 'BASAVARAJU RAJU VADDIGIRI', 9972375421, 'VBASAVARAJ403@GMAIL.COM',
    27000, 22950, 3432, 618, 4050, 617.8, 0, 0, 3432.2,
    29, 0.75, 32872.5, '2026-05-01', '2026-05-30', '''00761050312940', 'HDFC BANK LTD',
    'HDFC0008030', 'INF/NEFT/IN42612156787437/HDFC0008030/70689756 /DISBURSE                      /BASAVARAJUR', 'DISBURSED', 'REPEAT', 'DEEPAK KUMAR', NULL,
    'S/O VEERANA GOWDA  H NO 22/2 MADHUSUDAN REDDY BLDG DENMAR AVENUE LAYOUT KAMMASANDRA CROSS ELECTRONIC CITY POST BANGALORE KARNATAKA 560100  560100', 'BIOCON LIMITED 20TH KM HOSUR MAIN ROAD ELECTRONIC CITY POST BANGALORE KARNATAKA 560100  560100', 51, '31-60', 'May, 2026', 'PART-PAYMENT'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    6986, 'Maharashtra', 'Mumbai', 'LOA00003192', 'AADPF9838J', 'ACGLLLOT00000003547', 'SYDNEY  FERNANDES', 9821486065, 'SPACEJAM1502@GMAIL.COM',
    30000, 25500, 3814, 686, 4500, 686.44, 0, 0, 3813.56,
    29, 0.75, 36525, '2026-05-01', '2026-05-30', '''50100096040371', 'HDFC BANK',
    'HDFC0000410', 'INF/NEFT/IN42612156626621/HDFC0000410/70674439 /DISBURSE                      /SYDNEYFERNA', 'DISBURSED', 'REPEAT', 'RATNADEEP BIRADAR', 'KISHAN KUMAR',
    'SYDNEY FERNANDES 403 BOBBY APARTMENT CHS LTD, MUMBAI 400103', 'JP MORGAN SERVICES INDIA A WING 16TH FLOOR,  NIRLON KNOWLEDGE PARK, RAM MANDIR ROAD, MUMBAI 400063', 51, '31-60', 'May, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    7017, 'Maharashtra', 'Pune', 'ADV00000389', 'BAPPD3269J', 'ACGLLLOT00000003565', 'MAYUR PRABHAKAR DAKALE', 7666350105, 'MAYUR.DAKALE@REDIFFMAIL.COM',
    46000, 39100, 5847, 1053, 6900, 1052.54, 0, 0, 5847.46,
    31, 0.75, 56695, '2026-05-01', '2026-06-01', '''106604887006', 'HSBC BANK',
    'HSBC0411002', 'INF/NEFT/IN42612156815894/HSBC0411002/70691957 /DISBURSE                      /MAYURPRABHA', 'DISBURSED', 'REPEAT', 'POOJA', 'KISHAN KUMAR',
    'BUNGLOW NO -80,MANJARI, BUNGLOW NO -80,MANJARI, PUNE,,RAVI GARDEN SOCIETY,,PUNE,MAHARASHTRA,412307  412307', 'COLLABERA TALENT SOLUTIONS PRIVATE LIMITED WING 1, TOWER B, BUSINESS BAY, AIRPORT ROAD, YERWADA, PUNE -411006 WING 1, TOWER B, BUSINESS BAY, AIRPORT ROAD, YERWADA, PUNE -411006  411006', 49, '31-60', 'May, 2026', 'PART-PAYMENT'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    7068, 'Telangana', 'Rangareddy', 'LOA00002949', 'ALYPB9493K', 'ACGLLLOT00000003591', 'BORUGADDA NAGESWARA RAO', 8985665314, 'NAGESH.BORUGADDA@GMAIL.COM',
    40000, 34000, 5085, 915, 6000, 915.25, 0, 0, 5084.75,
    26, 0.75, 47800, '2026-05-04', '2026-05-30', '''918010100744793', 'AXIS BANK',
    'UTIB0004055', 'INF/NEFT/IN42612458413415/UTIB0004055/70784857 /DISBURSE                      /BORUGADDANA', 'DISBURSED', 'REPEAT', 'GARISHMA', NULL,
    'H NO 2-180/22, PLOT NO 22, DEVAKI ENCLAVE TORRUR KOHEDA ROAD,  TORRUR, K.V. RANGAREDDY, 8 TELANGANA-501511 NEAR LAKSHYA INTERNATIONAL SCHOOL, 501511', 'BAJAJ LIFE INSURANCE LTD (FORMERLY KNOWN AS BAJAJ ALLIANZ LIFE INSURANCE CO LTD) 3RD FLOOR, NORTH EAST PLAZA, KHAIRTABAD, HYDERABAD, TELANGANA 500082 IRRAM MANZIL COLONY, 500082', 51, '31-60', 'May, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    7090, 'Karnataka', 'Bangalore', 'LOA00003542', 'BMYPS7191D', 'ACGLLLOT00000003596', 'SAPNA AK NAIDU', 9742017957, 'SAPNAAKNAIDU@GMAIL.COM',
    35000, 29750, 4449, 801, 5250, 800.85, 0, 0, 4449.15,
    32, 0.75, 43400, '2026-05-04', '2026-06-05', '''925010045083663', 'AXIS BANK',
    'UTIB0004833', 'INF/NEFT/IN42612458413331/UTIB0004833/70784857 /DISBURSE                      /SAPNAAKNAID', 'DISBURSED', 'NEW', 'PAYAL NAINWAL', 'KISHAN KUMAR',
    'NO.40, KNV ENCLAVE, FLAT NO.002, 3RD CROSS, MARUTHI EXTENSION, NEAR MALLESHWARAM RAILWAY STATION BACK GATE  560021', 'GOJAS EDUCATION LLP NO.88, ANMOL PALANI BUILDING,5TH FLOOR, G.N. CHETTY ROAD, T.NAGAR, CHENNAI 600017, TAMIL NADU, INDIA  560043', 45, '31-60', 'May, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    7092, 'Delhi', 'New Delhi', 'ADV00001192', 'AYOPD3437A', 'ACGLLLOT00000003595', 'GAIRIK  DUTTA', 9999834184, 'GAIRIK.DUTTA@GMAIL.COM',
    25000, 21250, 3178, 572, 3750, 0, 286.02, 286.02, 3177.97,
    32, 0.75, 31000, '2026-05-04', '2026-06-05', '''5032728238', 'AXIS BANK',
    'UTIB0005140', 'INF/NEFT/IN42612458352779/UTIB0005140/70779215 /DISBURSE                      /GAIRIKDUTTA', 'DISBURSED', 'NEW', 'RATNADEEP BIRADAR', 'KISHAN KUMAR',
    'PLOT NO A-264/2 NO.249/2, UGF FLAT N CHHATARPUR ENCLAVE PHASE-II. DELHI 110074', 'MA FOI STRATEGIC CONSULTANTS PVT LTD A1,264/2, SAI APARTMENT,CHHATURPUR ENCLAVE PHASE -2,DELHI 110005', 45, '31-60', 'May, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    7116, 'Maharashtra', 'Thane', 'LOA00003547', 'AMBPR6762R', 'ACGLLLOT00000003602', 'PUJA  RUPAREL', 7032906514, 'PUJARUPAREL2@GMAIL.COM',
    40000, 34000, 5085, 915, 6000, 915.25, 0, 0, 5084.75,
    21, 0.75, 46300, '2026-05-04', '2026-05-25', '''7445947389', 'KOTAK MAHINDRA BANK LIMITED',
    'KKBK0000651', 'INF/NEFT/IN42612458541740/KKBK0000651/70798020 /DISBURSE                      /PUJARUPAREL', 'DISBURSED', 'NEW', 'RATNADEEP BIRADAR', 'KISHAN KUMAR',
    'FLAT: 10D, WING: BLDG-2, SAPPHIRE-2, KASARVADAVALI, SAPPHIRE CHSL, COSMOS JEWELS, G.B. ROAD, NEXT TO D MART, THANE 400615', 'DEUTSCHE INDIA PVT LTD (FORMERLY KNOWN AS DBOI GLOBAL SERVICES PVT LTD) BLOCK B-4,B-5, LEVEL 6, NIRLON KNOWLEDGE PARK, OFF. WESTERN EXPRESS HIGHWAY,GOREGAON 400010', 56, '31-60', 'May, 2026', 'PART-PAYMENT'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    7146, 'Maharashtra', 'Pune', 'LOA00003563', 'APTPP5387F', 'ACGLLLOT00000003619', 'NAYANA SAGAR KASB', 7721017895, 'NAYANAKASBE84@GMAIL.COM',
    25000, 21250, 3178, 572, 3750, 572.03, 0, 0, 3177.97,
    29, 0.75, 30437.5, '2026-05-04', '2026-06-02', '''2045884454', 'KOTAK MAHINDRA BANK',
    'KKBK0001784', 'INF/NEFT/IN42612458815890/KKBK0001784/70823569 /DISBURSE                      /NAYANASAGAR', 'DISBURSED', 'NEW', 'HIMANI SINGH', 'KISHAN KUMAR',
    'C-12, SAHARA PRESTIGE HOUSING SOCIE BHEKRAINAGAR O PP HARI OM SAREE DEPOT FURSUNGI TA:HAVELI DI:PUNE 412308  412308', 'VARROC ENGINEERING LIMITED SOLITAIRE BUSINESS HUB , VIMANNAGR PUNE 411014  411014', 48, '31-60', 'May, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    7105, 'Maharashtra', 'Pune', 'LOA00003564', 'AMQPC7136H', 'ACGLLLOT00000003620', 'RUSHIKESH DEVIDAS CHOPADE', 9822668458, 'CHOPADERISHI@GMAIL.COM',
    70000, 59500, 8898, 1602, 10500, 1601.69, 0, 0, 8898.31,
    31, 0.75, 86275, '2026-05-05', '2026-06-05', '''50100108977135', 'HDFC BANK LTD',
    'HDFC0004692', 'INF/NEFT/IN42612559063660/HDFC0004692/70832393 /DISBURSE                      /RUSHIKESHDE', 'DISBURSED', 'NEW', 'PAYAL NAINWAL', 'KISHAN KUMAR',
    'FLAT NO 103, B-WING SHUBH KALYAN , NEAR DESTINATION CENTRE,NANDED CITY PUNE.411041  411041', 'SUPERFLEET MOBILITY PRIVATE LIMITED SR NO 1182/1/5 FLAT NO 3, ANAND APTS, BEHIND HDFC BANK,FC ROAD, SHIVAJI NAGAR, PUNE, MAHARASHTRA - 411005  411005', 45, '31-60', 'May, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    7127, 'Uttar Pradesh', 'Gautam Buddha Nagar', 'LOA00003561', 'ALJPP4496M', 'ACGLLLOT00000003617', 'GAUTAM  PATHAK', 9811338198, 'GAUTAM.PATHAK7@GMAIL.COM',
    25000, 21250, 3178, 572, 3750, 572.03, 0, 0, 3177.97,
    34, 0.75, 31375, '2026-05-05', '2026-06-08', '''85560100006409', 'BANK OF BARODA',
    'BARB0DBPREM', 'INF/NEFT/IN42612559233260/BARB0DBPREM/70849474 /DISBURSE                      /GAUTAMPATHA', 'DISBURSED', 'NEW', 'POOJA', 'KISHAN KUMAR',
    'PLOT NO D48 SECTOR 41 GAUTAM BUDH NAGAR NOIDA UP 201301 IND PLOT NO D48 SECTOR 41 GAUTAM BUDH NAGAR NOIDA UP 201301 IND  201301', 'CREDBEE RESEARCH AND CONSULTING PVT LTD. F 35/4, SECOND FLOOR, OKHLA PHASE 2, NEW DELHI- 110020 F 35/4, SECOND FLOOR, OKHLA PHASE 2, NEW DELHI- 110020  110020', 42, '31-60', 'May, 2026', 'PART-PAYMENT'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    7130, 'Karnataka', 'Bangalore', 'LOA00003566', 'BROPA0298Q', 'ACGLLLOT00000003622', 'ARUN  KUMAR V', 9972241655, 'ARUNKR.KUMAR25@GMAIL.COM',
    35000, 29750, 4449, 801, 5250, 800.85, 0, 0, 4449.15,
    25, 0.75, 41562.5, '2026-05-05', '2026-05-30', '''10267788377', 'IDFC BANK',
    'IDFB0080181', 'INF/NEFT/IN42612559190412/IDFB0080181/70845346 /DISBURSE                      /ARUNKUMARV', 'DISBURSED', 'NEW', 'POOJA', 'KISHAN KUMAR',
    '109 SHASHI SINGH 4TH CROSS, RAGHURAM LYT, RAMCHANDRAPUR BANGALORE 560013 KARNATAKA INDIA 109 SHASHI SINGH 4TH CROSS, RAGHURAM LYT, RAMCHANDRAPUR BANGALORE 560013 KARNATAKA INDIA  560013', 'ACCENTURE SOLUTIONS PVT LTD PRESTIGE STAR TECH A-BLOCK, KORAMANGALA INDUSTRIAL LAYOUT, KORAMANGALA, BENGALURU, KARNATAKA 560095 PRESTIGE STAR TECH A-BLOCK, KORAMANGALA INDUSTRIAL LAYOUT, KORAMANGALA, BENGALURU, KARNATAKA 560095  560095', 51, '31-60', 'May, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    7139, 'Telangana', 'Hyderabad', 'LOA00003579', 'AOOPV8946G', 'ACGLLLOT00000003638', 'VAKITI V VENU', 9030893654, 'VENUDHARREDDYVN799@GMAIL.COM',
    20000, 17000, 2542, 458, 3000, 457.63, 0, 0, 2542.37,
    34, 0.75, 25100, '2026-05-05', '2026-06-08', '''021212010001247', 'UNION BANK OF INDIA',
    'UBIN0802123', 'INF/NEFT/IN42612559712926/UBIN0802123/70892760 /DISBURSE                      /VAKITIVVENU', 'DISBURSED', 'NEW', 'PAYAL NAINWAL', 'KISHAN KUMAR',
    'H/NO - 49-252/2 PADMANAGAR PHASE -1 3RD FLOOR QUTHUBULLAPUR HYDREABAD TELANGANA-500054  500053', 'AZAD ENGINEERING LIMITED 90/C PHASE I IDA JEEDMETLLA SHAPUR NAGAR MADCHAL HYDERABAD -500055 LAND MARK USHODHYA TRAVERS BACK SIDE 500053', 42, '31-60', 'May, 2026', 'PART-PAYMENT'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    7142, 'Karnataka', 'Bangalore', 'LOA00003569', 'FYLPM1513A', 'ACGLLLOT00000003625', 'MANOJ', 8892788595, 'ITSMANOJ.CONTACT@GMAIL.COM',
    50000, 42500, 6356, 1144, 7500, 1144.07, 0, 0, 6355.93,
    28, 0.75, 60500, '2026-05-05', '2026-06-02', '''3845674351', 'KOTAK MAHINDRA BANK LIMITED',
    'KKBK0008034', 'INF/NEFT/IN42612559190416/KKBK0008034/70845346 /DISBURSE                      /MANOJ', 'DISBURSED', 'NEW', 'POOJA', 'KISHAN KUMAR',
    '407 KHB APARTMENT YELAHANKA NEWTOWN BANGALORE 560064 407 KHB APARTMENT YELAHANKA NEWTOWN BANGALORE 560064  560064', 'PARSPEC INDIA PRIVATE LIMITED VAISHNAVI SIGNATURE, RMZ MILLENIA, HALASURU, BENGALURU, KARNATAKA 560103 VAISHNAVI SIGNATURE, RMZ MILLENIA, HALASURU, BENGALURU, KARNATAKA 560103  560103', 48, '31-60', 'May, 2026', 'PART-PAYMENT'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    7145, 'Telangana', 'Hyderabad', 'LOA00003573', 'CRGPM5481A', 'ACGLLLOT00000003630', 'MOHAMMAD  AREEF', 8121076064, 'AREEFMARLEY1994@GMAIL.COM',
    15000, 12750, 1907, 343, 2250, 343.22, 0, 0, 1906.78,
    25, 0.75, 17812.5, '2026-05-05', '2026-05-30', '''75500100014517', 'BANK OF BARODA',
    'BARB0VJSOMA', 'INF/NEFT/IN42612559233313/BARB0VJSOMA/70849474 /DISBURSE                      /MOHAMMADARE', 'DISBURSED', 'NEW', 'RATNADEEP BIRADAR', 'KISHAN KUMAR',
    '6-3-1177/58, B. S. MAKHTA, BEGUMPET HYDERABAD, 500016', 'GRASIM INDUSTRIES LIMITED, BIRLA PAINTS DIVISION 605, KUMAR BASTI, SRINIVASA NAGAR, AMEERPET, HYDERABAD, 500012', 51, '31-60', 'May, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    7149, 'Maharashtra', 'Mumbai', 'LOA00003568', 'BIMPS8957D', 'ACGLLLOT00000003624', 'PRANAY RAMESH SAWANT', 9769817444, 'PRANAYSAWANT.2010@REDIFFMAIL.COM',
    35000, 29750, 4449, 801, 5250, 800.85, 0, 0, 4449.15,
    35, 0.75, 44187.5, '2026-05-05', '2026-06-09', '''910010010057112', 'AXIS BANK',
    'UTIB0000653', 'INF/NEFT/IN42612559190527/UTIB0000653/70845346 /DISBURSE                      /PRANAYRAMES', 'DISBURSED', 'NEW', 'RATNADEEP BIRADAR', 'KISHAN KUMAR',
    'FL-303:BL-4:SEC-02, NERE , ECONOMY MAHALAXMI NAGAR, PANVEL RAIGARH NAVI MUMBAI 400059', 'OLIVE TEX SILK MILLS PRIVATE LIMITED 101-108, 150-154, SHIV SHAKTI INDUSTRIAL ESTATE, SAKINAKA, ANDHERI KURLA ROAD, ANDHERI (E), MUMBAI 400009', 41, '31-60', 'May, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    7150, 'Karnataka', 'Bangalore', 'LOA00003576', 'ATLPH1962N', 'ACGLLLOT00000003635', 'ANAMALA HEMANTH KUMAR', 7416991497, 'HEMANTH.K0440@GMAIL.COM',
    23000, 19550, 2924, 526, 3450, 526.27, 0, 0, 2923.73,
    27, 0.75, 27657.5, '2026-05-05', '2026-06-01', '''923010063714138', 'AXIS BANK',
    'UTIB0001597', 'INF/NEFT/IN42612559233267/UTIB0001597/70849474 /DISBURSE                      /ANAMALAHEMA', 'DISBURSED', 'NEW', 'POOJA', 'KISHAN KUMAR',
    '562/6 NA, 6TH CROSS, NAGAWARA, BANGALORE KARNATAKA - 560045 562/6 NA 6TH CROSS NAGAWARA, BANGALORE KARNATAKA  560045  560045', 'HCL TECHNOLOGIES LTD HCLTECH OFFICE ,MANYATA TECH PARK,560043 NAGAWARA BANGLORE HCLTECH OFFICE ,MANYATA TECH PARK,560043 NAGAWARA BANGLORE  560043', 49, '31-60', 'May, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    7163, 'West Bengal', 'Kolkata', 'LOA00003586', 'AJKPG9968N', 'ACGLLLOT00000003651', 'JOYDEEP  GHOSH', 9830434550, 'JOYDEEPGHOSHLEO@GMAIL.COM',
    80000, 68000, 10169, 1831, 12000, 1830.51, 0, 0, 10169.49,
    32, 0.75, 99200, '2026-05-05', '2026-06-06', '''50100159538721', 'HDFC BANK',
    'HDFC0000693', 'INF/NEFT/IN42612559804432/HDFC0000693/70900021 /DISBURSE                      /JOYDEEPGHOS', 'DISBURSED', 'NEW', 'DEEPAK KUMAR', 'KISHAN KUMAR',
    'P-75 DAKSHIN BEHALA ROAD LP-110/1/5 KOLKATA 700061  700061', 'RESDA CONSULTANTS PRIVATE LIMITED 25 A PARK STREET â€œ KARNANI MANSIONâ€, 2ND FLOOR, SUITE  212, KOLKATA -700016  700016', 44, '31-60', 'May, 2026', 'PART-PAYMENT'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    7168, 'Telangana', 'Hyderabad', 'LOA00003575', 'AYYPC4972H', 'ACGLLLOT00000003633', 'COPPULA KASI VLSHWANATH', 9640699922, 'KASHIVISHU9@GMAIL.COM',
    35000, 29750, 4449, 801, 5250, 800.85, 0, 0, 4449.15,
    25, 0.75, 41562.5, '2026-05-05', '2026-05-30', '''10172342364', 'IDFC BANK LTD',
    'IDFB0080226', 'INF/NEFT/IN42612559426246/IDFB0080226/70865335 /DISBURSE                      /COPPULAKASI', 'DISBURSED', 'NEW', 'PAYAL NAINWAL', 'KISHAN KUMAR',
    'VILLA NO 4 BHAVNA GLC CRIBS ROAD NO 2 BACHUPALL HYDERABAD ,NULL,,500090  500090', 'TATA CONSULTANCY SERVICES OFFICE TCS SYNERGY PARK GACHIBOWLI HYDERABAD 500019  500018', 51, '31-60', 'May, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    7169, 'Karnataka', 'Bangalore', 'LOA00003582', 'BYGPJ5907E', 'ACGLLLOT00000003642', 'JAMBU PRATHAP SAI CHETHAN', 9966557676, 'SAICHETHAN264@GMAIL.COM',
    12000, 10200, 1525, 275, 1800, 274.58, 0, 0, 1525.42,
    25, 0.75, 14250, '2026-05-05', '2026-05-30', '''141701544234', 'ICICI BANK LIMITED',
    'ICIC0001417', 'INF/INFT/044295374381/70879364     /JAMBUPRATHAPSAICHETH/DISBURSE', 'DISBURSED', 'NEW', 'POOJA', 'KISHAN KUMAR',
    '69,4TH CROSS HEMANTH NAGAR MARATHAHALLI HINDUSTAN SCHOOL MARATHAHALLI BANGALORE KARANATAKA 560037 69,4TH CROSS HEMANTH NAGAR MARATHAHALLI HINDUSTAN SCHOOL MARATHAHALLI BANGALORE KARANATAKA 560037  560037', 'SONATA SOFTWARE SONATA TOWERS, GLOBAL VILLAGE, RVCE POST, MYSORE RD, RV VIDYANIKETAN, MAILASANDRA, BENGALURU, KARNATAKA 560059 SONATA TOWERS, GLOBAL VILLAGE, RVCE POST, MYSORE RD, RV VIDYANIKETAN, MAILASANDRA, BENGALURU, KARNATAKA 560059  560059', 51, '31-60', 'May, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    7207, 'Telangana', 'Rangareddy', 'ADV00001248', 'HBPPS4522C', 'ACGLLLOT00000003648', 'SOLA KOTESWARA  RAO', 9059040248, 'KOTIYADAV905@GMAIL.COM',
    30000, 25500, 3814, 686, 4500, 686.44, 0, 0, 3813.56,
    25, 0.75, 35625, '2026-05-05', '2026-05-30', '''720401501309', 'ICICI BANK LTD8',
    'ICIC0007204', 'INF/INFT/044297746441/70892760     /SOLAKOTESWARARAO    /DISBURSE', 'DISBURSED', 'REPEAT', 'PAYAL SHARMA', 'KISHAN KUMAR',
    '17-26, PLOT NO - 527 FLAT NO -402 LAKSHMI RAMA APPARTMENT HMT SWARNAPURI COLONY MIYAPUR RELIANCE SMART BUILDING 500049', 'KYNDRYL SOLUTIONS PRIVATE LIMITED DIVYASREE NSL ORION, MADHURA NAGAR COLONY GACHIBOWLI, HYDERABAD MADHURA NAGAR COLONY 500032', 51, '31-60', 'May, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    7227, 'Tamil Nadu', 'Chennai', 'LOA00003595', 'BXQPR1613C', 'ACGLLLOT00000003663', 'IBUKUN SHEEBA ROGERS', 9789942417, 'SHEEBAROGERS89@GMAIL.COM',
    30000, 25500, 3814, 686, 4500, 686.44, 0, 0, 3813.56,
    24, 0.75, 35400, '2026-05-06', '2026-05-30', '''50100731817203', 'HDFC BANK LTD',
    'HDFC0005781', 'INF/NEFT/IN42612650300175/HDFC0005781/70933358 /                              /IBUKUNSHEEB', 'DISBURSED', 'NEW', 'DEEPAK KUMAR', 'KISHAN KUMAR',
    'T2, 3RD FLOOR, URODA 51 ARUSHAM DEVELOPMENTS NEW KUMARAN NAGAR 18TH CROSS ST SHOLINGANALLUR CH 600119  600118', 'DR.AGARWAL''S HEALTH CARE LIMITED 3783+73M, MOORES RD, THOUSAND LIGHTS WEST, THOUSAND LIGHTS, CHENNAI, TAMIL NADU 600006  600006', 51, '31-60', 'May, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    7234, 'Telangana', 'Hyderabad', 'LOA00003599', 'COKPP6759R', 'ACGLLLOT00000003671', 'POLISANI ARUN KUMAR', 9966473236, 'ARUN.0553@GMAIL.COM',
    40000, 34000, 5085, 915, 6000, 915.25, 0, 0, 5084.75,
    24, 0.75, 47200, '2026-05-06', '2026-05-30', '''146712010001681', 'UNION BANK OF INDIA',
    'UBIN0814679', 'INF/NEFT/IN42612650456751/UBIN0814679/70946884 /                              /POLISANIARU', 'DISBURSED', 'NEW', 'DEEPAK KUMAR', 'KISHAN KUMAR',
    'HIG-151/302, ANUSHA ORCHIDS, 5TH ROAD, KPHB COLONY, KUKATPALLY, HYDERABAD ,,HYDERABAD,TELANGANA-500085  500085', 'OVALEDGE INDIA PRIVATE LIMITED 307, OVALEDGE INDIA PRIVATE LIMITED, MANJEERA TRINITY MALL, JNU ROAD, KPHB COLONY, KUKATPALLY, HYDERABAD,HYDERABAD,TELANGANA-500071  500071', 51, '31-60', 'May, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    7244, 'Telangana', 'Hyderabad', 'LOA00003598', 'CQNPS9494K', 'ACGLLLOT00000003668', 'KORSAPATI SREEHARI BABU', 9381737009, 'KORSAPATISREEHARI@GMAIL.COM',
    40000, 34000, 5085, 915, 6000, 915.25, 0, 0, 5084.75,
    24, 0.75, 47200, '2026-05-06', '2026-05-30', '''50100070985516', 'HDFC BANK',
    'HDFC0000018', 'INF/NEFT/IN42612650456584/HDFC0000018/70946884 /                              /KORSAPATISR', 'DISBURSED', 'NEW', 'POOJA', 'KISHAN KUMAR',
    'FLAT NO: S2, 2-22-203, BHAVANI RESIDENCY,  JAYANAGAR ,KUKATPALLY, HYDERABAD, TELANGANA-500072 FLAT NO: S2, 2-22-203, BHAVANI RESIDENCY,  JAYANAGAR ,KUKATPALLY, HYDERABAD, TELANGANA-500072  500071', 'BLUMETRA SOLUTIONS INDIA PRIVATE LIMITED 2ND FLOOR, Q CITY, 109, WIPRO CIRCLE RD, BLOCK A, FINANCIAL DISTRICT, GACHIBOWLI, NANAKRAMGUDA, HYDERABAD, TELANGANA 500046  500045', 51, '31-60', 'May, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    7255, 'Maharashtra', 'Pune', 'LOA00003601', 'ATCPR4315G', 'ACGLLLOT00000003674', 'MANOJ  RATHOD', 8329694009, 'VICKYR6868@GMAIL.COM',
    40000, 34000, 5085, 915, 6000, 915.25, 0, 0, 5084.75,
    24, 0.75, 47200, '2026-05-06', '2026-05-30', '''105234595006', 'HSBC BANK',
    'HSBC0411002', 'INF/NEFT/IN42612650653435/HSBC0411002/70965630 /DISBURSE                      /MANOJRATHOD', 'DISBURSED', 'NEW', 'DEEPAK KUMAR', 'KISHAN KUMAR',
    'D-1011 SR NO 40//4 LOTUS LAXMI-2 VIKAS NAGAR KIWALE PUNE MAHARASHTRA 412101  412101', 'CAPGEMINI TECHNOLOGY SERVICES INDIA LIMITED CAPGEMINI PLOT NO. 14, RAJIV GANDHI INFOTECH PARK, MIDC SEZ, VILLAGE MAN, TALUKA MULSHI, HAVELI, HINJEWADI, PUNE, MAHARASHTRA 411057  411057', 51, '31-60', 'May, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    7275, 'Karnataka', 'Bangalore', 'LOA00003217', 'CDHPR5181F', 'ACGLLLOT00000003677', 'N TARUN KUMAR REDDY', 9901301656, 'TARUNREDDYN@GMAIL.COM',
    18000, 15300, 2288, 412, 2700, 411.86, 0, 0, 2288.14,
    31, 0.75, 22185, '2026-05-06', '2026-06-06', '''755001501512', 'ICICI BANK LTD',
    'ICIC0007550', 'INF/INFT/044313092601/70965630     /NTARUNKUMARREDDY    /DISBURSE', 'DISBURSED', 'REPEAT', 'RATNADEEP BIRADAR', 'KISHAN KUMAR',
    'NO3033RD FLOOR, SRI SRINIVASA NILAYAM PATEL LAYOUT VISHWAPRIYA NAGAR BEGUR B,23,BANGALORE,KARNATAKA 560068', 'INTELLIPAAT SOFTWARE SOLUTIONS PRIVATE LIMITED 6TH FLOOR PRIMECO TOWERS, AREKERE GATE JUNCTION BANNERGHATTA MAIN ROAD BNAGALORE 560076', 44, '31-60', 'May, 2026', 'PART-PAYMENT'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    7293, 'Tamil Nadu', 'Kanchipuram', 'LOA00003614', 'AHUPV5950H', 'ACGLLLOT00000003690', 'VINOTH  VASALA PRABHAKAR', 9790822881, 'VINO.DDUGKY@GMAIL.COM',
    35000, 29750, 4449, 801, 5250, 800.85, 0, 0, 4449.15,
    23, 0.75, 41037.5, '2026-05-07', '2026-05-30', '''3311997991', 'KOTAK MAHINDRA BANK LIMITED',
    'KKBK0000468', 'INF/NEFT/IN42612751596790/KKBK0000468/71017901 /                              /VINOTHVASAL', 'DISBURSED', 'NEW', 'PAYAL NAINWAL', 'KISHAN KUMAR',
    'A5/1ST BLOCK/1ST FLOOR PANCHAYAT MAIN RD, PERUNGUDI, CHENNAI, TAMIL NADU 600096,  600096', 'VS-VDP-HO NO:1, JAWAHARLAL NEHRU SALAI, VADAPALANI , CHENNAI-600026  600026', 51, '31-60', 'May, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    7316, 'Karnataka', 'Bangalore', 'LOA00003632', 'ALIPA3113F', 'ACGLLLOT00000003712', 'SAKET  AMBER', 9711502409, 'AMBERSAKET@GMAIL.COM',
    45000, 38250, 5720, 1030, 6750, 1029.66, 0, 0, 5720.34,
    22, 0.75, 52425, '2026-05-08', '2026-05-30', '''04851140118468', 'HDFC BANK',
    'HDFC0000485', 'INF/NEFT/IN42612853455863/HDFC0000485/71142734 /DISBURSE                      /SAKETAMBER', 'DISBURSED', 'NEW', 'DEEPAK KUMAR', 'KISHAN KUMAR',
    '307 3RD FLOOR KRYSTAM CAMPUS 10 QUARTZ SARJAPUR ROAD NEAR YEMELE BUS STOP BANGALORE KARNATAKA 562125  562125', 'J P MORGAN SERVICES INDIA PRIVATE LIMITED EMBASSY TECH VILLAGE MARATHAHALLI NEAR WELLS FARGO BENGALURU 560087  560087', 51, '31-60', 'May, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    7347, 'Karnataka', 'Bangalore', 'LOA00003629', 'BLMPP4832R', 'ACGLLLOT00000003708', 'PALLAVI  V', 9686418880, 'PALLAVIJAY23@YAHOO.COM',
    18000, 15300, 2288, 412, 2700, 411.86, 0, 0, 2288.14,
    31, 0.75, 22185, '2026-05-08', '2026-06-08', '''309029411797', 'RATNAKAR BANK LIMITED',
    'RATN0000156', 'INF/NEFT/IN42612853293877/RATN0000156/71128011 /DISBURSE                      /PALLAVIV', 'DISBURSED', 'NEW', 'GARISHMA', 'KISHAN KUMAR',
    'NO.32,5/2, EAST END D MAIN ROAD, 9TH BLOCK, BENGALURU, KAR -560069 NO.32,5/2, EAST END D MAIN ROAD, 9TH BLOCK, BENGALURU, KAR -560069  560069', 'ORIENT SPECTRA CONSULTING PRIVATE LIMITED PRESTIGE MERIDIAN 2 10TH FLOOR M.G.ROAD BANGALORE 560001 PRESTIGE MERIDIAN 2 10TH FLOOR M.G.ROAD BANGALORE 560001  560001', 42, '31-60', 'May, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    7354, 'Gujarat', 'Ahmedabad', 'LOA00003195', 'BCPPP0935D', 'ACGLLLOT00000003702', 'BHAUMIK DHARMENDRABHAI PATEL', 9429907555, 'BHAUMIK2599@GMAIL.COM',
    20000, 17000, 2542, 458, 3000, 457.63, 0, 0, 2542.37,
    31, 0.75, 24650, '2026-05-08', '2026-06-08', '''018901540184', 'ICICI BANK LIMITED',
    'ICIC0000189', 'INF/INFT/044344108781/71098649     /BHAUMIKDHARMENDRABHA/DISBURSE', 'DISBURSED', 'REPEAT', 'POOJA', NULL,
    '62 SHIVRANJANI C H SOC LTD B/H PARAS KUNJ OPP JAY SHEFALI SOC 380015', 'SAHYADRI INDUSTRIES LIMITED SWASTIK HOUSE, 39 D, GULTEKDI, JAWAHARLAL NEHRU MARG, PUNE 411037  411037', 42, '31-60', 'May, 2026', 'PART-PAYMENT'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    7381, 'Telangana', 'Hyderabad', 'LOA00003636', 'BSYPV5574M', 'ACGLLLOT00000003716', 'RYAKALA VISHNUKANTH  REDDY', 9542343175, 'VISHNUKANTHR1@GMAIL.COM',
    50000, 42500, 6356, 1144, 7500, 1144.07, 0, 0, 6355.93,
    22, 0.75, 58250, '2026-05-08', '2026-05-30', '''176901507702', 'ICICI BANK LTD',
    'ICIC0001769', 'INF/INFT/044352929201/71146540     /RYAKALAVISHNUKANTHRE/DISBURSE', 'DISBURSED', 'NEW', 'DEEPAK KUMAR', 'KISHAN KUMAR',
    '41& 42/PART,FLAT NO 402, SADHAN SADAN APARTMENTS, KUNDAN NAGAR COLONY,NEKNAMPUR, PUPPALGUDA ,RANGAREDDY DIST,TELANGANA, 500089  500089', 'AMERICAN AIRLINES SERVICES INDIA LLP RMZ NEXITY TOWER, HITEC CITY, HYDERABAD, 500081  500081', 51, '31-60', 'May, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    7288, 'Maharashtra', 'Pune', 'LOA00003637', 'AJRPC3213F', 'ACGLLLOT00000003720', 'SANTOSH MANOHAR CHALWAD', 7666016994, 'SKSANTOSHREDDY@GMAIL.COM',
    50000, 42500, 6356, 1144, 7500, 1144.07, 0, 0, 6355.93,
    23, 0.75, 58625, '2026-05-09', '2026-06-01', '''196701517878', 'ICICI BANK LIMITED',
    'ICIC0001967', 'INF/INFT/044358912191/71175029     /SANTOSHMANOHARCHALWA/DISBURSE', 'DISBURSED', 'NEW', 'POOJA', 'KISHAN KUMAR',
    'MEDIA PARK B.T.KAWADE RDBL-B SN-66B/2 GHORPADIGAON PUNE 411001 MEDIA PARK B.T.KAWADE RDBL-B SN-66B/2 GHORPADIGAON PUNE 411001  411001', 'QUANTUM LEAP CONSULTING PVT. LTD BAGMANE CAPITAL, 6TH FLOOR, LUXOR SOUTH BLOCK, ASHRAYA LAYOUT, GARUDACHAR PALYA, MAHADEVAPURA, BENGALURU, KARNATAKA 560048 BAGMANE CAPITAL, 6TH FLOOR, LUXOR SOUTH BLOCK, ASHRAYA LAYOUT, GARUDACHAR PALYA, MAHADEVAPURA, BENGALURU, KARNATAKA 560048  560048', 49, '31-60', 'May, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    7318, 'Karnataka', 'Bangalore', 'LOA00003646', 'CVBPP4936J', 'ACGLLLOT00000003730', 'MANISH  PRAKASH', 7787051611, 'MANISHPRAKASH7787@GMAIL.COM',
    50000, 42500, 6356, 1144, 7500, 1144.07, 0, 0, 6355.93,
    21, 0.75, 57875, '2026-05-09', '2026-05-30', '''924010007236736', 'AXIS BANK',
    'UTIB0004643', 'INF/NEFT/IN42612954578164/UTIB0004643/71198492 /DISBURSE                      /MANISHPRAKA', 'DISBURSED', 'NEW', 'DEEPAK KUMAR', 'KISHAN KUMAR',
    'L-2431,PARADISE-BRIGADE CORNERSTONE UTOPIA,VARTHUR GUNJUR MAIN ROAD ,VARTHUR GUNJUR MAIN ROAD BENGALURU - 560545  560300', 'VEARC TECHNOLOGIES PRIVATE LIMITED D, 4TH FLOOR, HELIOS BUSINESS PARK WING, 150, OUTER RING RD, HOBLI, KADUBEESANAHALLI, VARTHUR, BENGALURU, KARNATAKA 560103  560103', 51, '31-60', 'May, 2026', 'PART-PAYMENT'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    7350, 'Tamil Nadu', 'Kanchipuram', 'LOA00003631', 'CITPB6842G', 'ACGLLLOT00000003710', 'BATTEPATI GOHITH KUMAR REDDY', 7259953431, 'GOHITH.BATTEPATI@GMAIL.COM',
    40000, 34000, 5085, 915, 6000, 915.25, 0, 0, 5084.75,
    22, 0.75, 46600, '2026-05-09', '2026-05-30', '''50100380413989', 'HDFC BANK',
    'HDFC0000157', 'INF/NEFT/IN42612853293865/HDFC0000157/71128011 /DISBURSE                      /BATTEPATIGO', 'DISBURSED', 'NEW', 'GARISHMA', 'KISHAN KUMAR',
    'SHAPHIRE-1 1J, OPPOSITE TO VIVIRA MALL, OLYMPIA OPALINE MALACHITE OLYMPIA OPALINE, NAVALUR, CHENGALPATTU, CHENNAI, 600130 SHAPHIRE-1 1J, OPPOSITE TO VIVIRA MALL, OLYMPIA OPALINE MALACHITE OLYMPIA OPALINE, NAVALUR, CHENGALPATTU, CHENNAI, 600130  600130', 'HCL TECHNOLOGIES LTD SPECIAL ECONOMIC ZONE 33, ETA TECHNO PARK, RAJIV GANDHI SALAI, NAVALUR, TAMIL NADU 600130 SPECIAL ECONOMIC ZONE 33, ETA TECHNO PARK, RAJIV GANDHI SALAI, NAVALUR, TAMIL NADU 600130  600130', 51, '31-60', 'May, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    7402, 'Haryana', 'Faridabad', 'LOA00003643', 'COQPK8562K', 'ACGLLLOT00000003727', 'SAURABH  KOHLI', 9509757279, 'KOHLISAURABH08@GMAIL.COM',
    20000, 17000, 2542, 458, 3000, 457.63, 0, 0, 2542.37,
    24, 0.75, 23600, '2026-05-09', '2026-06-02', '''10202325288', 'IDFC FIRST BANK LTD',
    'IDFB0021313', 'INF/NEFT/IN42612954461718/IDFB0021313/71190086 /DISBURSE                      /SAURABHKOHL', 'DISBURSED', 'NEW', 'SHIVANI JOSHI', 'KISHAN KUMAR',
    'HOUSE  NO 1072 SECTOR 9  FARIDABAD FIRST FLOOR NEAR ST ANTHONY SCHOOL 121006  121006', 'FNP WEDDINGS & EVENTS INDIA PRIVATE LIMITE FERNS N PETALS ESTATE  ASHRAM MARG SULATANPUR FARMS  CHAHHATPUR 110030  110030', 48, '31-60', 'May, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    7324, 'Maharashtra', 'Thane', 'LOA00003659', 'DPOPS4598D', 'ACGLLLOT00000003747', 'MOHIT NANHE SINGH', 7208566903, 'SINGH.MOHIT137@GMAIL.COM',
    25000, 21250, 3178, 572, 3750, 572.03, 0, 0, 3177.97,
    22, 0.75, 29125, '2026-05-11', '2026-06-02', '''50100733176553', 'HDFC BANK',
    'HDFC0000321', 'INF/NEFT/IN42613156711393/HDFC0000321/71285953 /DISBURSE                      /MOHITNANHES', 'DISBURSED', 'NEW', 'HIMANI SINGH', 'KISHAN KUMAR',
    'D205, OM SAI HEIGHTS 2 YASHWANT GAURAV NILEMORE NALASOPARA WEST 401203  401203', 'KINNECT MEDIA PVT LTD A WING MARATHON FUTUREX MAFTLAL CHAMBER LOWER PAREL EAST - 401203  401203', 48, '31-60', 'May, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    7458, 'Haryana', 'Gurgaon', 'LOA00002667', 'ALXPB1478M', 'ACGLLLOT00000003742', 'RATAN  BHATIA', 9810307044, 'RATANBHATIA33@GMAIL.COM',
    55000, 46750, 6992, 1258, 8250, 1258.47, 0, 0, 6991.53,
    31, 0.75, 67787.5, '2026-05-11', '2026-06-11', '''4849000100014232', 'PUNJAB NATIONAL BANK',
    'PUNB0484900', 'INF/NEFT/IN42613156502283/PUNB0484900/71269938 /DISBURSE                      /RATANBHATIA', 'DISBURSED', 'REPEAT', 'DEEPAK KUMAR', 'KISHAN KUMAR',
    '1062 SECTOR 23A GURGAON NEAR NORTHCAP UNIVERSITY 1062 SECTOR 23A GURGAON NEAR NORTHCAP UNIVERSITY  122017', 'VICTORIOUS INDUSTRIES PVT. LTD PLOT NO.68 UDYOG VIHAR PHASE IV GURGAON PLOT NO.68 UDYOG VIHAR PHASE IV GURGAON  122001', 39, '31-60', 'May, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    7472, 'Karnataka', 'Bangalore', 'LOA00003227', 'AKXPD1308D', 'ACGLLLOT00000003751', 'DILIP  NINGILERI', 8296851864, 'N.DILIP25@GMAIL.COM',
    16000, 13600, 2034, 366, 2400, 366.1, 0, 0, 2033.9,
    32, 0.75, 19840, '2026-05-11', '2026-06-12', '''31930100014197', 'BANK OF BARODA',
    'BARB0MARTHA', 'INF/NEFT/IN42613156838063/BARB0MARTHA/71297098 /DISBURSE                      /DILIPNINGIL', 'DISBURSED', 'REPEAT', 'POOJA', NULL,
    '176/3, MANJUNATHA LAYOUT, MARATHAHALLI VILLAGE, MARATHAHALLI, BENGALURU, KARNATAKA 560037, 176/3, MANJUNATHA LAYOUT, MARATHAHALLI VILLAGE, MARATHAHALLI, BENGALURU, KARNATAKA 560037,  560037', 'PRUTHVI PROJECT ZEAL SQUARE 4TH FLOOR HSR LAYOUT  BANGALORE 560102 ZEAL SQUARE 4TH FLOOR HSR LAYOUT  BANGALORE 560102  560102', 38, '31-60', 'May, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    7489, 'Maharashtra', 'Pune', 'LOA00003669', 'AKMPC6313Q', 'ACGLLLOT00000003761', 'TAMAL  CHATTERJEE', 9874227722, 'TAMAL.CHATERJE@GMAIL.COM',
    45000, 38250, 5720, 1030, 6750, 1029.66, 0, 0, 5720.34,
    44, 0.75, 59850, '2026-05-12', '2026-06-25', '''00081020005443', 'HDFC BANK',
    'HDFC0000008', 'INF/NEFT/IN42613257575865/HDFC0000008/71353213 /                              /TAMALCHATTE', 'DISBURSED', 'NEW', 'DEEPAK KUMAR', 'KISHAN KUMAR',
    'B-1003, DHANASHREE ANAND 2, HANDEWADI, PUNE, MAHARASHTRA, PIN - 412308  412308', 'MASTERCARD TECHNOLOGY PRIVATE LIMITED BLUE GRASS BUSINESS PARK, PUNE NAGAR RD, KALYANI NAGAR, PUNE, MAHARASHTRA, PIN - 411006  411006', 25, '0-30', 'May, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    7498, 'Tamil Nadu', 'Chennai', 'LOA00003670', 'CZDPP8416K', 'ACGLLLOT00000003762', 'SHIRANJEEVI  PANDIYAN', 8951030501, 'ASHIRANJ7@GMAIL.COM',
    40000, 34000, 5085, 915, 6000, 915.25, 0, 0, 5084.75,
    43, 0.75, 52900, '2026-05-12', '2026-06-24', '''37481164706', 'STATE BANK OF INDIA',
    'SBIN0003870', 'INF/NEFT/IN42613257575881/SBIN0003870/71353213 /                              /SHIRANJEEVI', 'DISBURSED', 'NEW', 'DEEPAK KUMAR', 'KISHAN KUMAR',
    'SWARG APARTMENR S3 SECOND FLOOR SRI KRISHNA NAGAR KATTUPAKKAM 600056  600042', 'BARCLAYS GLOBAL SERVICE CENTRE PRIVATE LIMITED BLOCK 8 DLF IT.PARK. RAMAPURAM CHENNAI 600085  600085', 26, '0-30', 'May, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    7504, 'Telangana', 'Hyderabad', 'LOA00003674', 'APTPP2723D', 'ACGLLLOT00000003767', 'PARNANDI RAVINDER KUMAR', 9390566600, 'KARAMPRK23@GMAIL.COM',
    45000, 38250, 5720, 1030, 6750, 1029.66, 0, 0, 5720.34,
    21, 0.75, 52087.5, '2026-05-12', '2026-06-02', '''50100450897921', 'HDFC BANK LTD',
    'HDFC0005176', 'INF/NEFT/IN42613257809421/HDFC0005176/71376299 /                              /PARNANDIRAV', 'DISBURSED', 'NEW', 'POOJA', 'KISHAN KUMAR',
    'H NO 2-3-734/B/17 6 NUMBER ROAD SHANKAR NAAGAR AMBERPET 500013 H NO 2-3-734/B/17 6 NUMBER ROAD SHANKAR NAAGAR AMBERPET 500013  500013', 'KARAM SAFETY PVT LTD T19 TOWERS 9TH FLOOR RANIGUNJ SECUNDERABAD 500003. T19 TOWERS 9TH FLOOR RANIGUNJ SECUNDERABAD 500003.  500003', 48, '31-60', 'May, 2026', 'PART-PAYMENT'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    7511, 'Telangana', 'Rangareddy', 'LOA00003673', 'COYPP0655N', 'ACGLLLOT00000003766', 'PALPUNOORI SANTOSH REDDY', 9177564530, 'SANTOSHPALPUNURI@GMAIL.CON',
    60000, 51000, 7627, 1373, 9000, 1372.88, 0, 0, 7627.12,
    18, 0.75, 68100, '2026-05-12', '2026-05-30', '''911010025836402', 'AXIS BANK',
    'UTIB0000027', 'INF/NEFT/IN42613257809413/UTIB0000027/71376299 /                              /PALPUNOORIS', 'DISBURSED', 'NEW', 'PAYAL SHARMA', 'KISHAN KUMAR',
    'FLAT 506 CREATIVE ABORD APTS MASID BANDA NR TO SBI BANK HYDERABAD,TELANGANA MASID BANDA 500084', 'SPAI TECH PRIVATE LIMITED 302, SRI VISHNU SADAN, KONDAPUR, SERILINGAMPALLY KONDAPUR, SERILINGAMPALLY K V RANGAREDDY SRI VISHNU SADAN 500084', 51, '31-60', 'May, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    7525, 'Tamil Nadu', 'Chennai', 'LOA00003684', 'ACRPO2243G', 'ACGLLLOT00000003780', 'JOSEPH  OLIVERO', 9003270083, 'JOSEPHOLIVERO@GMAIL.COM',
    50000, 42500, 6356, 1144, 7500, 1144.07, 0, 0, 6355.93,
    19, 0.75, 57125, '2026-05-13', '2026-06-01', '''20200079865511', 'BANDHAN BANK LIMITED',
    'BDBL0002228', 'INF/NEFT/IN426133583 96524/BDBL0002228/71 419529 /DISBURSE /J OSEPHOLIVE', 'DISBURSED', 'NEW', 'DEEPAK KUMAR', 'KISHAN KUMAR',
    'B4/6 RUBYLANDMARK, ORGADAM HIGHWAY MANIVAKKAM CHENNAI 600048  600042', 'PROJX SOLUTIONS SRIPERUMBUDUR - ORAGADOM ROAD, NORTH, ORAGADAM INDUSTRIAL CORRIDOR, SIPCOT, CHENNAI,TAMIL NADU 602105, INDIA  602105', 49, '31-60', 'May, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    7544, 'West Bengal', 'Kolkata', 'LOA00003690', 'ALQPD3694Q', 'ACGLLLOT00000003788', 'RHITAM  DAS', 8017609891, 'RHITAM.DAS@GMAIL.COM',
    25000, 21250, 3178, 572, 3750, 572.03, 0, 0, 3177.97,
    19, 0.75, 28562.5, '2026-05-13', '2026-06-01', '''50100221842526', 'HDFC BANK',
    'HDFC0000008', 'INF/NEFT/IN42613358638377/HDFC0000008/71444669 /DISBURSE                      /RHITAMDAS', 'DISBURSED', 'NEW', 'HIMANI SINGH', 'KISHAN KUMAR',
    '108, ASHOK GARH FLAT 4 LP 101/21 KOLKATA 700 035  700035', 'APEEJAY INFRA LOGISTICS PVT LTD 15 PARK STREET, PARK HOTEL, KOLKATA 700016  700016', 49, '31-60', 'May, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    7563, 'Karnataka', 'Bangalore', 'LOA00003692', 'AKZPV9162B', 'ACGLLLOT00000003790', 'VASU  V', 8971323411, 'VASUV34@GMAIL.COM',
    20000, 17000, 2542, 458, 3000, 457.63, 0, 0, 2542.37,
    16, 0.75, 22400, '2026-05-14', '2026-05-30', '''055201554541', 'ICICI BANK LIMITED',
    'ICIC0000552', 'INF/INFT/044420167471/71463849     /VASUV/DISBURSE', 'DISBURSED', 'NEW', 'DEEPAK KUMAR', 'KISHAN KUMAR',
    '3 2ND CROSS UTTARAHALLI BANGALORE 560061 LANDMARK AISHWARYA BAR AND RESTAURANT 560061', 'INFOSYS BPM LIMITED ELECTRONIC CITY HOSUR ROAD BANGALORE 560100  560100', 51, '31-60', 'May, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    7584, 'Karnataka', 'Bangalore', 'LOA00003698', 'ANKPT9816C', 'ACGLLLOT00000003798', 'TEPPA  NAGARAJU', 9811649044, 'TEPPANAGARAJ@GMAIL.COM',
    35000, 29750, 4449, 801, 5250, 800.85, 0, 0, 4449.15,
    16, 0.75, 39200, '2026-05-14', '2026-05-30', '''482101501790', 'ICICI BANK LTD',
    'ICIC0004821', 'INF/INFT/044421537551/71471355     /TEPPANAGARAJU/', 'DISBURSED', 'NEW', 'HIMANI SINGH', 'KISHAN KUMAR',
    'GROUND FLOOR 22 GROUND FLOOR 22,TUNGABHADRA BLOCK - B3 KORAMAGALA NGV 560047 BANGALORE EAST BANGALORE KARNATAKA  560047', 'ACCENTURE SOLUTIONS PVT LTD PRESTIGE RMZ STARTECH KORAMANGALA INDUSTRIAL LAYOUT BANGALORE  560095', 51, '31-60', 'May, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    7592, 'Maharashtra', 'Pune', 'LOA00003701', 'BOPPS4147N', 'ACGLLLOT00000003801', 'PRACHEE JAYWANT SABE', 9011313279, 'PRACHISABE@GMAIL.COM',
    50000, 42500, 6356, 1144, 7500, 1144.07, 0, 0, 6355.93,
    16, 0.75, 56000, '2026-05-14', '2026-05-30', '''10175147382', 'IDFC FIRST BANK LTD',
    'IDFB0041434', 'INF/NEFT/IN42613459231384/IDFB0041434/71491835 /                              /PRACHEEJAYW', 'DISBURSED', 'NEW', 'HIMANI SINGH', 'KISHAN KUMAR',
    'FLAT NO. 1103; BUILDING-C1G; SOCIETY- BROOKLYNPRIDE WORLD CITY 412105  412105', 'VODAFONE INDIA SERVICES PVT LTD 201-206, SHIV SMRITI, 2ND FLOOR, 49/A, DR. ANNIE BESANT ROAD, ABOVE CORPORATION BANK, WORLI, MUMBAI, MAHARASHTRA - 400018  411018', 51, '31-60', 'May, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    7603, 'Uttar Pradesh', 'Noida', 'LOA00003710', 'AQXPK3317K', 'ACGLLLOT00000003810', 'RAVI  KUMAR', 9911878760, 'RAVIKUMAR.MCA2006@GMAIL.COM',
    25000, 21250, 3178, 572, 3750, 572.03, 0, 0, 3177.97,
    16, 0.75, 28000, '2026-05-14', '2026-05-30', '''159911878760', 'INDUSIND BANK',
    'INDB0000276', 'INF/NEFT/IN42613459381410/INDB0000276/71508627 /DISBURSE                      /RAVIKUMAR', 'DISBURSED', 'NEW', 'DEEPAK KUMAR', 'KISHAN KUMAR',
    'G604 PAN OASIS SECTOR 70 NOIDA 201301  201301', 'HCL TECHNOLOGIES LTD. TOWER 5 FLOOR 6TH ODC 2 , NOIDA SECTOR 126 201307  201307', 51, '31-60', 'May, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    7613, 'Karnataka', 'Bangalore', 'LOA00003709', 'FCAPS2129R', 'ACGLLLOT00000003809', 'SHAIK  NAWAZ', 8885336578, 'NAWZ.AFN@GMAIL.COM',
    35000, 29750, 4449, 801, 5250, 800.85, 0, 0, 4449.15,
    16, 0.75, 39200, '2026-05-14', '2026-05-30', '''0210010000669', 'CATHOLIC SYRIAN BANK LIMITED',
    'CSBK0000210', 'INF/NEFT/IN42613459381416/CSBK0000210/71508627 /DISBURSE                      /SHAIKNAWAZ', 'DISBURSED', 'NEW', 'PAYAL SHARMA', 'KISHAN KUMAR',
    'VENKATA LAKSHMI NIVAS 146  3RD FLOOR 7TH CROSS ROAD NEAR ANJANEYA SWAMY TEMPLE KALAMANDIR ANAND NAGARASWATH NAGARMARTHALLI BENGALURU NEAR ANJANEYA SWAMY TEMPLE 560037', 'ALEGEUS TECHNOLOGIES INDIA PRIVATE LIMITED 3RD FLOOR,BUILDING-1, PRESTIGE TECHNOSTAR DODDANAKUNDI INDUSTRIAL AREA 2 BENGALURU SATVA BUILDING 560048', 51, '31-60', 'May, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    7624, 'Maharashtra', 'Pune', 'LOA00003719', 'BGZPM1878C', 'ACGLLLOT00000003820', 'KAMLESH RAGHUNATH MHATRE', 7208792204, 'KAMLESHRMHATRE@GMAIL.COM',
    50000, 43750, 5297, 953, 6250, 953.39, 0, 0, 5296.61,
    17, 0.75, 56375, '2026-05-15', '2026-06-01', '''918010002025154', 'AXIS BANK',
    'UTIB0000173', 'INF/NEFT/IN42613559929278/UTIB0000173/71557377 /DISBURSE                      /KAMLESHRAGH', 'DISBURSED', 'NEW', 'HIMANI SINGH', 'KISHAN KUMAR',
    'ALTIS 1905, MARATHON NEXZONE,JNPT ROAD,PALASPA 410206  142207', 'JIO PLATFORMS LIMITED RCP, TWIN TOWER,18 FLOOR , GHANSOLI 400701  400824', 49, '31-60', 'May, 2026', 'PART-PAYMENT'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    7707, 'Maharashtra', 'Pune', 'LOA00003148', 'HFBPS0157D', 'ACGLLLOT00000003843', 'ARKA  SENGUPTA', 8637846638, 'ARS2447@GMAIL.COM',
    12000, 10200, 1525, 275, 1800, 274.58, 0, 0, 1525.42,
    31, 0.75, 14790, '2026-05-16', '2026-06-16', '''917010037810933', 'AXIS BANK',
    'UTIB0000073', 'INF/NEFT/IN42613650754623/UTIB0000073/71633593 /                              /ARKASENGUPT', 'DISBURSED', 'REPEAT', 'GARISHMA', NULL,
    'GET NO 296 BHADORIA NIVAS SAMBHAJI NAGAR,11/120,SAMBHAJIC NAGAR, NAGESHWAR N AGAR, BORADE WADI, MOSHI, PIMPRI-,NEAR BORHADEWADI VILLAGE MOSHI,PUNE,MAHAR ASHTRA,412105, PUNE, MAHARASHTRA, 412105 412105', 'DHANSHREE ENTERPRISES PLOT NO 16, CHAKAN MIDC PHASE 3, KURULI, CHAKAN, PUNE, MAHARASHTRA - 410501  410501', 34, '31-60', 'May, 2026', 'PART-PAYMENT'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    7602, 'Maharashtra', 'Raigarh', 'LOA00003742', 'ATSPJ5707E', 'ACGLLLOT00000003849', 'SUNIL BANDU JAGTAP', 9665272852, 'SUNIL.JAGTAP76@GMAIL.COM',
    15000, 12750, 1907, 343, 2250, 343.22, 0, 0, 1906.78,
    44, 0.75, 19950, '2026-05-18', '2026-07-01', '''50100147910381', 'HDFC BANK',
    'HDFC0000001', 'INF/NEFT/IN42613851407925/HDFC0000001/71663203 /                              /SUNILBANDUJ', 'DISBURSED', 'NEW', 'POOJA', 'KISHAN KUMAR',
    'FLATE NO 102 PLOT NO 19 SEC 26 TALOJA PHASE 2 TO PANVEL 410208 FLATE NO 102 PLOT NO 19 SEC 26 TALOJA PHASE 2 TO PANVEL 410208  402208', 'STERLING GREEN POWER SOLUTIONS PRIVATE LIMITED UNIVERSAL MAJESTIC BUILDING, 10TH FLOOR, P L LOKHANDE MARG, CHEMBUR MUMBAI MAHARASHTRA INDIA 400043 UNIVERSAL MAJESTIC BUILDING, 10TH FLOOR, P L LOKHANDE MARG, CHEMBUR MUMBAI MAHARASHTRA INDIA 400043  400043', 19, '0-30', 'May, 2026', 'PART-PAYMENT'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    7653, 'Tamil Nadu', 'Chennai', 'LOA00003744', 'AWXPP3404C', 'ACGLLLOT00000003851', 'JEYAKUMAR PAUL EZRA', 7708240011, 'DJSRA8@GMAIL.COM',
    50000, 42500, 6356, 1144, 7500, 1144.07, 0, 0, 6355.93,
    43, 0.75, 66125, '2026-05-18', '2026-06-30', '''19391140004912', 'HDFC BANK',
    'HDFC0001939', 'INF/NEFT/IN42613851501712/HDFC0001939/71672493 /                              /JEYAKUMARPA', 'DISBURSED', 'NEW', 'HIMANI SINGH', 'KISHAN KUMAR',
    'NO.49/3,M A GARDEN PILLAYAR KOIL STREET, NEAR AXIS BANK ATM,TEYNAMPET,CHENN AI,CHENNAI,TAMIL NADU,600018 CHENNAI TAMIL NADU, 600018  600018', 'INFONOVUM TECHNOLOGIES PRIVATE LIMITED ADD: 7 SRIMAN SRINIVASA ROAD, ALWARPET, CHENNAI 600018  600018', 20, '0-30', 'May, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    7718, 'Maharashtra', 'Pune', 'LOA00003749', 'BDOPN0615E', 'ACGLLLOT00000003856', 'SAMRUDHA SATISH NAPHADE', 8237737544, 'SAMRUDHAROCKS@GMAIL.COM',
    30000, 25500, 3814, 686, 4500, 686.44, 0, 0, 3813.56,
    43, 0.75, 39675, '2026-05-18', '2026-06-30', '''04670100016187', 'BANK OF BARODA',
    'BARB0MANNAG', 'INF/NEFT/IN42613851606730/BARB0MANNAG/71684505 /                              /SAMRUDHASAT', 'DISBURSED', 'NEW', 'HIMANI SINGH', 'KISHAN KUMAR',
    'KRISTAL28 FLAT NO.102 MADHUBAN COLONY, WAKAD ROAD,PUNE,MAHARASHTRA,411027  411027', 'FIS SOLUTIONS (INDIA) PRIVATE LIMITED ONE 169, 1, SANGVI KESRI ROAD, HARMONY SOCIETY, WARD NO. 8, WIRELESS COLONY, AUNDH, PUNE, MAHARASHTRA 411067  411062', 20, '0-30', 'May, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    7755, 'Maharashtra', 'Mumbai', 'LOA00003759', 'FITPK5242J', 'ACGLLLOT00000003866', 'ANAND  KUMAR', 7455090943, 'ANANDKUMAR1992232@GMAIL.COM',
    30000, 25500, 3814, 686, 4500, 686.44, 0, 0, 3813.56,
    12, 0.75, 32700, '2026-05-18', '2026-05-30', '''6149829762', 'KOTAK MAHINDRA BANK',
    'KKBK0005321', 'INF/NEFT/IN42613851739840/KKBK0005321/71699339 /DISBURSE                      /ANANDKUMAR', 'DISBURSED', 'NEW', 'GARISHMA', 'KISHAN KUMAR',
    'B402,SHUBHAM HEIGHTS,NICOLAS WADI RD, VERMA NAGAR, JIJAMATA COLONY,    ANDHERI EAST, MUMBAI, MAHARASHTRA 400069 B402,SHUBHAM HEIGHTS,NICOLAS WADI RD, VERMA NAGAR, JIJAMATA COLONY,    ANDHERI EAST, MUMBAI, MAHARASHTRA 400069  400069', 'EASTWELL INDUSTRIES PRIVATE LIMITED OPPOSITE WATER SUPPLY QUARTERS, O.T., ULHASNAGAR, THANE-421003, MAHARASHTRA, INDIA OPPOSITE WATER SUPPLY QUARTERS, O.T., ULHASNAGAR, THANE-421003, MAHARASHTRA, INDIA  421003', 51, '31-60', 'May, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    7664, 'Maharashtra', 'Pune', 'LOA00003761', 'IQYPS6132K', 'ACGLLLOT00000003868', 'SURVASE KRISHNA MADHAVRAO', 7507582341, 'KRISHSURWASE123@GMAIL.COM',
    15000, 12750, 1907, 343, 2250, 343.22, 0, 0, 1906.78,
    42, 0.75, 19725, '2026-05-19', '2026-06-30', '''500101014369197', 'CITY UNION BANK LIMITED',
    'CIUB0000111', 'INF/NEFT/IN42613952288455/CIUB0000111/71755581 /DISBURSE                      /SURVASEKRIS', 'DISBURSED', 'NEW', 'HIMANI SINGH', 'KISHAN KUMAR',
    '173; NANA PETH FL NO-3 SACHEE ENCLAVE 411002  411002', 'CITY UNION BANK LIMITED 1ST FLOWER BHOSALE COMPLEX GADITAL HADAPSAR PUNE 411028  411028', 20, '0-30', 'May, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    7696, 'Telangana', 'Hyderabad', 'LOA00003755', 'AIRPN6336M', 'ACGLLLOT00000003862', 'NELLUTLA ARUN KUMAR', 9392223558, 'ARUN.UNIQUE888@GMAIL.COM',
    35000, 29750, 4449, 801, 5250, 800.85, 0, 0, 4449.15,
    12, 0.75, 38150, '2026-05-19', '2026-05-30', '''1433172000009136', 'KARUR VYSYA BANK',
    'KVBL0001466', 'INF/NEFT/IN42613951956297/KVBL0001466/71714402 /                              /NELLUTLAARU', 'DISBURSED', 'NEW', 'GARISHMA', 'KISHAN KUMAR',
    '502,MYTHRI BLOCK B HARITAVANAM COLONY  NIJMAPET RANGAREDDY TELANGANA- 500090  500090', 'SAGILITY LIMITED 3RD FLOOR, WING-B, PURVA SUMMIT, SURVEY NO-08, KONDAPUR VILLAGE HYDERABAD TELAGANA- 500084  500085', 51, '31-60', 'May, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    7764, 'Karnataka', 'Bangalore', 'LOA00003765', 'AGKPH7088P', 'ACGLLLOT00000003873', 'ERUVARAM HEMA CHANDRA', 9000076282, 'HEMARISES@GMAIL.COM',
    50000, 42500, 6356, 1144, 7500, 1144.07, 0, 0, 6355.93,
    42, 0.75, 65750, '2026-05-19', '2026-06-30', '''912010008379354', 'AXIS BANK',
    'UTIB0000008', 'INF/NEFT/IN42613952144971/UTIB0000008/71736517 /                              /ERUVARAMHEM', 'DISBURSED', 'NEW', 'DEEPAK KUMAR', 'KISHAN KUMAR',
    'HOUSE NO 3-A,2ND FLOOR,  SURVEY NO.46/2,SITE NO-21, 3RD MAIN, VINAYAKA LAYOUT, BHATTARHALLI ,BANGLORE-560049  560049', 'MAHINDRA AROSPACE 251(P), 252 TO 264, 265(P), NARASAPURA INDUSTRIAL AREA, KOLAR, KARNATAKA 563133  563133', 20, '0-30', 'May, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    7765, 'Tamil Nadu', 'Chennai', 'LOA00003763', 'BLTPT3476L', 'ACGLLLOT00000003871', 'THULASI  RAMAN', 8667592066, 'TEEJAYCHAM1@GMAIL.COM',
    20000, 17000, 2542, 458, 3000, 457.63, 0, 0, 2542.37,
    37, 0.75, 25550, '2026-05-19', '2026-06-25', '''058001517135', 'ICICI BANK LIMITED',
    'ICIC0000580', 'INF/INFT/044474365531/71736517     /THULASIRAMAN/', 'DISBURSED', 'NEW', 'DEEPAK KUMAR', 'KISHAN KUMAR',
    'FLAT NO-96 BLOCK-D 7TH FLOOR GOVT OFFICERS COLONY-TNHB QUARTERS THIRUMANGALAM,CHENNAI,TAMIL NADU,600040  600040', 'CITICORP SERVICES INDIA PRIVATE LIMITED CITI BANK THARAMANI, CHENNAI, TAMIL NADU 600113  600113', 25, '0-30', 'May, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    7766, 'Karnataka', 'Bangalore', 'LOA00003762', 'GZKPM2171K', 'ACGLLLOT00000003869', 'MONIKA  S', 9538555509, 'MONIKAMITHRA0706@GMAIL.COM',
    30000, 25500, 3814, 686, 4500, 686.44, 0, 0, 3813.56,
    42, 0.75, 39450, '2026-05-19', '2026-06-30', '''67385499536', 'STATE BANK OF INDIA',
    'SBIN0071247', 'INF/NEFT/IN42613952037949/SBIN0071247/71724525 /                              /MONIKAS', 'DISBURSED', 'NEW', 'HIMANI SINGH', 'KISHAN KUMAR',
    'PADMAVATHI V #08/B, DODDANAGAMANGALA(V), BEGUR(H),2  , KAR -560100  560100', 'GREAT LEARNING EDUCATION SERVICES PVT. LTD. NO. H207, FLOOR, BUILDING, FLOOR 2, 36/5, SOMASUNDARAPALYA MAIN RD, ADJACENT TO 27TH MAIN ROAD, HARALUKUNTE VILLAGE, SECTOR 2, HSR LAYOUT, BENGALURU, KARNATAKA 560102  560102', 20, '0-30', 'May, 2026', 'PART-PAYMENT'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    7781, 'Telangana', 'Hyderabad', 'LOA00003768', 'ABUPE5413A', 'ACGLLLOT00000003876', 'ENUGALA  SURESH', 8019845850, 'SURESHREDDY475@GMAIL.COM',
    50000, 42500, 6356, 1144, 7500, 1144.07, 0, 0, 6355.93,
    42, 0.75, 65750, '2026-05-19', '2026-06-30', '''14730100066154', 'FEDERAL BANK',
    'FDRL0001473', 'INF/NEFT/IN42613952241673/FDRL0001473/71749597 /DISBURSE                      /ENUGALASURE', 'DISBURSED', 'NEW', 'DEEPAK KUMAR', 'KISHAN KUMAR',
    'FLAT NO G3 AKRUTHIS THULASI RECIDENCY ROAD NO 10 BANDARYLAYOUT NIZAMPET HYDERABAD TELANGANA 500090  500090', 'SLYLY INFOTECH PRIVATE LIMITED 5TH FLOOR 502A/B JAIN SADGURU IMAGES CAPITAL PARK VIP HILLS MADHAPUR HYDERABAD TELANGANA 500081  500081', 20, '0-30', 'May, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    7806, 'Tamil Nadu', 'Chennai', 'LOA00003775', 'AKRPG5447Q', 'ACGLLLOT00000003884', 'GOMATHI  KANAGARAJ', 9600062562, 'GOMATHIKANAGARAJ@YAHOO.COM',
    45000, 38250, 5720, 1030, 6750, 1029.66, 0, 0, 5720.34,
    42, 0.75, 59175, '2026-05-19', '2026-06-30', '''921010043813798', 'AXIS BANK',
    'UTIB0004236', 'INF/NEFT/IN42613952325468/UTIB0004236/71759414 /DISBURSE                      /GOMATHIKANA', 'DISBURSED', 'NEW', 'POOJA', 'KISHAN KUMAR',
    '5-586, PLOT 4B, DOOR NO 5/586 VINOBA NAGAR NEAR SEKARAN BLOOMFIELD VINOBA APARTMENT, NAGAR, SITHALAPAKKAM, CHENNAI, TAMIL NADU , INDIA, 600131 5-586, PLOT 4B, DOOR NO 5/586 VINOBA NAGAR NEAR SEKARAN BLOOMFIELD VINOBA APARTMENT, NAGAR, SITHALAPAKKAM, CHENNAI, TAMIL NADU , INDIA, 600131  600126', 'ENSONO TECHNOLOGIES LLP CHENNAI ONE IT PARK, THORAIPAKKAM PALLAVARAM RING ROAD, THORAIPAKKAM CHENNAI 600097 CHENNAI ONE IT PARK, THORAIPAKKAM PALLAVARAM RING ROAD, THORAIPAKKAM CHENNAI 600097  600094', 20, '0-30', 'May, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    7809, 'Tamil Nadu', 'Chennai', 'LOA00003779', 'ATSPD8619H', 'ACGLLLOT00000003888', 'DINESH BABU P', 9791129167, 'DINESHBABU1490@GMAIL.COM',
    40000, 34000, 5085, 915, 6000, 915.25, 0, 0, 5084.75,
    11, 0.75, 43300, '2026-05-19', '2026-05-30', '''108201503609', 'ICICI BANK LIMITED',
    'ICIC0001082', 'INF/INFT/044477668361/71759414     /DINESHBABUP/DISBURSE', 'DISBURSED', 'NEW', 'SHIVANI JOSHI', 'KISHAN KUMAR',
    '7 SRI SUBRAMANIYA NAGAR EXTN MORAI AVADI CHENNAI 600055  600090', 'NTTDATA PVT LTD NTT DATA 5TH BLOCK DLF IT PARK RAMAPURAM CHENNAI 600089  600090', 51, '31-60', 'May, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    7731, 'Telangana', 'Hyderabad', 'LOA00003783', 'BBRPM0722Q', 'ACGLLLOT00000003892', 'SANJAY  MANDAL', 9618241825, 'MNDL.SANJAY@GMAIL.COM',
    35000, 29750, 4449, 801, 5250, 800.85, 0, 0, 4449.15,
    42, 0.75, 46025, '2026-05-20', '2026-07-01', '''083370098006', 'HSBC BANK',
    'HSBC0500002', 'INF/NEFT/IN42614052635154/HSBC0500002/71784554 /DISBURSE                      /SANJAYMANDA', 'DISBURSED', 'NEW', 'POOJA', 'KISHAN KUMAR',
    '15-44/1 VENKATAPURAM VENKATRAOPET NEAR VANDANA COLLEGE HYDERABAD 500015 15-44/1 VENKATAPURAM VENKATRAOPET NEAR VANDANA COLLEGE HYDERABAD 500015  500015', 'APPLAUSE APP QUALITY INDIA PRIVATE LIMITED LEVEL 6, AWFIS FLOOR, N-HEIGHTS, PLOT NO 38, SIDDIQ NAGAR, GACHIBOWLI, HYDERABAD, TELANGANA 500081 LEVEL 6, AWFIS FLOOR, N-HEIGHTS, PLOT NO 38, SIDDIQ NAGAR, GACHIBOWLI, HYDERABAD, TELANGANA 500081  500081', 19, '0-30', 'May, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    7768, 'Maharashtra', 'Pune', 'LOA00003781', 'CQQPM2306D', 'ACGLLLOT00000003890', 'ATUL DHONDIBA MARSHIVANE', 8149329076, 'ATULMARSHIVANE895@GMAIL.COM',
    30000, 25500, 3814, 686, 4500, 686.44, 0, 0, 3813.56,
    41, 0.75, 39225, '2026-05-20', '2026-06-30', '''10168282149', 'IDFC FIRST BANK LTD',
    'IDFB0043821', 'INF/NEFT/IN42614052635145/IDFB0043821/71784554 /DISBURSE                      /ATULDHONDIB', 'DISBURSED', 'NEW', 'POOJA', 'KISHAN KUMAR',
    'S.NO.126/127/1; C4- 2008. EDEN GARDEN PUNE CITY PUNE PUNE (M CORP.)   411033 S.NO.126/127/1; C4- 2008. EDEN GARDEN PUNE CITY PUNE PUNE (M CORP.)   411033  411033', 'ALLIANZ TECHNOCLOGY SE PUNE EON IT PARK PUNE CLUSTER C KHARADI  411014 EON IT PARK PUNE CLUSTER C KHARADI  411014  411014', 20, '0-30', 'May, 2026', 'PART-PAYMENT'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    7774, 'Karnataka', 'Bangalore', 'LOA00003784', 'AYOPP6598C', 'ACGLLLOT00000003893', 'ATUL NARENDRA PANJARE', 9108876607, 'ATULANI@GMAIL.COM',
    60000, 51000, 7627, 1373, 9000, 1372.88, 0, 0, 7627.12,
    42, 0.75, 78900, '2026-05-20', '2026-07-01', '''028701508226', 'ICICI BANK LIMITED',
    'ICIC0000287', 'INF/INFT/044483562961/71784554     /ATULNARENDRAPANJARE /DISBURSE', 'DISBURSED', 'NEW', 'DEEPAK KUMAR', 'KISHAN KUMAR',
    'A 306,MJ LIFESTYLE ASTRO,3RD FLOOR,  CHIKANAGAMANGAL, HUSKUR POST  BANGALORE,  KARNATAKA  560099  560099', 'ARKAIN GAMES INDIA PRIVATE LIMITED DSR DIYA ARCADE, 9M-220, 9TH MAIN ROAD, 1ST BLOCK EXENSTION, HRBR LAYOUT, KALYAN NAGER, BENGALURU - 560043, (KA)  560043', 19, '0-30', 'May, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    7844, 'Karnataka', 'Bangalore', 'LOA00003793', 'CFUPM1791M', 'ACGLLLOT00000003907', 'RAKESH BABU MHATRE', 7304572008, 'MHATRERAKESH890@GMAIL.COM',
    50000, 42500, 6356, 1144, 7500, 1144.07, 0, 0, 6355.93,
    41, 0.75, 65375, '2026-05-20', '2026-06-30', '''72210100008557', 'BANK OF BARODA',
    'BARB0VJAIRO', 'INF/NEFT/IN42614052933815/BARB0VJAIRO/71821874 /DISBURSE                      /RAKESHBABUM', 'DISBURSED', 'NEW', 'POOJA', 'KISHAN KUMAR',
    '7, OPPOSITE CRITICARE HOSPITAL DR. A.D LOGANATHAN ROAD BANGLORE KARNATAKA -560052 7, OPPOSITE CRITICARE HOSPITAL DR. A.D LOGANATHAN ROAD BANGLORE KARNATAKA -560052  560052', 'CN TECHNOLOGIES PVT LTD VADDARAPALYA BEGIHALLI, BANNERGHATTA RD, JIGANI HOBLI, ANEKAL, KARNATAKA 560083 VADDARAPALYA BEGIHALLI, BANNERGHATTA RD, JIGANI HOBLI, ANEKAL, KARNATAKA 560083  560083', 20, '0-30', 'May, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    7855, 'Telangana', 'Hyderabad', 'LOA00003791', 'APGPP7619P', 'ACGLLLOT00000003903', 'HIMANSU SEKHAR PARIDA', 9346915806, 'HIMANSU.PARIDA86@GMAIL.COM',
    40000, 34000, 5085, 915, 6000, 915.25, 0, 0, 5084.75,
    41, 0.75, 52300, '2026-05-20', '2026-06-30', '''149850700000092', 'YES BANK',
    'YESB0000006', 'INF/NEFT/IN42614052902690/YESB0000006/71818025 /DISBURSE                      /HIMANSUSEKH', 'DISBURSED', 'NEW', 'DEEPAK KUMAR', 'KISHAN KUMAR',
    '505, ANJANI TOWER DK ROAD AMEERPET HYDERABAD TELANGANA PIN CODE 500016  500016', 'CENTRICITY FINANCIAL DISTRIBUTION PRIVATE LIMITED LEVEL 12, VASAVI MPM GRAND, DOOR NO. 8-3-323, UNIT NO. 1324, 12TH FLOOR, YELLA REDDY GUDA RD, AMEERPET, YELLA REDDY GUDA, HYDERABAD, TELANGANA 500073  500073', 20, '0-30', 'May, 2026', 'PART-PAYMENT'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    7859, 'Karnataka', 'Bangalore', 'LOA00003792', 'BCIPS8592N', 'ACGLLLOT00000003904', 'SREENIVAS  A', 9353113781, 'ANNADRA.SREENIVAS@GMAIL.COM',
    40000, 34000, 5085, 915, 6000, 915.25, 0, 0, 5084.75,
    41, 0.75, 52300, '2026-05-20', '2026-06-30', '''39223686236', 'STATE BANK OF INDIA',
    'SBIN0041208', 'INF/NEFT/IN42614052902625/SBIN0041208/71818025 /DISBURSE                      /SREENIVASA', 'DISBURSED', 'NEW', 'HIMANI SINGH', 'KISHAN KUMAR',
    'C/O: NAGABHUSHAN ANNADRA, URBAN FLORA APARTMENT FLAT NO 008 GROUND FLOOR, 2ND CROSS PILLAPPA LAYOUT, BESIDE LEGACY HORSE RIDING SCHOOL, VIRUPAKSHAPURA, BANGALORE NORTH, PO: VIDYARANYAPURA, DIST: BENGALURU,  560097', 'HCL TECHNOLOGIES LTD 88TE3T, NO 129, JIGANI INDUSTRIAL AREA, BOMMASANDRA JIGANI LINK ROAD, BENGALURU, KARNATAKA, 560105  560105', 20, '0-30', 'May, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    7870, 'Telangana', 'Hyderabad', 'LOA00003299', 'AZYPK5153D', 'ACGLLLOT00000003908', 'KIRAN KUMAR AKURATI', 9182490776, 'AKIRANKUMARSAP@GMAIL.COM',
    25000, 21250, 3178, 572, 3750, 572.03, 0, 0, 3177.97,
    40, 0.75, 32500, '2026-05-21', '2026-06-30', '''925010052361651', 'AXIS BANK',
    'UTIB0006276', 'INF/NEFT/IN42614153204518/UTIB0006276/71844737 /DISBURSE                      /KIRANKUMARA', 'DISBURSED', 'REPEAT', 'DEEPAK KUMAR', 'KISHAN KUMAR',
    '4-32-602 ALLWYN COLONY PHASE 1,PHASE I, SHIVA NAGAR, ALLWYN COLONY, KUKATP ALLY, HYDERABAD,,JALAKANYA HOTEL,4-32-600,,HYDERABAD,TELANGANA,500072 HYDERABAD 500071', 'INFOSYS LIMITED,STP, INFOSYS LIMITED,STP, ACHIBOWLI, HYDERABAD, TELANGANA 500032  500031', 20, '0-30', 'May, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    7885, 'Delhi', 'New Delhi', 'LOA00003800', 'BKUPN4825R', 'ACGLLLOT00000003919', 'AMIT  NEGI', 8882127613, 'ANEGI7337@GMAIL.COM',
    30000, 25500, 3814, 686, 4500, 0, 343.22, 343.22, 3813.56,
    35, 0.75, 37875, '2026-05-21', '2026-06-25', '''36612677391', 'STATE BANK OF INDIA',
    'SBIN0003181', 'INF/NEFT/IN42614153323789/SBIN0003181/71859189 /DISBURSE                      /AMITNEGI', 'DISBURSED', 'NEW', 'SHIVANI JOSHI', 'KISHAN KUMAR',
    'A-3 FF BLOCK A SIDDHATRI ENCLAVE UTTAM NAGAR NEW DELHI 110059  110059', 'SITA INFORMATION NETWORKING COMPUTING INDIA PRIVATE LIMITED TOWER 7C CYBERCITY GURGAON 122002  122002', 25, '0-30', 'May, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    7897, 'Maharashtra', 'Mumbai', 'LOA00003802', 'BDXPN4635H', 'ACGLLLOT00000003922', 'NAGIREDDY  NAGENDRA', 9951110062, 'NAGENDRANAGIREDDY96@GMAIL.COM',
    35000, 29750, 4449, 801, 5250, 800.85, 0, 0, 4449.15,
    40, 0.75, 45500, '2026-05-21', '2026-06-30', '''50100766270731', 'HDFC BANK',
    'HDFC0004024', 'INF/NEFT/IN42614153421224/HDFC0004024/71872199 /DISBURSE                      /NAGIREDDYNA', 'DISBURSED', 'NEW', 'DEEPAK KUMAR', 'KISHAN KUMAR',
    'FLAT NO 505, LAXMI BALAJI 2 RAMA GOSAVI MARG SECT OR 9,AIROLI ,NAVI MUMBAI,A IROLI , NAVI MUMBAI AIR OLI ,NAVI MUMBAI THANE NAVI MUMBAI, MAHARASHTRA, 400708  400078', 'ORACLE SOLUTION SERVICES (INDIA) PVT. LTD. UNIT NO. 501, LEVEL 5, NO, FIRST INTERNATIONAL FINANCIAL CENTER, C54 & 55, G BLOCK, BANDRA KURLA COMPLEX, BANDRA EAST, MUMBAI, MAHARASHTRA 400098  400098', 20, '0-30', 'May, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    7907, 'Maharashtra', 'Pune', 'LOA00003803', 'ARHPN1070F', 'ACGLLLOT00000003923', 'NISHANT KUMAR NAG', 8378885832, 'NISHANT.NAG1@GMAIL.COM',
    20000, 17000, 2542, 458, 3000, 457.63, 0, 0, 2542.37,
    40, 0.75, 26000, '2026-05-21', '2026-06-30', '''091501525402', 'ICICI BANK LIMITED',
    'ICIC0000915', 'INF/INFT/044498638401/71872199     /NISHANTKUMARNAG     /DISBURSE', 'DISBURSED', 'NEW', 'GARISHMA', 'KISHAN KUMAR',
    'VANALIKA-PROJECT, WING 1-A, FLAT NO-103, GAT NO-124, NR.LAVALE PHATA, PIRANGUT, PUNE-412115 VANALIKA-PROJECT, WING 1-A, FLAT NO-103, GAT NO-124, NR.LAVALE PHATA, PIRANGUT, PUNE-412115  412114', 'INFOSYS BPM LIMITED INFOSYS HINJEWADI PHASE 2 NEAR HOTEL GRAND TAMNNAA PUNE  411057 INFOSYS HINJEWADI PHASE 2 NEAR HOTEL GRAND TAMNNAA PUNE  411057  411057', 20, '0-30', 'May, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    7924, 'Haryana', 'Faridabad', 'LOA00003806', 'GKMPS3471K', 'ACGLLLOT00000003928', 'SUNNY', 7678657164, 'SUNNY1.CHAWLA@GMAIL.COM',
    60000, 51000, 7627, 1373, 9000, 1372.88, 0, 0, 7627.12,
    40, 0.75, 78000, '2026-05-21', '2026-06-30', '''43830260759', 'STATE BANK OF INDIA',
    'SBIN0000734', 'MMT/IMPS/614119400451/BULD71879738/SUNNY/SBIN0000734', 'DISBURSED', 'NEW', 'DEEPAK KUMAR', 'KISHAN KUMAR',
    'HOUSE NO-F-1648 GROUND FLOOR SAINIK COLONY SECTOR-49 FARIDABAD FARIDABAD 121001  121001', 'GHV ADVANCED CARE PRIVATE LIMITED 3RD FLOOR CAPITAL, CYBERSCAPE SECTOR-59, ULLAHWAS, GURUGRAM, GURGAON - 122102  122102', 20, '0-30', 'May, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    7921, 'Karnataka', 'Bangalore', 'LOA00003815', 'CPFPS0780B', 'ACGLLLOT00000003943', 'SUSMITA  SUBEDI', 8310608310, 'ABHIPAT33427@GMAIL.COM',
    30000, 25500, 3814, 686, 4500, 686.44, 0, 0, 3813.56,
    39, 0.75, 38775, '2026-05-22', '2026-06-30', '''50100209517894', 'HDFC BANK',
    'HDFC0003790', 'INF/NEFT/IN42614254087747/HDFC0003790/71937690 /DISBURSE                      /SUSMITASUBE', 'DISBURSED', 'NEW', 'DEEPAK KUMAR', 'KISHAN KUMAR',
    'SHASHANK AMOGHA APARTMENT FLAT NUMBER 210, 128, SASHANK AMOGHA RD, KPSC LAYOUT, KOGILU, BENGALURU, KARNATAKA 560064,  560064', 'OPTUM GLOBAL SOLUTIONS (INDIA) PRIVATE LIMITED HARISHCHANDRA LAYOUT, ITC GREEN, 3RD FLOOR, NORTH EAST WING, 18, DODDA BANASWADI MAIN RD, JEEVANAHALLI, MARUTHI SEVANAGAR, BENGALURU, KARNATAKA 560005  560005', 20, '0-30', 'May, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    7935, 'Haryana', 'Gurgaon', 'LOA00002726', 'COXPK1721B', 'ACGLLLOT00000003929', 'SAMPURNA  KARMAKAR', 7903064985, 'SAMPURNAKARMAKA6@GMAIL.COM',
    50000, 42500, 6356, 1144, 7500, 1144.07, 0, 0, 6355.93,
    39, 0.75, 64625, '2026-05-22', '2026-06-30', '''50100223474135', 'HDFC BANK LTD',
    'HDFC0004804', 'INF/NEFT/IN42614253754772/HDFC0004804/71899095 /DISBURSE                      /SAMPURNAKAR', 'DISBURSED', 'REPEAT', 'POOJA', NULL,
    'B-702, ORRIS CARNATION RESIDENCY, BLOCK 2C, GURGAON, 122004 OUR HEIGHTS,,GURGAON,HARYANA, SECTOR 85, 122101', 'WIPRO WIPRO LIMITED, 480-481, 480, PHASE III, UDYOG VIHAR, SECTOR 19, GURUGRAM, VA, HARYANA 122016 SECTOR 19, 122016', 20, '0-30', 'May, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    7950, 'Maharashtra', 'Pune', 'LOA00003616', 'FOTPS3931E', 'ACGLLLOT00000003934', 'PRATIK BHIMRAO SHINDE', 8275036792, 'PRATIKBSHINDE@GMAIL.COM',
    22000, 18700, 2797, 503, 3300, 503.39, 0, 0, 2796.61,
    31, 0.75, 27115, '2026-05-22', '2026-06-22', '''50100597514059', 'HDFC BANK LTD',
    'HDFC0004774', 'INF/NEFT/IN42614253886788/HDFC0004774/71914052 /DISBURSE                      /PRATIKBHIMR', 'DISBURSED', 'REPEAT', 'POOJA', NULL,
    'B/09 B/09, KRUSHNAI APP MANAJI NAGAR NARHE ROAD KAPDA TASKAR PUNE CITY WEST PUNE MAHARASHTRA INDIA 411041 411041', 'MIRAE ASSET SHAREKHAN J M ROAD ABOVE WOODLAND SHOWROOM SHIVAJINAGAR PUNE 411001  411001', 28, '0-30', 'May, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    7965, 'Karnataka', 'Bangalore', 'LOA00003819', 'BHSPS5085F', 'ACGLLLOT00000003948', 'SUDIP KUMAR NANDI', 9986216663, 'NANDI80@GMAIL.COM',
    60000, 51000, 7627, 1373, 9000, 1372.88, 0, 0, 7627.12,
    34, 0.75, 75300, '2026-05-22', '2026-06-25', '''029701514602', 'ICICI BANK LIMITED',
    'ICIC0000297', 'INF/INFT/044510431751/71937690     /SUDIPKUMARNANDI     /DISBURSE', 'DISBURSED', 'NEW', 'HIMANI SINGH', 'KISHAN KUMAR',
    'NO 306. SAS SWAROOP SUNSHINE LAYOUT TC PALYA MAIN ROAD BANGALORE 560036  560036', 'HSBC ELECTRONIC DATA PROCESSING INDIA PVT. LTD. 1A, HSBC EAST CAMPUS, RMZ ECOSPACE, BELLANDUR BANGALORE 560103  560103', 25, '0-30', 'May, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    7967, 'Telangana', 'Rangareddy', 'LOA00003817', 'AQSPC3218N', 'ACGLLLOT00000003946', 'CHARLA  MANOHAR', 9867849759, 'MANOHARCHARLA2@GMAIL.COM',
    50000, 42500, 6356, 1144, 7500, 1144.07, 0, 0, 6355.93,
    39, 0.75, 64625, '2026-05-22', '2026-06-30', '''081862674006', 'HSBC BANK',
    'HSBC0500002', 'INF/NEFT/IN42614254087763/HSBC0500002/71937690 /DISBURSE                      /CHARLAMANOH', 'DISBURSED', 'NEW', 'POOJA', 'KISHAN KUMAR',
    'PLOT NO 176 GROUND FLOOR,VISHALI NAGAR, CHANDA NAGAR,HYDERABAD, TELANGANA 5 00049, INDIA,NEAR PARK,HYDERABAD,TELANGANA,500049 PLOT NO 176 GROUND FLOOR,VISHALI NAGAR, CHANDA NAGAR,HYDERABAD, TELANGANA 5 00049, INDIA,NEAR PARK,HYDERABAD,TELANGANA,500049  500049', 'BA CONTINUUM INDIA PVT. LTD. OFFICE ADDRESS  5B RAHEJA MINDSPACE HI TECH CITY HYDERABAD 500081 OFFICE ADDRESS  5B RAHEJA MINDSPACE HI TECH CITY HYDERABAD 500081  500081', 20, '0-30', 'May, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    7972, 'Tamil Nadu', 'Chennai', 'LOA00003820', 'AIOPN5424D', 'ACGLLLOT00000003950', 'NIRMAL RAJ SELVARAJ', 9677581571, 'PIRATE.CSE@GMAIL.COM',
    60000, 51000, 7627, 1373, 9000, 1372.88, 0, 0, 7627.12,
    40, 0.75, 78000, '2026-05-22', '2026-07-01', '''50396765636', 'INDIAN BANK',
    'IDIB000M682', 'INF/NEFT/IN42614254087862/IDIB000M682/71937690 /DISBURSE                      /NIRMALRAJSE', 'DISBURSED', 'NEW', 'POOJA', 'KISHAN KUMAR',
    'NO -1405/1407 S3 A- BLOCK , BALAJI ENCLAVE KALAIVANAR ST , RAM NAGAR NORTH MADIPAKKAM , CHENNAI , - - 600091 NO -1405/1407 S3 A- BLOCK , BALAJI ENCLAVE KALAIVANAR ST , RAM NAGAR NORTH MADIPAKKAM , CHENNAI , - - 600091  600092', 'FIRSTMERIDIAN GLOBAL SERVICES PVT.LTD. FLOOR â€œD, JAMAL FAZAL CHAMBER, 3RD, 26, GREAMS RD, THOUSAND LIGHTS, CHENNAI, TAMIL NADU 600006 FLOOR â€œD, JAMAL FAZAL CHAMBER, 3RD, 26, GREAMS RD, THOUSAND LIGHTS, CHENNAI, TAMIL NADU 600006  600006', 19, '0-30', 'May, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    7973, 'Karnataka', 'Bangalore', 'LOA00003455', 'AETPM0894B', 'ACGLLLOT00000003941', 'KOTESHWARA NARASIMHA MANJUNATHA', 7090559969, 'KNM_60@YAHOO.COM',
    22000, 18700, 2797, 503, 3300, 503.39, 0, 0, 2796.61,
    39, 0.75, 28435, '2026-05-22', '2026-06-30', '''50100519579116', 'HDFC BANK',
    'HDFC0000367', 'INF/NEFT/IN42614254018716/HDFC0000367/71930099 /DISBURSE                      /KOTESHWARAN', 'DISBURSED', 'REPEAT', 'POOJA', NULL,
    '14/2PIPELINEMAINROAD MALLESHWARAMOPPTO21FEETGANESHA STATUE BANGALORE560003 14/2PIPELINEMAINROAD MALLESHWARAMOPPTO21FEETGANESHA STATUE BANGALORE560003  560003', 'KYNDRYL SOLUTION PVT LTD M3 BLOCK MANYATHA TECK PARK NAGAWAR OUTER RING ROAD BANGALORE 560045 M3 BLOCK MANYATHA TECK PARK NAGAWAR OUTER RING ROAD BANGALORE 560045  560045', 20, '0-30', 'May, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    8022, 'Uttar Pradesh', 'Ghaziabad', 'LOA00003831', 'DBVPB2256N', 'ACGLLLOT00000003978', 'JATIN  BISHT', 9540461108, 'JATINBISHT63@GMAIL.COM',
    30000, 25500, 3814, 686, 4500, 686.44, 0, 0, 3813.56,
    36, 0.75, 38100, '2026-05-25', '2026-06-30', '''101549616006', 'HSBC BANK',
    'HSBC0380002', 'INF/NEFT/IN42614555766694/HSBC0380002/72037786 /DISBURSE                      /JATINBISHT', 'DISBURSED', 'NEW', 'DEEPAK KUMAR', 'KISHAN KUMAR',
    'D152S VIJAY NAGAR SECTOR 11 GHAZIABAD 201009  201009', 'KMK VENTURES PRIVATE LIMITED SMARTWORKS LOGIX SECTOR 62 NOIDA 201301  201301', 20, '0-30', 'May, 2026', 'PART-PAYMENT'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    8040, 'Karnataka', 'Bangalore', 'LOA00003444', 'ACCPE8212C', 'ACGLLLOT00000003961', 'HARISH KRISHNA ERRAMILLI', 8374516396, 'HARISH.WORK5861@GMAIL.COM',
    22000, 18700, 2797, 503, 3300, 503.39, 0, 0, 2796.61,
    36, 0.75, 27940, '2026-05-25', '2026-06-30', '''50100840574558', 'HDFC BANK',
    'HDFC0000053', 'INF/NEFT/IN42614555445820/HDFC0000053/72005419 /DISBURSE                      /HARISHKRISH', 'DISBURSED', 'REPEAT', 'POOJA', NULL,
    '207, AISHWARYA SPLENDOUR APARTMENTS, BRIGADE MILLENIUM ROAD, J P NAGAR PARADISE COLONY, JP NAGAR 7TH PHASE, BANGALORE, KARNATAKA 560078', 'CLOUDTHAT TECHNOLOGIES PVT LTD 102, 4TH CROSS, 5TH BLOCK, INDUSTRIAL LAYOUT, KHB COLONY, KORAMANGALA, BANGALORE 560004', 20, '0-30', 'May, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    8045, 'Andhra Pradesh', 'Visakhapatnam', 'LOA00002819', 'CNMPM4199M', 'ACGLLLOT00000003967', 'VANAPALLI  DEVI', 7675981455, 'SWETHA5085@GMAIL.COM',
    35000, 29750, 4449, 801, 5250, 800.85, 0, 0, 4449.15,
    36, 0.75, 44450, '2026-05-25', '2026-06-30', '''62372128108', 'STATE BANK OF INDIA',
    'SBIN0021409', 'INF/NEFT/IN42614555665308/SBIN0021409/72026848 /DISBURSE                      /VANAPALLIDE', 'DISBURSED', 'REPEAT', 'POOJA', NULL,
    ',58-15-57, SHANTHI NAGAR, NAD JUNCTION, NEAR SBI BANK, VISAKHAPATNAM ,58-15-57, SHANTHI NAGAR, NAD JUNCTION, NEAR SBI BANK, VISAKHAPATNAM  530009', 'ELI LILLY AND COMPANY INDIA PVT LTD 30-8-7, BHANU ST, DABA GARDENS, ALLIPURAM, VISAKHAPATNAM, ANDHRA PRADESH 530020 30-8-7, BHANU ST, DABA GARDENS, ALLIPURAM, VISAKHAPATNAM, ANDHRA PRADESH 530020  530020', 20, '0-30', 'May, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    8053, 'Telangana', 'Hyderabad', 'LOA00003827', 'AQVPV8783A', 'ACGLLLOT00000003971', 'VEERENDRA  VAITLA', 9880963888, 'VEERENDRAVAITLA0904@GMAIL.COM',
    50000, 42500, 6356, 1144, 7500, 1144.07, 0, 0, 6355.93,
    36, 0.75, 63500, '2026-05-25', '2026-06-30', '''2611844738', 'KOTAK MAHINDRA BANK LIMITED',
    'KKBK0000431', 'INF/NEFT/IN42614555766677/KKBK0000431/72037786 /DISBURSE                      /VEERENDRAVA', 'DISBURSED', 'NEW', 'DEEPAK KUMAR', 'KISHAN KUMAR',
    '202 AVIDHA CLOUD 9 ROAD NO 1 SAI ANURAG COLONY BACHUPALLY 500090  500090', 'VENKATAGIRI, JUBILEE HILLS, HYDERABAD, TELANGANA 500033 2ND & 3RD FLOOR PLOT, NO. 703/A, ROAD NO. 36, ADITYA ENCLAVE, VENKATAGIRI, JUBILEE HILLS, HYDERABAD, TELANGANA 500033  500033', 20, '0-30', 'May, 2026', 'PART-PAYMENT'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    8055, 'Karnataka', 'Bangalore', 'LOA00003833', 'KJKPK0812F', 'ACGLLLOT00000003980', 'OM RAMESH KAMBLE', 9892479437, 'KAMBLEOM045@GMAIL.COM',
    30000, 25500, 3814, 686, 4500, 686.44, 0, 0, 3813.56,
    17, 0.75, 33825, '2026-05-25', '2026-06-11', '''36210100012123', 'BANK OF BARODA',
    'BARB0KALWAX', 'INF/NEFT/IN42614555841274/BARB0KALWAX/72046653 /DISBURSE                      /OMRAMESHKAM', 'DISBURSED', 'NEW', 'DEEPAK KUMAR', 'KISHAN KUMAR',
    'VMB MAPLE APARTMENT FLAT NO. 301 DODDATHOGUR, ELECTRONIC CITY BANGLORE KARNATAKA - 560100  560100', 'CN TECHNOLOGIES(INDIA) VADDARAPALYA BEGIHALLI, BANNERGHATTA RD, JIGANI HOBLI, ANEKAL, KARNATAKA 560083  560083', 39, '31-60', 'May, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    8060, 'Telangana', 'Hyderabad', 'LOA00003703', 'ASYPV4478K', 'ACGLLLOT00000003965', 'VENKAT SRAVAN SRAVAN VADDAMANI', 8179017390, 'SRAVAN13101986@GMAIL.COM',
    47000, 39950, 5975, 1075, 7050, 1075.42, 0, 0, 5974.58,
    36, 0.75, 59690, '2026-05-25', '2026-06-30', '''5282636557', 'AXIS BANK',
    'UTIB0005151', 'INF/NEFT/IN42614555665153/UTIB0005151/72026848 /DISBURSE                      /VENKATSRAVA', 'DISBURSED', 'REPEAT', 'PAYAL SHARMA', 'KISHAN KUMAR',
    'SEEMA RESIDENCY FLAT NO.501 ROAD NO.8 ALAKPUR TOWN ,HYDERABAD,TELANGANA ALAKPUR TOWN 500089', 'ADP PRIVATE LIMITED ONE WEST BUILDING, SURVEY NO. 88/AA AND 88/E NANAKRAMGUDA VILLAGE, SERILINGAMPALLY MANDAL, RANGA REDDY DISTRICT, HYDERABAD NANAKRAMGUDA VILLAGE, 500008', 20, '0-30', 'May, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    8067, 'Uttar Pradesh', 'Noida', 'LOA00003829', 'HASPS6836R', 'ACGLLLOT00000003975', 'JATIN  SINGH', 9205601266, 'JATINS741@GMAIL.COM',
    30000, 25500, 3814, 686, 4500, 686.44, 0, 0, 3813.56,
    42, 0.75, 39450, '2026-05-25', '2026-07-06', '''157901535127', 'ICICI BANK LIMITED',
    'ICIC0001579', 'INF/INFT/044530569251/72026848     /JATINSINGH/DISBURSE', 'DISBURSED', 'NEW', 'POOJA', 'KISHAN KUMAR',
    'E-201/2F,AIGIN ROYAL, GH-16D, SECTOR-1 GREATER NOIDA,GAUTAM BUDH NAGAR 201306 E-201/2F,AIGIN ROYAL, GH-16D, SECTOR-1 GREATER NOIDA,GAUTAM BUDH NAGAR 201306  201306', 'PHOENIX CONTACT INDIA PVT LTD 2ND AND 3RD FLOOR KHASRA NO 531 ANANGPUR DISTT FARIDABAD HARYANA 121003 2ND AND 3RD FLOOR KHASRA NO 531 ANANGPUR DISTT FARIDABAD HARYANA 121003  121003', 14, '0-30', 'May, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    8090, 'Uttar Pradesh', 'Gautam Buddha Nagar', 'LOA00003667', 'ATHPK2681F', 'ACGLLLOT00000003984', 'CHAITANYA  KAMRA', 8115651481, 'CHAITANYAKAMRA07@GMAIL.COM',
    40000, 34000, 5085, 915, 6000, 915.25, 0, 0, 5084.75,
    36, 0.75, 50800, '2026-05-25', '2026-06-30', '''50100415635730', 'HDFC BANK',
    'HDFC0004792', 'INF/NEFT/IN42614555841264/HDFC0004792/72046653 /DISBURSE                      /CHAITANYAKA', 'DISBURSED', 'REPEAT', 'DEEPAK KUMAR', NULL,
    'FLAT 1504 TOWER B-7. GARDENIA GLORY SEC 46, GARDENIA GLORY, SEC 46 NOIDA, GAUTAM BUDDHA NAGAR PO NOIDA, DIST:GAUTAM BUDDHA NAGAR, UTTAR PRADESH, 201301  201301', 'TSDC TECHNOLOGIES LLP B-29, SECTOR 1 NOIDA 201301  201301', 20, '0-30', 'May, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    8113, 'Maharashtra', 'Mumbai', 'LOA00003311', 'CMYPS6640E', 'ACGLLLOT00000003988', 'ANKUSH NAGOJI SHIKHARE', 9821444214, 'ANKUSHSHIKHARE1988@GMAIL.COM',
    25000, 21250, 3178, 572, 3750, 572.03, 0, 0, 3177.97,
    31, 0.75, 30812.5, '2026-05-26', '2026-06-26', '''20012523542084', 'SBM BANK MAURITIUS LIMITED',
    'STCB0000065', 'INF/NEFT/IN426146561 63226/STCB0000065/72 070314 /DISBURSE /A NKUSHNAGOJ', 'DISBURSED', 'REPEAT', 'POOJA', NULL,
    'PLOT NO : 410 FLAT NO: C3 FLOOR: GR NIRGUN, KANDIVALI (W) CHARKOP, SECTOR-4, RSC - 37, BEHIND CHARKOP BUS DEPOT, NIRGUN CHSL, KANDIVALI (W)  400067', 'SBM BANK (INDIA) LTD SBM BANK (INDIA) LTD. AKRUTI TRADE CENTRE, UNIT NO. 201 & 203, A-WING, 2ND FLOOR, M.LD.C, ANDHERI (E), MUMBAI-400059  400059', 24, '0-30', 'May, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    8143, 'Telangana', 'Rangareddy', 'LOA00003839', 'BPHPR0266N', 'ACGLLLOT00000003993', 'RAMPILLA  HARISH', 9676484193, 'HARISHRAMPILLA.0525@GMAIL.COM',
    50000, 42500, 6356, 1144, 7500, 1144.07, 0, 0, 6355.93,
    35, 0.75, 63125, '2026-05-26', '2026-06-30', '''30447273126', 'STATE BANK OF INDIA',
    'SBIN0004187', 'INF/NEFT/IN426146563 54165/SBIN0004187/72 092964 /DISBURSE /R AMPILLAHAR', 'DISBURSED', 'NEW', 'DEEPAK KUMAR', 'KISHAN KUMAR',
    'DR NO : 1-7/35 , FLAT NO : 302 , FLOOR NO-3 , PEMMARAJU SYAMALA DEVI NIVASAM , SRI LAKSHMI VENKAT NAGAR RD, HMT COLONY, MIYAPUR, HYDERABAD, TELANGANA 500049  500049', 'CIGNA HEALTH SOLUTIONS INDIA PRIVATE LIMITED EVERNORTH HEALTH SERVICES , SHILPA GRAM CRAFT VILLAGE, MY HOME BHOOJA, KNOWLEDGE CITY RD, SILPA GRAM CRAFT VILLAGE,  HITEC CITY, RAI DURG - 500081  500081', 20, '0-30', 'May, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    8155, 'Maharashtra', 'Thane', 'LOA00003843', 'CEYPJ5249A', 'ACGLLLOT00000003997', 'JIGAR DHIRUBHAI JETHVA', 7666284620, 'JIGARJETHVA4@GMAIL.COM',
    25000, 21250, 3178, 572, 3750, 572.03, 0, 0, 3177.97,
    34, 0.75, 31375, '2026-05-26', '2026-06-29', '''520101041051072', 'UNION BANK OF INDIA',
    'UBIN0905712', 'INF/NEFT/IN42614656504950/UBIN0905712/72110836 /DISBURSE                      /JIGARDHIRUB', 'DISBURSED', 'NEW', 'PAYAL SHARMA', 'KISHAN KUMAR',
    'MAHADEV SADAN 24/4 GUPTE ROAD PAWAN ICE CREAM SHOP DOMBIVLI WEST PAWAN ICE CREAM 421202', '5PAISA CAPITAL LTD SUNINFOTECH PARK WAGHLE ESTATE ROAD NO 16 THANE WEST SUNINFOTECH PARK WAGHLE ESTATE ROAD NO 16 THANE WEST SUNINFOTECH PARK 400604', 21, '0-30', 'May, 2026', 'PART-PAYMENT'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    8159, 'Karnataka', 'Bangalore', 'LOA00003732', 'AGWPV4882B', 'ACGLLLOT00000004001', 'A VASANTHA KUMAR', 9731214223, 'VASANTHA2MBA@GMAIL.COM',
    25000, 21250, 3178, 572, 3750, 572.03, 0, 0, 3177.97,
    35, 0.75, 31562.5, '2026-05-26', '2026-06-30', '''2401266962235832', 'AU SMALL FINANCE BANK LIMITED',
    'AUBL0002669', 'INF/NEFT/IN42614656504945/AUBL0002669/72110836 /DISBURSE                      /AVASANTHAKU', 'DISBURSED', 'REPEAT', 'DEEPAK KUMAR', NULL,
    '2129, NETHRAVATHI NIVAS, RAMAIAH LAYOUT, RAMAMURTHY NAGAR-560016  560016', 'YETHI CONSULTING PRIVATE LIMITED 1ST FLOOR, A, RANKA JUNCTION, AH45, KR PURAM BRIDGE, INDUSTRIAL ESTATE, DOORAVANI NAGAR, BENGALURU, KARNATAKA 560016.  560016', 20, '0-30', 'May, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    8166, 'Maharashtra', 'Pune', 'LOA00003433', 'ALIPB8745J', 'ACGLLLOT00000004005', 'CHINMOY  BANERJEE', 9123754766, 'BANERJEECHINMOY12@GMAIL.COM',
    35000, 29750, 4449, 801, 5250, 800.85, 0, 0, 4449.15,
    31, 0.75, 43137.5, '2026-05-26', '2026-06-26', '''330201501643', 'ICICI BANK LTD',
    'ICIC0003302', 'INF/INFT/044546308451/72110836     /CHINMOYBANERJEE     /DISBURSE', 'DISBURSED', 'REPEAT', 'POOJA', NULL,
    'B 1004, DHANASHREE ANAND 2 HANDEWADI PUNE - 412308 B 1004, DHANASHREE ANAND 2 HANDEWADI PUNE - 412308  412308', 'MASTERCARD TECHNOLOGY PVT LTD BLUEGRASS BUSINESS PARK  KALYANI NAGAR  PUNE - 411006 BLUEGRASS BUSINESS PARK  KALYANI NAGAR  PUNE - 411006  411006', 24, '0-30', 'May, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    8084, 'Tamil Nadu', 'Chennai', 'LOA00003854', 'AVBPP5862D', 'ACGLLLOT00000004022', 'D PRAVEEN', 9994147880, 'PRAVEENDAVID2387@GMAIL.COM',
    25000, 21250, 3178, 572, 3750, 572.03, 0, 0, 3177.97,
    34, 0.75, 31375, '2026-05-27', '2026-06-30', '''10013909766', 'IDFC FIRST Bank',
    'IDFB0080102', 'MMT/IMPS/614717191047/BULD72157857/DPRAVEEN/IDFB0080102', 'DISBURSED', 'NEW', 'POOJA', 'KISHAN KUMAR',
    'PLOT NO- 2A SAI BAKKIAM RESIDENCY B-BLOCKS2 DHARMABOOPATHY NAGAR 1ST STREET VADAKUPATTU MEDAVAKKAM CHENGALPAT KANCHEEPURAM 600100 TAMIL NADU INDIA PLOT NO- 2A SAI BAKKIAM RESIDENCY B-BLOCKS2 DHARMABOOPATHY NAGAR 1ST STREET VADAKUPATTU MEDAVAKKAM CHENGALPAT KANCHEEPURAM 600100 TAMIL NADU INDIA  600100', 'HCL TECHNOLOGIES LTD. ELCOT-SPECIAL ECONOMIC ZONE (SEZ) NO. 602/3 & 138, SHOLINGANALLUR VILLAGE MEDAVAKKAM HIGH ROAD, SHOLINGANALLUR CHENNAI, TAMIL NADU 600119 ELCOT-SPECIAL ECONOMIC ZONE (SEZ) NO. 602/3 & 138, SHOLINGANALLUR VILLAGE MEDAVAKKAM HIGH ROAD, SHOLINGANALLUR CHENNAI, TAMIL NADU 600119  600118', 20, '0-30', 'May, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    8198, 'Maharashtra', 'Thane', 'LOA00003849', 'BACPD3731Q', 'ACGLLLOT00000004012', 'DUPPALA ANIL KUMAR GOUD', 9227007057, 'ANILDUPPALA4@GMAIL.COM',
    35000, 29750, 4449, 801, 5250, 800.85, 0, 0, 4449.15,
    34, 0.75, 43925, '2026-05-27', '2026-06-30', '''19950100094577', 'FEDERAL BANK',
    'FDRL0001995', 'MMT/IMPS/614717190073/BULD72157857/DUPPALAANI/FDRL0001995', 'DISBURSED', 'NEW', 'DEEPAK KUMAR', 'KISHAN KUMAR',
    '1805,CASA EVIVA T WING DOWNTOWN PALAVA2 DOMBIVLI  421204  421204', 'SWEDISH ENVIRONMENTAL RESEARCH INSTITUTE SHELTON SAPPHIRE CBD BELAPUR NAVI MUMBAI 400016  400016', 20, '0-30', 'May, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    8210, 'Karnataka', 'Bangalore', 'LOA00003853', 'AUSPB7778C', 'ACGLLLOT00000004020', 'ARJUUN  BERRY', 9711487797, 'ARJUN.BERRY@YAHOO.CO.IN',
    70000, 59500, 8898, 1602, 10500, 1601.69, 0, 0, 8898.31,
    34, 0.75, 87850, '2026-05-27', '2026-06-30', '''10169367871', 'IDFC BANK',
    'IDFB0080153', 'MMT/IMPS/614717191022/BULD72157857/ARJUUNBERR/IDFB0080153', 'DISBURSED', 'NEW', 'POOJA', 'KISHAN KUMAR',
    '64/1 REDDY HOUSE FLAT 401 RAJASHREE LAYOUT  6TH CROSS MUNNEKOLLALA  BANGALORE  560037 KARNATAKA 64/1 REDDY HOUSE FLAT 401 RAJASHREE LAYOUT  6TH CROSS MUNNEKOLLALA  BANGALORE  560037 KARNATAKA  560037', 'GAMESKRAFT TECHNOLOGIES PRIVATE LIMITED URBAN VAULT 1086 HSR LAYOUT SECTOR 4 BANGALORE  560102 KARNATAKA URBAN VAULT 1086 HSR LAYOUT SECTOR 4 BANGALORE  560102 KARNATAKA  560102', 20, '0-30', 'May, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    8217, 'Karnataka', 'Bangalore', 'ADV00001003', 'CQBPK8670F', 'ACGLLLOT00000004031', 'SONANKI  KESHRI', 9167783473, 'MONA.KESHRI07@GMAIL.COM',
    30000, 25500, 3814, 686, 4500, 686.44, 0, 0, 3813.56,
    34, 0.75, 37650, '2026-05-27', '2026-06-30', '''2724101105410', 'CANARA BANK',
    'CNRB0003006', 'INF/NEFT/IN426147570 34005/CNRB0003006/72 165878 /DISBURSE /S ONANKIKESH', 'DISBURSED', 'REPEAT', 'GARISHMA', 'KISHAN KUMAR',
    'FLAT NO D-201 PRIME CITY APARTMENT, ELECTRONIC CITY PHASE 1, DODDATHOGURU, PO: ELECTRONICS CITY, DIST: BENGALURU, KARNATAKA - 560100 FLAT NO D-201 PRIME CITY APARTMENT, ELECTRONIC CITY PHASE 1, DODDATHOGURU, PO: ELECTRONICS CITY, DIST: BENGALURU, KARNATAKA - 560100  560100', 'SIGMA ALDRICH CHEMICALS PVT LTD MERCK TOWER 2 ELECTRONIC CITY PHASE 1 BANGALORE 560100 MERCK TOWER 2 ELECTRONIC CITY PHASE 1 BANGALORE 560100  560100', 20, '0-30', 'May, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    8229, 'Tamil Nadu', 'Kanchipuram', 'LOA00003863', 'FWAPS3598Q', 'ACGLLLOT00000004039', 'SOWMIA THAIYAN VAIDYANATHAN', 9498448565, 'SOWMIVINU5@GMAIL.COM',
    35000, 29750, 4449, 801, 5250, 800.85, 0, 0, 4449.15,
    34, 0.75, 43925, '2026-05-27', '2026-06-30', '''42111388186', 'STANDARD CHARTERED BANK',
    'SCBL0036088', 'INF/NEFT/IN42614757098218/SCBL0036088/72171499 /DISBURSE                      /SOWMIATHAIY', 'DISBURSED', 'NEW', 'POOJA', 'KISHAN KUMAR',
    '1/25 GANDHI NAGAR 2ND STREET. PERUNGALATHUR. CHENNAI -600063 1/25 GANDHI NAGAR 2ND STREET. PERUNGALATHUR. CHENNAI -6  600063', 'ACCENTURE SOLUTIONS PVT LTD CDC2 â€“ SEZ, GATEWAY OFFICE PARKS, NO. 16, GST ROAD, NEW PERUNGALATHUR, CHENNAI, TAMIL NADU 600063 CDC2 â€“ SEZ, GATEWAY OFFICE PARKS, NO. 16, GST ROAD, NEW PERUNGALATHUR, CHENNAI, TAMIL NADU 600063  600078', 20, '0-30', 'May, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    8230, 'Telangana', 'Hyderabad', 'LOA00003860', 'DKPPK1688J', 'ACGLLLOT00000004035', 'KURISIPATI SRI HARSHA', 9642246224, 'HARSHASRI93@GMAIL.COM',
    70000, 59500, 8898, 1602, 10500, 1601.69, 0, 0, 8898.31,
    35, 0.75, 88375, '2026-05-27', '2026-07-01', '''0896104000622004', 'IDBI BANK',
    'IBKL0000896', 'INF/NEFT/IN42614757099576/IBKL0000896/72171499 /DISBURSE                      /KURISIPATIS', 'DISBURSED', 'NEW', 'SHIVANI JOSHI', 'KISHAN KUMAR',
    'PLOT NO 111B, LAKE VIEW RESIDENCY, SAINIKPURI, HYDERABAD TELANGANA 500094 TELANGANA 500094  500062', 'LUMENDATA SOLUTIONS INDIA PVT LTD TOWER-B, MANTRI COMMERCIO, 2GETHR@ORR, 2ND FLOOR, LUMENDATA SOLUTIONS, OUTER RING RD, KARIYAMMANA AGRAHARA, BELLANDUR, BENGALURU, KARNATAKA 560103  560103', 19, '0-30', 'May, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    8231, 'West Bengal', 'Kolkata', 'LOA00003623', 'APIPG4962Q', 'ACGLLLOT00000004032', 'ANIRBAN  GANGULY', 7631199947, 'AGANGULY12@HOTMAIL.COM',
    40000, 34000, 5085, 915, 6000, 915.25, 0, 0, 5084.75,
    41, 0.75, 52300, '2026-05-27', '2026-07-07', '''05301000017228', 'HDFC BANK',
    'HDFC0000530', 'MMT/IMPS/614717191201/BULD72157857/ANIRBANGAN/HDFC0000530', 'DISBURSED', 'REPEAT', 'PAYAL SHARMA', 'KISHAN KUMAR',
    '4TH-FR;FL-4B 27 CHARU CHANDRA AVENUE LP-ACPB1350 KOLKATA CHARU CHANDRA AVENUE 700033', 'AFC SYSTEM PRIVATE LIMITED PLOT NO.33, ECOTECH - 12, GREATER NOIDA ECOTECH 201310', 13, '0-30', 'May, 2026', 'PART-PAYMENT'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    8236, 'Telangana', 'Hyderabad', 'LOA00002463', 'CGWPM8333G', 'ACGLLLOT00000004033', 'ROHAN  MEDISETTI', 9010608386, 'ROHAN.RGUKT@GMAIL.COM',
    40000, 34000, 5085, 915, 6000, 915.25, 0, 0, 5084.75,
    30, 0.75, 49000, '2026-05-27', '2026-06-26', '''926010007246973', 'AXIS BANK',
    'UTIB0004837', 'INF/NEFT/IN42614757099571/UTIB0004837/72171499 /DISBURSE                      /ROHANMEDISE', 'DISBURSED', 'REPEAT', 'SHIVANI JOSHI', 'KISHAN KUMAR',
    'FLAT NO 102, ''B'' BLOCK, SUPRA ECO HOMES, RAJARAJESHWARI NAGAR, KONDAPUR, RANGAREDDY DIST, TELANGANA-500084 SUPRA ECO HOMES 500085', 'WELLS FARGO INTERNATIONAL SOLUTIONS PRIVATE LIMITED TOWER 4 , WELLS FARGO, DIVYA SHREE ORION SEZ, RAIDURGAM-500032 DIVYA SHREE ORION 500032', 24, '0-30', 'May, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    8238, 'Maharashtra', 'Pune', 'LOA00003862', 'CHQPM3672K', 'ACGLLLOT00000004037', 'KOUSHALYA DARSHANI P M', 9731529433, 'KOUSHALYADARSHANI9@GMAIL.COM',
    60000, 51000, 7627, 1373, 9000, 1372.88, 0, 0, 7627.12,
    29, 0.75, 73050, '2026-05-27', '2026-06-25', '''50100534330952', 'HDFC BANK',
    'HDFC0000077', 'INF/NEFT/IN42614757099585/HDFC0000077/72171499 /DISBURSE                      /KOUSHALYADA', 'DISBURSED', 'NEW', 'GARISHMA', 'KISHAN KUMAR',
    'FLAT NO 409 T9,KHARADI, PUNE,MANJARI KHURD,VTP CYGNUS PUNE,MAHARASHTRA- 412307  412307', 'BP BUSINESS SOLUTIONS INDIA PVT LTD GERA COMMERCE ZONE , B5 , KHARADI GERA COMMERCE ZONE , B5 , KHARADI  410406', 25, '0-30', 'May, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    8248, 'Maharashtra', 'Pune', 'LOA00003377', 'AJDPV3792Q', 'ACGLLLOT00000004040', 'VAIBHAVI  VITEKAR', 9119445936, 'VITEKARVAIBHAVI@GMAIL.COM',
    35000, 29750, 4449, 801, 5250, 800.85, 0, 0, 4449.15,
    29, 0.75, 42612.5, '2026-05-27', '2026-06-25', '''923010020050192', 'AXIS BANK',
    'UTIB0000269', 'INF/NEFT/IN42614757099597/UTIB0000269/72171499 /DISBURSE                      /VAIBHAVIVIT', 'DISBURSED', 'REPEAT', 'SHIVANI JOSHI', NULL,
    'SR.NO.12/4;FLAT NO.C-105 DHANORI AMORAPOLIS PUNECITY  411015', 'BP BUSINESS SOLUTIONS INDIA PVT LTD 7TH, 8TH, 9TH AND 10TH FLOOR, BUILDING 5 (R3),S.NO.65, KRC INFRASTRUCTURE PROJECTS PVT LTD,KHARADI,PUNE,MAHARASHTRA-411014  411014', 25, '0-30', 'May, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    8244, 'Haryana', 'Gurgaon', 'LOA00003864', 'FYKPK6614R', 'ACGLLLOT00000004043', 'AKASH  KUMAR', 9304690511, 'AKASHBCETDURGAPUR@GMAIL.COM',
    20000, 17000, 2542, 458, 3000, 457.63, 0, 0, 2542.37,
    33, 0.75, 24950, '2026-05-28', '2026-06-30', '''026501524227', 'ICICI BANK LIMITED',
    'ICIC0000265', 'INF/INFT/044561277821/72185805     /AKASHKUMAR/DISBURSE', 'DISBURSED', 'NEW', 'GARISHMA', 'KISHAN KUMAR',
    'FLAT NO 108 FLAT NO 108,U-44/2 DLF PHASE III U BLOCK GURGAON HARYANA - 122010  122010', 'GENPACT INDIA PRIVATE LIMITED GENPACT , BADHSAPUR , SEC 69, GURGAON- 122101 GENPACT , BADHSAPUR , SEC 69, GURGAON- 122101  122001', 20, '0-30', 'May, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    8246, 'Karnataka', 'Bangalore', 'LOA00003868', 'APSPL9219B', 'ACGLLLOT00000004055', 'KOTHAKOTA LOKESH NAIDU', 8431470823, 'LOKESHCHOWDARY998@GMAIL.COM',
    15000, 12750, 1907, 343, 2250, 343.22, 0, 0, 1906.78,
    33, 0.75, 18712.5, '2026-05-28', '2026-06-30', '''50100339698721', 'HDFC BANK',
    'HDFC0004075', 'INF/NEFT/IN42614857345677/HDFC0004075/72193162 /DISBURSE                      /KOTHAKOTALO', 'DISBURSED', 'NEW', 'SHIVANI JOSHI', 'KISHAN KUMAR',
    'SHANVIK HOME TIMMAREDDY LAYOUT KORALUR BANGALORE 560067  560067', 'TALISMA CORPORATION PRIVATE LIMITED GROUND FLOOR SALAPURIA SATTVA BUILDING TINFACTORY BANGALORE 560016  560016', 20, '0-30', 'May, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    8285, 'Maharashtra', 'Thane', 'ADV00000743', 'AQNPP5049B', 'ACGLLLOT00000004050', 'DEBJIT  PAL', 7760002211, 'PAL.DDEBJIT@GMAIL.COM',
    40000, 34000, 5085, 915, 6000, 915.25, 0, 0, 5084.75,
    32, 0.75, 49600, '2026-05-28', '2026-06-29', '''925010034842734', 'AXIS BANK',
    'UTIB0004852', 'MMT/IMPS/614815565802/BULD72193162/DEBJITPAL/UTIB0004852', 'DISBURSED', 'REPEAT', 'PAYAL SHARMA', 'KISHAN KUMAR',
    '401 LODHA SPLENDORA, TIERRA D-WING THANE WEST OWALE 400615  400615', 'BNP PARIBAS INDIA SOLUTIONS PVT. LTD NIRLON KNOWLEDGE PARK B3 BUILDING. GOREGAON EAST GOREGAON EAST 400064  400064', 21, '0-30', 'May, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    8288, 'West Bengal', 'Kolkata', 'LOA00003469', 'AKPPK1635C', 'ACGLLLOT00000004053', 'ARUNAV  KOL', 9903237344, 'ARUNAVKOL@GMAIL.COM',
    70000, 59500, 8898, 1602, 10500, 1601.69, 0, 0, 8898.31,
    32, 0.75, 86800, '2026-05-28', '2026-06-29', '''627701513746', 'ICICI BANK LIMITED',
    'ICIC0001271', 'INF/INFT/044562411041/72193162     /ARUNAVKOL/DISBURSE', 'DISBURSED', 'REPEAT', 'GARISHMA', 'KISHAN KUMAR',
    '3/4/A1, GOLEPARK CO-OP HOUSING, 49B GOBINDAPUR ROAD LAKE GARDEN KOLKATA, WEST BANGAL -700045 KOLKATA WEST BENGAL 700045 I 3/4/A1, GOLEPARK CO-OP HOUSING, 49B GOBINDAPUR ROAD LAKE GARDEN KOLKATA, WEST BANGAL -700045 KOLKATA WEST BENGAL 700045 I  700045', 'PERNOD RICARD INDIA PRIVATE LIMITED UNIT 407 408 409 411, SOUTH CITY BUSINESS PARK. ANANDAPUR KOLKATA 700107 UNIT 407 408 409 411, SOUTH CITY BUSINESS PARK. ANANDAPUR KOLKATA 700107  700107', 21, '0-30', 'May, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    8294, 'Telangana', 'Hyderabad', 'LOA00003483', 'DFEPK1399E', 'ACGLLLOT00000004054', 'AVINASH  KANDALA', 9000150785, 'AVINASHKANDALA1122@GMAIL.COM',
    35000, 29750, 4449, 801, 5250, 800.85, 0, 0, 4449.15,
    29, 0.75, 42612.5, '2026-05-28', '2026-06-26', '''50100013601150', 'HDFC BANK',
    'HDFC0000050', 'INF/NEFT/IN42614857345661/HDFC0000050/72193162 /DISBURSE                      /AVINASHKAND', 'DISBURSED', 'REPEAT', 'GARISHMA', NULL,
    'HOME: 301, AVIGHNA HOMES, RAJARAJESHWARI NAGAR, KONDAPUR HYDERABAD 500084  500081', 'QUEST DIAGNOSTICS HTAS INDIA PRIVATE LIMITED. H06A, PHOENIX AVANCE BUSINESS HUB, HITECH CITY HYDERABAD 500081  500081', 24, '0-30', 'May, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    8320, 'Maharashtra', 'Pune', 'LOA00003658', 'AWOPK6402E', 'ACGLLLOT00000004065', 'KETAN VINAYAK KULKARNI', 9527307900, 'KV.KETAN@GMAIL.COM',
    42000, 35700, 5339, 961, 6300, 961.02, 0, 0, 5338.98,
    33, 0.75, 52395, '2026-05-28', '2026-06-30', '''10230734058', 'IDFC BANK LTD',
    'IDFB0041359', 'INF/NEFT/IN42614857468626/IDFB0041359/72210112 /DISBURSE                      /KETANVINAYA', 'DISBURSED', 'REPEAT', 'SHIVANI JOSHI', 'KISHAN KUMAR',
    'FL NO 5 VITTHAL PRAKASH APT LANE NO 23B GANESH NAGAR,,DHAYARI,,PUNE  411041', 'FIS SOLUTIONS (INDIA) PRIVATE LIMITED OFFICE -  ONE. 169, HARMONY SOCIETY, AUNDH, MAHARASHTRA 411067  411062', 20, '0-30', 'May, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    8328, 'Maharashtra', 'Mumbai', 'LOA00002665', 'GDWPS9023Q', 'ACGLLLOT00000004067', 'KEVAL  SHAH', 9985485052, 'KEVAL.VORA52@GMAIL.COM',
    20000, 17000, 2542, 458, 3000, 457.63, 0, 0, 2542.37,
    33, 0.75, 24950, '2026-05-28', '2026-06-30', '''50100798605951', 'HDFC BANK',
    'HDFC0001574', 'INF/NEFT/IN42614857468623/HDFC0001574/72210112 /DISBURSE                      /KEVALSHAH', 'DISBURSED', 'REPEAT', 'POOJA', NULL,
    '501, CTS NO 186 186 1 TO 4 VILLAGE MALAD S. LIBERTY GARDEN, NEAR GANESH SRA, MALAD (W), MUMBAI, 400064 VILLAGE MALAD 400064', 'GALLAGHER SERVICE CENTER LLP 6TH FLOOR, C, EMBASSY 247 PARK, LAL BAHADUR SHASTRI MARG, VIKHROLI WEST, MUMBAI, MAHARASHTRA 400083 EMBASSY 247 PARK, 400083', 20, '0-30', 'May, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    8333, 'Telangana', 'Hyderabad', 'LOA00003204', 'CMZPK9323D', 'ACGLLLOT00000004074', 'KARUR MADHU SIMHA', 7981124741, 'MADHUSIMHA01@GMAIL.COM',
    15000, 12750, 1907, 343, 2250, 343.22, 0, 0, 1906.78,
    33, 0.75, 18712.5, '2026-05-28', '2026-06-30', '''5739831558', 'AXIS BANK',
    'UTIB0005151', 'INF/NEFT/IN42614857487230/UTIB0005151/72211358 /DISBURSE                      /KARURMADHUS', 'DISBURSED', 'REPEAT', 'GARISHMA', NULL,
    '3-4,137 LOKHANDE APARTMENTS, APT 104,SHALINI HOSPITALS, BARKATPURA, KACHIGUDA HYDERABAD, TELANGANA, 500027', 'SYNCHRONY INTERNATIONAL SERVICES PRIVATE LIMITED KNOWLEDGE CITY, SALARPURIA SATTVA, BUILDING PHASE 3, SERLINGAMPALLY, 500032  500031', 20, '0-30', 'May, 2026', 'PART-PAYMENT'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    8334, 'Karnataka', 'Bangalore', 'LOA00003635', 'AKEPV4456D', 'ACGLLLOT00000004075', 'VINOD  VIDYADHARAN', 9947091211, 'VVINOD143@GMAIL.COM',
    50000, 42500, 6356, 1144, 7500, 1144.07, 0, 0, 6355.93,
    33, 0.75, 62375, '2026-05-28', '2026-06-30', '''27111140002882', 'HDFC BANK',
    'HDFC0002711', 'INF/NEFT/IN42614857487805/HDFC0002711/72211358 /DISBURSE                      /VINODVIDYAD', 'DISBURSED', 'REPEAT', 'POOJA', NULL,
    'F202,ORCHID WOODS,HORAMAVU, BANGALORE,ORCHID WOODS,BANGALORE,KARNATAKA,560 077 BANGALORE, KARNATAKA, 560077 F202,ORCHID WOODS,HORAMAVU, BANGALORE,ORCHID WOODS,BANGALORE,KARNATAKA,560 077 BANGALORE, KARNATAKA, 560077  560077', 'PROJECT44 SOFTWARE SERVICES PRIVATE LIMITED SIXTH FLOOR, ZONASHA IT BUILDING, MAHADEVAPURA, BANGALORE. 560048 SIXTH FLOOR, ZONASHA IT BUILDING, MAHADEVAPURA, BANGALORE. 560048  560048', 20, '0-30', 'May, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    8335, 'Telangana', 'Hyderabad', 'LOA00003533', 'AMYPG8757E', 'ACGLLLOT00000004076', 'GURRAM  SREEKANTH', 8978369465, 'GURRAM.SREE7@GMAIL.COM',
    47000, 39950, 5975, 1075, 7050, 1075.42, 0, 0, 5974.58,
    33, 0.75, 58632.5, '2026-05-28', '2026-06-30', '''111801515645', 'ICICI BANK LIMITED',
    'ICIC0001118', 'INF/INFT/044565197711/72211358     /GURRAMSREEKANTH     /DISBURSE', 'DISBURSED', 'REPEAT', 'GARISHMA', NULL,
    'DETAILS AS OR C/O GURRAM VENKATA RAMANAIAH, 10-3-28 AND 29 FLAT NO 402 PONNERI RESIDENCY, STREET NO 7, OPPOSITE TO PARK, EAST MARREDPALLY, SECUNDERABAD, PO: NEHRUNAGAR,  500026', 'ICF CONSULTING INDIA PRIVATE LIMITED CADDIE COMMERCIAL TOWER @ AERO CITY DIAL 2ND FLOOR, NEW DELHI, DELHI 110037  110037', 20, '0-30', 'May, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    8315, 'Maharashtra', 'Mumbai', 'LOA00003881', 'AJXPB9478R', 'ACGLLLOT00000004088', 'DHARMENDRA KUMAR RAMSURAT BHARTI', 8169182290, 'DHARAM_B@HOTMAIL.COM',
    20000, 17000, 2542, 458, 3000, 457.63, 0, 0, 2542.37,
    36, 0.75, 25400, '2026-05-29', '2026-07-04', '''920010067123025', 'AXIS BANK',
    'UTIB0000018', 'INF/NEFT/IN42614957719687/UTIB0000018/72231069 /DISBURSE                      /DHARMENDRAK', 'DISBURSED', 'NEW', 'GARISHMA', 'KISHAN KUMAR',
    '1611 BLDG NO.R/8B, SRA BUILDING, MALAD (E) AT-APPAPADA KURAR VILLAGE, MUMBAI MAHARASHTRA 400097  400097', 'POLYSET PLASTICS PVT. LTD 901-906, IB PATEL RD, JAY PRAKASH NAGAR, GOREGAON EAST, MUMBAI, MAHARASHTRA 400063 901-906, IB PATEL RD, JAY PRAKASH NAGAR, GOREGAON EAST, MUMBAI, MAHARASHTRA 400063  400063', 16, '0-30', 'May, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    8351, 'Karnataka', 'Bangalore', 'LOA00003323', 'FYQPS6426D', 'ACGLLLOT00000004083', 'SANTHOSH KUMAR SK', 8217571019, 'KRISHNEGOWDASANTHOSH@GMAIL.COM',
    25000, 21250, 3178, 572, 3750, 572.03, 0, 0, 3177.97,
    31, 0.75, 30812.5, '2026-05-29', '2026-06-29', '''67370100004141', 'BANK OF BARODA',
    'BARB0VJCHPT', 'INF/NEFT/IN42614957651840/BARB0VJCHPT/72222827 /                              /SANTHOSHKUM', 'DISBURSED', 'REPEAT', 'SHIVANI JOSHI', 'KISHAN KUMAR',
    '4,5TH MAIN, 7TH CROSS, K EMPAMMADEVI LAYOUT MARIYAPPANAPALYA BANGALORE 560056 LANDMARK KUTTERA PARK LAND 560056', 'STREAMLINE HEALTHCARE SOLUTIONS (INDIA) PRIVATE LIMITED TH FLOOR, FAIRWAY BUSINESS PARK, DOMLUR BANGALORE 560071 LANDMARK EGL GATE  560071', 21, '0-30', 'May, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    8361, 'Haryana', 'Faridabad', 'LOA00003879', 'CYMPK7681R', 'ACGLLLOT00000004086', 'VIJAY  KUMAR', 9711596174, 'VIJAYGEHLAWAT071@GMAIL.COM',
    25000, 21250, 3178, 572, 3750, 572.03, 0, 0, 3177.97,
    32, 0.75, 31000, '2026-05-29', '2026-06-30', '''13810100224630', 'FEDERAL BANK',
    'FDRL0001381', 'INF/NEFT/IN42614957719743/FDRL0001381/72231069 /DISBURSE                      /VIJAYKUMAR', 'DISBURSED', 'NEW', 'PAYAL SHARMA', 'KISHAN KUMAR',
    '6322 MCF- 390 GALI N-12,PARVATIYA COLONY WARD N-6 PART 2 FARIDABAD,PARVATIY A COLONY WARD PARVATIY A COLONY WARD N-6 PART 2 FARIDABAD FARIDABAD FARIDABAD SECTOR 22, HARYANA COLONY WARD PARVATIY A 121005', 'BAJAJ LIFE INSURANCE LTD 58&59 HOODA MARKET SECTER 19 NEAR SANJHA CHULHA FARIDABAD 58&59 HOODA MARKET SECTER 19 NEAR SANJHA CHULHA FARIDABAD HOODA MARKET 121002', 20, '0-30', 'May, 2026', 'PART-PAYMENT'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    8393, 'Karnataka', 'Bangalore', 'LOA00003884', 'APPPP2551M', 'ACGLLLOT00000004119', 'A N PRAKASH', 9980523248, 'PREKKU23@GMAIL.COM',
    25000, 21250, 3178, 572, 3750, 572.03, 0, 0, 3177.97,
    32, 0.75, 31000, '2026-05-29', '2026-06-30', '''5459224809', 'AXIS BANK',
    'UTIB0005157', 'INF/NEFT/IN42614958163001/UTIB0005157/72276217 /DISBURSE                      /ANPRAKASH', 'DISBURSED', 'NEW', 'SHIVANI JOSHI', 'KISHAN KUMAR',
    'NO.91 KEMPANNA LAYOUT DWARAKAMAYI APARTMENT GOWDANPALYA UTTARAHALLI BENGALURU 560061  560061', 'ACCENTURE SOLUTIONS PVT LTD TOWER A,119, GOSHALA RD, GARUDACHAR PALYA, MAHADEVAPURA, BANGALORE BANGALORE KARNATAKA 560048  560048', 20, '0-30', 'May, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    8400, 'Telangana', 'Hyderabad', 'LOA00003360', 'FVRPS6673C', 'ACGLLLOT00000004105', 'SIVA SHANKAR REDDY SOWDURI', 8686082836, 'IAMSIVA22@GMAIL.COM',
    40000, 34000, 5085, 915, 6000, 915.25, 0, 0, 5084.75,
    32, 0.75, 49600, '2026-05-29', '2026-06-30', '''3948135841', 'KOTAK MAHINDRA BANK',
    'KKBK0008527', 'INF/NEFT/IN42614957985238/KKBK0008527/72261712 /DISBURSE                      /SIVASHANKAR', 'DISBURSED', 'REPEAT', 'PAYAL SHARMA', 'KISHAN KUMAR',
    '3RD  FLOOR FLAT NO 302 SHIVAAHAN RESIDENCY ROAD NO 16 PANCHAVATI COLONY MANIKONDA PANCHAVATI COLONY MANIKONDA 500082', 'GSR BUSINESS SERVICES PRIVATE LIMITED WEST WING, KHIVRAJ BUILDING PLOT NO.6, ELECTRICAL & ELECTRONIC INDUSTRIAL ESTATE, PERUNGUDI ESTATE, PERUNGUDI, CHENNAI LANDMARK:, ABOVE MARUTI SUZUKI ARENA 600096', 20, '0-30', 'May, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    8408, 'Telangana', 'Hyderabad', 'LOA00003226', 'AUMPB5949F', 'ACGLLLOT00000004110', 'MANIT KUMAR BHATTACHARJEE', 9121010269, 'MBDJONES2@GMAIL.COM',
    40000, 34000, 5085, 915, 6000, 915.25, 0, 0, 5084.75,
    31, 0.75, 49300, '2026-05-29', '2026-06-29', '''50100412716061', 'HDFC BANK',
    'HDFC0004299', 'INF/NEFT/IN42614958054421/HDFC0004299/72269031 /DISBURSE                      /MANITKUMARB', 'DISBURSED', 'REPEAT', 'POOJA', NULL,
    '402 SRINIVASA RESIDENCY, PLOT 86/C RADHANAGAR STREET 1 BANDLAGUDA JAGIR, HYDERABAD 500086 LANDMARK- KK CONVENTION HALL  500086', 'GALLAGHER INSURANCE BROKERS LIMITED AWFIS SPACE SOLUTION, 1ST FLOOR, KOTHAGUDA, HYDERABAD 500032 LANDMARK- KOTHAGUDA CROSSING, SKODA SHOWROOM  500031', 21, '0-30', 'May, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    8412, 'West Bengal', 'Kolkata', 'LOA00003216', 'GELPS0044P', 'ACGLLLOT00000004115', 'SIDDHARTH KUMAR SINGH', 8582956741, 'SIDFUNKYSPV@GMAIL.COM',
    30000, 25500, 3814, 686, 4500, 686.44, 0, 0, 3813.56,
    32, 0.75, 37200, '2026-05-29', '2026-06-30', '''105601568191', 'ICICI BANK LIMITED',
    'ICIC0001056', 'INF/INFT/044576976991/72273077     /SIDDHARTHKUMARSINGH /DISBURSE', 'DISBURSED', 'REPEAT', 'POOJA', NULL,
    '146 , SODEPUR KALITALA 2ND LANE POST OFFICE :- HARIDEVPUR,  KOLKATA 700082  700082', 'DELOITTE TOUCHE TOHMATSU INDIA LLP BENGAL INTELLIGENT PARK,  EP GP BLOCK, SECTOR 5,  KOLKATA :- 700091 OPPOSITE TO PANTALOONS SHOWROOM 700090', 20, '0-30', 'May, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    8414, 'Delhi', 'New Delhi', 'LOA00003198', 'ADPPB9836R', 'ACGLLLOT00000004123', 'SUMANTA  BISWAS', 9477321368, 'SUMANB73@GMAIL.COM',
    16000, 13600, 2034, 366, 2400, 0, 183.05, 183.05, 2033.9,
    32, 0.75, 19840, '2026-05-29', '2026-06-30', '''0389010291510', 'PUNJAB NATIONAL BANK',
    'PUNB0038920', 'INF/NEFT/IN42614958118400/PUNB0038920/72274411 /DISBURSE                      /SUMANTABISW', 'DISBURSED', 'REPEAT', 'GARISHMA', NULL,
    'S/O CHARAN SINGH HNO-20 GROUND FLOOR, GALI NO-6 EAST LAXMI MARKET DELHI NEAR SHI MANDIR 110092', 'COAL CONTROLLER ORGANISATION, MINISTRY OF COAL, GOVERNMENT OF INDIA COAL CONTROLLER ORGANISATION,SCOPE MINAR, CORE-1, 5TH FLOOR, LAXMI NAGAR  110092', 20, '0-30', 'May, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    8422, 'Gujarat', 'Ahmedabad', 'ADV00000993', 'AHNPT8857G', 'ACGLLLOT00000004124', 'SANJANA VIJAY TALREJA', 7411783434, 'SVIDHANI12@GMAIL.COM',
    28000, 23800, 3559, 641, 4200, 640.68, 0, 0, 3559.32,
    32, 0.75, 34720, '2026-05-29', '2026-06-30', '''324401501698', 'ICICI BANK LIMITED',
    'ICIC0000295', 'INF/INFT/044577317881/72274411     /SANJANAVIJAYTALREJA /DISBURSE', 'DISBURSED', 'REPEAT', 'DEEPAK KUMAR', NULL,
    '4 A NARAIN NIVAS SAHJIVAN SOCIETY OPP SINDHUNAGAR SOCIETY OLD WADAJ AHMEDABAD 380013 SAHJIVAN SOCIETY 380013', 'JEC ADIUVO INDIA PVT LTD TEJAS ARCADE B BLOCK MILK COLONY ROAD SUBRAMANYANAGAR BANGALORE 560030 SUBRAMANYANAGAR 560030', 20, '0-30', 'May, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    8425, 'Maharashtra', 'Pune', 'LOA00003290', 'BEZPD0506C', 'ACGLLLOT00000004127', 'DINESH  DAHIYA', 7756080928, 'DAHIYADINESH775@GMAIL.COM',
    15000, 12750, 1907, 343, 2250, 343.22, 0, 0, 1906.78,
    32, 0.75, 18600, '2026-05-29', '2026-06-30', '''098601555992', 'ICICI BANK LIMITED',
    'ICIC0000986', 'INF/INFT/044577879261/72276217     /DINESHDAHIYA/DISBURSE', 'DISBURSED', 'REPEAT', 'PAYAL SHARMA', NULL,
    'FLAT NO 507 NEAR INDIRA COLLEGE VIDYA VALLEY SCHOOL ROAD , WAKAD, PUNE PANACHE - PRASANNA DEVELOPERS, NEAR BHUMKAR CHOW, MAHARASHTRA, INDIA PUNE MAHARASHTRA, 411057 FLAT NO 507 NEAR INDIRA COLLEGE VIDYA VALLEY SCHOOL ROAD , WAKAD, PUNE PANACHE - PRASANNA DEVELOPERS, NEAR BHUMKAR CHOW, MAHARASHTRA, INDIA PUNE MAHARASHTRA, 411057  411057', 'NCSI TECHNOLOGY BLUE RIDGE - PARANJPE SCHEMES,IT 07,05TH FLOOR, PHASE 1, HINJAWADI RAJIV GANDHI INFOTECH PARK, HINJAWADI, HINJAVADI, MAHARASHTRA 411057 BLUE RIDGE - PARANJPE SCHEMES,IT 07,05TH FLOOR, PHASE 1, HINJAWADI RAJIV GANDHI INFOTECH PARK, HINJAWADI, HINJAVADI, MAHARASHTRA 411057  411057', 20, '0-30', 'May, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    8421, 'Telangana', 'Hyderabad', 'LOA00002625', 'ASQPP6496F', 'ACGLLLOT00000004139', 'PAVULURI BIPIN CHANDRA', 9985641904, 'PAVULURIBIPIN@GMAIL.COM',
    65000, 55250, 8263, 1487, 9750, 1487.29, 0, 0, 8262.71,
    31, 0.75, 80112.5, '2026-05-30', '2026-06-30', '''20132130779', 'STATE BANK OF INDIA',
    'SBIN0011081', 'INF/NEFT/IN42615058416454/SBIN0011081/72293274 /DISBURSE                      /PAVULURIBIP', 'DISBURSED', 'REPEAT', 'POOJA', 'KISHAN KUMAR',
    'FLAT 402, STERLING HEIGHTS APARTMENTS, NEAR RL CITY, MAYURI NAGAR, NIJAMPET, HYDERABAD-500049 MAYURI NAGAR, NIJAMPET, HYDERABAD-500049 500048', 'DURA AUTOMOTIVE SERVICES I PVT LTD , HQ4, SADGURU CAPITAL PARK, MADHAPUR, NEAR HITECH CITY, HYDERABAD, TELANGANA-500081 DURA AUTOMOTIVE SERVICES I PVT LTD  500081', 20, '0-30', 'May, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    8430, 'Karnataka', 'Bangalore', 'LOA00003503', 'AMDPK9103H', 'ACGLLLOT00000004134', 'KR ANJAN KUMAR', 9880044900, 'ANJAN_123@YAHOO.COM',
    90000, 76500, 11441, 2059, 13500, 2059.32, 0, 0, 11440.68,
    31, 0.75, 110925, '2026-05-30', '2026-06-30', '''20042236802', 'STATE BANK OF INDIA',
    'SBIN0007989', 'INF/NEFT/IN42615058361681/SBIN0007989/72288314 /DISBURSE                      /KRANJANKUMA', 'DISBURSED', 'REPEAT', 'SHIVANI JOSHI', 'KISHAN KUMAR',
    '67 1ST FLOOR 3RD MAIN ROAD 2ND STAGE BENGALURU 560040', 'HSBC 80/A & 80/B, ECOSPACE CAMPUS, HSBC EAST B7, BELLANDUR, SARJAPUR RING ROAD 560007', 20, '0-30', 'May, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    8455, 'Karnataka', 'Bangalore', 'LOA00003639', 'ABGPN9661F', 'ACGLLLOT00000004137', 'MANOJ KUMAR G', 9845588502, 'MKG2367@GMAIL.COM',
    45000, 38250, 5720, 1030, 6750, 1029.66, 0, 0, 5720.34,
    31, 0.75, 55462.5, '2026-05-30', '2026-06-30', '''8811010001108804', 'DBS BANK LTD',
    'DBSSOINO811', 'MMT/IMPS/615022254473/BULD72334355/MANOJKUMAR/UTIB0005110', 'DISBURSED', 'REPEAT', 'DEEPAK KUMAR', NULL,
    '1187 GROUND FLOOR  3RD CROSS NEW THIPPASANDRA  BANGALORE 560075  560075', 'KYNDRYL SOLUTIONS PRIVATE LIMITED M3 MANYATA TECH PARK HEBBAL BANGALORE  560045  560045', 20, '0-30', 'May, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    8466, 'Karnataka', 'Bangalore', 'LOA00003370', 'AAQPI8293M', 'ACGLLLOT00000004130', 'IRSHATH  BASHA', 8122760427, 'IRSHATHBASHA@GMAIL.COM',
    25000, 21250, 3178, 572, 3750, 572.03, 0, 0, 3177.97,
    31, 0.75, 30812.5, '2026-05-30', '2026-06-30', '''106001507413', 'ICICI BANK LIMITED',
    'ICIC0000398', 'INF/INFT/044581533821/72288314     /IRSHATHBASHA/DISBURSE', 'DISBURSED', 'REPEAT', 'POOJA', NULL,
    'VYALIKAVAL HBCS LAYOUT,,NAGAWARA,  BENGALURU, KARNATAKA 560045 VYALIKAVAL HBCS LAYOUT,,NAGAWARA,  BENGALURU, KARNATAKA 560045  560045', 'MANIPAL ACADEMY OF HIGHER EDUCATION, MANIPAL SURVEY NO 23, 27, THANISANDRA MAIN RD, CHOKKANAHALLI, BENGALURU, KARNATAKA 560064 LANDMARK : NEAR BANK OF BARODA ATM SURVEY NO 23, 27, THANISANDRA MAIN RD, CHOKKANAHALLI, BENGALURU, KARNATAKA 560064 LANDMARK : NEAR BANK OF BARODA ATM  560064', 20, '0-30', 'May, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    8471, 'Karnataka', 'Bangalore', 'LOA00002951', 'AMLPG3642F', 'ACGLLLOT00000004136', 'R GIRINATHA REDDY', 9620666642, 'RGREDDY82@GMAIL.COM',
    30000, 25500, 3814, 686, 4500, 686.44, 0, 0, 3813.56,
    31, 0.75, 36975, '2026-05-30', '2026-06-30', '''10270781319', 'IDFC BANK LTD',
    'IDFB0081181', 'INF/NEFT/IN42615058361718/IDFB0081181/72288314 /DISBURSE                      /RGIRINATHAR', 'DISBURSED', 'REPEAT', 'GARISHMA', NULL,
    'MR R GIRINATHAREDDY FLAT 206 VANDHANA HOMES,,,MANIPAL COUNTY ROAD, AISHWARYA CRYSTAL LAYOUT, N EAR MR ENCLAVE APTS, SINGASANDRA,BANGALORE,,KARNATAKA,560068 BANGALORE, KARNATAKA, 560068, MR R GIRINATHAREDDY FLAT 206 VANDHANA HOMES,,,MANIPAL COUNTY ROAD, AISHWARYA CRYSTAL LAYOUT, N EAR MR ENCLAVE APTS, SINGASANDRA,BANGALORE,,KARNATAKA,560068 BANGALORE, KARNATAKA, 560068,  560068', 'ARIS GLOBLE PLOT # 206  OFFICE NO : 165/2  KALYANI MAGNUM,  DORESANIPALYA, BANNERGHATTA RD, JP NAGAR 4TH PHASE, BENGALURU, 560078 PLOT # 206  OFFICE NO : 165/2  KALYANI MAGNUM,  DORESANIPALYA, BANNERGHATTA RD, JP NAGAR 4TH PHASE, BENGALURU, 560078  560011', 20, '0-30', 'May, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    8472, 'West Bengal', 'Kolkata', 'LOA00002812', 'BCFPM0902H', 'ACGLLLOT00000004138', 'MANAS  MUKHERJEE', 9748483743, 'MUKHERJEE.MANAS4@GMAIL.COM',
    21000, 17850, 2669, 481, 3150, 480.51, 0, 0, 2669.49,
    31, 0.75, 25882.5, '2026-05-30', '2026-06-30', '''189748483743', 'INDUSIND BANK',
    'INDB0000015', 'INF/NEFT/IN42615058361712/INDB0000015/72288314 /DISBURSE                      /MANASMUKHER', 'DISBURSED', 'REPEAT', 'DEEPAK KUMAR', NULL,
    '14 RUSSA ROAD SOUTH 2ND LANE TOLLYGUNGE KOLKATA 700033 MR BANGUR HOSPITAL 700033', 'AXIS BANK SOVABAZAR BRANCH 1 RAJA GURUDAS STREET KOLKATA 700006 MINERVA THEATRE 700006', 20, '0-30', 'May, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    8482, 'Telangana', 'Hyderabad', 'ADV00001151', 'BERPM4707E', 'ACGLLLOT00000004142', 'MANI TEJA MAJETI', 8123983016, 'MANITEJAROCKZ@GMAIL.COM',
    30000, 25500, 3814, 686, 4500, 686.44, 0, 0, 3813.56,
    31, 0.75, 36975, '2026-05-30', '2026-06-30', '''8123983016', 'KOTAK MAHINDRA BANK',
    'KKBK0007489', 'INF/NEFT/IN42615058416464/KKBK0007489/72293274 /DISBURSE                      /MANITEJAMAJ', 'DISBURSED', 'REPEAT', 'GARISHMA', NULL,
    '2ND FLOOR H.NO-2-36, CHANDA NAGAR GOUTHAMI NAGAR COLONY HYDERABAD RANGAREDDY TELANGANA-500050  500051', 'CAPGEMINI TECHNOLOGY SERVICES INDIA LIMITED ROAD NO 2, FINANCIAL DISTRICT, GACHIBOWLI, NANAKRAMGUDA, HYDERABAD TELANGANA 500032 ROAD NO 2, FINANCIAL DISTRICT, GACHIBOWLI, NANAKRAMGUDA, HYDERABAD TELANGANA 500032  500031', 20, '0-30', 'May, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    8485, 'Maharashtra', 'Mumbai', 'LOA00003478', 'BKKPS7392L', 'ACGLLLOT00000004146', 'KHUSHI NARENDRA SHARMA', 9920977937, 'KRUASHARMA306@GMAIL.COM',
    22000, 18700, 2797, 503, 3300, 503.39, 0, 0, 2796.61,
    31, 0.75, 27115, '2026-05-30', '2026-06-30', '''920010019755676', 'AXIS BANK',
    'UTIB0000028', 'INF/NEFT/IN42615058416488/UTIB0000028/72293274 /DISBURSE                      /KHUSHINAREN', 'DISBURSED', 'REPEAT', 'DEEPAK KUMAR', NULL,
    '2/1 IRANI BUILDING, GOKHALE ROAD, DADAR MMUMBAI 400028  400028', 'TATA AIG GENERAL INSURANCE COMPANY LTD. ROMELL TECH PARK, NIRLON COMPOUND, GOREGAON EAST 400063  400063', 20, '0-30', 'May, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    8495, 'Haryana', 'Gurgaon', 'LOA00003349', 'ALGPB6182P', 'ACGLLLOT00000004149', 'SOHINI  CHATTERJEE', 9560525353, 'SOHI0510@GMAIL.COM',
    75000, 63750, 9534, 1716, 11250, 1716.1, 0, 0, 9533.9,
    31, 0.75, 92437.5, '2026-05-30', '2026-06-30', '''184301500418', 'ICICI BANK LIMITED',
    'ICIC0001843', 'INF/INFT/044585172541/72305277     /SOHINICHATTERJEE    /DISBURSE', 'DISBURSED', 'REPEAT', 'PAYAL SHARMA', 'KISHAN KUMAR',
    'FLAT NO. F 806, EIGHTH FLOOR, TOWER F, THE MELIA, SOHNA, SECTOR 35, GURGAON 122103', 'JOHNSON MATTHEY INDIA PRIVATE LIMITED PLOT NO.12,SECTOR-3, IMT MANESAR, GURGAON GURGAON 122006', 20, '0-30', 'May, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    8498, 'Telangana', 'Hyderabad', 'LOA00003545', 'AWOPT0021E', 'ACGLLLOT00000004152', 'KADAMATY NAYA TEJA', 8555901077, 'NAYATEJA.KADAMATY@GMAIL.COM',
    42000, 35700, 5339, 961, 6300, 961.02, 0, 0, 5338.98,
    31, 0.75, 51765, '2026-05-30', '2026-06-30', '''404101501227', 'ICICI BANK LTD',
    'ICIC0004041', 'INF/INFT/044584327741/72300674     /KADAMATYNAYATEJA    /DISBURSE', 'DISBURSED', 'REPEAT', 'POOJA', NULL,
    'P NO-5,7 AND 14,16, FLAT D.NO: 103, NIZAMPET, BANDARI LAYOUT, HYDERABAD, TELANGANA, 500090  500090', 'NEXTPOWER INDIA PRIVATE LIMITED. RMZ NEXITY TOWER 20, SILPA GRAM CRAFT VILLAGE, HITEC CITY, HYDERABAD, TELANGANA 500081 KNOWLEDGE CITY BUILDING 500081', 20, '0-30', 'May, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    8502, 'Gujarat', 'Ahmedabad', 'LOA00003278', 'AWIPK2975J', 'ACGLLLOT00000004175', 'RASHESH BHAGVANDAS KHATRI', 9099130017, 'RASH_2112@YAHOO.CO.IN',
    25000, 21250, 3178, 572, 3750, 572.03, 0, 0, 3177.97,
    31, 0.75, 30812.5, '2026-05-30', '2026-06-30', '''085001511971', 'ICICI BANK LIMITED',
    'ICIC0000850', 'INF/NEFT/IN42615058720398/HDFC0000067/72322169 /DISBURSE                      /RASHESHBHAG', 'DISBURSED', 'REPEAT', 'PAYAL SHARMA', 'KISHAN KUMAR',
    '5/A/PAIKY.RAVIKUNJ CO OP H SOC, NR.NARANPURA BUS STOP, OPP.NAKSHI FARNICHAR, NARANPURA AHMEDABAD 380013', 'DNATA INTERNATIONAL PRIVATE LIMITED FIRST FLOOR  PARK CENTRA SECTOR 30  GURGAON- 122001  122001', 20, '0-30', 'May, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    8503, 'Uttar Pradesh', 'Greater Noida', 'LOA00003248', 'AVWPT6524B', 'ACGLLLOT00000004165', 'SHIVAM  TRIVEDI', 9695206644, 'SHIVAMTRIVEDI.PSIT@GMAIL.COM',
    15000, 12750, 1907, 343, 2250, 343.22, 0, 0, 1906.78,
    31, 0.75, 18487.5, '2026-05-30', '2026-06-30', '''32567511231', 'STATE BANK OF INDIA',
    'SBIN0008018', 'INF/NEFT/IN42615058631238/SBIN0008018/72313428 /DISBURSE                      /SHIVAMTRIVE', 'DISBURSED', 'REPEAT', 'GARISHMA', NULL,
    'J8 - 1802,SECTOR 4, NOIDA,NA,AMRAPALI GOLF HOMES KINGSWOOD,,NOIDA,UTTAR P RADESH,201306 J8 - 1802,SECTOR 4, NOIDA,NA,AMRAPALI GOLF HOMES KINGSWOOD,,NOIDA,UTTAR P RADESH,201306  201310', 'HCL TECH  LTD. HCL TECHNOLOGIES LIMITED, PLOT NO. 3A, SEZ, SECTOR -126, NOIDA - 201303 HCL TECHNOLOGIES LIMITED, PLOT NO. 3A, SEZ, SECTOR -126, NOIDA - 201303  201303', 20, '0-30', 'May, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    8509, 'Maharashtra', 'Thane', 'LOA00003677', 'ABOPW8539K', 'ACGLLLOT00000004163', 'LIJO CHANDRAN WILLIAM', 9309847827, 'LIJOWILLIAM559@GMAIL.COM',
    25000, 21250, 3178, 572, 3750, 572.03, 0, 0, 3177.97,
    31, 0.75, 30812.5, '2026-05-30', '2026-06-30', '''60517772882', 'BANK OF MAHARASHTRA',
    'MAHB0001825', 'INF/NEFT/IN42615058631257/MAHB0001825/72313428 /DISBURSE                      /LIJOCHANDRA', 'DISBURSED', 'REPEAT', 'GARISHMA', NULL,
    'FLAT NO. 1103 A WING,ING. SA ORNATE DEVELOPERS  VASAI PALGHAR VASAI-VIRAR CITY, MAHARASHTRA- 401208 FLAT NO. 1103 A WING,ING. SA ORNATE DEVELOPERS  VASAI PALGHAR VASAI-VIRAR CITY, MAHARASHTRA- 401208  401208', 'MEDIABRANDS INDIA PRIVATE LIMITED [3:59 PM, 12/5/2026] +91 93098 47827: ANDHERI EAST SAKI NAKA 401 A  CHIBBER HOUSE 4TH FLOOR  PINCODE 400072 [3:59 PM, 12/5/2026] +91 93098 47827: ANDHERI EAST SAKI NAKA 401 A  CHIBBER HOUSE 4TH FLOOR  PINCODE 400072  400072', 20, '0-30', 'May, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    8511, 'Karnataka', 'Bangalore', 'LOA00003627', 'BOVPG9293R', 'ACGLLLOT00000004159', 'GOUTHAM RAJ R', 8618040482, 'GOUTHAMWANTSJOB@GMAIL.COM',
    30000, 25500, 3814, 686, 4500, 686.44, 0, 0, 3813.56,
    31, 0.75, 36975, '2026-05-30', '2026-06-30', '''074316548006', 'HSBC BANK',
    'HSBC0560002', 'INF/NEFT/IN42615058552292/HSBC0560002/72305277 /DISBURSE                      /GOUTHAMRAJR', 'DISBURSED', 'REPEAT', 'DEEPAK KUMAR', NULL,
    'NO 44 1ST MAIN ROAD NEAR TERACE GARDEN APARTMENT ITTUMADU BANGALORE SOUTH BENGALURU KARNATAKA - 560085  560085', 'SYSTAL TECHNOLOGY SOLUTIONS PRIVATE LIMITED TOWER D, 3RD FLOOR, DIAMOND DISTRICT, HAL OLD AIRPORT RD, KODIHALLI, BENGALURU, KARNATAKA 560008  560008', 20, '0-30', 'May, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    8517, 'Karnataka', 'Bangalore', 'LOA00003371', 'AIUPG5092N', 'ACGLLLOT00000004183', 'GURIJALA NAGESWARA REDDY', 9008147218, 'REDDYGURIJALA456@GMAIL.COM',
    31000, 26350, 3941, 709, 4650, 709.32, 0, 0, 3940.68,
    31, 0.75, 38207.5, '2026-05-30', '2026-06-30', '''45512399337', 'STANDARD CHARTERED BANK',
    'SCBL0036073', 'INF/NEFT/IN42615058719565/SCBL0036073/72322169 /DISBURSE                      /GURIJALANAG', 'DISBURSED', 'REPEAT', 'GARISHMA', NULL,
    'NO 264, 3RD FLOOR, 6TH CROSS, ELECTRIC CITY, GP ROYAL LAYOUT PHACE 2, BANGALORE KARNATAKA - 560100 NO 264, 3RD FLOOR, 6TH CROSS, ELECTRIC CITY, GP ROYAL LAYOUT PHACE 2, BANGALORE KARNATAKA - 560100  560100', 'TATA CONSULTANCY SERVICES TATA CONSULTANCY SERVICES LIMITED B4, THINK CAMPUS. ELECTRONIC CITY PHASE 2. BANGALORE 560100 TATA CONSULTANCY SERVICES LIMITED B4, THINK CAMPUS. ELECTRONIC CITY PHASE 2. BANGALORE 560100  560100', 20, '0-30', 'May, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    8519, 'Telangana', 'Hyderabad', 'LOA00002232', 'CSYPS0832E', 'ACGLLLOT00000004166', 'RAMA VENESWARA RAO SESETTI', 9000289114, 'VENESWARARAO1991@GMAIL.COM',
    35000, 29750, 4449, 801, 5250, 800.85, 0, 0, 4449.15,
    31, 0.75, 43137.5, '2026-05-30', '2026-06-30', '''782701508946', 'ICICI BANK',
    'ICIC0007827', 'INF/INFT/044586598521/72313428     /RAMAVENESWARARAOSESE/DISBURSE', 'DISBURSED', 'REPEAT', 'DEEPAK KUMAR', NULL,
    'F NO 301 OLIVE GREENS SAI AVASA MAYURI NAGAR MIYAPUR BESIDE BOMMARILLU APARTMENTS HYDERABAD  TELANGANA  500049  500048', 'NOVARTIS HEALTHCARE PRIVATE LIMITED KNOWLEDGE CITY  SALARPURIA SATTVA  DURGAM CHERUVU ROAD  HYDERABAD  500032  500031', 20, '0-30', 'May, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    8521, 'Delhi', 'New Delhi', 'LOA00002572', 'HGDPS5447B', 'ACGLLLOT00000004172', 'ROHIT  SHARMA', 8851888416, 'TOPCAREER43@GMAIL.COM',
    32000, 27200, 4068, 732, 4800, 0, 366.1, 366.1, 4067.8,
    31, 0.75, 39440, '2026-05-30', '2026-06-30', '''10034949499', 'Idfc Bank',
    'IDFB0020112', 'INF/NEFT/IN42615058631147/IDFB0020112/72313428 /DISBURSE                      /ROHITSHARMA', 'DISBURSED', 'REPEAT', 'POOJA', NULL,
    '140, AMAR JYOTI KUNJ, MASYUR VIHAR PHASE-1, MAYUR VIHAR PH-1, EAST DELHI, DELHI-110091 AMAR JYOTI KUNJ, 110091', 'DLF HOME DEVELOPERS LIMITED , GURGAON - DELHI EXPY, DLF CYBER CITY, DLF PHASE 2, SECTOR 24, GURUGRAM, HARYANA 122002 NDUSIND BANK METRO STATION 122002', 20, '0-30', 'May, 2026', 'PART-PAYMENT'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    8523, 'West Bengal', 'Kolkata', 'LOA00002987', 'ASBPM3029L', 'ACGLLLOT00000004171', 'SHEIKH  MORSALIN', 9937204949, 'MORSALIN.SHEIKH@GMAIL.COM',
    43000, 36550, 5466, 984, 6450, 983.9, 0, 0, 5466.1,
    31, 0.75, 52997.5, '2026-05-30', '2026-06-30', '''912010059985427', 'AXIS BANK',
    'UTIB0000836', 'INF/NEFT/IN42615058631274/UTIB0000836/72313428 /DISBURSE                      /SHEIKHMORSA', 'DISBURSED', 'REPEAT', 'DEEPAK KUMAR', NULL,
    '15, KARAYA ROAD, 1 ST FLOOR KOLKATA , 700017, NR HOTEL NEW DAIMOND SUITE 700017', 'AXIS BANK LTD AXIS BANK, 3RD FLOOR , 1 SHAKESPEARE SARANI KOLKATA 700071 , NR AC MARKET 700071', 20, '0-30', 'May, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    8532, 'Telangana', 'Hyderabad', 'LOA00003756', 'AYGPG1609K', 'ACGLLLOT00000004199', 'GULLADURTHY  HARINATH', 9885381858, 'GHARIPTPD@GMAIL.COM',
    15000, 12750, 1907, 343, 2250, 343.22, 0, 0, 1906.78,
    31, 0.75, 18487.5, '2026-05-30', '2026-06-30', '''112001517089', 'ICICI BANK LIMITED',
    'ICIC0001120', 'INF/INFT/044590344291/72332601     /GULLADURTHYHARINATH /DISBURSE', 'DISBURSED', 'REPEAT', 'PAYAL SHARMA', 'KISHAN KUMAR',
    'H NO.8-4-422/11, S1 , JEREMY HOUSE PREMNAGAR, ERRAGADDA SANATHNAGAR PO:SANATHNAGAR I E HYDERABAD JEREMY HOUSE 500018', 'RAINBOW CHILDRENS MEDICARE LIMITED RAINBOW CHILDRENS HOSPITAL, ROAD NO 2 BANJARA HILLS, HYDERABAD RAINBOW CHILDRENS HOSPITAL 500018', 20, '0-30', 'May, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    8534, 'Maharashtra', 'Mumbai', 'LOA00003400', 'DCXPS7416A', 'ACGLLLOT00000004178', 'FAHIM GHULAM JILANI SAYED', 9819807794, 'SAYEDFAHIM25@YAHOO.IN',
    21000, 17850, 2669, 481, 3150, 480.51, 0, 0, 2669.49,
    31, 0.75, 25882.5, '2026-05-30', '2026-06-30', '''50100221891902', 'HDFC BANK',
    'HDFC0000665', 'INF/NEFT/IN42615058720342/HDFC0000665/72322169 /DISBURSE                      /FAHIMGHULAM', 'DISBURSED', 'REPEAT', 'DEEPAK KUMAR', NULL,
    'B 102 INDIAN OCEAN SAGAR CITY VP ROAD ANDHERI WEST MUMBAI 400058  400058', 'SHRIRAM FINANCE LIMITED SOLITAIRE CORPORATE PATK 6TH FLOOR CHAKALA ANDHERI EAST MUMBAI 400093  400093', 20, '0-30', 'May, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    8537, 'Karnataka', 'Bangalore', 'LOA00003492', 'DOIPR4849F', 'ACGLLLOT00000004181', 'ABBIREDDY MAHESH BHUPATHI RAYUDU', 9502534368, 'RAYUDUAMB1@GMAIL.COM',
    35000, 29750, 4449, 801, 5250, 800.85, 0, 0, 4449.15,
    26, 0.75, 41825, '2026-05-30', '2026-06-25', '''50100349623977', 'HDFC BANK',
    'HDFC0004075', 'INF/NEFT/IN42615058719734/HDFC0004075/72322169 /DISBURSE                      /ABBIREDDYMA', 'DISBURSED', 'REPEAT', 'POOJA', NULL,
    '2-178 , NEELAM THOTA DIWAN CHERUVU , RAJANAGARAM MANDAL RAJANAGARAM EAST GODAVARI ANDHRA PRADESH DIWAN CHERUVU 560043', 'NOKIA SOLUTIONS AND NETWORKS INDIA PRIVATE LIMITED E2 BUILDING MANYATA TECH PARK NEAR NAGAWARA BANGALORE BANGALORE KARNATAKA NEAR NAGAWARA 560045', 25, '0-30', 'May, 2026', 'PART-PAYMENT'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    8556, 'Tamil Nadu', 'Chennai', 'LOA00003676', 'AZUPR7151C', 'ACGLLLOT00000004197', 'R  GUHAPRASAD', 9999969058, 'RGUHA.PRASAD@YAHOO.COM',
    35000, 29750, 4449, 801, 5250, 800.85, 0, 0, 4449.15,
    31, 0.75, 43137.5, '2026-05-30', '2026-06-30', '''002101592903', 'ICICI BANK LIMITED',
    'ICIC0000021', 'INF/INFT/044589377031/72328349     /RGUHAPRASAD/DISBURSE', 'DISBURSED', 'REPEAT', 'DEEPAK KUMAR', NULL,
    'A 1103, XS REAL CATALUNYA CITY, FLAMENCO PHASE 2A SIRUSERI CHENNAI TAMIL NADU 603103  600100', 'SHELL INDIA MP LTD - SSSC SHELL CENTRE CHENNAI, 200 FT RADIAL ROAD, PALLIKARANAI, CHENNAI, TAMIL NADU 600100  600100', 20, '0-30', 'May, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    8567, 'Karnataka', 'Bangalore', 'LOA00003771', 'FSZPK2156K', 'ACGLLLOT00000004219', 'N  KENCHARAJ', 8884871994, 'KENCH.RAJ006@GMAIL.COM',
    15000, 12750, 1907, 343, 2250, 343.22, 0, 0, 1906.78,
    31, 0.75, 18487.5, '2026-05-30', '2026-06-30', '''369401506096', 'ICICI BANK LIMITED',
    'ICIC0003694', 'INF/INFT/044590915521/72334355     /NKENCHARAJ/DISBURSE', 'DISBURSED', 'REPEAT', 'PAYAL SHARMA', 'KISHAN KUMAR',
    'NO.13/14 K,NO.101 2ND CROSS 11TH MAIN M SATHISH REDDY LAYOUT BEGUR ROAD HONGASANDRA BENGALURU MAIN M SATHISH REDDY LAYOUT 560068', 'HURON EURASIA INDIA PRIVATE LIMITED TOWER A, GLOBAL TECHNOLOGY PARK, 9TH FLOOR OUTER RING RD, NEAR MARRIOTT HOTEL DEVARABISANAHALLI, BENGALURU, KARNATAKA TECHNOLOGY PARK 560103', 20, '0-30', 'May, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    8569, 'Karnataka', 'Bangalore', 'LOA00003588', 'ANOPN9827F', 'ACGLLLOT00000004208', 'SANTHOSH  N', 9886722824, 'SANTHOSH.N2@GMAIL.COM',
    50000, 42500, 6356, 1144, 7500, 1144.07, 0, 0, 6355.93,
    31, 0.75, 61625, '2026-05-30', '2026-06-30', '''390301504310', 'ICICI BANK LTD',
    'ICIC0003903', 'INF/INFT/044590919121/72334355     /SANTHOSHN/DISBURSE', 'DISBURSED', 'REPEAT', 'PAYAL SHARMA', 'KISHAN KUMAR',
    'NO 3 AND 4 AKASH VAIBHAV APARTMENT F2 FIRST FLOOR 12TH A MAIN ROAD KAVERINA GAR,BOMMANAHALLI BANGA LORE,BOMMANAHALLI BOMMANAHALLI, KARNATAKA, 560068 560068', 'DELOITTE & TOUCHE ASSURANCE & ENTERPRISE RISK SERVICES INDIA PRIVATELIMITED SURVEY NO 123 & 132/2 DIVYA SHREE TECHNOPOLIS  BLOCK C OLD AIRPORT ROAD  YEMLUR  BENGALURU -560037  560037', 20, '0-30', 'May, 2026', 'PART-PAYMENT'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    8578, 'Telangana', 'Hyderabad', 'ADV00000734', 'ARPPB6045C', 'ACGLLLOT00000004213', 'BURRA  KARTHIK', 9959088612, 'BURRA.KARTHIK@GMAIL.COM',
    24000, 20400, 3051, 549, 3600, 549.15, 0, 0, 3050.85,
    31, 0.75, 29580, '2026-05-30', '2026-06-30', '''20149926589', 'STATE BANK OF INDIA',
    'SBIN0017896', 'MMT/IMPS/615020107042/BULD72332601/BURRAKARTH/SBIN0017896', 'DISBURSED', 'REPEAT', 'DEEPAK KUMAR', NULL,
    '6-17-19, DWARAKA RESIDENCY, RAMPALLY KEESARA MANDAL, RAMPALLE,PO:ROMPALLI,DIST:MEDCHAL-MALKAJGIRI  501301', 'RELIANCE INDUSTRIES LTD 1-801, JAYASHREE COMPLEX, BHONGIR  508116', 20, '0-30', 'May, 2026', 'PART-PAYMENT'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    8579, 'Karnataka', 'Bangalore', 'LOA00003801', 'AUUPA6695H', 'ACGLLLOT00000004215', 'ANANTHARAJ  BALACHANDRAN', 9739152937, 'ANANTH.CHANDRAN@GMAIL.COM',
    40000, 34000, 5085, 915, 6000, 915.25, 0, 0, 5084.75,
    31, 0.75, 49300, '2026-05-30', '2026-06-30', '''913010057227106', 'AXIS BANK',
    'UTIB0000052', 'MMT/IMPS/615020105676/BULD72332601/ANANTHARAJ/UTIB0000052', 'DISBURSED', 'REPEAT', 'PAYAL SHARMA', 'KISHAN KUMAR',
    'JJ RESIDENCY,81 & 88, FLAT NO: 103,1ST FLOOR,6TH B CROSS, DODDANEKKUNDI EXTENSION, CHINNAPANAHALLI BENGALURU, KARNATAKA NEAR OM SAKTHI TEMPLE 560037', 'DEVON SOFTWARE SERVICES PVT LTD DEVON SOFTWARE SERVICES PVT LTD 2A WEST TOWER ETV VILLAGE DEVERABEESANAHALLI DEVERABEESANAHALLI  VARTHUR HOBLI BANGALORE WEST TOWER ETV 560087', 20, '0-30', 'May, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    8581, 'Telangana', 'Hyderabad', 'LOA00003354', 'CMGPM9733A', 'ACGLLLOT00000004217', 'MADURI SAI KRISHNA', 9676460506, 'SAIKRISHNA.M100@GMAIL.COM',
    30000, 25500, 3814, 686, 4500, 686.44, 0, 0, 3813.56,
    31, 0.75, 36975, '2026-05-30', '2026-06-30', '''916010032368728', 'AXIS BANK',
    'UTIB0000008', 'MMT/IMPS/615022254913/BULD72334355/MADURISAIK/UTIB0000008', 'DISBURSED', 'REPEAT', 'PAYAL SHARMA', 'KISHAN KUMAR',
    'FLAT NO-3668 4TH FLOOR ROAD NO-7 PHASE-2 VIDYUTH NAGAR MIG HYDERABAD TELANGANA 502032  500003', 'WELLS FARGO CENTRE, BUILDING WELLS FARGO CENTRE, BUILDING 1A, D IVYASREE NSL SEZ SURVEY NO. 66/1, RAIDURGA VILLAGE, SERLINGAMPALLI, HYDERABAD, TELANGANA 500032, INDIA. 500031', 20, '0-30', 'May, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    8585, 'West Bengal', 'Kolkata', 'ADV00000920', 'AIFPC0858F', 'ACGLLLOT00000004218', 'SAYANTANI  CHOUDHURY', 9920541531, 'SAYANTANI.CHOUDHURY.17@GMAIL.COM',
    45000, 38250, 5720, 1030, 6750, 1029.66, 0, 0, 5720.34,
    31, 0.75, 55462.5, '2026-05-30', '2026-06-30', '''572501000016', 'ICICI BANK',
    'ICIC0005725', 'INF/INFT/044590919271/72334355     /SAYANTANICHOUDHURY  /DISBURSE', 'DISBURSED', 'REPEAT', 'POOJA', NULL,
    'P-57 S.N.ROY ROAD  700038', 'KEYSIGHT TECHNOLOGIES INDIA PVT. LTD INFINITY THINK TANK FLOOR 8, SEC 5, KOL-700099  700099', 20, '0-30', 'May, 2026', 'PART-PAYMENT'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    8596, 'Maharashtra', 'Mumbai', 'LOA00003641', 'ARJPP2023L', 'ACGLLLOT00000004223', 'OSCAR BONAVENTURE PATEL', 9920087737, 'OSCARPATEL2@GMAIL.COM',
    25000, 21250, 3178, 572, 3750, 572.03, 0, 0, 3177.97,
    30, 0.75, 30625, '2026-05-31', '2026-06-30', '''5413953113', 'AXIS BANK BRANCH',
    'UTIB0005113', 'MMT/IMPS/615113933583/BULD72338511/OSCARBONAV/UTIB0005113', 'DISBURSED', 'REPEAT', 'DEEPAK KUMAR', NULL,
    '99 VILLA 2ND FLR RM NO 203 KHARODHI VILLAGE MARVE ROAD MALAD WEST -400095  400095', 'TATA CONSULTANCY SERVICES TRILL IT PARK 4 AWING2ND FLR OPP KOTAK BANK GOREGAON EAST -400097  400097', 20, '0-30', 'May, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    8600, 'Karnataka', 'Bangalore', 'LOA00003457', 'APAPM5927P', 'ACGLLLOT00000004227', 'BISHWAJIT  MUKHERJEE', 7406781309, 'BISHWAJIT210@REDIFFMAIL.COM',
    25000, 21250, 3178, 572, 3750, 572.03, 0, 0, 3177.97,
    30, 0.75, 30625, '2026-05-31', '2026-06-30', '''50100728811185', 'HDFC BANK',
    'HDFC0002841', 'MMT/IMPS/615113933527/BULD72338511/BISHWAJITM/HDFC0002841', 'DISBURSED', 'REPEAT', 'PAYAL SHARMA', 'KISHAN KUMAR',
    'RADIANT RESHAN APPARTMENT  FLAT NO 204 BTM RESIDENCY PHASE 1&2 AKSHAYA NAGAR AKSHAYA NAGAR 560068', 'PREMAS LIFE SCIENCES PVT LTD NO777,31/2 FIRST FLOOR NTI LAYOUT SECOND PHASE RAJEN GANDHI NAGAR SAHAKAR NAGAR 2 ND PHASE RAJEN GANDHI NAGAR 560092', 20, '0-30', 'May, 2026', 'PART-PAYMENT'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    8603, 'Maharashtra', 'Thane', 'ADV00000994', 'AHHPB8964A', 'ACGLLLOT00000004230', 'BHUPESH LAL BHATIA', 9820667836, 'BHUPESH.BHATIA.L@GMAIL.COM',
    40000, 34000, 5085, 915, 6000, 915.25, 0, 0, 5084.75,
    31, 0.75, 49300, '2026-05-31', '2026-06-30', '''1541019820667836', 'UTKARSH SMALL FINANCE BANK',
    'UTKS0001541', 'MMT/IMPS/615104410368/BULD72334842/BHUPESHLAL/UTKS0001541', 'DISBURSED', 'REPEAT', 'PAYAL SHARMA', 'KISHAN KUMAR',
    'FLAT B  8 PLOT 2 1 & SECT 14 LAND MARK STY VASHI 400703 STY VASHI 400703 400703', 'AAVAS FINANCERS LTD NEELKANTH LANDMARK 5TH FLOOR OFFICE NO 502 BEHIND ORION MALL OLD PANVEL 410206  412206', 20, '0-30', 'May, 2026', 'PART-PAYMENT'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    8604, 'Karnataka', 'Bangalore', 'LOA00003570', 'ECBPD0599E', 'ACGLLLOT00000004231', 'DHARUN  AASHICK', 8754834945, 'DHARUNAASHICK@GMAIL.COM',
    35000, 29750, 4449, 801, 5250, 800.85, 0, 0, 4449.15,
    31, 0.75, 43137.5, '2026-05-31', '2026-06-30', '''921010024115484', 'AXIS BANK',
    'UTIB0003200', 'MMT/IMPS/615104410922/BULD72334842/DHARUNAASH/UTIB0003200', 'DISBURSED', 'REPEAT', 'DEEPAK KUMAR', NULL,
    '103 TASHU''S ABODE 9TH CROSS  NEELADRI NAGAR, 9TH CROSS NEELADRI NAGAR,  BENGALURU 560100 KARNATAKA  560100', 'ENERGAGE SOLUTIONS INDIA PRIVATE LIMITED 11TH FLOOR PIXAL A BUILDING,  PES CAMPUS, ELECTRONIC CITY PHASE 1,  BENGALURU 560100  560100', 20, '0-30', 'May, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    8610, 'Tamil Nadu', 'Chennai', 'LOA00003747', 'BMZPA7362M', 'ACGLLLOT00000004233', 'ANANTH  LAKSHMINARAYANAN', 9791471156, 'ANANTHALPHA93@GMAIL.COM',
    30000, 25500, 3814, 686, 4500, 686.44, 0, 0, 3813.56,
    30, 0.75, 36750, '2026-05-31', '2026-06-30', '''10085789035', 'IDFC FIRST BANK LTD',
    'IDFB0080121', 'MMT/IMPS/615113933569/BULD72338511/ANANTHLAKS/IDFB0080121', 'DISBURSED', 'REPEAT', 'SHIVANI JOSHI', 'KISHAN KUMAR',
    'D 402 FANSTASTIC BY URBAN TREE NOOMBAL MAIN ROAD CHENNAI 600095  600094', 'IDFC FIRST BANK LTD NO 4 CALAVALA CENTENARY CLUB HOUSE ROAD CHENNAI 600002  600002', 20, '0-30', 'May, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    8630, 'West Bengal', 'Kolkata', 'ADV00000798', 'AFHPC4924M', 'ACGLLLOT00000004235', 'KUMAR KOUSHIK CHOUDHURY', 9874485566, 'KUMARANDKOUSHIK@GMAIL.COM',
    35000, 29750, 4449, 801, 5250, 800.85, 0, 0, 4449.15,
    31, 0.75, 43137.5, '2026-05-31', '2026-07-01', '''55550115753079', 'FEDERAL BANK',
    'FDRL0001985', 'MMT/IMPS/615114079333/BULD72339933/KUMARKOUSH/FDRL0001985', 'DISBURSED', 'REPEAT', 'GARISHMA', NULL,
    '1507,SOUTHWIND BLOCK 6 EM BYPASS ROAD RELIANCE FRESH 700149 SOUTH PRESIDENCY  700141', 'BANDHAN BANK BN5 ADVENTZ INFINITY   KOLKATA SALTLAKE SECTOR V   700091', 19, '0-30', 'May, 2026', 'PART-PAYMENT'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    8631, 'Maharashtra', 'Pune', 'LOA00002860', 'AJZPL7872K', 'ACGLLLOT00000004234', 'GAURAV SANJAY LAKHA', 8421389187, 'GAURAVLAKHA@GMAIL.COM',
    25000, 21250, 3178, 572, 3750, 572.03, 0, 0, 3177.97,
    30, 0.75, 30625, '2026-05-31', '2026-06-30', '''50100209880452', 'HDFC BANK',
    'HDFC0003344', 'MMT/IMPS/615113934030/BULD72338511/GAURAVSANJ/HDFC0003344', 'DISBURSED', 'REPEAT', 'DEEPAK KUMAR', NULL,
    'S.NO 26/1/1 NEAR GAJANAN MAHARAJ MANDIR SHALOM PALACE WAKAD ROAD VISHAL NAGAR PIMPLE NILAKH 411027  411027', 'EPIQ SYSTEMS INDIA PRIVATE LIMITED TEERTH TECHNOSPACE, C WING, OFFICE NO. 708, BENGALURU - MUMBAI HWY, BANER, PUNE, MAHARASHTRA 411069  411060', 20, '0-30', 'May, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    8641, 'Telangana', 'Hyderabad', 'LOA00003750', 'GYNPS5049J', 'ACGLLLOT00000004236', 'SHAIK  SHABBIR', 9492812087, 'SHABBIRSHAIK0601@GMAIL.COM',
    50000, 42500, 6356, 1144, 7500, 1144.07, 0, 0, 6355.93,
    36, 0.75, 63500, '2026-05-31', '2026-07-06', '''067901003914', 'ICICI BANK LIMITED',
    'ICIC0000679', 'INF/INFT/044593289111/72340661     /SHAIKSHABBIR/DISBURSE', 'DISBURSED', 'REPEAT', 'SHIVANI JOSHI', 'KISHAN KUMAR',
    'HIGH 563 , FLOT 304 , SHRI SHIRDI SAI NILAYAM , KPHB 6TH PHASE 500085  500085', 'COGNIZANT TECHNOLOGY SOLUTION INDIA PRIVATE LTD BUILDING 12 A , COGNIZANT TECHNOLOGY SOLUTIONS , RAHEJA MIND SPACE MADAPUR , 500091  500091', 14, '0-30', 'May, 2026', 'PART-PAYMENT'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    8649, 'Maharashtra', 'Thane', 'LOA00003888', 'JDPPK6502N', 'ACGLLLOT00000004241', 'KAUSTUBH VIJAY KOLI', 9702699919, 'KAUSTUBHKOLI4@GMAIL.COM',
    40000, 34000, 5085, 915, 6000, 915.25, 0, 0, 5084.75,
    31, 0.75, 49300, '2026-05-31', '2026-07-01', '''0217101047161', 'CANARA BANK',
    'CNRB0000217', 'INF/NEFT/IN426151591 68636/CNRB0000217/72 342957 /DISBURSE /K AUSTUBHVIJ', 'DISBURSED', 'NEW', 'GARISHMA', 'KISHAN KUMAR',
    'K D KOLI PARYACHE MAIDAN THANE BELAPUR ROAD NEAR VITAWA KALWA THANE MAHASHTRA- 400605 THANE MAHARASHTRA 400605. K D KOLI  PARYACHE MAIDAN THANE BELAPUR ROAD NEAR VITAWA KALWA THANE MAHASHTRA- 400605 THANE MAHARASHTRA 400605  400605', 'WUERTH INDIA PRIVATE LIMITED SAHAR WINDFALL, SAHAR PLAZA COMPLEX, 703 & 704, SIR M V ROAD, MAROL, ANDHERI EAST, MUMBAI, MAHARASHTRA 400059 SAHAR WINDFALL, SAHAR PLAZA COMPLEX, 703 & 704, SIR M V ROAD, MAROL, ANDHERI EAST, MUMBAI, MAHARASHTRA 400059  400059', 19, '0-30', 'May, 2026', 'PART-PAYMENT'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    8652, 'Uttar Pradesh', 'Gautam Buddha Nagar', 'LOA00003304', 'ALUPG4996Q', 'ACGLLLOT00000004238', 'RAHUL  GUPTA', 9999772387, 'RAHUL301985@GMAIL.COM',
    32000, 27200, 4068, 732, 4800, 732.2, 0, 0, 4067.8,
    30, 0.75, 39200, '2026-05-31', '2026-06-30', '''103101537788', 'ICICI BANK LIMITED',
    'ICIC0001031', 'INF/INFT/044593625541/72341576     /RAHULGUPTA/DISBURSE', 'DISBURSED', 'REPEAT', 'POOJA', NULL,
    'MR. SAYED AHMAR ALI AND MRS. WASIA SIDDIQUI. FLAT NO-803, TOWER-T6, NIRALA ESTATE, GREATER NOIDA WEST, UTTAR PRADESH. 201306', 'AMERIPRISE INDIA LLP 50/9, 1ST FLOOR TOLSTOY LANE JANPATH, NEW DELHI 110001', 20, '0-30', 'May, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    8662, 'Uttar Pradesh', 'Greater Noida', 'LOA00003602', 'AJZPD4404F', 'ACGLLLOT00000004240', 'HANISH  DUA', 9999851011, 'HANISHDUA@LIVE.COM',
    22000, 18700, 2797, 503, 3300, 503.39, 0, 0, 2796.61,
    30, 0.75, 26950, '2026-05-31', '2026-06-30', '''42875315366', 'STATE BANK OF INDIA',
    'SBIN0064003', 'INF/NEFT/IN42615159134909/SBIN0064003/72341576 /DISBURSE                      /HANISHDUA', 'DISBURSED', 'REPEAT', 'POOJA', NULL,
    'SUN-1,2301,MIGSUN WYNNE TWIINZ,TWIINZ, ETA II, GREATER NOIDA, UTTAR PRADESH , INDIA,,,NOIDA,UTTAR PRADESH,201310 NOIDA  201310', 'VIRGIN ATLANTIC AIRWAYS LIMITED 314, 3RD FLOOR, TIME TOWER, SECTOR 25, GURGAON-122001, HARYANA  122001', 20, '0-30', 'May, 2026', 'PART-PAYMENT'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    8738, 'Maharashtra', 'Thane', 'LOA00003893', 'DAFPA5255K', 'ACGLLLOT00000004286', 'DNYANESHWAR DILIP AHIRE', 9960636360, 'DNYAHIRE16496@GMAIL.COM',
    20000, 17000, 2542, 458, 3000, 457.63, 0, 0, 2542.37,
    42, 0.75, 26300, '2026-06-01', '2026-07-13', '''60382425158', 'BANK OF MAHARASHTRA',
    'MAHB0001390', 'MMT/IMPS/615219129678/BULD72409670/DNYANESHWA/MAHB0001390', 'DISBURSED', 'NEW', 'GARISHMA', 'KISHAN KUMAR',
    'B203, TIRUPATI COOPERATIVE HOUSING SOCIETY, KHAREGAON, THANE-400605. B203, TIRUPATI COOPERATIVE HOUSING SOCIETY, KHAREGAON, THANE-400605.  400605', 'ABHISHEK MILLENNIUM CONTRACTS PVT LTD GATE NO 2A LODHA PARK NEAR DEEPAK TALKIES LOWER PAREL MUMBAI, MAHARASHTRA 400013 GATE NO 2A LODHA PARK NEAR DEEPAK TALKIES LOWER PAREL MUMBAI, MAHARASHTRA 400013  400013', 7, '0-30', 'June, 2026', 'PART-PAYMENT'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    8749, 'Karnataka', 'Bangalore', 'LOA00003556', 'FERPS9679H', 'ACGLLLOT00000004272', 'SHALINI  S', 9845467627, 'SHALINISHASHIKUMAR93@GMAIL.COM',
    35000, 29750, 4449, 801, 5250, 800.85, 0, 0, 4449.15,
    30, 0.75, 42875, '2026-06-01', '2026-07-01', '''39737086438', 'STATE BANK OF INDIA',
    'SBIN0040009', 'INF/NEFT/IN42615259804898/SBIN0040009/72388483 /DISBURSE                      /SHALINIS', 'DISBURSED', 'REPEAT', 'SHIVANI JOSHI', 'KISHAN KUMAR',
    '16,210, 2ND CROSS RD, INDIA,NEAR VASU DONE BI RIYANI,TIPU NAGAR, CHAMRAJPET,BANGALORE,KARNATAKA 560018', 'AMAZON DEVELOPMENT CENTRE (INDIA) PRIVATE LIMITED TAURUS 3 BAGMANE CONSTELLATION FERNS CITY BANGALORE 560006', 19, '0-30', 'June, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    8762, 'Karnataka', 'Bangalore', 'LOA00003454', 'CFQPS1512G', 'ACGLLLOT00000004279', 'SHAIK  KHADERVALLI', 9966843213, 'ITSMEKHADERS@YAHOO.COM',
    35000, 29750, 4449, 801, 5250, 800.85, 0, 0, 4449.15,
    30, 0.75, 42875, '2026-06-01', '2026-07-01', '''1714371998', 'KOTAK MAHINDRA BANK',
    'KKBK0008145', 'MMT/IMPS/615219130410/BULD72409670/SHAIKKHADE/KKBK0008145', 'DISBURSED', 'REPEAT', 'GARISHMA', NULL,
    '302, SVSG MEDOWS , 2ND CROSS , ALFA GARDENS BANGALORE , BANGALORE , - - 560036  560036', 'PROZO INTEGRATED LOGISTICS  PRIVATE LIMITED SY NO. 131/3, ANJANEYA GARDEN, IOC ROAD, NEAR MARIE GOLD LOGISTICS, MAKANAHALLI VILLAGE, HOSKOTE, BENGALURU, KARNATAKA 560067 SY NO. 131/3, ANJANEYA GARDEN, IOC ROAD, NEAR MARIE GOLD LOGISTICS, MAKANAHALLI VILLAGE, HOSKOTE, BENGALURU, KARNATAKA 560067  560067', 19, '0-30', 'June, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    8767, 'Delhi', 'New Delhi', 'LOA00002427', 'AHFPG3604A', 'ACGLLLOT00000004277', 'NEERAJ  GARG', 9891866204, 'NEERAJGARG6@GMAIL.COM',
    25000, 22750, 1907, 343, 2250, 0, 171.61, 171.61, 1906.78,
    30, 0.9, 31750, '2026-06-01', '2026-07-01', '''062810011902622', 'UNION BANK OF INDIA',
    'UBIN0806285', 'MMT/IMPS/615219129275/BULD72409670/NEERAJGARG/UBIN0806285', 'DISBURSED', 'REPEAT', 'DEEPAK KUMAR', NULL,
    '6/20, STREET NO 4, VISHWAS NAGAR, DELHI - 110032, NEAR HDFC BANK 110032', 'DHANI LOANS AND SERVICES LTD. 108, GO WORK BUILDING, UDYOG VIHAR PHASE 1, GURGAON - 122016  122016', 19, '0-30', 'June, 2026', 'PART-PAYMENT'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    8774, 'Maharashtra', 'Thane', 'LOA00002115', 'AGYPC7356F', 'ACGLLLOT00000004280', 'SAURABH  CHAVAN', 9920014648, 'CSAURABH2109@GMAIL.COM',
    40000, 34000, 5085, 915, 6000, 915.25, 0, 0, 5084.75,
    31, 0.75, 49300, '2026-06-01', '2026-07-02', '''50100836703619', 'HDFC BANK LTD',
    'HDFC0007689', 'MMT/IMPS/615219130176/BULD72409670/SAURABHCHA/HDFC0007689', 'DISBURSED', 'REPEAT', 'POOJA', NULL,
    '304 FLOOR: 3 WING: A-2 SWASTIK-A2, KHOPAT, POLHRAN ROAD NO.1,  SWASTIK CHSL, THANE(W) THANE - 400601 BEHIND SHIVSENA SHAKHA, 400601', 'HDFC LIFE INSURANCE COMPANY LIMITED HDFC LIFE INSURANCE 2ND FLOOR DEV CORPORA NEAR CADBURY JUNCTION THANE WEST 400601 HDFC LIFE INSURANCE 2ND FLOOR DEV CORPORA NEAR CADBURY JUNCTION THANE WEST 400601  400601', 18, '0-30', 'June, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    8779, 'Karnataka', 'Bangalore', 'LOA00003128', 'ALSPR9022N', 'ACGLLLOT00000004281', 'RAMESH RUDRAPATNA YADUNANDA KUMAR', 9886616456, 'RAMESHRYIYG@GMAIL.COM',
    40000, 34000, 5085, 915, 6000, 915.25, 0, 0, 5084.75,
    29, 0.75, 48700, '2026-06-01', '2026-06-30', '''159886616456', 'INDUSIND BANK LTD',
    'INDB0001103', 'MMT/IMPS/615219129424/BULD72409670/RAMESHRUDR/INDB0001103', 'DISBURSED', 'REPEAT', 'DEEPAK KUMAR', NULL,
    '256 2ND BLOCK 5TH CROSS HMT LAYOUT VIDYARANYAPURA BANGALORE 560097  560097', 'WHATFIX PRIVATE LIMITED WHATFIX TOWERS 1289, HSR LAYOUT, BANGALORE 560102 LANDMARK,  NEAR HSR BDA COMPLEX 560102', 20, '0-30', 'June, 2026', 'PART-PAYMENT'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    8800, 'Maharashtra', 'Pune', 'LOA00002491', 'GHAPK5746J', 'ACGLLLOT00000004292', 'SUMEET YASHWANT KOTHAWALE', 9209191406, 'KOTHAWALESUMEET26@GMAIL.COM',
    22000, 18700, 2797, 503, 3300, 503.39, 0, 0, 2796.61,
    30, 0.75, 26950, '2026-06-01', '2026-07-01', '''50100500119913', 'HDFC BANK',
    'HDFC0000052', 'MMT/IMPS/615220202714/BULD72411635/SUMEETYASH/HDFC0000052', 'DISBURSED', 'REPEAT', 'POOJA', NULL,
    '459 NARAYAN PETH FL NO 19 NR LOKHANDE TALIM  411030', 'TVH INDIA PRIVATE LIMITED 15TH FLOOR, TOWER 3, FOUNTAINHEAD, PHOENIX MARKET CITY,NAGAR ROAD, VIMANNAGAR, PUNE-411014  411014', 19, '0-30', 'June, 2026', 'PART-PAYMENT'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    8863, 'Tamil Nadu', 'Chennai', 'LOA00003898', 'AIQPV5563P', 'ACGLLLOT00000004309', 'VASUDEVAN  RAMALINGAM', 9884418941, 'VASUDEVANRM@GMAIL.COM',
    40000, 34000, 5085, 915, 6000, 915.25, 0, 0, 5084.75,
    28, 0.75, 48400, '2026-06-02', '2026-06-30', '''20186051577', 'STATE BANK OF INDIA',
    'SBIN0004285', 'MMT/IMPS/615319631193/BULD72474253/VASUDEVANR/SBIN0004285', 'DISBURSED', 'NEW', 'DEEPAK KUMAR', 'KISHAN KUMAR',
    '17A, 1ST FLR, 1ST STREET,LAKSHMI NAGAR VELACHERY CHENNAI TAMIL NADU-600042  600042', 'LUXOFT INDIA LLP LUXOFT LLP  2ND FLOOR  OLYMPIA TECH PARK  GUINDY, CHENNAI 600032  600032', 20, '0-30', 'June, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    8864, 'Karnataka', 'Bangalore', 'LOA00003895', 'BKOPM2631J', 'ACGLLLOT00000004300', 'MAGULURI  SURENDRA', 7042676938, 'SURENDRADBA12@GMAIL.COM',
    40000, 34000, 5085, 915, 6000, 915.25, 0, 0, 5084.75,
    28, 0.75, 48400, '2026-06-02', '2026-06-30', '''025301592996', 'ICICI BANK LIMITED',
    'ICIC0000253', 'INF/INFT/044620765721/72462733     /MAGULURISURENDRA    /DISBURSE', 'DISBURSED', 'NEW', 'DEEPAK KUMAR', 'KISHAN KUMAR',
    '312, VIKYATH ELEGANT, SAKETHA NAGAR, HOODI, BANGLORE, 560048  560048', 'NETAPP INDIA PRIVATE LIMITED NETAPP IND PVT LTD, ITPL MAIN ROAD, WHITEFIELD, BANGLORE, 560048  560048', 20, '0-30', 'June, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    8869, 'Delhi', 'New Delhi', 'LOA00003203', 'BJYPG8973J', 'ACGLLLOT00000004299', 'PETER  GOMES', 8376942020, 'PETERGOMESR4@GMAIL.COM',
    13000, 11050, 1653, 297, 1950, 0, 148.73, 148.73, 1652.54,
    29, 0.75, 15827.5, '2026-06-02', '2026-07-01', '''925010044049718', 'AXIS BANK',
    'UTIB0002685', 'MMT/IMPS/615316189975/BULD72450823/PETERGOMES/UTIB0002685', 'DISBURSED', 'REPEAT', 'DEEPAK KUMAR', NULL,
    'S-77 3RD FLOOR SUNDAR BLOCK SHAKARPUR DELHI-110092  110092', 'DENAVE INDIA PRIVATE LIMITED 154A, 2ND FLOOR, SECTOR 63, NOIDA, UTTAR PRADESH â€“ 201307  201307', 19, '0-30', 'June, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    8895, 'Maharashtra', 'Pune', 'LOA00003420', 'FWDPK9082G', 'ACGLLLOT00000004308', 'PRADNYA RAJENDRA KOTHAWADE', 9421172547, 'PRADNYAKOTHAWADE190696@GMAIL.COM',
    25000, 21250, 3178, 572, 3750, 572.03, 0, 0, 3177.97,
    30, 0.75, 30625, '2026-06-02', '2026-07-02', '''20245623700', 'STATE BANK OF INDIA',
    'SBIN0013295', 'MMT/IMPS/615319630485/BULD72474253/PRADNYARAJ/SBIN0013295', 'DISBURSED', 'REPEAT', 'SHIVANI JOSHI', 'KISHAN KUMAR',
    'SR.NO.221 TO 223 BLDG-C IREN TOWER FLAT NO-601 411007  411007', 'SUREKHA DESIGNS PRIVATE LIMITED SUREKHA DESIGNS PRIVATE LIMITED, ASTRIVA , F1 NYATI EBONY, UNDRI, PUNE 411060  411060', 18, '0-30', 'June, 2026', 'PART-PAYMENT'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    8907, 'Maharashtra', 'Thane', 'LOA00003902', 'AXSPP9593Q', 'ACGLLLOT00000004315', 'VIJENDRA AWADHESH PANDEY', 8655884118, 'PANDEPANDE007@GMAIL.COM',
    25000, 21250, 3178, 572, 3750, 572.03, 0, 0, 3177.97,
    30, 0.75, 30625, '2026-06-02', '2026-07-02', '''012610110008869', 'BANK OF INDIA',
    'BKID0000126', 'MMT/IMPS/615320757874/BULD72477486/VIJENDRAAW/BKID0000126', 'DISBURSED', 'NEW', 'PAYAL SHARMA', 'KISHAN KUMAR',
    'FLAT NO 401; VAIBHAV SANKUL BUILDING IJAYNAGAR;KALYAN THANE KALYAN-DOMBIVLI (M CORP.) VAIBHAV SANKUL BUILDING 421306', 'INDIAN RAILWAY F&CAO BUILDING,3RD FLOOR,CSMT STATION NO.06 F&CAO BUILDING,3RD FLOOR,CSMT STATION NO.06 F&CAO BUILDING,3RD FLOOR,CSMT STATION NO.06 400001', 18, '0-30', 'June, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    8825, 'Karnataka', 'Bangalore', 'LOA00003903', 'CAYPA1834J', 'ACGLLLOT00000004316', 'ANANTHA KUMARA B L', 9739396330, 'BAMULPREPAK@GMAIL.COM',
    20000, 17000, 2542, 458, 3000, 457.63, 0, 0, 2542.37,
    29, 0.75, 24350, '2026-06-03', '2026-07-02', '''8404101006491', 'CANARA BANK',
    'CNRB0001371', 'INF/NEFT/IN426154511 42162/CNRB0001371/72 499948 /DISBURSE /A NANTHAKUMA', 'DISBURSED', 'NEW', 'POOJA', 'KISHAN KUMAR',
    'HOUSE NO 6 PURUSHOTTAM BUILDING  KULLAREDDY LAYOUT  MICOLAYOUT  BOMMANAHALLI BENGALURU 560068 HOUSE NO 6 PURUSHOTTAM BUILDING  KULLAREDDY LAYOUT  MICOLAYOUT  BOMMANAHALLI BENGALURU 560068  560068', 'BAMUL BENGALURU COOPERATIVE MILK UNION LTD  DR MH MARIGOWDA ROAD  OPPOSITE TO CHRIST UNIVERSITY  DAIRY CIRCLE  BENGALURU 560029 BENGALURU COOPERATIVE MILK UNION LTD  DR MH MARIGOWDA ROAD  OPPOSITE TO CHRIST UNIVERSITY  DAIRY CIRCLE  BENGALURU 560029  560029', 18, '0-30', 'June, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    8946, 'Karnataka', 'Bangalore', 'LOA00003915', 'AVGPS3282F', 'ACGLLLOT00000004340', 'A R S SATHEESH', 9242181138, 'S.ADITYA.SATISH.ARUNACHALAM@GMAIL.COM',
    80000, 68000, 10169, 1831, 12000, 1830.51, 0, 0, 10169.49,
    27, 0.75, 96200, '2026-06-03', '2026-06-30', '''074404344006', 'HSBC BANK',
    'HSBC0560002', 'MMT/IMPS/615419106652/BULD72541940/ARSSATHEES/HSBC0560002', 'DISBURSED', 'NEW', 'DEEPAK KUMAR', 'KISHAN KUMAR',
    'FLAT 106 BLOCK 21 VBHC VAIBHAVA CHANDAPURA ANEKAL MAIN ROAD BYEGADADENAHALLI BANGALORE 562106  562106', 'JONES LANG LASALLE PROPERTY CONSULTANTS (INDIA) PRIVATE LIMITED 4TH FLOOR PRESTIGE TRADE TOWER PALACE ROAD SAMPANGI RAMA NAGARA BANGALORE 562106  562016', 20, '0-30', 'June, 2026', 'PART-PAYMENT'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    8966, 'Uttar Pradesh', 'Noida', 'LOA00003911', 'DHUPR0076R', 'ACGLLLOT00000004334', 'AMAN  RAJ', 8949731232, 'AMANRAAZ49@GMAIL.COM',
    25000, 21250, 3178, 572, 3750, 572.03, 0, 0, 3177.97,
    35, 0.75, 31562.5, '2026-06-03', '2026-07-08', '''4585101003447', 'CANARA BANK',
    'CNRB0004585', 'MMT/IMPS/615418879823/BULD72532357/AMANRAJ/CNRB0004585', 'DISBURSED', 'NEW', 'GARISHMA', 'KISHAN KUMAR',
    '1407 KM33 JAYPEE KOSMOS SECTOR 134 NOIDA UP 201304 1407 KM33 JAYPEE KOSMOS SECTOR 134 NOIDA UP 201304  201304', 'QMET INTERNATIONAL PRIVATE LIMITED SY. NO. OF 148 , KABEER TIMBER FACTORY KOPA VILLAGE , KOPPA, KARNATAKA, INDIA - 577126 SY. NO. OF 148 , KABEER TIMBER FACTORY KOPA VILLAGE , KOPPA, KARNATAKA, INDIA - 577126  583226', 12, '0-30', 'June, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    8980, 'West Bengal', 'Kolkata', 'LOA00003313', 'BBSPD6037L', 'ACGLLLOT00000004322', 'AVIK  DAS', 7086090204, 'AVIKD177@GMAIL.COM',
    40000, 34000, 5085, 915, 6000, 915.25, 0, 0, 5084.75,
    31, 0.75, 49300, '2026-06-03', '2026-07-04', '''20171140002812', 'HDFC BANK',
    'HDFC0002017', 'MMT/IMPS/615416630330/BULD72517203/AVIKDAS/HDFC0002017', 'DISBURSED', 'REPEAT', 'SHIVANI JOSHI', 'KISHAN KUMAR',
    'SWAN COURT AI04A STREET NUMBER 622 NEWTOWN AAIIB KOLKATA-700161  700090', 'HYUNDAI MOTOR INDIA LIMITED MARTIN BURN BUSINESS PARK SECTOR V BIDHANNAGAR KOLKATA-700091  700090', 16, '0-30', 'June, 2026', 'PART-PAYMENT'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    8982, 'Haryana', 'Faridabad', 'LOA00003301', 'COYPK1407H', 'ACGLLLOT00000004323', 'SANDEEP  KUMAR', 7428198579, 'SANDEEPRAO211@GMAIL.COM',
    30000, 25500, 3814, 686, 4500, 686.44, 0, 0, 3813.56,
    29, 0.75, 36525, '2026-06-03', '2026-07-02', '''140001516241', 'ICICI BANK LIMITED',
    'ICIC0001400', 'INF/INFT/044632638351/72517203     /SANDEEPKUMAR/DISBURSE', 'DISBURSED', 'REPEAT', 'DEEPAK KUMAR', NULL,
    'HOME: 1087, SECOND FLOOR SECTOR-46 FARIDABAD 121010  121010', 'MEDSOURCE OZONE BIOMEDICALS PVT. LTD 109, SECTOR-31 FARIDABAD 121003  121003', 18, '0-30', 'June, 2026', 'PART-PAYMENT'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    8983, 'Tamil Nadu', 'Chennai', 'ADV00001514', 'AYIPA2567L', 'ACGLLLOT00000004326', 'AMARNATH  VASUDEVAN', 9790819603, 'AMARNATHV32@GMAIL.COM',
    15000, 12750, 1907, 343, 2250, 343.22, 0, 0, 1906.78,
    27, 0.75, 18037.5, '2026-06-03', '2026-06-30', '''10246529632', 'IDFC FIRST Bank',
    'IDFB0080102', 'MMT/IMPS/615416631445/BULD72517203/AMARNATHVA/IDFB0080102', 'DISBURSED', 'REPEAT', 'POOJA', 'KISHAN KUMAR',
    '27/D6 KAMARAJ CAMPUS 6 TH MAIN ROAD JAWAHAR NAGAR CHENNAI 600082 NEAR K5 PERAVALLUR POLICE STATION CHENNAI 600082 NEAR K5 PERAVALLUR POLICE STATION 600082', 'IRIS KPO RESOURCING PRIVATE LIMITED FIFTH FLOOR POTTI PATTI PLAZA NUNGAMBAKKAM HIGH ROAD NUNGAMBAKKAM CHENNAI 600034 HIGH ROAD NUNGAMBAKKAM CHENNAI 600034 600034', 20, '0-30', 'June, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    8995, 'Uttar Pradesh', 'Ghaziabad', 'LOA00003914', 'CNDPA6978B', 'ACGLLLOT00000004339', 'ABHIJEET  AWASTHI', 9795814132, 'ABHIJEETAWASTHI993@GMAIL.COM',
    75000, 63750, 9534, 1716, 11250, 1716.1, 0, 0, 9533.9,
    37, 0.75, 95812.5, '2026-06-03', '2026-07-10', '''00000020364852781', 'STATE BANK OF INDIA',
    'SBIN0011607', 'MMT/IMPS/615419042278/BULD72539961/ABHIJEETAW/SBIN0011607', 'DISBURSED', 'NEW', 'PAYAL SHARMA', 'KISHAN KUMAR',
    '5016 TOWER 1 GH07,101,BIHARIPUR VILLAGE CROSSINGS REPUBLIK, GHAZIABAD, UTT AR PRAD,ABES,GHAZIABAD,UTTAR PRADESH ,BIHARIPUR VILLAGE 201016', 'PROVIDENTIAL PLATFORMS PRIVATE LIMITED (NIVESH) C-112, 1ST FLOOR SECTOR 2, NOIDA â€“ GAUTAM BUDDHA NAGAR NOIDA C-112, 1ST FLOOR SECTOR 2, NOIDA â€“ GAUTAM BUDDHA NAGAR NOIDA GAUTAM BUDDHA NAGAR NOIDA 201301', 10, '0-30', 'June, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    9025, 'Karnataka', 'Bangalore', 'LOA00003918', 'ABLPF3798E', 'ACGLLLOT00000004344', 'FAZIL', 9738383455, 'FAZIL102328@GMAIL.COM',
    35000, 29750, 4449, 801, 5250, 800.85, 0, 0, 4449.15,
    27, 0.75, 42087.5, '2026-06-03', '2026-06-30', '''50100238944183', 'HDFC BANK',
    'HDFC0001869', 'MMT/IMPS/615419106735/BULD72541940/FAZIL/HDFC0001869', 'DISBURSED', 'NEW', 'DEEPAK KUMAR', 'KISHAN KUMAR',
    'HOUSE NUMBER 420, DR RAJKUMAR ROAD, KUDUR, MAGADI TALUK BANGALORE 561101  561101', 'SOCIETE GENERALE GLOBAL SOLUTION CENTRE PVT. LTD. 10TH FLOOR, VOYAGER BUILDING, ITPL MAIN RD, PATTANDUR AGRAHARA, WHITEFIELD, BENGALURU, KARNATAKA 560066  560066', 20, '0-30', 'June, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    9033, 'Karnataka', 'Bangalore', 'LOA00003919', 'BOSPG4290K', 'ACGLLLOT00000004347', 'ASHWINI  GOGOI', 7008634196, 'ASHWINI.JOBESGOGOI@GMAIL.COM',
    20000, 17000, 2542, 458, 3000, 457.63, 0, 0, 2542.37,
    26, 0.75, 23900, '2026-06-04', '2026-06-30', '''9313144579', 'KOTAK MAHINDRA BANK LIMITED',
    'KKBK0000431', 'MMT/IMPS/615513428650/BULD72562717/ASHWINIGOG/KKBK0000431', 'DISBURSED', 'NEW', 'POOJA', 'KISHAN KUMAR',
    'FLAT NO301 , BNR PRIDE, 3RD CROSS ROAD, LAXMINARAYANA LAYOUT, WHITEFIELD VAGDEVI LAYOUT, BANGALORE, KARNATAKA, INDIA BANGALORE, KARNATAKA, 560037, FLAT NO301 , BNR PRIDE, 3RD CROSS ROAD, LAXMINARAYANA LAYOUT, WHITEFIELD VAGDEVI LAYOUT, BANGALORE, KARNATAKA, INDIA BANGALORE, KARNATAKA, 560037,  560037', 'ACCENTURE SOLUTIONS PVT LTD BDC10 A BAGMANE TECH PARK , MAHADEVPURA BANGALORE 560048 BDC10 A BAGMANE TECH PARK , MAHADEVPURA BANGALORE 560048  560048', 20, '0-30', 'June, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    9070, 'Haryana', 'Gurgaon', 'LOA00002919', 'ARGPJ8396P', 'ACGLLLOT00000004346', 'NITIN  JAMWAL', 8527068605, 'JAMWALNITIN@GMAIL.COM',
    50000, 42500, 6356, 1144, 7500, 1144.07, 0, 0, 6355.93,
    28, 0.75, 60500, '2026-06-04', '2026-07-02', '''914010017700486', 'AXIS BANK',
    'UTIB0000540', 'MMT/IMPS/615513428622/BULD72562717/NITINJAMWA/UTIB0000540', 'DISBURSED', 'REPEAT', 'POOJA', NULL,
    'I  62 3RD - FLOOR  SOUTH CITY  1 GURGAON  GURGAON  122003 I - 62 , 3RD - FLOOR , SOUTH CITY - 1 GURGAON , GURGAON , - - 122003  122001', 'CLUES NETWORK PRIVATE LIMITED CLUES NETWORK PRIVATE LIMITED THIRD FLOOR, PLOT NO.: 94, SECTOR 44, INSTITUTIONAL AREA, DLF QE, GURGAON, HARYANA, 122002, INDIA CLUES NETWORK PRIVATE LIMITED THIRD FLOOR, PLOT NO.: 94, SECTOR 44, INSTITUTIONAL AREA, DLF QE, GURGAON, HARYANA, 122002, INDIA  122002', 18, '0-30', 'June, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    9072, 'Karnataka', 'Bangalore', 'LOA00003656', 'ASTPC4558J', 'ACGLLLOT00000004345', 'SURESH', 7760181531, '111SURESHSURI@GMAIL.COM',
    30000, 25500, 3814, 686, 4500, 686.44, 0, 0, 3813.56,
    26, 0.75, 35850, '2026-06-04', '2026-06-30', '''924010027964961', 'AXIS BANK',
    'UTIB0001506', 'MMT/IMPS/615516896535/BULD72581675/SURESH/UTIB0001506', 'DISBURSED', 'REPEAT', 'DEEPAK KUMAR', NULL,
    '61 9TH MAIN ROAD BEHIND BHARAT PETROL PUMP BOMMANHALLI BANGALORE 560068  560068', 'AXIS BANK LTD AXIS BANK 4TH BLOCK KORAMANGALA BANGALORE 560034  560034', 20, '0-30', 'June, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    9112, 'Maharashtra', 'Mumbai', 'LOA00003929', 'AMTPR4837R', 'ACGLLLOT00000004371', 'KULDEEP SINGH MANWAR SINGH RAWAT', 9819826707, 'KULRAW28@GMAIL.COM',
    20000, 17000, 2542, 458, 3000, 457.63, 0, 0, 2542.37,
    26, 0.75, 23900, '2026-06-04', '2026-06-30', '''05011610149359', 'HDFC BANK',
    'HDFC0000501', 'MMT/IMPS/615520509166/BULD72610574/KULDEEPSIN/HDFC0000501', 'DISBURSED', 'NEW', 'PAYAL SHARMA', 'KISHAN KUMAR',
    '1SR FLR BLDG NO 26, 890B, BACKSIDE, CHEMBUR, NEST TO BHARTI ICE CHEMBUR COLONY MUMBAI NEST TO BHARTI ICE CHEMBUR COLONY MUMBAI 400074', 'TATA CONSULTANCY SERVICES NESCO IT PARK COMPLEX GOREGAON EAST, MUMBAI NESCO IT PARK COMPLEX GOREGAON EAST, MUMBAI NESCO IT PARK COMPLEX GOREGAON EAST, MUMBAI 400069', 20, '0-30', 'June, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    9116, 'Gujarat', 'Ahmedabad', 'LOA00003925', 'AOQPG2349G', 'ACGLLLOT00000004366', 'MIHIR SURESHCHANDRA GHAYAL', 9909912611, 'MIHIR_SRLIM@YAHOO.COM',
    50000, 42500, 6356, 1144, 7500, 1144.07, 0, 0, 6355.93,
    26, 0.75, 59750, '2026-06-04', '2026-06-30', '''918010044368509', 'AXIS BANK',
    'UTIB0000388', 'MMT/IMPS/615520508194/BULD72610574/MIHIRSURES/UTIB0000388', 'DISBURSED', 'NEW', 'DEEPAK KUMAR', 'KISHAN KUMAR',
    'FLAT NO - H-23, ASMAAKAM-1, NEAR TORRENT POWER STATION, VEJALPUR, AHMEDABAD, GUJARAT 380060.  380051', 'MANKIND PHARMA LIMITED SEA WOOD GRANT CENTRAL MALL, NERUL WEST, NAVI MUMBAI 400706  400706', 20, '0-30', 'June, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    9128, 'Karnataka', 'Bangalore', 'LOA00003737', 'DLWPS7065B', 'ACGLLLOT00000004364', 'VIVEK  S', 8147992629, 'VIVEKSHIVADAS@YMAIL.COM',
    30000, 25500, 3814, 686, 4500, 686.44, 0, 0, 3813.56,
    27, 0.75, 36075, '2026-06-04', '2026-07-01', '''850401500465', 'ICICI BANK LTD',
    'ICIC0008504', 'INF/INFT/044650617531/72610574     /VIVEKS/DISBURSE', 'DISBURSED', 'REPEAT', 'GARISHMA', NULL,
    '83 45 TH MAIN 8TH BLOCK BANASHANKARI 6TH STAGENEAR SRI LAKSHMI TEMPLE BENGALURU - 560060 83 45 TH MAIN 8TH BLOCK BANASHANKARI 6TH STAGENEAR SRI LAKSHMI TEMPLE BENGALURU - 560060  560060', 'HP COMPUTING & PRINTING SYSTEMS INDIA PRIVATE LIMITED HP COMMUTING AND PRINTING SERVICS BAGMANE TECH PARK CV RAMANGAR BANAGLORE 560093 HP COMMUTING AND PRINTING SERVICS BAGMANE TECH PARK CV RAMANGAR BANAGLORE 560093  560093', 19, '0-30', 'June, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    9149, 'Telangana', 'Hyderabad', 'LOA00003388', 'DBQPK3943E', 'ACGLLLOT00000004365', 'JEETENDRA  KANSRALI', 9886479043, 'JEETEN114@GMAIL.COM',
    24000, 20400, 3051, 549, 3600, 549.15, 0, 0, 3050.85,
    30, 0.75, 29400, '2026-06-04', '2026-07-04', '''50100854881150', 'HDFC BANK',
    'HDFC0002083', 'MMT/IMPS/615519275677/BULD72603517/JEETENDRAK/HDFC0002083', 'DISBURSED', 'REPEAT', 'SHIVANI JOSHI', 'KISHAN KUMAR',
    '212, TOWER P, INDIS VB CITY , BOLARUM , HYDERABAD, 500014,  500013', 'APOLLO HOME HEALTHCARE LTD PLOT NO:8-2-293/82/564/A43, PRASANTHI TOWERS ROAD NO:92,JUBILEE HILLS HYDERABAD  500034', 16, '0-30', 'June, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    9163, 'Karnataka', 'Bangalore', 'LOA00003708', 'ACCPI9804N', 'ACGLLLOT00000004376', 'PRASHANTH  I', 8904407550, 'PRASHANTHINDRAKUMAR1@GMAIL.COM',
    50000, 42500, 6356, 1144, 7500, 1144.07, 0, 0, 6355.93,
    26, 0.75, 59750, '2026-06-04', '2026-06-30', '''50100294229999', 'HDFC BANK',
    'HDFC0001206', 'MMT/IMPS/615520509199/BULD72610574/PRASHANTHI/HDFC0001206', 'DISBURSED', 'REPEAT', 'PAYAL SHARMA', 'KISHAN KUMAR',
    'BHARATH NAGAR, BANGALORE NORTH, BANGALORE, KARNATAKA 560091  560091', 'NESS DIGITAL ENGINEERING (INDIA) PRIVATE LIMITED 33, 17H MAIN ROAD, KORAMANGALA 6TH BLOCK, BANGALORE-560095  560095', 20, '0-30', 'June, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    9091, 'Karnataka', 'Bangalore', 'LOA00003707', 'ALQPM4607G', 'ACGLLLOT00000004351', 'MANOJ  JANARDHAN', 9971395554, 'JANARDHANMANOJ@GMAILK.CO',
    50000, 42500, 6356, 1144, 7500, 1144.07, 0, 0, 6355.93,
    28, 0.75, 60500, '2026-06-05', '2026-07-03', '''925010039545425', 'AXIS BANK',
    'UTIB0004723', 'MMT/IMPS/615611585172/BULD72623532/MANOJJANAR/UTIB0004723', 'DISBURSED', 'REPEAT', 'POOJA', NULL,
    'NO 1402 PURVA SKYWOOD SVREY NO 92-95 BANGALORE KARNATAKA, 560068  560068', 'AXIS MAX LIFE INSURANCE LIMITED 2ND FLOOR, SRI VENKATESHWARA COMPLEX, MAX LIFE INSURANCE CO. LTD, 914, 80 FEET RD, 6TH BLOCK, KORAMANGALA, KARNATAKA 560095  560095', 17, '0-30', 'June, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    9156, 'Tamil Nadu', 'Kanchipuram', 'LOA00003651', 'EHWPS1252M', 'ACGLLLOT00000004373', 'SUDHARSAN  M', 9159504058, 'SUDHARSANMS15@GMAIL.COM',
    30000, 25500, 3814, 686, 4500, 686.44, 0, 0, 3813.56,
    25, 0.75, 35625, '2026-06-05', '2026-06-30', '''50100787749660', 'HDFC BANK LTD',
    'HDFC0007831', 'MMT/IMPS/615611585253/BULD72623532/SUDHARSANM/HDFC0007831', 'DISBURSED', 'REPEAT', 'PAYAL SHARMA', 'KISHAN KUMAR',
    'NO.91, MALAIYALA STREET KANCHEEPURAM, TAMILNADU MALAIYALA STREET 631501', 'PRESIDENCY UNIVERSITY PRESIDENCY UNIVERSITY BENGALURU KARNATAKA INDIA RAJANKUNTE YALANKHA PRESIDENCY UNIVERSITY 560064', 20, '0-30', 'June, 2026', 'PART-PAYMENT'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    9170, 'Maharashtra', 'Raigarh', 'LOA00003247', 'AONPG5741B', 'ACGLLLOT00000004381', 'GOHIL MITESH RAMESH', 9638554846, 'MITESHGOHIL2008@GMAIL.COM',
    25000, 21250, 3178, 572, 3750, 572.03, 0, 0, 3177.97,
    26, 0.75, 29875, '2026-06-05', '2026-07-01', '''910010027306856', 'AXIS BANK',
    'UTIB0000178', 'MMT/IMPS/615613873478/BULD72635990/GOHILMITES/UTIB0000178', 'DISBURSED', 'REPEAT', 'POOJA', NULL,
    'B204 GIRIRAJ ENCLAVE SECTOR 20 ROADPALI KALAMBOLI 410218 B204 GIRIRAJ ENCLAVE SECTOR 20 ROADPALI KALAMBOLI 410218  410218', 'JSW STEEL LIMITED 9TH FLOOR  TOWER 1 SEAWOOD NEXUSMALL  NAVI MUMBAI  400706 9TH FLOOR  TOWER 1 SEAWOOD NEXUSMALL  NAVI MUMBAI  400706  400706', 19, '0-30', 'June, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    9192, 'Karnataka', 'Bangalore', 'LOA00003938', 'HFTPK4051Q', 'ACGLLLOT00000004387', 'MANOJ R KULKARNI', 7349493289, 'KULKARNIMANOJ223@GMAIL.COM',
    12000, 10200, 1525, 275, 1800, 274.58, 0, 0, 1525.42,
    25, 0.75, 14250, '2026-06-05', '2026-06-30', '''50100339231171', 'HDFC BANK',
    'HDFC0000549', 'MMT/IMPS/615616344076/BULD72657939/MANOJRKULK/HDFC0000549', 'DISBURSED', 'NEW', 'POOJA', 'KISHAN KUMAR',
    'NO 329, GROUND FLOOR, DOOR NO.001, JJ RESIDENCY, 3 CROSS, NAIDU LAVOUT, SHANTHIPURA, ELECTRONIC CITY HASE-2, ELECTRONIC CITY POST, BANGALORE,KARNATAKA-560100  560100', 'ORCHARD HEALTHCARE PRIVATE LIMITED 953/28/1, K NARAYANAPURA MAIN RD, BDS NAGAR, KOTHANUR, BENGALURU, KARNATAKA 560077 953/28/1, K NARAYANAPURA MAIN RD, BDS NAGAR, KOTHANUR, BENGALURU, KARNATAKA 560077  560077', 20, '0-30', 'June, 2026', 'PART-PAYMENT'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    9193, 'Tamil Nadu', 'Chennai', 'LOA00003612', 'BCOPS2354C', 'ACGLLLOT00000004380', 'SOUNDRA  PRIYA', 9940645535, 'PRIYAABINESH10@GMAIL.COM',
    30000, 25500, 3814, 686, 4500, 686.44, 0, 0, 3813.56,
    25, 0.75, 35625, '2026-06-05', '2026-06-30', '''8143680121', 'INDIAN BANK',
    'IDIB000C017', 'MMT/IMPS/615613873943/BULD72635990/SOUNDRAPRI/IDIB000C017', 'DISBURSED', 'REPEAT', 'POOJA', NULL,
    'AS PRIME CLINIC NO 45D,NERKUNDRAM,NA,CHENNAI,,CHENNAI,TAMIL NADU,600107 CHENNAI TAMIL NADU, 600107 AS PRIME CLINIC NO 45D,NERKUNDRAM,NA,CHENNAI,,CHENNAI,TAMIL NADU,600107 CHENNAI TAMIL NADU, 600107  600107', 'APOLLO HOSPITALS ENTERPRISES LTD APOLLO FIRST MED HOSPITAL 154, PH ROAD,KILPAUK CHENNAI  600010 APOLLO FIRST MED HOSPITAL 154, PH ROAD,KILPAUK CHENNAI  600010  600010', 20, '0-30', 'June, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    9268, 'Maharashtra', 'Pune', 'LOA00003522', 'JEPPS0027M', 'ACGLLLOT00000004401', 'SHAIKH AAQUIBE RAFIQUE', 8668597997, 'AQUIBSHAIKH16@GMAIL.COM',
    25000, 21250, 3178, 572, 3750, 572.03, 0, 0, 3177.97,
    26, 0.75, 29875, '2026-06-05', '2026-07-01', '''76530100015159', 'BANK OF BARODA',
    'BARB0VJNIBM', 'MMT/IMPS/615620873867/BULD72691270/SHAIKHAAQU/BARB0VJNIBM', 'DISBURSED', 'REPEAT', 'DEEPAK KUMAR', NULL,
    'SNO 74 LANE NO A-28 SAYYAD NAGER ADARSH COLONY HADAPSAR PUNE 411028  411028', 'RANDSTAD INDIA PRIVATE LIMITED 43EQ SMARTWORKS SCHAEFFLER OFFICE OPP OF BHARTI VIDYAPETH 43EQ, SURVEY NO 43, H. NO. 8/1 (P, PLOT A, OPPOSITE BHARTIYA VIDYAPEETH SCHOOL, BANER-BALEWADI, PUNE, MAHARASHTRA 411045. 411045', 19, '0-30', 'June, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    9264, 'Haryana', 'Gurgaon', 'LOA00003954', 'DQIPM8123D', 'ACGLLLOT00000004412', 'DIVYAM  MATHUR', 9927323323, 'DIVYAMMATHUR007@GMAIL.COM',
    50000, 42500, 6356, 1144, 7500, 1144.07, 0, 0, 6355.93,
    25, 0.75, 59375, '2026-06-06', '2026-07-01', '''035801564678', 'ICICI BANK LIMITED',
    'ICIC0000358', 'INF/INFT/044673860511/72715608     /DIVYAMMATHUR/DISBURSE', 'DISBURSED', 'NEW', 'POOJA', 'KISHAN KUMAR',
    '702 TOWER J 7TH FLOOR GREEN COURT SECTOR 90 GURGAON 702, TOWER J, 7TH FLOOR GREEN COURT, SECTOR 90 GURGAON 122505  122505', 'HASHEDIN TECHNOLOGIES PRIVATE LIMITED CYBER CITY, SMARTWORKS, BUILDING NO. 4 RK4 SQUARE, GURUGRAM, HARYANA 122002 CYBER CITY, SMARTWORKS, BUILDING NO. 4 RK4 SQUARE, GURUGRAM, HARYANA 122002  122002', 19, '0-30', 'June, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    9279, 'Haryana', 'Gurgaon', 'LOA00003952', 'ALZPM0857H', 'ACGLLLOT00000004410', 'NEHA  BHARDWAJ', 9911725244, 'NEHABHARDWAJOFFICE1@GMAIL.COM',
    50000, 42500, 6356, 1144, 7500, 1144.07, 0, 0, 6355.93,
    33, 0.75, 62375, '2026-06-06', '2026-07-09', '''911010016424498', 'AXIS BANK',
    'UTIB0001262', 'MMT/IMPS/615713864886/BULD72715608/NEHABHARDW/UTIB0001262', 'DISBURSED', 'NEW', 'DEEPAK KUMAR', 'KISHAN KUMAR',
    'HOUSE NO 1140 GF SECTOR 57 SUSHANT LOK PHASE 2 GURUGRAM 122003  122003', 'BAANI HOSPITALITY SERVICES (FORM. KNOWN AS AALIYAH REAL ESTATES PVT. LTD.) BAANI CITY CENTER SECTOR 63 GURUGRAM 122101 LANDMARK HILTON HOTEL  122101', 11, '0-30', 'June, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    9310, 'Delhi', 'New Delhi', 'LOA00003955', 'CWRPM2241N', 'ACGLLLOT00000004413', 'SYED ALI MEHDI', 8445777786, 'ALIMEHDI777@GMAIL.COM',
    40000, 34000, 5085, 915, 6000, 0, 457.63, 457.63, 5084.75,
    26, 0.75, 47800, '2026-06-06', '2026-07-02', '''601810110010816', 'BANK OF INDIA',
    'BKID0006018', 'MMT/IMPS/615713864838/BULD72715608/SYEDALIMEH/BKID0006018', 'DISBURSED', 'NEW', 'POOJA', 'KISHAN KUMAR',
    'G-118-G-1 G/F DILSHAD COLONY SHAHDARA DELHI 110095 G-118-G-1 G/F DILSHAD COLONY SHAHDARA DELHI 110095  110095', 'JAMIA HAMDARD DEPT OF CSE, SEST, JAMIA HAMDARD, HAMDARD NAGAR, NEW DELHI 110062 DEPT OF CSE, SEST, JAMIA HAMDARD, HAMDARD NAGAR, NEW DELHI 110062  110062', 18, '0-30', 'June, 2026', 'PART-PAYMENT'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    9372, 'Telangana', 'Hyderabad', 'LOA00003964', 'HMDPM4460G', 'ACGLLLOT00000004429', 'PATAMSETTI RAJA MANIKANTESWAR', 9573905226, 'ESHWARPATAMSETTI@GMAIL.COM',
    20000, 17000, 2542, 458, 3000, 457.63, 0, 0, 2542.37,
    22, 0.75, 23300, '2026-06-08', '2026-06-30', '''004801648054', 'ICICI BANK LIMITED',
    'ICIC0000048', 'INF/INFT/044699522381/72814207     /PATAMSETTIRAJAMANIKA/DISBURSE', 'DISBURSED', 'NEW', 'POOJA', 'KISHAN KUMAR',
    'LAT NO201 2ND FLOOR VAGVI HEIGHTS APARTMENT GOKUL PLOTS,HYDERABAD,TELANGANA,500085 LAT NO201 2ND FLOOR VAGVI HEIGHTS APARTMENT GOKUL PLOTS,HYDERABAD,TELANGANA,500085  500085', 'AVANCE CONSULTING SERVICES PRIVATE LIMITED 4TH FLOOR, LIFESTYLE STORES BUILDING, BEGUMPET, HYDERABAD, TELANGANA, 500016 4TH FLOOR, LIFESTYLE STORES BUILDING, BEGUMPET, HYDERABAD, TELANGANA, 500016  500016', 20, '0-30', 'June, 2026', 'PART-PAYMENT'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    9465, 'Gujarat', 'Ahmedabad', 'LOA00003970', 'AJPPJ4840B', 'ACGLLLOT00000004441', 'DHARMESH MADHUSUDAN JOGI', 7304034221, 'DHARMESHJOGI09@GMAIL.COM',
    15000, 12750, 1907, 343, 2250, 343.22, 0, 0, 1906.78,
    25, 0.75, 17812.5, '2026-06-08', '2026-07-03', '''50100806893644', 'HDFC BANK',
    'HDFC0002497', 'MMT/IMPS/615917904675/BULD72840094/DHARMESHMA/HDFC0002497', 'DISBURSED', 'NEW', 'SHIVANI JOSHI', 'KISHAN KUMAR',
    'E 403 SHRI HARI RESIDENCY, NEW C G ROAD, CHANDKHEDA SAKAR SCHOOL LANE, AHEMDBAD - 382424  382425', 'ODOO IN PRIVATE LIMITED 401 TOWER 3, INFOCITY, AIRPORT ROAD, GANDHINAGAR 382007  382007', 17, '0-30', 'June, 2026', 'PART-PAYMENT'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    9495, 'Karnataka', 'Bangalore', 'LOA00003448', 'ABFPI1499D', 'ACGLLLOT00000004440', 'SAGAYA CHRISTU RAJ', 9972578075, 'SAGAYA.CHRISRAJ89@GMAIL.COM',
    40000, 34000, 5085, 915, 6000, 915.25, 0, 0, 5084.75,
    28, 0.75, 48400, '2026-06-08', '2026-07-06', '''507901000010', 'ICICI BANK LTD',
    'ICIC0005079', 'INF/INFT/044704893101/72840094     /SAGAYACHRISTURAJ    /', 'DISBURSED', 'REPEAT', 'DEEPAK KUMAR', NULL,
    '468, 6TH MAIN RD, 1ST STAGE, HBR LAYOUT, BENGALURU, KARNATAKA 560043  560043', 'SILICON MEDIA TECHNOLOGIES PVT LTD SILICONINDIA, SURYA CHAMBERS, 124D, OLD ARD, MURUGESHPALYA, KAVERI NAGAR, HAL, BENGALURU, KARNATAKA 560017  560017', 14, '0-30', 'June, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    9520, 'Maharashtra', 'Mumbai', 'ADV00000466', 'ALUPP1659F', 'ACGLLLOT00000004456', 'PAWAN MURLIDHAR POPTANI', 8169855074, 'PAWANPOPTANI@GMAIL.COM',
    38000, 32300, 4831, 869, 5700, 869.49, 0, 0, 4830.51,
    28, 0.75, 45980, '2026-06-08', '2026-07-06', '''015101611149', 'ICICI BANK LIMITED',
    'ICIC0000151', 'INF/INFT/044709316751/72864104     /PAWANMURLIDHARPOPTAN/', 'DISBURSED', 'REPEAT', 'POOJA', NULL,
    'OLD BARRACK T143 ROOM 10 CHEMBUR COLONY MUMBAI 400074 NEAR SHITLADEVI MANDIR 400074', 'APMOSYS TECHNOLOGIES PRIVATE LIMITED B-505 TECHNOCITY PLOT NO. X-4/1 AND X-4, 2, MAHAPE ROAD, RELIANCE CORPORATE PARK, MIDC INDUSTRIAL AREA, GHANSOLI, NAVI MUMBAI, MAHARASHTRA 400701 B-505 TECHNOCITY PLOT NO. X-4/1 AND X-4, 2, MAHAPE ROAD, RELIANCE CORPORATE PARK, MIDC INDUSTRIAL AREA, GHANSOLI, NAVI MUMBAI, MAHARASHTRA 400701 B-505 TECHNOCITY PLOT NO. X-4/1 AND X-4, 2, MAHAPE ROAD, RELIANCE CORPORATE PARK, MIDC INDUSTRIAL AREA, GHANSOLI, NAVI MUMBAI, MAHARASHTRA 400701 400701', 14, '0-30', 'June, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    9487, 'Maharashtra', 'Pune', 'LOA00003973', 'BXPPG2235N', 'ACGLLLOT00000004446', 'NAVNATH BABAN GAYAWAL', 9503607425, 'NAVNATHGAYAWAL2@GMAIL.COM',
    30000, 25500, 3814, 686, 4500, 686.44, 0, 0, 3813.56,
    15, 0.75, 33375, '2026-06-09', '2026-06-24', '''0052066337', 'KOTAK MAHINDRA BANK',
    'KKBK0001793', 'INF/NEFT/IN42616056891279/KKBK0001793/72890179 /DISBURSE                      /NAVNATHBABA', 'DISBURSED', 'NEW', 'DEEPAK KUMAR', 'KISHAN KUMAR',
    'SHIVAJI SN 55/9/1A-55/9/2 FL701/AVENKATESH BUIL. WADGAON BK DHAYARI PUNE 411041  411041', 'SUNERGINEER SOLUTIONS PVT LTD 502 EXCELLO PLAZZO AMBEGAON BK  411046', 26, '0-30', 'June, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    9528, 'Telangana', 'Hyderabad', 'LOA00003429', 'ALKPT0461H', 'ACGLLLOT00000004458', 'SAIRAM SAIVENKAT TALATAM', 9890850604, 'SAIRAMTALATAM92@GMAIL.COM',
    42000, 35700, 5339, 961, 6300, 961.02, 0, 0, 5338.98,
    28, 0.75, 50820, '2026-06-09', '2026-07-07', '''159890850604', 'INDUSIND BANK LTD',
    'INDB0001507', 'INF/NEFT/IN42616056891274/INDB0001507/72890179 /DISBURSE                      /SAIRAMSAIVE', 'DISBURSED', 'REPEAT', 'POOJA', NULL,
    'FLAT NO 109 RUBY BLOCK VENSAI PROJECT KOMPALLAY HYDERABAD,HYDERABAD,TELANGANA,500014 FLAT NO 109 RUBY BLOCK VENSAI PROJECT KOMPALLAY HYDERABAD,HYDERABAD,TELANGANA,500014  500012', 'AZAD ENGINEERING LIMITED 90/D IDA PHASE 1 JEEDIMETLA HYDERABAD 500055 90/D IDA PHASE 1 JEEDIMETLA HYDERABAD 500055  500053', 13, '0-30', 'June, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    9532, 'Karnataka', 'Bangalore', 'LOA00003983', 'ARRPS6880Q', 'ACGLLLOT00000004461', 'TEJASIMHA RAJASIMHA KARUR', 9980166677, 'TEJASIMHA.KARUR@GMAIL.COM',
    80000, 68000, 10169, 1831, 12000, 1830.51, 0, 0, 10169.49,
    21, 0.75, 92600, '2026-06-09', '2026-06-30', '''05091610105771', 'HDFC BANK',
    'HDFC0000509', 'MMT/IMPS/616017081821/BULD72921645/TEJASIMHAR/HDFC0000509', 'DISBURSED', 'NEW', 'DEEPAK KUMAR', 'KISHAN KUMAR',
    'NO. 113, SAI PARADISE, ATTIBELLE ANEKAL  ROAD, MEDIHALLI, MAYASANDRA, ANEKAL  - 562107  562107', 'ASCENDUM SOLUTIONS INDIA PRIVATE LIMITED 170-172, EPIP ZONE WHITEFIELD RD, PHASE 2, BROOKEFIELD, BANGALORE 560006  560006', 20, '0-30', 'June, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    9537, 'Maharashtra', 'Thane', 'LOA00003985', 'ATTPM4511C', 'ACGLLLOT00000004463', 'PARESH CHANDRAKANT MORE', 9920179462, 'P.MORE1989@GMAIL.COM',
    25000, 21250, 3178, 572, 3750, 572.03, 0, 0, 3177.97,
    21, 0.75, 28937.5, '2026-06-09', '2026-06-30', '''0148565201', 'Kotak Mahindra Bank',
    'KKBK0001416', 'MMT/IMPS/616019355818/BULD72940013/PARESHCHAN/KKBK0001416', 'DISBURSED', 'NEW', 'PAYAL SHARMA', 'KISHAN KUMAR',
    'RIDHHI PARK CHS, A WING, 4TH FLOOR, ROOM NO. 404, MADHUKAR NAGAR, OPP. GAVDEVI TEMPLE, CHOLEGAON, DOMBIVLI, THANE, MAHARASHTRA, RIDHHI PARK 421201', 'DP WORLD EXPRESS LOGISTICS PRIVATE LIMITED GLOBE COMPLEX, OPP WADPE, BHIWANDI 421302 GLOBE COMPLEX, OPP WADPE, BHIWANDI 421302 GLOBE COMPLEX, OPP WADPE, BHIWANDI 421302 421302', 20, '0-30', 'June, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    9585, 'Maharashtra', 'Pune', 'LOA00003998', 'CQDPS0503H', 'ACGLLLOT00000004480', 'PAWAN HEMANTKUMAR SONI', 9970028007, 'PAWAN.SONI37@GMAIL.COM',
    75000, 63750, 9534, 1716, 11250, 1716.1, 0, 0, 9533.9,
    20, 0.75, 86250, '2026-06-10', '2026-06-30', '''108601508081', 'ICICI BANK LIMITED',
    'ICIC0000337', 'INF/INFT/044737357571/72994409     /PAWANHEMANTKUMARSONI/DISBURSE', 'DISBURSED', 'NEW', 'POOJA', 'KISHAN KUMAR',
    'FL-C-303 MARVEL ALBEROSN- 41/3/1/1 TO 6 KONDHWA BK NR. ANGARAJ DHABA 411048 FL-C-303 MARVEL ALBEROSN- 41/3/1/1 TO 6 KONDHWA BK NR. ANGARAJ DHABA 411048  411048', 'OMNYPAYMENTS SOFTWARE PVT LTD 12, SUNCITY ROAD,  ANANDNAGAR,  PUNE 411051 12, SUNCITY ROAD,  ANANDNAGAR,  PUNE 411051  411051', 20, '0-30', 'June, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    9594, 'Karnataka', 'Bangalore', 'LOA00004005', 'AOKPV0764Q', 'ACGLLLOT00000004487', 'VINEETH  V', 9620938476, 'VVINEETH.VISHWANATH@GMAIL.COM',
    50000, 42500, 6356, 1144, 7500, 1144.07, 0, 0, 6355.93,
    16, 0.75, 56000, '2026-06-10', '2026-06-26', '''45010205692', 'STANDARD CHARTERED BANK',
    'SCBL0036102', 'MMT/IMPS/616119547436/BULD73025275/VINEETHV/SCBL0036102', 'DISBURSED', 'NEW', 'GARISHMA', 'KISHAN KUMAR',
    '558,ROHINI NILAYAM ,5TH CROSS, SREE NARAYANA LAYOUT,BETTADASANPURA,BANGALORE, KARNATAK A,560114 558,ROHINI NILAYAM ,5TH CROSS, SREE NARAYANA LAYOUT,BETTADASANPURA,BANGALORE ,KARNATAK A,560114  560068', 'STANDARD CHARTERED GLOBAL BUSINESS SERVICES PRIVATE LIMITED STANDARD CHARTERED GLOBAL BUSINESS SERVICES PRIVATE LIMITED, RMZ ECOWORLD, ADARSH PALM RETREAT, BELLANDUR, BENGALURU - 560103 STANDARD CHARTERED GLOBAL BUSINESS SERVICES PRIVATE LIMITED, RMZ ECOWORLD, ADARSH PALM RETREAT, BELLANDUR, BENGALURU - 560103  560103', 24, '0-30', 'June, 2026', 'PART-PAYMENT'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    9602, 'West Bengal', 'Kolkata', 'ADV00001643', 'BDRPB7870C', 'ACGLLLOT00000004488', 'SAHARSH  BAGLA', 7980150361, 'SAHARSHBAGLA@GMAIL.COM',
    22000, 18700, 2797, 503, 3300, 503.39, 0, 0, 2796.61,
    26, 0.75, 26290, '2026-06-10', '2026-07-06', '''110113000428', 'CANARA BANK',
    'CNRB0003267', 'MMT/IMPS/616119547501/BULD73025275/SAHARSHBAG/CNRB0003267', 'DISBURSED', 'REPEAT', 'SHIVANI JOSHI', 'KISHAN KUMAR',
    '4/5 SINGHI BAGAN LANE.1ST FLOOR KOLKATA -700007  700007', 'CABCON INDIA LTD BG- 12 ACTION AREA 1 B, THE TERMINUS BUILDING. 1ST FLOOR. KOLKATA - 700156  700156', 14, '0-30', 'June, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    9603, 'Uttar Pradesh', 'Ghaziabad', 'LOA00004007', 'BBVPJ8600E', 'ACGLLLOT00000004490', 'SAURABH  JAIN', 7026037940, 'JNSAURABH24@GMAIL.COM',
    40000, 34000, 5085, 915, 6000, 915.25, 0, 0, 5084.75,
    20, 0.75, 46000, '2026-06-10', '2026-06-30', '''9414210203', 'KOTAK MAHINDRA BANK',
    'KKBK0005298', 'MMT/IMPS/616119549180/BULD73025275/SAURABHJAI/KKBK0005298', 'DISBURSED', 'NEW', 'DEEPAK KUMAR', 'KISHAN KUMAR',
    'M4 1001 AMARPALI GOLF HOME  10TH FLOOR GREATER NOIDA 201016  201016', 'COFORGE LTD SECTOR TECH ZONE, PLOT NO. TZ-2 & 2A, YAMUNA EXPY, GREATER NOIDA, UTTAR PRADESH 201308  201308', 20, '0-30', 'June, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    9633, 'Telangana', 'Hyderabad', 'LOA00003543', 'AHQPA3644R', 'ACGLLLOT00000004498', 'RAMARAO  ARRABELLI', 9052537888, 'RAMA.R452@GMAIL.COM',
    45000, 38250, 5720, 1030, 6750, 1029.66, 0, 0, 5720.34,
    19, 0.75, 51412.5, '2026-06-11', '2026-06-30', '''75780100010173', 'BANK OF BARODA',
    'BARB0VJJUBI', 'MMT/IMPS/616217313928/BULD73082468/RAMARAOARR/BARB0VJJUBI', 'DISBURSED', 'REPEAT', 'GARISHMA', NULL,
    'FLAT NO.501, SUPRIYA MEADOWS, ROAD NO.27, DEEPTHISRI NAGAR, MADINAGUDA, HYDERABAD 500015', 'OPTUM GLOBAL SOLUTIONS (INDIA) PRIVATE LIMITED BUILDING NO 12B, RAHEJA MINDSPACE, Hitec city,Hyderabad 500012', 20, '0-30', 'June, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    9635, 'Tamil Nadu', 'Chennai', 'LOA00004014', 'AHAPH2095R', 'ACGLLLOT00000004503', 'HARISUNDAR  VAITHIYANATHAN', 9994214565, 'HARISUNDAR.VAITHIYANATHAN.CHN@GMAIL.COM',
    45000, 38250, 5720, 1030, 6750, 1029.66, 0, 0, 5720.34,
    19, 0.75, 51412.5, '2026-06-11', '2026-06-30', '''500101014381428', 'CITY UNION BANK LIMITED',
    'CIUB0000446', 'MMT/IMPS/616219588458/BULD73101211/HARISUNDAR/CIUB0000446', 'DISBURSED', 'NEW', 'GARISHMA', 'KISHAN KUMAR',
    'A208,AVADI, CHENNAI,.,NEWRY TRITON,,THIRUVALLUR,TAMIL NADU,600071 A208,AVADI, CHENNAI,.,NEWRY TRITON,,THIRUVALLUR,TAMIL NADU,600071  600078', 'CITY UNION BANK LIMITED CITY UNION BANK NO61 CP RAMASAMY ROAD ABIRAMAPURAM  CHENNAI 600028 CITY UNION BANK NO61 CP RAMASAMY ROAD ABIRAMAPURAM  CHENNAI 600028  600028', 20, '0-30', 'June, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    9667, 'Maharashtra', 'Pune', 'LOA00003987', 'BNQPS1420L', 'ACGLLLOT00000004508', 'RUSHIKESH VIJAY SHELAR', 8793012208, 'RUSHIKESH.V.SHELAR@GMAIL.COM',
    80000, 68000, 10169, 1831, 12000, 1830.51, 0, 0, 10169.49,
    19, 0.75, 91400, '2026-06-12', '2026-07-01', '''50100334356039', 'HDFC BANK',
    'HDFC0000039', 'MMT/IMPS/616313855441/BULD73130745/RUSHIKESHV/HDFC0000039', 'DISBURSED', 'NEW', 'PAYAL SHARMA', 'KISHAN KUMAR',
    'FLAT NO 202 FLAT NO 202,MANASI SOC337416 MANASI APARTMENT SAHAKAR NAGAR 2 DHIMKAR PATH NEAR KANAK KUNJ  PUNE CITY WEST PUNE MAHARASHTRA MANASI APARTMENT 411009', 'TECHNICOLOR CREA VE STUDIOS, ONE INTERNATIONAL CENTER, 5TH FLOOR, 501-505. PRABHADEVI, DADAR WEST. MUMBAI ONE INTERNATIONAL CENTER, 5TH FLOOR, 501-505. PRABHADEVI, DADAR WEST. MUMBAI ONE INTERNATIONAL CENTER, 5TH FLOOR, 501-505. PRABHADEVI, DADAR WEST. MUMBAI 400013', 19, '0-30', 'June, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    9680, 'Maharashtra', 'Pune', 'LOA00003733', 'BKIPP0855P', 'ACGLLLOT00000004511', 'RAHUL RAMESH P', 9778384804, 'RAHULRAKKU@GMAIL.COM',
    30000, 25500, 3814, 686, 4500, 686.44, 0, 0, 3813.56,
    29, 0.75, 36525, '2026-06-12', '2026-07-11', '''50100416275892', 'HDFC BANK',
    'HDFC0001445', 'MMT/IMPS/616317363561/BULD73155466/RAHULRAMES/HDFC0001445', 'DISBURSED', 'REPEAT', 'POOJA', NULL,
    'SHIVARAYI COMPLEX FLAT NO 302 OPP HANUMAN MANDIR, AWALVADI, AWALVADI AWALVADI PUNE PUNE, MAHARASHTRA, 412207  412207', 'MILLENNIUM ENGINEERS AND CONTRACTORS PRIVATE LIMITED MITCON ROAD PUNE-411045  411045', 9, '0-30', 'June, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    9701, 'Delhi', 'New Delhi', 'LOA00004024', 'BMZPR5560E', 'ACGLLLOT00000004519', 'ANCHAL  RASTOGI', 8810336603, 'ANCHAL.RASTOGI31@GMAIL.COM',
    20000, 17000, 2542, 458, 3000, 0, 228.81, 228.81, 2542.37,
    20, 0.75, 23000, '2026-06-12', '2026-07-02', '''082901513384', 'ICICI BANK LIMITED',
    'ICIC0001024', 'INF/INFT/044771595601/73174915     /ANCHALRASTOGI/', 'DISBURSED', 'NEW', 'DEEPAK KUMAR', 'KISHAN KUMAR',
    '191/4 FIRST FLOOR GALI NO-14 BHOLA NATH NAGAR SHAHDARA DELHI 110032  110032', 'INFINITE COMPUTER SOLUTIONS (INDIA) LIMITED INFINITE COMPUTER SOLUTIONS SEC 58 A BLOCK NOIDA 201301  201301', 18, '0-30', 'June, 2026', 'PART-PAYMENT'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    9766, 'Karnataka', 'Bangalore', 'LOA00004032', 'ALSPY7347R', 'ACGLLLOT00000004530', 'PANKAJ  YADAV', 6361319253, 'D.PNKAJYADAV@GMAIL.COM',
    15000, 12750, 1907, 343, 2250, 343.22, 0, 0, 1906.78,
    17, 0.75, 16912.5, '2026-06-13', '2026-06-30', '''10048534591', 'Idfc Bank',
    'IDFB0040103', 'MMT/IMPS/616418121494/BULD73221233/PANKAJYADA/IDFB0040103', 'DISBURSED', 'NEW', 'POOJA', 'KISHAN KUMAR',
    '309,247/ RV ILLAM NEW MICO LOYOUT  6TH CROSS RAGHAVENDRA LAYOUT, BEGUR , BANGALORE 560068 309,247/ RV ILLAM NEW MICO LOYOUT  6TH CROSS RAGHAVENDRA LAYOUT, BEGUR , BANGALORE 560068  560068', 'TVS ELECTRONICS LIMITED 9TH FLOOR, BRIGADE DECCAN HEIGHTS, TUMKUR RD, YESHWANTHPUR INDUSTRIAL AREA, PHASE 1, YESWANTHPUR, BENGALURU, KARNATAKA 560022 9TH FLOOR, BRIGADE DECCAN HEIGHTS, TUMKUR RD, YESHWANTHPUR INDUSTRIAL AREA, PHASE 1, YESWANTHPUR, BENGALURU, KARNATAKA 560022  560022', 20, '0-30', 'June, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    9775, 'Maharashtra', 'Thane', 'LOA00004033', 'DCYPP5309G', 'ACGLLLOT00000004531', 'PRASHANT SHRIRANG PATIL', 9920140196, 'PATILPRASHANT3296@GMAIL.COM',
    15000, 12750, 1907, 343, 2250, 343.22, 0, 0, 1906.78,
    17, 0.75, 16912.5, '2026-06-13', '2026-06-30', '''50100857024691', 'HDFC BANK',
    'HDFC0004435', 'MMT/IMPS/616418120472/BULD73221233/PRASHANTSH/HDFC0004435', 'DISBURSED', 'NEW', 'DEEPAK KUMAR', 'KISHAN KUMAR',
    'AAI SADAN SOCIETY , ROOM NO 101 , NERUL SHIRAWANE MARKET NEAR TIMES ELECTRONIC, 400706  400706', 'HDFC SALES HDFC SALES PVT LTD, OFFICE NUMBER - 214 , RUPA SOLITAIRE ,KOPARKHAIRANE, 400710  400710', 20, '0-30', 'June, 2026', 'PART-PAYMENT'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    9771, 'Gujarat', 'Ahmedabad', 'LOA00004050', 'AXHPP3442P', 'ACGLLLOT00000004549', 'AMIT GANESHBHAI RAJPUT', 7622000087, 'NYAASA.ENTERPRISE01@GMAIL.COM',
    50000, 42500, 6356, 1144, 7500, 1144.07, 0, 0, 6355.93,
    21, 0.75, 57875, '2026-06-15', '2026-07-06', '''10000261071', 'IDFC BANK LIMITED',
    'IDFB0040301', 'MMT/IMPS/616619330317/BULD73302135/AMITGANESH/IDFB0040301', 'DISBURSED', 'NEW', 'TANNU SINGH', 'KISHAN KUMAR',
    '54 DIPMALA SOC. B\H. JAGDAS SOC. KADILA LAB. RD. GHODASAR AHMEDABAD JAGDAS SOC. 380050', 'PARMESHWAR COMMODITIES 41, NEELKANTH INDUSTRIAL PARK, NEAR VATVA RAILWAY BRIDGE, VATVA - 382440, AHMEDABAD, GUJARAT NEAR VATVA RAILWAY BRIDGE, 382440', 14, '0-30', 'June, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    9845, 'Delhi', 'New Delhi', 'LOA00004044', 'GOWPD7963D', 'ACGLLLOT00000004543', 'MOHIT  DHINGRA', 8700650684, 'DHINGRAMOHIT891@GMAIL.COM',
    40000, 34000, 5085, 915, 6000, 0, 457.63, 457.63, 5084.75,
    15, 0.75, 44500, '2026-06-15', '2026-06-30', '''924010070707522', 'AXIS BANK',
    'UTIB0005152', 'MMT/IMPS/616617028753/BULD73282064/MOHITDHING/UTIB0005152', 'DISBURSED', 'NEW', 'DEEPAK KUMAR', 'KISHAN KUMAR',
    'WZ-3B , 11A VISHNU GARDEN DELHI  110018', 'WINDMOLLER AND HOLSCHER INDIA PVT LTD WINDMOLLER AND HOLSCHER INDIA PVT LTD , KAILASH COLONY , NEAR BANDHAN BANK 3RD FLOOR, 17,18,19 KAILASH ENCLAVE OPPOSITE METRO NO 76 LALA LAJPAT RAI ROAD NEAR KAILASH COLONY SOUTH - 110048  110048', 20, '0-30', 'June, 2026', 'PART-PAYMENT'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    9906, 'Karnataka', 'Bangalore', 'LOA00004052', 'CZIPS8721D', 'ACGLLLOT00000004554', 'SURESH  M', 8951253189, 'SSURI6771@GMAIL.COM',
    18000, 15300, 2288, 412, 2700, 411.86, 0, 0, 2288.14,
    14, 0.75, 19890, '2026-06-16', '2026-06-30', '''315701503510', 'ICICI BANK LTD',
    'ICIC0003157', 'INF/INFT/044811028081/73368371     /SURESHM/', 'DISBURSED', 'NEW', 'POOJA', 'KISHAN KUMAR',
    '14 2ND B CROSS HOSAHALLI VIJAYANAGAR BANGLURU 560040 14 2ND B CROSS HOSAHALLI VIJAYANAGAR BANGLURU 560040  560040', 'ACCENTURE SOLUTIONS PVT LTD AACENTURE, BDC10 BAGMANE TECH PARK TOWER A MAHADEVPURA GHOSALA ROAD BANGALORE 560048 AACENTURE, BDC10 BAGMANE TECH PARK TOWER A MAHADEVPURA GHOSALA ROAD BANGALORE 560048  560048', 20, '0-30', 'June, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    9979, 'Karnataka', 'Bangalore', 'LOA00004062', 'ASKPM7521L', 'ACGLLLOT00000004568', 'SARADINDU  MULLICK', 7439570720, 'MALLICKSARAD@GMAIL.COM',
    35000, 29750, 4449, 801, 5250, 800.85, 0, 0, 4449.15,
    21, 0.75, 40512.5, '2026-06-17', '2026-07-08', '''99980130129039', 'FEDERAL BANK',
    'FDRL0002166', 'MMT/IMPS/616819106728/BULD73430773/SARADINDUM/FDRL0002166', 'DISBURSED', 'NEW', 'TANNU SINGH', 'KISHAN KUMAR',
    'NO 376/3 7HULIMAVU VILLAGE BEGUR HOBLI  , KAR 560076 HULIMAVU VILLAGE 560076', 'MODERN SPAACES KADA AGRAHARA RD, SREE NARAYANA NAGAR, KOMMASANDRA KADA AGRAHARA, KARNATAKA 562125 KOMMASANDRA 562125', 12, '0-30', 'June, 2026', 'OPEN'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    10040, 'Karnataka', 'Bangalore', 'LOA00004073', 'APXPA3904R', 'ACGLLLOT00000004577', 'ARYAN  VAISHNAV', 7676867670, 'ARYANVAISHNAV55@GMAIL.COM',
    50000, 42500, 6356, 1144, 7500, 1144.07, 0, 0, 6355.93,
    12, 0.75, 54500, '2026-06-18', '2026-06-30', '''5308436813', 'AXIS BANK',
    'UTIB0005157', 'MMT/IMPS/616919013329/BULD73491126/ARYANVAISH/UTIB0005157', 'DISBURSED', 'NEW', 'POOJA', 'KISHAN KUMAR',
    'K2N APTS, FLAT-NO .301 4TH CROSS, MLA LAYOUT KALENA AGRAHARA BENGALURU K2N APTS, FLAT-NO .301 4TH CROSS, MLA LAYOUT KALENA AGRAHARA BENGALURU KARNATAKA  560076', 'HEWLETT PACKARD ENTERPRISE GLOBALSOFT PRIVATE LIMITED EC-2 CAMPUS,HPE AVENUE,SURVEY NO.39(PART) ELECTRONIC CITY PHASE II, HOSUR ROAD, BANGALORE 560100 EC-2 CAMPUS,HPE AVENUE,SURVEY NO.39(PART) ELECTRONIC CITY PHASE II, HOSUR ROAD, BANGALORE 560100  560100', 20, '0-30', 'June, 2026', 'PART-PAYMENT'
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;
