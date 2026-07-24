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
  created_at: string | null
  updated_at: string | null
}

export interface CasePayment {
  id: string
  case_id: string
  loan_no: string | null
  customer_name: string | null
  executive_id: string | null
  executive_name: string | null
  branch_name: string | null
  amount_paid: number
  payment_mode: 'CASH' | 'UPI' | 'CHEQUE' | 'NEFT'
  payment_reference: string | null
  receipt_number: string | null
  notes: string | null
  created_at: string | null
}

export interface CaseVisit {
  id: string
  case_id: string
  loan_no: string | null
  customer_name: string | null
  executive_id: string | null
  executive_name: string | null
  branch_name: string | null
  latitude: number | null
  longitude: number | null
  visit_status:
    | 'CUSTOMER_MET'
    | 'PARTIAL_PAYMENT_PROMISE'
    | 'DOOR_LOCKED'
    | 'REFUSED_TO_PAY'
    | 'THIRD_PARTY_MET'
  remarks: string | null
  promise_date: string | null
  expected_amount: number | null
  photos_urls: string[] | null
  created_at: string | null
}

export interface StaffUser {
  id: string
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

export type Database = {
  public: {
    Tables: {
      cases: { Row: CaseRow }
      case_payments: { Row: CasePayment }
      case_visits: { Row: CaseVisit }
      users: { Row: StaffUser }
      follow_ups: { Row: FollowUp }
    }
  }
}
