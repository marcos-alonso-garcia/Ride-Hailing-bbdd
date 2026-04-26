-- ==========================================================
-- PLAN DE BACKUP Y RECUPERACIÓN
-- ==========================================================

-- Este archivo no crea tablas ni datos: lo usamos para documentar
-- cómo haríamos la copia y la restauración del sistema.

-- ==========================================================
-- 1. BACKUP LÓGICO COMPLETO
-- ==========================================================

-- Lo hacemos con mysqldump porque para esta práctica es suficiente,
-- fácil de probar y además nos deja un fichero portable.
--
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
-- Detalles importantes:
-- --single-transaction  -> saca un snapshot consistente sin bloquear InnoDB
-- --routines            -> incluye procedimientos almacenados
-- --triggers            -> incluye triggers
-- --set-gtid-purged=OFF -> evita problemas si no estamos usando GTID

-- ==========================================================
-- 2. RESTORE DEL BACKUP
-- ==========================================================

-- En PowerShell:
--
-- Get-Content .\backup_ride_hailing.sql | docker exec -i ridehailing-mysql mysql -uroot -prootpass
--
-- En cmd:
--
-- docker exec -i ridehailing-mysql mysql -uroot -prootpass < backup_ride_hailing.sql

-- ==========================================================
-- 3. VERIFICACIÓN POST-RESTORE
-- ==========================================================

-- Después de restaurar, lo primero es comprobar que están los objetos
-- más importantes y que los conteos básicos cuadran.
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

-- RPO:
-- Para esta práctica aceptamos perder como mucho los cambios
-- desde la última copia manual o programada.
--
-- RTO:
-- La recuperación es bastante rápida porque consiste en levantar
-- el contenedor y cargar el fichero SQL completo.
--
-- Motivo de elección:
-- Nos parecía la opción más razonable para un proyecto universitario:
-- simple, portable y suficiente para el tamaño del sistema.