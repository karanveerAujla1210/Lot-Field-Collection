'use client'

import { useForm } from 'react-hook-form'
import { zodResolver } from '@hookform/resolvers/zod'
import { AppLayout } from '@/components/layout/AppLayout'
import { useCaseStore } from '@/stores/useCaseStore'
import { useAuthStore } from '@/stores/useAuthStore'
import { useSubmitPayment } from '@/hooks/usePayments'
import { paymentSchema, type PaymentFormData } from '@/lib/validations/payment.schema'
import { formatCurrency } from '@/lib/utils/currency'
import { deriveOutstanding, deriveEmi } from '@/lib/utils/risk'
import { toast } from 'sonner'
import { useRouter } from 'next/navigation'
import { ArrowLeft, Loader2 } from 'lucide-react'

const PAYMENT_MODES = [
  { value: 'CASH', label: '💵 Cash', color: 'bg-emerald-50 border-emerald-400 text-emerald-700' },
  { value: 'UPI', label: '📱 UPI', color: 'bg-purple-50 border-purple-400 text-purple-700' },
  { value: 'CHEQUE', label: '🏦 Cheque', color: 'bg-blue-50 border-blue-400 text-blue-700' },
  { value: 'NEFT', label: '🔄 NEFT', color: 'bg-orange-50 border-orange-400 text-orange-700' },
]

