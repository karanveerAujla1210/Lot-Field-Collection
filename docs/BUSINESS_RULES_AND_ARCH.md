# FinCollect Enterprise Business Architecture & Technical Rules

## 1. System Roles & Access Control Matrix (8 Tiers)

| Role Code | Description | Scope Boundary |
| :--- | :--- | :--- |
| `SUPER_ADMIN` | System wide administrator | Global tenant & platform configuration |
| `ADMIN` | Portfolio & System Manager | Enterprise portfolio management & imports |
| `REGIONAL_MANAGER` | Regional Supervisor | All branches within assigned region |
| `BRANCH_MANAGER` | Branch Manager | Branch portfolio, allocations & team ranking |
| `COLLECTION_MANAGER` | Field Collection Lead | Team targets, recovery strategies & visits |
| `FIELD_EXECUTIVE` | Field Execution Agent | Assigned customer allocations, visits & payments |
| `FINANCE` | Financial Auditor | Payment verification, ledger & receipts |
| `AUDITOR` | Compliance Officer | Read-only access to audit logs & reports |

---

## 2. Business Flow Rules

### 2.1 Customer & Loan Bulk Allocation Flow
1. Admin uploads Excel file (`.xlsx`).
2. `ExcelImportService` parses spreadsheet and invokes `excel-import` Edge Function.
3. System validates mandatory columns: `customer_code`, `loan_account_number`, `branch_code`, `executive_employee_code`.
4. Customers and Loans are inserted/updated atomically (`upsert` on unique code).
5. Allocations created with `status = 'ASSIGNED'`.
6. Real-time Push Notification sent to Field Executive's device token.
7. Mobile client receives allocation immediately via Supabase Realtime channel.

### 2.2 Field Visit Execution Flow
1. Field Executive arrives at customer location.
2. App retrieves device GPS coordinates (`latitude`, `longitude`, `accuracy`).
3. Executive captures photos uploaded to `house-photo` storage bucket.
4. Executive enters visit remarks, outcome (`CUSTOMER_MET`, `DOOR_LOCKED`, `REFUSED_TO_PAY`), and optional Promise to Pay (PTP) date & expected amount.
5. Visit record saved with PL/pgSQL audit trigger log.
6. Allocation status updated to `IN_PROGRESS`.

### 2.3 Payment Collection & Financial Ledger Flow
1. Field Executive collects payment (Cash/UPI/Cheque/NEFT).
2. App calls `payment-processor` Edge Function.
3. Unique receipt number generated (`RCP-YYMMDD-XXXX`).
4. Database trigger `update_loan_balances_on_payment` automatically:
   - Reduces `principal_outstanding` and `total_outstanding`.
   - Closes loan if outstanding reaches `0.00`.
   - Updates allocation status to `COLLECTED` or `PARTIALLY_COLLECTED`.
   - Creates `COLLECTION_CREDIT` transaction entry in `ledger`.
   - Issues `receipts` record with digital QR payload.
5. Push notification dispatched to Branch Manager.
6. Real-time update reflected on CRM Master Dashboard.

### 2.4 DPD Aging & Bucket Recalculation Flow
1. System runs daily cron execution of `recalculate_dpd_and_buckets()`.
2. Days Past Due (`dpd`) = `CURRENT_DATE - next_emi_due_date`.
3. Bucket assignment rules:
   - `0 days`: `CURRENT`
   - `1 - 30 days`: `SMA-0`
   - `31 - 60 days`: `SMA-1`
   - `61 - 90 days`: `SMA-2`
   - `91 - 180 days`: `NPA`
   - `> 180 days`: `NPA-90+`

---

## 3. Offline Sync Architecture

```
Mobile Local Storage (SQLite / Realm)
        │
        │ Queue: [ { id, type, action, timestamp, data } ]
        │
        ├─ Network Restored ─► Invokes 'offline-sync' Edge Function
        │                           │
        │                           ├─ Validate Client Timestamps
        │                           ├─ Resolve Duplicate Codes (23505)
        │                           ├─ Execute Inserters
        │                           └─ Record in [sync_logs]
        ▼
Server PostgreSQL State Clean
```

---

## 4. Storage Buckets Specification

| Bucket Name | Privacy Level | Allowed File Types | Size Limit |
| :--- | :--- | :--- | :--- |
| `customer-photo` | Private | JPEG, PNG, WEBP | 10 MB |
| `house-photo` | Private | JPEG, PNG, WEBP | 10 MB |
| `receipt-photo` | Private | JPEG, PNG, WEBP | 10 MB |
| `kyc` | Private | JPEG, PNG, PDF | 20 MB |
| `documents` | Private | JPEG, PNG, PDF, XLSX | 20 MB |
| `executive-profile` | Public | JPEG, PNG, WEBP | 5 MB |

---

## 5. Scalability & Performance Benchmarks

- **Target Customers**: 100,000 active customer profiles.
- **Target Executives**: 5,000 field collection agents.
- **Indexing Strategy**: B-Tree composite indexes on `(executive_id, status)`, `(branch_id, dpd)`, `(customer_id)`, and `(loan_account_number)`.
- **Query Optimization**: Pagination limit = 50 rows, indexed searches, Realtime events scoped by branch.
