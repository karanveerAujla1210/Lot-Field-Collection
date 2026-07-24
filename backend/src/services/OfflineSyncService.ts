// Offline Queue & Bi-directional Sync Service for LOT Field Collection Field Executive App

import { supabase } from "../config/supabase.config.js";

export interface SyncQueueItem {
  id: string; // Local temp ID
  type: "VISIT" | "PAYMENT" | "FOLLOWUP" | "GPS_LOG" | "ATTENDANCE";
  action: "CREATE" | "UPDATE";
  client_timestamp: string;
  data: any;
}

export interface SyncResult {
  synced_ids: string[];
  records_uploaded: number;
  delta_allocations: any[];
  conflict_count: number;
  errors: any[];
}

export class OfflineSyncService {
  /**
   * Synchronize local offline queue with Supabase Cloud Backend
   */
  static async syncOfflineQueue(
    executiveId: string,
    deviceId: string,
    queue: SyncQueueItem[]
  ): Promise<SyncResult> {
    if (!queue || queue.length === 0) {
      // Just fetch Delta Allocations if queue is empty
      const { data: updatedAllocations } = await supabase
        .from("allocations")
        .select("*, loans(*, customers(*))")
        .eq("executive_id", executiveId)
        .in("status", ["ASSIGNED", "IN_PROGRESS", "PARTIALLY_COLLECTED"]);

      return {
        synced_ids: [],
        records_uploaded: 0,
        delta_allocations: updatedAllocations || [],
        conflict_count: 0,
        errors: [],
      };
    }

    const syncStartedAt = new Date().toISOString();

    // Call Supabase Edge Function 'offline-sync'
    const { data, error } = await supabase.functions.invoke("offline-sync", {
      body: {
        executive_id: executiveId,
        device_id: deviceId,
        queue,
        sync_started_at: syncStartedAt,
      },
    });

    if (error || !data?.success) {
      throw new Error(`Offline Sync failed: ${error?.message || "Edge function error"}`);
    }

    return {
      synced_ids: data.synced_ids || [],
      records_uploaded: data.records_uploaded || 0,
      delta_allocations: data.delta_allocations || [],
      conflict_count: data.conflict_count || 0,
      errors: data.errors || [],
    };
  }
}
