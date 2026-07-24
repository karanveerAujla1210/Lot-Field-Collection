// Authentication & Identity Service for FinCollect Platform

import { supabase } from "../config/supabase.config.js";
import { UserRoleCode } from "../types/database.types.js";

export interface LoginResponse {
  user: any;
  profile: any;
  role: UserRoleCode;
  permissions: string[];
  session: any;
}

export class AuthService {
  /**
   * Authenticate user with Email & Password, returning Session, Role, and Permissions
   */
  static async login(email: string, password: string, deviceId?: string, deviceName?: string): Promise<LoginResponse> {
    const { data: authData, error: authError } = await supabase.auth.signInWithPassword({
      email,
      password,
    });

    if (authError || !authData.user) {
      throw new Error(`Authentication failed: ${authError?.message || "Invalid credentials"}`);
    }

    // Fetch User Profile with Role details
    const { data: profile, error: profileError } = await supabase
      .from("users")
      .select("*, roles(id, name, code)")
      .eq("id", authData.user.id)
      .single();

    if (profileError || !profile) {
      throw new Error("User profile or role assignment not found");
    }

    if (profile.status !== "ACTIVE") {
      await supabase.auth.signOut();
      throw new Error(`Account is currently ${profile.status}. Access denied.`);
    }

    // Update last login timestamp & device details
    await supabase.from("users").update({
      last_login_at: new Date().toISOString(),
      device_id: deviceId || profile.device_id,
      device_name: deviceName || profile.device_name,
    }).eq("id", profile.id);

    // Fetch Role Permissions
    const roleCode = (profile.roles as any)?.code as UserRoleCode;
    const roleId = (profile.roles as any)?.id;

    const { data: permData } = await supabase
      .from("role_permissions")
      .select("permissions(code)")
      .eq("role_id", roleId);

    const permissions = permData?.map(p => (p.permissions as any)?.code).filter(Boolean) || [];

    // Log Activity
    await supabase.from("activity_logs").insert({
      user_id: profile.id,
      action: "LOGIN",
      entity_type: "USER",
      entity_id: profile.id,
      new_state: { device_id: deviceId, timestamp: new Date().toISOString() },
    });

    return {
      user: authData.user,
      profile,
      role: roleCode,
      permissions,
      session: authData.session,
    };
  }

  /**
   * Request password reset email
   */
  static async forgotPassword(email: string, redirectTo?: string): Promise<void> {
    const { error } = await supabase.auth.resetPasswordForEmail(email, {
      redirectTo: redirectTo || "https://fincollect.app/reset-password",
    });
    if (error) throw error;
  }

  /**
   * Change current user password
   */
  static async changePassword(newPassword: string): Promise<void> {
    const { error } = await supabase.auth.updateUser({
      password: newPassword,
    });
    if (error) throw error;
  }

  /**
   * Terminate current session
   */
  static async logout(): Promise<void> {
    const { data: session } = await supabase.auth.getSession();
    if (session?.session?.user) {
      await supabase.from("activity_logs").insert({
        user_id: session.session.user.id,
        action: "LOGOUT",
        entity_type: "USER",
        entity_id: session.session.user.id,
      });
    }
    await supabase.auth.signOut();
  }

  /**
   * Register or update FCM Device Token for Push Notifications
   */
  static async registerDeviceToken(userId: string, fcmToken: string, deviceType: 'ANDROID' | 'IOS' | 'WEB', deviceId: string, appVersion?: string): Promise<void> {
    const { error } = await supabase.from("device_tokens").upsert({
      user_id: userId,
      fcm_token: fcmToken,
      device_type: deviceType,
      device_id: deviceId,
      app_version: appVersion || "1.0.0",
      is_active: true,
      last_seen_at: new Date().toISOString(),
    }, { onConflict: "user_id, device_id" });

    if (error) throw error;
  }
}