export default function NewPaymentPage() {
  const router = useRouter()
  const { selectedCase } = useCaseStore()
  const { user } = useAuthStore()
  const submitPayment = useSubmitPayment()

  const outstanding = selectedCase ? deriveOutstanding(selectedCase) : 0
  const emi = selectedCase ? deriveEmi(selectedCase) : 0
  const suggested = Math.max(Math.round(Math.min(outstanding, emi)), 1)

  const { register, handleSubmit, formState: { errors }, watch } = useForm<PaymentFormData>({
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    resolver: zodResolver(paymentSchema) as any,
    defaultValues: { amount: suggested, paymentMode: 'CASH' },
  })
  const paymentMode = watch('paymentMode')

  const onSubmit = async (data: PaymentFormData) => {
    if (!selectedCase) { toast.error('Please select a case first'); return }
    if (!user) { toast.error('Please login first'); return }

    try {
      const result = await submitPayment.mutateAsync({
        formData: data,
        caseId: selectedCase.id,
        loanNo: selectedCase.loan_no,
        customerName: selectedCase.customer_name,
        executiveId: user.id,
        executiveName: user.email ?? 'Field Executive',
        branchName: selectedCase.branch_name ?? selectedCase.state_name,
      })
      toast.success(`Payment saved! Receipt: ${result.receiptNumber}`)
      router.back()
    } catch (err: unknown) {
      toast.error(`Failed: ${err instanceof Error ? err.message : 'Unknown error'}`)
    }
  }

  if (!selectedCase) {
    return (
      <AppLayout>
        <div className="p-8 text-center">
          <p className="text-slate-500 font-medium">No case selected</p>
          <button onClick={() => router.push('/customers')} className="mt-3 text-blue-600 text-sm font-medium">← Select a customer</button>
        </div>
      </AppLayout>
    )
  }

  return (
    <AppLayout>
      <header className="sticky top-0 bg-white dark:bg-slate-900 border-b border-slate-200 dark:border-slate-800 px-4 h-14 flex items-center gap-3 z-40">
        <button onClick={() => router.back()} className="text-slate-500 hover:text-slate-800"><ArrowLeft size={20} /></button>
        <h1 className="font-bold text-slate-900 dark:text-white">Collect Payment</h1>
      </header>

      <div className="px-4 py-4 space-y-4">
        {/* Case banner */}
        <div className="bg-emerald-50 dark:bg-emerald-950 rounded-xl p-3 border border-emerald-200 dark:border-emerald-900">
          <p className="text-xs text-emerald-600 font-medium">Collecting from</p>
          <p className="font-bold text-emerald-800 dark:text-emerald-300">{selectedCase.customer_name}</p>
          <div className="flex gap-4 mt-1 text-xs text-emerald-600">
            <span>Outstanding: {formatCurrency(outstanding)}</span>
            <span>EMI: {formatCurrency(emi)}</span>
          </div>
        </div>

        <form onSubmit={handleSubmit(onSubmit)} className="space-y-4">
          {/* Amount */}
          <div className="bg-white dark:bg-slate-900 rounded-xl p-4 border border-slate-100 dark:border-slate-800">
            <label className="block text-sm font-semibold text-slate-800 dark:text-slate-200 mb-2">Amount (₹) *</label>
            <input type="number" min="1" step="1"
              className="w-full h-14 text-2xl font-bold px-4 border border-slate-200 dark:border-slate-700 rounded-xl focus:ring-2 focus:ring-emerald-100 outline-none bg-white dark:bg-slate-800"
              {...register('amount')} />
            {errors.amount && <p className="text-xs text-red-500 mt-1">{errors.amount.message}</p>}
            <p className="text-xs text-slate-400 mt-1">Suggested: {formatCurrency(suggested)}</p>
          </div>

          {/* Payment Mode */}
          <div className="bg-white dark:bg-slate-900 rounded-xl p-4 border border-slate-100 dark:border-slate-800">
            <label className="block text-sm font-semibold text-slate-800 dark:text-slate-200 mb-3">Payment Mode *</label>
            <div className="grid grid-cols-2 gap-2">
              {PAYMENT_MODES.map(({ value, label, color }) => (
                <label key={value}
                  className={`flex items-center gap-2 p-3 rounded-xl border-2 cursor-pointer transition-all ${paymentMode === value ? color : 'border-slate-200 dark:border-slate-700'}`}>
                  <input type="radio" value={value} {...register('paymentMode')} className="hidden" />
                  <span className="text-sm font-bold">{label}</span>
                </label>
              ))}
            </div>
          </div>

          {/* Reference fields */}
          {paymentMode === 'UPI' && (
            <div className="bg-white dark:bg-slate-900 rounded-xl p-4 border border-slate-100 dark:border-slate-800">
              <label className="block text-sm font-semibold text-slate-800 dark:text-slate-200 mb-2">UPI Transaction ID</label>
              <input type="text" placeholder="eg. 123456789012" {...register('referenceUpi')}
                className="w-full text-sm border border-slate-200 dark:border-slate-700 rounded-lg p-3 focus:ring-2 focus:ring-blue-100 outline-none bg-white dark:bg-slate-800" />
            </div>
          )}
          {paymentMode === 'CHEQUE' && (
            <div className="bg-white dark:bg-slate-900 rounded-xl p-4 border border-slate-100 dark:border-slate-800">
              <label className="block text-sm font-semibold text-slate-800 dark:text-slate-200 mb-2">Cheque Number</label>
              <input type="text" placeholder="eg. CHQ-001234" {...register('referenceCheque')}
                className="w-full text-sm border border-slate-200 dark:border-slate-700 rounded-lg p-3 focus:ring-2 focus:ring-blue-100 outline-none bg-white dark:bg-slate-800" />
            </div>
          )}
          {paymentMode === 'NEFT' && (
            <div className="bg-white dark:bg-slate-900 rounded-xl p-4 border border-slate-100 dark:border-slate-800">
              <label className="block text-sm font-semibold text-slate-800 dark:text-slate-200 mb-2">NEFT Reference</label>
              <input type="text" placeholder="eg. NEFT123456789" {...register('referenceNeft')}
                className="w-full text-sm border border-slate-200 dark:border-slate-700 rounded-lg p-3 focus:ring-2 focus:ring-blue-100 outline-none bg-white dark:bg-slate-800" />
            </div>
          )}

          {/* Notes */}
          <div className="bg-white dark:bg-slate-900 rounded-xl p-4 border border-slate-100 dark:border-slate-800">
            <label className="block text-sm font-semibold text-slate-800 dark:text-slate-200 mb-2">Notes (optional)</label>
            <textarea rows={2} placeholder="Additional notes..." {...register('notes')}
              className="w-full text-sm border border-slate-200 dark:border-slate-700 rounded-lg p-3 resize-none focus:ring-2 focus:ring-blue-100 outline-none bg-white dark:bg-slate-800" />
          </div>

          {/* Submit */}
          <button type="submit" disabled={submitPayment.isPending}
            className="w-full h-12 bg-emerald-600 hover:bg-emerald-700 disabled:opacity-60 disabled:cursor-not-allowed text-white font-bold rounded-xl flex items-center justify-center gap-2 transition-colors">
            {submitPayment.isPending ? <><Loader2 size={16} className="animate-spin" /> Processing...</> : '💳 Collect Payment'}
          </button>
        </form>
      </div>
    </AppLayout>
  )
}
