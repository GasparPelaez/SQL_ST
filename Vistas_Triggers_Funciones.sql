-- CREACION DE FUNCIONES ----------------------------------------------------------
 

-- Función para calcular el total gastado por un cliente en servicios.

DROP FUNCTION IF EXISTS CalcularTotalGastadoCliente ;

DELIMITER //
CREATE FUNCTION CalcularTotalGastadoCliente(id_clientes INT)
RETURNS DECIMAL(10, 2)
DETERMINISTIC
BEGIN
    DECLARE totalGastado DECIMAL(10, 2);
    SELECT SUM(s.Precio)
    INTO totalGastado
    FROM HistorialServicios hs
    JOIN COMPUTADORAS v ON hs.computadoras_id = v.id_computadoras
    JOIN Servicios s ON hs.Servicios_id = s.id_servicios
    WHERE v.Cliente_id = id_clientes;
    RETURN totalGastado;
END //
DELIMITER ;
-- SELECT CalcularTotalGastadoCliente(7).


-- Función para Encontrar el Servicio Más Caro.

DROP FUNCTION IF EXISTS EncontrarServicioMasCaro;

DELIMITER $$
CREATE FUNCTION EncontrarServicioMasCaro() RETURNS VARCHAR(50)
DETERMINISTIC 
BEGIN
    DECLARE servicio_mas_caro VARCHAR(50);
    SELECT Descripcion INTO servicio_mas_caro FROM SERVICIOS 
    ORDER BY Precio DESC LIMIT 1;
    RETURN servicio_mas_caro;
END;
$$
DELIMITER 
-- SELECT EncontrarServicioMasCaro().


-- Calcular el Total de Gastos de un Empleado en compras.

DROP FUNCTION IF EXISTS CalcularTotalGastosEmpleado;

DELIMITER $$
CREATE FUNCTION CalcularTotalGastosEmpleado(id_empleados INT) RETURNS DECIMAL(10, 2)
DETERMINISTIC 
BEGIN
    DECLARE total DECIMAL(10, 2);
    SELECT SUM(Precio) INTO total FROM COMPRAS WHERE Empleados_id = id_empleados;
    RETURN total;
END;
$$
DELIMITER ;
-- SELECT CalcularTotalGastosEmpleado(7).


-- Función para obtener cantidad total disponible del producto por nombre.

DROP FUNCTION IF EXISTS ObtenerInventarioPorNombre;

DELIMITER //
CREATE FUNCTION ObtenerInventarioPorNombre(productoNombre VARCHAR(50))
RETURNS INT
DETERMINISTIC 
BEGIN
    DECLARE cantidad INT;
    SELECT SUM(CantidadDisponible)
    INTO cantidad
    FROM INVENTARIO
    WHERE Nombre = productoNombre;
    RETURN cantidad;
END //
DELIMITER ;
-- SELECT ObtenerInventarioPorNombre("compresores").


/*----------------------------------------------------- CREACION DE TRIGGERS --------------------------------------------------------*/
 
 
-- Clientes - Notificación de nuevo cliente.
-- Creando una tabla temporal para registrar los cambios viejos.

DROP TRIGGER IF EXISTS NuevoClienteNotification;

DELIMITER //
CREATE TRIGGER NuevoClienteNotification
AFTER INSERT
ON CLIENTES FOR EACH ROW
BEGIN
    DECLARE Mensaje VARCHAR(255);
    
    SET Mensaje = CONCAT('Nuevo cliente agregado: ', NEW.Nombre, ' ', NEW.Apellido);
    
    -- Inserta el mensaje en la tabla temporal
    CREATE TEMPORARY TABLE IF NOT EXISTS TempNotificaciones (
        ID INT AUTO_INCREMENT PRIMARY KEY,
        Mensaje VARCHAR(255)
    );
    
    INSERT INTO TempNotificaciones (Mensaje)
    VALUES (Mensaje);
END;
//
DELIMITER ;
-- Probamos el Triggers insertando datos.
-- INSERT INTO CLIENTES.
-- VALUES (null, 'Cliente', 'Ejemplo', 'Pasaporte', 12312, 9876543210, 'Dirección', 'CP', 'correo@ejemplo.com').

-- SELECT * FROM TempNotificaciones. Se ve el mensaje de creacion.
-- SELECT * FROM clientes.




