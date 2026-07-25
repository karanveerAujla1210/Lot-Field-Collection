// Customer Management Service for LOT Field Collection Platform

import { supabase } from "../config/supabase.config.js";
import { Database } from "../types/database.types.js";

type CaseRow = Database['public']['Tables']['cases']['Row'];

export class CustomerService {
  /**
   * Get Case by ID
   */
  static async getCaseById(caseId: string): Promise<CaseRow | null> {
    const { data, error } = await supabase
      .from("cases")
      .select("*")
      .eq("id", caseId)
      .single();

    if (error) throw error;
    return data as any;
  }

  /**
   * List Cases with pagination and filtering
   */
  static async listCases(params: {
    executiveId?: string;
    bucket?: string;
    searchQuery?: string;
    page?: number;
    limit?: number;
  }): Promise<{ cases: CaseRow[]; total: number }> {
    const page = params.page || 1;
    const limit = params.limit || 50;
    const offset = (page - 1) * limit;

    let query = supabase.from("cases").select("*", { count: "exact" });

    if (params.executiveId) {
      query = query.eq("assigned_executive_id", params.executiveId);
    }

    if (params.bucket) {
      query = query.eq("bucket", params.bucket);
    }

    if (params.searchQuery) {
      query = query.or(`customer_name.ilike.%${params.searchQuery}%,loan_no.ilike.%${params.searchQuery}%,mobile_number.ilike.%${params.searchQuery}%`);
    }

    const { data, count, error } = await query
      .order("due_days", { ascending: false })
      .range(offset, offset + limit - 1);

    if (error) throw error;

    return {
      cases: (data || []) as CaseRow[],
      total: count || 0,
    };
  }

  /**
   * Update Case Geo-coordinates
   */
  static async updateCaseLocation(caseId: string, latitude: number, longitude: number): Promise<void> {
    const { error } = await supabase
      .from("cases")
      .update({
        latitude,
        longitude,
        updated_at: new Date().toISOString(),
      })
      .eq("id", caseId);

    if (error) throw error;
  }
}
