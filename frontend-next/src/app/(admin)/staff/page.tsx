'use client'

import { useState } from 'react'
import { useStaff, useCreateStaff } from '@/hooks/useStaff'
import { Skeleton } from '@/components/ui/skeleton'
import { Badge } from '@/components/ui/badge'
import { Users, UserPlus, Mail, X, Loader2 } from 'lucide-react'
import { toast } from 'sonner'

const ROLE_COLORS: Record<string, string> = {
  SUPER_ADMIN: 'bg-purple-100 text-purple-800',
  ADMIN: 'bg-blue-100 text-blue-800',
  FIELD_EXECUTIVE: 'bg-emerald-100 text-emerald-800',
}

export default function StaffPage() {
  const { data: staff = [], isLoading } = useStaff()
  const createStaff = useCreateStaff()
  const activeStaff = staff.filter(s => s.status === 'ACTIVE')
  const [showModal, setShowModal] = useState(false)
  const [form, setForm] = useState({
    email: '', password: '', fullName: '', phone: '',
    role: 'executive' as 'admin' | 'executive', branchName: '',
  })

  const handleCreate = async () => {
    if (!form.email || !form.password || !form.fullName) {
      toast.error('Email, password and name are required')
      return
    }
    try {
      await createStaff.mutateAsync(form)
      toast.success('Staff member created!')
      setShowModal(false)
      setForm({ email: '', password: '', fullName: '', phone: '', role: 'executive', branchName: '' })
    } catch (err: unknown) {
      toast.error(err instanceof Error ? err.message : 'Failed to create staff')
    }
  }

  return (
    <div className="min-h-screen">
      <header className="sticky top-0 h-16 bg-white dark:bg-slate-900 border-b border-slate-200 dark:border-slate-800 flex items-center justify-between px-6 z-40">
        <div>
          <h1 className="font-bold text-slate-900 dark:text-white text-lg">Staff Management</h1>
          <p className="text-xs text-slate-500">{activeStaff.length} active members</p>
        </div>
        <button onClick={() => setShowModal(true)} className="flex items-center gap-1.5 px-3 py-2 bg-blue-600 text-white rounded-lg text-sm font-medium hover:bg-blue-700 transition-colors">
          <UserPlus size={14} /> Add Staff
        </button>
      </header>

      <div className="p-6 max-w-7xl mx-auto space-y-4">
        <div className="grid grid-cols-3 gap-4">
          {[
            { label: 'Total Staff', value: staff.length },
            { label: 'Active', value: activeStaff.length },
            { label: 'Executives', value: staff.filter(s => s.roles?.code === 'FIELD_EXECUTIVE').length },
          ].map(({ label, value }) => (
            <div key={label} className="bg-white dark:bg-slate-900 rounded-xl p-4 border border-slate-200 dark:border-slate-800 shadow-sm flex items-center gap-3">
              <div className="w-10 h-10 bg-blue-50 dark:bg-blue-950 rounded-xl flex items-center justify-center">
                <Users size={18} className="text-blue-600" />
              </div>
              <div>
                <p className="text-2xl font-bold text-slate-900 dark:text-white">{value}</p>
                <p className="text-xs text-slate-500">{label}</p>
              </div>
            </div>
          ))}
        </div>

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
                      <Badge className={`text-[10px] ${ROLE_COLORS[s.roles?.code ?? 'FIELD_EXECUTIVE']}`}>
                        {s.roles?.code ?? 'FIELD_EXECUTIVE'}
                      </Badge>
                    </td>
                    <td className="px-5 py-3 text-slate-500">{s.branch_id ?? 'N/A'}</td>
                    <td className="px-5 py-3">
                      <span className={`px-2 py-0.5 rounded-full text-[10px] font-bold ${s.status === 'ACTIVE' ? 'bg-emerald-100 text-emerald-700' : 'bg-red-100 text-red-700'}`}>
                        {s.status ?? 'Active'}
                      </span>
                    </td>
                  </tr>
                ))}
            </tbody>
          </table>
        </div>
      </div>

      {showModal && (
        <div className="fixed inset-0 bg-black/50 z-50 flex items-center justify-center p-4">
          <div className="bg-white dark:bg-slate-900 rounded-2xl w-full max-w-md p-6 space-y-4">
            <div className="flex justify-between items-center">
              <h3 className="font-bold text-slate-900 dark:text-white">Add Staff Member</h3>
              <button onClick={() => setShowModal(false)}><X size={20} className="text-slate-500" /></button>
            </div>
            {([
              { label: 'Full Name *', key: 'fullName', type: 'text', placeholder: 'John Doe' },
              { label: 'Email *', key: 'email', type: 'email', placeholder: 'john@company.com' },
              { label: 'Password *', key: 'password', type: 'password', placeholder: '••••••••' },
              { label: 'Phone', key: 'phone', type: 'tel', placeholder: '+91 9876543210' },
              { label: 'Branch', key: 'branchName', type: 'text', placeholder: 'Mumbai' },
            ] as const).map(({ label, key, type, placeholder }) => (
              <div key={key}>
                <label className="text-xs text-slate-500 mb-1 block">{label}</label>
                <input type={type} placeholder={placeholder}
                  value={form[key]}
                  onChange={e => setForm(p => ({ ...p, [key]: e.target.value }))}
                  className="w-full text-sm border border-slate-200 dark:border-slate-700 rounded-lg p-3 outline-none bg-white dark:bg-slate-800" />
              </div>
            ))}
            <div>
              <label className="text-xs text-slate-500 mb-1 block">Role</label>
              <select value={form.role} onChange={e => setForm(p => ({ ...p, role: e.target.value as 'admin' | 'executive' }))}
                className="w-full text-sm border border-slate-200 dark:border-slate-700 rounded-lg p-3 outline-none bg-white dark:bg-slate-800">
                <option value="executive">Executive</option>
                <option value="admin">Admin</option>
              </select>
            </div>
            <button onClick={handleCreate} disabled={createStaff.isPending}
              className="w-full h-12 bg-blue-600 text-white font-bold rounded-xl disabled:opacity-60 flex items-center justify-center gap-2">
              {createStaff.isPending ? <><Loader2 size={16} className="animate-spin" /> Creating...</> : 'Create Staff'}
            </button>
          </div>
        </div>
      )}
    </div>
  )
}
