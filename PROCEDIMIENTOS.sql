USE `gymtrack`;
DROP procedure IF EXISTS `CrearUsuario`;

DELIMITER $$
USE `gymtrack`$$
CREATE PROCEDURE CrearUsuario (
    IN Nombre VARCHAR(100),
    IN Correo VARCHAR(100),
    IN NumTel VARCHAR(20)
)
BEGIN
    -- Verificar si el correo ya existe
    IF NOT EXISTS (SELECT 1 FROM usuarios WHERE correo = Correo) THEN
        INSERT INTO usuarios (nombre, correo, telefono)
        VALUES (Nombre, Correo, NumTel);
    ELSE
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El correo ya está registrado.';
    END IF;
END$$

DELIMITER ;

USE `gymtrack`;
DROP procedure IF EXISTS `ModificarUsuarioGym`;

DELIMITER $$
USE `gymtrack`$$
CREATE PROCEDURE ModificarUsuarioGym (
    IN p_id INT,
    IN Nombre VARCHAR(100),
    IN Correo VARCHAR(100),
    IN NumTel VARCHAR(20)
)
BEGIN
    IF EXISTS (SELECT 1 FROM usuarios WHERE id = p_id) THEN

        IF NOT EXISTS (
            SELECT 1 FROM usuarios
            WHERE correo = Correo AND id <> p_id
        ) THEN

            UPDATE usuarios
            SET Nombre = p_nombre,
                Correo = p_correo,
                NumTel = p_telefono
            WHERE id = p_id;

        ELSE
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Ese correo ya está en uso por otro cliente.';
        END IF;

    ELSE
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El cliente no existe.';
    END IF;
END$$

DELIMITER ;

USE `gymtrack`;
DROP procedure IF EXISTS `VerificarLogin`;

DELIMITER $$
USE `gymtrack`$$
CREATE PROCEDURE VerificarLogin (
    IN Correo VARCHAR(100),
    IN contrasena VARCHAR(255)
)
BEGIN
    DECLARE v_id INT;

    SELECT id INTO v_id
    FROM usuarios
    WHERE correo = Correo AND contrasena = contrasena;

    IF v_id IS NOT NULL THEN
        SELECT 'Acceso permitido' AS mensaje, v_id AS usuario_id;
    ELSE
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Credenciales incorrectas';
    END IF;
END;$$

DELIMITER ;

USE `gymtrack`;
DROP procedure IF EXISTS `BuscarUsuarioPorDocumento`;

DELIMITER $$
USE `gymtrack`$$
CREATE PROCEDURE BuscarUsuarioPorDocumento (
    IN TipoDoc tinyint(3),
    IN NumDoc VARCHAR(20)
)
BEGIN
    IF EXISTS (
        SELECT 1 FROM usuarios
        WHERE tipo_documento = TipoDoc
          AND numero_documento = NumDoc
    ) THEN
        SELECT * FROM usuarios
        WHERE tipo_documento = TipoDoc
          AND numero_documento = NumDoc;
    ELSE
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'No se encontró un usuario con ese documento.';
    END IF;
END;$$

DELIMITER ;

USE `gymtrack`;
DROP procedure IF EXISTS `BuscarUsuarioPorDocumento`;

DELIMITER $$


DROP TRIGGER IF EXISTS `gymtrack`.`usuario_AFTER_INSERT`;

DELIMITER $$
USE `gymtrack`$$
CREATE DEFINER = CURRENT_USER TRIGGER `gymtrack`.`usuario_AFTER_INSERT` AFTER INSERT ON `usuario` FOR EACH ROW
BEGIN
UPDATE usuario
SET activo = 1
WHERE id;
END$$
DELIMITER ;

CREATE OR REPLACE VIEW vw_usuarios_roles AS
SELECT 
    u.id AS usuario_id,
    u.nombre AS nombre_usuario,
    u.correo,
    u.telefono,
    u.activo,
    r.nombre_rol
FROM usuarios u
JOIN roles r ON u.rol_id = r.id;


USE `gymtrack`;
DROP procedure IF EXISTS `sp_registrar_pago`;

DELIMITER $$
USE `gymtrack`$$
CREATE PROCEDURE `sp_registrar_pago` (
IN p_NumDoc VARCHAR(15),
    IN p_TipoDoc TINYINT,
    IN p_ID_MetodoPago TINYINT,
    IN p_ValorPagado INT,
    IN p_RefPago INT
)
BEGIN
    INSERT INTO Factura (NumDoc, UsuarioTipoDoc, ID_MetoPago, ValorPag, RefPago)
    VALUES (p_NumDoc, p_TipoDoc, p_ID_MetodoPago, p_ValorPagado, p_RefPago);
END$$

DELIMITER ;



DELIMITER //

