'use client'

import { create } from 'zustand'
import { persist } from 'zustand/middleware'
import type { CaseRow } from '@/types/database.types'

interface CaseState {
  selectedCase: CaseRow | null
  casesCache: CaseRow[]
  setSelectedCase: (caseRow: CaseRow | null) => void
  setCasesCache: (cases: CaseRow[]) => void
  findCaseById: (id: string) => CaseRow | null
  clearSelectedCase: () => void
}

export const useCaseStore = create<CaseState>()(
  persist(
    (set, get) => ({
      selectedCase: null,
      casesCache: [],
      setSelectedCase: (selectedCase) => set({ selectedCase }),
      setCasesCache: (casesCache) => set({ casesCache }),
      findCaseById: (id) =>
        get().casesCache.find((c) => c.id === id) ?? null,
      clearSelectedCase: () => set({ selectedCase: null }),
    }),
    {
      name: 'lot-selected-case',
      partialize: (state) => ({ selectedCase: state.selectedCase }),
    }
  )
)
