// Follow-up & Reminder Service for FinCollect Platform

import { supabase } from "../config/supabase.config.js";
import { Database, FollowupStatus, FollowupType } from "../types/database.types.js";

type FollowupRow = Database['public']['Tables']['followups']['Row'];

export class FollowupService {
  /**
   * Schedule a new Follow-up
   */
  static async scheduleFollowup(params: {
    loanId: string;
    customerId: string;
    executiveId: string;
    scheduledAt: string;
    followupType: FollowupType;
    notes?: string;
  }): Promise<FollowupRow> {
    const followupCode = `FLP-${Date.now()}-${Math.floor(Math.random() * 1000)}`;

    const { data, error } = await supabase
      .from("followups")
      .insert({
        followup_code: followupCode,
        loan_id: params.loanId,
        customer_id: params.customerId,
        executive_id: params.executiveId,
        scheduled_at: params.scheduledAt,
        followup_type: params.followupType,
        status: "PENDING",
        notes: params.notes || null,
      })
      .select("*")
      .single();

    if (error) throw error;
    return data as FollowupRow;
  }

  /**
   * Get pending follow-ups for Executive
   */
  static async getExecutivePendingFollowups(executiveId: string): Promise<any[]> {
    const { data, error } = await supabase
      .from("followups")
      .select("*, loans(*, customers(*))")
      .eq("executive_id", executiveId)
      .eq("status", "PENDING")
      .order("scheduled_at", { ascending: true });

    if (error) throw error;
    return data || [];
  }

  /**
   * Mark Followup Completed
   */
  static async completeFollowup(followupId: string): Promise<void> {
    const { error } = await supabase
      .from("followups")
      .update({
        status: "COMPLETED",
        updated_at: new Date().toISOString(),
      })
      .eq("id", followupId);

    if (error) throw error;
  }
}
