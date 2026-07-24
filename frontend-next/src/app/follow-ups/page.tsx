'use client'

import { AppLayout } from '@/components/layout/AppLayout'
import { useCases } from '@/hooks/useCases'
import { useCaseStore } from '@/stores/useCaseStore'
import { formatCurrency } from '@/lib/utils/currency'
import { formatTimestamp } from '@/lib/utils/risk'
import { Skeleton } from '@/components/ui/skeleton'
import { useRouter } from 'next/navigation'
import { Clock, Car, CreditCard, Bell } from 'lucide-react'

// Follow-ups are derived from cases with due_days > 0 that haven't been visited recently
export default function FollowUpsPage() {
  const { data: cases = [], isLoading } = useCases()
  const { setSelectedCase } = useCaseStore()
  const router = useRouter()

  // Cases sorted by urgency (highest due_days first, treated as follow-up queue)
  const followUpQueue = [...cases]
    .filter(c => (c.due_days ?? 0) > 0)
    .sort((a, b) => (b.due_days ?? 0) - (a.due_days ?? 0))
    .slice(0, 50)

  return (
    <AppLayout>
      <header className="sticky top-0 bg-white dark:bg-slate-900 border-b border-slate-200 dark:border-slate-800 px-4 py-3 z-40">
        <div className="flex justify-between items-center">
          <div>
            <h1 className="font-bold text-slate-900 dark:text-white text-base">Follow-up Reminders</h1>
            <p className="text-xs text-slate-500">{followUpQueue.length} cases pending follow-up</p>
          </div>
          <div className="w-8 h-8 bg-amber-100 dark:bg-amber-950 rounded-full flex items-center justify-center">
            <Bell size={16} className="text-amber-600" />
          </div>
        </div>
      </header>

      <div className="px-4 py-4 space-y-3">
        {isLoading
          ? Array.from({ length: 6 }).map((_, i) => <Skeleton key={i} className="h-28 rounded-xl" />)
          : followUpQueue.map(c => {
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
                  <div>
                    <p className="text-slate-400 text-[10px] uppercase">Branch</p>
                    <p className="font-bold text-slate-800 dark:text-white">{c.branch_name ?? c.state_name ?? 'N/A'}</p>
                  </div>
                </div>

                <div className="flex gap-2">
                  <button
                    onClick={() => { setSelectedCase(c); router.push('/visits/new') }}
                    className="flex-1 flex items-center justify-center gap-1 py-2 bg-blue-50 dark:bg-blue-950 text-blue-600 rounded-lg text-xs font-bold hover:bg-blue-100 transition-colors">
                    <Car size={12} /> Schedule Visit
                  </button>
                  <button
                    onClick={() => { setSelectedCase(c); router.push('/payments/new') }}
                    className="flex-1 flex items-center justify-center gap-1 py-2 bg-emerald-50 dark:bg-emerald-950 text-emerald-600 rounded-lg text-xs font-bold hover:bg-emerald-100 transition-colors">
                    <CreditCard size={12} /> Collect
                  </button>
                </div>
              </div>
            )
          })}

        {!isLoading && followUpQueue.length === 0 && (
          <div className="text-center py-16 text-slate-400">
            <Clock size={40} className="mx-auto mb-3 opacity-30" />
            <p className="font-medium">No follow-ups pending</p>
            <p className="text-sm">All cases are up to date</p>
          </div>
        )}
      </div>
    </AppLayout>
  )
}
