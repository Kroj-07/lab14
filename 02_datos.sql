--  Especialidades (3)
INSERT INTO especialidad (nombre) VALUES 
('Cardiología'), 
('Pediatría'), 
('Dermatología');

-- Médicos (5)
INSERT INTO medico (nombre, dni, especialidad_id, usuario_db) VALUES 
('Dr. Carlos Mendoza', '11111111', 1, 'medico_carlos'),
('Dra. Ana Torres',    '22222222', 1, 'medico_ana'),
('Dr. Luis Gomez',     '33333333', 2, 'medico_luis'),
('Dra. Sofia Castro',  '44444444', 2, 'medico_sofia'),
('Dr. Jorge Vargas',   '55555555', 3, 'medico_jorge');

-- Pacientes (10)
INSERT INTO paciente (nombre, dni, telefono, email) VALUES 
('Juan Perez',       '70000001', '999111001', 'juan.perez@email.com'),
('Maria Lopez',      '70000002', '999111002', 'maria.lopez@email.com'),
('Pedro Ramirez',    '70000003', '999111003', 'pedro.ramirez@email.com'),
('Lucia Fernandez',  '70000004', '999111004', 'lucia.f@email.com'),
('Diego Sanchez',    '70000005', '999111005', 'diego.s@email.com'),
('Elena Torres',     '70000006', '999111006', 'elena.t@email.com'),
('Gabriel Morales',  '70000007', '999111007', 'gabriel.m@email.com'),
('Carmen Ruiz',      '70000008', '999111008', 'carmen.r@email.com'),
('Rosa Flores',      '70000009', '999111009', 'rosa.f@email.com'),
('Javier Benitez',   '70000010', '999111010', 'javier.b@email.com');

-- Insertar Horarios (20 horarios para alimentar las 20 citas)
INSERT INTO horario (medico_id, fecha_hora) VALUES 
(1, '2026-06-01 08:00:00'), (1, '2026-06-01 09:00:00'), (1, '2026-06-01 10:00:00'), (1, '2026-06-01 11:00:00'),
(2, '2026-06-01 08:00:00'), (2, '2026-06-01 09:00:00'), (2, '2026-06-01 10:00:00'), (2, '2026-06-01 11:00:00'),
(3, '2026-06-02 08:00:00'), (3, '2026-06-02 09:00:00'), (3, '2026-06-02 10:00:00'), (3, '2026-06-02 11:00:00'),
(4, '2026-06-02 08:00:00'), (4, '2026-06-02 09:00:00'), (4, '2026-06-02 10:00:00'), (4, '2026-06-02 11:00:00'),
(5, '2026-06-03 08:00:00'), (5, '2026-06-03 09:00:00'), (5, '2026-06-03 10:00:00'), (5, '2026-06-03 11:00:00');

-- Citas (20)
INSERT INTO cita (paciente_id, medico_id, horario_id, estado) VALUES 
(1, 1, 1, 'agendada'),  (2, 1, 2, 'agendada'),  (3, 1, 3, 'agendada'),  (4, 1, 4, 'agendada'),
(5, 2, 5, 'agendada'),  (6, 2, 6, 'agendada'),  (7, 2, 7, 'agendada'),  (8, 2, 8, 'agendada'),
(9, 3, 9, 'agendada'),  (10, 3, 10, 'agendada'), (1, 3, 11, 'agendada'), (2, 3, 12, 'agendada'),
(3, 4, 13, 'agendada'), (4, 4, 14, 'agendada'), (5, 4, 15, 'agendada'), (6, 4, 16, 'agendada'),
(7, 5, 17, 'agendada'), (8, 5, 18, 'agendada'), (9, 5, 19, 'agendada'), (10, 5, 20, 'agendada');



-- ============================================================================

-- Consulta JOIN 1: Reporte completo de Citas con Paciente, Médico y Fecha/Hora
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

-- Consulta JOIN 2: Cantidad de Citas programadas por Especialidad
SELECT 
    e.nombre AS especialidad,
    COUNT(c.id) AS total_citas
FROM especialidad e
JOIN medico m ON m.especialidad_id = e.id
JOIN cita c ON c.medico_id = m.id
GROUP BY e.nombre;