import { getApiClient, handleApiError } from '@/lib/api/client'
import type { CasePayment } from '@/types/database.types'

export type CreatePaymentPayload = Omit<CasePayment, 'id' | 'receipt_number' | 'created_at'>

export const PaymentRepository = {
  async findByCaseId(caseId: string): Promise<CasePayment[]> {
    try {
      const { data, error } = await getApiClient()
        .from('case_payments').select('*').eq('case_id', caseId)
        .order('created_at', { ascending: false }).limit(20)
      if (error) throw error
      return (data ?? []) as CasePayment[]
    } catch (e) { handleApiError(e) }
  },

  async create(payload: CreatePaymentPayload): Promise<CasePayment> {
    try {
      const { data, error } = await getApiClient()
        .from('case_payments').insert(payload).select().single()
      if (error) throw error
      if (!data) throw new Error('Payment not returned after insert')
      return data as CasePayment
    } catch (e) { handleApiError(e) }
  },

  async findAll(): Promise<Pick<CasePayment, 'amount_paid' | 'created_at'>[]> {
    try {
      const { data, error } = await getApiClient()
        .from('case_payments').select('amount_paid, created_at').order('created_at', { ascending: true })
      if (error) throw error
      return data ?? []
    } catch (e) { handleApiError(e) }
  },
}
