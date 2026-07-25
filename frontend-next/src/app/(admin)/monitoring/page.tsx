'use client'

import { useEffect, useRef } from 'react'
import { useCases } from '@/hooks/useCases'
import { useRealtimeSync } from '@/hooks/useRealtimeSync'
import { Skeleton } from '@/components/ui/skeleton'
import { deriveRisk, RISK_CONFIG, deriveOutstanding } from '@/lib/utils/risk'
import { formatCurrency } from '@/lib/utils/currency'
import { MapPin, RefreshCw } from 'lucide-react'
import type { CaseRow } from '@/types/database.types'

function LiveMap({ cases }: { cases: CaseRow[] }) {
  const mapRef = useRef<HTMLDivElement>(null)
  const mapInstanceRef = useRef<unknown>(null)

  useEffect(() => {
    if (!mapRef.current || mapInstanceRef.current) return
    import('leaflet').then(L => {
      const map = L.map(mapRef.current!, { center: [20.5937, 78.9629], zoom: 5 })
      L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
        attribution: '© OpenStreetMap contributors',
      }).addTo(map)
      cases.forEach(c => {
        const risk = deriveRisk(c)
        const color = RISK_CONFIG[risk].color
        const marker = L.circleMarker([c.latitude as number, c.longitude as number], {
          radius: 8, fillColor: color, color: '#fff', weight: 2, fillOpacity: 0.9,
        }).addTo(map)
        marker.bindPopup(`
          <strong>${c.customer_name}</strong><br/>
          Loan: ${c.loan_no}<br/>
          Outstanding: ${formatCurrency(deriveOutstanding(c))}<br/>
          Risk: <b>${risk}</b>
        `)
      })
      mapInstanceRef.current = map
    })
    return () => {
      if (mapInstanceRef.current) {
        (mapInstanceRef.current as { remove: () => void }).remove()
        mapInstanceRef.current = null
      }
    }
  }, [cases])

  return <div ref={mapRef} className="w-full h-[calc(100vh-160px)] rounded-xl z-0" />
}

export default function MonitoringPage() {
  useRealtimeSync()
  const { data: cases = [], isLoading, refetch } = useCases()
  const mappableCases = cases.filter(c => c.latitude && c.longitude)

  return (
    <div className="min-h-screen flex flex-col">
      <header className="sticky top-0 h-16 bg-white dark:bg-slate-900 border-b border-slate-200 dark:border-slate-800 flex items-center justify-between px-6 z-40">
        <div>
          <h1 className="font-bold text-slate-900 dark:text-white text-lg">Live GPS Monitoring</h1>
          <p className="text-xs text-slate-500 flex items-center gap-1">
            <span className="w-1.5 h-1.5 rounded-full bg-emerald-500 animate-pulse" />
            {mappableCases.length} cases with GPS coordinates
          </p>
        </div>
        <button onClick={() => refetch()} className="flex items-center gap-1.5 px-3 py-2 text-sm font-medium bg-slate-100 dark:bg-slate-800 rounded-lg hover:bg-slate-200 transition-colors">
          <RefreshCw size={14} /> Refresh
        </button>
      </header>

      <div className="p-4 flex-1">
        {isLoading ? (
          <Skeleton className="w-full h-[calc(100vh-160px)] rounded-xl" />
        ) : mappableCases.length === 0 ? (
          <div className="flex flex-col items-center justify-center h-[calc(100vh-200px)] text-slate-400">
            <MapPin size={48} className="mb-4 opacity-30" />
            <p className="text-lg font-semibold">No GPS data available</p>
            <p className="text-sm">Cases with latitude/longitude will appear on the map</p>
          </div>
        ) : (
          <LiveMap cases={mappableCases} />
        )}
      </div>
    </div>
  )
}
