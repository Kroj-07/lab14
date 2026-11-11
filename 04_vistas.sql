-- ============================================================================
-- ACTIVIDAD 4: VISTAS Y PRIVACIDAD DE DATOS (ENMASCARAMIENTO)

CREATE OR REPLACE VIEW vista_recepcion AS
SELECT 
    c.id AS id_cita,
    p.nombre AS paciente_nombre,
    p.telefono AS paciente_telefono,
    m.nombre AS medico_nombre,
    e.nombre AS especialidad,
    h.fecha_hora,
    c.estado
FROM cita c
JOIN paciente p ON c.paciente_id = p.id
JOIN medico m ON c.medico_id = m.id
JOIN especialidad e ON m.especialidad_id = e.id
JOIN horario h ON c.horario_id = h.id;

GRANT SELECT ON vista_recepcion TO recepcionista;

-- Demostración SQL de Enmascaramiento / Seudonimización
SELECT 
    id,
    nombre,
    dni AS dni_original,
    CONCAT('****', SUBSTRING(dni FROM 5 FOR 4)) AS dni_enmascarado,
    email AS email_original,
    CONCAT(SUBSTRING(email FROM 1 FOR 2), '***@', SPLIT_PART(email, '@', 2)) AS email_enmascarado
FROM paciente;