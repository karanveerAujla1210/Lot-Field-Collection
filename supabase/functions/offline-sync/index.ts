// Supabase Edge Function: offline-sync
// High-reliability offline execution queue sync & conflict resolution engine

import { serve } from "https://deno.land/std@0.177.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.45.0";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

interface SyncItem {
  id: string; // Offline temp UUID
  type: "VISIT" | "PAYMENT" | "FOLLOWUP" | "GPS_LOG" | "ATTENDANCE";
  action: "CREATE" | "UPDATE";
  client_timestamp: string;
  data: any;
}

serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const supabaseUrl = Deno.env.get("SUPABASE_URL") || "";
    const supabaseServiceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") || "";
    const supabase = createClient(supabaseUrl, supabaseServiceKey);

    const { executive_id, device_id, queue, sync_started_at } = await req.json() as {
      executive_id: string;
      device_id: string;
      queue: SyncItem[];
      sync_started_at: string;
    };

    if (!executive_id || !device_id || !Array.isArray(queue)) {
      return new Response(
        JSON.stringify({ error: "Invalid sync payload format." }),
        { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    let uploadedCount = 0;
    let conflictCount = 0;
    const errors: any[] = [];
    const syncedIds: string[] = [];

    // Process each item in offline queue
    for (const item of queue) {
      try {
        if (item.type === "VISIT") {
          const visitCode = item.data.visit_code || `VIS-${Date.now()}-${Math.floor(Math.random()*1000)}`;
          const { error } = await supabase.from("visits").insert({
            ...item.data,
            visit_code: visitCode,
            executive_id,
          });
          if (error && error.code !== "23505") throw error; // Ignore duplicate code
        } else if (item.type === "PAYMENT") {
          const receiptNumber = item.data.receipt_number || `RCP-${Date.now()}-${Math.floor(Math.random()*1000)}`;
          const paymentCode = item.data.payment_code || `PAY-${Date.now()}-${Math.floor(Math.random()*1000)}`;
          const { error } = await supabase.from("payments").insert({
            ...item.data,
            payment_code: paymentCode,
            receipt_number: receiptNumber,
            executive_id,
          });
          if (error && error.code !== "23505") throw error;
        } else if (item.type === "FOLLOWUP") {
          const followupCode = item.data.followup_code || `FLP-${Date.now()}-${Math.floor(Math.random()*1000)}`;
          const { error } = await supabase.from("followups").insert({
            ...item.data,
            followup_code: followupCode,
            executive_id,
          });
          if (error && error.code !== "23505") throw error;
        } else if (item.type === "GPS_LOG") {
          const { error } = await supabase.from("gps_logs").insert({
            ...item.data,
            executive_id,
            device_id,
          });
          if (error) throw error;
        } else if (item.type === "ATTENDANCE") {
          const { error } = await supabase.from("attendance").upsert({
            ...item.data,
            executive_id,
          }, { onConflict: "executive_id, date" });
          if (error) throw error;
        }

        syncedIds.push(item.id);
        uploadedCount++;
      } catch (err: any) {
        conflictCount++;
        errors.push({ id: item.id, type: item.type, error: err.message });
      }
    }

    // Download latest server state for Executive (Delta sync)
    const { data: updatedAllocations } = await supabase
      .from("allocations")
      .select("*, loans(*, customers(*))")
      .eq("executive_id", executive_id)
      .in("status", ["ASSIGNED", "IN_PROGRESS", "PARTIALLY_COLLECTED"]);

    // Write Sync Log
    await supabase.from("sync_logs").insert({
      executive_id,
      device_id,
      sync_started_at,
      sync_completed_at: new Date().toISOString(),
      records_uploaded: uploadedCount,
      records_downloaded: updatedAllocations?.length || 0,
      status: conflictCount === 0 ? "SUCCESS" : "PARTIAL",
      conflict_count: conflictCount,
      error_details: errors,
    });

    return new Response(
      JSON.stringify({
        success: true,
        synced_ids: syncedIds,
        records_uploaded: uploadedCount,
        delta_allocations: updatedAllocations || [],
        conflict_count: conflictCount,
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