-- SERVICIOS - Registro de cambios en los precios.
-- Creando una tabla temporal para registrar los cambios viejos.

DROP TRIGGER IF EXISTS RegistroCambiosPrecioServicio;

DELIMITER //
CREATE TRIGGER RegistroCambiosPrecioServicio
BEFORE UPDATE
ON SERVICIOS FOR EACH ROW
BEGIN
    DECLARE PrecioAnterior DECIMAL(8, 2);
    
    IF NEW.Precio <> OLD.Precio THEN
        -- Almacena el precio anterior en una tabla temporal
        CREATE TEMPORARY TABLE IF NOT EXISTS TempPreciosAnteriores (
            id_servicio INT,
            PrecioAnterior DECIMAL(8, 2)
        );
        
        SET PrecioAnterior = OLD.Precio;
        
        -- Inserta el registro en la tabla temporal.
        INSERT INTO TempPreciosAnteriores (id_servicio, PrecioAnterior)
        VALUES (NEW.id_servicios, PrecioAnterior);
    END IF;
END;
//
DELIMITER ;

-- Probamos el triggers y cambiamos el precio del servicio".
-- UPDATE SERVICIOS
-- SET Precio = 100
-- WHERE id_servicios = 1.

-- SELECT * FROM TempPreciosAnteriores;  --Se ve el precio anterior puesto.
-- SELECT * FROM SERVICIOS WHERE id_servicios = 1; --Se ve el nuevo precio puesto.





-- INVENTARIO - Registro de cambios en el stock.
-- Creando una tabla temporal para registrar los cambios viejos.
 
DROP TRIGGER IF EXISTS RegistroCambiosStockInventario;
 
DELIMITER //
CREATE TRIGGER RegistroCambiosStockInventario
BEFORE UPDATE
ON INVENTARIO FOR EACH ROW
BEGIN
    DECLARE CantidadAnterior INT;
    
    IF NEW.CantidadDisponible <> OLD.CantidadDisponible THEN
        -- Almacena la cantidad anterior en una tabla temporal.
        CREATE TEMPORARY TABLE IF NOT EXISTS TempCantidadesAnteriores (
            id_inventario INT,
            CantidadAnterior INT
        );
        
        SET CantidadAnterior = OLD.CantidadDisponible;
        
        -- Inserta el registro en la tabla temporal.
        INSERT INTO TempCantidadesAnteriores (id_inventario, CantidadAnterior)
        VALUES (NEW.id_inventario, CantidadAnterior);
    END IF;
END;
//
DELIMITER ;
-- Probamos el triggers y se cambia el stock del inventario".
-- UPDATE INVENTARIO
-- SET CantidadDisponible = 50
-- WHERE id_inventario = 1.

-- SELECT * FROM TempCantidadesAnteriores. -- Se ve el stock viejo.
-- SELECT * FROM INVENTARIO WHERE id_inventario = '1'. -- Se ve el stock nuevo.


/*----------------------------------------------------- CREACION DE SP --------------------------------------------------------*/


-- SP Para ordenar ASC o DESC depende TABLA y COLUMNA.

DROP PROCEDURE IF EXISTS OrdenarTabla;

DELIMITER //
CREATE PROCEDURE OrdenarTabla(IN nombreTabla VARCHAR(255), IN columnaOrden VARCHAR(255), IN orden VARCHAR(4))
BEGIN
    SET @query = CONCAT('SELECT * FROM ', nombreTabla, ' ORDER BY ', columnaOrden, ' ', orden);
    PREPARE stmt FROM @query;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
END //
DELIMITER ;
-- CALL OrdenarTabla('clientes', 'Nombre', 'ASC').


-- SP Para insertar Clientes.

DROP PROCEDURE IF EXISTS InsertarCliente;

DELIMITER //
CREATE PROCEDURE InsertarCliente(
    IN p_Nombre VARCHAR(50),
    IN p_Apellido VARCHAR(50),
    IN p_TipoDocumento VARCHAR(20),
    IN p_NumeroDocumento VARCHAR(20),
    IN p_Telefono VARCHAR(20),
    IN p_Direccion VARCHAR(50),
    IN p_CP VARCHAR(15),
    IN p_Email VARCHAR(100)
)
BEGIN
    INSERT INTO CLIENTES (Nombre, Apellido, TipoDocumento, NumeroDocumento, Telefono, Direccion, CP, Email)
    VALUES (p_Nombre, p_Apellido, p_TipoDocumento, p_NumeroDocumento, p_Telefono, p_Direccion, p_CP, p_Email);
