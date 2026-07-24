'use client'

import { AdminLayout } from '@/components/layout/AdminLayout'
import { useCases } from '@/hooks/useCases'
import { useStaff } from '@/hooks/useStaff'
import { useRealtimeSync } from '@/hooks/useRealtimeSync'
import { useSyncStore } from '@/stores/useSyncStore'
import { formatCurrency, formatCurrencyCompact } from '@/lib/utils/currency'
import { deriveOutstanding, deriveRisk, RISK_CONFIG } from '@/lib/utils/risk'
import { toNumber } from '@/lib/utils/currency'
import { Skeleton } from '@/components/ui/skeleton'
import { Badge } from '@/components/ui/badge'
import {
  TrendingUp, Users, AlertTriangle, Wallet,
  RefreshCw, Download, Search, Bell
} from 'lucide-react'
import {
  BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer, LineChart, Line
} from 'recharts'
import type { CaseRow } from '@/types/database.types'

function KpiCard({ title, value, icon: Icon, trend, color }: {
  title: string; value: string; icon: React.ElementType; trend?: string; color: string
}) {
  return (
    <div className={`bg-white dark:bg-slate-900 rounded-xl p-4 shadow-sm border-l-4 ${color} flex flex-col gap-3`}>
      <div className="flex justify-between items-start">
        <span className="text-xs text-slate-500 uppercase tracking-wider font-medium">{title}</span>
        <div className="p-1.5 bg-slate-50 dark:bg-slate-800 rounded-lg">
          <Icon size={18} className="text-slate-600 dark:text-slate-400" />
        </div>
      </div>
      <div>
        <p className="text-2xl font-bold text-slate-900 dark:text-white">{value}</p>
        {trend && (
          <p className="text-xs text-emerald-600 flex items-center gap-1 mt-1">
            <TrendingUp size={12} /> {trend}
          </p>
        )}
      </div>
    </div>
  )
}

const BUCKET_COLORS: Record<string, string> = {
  'X': '#dc2626', 'NPA': '#7c3aed', '1-30': '#f59e0b',
  '31-60': '#f97316', '61-90': '#ef4444', 'OPEN': '#16a34a',
}

