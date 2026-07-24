'use client'

import { AdminLayout } from '@/components/layout/AdminLayout'
import { useStaff } from '@/hooks/useStaff'
import { Skeleton } from '@/components/ui/skeleton'
import { Badge } from '@/components/ui/badge'
import { Users, UserPlus, Mail, Phone } from 'lucide-react'

const ROLE_COLORS: Record<string, string> = {
  super_admin: 'bg-purple-100 text-purple-800',
  admin: 'bg-blue-100 text-blue-800',
  executive: 'bg-emerald-100 text-emerald-800',
}

export default function StaffPage() {
  const { data: staff = [], isLoading } = useStaff()
  const activeStaff = staff.filter(s => s.is_active)

  return (
    <AdminLayout>
      <div className="min-h-screen">
        <header className="sticky top-0 h-16 bg-white dark:bg-slate-900 border-b border-slate-200 dark:border-slate-800 flex items-center justify-between px-6 z-40">
          <div>
            <h1 className="font-bold text-slate-900 dark:text-white text-lg">Staff Management</h1>
            <p className="text-xs text-slate-500">{activeStaff.length} active members</p>
          </div>
          <button className="flex items-center gap-1.5 px-3 py-2 bg-blue-600 text-white rounded-lg text-sm font-medium hover:bg-blue-700 transition-colors">
            <UserPlus size={14} /> Add Staff
          </button>
        </header>

        <div className="p-6 max-w-7xl mx-auto space-y-4">
          {/* Summary cards */}
          <div className="grid grid-cols-3 gap-4">
            {[
              { label: 'Total Staff', value: staff.length, icon: Users },
              { label: 'Active', value: activeStaff.length, icon: Users },
              { label: 'Executives', value: staff.filter(s => s.role === 'executive').length, icon: Users },
            ].map(({ label, value, icon: Icon }) => (
              <div key={label} className="bg-white dark:bg-slate-900 rounded-xl p-4 border border-slate-200 dark:border-slate-800 shadow-sm flex items-center gap-3">
                <div className="w-10 h-10 bg-blue-50 dark:bg-blue-950 rounded-xl flex items-center justify-center">
                  <Icon size={18} className="text-blue-600" />
                </div>
                <div>
                  <p className="text-2xl font-bold text-slate-900 dark:text-white">{value}</p>
                  <p className="text-xs text-slate-500">{label}</p>
                </div>
              </div>
            ))}
          </div>

          {/* Staff table */}
          <div className="bg-white dark:bg-slate-900 rounded-xl border border-slate-200 dark:border-slate-800 shadow-sm overflow-hidden">
            <table className="w-full text-sm">
              <thead>
                <tr className="bg-slate-50 dark:bg-slate-800/60 text-xs text-slate-500 uppercase tracking-wider">
                  <th className="px-5 py-3 text-left font-medium">Name</th>
                  <th className="px-5 py-3 text-left font-medium">Email</th>
                  <th className="px-5 py-3 text-left font-medium">Role</th>
                  <th className="px-5 py-3 text-left font-medium">Branch</th>
                  <th className="px-5 py-3 text-left font-medium">Status</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-slate-100 dark:divide-slate-800">
                {isLoading
                  ? Array.from({ length: 6 }).map((_, i) => (
                    <tr key={i}>
                      {Array.from({ length: 5 }).map((_, j) => (
                        <td key={j} className="px-5 py-3"><Skeleton className="h-4 w-24" /></td>
                      ))}
                    </tr>
                  ))
                  : staff.map(s => (
                    <tr key={s.id} className="hover:bg-slate-50 dark:hover:bg-slate-800/40 transition-colors">
                      <td className="px-5 py-3">
                        <div className="flex items-center gap-2">
                          <div className="w-7 h-7 rounded-full bg-blue-100 dark:bg-blue-900 flex items-center justify-center text-blue-700 text-xs font-bold">
                            {s.full_name?.[0] ?? s.email?.[0]?.toUpperCase() ?? '?'}
                          </div>
                          <span className="font-medium text-slate-800 dark:text-slate-200">{s.full_name ?? 'Unknown'}</span>
                        </div>
                      </td>
                      <td className="px-5 py-3 text-slate-500">
                        <span className="flex items-center gap-1"><Mail size={12} />{s.email}</span>
                      </td>
                      <td className="px-5 py-3">
                        <Badge className={`text-[10px] ${ROLE_COLORS[s.role ?? 'executive']}`}>
                          {s.role ?? 'executive'}
                        </Badge>
                      </td>
                      <td className="px-5 py-3 text-slate-500">{s.branch_name ?? 'N/A'}</td>
                      <td className="px-5 py-3">
                        <span className={`px-2 py-0.5 rounded-full text-[10px] font-bold ${s.is_active ? 'bg-emerald-100 text-emerald-700' : 'bg-red-100 text-red-700'}`}>
                          {s.is_active ? 'Active' : 'Inactive'}
                        </span>
                      </td>
                    </tr>
                  ))}
              </tbody>
            </table>
          </div>
        </div>
      </div>
    </AdminLayout>
  )
}
