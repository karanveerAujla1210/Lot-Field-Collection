const fs = require('fs');
const path = require('path');
const xlsx = require('xlsx');

// 1. Staff Data from User Image
const staffData = [
  { name: 'Jitendra', location: 'Bangalore', phone: '9449477443', empCode: 'EMP001' },
  { name: 'Sushant', location: 'Delhi - Gurugram', phone: '8700413312', empCode: 'EMP002' },
  { name: 'Rahul', location: 'Noida - Ghaziabad - Faridabad', phone: '7042793573', empCode: 'EMP003' },
  { name: 'Imteyaz', location: 'West bengal - Kolkata', phone: '8100669081', empCode: 'EMP004' },
  { name: 'Anil', location: 'Ahemdabad - Gujarat', phone: '8320109581', empCode: 'EMP005' },
  { name: 'Prince', location: 'Hyderabad', phone: '6302703146', empCode: 'EMP006' },
  { name: 'Abhishek', location: 'Hyderabad', phone: '9908923165', empCode: 'EMP007' },
  { name: 'Vijay', location: 'Mumbai', phone: '9579527355', empCode: 'EMP008' },
  { name: 'Roshan', location: 'Thane - Raigarh', phone: '9321048358', empCode: 'EMP009' },
  { name: 'Ketan', location: 'Pune', phone: '7385313114', empCode: 'EMP010' }
];

