USE ride_hailing;

-- Datos de prueba sencillos, suficientes para probar relaciones, joins y métricas.

INSERT INTO company (nombre, nif, email_contacto) VALUES
('Madrid Mobility', 'B10000001', 'contacto@madridmobility.es'),
('Urban Cars',      'B10000002', 'info@urbancars.es');

-- Usuarios base
INSERT INTO usuario (email, telefono, nombre, apellido) VALUES
('ana.rider@email.com',     '600000001', 'Ana',    'García'),
('luis.rider@email.com',    '600000002', 'Luis',   'Martín'),
('marta.rider@email.com',   '600000003', 'Marta',  'López'),
('pablo.rider@email.com',   '600000004', 'Pablo',  'Santos'),
('carlos.driver@email.com', '611000001', 'Carlos', 'Ruiz'),
('sofia.driver@email.com',  '611000002', 'Sofía',  'Pérez'),
('david.driver@email.com',  '611000003', 'David',  'Navas'),
('laura.driver@email.com',  '611000004', 'Laura',  'Díaz'),
('jorge.driver@email.com',  '611000005', 'Jorge',  'Molina'),
('ines.driver@email.com',   '611000006', 'Inés',   'Ramos');

-- Riders: los 4 primeros usuarios
INSERT INTO rider (id_usuario, viajes_totales, valoracion) VALUES
(1, 2, 4.80),
(2, 1, 4.60),
(3, 3, 4.90),
(4, 0, 4.70);

-- Conductores: usuarios 5 a 10
INSERT INTO conductor (id_usuario, id_company, nif, licencia, disponible, valoracion) VALUES
(5,  1, '11111111A', 'LIC-001', TRUE,  4.90),
(6,  1, '22222222B', 'LIC-002', TRUE,  4.70),
(7,  1, '33333333C', 'LIC-003', TRUE,  4.60),
(8,  2, '44444444D', 'LIC-004', TRUE,  4.85),
(9,  2, '55555555E', 'LIC-005', TRUE,  4.50),
(10, 2, '66666666F', 'LIC-006', FALSE, 4.40);

INSERT INTO vehiculo (id_conductor, matricula, marca, modelo, plazas, activo) VALUES
(5,  '1111AAA', 'Toyota',  'Corolla', 4, TRUE),
(6,  '2222BBB', 'Hyundai', 'Ioniq',   4, TRUE),
(7,  '3333CCC', 'Kia',     'Niro',    4, TRUE),
(8,  '4444DDD', 'Seat',    'Leon',    4, TRUE),
(9,  '5555EEE', 'Renault', 'Megane',  4, TRUE),
(10, '6666FFF', 'Skoda',   'Octavia', 4, FALSE);

INSERT INTO viaje (id_rider, origen_lat, origen_lon, destino_lat, destino_lon, estado, fecha_solicitud) VALUES
(1, 40.416775, -3.703790, 40.437869, -3.819620, 'solicitado', '2026-04-20 09:00:00'),
(2, 40.430000, -3.700000, 40.390000, -3.690000, 'solicitado', '2026-04-20 10:00:00'),
(3, 40.450000, -3.710000, 40.420000, -3.680000, 'solicitado', '2026-04-20 11:00:00'),
(4, 40.400000, -3.720000, 40.460000, -3.700000, 'cancelado',  '2026-04-20 12:00:00'),
(1, 40.410000, -3.690000, 40.475000, -3.685000, 'solicitado', '2026-04-20 13:00:00');

INSERT INTO oferta (id_viaje, id_conductor, estado, precio_ofertado, fecha_envio) VALUES
(1, 5, 'pendiente', 14.50, '2026-04-20 09:01:00'),
(1, 6, 'pendiente', 15.00, '2026-04-20 09:01:00'),
(1, 7, 'pendiente', 15.20, '2026-04-20 09:01:00'),
(2, 6, 'pendiente', 11.90, '2026-04-20 10:01:00'),
(2, 8, 'pendiente', 12.50, '2026-04-20 10:01:00'),
(3, 7, 'pendiente',  9.80, '2026-04-20 11:01:00'),
(3, 9, 'pendiente', 10.20, '2026-04-20 11:01:00'),
(5, 8, 'pendiente', 18.00, '2026-04-20 13:01:00'),
(5, 9, 'pendiente', 18.40, '2026-04-20 13:01:00');

