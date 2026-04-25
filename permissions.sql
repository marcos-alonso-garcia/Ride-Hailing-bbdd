-- Crear el usuario para gestionar el backend
CREATE USER 'gestor_backend'@'%' IDENTIFIED BY 'backend_contraseña';

-- Conceder permisos DML operativos y ejecución de rutinas (Procedimientos almacenados)
GRANT SELECT, INSERT, UPDATE, DELETE, EXECUTE ON ride_hailing.* TO 'gestor_backend'@'%';

-- Crear el usuario para gestionar el dashboard
CREATE USER 'analista'@'%' IDENTIFIED BY 'analista_contraseña';

-- Conceder permisos de lectura y capacidad de inspeccionar vistas para herramientas de BI
GRANT SELECT, SHOW VIEW ON ride_hailing.* TO 'analista'@'%';

-- Aplicar cambios
FLUSH PRIVILEGES;