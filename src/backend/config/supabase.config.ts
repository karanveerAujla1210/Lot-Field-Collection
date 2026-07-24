// Supabase Centralized Client Configuration for FinCollect Platform

import { createClient, SupabaseClient } from "@supabase/supabase-js";

// Read Environment Credentials
export const SUPABASE_URL = process.env.NEXT_PUBLIC_SUPABASE_URL || "https://tflsmxmuvrecrewknbvb.supabase.co";
export const SUPABASE_PUBLISHABLE_KEY = process.env.NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY || "sb_publishable_OAx279ocalpzqLVAhhMb-w_WdfkOWUH";

// Singleton Client Instance
let instance: SupabaseClient<any> | null = null;

export const getSupabaseClient = (): SupabaseClient<any> => {
  if (!instance) {
    instance = createClient<any>(SUPABASE_URL, SUPABASE_PUBLISHABLE_KEY, {
      auth: {
        persistSession: true,
        autoRefreshToken: true,
        detectSessionInUrl: true,
      },
      realtime: {
        params: {
          eventsPerSecond: 20,
        },
      },
    });
  }
  return instance;
};

export const supabase = getSupabaseClient();
