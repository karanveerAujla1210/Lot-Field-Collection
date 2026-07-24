// Customer Management Service for LOT Field Collection Platform

import { supabase } from "../config/supabase.config.js";
import { Database } from "../types/database.types.js";

type CustomerRow = Database['public']['Tables']['customers']['Row'];
type CustomerInsert = Database['public']['Tables']['customers']['Insert'];

export class CustomerService {
  /**
   * Get Customer by ID
   */
  static async getCustomerById(customerId: string): Promise<CustomerRow | null> {
    const { data, error } = await supabase
      .from("customers")
      .select("*, branches(name, branch_code)")
      .eq("id", customerId)
      .single();

    if (error) throw error;
    return data as any;
  }

  /**
   * List Customers with pagination and filtering
   */
  static async listCustomers(params: {
    branchId?: string;
    riskCategory?: string;
    searchQuery?: string;
    page?: number;
    limit?: number;
  }): Promise<{ customers: CustomerRow[]; total: number }> {
    const page = params.page || 1;
    const limit = params.limit || 50;
    const offset = (page - 1) * limit;

    let query = supabase.from("customers").select("*", { count: "exact" });

    if (params.branchId) {
      query = query.eq("branch_id", params.branchId);
    }

    if (params.riskCategory) {
      query = query.eq("risk_category", params.riskCategory);
    }

    if (params.searchQuery) {
      query = query.or(`full_name.ilike.%${params.searchQuery}%,customer_code.ilike.%${params.searchQuery}%,phone_primary.ilike.%${params.searchQuery}%`);
    }

    const { data, count, error } = await query
      .order("created_at", { ascending: false })
      .range(offset, offset + limit - 1);

    if (error) throw error;

    return {
      customers: (data || []) as CustomerRow[],
      total: count || 0,
    };
  }

  /**
   * Create new Customer profile
   */
  static async createCustomer(customer: CustomerInsert): Promise<CustomerRow> {
    const { data, error } = await supabase
      .from("customers")
      .insert(customer)
      .select("*")
      .single();

    if (error) throw error;
    return data as CustomerRow;
  }

  /**
   * Update Customer Geo-coordinates
   */
  static async updateCustomerLocation(customerId: string, latitude: number, longitude: number): Promise<void> {
    const { error } = await supabase
      .from("customers")
      .update({
        latitude,
        longitude,
        updated_at: new Date().toISOString(),
      })
      .eq("id", customerId);

    if (error) throw error;
  }

  /**
   * Upload Customer Photo to Supabase Storage ('customer-photo' bucket)
   */
  static async uploadCustomerPhoto(customerId: string, fileBlob: Blob, fileExtension = "jpg"): Promise<string> {
    const filePath = `customer_${customerId}_${Date.now()}.${fileExtension}`;
    
    const { error: uploadErr } = await supabase.storage
      .from("customer-photo")
      .upload(filePath, fileBlob, { upsert: true });

    if (uploadErr) throw uploadErr;

    const { data } = supabase.storage.from("customer-photo").getPublicUrl(filePath);
    const photoUrl = data.publicUrl;

    // Save URL in database
    await supabase.from("customers").update({
      photo_url: photoUrl,
      updated_at: new Date().toISOString(),
    }).eq("id", customerId);

    return photoUrl;
  }
}
