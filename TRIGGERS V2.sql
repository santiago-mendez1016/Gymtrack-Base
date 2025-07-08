-- ===================
-- TRIGGERS 
-- ===================


-- =====================
-- 1. CAMBIO DE CONTRASEÑA
-- =====================

DELIMITER //

CREATE TRIGGER Trigger_AuditarCambioContrasena
BEFORE UPDATE ON usuario
FOR EACH ROW
BEGIN
    -- Solo guardar si la contraseña realmente cambió
    IF OLD.contrasena <> NEW.contrasena THEN
        INSERT INTO historial_contrasenas (id_usuario, contrasena_anterior)
        VALUES (OLD.id_usuario, OLD.contrasena);
    END IF;
END //

DELIMITER ;


-- EN ESTA PARTE ES DONDE SE GUARDA LA NUEVA CONTRASEÑA Y SE GUARDA ULTIMA FECHA DE MODIFICACION DE ESTA
UPDATE usuario
SET contrasena = SHA2('nuevaclave123', 256)
WHERE correo = 'laura@gmail.com';


SELECT 
    hc.id_historial,
    u.nombre,
    hc.contrasena_anterior,
    hc.fecha_modificacion
FROM historial_contrasenas hc
JOIN usuario u ON hc.id_usuario = u.id_usuario
ORDER BY hc.fecha_modificacion DESC;	