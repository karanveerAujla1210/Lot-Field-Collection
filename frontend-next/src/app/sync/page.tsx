'use client'

import { AppLayout } from '@/components/layout/AppLayout'
import { useSyncStore } from '@/stores/useSyncStore'
import { useCases } from '@/hooks/useCases'
import { useQueryClient } from '@tanstack/react-query'
import { toast } from 'sonner'
import { RefreshCw, Wifi, WifiOff, CheckCircle, Clock, Database, Loader2 } from 'lucide-react'
import { useState } from 'react'

export default function SyncPage() {
  const queryClient = useQueryClient()
  const { lastSynced, isOnline, isSyncing, setSyncing, setLastSynced } = useSyncStore()
  const { data: cases = [] } = useCases()
  const [syncLog, setSyncLog] = useState<string[]>([])

  const handleFullSync = async () => {
    setSyncing(true)
    setSyncLog([])
    try {
      setSyncLog(prev => [...prev, '🔄 Invalidating cases cache...'])
      await queryClient.invalidateQueries({ queryKey: ['cases'] })
      setSyncLog(prev => [...prev, '🔄 Refetching payments...'])
      await queryClient.invalidateQueries({ queryKey: ['payments'] })
      setSyncLog(prev => [...prev, '🔄 Refetching visits...'])
      await queryClient.invalidateQueries({ queryKey: ['visits'] })
      setSyncLog(prev => [...prev, '🔄 Refetching staff...'])
      await queryClient.invalidateQueries({ queryKey: ['staff'] })
      setLastSynced(new Date())
      setSyncLog(prev => [...prev, '✅ Sync complete!'])
      toast.success('All data synced successfully')
    } catch {
      setSyncLog(prev => [...prev, '❌ Sync failed — check connection'])
      toast.error('Sync failed')
    } finally {
      setSyncing(false)
    }
  }

  return (
    <AppLayout>
      <header className="sticky top-0 bg-white dark:bg-slate-900 border-b border-slate-200 dark:border-slate-800 px-4 h-14 flex items-center z-40">
        <h1 className="font-bold text-slate-900 dark:text-white">Offline Sync</h1>
      </header>

      <div className="px-4 py-4 space-y-4">
        {/* Connection status */}
        <div className={`rounded-xl p-4 flex items-center gap-3 ${isOnline ? 'bg-emerald-50 dark:bg-emerald-950/30 border border-emerald-200 dark:border-emerald-900' : 'bg-red-50 dark:bg-red-950/30 border border-red-200 dark:border-red-900'}`}>
          {isOnline
            ? <Wifi size={24} className="text-emerald-600 shrink-0" />
            : <WifiOff size={24} className="text-red-600 shrink-0" />}
          <div>
            <p className={`font-bold text-sm ${isOnline ? 'text-emerald-800 dark:text-emerald-300' : 'text-red-800 dark:text-red-300'}`}>
              {isOnline ? 'Connected to Supabase' : 'Offline Mode'}
            </p>
            <p className={`text-xs ${isOnline ? 'text-emerald-600' : 'text-red-500'}`}>
              {isOnline ? 'Real-time sync is active' : 'Changes will sync when reconnected'}
            </p>
          </div>
        </div>

        {/* Stats */}
        <div className="grid grid-cols-2 gap-3">
          <div className="bg-white dark:bg-slate-900 rounded-xl p-4 border border-slate-100 dark:border-slate-800 text-center">
            <Database size={20} className="text-blue-600 mx-auto mb-1" />
            <p className="text-2xl font-bold text-slate-900 dark:text-white">{cases.length}</p>
            <p className="text-xs text-slate-500">Cases Cached</p>
          </div>
          <div className="bg-white dark:bg-slate-900 rounded-xl p-4 border border-slate-100 dark:border-slate-800 text-center">
            <Clock size={20} className="text-slate-400 mx-auto mb-1" />
            <p className="text-sm font-bold text-slate-900 dark:text-white">
              {lastSynced ? lastSynced.toLocaleTimeString() : '—'}
            </p>
            <p className="text-xs text-slate-500">Last Synced</p>
          </div>
        </div>

        {/* Sync button */}
        <button onClick={handleFullSync} disabled={isSyncing}
          className="w-full h-12 bg-blue-600 hover:bg-blue-700 disabled:opacity-60 text-white font-bold rounded-xl flex items-center justify-center gap-2 transition-colors">
          {isSyncing
            ? <><Loader2 size={16} className="animate-spin" /> Syncing...</>
            : <><RefreshCw size={16} /> Sync Now</>}
        </button>

        {/* Sync log */}
        {syncLog.length > 0 && (
          <div className="bg-slate-900 rounded-xl p-4 space-y-1">
            <p className="text-xs font-semibold text-slate-400 uppercase mb-2">Sync Log</p>
            {syncLog.map((line, i) => (
              <p key={i} className="text-xs text-slate-300 font-mono">{line}</p>
            ))}
          </div>
        )}

        {/* Info */}
        <div className="bg-white dark:bg-slate-900 rounded-xl p-4 border border-slate-100 dark:border-slate-800 space-y-3">
          <p className="text-xs font-semibold text-slate-500 uppercase">How sync works</p>
          {[
            { icon: CheckCircle, text: 'Cases, payments and visits auto-sync via Supabase Realtime' },
            { icon: RefreshCw, text: 'Manual sync refreshes all queries from the server' },
            { icon: Clock, text: 'Auto-refresh every 60 seconds when online' },
          ].map(({ icon: Icon, text }, i) => (
            <div key={i} className="flex items-start gap-2">
              <Icon size={14} className="text-blue-600 mt-0.5 shrink-0" />
              <p className="text-xs text-slate-600 dark:text-slate-400">{text}</p>
            </div>
          ))}
        </div>
      </div>
    </AppLayout>
  )
}
