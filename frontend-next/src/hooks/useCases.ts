'use client'

import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import { getSupabaseClient } from '@/lib/supabase/client'
import type { CaseRow } from '@/types/database.types'
import { useCaseStore } from '@/stores/useCaseStore'

export const CASES_QUERY_KEY = ['cases'] as const

export function useCases() {
  const { setCasesCache, setSelectedCase, selectedCase, findCaseById } = useCaseStore()

  return useQuery({
    queryKey: CASES_QUERY_KEY,
    queryFn: async (): Promise<CaseRow[]> => {
      const supabase = getSupabaseClient()
      const { data, error } = await supabase
        .from('cases')
        .select('*')
        .order('due_days', { ascending: false })
        .limit(500)
      if (error) throw error
      const cases = data ?? []
      setCasesCache(cases)
      // Auto-select first case if none selected
      if (!selectedCase && cases.length > 0) {
        setSelectedCase(cases[0])
      } else if (selectedCase) {
        const refreshed = findCaseById(selectedCase.id)
        if (refreshed) setSelectedCase(refreshed)
      }
      return cases
    },
    staleTime: 30_000,
    refetchInterval: 60_000,
  })
}

export function useCase(id: string | null) {
  return useQuery({
    queryKey: ['cases', id],
    queryFn: async (): Promise<CaseRow | null> => {
      if (!id) return null
      const supabase = getSupabaseClient()
      const { data, error } = await supabase
        .from('cases')
        .select('*')
        .eq('id', id)
        .single()
      if (error) throw error
      return data
    },
    enabled: !!id,
  })
}
