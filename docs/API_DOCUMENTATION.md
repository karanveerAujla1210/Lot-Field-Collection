# FinCollect Enterprise Backend API Documentation

## Supabase Endpoints Overview

- **Supabase URL**: `https://tflsmxmuvrecrewknbvb.supabase.co`
- **Publishable Key**: `sb_publishable_OAx279ocalpzqLVAhhMb-w_WdfkOWUH`
- **Database Engine**: PostgreSQL 15 + PostGIS
- **Authentication**: Supabase Auth (JWT Bearer Token header: `Authorization: Bearer <access_token>`)

---

## 1. Authentication APIs (`/auth`)

### 1.1 Login with Email & Password
- **SDK Call**: `AuthService.login(email, password, deviceId, deviceName)`
- **REST Endpoint**: `POST /auth/v1/token?grant_type=password`
- **Request Body**:
  ```json
  {
    "email": "executive@fincollect.app",
    "password": "SecurePassword123!"
  }
  ```
- **Response**:
  ```json
  {
    "access_token": "eyJhbGciOi...",
    "token_type": "bearer",
    "expires_in": 3600,
    "refresh_token": "rF8x...",
    "user": {
      "id": "u1234567-89ab-cdef-0123-456789abcdef",
      "email": "executive@fincollect.app"
    }
  }
  ```

### 1.2 Device Token Registration
- **SDK Call**: `AuthService.registerDeviceToken(userId, fcmToken, deviceType, deviceId, appVersion)`
- **RPC / Table**: `UPSERT /rest/v1/device_tokens`

---

## 2. Customer APIs (`/customers`)

### 2.1 List / Search Customers
- **SDK Call**: `CustomerService.listCustomers({ branchId, riskCategory, searchQuery, page, limit })`
- **REST Endpoint**: `GET /rest/v1/customers?select=*&branch_id=eq.<branch_id>&order=created_at.desc`

### 2.2 Create Customer Profile
- **SDK Call**: `CustomerService.createCustomer(customerData)`
- **REST Endpoint**: `POST /rest/v1/customers`

---

## 3. Loan Portfolio APIs (`/loans`)

### 3.1 Get Loan Details
- **SDK Call**: `LoanService.getLoanDetails(loanId)`
- **REST Endpoint**: `GET /rest/v1/loans?id=eq.<loanId>&select=*,customers(*),branches(*)`

### 3.2 Fetch Loans by DPD Bucket
- **SDK Call**: `LoanService.getLoansByBucket(bucket, branchId)`
- **Buckets**: `CURRENT`, `SMA-0`, `SMA-1`, `SMA-2`, `NPA`, `NPA-90+`

---

## 4. Allocation APIs (`/allocations`)

### 4.1 Assign Loan Allocation
- **SDK Call**: `AllocationService.createAllocation({ loanId, customerId, executiveId, assignedBy, branchId, dueDate, targetAmount })`
- **REST Endpoint**: `POST /rest/v1/allocations`

---

## 5. Field Visit APIs (`/visits`)

### 5.1 Record Field Visit
- **SDK Call**: `VisitService.recordVisit({ loanId, customerId, executiveId, latitude, longitude, visitStatus, remarks, photosUrls, promiseDate, expectedAmount })`
- **REST Endpoint**: `POST /rest/v1/visits`

---

## 6. Payment Collection APIs (`/payments`)

### 6.1 Process Payment & Generate Receipt
- **SDK Call**: `PaymentService.processPayment({ loanId, customerId, executiveId, branchId, amountPaid, paymentMode, paymentReference, receiptPhotoUrl })`
- **Edge Function Endpoint**: `POST /functions/v1/payment-processor`
- **Response**:
  ```json
  {
    "success": true,
    "receipt_number": "RCP-948123-4819",
    "updated_outstanding": 12500.00
  }
  ```

---

## 7. Supabase Edge Functions Reference

| Function Name | Invocation Path | Purpose |
| :--- | :--- | :--- |
| `excel-import` | `/functions/v1/excel-import` | Bulk customer/loan portfolio import & allocation assignment |
| `payment-processor` | `/functions/v1/payment-processor` | Financial collection, receipt PDF generation & ledger sync |
| `offline-sync` | `/functions/v1/offline-sync` | Offline execution queue replay & conflict resolution |
| `push-notifications` | `/functions/v1/push-notifications` | Multi-channel FCM push notification dispatcher |
| `dashboard-aggregator` | `/functions/v1/dashboard-aggregator` | Real-time KPI metrics aggregator |

---

## 8. Realtime Subscriptions

```javascript
// Bi-directional live sync between CRM and Mobile Client
supabase
  .channel('global-collection')
  .on('postgres_changes', { event: '*', schema: 'public', table: 'payments' }, payload => {
    console.log('Payment event received:', payload);
  })
  .subscribe();
```
