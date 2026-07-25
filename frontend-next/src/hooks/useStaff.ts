'use client'

import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
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
      return (data ?? []) as StaffUser[]
    },
    staleTime: 60_000,
  })
}

interface CreateStaffArgs {
  email: string
  password: string
  fullName: string
  phone: string
  role: 'admin' | 'executive'
  branchName: string
}

export function useCreateStaff() {
  const queryClient = useQueryClient()

  return useMutation({
    mutationFn: async (args: CreateStaffArgs) => {
      const supabase = getSupabaseClient()
      // Delegate to Edge Function — auth.admin requires service role key
      // which must never be exposed in the browser
      const { data, error } = await supabase.functions.invoke('create-staff', {
        body: args,
      })
      if (error) throw error
      return data as StaffUser
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['staff'] })
    },
  })
}

export function useToggleStaffStatus() {
  const queryClient = useQueryClient()

  return useMutation({
    mutationFn: async ({ id, isActive }: { id: string; isActive: boolean }) => {
      const supabase = getSupabaseClient()
      const { error } = await supabase
        .from('users')
        .update({ is_active: isActive })
        .eq('id', id)
      if (error) throw error
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['staff'] })
    },
  })
}
