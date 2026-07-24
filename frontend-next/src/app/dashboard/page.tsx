'use client'

import { AppLayout } from '@/components/layout/AppLayout'
import { useCases } from '@/hooks/useCases'
import { useRealtimeSync } from '@/hooks/useRealtimeSync'
import { useCaseStore } from '@/stores/useCaseStore'
import { useAuthStore } from '@/stores/useAuthStore'
import { useSyncStore } from '@/stores/useSyncStore'
import { formatCurrency } from '@/lib/utils/currency'
import { deriveOutstanding, deriveEmi, deriveRisk, RISK_CONFIG } from '@/lib/utils/risk'
import { Skeleton } from '@/components/ui/skeleton'
import { Badge } from '@/components/ui/badge'
import { useRouter } from 'next/navigation'
import { Phone, MapPin, Car, CreditCard, Clock } from 'lucide-react'

export default function ExecutiveDashboardPage() {
  useRealtimeSync()
  const router = useRouter()
  const { data: cases = [], isLoading } = useCases()
  const { selectedCase, setSelectedCase } = useCaseStore()
  const { user } = useAuthStore()
  const { lastSynced } = useSyncStore()

  return (
    <AppLayout>
      {/* Header */}
      <header className="sticky top-0 bg-white dark:bg-slate-900 border-b border-slate-200 dark:border-slate-800 px-4 py-3 z-40">
        <div className="flex justify-between items-center">
          <div>
            <h1 className="font-bold text-slate-900 dark:text-white text-base">Field Dashboard</h1>
            <p className="text-xs text-slate-500">{user?.email ?? 'Field Executive'}</p>
          </div>
          {lastSynced && (
            <span className="flex items-center gap-1.5 text-xs text-emerald-600 font-medium bg-emerald-50 px-2 py-1 rounded-full">
              <span className="w-1.5 h-1.5 rounded-full bg-emerald-500 animate-pulse" />
              Live
            </span>
          )}
        </div>
      </header>

      <div className="px-4 py-4 space-y-4">
        {/* Selected Case Card */}
        {selectedCase && (
          <div className="bg-gradient-to-br from-blue-600 to-blue-800 rounded-2xl p-4 text-white shadow-lg">
            <div className="flex justify-between items-start mb-3">
              <div>
                <p className="text-blue-200 text-xs font-medium uppercase tracking-wider">Active Case</p>
                <h2 className="font-bold text-lg leading-tight mt-0.5">{selectedCase.customer_name}</h2>
                <p className="text-blue-200 text-xs">Loan: {selectedCase.loan_no ?? 'N/A'}</p>
              </div>
              <Badge className={`text-[10px] ${RISK_CONFIG[deriveRisk(selectedCase)].className}`}>
                {RISK_CONFIG[deriveRisk(selectedCase)].label}
              </Badge>
            </div>
            <div className="grid grid-cols-2 gap-3 mb-4">
              <div className="bg-white/10 rounded-xl p-3">
                <p className="text-blue-200 text-[10px] uppercase">Outstanding</p>
                <p className="font-bold text-sm">{formatCurrency(deriveOutstanding(selectedCase))}</p>
              </div>
              <div className="bg-white/10 rounded-xl p-3">
                <p className="text-blue-200 text-[10px] uppercase">EMI</p>
                <p className="font-bold text-sm">{formatCurrency(deriveEmi(selectedCase))}</p>
              </div>
            </div>
            <div className="flex gap-2">
              {selectedCase.mobile_number && (
                <a href={`tel:${selectedCase.mobile_number}`}
                  className="flex-1 flex items-center justify-center gap-1.5 bg-white/20 hover:bg-white/30 rounded-xl py-2.5 text-xs font-bold transition-colors">
                  <Phone size={14} /> Call
                </a>
              )}
              <button onClick={() => router.push('/visits/new')}
                className="flex-1 flex items-center justify-center gap-1.5 bg-white/20 hover:bg-white/30 rounded-xl py-2.5 text-xs font-bold transition-colors">
                <Car size={14} /> Visit
              </button>
              <button onClick={() => router.push('/payments/new')}
                className="flex-1 flex items-center justify-center gap-1.5 bg-white text-blue-700 hover:bg-blue-50 rounded-xl py-2.5 text-xs font-bold transition-colors">
                <CreditCard size={14} /> Collect
              </button>
            </div>
          </div>
        )}

        {/* Quick Stats */}
        <div className="grid grid-cols-3 gap-3">
          <div className="bg-white dark:bg-slate-900 rounded-xl p-3 text-center border border-slate-100 dark:border-slate-800">
            <p className="text-2xl font-bold text-slate-900 dark:text-white">{cases.length}</p>
            <p className="text-[10px] text-slate-500 mt-0.5">Total Cases</p>
          </div>
          <div className="bg-white dark:bg-slate-900 rounded-xl p-3 text-center border border-slate-100 dark:border-slate-800">
            <p className="text-2xl font-bold text-emerald-600">{cases.filter(c => deriveRisk(c) === 'LOW').length}</p>
            <p className="text-[10px] text-slate-500 mt-0.5">Low Risk</p>
          </div>
          <div className="bg-white dark:bg-slate-900 rounded-xl p-3 text-center border border-slate-100 dark:border-slate-800">
            <p className="text-2xl font-bold text-red-500">{cases.filter(c => deriveRisk(c) === 'CRITICAL').length}</p>
            <p className="text-[10px] text-slate-500 mt-0.5">Critical</p>
          </div>
        </div>

        {/* Customer Queue */}
        <div>
          <div className="flex justify-between items-center mb-3">
            <h3 className="font-semibold text-slate-800 dark:text-slate-200">Customer Queue</h3>
            <span className="text-xs text-slate-400">{cases.length} Total</span>
          </div>
          <div className="space-y-3">
            {isLoading
              ? Array.from({ length: 5 }).map((_, i) => <Skeleton key={i} className="h-32 rounded-xl" />)
              : cases.slice(0, 30).map(c => (
                <div
                  key={c.id}
                  onClick={() => setSelectedCase(c)}
                  className={`bg-white dark:bg-slate-900 rounded-xl p-4 border transition-all cursor-pointer ${selectedCase?.id === c.id ? 'border-blue-500 ring-1 ring-blue-200' : 'border-slate-100 dark:border-slate-800 hover:shadow-sm'}`}
                >
                  <div className="flex justify-between items-start gap-2">
                    <div className="min-w-0">
                      <span className="text-[10px] font-bold px-1.5 py-0.5 rounded bg-red-100 text-red-700">{c.bucket ?? 'Open'}</span>
                      <h4 className="font-bold text-sm text-slate-900 dark:text-white mt-1 truncate">{c.customer_name}</h4>
                      <p className="text-xs text-slate-500">Loan: {c.loan_no ?? 'N/A'}</p>
                    </div>
                    <span className="text-[10px] px-2 py-0.5 rounded-full bg-emerald-50 text-emerald-700 font-semibold whitespace-nowrap">{c.loan_status ?? 'OPEN'}</span>
                  </div>
                  <div className="grid grid-cols-2 gap-3 mt-3 pt-2 border-t border-slate-100 dark:border-slate-800 text-xs">
                    <div>
                      <p className="text-slate-400 uppercase text-[10px]">Outstanding</p>
                      <p className="font-bold text-slate-800 dark:text-white">{formatCurrency(deriveOutstanding(c))}</p>
                    </div>
                    <div>
                      <p className="text-slate-400 uppercase text-[10px]">Collected</p>
                      <p className="font-bold text-slate-800 dark:text-white">{formatCurrency(c.total_collected_amount ?? 0)}</p>
                    </div>
                  </div>
                  <div className="flex gap-2 mt-3">
                    {c.mobile_number && (
                      <a href={`tel:${c.mobile_number}`} onClick={e => e.stopPropagation()}
                        className="flex-1 text-center py-1.5 bg-slate-50 dark:bg-slate-800 text-blue-600 rounded-lg font-bold text-xs">Call</a>
                    )}
                    <button onClick={() => { setSelectedCase(c); router.push(`/customers/${c.id}`) }}
                      className="flex-1 py-1.5 bg-slate-50 dark:bg-slate-800 text-blue-600 rounded-lg font-bold text-xs">Details</button>
                    <button onClick={() => { setSelectedCase(c); router.push('/visits/new') }}
                      className="flex-1 py-1.5 bg-blue-600 text-white rounded-lg font-bold text-xs">Visit</button>
                  </div>
                </div>
              ))}
          </div>
        </div>
      </div>
    </AppLayout>
  )
}
