-- ============================================================================
-- 01b: REGLA ADICIONAL DE INTEGRIDAD (se ejecuta despues de 01 y antes de 02)
-- Regla: la cita y su horario tienen que ser del mismo medico.
-- Con solo la FK de horario_id se podia agendar una cita del medico 1
-- en un horario del medico 2.

-- la FK compuesta necesita una clave unica en (id, medico_id)
ALTER TABLE horario
    ADD CONSTRAINT uq_horario_id_medico UNIQUE (id, medico_id);

-- la pareja (horario_id, medico_id) de la cita tiene que existir en horario
ALTER TABLE cita
    ADD CONSTRAINT fk_cita_horario_medico
    FOREIGN KEY (horario_id, medico_id)
    REFERENCES horario (id, medico_id)
    ON DELETE RESTRICT;
