export type AppRole = 'super_admin' | 'admin' | 'executive'

export function toAppRole(roleCode: string | null | undefined): AppRole {
  switch (roleCode?.toUpperCase()) {
    case 'SUPER_ADMIN': return 'super_admin'
    case 'ADMIN': return 'admin'
    case 'FIELD_EXECUTIVE': return 'executive'
    default: return 'executive'
  }
}

export function isAdminRole(role: AppRole | null): boolean {
  return role === 'super_admin' || role === 'admin'
}
