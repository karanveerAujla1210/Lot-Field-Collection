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
}

export const useSyncStore = create<SyncState>()((set) => ({
  lastSynced: null,
  isOnline: true,
  isSyncing: false,
  pendingCount: 0,
  setLastSynced: (lastSynced) => set({ lastSynced }),
  setOnline: (isOnline) => set({ isOnline }),
  setSyncing: (isSyncing) => set({ isSyncing }),
  setPendingCount: (pendingCount) => set({ pendingCount }),
}))
