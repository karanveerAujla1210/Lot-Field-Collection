// Supabase Edge Function: dashboard-aggregator
// High-performance real-time KPI metrics aggregator for Executive, Manager, and Admin dashboards

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

    const { role, user_id, branch_id } = await req.json();

    const todayStr = new Date().toISOString().split("T")[0];

    if (role === "FIELD_EXECUTIVE") {
      // 1. Executive Dashboard KPI
      const { data: allocations } = await supabase
        .from("allocations")
        .select("id, target_amount, status")
        .eq("executive_id", user_id);

      const { data: todayPayments } = await supabase
        .from("payments")
        .select("amount_paid")
        .eq("executive_id", user_id)
        .gte("collected_at", `${todayStr}T00:00:00Z`);

      const { data: todayVisits } = await supabase
        .from("visits")
        .select("id, visit_status")
        .eq("executive_id", user_id)
        .gte("visit_date", `${todayStr}T00:00:00Z`);

      const totalTarget = allocations?.reduce((acc, a) => acc + Number(a.target_amount || 0), 0) || 0;
      const todayCollected = todayPayments?.reduce((acc, p) => acc + Number(p.amount_paid || 0), 0) || 0;
      const collectionRate = totalTarget > 0 ? ((todayCollected / totalTarget) * 100).toFixed(2) : 0;

      return new Response(
        JSON.stringify({
          role: "FIELD_EXECUTIVE",
          metrics: {
            today_allocation_count: allocations?.length || 0,
            today_target_amount: totalTarget,
            today_collected_amount: todayCollected,
            collection_percentage: collectionRate,
            pending_visits_count: allocations?.filter(a => a.status === "ASSIGNED").length || 0,
            completed_visits_today: todayVisits?.length || 0,
          },
        }),
        { status: 200, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    } else if (role === "BRANCH_MANAGER" || role === "COLLECTION_MANAGER") {
      // 2. Manager Dashboard KPI & Ranking
      const { data: branchPayments } = await supabase
        .from("payments")
        .select("amount_paid, executive_id, users(full_name)")
        .eq("branch_id", branch_id)
        .gte("collected_at", `${todayStr}T00:00:00Z`);

      const { data: branchVisits } = await supabase
        .from("visits")
        .select("id, visit_status")
        .gte("visit_date", `${todayStr}T00:00:00Z`);

      const totalCollected = branchPayments?.reduce((acc, p) => acc + Number(p.amount_paid || 0), 0) || 0;

      // Executive Leaderboard Ranking
      const leaderboardMap: Record<string, { name: string; amount: number }> = {};
      branchPayments?.forEach(p => {
        const execId = p.executive_id;
        const name = (p.users as any)?.full_name || "Executive";
        if (!leaderboardMap[execId]) leaderboardMap[execId] = { name, amount: 0 };
        leaderboardMap[execId].amount += Number(p.amount_paid);
      });

      const ranking = Object.values(leaderboardMap).sort((a, b) => b.amount - a.amount);

      return new Response(
        JSON.stringify({
          role: "BRANCH_MANAGER",
          metrics: {
            team_today_collected: totalCollected,
            team_visits_conducted: branchVisits?.length || 0,
            executive_ranking: ranking,
          },
        }),
        { status: 200, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    } else {
      // 3. Admin / Super Admin High Level Metrics
      const { data: totalLoans } = await supabase.from("loans").select("total_outstanding, dpd, bucket");
      const { data: totalPayments } = await supabase.from("payments").select("amount_paid");

      const portfolioOutstanding = totalLoans?.reduce((acc, l) => acc + Number(l.total_outstanding || 0), 0) || 0;
      const totalCollectedAllTime = totalPayments?.reduce((acc, p) => acc + Number(p.amount_paid || 0), 0) || 0;
      const npaCount = totalLoans?.filter(l => (l.dpd || 0) > 90).length || 0;

      return new Response(
        JSON.stringify({
          role: "ADMIN",
          metrics: {
            total_active_loans: totalLoans?.length || 0,
            portfolio_total_outstanding: portfolioOutstanding,
            total_collections_all_time: totalCollectedAllTime,
            npa_accounts_count: npaCount,
          },
        }),
        { status: 200, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }
  } catch (err: any) {
    return new Response(
      JSON.stringify({ error: err.message }),
      { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  }
});
