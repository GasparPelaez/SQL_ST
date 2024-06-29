-- Creamos la base de datos del local Servicio Tecnico

DROP DATABASE IF EXISTS servicio_tecnico;

CREATE DATABASE servicio_tecnico;

USE servicio_tecnico;

-- Crecion de Tablas

-- Tabla clientes

CREATE TABLE CLIENTES (
    id_clientes INT AUTO_INCREMENT UNIQUE PRIMARY KEY,
    Nombre VARCHAR(50) NOT NULL,
    Apellido VARCHAR(50) NOT NULL,
    TipoDocumento VARCHAR(20) NOT NULL,
    NumeroDocumento VARCHAR(20) UNIQUE NOT NULL,
    Telefono VARCHAR(20) NOT NULL,
    Direccion VARCHAR(50),
    CP VARCHAR(15),
    Email VARCHAR(100)
);

-- Tabla Computadoras

CREATE TABLE Computadoras (
    id_computadoras INT AUTO_INCREMENT UNIQUE PRIMARY KEY,
    Cliente_id INT NOT NULL,
    FOREIGN KEY (Cliente_id)
        REFERENCES clientes (id_clientes)
        ON DELETE CASCADE,
    Marca VARCHAR(50),
    Modelo VARCHAR(50) NOT NULL,
    Anio INT,
    numero_de_serie VARCHAR(20) NOT NULL
);

-- Tabla SERVICIOS
CREATE TABLE SERVICIOS (
    id_servicios INT AUTO_INCREMENT UNIQUE PRIMARY KEY,
    Descripcion VARCHAR(50) NOT NULL,
    Precio DECIMAL(8, 2) NOT NULL
);

-- Tabla EMPLEADOS
CREATE TABLE EMPLEADOS (
    id_empleados INT AUTO_INCREMENT UNIQUE PRIMARY KEY,
    contacto_id INT,
    Nombre VARCHAR(50) NOT NULL,
    Apellido VARCHAR(50) NOT NULL,
    Cargo VARCHAR(50) NOT NULL
);


-- Tabla HistorialServicios

CREATE TABLE HistorialServicios (
    id_historialServicios INT AUTO_INCREMENT UNIQUE PRIMARY KEY,
    computadoras_id INT NOT NULL,
    FOREIGN KEY (computadoras_id)
        REFERENCES Computadoras (id_computadoras)
        ON DELETE CASCADE,
    Servicios_id INT NOT NULL,
    FOREIGN KEY (Servicios_id)
        REFERENCES servicios (id_servicios)
        ON DELETE CASCADE,
    Empleados_id INT,
    FOREIGN KEY (Empleados_id)
        REFERENCES empleados (id_empleados)
        ON DELETE CASCADE,
    Fecha DATE NOT NULL,
    Observaciones TEXT
);

-- Tabla CONTACTO
CREATE TABLE CONTACTO (
    id_contacto INT AUTO_INCREMENT UNIQUE PRIMARY KEY,
    Telefono VARCHAR(50) NOT NULL,
    Email VARCHAR(50) NOT NULL
);

-- Tabla CITAS
CREATE TABLE CITAS (
    id_citas INT AUTO_INCREMENT UNIQUE PRIMARY KEY,
    Cliente_id INT NOT NULL,
    FOREIGN KEY (Cliente_id)
        REFERENCES clientes (id_clientes)
        ON DELETE CASCADE,
    computadoras_id INT NOT NULL,
    FOREIGN KEY (computadoras_id)
        REFERENCES Computadoras (id_computadoras)
        ON DELETE CASCADE,
    Fecha DATE,
    Descripcion VARCHAR(100)
);

-- Tabla INVENTARIO
CREATE TABLE INVENTARIO (
    id_inventario INT AUTO_INCREMENT UNIQUE PRIMARY KEY,
    Nombre VARCHAR(50) NOT NULL,
    CantidadDisponible INT,
    PrecioUnitario DECIMAL(8, 2) NOT NULL
);

-- Tabla VENTAS
CREATE TABLE VENTAS (
    id_ventas INT AUTO_INCREMENT UNIQUE PRIMARY KEY,
    Clientes_id INT NOT NULL,
    FOREIGN KEY (Clientes_id)
        REFERENCES clientes (id_clientes)
        ON DELETE CASCADE,
    Empleados_id INT,
    FOREIGN KEY (Empleados_id)
        REFERENCES empleados (id_empleados)
        ON DELETE CASCADE,
    Inventario_id INT NOT NULL,
    FOREIGN KEY (Inventario_id)
        REFERENCES inventario (id_inventario)
        ON DELETE CASCADE,
    Fecha DATE NOT NULL,
    Cantidad INT NOT NULL,
    Total DECIMAL(10, 2) NOT NULL
);

-- Tabla PROVEEDORES
CREATE TABLE PROVEEDORES (
    id_proveedores INT AUTO_INCREMENT UNIQUE PRIMARY KEY,
    Nombre VARCHAR(50) NOT NULL,
    Direccion VARCHAR(50),
    Telefono VARCHAR(20),
    Email VARCHAR(100)
);

-- Tabla COMPRAS
CREATE TABLE COMPRAS (
    id_compras INT AUTO_INCREMENT UNIQUE PRIMARY KEY,
    Proveedores_id INT NOT NULL,
    FOREIGN KEY (Proveedores_id)
        REFERENCES PROVEEDORES (id_proveedores)
		ON DELETE CASCADE,
    Empleados_id INT NOT NULL,
    FOREIGN KEY (Empleados_id)
        REFERENCES empleados (id_empleados)
        ON DELETE CASCADE,
    Inventario_id INT NOT NULL,
    FOREIGN KEY (Inventario_id)
        REFERENCES inventario (id_inventario)
        ON DELETE CASCADE,
    Fecha DATE,
    Cantidad INT,
    Precio DECIMAL(10, 2)
);
