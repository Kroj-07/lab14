-- Consulta JOIN 1 de 02_datos.sql, repetida para comprobar la restauracion
SELECT 
    c.id AS id_cita,
    p.nombre AS paciente,
    m.nombre AS medico,
    e.nombre AS especialidad,
    h.fecha_hora,
    c.estado
FROM cita c
JOIN paciente p ON c.paciente_id = p.id
JOIN medico m ON c.medico_id = m.id
JOIN especialidad e ON m.especialidad_id = e.id
JOIN horario h ON c.horario_id = h.id
ORDER BY h.fecha_hora;
