-- ENSAYO 5 (denegado): el medico intenta modificar una de sus citas
-- Cuenta: medico_carlos. Esperado: error de permisos
SELECT current_user, session_user;
UPDATE cita SET estado = 'cancelada' WHERE id = 2;
