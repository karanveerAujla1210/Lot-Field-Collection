# LOT Field Collection — Enterprise Platform

A full-stack enterprise field collection platform for loan officers and admins, built with vanilla HTML/JS frontend, TypeScript backend services, Supabase (PostgreSQL + Realtime), and a Capacitor-based Android app.

---

## Project Structure

```
lot-field-collection/
├── frontend/                   # Web UI (served by Vercel / http-server)
│   ├── index.html              # Master portal (iframe-based screen switcher)
│   ├── bridge/
│   │   └── fincollect-bridge.js  # Supabase JS bridge (shared by all screens)
│   └── screens/                # All 16 application screens
│       ├── login_screen/
│       ├── admin_dashboard/
│       ├── dashboard/
│       ├── live_monitoring/
│       ├── customer_list/
│       ├── customer_details/
│       ├── visit_screen/
│       ├── payment_screen/
│       ├── follow_up_screen/
│       ├── reports_analytics/
│       ├── staff_management/
│       ├── portfolio_manager/
│       ├── profile_screen/
│       ├── sync_screen/
│       └── ...
│
├── backend/                    # TypeScript backend services
│   ├── package.json
│   ├── tsconfig.json
│   └── src/
│       ├── index.ts
│       ├── config/
│       │   └── supabase.config.ts
│       ├── services/
│       │   ├── AuthService.ts
│       │   ├── CustomerService.ts
│       │   ├── PaymentService.ts
│       │   ├── VisitService.ts
│       │   ├── LoanService.ts
│       │   ├── AllocationService.ts
│       │   ├── AttendanceService.ts
│       │   ├── FollowupService.ts
│       │   ├── ReportService.ts
│       │   ├── AuditService.ts
│       │   ├── ExcelImportService.ts
│       │   ├── OfflineSyncService.ts
│       │   └── RealtimeService.ts
│       └── types/
│           └── database.types.ts
│
├── mobile/                     # Capacitor Android app
│   └── android/
│
├── supabase/                   # Database schema & migrations
│   ├── migrations/
│   └── seed.sql
│
├── scripts/
│   └── build-www.js            # Copies frontend/ into mobile assets
│
├── docs/                       # Project documentation
├── .env                        # Local environment variables (gitignored)
├── .env.example                # Template for environment variables
├── package.json                # Monorepo root
├── tsconfig.json               # Root TypeScript config
└── vercel.json                 # Vercel deployment config
```

---

## Getting Started

### Prerequisites
- Node.js 18+
- A [Supabase](https://supabase.com) project

### 1. Clone & Install
```bash
git clone <repo-url>
cd lot-field-collection
npm install
```

### 2. Configure Environment
```bash
cp .env.example .env
# Edit .env with your Supabase URL and keys
```

### 3. Run the Frontend Locally
```bash
npm run dev
# Opens at http://localhost:3000
```

### 4. Type-Check the Backend
```bash
npm run type-check
```

---

## Deployment

The frontend is deployed via **Vercel**. The `vercel.json` serves the `frontend/` directory with CORS headers.

Push to your connected GitHub repo and Vercel will auto-deploy.

---

## Mobile (Android)

The mobile app is built with [Capacitor](https://capacitorjs.com/).

```bash
# Build web assets into mobile
npm run build:www

# Open in Android Studio
npx cap open android
```

---

## Database

Supabase migrations are in `supabase/migrations/`. Apply with:

```bash
npx supabase db push
```
