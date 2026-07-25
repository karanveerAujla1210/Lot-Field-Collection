'use client'

import { useEffect } from 'react'
import { useQueryClient } from '@tanstack/react-query'
import { getSupabaseClient } from '@/lib/supabase/client'
import { useAuthStore } from '@/stores/useAuthStore'
import { useSyncStore } from '@/stores/useSyncStore'
import { isAdminRole } from '@/lib/auth/roles'

export function useRealtimeSync() {
  const queryClient = useQueryClient()
  const { setLastSynced } = useSyncStore()
  const { user, role } = useAuthStore()

  useEffect(() => {
    if (!user) return
    const supabase = getSupabaseClient()
    const isAdmin = isAdminRole(role)

    // Admins listen to all rows; executives filter to their assigned cases
    const casesFilter = isAdmin ? undefined : `assigned_executive_id=eq.${user.id}`
    const visitsFilter = isAdmin ? undefined : `executive_id=eq.${user.id}`
    const paymentsFilter = isAdmin ? undefined : `executive_id=eq.${user.id}`

    const channel = supabase
      .channel('lot-field-collection-live')
      .on('postgres_changes', {
        event: '*', schema: 'public', table: 'cases',
        ...(casesFilter ? { filter: casesFilter } : {}),
      }, () => {
        queryClient.invalidateQueries({ queryKey: ['cases'] })
        setLastSynced(new Date())
      })
      .on('postgres_changes', {
        event: '*', schema: 'public', table: 'case_payments',
        ...(paymentsFilter ? { filter: paymentsFilter } : {}),
      }, () => {
        queryClient.invalidateQueries({ queryKey: ['payments'] })
        queryClient.invalidateQueries({ queryKey: ['cases'] })
        setLastSynced(new Date())
      })
      .on('postgres_changes', {
        event: '*', schema: 'public', table: 'case_visits',
        ...(visitsFilter ? { filter: visitsFilter } : {}),
      }, () => {
        queryClient.invalidateQueries({ queryKey: ['visits'] })
        setLastSynced(new Date())
      })
      .subscribe()

    return () => {
      supabase.removeChannel(channel)
    }
  }, [queryClient, setLastSynced, user, role])
}
