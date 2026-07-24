'use client'

import { useEffect } from 'react'
import { useQueryClient } from '@tanstack/react-query'
import { getSupabaseClient } from '@/lib/supabase/client'
import { useSyncStore } from '@/stores/useSyncStore'

export function useRealtimeSync() {
  const queryClient = useQueryClient()
  const { setLastSynced } = useSyncStore()

  useEffect(() => {
    const supabase = getSupabaseClient()
    const channel = supabase
      .channel('lot-field-collection-live')
      .on('postgres_changes', { event: '*', schema: 'public', table: 'cases' }, () => {
        queryClient.invalidateQueries({ queryKey: ['cases'] })
        setLastSynced(new Date())
      })
      .on('postgres_changes', { event: '*', schema: 'public', table: 'case_payments' }, () => {
        queryClient.invalidateQueries({ queryKey: ['payments'] })
        queryClient.invalidateQueries({ queryKey: ['cases'] })
        setLastSynced(new Date())
      })
      .on('postgres_changes', { event: '*', schema: 'public', table: 'case_visits' }, () => {
        queryClient.invalidateQueries({ queryKey: ['visits'] })
        setLastSynced(new Date())
      })
      .subscribe()

    return () => {
      supabase.removeChannel(channel)
    }
  }, [queryClient, setLastSynced])
}
