'use client'

import { useState } from 'react'
import { useForm } from 'react-hook-form'
import { zodResolver } from '@hookform/resolvers/zod'
import { useCaseStore } from '@/stores/useCaseStore'
import { useAuthStore } from '@/stores/useAuthStore'
import { useSubmitVisit } from '@/hooks/useVisits'
import { useGeolocation } from '@/hooks/useGeolocation'
import { visitSchema, type VisitFormData } from '@/lib/validations/visit.schema'
import { toast } from 'sonner'
import { useRouter } from 'next/navigation'
import { ArrowLeft, MapPin, Loader2, CheckCircle, ImagePlus, X } from 'lucide-react'

const VISIT_STATUS_OPTIONS = [
  { value: 'CUSTOMER_MET', label: '✅ Customer Met' },
  { value: 'PARTIAL_PAYMENT_PROMISE', label: '🤝 PTP — Promise to Pay' },
  { value: 'DOOR_LOCKED', label: '🔒 Door Locked' },
  { value: 'REFUSED_TO_PAY', label: '❌ Refused to Pay' },
  { value: 'THIRD_PARTY_MET', label: '👥 Third Party Met' },
]

export default function NewVisitPage() {
  const router = useRouter()
  const { selectedCase } = useCaseStore()
  const { user } = useAuthStore()
  const { getCurrentPosition, isLoading: gpsLoading, error: gpsError } = useGeolocation()
  const submitVisit = useSubmitVisit()
  const [gpsAcquired, setGpsAcquired] = useState(false)
  const [coords, setCoords] = useState<{ lat: number; lng: number } | null>(null)
  const [photos, setPhotos] = useState<File[]>([])

  const { register, handleSubmit, formState: { errors }, watch } = useForm<VisitFormData>({
    resolver: zodResolver(visitSchema) as never,
    defaultValues: { visitStatus: 'CUSTOMER_MET', remarks: '' },
  })
  const visitStatus = watch('visitStatus')

  const handleGetGPS = async () => {
    try {
      const position = await getCurrentPosition()
      setCoords({ lat: position.latitude, lng: position.longitude })
      setGpsAcquired(true)
      toast.success('GPS location acquired')
    } catch {
      toast.error(`GPS failed: ${gpsError ?? 'Unable to get location'}`)
    }
  }

  const onSubmit = async (data: VisitFormData) => {
    if (!selectedCase) { toast.error('Please select a case first'); return }
    if (!user) { toast.error('Please login first'); return }
    if (!coords) { toast.error('Please get GPS location first'); return }

    // Guard against null loan_no / customer_name
    if (!selectedCase.loan_no || !selectedCase.customer_name) {
      toast.error('Case is missing loan number or customer name')
      return
    }

    try {
      await submitVisit.mutateAsync({
        formData: data,
        caseId: selectedCase.id,
        loanNo: selectedCase.loan_no,
        customerName: selectedCase.customer_name,
        executiveId: user.id,
        executiveName: user.email ?? 'Field Executive',
        branchName: selectedCase.branch_name ?? selectedCase.state_name,
        latitude: coords.lat,
        longitude: coords.lng,
        photos,
      })
      toast.success('Visit recorded successfully!')
      router.back()
    } catch (err: unknown) {
      toast.error(`Failed: ${err instanceof Error ? err.message : 'Unknown error'}`)
    }
  }

  if (!selectedCase) {
    return (
      <div className="p-8 text-center">
        <p className="text-slate-500 font-medium">No case selected</p>
        <button onClick={() => router.push('/customers')} className="mt-3 text-blue-600 text-sm font-medium">← Select a customer</button>
      </div>
    )
  }

  return (
    <>
      <header className="sticky top-0 bg-white dark:bg-slate-900 border-b border-slate-200 dark:border-slate-800 px-4 h-14 flex items-center gap-3 z-40">
        <button onClick={() => router.back()} className="text-slate-500 hover:text-slate-800"><ArrowLeft size={20} /></button>
        <h1 className="font-bold text-slate-900 dark:text-white">Record Visit</h1>
      </header>

      <div className="px-4 py-4 space-y-4">
        <div className="bg-blue-50 dark:bg-blue-950 rounded-xl p-3 border border-blue-200 dark:border-blue-900">
          <p className="text-xs text-blue-500 font-medium">Recording visit for</p>
          <p className="font-bold text-blue-800 dark:text-blue-300">{selectedCase.customer_name}</p>
          <p className="text-xs text-blue-500">Loan: {selectedCase.loan_no}</p>
        </div>

        <form onSubmit={handleSubmit(onSubmit)} className="space-y-4">
          <div className="bg-white dark:bg-slate-900 rounded-xl p-4 border border-slate-100 dark:border-slate-800">
            <label className="block text-sm font-semibold text-slate-800 dark:text-slate-200 mb-3">Visit Outcome</label>
            <div className="space-y-2">
              {VISIT_STATUS_OPTIONS.map(({ value, label }) => (
                <label key={value} className={`flex items-center gap-3 p-3 rounded-xl border cursor-pointer transition-all ${visitStatus === value ? 'border-blue-500 bg-blue-50 dark:bg-blue-950' : 'border-slate-200 dark:border-slate-700'}`}>
                  <input type="radio" value={value} {...register('visitStatus')} className="text-blue-600" />
                  <span className="text-sm font-medium">{label}</span>
                </label>
              ))}
            </div>
            {errors.visitStatus && <p className="text-xs text-red-500 mt-1">{errors.visitStatus.message}</p>}
          </div>

          <div className="bg-white dark:bg-slate-900 rounded-xl p-4 border border-slate-100 dark:border-slate-800">
            <label className="block text-sm font-semibold text-slate-800 dark:text-slate-200 mb-2">Visit Photos</label>
            <p className="text-xs text-slate-500 mb-3">Add up to 5 JPG, PNG, or WebP photos (10 MB each).</p>
            <label className="w-full flex items-center justify-center gap-2 py-3 border-2 border-dashed border-slate-300 dark:border-slate-600 rounded-xl text-sm font-medium text-slate-600 dark:text-slate-400 hover:border-blue-400 hover:text-blue-600 cursor-pointer transition-colors">
              <ImagePlus size={16} /> Add photos
              <input
                type="file"
                accept="image/jpeg,image/png,image/webp"
                multiple
                className="sr-only"
                onChange={(event) => {
                  const selected = Array.from(event.target.files ?? [])
                  const valid = selected.filter((file) => file.size <= 10 * 1024 * 1024)
                  if (valid.length !== selected.length) toast.error('Each photo must be 10 MB or smaller')
                  setPhotos((current) => [...current, ...valid].slice(0, 5))
                  event.target.value = ''
                }}
              />
            </label>
            {photos.length > 0 && (
              <div className="mt-3 space-y-2">
                {photos.map((photo, index) => (
                  <div key={`${photo.name}-${photo.lastModified}`} className="flex items-center justify-between gap-3 text-xs bg-slate-50 dark:bg-slate-800 rounded-lg px-3 py-2">
                    <span className="truncate">{photo.name}</span>
                    <button type="button" aria-label={`Remove ${photo.name}`} onClick={() => setPhotos((current) => current.filter((_, photoIndex) => photoIndex !== index))} className="text-slate-500 hover:text-red-600"><X size={14} /></button>
                  </div>
                ))}
              </div>
            )}
          </div>

          <div className="bg-white dark:bg-slate-900 rounded-xl p-4 border border-slate-100 dark:border-slate-800">
            <label className="block text-sm font-semibold text-slate-800 dark:text-slate-200 mb-2">Remarks *</label>
            <textarea
              rows={3}
              placeholder="Describe what happened during the visit..."
              className="w-full text-sm border border-slate-200 dark:border-slate-700 rounded-lg p-3 resize-none focus:ring-2 focus:ring-blue-100 outline-none bg-white dark:bg-slate-800"
              {...register('remarks')}
            />
            {errors.remarks && <p className="text-xs text-red-500 mt-1">{errors.remarks.message}</p>}
          </div>

          {visitStatus === 'PARTIAL_PAYMENT_PROMISE' && (
            <div className="bg-white dark:bg-slate-900 rounded-xl p-4 border border-slate-100 dark:border-slate-800 space-y-3">
              <label className="block text-sm font-semibold text-slate-800 dark:text-slate-200">PTP Details</label>
              <div>
                <label className="text-xs text-slate-500 mb-1 block">Promise Date</label>
                <input type="date" {...register('promiseDate')}
                  className="w-full text-sm border border-slate-200 dark:border-slate-700 rounded-lg p-3 focus:ring-2 focus:ring-blue-100 outline-none bg-white dark:bg-slate-800" />
              </div>
              <div>
                <label className="text-xs text-slate-500 mb-1 block">Expected Amount (₹)</label>
                <input type="number" placeholder="0" {...register('expectedAmount')}
                  className="w-full text-sm border border-slate-200 dark:border-slate-700 rounded-lg p-3 focus:ring-2 focus:ring-blue-100 outline-none bg-white dark:bg-slate-800" />
              </div>
            </div>
          )}

          <div className="bg-white dark:bg-slate-900 rounded-xl p-4 border border-slate-100 dark:border-slate-800">
            <label className="block text-sm font-semibold text-slate-800 dark:text-slate-200 mb-3">GPS Location *</label>
            {gpsAcquired && coords ? (
              <div className="flex items-center gap-2 text-emerald-600 bg-emerald-50 dark:bg-emerald-950 rounded-lg p-3">
                <CheckCircle size={16} />
                <p className="text-xs font-medium">{coords.lat.toFixed(6)}, {coords.lng.toFixed(6)}</p>
              </div>
            ) : (
              <button type="button" onClick={handleGetGPS} disabled={gpsLoading}
                className="w-full flex items-center justify-center gap-2 py-3 border-2 border-dashed border-slate-300 dark:border-slate-600 rounded-xl text-sm font-medium text-slate-600 dark:text-slate-400 hover:border-blue-400 hover:text-blue-600 transition-colors disabled:opacity-60">
                {gpsLoading ? <Loader2 size={16} className="animate-spin" /> : <MapPin size={16} />}
                {gpsLoading ? 'Getting location...' : 'Get Current GPS Location'}
              </button>
            )}
          </div>

          <button type="submit" disabled={submitVisit.isPending || !gpsAcquired}
            className="w-full h-12 bg-blue-600 hover:bg-blue-700 disabled:opacity-60 disabled:cursor-not-allowed text-white font-bold rounded-xl flex items-center justify-center gap-2 transition-colors">
            {submitVisit.isPending ? <><Loader2 size={16} className="animate-spin" /> Saving...</> : '✅ Save Visit'}
          </button>
        </form>
      </div>
    </>
  )
}