CREATE PROCEDURE sp_aplicar_descuento (
    IN p_IDFactura TINYINT
)
BEGIN
    DECLARE v_TotalOriginal INT;
    DECLARE v_TotalDescuento INT DEFAULT 0;
    DECLARE v_Porc TINYINT;
    DECLARE v_DescServicioID TINYINT;
    
    -- Sumar los costos originales
    SELECT SUM(s.Costo)
    INTO v_TotalOriginal
    FROM Factura_Servicio fs
    JOIN Servicio s ON s.IDServicio = fs.ServicioIDServicio
    WHERE fs.FACTURAID_Factura = p_IDFactura;

    -- Calcular el descuento (si hay)
    SELECT d.Porc
    INTO v_Porc
    FROM Descuentos d
    JOIN Factura_Servicio fs ON fs.ServicioIDServicio = d.ID_Servicio
    WHERE fs.FACTURAID_Factura = p_IDFactura
    AND CURRENT_DATE BETWEEN d.FechIni AND DATE_ADD(d.FechIni, INTERVAL d.Durac DAY)
    LIMIT 1;

    IF v_Porc IS NOT NULL THEN
        SET v_TotalDescuento = v_TotalOriginal - (v_TotalOriginal * v_Porc / 100);
    ELSE
        SET v_TotalDescuento = v_TotalOriginal;
    END IF;

    -- Actualizar el valor en la factura
    UPDATE Factura
    SET ValorPag = v_TotalDescuento
    WHERE ID_Factura = p_IDFactura;
END;
//

DELIMITER ;

CALL sp_aplicar_descuento(1); -- Aplica descuento a la factura con ID 1


CREATE OR REPLACE VIEW vw_historial_pagos AS
SELECT 
    f.ID_Factura,
    f.FecPag,
    f.ValorPag,
    f.RefPago,
    
    u.NumDoc,
    u.Nombre,
    u.Ape1,
    u.Ape2,
    u.Correo,
    
    mp.MetodPago,
    
    s.IDServicio,
    s.Descr AS Servicio,
    s.Costo,
    s.Durac

FROM Factura f
JOIN Usuario u 
    ON f.NumDoc = u.NumDoc AND f.UsuarioTipoDoc = u.TipoDoc

JOIN Metodo_Pago mp 
    ON f.ID_MetoPago = mp.ID_MetoPago

JOIN Factura_Servicio fs 
    ON fs.FACTURAID_Factura = f.ID_Factura 
    AND fs.UsuarioNumDoc = u.NumDoc 
    AND fs.UsuarioTipoDoc = u.TipoDoc

JOIN Servicio s 
    ON s.IDServicio = fs.ServicioIDServicio;
    
SELECT * FROM vw_historial_pagos;

DELIMITER //

CREATE PROCEDURE sp_ver_servicios()
BEGIN
    SELECT 
        s.IDServicio,
        s.Descr AS Servicio,
        c.Nombre AS Categoria,
        s.Durac,
        s.Costo
    FROM Servicio s
    LEFT JOIN CATEGORIAS c ON s.ID_Categoria = c.ID_Categoria;
END;
//

DELIMITER ;

CALL sp_ver_servicios();

DELIMITER //

CREATE TRIGGER trg_descuento_factura
BEFORE INSERT ON Factura
FOR EACH ROW
BEGIN
    DECLARE v_descuento INT DEFAULT 0;
    DECLARE v_porcentaje INT;

    -- Buscar si hay un descuento activo para el servicio relacionado
    SELECT d.Porc
    INTO v_porcentaje
    FROM Descuentos d
    JOIN Factura_Servicio fs ON fs.ServicioIDServicio = d.ID_Servicio
    WHERE fs.FACTURAID_Factura = NEW.ID_Factura
      AND CURDATE() BETWEEN d.FechIni AND DATE_ADD(d.FechIni, INTERVAL d.Durac DAY)
    LIMIT 1;

    -- Si hay descuento, aplicarlo al valor
    IF v_porcentaje IS NOT NULL THEN
        SET NEW.ValorPag = NEW.ValorPag - (NEW.ValorPag * v_porcentaje / 100);
    END IF;

END;
//
DELIMITER ;

DELIMITER //

CREATE TRIGGER trg_fecha_pago
BEFORE INSERT ON Factura
FOR EACH ROW
BEGIN
    SET NEW.FecPag = CURRENT_TIMESTAMP;
END;
//

DELIMITER ;

SELECT * FROM Factura WHERE ID_Factura = 1;

CREATE OR REPLACE VIEW vw_descuentos_servicios AS
SELECT 
    d.ID_Desc,
    d.Nom AS Nombre_Descuento,
    d.Porc AS Porcentaje,
    d.Descr AS Descripcion_Descuento,
    d.Durac AS Duracion_Dias,
    d.FechIni AS Fecha_Inicio,
    
    s.IDServicio,
    s.Descr AS Servicio,
    s.Costo AS Precio_Original

FROM Descuentos d
JOIN Servicio s ON d.ID_Servicio = s.IDServicio;

SELECT * FROM vw_descuentos_servicios;












