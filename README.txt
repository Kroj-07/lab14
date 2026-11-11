LABORATORIO - SEGURIDAD DE UNA BASE DE DATOS DE CITAS MEDICAS
==============================================================

1. VERSION DE POSTGRESQL
------------------------
- PostgreSQL 18.4 (x86_64-windows). psql, pg_dump, pg_restore, createdb y dropdb 18.4.
- En Windows, si las herramientas no estan en el PATH, se usa la ruta completa:
    "C:\Program Files\PostgreSQL\18\bin\psql.exe"
- Todas las conexiones son locales: -h localhost. psql pide la contrasena de
  la cuenta al conectarse; ninguna contrasena esta escrita en estos archivos.
- Para ver bien las tildes en la consola de Windows, antes de psql:
    PowerShell:  $env:PGCLIENTENCODING = "UTF8"
    cmd:         chcp 65001

2. CONTENIDO
------------
  Informe_Seguridad_BD.pdf               Informe (diseno, decisiones, pruebas y resultados)
  diagrama_ER.png                        Diagrama entidad-relacion
  citas_medicas.backup                   Respaldo logico (pg_dump -Fc) de citas_medicas
  Scripts_SQL/01_esquema.sql             Tablas y restricciones
  Scripts_SQL/01b_integridad_horario.sql Regla adicional: la cita y su horario son del mismo medico
  Scripts_SQL/02_datos.sql               Datos ficticios y consultas JOIN 1 y 2
  Scripts_SQL/03_roles.sql               Roles, permisos y seguridad por filas (RLS)
  Scripts_SQL/04_vistas.sql              Vista de recepcion y enmascaramiento
  Scripts_SQL/05_auditoria.sql           Tabla de auditoria, funcion y trigger
  Scripts_SQL/pruebas/                   Scripts de los ensayos y verificaciones (seccion 6)
  evidencias/                            Salida real de la corrida final (archivos 00 a 21)

3. ORDEN DE EJECUCION (como postgres)
-------------------------------------
  createdb -h localhost -U postgres citas_medicas
  psql -h localhost -U postgres -d citas_medicas -f Scripts_SQL/01_esquema.sql
  psql -h localhost -U postgres -d citas_medicas -f Scripts_SQL/01b_integridad_horario.sql
  psql -h localhost -U postgres -d citas_medicas -f Scripts_SQL/02_datos.sql
  psql -h localhost -U postgres -d citas_medicas -f Scripts_SQL/03_roles.sql
  psql -h localhost -U postgres -d citas_medicas -f Scripts_SQL/04_vistas.sql
  psql -h localhost -U postgres -d citas_medicas -f Scripts_SQL/05_auditoria.sql

  IMPORTANTE: los roles son de todo el servidor. Antes de volver a ejecutar
  03_roles.sql hay que borrar citas_restaurada (si existe), porque contiene
  permisos de esos roles y DROP ROLE fallaria:
    dropdb -h localhost -U postgres --if-exists citas_restaurada

4. CUENTAS DE PRUEBA
--------------------
  Roles de grupo (NOLOGIN): administrador, recepcionista, medico
  Cuentas con inicio de sesion:
    admin_user     miembro de administrador
    recep_user     miembro de recepcionista
    medico_carlos  miembro de medico (Dr. Carlos Mendoza, medico.id = 1)

  03_roles.sql no asigna contrasenas. Cada integrante define contrasenas
  locales y desechables despues de ejecutar 03:
    psql -h localhost -U postgres -d citas_medicas
    \password admin_user
    \password recep_user
    \password medico_carlos

5. RESPALDO Y RESTAURACION
--------------------------
  Crear el respaldo:
    pg_dump -Fc -h localhost -U postgres -d citas_medicas -f citas_medicas.backup

  Restaurar en una base nueva y vacia:
    createdb -h localhost -U postgres citas_restaurada
    pg_restore -h localhost -U postgres -d citas_restaurada citas_medicas.backup

  Los roles NO viajan en el respaldo: pg_dump guarda una sola base y los roles
  pertenecen a todo el servidor. En otro servidor hay que crearlos antes
  (ejecutando 03_roles.sql en una base vacia o con pg_dumpall --roles-only),
  o bien restaurar sin duenos ni permisos:
    pg_restore -h localhost -U postgres --no-owner --no-privileges -d citas_restaurada citas_medicas.backup

