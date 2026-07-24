-- =============================================================================
-- FINCOLLECT ENTERPRISE PLATFORM - SUPER ADMIN USER PROVISIONING
-- User: singh2212karanveer@gmail.com
-- Password: Aujla@1210
-- Role: SUPER_ADMIN
-- =============================================================================

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

DO $$
DECLARE
    new_user_id UUID := 'a1000000-0000-0000-0000-000000000001';
    super_admin_role_id UUID := '10000000-0000-0000-0000-000000000001';
    user_email TEXT := 'singh2212karanveer@gmail.com';
    user_password TEXT := 'Aujla@1210';
BEGIN
    -- 1. Ensure Super Admin role exists
    INSERT INTO public.roles (id, name, code, description)
    VALUES (super_admin_role_id, 'Super Admin', 'SUPER_ADMIN', 'System wide full access and tenant control')
    ON CONFLICT (code) DO NOTHING;

    -- 2. Insert into auth.users (Supabase Authentication Table)
    INSERT INTO auth.users (
        id,
        instance_id,
        aud,
        role,
        email,
        encrypted_password,
        email_confirmed_at,
        raw_app_meta_data,
        raw_user_meta_data,
        created_at,
        updated_at
    ) VALUES (
        new_user_id,
        '00000000-0000-0000-0000-000000000000',
        'authenticated',
        'authenticated',
        user_email,
        crypt(user_password, gen_salt('bf')),
        NOW(),
        '{"provider":"email","providers":["email"]}',
        '{"full_name":"Karanveer Singh","role":"SUPER_ADMIN"}',
        NOW(),
        NOW()
    )
    ON CONFLICT (id) DO UPDATE SET 
        encrypted_password = crypt(user_password, gen_salt('bf')),
        email_confirmed_at = NOW();

    -- 3. Insert into auth.identities for email provider login
    INSERT INTO auth.identities (
        id,
        user_id,
        identity_data,
        provider,
        last_sign_in_at,
        created_at,
        updated_at
    ) VALUES (
        new_user_id,
        new_user_id,
        format('{"sub":"%s","email":"%s"}', new_user_id, user_email)::jsonb,
        'email',
        NOW(),
        NOW(),
        NOW()
    )
    ON CONFLICT (provider, id) DO NOTHING;

    -- 4. Insert/Upsert into public.users with Super Admin Role
    INSERT INTO public.users (
        id,
        employee_code,
        full_name,
        email,
        phone,
        role_id,
        status
    ) VALUES (
        new_user_id,
        'ADMIN-001',
        'Karanveer Singh',
        user_email,
        '9999999999',
        super_admin_role_id,
        'ACTIVE'
    )
    ON CONFLICT (email) DO UPDATE SET 
        role_id = super_admin_role_id,
        status = 'ACTIVE';

    RAISE NOTICE 'Super Admin user % created/updated successfully with email %', new_user_id, user_email;
END $$;
