'use client'

import { useState } from 'react'
import { useCases } from '@/hooks/useCases'
import { useFollowUps, useCreateFollowUp, useCompleteFollowUp } from '@/hooks/useFollowUps'
import { useCaseStore } from '@/stores/useCaseStore'
import { useAuthStore } from '@/stores/useAuthStore'
import { formatCurrency } from '@/lib/utils/currency'
import { Skeleton } from '@/components/ui/skeleton'
import { useRouter } from 'next/navigation'
import { Clock, Car, CreditCard, Bell, CheckCircle, Plus, X } from 'lucide-react'
import { toast } from 'sonner'

export default function FollowUpsPage() {
  const { data: cases = [], isLoading: casesLoading } = useCases()
  const { user } = useAuthStore()
  const { data: followUps = [], isLoading: followUpsLoading } = useFollowUps(user?.id)
  const createFollowUp = useCreateFollowUp()
  const completeFollowUp = useCompleteFollowUp()
  const { setSelectedCase } = useCaseStore()
  const router = useRouter()
  const [activeTab, setActiveTab] = useState<'scheduled' | 'queue'>('scheduled')
  const [showScheduleModal, setShowScheduleModal] = useState(false)
  const [scheduleForm, setScheduleForm] = useState({ date: '', notes: '' })

  const overdueQueue = [...cases]
    .filter(c => (c.due_days ?? 0) > 0)
    .sort((a, b) => (b.due_days ?? 0) - (a.due_days ?? 0))
    .slice(0, 50)

  const pendingFollowUps = followUps.filter(f => f.status === 'PENDING')

  const handleSchedule = async () => {
    const c = useCaseStore.getState().selectedCase
    if (!c || !user || !scheduleForm.date) {
      toast.error('Select a case and fill in the date')
      return
    }
    if (!c.loan_no || !c.customer_name) {
      toast.error('Case is missing required data')
      return
    }
    try {
      await createFollowUp.mutateAsync({
        caseId: c.id,
        loanNo: c.loan_no,
        customerName: c.customer_name,
        executiveId: user.id,
        followUpDate: scheduleForm.date,
        notes: scheduleForm.notes,
      })
      toast.success('Follow-up scheduled!')
      setShowScheduleModal(false)
      setScheduleForm({ date: '', notes: '' })
    } catch (err: unknown) {
      toast.error(err instanceof Error ? err.message : 'Failed to schedule')
    }
  }

  return (
    <>
      <header className="sticky top-0 bg-white dark:bg-slate-900 border-b border-slate-200 dark:border-slate-800 px-4 py-3 z-40">
        <div className="flex justify-between items-center mb-3">
          <div>
            <h1 className="font-bold text-slate-900 dark:text-white text-base">Follow-up Reminders</h1>
            <p className="text-xs text-slate-500">{pendingFollowUps.length} scheduled · {overdueQueue.length} overdue</p>
          </div>
          <div className="w-8 h-8 bg-amber-100 dark:bg-amber-950 rounded-full flex items-center justify-center">
            <Bell size={16} className="text-amber-600" />
          </div>
        </div>
        <div className="flex gap-2">
          {(['scheduled', 'queue'] as const).map(tab => (
            <button key={tab} onClick={() => setActiveTab(tab)}
              className={`px-3 py-1.5 rounded-full text-xs font-semibold transition-colors ${activeTab === tab ? 'bg-blue-600 text-white' : 'bg-slate-100 dark:bg-slate-800 text-slate-600 dark:text-slate-400'}`}>
              {tab === 'scheduled' ? `Scheduled (${pendingFollowUps.length})` : `Overdue Queue (${overdueQueue.length})`}
            </button>
          ))}
        </div>
      </header>

      <div className="px-4 py-4 space-y-3">
        {activeTab === 'scheduled' && (
          <>
            {followUpsLoading
              ? Array.from({ length: 4 }).map((_, i) => <Skeleton key={i} className="h-24 rounded-xl" />)
              : pendingFollowUps.length === 0
                ? (
                  <div className="text-center py-16 text-slate-400">
                    <Clock size={40} className="mx-auto mb-3 opacity-30" />
                    <p className="font-medium">No scheduled follow-ups</p>
                    <p className="text-sm">Select a case from the queue and schedule one</p>
                  </div>
                )
                : pendingFollowUps.map(f => (
                  <div key={f.id} className="bg-white dark:bg-slate-900 rounded-xl p-4 border border-slate-100 dark:border-slate-800">
                    <div className="flex justify-between items-start mb-2">
                      <div>
                        <p className="font-bold text-sm text-slate-900 dark:text-white">{f.customer_name}</p>
                        <p className="text-xs text-slate-500">Loan: {f.loan_no}</p>
                      </div>
                      <div className="flex items-center gap-1 text-xs font-bold text-amber-600">
                        <Clock size={12} />
                        {f.follow_up_date ? new Date(f.follow_up_date).toLocaleDateString('en-IN') : 'No date'}
                      </div>
                    </div>
                    {f.notes && <p className="text-xs text-slate-500 mb-3">{f.notes}</p>}
                    <button
                      onClick={async () => {
                        await completeFollowUp.mutateAsync(f.id)
                        toast.success('Follow-up marked complete')
                      }}
                      className="flex items-center gap-1 px-3 py-1.5 bg-emerald-50 dark:bg-emerald-950 text-emerald-600 rounded-lg text-xs font-bold">
                      <CheckCircle size={12} /> Mark Complete
                    </button>
                  </div>
                ))
            }
          </>
        )}

        {activeTab === 'queue' && (
          <>
            {casesLoading
              ? Array.from({ length: 6 }).map((_, i) => <Skeleton key={i} className="h-28 rounded-xl" />)
              : overdueQueue.map(c => {
                const urgency = (c.due_days ?? 0) >= 90 ? 'high' : (c.due_days ?? 0) >= 30 ? 'medium' : 'low'
                const urgencyStyles = {
                  high: 'border-l-red-500 bg-red-50/50 dark:bg-red-950/20',
                  medium: 'border-l-amber-500 bg-amber-50/50 dark:bg-amber-950/20',
                  low: 'border-l-blue-400 bg-white dark:bg-slate-900',
                }[urgency]
                return (
                  <div key={c.id} className={`rounded-xl p-4 border border-slate-100 dark:border-slate-800 border-l-4 ${urgencyStyles}`}>
                    <div className="flex justify-between items-start mb-2">
                      <div>
                        <h3 className="font-bold text-sm text-slate-900 dark:text-white">{c.customer_name}</h3>
                        <p className="text-xs text-slate-500">Loan: {c.loan_no}</p>
                      </div>
                      <div className="flex items-center gap-1 text-xs font-bold">
                        <Clock size={12} className={urgency === 'high' ? 'text-red-500' : 'text-amber-500'} />
                        <span className={urgency === 'high' ? 'text-red-600' : urgency === 'medium' ? 'text-amber-600' : 'text-blue-600'}>
                          {c.due_days} DPD
                        </span>
                      </div>
                    </div>
                    <div className="flex gap-3 text-xs mb-3">
                      <div>
                        <p className="text-slate-400 text-[10px] uppercase">Outstanding</p>
                        <p className="font-bold text-slate-800 dark:text-white">{formatCurrency(c.loan_repay_amount ?? c.loan_amount ?? 0)}</p>
                      </div>
                      <div>
                        <p className="text-slate-400 text-[10px] uppercase">Bucket</p>
                        <p className="font-bold text-slate-800 dark:text-white">{c.bucket ?? 'Open'}</p>
                      </div>
                    </div>
                    <div className="flex gap-2">
                      <button onClick={() => { setSelectedCase(c); router.push('/visits/new') }}
                        className="flex-1 flex items-center justify-center gap-1 py-2 bg-blue-50 dark:bg-blue-950 text-blue-600 rounded-lg text-xs font-bold">
                        <Car size={12} /> Visit
                      </button>
                      <button onClick={() => { setSelectedCase(c); router.push('/payments/new') }}
                        className="flex-1 flex items-center justify-center gap-1 py-2 bg-emerald-50 dark:bg-emerald-950 text-emerald-600 rounded-lg text-xs font-bold">
                        <CreditCard size={12} /> Collect
                      </button>
                      <button onClick={() => { setSelectedCase(c); setShowScheduleModal(true) }}
                        className="flex-1 flex items-center justify-center gap-1 py-2 bg-amber-50 dark:bg-amber-950 text-amber-600 rounded-lg text-xs font-bold">
                        <Plus size={12} /> Schedule
                      </button>
                    </div>
                  </div>
                )
              })
            }
          </>
        )}
      </div>

      {/* Schedule Follow-up Modal */}
      {showScheduleModal && (
        <div className="fixed inset-0 bg-black/50 z-50 flex items-end">
          <div className="bg-white dark:bg-slate-900 rounded-t-2xl w-full p-6 space-y-4">
            <div className="flex justify-between items-center">
              <h3 className="font-bold text-slate-900 dark:text-white">Schedule Follow-up</h3>
              <button onClick={() => setShowScheduleModal(false)}><X size={20} className="text-slate-500" /></button>
            </div>
            <div>
              <label className="text-xs text-slate-500 mb-1 block">Follow-up Date *</label>
              <input type="date" value={scheduleForm.date}
                onChange={e => setScheduleForm(p => ({ ...p, date: e.target.value }))}
                className="w-full text-sm border border-slate-200 dark:border-slate-700 rounded-lg p-3 outline-none bg-white dark:bg-slate-800" />
            </div>
            <div>
              <label className="text-xs text-slate-500 mb-1 block">Notes</label>
              <textarea rows={2} value={scheduleForm.notes}
                onChange={e => setScheduleForm(p => ({ ...p, notes: e.target.value }))}
                placeholder="Reason for follow-up..."
                className="w-full text-sm border border-slate-200 dark:border-slate-700 rounded-lg p-3 resize-none outline-none bg-white dark:bg-slate-800" />
            </div>
            <button onClick={handleSchedule} disabled={createFollowUp.isPending}
              className="w-full h-12 bg-blue-600 text-white font-bold rounded-xl disabled:opacity-60">
              {createFollowUp.isPending ? 'Scheduling...' : 'Schedule Follow-up'}
            </button>
          </div>
        </div>
      )}
    </>
  )
}
