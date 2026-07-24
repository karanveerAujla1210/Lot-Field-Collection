// Supabase Edge Function: payment-processor
// Financial collection processor, receipt generator & ledger synchronization

import { serve } from "https://deno.land/std@0.177.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.45.0";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const supabaseUrl = Deno.env.get("SUPABASE_URL") || "";
    const supabaseServiceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") || "";
    const supabase = createClient(supabaseUrl, supabaseServiceKey);

    const {
      visit_id,
      loan_id,
      customer_id,
      executive_id,
      branch_id,
      amount_paid,
      payment_mode,
      payment_reference,
      receipt_photo_url,
    } = await req.json();

    if (!loan_id || !customer_id || !executive_id || !amount_paid || !payment_mode) {
      return new Response(
        JSON.stringify({ error: "Missing required payment fields." }),
        { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    // Generate Unique Receipt Number
    const timestamp = Date.now().toString().slice(-6);
    const randomSuffix = Math.floor(1000 + Math.random() * 9000);
    const receiptNumber = `RCP-${timestamp}-${randomSuffix}`;
    const paymentCode = `PAY-${timestamp}-${randomSuffix}`;

    // Insert Payment Record (Triggers DB function update_loan_balances_on_payment)
    const { data: payment, error: payErr } = await supabase.from("payments").insert({
      payment_code: paymentCode,
      receipt_number: receiptNumber,
      visit_id: visit_id || null,
      loan_id,
      customer_id,
      executive_id,
      branch_id,
      amount_paid: Number(amount_paid),
      payment_mode,
      payment_reference: payment_reference || `REF-${receiptNumber}`,
      receipt_photo_url: receipt_photo_url || null,
      payment_status: "SUCCESS",
    }).select("*").single();

    if (payErr) throw payErr;

    // Fetch updated Loan state
    const { data: updatedLoan } = await supabase.from("loans").select("*").eq("id", loan_id).single();

    // Fetch Branch Manager for Notification
    const { data: managers } = await supabase
      .from("users")
      .select("id")
      .eq("branch_id", branch_id)
      .in("role_id", (
        await supabase.from("roles").select("id").in("code", ["BRANCH_MANAGER", "COLLECTION_MANAGER"])
      ).data?.map(r => r.id) || []);

    if (managers && managers.length > 0) {
      const notifications = managers.map(m => ({
        user_id: m.id,
        title: "Payment Collected",
        body: `Payment of ₹${amount_paid} (${payment_mode}) collected for Receipt #${receiptNumber}.`,
        notification_type: "PAYMENT",
        entity_type: "PAYMENT",
        entity_id: payment.id,
      }));
      await supabase.from("notifications").insert(notifications);
    }

    return new Response(
      JSON.stringify({
        success: true,
        message: "Payment processed, receipt generated, and loan outstanding updated successfully.",
        payment,
        updated_outstanding: updatedLoan?.total_outstanding,
        receipt_number: receiptNumber,
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
