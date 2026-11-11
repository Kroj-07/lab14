-- Actividad 2: verificacion de SSL/TLS en el servidor y en la sesion actual
SHOW ssl;
SELECT ssl FROM pg_stat_ssl WHERE pid = pg_backend_pid();
-- detalle de la sesion (si no hay TLS, version y cipher salen vacios)
SELECT pid, ssl, version, cipher FROM pg_stat_ssl WHERE pid = pg_backend_pid();
SELECT inet_client_addr() AS ip_cliente, inet_server_addr() AS ip_servidor;
-- reglas de pg_hba.conf: host acepta con o sin TLS, hostssl solo con TLS
SELECT line_number, type, database, user_name, address, auth_method
FROM pg_hba_file_rules ORDER BY line_number;
