// Field Visit Execution Service for LOT Field Collection Platform

import { supabase } from "../config/supabase.config.js";
import { Database, VisitStatus } from "../types/database.types.js";

type VisitRow = Database['public']['Tables']['case_visits']['Row'];

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
    caseId: string;
    loanNo: string;
    customerName: string;
    executiveId: string;
    executiveName: string;
    branchName: string;
    latitude: number;
    longitude: number;
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

    const { data: visit, error } = await supabase
      .from("case_visits")
      .insert({
        case_id: params.caseId,
        loan_no: params.loanNo,
        customer_name: params.customerName,
        executive_id: params.executiveId,
        executive_name: params.executiveName,
        branch_name: params.branchName,
        latitude: params.latitude,
        longitude: params.longitude,
        visit_status: params.visitStatus,
        remarks: params.remarks,
        photos_urls: params.photosUrls || [],
        promise_date: params.promiseDate || null,
        expected_amount: params.expectedAmount || null,
      })
      .select("*")
      .single();

    if (error) throw error;

    return visit as VisitRow;
  }

  /**
   * Get Visit Timeline for a Case
   */
  static async getCaseVisitHistory(caseId: string): Promise<VisitRow[]> {
    const { data, error } = await supabase
      .from("case_visits")
      .select("*")
      .eq("case_id", caseId)
      .order("created_at", { ascending: false });

    if (error) throw error;
    return (data || []) as any;
  }
}
