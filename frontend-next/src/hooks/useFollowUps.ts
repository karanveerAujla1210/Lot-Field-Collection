'use client'

import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import { getSupabaseClient } from '@/lib/supabase/client'
import type { FollowUp } from '@/types/database.types'

export function useFollowUps(executiveId?: string | null) {
  return useQuery({
    queryKey: ['follow_ups', executiveId ?? 'all'],
    queryFn: async (): Promise<FollowUp[]> => {
      const supabase = getSupabaseClient()
      let query = supabase
        .from('follow_ups')
        .select('*')
        .order('follow_up_date', { ascending: true })
        .limit(100)

      if (executiveId) {
        query = query.eq('executive_id', executiveId)
      }

      const { data, error } = await query
      if (error) throw error
      return (data ?? []) as FollowUp[]
    },
    staleTime: 30_000,
  })
}

export function useCreateFollowUp() {
  const queryClient = useQueryClient()

  return useMutation({
    mutationFn: async (args: {
      caseId: string
      loanNo: string
      customerName: string
      executiveId: string
      followUpDate: string
      notes: string
    }) => {
      const supabase = getSupabaseClient()
      const { data, error } = await supabase
        .from('follow_ups')
        .insert({
          case_id: args.caseId,
          loan_no: args.loanNo,
          customer_name: args.customerName,
          executive_id: args.executiveId,
          follow_up_date: args.followUpDate,
          notes: args.notes,
          status: 'PENDING',
        })
        .select()
        .single()
      if (error) throw error
      return data as FollowUp
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['follow_ups'] })
    },
  })
}

export function useCompleteFollowUp() {
  const queryClient = useQueryClient()

  return useMutation({
    mutationFn: async (id: string) => {
      const supabase = getSupabaseClient()
      const { error } = await supabase
        .from('follow_ups')
        .update({ status: 'COMPLETED' })
        .eq('id', id)
      if (error) throw error
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['follow_ups'] })
    },
  })
}