export default function AdminDashboardPage() {
  useRealtimeSync()
  const { data: cases = [], isLoading: casesLoading } = useCases()
  const { data: staff = [], isLoading: staffLoading } = useStaff()
  const { lastSynced } = useSyncStore()

  const totalCollection = cases.reduce((s, c) => s + toNumber(c.total_collected_amount), 0)
  const totalOutstanding = cases.reduce((s, c) => s + deriveOutstanding(c), 0)
  const criticalCases = cases.filter(c => deriveRisk(c) === 'CRITICAL').length

  // Bucket distribution for bar chart
  const bucketData = Object.entries(
    cases.reduce((acc: Record<string, number>, c) => {
      const b = c.bucket ?? 'OPEN'
      acc[b] = (acc[b] ?? 0) + 1
      return acc
    }, {})
  ).map(([bucket, count]) => ({ bucket, count }))

  // Top 15 cases by outstanding
  const topCases = [...cases]
    .sort((a, b) => deriveOutstanding(b) - deriveOutstanding(a))
    .slice(0, 15)

  return (
    <AdminLayout>
      <div className="min-h-screen">
        {/* Top Bar */}
        <header className="sticky top-0 h-16 bg-white dark:bg-slate-900 border-b border-slate-200 dark:border-slate-800 flex justify-between items-center px-6 z-40">
          <div className="relative w-80">
            <Search size={16} className="absolute left-3 top-1/2 -translate-y-1/2 text-slate-400" />
            <input
              className="w-full bg-slate-50 dark:bg-slate-800 border-none rounded-full pl-9 pr-4 py-2 text-sm focus:ring-2 focus:ring-blue-100 outline-none"
              placeholder="Search accounts, cases, or agents..."
            />
          </div>
          <div className="flex items-center gap-4">
            {lastSynced && (
              <span className="flex items-center gap-1.5 text-xs text-emerald-600 font-medium">
                <span className="w-2 h-2 rounded-full bg-emerald-500 animate-pulse" />
                Live Synced
              </span>
            )}
            <button className="relative text-slate-500 hover:text-blue-600">
              <Bell size={20} />
              <span className="absolute -top-1 -right-1 w-2 h-2 bg-red-500 rounded-full" />
            </button>
          </div>
        </header>

        {/* Content */}
        <div className="p-6 max-w-7xl mx-auto space-y-6">
          {/* Page Title */}
          <div className="flex justify-between items-end">
            <div>
              <h2 className="text-3xl font-bold text-slate-900 dark:text-white">Overview</h2>
              <p className="text-sm text-slate-500 mt-1">Global collection metrics — Live from Supabase</p>
            </div>
            <div className="flex gap-2">
              <button className="flex items-center gap-1.5 px-3 py-2 text-xs font-medium bg-white dark:bg-slate-800 border border-slate-200 dark:border-slate-700 rounded-lg hover:bg-slate-50 transition-colors">
                <RefreshCw size={14} /> Refresh
              </button>
              <button className="flex items-center gap-1.5 px-3 py-2 text-xs font-medium bg-white dark:bg-slate-800 border border-slate-200 dark:border-slate-700 rounded-lg hover:bg-slate-50 transition-colors">
                <Download size={14} /> Export PDF
              </button>
            </div>
          </div>

          {/* KPI Grid */}
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
            {casesLoading ? (
              Array.from({ length: 4 }).map((_, i) => <Skeleton key={i} className="h-28 rounded-xl" />)
            ) : (
              <>
                <KpiCard title="Total Collection" value={formatCurrencyCompact(totalCollection)} icon={Wallet} trend="Live data" color="border-blue-600" />
                <KpiCard title="Outstanding" value={formatCurrencyCompact(totalOutstanding)} icon={TrendingUp} color="border-emerald-500" />
                <KpiCard title="Active Executives" value={`${staff.length} / ${staff.length}`} icon={Users} trend="All online" color="border-purple-500" />
                <KpiCard title="Critical Cases" value={criticalCases.toString()} icon={AlertTriangle} trend="180+ days DPD" color="border-red-500" />
              </>
            )}
          </div>

          {/* Charts Row */}
          <div className="grid grid-cols-1 lg:grid-cols-2 gap-4">
            {/* Bucket Distribution */}
            <div className="bg-white dark:bg-slate-900 rounded-xl p-5 border border-slate-200 dark:border-slate-800 shadow-sm">
              <h3 className="font-semibold text-slate-800 dark:text-slate-200 mb-4">Cases by DPD Bucket</h3>
              {casesLoading ? <Skeleton className="h-48" /> : (
                <ResponsiveContainer width="100%" height={200}>
                  <BarChart data={bucketData} margin={{ top: 0, right: 0, left: -20, bottom: 0 }}>
                    <CartesianGrid strokeDasharray="3 3" className="opacity-30" />
                    <XAxis dataKey="bucket" tick={{ fontSize: 11 }} />
                    <YAxis tick={{ fontSize: 11 }} />
                    <Tooltip />
                    <Bar dataKey="count" fill="#0038ca" radius={[4, 4, 0, 0]} />
                  </BarChart>
                </ResponsiveContainer>
              )}
            </div>

            {/* Total Cases Trend (simulated) */}
            <div className="bg-white dark:bg-slate-900 rounded-xl p-5 border border-slate-200 dark:border-slate-800 shadow-sm">
              <h3 className="font-semibold text-slate-800 dark:text-slate-200 mb-4">Collection Trend</h3>
              <ResponsiveContainer width="100%" height={200}>
                <LineChart data={[
                  { month: 'Aug', amount: 2100000 }, { month: 'Sep', amount: 2500000 },
                  { month: 'Oct', amount: 2200000 }, { month: 'Nov', amount: 2900000 },
                  { month: 'Dec', amount: 3180000 },
                ]}>
                  <CartesianGrid strokeDasharray="3 3" className="opacity-30" />
                  <XAxis dataKey="month" tick={{ fontSize: 11 }} />
                  <YAxis tickFormatter={(v) => `₹${(v / 100000).toFixed(0)}L`} tick={{ fontSize: 11 }} />
                  <Tooltip formatter={(v) => formatCurrency(Number(v))} />
                  <Line type="monotone" dataKey="amount" stroke="#0038ca" strokeWidth={2} dot={{ r: 4 }} />
                </LineChart>
              </ResponsiveContainer>
            </div>
          </div>

          {/* Case Table */}
          <div className="bg-white dark:bg-slate-900 rounded-xl border border-slate-200 dark:border-slate-800 shadow-sm overflow-hidden">
            <div className="flex justify-between items-center px-5 py-4 border-b border-slate-100 dark:border-slate-800">
              <h3 className="font-semibold text-slate-800 dark:text-slate-200">
                Live Cases <span className="text-xs text-slate-400 font-normal ml-1">({cases.length} total)</span>
              </h3>
            </div>
            <div className="overflow-x-auto">
              <table className="w-full text-sm">
                <thead>
                  <tr className="bg-slate-50 dark:bg-slate-800/60 text-xs text-slate-500 uppercase tracking-wider">
                    <th className="px-5 py-3 text-left font-medium">Loan No</th>
                    <th className="px-5 py-3 text-left font-medium">Customer</th>
                    <th className="px-5 py-3 text-left font-medium">Outstanding</th>
                    <th className="px-5 py-3 text-left font-medium">Branch</th>
                    <th className="px-5 py-3 text-left font-medium">Status</th>
                    <th className="px-5 py-3 text-left font-medium">Risk</th>
                  </tr>
                </thead>
                <tbody className="divide-y divide-slate-100 dark:divide-slate-800">
                  {casesLoading
                    ? Array.from({ length: 8 }).map((_, i) => (
                      <tr key={i}>
                        {Array.from({ length: 6 }).map((_, j) => (
                          <td key={j} className="px-5 py-3"><Skeleton className="h-4 w-24" /></td>
                        ))}
                      </tr>
                    ))
                    : topCases.map((c: CaseRow) => {
                      const risk = deriveRisk(c)
                      const riskCfg = RISK_CONFIG[risk]
                      return (
                        <tr key={c.id} className="hover:bg-slate-50 dark:hover:bg-slate-800/40 transition-colors group">
                          <td className="px-5 py-3 font-bold text-blue-700 dark:text-blue-400">{c.loan_no ?? 'N/A'}</td>
                          <td className="px-5 py-3 font-medium text-slate-800 dark:text-slate-200">{c.customer_name ?? 'N/A'}</td>
                          <td className="px-5 py-3 font-bold text-emerald-600">{formatCurrency(deriveOutstanding(c))}</td>
                          <td className="px-5 py-3 text-slate-500">{c.branch_name ?? c.state_name ?? 'India'}</td>
                          <td className="px-5 py-3">
                            <span className="px-2 py-0.5 bg-emerald-50 text-emerald-700 rounded-full text-[10px] font-bold">
                              {c.loan_status ?? 'OPEN'}
                            </span>
                          </td>
                          <td className="px-5 py-3">
                            <Badge className={`text-[10px] ${riskCfg.className}`}>{riskCfg.label}</Badge>
                          </td>
                        </tr>
                      )
                    })}
                </tbody>
              </table>
            </div>
          </div>
        </div>
      </div>
    </AdminLayout>
  )
}
