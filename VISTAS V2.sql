
-- USUARIOS CON ROLES
CALL RegistrarUsuarioCompleto(
    'Laura Gómez',
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

CALL RegistrarUsuarioCompleto(
    'Carlos Pérez',
    '9876543210',
    'Cédula',
    'carlos@admin.com',
    '3202222222',
    'Carrera 12 #8-30',
    '1985-11-02',
    'claveadmin456',
    2,
    'Activo',
    CURDATE()
);

CALL RegistrarUsuarioCompleto(
    'Sofía Ramírez',
    '1122334455',
    'Cédula',
    'sofia@trainer.com',
    '3003333333',
    'Avenida 9 #3-15',
    '1990-08-22',
    'clavetrainer789',
    3,
    'Activo',
    CURDATE()
);

-- PRUEBAS DE INICIO DE SESIÓN
CALL IniciarSesion('laura@gmail.com', 'clavecliente123');
CALL IniciarSesion('carlos@admin.com', 'claveadmin456');
CALL IniciarSesion('sofia@trainer.com', 'clavetrainer789');

-- FACTURA PARA LAURA CON 3 SERVICIOS
CALL GenerarFacturaConServicios(
    1,                  -- id_usuario (Laura)
    1,                  -- id_metodo (Efectivo)
    150000.00,          -- valor_pagado
    'REF123ABC',        -- referencia_pago
    1,                  -- Gym_Pilates
    2,                  -- Gym_Boxeo
    3                   -- Gym_Entrenador_Personalizado
);

-- GENERAR HORARIOS DISPONIBLES
CALL CargarHorariosDisponibles();
SELECT *
FROM Horario_Disponible
ORDER BY 
    FIELD(Dia_Semana, 'Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo'),
    Hora;


CALL ActualizarDatosUsuario(
    1,                   -- ID de Laura Gómez
    'Laura G. Montoya',  -- Nuevo nombre
    NULL,                -- No cambia el correo
    '3209998888',        -- Nuevo teléfono
    NULL,                -- Dirección igual
    NULL                 -- Fecha nacimiento igual
);
SELECT * FROM usuario WHERE id_usuario = 2;