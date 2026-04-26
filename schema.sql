-- Creamos la base de datos del proyecto con utf8mb4 para evitar problemas con tildes y caracteres especiales.
CREATE DATABASE IF NOT EXISTS ride_hailing
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_0900_ai_ci;

USE ride_hailing;

-- Tabla de compañías. Cada conductor trabajará para una company.
CREATE TABLE ride_hailing.company (
    id_company      BIGINT         NOT NULL AUTO_INCREMENT,
    nombre          VARCHAR(120)   NOT NULL,
    nif             VARCHAR(20)    NOT NULL,
    email_contacto  VARCHAR(120)   NOT NULL,
    -- Fechas técnicas para saber cuándo se crea o modifica cada fila.
    created_at      DATETIME       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at      DATETIME       NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    PRIMARY KEY (id_company),
    UNIQUE KEY uk_company_nif (nif)
) ENGINE=InnoDB;

-- Usuario es la entidad base del sistema. De aquí cuelgan rider y conductor.
CREATE TABLE ride_hailing.usuario (
    id_usuario      BIGINT       NOT NULL AUTO_INCREMENT,
    email           VARCHAR(120) NOT NULL,
    telefono        VARCHAR(20)  NOT NULL,
    nombre          VARCHAR(120) NOT NULL,
    apellido        VARCHAR(120) NOT NULL,
    fecha_alta      DATE         NOT NULL DEFAULT (CURRENT_DATE),
    activo          BOOLEAN      NOT NULL DEFAULT TRUE,
    -- Estas columnas nos vienen bien para auditoría básica y depuración.
    created_at      DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at      DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    PRIMARY KEY (id_usuario),
    UNIQUE KEY uk_usuario_email (email),
    UNIQUE KEY uk_usuario_telefono (telefono)
) ENGINE=InnoDB;

-- Rider como subtipo de usuario.
CREATE TABLE ride_hailing.rider (
    id_usuario          BIGINT NOT NULL,
    -- Lo guardamos aquí para no recalcular siempre el histórico completo.
    viajes_totales      INT NOT NULL,
    valoracion          DECIMAL(3,2) DEFAULT 5.00,

    PRIMARY KEY (id_usuario),
    CONSTRAINT fk_rider_usuario
        FOREIGN KEY (id_usuario)
        REFERENCES ride_hailing.usuario(id_usuario)
        ON UPDATE CASCADE
        ON DELETE CASCADE -- Si desaparece el usuario, no tiene sentido dejar el rider suelto.
) ENGINE=InnoDB;

-- Conductor como subtipo de usuario.
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
        ON DELETE CASCADE, -- Si se borra el usuario, tampoco queremos dejar un conductor huérfano.
    
    CONSTRAINT fk_conductor_company
        FOREIGN KEY (id_company)
        REFERENCES ride_hailing.company(id_company)
        ON UPDATE CASCADE
        ON DELETE RESTRICT -- No dejamos borrar una company si todavía tiene conductores asociados.
) ENGINE=InnoDB;

-- Hemos modelado vehículo de forma simple: un conductor puede tener varios vehículos.
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
  -- Este índice ayuda en joins y listados por conductor.
  KEY idx_vehiculo_conductor (id_conductor),
  CONSTRAINT fk_vehiculo_conductor
    FOREIGN KEY (id_conductor) REFERENCES ride_hailing.conductor(id_usuario)
    ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT chk_vehiculo_plazas CHECK (plazas BETWEEN 1 AND 8)
) ENGINE=InnoDB;

-- Viaje solicitado por un rider. Al principio puede no tener conductor ni vehículo asignados.
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
  -- Este índice nos viene bien para filtros por estado y orden por fecha.
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

