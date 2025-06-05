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

SELECT * FROM vw_descuentos_servicios;s












