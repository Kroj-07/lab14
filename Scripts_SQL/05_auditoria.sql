-- ============================================================================
-- ACTIVIDAD 5: AUDITORIA DE LA TABLA CITA
-- Se ejecuta despues de 01 a 04, conectado como postgres.

-- Limpieza para poder volver a correr el script
DROP TRIGGER IF EXISTS trg_auditoria_cita ON cita;
DROP FUNCTION IF EXISTS fn_auditoria_cita();
DROP TABLE IF EXISTS auditoria_cita;

-- 1. Tabla del historial
-- cita_id no tiene FK a propósito: si borran la cita el registro igual debe quedar
CREATE TABLE auditoria_cita (
    id               SERIAL PRIMARY KEY,
    operacion        VARCHAR(10) NOT NULL
        CHECK (operacion IN ('INSERT', 'UPDATE', 'DELETE')),
    fecha_hora       TIMESTAMPTZ NOT NULL DEFAULT now(),
    usuario_bd       VARCHAR(63) NOT NULL,
    cita_id          INT NOT NULL,
    datos_anteriores JSONB,   -- fila antes del cambio (NULL en INSERT)
    datos_nuevos     JSONB    -- fila despues del cambio (NULL en DELETE)
);

-- 2. Funcion del trigger
-- SECURITY DEFINER: corre con los permisos del dueño, asi la recepcionista
-- no necesita permiso de escritura sobre la tabla de auditoria.
-- Ojo: dentro de esta funcion CURRENT_USER devuelve al dueño (postgres),
-- por eso se guarda SESSION_USER, que es la cuenta que inicio sesion.
CREATE OR REPLACE FUNCTION fn_auditoria_cita()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
    INSERT INTO auditoria_cita (operacion, usuario_bd, cita_id, datos_anteriores, datos_nuevos)
    VALUES (TG_OP, SESSION_USER, COALESCE(NEW.id, OLD.id), to_jsonb(OLD), to_jsonb(NEW));
    RETURN NULL;  -- en un trigger AFTER el valor de retorno no se usa
END;
$$;

-- nadie debe poder llamar la funcion por su cuenta
REVOKE EXECUTE ON FUNCTION fn_auditoria_cita() FROM PUBLIC;

-- 3. Trigger sobre cita
CREATE TRIGGER trg_auditoria_cita
AFTER INSERT OR UPDATE OR DELETE ON cita
FOR EACH ROW
EXECUTE FUNCTION fn_auditoria_cita();

-- 4. Permisos: solo el administrador puede leer el historial
REVOKE ALL ON TABLE auditoria_cita FROM PUBLIC;
REVOKE ALL ON SEQUENCE auditoria_cita_id_seq FROM PUBLIC;
GRANT SELECT ON TABLE auditoria_cita TO administrador;
