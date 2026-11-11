-- AUDITORIA paso 2: recepcion registra una cita y repite el UPDATE del ensayo 2
-- Cuenta: recep_user
SELECT current_user, session_user;

-- INSERT en el horario libre
INSERT INTO cita (paciente_id, medico_id, horario_id)
SELECT 2, 3, id FROM horario WHERE medico_id = 3 AND fecha_hora = '2026-06-06 08:00:00'
RETURNING id;

-- mismo UPDATE del ensayo 2
UPDATE cita SET estado = 'completada' WHERE id = 1;
SELECT id_cita, paciente_nombre, estado FROM vista_recepcion WHERE id_cita = 1;
