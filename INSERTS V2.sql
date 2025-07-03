-- ============================
-- DATOS INICIALES
-- ============================

-- ROLES DISPONIBLES
INSERT INTO rol (nombre_rol) VALUES ('Cliente'), ('Administrador'), ('Entrenador');

-- MÉTODOS DE PAGO
INSERT INTO metodo_pago (metodo) VALUES
('Efectivo'),
('Tarjeta Crédito'),
('Tarjeta Débito'),
('Transferencia');

-- CATEGORÍA DE PLANES
INSERT INTO categoria (nombre_categoria) VALUES ('Planes GYM');

-- PLANES DISPONIBLES
INSERT INTO servicio (id_categoria, nombre_servicio, duracion, costo) VALUES
(1, 'Gym_Pilates', '1 mes', 50000.00),
(1, 'Gym_Boxeo', '1 mes', 60000.00),
(1, 'Gym_Entrenador_Personalizado', '1 mes', 80000.00),
(1, 'Gym_Zumba', '1 mes', 55000.00),
(1, 'Gym_Rumba', '1 mes', 45000.00),
(1, 'Gym_Only', '1 mes', 70000.00),
(1, 'Gym_All', '1 mes', 100000.00);