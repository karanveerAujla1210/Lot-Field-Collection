'use client'

import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import { useAuthStore } from '@/stores/useAuthStore'
import { useSyncStore } from '@/stores/useSyncStore'
import { useOfflineQueue } from '@/stores/useOfflineQueue'
import { VisitRepository } from '@/lib/repositories/VisitRepository'
import { useAuditLog } from '@/hooks/useAuditLog'
import type { CaseVisit } from '@/types/database.types'
import type { VisitFormData } from '@/lib/validations/visit.schema'

export function useVisits(caseId: string | null) {
  return useQuery({
    queryKey: ['visits', caseId],
    queryFn: () => VisitRepository.findByCaseId(caseId!),
    enabled: !!caseId,
  })
}

export interface SubmitVisitArgs {
  formData: VisitFormData
  caseId: string
  loanNo: string
  customerName: string
  executiveId: string
  executiveName: string
  branchName: string | null
  latitude: number
  longitude: number
  photos: File[]
}

export function useSubmitVisit() {
  const queryClient = useQueryClient()
  const { isOnline } = useSyncStore()
  const { enqueue } = useOfflineQueue()
  const { log } = useAuditLog()
  const { user } = useAuthStore()

  return useMutation({
    mutationFn: async (args: SubmitVisitArgs): Promise<CaseVisit | null> => {
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
        photos_urls: [] as string[],
      }

      // Offline — queue for later
      if (!isOnline) {
        enqueue({ type: 'VISIT', payload: payload as unknown as Record<string, unknown> })
        return null
      }

      const photosUrls = await VisitRepository.uploadPhotos(args.caseId, args.photos)
      const visit = await VisitRepository.create({ ...payload, photos_urls: photosUrls })

      log('VISIT_CREATED', 'case_visits', visit.id, {
        caseId: args.caseId,
        loanNo: args.loanNo,
        visitStatus: args.formData.visitStatus,
        executiveId: user?.id,
      })

      return visit
    },
    onSuccess: (_, variables) => {
      queryClient.invalidateQueries({ queryKey: ['visits', variables.caseId] })
      queryClient.invalidateQueries({ queryKey: ['cases'] })
    },
  })
}
