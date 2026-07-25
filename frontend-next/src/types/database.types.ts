export type Json =
  | string
  | number
  | boolean
  | null
  | { [key: string]: Json | undefined }
  | Json[]

export interface CaseRow {
  id: string
  loan_no: string | null
  customer_name: string | null
  mobile_number: string | null
  loan_amount: number | null
  loan_repay_amount: number | null
  total_collected_amount: number | null
  tenure: number | null
  due_days: number | null
  bucket: string | null
  loan_status: string | null
  branch_name: string | null
  state_name: string | null
  house_address: string | null
  office_address: string | null
  latitude: number | null
  longitude: number | null
  last_visit_at: string | null
  last_visit_status: string | null
  visit_count: number | null
  last_payment_at: string | null
  last_payment_amount: number | null
  payment_count: number | null
  assigned_executive_id: string | null
  assigned_executive_name: string | null
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
  payment_mode: 'CASH' | 'UPI' | 'CHEQUE' | 'NEFT'
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

// Matches the flat users table from migration 20260724000004
export interface StaffUser {
  id: string
  employee_code: string | null
  email: string | null
  full_name: string | null
  phone: string | null
  role: 'super_admin' | 'admin' | 'executive' | null
  branch_name: string | null
  is_active: boolean | null
  created_at: string | null
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
