-- ============================================================================
-- ACTIVIDAD 3: CONTROL DE ACCESO Y ROLES DE SEGURIDAD

-- 1. Limpieza por si acaso
DROP OWNED BY administrador CASCADE;
DROP OWNED BY recepcionista CASCADE;
DROP OWNED BY medico CASCADE;

DROP ROLE IF EXISTS administrador;
DROP ROLE IF EXISTS recepcionista;
DROP ROLE IF EXISTS medico;

-- Cuentas de prueba individuales
DROP ROLE IF EXISTS admin_user;
DROP ROLE IF EXISTS recep_user;
DROP ROLE IF EXISTS medico_carlos;

-- 2. Creación de Roles Principales
CREATE ROLE administrador WITH LOGIN PASSWORD 'AdminPass123!';
CREATE ROLE recepcionista WITH LOGIN PASSWORD 'RecepPass123!';
CREATE ROLE medico WITH LOGIN PASSWORD 'MedicoPass123!';

-- Cuentas específicas de prueba
CREATE ROLE admin_user WITH LOGIN PASSWORD 'admin123' IN ROLE administrador;
CREATE ROLE recep_user WITH LOGIN PASSWORD 'recep123' IN ROLE recepcionista;
CREATE ROLE medico_carlos WITH LOGIN PASSWORD 'medico123' IN ROLE medico;

-- 3. Permisos para ADMINISTRADOR (Mínimo privilegio / Acceso total al esquema)
GRANT USAGE ON SCHEMA public TO administrador;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO administrador;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO administrador;

-- 4. Permisos para RECEPCIONISTA
GRANT USAGE ON SCHEMA public TO recepcionista;

-- Citar permiso sobre tablas base
GRANT INSERT, UPDATE ON TABLE cita TO recepcionista;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO recepcionista;

-- Permiso de lectura sobre la vista de recepción (se habilitará tras crear la vista en Actividad 4)
-- GRANT SELECT ON vista_recepcion TO recepcionista;

-- DENEGAR acceso directo a la tabla paciente (se verifica en ensayo denegado 4)
REVOKE ALL ON TABLE paciente FROM recepcionista;


-- 5. Permisos para MÉDICO y Restricción por Cuenta (Row Level Security - RLS)
GRANT USAGE ON SCHEMA public TO medico;
GRANT SELECT ON TABLE cita TO medico;
GRANT SELECT ON TABLE paciente TO medico;
GRANT SELECT ON TABLE horario TO medico;

-- Impedir que el médico modifique sus citas (cumple ensayo denegado 5)
REVOKE INSERT, UPDATE, DELETE ON TABLE cita FROM medico;

-- Habilitar Row Level Security (RLS) en la tabla Cita para filtrar por Médico automáticamente
ALTER TABLE cita ENABLE ROW LEVEL SECURITY;

-- Política de RLS: Un médico solo ve sus citas comparando su usuario_db con CURRENT_USER
CREATE POLICY politica_medico_citas ON cita
    FOR SELECT
    TO medico
    USING (
        medico_id = (SELECT id FROM medico WHERE usuario_db = CURRENT_USER)
        OR CURRENT_USER = 'admin_user'
        OR CURRENT_USER = 'recep_user'
    );