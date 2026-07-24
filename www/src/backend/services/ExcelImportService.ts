// Excel Bulk Import & Portfolio Allocation Parser Service for FinCollect Platform

import { supabase } from "../config/supabase.config.js";
import * as XLSX from "xlsx";

export interface ImportJobStatus {
  id: string;
  job_code: string;
  status: 'PENDING' | 'PROCESSING' | 'COMPLETED' | 'FAILED';
  total_records: number;
  processed_records: number;
  success_count: number;
  error_count: number;
  error_log_json: any;
}

export class ExcelImportService {
  /**
   * Parse Excel File Buffer into typed JSON rows
   */
  static parseExcelBuffer(arrayBuffer: ArrayBuffer): any[] {
    const workbook = XLSX.read(arrayBuffer, { type: "array" });
    const sheetName = workbook.SheetNames[0];
    const sheet = workbook.Sheets[sheetName];
    return XLSX.utils.sheet_to_json(sheet);
  }

  /**
   * Upload and process Excel file for Portfolio Allocation
   */
  static async uploadAndImportExcel(
    fileBuffer: ArrayBuffer,
    fileName: string,
    uploadedByUserId: string
  ): Promise<ImportJobStatus> {
    // 1. Parse rows
    const rows = this.parseExcelBuffer(fileBuffer);
    if (!rows || rows.length === 0) {
      throw new Error("Uploaded Excel file contains no valid data rows.");
    }

    // 2. Create Import Job record
    const jobCode = `IMP-${Date.now()}-${Math.floor(Math.random() * 1000)}`;
    const { data: job, error: jobErr } = await supabase
      .from("import_jobs")
      .insert({
        job_code: jobCode,
        file_name: fileName,
        uploaded_by: uploadedByUserId,
        status: "PENDING",
        total_records: rows.length,
      })
      .select("*")
      .single();

    if (jobErr || !job) throw jobErr || new Error("Failed to create import job record");

    // 3. Invoke Edge Function 'excel-import' asynchronously
    supabase.functions.invoke("excel-import", {
      body: {
        job_id: job.id,
        rows,
        uploaded_by: uploadedByUserId,
      },
    }).catch(console.error);

    return job as ImportJobStatus;
  }

  /**
   * Poll Import Job status
   */
  static async getJobStatus(jobId: string): Promise<ImportJobStatus> {
    const { data, error } = await supabase
      .from("import_jobs")
      .select("*")
      .eq("id", jobId)
      .single();

    if (error) throw error;
    return data as ImportJobStatus;
  }
}
