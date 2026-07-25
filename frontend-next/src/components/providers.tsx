'use client'

import { QueryClient, QueryClientProvider } from '@tanstack/react-query'
import { ThemeProvider } from 'next-themes'
import { Toaster } from 'sonner'
import { useState, useEffect } from 'react'
import { getSupabaseClient } from '@/lib/supabase/client'
import { useAuthStore } from '@/stores/useAuthStore'
import { useSyncStore } from '@/stores/useSyncStore'
import { toAppRole } from '@/lib/auth/roles'

type RoleProfile = { roles: { code: string } | null }

async function loadRole(userId: string) {
  const { data } = await getSupabaseClient()
    .from('users')
    .select('roles(code)')
    .eq('id', userId)
    .single()
  return toAppRole((data as { roles?: { code: string } } | null)?.roles?.code)
}

function AuthRehydrator() {
  const { setSession, setRole, setLoading } = useAuthStore()
  const { initOnlineListener } = useSyncStore()

  useEffect(() => {
    const supabase = getSupabaseClient()

    // Rehydrate session from Supabase on mount
    supabase.auth.getSession().then(async ({ data: { session } }) => {
      setSession(session)
      if (session?.user) {
        setRole(await loadRole(session.user.id))
      }
      setLoading(false)
    })

    // Listen for auth state changes
    const { data: { subscription } } = supabase.auth.onAuthStateChange(async (_event, session) => {
      setSession(session)
      if (session?.user) {
        setRole(await loadRole(session.user.id))
      } else {
        setRole(null)
      }
      setLoading(false)
    })

    // Wire up online/offline detection
    const cleanupOnline = initOnlineListener()

    return () => {
      subscription.unsubscribe()
      cleanupOnline()
    }
  }, [setSession, setRole, setLoading, initOnlineListener])

  return null
}

export function Providers({ children }: { children: React.ReactNode }) {
  const [queryClient] = useState(
    () =>
      new QueryClient({
        defaultOptions: {
          queries: {
            staleTime: 30_000,
            retry: 2,
          },
        },
      })
  )

  return (
    <QueryClientProvider client={queryClient}>
      <ThemeProvider attribute="class" defaultTheme="light" enableSystem={false}>
        <AuthRehydrator />
        {children}
        <Toaster
          position="bottom-right"
          richColors
          closeButton
          toastOptions={{ duration: 4000 }}
        />
      </ThemeProvider>
    </QueryClientProvider>
  )
}
