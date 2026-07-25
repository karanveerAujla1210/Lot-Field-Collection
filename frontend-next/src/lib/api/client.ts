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

export function handleApiError(error: unknown): void {
  if (error instanceof Error) {
    console.error('API Error:', error.message)
  } else {
    console.error('API Error: An unexpected error occurred')
  }
}
