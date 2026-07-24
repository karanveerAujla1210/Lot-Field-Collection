'use client'

import { AdminLayout } from '@/components/layout/AdminLayout'
import { useCases } from '@/hooks/useCases'
import { useStaff } from '@/hooks/useStaff'
import { formatCurrency, formatCurrencyCompact, toNumber } from '@/lib/utils/currency'
import { deriveOutstanding, deriveRisk } from '@/lib/utils/risk'
import { Skeleton } from '@/components/ui/skeleton'
import {
  BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer,
  PieChart, Pie, Cell, type PieLabelRenderProps,
} from 'recharts'

const COLORS = ['#0038ca', '#00573a', '#e85d04', '#ba1a1a', '#7c3aed']

export default function ReportsPage() {
  const { data: cases = [], isLoading } = useCases()
  const { data: staff = [] } = useStaff()

  const totalCollection = cases.reduce((s, c) => s + toNumber(c.total_collected_amount), 0)
  const totalOutstanding = cases.reduce((s, c) => s + deriveOutstanding(c), 0)

  const bucketData = Object.entries(
    cases.reduce((acc: Record<string, number>, c) => {
      const b = c.bucket ?? 'OPEN'
      acc[b] = (acc[b] ?? 0) + 1
      return acc
    }, {})
  ).map(([name, value]) => ({ name, value }))

  const riskData = ['LOW', 'MEDIUM', 'HIGH', 'CRITICAL'].map(r => ({
    name: r,
    count: cases.filter(c => deriveRisk(c) === r).length,
  }))

  const branchData = Object.entries(
    cases.reduce((acc: Record<string, number>, c) => {
      const b = c.branch_name ?? c.state_name ?? 'Other'
      acc[b] = (acc[b] ?? 0) + deriveOutstanding(c)
      return acc
    }, {})
  ).sort((a, b) => b[1] - a[1]).slice(0, 8).map(([branch, amount]) => ({ branch, amount }))

  return (
    <AdminLayout>
      <div className="min-h-screen">
        <header className="sticky top-0 h-16 bg-white dark:bg-slate-900 border-b border-slate-200 dark:border-slate-800 flex items-center px-6 z-40">
          <div>
            <h1 className="font-bold text-slate-900 dark:text-white text-lg">Reports & Analytics</h1>
            <p className="text-xs text-slate-500">Live data from Supabase</p>
          </div>
        </header>

        <div className="p-6 max-w-7xl mx-auto space-y-6">
          {/* Summary KPIs */}
          <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
            {[
              { title: 'Total Cases', value: cases.length.toString() },
              { title: 'Total Collection', value: formatCurrencyCompact(totalCollection) },
              { title: 'Total Outstanding', value: formatCurrencyCompact(totalOutstanding) },
              { title: 'Total Staff', value: staff.length.toString() },
            ].map(({ title, value }) => (
              <div key={title} className="bg-white dark:bg-slate-900 rounded-xl p-4 border border-slate-200 dark:border-slate-800 shadow-sm">
                <p className="text-xs text-slate-500 uppercase tracking-wider">{title}</p>
                {isLoading ? <Skeleton className="h-8 mt-2" /> : <p className="text-2xl font-bold text-slate-900 dark:text-white mt-1">{value}</p>}
              </div>
            ))}
          </div>

          <div className="grid grid-cols-1 lg:grid-cols-2 gap-4">
            {/* DPD Bucket Pie */}
            <div className="bg-white dark:bg-slate-900 rounded-xl p-5 border border-slate-200 dark:border-slate-800 shadow-sm">
              <h3 className="font-semibold text-slate-800 dark:text-slate-200 mb-4">Cases by DPD Bucket</h3>
              {isLoading ? <Skeleton className="h-56" /> : (
                <ResponsiveContainer width="100%" height={220}>
                  <PieChart>
                    <Pie data={bucketData} dataKey="value" nameKey="name" cx="50%" cy="50%" outerRadius={80} label={(props: PieLabelRenderProps) => `${props.name ?? ''}: ${(((props.percent as number) ?? 0) * 100).toFixed(0)}%`}>
                      {bucketData.map((_, i) => <Cell key={i} fill={COLORS[i % COLORS.length]} />)}
                    </Pie>
                    <Tooltip />
                  </PieChart>
                </ResponsiveContainer>
              )}
            </div>

            {/* Risk Distribution Bar */}
            <div className="bg-white dark:bg-slate-900 rounded-xl p-5 border border-slate-200 dark:border-slate-800 shadow-sm">
              <h3 className="font-semibold text-slate-800 dark:text-slate-200 mb-4">Risk Distribution</h3>
              {isLoading ? <Skeleton className="h-56" /> : (
                <ResponsiveContainer width="100%" height={220}>
                  <BarChart data={riskData} margin={{ top: 0, right: 0, left: -20, bottom: 0 }}>
                    <CartesianGrid strokeDasharray="3 3" className="opacity-30" />
                    <XAxis dataKey="name" tick={{ fontSize: 11 }} />
                    <YAxis tick={{ fontSize: 11 }} />
                    <Tooltip />
                    <Bar dataKey="count" radius={[4, 4, 0, 0]}
                      fill="#0038ca"
                      label={{ position: 'top', fontSize: 11 }} />
                  </BarChart>
                </ResponsiveContainer>
              )}
            </div>

            {/* Branch Outstanding */}
            <div className="bg-white dark:bg-slate-900 rounded-xl p-5 border border-slate-200 dark:border-slate-800 shadow-sm lg:col-span-2">
              <h3 className="font-semibold text-slate-800 dark:text-slate-200 mb-4">Outstanding by Branch</h3>
              {isLoading ? <Skeleton className="h-56" /> : (
                <ResponsiveContainer width="100%" height={220}>
                  <BarChart data={branchData} margin={{ top: 0, right: 0, left: 10, bottom: 20 }}>
                    <CartesianGrid strokeDasharray="3 3" className="opacity-30" />
                    <XAxis dataKey="branch" tick={{ fontSize: 10 }} angle={-30} textAnchor="end" interval={0} />
                    <YAxis tickFormatter={v => `₹${(v / 100000).toFixed(0)}L`} tick={{ fontSize: 11 }} />
                    <Tooltip formatter={(v) => formatCurrency(Number(v))} />
                    <Bar dataKey="amount" fill="#00573a" radius={[4, 4, 0, 0]} />
                  </BarChart>
                </ResponsiveContainer>
              )}
            </div>
          </div>
        </div>
      </div>
    </AdminLayout>
  )
}
