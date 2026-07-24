// Loan & DPD Portfolio Service for LOT Field Collection Platform

import { supabase } from "../config/supabase.config.js";
import { Database } from "../types/database.types.js";

type LoanRow = Database['public']['Tables']['loans']['Row'];

export class LoanService {
  /**
   * Fetch Loan details with Customer information
   */
  static async getLoanDetails(loanId: string): Promise<any> {
    const { data, error } = await supabase
      .from("loans")
      .select("*, customers(*), branches(name, branch_code)")
      .eq("id", loanId)
      .single();

    if (error) throw error;
    return data;
  }

  /**
   * Search loans by Account Number or Customer Code
   */
  static async searchLoans(queryStr: string): Promise<LoanRow[]> {
    const { data, error } = await supabase
      .from("loans")
      .select("*, customers(full_name, phone_primary)")
      .or(`loan_account_number.ilike.%${queryStr}%`)
      .limit(20);

    if (error) throw error;
    return (data || []) as any;
  }

  /**
   * Get Loans by DPD Bucket
   */
  static async getLoansByBucket(bucket: string, branchId?: string): Promise<LoanRow[]> {
    let query = supabase.from("loans").select("*, customers(full_name, phone_primary)").eq("bucket", bucket);
    
    if (branchId) {
      query = query.eq("branch_id", branchId);
    }

    const { data, error } = await query.order("dpd", { ascending: false });

    if (error) throw error;
    return (data || []) as any;
  }

  /**
   * Manually trigger DPD recalculation for all active loans
   */
  static async triggerDpdRecalculation(): Promise<number> {
    const { data, error } = await supabase.rpc("recalculate_dpd_and_buckets");
    if (error) throw error;
    return data as number;
  }
}
