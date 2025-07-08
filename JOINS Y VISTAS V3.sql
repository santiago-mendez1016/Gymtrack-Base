-- =============================================
-- ARCHIVO: VISTAS Y CONSULTAS DE PRUEBA - GYMTRACK
-- ORGANIZADO Y FUNCIONAL PARA EXPOSICIÓN
-- =============================================

USE GYMTRACK;

-- =========================
-- 1. VISTA: USUARIOS CON SU RESPECTIVO ROL Y DATOS COMPLETOS
-- =========================

CREATE OR REPLACE VIEW VistaUsuariosConRol AS
SELECT
    u.id_usuario,
    u.documento AS "Número de Documento",
    u.tipo_doc AS "Tipo de Documento",
    u.nombre AS "Nombre",
    u.ape_1 AS "Primer Apellido",
    u.ape_2 AS "Segundo Apellido",
    u.telefono AS "Número de Teléfono",
    u.correo AS "Correo Electrónico",
    IF(u.estado = 1, 'Activo', 'Inactivo') AS "Estado del Usuario",
    u.direccion AS "Dirección",
    u.contrasena AS "Contraseña Encriptada",
    ur.id_rol AS "ID del Rol",
    r.nombre_rol AS "Rol",
    ur.estado AS "Estado del Rol",
    ur.fecha_inicio AS "Fecha de Inicio del Rol",
    u.fecha_nacimiento AS "Fecha de Nacimiento"
FROM usuario u
JOIN usuario_rol ur ON u.id_usuario = ur.id_usuario
JOIN rol r ON ur.id_rol = r.id_rol;

-- =========================
-- 2. VISTA: FACTURA DETALLADA (NORMALIZADA)
-- =========================

CREATE OR REPLACE VIEW VistaFacturaDetalle AS
SELECT
    f.id_factura,
    mp.id_metodo AS id_metodo_pago,
    u.documento AS doc_usuario,
    u.tipo_doc AS tipo_doc_usuario,
    f.valor_pagado,
    f.fecha_pago,
    f.referencia_pago
FROM factura f
INNER JOIN usuario u ON f.id_usuario = u.id_usuario
INNER JOIN metodo_pago mp ON f.id_metodo = mp.id_metodo;


-- =========================
-- 3. VISTA: SERVICIOS CON CATEGORÍA
-- =========================

CREATE OR REPLACE VIEW VistaServiciosConCategoria AS
SELECT 
    s.id_servicio,
    c.nombre_categoria,
    s.nombre_servicio AS plan,
    s.duracion,
    s.costo
FROM servicio s
JOIN categoria c ON s.id_categoria = c.id_categoria;

-- =========================
-- 4. VISTA: DISPONIBILIDAD DE HORARIOS (ORDENADA)
-- =========================

CREATE OR REPLACE VIEW VistaDisponibilidadHorarios AS
SELECT
    Dia_Semana,
    Hora,
    Disponible,
    Clase
FROM Horario_Disponible
ORDER BY 
    FIELD(Dia_Semana, 'Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo'),
    Hora;


-- ============================
-- 5. CALLS DE PRUEBA Y DATOS VISIBLES PARA EXPOSICIÓN
-- ============================

-- REGISTRAR USUARIO 1: Laura
CALL RegistrarUsuarioCompleto(
    'Laura',
    'Gómez',
    'Méndez',
    '1234567890',
    'Cédula',
    'laura@gmail.com',
    '3111111111',
    'Calle 10 #5-20',
    '2000-05-15',
    'clavecliente123',
    1,
    'Activo',
    CURDATE()
);

-- PROBAR INICIO DE SESIÓN
CALL IniciarSesion('laura@gmail.com', 'clavecliente123');

-- FACTURA PARA LAURA CON 3 SERVICIOS
CALL GenerarFacturaConServicios(
    1,                 -- id_usuario (Laura)
    1,                 -- id_metodo (Efectivo)
    150000.00,         -- valor_pagado
    'REF123ABC',       -- referencia_pago
    1,                 -- Gym_Pilates
    2,                 -- Gym_Boxeo
    3                  -- Gym_Entrenador_Personalizado
);

-- CARGAR HORARIOS DISPONIBLES
CALL CargarHorariosDisponibles();

-- ============================
-- 6. CONSULTAS DE VERIFICACIÓN
-- ============================

-- Ver usuarios con su rol
SELECT * FROM VistaUsuariosConRol;

-- Ver servicios y categorías
SELECT * FROM VistaServiciosConCategoria;

-- Ver detalles de la factura generada
SELECT * FROM VistaFacturaDetalle;

-- Ver directamente la tabla Horario_Disponible
SELECT * FROM Horario_Disponible
ORDER BY 
    FIELD(Dia_Semana, 'Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo'),
    Hora;
