// Unified Audit Logging Service for LOT Field Collection Platform

import { supabase } from "../config/supabase.config.js";

export class AuditService {
  /**
   * Record explicit activity log entry
   */
  static async logActivity(params: {
    userId?: string;
    action: string;
    entityType: string;
    entityId?: string;
    oldState?: any;
    newState?: any;
  }): Promise<void> {
    const { error } = await supabase.from("activity_logs").insert({
      user_id: params.userId || null,
      action: params.action,
      entity_type: params.entityType,
      entity_id: params.entityId || null,
      old_state: params.oldState || null,
      new_state: params.newState || null,
    });

    if (error) throw error;
  }

  /**
   * Query Activity Audit Logs
   */
  static async queryAuditLogs(params: {
    userId?: string;
    entityType?: string;
    action?: string;
    limit?: number;
  }): Promise<any[]> {
    let query = supabase.from("activity_logs").select("*, users(full_name, employee_code)");

    if (params.userId) query = query.eq("user_id", params.userId);
    if (params.entityType) query = query.eq("entity_type", params.entityType);
    if (params.action) query = query.eq("action", params.action);

    const { data, error } = await query
      .order("created_at", { ascending: false })
      .limit(params.limit || 100);

    if (error) throw error;
    return data || [];
  }
}
