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

