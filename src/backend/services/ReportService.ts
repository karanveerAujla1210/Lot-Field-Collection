// Enterprise Analytics & Reports Service for FinCollect Platform

import { supabase } from "../config/supabase.config.js";

export class ReportService {
  /**
   * Daily Collection Summary Report
   */
  static async getDailyCollectionReport(startDate: string, endDate: string, branchId?: string): Promise<any[]> {
    let query = supabase
      .from("payments")
      .select("collected_at, amount_paid, payment_mode, receipt_number, users(full_name, employee_code), branches(name), loans(loan_account_number)")
      .gte("collected_at", `${startDate}T00:00:00Z`)
      .lte("collected_at", `${endDate}T23:59:59Z`);

    if (branchId) query = query.eq("branch_id", branchId);

    const { data, error } = await query.order("collected_at", { ascending: false });
    if (error) throw error;
    return data || [];
  }

  /**
   * Executive Performance Leaderboard Report
   */
  static async getExecutivePerformanceReport(branchId?: string): Promise<any[]> {
    let query = supabase
      .from("payments")
      .select("executive_id, amount_paid, users(full_name, employee_code, branches(name))");

    if (branchId) query = query.eq("branch_id", branchId);

    const { data, error } = await query;
    if (error) throw error;

    const summary: Record<string, { executive: string; code: string; branch: string; total_collected: number; count: number }> = {};

    data?.forEach((row: any) => {
      const execId = row.executive_id;
      const name = row.users?.full_name || "Executive";
      const code = row.users?.employee_code || "";
      const branch = row.users?.branches?.name || "";

      if (!summary[execId]) {
        summary[execId] = { executive: name, code, branch, total_collected: 0, count: 0 };
      }
      summary[execId].total_collected += Number(row.amount_paid);
      summary[execId].count += 1;
    });

    return Object.values(summary).sort((a, b) => b.total_collected - a.total_collected);
  }

  /**
   * DPD Aging Bucket Portfolio Matrix Report
   */
  static async getDpdBucketMatrixReport(branchId?: string): Promise<any> {
    let query = supabase.from("loans").select("bucket, total_outstanding, principal_outstanding");

    if (branchId) query = query.eq("branch_id", branchId);

    const { data, error } = await query;
    if (error) throw error;

    const buckets: Record<string, { count: number; total_outstanding: number }> = {
      'CURRENT': { count: 0, total_outstanding: 0 },
      'SMA-0': { count: 0, total_outstanding: 0 },
      'SMA-1': { count: 0, total_outstanding: 0 },
      'SMA-2': { count: 0, total_outstanding: 0 },
      'NPA': { count: 0, total_outstanding: 0 },
      'NPA-90+': { count: 0, total_outstanding: 0 },
    };

    data?.forEach(l => {
      const b = l.bucket || 'CURRENT';
      if (buckets[b]) {
        buckets[b].count += 1;
        buckets[b].total_outstanding += Number(l.total_outstanding);
      }
    });

    return buckets;
  }

  /**
   * Promise To Pay (PTP) Conversion Efficiency Report
   */
  static async getPtpConversionReport(startDate: string, endDate: string): Promise<any> {
    const { data: visits, error } = await supabase
      .from("visits")
      .select("id, visit_status, promise_date, expected_amount, customer_id")
      .not("promise_date", "is", null)
      .gte("visit_date", `${startDate}T00:00:00Z`)
      .lte("visit_date", `${endDate}T23:59:59Z`);

    if (error) throw error;

    const totalPtpCount = visits?.length || 0;
    const totalPtpAmount = visits?.reduce((acc, v) => acc + Number(v.expected_amount || 0), 0) || 0;

    return {
      total_ptp_promises: totalPtpCount,
      total_expected_ptp_amount: totalPtpAmount,
      visits_with_ptp: visits || [],
    };
  }
}
