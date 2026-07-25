'use client'

import { create } from 'zustand'
import { persist } from 'zustand/middleware'
import type { OfflineQueueItem } from '@/types/database.types'

interface OfflineQueueState {
  queue: OfflineQueueItem[]
  enqueue: (item: Omit<OfflineQueueItem, 'id' | 'createdAt' | 'retryCount'>) => void
  dequeue: (id: string) => void
  incrementRetry: (id: string) => void
  clearFailed: () => void
  pendingCount: () => number
}

export const useOfflineQueue = create<OfflineQueueState>()(
  persist(
    (set, get) => ({
      queue: [],

      enqueue: (item) =>
        set((state) => ({
          queue: [
            ...state.queue,
            {
              ...item,
              id: crypto.randomUUID(),
              createdAt: new Date().toISOString(),
              retryCount: 0,
            },
          ],
        })),

      dequeue: (id) =>
        set((state) => ({ queue: state.queue.filter((i) => i.id !== id) })),

      incrementRetry: (id) =>
        set((state) => ({
          queue: state.queue.map((i) =>
            i.id === id ? { ...i, retryCount: i.retryCount + 1 } : i
          ),
        })),

      clearFailed: () =>
        set((state) => ({ queue: state.queue.filter((i) => i.retryCount < 3) })),

      pendingCount: () => get().queue.length,
    }),
    { name: 'lot-offline-queue' }
  )
)