6. COMO REPRODUCIR LAS EVIDENCIAS
---------------------------------
  Partiendo de una base nueva con 01 -> 01b -> 02 -> 03 -> 04 (seccion 3) y con las
  contrasenas definidas (seccion 4), ejecutar en este orden. -X ignora la
  configuracion personal de psql y -a muestra cada sentencia antes de su resultado.

  N.  Cuenta         Comando
  --  -------------  ---------------------------------------------------------------
  1   postgres       psql -X -a -h localhost -U postgres -d citas_medicas -f Scripts_SQL/pruebas/07_roles_permisos.sql
                     (roles, membresias, permisos por tabla y columna, politicas RLS)
  2   postgres       psql -X -a -h localhost -U postgres -d citas_medicas -f Scripts_SQL/pruebas/08_ssl.sql
                     (SHOW ssl, pg_stat_ssl y reglas de pg_hba.conf)
                     y el intento exigiendo TLS:
                     psql -X "host=localhost dbname=citas_medicas user=postgres sslmode=require" -c "SELECT 1;"
  3   recep_user     psql -X -a -h localhost -U recep_user -d citas_medicas -f Scripts_SQL/pruebas/09_ensayo1_recep_vista.sql
                     (ensayo 1, permitido)
  4   recep_user     psql -X -a -h localhost -U recep_user -d citas_medicas -f Scripts_SQL/pruebas/10_ensayo2_recep_update.sql
                     (ensayo 2, permitido)
  5   medico_carlos  psql -X -a -h localhost -U medico_carlos -d citas_medicas -f Scripts_SQL/pruebas/11_ensayo3_medico_agenda.sql
                     (ensayo 3, permitido: solo 4 citas del medico 1)
  6   recep_user     psql -X -a -h localhost -U recep_user -d citas_medicas -f Scripts_SQL/pruebas/12_ensayo4_recep_dni.sql
                     (ensayo 4, denegado: permiso denegado a la tabla paciente)
  7   medico_carlos  psql -X -a -h localhost -U medico_carlos -d citas_medicas -f Scripts_SQL/pruebas/13_ensayo5_medico_update.sql
                     (ensayo 5, denegado: permiso denegado a la tabla cita)
  8   postgres       psql -X -a -h localhost -U postgres -d citas_medicas -f Scripts_SQL/05_auditoria.sql
                     (instala la auditoria)
  9   admin_user     psql -X -a -h localhost -U admin_user -d citas_medicas -f Scripts_SQL/pruebas/15_auditoria_admin_horario.sql
                     (crea un horario libre)
  10  recep_user     psql -X -a -h localhost -U recep_user -d citas_medicas -f Scripts_SQL/pruebas/16_auditoria_recep_insert_update.sql
                     (INSERT de una cita y repeticion del UPDATE del ensayo 2)
  11  admin_user     psql -X -a -h localhost -U admin_user -d citas_medicas -f Scripts_SQL/pruebas/17_auditoria_admin_delete.sql
                     (DELETE de la cita de prueba y lectura de auditoria_cita)
  12  postgres       comandos de la seccion 5 (pg_dump, createdb, pg_restore)
  13  postgres       psql -X -a -h localhost -U postgres -d citas_medicas    -f Scripts_SQL/pruebas/20_conteos.sql
                     psql -X -a -h localhost -U postgres -d citas_restaurada -f Scripts_SQL/pruebas/20_conteos.sql
                     (conteo de filas por tabla en ambas bases)
  14  postgres       psql -X -a -h localhost -U postgres -d citas_medicas    -f Scripts_SQL/pruebas/21_join1.sql
                     psql -X -a -h localhost -U postgres -d citas_restaurada -f Scripts_SQL/pruebas/21_join1.sql
                     (consulta JOIN 1 en ambas bases; en Git Bash se pueden comparar con
                      diff <(psql -X -At -h localhost -U postgres -d citas_medicas -f Scripts_SQL/pruebas/21_join1.sql) \
                           <(psql -X -At -h localhost -U postgres -d citas_restaurada -f Scripts_SQL/pruebas/21_join1.sql))

  La salida obtenida en cada paso esta en evidencias/ (00 a 21). En esas salidas
  los scripts de prueba figuran como evidencias/sql/..., que equivale a
  Scripts_SQL/pruebas/... en esta entrega.

  Las consultas JOIN 1 y 2 y la demostracion de enmascaramiento se muestran al
  ejecutar 02_datos.sql y 04_vistas.sql (seccion 3).
