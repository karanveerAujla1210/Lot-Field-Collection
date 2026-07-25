import { getApiClient, handleApiError } from '@/lib/api/client'
import type { CaseRow } from '@/types/database.types'

export const CaseRepository = {
  async findAll(executiveId?: string): Promise<CaseRow[]> {
    try {
      const db = getApiClient()
      let query = db.from('cases').select('*').order('due_days', { ascending: false }).limit(500)
      if (executiveId) query = query.eq('assigned_executive_id', executiveId)
      const { data, error } = await query
      if (error) throw error
      return data ?? []
    } catch (e) { handleApiError(e) }
  },

  async findById(id: string): Promise<CaseRow | null> {
    try {
      const { data, error } = await getApiClient().from('cases').select('*').eq('id', id).single()
      if (error) throw error
      return data
    } catch (e) { handleApiError(e) }
  },
}
