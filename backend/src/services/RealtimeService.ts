// Supabase Realtime Subscription Service for LOT Field Collection Platform

import { supabase } from "../config/supabase.config.js";
import { RealtimeChannel } from "@supabase/supabase-js";

export type RealtimeEventCallback = (payload: {
  table: string;
  eventType: 'INSERT' | 'UPDATE' | 'DELETE';
  new: any;
  old: any;
}) => void;

export class RealtimeService {
  private static channels: Map<string, RealtimeChannel> = new Map();

  /**
   * Subscribe to live collection activities (Allocations, Visits, Payments, Followups)
   */
  static subscribeToLiveCollection(branchId?: string, onEvent?: RealtimeEventCallback): RealtimeChannel {
    const channelName = branchId ? `branch-collection-${branchId}` : `global-collection`;

    if (this.channels.has(channelName)) {
      return this.channels.get(channelName)!;
    }

    const channel = supabase.channel(channelName)
      .on(
        "postgres_changes",
        { event: "*", schema: "public", table: "payments" },
        (payload) => {
          if (onEvent) onEvent({ table: "payments", eventType: payload.eventType as any, new: payload.new, old: payload.old });
        }
      )
      .on(
        "postgres_changes",
        { event: "*", schema: "public", table: "visits" },
        (payload) => {
          if (onEvent) onEvent({ table: "visits", eventType: payload.eventType as any, new: payload.new, old: payload.old });
        }
      )
      .on(
        "postgres_changes",
        { event: "*", schema: "public", table: "allocations" },
        (payload) => {
          if (onEvent) onEvent({ table: "allocations", eventType: payload.eventType as any, new: payload.new, old: payload.old });
        }
      )
      .on(
        "postgres_changes",
        { event: "*", schema: "public", table: "notifications" },
        (payload) => {
          if (onEvent) onEvent({ table: "notifications", eventType: payload.eventType as any, new: payload.new, old: payload.old });
        }
      )
      .subscribe();

    this.channels.set(channelName, channel);
    return channel;
  }

  /**
   * Subscribe to live Field Executive GPS Breadcrumbs
   */
  static subscribeToExecutiveTracking(onGpsLocation?: (log: any) => void): RealtimeChannel {
    const channel = supabase.channel("live-gps-tracking")
      .on(
        "postgres_changes",
        { event: "INSERT", schema: "public", table: "gps_logs" },
        (payload) => {
          if (onGpsLocation) onGpsLocation(payload.new);
        }
      )
      .subscribe();

    return channel;
  }

  /**
   * Unsubscribe from all realtime channels
   */
  static unsubscribeAll(): void {
    this.channels.forEach(ch => supabase.removeChannel(ch));
    this.channels.clear();
  }
}
