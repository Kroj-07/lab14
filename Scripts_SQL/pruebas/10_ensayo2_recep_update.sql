-- ENSAYO 2 (permitido): recepcion modifica una cita y verifica el cambio
-- Cuenta: recep_user
SELECT current_user, session_user;
SELECT id_cita, paciente_nombre, medico_nombre, estado FROM vista_recepcion WHERE id_cita = 1;
UPDATE cita SET estado = 'completada' WHERE id = 1;
SELECT id_cita, paciente_nombre, medico_nombre, estado FROM vista_recepcion WHERE id_cita = 1;
