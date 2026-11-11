-- Conteo de filas por tabla (se corre igual en citas_medicas y en citas_restaurada)
SELECT current_database() AS base, 'especialidad' AS tabla, count(*) AS filas FROM especialidad
UNION ALL SELECT current_database(), 'medico',         count(*) FROM medico
UNION ALL SELECT current_database(), 'paciente',       count(*) FROM paciente
UNION ALL SELECT current_database(), 'horario',        count(*) FROM horario
UNION ALL SELECT current_database(), 'cita',           count(*) FROM cita
UNION ALL SELECT current_database(), 'auditoria_cita', count(*) FROM auditoria_cita;
