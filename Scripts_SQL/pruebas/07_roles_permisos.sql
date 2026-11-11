-- Roles, membresias, permisos y politicas despues de 03 (como postgres)
SELECT r.rolname, r.rolcanlogin,
       COALESCE(string_agg(g.rolname, ', '), '') AS miembro_de
FROM pg_roles r
LEFT JOIN pg_auth_members m ON m.member = r.oid
LEFT JOIN pg_roles g ON g.oid = m.roleid
WHERE r.rolname IN ('administrador', 'recepcionista', 'medico',
                    'admin_user', 'recep_user', 'medico_carlos')
GROUP BY r.rolname, r.rolcanlogin
ORDER BY r.rolcanlogin, r.rolname;

-- permisos sobre tablas y vistas
SELECT table_name AS objeto, grantee AS rol,
       string_agg(privilege_type, ', ' ORDER BY privilege_type) AS permisos
FROM information_schema.table_privileges
WHERE grantee IN ('administrador', 'recepcionista', 'medico')
GROUP BY table_name, grantee
ORDER BY grantee, table_name;

-- permisos dados solo sobre algunas columnas
SELECT c.relname AS tabla, a.attname AS columna, a.attacl AS permisos
FROM pg_attribute a
JOIN pg_class c ON c.oid = a.attrelid
WHERE a.attacl IS NOT NULL AND c.relnamespace = 'public'::regnamespace
ORDER BY 1, 2;

-- politicas RLS sobre cita
SELECT policyname, cmd, roles, qual, with_check
FROM pg_policies WHERE tablename = 'cita' ORDER BY policyname;
