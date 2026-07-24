// Executive Customer & Loan Allocation Service for LOT Field Collection Platform

import { supabase } from "../config/supabase.config.js";
import { Database } from "../types/database.types.js";

type AllocationRow = Database['public']['Tables']['allocations']['Row'];

export class AllocationService {
  /**
   * Assign loan allocation to an Executive
   */
  static async createAllocation(params: {
    loanId: string;
    customerId: string;
    executiveId: string;
    assignedBy: string;
    branchId: string;
    dueDate: string;
    targetAmount: number;
    notes?: string;
  }): Promise<AllocationRow> {
    const allocationCode = `ALLOC-${Date.now()}-${Math.floor(Math.random() * 1000)}`;

    const { data, error } = await supabase
      .from("allocations")
      .insert({
        allocation_code: allocationCode,
        loan_id: params.loanId,
        customer_id: params.customerId,
        executive_id: params.executiveId,
        assigned_by: params.assignedBy,
        branch_id: params.branchId,
        due_date: params.dueDate,
        target_amount: params.targetAmount,
        notes: params.notes || null,
        status: "ASSIGNED",
      })
      .select("*")
      .single();

    if (error) throw error;

    // Send push notification to executive
    await supabase.from("notifications").insert({
      user_id: params.executiveId,
      title: "New Allocation Assigned",
      body: `You have been allocated a new loan target of ₹${params.targetAmount}.`,
      notification_type: "ALLOCATION",
      entity_type: "ALLOCATION",
      entity_id: data.id,
    });

    return data as AllocationRow;
  }

  /**
   * Fetch active allocations assigned to a Field Executive
   */
  static async getExecutiveAllocations(executiveId: string): Promise<any[]> {
    const { data, error } = await supabase
      .from("allocations")
      .select("*, loans(*, customers(*))")
      .eq("executive_id", executiveId)
      .in("status", ["ASSIGNED", "IN_PROGRESS", "PARTIALLY_COLLECTED"])
      .order("due_date", { ascending: true });

    if (error) throw error;
    return data || [];
  }

  /**
   * Reallocate an allocation to another Executive
   */
  static async reallocate(allocationId: string, newExecutiveId: string, assignedBy: string): Promise<void> {
    // 1. Mark existing allocation REALLOCATED
    await supabase
      .from("allocations")
      .update({ status: "REALLOCATED", updated_at: new Date().toISOString() })
      .eq("id", allocationId);

    // 2. Fetch existing details
    const { data: oldAlloc } = await supabase
      .from("allocations")
      .select("*")
      .eq("id", allocationId)
      .single();

    if (oldAlloc) {
      await this.createAllocation({
        loanId: oldAlloc.loan_id,
        customerId: oldAlloc.customer_id,
        executiveId: newExecutiveId,
        assignedBy,
        branchId: oldAlloc.branch_id,
        dueDate: oldAlloc.due_date,
        targetAmount: oldAlloc.target_amount,
        notes: `Reallocated from executive ${oldAlloc.executive_id}`,
      });
    }
  }
}
