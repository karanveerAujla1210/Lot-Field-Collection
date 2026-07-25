'use client'

import { create } from 'zustand'

interface SyncState {
  lastSynced: Date | null
  isOnline: boolean
  isSyncing: boolean
  pendingCount: number
  setLastSynced: (date: Date) => void
  setOnline: (online: boolean) => void
  setSyncing: (syncing: boolean) => void
  setPendingCount: (count: number) => void
  initOnlineListener: () => () => void
}

export const useSyncStore = create<SyncState>()((set) => ({
  lastSynced: null,
  isOnline: typeof navigator !== 'undefined' ? navigator.onLine : true,
  isSyncing: false,
  pendingCount: 0,
  setLastSynced: (lastSynced) => set({ lastSynced }),
  setOnline: (isOnline) => set({ isOnline }),
  setSyncing: (isSyncing) => set({ isSyncing }),
  setPendingCount: (pendingCount) => set({ pendingCount }),
  initOnlineListener: () => {
    const onOnline = () => set({ isOnline: true })
    const onOffline = () => set({ isOnline: false })
    window.addEventListener('online', onOnline)
    window.addEventListener('offline', onOffline)
    return () => {
      window.removeEventListener('online', onOnline)
      window.removeEventListener('offline', onOffline)
    }
  },
}))
