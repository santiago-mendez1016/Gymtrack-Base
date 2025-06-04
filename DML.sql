DROP DATABASE IF EXISTS Gymtrack;
CREATE DATABASE Gymtrack;
USE Gymtrack;

-- Tabla de tipo de documento
CREATE TABLE Tipo_Doc (
    TipoDoc TINYINT(3) PRIMARY KEY,
    NomDoc VARCHAR(255)
);

-- Tabla de roles
CREATE TABLE Roles (
    ID_Rol TINYINT(3) PRIMARY KEY,
    NomRol VARCHAR(255)
);

-- Tabla de clientes / usuarios
CREATE TABLE Usuario (
    NumDoc VARCHAR(15) PRIMARY KEY,
    TipoDoc TINYINT(3),
    Nombre VARCHAR(50),
    Ape1 VARCHAR(30),
    Ape2 VARCHAR(30),
    NumTel VARCHAR(15),
    Correo VARCHAR(100),
    EstUsu BIT,
    Direccion VARCHAR(100),
    Contr VARCHAR(20),
    IDRol TINYINT(3), -- si decides conservarlo, aunque se recomienda gestionarlo por Usuario_Roles
    FechNac DATE
);

-- Tabla de relación Usuario - Roles
CREATE TABLE Usuario_Roles (
    UsuarioNumDoc VARCHAR(15),
    UsuarioTipoDoc TINYINT(3),
    RolesIDRol TINYINT(3),
    Estado VARCHAR(10),
    FechIniEst DATE,
    PRIMARY KEY (UsuarioNumDoc, UsuarioTipoDoc, RolesIDRol)
);

-- Tabla de método de pago
CREATE TABLE Metodo_Pago (
    ID_MetoPago TINYINT(3) PRIMARY KEY,
    MetodPago VARCHAR(15)
);

-- Tabla de facturas
CREATE TABLE Factura (
    ID_Factura TINYINT(3) PRIMARY KEY,
    NumDoc VARCHAR(15),
    ID_MetoPago TINYINT(3),
    UsuarioTipoDoc TINYINT(3),
    ValorPag INTEGER(10),
    FecPag TIMESTAMP,
    RefPago INTEGER(10)
);

-- Tabla de categorías de servicios
CREATE TABLE CATEGORIAS (
    ID_Categoria TINYINT(3) PRIMARY KEY,
    Nombre VARCHAR(255),
    ServicioIDServicio TINYINT(3)
);

-- Tabla de servicios
CREATE TABLE Servicio (
    IDServicio TINYINT(3) PRIMARY KEY,
    ID_Categoria TINYINT(3),
    Descr VARCHAR(255),
    Durac VARCHAR(255),
    Costo INTEGER(10)
);

-- Tabla de relación Factura - Servicios
CREATE TABLE Factura_Servicio (
    FACTURAID_Factura TINYINT(3),
    ServicioIDServicio TINYINT(3),
    ServicioID_Categoria TINYINT(3),
    UsuarioNumDoc VARCHAR(15),
    UsuarioTipoDoc TINYINT(3)
);

-- Tabla de descuentos
CREATE TABLE Descuentos (
    ID_Desc TINYINT(3) PRIMARY KEY,
    Nom VARCHAR(255),
    Porc TINYINT(3),
    Descr VARCHAR(255),
    Durac VARCHAR(255),
    FechIni DATE,
    ID_Servicio TINYINT(3)
);


-- Llaves foraneas:


-- Usuario
ALTER TABLE Usuario ADD FOREIGN KEY (TipoDoc) REFERENCES Tipo_Doc(TipoDoc);


-- Usuario_Roles
ALTER TABLE Usuario_Roles ADD FOREIGN KEY (UsuarioNumDoc) REFERENCES Usuario(NumDoc);
ALTER TABLE Usuario_Roles ADD FOREIGN KEY (UsuarioTipoDoc) REFERENCES Tipo_Doc(TipoDoc);
ALTER TABLE Usuario_Roles ADD FOREIGN KEY (RolesIDRol) REFERENCES Roles(ID_Rol);


-- Factura
ALTER TABLE Factura ADD FOREIGN KEY (NumDoc) REFERENCES Usuario(NumDoc);
ALTER TABLE Factura ADD FOREIGN KEY (ID_MetoPago) REFERENCES Metodo_Pago(ID_MetoPago);
ALTER TABLE Factura ADD FOREIGN KEY (UsuarioTipoDoc) REFERENCES Tipo_Doc(TipoDoc);


-- Servicio
ALTER TABLE Servicio ADD FOREIGN KEY (ID_Categoria) REFERENCES CATEGORIAS(ID_Categoria);


-- CATEGORIAS (relación inversa opcional, puede eliminarse)
ALTER TABLE CATEGORIAS ADD FOREIGN KEY (ServicioIDServicio) REFERENCES Servicio(IDServicio);


-- Factura_Servicio
ALTER TABLE Factura_Servicio ADD FOREIGN KEY (FACTURAID_Factura) REFERENCES Factura(ID_Factura);
ALTER TABLE Factura_Servicio ADD FOREIGN KEY (ServicioIDServicio) REFERENCES Servicio(IDServicio);
ALTER TABLE Factura_Servicio ADD FOREIGN KEY (ServicioID_Categoria) REFERENCES CATEGORIAS(ID_Categoria);
ALTER TABLE Factura_Servicio ADD FOREIGN KEY (UsuarioNumDoc) REFERENCES Usuario(NumDoc);
ALTER TABLE Factura_Servicio ADD FOREIGN KEY (UsuarioTipoDoc) REFERENCES Tipo_Doc(TipoDoc);


-- Descuentos
ALTER TABLE Descuentos ADD FOREIGN KEY (ID_Servicio) REFERENCES Servicio(IDServicio);
