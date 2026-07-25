'use client'

import { useCallback } from 'react'
import { useQuery } from '@tanstack/react-query'
import { useAuthStore } from '@/stores/useAuthStore'
import { AuditRepository } from '@/lib/repositories/AuditRepository'
import type { AuditAction, AuditLog } from '@/types/database.types'

export function useAuditLog() {
  const { user } = useAuthStore()

  const log = useCallback(
    (action: AuditAction, entityType?: string, entityId?: string, metadata?: Record<string, unknown>) => {
      if (!user) return
      // Fire-and-forget — never block the UI
      AuditRepository.create({
        user_id: user.id,
        user_email: user.email ?? null,
        action,
        entity_type: entityType ?? null,
        entity_id: entityId ?? null,
        metadata: metadata ?? null,
      }).catch(() => {
        // Silently fail — audit logs must never break the app
      })
    },
    [user]
  )

  return { log }
}

export function useAuditLogs(limit = 100) {
  return useQuery({
    queryKey: ['audit_logs', limit],
    queryFn: () => AuditRepository.findAll(limit),
    staleTime: 30_000,
  })
}

export function useMyAuditLogs() {
  const { user } = useAuthStore()
  return useQuery({
    queryKey: ['audit_logs', 'me', user?.id],
    queryFn: () => AuditRepository.findByUser(user!.id),
    enabled: !!user,
    staleTime: 30_000,
  })
}

export type { AuditLog }
