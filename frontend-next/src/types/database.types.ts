export type Json =
  | string
  | number
  | boolean
  | null
  | { [key: string]: Json | undefined }
  | Json[]

export interface CaseRow {
  id: string
  lead_id: number | null
  state_name: string | null
  branch_name: string | null
  customer_code: string | null
  pan_number: string | null
  loan_no: string | null
  customer_name: string | null
  mobile_number: string | null
  email: string | null
  loan_amount: number | null
  net_disbursed_amount: number | null
  admin_fee: number | null
  admin_fee_gst: number | null
  total_admin_fee: number | null
  igst: number | null
  cgst: number | null
  sgst: number | null
  processing: number | null
  tenure: number | null
  roi: number | null
  loan_repay_amount: number | null
  disbursement_date: string | null
  repayment_date: string | null
  customer_bank_account: string | null
  customer_bank_name: string | null
  customer_bank_ifsc: string | null
  disbursement_reference: string | null
  disbursement_status: string | null
  repeat_type: string | null
  sanctioned_by: string | null
  approved_by: string | null
  house_address: string | null
  office_address: string | null
  due_days: number | null
  bucket: string | null
  month: string | null
  loan_status: string | null
  total_collected_amount: number | null
  last_payment_amount: number | null
  last_payment_at: string | null
  payment_count: number | null
  last_visit_at: string | null
  last_visit_status: string | null
  visit_count: number | null
  assigned_executive_id: string | null
  assigned_executive_name: string | null
  latitude: number | null
  longitude: number | null
  created_at: string | null
  updated_at: string | null
}

export interface CasePayment {
  id: string
  case_id: string
  loan_no: string
  customer_name: string
  executive_id: string | null
  executive_name: string | null
  branch_name: string | null
  amount_paid: number
  payment_mode: string
  payment_reference: string | null
  receipt_number: string
  notes: string | null
  created_at: string | null
}

export interface CaseVisit {
  id: string
  case_id: string
  loan_no: string
  customer_name: string
  executive_id: string | null
  executive_name: string | null
  branch_name: string | null
  latitude: number
  longitude: number
  visit_status:
    | 'CUSTOMER_MET'
    | 'PARTIAL_PAYMENT_PROMISE'
    | 'DOOR_LOCKED'
    | 'REFUSED_TO_PAY'
    | 'THIRD_PARTY_MET'
  remarks: string
  promise_date: string | null
  expected_amount: number | null
  photos_urls: string[] | null
  created_at: string | null
}

// Matches the users table from migration 20260723000000
export interface StaffUser {
  id: string
  employee_code: string
  full_name: string
  email: string
  phone: string
  role_id: string
  branch_id: string | null
  avatar_url: string | null
  status: string
  device_id: string | null
  device_name: string | null
  last_login_at: string | null
  created_at: string
  updated_at: string
  roles?: { code: string }
}

export interface FollowUp {
  id: string
  case_id: string
  loan_no: string | null
  customer_name: string | null
  executive_id: string | null
  follow_up_date: string | null
  notes: string | null
  status: 'PENDING' | 'COMPLETED' | 'RESCHEDULED' | null
  created_at: string | null
}

export type AuditAction =
  | 'LOGIN'
  | 'LOGOUT'
  | 'VISIT_CREATED'
  | 'PAYMENT_CREATED'
  | 'FOLLOWUP_CREATED'
  | 'FOLLOWUP_COMPLETED'
  | 'STAFF_CREATED'
  | 'CASE_VIEWED'

export interface AuditLog {
  id: string
  user_id: string
  user_email: string | null
  action: AuditAction
  entity_type: string | null
  entity_id: string | null
  metadata: Record<string, unknown> | null
  created_at: string | null
}

export type CreateAuditLogPayload = Omit<AuditLog, 'id' | 'created_at'>

// Offline queue item stored in localStorage
export interface OfflineQueueItem {
  id: string
  type: 'VISIT' | 'PAYMENT'
  payload: Record<string, unknown>
  photos?: string[] // base64 encoded
  createdAt: string
  retryCount: number
}

type Table<
  Row,
  Insert = Partial<Row> & Record<string, unknown>,
  Update = Partial<Row> & Record<string, unknown>,
> = {
  Row: Row & Record<string, unknown>
  Insert: Insert
  Update: Update
  Relationships: []
}

export type Database = {
  public: {
    Tables: {
      cases: Table<CaseRow>
      case_payments: Table<CasePayment>
      case_visits: Table<CaseVisit>
      users: Table<StaffUser>
      follow_ups: Table<FollowUp>
      audit_logs: Table<AuditLog>
    }
    Views: Record<never, never>
    Functions: Record<never, never>
    Enums: Record<never, never>
    CompositeTypes: Record<never, never>
  }
}
