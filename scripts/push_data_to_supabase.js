const { createClient } = require('@supabase/supabase-js');
const xlsx = require('xlsx');

const SUPABASE_URL = 'https://tflsmxmuvrecrewknbvb.supabase.co';
const SUPABASE_KEY = 'sb_publishable_OAx279ocalpzqLVAhhMb-w_WdfkOWUH';
const supabase = createClient(SUPABASE_URL, SUPABASE_KEY);

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

function excelDateToISO(serial) {
  if (!serial) return null;
  if (typeof serial === 'string') return serial;
  if (isNaN(serial)) return null;
  const utc_days = Math.floor(serial - 25569);
  const date_info = new Date(utc_days * 86400 * 1000);
  return date_info.toISOString().split('T')[0];
}

async function main() {
  console.log('--- STARTING BULK PUSH TO SUPABASE ---');

  // 1. Seed Users (Staff)
  const usersPayload = staffData.map(s => ({
    employee_code: s.empCode,
    full_name: s.name,
    email: `${s.name.toLowerCase()}@fincollect.com`,
    phone: s.phone,
    status: 'ACTIVE'
  }));

  const { data: uData, error: uErr } = await supabase.from('users').upsert(usersPayload, { onConflict: 'phone' }).select();
  if (uErr) {
    console.error('Users push error (check if RLS disabled):', uErr.message);
  } else {
    console.log(`Successfully pushed ${uData?.length || usersPayload.length} staff records into public.users!`);
  }

  // 2. Read Excel & Seed Cases
  const excelPath = 'C:\\Users\\DELL\\Downloads\\Open & Part Cases till 20th July.xlsx';
  const wb = xlsx.readFile(excelPath);
  const sheet = wb.Sheets[wb.SheetNames[0]];
  const casesRows = xlsx.utils.sheet_to_json(sheet);

  console.log(`Preparing to push ${casesRows.length} cases to public.cases...`);

  const casesPayload = casesRows.map((r, idx) => ({
    lead_id: r['Lead Id'] || null,
    state_name: r['State Name'] || null,
    branch_name: r['Branch Name'] || null,
    customer_code: r['Customer Id'] || `CUST-${idx + 1}`,
    pan_number: r['Pan Number'] || null,
    loan_no: r['Loan No'] || `LOAN-${idx + 1}`,
    customer_name: r['Customer Name'] || null,
    mobile_number: r['Mobile Number'] ? String(r['Mobile Number']) : null,
    email: r['Email'] || null,
    loan_amount: r['Loan Amount'] || 0,
    net_disbursed_amount: r['Net Disbursed Amount'] || 0,
    admin_fee: r['Admin Fee'] || 0,
    admin_fee_gst: r['Admin Fee GST'] || 0,
    total_admin_fee: r['Total Admin Fee'] || 0,
    igst: r['IGST'] || 0,
    cgst: r['CGST'] || 0,
    sgst: r['SGST'] || 0,
    processing: r['Processing'] || 0,
    tenure: r['Tenure'] || 0,
    roi: r['ROI'] || 0,
    loan_repay_amount: r['Loan Repay Amount'] || 0,
    disbursement_date: excelDateToISO(r['Disbursement Date']),
    repayment_date: excelDateToISO(r['Repayment Date']),
    customer_bank_account: r['Customer Bank Account Number'] ? String(r['Customer Bank Account Number']) : null,
    customer_bank_name: r['Customer Bank Name'] || null,
    customer_bank_ifsc: r['Customer Bank IFSC'] || null,
    disbursement_reference: r['Refrence No Of Disbursement'] || null,
    disbursement_status: r['Disbursement Status'] || null,
    repeat_type: r['Repeat Type'] || null,
    sanctioned_by: r['Sanctioned By'] || null,
    approved_by: r['Approved By'] || null,
    house_address: r['House Address'] || null,
    office_address: r['Office Address'] || null,
    due_days: r['Due Days'] || 0,
    bucket: r['Bucket'] || null,
    month: r['Month'] || null,
    loan_status: r['Loan Status'] || 'OPEN'
  }));

  // Push in batches of 100
  const BATCH_SIZE = 100;
  let totalInserted = 0;

  for (let i = 0; i < casesPayload.length; i += BATCH_SIZE) {
    const batch = casesPayload.slice(i, i + BATCH_SIZE);
    const { data: cData, error: cErr } = await supabase.from('cases').upsert(batch, { onConflict: 'loan_no' }).select('id');
    if (cErr) {
      console.error(`Batch ${i / BATCH_SIZE + 1} push error:`, cErr.message);
    } else {
      totalInserted += (cData?.length || batch.length);
      console.log(`Pushed batch ${i / BATCH_SIZE + 1}: ${totalInserted}/${casesPayload.length} cases.`);
    }
  }

  console.log('--- FINISHED BULK PUSH ---');
}

main();
