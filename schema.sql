CREATE DATABASE IF NOT EXISTS ride_hailing
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_0900_ai_ci;


-- Entidad Company
CREATE TABLE ride_hailing.company (
    id_company      BIGINT         NOT NULL AUTO_INCREMENT,
    nombre          VARCHAR(120)   NOT NULL,
    nif             VARCHAR(20)    NOT NULL,
    email_contacto  VARCHAR(120)   NOT NULL,
    -- Auditoría técnica
    created_at      DATETIME       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at      DATETIME       NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    PRIMARY KEY (id_company),
    UNIQUE KEY uk_company_nif (nif)
) ENGINE=InnoDB;

-- Entidad Usuario
CREATE TABLE ride_hailing.usuario (
    id_usuario      BIGINT       NOT NULL AUTO_INCREMENT,
    email           VARCHAR(120) NOT NULL,
    telefono        VARCHAR(20)  NOT NULL,
    nombre          VARCHAR(120) NOT NULL,
    apellido        VARCHAR(120) NOT NULL,
    fecha_alta      DATE         NOT NULL DEFAULT (CURRENT_DATE),
    activo          BOOLEAN      NOT NULL DEFAULT TRUE,
    -- Auditoría técnica
    created_at      DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at      DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    PRIMARY KEY (id_usuario),
    UNIQUE KEY uk_usuario_email (email),
    UNIQUE KEY uk_usuario_telefono (telefono)
) ENGINE=InnoDB;

-- Entidad Rider (hijo de usuario)
CREATE TABLE ride_hailing.rider (
    id_usuario          BIGINT NOT NULL,
    -- Se mantiene como acumulado para no recalcular el histórico en cada consulta.
    viajes_totales      INT NOT NULL,
    valoracion          DECIMAL(3,2) DEFAULT 5.00,

    PRIMARY KEY (id_usuario),
    CONSTRAINT fk_rider_usuario
        FOREIGN KEY (id_usuario)
        REFERENCES ride_hailing.usuario(id_usuario)
        ON UPDATE CASCADE
        ON DELETE CASCADE -- Elimina rider si se elimina el usuario (evita huérfanos)
) ENGINE=InnoDB;

-- Entidad Conductor (hijo de usuario)
CREATE TABLE ride_hailing.conductor (
    id_usuario      BIGINT NOT NULL,
    id_company      BIGINT NOT NULL,
    nif             VARCHAR(20) NOT NULL,
    licencia        VARCHAR(50) NOT NULL,
    valoracion      DECIMAL(3,2) NOT NULL DEFAULT 5.00,
    disponible      BOOLEAN NOT NULL DEFAULT FALSE,

    PRIMARY KEY (id_usuario),

    CONSTRAINT fk_conductor_usuario
        FOREIGN KEY (id_usuario)
        REFERENCES ride_hailing.usuario(id_usuario)
        ON UPDATE CASCADE
        ON DELETE CASCADE, -- Elimina conductor si se elimina el usuario (evita huérfanos)
    
    CONSTRAINT fk_conductor_company
        FOREIGN KEY (id_company)
        REFERENCES ride_hailing.company(id_company)
        ON UPDATE CASCADE
        ON DELETE RESTRICT -- Eliminar una company no debe eliminar sus conductores   
) ENGINE=InnoDB;

-- Vehículos de los conductores. Se usa 1:N para mantener el diseño sencillo.
CREATE TABLE vehiculo (
  id_vehiculo  BIGINT      NOT NULL AUTO_INCREMENT,
  id_conductor BIGINT      NOT NULL,
  matricula    VARCHAR(12) NOT NULL,
  marca        VARCHAR(50) NOT NULL,
  modelo       VARCHAR(50) NOT NULL,
  plazas       INT         NOT NULL DEFAULT 4,
  activo       BOOLEAN     NOT NULL DEFAULT TRUE,

  PRIMARY KEY (id_vehiculo),
  UNIQUE KEY uk_vehiculo_matricula (matricula),
  KEY idx_vehiculo_conductor (id_conductor),
  CONSTRAINT fk_vehiculo_conductor
    FOREIGN KEY (id_conductor) REFERENCES ride_hailing.conductor(id_usuario)
    ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT chk_vehiculo_plazas CHECK (plazas BETWEEN 1 AND 8)
) ENGINE=InnoDB;

