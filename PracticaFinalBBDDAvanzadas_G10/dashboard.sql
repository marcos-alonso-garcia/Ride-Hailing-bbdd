USE ride_hailing;

-- ==========================================================
-- DASHBOARD DE NEGOCIO
-- ==========================================================

-- Reparto actual de viajes por estado.
SELECT estado, COUNT(*) AS total_viajes
FROM viaje
GROUP BY estado
ORDER BY total_viajes DESC;

-- Viajes solicitados por hora.
-- Esto nos viene bien para detectar picos de demanda.
SELECT DATE(fecha_solicitud) AS dia,
       HOUR(fecha_solicitud) AS hora,
       COUNT(*) AS viajes_solicitados
FROM viaje
GROUP BY DATE(fecha_solicitud), HOUR(fecha_solicitud)
ORDER BY dia, hora;

-- Ofertas aceptadas por hora.
-- Así vemos en qué momento se están cerrando más asignaciones.
SELECT DATE(fecha_decision) AS dia,
       HOUR(fecha_decision) AS hora,
       COUNT(*) AS ofertas_aceptadas
FROM oferta
WHERE estado = 'aceptada'
  AND fecha_decision IS NOT NULL
GROUP BY DATE(fecha_decision), HOUR(fecha_decision)
ORDER BY dia, hora;

-- Reparto de ofertas por estado.
SELECT estado, COUNT(*) AS total_ofertas
FROM oferta
GROUP BY estado
ORDER BY total_ofertas DESC;

-- Tasa de aceptación por conductor.
-- La lógica está en la vista para no repetir la agregación cada vez.
SELECT *
FROM v_tasa_aceptacion_conductor
ORDER BY tasa_aceptacion DESC;

-- Tasa de aceptación por company.
SELECT *
FROM v_tasa_aceptacion_company
ORDER BY tasa_aceptacion DESC;

-- Tiempo medio y km medios de viajes finalizados.
-- Filtramos viajes cerrados para no mezclar casos todavía abiertos.
SELECT
  ROUND(AVG(TIMESTAMPDIFF(MINUTE, fecha_inicio, fecha_fin)), 2) AS minutos_medios,
  ROUND(AVG(km), 2) AS km_medios
FROM viaje
WHERE estado = 'finalizado'
  AND fecha_inicio IS NOT NULL
  AND fecha_fin IS NOT NULL
  AND km IS NOT NULL;

-- Ingresos por conductor.
-- La vista ya incluye euros/km y euros/minuto, que son métricas pedidas en el enunciado.
SELECT *
FROM v_ingresos_conductor
ORDER BY ingresos DESC;

-- Ingresos por company.
SELECT *
FROM v_ingresos_company
ORDER BY ingresos DESC;

-- Vista operativa de viajes con nombres y matrícula.
-- Nos sirve tanto para demo como para revisión rápida del sistema.
SELECT *
FROM v_viajes_detalle
ORDER BY fecha_solicitud DESC;

-- ==========================================================
-- DASHBOARD DE BASE DE DATOS / MONITORIZACIÓN
-- ==========================================================

-- Conexiones activas ahora mismo.
SHOW STATUS LIKE 'Threads_connected';

-- Pico histórico de conexiones utilizadas.
SHOW STATUS LIKE 'Max_used_connections';

-- Límite configurado de conexiones.
SHOW VARIABLES LIKE 'max_connections';

-- Consultas lentas registradas.
SHOW STATUS LIKE 'Slow_queries';

-- Tamaño de tablas e índices.
-- Esto ayuda a vigilar crecimiento sin revisar tabla por tabla a mano.
SELECT
  table_name,
  ROUND(data_length / 1024 / 1024, 2) AS datos_mb,
  ROUND(index_length / 1024 / 1024, 2) AS indices_mb
FROM information_schema.tables
WHERE table_schema = 'ride_hailing'
ORDER BY datos_mb + indices_mb DESC;

-- Resumen de índices creados.
-- Nos viene bien para revisar rápido qué joins y filtros están optimizados.
SELECT
  table_name,
  index_name,
  column_name,
  seq_in_index,
  non_unique
FROM information_schema.statistics
WHERE table_schema = 'ride_hailing'
ORDER BY table_name, index_name, seq_in_index;