-- Oferta enviada a un conductor para un viaje concreto.
CREATE TABLE oferta (
  id_oferta       BIGINT NOT NULL AUTO_INCREMENT,
  id_viaje        BIGINT NOT NULL,
  id_conductor    BIGINT NOT NULL,
  estado          ENUM('pendiente','aceptada','rechazada','caducada') NOT NULL DEFAULT 'pendiente',
  -- Guardamos el precio ofertado para no perder la propuesta original.
  precio_ofertado DECIMAL(10,2) NOT NULL,
  fecha_envio     DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  fecha_decision  DATETIME NULL,

  PRIMARY KEY (id_oferta),
  -- Evita duplicar ofertas al mismo conductor para el mismo viaje.
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

-- Esta tabla fuerza que solo haya una oferta ganadora por viaje.
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

-- Pago asociado al viaje. En nuestro modelo dejamos como máximo un pago por viaje.
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

-- Auditoría genérica para guardar operaciones relevantes del sistema.
CREATE TABLE auditoria (
  id_auditoria   BIGINT NOT NULL AUTO_INCREMENT,
  tabla_afectada VARCHAR(50) NOT NULL,
  -- Guardamos el id lógico para poder auditar tablas distintas con la misma estructura.
  id_registro    BIGINT NOT NULL,
  accion         VARCHAR(20) NOT NULL,
  descripcion    VARCHAR(255) NOT NULL,
  usuario_mysql  VARCHAR(100) NOT NULL,
  fecha          DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

  PRIMARY KEY (id_auditoria),
  KEY idx_auditoria_fecha (fecha),
  KEY idx_auditoria_tabla (tabla_afectada)
) ENGINE=InnoDB;

-- Vista de detalle para consultas operativas y dashboard.
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

-- Vista para sacar la tasa de aceptación por conductor sin repetir la agregación cada vez.
CREATE VIEW v_tasa_aceptacion_conductor AS
...

-- Vista equivalente, pero agregada por company.
CREATE VIEW v_tasa_aceptacion_company AS
...

-- Vista de ingresos por conductor, incluyendo euros/km y euros/minuto.
CREATE VIEW v_ingresos_conductor AS
...

-- Vista de ingresos agregados por compañía.
CREATE VIEW v_ingresos_company AS
...

DELIMITER $$

-- Procedimiento principal del caso de uso: aceptar una oferta de forma segura.
CREATE PROCEDURE sp_aceptar_oferta(IN p_id_oferta BIGINT)
BEGIN
  -- Variables locales que usamos durante la transacción.
  DECLARE v_id_viaje BIGINT;
  DECLARE v_id_conductor BIGINT;
  DECLARE v_estado_viaje VARCHAR(20);
  DECLARE v_precio DECIMAL(10,2);

  -- Si algo falla, deshacemos todo para no dejar el viaje a medias.
  DECLARE EXIT HANDLER FOR SQLEXCEPTION
  BEGIN
    ROLLBACK;
    RESIGNAL;
  END;

  START TRANSACTION;

  -- Bloqueamos la oferta/viaje para evitar que dos conductores acepten a la vez.
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

  -- Guardamos la oferta ganadora para tener trazabilidad clara.
  INSERT INTO asignacion_viaje (id_viaje, id_oferta, id_conductor)
  VALUES (v_id_viaje, p_id_oferta, v_id_conductor);

  UPDATE oferta
  SET estado = 'aceptada', fecha_decision = NOW()
  WHERE id_oferta = p_id_oferta;

  -- El resto de ofertas pendientes del mismo viaje pasan a caducadas.
  UPDATE oferta
  SET estado = 'caducada', fecha_decision = NOW()
  WHERE id_viaje = v_id_viaje
    AND id_oferta <> p_id_oferta
    AND estado = 'pendiente';

  -- El viaje queda ya asignado al conductor que aceptó.
  UPDATE viaje
  SET estado = 'aceptado',
      id_conductor = v_id_conductor,
      fecha_aceptacion = NOW(),
      precio = v_precio
  WHERE id_viaje = v_id_viaje;

  COMMIT;
END$$

-- Trigger para auditar cambios de estado en viaje.
CREATE TRIGGER trg_viaje_auditoria_update
AFTER UPDATE ON viaje
FOR EACH ROW
BEGIN
  -- Aquí solo registramos cambios de estado, para no llenar la auditoría de ruido.
  IF OLD.estado <> NEW.estado THEN
    INSERT INTO auditoria (tabla_afectada, id_registro, accion, descripcion, usuario_mysql)
    VALUES ('viaje', NEW.id_viaje, 'UPDATE', CONCAT('Cambio de estado: ', OLD.estado, ' -> ', NEW.estado), USER());
  END IF;
END$$

-- Trigger para dejar trazado cuándo se envía una oferta.
CREATE TRIGGER trg_oferta_auditoria_insert
AFTER INSERT ON oferta
FOR EACH ROW
BEGIN
  INSERT INTO auditoria (tabla_afectada, id_registro, accion, descripcion, usuario_mysql)
  VALUES ('oferta', NEW.id_oferta, 'INSERT', CONCAT('Oferta enviada al conductor ', NEW.id_conductor), USER());
END$$

DELIMITER ;