'use client'

import { useEffect, useRef } from 'react'
import { useQueryClient } from '@tanstack/react-query'
import { useSyncStore } from '@/stores/useSyncStore'
import { useOfflineQueue } from '@/stores/useOfflineQueue'
import { useAuthStore } from '@/stores/useAuthStore'
import { VisitRepository } from '@/lib/repositories/VisitRepository'
import { PaymentRepository } from '@/lib/repositories/PaymentRepository'
import { toast } from 'sonner'
import type { CreateVisitPayload } from '@/lib/repositories/VisitRepository'
import type { CreatePaymentPayload } from '@/lib/repositories/PaymentRepository'

const MAX_RETRIES = 3
const FLUSH_INTERVAL_MS = 30_000

export function useBackgroundSync() {
  const queryClient = useQueryClient()
  const { isOnline, setLastSynced, setSyncing } = useSyncStore()
  const { queue, dequeue, incrementRetry, clearFailed } = useOfflineQueue()
  const { user } = useAuthStore()
  const isFlushing = useRef(false)

  const flushQueue = async () => {
    if (isFlushing.current || !isOnline || queue.length === 0 || !user) return
    isFlushing.current = true
    setSyncing(true)

    let successCount = 0
    let failCount = 0

    for (const item of queue) {
      if (item.retryCount >= MAX_RETRIES) continue
      try {
        if (item.type === 'VISIT') {
          await VisitRepository.create(item.payload as unknown as CreateVisitPayload)
        } else if (item.type === 'PAYMENT') {
          await PaymentRepository.create(item.payload as unknown as CreatePaymentPayload)
        }
        dequeue(item.id)
        successCount++
      } catch {
        incrementRetry(item.id)
        failCount++
      }
    }

    clearFailed()

    if (successCount > 0) {
      queryClient.invalidateQueries({ queryKey: ['cases'] })
      queryClient.invalidateQueries({ queryKey: ['visits'] })
      queryClient.invalidateQueries({ queryKey: ['payments'] })
      setLastSynced(new Date())
      toast.success(`Synced ${successCount} offline record${successCount > 1 ? 's' : ''}`)
    }
    if (failCount > 0) {
      toast.error(`${failCount} record${failCount > 1 ? 's' : ''} failed to sync`)
    }

    setSyncing(false)
    isFlushing.current = false
  }

  // Flush immediately when coming back online
  useEffect(() => {
    if (isOnline && queue.length > 0) {
      flushQueue()
    }
  // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [isOnline])

  // Periodic flush every 30s while online
  useEffect(() => {
    if (!isOnline) return
    const interval = setInterval(flushQueue, FLUSH_INTERVAL_MS)
    return () => clearInterval(interval)
  // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [isOnline, queue.length])

  return { pendingCount: queue.length, flushQueue }
}
