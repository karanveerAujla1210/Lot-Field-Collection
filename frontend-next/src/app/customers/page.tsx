'use client'

import { useState } from 'react'
import { AppLayout } from '@/components/layout/AppLayout'
import { useCases } from '@/hooks/useCases'
import { useCaseStore } from '@/stores/useCaseStore'
import { formatCurrency } from '@/lib/utils/currency'
import { deriveOutstanding, deriveRisk, RISK_CONFIG } from '@/lib/utils/risk'
import { Skeleton } from '@/components/ui/skeleton'
import { Badge } from '@/components/ui/badge'
import { useRouter } from 'next/navigation'
import { Search, Phone, Car, CreditCard, SlidersHorizontal } from 'lucide-react'
import type { CaseRow } from '@/types/database.types'

export default function CustomerListPage() {
  const router = useRouter()
  const { data: cases = [], isLoading } = useCases()
  const { setSelectedCase } = useCaseStore()
  const [search, setSearch] = useState('')
  const [filterRisk, setFilterRisk] = useState<string>('ALL')

  const filtered = cases.filter(c => {
    const q = search.toLowerCase()
    const matchesSearch = !q || [c.customer_name, c.loan_no, c.mobile_number, c.branch_name]
      .some(v => v?.toLowerCase().includes(q))
    const matchesRisk = filterRisk === 'ALL' || deriveRisk(c) === filterRisk
    return matchesSearch && matchesRisk
  })

  return (
    <AppLayout>
      {/* Header */}
      <header className="sticky top-0 bg-white dark:bg-slate-900 border-b border-slate-200 dark:border-slate-800 px-4 py-3 z-40">
        <h1 className="font-bold text-slate-900 dark:text-white text-base mb-3">
          Customer List <span className="text-sm font-normal text-slate-400 ml-1">({filtered.length})</span>
        </h1>
        <div className="relative mb-2">
          <Search size={16} className="absolute left-3 top-1/2 -translate-y-1/2 text-slate-400" />
          <input
            className="w-full pl-9 pr-4 py-2.5 bg-slate-50 dark:bg-slate-800 rounded-xl text-sm focus:ring-2 focus:ring-blue-100 outline-none border border-slate-200 dark:border-slate-700"
            placeholder="Search name, loan no, phone..."
            value={search}
            onChange={e => setSearch(e.target.value)}
          />
        </div>
        {/* Risk filter chips */}
        <div className="flex gap-2 overflow-x-auto no-scrollbar pb-1">
          {['ALL', 'LOW', 'MEDIUM', 'HIGH', 'CRITICAL'].map(r => (
            <button key={r} onClick={() => setFilterRisk(r)}
              className={`px-3 py-1 rounded-full text-xs font-semibold whitespace-nowrap transition-colors ${
                filterRisk === r
                  ? 'bg-blue-600 text-white'
                  : 'bg-slate-100 dark:bg-slate-800 text-slate-600 dark:text-slate-400'
              }`}>
              {r}
            </button>
          ))}
        </div>
      </header>

      <div className="px-4 py-4 space-y-3">
        {isLoading
          ? Array.from({ length: 6 }).map((_, i) => <Skeleton key={i} className="h-36 rounded-xl" />)
          : filtered.map((c: CaseRow) => {
            const risk = deriveRisk(c)
            const riskCfg = RISK_CONFIG[risk]
            return (
              <div key={c.id}
                className="bg-white dark:bg-slate-900 rounded-xl p-4 border border-slate-100 dark:border-slate-800 hover:shadow-sm transition-all">
                <div className="flex justify-between items-start gap-2 mb-3">
                  <div className="min-w-0">
                    <span className="text-[10px] font-bold px-1.5 py-0.5 rounded bg-red-100 text-red-700">{c.bucket ?? 'Open'}</span>
                    <h3 className="font-bold text-sm text-slate-900 dark:text-white mt-1 truncate">{c.customer_name}</h3>
                    <p className="text-xs text-slate-500">Loan: {c.loan_no ?? 'N/A'}</p>
                  </div>
                  <Badge className={`text-[10px] shrink-0 ${riskCfg.className}`}>{riskCfg.label}</Badge>
                </div>

                <div className="grid grid-cols-2 gap-3 py-2 border-y border-slate-100 dark:border-slate-800 text-xs mb-3">
                  <div>
                    <p className="text-slate-400 text-[10px] uppercase">Outstanding</p>
                    <p className="font-bold text-slate-800 dark:text-white">{formatCurrency(deriveOutstanding(c))}</p>
                  </div>
                  <div>
                    <p className="text-slate-400 text-[10px] uppercase">Collected</p>
                    <p className="font-bold text-slate-800 dark:text-white">{formatCurrency(c.total_collected_amount ?? 0)}</p>
                  </div>
                </div>

                <div className="flex gap-2">
                  {c.mobile_number && (
                    <a href={`tel:${c.mobile_number}`}
                      className="flex-1 flex items-center justify-center gap-1 py-2 bg-slate-50 dark:bg-slate-800 text-blue-600 rounded-lg font-bold text-xs">
                      <Phone size={12} /> Call
                    </a>
                  )}
                  <button
                    onClick={() => { setSelectedCase(c); router.push(`/customers/${c.id}`) }}
                    className="flex-1 py-2 bg-slate-50 dark:bg-slate-800 text-blue-600 rounded-lg font-bold text-xs">
                    Details
                  </button>
                  <button
                    onClick={() => { setSelectedCase(c); router.push('/visits/new') }}
                    className="flex-1 flex items-center justify-center gap-1 py-2 bg-blue-600 text-white rounded-lg font-bold text-xs">
                    <Car size={12} /> Visit
                  </button>
                </div>
              </div>
            )
          })}

        {!isLoading && filtered.length === 0 && (
          <div className="text-center py-16 text-slate-400">
            <Search size={40} className="mx-auto mb-3 opacity-30" />
            <p className="font-medium">No customers found</p>
            <p className="text-sm">Try adjusting your search or filters</p>
          </div>
        )}
      </div>
    </AppLayout>
  )
}
