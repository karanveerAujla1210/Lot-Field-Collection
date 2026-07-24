// Database Type Definitions for LOT Field Collection Backend Platform

export type Json =
  | string
  | number
  | boolean
  | null
  | { [key: string]: Json | undefined }
  | Json[];

export type UserRoleCode =
  | 'SUPER_ADMIN'
  | 'ADMIN'
  | 'REGIONAL_MANAGER'
  | 'BRANCH_MANAGER'
  | 'COLLECTION_MANAGER'
  | 'FIELD_EXECUTIVE'
  | 'FINANCE'
  | 'AUDITOR';

export type UserStatus = 'ACTIVE' | 'INACTIVE' | 'SUSPENDED';

export type LoanBucket = 'CURRENT' | 'SMA-0' | 'SMA-1' | 'SMA-2' | 'NPA' | 'NPA-90+';

export type LoanStatus = 'ACTIVE' | 'CLOSED' | 'SETTLED' | 'WRITTEN_OFF' | 'LEGAL';

export type AllocationStatus =
  | 'ASSIGNED'
  | 'IN_PROGRESS'
  | 'PARTIALLY_COLLECTED'
  | 'COLLECTED'
  | 'REALLOCATED'
  | 'EXPIRED';

export type VisitStatus =
  | 'CUSTOMER_MET'
  | 'DOOR_LOCKED'
  | 'ADDRESS_NOT_FOUND'
  | 'REFUSED_TO_PAY'
  | 'THIRD_PARTY_MET'
  | 'PARTIAL_PAYMENT_PROMISE';

export type PaymentMode = 'CASH' | 'UPI' | 'CHEQUE' | 'NEFT' | 'POS_CARD' | 'NET_BANKING';

export type PaymentStatus = 'SUCCESS' | 'PENDING_VERIFICATION' | 'REJECTED' | 'REFUNDED';

export type FollowupType = 'FIELD_VISIT' | 'PHONE_CALL' | 'SMS_REMINDER' | 'LEGAL_NOTICE';

export type FollowupStatus = 'PENDING' | 'COMPLETED' | 'MISSED' | 'CANCELLED';

export type StorageBucketName =
  | 'customer-photo'
  | 'house-photo'
  | 'receipt-photo'
  | 'kyc'
  | 'documents'
  | 'executive-profile';

