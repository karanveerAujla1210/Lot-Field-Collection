import { getApiClient, handleApiError } from '@/lib/api/client'
import type { AuditLog, CreateAuditLogPayload } from '@/types/database.types'

export const AuditRepository = {
  async create(payload: CreateAuditLogPayload): Promise<void> {
    try {
      const { error } = await getApiClient().from('audit_logs').insert(payload)
      if (error) throw error
    } catch (e) {
      handleApiError(e)
      // Silently fail for audit logs
    }
  },

  async findAll(limit = 100): Promise<AuditLog[]> {
    try {
      const { data, error } = await getApiClient()
        .from('audit_logs').select('*')
        .order('created_at', { ascending: false }).limit(limit)
      if (error) throw error
      return (data ?? []) as AuditLog[]
    } catch (e) {
      handleApiError(e)
      return []
    }
  },

  async findByUser(userId: string, limit = 50): Promise<AuditLog[]> {
    try {
      const { data, error } = await getApiClient()
        .from('audit_logs').select('*').eq('user_id', userId)
        .order('created_at', { ascending: false }).limit(limit)
      if (error) throw error
      return (data ?? []) as AuditLog[]
    } catch (e) {
      handleApiError(e)
      return []
    }
  },
}
