-- AUDITORIA paso 3: el administrador elimina la cita de prueba y revisa el historial
-- Cuenta: admin_user
SELECT current_user, session_user;

DELETE FROM cita
WHERE horario_id = (SELECT id FROM horario WHERE medico_id = 3 AND fecha_hora = '2026-06-06 08:00:00')
RETURNING id;

SELECT id, operacion, fecha_hora, usuario_bd, cita_id,
       datos_anteriores ->> 'estado' AS estado_antes,
       datos_nuevos ->> 'estado'     AS estado_despues
FROM auditoria_cita
ORDER BY id;
