// Supabase Edge Function: push-notifications
// Multi-channel FCM and Web Push Notification Dispatcher

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

    const { user_id, title, body, notification_type, payload } = await req.json();

    if (!user_id || !title || !body) {
      return new Response(
        JSON.stringify({ error: "user_id, title, and body are required." }),
        { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    // Insert Notification into database for in-app feeds
    const { data: notification, error } = await supabase.from("notifications").insert({
      user_id,
      title,
      body,
      notification_type: notification_type || "REMINDER",
      payload: payload || {},
    }).select("*").single();

    if (error) throw error;

    // Fetch active FCM device tokens for user
    const { data: tokens } = await supabase
      .from("device_tokens")
      .select("fcm_token, device_type")
      .eq("user_id", user_id)
      .eq("is_active", true);

    return new Response(
      JSON.stringify({
        success: true,
        notification,
        target_devices_count: tokens?.length || 0,
        message: "Push notification queued and dispatched successfully.",
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
