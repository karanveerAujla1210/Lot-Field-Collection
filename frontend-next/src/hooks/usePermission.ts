'use client'

import { useAuthStore } from '@/stores/useAuthStore'
import { can, canAll, type Permission } from '@/lib/permissions/matrix'

export function usePermission() {
  const { role } = useAuthStore()
  return {
    can: (permission: Permission) => can(role, permission),
    canAll: (permissions: Permission[]) => canAll(role, permissions),
    role,
  }
}