// Helper to sanitize text for SQL
function sqlEscape(str) {
  if (str === null || str === undefined) return 'NULL';
  if (typeof str === 'number') return str;
  const cleaned = String(str).replace(/'/g, "''").trim();
  return `'${cleaned}'`;
}

// Convert Excel Serial Date to YYYY-MM-DD
function excelDateToISO(serial) {
  if (!serial) return 'NULL';
  if (typeof serial === 'string') {
    if (serial.includes('-') || serial.includes('/')) return sqlEscape(serial);
    serial = parseFloat(serial);
  }
  if (isNaN(serial)) return 'NULL';
  const utc_days = Math.floor(serial - 25569);
  const utc_value = utc_days * 86400;
  const date_info = new Date(utc_value * 1000);
  const yyyy = date_info.getFullYear();
  const mm = String(date_info.getMonth() + 1).padStart(2, '0');
  const dd = String(date_info.getDate()).padStart(2, '0');
  return `'${yyyy}-${mm}-${dd}'`;
}

// 2. Read Excel File
const excelPath = 'C:\\Users\\DELL\\Downloads\\Open & Part Cases till 20th July.xlsx';
console.log('Reading Excel file from:', excelPath);

const wb = xlsx.readFile(excelPath);
const sheet = wb.Sheets[wb.SheetNames[0]];
const casesRows = xlsx.utils.sheet_to_json(sheet);

console.log(`Loaded ${casesRows.length} cases from Excel file.`);

// Unique Branches Extraction
const branchesMap = new Map();
staffData.forEach((staff, idx) => {
  const code = `BR-${String(idx + 1).padStart(3, '0')}`;
  branchesMap.set(staff.location.toLowerCase(), {
    code,
    name: staff.location,
    city: staff.location.split('-')[0].trim(),
    state: staff.location.includes('-') ? staff.location.split('-')[1].trim() : staff.location
  });
});

casesRows.forEach(row => {
  const bName = row['Branch Name'] || row['State Name'] || 'Head Office';
  const key = String(bName).toLowerCase();
  if (!branchesMap.has(key)) {
    const code = `BR-${String(branchesMap.size + 1).padStart(3, '0')}`;
    branchesMap.set(key, {
      code,
      name: bName,
      city: String(bName).split('-')[0].trim(),
      state: row['State Name'] || 'India'
    });
  }
});

// Generate Migration SQL File
let sql = `-- =============================================================================
-- FINCOLLECT ENTERPRISE DATABASE MIGRATION & DATA SEEDING
-- Target File: Open & Part Cases till 20th July.xlsx (${casesRows.length} rows) + Staff Data (10 Field Executives)
-- Generated Date: ${new Date().toISOString()}
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
`;

branchesMap.forEach(b => {
  sql += `INSERT INTO public.branches (branch_code, name, city, state) VALUES (${sqlEscape(b.code)}, ${sqlEscape(b.name)}, ${sqlEscape(b.city)}, ${sqlEscape(b.state)}) ON CONFLICT (branch_code) DO NOTHING;\n`;
});

sql += `\n-- SEED STAFF / FIELD EXECUTIVES DATA\n`;

staffData.forEach((staff, idx) => {
  const email = `${staff.name.toLowerCase()}@lotfieldcollection.com`;
  const branchKey = staff.location.toLowerCase();
  const b = branchesMap.get(branchKey);
  const bCode = b ? b.code : 'BR-001';
  sql += `INSERT INTO public.users (employee_code, full_name, email, phone, role_id, branch_id) VALUES (${sqlEscape(staff.empCode)}, ${sqlEscape(staff.name)}, ${sqlEscape(email)}, ${sqlEscape(staff.phone)}, '10000000-0000-0000-0000-000000000006', (SELECT id FROM public.branches WHERE branch_code = ${sqlEscape(bCode)} LIMIT 1)) ON CONFLICT (phone) DO UPDATE SET full_name = EXCLUDED.full_name;\n`;
});

sql += `\n-- SEED EXCEL OPEN & PART CASES DATA (${casesRows.length} RECORDS)\n`;

casesRows.forEach((r, idx) => {
  const leadId = r['Lead Id'] || null;
  const stateName = sqlEscape(r['State Name']);
  const branchName = sqlEscape(r['Branch Name']);
  const customerId = sqlEscape(r['Customer Id'] || `CUST-${idx + 1}`);
  const pan = sqlEscape(r['Pan Number']);
  const loanNo = sqlEscape(r['Loan No'] || `LOAN-${idx + 1}`);
  const custName = sqlEscape(r['Customer Name']);
  const mobile = sqlEscape(r['Mobile Number']);
  const email = sqlEscape(r['Email']);
  const loanAmount = r['Loan Amount'] || 0;
  const netDisbursed = r['Net Disbursed Amount'] || 0;
  const adminFee = r['Admin Fee'] || 0;
  const adminFeeGst = r['Admin Fee GST'] || 0;
  const totalAdminFee = r['Total Admin Fee'] || 0;
  const igst = r['IGST'] || 0;
  const cgst = r['CGST'] || 0;
  const sgst = r['SGST'] || 0;
  const processing = r['Processing'] || 0;
  const tenure = r['Tenure'] || 0;
  const roi = r['ROI'] || 0;
  const repayAmount = r['Loan Repay Amount'] || 0;
  const disbDate = excelDateToISO(r['Disbursement Date']);
  const repayDate = excelDateToISO(r['Repayment Date']);
  const bankAcc = sqlEscape(r['Customer Bank Account Number']);
  const bankName = sqlEscape(r['Customer Bank Name']);
  const bankIfsc = sqlEscape(r['Customer Bank IFSC']);
  const refNo = sqlEscape(r['Refrence No Of Disbursement']);
  const disbStatus = sqlEscape(r['Disbursement Status']);
  const repeatType = sqlEscape(r['Repeat Type']);
  const sanctionedBy = sqlEscape(r['Sanctioned By']);
  const approvedBy = sqlEscape(r['Approved By']);
  const houseAddr = sqlEscape(r['House Address']);
  const officeAddr = sqlEscape(r['Office Address']);
  const dueDays = r['Due Days'] || 0;
  const bucket = sqlEscape(r['Bucket']);
  const month = sqlEscape(r['Month']);
  const loanStatus = sqlEscape(r['Loan Status']);

  sql += `INSERT INTO public.cases (
    lead_id, state_name, branch_name, customer_code, pan_number, loan_no, customer_name, mobile_number, email,
    loan_amount, net_disbursed_amount, admin_fee, admin_fee_gst, total_admin_fee, igst, cgst, sgst, processing,
    tenure, roi, loan_repay_amount, disbursement_date, repayment_date, customer_bank_account, customer_bank_name,
    customer_bank_ifsc, disbursement_reference, disbursement_status, repeat_type, sanctioned_by, approved_by,
    house_address, office_address, due_days, bucket, month, loan_status
  ) VALUES (
    ${leadId}, ${stateName}, ${branchName}, ${customerId}, ${pan}, ${loanNo}, ${custName}, ${mobile}, ${email},
    ${loanAmount}, ${netDisbursed}, ${adminFee}, ${adminFeeGst}, ${totalAdminFee}, ${igst}, ${cgst}, ${sgst}, ${processing},
    ${tenure}, ${roi}, ${repayAmount}, ${disbDate}, ${repayDate}, ${bankAcc}, ${bankName},
    ${bankIfsc}, ${refNo}, ${disbStatus}, ${repeatType}, ${sanctionedBy}, ${approvedBy},
    ${houseAddr}, ${officeAddr}, ${dueDays}, ${bucket}, ${month}, ${loanStatus}
  ) ON CONFLICT (loan_no) DO UPDATE SET loan_status = EXCLUDED.loan_status;\n`;
});

const outPath = path.join(__dirname, '..', 'supabase', 'migrations', '20260724000004_create_all_tables_staff_and_cases.sql');
fs.writeFileSync(outPath, sql);

console.log(`Successfully generated migration file at: ${outPath} (${(sql.length / 1024).toFixed(2)} KB)`);
