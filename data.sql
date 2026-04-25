USE ride_hailing;

-- Datos de prueba sencillos, suficientes para probar relaciones, joins y métricas.

INSERT INTO company (nombre, nif, email_contacto) VALUES
('Madrid Mobility', 'B10000001', 'contacto@madridmobility.es'),
('Urban Cars',      'B10000002', 'info@urbancars.es');

INSERT INTO usuario (tipo, email, telefono, nombre, apellido) VALUES
('rider',     'ana.rider@email.com',     '600000001', 'Ana',    'García'),
('rider',     'luis.rider@email.com',    '600000002', 'Luis',   'Martín'),
('rider',     'marta.rider@email.com',   '600000003', 'Marta',  'López'),
('rider',     'pablo.rider@email.com',   '600000004', 'Pablo',  'Santos'),
('conductor', 'carlos.driver@email.com', '611000001', 'Carlos', 'Ruiz'),
('conductor', 'sofia.driver@email.com',  '611000002', 'Sofía',  'Pérez'),
('conductor', 'david.driver@email.com',  '611000003', 'David',  'Navas'),
('conductor', 'laura.driver@email.com',  '611000004', 'Laura',  'Díaz'),
('conductor', 'jorge.driver@email.com',  '611000005', 'Jorge',  'Molina'),
('conductor', 'ines.driver@email.com',   '611000006', 'Inés',   'Ramos');

INSERT INTO rider (id_usuario, valoracion) VALUES
(1, 4.80), (2, 4.60), (3, 4.90), (4, 4.70);

INSERT INTO conductor (id_usuario, id_company, nif, licencia, disponible, valoracion) VALUES
(5,  1, '11111111A', 'LIC-001', TRUE,  4.90),
(6,  1, '22222222B', 'LIC-002', TRUE,  4.70),
(7,  1, '33333333C', 'LIC-003', TRUE,  4.60),
(8,  2, '44444444D', 'LIC-004', TRUE,  4.85),
(9,  2, '55555555E', 'LIC-005', TRUE,  4.50),
(10, 2, '66666666F', 'LIC-006', FALSE, 4.40);

INSERT INTO vehiculo (id_conductor, matricula, marca, modelo, plazas, activo) VALUES
(1, '1111AAA', 'Toyota',  'Corolla', 4, TRUE),
(2, '2222BBB', 'Hyundai', 'Ioniq',   4, TRUE),
(3, '3333CCC', 'Kia',     'Niro',    4, TRUE),
(4, '4444DDD', 'Seat',    'Leon',    4, TRUE),
(5, '5555EEE', 'Renault', 'Megane',  4, TRUE),
(6, '6666FFF', 'Skoda',   'Octavia', 4, FALSE);

-- Viajes solicitados. Las coordenadas son de ejemplo dentro de Madrid.
INSERT INTO viaje (id_rider, origen_lat, origen_lon, destino_lat, destino_lon, estado, fecha_solicitud) VALUES
(1, 40.416775, -3.703790, 40.437869, -3.819620, 'solicitado', '2026-04-20 09:00:00'),
(2, 40.430000, -3.700000, 40.390000, -3.690000, 'solicitado', '2026-04-20 10:00:00'),
(3, 40.450000, -3.710000, 40.420000, -3.680000, 'solicitado', '2026-04-20 11:00:00'),
(4, 40.400000, -3.720000, 40.460000, -3.700000, 'cancelado',  '2026-04-20 12:00:00'),
(1, 40.410000, -3.690000, 40.475000, -3.685000, 'solicitado', '2026-04-20 13:00:00');

-- Ofertas enviadas a varios conductores por cada viaje.
INSERT INTO oferta (id_viaje, id_conductor, estado, precio_ofertado, fecha_envio) VALUES
(1, 1, 'pendiente', 14.50, '2026-04-20 09:01:00'),
(1, 2, 'pendiente', 15.00, '2026-04-20 09:01:00'),
(1, 3, 'pendiente', 15.20, '2026-04-20 09:01:00'),
(2, 2, 'pendiente', 11.90, '2026-04-20 10:01:00'),
(2, 4, 'pendiente', 12.50, '2026-04-20 10:01:00'),
(3, 3, 'pendiente',  9.80, '2026-04-20 11:01:00'),
(3, 5, 'pendiente', 10.20, '2026-04-20 11:01:00'),
(5, 4, 'pendiente', 18.00, '2026-04-20 13:01:00'),
(5, 5, 'pendiente', 18.40, '2026-04-20 13:01:00');

-- Se aceptan tres ofertas usando el procedimiento con transacción y bloqueo.
CALL sp_aceptar_oferta(1);
CALL sp_aceptar_oferta(4);
CALL sp_aceptar_oferta(8);

-- Se completan algunos viajes para tener métricas de ingresos, km y tiempo.
UPDATE viaje
SET estado = 'finalizado',
    id_vehiculo = 1,
    fecha_inicio = '2026-04-20 09:10:00',
    fecha_fin = '2026-04-20 09:35:00',
    km = 8.50,
    precio = 14.50
WHERE id_viaje = 1;

UPDATE viaje
SET estado = 'finalizado',
    id_vehiculo = 2,
    fecha_inicio = '2026-04-20 10:08:00',
    fecha_fin = '2026-04-20 10:29:00',
    km = 6.20,
    precio = 11.90
WHERE id_viaje = 2;

UPDATE viaje
SET estado = 'en_curso',
    id_vehiculo = 4,
    fecha_inicio = '2026-04-20 13:15:00',
    km = 0.00,
    precio = 18.00
WHERE id_viaje = 5;

INSERT INTO pago (id_viaje, id_conductor, importe, metodo, estado, fecha_pago) VALUES
(1, 1, 14.50, 'tarjeta', 'pagado', '2026-04-20 09:36:00'),
(2, 2, 11.90, 'tarjeta', 'pagado', '2026-04-20 10:30:00');
