-- AUDITORIA paso 1: el administrador crea un horario libre
-- Cuenta: admin_user
SELECT current_user, session_user;
INSERT INTO horario (medico_id, fecha_hora) VALUES (3, '2026-06-06 08:00:00')
RETURNING id, medico_id, fecha_hora;
