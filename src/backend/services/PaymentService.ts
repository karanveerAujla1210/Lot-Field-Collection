// Payment Collection & Receipt Management Service for FinCollect Platform

import { supabase } from "../config/supabase.config.js";
import { Database, PaymentMode } from "../types/database.types.js";

type PaymentRow = Database['public']['Tables']['payments']['Row'];

export class PaymentService {
  /**
   * Upload Receipt Photo to Supabase Storage ('receipt-photo' bucket)
   */
  static async uploadReceiptPhoto(receiptNumber: string, fileBlob: Blob, fileExtension = "jpg"): Promise<string> {
    const filePath = `receipt_${receiptNumber}_${Date.now()}.${fileExtension}`;
    
    const { error: uploadErr } = await supabase.storage
      .from("receipt-photo")
      .upload(filePath, fileBlob, { upsert: true });

    if (uploadErr) throw uploadErr;

    const { data } = supabase.storage.from("receipt-photo").getPublicUrl(filePath);
    return data.publicUrl;
  }

  /**
   * Process and record a field payment collection
   */
  static async processPayment(params: {
    visitId?: string;
    loanId: string;
    customerId: string;
    executiveId: string;
    branchId: string;
    amountPaid: number;
    paymentMode: PaymentMode;
    paymentReference?: string;
    receiptPhotoUrl?: string;
  }): Promise<{ payment: PaymentRow; receiptNumber: string }> {
    if (!params.amountPaid || params.amountPaid <= 0) {
      throw new Error("Payment collection amount must be strictly greater than 0.");
    }

    // Call Supabase Edge Function 'payment-processor'
    const { data, error } = await supabase.functions.invoke("payment-processor", {
      body: {
        visit_id: params.visitId || null,
        loan_id: params.loanId,
        customer_id: params.customerId,
        executive_id: params.executiveId,
        branch_id: params.branchId,
        amount_paid: params.amountPaid,
        payment_mode: params.paymentMode,
        payment_reference: params.paymentReference || null,
        receipt_photo_url: params.receiptPhotoUrl || null,
      },
    });

    if (error || !data?.success) {
      // Direct Database Fallback if Edge function is unreachable
      const timestamp = Date.now().toString().slice(-6);
      const randomSuffix = Math.floor(1000 + Math.random() * 9000);
      const receiptNumber = `RCP-${timestamp}-${randomSuffix}`;
      const paymentCode = `PAY-${timestamp}-${randomSuffix}`;

      const { data: dbPay, error: dbErr } = await supabase
        .from("payments")
        .insert({
          payment_code: paymentCode,
          receipt_number: receiptNumber,
          visit_id: params.visitId || null,
          loan_id: params.loanId,
          customer_id: params.customerId,
          executive_id: params.executiveId,
          branch_id: params.branchId,
          amount_paid: params.amountPaid,
          payment_mode: params.paymentMode,
          payment_reference: params.paymentReference || `REF-${receiptNumber}`,
          receipt_photo_url: params.receiptPhotoUrl || null,
          payment_status: "SUCCESS",
        })
        .select("*")
        .single();

      if (dbErr) throw dbErr;

      return { payment: dbPay as PaymentRow, receiptNumber };
    }

    return {
      payment: data.payment as PaymentRow,
      receiptNumber: data.receipt_number,
    };
  }

  /**
   * Get Receipt Details for Printing or Verification
   */
  static async getReceipt(receiptNumber: string): Promise<any> {
    const { data, error } = await supabase
      .from("receipts")
      .select("*, payments(*), loans(*), customers(*), users(full_name, employee_code)")
      .eq("receipt_number", receiptNumber)
      .single();

    if (error) throw error;
    return data;
  }

  /**
   * Get Financial Ledger for a Loan
   */
  static async getLoanLedger(loanId: string): Promise<any[]> {
    const { data, error } = await supabase
      .from("ledger")
      .select("*")
      .eq("loan_id", loanId)
      .order("transaction_date", { ascending: true });

    if (error) throw error;
    return data || [];
  }
}
