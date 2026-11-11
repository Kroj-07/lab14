DROP TABLE IF EXISTS cita CASCADE;
DROP TABLE IF EXISTS horario CASCADE;
DROP TABLE IF EXISTS medico CASCADE;
DROP TABLE IF EXISTS especialidad CASCADE;
DROP TABLE IF EXISTS paciente CASCADE;

CREATE TABLE especialidad (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE medico (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(150) NOT NULL,
    dni VARCHAR(15) UNIQUE NOT NULL,
    especialidad_id INT NOT NULL
		REFERENCES especialidad(id) ON DELETE RESTRICT,
    usuario_db VARCHAR(50) UNIQUE -- Permite vincular el usuario PostgreSQL con el médico
);

CREATE TABLE paciente (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(150) NOT NULL,
    dni VARCHAR(15) UNIQUE NOT NULL,
    telefono VARCHAR(20),
    email VARCHAR(100)
);

CREATE TABLE horario (
    id SERIAL PRIMARY KEY,
    medico_id INT NOT NULL 
		REFERENCES medico(id) ON DELETE CASCADE,
    fecha_hora TIMESTAMP NOT NULL,
    CONSTRAINT uq_medico_horario UNIQUE (medico_id, fecha_hora) 
);

CREATE TABLE cita (
    id SERIAL PRIMARY KEY,
    paciente_id INT NOT NULL
		REFERENCES paciente(id) ON DELETE RESTRICT,
    medico_id INT NOT NULL
		REFERENCES medico(id) ON DELETE RESTRICT,
    horario_id INT NOT NULL UNIQUE
		REFERENCES horario(id) ON DELETE RESTRICT, 
    estado VARCHAR(20) DEFAULT 'agendada' CHECK (estado IN ('agendada', 'completada', 'cancelada'))
);