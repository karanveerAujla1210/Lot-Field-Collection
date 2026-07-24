// Field Executive Attendance & GPS Tracking Service for FinCollect Platform

import { supabase } from "../config/supabase.config.js";
import { Database } from "../types/database.types.js";

type AttendanceRow = Database['public']['Tables']['attendance']['Row'];

export class AttendanceService {
  /**
   * Executive Morning Check-in with GPS validation
   */
  static async checkIn(executiveId: string, latitude: number, longitude: number): Promise<AttendanceRow> {
    const todayStr = new Date().toISOString().split("T")[0];
    const attendanceCode = `ATT-${executiveId.slice(0, 8)}-${todayStr}`;

    const { data, error } = await supabase
      .from("attendance")
      .upsert({
        attendance_code: attendanceCode,
        executive_id: executiveId,
        date: todayStr,
        check_in_time: new Date().toISOString(),
        check_in_lat: latitude,
        check_in_lng: longitude,
        status: "PRESENT",
      }, { onConflict: "executive_id, date" })
      .select("*")
      .single();

    if (error) throw error;
    return data as AttendanceRow;
  }

  /**
   * Executive Evening Check-out
   */
  static async checkOut(executiveId: string, latitude: number, longitude: number, distanceCoveredKm = 0): Promise<void> {
    const todayStr = new Date().toISOString().split("T")[0];

    const { error } = await supabase
      .from("attendance")
      .update({
        check_out_time: new Date().toISOString(),
        check_out_lat: latitude,
        check_out_lng: longitude,
        distance_covered_km: distanceCoveredKm,
      })
      .eq("executive_id", executiveId)
      .eq("date", todayStr);

    if (error) throw error;
  }

  /**
   * Log GPS Breadcrumb from Mobile App
   */
  static async logGpsLocation(params: {
    executiveId: string;
    latitude: number;
    longitude: number;
    accuracy?: number;
    speed?: number;
    batteryLevel?: number;
    deviceId?: string;
  }): Promise<void> {
    const { error } = await supabase.from("gps_logs").insert({
      executive_id: params.executiveId,
      latitude: params.latitude,
      longitude: params.longitude,
      accuracy: params.accuracy || null,
      speed: params.speed || null,
      battery_level: params.batteryLevel || null,
      device_id: params.deviceId || null,
    });

    if (error) throw error;
  }

  /**
   * Get Today's GPS route for an Executive
   */
  static async getExecutiveGpsRoute(executiveId: string, dateStr?: string): Promise<any[]> {
    const date = dateStr || new Date().toISOString().split("T")[0];

    const { data, error } = await supabase
      .from("gps_logs")
      .select("*")
      .eq("executive_id", executiveId)
      .gte("captured_at", `${date}T00:00:00Z`)
      .lte("captured_at", `${date}T23:59:59Z`)
      .order("captured_at", { ascending: true });

    if (error) throw error;
    return data || [];
  }
}
