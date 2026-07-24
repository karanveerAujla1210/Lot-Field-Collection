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
