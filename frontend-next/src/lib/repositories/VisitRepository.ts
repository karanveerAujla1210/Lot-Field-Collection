import { getApiClient, handleApiError } from '@/lib/api/client'
import type { CaseVisit } from '@/types/database.types'

export type CreateVisitPayload = Omit<CaseVisit, 'id' | 'created_at'>

export const VisitRepository = {
  async findByCaseId(caseId: string): Promise<CaseVisit[]> {
    try {
      const { data, error } = await getApiClient()
        .from('case_visits').select('*').eq('case_id', caseId)
        .order('created_at', { ascending: false }).limit(20)
      if (error) throw error
      return (data ?? []) as CaseVisit[]
    } catch (e) {
      handleApiError(e)
      return []
    }
  },

  async create(payload: CreateVisitPayload): Promise<CaseVisit> {
    try {
      const { data, error } = await getApiClient()
        .from('case_visits').insert(payload).select().single()
      if (error) throw error
      if (!data) throw new Error('Visit not returned after insert')
      return data as CaseVisit
    } catch (e) {
      handleApiError(e)
      throw e
    }
  },

  async uploadPhotos(caseId: string, photos: File[]): Promise<string[]> {
    if (photos.length === 0) return []
    const db = getApiClient()
    const paths: string[] = []
    for (const photo of photos) {
      try {
        const ext = photo.name.split('.').pop()?.toLowerCase() ?? 'jpg'
        const path = `visits/${caseId}/${crypto.randomUUID()}.${ext}`
        const { error } = await db.storage.from('house-photo').upload(path, photo, {
          cacheControl: '3600', contentType: photo.type, upsert: false,
        })
        if (error) throw error
        paths.push(path)
      } catch (e) {
        handleApiError(e)
        // Continue with other photos even if one fails
      }
    }
    return paths
  },
}
