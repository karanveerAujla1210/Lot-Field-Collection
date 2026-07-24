'use client'

import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import { getSupabaseClient } from '@/lib/supabase/client'
import type { CasePayment } from '@/types/database.types'
import type { PaymentFormData } from '@/lib/validations/payment.schema'
import { useCaseStore } from '@/stores/useCaseStore'

export function usePayments(caseId: string | null) {
  return useQuery({
    queryKey: ['payments', caseId],
    queryFn: async (): Promise<CasePayment[]> => {
      if (!caseId) return []
      const supabase = getSupabaseClient()
      const { data, error } = await supabase
        .from('case_payments')
        .select('*')
        .eq('case_id', caseId)
        .order('created_at', { ascending: false })
        .limit(20)
      if (error) throw error
      return data ?? []
    },
    enabled: !!caseId,
  })
}

interface SubmitPaymentArgs {
  formData: PaymentFormData
  caseId: string
  loanNo: string | null
  customerName: string | null
  executiveId: string
  executiveName: string
  branchName: string | null
}

export function useSubmitPayment() {
  const queryClient = useQueryClient()

  return useMutation({
    mutationFn: async (args: SubmitPaymentArgs) => {
      const supabase = getSupabaseClient()
      const receiptNumber = `RCP-${Date.now()}`
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
        receipt_number: receiptNumber,
        notes: args.formData.notes ?? `Collected on ${new Date().toISOString()}`,
      }
      const { data, error } = await supabase
        .from('case_payments')
        // eslint-disable-next-line @typescript-eslint/no-explicit-any
        .insert(payload as any)
        .select()
        .single()
      if (error) throw error
      // eslint-disable-next-line @typescript-eslint/no-explicit-any
      return { ...(data as any), receiptNumber }
    },
    onSuccess: (_, variables) => {
      queryClient.invalidateQueries({ queryKey: ['payments', variables.caseId] })
      queryClient.invalidateQueries({ queryKey: ['cases'] })
    },
  })
}
