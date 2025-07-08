-- ================================
-- ARCHIVO 1: ESTRUCTURA - DDL GYMTRACK
-- ================================

DROP DATABASE IF EXISTS GYMTRACK;
CREATE DATABASE GYMTRACK;
USE GYMTRACK;

-- 1. USUARIO
CREATE TABLE usuario (
    id_usuario INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    ape_1 VARCHAR(100) NOT NULL,
    ape_2 VARCHAR(100) NOT NULL, 
    documento VARCHAR(20) UNIQUE NOT NULL,
    tipo_doc ENUM('Cédula', 'Pasaporte') NOT NULL,
    correo VARCHAR(100) UNIQUE NOT NULL,
    telefono VARCHAR(20),
    direccion VARCHAR(100),
    fecha_nacimiento DATE,
    contrasena VARCHAR(255) NOT NULL,
    estado BOOLEAN DEFAULT TRUE
);

-- 2. ROL
CREATE TABLE rol (
    id_rol INT AUTO_INCREMENT PRIMARY KEY,
    nombre_rol VARCHAR(50) NOT NULL
);

-- 3. USUARIO_ROL
CREATE TABLE usuario_rol (
    id_usuario INT,
    id_rol INT,
    estado VARCHAR(10),
    fecha_inicio DATE,
    PRIMARY KEY (id_usuario, id_rol),
    FOREIGN KEY (id_usuario) REFERENCES usuario(id_usuario),
    FOREIGN KEY (id_rol) REFERENCES rol(id_rol)
);

-- 4. CATEGORIA
CREATE TABLE categoria (
    id_categoria INT AUTO_INCREMENT PRIMARY KEY,
    nombre_categoria VARCHAR(100) NOT NULL
);

-- 5. SERVICIO
CREATE TABLE servicio (
    id_servicio INT AUTO_INCREMENT PRIMARY KEY,
    id_categoria INT,
    nombre_servicio VARCHAR(100) NOT NULL,
    duracion VARCHAR(50),
    costo DECIMAL(10),
    FOREIGN KEY (id_categoria) REFERENCES categoria(id_categoria)
);

-- 6. MÉTODO DE PAGO
CREATE TABLE metodo_pago (
    id_metodo INT AUTO_INCREMENT PRIMARY KEY,
    metodo VARCHAR(50) NOT NULL
);

-- 7. FACTURA
CREATE TABLE factura (
    id_factura INT AUTO_INCREMENT PRIMARY KEY,
    id_usuario INT NOT NULL,
    id_metodo INT NOT NULL,
    fecha_pago TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    valor_pagado DECIMAL(10,2),
    referencia_pago VARCHAR(50),
    FOREIGN KEY (id_usuario) REFERENCES usuario(id_usuario),
    FOREIGN KEY (id_metodo) REFERENCES metodo_pago(id_metodo)
);

-- 8. FACTURA_SERVICIO
CREATE TABLE factura_servicio (
    id_factura INT,
    id_servicio INT,
    PRIMARY KEY (id_factura, id_servicio),
    FOREIGN KEY (id_factura) REFERENCES factura(id_factura),
    FOREIGN KEY (id_servicio) REFERENCES servicio(id_servicio)
);

-- 9. HORARIO
CREATE TABLE horario (
    id_horario INT AUTO_INCREMENT PRIMARY KEY,
    dia ENUM('Lunes','Martes','Miércoles','Jueves','Viernes','Sábado','Domingo') NOT NULL,
    hora TIME NOT NULL,
    id_servicio INT,
    disponible BOOLEAN DEFAULT TRUE,
    FOREIGN KEY (id_servicio) REFERENCES servicio(id_servicio)
);

-- 10. AGENDA ENTRENADOR
CREATE TABLE agenda_entrenador (
    id_usuario INT,
    id_horario INT,
    PRIMARY KEY (id_usuario, id_horario),
    FOREIGN KEY (id_usuario) REFERENCES usuario(id_usuario),
    FOREIGN KEY (id_horario) REFERENCES horario(id_horario)
);

-- 11. HORARIOS DISPONIBLES
CREATE TABLE Horario_Disponible (
    ID_Horario INT AUTO_INCREMENT PRIMARY KEY,
    Dia_Semana ENUM('Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo'),
    Hora TIME,
    Disponible BOOL DEFAULT TRUE,
    Clase VARCHAR(50) 
);

-- 12. HISTORIAL DE CONTRASEÑAS
CREATE TABLE historial_contrasenas (
    id_historial INT AUTO_INCREMENT PRIMARY KEY,
    id_usuario INT NOT NULL,
    contrasena_anterior VARCHAR(255) NOT NULL,
    fecha_modificacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_usuario) REFERENCES usuario(id_usuario)
);
