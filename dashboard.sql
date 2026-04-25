USE ride_hailing;

-- ==========================================================
-- DASHBOARD DE NEGOCIO
-- ==========================================================

-- Viajes por estado.
SELECT estado, COUNT(*) AS total_viajes
FROM viaje
GROUP BY estado
ORDER BY total_viajes DESC;

-- Viajes por hora.
-- Sirve para detectar picos de demanda por franja horaria.
SELECT DATE(fecha_solicitud) AS dia,
       HOUR(fecha_solicitud) AS hora,
       COUNT(*) AS viajes_solicitados
FROM viaje
GROUP BY DATE(fecha_solicitud), HOUR(fecha_solicitud)
ORDER BY dia, hora;

-- Ofertas por estado.
SELECT estado, COUNT(*) AS total_ofertas
FROM oferta
GROUP BY estado
ORDER BY total_ofertas DESC;

-- Tasa de aceptación por conductor.
-- La agregación vive en la vista; aquí solo se priorizan los mejores ratios.
SELECT *
FROM v_tasa_aceptacion_conductor
ORDER BY tasa_aceptacion DESC;

-- Tasa de aceptación por company.
SELECT *
FROM v_tasa_aceptacion_company
ORDER BY tasa_aceptacion DESC;

-- Tiempo medio y kilometraje medio de viajes finalizados.
-- Se filtran viajes cerrados para no mezclar trayectos todavía abiertos.
SELECT
  ROUND(AVG(TIMESTAMPDIFF(MINUTE, fecha_inicio, fecha_fin)), 2) AS minutos_medios,
  ROUND(AVG(km), 2) AS km_medios
FROM viaje
WHERE estado = 'finalizado';

-- Ingresos por conductor.
SELECT *
FROM v_ingresos_conductor
ORDER BY ingresos DESC;

-- Ingresos por company.
SELECT *
FROM v_ingresos_company
ORDER BY ingresos DESC;

-- ==========================================================
-- DASHBOARD DE BASE DE DATOS / MONITORIZACIÓN
-- ==========================================================

-- Conexiones actuales.
SHOW STATUS LIKE 'Threads_connected';

-- Máximo de conexiones usadas.
SHOW STATUS LIKE 'Max_used_connections';

-- Límite de conexiones configurado.
SHOW VARIABLES LIKE 'max_connections';

-- Consultas lentas registradas.
SHOW STATUS LIKE 'Slow_queries';

-- Tamaño de tablas e índices en MB.
-- `information_schema.tables` permite vigilar crecimiento sin consultar tabla por tabla.
SELECT
  table_name,
  ROUND(data_length / 1024 / 1024, 2) AS datos_mb,
  ROUND(index_length / 1024 / 1024, 2) AS indices_mb
FROM information_schema.tables
WHERE table_schema = 'ride_hailing'
ORDER BY datos_mb + indices_mb DESC;

-- Índices creados en el esquema.
-- Ayuda a revisar rápidamente qué columnas están optimizadas para joins o filtros.
SELECT
  table_name,
  index_name,
  column_name,
  seq_in_index,
  non_unique
FROM information_schema.statistics
WHERE table_schema = 'ride_hailing'
ORDER BY table_name, index_name, seq_in_index;
