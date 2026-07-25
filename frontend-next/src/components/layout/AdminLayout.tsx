'use client'

import { useEffect } from 'react'
import { Skeleton } from '@/components/ui/skeleton'
import { useRouter } from 'next/navigation'
import { Sidebar } from './Sidebar'
import { useAuthStore } from '@/stores/useAuthStore'
import { isAdminRole } from '@/lib/auth/roles'

export function AdminLayout({ children }: { children: React.ReactNode }) {
  const router = useRouter()
  const { role, isLoading } = useAuthStore()

  useEffect(() => {
    if (!isLoading && !isAdminRole(role)) router.replace('/dashboard')
  }, [isLoading, role, router])

  if (isLoading) {
    return (
      <div className="min-h-screen bg-slate-50 dark:bg-slate-950 flex">
        <div className="w-64 h-screen bg-white dark:bg-slate-900 border-r border-slate-200 dark:border-slate-800" />
        <main className="ml-64 flex-1 p-6 space-y-4">
          <Skeleton className="h-10 w-64 rounded-xl" />
          <Skeleton className="h-32 rounded-xl" />
          <Skeleton className="h-64 rounded-xl" />
        </main>
      </div>
    )
  }

  if (!isAdminRole(role)) return null

  return (
    <div className="min-h-screen bg-slate-50 dark:bg-slate-950 flex">
      <Sidebar />
      <main className="ml-64 flex-1 min-h-screen overflow-auto">
        {children}
      </main>
    </div>
  )
}
