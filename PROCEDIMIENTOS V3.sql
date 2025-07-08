-- ================================================
-- ARCHIVO 3: PROCEDIMIENTOS Y TRIGGERS - GYMTRACK
-- ================================================
USE GYMTRACK;

-- ============================
-- 1. PROCEDIMIENTO: REGISTRAR USUARIO COMPLETO
-- ============================
DELIMITER //

CREATE PROCEDURE RegistrarUsuarioCompleto (
    IN p_nombre VARCHAR(100),
    IN p_ape_1 VARCHAR(100),
    IN p_ape_2 VARCHAR(100),
    IN p_documento VARCHAR(20),
    IN p_tipo_doc ENUM('Cédula', 'Pasaporte'),
    IN p_correo VARCHAR(100),
    IN p_telefono VARCHAR(20),
    IN p_direccion VARCHAR(100),
    IN p_fecha_nacimiento DATE,
    IN p_contrasena VARCHAR(255),
    IN p_id_rol INT,
    IN p_estado_rol VARCHAR(10),
    IN p_fecha_inicio DATE
)
BEGIN
    DECLARE v_id_usuario INT;

    INSERT INTO usuario (
        nombre, ape_1, ape_2, documento, tipo_doc, correo, telefono, direccion, fecha_nacimiento, contrasena
    ) VALUES (
        p_nombre, p_ape_1, p_ape_2, p_documento, p_tipo_doc, p_correo, p_telefono, p_direccion, p_fecha_nacimiento,
        SHA2(p_contrasena, 256)
    );

    SET v_id_usuario = LAST_INSERT_ID();

    INSERT INTO usuario_rol (
        id_usuario, id_rol, estado, fecha_inicio
    ) VALUES (
        v_id_usuario, p_id_rol, p_estado_rol, p_fecha_inicio
    );
END //

DELIMITER ;

-- ============================
-- 2. PROCEDIMIENTO: INICIAR SESIÓN
-- ============================
DELIMITER //

CREATE PROCEDURE IniciarSesion (
    IN p_correo VARCHAR(100),
    IN p_contrasena VARCHAR(255)
)
BEGIN
    SELECT
        u.id_usuario,
        u.nombre,
        u.ape_1,
        u.ape_2,
        u.correo,
        r.nombre_rol,
        ur.estado AS estado_rol
    FROM usuario u
    JOIN usuario_rol ur ON u.id_usuario = ur.id_usuario
    JOIN rol r ON ur.id_rol = r.id_rol
    WHERE u.correo = p_correo
      AND u.contrasena = SHA2(p_contrasena, 256)
      AND u.estado = TRUE
    LIMIT 1;
END //

DELIMITER ;

-- ============================
-- 3. PROCEDIMIENTO: GENERAR FACTURA CON SERVICIOS
-- ============================
DELIMITER //

CREATE PROCEDURE GenerarFacturaConServicios (
    IN p_id_usuario INT,
    IN p_id_metodo INT,
    IN p_valor_pagado DECIMAL(10,2),
    IN p_referencia_pago VARCHAR(50),
    IN p_id_servicio1 INT,
    IN p_id_servicio2 INT,
    IN p_id_servicio3 INT
)
BEGIN
    DECLARE v_id_factura INT;

    INSERT INTO factura (
        id_usuario, id_metodo, valor_pagado, referencia_pago
    ) VALUES (
        p_id_usuario, p_id_metodo, p_valor_pagado, p_referencia_pago
    );

    SET v_id_factura = LAST_INSERT_ID();

    IF p_id_servicio1 IS NOT NULL THEN
        INSERT INTO factura_servicio (id_factura, id_servicio)
        VALUES (v_id_factura, p_id_servicio1);
    END IF;

    IF p_id_servicio2 IS NOT NULL THEN
        INSERT INTO factura_servicio (id_factura, id_servicio)
        VALUES (v_id_factura, p_id_servicio2);
    END IF;

    IF p_id_servicio3 IS NOT NULL THEN
        INSERT INTO factura_servicio (id_factura, id_servicio)
        VALUES (v_id_factura, p_id_servicio3);
    END IF;
END //

DELIMITER ;

-- ============================
-- 4. PROCEDIMIENTO: CARGAR HORARIOS DISPONIBLES
-- ============================
DELIMITER //

CREATE PROCEDURE CargarHorariosDisponibles()
BEGIN
    TRUNCATE TABLE Horario_Disponible;

    -- Lunes a Viernes: 6:00 a 20:00
    INSERT INTO Horario_Disponible (Dia_Semana, Hora)
    SELECT d.dia, MAKETIME(h.hora, 0, 0)
    FROM (
        SELECT 'Lunes' AS dia UNION
        SELECT 'Martes' UNION
        SELECT 'Miércoles' UNION
        SELECT 'Jueves' UNION
        SELECT 'Viernes'
    ) d,
    (
        SELECT 6 AS hora UNION SELECT 7 UNION SELECT 8 UNION SELECT 9 UNION
        SELECT 10 UNION SELECT 11 UNION SELECT 12 UNION SELECT 13 UNION SELECT 14 UNION
        SELECT 15 UNION SELECT 16 UNION SELECT 17 UNION SELECT 18 UNION SELECT 19 UNION SELECT 20
    ) h;

    -- Sábado: 8:00 a 14:00
    INSERT INTO Horario_Disponible (Dia_Semana, Hora)
    SELECT 'Sábado', MAKETIME(h.hora, 0, 0)
    FROM (
        SELECT 8 AS hora UNION SELECT 9 UNION SELECT 10 UNION SELECT 11 UNION
        SELECT 12 UNION SELECT 13 UNION SELECT 14
    ) h;

    -- Domingo: 9:00 a 17:00 con clase 'Gym_All'
    INSERT INTO Horario_Disponible (Dia_Semana, Hora, Clase)
    SELECT 'Domingo', MAKETIME(h.hora, 0, 0), 'Gym_All'
    FROM (
        SELECT 9 AS hora UNION SELECT 10 UNION SELECT 11 UNION SELECT 12 UNION
        SELECT 13 UNION SELECT 14 UNION SELECT 15 UNION SELECT 16 UNION SELECT 17
    ) h;
END //

DELIMITER ;

-- ============================
-- 5. PROCEDIMIENTO: ACTUALIZAR DATOS DE USUARIO
-- ============================
DELIMITER //

CREATE PROCEDURE ActualizarDatosUsuario (
    IN p_id_usuario INT,
    IN p_nuevo_nombre VARCHAR(100),
    IN p_nuevo_correo VARCHAR(100),
    IN p_nuevo_telefono VARCHAR(20),
    IN p_nueva_direccion VARCHAR(100),
    IN p_nueva_fecha_nacimiento DATE
)
BEGIN
    UPDATE usuario
    SET
        nombre = IFNULL(p_nuevo_nombre, nombre),
        correo = IFNULL(p_nuevo_correo, correo),
        telefono = IFNULL(p_nuevo_telefono, telefono),
        direccion = IFNULL(p_nueva_direccion, direccion),
        fecha_nacimiento = IFNULL(p_nueva_fecha_nacimiento, fecha_nacimiento)
    WHERE id_usuario = p_id_usuario;
END //

DELIMITER ;
