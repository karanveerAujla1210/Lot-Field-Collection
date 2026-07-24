'use client'

import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import { getSupabaseClient } from '@/lib/supabase/client'
import type { CaseVisit } from '@/types/database.types'
import type { VisitFormData } from '@/lib/validations/visit.schema'

export function useVisits(caseId: string | null) {
  return useQuery({
    queryKey: ['visits', caseId],
    queryFn: async (): Promise<CaseVisit[]> => {
      if (!caseId) return []
      const supabase = getSupabaseClient()
      const { data, error } = await supabase
        .from('case_visits')
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

interface SubmitVisitArgs {
  formData: VisitFormData
  caseId: string
  loanNo: string | null
  customerName: string | null
  executiveId: string
  executiveName: string
  branchName: string | null
  latitude: number
  longitude: number
}

export function useSubmitVisit() {
  const queryClient = useQueryClient()

  return useMutation({
    mutationFn: async (args: SubmitVisitArgs) => {
      const supabase = getSupabaseClient()
      const payload = {
        case_id: args.caseId,
        loan_no: args.loanNo,
        customer_name: args.customerName,
        executive_id: args.executiveId,
        executive_name: args.executiveName,
        branch_name: args.branchName,
        latitude: args.latitude,
        longitude: args.longitude,
        visit_status: args.formData.visitStatus,
        remarks: args.formData.remarks,
        promise_date: args.formData.promiseDate ?? null,
        expected_amount: args.formData.expectedAmount ?? null,
        photos_urls: [],
      }
      const { data, error } = await supabase
        .from('case_visits')
        // eslint-disable-next-line @typescript-eslint/no-explicit-any
        .insert(payload as any)
        .select()
        .single()
      if (error) throw error
      // eslint-disable-next-line @typescript-eslint/no-explicit-any
      return data as any
    },
    onSuccess: (_, variables) => {
      queryClient.invalidateQueries({ queryKey: ['visits', variables.caseId] })
      queryClient.invalidateQueries({ queryKey: ['cases'] })
    },
  })
}
