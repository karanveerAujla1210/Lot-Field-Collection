// Field Visit Execution Service for FinCollect Platform

import { supabase } from "../config/supabase.config.js";
import { Database, VisitStatus } from "../types/database.types.js";

type VisitRow = Database['public']['Tables']['visits']['Row'];

export class VisitService {
  /**
   * Upload Visit Photo to Supabase Storage ('house-photo' bucket)
   */
  static async uploadHousePhoto(visitId: string, fileBlob: Blob, fileExtension = "jpg"): Promise<string> {
    const filePath = `visit_${visitId}_${Date.now()}.${fileExtension}`;
    
    const { error: uploadErr } = await supabase.storage
      .from("house-photo")
      .upload(filePath, fileBlob, { upsert: true });

    if (uploadErr) throw uploadErr;

    const { data } = supabase.storage.from("house-photo").getPublicUrl(filePath);
    return data.publicUrl;
  }

  /**
   * Capture and record a new Field Visit
   */
  static async recordVisit(params: {
    allocationId?: string;
    loanId: string;
    customerId: string;
    executiveId: string;
    latitude: number;
    longitude: number;
    gpsAccuracy?: number;
    visitStatus: VisitStatus;
    remarks: string;
    photosUrls?: string[];
    promiseDate?: string;
    expectedAmount?: number;
  }): Promise<VisitRow> {
    // Validate GPS Coordinates
    if (!params.latitude || !params.longitude) {
      throw new Error("Valid GPS latitude and longitude are mandatory for field visit recording.");
    }

    const visitCode = `VIS-${Date.now()}-${Math.floor(Math.random() * 1000)}`;

    const { data: visit, error } = await supabase
      .from("visits")
      .insert({
        visit_code: visitCode,
        allocation_id: params.allocationId || null,
        loan_id: params.loanId,
        customer_id: params.customerId,
        executive_id: params.executiveId,
        latitude: params.latitude,
        longitude: params.longitude,
        gps_accuracy: params.gpsAccuracy || null,
        photos_urls: params.photosUrls || [],
        visit_status: params.visitStatus,
        remarks: params.remarks,
        promise_date: params.promiseDate || null,
        expected_amount: params.expectedAmount || null,
      })
      .select("*")
      .single();

    if (error) throw error;

    // Update Allocation Status to IN_PROGRESS
    if (params.allocationId) {
      await supabase
        .from("allocations")
        .update({ status: "IN_PROGRESS", updated_at: new Date().toISOString() })
        .eq("id", params.allocationId);
    }

    // Create Followup if Promise Date provided
    if (params.promiseDate) {
      const followupCode = `FLP-${Date.now()}-${Math.floor(Math.random() * 1000)}`;
      await supabase.from("followups").insert({
        followup_code: followupCode,
        loan_id: params.loanId,
        customer_id: params.customerId,
        executive_id: params.executiveId,
        scheduled_at: `${params.promiseDate}T09:00:00Z`,
        followup_type: "FIELD_VISIT",
        status: "PENDING",
        notes: `PTP Promise from visit ${visitCode}: ₹${params.expectedAmount || 0}`,
      });
    }

    return visit as VisitRow;
  }

  /**
   * Get Visit Timeline for a Customer / Loan
   */
  static async getCustomerVisitHistory(customerId: string): Promise<VisitRow[]> {
    const { data, error } = await supabase
      .from("visits")
      .select("*, users(full_name)")
      .eq("customer_id", customerId)
      .order("visit_date", { ascending: false });

    if (error) throw error;
    return (data || []) as any;
  }
}