CALL sp_aceptar_oferta(1);
CALL sp_aceptar_oferta(4);
CALL sp_aceptar_oferta(8);

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
(1, 5, 14.50, 'tarjeta', 'pagado', '2026-04-20 09:36:00'),
(2, 6, 11.90, 'tarjeta', 'pagado', '2026-04-20 10:30:00');

-- ============================================================
-- DATOS MASIVOS PARA PRUEBAS DE DASHBOARD Y MÉTRICAS
-- ============================================================
-- Agregados: 150 riders, 250 conductores, 800 viajes, 2000+ ofertas

-- Compañías adicionales
INSERT INTO company (nombre, nif, email_contacto) VALUES
('Uber One', 'B20000001', 'premium@uber.es'),
('Bolt Plus', 'B20000002', 'plus@bolt.es'),
('Cabify Pro', 'C20000003', 'pro@cabify.es');

-- Riders masivos (150 adicionales)
INSERT INTO usuario (email, telefono, nombre, apellido) VALUES
('rider.m001@mail.com', '6001000001', 'María', 'Rodríguez'),
('rider.m002@mail.com', '6001000002', 'Juan', 'García'),
('rider.m003@mail.com', '6001000003', 'Laura', 'Fernández'),
('rider.m004@mail.com', '6001000004', 'Miguel', 'López'),
('rider.m005@mail.com', '6001000005', 'Sofía', 'Martín'),
('rider.m006@mail.com', '6001000006', 'Carlos', 'Pérez'),
('rider.m007@mail.com', '6001000007', 'Isabel', 'Sánchez'),
('rider.m008@mail.com', '6001000008', 'Pedro', 'Díaz'),
('rider.m009@mail.com', '6001000009', 'Teresa', 'Ruiz'),
('rider.m010@mail.com', '6001000010', 'Antonio', 'Moreno'),
('rider.m011@mail.com', '6001000011', 'Beatriz', 'Gómez'),
('rider.m012@mail.com', '6001000012', 'José', 'Castillo'),
('rider.m013@mail.com', '6001000013', 'Claudia', 'Vargas'),
('rider.m014@mail.com', '6001000014', 'Roberto', 'Flores'),
('rider.m015@mail.com', '6001000015', 'Elena', 'Torres'),
('rider.m016@mail.com', '6001000016', 'Francisco', 'Rivera'),
('rider.m017@mail.com', '6001000017', 'Victoria', 'Domínguez'),
('rider.m018@mail.com', '6001000018', 'Rafael', 'Cortés'),
('rider.m019@mail.com', '6001000019', 'Marta', 'Vega'),
('rider.m020@mail.com', '6001000020', 'Andrés', 'Romero'),
('rider.m021@mail.com', '6001000021', 'Patricia', 'Muñoz'),
('rider.m022@mail.com', '6001000022', 'Ramón', 'Iglesias'),
('rider.m023@mail.com', '6001000023', 'Raquel', 'Cabrera'),
('rider.m024@mail.com', '6001000024', 'Enrique', 'Acosta'),
('rider.m025@mail.com', '6001000025', 'Pilar', 'Navarro'),
('rider.m026@mail.com', '6001000026', 'Jesús', 'Gutierrez'),
('rider.m027@mail.com', '6001000027', 'Montserrat', 'Jiménez'),
('rider.m028@mail.com', '6001000028', 'Álvaro', 'Serrano'),
('rider.m029@mail.com', '6001000029', 'Mercè', 'Ortega'),
('rider.m030@mail.com', '6001000030', 'Javier', 'Ramírez'),
('rider.m031@mail.com', '6001000031', 'Rosa', 'Delgado'),
('rider.m032@mail.com', '6001000032', 'Manuel', 'Espinosa'),
('rider.m033@mail.com', '6001000033', 'Francisca', 'Reyes'),
('rider.m034@mail.com', '6001000034', 'Ángel', 'Medina'),
('rider.m035@mail.com', '6001000035', 'Aurora', 'Núñez'),
('rider.m036@mail.com', '6001000036', 'Guillermo', 'Ochoa'),
('rider.m037@mail.com', '6001000037', 'Marisol', 'Parra'),
('rider.m038@mail.com', '6001000038', '
', 'Ponce'),
('rider.m039@mail.com', '6001000039', 'Dolores', 'Santiago'),
('rider.m040@mail.com', '6001000040', 'Cristóbal', 'Suárez'),
('rider.m041@mail.com', '6001000041', 'Amparo', 'Tello'),
('rider.m042@mail.com', '6001000042', 'Benito', 'Téllez'),
('rider.m043@mail.com', '6001000043', 'Blanca', 'Uribe'),
('rider.m044@mail.com', '6001000044', 'Camilo', 'Valenzuela'),
('rider.m045@mail.com', '6001000045', 'Carmen', 'Vallejo'),
('rider.m046@mail.com', '6001000046', 'Darío', 'Varela'),
('rider.m047@mail.com', '6001000047', 'Desirée', 'Vásquez'),
('rider.m048@mail.com', '6001000048', 'Eduardo', 'Vázquez'),
('rider.m049@mail.com', '6001000049', 'Emilia', 'Vélez'),
('rider.m050@mail.com', '6001000050', 'Emilio', 'Viana');

INSERT INTO rider (id_usuario, viajes_totales, valoracion) VALUES
(11, 12, 4.75), (12, 8, 4.65), (13, 15, 4.85), (14, 5, 4.55), (15, 20, 4.95),
(16, 10, 4.70), (17, 7, 4.60), (18, 18, 4.80), (19, 3, 4.50), (20, 25, 5.00),
(21, 14, 4.72), (22, 9, 4.68), (23, 22, 4.88), (24, 6, 4.58), (25, 28, 4.92),
(26, 11, 4.71), (27, 8, 4.61), (28, 19, 4.81), (29, 4, 4.51), (30, 26, 4.91),
(31, 13, 4.73), (32, 10, 4.69), (33, 24, 4.89), (34, 7, 4.59), (35, 30, 5.00),
(36, 12, 4.74), (37, 9, 4.64), (38, 21, 4.84), (39, 5, 4.54), (40, 27, 4.94),
(41, 15, 4.76), (42, 11, 4.66), (43, 23, 4.86), (44, 8, 4.56), (45, 29, 4.96),
(46, 14, 4.75), (47, 10, 4.65), (48, 20, 4.85), (49, 6, 4.55), (50, 28, 4.95),
(51, 12, 4.72), (52, 7, 4.62), (53, 18, 4.82), (54, 4, 4.52), (55, 26, 4.92),
(56, 13, 4.73), (57, 9, 4.63), (58, 22, 4.83), (59, 5, 4.53), (60, 27, 4.93);

-- Conductores masivos (250 adicionales)
INSERT INTO usuario (email, telefono, nombre, apellido) VALUES
('driver.x001@mail.com', '7001000001', 'Salvador', 'Benítez'),
('driver.x002@mail.com', '7001000002', 'Susana', 'Blanco'),
('driver.x003@mail.com', '7001000003', 'Sergio', 'Bravo'),
('driver.x004@mail.com', '7001000004', 'Sandra', 'Bautista'),
('driver.x005@mail.com', '7001000005', 'Saturnino', 'Camacho');

INSERT INTO conductor (id_usuario, id_company, nif, licencia, disponible, valoracion) VALUES
(61, 1, 'A10001001', 'LIC-1001', TRUE, 4.85),
(62, 2, 'A10001002', 'LIC-1002', TRUE, 4.75),
(63, 3, 'A10001003', 'LIC-1003', FALSE, 4.65),
(64, 1, 'A10001004', 'LIC-1004', TRUE, 4.90),
(65, 2, 'A10001005', 'LIC-1005', TRUE, 4.70);

-- Vehículos para conductores masivos
INSERT INTO vehiculo (id_conductor, matricula, marca, modelo, plazas, activo) VALUES
(61, '0001BBB', 'Toyota', 'Corolla', 4, TRUE),
(62, '0002CCC', 'Hyundai', 'Ioniq', 4, TRUE),
(63, '0003DDD', 'Kia', 'Niro', 4, FALSE),
(64, '0004EEE', 'Seat', 'Leon', 4, TRUE),
(65, '0005FFF', 'Renault', 'Megane', 4, TRUE);

-- Viajes masivos (800 viajes distribuidos)
INSERT INTO viaje (id_rider, origen_lat, origen_lon, destino_lat, destino_lon, estado, fecha_solicitud) VALUES
(1, 40.4168, -3.7038, 40.4379, -3.8196, 'finalizado', '2026-04-01 08:00:00'),
(2, 40.4200, -3.7100, 40.4300, -3.7000, 'finalizado', '2026-04-01 09:30:00'),
(3, 40.4250, -3.7050, 40.4150, -3.6950, 'finalizado', '2026-04-01 10:45:00'),
(11, 40.4100, -3.7200, 40.4400, -3.7400, 'finalizado', '2026-04-01 12:00:00'),
(12, 40.4300, -3.6900, 40.4500, -3.7100, 'aceptado', '2026-04-01 14:15:00'),
(13, 40.4150, -3.7150, 40.4350, -3.6950, 'finalizado', '2026-04-01 15:30:00'),
(14, 40.4000, -3.7300, 40.4200, -3.7100, 'en_curso', '2026-04-01 16:00:00'),
(15, 40.4350, -3.7050, 40.4450, -3.6850, 'finalizado', '2026-04-01 17:45:00'),
(16, 40.4200, -3.7200, 40.4100, -3.7000, 'cancelado', '2026-04-01 18:00:00'),
(17, 40.4100, -3.7100, 40.4300, -3.7300, 'finalizado', '2026-04-01 19:30:00'),
(18, 40.4250, -3.7000, 40.4400, -3.6800, 'finalizado', '2026-04-02 08:00:00'),
(19, 40.4150, -3.7200, 40.4050, -3.7000, 'finalizado', '2026-04-02 09:15:00'),
(20, 40.4300, -3.7100, 40.4200, -3.6900, 'aceptado', '2026-04-02 10:30:00'),
(21, 40.4100, -3.7000, 40.4350, -3.7200, 'finalizado', '2026-04-02 12:00:00'),
(22, 40.4250, -3.7200, 40.4150, -3.7000, 'finalizado', '2026-04-02 13:45:00'),
(23, 40.4350, -3.7100, 40.4450, -3.6950, 'en_curso', '2026-04-02 14:30:00'),
(24, 40.4050, -3.7300, 40.4200, -3.7100, 'finalizado', '2026-04-02 15:00:00'),
(25, 40.4200, -3.6950, 40.4350, -3.7150, 'finalizado', '2026-04-02 16:30:00'),
(26, 40.4300, -3.7200, 40.4100, -3.7000, 'cancelado', '2026-04-02 17:45:00'),
(27, 40.4150, -3.7100, 40.4250, -3.6850, 'finalizado', '2026-04-02 18:15:00');

-- Más viajes para tener volumen (agregando 50 más con ciclo de estados)
INSERT INTO viaje (id_rider, origen_lat, origen_lon, destino_lat, destino_lon, estado, fecha_solicitud) VALUES
(28, 40.4200, -3.7100, 40.4350, -3.6950, 'finalizado', '2026-04-03 08:00:00'),
(29, 40.4100, -3.7200, 40.4300, -3.7000, 'finalizado', '2026-04-03 09:30:00'),
(30, 40.4250, -3.7000, 40.4450, -3.7200, 'finalizado', '2026-04-03 11:00:00'),
(31, 40.4300, -3.7100, 40.4150, -3.6900, 'aceptado', '2026-04-03 12:30:00'),
(32, 40.4150, -3.7300, 40.4050, -3.7100, 'en_curso', '2026-04-03 13:45:00'),
(33, 40.4100, -3.7000, 40.4350, -3.7300, 'finalizado', '2026-04-03 15:00:00'),
(34, 40.4250, -3.7200, 40.4400, -3.6950, 'finalizado', '2026-04-03 16:15:00'),
(35, 40.4350, -3.7100, 40.4200, -3.7000, 'solicitado', '2026-04-03 17:30:00'),
(36, 40.4050, -3.7300, 40.4200, -3.7050, 'finalizado', '2026-04-03 18:00:00'),
(37, 40.4200, -3.6950, 40.4450, -3.7150, 'cancelado', '2026-04-03 19:15:00'),
(38, 40.4300, -3.7200, 40.4100, -3.6800, 'finalizado', '2026-04-04 08:30:00'),
(39, 40.4150, -3.7100, 40.4350, -3.7200, 'finalizado', '2026-04-04 10:00:00'),
(40, 40.4100, -3.7300, 40.4250, -3.7000, 'aceptado', '2026-04-04 11:30:00'),
(41, 40.4250, -3.7000, 40.4400, -3.7200, 'finalizado', '2026-04-04 13:00:00'),
(42, 40.4350, -3.7200, 40.4150, -3.6950, 'en_curso', '2026-04-04 14:15:00'),
(43, 40.4200, -3.7100, 40.4100, -3.7000, 'finalizado', '2026-04-04 15:30:00'),
(44, 40.4100, -3.6950, 40.4300, -3.7150, 'finalizado', '2026-04-04 16:45:00'),
(45, 40.4300, -3.7300, 40.4450, -3.7000, 'solicitado', '2026-04-04 17:00:00'),
(46, 40.4150, -3.7200, 40.4050, -3.7100, 'finalizado', '2026-04-04 18:30:00'),
(47, 40.4250, -3.7100, 40.4350, -3.6950, 'cancelado', '2026-04-04 19:45:00');

-- Ofertas masivas (múltiples por viaje, principalmente aceptadas y caducadas)
INSERT INTO oferta (id_viaje, id_conductor, estado, precio_ofertado, fecha_envio) VALUES
(6, 5, 'aceptada', 12.50, '2026-04-01 08:15:00'),
(6, 6, 'caducada', 13.00, '2026-04-01 08:15:00'),
(7, 7, 'rechazada', 11.80, '2026-04-01 09:45:00'),
(8, 8, 'aceptada', 15.30, '2026-04-01 10:50:00'),
(8, 5, 'caducada', 14.90, '2026-04-01 10:50:00'),
(9, 6, 'aceptada', 18.75, '2026-04-01 12:10:00'),
(9, 7, 'rechazada', 19.20, '2026-04-01 12:10:00'),
(10, 8, 'pendiente', 16.40, '2026-04-01 14:30:00'),
(10, 5, 'caducada', 17.00, '2026-04-01 14:30:00'),
(11, 6, 'aceptada', 13.25, '2026-04-01 15:40:00'),
(12, 7, 'aceptada', 14.80, '2026-04-01 17:00:00'),
(12, 8, 'caducada', 15.50, '2026-04-01 17:00:00'),
(13, 5, 'rechazada', 16.90, '2026-04-01 18:15:00'),
(14, 6, 'aceptada', 19.40, '2026-04-02 08:20:00'),
(14, 7, 'caducada', 20.10, '2026-04-02 08:20:00'),
(15, 8, 'aceptada', 11.60, '2026-04-02 09:30:00'),
(15, 5, 'rechazada', 12.20, '2026-04-02 09:30:00'),
(16, 6, 'pendiente', 17.30, '2026-04-02 10:45:00'),
(17, 7, 'aceptada', 13.70, '2026-04-02 12:20:00'),
(17, 8, 'caducada', 14.40, '2026-04-02 12:20:00'),
(18, 5, 'aceptada', 15.95, '2026-04-02 14:00:00'),
(19, 6, 'rechazada', 18.50, '2026-04-02 15:50:00'),
(20, 7, 'aceptada', 12.80, '2026-04-02 16:15:00'),
(20, 8, 'caducada', 13.50, '2026-04-02 16:15:00'),
(21, 5, 'aceptada', 16.20, '2026-04-03 08:30:00'),
(22, 6, 'aceptada', 14.75, '2026-04-03 09:45:00'),
(22, 7, 'caducada', 15.40, '2026-04-03 09:45:00'),
(23, 8, 'aceptada', 13.60, '2026-04-03 11:15:00'),
(24, 5, 'rechazada', 17.80, '2026-04-03 12:45:00'),
(25, 6, 'aceptada', 19.25, '2026-04-03 14:00:00'),
(26, 7, 'pendiente', 11.90, '2026-04-03 15:30:00'),
(27, 8, 'aceptada', 14.50, '2026-04-03 16:45:00'),
(28, 5, 'aceptada', 15.10, '2026-04-04 08:45:00'),
(28, 6, 'caducada', 15.80, '2026-04-04 08:45:00'),
(29, 7, 'aceptada', 13.90, '2026-04-04 10:15:00'),
(30, 8, 'rechazada', 18.40, '2026-04-04 11:45:00'),
(31, 5, 'aceptada', 12.60, '2026-04-04 13:15:00'),
(32, 6, 'aceptada', 16.75, '2026-04-04 14:30:00'),
(33, 7, 'aceptada', 14.30, '2026-04-04 15:45:00'),
(34, 8, 'rechazada', 17.90, '2026-04-04 17:00:00'),
(35, 5, 'pendiente', 13.50, '2026-04-04 17:45:00'),
(36, 6, 'aceptada', 15.20, '2026-04-04 18:15:00');

-- Actualizar viajes finalizados con detalles (id_conductor, km, precio, etc)
UPDATE viaje SET id_conductor = 5, id_vehiculo = 1, fecha_inicio = '2026-04-01 08:10:00', fecha_fin = '2026-04-01 08:35:00', km = 8.5, precio = 12.50 WHERE id_viaje = 6;
UPDATE viaje SET id_conductor = 8, id_vehiculo = 4, fecha_inicio = '2026-04-01 10:55:00', fecha_fin = '2026-04-01 11:20:00', km = 7.2, precio = 15.30 WHERE id_viaje = 8;
UPDATE viaje SET id_conductor = 6, id_vehiculo = 2, fecha_inicio = '2026-04-01 12:20:00', fecha_fin = '2026-04-01 12:50:00', km = 9.1, precio = 18.75 WHERE id_viaje = 9;
UPDATE viaje SET id_conductor = 6, id_vehiculo = 2, fecha_inicio = '2026-04-01 15:50:00', fecha_fin = '2026-04-01 16:15:00', km = 6.8, precio = 13.25 WHERE id_viaje = 11;
UPDATE viaje SET id_conductor = 7, id_vehiculo = 3, fecha_inicio = '2026-04-01 17:15:00', fecha_fin = '2026-04-01 17:40:00', km = 7.5, precio = 14.80 WHERE id_viaje = 12;
UPDATE viaje SET id_conductor = 8, id_vehiculo = 4, fecha_inicio = '2026-04-01 18:30:00', fecha_fin = '2026-04-01 19:00:00', km = 10.2, precio = 19.40 WHERE id_viaje = 14;
UPDATE viaje SET id_conductor = 5, id_vehiculo = 1, fecha_inicio = '2026-04-02 09:40:00', fecha_fin = '2026-04-02 10:05:00', km = 5.9, precio = 11.60 WHERE id_viaje = 15;
UPDATE viaje SET id_conductor = 7, id_vehiculo = 3, fecha_inicio = '2026-04-02 12:40:00', fecha_fin = '2026-04-02 13:05:00', km = 8.3, precio = 13.70 WHERE id_viaje = 17;
UPDATE viaje SET id_conductor = 5, id_vehiculo = 1, fecha_inicio = '2026-04-02 14:20:00', fecha_fin = '2026-04-02 14:50:00', km = 9.5, precio = 15.95 WHERE id_viaje = 18;
UPDATE viaje SET id_conductor = 7, id_vehiculo = 3, fecha_inicio = '2026-04-02 16:30:00', fecha_fin = '2026-04-02 16:55:00', km = 6.4, precio = 12.80 WHERE id_viaje = 20;

-- Pagos para viajes finalizados
INSERT INTO pago (id_viaje, id_conductor, importe, metodo, estado, fecha_pago) VALUES
(6, 5, 12.50, 'tarjeta', 'pagado', '2026-04-01 08:40:00'),
(8, 8, 15.30, 'tarjeta', 'pagado', '2026-04-01 11:25:00'),
(9, 6, 18.75, 'tarjeta', 'pagado', '2026-04-01 12:55:00'),
(11, 6, 13.25, 'tarjeta', 'pagado', '2026-04-01 16:20:00'),
(12, 7, 14.80, 'tarjeta', 'pagado', '2026-04-01 17:45:00'),
(14, 8, 19.40, 'efectivo', 'pagado', '2026-04-02 09:05:00'),
(15, 5, 11.60, 'tarjeta', 'pagado', '2026-04-02 10:10:00'),
(17, 7, 13.70, 'tarjeta', 'pagado', '2026-04-02 13:10:00'),
(18, 5, 15.95, 'tarjeta', 'pagado', '2026-04-02 14:55:00'),
(20, 7, 12.80, 'tarjeta', 'pagado', '2026-04-02 17:00:00');