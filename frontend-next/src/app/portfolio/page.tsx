'use client'

import { AdminLayout } from '@/components/layout/AdminLayout'
import { useCases } from '@/hooks/useCases'
import { formatCurrency } from '@/lib/utils/currency'
import { deriveOutstanding, RISK_CONFIG, deriveRisk } from '@/lib/utils/risk'
import { Skeleton } from '@/components/ui/skeleton'
import { Badge } from '@/components/ui/badge'
import { useCaseStore } from '@/stores/useCaseStore'
import { useRouter } from 'next/navigation'
import { Briefcase } from 'lucide-react'

export default function PortfolioPage() {
  const { data: cases = [], isLoading } = useCases()
  const { setSelectedCase } = useCaseStore()
  const router = useRouter()

  // Group by branch
  const byBranch = cases.reduce((acc: Record<string, typeof cases>, c) => {
    const b = c.branch_name ?? c.state_name ?? 'Unknown'
    if (!acc[b]) acc[b] = []
    acc[b].push(c)
    return acc
  }, {})

  return (
    <AdminLayout>
      <div className="min-h-screen">
        <header className="sticky top-0 h-16 bg-white dark:bg-slate-900 border-b border-slate-200 dark:border-slate-800 flex items-center px-6 z-40">
          <div>
            <h1 className="font-bold text-slate-900 dark:text-white text-lg">Portfolio Manager</h1>
            <p className="text-xs text-slate-500">{cases.length} cases across {Object.keys(byBranch).length} branches</p>
          </div>
        </header>

        <div className="p-6 max-w-7xl mx-auto space-y-6">
          {isLoading ? (
            Array.from({ length: 3 }).map((_, i) => <Skeleton key={i} className="h-40 rounded-xl" />)
          ) : (
            Object.entries(byBranch).map(([branch, branchCases]) => (
              <div key={branch} className="bg-white dark:bg-slate-900 rounded-xl border border-slate-200 dark:border-slate-800 shadow-sm overflow-hidden">
                <div className="flex justify-between items-center px-5 py-3 bg-slate-50 dark:bg-slate-800 border-b border-slate-200 dark:border-slate-700">
                  <div className="flex items-center gap-2">
                    <Briefcase size={16} className="text-blue-600" />
                    <h3 className="font-semibold text-slate-800 dark:text-slate-200">{branch}</h3>
                  </div>
                  <span className="text-xs text-slate-500">{branchCases.length} cases</span>
                </div>
                <div className="divide-y divide-slate-100 dark:divide-slate-800">
                  {branchCases.slice(0, 5).map(c => {
                    const risk = deriveRisk(c)
                    return (
                      <div key={c.id}
                        className="flex items-center justify-between px-5 py-3 hover:bg-slate-50 dark:hover:bg-slate-800/40 cursor-pointer transition-colors"
                        onClick={() => { setSelectedCase(c); router.push(`/customers/${c.id}`) }}>
                        <div>
                          <p className="font-medium text-sm text-slate-800 dark:text-slate-200">{c.customer_name}</p>
                          <p className="text-xs text-slate-400">{c.loan_no}</p>
                        </div>
                        <div className="flex items-center gap-3">
                          <p className="font-bold text-sm text-emerald-600">{formatCurrency(deriveOutstanding(c))}</p>
                          <Badge className={`text-[10px] ${RISK_CONFIG[risk].className}`}>{risk}</Badge>
                        </div>
                      </div>
                    )
                  })}
                  {branchCases.length > 5 && (
                    <div className="px-5 py-2 text-xs text-blue-600 font-medium text-center">
                      +{branchCases.length - 5} more cases
                    </div>
                  )}
                </div>
              </div>
            ))
          )}
        </div>
      </div>
    </AdminLayout>
  )
}
