USE ride_hailing;

-- ==========================================================
-- CONSULTAS DE OPERATIVA BÁSICA
-- ==========================================================

-- 1. Consultar viajes con datos de rider, conductor, company y vehículo.
SELECT *
FROM v_viajes_detalle
ORDER BY fecha_solicitud DESC;

-- 2. Crear un nuevo rider dentro de una transacción.
START TRANSACTION;

-- Primero se crea el usuario base y luego su fila especializada en `rider`.
INSERT INTO usuario (email, telefono, nombre, apellido)
VALUES ('nuevo.rider@email.com', '600000099', 'Nuevo', 'Rider');

INSERT INTO rider (id_usuario, viajes_totales, valoracion)
VALUES (LAST_INSERT_ID(), 0, 5.00);

COMMIT;

-- 3. Crear un viaje nuevo y enviar ofertas a dos conductores.
START TRANSACTION;

-- El viaje nace sin conductor; la relación se completa al aceptar una oferta.
INSERT INTO viaje (id_rider, origen_lat, origen_lon, destino_lat, destino_lon)
VALUES (1, 40.421000, -3.701000, 40.430000, -3.710000);

SET @nuevo_viaje = LAST_INSERT_ID();

INSERT INTO oferta (id_viaje, id_conductor, precio_ofertado)
VALUES
(@nuevo_viaje, 1, 8.50),
(@nuevo_viaje, 2, 8.90);

COMMIT;

-- 4. Aceptar una oferta usando el procedimiento principal.
-- Cambiar el id por una oferta pendiente existente.
CALL sp_aceptar_oferta(10);

-- 5. Ejemplo claro de lock por concurrencia.
-- Esta consulta bloquea el viaje seleccionado hasta COMMIT o ROLLBACK.
START TRANSACTION;

SELECT id_viaje, estado, id_conductor
FROM viaje
WHERE id_viaje = 3
FOR UPDATE;

-- Aquí se podría decidir cancelar o asignar el viaje.
ROLLBACK;

-- 6. Finalizar un viaje y registrar el pago dentro de una transacción.
START TRANSACTION;

-- El filtro evita cerrar por error viajes que todavía no han empezado.
UPDATE viaje
SET estado = 'finalizado',
    fecha_fin = NOW(),
    km = 7.30,
    precio = 13.20
WHERE id_viaje = 5
  AND estado = 'en_curso';

-- El pago se genera a partir del viaje ya actualizado para no duplicar datos manualmente.
INSERT INTO pago (id_viaje, id_conductor, importe, metodo, estado, fecha_pago)
SELECT id_viaje, id_conductor, precio, 'tarjeta', 'pagado', NOW()
FROM viaje
WHERE id_viaje = 5
  AND precio IS NOT NULL
  AND id_conductor IS NOT NULL;

COMMIT;

-- 7. Cancelar un viaje pendiente. Es mejor actualizar el estado que borrar el histórico.
UPDATE viaje
SET estado = 'cancelado'
WHERE id_viaje = 3
  AND estado = 'solicitado';

-- 8. Rechazar una oferta pendiente.
-- `fecha_decision` permite distinguir ofertas activas de ofertas ya resueltas.
UPDATE oferta
SET estado = 'rechazada', fecha_decision = NOW()
WHERE id_oferta = 6
  AND estado = 'pendiente';

-- 9. JOIN: conductores y vehículos activos.
SELECT
  c.id_usuario AS id_conductor,
  u.nombre,
  u.apellido,
  co.nombre AS company,
  v.matricula,
  v.marca,
  v.modelo
FROM conductor c
JOIN usuario u ON u.id_usuario = c.id_usuario
JOIN company co ON co.id_company = c.id_company
LEFT JOIN vehiculo v ON v.id_conductor = c.id_usuario AND v.activo = TRUE
ORDER BY co.nombre, u.nombre;

-- 10. Ver auditoría básica.
SELECT *
FROM auditoria
ORDER BY fecha DESC;