export interface Database {
  public: {
    Tables: {
      users: {
        Row: {
          id: string;
          employee_code: string;
          full_name: string;
          email: string;
          phone: string;
          role_id: string;
          branch_id: string | null;
          avatar_url: string | null;
          status: UserStatus;
          device_id: string | null;
          device_name: string | null;
          last_login_at: string | null;
          created_at: string;
          updated_at: string;
        };
        Insert: Omit<Database['public']['Tables']['users']['Row'], 'created_at' | 'updated_at'>;
        Update: Partial<Database['public']['Tables']['users']['Insert']>;
      };
      roles: {
        Row: {
          id: string;
          name: string;
          code: UserRoleCode;
          description: string | null;
          created_at: string;
          updated_at: string;
        };
        Insert: Omit<Database['public']['Tables']['roles']['Row'], 'id' | 'created_at' | 'updated_at'>;
        Update: Partial<Database['public']['Tables']['roles']['Insert']>;
      };
      permissions: {
        Row: {
          id: string;
          module: string;
          action: string;
          code: string;
          description: string | null;
          created_at: string;
        };
        Insert: Omit<Database['public']['Tables']['permissions']['Row'], 'id' | 'created_at'>;
        Update: Partial<Database['public']['Tables']['permissions']['Insert']>;
      };
      role_permissions: {
        Row: {
          role_id: string;
          permission_id: string;
          created_at: string;
        };
        Insert: Omit<Database['public']['Tables']['role_permissions']['Row'], 'created_at'>;
        Update: Partial<Database['public']['Tables']['role_permissions']['Insert']>;
      };
      branches: {
        Row: {
          id: string;
          branch_code: string;
          name: string;
          region: string;
          city: string;
          state: string;
          address: string | null;
          contact_phone: string | null;
          contact_email: string | null;
          is_active: boolean;
          created_at: string;
          updated_at: string;
        };
        Insert: Omit<Database['public']['Tables']['branches']['Row'], 'id' | 'created_at' | 'updated_at'>;
        Update: Partial<Database['public']['Tables']['branches']['Insert']>;
      };
      customers: {
        Row: {
          id: string;
          customer_code: string;
          full_name: string;
          phone_primary: string;
          phone_secondary: string | null;
          email: string | null;
          address_residence: string;
          address_office: string | null;
          city: string;
          state: string;
          pincode: string;
          latitude: number | null;
          longitude: number | null;
          photo_url: string | null;
          kyc_status: string;
          risk_category: string;
          branch_id: string;
          created_at: string;
          updated_at: string;
        };
        Insert: Omit<Database['public']['Tables']['customers']['Row'], 'id' | 'created_at' | 'updated_at'>;
        Update: Partial<Database['public']['Tables']['customers']['Insert']>;
      };
      loans: {
        Row: {
          id: string;
          loan_account_number: string;
          customer_id: string;
          branch_id: string;
          loan_type: string;
          disbursed_amount: number;
          principal_outstanding: number;
          interest_outstanding: number;
          penalty_outstanding: number;
          total_outstanding: number;
          emi_amount: number;
          disbursed_date: string;
          maturity_date: string;
          next_emi_due_date: string;
          dpd: number;
          bucket: LoanBucket;
          status: LoanStatus;
          created_at: string;
          updated_at: string;
        };
        Insert: Omit<Database['public']['Tables']['loans']['Row'], 'id' | 'created_at' | 'updated_at'>;
        Update: Partial<Database['public']['Tables']['loans']['Insert']>;
      };
      allocations: {
        Row: {
          id: string;
          allocation_code: string;
          loan_id: string;
          customer_id: string;
          executive_id: string;
          assigned_by: string;
          branch_id: string;
          allocated_at: string;
          due_date: string;
          target_amount: number;
          status: AllocationStatus;
          notes: string | null;
          created_at: string;
          updated_at: string;
        };
        Insert: Omit<Database['public']['Tables']['allocations']['Row'], 'id' | 'created_at' | 'updated_at'>;
        Update: Partial<Database['public']['Tables']['allocations']['Insert']>;
      };
      visits: {
        Row: {
          id: string;
          visit_code: string;
          allocation_id: string | null;
          loan_id: string;
          customer_id: string;
          executive_id: string;
          visit_date: string;
          latitude: number;
          longitude: number;
          gps_accuracy: number | null;
          photos_urls: Json;
          visit_status: VisitStatus;
          remarks: string;
          promise_date: string | null;
          expected_amount: number | null;
          created_at: string;
        };
        Insert: Omit<Database['public']['Tables']['visits']['Row'], 'id' | 'created_at'>;
        Update: Partial<Database['public']['Tables']['visits']['Insert']>;
      };
      payments: {
        Row: {
          id: string;
          payment_code: string;
          receipt_number: string;
          visit_id: string | null;
          loan_id: string;
          customer_id: string;
          executive_id: string;
          branch_id: string;
          amount_paid: number;
          payment_mode: PaymentMode;
          payment_reference: string | null;
          receipt_photo_url: string | null;
          payment_status: PaymentStatus;
          collected_at: string;
          verified_by: string | null;
          verified_at: string | null;
          created_at: string;
        };
        Insert: Omit<Database['public']['Tables']['payments']['Row'], 'id' | 'created_at'>;
        Update: Partial<Database['public']['Tables']['payments']['Insert']>;
      };
      followups: {
        Row: {
          id: string;
          followup_code: string;
          loan_id: string;
          customer_id: string;
          executive_id: string;
          scheduled_at: string;
          followup_type: FollowupType;
          status: FollowupStatus;
          notes: string | null;
          reminder_sent: boolean;
          created_at: string;
          updated_at: string;
        };
        Insert: Omit<Database['public']['Tables']['followups']['Row'], 'id' | 'created_at' | 'updated_at'>;
        Update: Partial<Database['public']['Tables']['followups']['Insert']>;
      };
      attendance: {
        Row: {
          id: string;
          attendance_code: string;
          executive_id: string;
          date: string;
          check_in_time: string;
          check_out_time: string | null;
          check_in_lat: number;
          check_in_lng: number;
          check_out_lat: number | null;
          check_out_lng: number | null;
          distance_covered_km: number;
          status: string;
          created_at: string;
        };
        Insert: Omit<Database['public']['Tables']['attendance']['Row'], 'id' | 'created_at'>;
        Update: Partial<Database['public']['Tables']['attendance']['Insert']>;
      };
      gps_logs: {
        Row: {
          id: string;
          executive_id: string;
          latitude: number;
          longitude: number;
          accuracy: number | null;
          speed: number | null;
          battery_level: number | null;
          device_id: string | null;
          captured_at: string;
        };
        Insert: Omit<Database['public']['Tables']['gps_logs']['Row'], 'id' | 'captured_at'>;
        Update: Partial<Database['public']['Tables']['gps_logs']['Insert']>;
      };
      notifications: {
        Row: {
          id: string;
          user_id: string;
          title: string;
          body: string;
          notification_type: string;
          entity_type: string | null;
          entity_id: string | null;
          is_read: boolean;
          payload: Json;
          created_at: string;
        };
        Insert: Omit<Database['public']['Tables']['notifications']['Row'], 'id' | 'created_at'>;
        Update: Partial<Database['public']['Tables']['notifications']['Insert']>;
      };
      activity_logs: {
        Row: {
          id: string;
          user_id: string | null;
          action: string;
          entity_type: string;
          entity_id: string | null;
          old_state: Json | null;
          new_state: Json | null;
          ip_address: string | null;
          user_agent: string | null;
          created_at: string;
        };
        Insert: Omit<Database['public']['Tables']['activity_logs']['Row'], 'id' | 'created_at'>;
        Update: Partial<Database['public']['Tables']['activity_logs']['Insert']>;
      };
      documents: {
        Row: {
          id: string;
          document_code: string;
          entity_type: string;
          entity_id: string;
          document_type: string;
          file_name: string;
          file_url: string;
          mime_type: string;
          file_size: number;
          uploaded_by: string | null;
          created_at: string;
        };
        Insert: Omit<Database['public']['Tables']['documents']['Row'], 'id' | 'created_at'>;
        Update: Partial<Database['public']['Tables']['documents']['Insert']>;
      };
      settings: {
        Row: {
          id: string;
          setting_key: string;
          setting_value: string;
          category: string;
          description: string | null;
          updated_by: string | null;
          updated_at: string;
        };
        Insert: Omit<Database['public']['Tables']['settings']['Row'], 'id' | 'updated_at'>;
        Update: Partial<Database['public']['Tables']['settings']['Insert']>;
      };
      device_tokens: {
        Row: {
          id: string;
          user_id: string;
          fcm_token: string;
          device_type: string;
          device_id: string;
          app_version: string | null;
          is_active: boolean;
          last_seen_at: string;
          created_at: string;
        };
        Insert: Omit<Database['public']['Tables']['device_tokens']['Row'], 'id' | 'created_at'>;
        Update: Partial<Database['public']['Tables']['device_tokens']['Insert']>;
      };
      sync_logs: {
        Row: {
          id: string;
          executive_id: string;
          device_id: string;
          sync_started_at: string;
          sync_completed_at: string | null;
          records_uploaded: number;
          records_downloaded: number;
          status: string;
          conflict_count: number;
          error_details: Json | null;
          created_at: string;
        };
        Insert: Omit<Database['public']['Tables']['sync_logs']['Row'], 'id' | 'created_at'>;
        Update: Partial<Database['public']['Tables']['sync_logs']['Insert']>;
      };
      import_jobs: {
        Row: {
          id: string;
          job_code: string;
          file_name: string;
          uploaded_by: string;
          status: string;
          total_records: number;
          processed_records: number;
          success_count: number;
          error_count: number;
          error_log_json: Json;
          created_at: string;
          finished_at: string | null;
        };
        Insert: Omit<Database['public']['Tables']['import_jobs']['Row'], 'id' | 'created_at'>;
        Update: Partial<Database['public']['Tables']['import_jobs']['Insert']>;
      };
      receipts: {
        Row: {
          id: string;
          receipt_number: string;
          payment_id: string;
          loan_id: string;
          customer_id: string;
          executive_id: string;
          amount: number;
          receipt_date: string;
          pdf_url: string | null;
          digital_signature: string | null;
          qr_code_data: string | null;
          status: string;
          created_at: string;
        };
        Insert: Omit<Database['public']['Tables']['receipts']['Row'], 'id' | 'created_at'>;
        Update: Partial<Database['public']['Tables']['receipts']['Insert']>;
      };
      ledger: {
        Row: {
          id: string;
          loan_id: string;
          customer_id: string;
          payment_id: string | null;
          transaction_type: string;
          debit: number;
          credit: number;
          balance_after: number;
          transaction_date: string;
          reference_number: string | null;
          created_by: string | null;
          created_at: string;
        };
        Insert: Omit<Database['public']['Tables']['ledger']['Row'], 'id' | 'created_at'>;
        Update: Partial<Database['public']['Tables']['ledger']['Insert']>;
      };
    };
  };
}
