'use client'

import { useAuthStore } from '@/stores/useAuthStore'
import { useSyncStore } from '@/stores/useSyncStore'
import { getSupabaseClient } from '@/lib/supabase/client'
import { AuditRepository } from '@/lib/repositories/AuditRepository'
import { useRouter } from 'next/navigation'
import { toast } from 'sonner'
import { Mail, LogOut, Moon, Sun, Bell, Shield } from 'lucide-react'
import { useTheme } from 'next-themes'

export default function ProfilePage() {
  const router = useRouter()
  const { user, clear } = useAuthStore()
  const { lastSynced, isOnline } = useSyncStore()
  const { theme, setTheme } = useTheme()

  const handleLogout = async () => {
    const supabase = getSupabaseClient()
    if (user) {
      AuditRepository.create({
        user_id: user.id,
        user_email: user.email ?? null,
        action: 'LOGOUT',
        entity_type: null,
        entity_id: null,
        metadata: null,
      }).catch(() => {})
    }
    await supabase.auth.signOut()
    clear()
    toast.success('Logged out successfully')
    router.push('/login')
  }

  const initials = user?.email?.slice(0, 2).toUpperCase() ?? 'FC'

  return (
    <>
      <header className="sticky top-0 bg-white dark:bg-slate-900 border-b border-slate-200 dark:border-slate-800 px-4 h-14 flex items-center z-40">
        <h1 className="font-bold text-slate-900 dark:text-white">Profile</h1>
      </header>

      <div className="px-4 py-6 space-y-4">
        <div className="flex flex-col items-center py-6 bg-white dark:bg-slate-900 rounded-2xl border border-slate-100 dark:border-slate-800">
          <div className="w-20 h-20 rounded-full bg-blue-600 flex items-center justify-center text-white text-2xl font-bold mb-3">
            {initials}
          </div>
          <p className="font-bold text-slate-900 dark:text-white">{user?.email ?? 'Field Executive'}</p>
          <p className="text-xs text-slate-500 mt-0.5">LOT Field Collection</p>
          <div className="flex items-center gap-1.5 mt-2">
            <span className={`w-2 h-2 rounded-full ${isOnline ? 'bg-emerald-500' : 'bg-red-400'}`} />
            <span className="text-xs text-slate-500">{isOnline ? 'Online' : 'Offline'}</span>
          </div>
        </div>

        <div className="bg-white dark:bg-slate-900 rounded-xl border border-slate-100 dark:border-slate-800 overflow-hidden">
          {[
            { icon: Mail, label: 'Email', value: user?.email ?? 'N/A' },
            { icon: Shield, label: 'User ID', value: `${user?.id?.slice(0, 12) ?? 'N/A'}...` },
            { icon: Bell, label: 'Last Synced', value: lastSynced ? lastSynced.toLocaleTimeString() : 'Not synced yet' },
          ].map(({ icon: Icon, label, value }, i, arr) => (
            <div key={label} className={`flex items-center gap-3 px-4 py-3.5 ${i < arr.length - 1 ? 'border-b border-slate-100 dark:border-slate-800' : ''}`}>
              <Icon size={16} className="text-slate-400" />
              <div>
                <p className="text-[10px] text-slate-400 uppercase">{label}</p>
                <p className="text-sm font-medium text-slate-800 dark:text-slate-200">{value}</p>
              </div>
            </div>
          ))}
        </div>

        <div className="bg-white dark:bg-slate-900 rounded-xl border border-slate-100 dark:border-slate-800 overflow-hidden">
          <p className="px-4 py-2 text-[10px] font-semibold text-slate-400 uppercase tracking-wider border-b border-slate-100 dark:border-slate-800">
            Preferences
          </p>
          <div className="flex items-center justify-between px-4 py-3.5">
            <div className="flex items-center gap-3">
              {theme === 'dark' ? <Moon size={16} className="text-slate-400" /> : <Sun size={16} className="text-slate-400" />}
              <span className="text-sm font-medium text-slate-800 dark:text-slate-200">Dark Mode</span>
            </div>
            <button
              onClick={() => setTheme(theme === 'dark' ? 'light' : 'dark')}
              className={`relative w-11 h-6 rounded-full transition-colors ${theme === 'dark' ? 'bg-blue-600' : 'bg-slate-200'}`}>
              <span className={`absolute top-0.5 left-0.5 w-5 h-5 bg-white rounded-full shadow-sm transition-transform ${theme === 'dark' ? 'translate-x-5' : 'translate-x-0'}`} />
            </button>
          </div>
        </div>

        <div className="bg-white dark:bg-slate-900 rounded-xl border border-slate-100 dark:border-slate-800 px-4 py-3.5">
          <div className="flex justify-between">
            <span className="text-sm text-slate-500">App Version</span>
            <span className="text-sm font-medium text-slate-800 dark:text-slate-200">v 4.2.0-next</span>
          </div>
        </div>

        <button onClick={handleLogout}
          className="w-full flex items-center justify-center gap-2 py-3.5 bg-red-50 dark:bg-red-950/30 text-red-600 rounded-xl font-bold text-sm border border-red-100 dark:border-red-900 hover:bg-red-100 transition-colors">
          <LogOut size={16} /> Logout
        </button>
      </div>
    </>
  )
}
