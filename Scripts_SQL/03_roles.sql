-- ============================================================================
-- ACTIVIDAD 3: CONTROL DE ACCESO Y ROLES
-- Se ejecuta como postgres despues de 01, 01b y 02, en la base citas_medicas.
-- Las contraseñas NO van en el script: se ponen a mano con \password (ver al final).
--
-- Ojo al re-ejecutar: los roles son de todo el servidor. Si existe otra base
-- con permisos para estos roles (por ejemplo citas_restaurada), DROP ROLE falla.
-- En ese caso primero: dropdb citas_restaurada  (o correr el bloque DO alla tambien).

-- 1. Limpieza: DROP OWNED solo si el rol existe (antes daba error)
DROP POLICY IF EXISTS politica_medico_citas ON cita;
DROP POLICY IF EXISTS medico_ve_sus_citas   ON cita;
DROP POLICY IF EXISTS recep_select_cita     ON cita;
DROP POLICY IF EXISTS recep_insert_cita     ON cita;
DROP POLICY IF EXISTS recep_update_cita     ON cita;
DROP POLICY IF EXISTS admin_todo_cita       ON cita;
DROP VIEW IF EXISTS vista_agenda_medico;

DO $$
DECLARE
    r TEXT;
BEGIN
    FOREACH r IN ARRAY ARRAY['admin_user', 'recep_user', 'medico_carlos',
                             'administrador', 'recepcionista', 'medico']
    LOOP
        IF EXISTS (SELECT 1 FROM pg_roles WHERE rolname = r) THEN
            EXECUTE format('DROP OWNED BY %I CASCADE', r);
        END IF;
    END LOOP;
END
$$;

-- primero las cuentas y despues los grupos
DROP ROLE IF EXISTS admin_user;
DROP ROLE IF EXISTS recep_user;
DROP ROLE IF EXISTS medico_carlos;
DROP ROLE IF EXISTS administrador;
DROP ROLE IF EXISTS recepcionista;
DROP ROLE IF EXISTS medico;

-- 2. Roles de grupo: NOLOGIN, solo agrupan permisos
CREATE ROLE administrador NOLOGIN;
CREATE ROLE recepcionista NOLOGIN;
CREATE ROLE medico NOLOGIN;

-- Cuentas de prueba: LOGIN pero sin contraseña aqui
CREATE ROLE admin_user    LOGIN IN ROLE administrador;
CREATE ROLE recep_user    LOGIN IN ROLE recepcionista;
CREATE ROLE medico_carlos LOGIN IN ROLE medico;   -- coincide con medico.usuario_db del Dr. Carlos Mendoza

-- 3. ADMINISTRADOR: consultar, registrar, modificar y eliminar
GRANT USAGE ON SCHEMA public TO administrador;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO administrador;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO administrador;
-- para lo que se crea despues (vista_recepcion en 04, auditoria_cita en 05)
-- solo lectura; los permisos de escritura se dan a mano si hacen falta
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT ON TABLES TO administrador;

-- 4. RECEPCIONISTA: vista (se da en 04), insertar y modificar citas
GRANT USAGE ON SCHEMA public TO recepcionista;
GRANT INSERT, UPDATE ON TABLE cita TO recepcionista;
-- SELECT solo de id: lo necesita el WHERE id = X del UPDATE y el RETURNING id
GRANT SELECT (id) ON TABLE cita TO recepcionista;
-- para agendar tiene que ver los horarios (no tienen datos personales)
GRANT SELECT ON TABLE horario TO recepcionista;
-- solo la secuencia de cita, no todas
GRANT USAGE ON SEQUENCE cita_id_seq TO recepcionista;
-- sin permisos sobre paciente (el ensayo 4 debe dar error)
REVOKE ALL ON TABLE paciente FROM recepcionista;

-- 5. MEDICO: solo sus citas
GRANT USAGE ON SCHEMA public TO medico;
GRANT SELECT ON TABLE cita TO medico;
-- la politica tiene que buscar su id, por eso lee solo estas 2 columnas
GRANT SELECT (id, usuario_db) ON TABLE medico TO medico;
-- no se le da nada sobre paciente (tenia SELECT de toda la tabla, con dni)
REVOKE ALL ON TABLE paciente FROM medico;
REVOKE INSERT, UPDATE, DELETE ON TABLE cita FROM medico;

-- Vista de agenda para que el medico vea el nombre del paciente.
-- Como su dueño es postgres, la vista no pasa por el RLS de cita,
-- por eso el filtro por CURRENT_USER va dentro de la misma vista.
-- security_barrier evita que un filtro del usuario se evalue antes que el nuestro.
CREATE VIEW vista_agenda_medico WITH (security_barrier) AS
SELECT c.id        AS id_cita,
       h.fecha_hora,
       p.nombre    AS paciente,
       c.estado
FROM cita c
JOIN medico   m ON m.id = c.medico_id
JOIN horario  h ON h.id = c.horario_id
JOIN paciente p ON p.id = c.paciente_id
WHERE m.usuario_db = CURRENT_USER;

GRANT SELECT ON vista_agenda_medico TO medico;

-- 6. Row Level Security en cita
ALTER TABLE cita ENABLE ROW LEVEL SECURITY;

-- medico: solo filas de su propio id
CREATE POLICY medico_ve_sus_citas ON cita
    FOR SELECT TO medico
    USING (medico_id = (SELECT id FROM medico WHERE usuario_db = CURRENT_USER));

-- recepcionista: ve, registra y modifica citas (sin politica no veia ninguna fila)
CREATE POLICY recep_select_cita ON cita
    FOR SELECT TO recepcionista USING (true);
CREATE POLICY recep_insert_cita ON cita
    FOR INSERT TO recepcionista WITH CHECK (true);
CREATE POLICY recep_update_cita ON cita
    FOR UPDATE TO recepcionista USING (true) WITH CHECK (true);

-- administrador: todo
CREATE POLICY admin_todo_cita ON cita
    FOR ALL TO administrador USING (true) WITH CHECK (true);

-- 7. Contraseñas: se ponen a mano en psql, nunca en el script
--   \password admin_user
--   \password recep_user
--   \password medico_carlos
