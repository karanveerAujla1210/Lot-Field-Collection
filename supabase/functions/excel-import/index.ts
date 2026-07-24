// Supabase Edge Function: excel-import
// High-capacity streaming Excel/CSV parser and portfolio allocation engine

import { serve } from "https://deno.land/std@0.177.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.45.0";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

interface ImportRow {
  customer_code: string;
  full_name: string;
  phone_primary: string;
  address_residence: string;
  city: string;
  state: string;
  pincode: string;
  branch_code: string;
  loan_account_number: string;
  loan_type: string;
  disbursed_amount: number;
  principal_outstanding: number;
  emi_amount: number;
  disbursed_date: string;
  maturity_date: string;
  next_emi_due_date: string;
  executive_employee_code: string;
  target_amount: number;
  allocation_due_date: string;
}

serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const supabaseUrl = Deno.env.get("SUPABASE_URL") || "";
    const supabaseServiceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") || "";
    const supabase = createClient(supabaseUrl, supabaseServiceKey);

    const { job_id, rows, uploaded_by } = await req.json() as {
      job_id: string;
      rows: ImportRow[];
      uploaded_by: string;
    };

    if (!job_id || !rows || !Array.isArray(rows)) {
      return new Response(
        JSON.stringify({ error: "Invalid payload format. Expected job_id and rows array." }),
        { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    // Update job status to PROCESSING
    await supabase.from("import_jobs").update({
      status: "PROCESSING",
      total_records: rows.length,
    }).eq("id", job_id);

    let successCount = 0;
    let errorCount = 0;
    const errors: { row: number; reason: string; customer_code?: string }[] = [];

    // Pre-cache branches and users map
    const { data: branchData } = await supabase.from("branches").select("id, branch_code");
    const { data: userData } = await supabase.from("users").select("id, employee_code, branch_id");

    const branchMap = new Map<string, string>();
    branchData?.forEach(b => branchMap.set(b.branch_code, b.id));

    const userMap = new Map<string, { id: string; branch_id: string }>();
    userData?.forEach(u => userMap.set(u.employee_code, { id: u.id, branch_id: u.branch_id }));

    // Process rows in batch
    for (let i = 0; i < rows.length; i++) {
      const row = rows[i];
      try {
        if (!row.customer_code || !row.loan_account_number || !row.branch_code || !row.executive_employee_code) {
          throw new Error("Missing mandatory fields (customer_code, loan_account_number, branch_code, or executive_employee_code)");
        }

        const branchId = branchMap.get(row.branch_code);
        if (!branchId) throw new Error(`Branch code ${row.branch_code} not found in database`);

        const execInfo = userMap.get(row.executive_employee_code);
        if (!execInfo) throw new Error(`Executive code ${row.executive_employee_code} not found`);

        // 1. Upsert Customer
        const { data: customer, error: custErr } = await supabase.from("customers").upsert({
          customer_code: row.customer_code,
          full_name: row.full_name,
          phone_primary: row.phone_primary,
          address_residence: row.address_residence,
          city: row.city,
          state: row.state,
          pincode: row.pincode,
          branch_id: branchId,
        }, { onConflict: "customer_code" }).select("id").single();

        if (custErr) throw custErr;

        // 2. Upsert Loan
        const totalOutstanding = (row.principal_outstanding || 0);
        const { data: loan, error: loanErr } = await supabase.from("loans").upsert({
          loan_account_number: row.loan_account_number,
          customer_id: customer.id,
          branch_id: branchId,
          loan_type: row.loan_type || "Personal Loan",
          disbursed_amount: row.disbursed_amount || totalOutstanding,
          principal_outstanding: row.principal_outstanding,
          total_outstanding: totalOutstanding,
          emi_amount: row.emi_amount || 0,
          disbursed_date: row.disbursed_date || new Date().toISOString().split("T")[0],
          maturity_date: row.maturity_date || new Date().toISOString().split("T")[0],
          next_emi_due_date: row.next_emi_due_date || new Date().toISOString().split("T")[0],
        }, { onConflict: "loan_account_number" }).select("id").single();

        if (loanErr) throw loanErr;

        // 3. Create Allocation
        const allocationCode = `ALLOC-${Date.now()}-${i}`;
        const { error: allocErr } = await supabase.from("allocations").insert({
          allocation_code: allocationCode,
          loan_id: loan.id,
          customer_id: customer.id,
          executive_id: execInfo.id,
          assigned_by: uploaded_by,
          branch_id: branchId,
          due_date: row.allocation_due_date || new Date().toISOString().split("T")[0],
          target_amount: row.target_amount || row.emi_amount || totalOutstanding,
          status: "ASSIGNED",
        });

        if (allocErr) throw allocErr;

        // 4. Dispatch Notification to Field Executive
        await supabase.from("notifications").insert({
          user_id: execInfo.id,
          title: "New Customer Allocated",
          body: `Loan #${row.loan_account_number} (${row.full_name}) has been allocated to you.`,
          notification_type: "ALLOCATION",
          entity_type: "LOAN",
          entity_id: loan.id,
        });

        successCount++;
      } catch (err: any) {
        errorCount++;
        errors.push({ row: i + 1, reason: err.message, customer_code: row.customer_code });
      }

      // Update progress every 10 records
      if (i % 10 === 0 || i === rows.length - 1) {
        await supabase.from("import_jobs").update({
          processed_records: i + 1,
          success_count: successCount,
          error_count: errorCount,
          error_log_json: errors,
        }).eq("id", job_id);
      }
    }

    // Mark Job Completed
    await supabase.from("import_jobs").update({
      status: errorCount === rows.length ? "FAILED" : "COMPLETED",
      finished_at: new Date().toISOString(),
    }).eq("id", job_id);

    return new Response(
      JSON.stringify({
        success: true,
        message: "Excel import completed",
        total: rows.length,
        successCount,
        errorCount,
        errors,
      }),
      { status: 200, headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  } catch (err: any) {
    return new Response(
      JSON.stringify({ error: err.message }),
      { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  }
});