-- Viajes solicitados por riders.
CREATE TABLE viaje (
  id_viaje         BIGINT NOT NULL AUTO_INCREMENT,
  id_rider         BIGINT NOT NULL,
  id_conductor     BIGINT NULL,
  id_vehiculo      BIGINT NULL,
  origen_lat       DECIMAL(9,6) NOT NULL,
  origen_lon       DECIMAL(9,6) NOT NULL,
  destino_lat      DECIMAL(9,6) NOT NULL,
  destino_lon      DECIMAL(9,6) NOT NULL,
  estado           ENUM('solicitado','aceptado','en_curso','finalizado','cancelado') NOT NULL DEFAULT 'solicitado',
  fecha_solicitud  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  fecha_aceptacion DATETIME NULL,
  fecha_inicio     DATETIME NULL,
  fecha_fin        DATETIME NULL,
  km               DECIMAL(8,2) NULL,
  precio           DECIMAL(10,2) NULL,
  created_at       DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at       DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

  PRIMARY KEY (id_viaje),
  KEY idx_viaje_rider (id_rider),
  KEY idx_viaje_conductor (id_conductor),
  KEY idx_viaje_estado_fecha (estado, fecha_solicitud),
  CONSTRAINT fk_viaje_rider
    FOREIGN KEY (id_rider) REFERENCES ride_hailing.rider(id_usuario)
    ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_viaje_conductor
    FOREIGN KEY (id_conductor) REFERENCES ride_hailing.conductor(id_usuario)
    ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_viaje_vehiculo
    FOREIGN KEY (id_vehiculo) REFERENCES vehiculo(id_vehiculo)
    ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT chk_viaje_km CHECK (km IS NULL OR km >= 0),
  CONSTRAINT chk_viaje_precio CHECK (precio IS NULL OR precio >= 0)
) ENGINE=InnoDB;

-- Ofertas enviadas a conductores para un viaje.
CREATE TABLE oferta (
  id_oferta       BIGINT NOT NULL AUTO_INCREMENT,
  id_viaje        BIGINT NOT NULL,
  id_conductor    BIGINT NOT NULL,
  estado          ENUM('pendiente','aceptada','rechazada','caducada') NOT NULL DEFAULT 'pendiente',
  precio_ofertado DECIMAL(10,2) NOT NULL,
  fecha_envio     DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  fecha_decision  DATETIME NULL,

  PRIMARY KEY (id_oferta),
  UNIQUE KEY uk_oferta_viaje_conductor (id_viaje, id_conductor),
  KEY idx_oferta_viaje_estado (id_viaje, estado),
  KEY idx_oferta_conductor_estado (id_conductor, estado),
  CONSTRAINT fk_oferta_viaje
    FOREIGN KEY (id_viaje) REFERENCES viaje(id_viaje)
    ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_oferta_conductor
    FOREIGN KEY (id_conductor) REFERENCES ride_hailing.conductor(id_usuario)
    ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT chk_oferta_precio CHECK (precio_ofertado >= 0)
) ENGINE=InnoDB;

