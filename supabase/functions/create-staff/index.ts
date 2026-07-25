import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

Deno.serve(async (req) => {
  if (req.method === 'OPTIONS') return new Response('ok', { headers: corsHeaders })

  try {
    // Verify the caller is an admin using their JWT
    const authHeader = req.headers.get('Authorization')
    if (!authHeader) return new Response('Unauthorized', { status: 401, headers: corsHeaders })

    const userClient = createClient(
      Deno.env.get('SUPABASE_URL')!,
      Deno.env.get('SUPABASE_ANON_KEY')!,
      { global: { headers: { Authorization: authHeader } } }
    )
    const { data: { user: caller }, error: authError } = await userClient.auth.getUser()
    if (authError || !caller) return new Response('Unauthorized', { status: 401, headers: corsHeaders })

    // Check caller is admin/super_admin
    const { data: callerProfile } = await userClient
      .from('users')
      .select('role')
      .eq('id', caller.id)
      .single()
    const callerRole = (callerProfile as { role?: string } | null)?.role ?? ''
    if (callerRole !== 'admin' && callerRole !== 'super_admin') {
      return new Response('Forbidden', { status: 403, headers: corsHeaders })
    }

    const { email, password, fullName, phone, role, branchName } = await req.json()

    // Use service role client for admin operations
    const adminClient = createClient(
      Deno.env.get('SUPABASE_URL')!,
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
    )

    const { data: authData, error: createError } = await adminClient.auth.admin.createUser({
      email,
      password,
      email_confirm: true,
      user_metadata: { full_name: fullName },
    })
    if (createError) throw createError

    const { data, error } = await adminClient
      .from('users')
      .insert({
        id: authData.user.id,
        employee_code: `EMP-${Date.now()}`,
        email,
        full_name: fullName,
        phone,
        role,
        branch_name: branchName,
        is_active: true,
      })
      .select()
      .single()
    if (error) throw error

    return new Response(JSON.stringify(data), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    })
  } catch (err) {
    const message = err instanceof Error ? err.message : 'Internal error'
    return new Response(JSON.stringify({ error: message }), {
      status: 400,
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    })
  }
})
