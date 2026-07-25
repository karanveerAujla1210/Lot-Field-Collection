import { redirect } from 'next/navigation'
import { createClient } from '@/lib/supabase/server'
import { isAdminRole, toAppRole } from '@/lib/auth/roles'

export default async function HomePage() {
  const supabase = await createClient()
  const { data: { user } } = await supabase.auth.getUser()

  if (!user) redirect('/login')

  const { data: profile } = await supabase
    .from('users')
    .select('roles!users_role_id_fkey(code)')
    .eq('id', user.id)
    .single()

  const role = toAppRole(
    (profile as unknown as { roles: { code: string } | null } | null)?.roles?.code
  )
  if (isAdminRole(role)) redirect('/dashboard/admin')
  redirect('/dashboard')
}
