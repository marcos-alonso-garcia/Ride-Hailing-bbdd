-- Plan simple de backup y recuperación para ride_hailing.
-- Este archivo documenta los comandos principales. Se ejecutan desde terminal.

-- Objetivo de recuperación:
-- RPO: 24 horas en el caso básico, porque se plantea un backup diario.
-- RTO: 2 horas, porque la restauración se puede hacer con el fichero .sql y Docker.

-- 1. Comprobar que el binlog está activo para poder explicar PITR.
SHOW VARIABLES LIKE 'log_bin';
SHOW VARIABLES LIKE 'binlog_format';
SHOW VARIABLES LIKE 'binlog_expire_logs_seconds';
SHOW BINARY LOGS;

-- 2. Backup lógico diario con mysqldump.
-- Comando desde la carpeta del proyecto:
-- docker exec ridehailing-mysql mysqldump \
--   -ubackup_user -pbackup_pass \
--   --databases ride_hailing \
--   --single-transaction \
--   --routines --triggers --events \
--   --set-gtid-purged=OFF \
--   > backup_ride_hailing.sql

-- 3. Restauración del backup.
-- docker exec -i ridehailing-mysql mysql -uroot -prootpass < backup_ride_hailing.sql

-- 4. Verificación posterior a la restauración.
USE ride_hailing;

SELECT 'company' AS tabla, COUNT(*) AS filas FROM company
UNION ALL SELECT 'usuario', COUNT(*) FROM usuario
UNION ALL SELECT 'rider', COUNT(*) FROM rider
UNION ALL SELECT 'conductor', COUNT(*) FROM conductor
UNION ALL SELECT 'vehiculo', COUNT(*) FROM vehiculo
UNION ALL SELECT 'viaje', COUNT(*) FROM viaje
UNION ALL SELECT 'oferta', COUNT(*) FROM oferta
UNION ALL SELECT 'pago', COUNT(*) FROM pago;

-- 5. Recuperación punto en el tiempo, ejemplo teórico.
-- Si hay un DELETE accidental a las 10:30, se restaura el backup y se aplican binlogs hasta las 10:29:59:
-- docker exec ridehailing-mysql mysqlbinlog \
--   --start-datetime="2026-04-20 00:00:00" \
--   --stop-datetime="2026-04-20 10:29:59" \
--   /var/lib/mysql/mysql-bin.000001 > cambios.sql
-- docker exec -i ridehailing-mysql mysql -uroot -prootpass < cambios.sql