END //
DELIMITER ;

/*CALL InsertarCliente(
    'Juan',
    'Pérez',
    'DNI',
    '12345678',
    '555-123-456',
    'Calle Principal 123',
    '12345',
    'juan@example.com'
)*/
-- SELECT * FROM CLIENTES.


-- SP Eliminar un cliente.

DROP PROCEDURE IF EXISTS EliminarCliente;

DELIMITER //
CREATE PROCEDURE EliminarCliente(IN p_ClienteId INT)
BEGIN
    DELETE FROM CLIENTES WHERE id_clientes = p_ClienteId;
END //
DELIMITER ;
-- CALL EliminarCliente(20).       



-- SP Insertar una nueva computadora para un cliente existente.

DROP PROCEDURE IF EXISTS InsertarComputadoraParaCliente;

DELIMITER //

CREATE PROCEDURE InsertarComputadoraParaCliente(
    IN p_ClienteId INT,
    IN p_Marca VARCHAR(50),
    IN p_Modelo VARCHAR(50),
    IN p_Anio INT,
    IN p_numero_de_serie VARCHAR(20),
    )
BEGIN
    INSERT INTO computadoras (Cliente_id, Marca, Modelo, Anio, numero_de_serie)
    VALUES (p_ClienteId, p_Marca, p_Modelo, p_Anio, p_numero_de_serie);
END //
DELIMITER ;
-- CALL InsertarComputadoraParaCliente(1, 'NuevaMarca', 'NuevoModelo', 2022, 'NuevoSN', 5000).
-- SELECT * FROM computadoras.


/*----------------------------------------------------- CREACION DE VISTAS --------------------------------------------------------*/


-- VISTA de Clientes con Computadoras.

DROP VIEW IF EXISTS VistaClientesConComputadoras;

CREATE OR REPLACE VIEW VistaClientesConComputadoras AS
SELECT C.id_clientes, C.Nombre , C.Apellido , C.Telefono , C.Direccion, V.Marca, V.Modelo, V.numero_de_serie
FROM CLIENTES C
LEFT JOIN COMPUTADORAS V ON C.id_clientes = V.Cliente_id;
-- SELECT * FROM VistaClientesConComputadoras.



-- VISTA de Historial de Servicios Detallado.

DROP VIEW IF EXISTS VistaHistorialServiciosDetallado;

CREATE OR REPLACE VIEW VistaHistorialServiciosDetallado AS
SELECT HS.id_historialServicios, C.Nombre AS NombreCliente, V.Modelo AS ModeloComputadoras, S.Descripcion AS Servicio, E.Nombre AS NombreEmpleado, HS.Fecha, HS.Observaciones
FROM HISTORIALSERVICIOS HS
JOIN CLIENTES C ON HS.Computadoras_id = C.id_clientes
JOIN COMPUTADORAS V ON HS.Computadoras_id = V.id_computadoras
JOIN SERVICIOS S ON HS.Servicios_id = S.id_servicios
LEFT JOIN EMPLEADOS E ON HS.Empleados_id = E.id_empleados;
-- SELECT * FROM VistaHistorialServiciosDetallado.



-- VISTA de Ventas Totales por Cliente.

DROP VIEW IF EXISTS VistaVentasTotalesPorCliente;

CREATE OR REPLACE VIEW VistaVentasTotalesPorCliente AS
SELECT C.Nombre AS NombreCliente, SUM(V.Cantidad) AS TotalVentas
FROM CLIENTES C
LEFT JOIN VENTAS V ON C.id_clientes = V.Clientes_id
GROUP BY C.id_clientes;
-- SELECT * FROM VistaVentasTotalesPorCliente.



-- VISTA de Compras Totales por Proveedor.

DROP VIEW IF EXISTS VistaComprasTotalesPorProveedor;

CREATE OR REPLACE VIEW VistaComprasTotalesPorProveedor AS
SELECT
    P.Nombre AS NombreProveedor,
    SUM(C.Cantidad) AS TotalCompras
FROM PROVEEDORES P
LEFT JOIN COMPRAS C ON P.id_proveedores = C.Proveedores_id
GROUP BY P.Nombre;
-- SELECT * FROM VistaComprasTotalesPorProveedor.
