import type { AppRole } from '@/lib/auth/roles'

export type Permission =
  | 'cases:read'
  | 'cases:read_all'        // admin only — see all cases
  | 'visits:create'
  | 'visits:read'
  | 'payments:create'
  | 'payments:read'
  | 'followups:create'
  | 'followups:read'
  | 'followups:complete'
  | 'staff:read'
  | 'staff:create'
  | 'staff:toggle'
  | 'reports:read'
  | 'monitoring:read'
  | 'portfolio:read'
  | 'audit:read'
  | 'sync:manual'

const ROLE_PERMISSIONS: Record<NonNullable<AppRole>, Permission[]> = {
  executive: [
    'cases:read',
    'visits:create',
    'visits:read',
    'payments:create',
    'payments:read',
    'followups:create',
    'followups:read',
    'followups:complete',
    'sync:manual',
  ],
  admin: [
    'cases:read',
    'cases:read_all',
    'visits:create',
    'visits:read',
    'payments:create',
    'payments:read',
    'followups:create',
    'followups:read',
    'followups:complete',
    'staff:read',
    'staff:create',
    'staff:toggle',
    'reports:read',
    'monitoring:read',
    'portfolio:read',
    'audit:read',
    'sync:manual',
  ],
  super_admin: [
    'cases:read',
    'cases:read_all',
    'visits:create',
    'visits:read',
    'payments:create',
    'payments:read',
    'followups:create',
    'followups:read',
    'followups:complete',
    'staff:read',
    'staff:create',
    'staff:toggle',
    'reports:read',
    'monitoring:read',
    'portfolio:read',
    'audit:read',
    'sync:manual',
  ],
}

export function can(role: AppRole | null, permission: Permission): boolean {
  if (!role) return false
  return ROLE_PERMISSIONS[role]?.includes(permission) ?? false
}

export function canAll(role: AppRole | null, permissions: Permission[]): boolean {
  return permissions.every(p => can(role, p))
}
