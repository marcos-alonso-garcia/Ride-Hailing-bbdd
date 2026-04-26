-- ==========================================================
-- SEGURIDAD Y CONTROL DE ACCESOS
-- ==========================================================

-- Usuario principal de la aplicación.
-- Puede operar sobre los datos del sistema, pero no tocar administración del servidor.
CREATE USER IF NOT EXISTS 'app_user'@'%' IDENTIFIED BY 'app_pass_123';
GRANT SELECT, INSERT, UPDATE, DELETE ON ride_hailing.* TO 'app_user'@'%';

-- Usuario de analítica / dashboard.
-- Solo lectura, porque su función es consultar métricas y reporting.
CREATE USER IF NOT EXISTS 'analytics_user'@'%' IDENTIFIED BY 'analytics_pass_123';
GRANT SELECT ON ride_hailing.* TO 'analytics_user'@'%';

-- Usuario de backup.
-- Le damos lo justo para sacar copias lógicas sin usar root.
CREATE USER IF NOT EXISTS 'backup_user'@'%' IDENTIFIED BY 'backup_pass_123';
GRANT SELECT, SHOW VIEW, TRIGGER, LOCK TABLES ON ride_hailing.* TO 'backup_user'@'%';

-- Usuario para monitorización con mysqld_exporter.
-- Sigue la idea de mínimos privilegios para no exponer más de la cuenta.
CREATE USER IF NOT EXISTS 'exporter'@'%' IDENTIFIED BY 'exporterpass';
GRANT PROCESS, REPLICATION CLIENT, SELECT ON *.* TO 'exporter'@'%';

FLUSH PRIVILEGES;