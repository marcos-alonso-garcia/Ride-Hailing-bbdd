-- ==========================================================
-- PLAN DE BACKUP Y RECUPERACIÓN
-- ==========================================================

-- Este archivo documenta la estrategia de backup/restore de la BD ride_hailing.
-- La práctica usa un backup lógico con mysqldump por ser portable, sencillo
-- de probar y suficiente para el volumen de datos del proyecto.

-- ==========================================================
-- 1. BACKUP LÓGICO COMPLETO
-- ==========================================================

-- Ejecutar desde terminal (PowerShell/cmd/bash), no dentro del cliente MySQL:
--
-- docker exec ridehailing-mysql mysqldump ^
--   -uroot -prootpass ^
--   --databases ride_hailing ^
--   --single-transaction ^
--   --routines ^
--   --triggers ^
--   --set-gtid-purged=OFF ^
--   > backup_ride_hailing.sql
--
-- Explicación:
-- --single-transaction : snapshot consistente sin bloquear tablas InnoDB
-- --routines           : incluye procedimientos almacenados
-- --triggers           : incluye triggers
-- --set-gtid-purged=OFF: evita problemas si no se usa replicación GTID

-- ==========================================================
-- 2. RESTORE DEL BACKUP
-- ==========================================================

-- Ejecutar desde terminal:
--
-- Get-Content .\backup_ride_hailing.sql | docker exec -i ridehailing-mysql mysql -uroot -prootpass
--
-- Alternativa en cmd:
--
-- docker exec -i ridehailing-mysql mysql -uroot -prootpass < backup_ride_hailing.sql

-- ==========================================================
-- 3. VERIFICACIÓN POST-RESTORE
-- ==========================================================

-- Comprobaciones dentro de MySQL:
USE ride_hailing;

SHOW TABLES;
SHOW FULL TABLES WHERE Table_type = 'VIEW';
SHOW PROCEDURE STATUS WHERE Db = 'ride_hailing';
SHOW TRIGGERS FROM ride_hailing;

SELECT COUNT(*) AS total_usuarios FROM usuario;
SELECT COUNT(*) AS total_viajes FROM viaje;
SELECT COUNT(*) AS total_ofertas FROM oferta;
SELECT COUNT(*) AS total_pagos FROM pago;

-- ==========================================================
-- 4. JUSTIFICACIÓN DE LA ESTRATEGIA
-- ==========================================================

-- RPO propuesto:
--   Bajo para el contexto de la práctica. Se acepta perder como máximo
--   los cambios desde el último backup manual o programado.
--
-- RTO propuesto:
--   Bajo/medio. La recuperación consiste en recrear el contenedor si hace falta
--   y restaurar el fichero SQL completo.
--
-- Motivo de elección:
--   El backup lógico con mysqldump es suficiente para el tamaño del proyecto,
--   fácil de probar, portable entre entornos y compatible con Docker.

-- ==========================================================
-- 5. MEJORA FUTURA
-- ==========================================================

-- Como mejora, podría activarse binlog y combinar backup completo + binlogs
-- para recuperación punto en el tiempo (PITR), pero no es imprescindible
-- para esta práctica.