-- Tabla que fuerza una única asignación por viaje.
CREATE TABLE asignacion_viaje (
  id_viaje          BIGINT NOT NULL,
  id_oferta         BIGINT NOT NULL,
  id_conductor      BIGINT NOT NULL,
  fecha_asignacion  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

  PRIMARY KEY (id_viaje),
  UNIQUE KEY uk_asignacion_oferta (id_oferta),
  KEY idx_asignacion_conductor (id_conductor),
  CONSTRAINT fk_asignacion_viaje
    FOREIGN KEY (id_viaje) REFERENCES viaje(id_viaje)
    ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_asignacion_oferta
    FOREIGN KEY (id_oferta) REFERENCES oferta(id_oferta)
    ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_asignacion_conductor
    FOREIGN KEY (id_conductor) REFERENCES ride_hailing.conductor(id_usuario)
    ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;

-- Pagos de viajes.
CREATE TABLE pago (
  id_pago       BIGINT NOT NULL AUTO_INCREMENT,
  id_viaje      BIGINT NOT NULL,
  id_conductor  BIGINT NOT NULL,
  importe       DECIMAL(10,2) NOT NULL,
  metodo        ENUM('tarjeta','efectivo') NOT NULL DEFAULT 'tarjeta',
  estado        ENUM('pendiente','pagado','fallido') NOT NULL DEFAULT 'pendiente',
  fecha_pago    DATETIME NULL,

  PRIMARY KEY (id_pago),
  UNIQUE KEY uk_pago_viaje (id_viaje),
  KEY idx_pago_conductor (id_conductor),
  CONSTRAINT fk_pago_viaje
    FOREIGN KEY (id_viaje) REFERENCES viaje(id_viaje)
    ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_pago_conductor
    FOREIGN KEY (id_conductor) REFERENCES ride_hailing.conductor(id_usuario)
    ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT chk_pago_importe CHECK (importe >= 0)
) ENGINE=InnoDB;

-- Auditoría básica.
CREATE TABLE auditoria (
  id_auditoria   BIGINT NOT NULL AUTO_INCREMENT,
  tabla_afectada VARCHAR(50) NOT NULL,
  -- Guarda el id lógico del registro afectado sin depender de una sola tabla concreta.
  id_registro    BIGINT NOT NULL,
  accion         VARCHAR(20) NOT NULL,
  descripcion    VARCHAR(255) NOT NULL,
  usuario_mysql  VARCHAR(100) NOT NULL,
  fecha          DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

  PRIMARY KEY (id_auditoria),
  KEY idx_auditoria_fecha (fecha),
  KEY idx_auditoria_tabla (tabla_afectada)
) ENGINE=InnoDB;

-- Vistas para consultas frecuentes y dashboard.
CREATE VIEW v_viajes_detalle AS
SELECT
  v.id_viaje,
  v.estado,
  v.fecha_solicitud,
  v.fecha_inicio,
  v.fecha_fin,
  v.km,
  v.precio,
  ur.nombre AS rider_nombre,
  uc.nombre AS conductor_nombre,
  co.nombre AS company,
  ve.matricula
FROM viaje v
JOIN rider r ON r.id_usuario = v.id_rider
JOIN usuario ur ON ur.id_usuario = r.id_usuario
LEFT JOIN conductor c ON c.id_usuario = v.id_conductor
LEFT JOIN usuario uc ON uc.id_usuario = c.id_usuario
LEFT JOIN company co ON co.id_company = c.id_company
LEFT JOIN vehiculo ve ON ve.id_vehiculo = v.id_vehiculo;

-- Resume cuántas ofertas recibe cada conductor y cuántas termina aceptando.
CREATE VIEW v_tasa_aceptacion_conductor AS
SELECT
  c.id_usuario AS id_conductor,
  u.nombre,
  u.apellido,
  COUNT(o.id_oferta) AS ofertas_recibidas,
  SUM(o.estado = 'aceptada') AS ofertas_aceptadas,
  ROUND(100 * SUM(o.estado = 'aceptada') / NULLIF(COUNT(o.id_oferta), 0), 2) AS tasa_aceptacion
FROM conductor c
JOIN usuario u ON u.id_usuario = c.id_usuario
LEFT JOIN oferta o ON o.id_conductor = c.id_usuario
GROUP BY c.id_usuario, u.nombre, u.apellido;

-- Repite la métrica de aceptación anterior, pero agregada por compañía.
CREATE VIEW v_tasa_aceptacion_company AS
SELECT
  co.id_company,
  co.nombre AS company,
  COUNT(o.id_oferta) AS ofertas_recibidas,
  SUM(o.estado = 'aceptada') AS ofertas_aceptadas,
  ROUND(100 * SUM(o.estado = 'aceptada') / NULLIF(COUNT(o.id_oferta), 0), 2) AS tasa_aceptacion
FROM company co
JOIN conductor c ON c.id_company = co.id_company
LEFT JOIN oferta o ON o.id_conductor = c.id_usuario
GROUP BY co.id_company, co.nombre;

-- Calcula ingresos y eficiencia económica por distancia y por minuto para cada conductor.
CREATE VIEW v_ingresos_conductor AS
SELECT
  c.id_usuario AS id_conductor,
  u.nombre,
  u.apellido,
  COUNT(p.id_pago) AS viajes_pagados,
  COALESCE(SUM(p.importe), 0) AS ingresos,
  ROUND(COALESCE(SUM(p.importe) / NULLIF(SUM(v.km), 0), 0), 2) AS euros_km,
  ROUND(COALESCE(SUM(p.importe) / NULLIF(SUM(TIMESTAMPDIFF(MINUTE, v.fecha_inicio, v.fecha_fin)), 0), 0), 2) AS euros_minuto
FROM conductor c
JOIN usuario u ON u.id_usuario = c.id_usuario
LEFT JOIN pago p ON p.id_conductor = c.id_usuario AND p.estado = 'pagado'
LEFT JOIN viaje v ON v.id_viaje = p.id_viaje
GROUP BY c.id_usuario, u.nombre, u.apellido;

-- Agrega los ingresos de todos los conductores de una misma compañía.
CREATE VIEW v_ingresos_company AS
SELECT
  co.id_company,
  co.nombre AS company,
  COUNT(p.id_pago) AS viajes_pagados,
  COALESCE(SUM(p.importe), 0) AS ingresos,
  ROUND(COALESCE(SUM(p.importe) / NULLIF(SUM(v.km), 0), 0), 2) AS euros_km,
  ROUND(COALESCE(SUM(p.importe) / NULLIF(SUM(TIMESTAMPDIFF(MINUTE, v.fecha_inicio, v.fecha_fin)), 0), 0), 2) AS euros_minuto
FROM company co
JOIN conductor c ON c.id_company = co.id_company
LEFT JOIN pago p ON p.id_conductor = c.id_usuario AND p.estado = 'pagado'
LEFT JOIN viaje v ON v.id_viaje = p.id_viaje
GROUP BY co.id_company, co.nombre;

DELIMITER $$

CREATE PROCEDURE sp_aceptar_oferta(IN p_id_oferta BIGINT)
BEGIN
  -- Variables de trabajo para mantener la decisión dentro de una única transacción.
  DECLARE v_id_viaje BIGINT;
  DECLARE v_id_conductor BIGINT;
  DECLARE v_estado_viaje VARCHAR(20);
  DECLARE v_precio DECIMAL(10,2);

  -- Ante cualquier error se revierte todo y no queda media asignación aplicada.
  DECLARE EXIT HANDLER FOR SQLEXCEPTION
  BEGIN
    ROLLBACK;
    RESIGNAL;
  END;

  START TRANSACTION;

  -- FOR UPDATE evita que otra sesión acepte otra oferta del mismo viaje a la vez.
  SELECT o.id_viaje, o.id_conductor, v.estado, o.precio_ofertado
    INTO v_id_viaje, v_id_conductor, v_estado_viaje, v_precio
  FROM oferta o
  JOIN viaje v ON v.id_viaje = o.id_viaje
  WHERE o.id_oferta = p_id_oferta
    AND o.estado = 'pendiente'
  FOR UPDATE;

  IF v_estado_viaje <> 'solicitado' THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'El viaje ya no está disponible';
  END IF;

  -- Deja trazabilidad explícita de qué oferta fue la ganadora del viaje.
  INSERT INTO asignacion_viaje (id_viaje, id_oferta, id_conductor)
  VALUES (v_id_viaje, p_id_oferta, v_id_conductor);

  UPDATE oferta
  SET estado = 'aceptada', fecha_decision = NOW()
  WHERE id_oferta = p_id_oferta;

  UPDATE oferta
  SET estado = 'caducada', fecha_decision = NOW()
  WHERE id_viaje = v_id_viaje
    AND id_oferta <> p_id_oferta
    AND estado = 'pendiente';

  -- El precio definitivo del viaje queda fijado con la oferta aceptada.
  UPDATE viaje
  SET estado = 'aceptado',
      id_conductor = v_id_conductor,
      fecha_aceptacion = NOW(),
      precio = v_precio
  WHERE id_viaje = v_id_viaje;

  COMMIT;
END$$

CREATE TRIGGER trg_viaje_auditoria_update
AFTER UPDATE ON viaje
FOR EACH ROW
BEGIN
  -- Solo audita cambios de estado para evitar ruido por otras columnas.
  IF OLD.estado <> NEW.estado THEN
    INSERT INTO auditoria (tabla_afectada, id_registro, accion, descripcion, usuario_mysql)
    VALUES ('viaje', NEW.id_viaje, 'UPDATE', CONCAT('Cambio de estado: ', OLD.estado, ' -> ', NEW.estado), USER());
  END IF;
END$$

CREATE TRIGGER trg_oferta_auditoria_insert
AFTER INSERT ON oferta
FOR EACH ROW
BEGIN
  -- Permite reconstruir a qué conductor se despachó cada oferta.
  INSERT INTO auditoria (tabla_afectada, id_registro, accion, descripcion, usuario_mysql)
  VALUES ('oferta', NEW.id_oferta, 'INSERT', CONCAT('Oferta enviada al conductor ', NEW.id_conductor), USER());
END$$

DELIMITER ;
