'use client'

import Link from 'next/link'
import { usePathname, useRouter } from 'next/navigation'
import {
  LayoutDashboard, Users, MapPin, FolderOpen, BarChart3,
  Badge, Settings, LogOut, Send, ChevronRight,
} from 'lucide-react'
import { cn } from '@/lib/utils/cn'
import { getSupabaseClient } from '@/lib/supabase/client'
import { useAuthStore } from '@/stores/useAuthStore'
import { toast } from 'sonner'

const navItems = [
  { href: '/dashboard/admin', label: 'Dashboard', icon: LayoutDashboard },
  { href: '/staff', label: 'Staff Management', icon: Badge },
  { href: '/monitoring', label: 'Live Monitoring', icon: MapPin },
  { href: '/portfolio', label: 'Portfolio Manager', icon: FolderOpen },
  { href: '/reports', label: 'Reports & Analytics', icon: BarChart3 },
]

export function Sidebar() {
  const pathname = usePathname()
  const router = useRouter()
  const { user, clear } = useAuthStore()

  const handleLogout = async () => {
    const supabase = getSupabaseClient()
    await supabase.auth.signOut()
    clear()
    toast.success('Logged out successfully')
    router.push('/login')
  }

  return (
    <aside className="h-screen w-64 fixed left-0 top-0 bg-white dark:bg-slate-900 border-r border-slate-200 dark:border-slate-800 flex flex-col py-6 z-50">
      {/* Brand */}
      <div className="px-4 mb-8">
        <div className="flex items-center gap-2 mb-1">
          <div className="w-8 h-8 rounded-lg bg-blue-600 flex items-center justify-center">
            <span className="text-white font-bold text-sm">FC</span>
          </div>
          <h1 className="font-bold text-base text-blue-700 dark:text-blue-400 leading-tight">
            LOT Field Collection
          </h1>
        </div>
        <p className="text-xs text-slate-500 ml-10">Loan Recovery Master</p>
      </div>

      {/* Navigation */}
      <nav className="flex-1 space-y-1 px-2 overflow-y-auto">
        {navItems.map(({ href, label, icon: Icon }) => {
          const active = pathname === href || pathname.startsWith(href + '/')
          return (
            <Link
              key={href}
              href={href}
              className={cn(
                'flex items-center gap-3 px-3 py-2.5 rounded-lg text-sm font-medium transition-all duration-150',
                active
                  ? 'bg-blue-50 dark:bg-blue-950 text-blue-700 dark:text-blue-400'
                  : 'text-slate-600 dark:text-slate-400 hover:bg-slate-100 dark:hover:bg-slate-800'
              )}
            >
              <Icon size={18} />
              <span className="flex-1">{label}</span>
              {active && <ChevronRight size={14} className="opacity-60" />}
            </Link>
          )
        })}
      </nav>

      {/* Footer */}
      <div className="px-2 mt-4 pt-4 border-t border-slate-200 dark:border-slate-800 space-y-1">
        <button className="w-full flex items-center justify-center gap-2 py-2.5 bg-blue-600 hover:bg-blue-700 text-white rounded-xl text-sm font-bold transition-colors shadow-sm">
          <Send size={16} />
          Distribute Cases
        </button>
        <Link href="/profile" className="flex items-center gap-3 px-3 py-2 text-slate-500 hover:bg-slate-100 dark:hover:bg-slate-800 rounded-lg text-sm transition-colors">
          <Settings size={16} /> Settings
        </Link>
        <button onClick={handleLogout} className="w-full flex items-center gap-3 px-3 py-2 text-red-500 hover:bg-red-50 dark:hover:bg-red-950/20 rounded-lg text-sm transition-colors">
          <LogOut size={16} /> Logout
        </button>
        {/* User avatar */}
        <div className="flex items-center gap-3 px-3 pt-2">
          <div className="w-8 h-8 rounded-full bg-blue-100 dark:bg-blue-900 flex items-center justify-center text-blue-700 font-bold text-sm">
            {user?.email?.[0]?.toUpperCase() ?? 'A'}
          </div>
          <div>
            <p className="text-xs font-bold text-slate-800 dark:text-slate-200 truncate max-w-[120px]">{user?.email ?? 'Admin'}</p>
            <p className="text-[10px] text-slate-500">Super Admin</p>
          </div>
        </div>
      </div>
    </aside>
  )
}
