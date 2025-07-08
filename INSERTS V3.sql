-- ================================================
-- ARCHIVO 2: DATOS INICIALES - GYMTRACK
-- ================================================
USE GYMTRACK;

-- ============================
-- ROLES DISPONIBLES
-- ============================
INSERT INTO rol (nombre_rol) VALUES
('Cliente'),
('Administrador'),
('Entrenador');



-- ============================
-- MÉTODOS DE PAGO
-- ============================
INSERT INTO metodo_pago (metodo) VALUES
('Efectivo'),
('Tarjeta Crédito'),
('Tarjeta Débito'),
('Transferencia');

-- ============================
-- CATEGORÍAS DE PLANES
-- ============================
INSERT INTO categoria (nombre_categoria) VALUES
('Planes GYM');

-- ============================
-- PLANES / SERVICIOS DISPONIBLES
-- ============================
INSERT INTO servicio (id_categoria, nombre_servicio, duracion, costo) VALUES
(1, 'Gym_Pilates', '1 mes', 90000),
(1, 'Gym_Boxeo', '1 mes', 90000),
(1, 'Gym_Entrenador_Personalizado', '1 mes', 160000),
(1, 'Gym_Spining', '1 mes', 80000),
(1, 'Gym_Libre', '1 mes', 120000),
(1, 'Zona_Funcional', '1 mes', 95000);
