'use client'

import { use } from 'react'
import { useCase } from '@/hooks/useCases'
import { useVisits } from '@/hooks/useVisits'
import { usePayments } from '@/hooks/usePayments'
import { useCaseStore } from '@/stores/useCaseStore'
import { formatCurrency } from '@/lib/utils/currency'
import { deriveOutstanding, deriveEmi, deriveRisk, RISK_CONFIG, formatTimestamp } from '@/lib/utils/risk'
import { Skeleton } from '@/components/ui/skeleton'
import { Badge } from '@/components/ui/badge'
import { Tabs, TabsContent, TabsList, TabsTrigger } from '@/components/ui/tabs'
import { useRouter } from 'next/navigation'
import { Phone, MapPin, Car, CreditCard, ArrowLeft, Banknote } from 'lucide-react'

export default function CustomerDetailPage({ params }: { params: Promise<{ id: string }> }) {
  const { id } = use(params)
  const router = useRouter()
  const { setSelectedCase } = useCaseStore()
  const { data: caseRow, isLoading } = useCase(id)
  const { data: visits = [] } = useVisits(id)
  const { data: payments = [] } = usePayments(id)

  if (isLoading) {
    return (
      <div className="p-4 space-y-4">
        <Skeleton className="h-48 rounded-2xl" />
        <Skeleton className="h-32 rounded-xl" />
        <Skeleton className="h-64 rounded-xl" />
      </div>
    )
  }

  if (!caseRow) return (
    <div className="p-8 text-center text-slate-400">
      <p className="text-lg font-semibold">Case not found</p>
      <button onClick={() => router.back()} className="mt-4 text-blue-600 text-sm font-medium">← Go back</button>
    </div>
  )

  const outstanding = deriveOutstanding(caseRow)
  const emi = deriveEmi(caseRow)
  const risk = deriveRisk(caseRow)
  const address = caseRow.house_address ?? caseRow.office_address ?? `${caseRow.branch_name ?? ''}, ${caseRow.state_name ?? 'India'}`

  return (
    <>
      <header className="sticky top-0 bg-white dark:bg-slate-900 border-b border-slate-200 dark:border-slate-800 px-4 h-14 flex items-center gap-3 z-40">
        <button onClick={() => router.back()} className="text-slate-500 hover:text-slate-800">
          <ArrowLeft size={20} />
        </button>
        <h1 className="font-bold text-slate-900 dark:text-white">Customer Details</h1>
      </header>

      <div className="px-4 py-4 space-y-4">
        <div className="bg-gradient-to-br from-blue-600 to-blue-800 rounded-2xl p-5 text-white">
          <div className="flex justify-between items-start mb-4">
            <div>
              <h2 className="text-xl font-bold">{caseRow.customer_name}</h2>
              <p className="text-blue-200 text-sm">Loan: {caseRow.loan_no ?? 'N/A'}</p>
            </div>
            <Badge className={`text-[10px] ${RISK_CONFIG[risk].className}`}>{RISK_CONFIG[risk].label}</Badge>
          </div>
          <div className="grid grid-cols-2 gap-3 mb-4">
            <div className="bg-white/10 rounded-xl p-3">
              <p className="text-blue-200 text-[10px] uppercase">Outstanding</p>
              <p className="font-bold">{formatCurrency(outstanding)}</p>
            </div>
            <div className="bg-white/10 rounded-xl p-3">
              <p className="text-blue-200 text-[10px] uppercase">EMI</p>
              <p className="font-bold">{formatCurrency(emi)}</p>
            </div>
            <div className="bg-white/10 rounded-xl p-3">
              <p className="text-blue-200 text-[10px] uppercase">Collected</p>
              <p className="font-bold">{formatCurrency(caseRow.total_collected_amount ?? 0)}</p>
            </div>
            <div className="bg-white/10 rounded-xl p-3">
              <p className="text-blue-200 text-[10px] uppercase">Tenure</p>
              <p className="font-bold">{caseRow.tenure ? `${caseRow.tenure} mo` : 'N/A'}</p>
            </div>
          </div>
          <div className="flex gap-2">
            {caseRow.mobile_number && (
              <a href={`tel:${caseRow.mobile_number}`}
                className="flex-1 flex items-center justify-center gap-1.5 bg-white/20 hover:bg-white/30 rounded-xl py-2.5 text-xs font-bold transition-colors">
                <Phone size={14} /> Call
              </a>
            )}
            <button
              onClick={() => window.open(`https://www.google.com/maps/search/?api=1&query=${encodeURIComponent(address)}`, '_blank')}
              className="flex-1 flex items-center justify-center gap-1.5 bg-white/20 hover:bg-white/30 rounded-xl py-2.5 text-xs font-bold transition-colors">
              <MapPin size={14} /> Navigate
            </button>
          </div>
        </div>

        <div className="bg-white dark:bg-slate-900 rounded-xl p-4 border border-slate-100 dark:border-slate-800 space-y-2">
          <h3 className="font-semibold text-sm text-slate-800 dark:text-slate-200 mb-3">Borrower Info</h3>
          {[
            { label: 'Phone', value: caseRow.mobile_number ?? 'N/A' },
            { label: 'Address', value: address },
            { label: 'Branch', value: caseRow.branch_name ?? caseRow.state_name ?? 'N/A' },
            { label: 'Status', value: caseRow.loan_status ?? 'OPEN' },
            { label: 'Overdue', value: caseRow.due_days ? `${caseRow.due_days} days` : 'N/A' },
            { label: 'Bucket', value: caseRow.bucket ?? 'Open' },
          ].map(({ label, value }) => (
            <div key={label} className="flex justify-between text-sm">
              <span className="text-slate-500">{label}</span>
              <span className="font-medium text-slate-800 dark:text-slate-200 text-right max-w-[200px]">{value}</span>
            </div>
          ))}
        </div>

        <Tabs defaultValue="visits">
          <TabsList className="w-full">
            <TabsTrigger value="visits" className="flex-1">Visits ({visits.length})</TabsTrigger>
            <TabsTrigger value="payments" className="flex-1">Payments ({payments.length})</TabsTrigger>
          </TabsList>
          <TabsContent value="visits" className="space-y-3 mt-3">
            {visits.length === 0 ? (
              <p className="text-center text-sm text-slate-400 py-8">No visits recorded yet</p>
            ) : visits.map(v => (
              <div key={v.id} className="bg-white dark:bg-slate-900 rounded-xl p-3 border border-slate-100 dark:border-slate-800 flex gap-3">
                <div className="w-8 h-8 rounded-full bg-blue-100 flex items-center justify-center shrink-0 mt-0.5">
                  <Car size={14} className="text-blue-600" />
                </div>
                <div className="flex-1 min-w-0">
                  <div className="flex justify-between items-start">
                    <p className="font-semibold text-sm text-slate-800 dark:text-slate-200">{v.visit_status.replace(/_/g, ' ')}</p>
                    <span className="text-[10px] text-slate-400">{formatTimestamp(v.created_at)}</span>
                  </div>
                  <p className="text-xs text-slate-500 mt-0.5 truncate">{v.remarks}</p>
                  <p className="text-xs text-blue-600 mt-0.5">{v.executive_name}</p>
                </div>
              </div>
            ))}
          </TabsContent>
          <TabsContent value="payments" className="space-y-3 mt-3">
            {payments.length === 0 ? (
              <p className="text-center text-sm text-slate-400 py-8">No payments recorded yet</p>
            ) : payments.map(p => (
              <div key={p.id} className="bg-white dark:bg-slate-900 rounded-xl p-3 border border-slate-100 dark:border-slate-800 flex gap-3">
                <div className="w-8 h-8 rounded-full bg-emerald-100 flex items-center justify-center shrink-0 mt-0.5">
                  <Banknote size={14} className="text-emerald-600" />
                </div>
                <div className="flex-1 min-w-0">
                  <div className="flex justify-between items-start">
                    <p className="font-semibold text-sm text-emerald-700">{formatCurrency(p.amount_paid)}</p>
                    <span className="text-[10px] text-slate-400">{formatTimestamp(p.created_at)}</span>
                  </div>
                  <p className="text-xs text-slate-500 mt-0.5">{p.payment_mode} · {p.receipt_number}</p>
                  <p className="text-xs text-blue-600 mt-0.5">{p.executive_name}</p>
                </div>
              </div>
            ))}
          </TabsContent>
        </Tabs>

        <div className="flex gap-3 pb-4">
          <button onClick={() => { setSelectedCase(caseRow); router.push('/visits/new') }}
            className="flex-1 flex items-center justify-center gap-2 py-3 bg-slate-100 dark:bg-slate-800 text-slate-800 dark:text-slate-200 rounded-xl font-bold text-sm">
            <Car size={16} /> New Visit
          </button>
          <button onClick={() => { setSelectedCase(caseRow); router.push('/payments/new') }}
            className="flex-1 flex items-center justify-center gap-2 py-3 bg-blue-600 text-white rounded-xl font-bold text-sm">
            <CreditCard size={16} /> Collect Payment
          </button>
        </div>
      </div>
    </>
  )
}
