'use client'

import { create } from 'zustand'
import { persist } from 'zustand/middleware'
import type { User, Session } from '@supabase/supabase-js'

interface AuthState {
  user: User | null
  session: Session | null
  role: 'super_admin' | 'admin' | 'executive' | null
  isLoading: boolean
  setUser: (user: User | null) => void
  setSession: (session: Session | null) => void
  setRole: (role: 'super_admin' | 'admin' | 'executive' | null) => void
  setLoading: (loading: boolean) => void
  clear: () => void
}

export const useAuthStore = create<AuthState>()(
  persist(
    (set) => ({
      user: null,
      session: null,
      role: null,
      isLoading: true,
      setUser: (user) => set({ user }),
      setSession: (session) => set({ session, user: session?.user ?? null }),
      setRole: (role) => set({ role }),
      setLoading: (isLoading) => set({ isLoading }),
      clear: () => set({ user: null, session: null, role: null, isLoading: false }),
    }),
    {
      name: 'lot-auth-store',
      partialize: (state) => ({ role: state.role, user: state.user }),
    }
  )
)
