-- =============================================================================
-- FINCOLLECT ENTERPRISE PLATFORM - SUPER ADMIN ROLE ASSIGNMENT
-- =============================================================================
-- Create the account through Supabase Auth (Dashboard or Admin API) first.
-- Credentials and direct writes to auth.users must never be committed to SQL.

DO $$
DECLARE
    target_email TEXT := 'singh2212karanveer@gmail.com';
    target_user_id UUID;
    super_admin_role_id UUID := '10000000-0000-0000-0000-000000000001';
BEGIN
    INSERT INTO public.roles (id, name, code, description)
    VALUES (
        super_admin_role_id,
        'Super Admin',
        'SUPER_ADMIN',
        'System wide full access and tenant control'
    )
    ON CONFLICT (code) DO NOTHING;

    SELECT id INTO target_user_id
    FROM auth.users
    WHERE email = target_email
    LIMIT 1;

    IF target_user_id IS NULL THEN
        RAISE NOTICE 'No Auth user exists for %; assign SUPER_ADMIN after creating the account.', target_email;
        RETURN;
    END IF;

    UPDATE public.users
    SET role_id = super_admin_role_id, status = 'ACTIVE', updated_at = CURRENT_TIMESTAMP
    WHERE id = target_user_id;
END $$;
