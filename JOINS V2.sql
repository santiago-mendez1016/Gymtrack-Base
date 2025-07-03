-- ================================================
-- VISTAS Y CONSULTAS JOIN
-- ================================================
USE GYMTRACK;



-- VISTA: USUARIOS CON SU RESPECTIVO ROL Y DATOS PRINCIPALES
CREATE OR REPLACE VIEW VistaUsuariosConRol AS
SELECT
    u.id_usuario,
    u.nombre,
    u.documento,
    u.tipo_doc,
    u.correo,
    u.telefono,
    u.direccion,
    u.fecha_nacimiento,
    r.nombre_rol,
    ur.estado AS estado_rol,
    ur.fecha_inicio
FROM usuario u
JOIN usuario_rol ur ON u.id_usuario = ur.id_usuario
JOIN rol r ON ur.id_rol = r.id_rol;

CREATE OR REPLACE VIEW VistaFacturaDetalle AS
SELECT
    f.id_factura,
    u.nombre AS nombre_usuario,
    u.correo,
    mp.metodo AS metodo_pago,
    f.fecha_pago,
    f.valor_pagado,
    f.referencia_pago,
    s.nombre_servicio AS plan_contratado,
    s.duracion,
    s.costo
FROM factura f
JOIN usuario u ON f.id_usuario = u.id_usuario
JOIN metodo_pago mp ON f.id_metodo = mp.id_metodo
JOIN factura_servicio fs ON f.id_factura = fs.id_factura
JOIN servicio s ON fs.id_servicio = s.id_servicio;




-- CONSULTAS DE PRUEBA
SELECT * FROM VistaUsuariosConRol;
SELECT 
    s.id_servicio,
    c.nombre_categoria,
    s.nombre_servicio AS plan,
    s.duracion,
    s.costo
FROM servicio s
JOIN categoria c ON s.id_categoria = c.id_categoria;

SELECT * FROM VistaFacturaDetalle;


-- ================================================
-- VISTA: DISPONIBILIDAD DE HORARIOS
-- ================================================
CREATE OR REPLACE VIEW VistaDisponibilidadHorarios AS
SELECT
    dia,
    hora
FROM horario
ORDER BY 
    FIELD(dia, 'Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo'),
    hora;