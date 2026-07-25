'use client'

import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import { useAuthStore } from '@/stores/useAuthStore'
import { useSyncStore } from '@/stores/useSyncStore'
import { useOfflineQueue } from '@/stores/useOfflineQueue'
import { PaymentRepository } from '@/lib/repositories/PaymentRepository'
import { useAuditLog } from '@/hooks/useAuditLog'
import type { CasePayment } from '@/types/database.types'
import type { PaymentFormData } from '@/lib/validations/payment.schema'

export function usePayments(caseId: string | null) {
  return useQuery({
    queryKey: ['payments', caseId],
    queryFn: () => PaymentRepository.findByCaseId(caseId!),
    enabled: !!caseId,
  })
}

export interface CollectionTrendPoint { month: string; amount: number }

export function useCollectionTrend() {
  return useQuery({
    queryKey: ['payments', 'collection-trend'],
    queryFn: async (): Promise<CollectionTrendPoint[]> => {
      const data = await PaymentRepository.findAll()
      const formatter = new Intl.DateTimeFormat('en-IN', { month: 'short', year: '2-digit' })
      const totals = new Map<string, number>()
      for (const p of data) {
        if (!p.created_at) continue
        const label = formatter.format(new Date(p.created_at))
        totals.set(label, (totals.get(label) ?? 0) + Number(p.amount_paid ?? 0))
      }
      return Array.from(totals, ([month, amount]) => ({ month, amount })).slice(-12)
    },
    staleTime: 30_000,
  })
}

export interface SubmitPaymentArgs {
  formData: PaymentFormData
  caseId: string
  loanNo: string
  customerName: string
  executiveId: string
  executiveName: string
  branchName: string | null
}

export function useSubmitPayment() {
  const queryClient = useQueryClient()
  const { isOnline } = useSyncStore()
  const { enqueue } = useOfflineQueue()
  const { log } = useAuditLog()
  const { user } = useAuthStore()

  return useMutation({
    mutationFn: async (args: SubmitPaymentArgs): Promise<(CasePayment & { receiptNumber: string }) | null> => {
      let reference: string | null = null
      if (args.formData.paymentMode === 'UPI') reference = args.formData.referenceUpi ?? null
      if (args.formData.paymentMode === 'CHEQUE') reference = args.formData.referenceCheque ?? null
      if (args.formData.paymentMode === 'NEFT') reference = args.formData.referenceNeft ?? null

      const payload = {
        case_id: args.caseId,
        loan_no: args.loanNo,
        customer_name: args.customerName,
        executive_id: args.executiveId,
        executive_name: args.executiveName,
        branch_name: args.branchName,
        amount_paid: args.formData.amount,
        payment_mode: args.formData.paymentMode,
        payment_reference: reference,
        notes: args.formData.notes ?? null,
      }

      // Offline — queue for later
      if (!isOnline) {
        enqueue({ type: 'PAYMENT', payload: payload as unknown as Record<string, unknown> })
        return null
      }

      const payment = await PaymentRepository.create(payload as Parameters<typeof PaymentRepository.create>[0])

      log('PAYMENT_CREATED', 'case_payments', payment.id, {
        caseId: args.caseId,
        loanNo: args.loanNo,
        amount: args.formData.amount,
        mode: args.formData.paymentMode,
        executiveId: user?.id,
      })

      return { ...payment, receiptNumber: payment.receipt_number }
    },
    onSuccess: (_, variables) => {
      queryClient.invalidateQueries({ queryKey: ['payments', variables.caseId] })
      queryClient.invalidateQueries({ queryKey: ['cases'] })
    },
  })
}
