'use client'

import { useQuery } from '@tanstack/react-query'
import { getSupabaseClient } from '@/lib/supabase/client'
import type { StaffUser } from '@/types/database.types'

export function useStaff() {
  return useQuery({
    queryKey: ['staff'],
    queryFn: async (): Promise<StaffUser[]> => {
      const supabase = getSupabaseClient()
      const { data, error } = await supabase
        .from('users')
        .select('*')
        .order('created_at', { ascending: false })
      if (error) throw error
      return data ?? []
    },
    staleTime: 60_000,
  })
}
