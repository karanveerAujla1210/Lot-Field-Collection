import { getSupabaseClient } from '@/lib/supabase/client'

export function getApiClient() {
  return getSupabaseClient()
}

export class ApiError extends Error {
  constructor(message: string, public readonly code?: string) {
    super(message)
    this.name = 'ApiError'
  }
}

export function handleApiError(error: unknown): never {
  if (error instanceof Error) throw new ApiError(error.message)
  throw new ApiError('An unexpected error occurred')
}
