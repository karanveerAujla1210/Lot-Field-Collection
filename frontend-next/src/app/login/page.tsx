'use client'

import { useState } from 'react'
import { useForm } from 'react-hook-form'
import { zodResolver } from '@hookform/resolvers/zod'
import { useRouter } from 'next/navigation'
import { Eye, EyeOff, Shield, Building2, Lock } from 'lucide-react'
import { toast } from 'sonner'
import { loginSchema, type LoginFormData } from '@/lib/validations/login.schema'
import { getSupabaseClient } from '@/lib/supabase/client'
import { useAuthStore } from '@/stores/useAuthStore'
import { isAdminRole, toAppRole } from '@/lib/auth/roles'
import { AuditRepository } from '@/lib/repositories/AuditRepository'

export default function LoginPage() {
  const router = useRouter()
  const { setSession, setRole, setLoading } = useAuthStore()
  const [showPassword, setShowPassword] = useState(false)
  const [isLoading, setIsLoading] = useState(false)

  const { register, handleSubmit, formState: { errors } } = useForm<LoginFormData>({
    resolver: zodResolver(loginSchema),
  })

  const onSubmit = async (data: LoginFormData) => {
    setIsLoading(true)
    try {
      const supabase = getSupabaseClient()
      const { data: authData, error } = await supabase.auth.signInWithPassword({
        email: data.email,
        password: data.password,
      })
      if (error) throw error
      if (!authData.session || !authData.user) {
        throw new Error('Login succeeded but no session was returned')
      }

      setSession(authData.session)

      // Fetch the normalized role once on login and cache it in the store.
      const { data: profile } = await supabase
        .from('users')
        .select('role')
        .eq('id', authData.user.id)
        .single()
      const role = toAppRole((profile as { role?: string } | null)?.role)
      setRole(role)
      setLoading(false)

      // Audit log — fire and forget
      AuditRepository.create({
        user_id: authData.user.id,
        user_email: authData.user.email ?? null,
        action: 'LOGIN',
        entity_type: null,
        entity_id: null,
        metadata: { role },
      }).catch(() => {})

      toast.success('Login successful!')
      router.replace(isAdminRole(role) ? '/dashboard/admin' : '/dashboard')
      router.refresh()
    } catch (err: unknown) {
      const message = err instanceof Error ? err.message : 'Login failed'
      toast.error(`Login failed: ${message}`)
    } finally {
      setIsLoading(false)
    }
  }

  return (
    <div className="min-h-screen bg-[#f9f9ff] flex flex-col">
      <header className="flex justify-between items-center w-full px-4 h-14 bg-white border-b border-slate-100 fixed top-0 z-50">
        <div className="flex items-center gap-2">
          <Building2 className="text-blue-700" size={22} />
          <h1 className="text-lg font-bold text-blue-700">LOT Field Collection</h1>
        </div>
        <div className="w-8 h-8 rounded-full bg-slate-100 flex items-center justify-center">
          <Shield size={16} className="text-slate-500" />
        </div>
      </header>

      <main className="flex-grow flex items-center justify-center px-4 py-8 mt-14">
        <div className="w-full max-w-[400px] flex flex-col gap-6">
          <div className="text-center space-y-2">
            <div className="w-20 h-20 bg-blue-50 rounded-2xl flex items-center justify-center mx-auto mb-4">
              <Lock className="text-blue-700" size={40} />
            </div>
            <h2 className="text-2xl font-bold text-slate-900">Welcome Back</h2>
            <p className="text-sm text-slate-500">Access your secure agent dashboard</p>
          </div>

          <div className="bg-white rounded-xl p-6 border border-slate-200 shadow-sm">
            <form onSubmit={handleSubmit(onSubmit)} className="flex flex-col gap-4">
              <div className="space-y-1.5">
                <label className="text-sm font-medium text-slate-700" htmlFor="email">
                  Email Address
                </label>
                <input
                  id="email"
                  type="email"
                  placeholder="agent@company.com"
                  className="w-full h-12 px-4 border border-slate-200 rounded-lg focus:border-blue-600 focus:ring-2 focus:ring-blue-100 outline-none transition-all text-sm bg-white"
                  {...register('email')}
                />
                {errors.email && <p className="text-xs text-red-500">{errors.email.message}</p>}
              </div>

              <div className="space-y-1.5">
                <label className="text-sm font-medium text-slate-700" htmlFor="password">
                  Password
                </label>
                <div className="relative">
                  <input
                    id="password"
                    type={showPassword ? 'text' : 'password'}
                    placeholder="••••••••"
                    className="w-full h-12 px-4 pr-11 border border-slate-200 rounded-lg focus:border-blue-600 focus:ring-2 focus:ring-blue-100 outline-none transition-all text-sm bg-white"
                    {...register('password')}
                  />
                  <button
                    type="button"
                    onClick={() => setShowPassword(!showPassword)}
                    className="absolute right-3 top-1/2 -translate-y-1/2 text-slate-400 hover:text-slate-600"
                  >
                    {showPassword ? <EyeOff size={18} /> : <Eye size={18} />}
                  </button>
                </div>
                {errors.password && <p className="text-xs text-red-500">{errors.password.message}</p>}
              </div>

              <div className="flex items-center justify-between">
                <label className="flex items-center gap-2 cursor-pointer">
                  <input type="checkbox" className="rounded border-slate-300 text-blue-600" {...register('rememberMe')} />
                  <span className="text-xs text-slate-600">Remember Me</span>
                </label>
                <button
                  type="button"
                  onClick={() => toast.info('Contact your admin to reset your password.')}
                  className="text-xs text-blue-600 font-semibold hover:underline"
                >
                  Forgot Password?
                </button>
              </div>

              <button
                type="submit"
                disabled={isLoading}
                className="mt-2 h-12 bg-blue-700 hover:bg-blue-800 disabled:opacity-60 disabled:cursor-not-allowed text-white font-semibold rounded-full shadow-lg transition-all flex items-center justify-center gap-2 text-sm"
              >
                {isLoading ? (
                  <span className="flex items-center gap-2">
                    <svg className="animate-spin h-4 w-4" viewBox="0 0 24 24" fill="none">
                      <circle className="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" strokeWidth="4" />
                      <path className="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4z" />
                    </svg>
                    Signing in...
                  </span>
                ) : (
                  <>Login <Lock size={16} /></>
                )}
              </button>
            </form>
          </div>

          <p className="text-center text-xs text-slate-400">
            Secured by 256-bit AES Encryption
          </p>
        </div>
      </main>

      <footer className="py-4 px-4 flex flex-col items-center gap-1">
        <p className="text-xs text-slate-400">v 4.2.0-stable</p>
      </footer>
    </div>
  )
}
