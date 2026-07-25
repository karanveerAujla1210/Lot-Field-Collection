'use client'

import { useQuery, useQueryClient } from '@tanstack/react-query'
import { getSupabaseClient } from '@/lib/supabase/client'
import { useAuthStore } from '@/stores/useAuthStore'
import { isAdminRole } from '@/lib/auth/roles'
import type { CaseRow } from '@/types/database.types'

export const CASES_QUERY_KEY = ['cases'] as const

export function useCases() {
  const { user, role } = useAuthStore()

  return useQuery({
    queryKey: [...CASES_QUERY_KEY, user?.id, role],
    queryFn: async (): Promise<CaseRow[]> => {
      const supabase = getSupabaseClient()
      let query = supabase
        .from('cases')
        .select('*')
        .order('due_days', { ascending: false })
        .limit(500)

      // Executives only see their assigned cases
      if (!isAdminRole(role) && user?.id) {
        query = query.eq('assigned_executive_id', user.id)
      }

      const { data, error } = await query
      if (error) throw error
      return data ?? []
    },
    enabled: !!user,
    staleTime: 30_000,
    refetchInterval: 60_000,
  })
}

export function useCase(id: string | null) {
  const queryClient = useQueryClient()

  return useQuery({
    queryKey: ['cases', id],
    queryFn: async (): Promise<CaseRow | null> => {
      if (!id) return null

      // Try cache first before hitting DB
      const cached = queryClient.getQueryData<CaseRow[]>(CASES_QUERY_KEY)
      if (cached) {
        const found = cached.find((c) => c.id === id)
        if (found) return found
      }

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
