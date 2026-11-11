-- ENSAYO 3 (permitido): el medico consulta su programacion
-- Cuenta: medico_carlos (Dr. Carlos Mendoza, medico.id = 1)
-- Esperado: solo sus 4 citas, aunque la consulta no filtra por medico
SELECT current_user, session_user;
SELECT id, paciente_id, medico_id, horario_id, estado FROM cita;
SELECT count(*) AS citas_visibles, count(DISTINCT medico_id) AS medicos_distintos FROM cita;
SELECT * FROM vista_agenda_medico ORDER BY fecha_hora;
