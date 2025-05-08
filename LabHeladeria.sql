CREATE DATABASE Heladeria;
GO
USE [master]
GO
CREATE LOGIN [usrheladeria] WITH PASSWORD = N'123456',
	DEFAULT_DATABASE = [Heladeria],
	CHECK_EXPIRATION = OFF,
	CHECK_POLICY = ON
GO
USE [Heladeria]
GO
CREATE USER [usrheladeria] FOR LOGIN [usrheladeria]
GO
ALTER ROLE [db_owner] ADD MEMBER [usrheladeria]
GO

DROP TABLE Pedido;
DROP TABLE VentaDetalle;
DROP TABLE Venta;
DROP TABLE Cliente;
DROP TABLE Sabor;
DROP TABLE Proveedor;
DROP TABLE Usuario;
DROP TABLE Empleado;
DROP TABLE Producto;

CREATE TABLE Producto (
  id INT NOT NULL PRIMARY KEY IDENTITY(1,1),
  nombre VARCHAR(250) NOT NULL,
  precio DECIMAL NOT NULL CHECK (precio > 0)
);
CREATE TABLE Empleado (
  id INT NOT NULL PRIMARY KEY IDENTITY(1,1),
  nombres VARCHAR(30) NOT NULL,
  primerApellido VARCHAR(30) NULL,
  segundoApellido VARCHAR(30) NULL,
  cargo VARCHAR(50) NOT NULL,
  fechaContratacion DATE NOT NULL DEFAULT GETDATE(),
  telefono BIGINT NOT NULL,
  direccion VARCHAR(250) NOT NULL,
);
CREATE TABLE Usuario (
  id INT NOT NULL PRIMARY KEY IDENTITY(1,1),
  idEmpleado INT NOT NULL,
  usuario VARCHAR(20) NOT NULL,
  clave VARCHAR(250) NOT NULL,
  CONSTRAINT fk_Usuario_Empleado FOREIGN KEY(idEmpleado) REFERENCES Empleado(id)
);
CREATE TABLE Proveedor (
  id INT NOT NULL PRIMARY KEY IDENTITY(1,1),
  nit BIGINT NOT NULL,
  telefono VARCHAR(30) NOT NULL,
  tipoProducto VARCHAR(100) NOT NULL
);
CREATE TABLE Sabor (
  id INT NOT NULL PRIMARY KEY IDENTITY(1,1),
  idProducto INT NOT NULL,
  nombre VARCHAR(250) NULL
  CONSTRAINT fk_Sabor_Producto FOREIGN KEY(idProducto) REFERENCES Producto(id)
);
CREATE TABLE Cliente (
  id INT NOT NULL PRIMARY KEY IDENTITY(1,1),
  ci BIGINT NOT NULL,
  razonSocial VARCHAR(100) NOT NULL,
  telefono VARCHAR(30) NOT NULL
);
CREATE TABLE Venta (
  id INT NOT NULL PRIMARY KEY IDENTITY(1,1),
  idUsuario INT NOT NULL,
  idCliente INT NOT NULL,
  fecha DATE NOT NULL DEFAULT GETDATE(),
  CONSTRAINT fk_Venta_Usuario FOREIGN KEY(idUsuario) REFERENCES Usuario(id),
  CONSTRAINT fk_Venta_Cliente FOREIGN KEY(idCliente) REFERENCES Cliente(id)
);
CREATE TABLE VentaDetalle (
  id INT NOT NULL PRIMARY KEY IDENTITY(1,1),
  idVenta INT NOT NULL,
  idProducto INT NOT NULL,
  cantidad DECIMAL NOT NULL CHECK (cantidad > 0),
  precioUnitario DECIMAL NOT NULL,
  total DECIMAL NOT NULL,
  CONSTRAINT fk_VentaDetalle_Venta FOREIGN KEY(idVenta) REFERENCES Venta(id),
  CONSTRAINT fk_VentaDetalle_Producto FOREIGN KEY(idProducto) REFERENCES Producto(id)
);
CREATE TABLE Pedido (
  id INT NOT NULL PRIMARY KEY IDENTITY(1,1),
  idCliente INT NOT NULL,
  idEmpleado INT NOT NULL,
  fechaPedido DATE NOT NULL DEFAULT GETDATE(),
  tipoPago VARCHAR(250) NOT NULL,
  estadoEntrega VARCHAR(250) NOT NULL,
  CONSTRAINT fk_Pedido_Cliente FOREIGN KEY(idCliente) REFERENCES Cliente(id),
  CONSTRAINT fk_Pedido_Empleado FOREIGN KEY(idEmpleado) REFERENCES Empleado(id)
);

ALTER TABLE Producto ADD usuarioRegistro VARCHAR(50) NOT NULL DEFAULT SUSER_NAME();
ALTER TABLE Producto ADD fechaRegistro DATETIME NOT NULL DEFAULT GETDATE();
ALTER TABLE Producto ADD estado SMALLINT NOT NULL DEFAULT 1; -- -1:Eliminado, 0: Inactivo, 1: Activo

ALTER TABLE Empleado ADD usuarioRegistro VARCHAR(50) NOT NULL DEFAULT SUSER_NAME();
ALTER TABLE Empleado ADD fechaRegistro DATETIME NOT NULL DEFAULT GETDATE();
ALTER TABLE Empleado ADD estado SMALLINT NOT NULL DEFAULT 1; -- -1:Eliminado, 0: Inactivo, 1: Activo

ALTER TABLE Usuario ADD usuarioRegistro VARCHAR(50) NOT NULL DEFAULT SUSER_NAME();
ALTER TABLE Usuario ADD fechaRegistro DATETIME NOT NULL DEFAULT GETDATE();
ALTER TABLE Usuario ADD estado SMALLINT NOT NULL DEFAULT 1; -- -1:Eliminado, 0: Inactivo, 1: Activo

ALTER TABLE Proveedor ADD usuarioRegistro VARCHAR(50) NOT NULL DEFAULT SUSER_NAME();
ALTER TABLE Proveedor ADD fechaRegistro DATETIME NOT NULL DEFAULT GETDATE();
ALTER TABLE Proveedor ADD estado SMALLINT NOT NULL DEFAULT 1; -- -1:Eliminado, 0: Inactivo, 1: Activo

ALTER TABLE Sabor ADD usuarioRegistro VARCHAR(50) NOT NULL DEFAULT SUSER_NAME();
ALTER TABLE Sabor ADD fechaRegistro DATETIME NOT NULL DEFAULT GETDATE();
ALTER TABLE Sabor ADD estado SMALLINT NOT NULL DEFAULT 1; -- -1:Eliminado, 0: Inactivo, 1: Activo

ALTER TABLE Cliente ADD usuarioRegistro VARCHAR(50) NOT NULL DEFAULT SUSER_NAME();
ALTER TABLE Cliente ADD fechaRegistro DATETIME NOT NULL DEFAULT GETDATE();
ALTER TABLE Cliente ADD estado SMALLINT NOT NULL DEFAULT 1; -- -1:Eliminado, 0: Inactivo, 1: Activo

ALTER TABLE Venta ADD usuarioRegistro VARCHAR(50) NOT NULL DEFAULT SUSER_NAME();
ALTER TABLE Venta ADD fechaRegistro DATETIME NOT NULL DEFAULT GETDATE();
ALTER TABLE Venta ADD estado SMALLINT NOT NULL DEFAULT 1; -- -1:Eliminado, 0: Inactivo, 1: Activo

ALTER TABLE VentaDetalle ADD usuarioRegistro VARCHAR(50) NOT NULL DEFAULT SUSER_NAME();
ALTER TABLE VentaDetalle ADD fechaRegistro DATETIME NOT NULL DEFAULT GETDATE();
ALTER TABLE VentaDetalle ADD estado SMALLINT NOT NULL DEFAULT 1; -- -1:Eliminado, 0: Inactivo, 1: Activo

GO
ALTER PROC paProductoListar @parametro VARCHAR(100)
AS
  SELECT * FROM Producto
  WHERE estado<>-1 AND nombre LIKE '%'+REPLACE(@parametro,' ','%')+'%'
  ORDER BY estado DESC, nombre ASC;

  EXEC paProductoListar '';

GO
ALTER PROC paEmpleadoListar @parametro VARCHAR(100)
AS
  SELECT ISNULL(u.usuario,'--') AS usuario,e.* 
  FROM Empleado e
  LEFT JOIN Usuario u ON e.id = u.idEmpleado
  WHERE e.estado<>-1 
	AND e.nombres+ISNULL(e.primerApellido,'')+ISNULL(e.segundoApellido,'') LIKE '%'+REPLACE(@parametro,' ','%')+'%'
  ORDER BY e.estado DESC, e.nombres ASC, e.primerApellido ASC;

  EXEC paEmpleadoListar '';

GO
ALTER PROC paProveedorListar @parametro VARCHAR(100)
AS
  SELECT * FROM Proveedor
  WHERE estado<>-1 AND nit+telefono+tipoProducto LIKE '%'+REPLACE(@parametro,' ','%')+'%'
  ORDER BY estado DESC;

EXEC paProveedorListar '';

GO
ALTER PROC paSaborListar @parametro VARCHAR(100)
AS
  SELECT ISNULL(p.nombre,'--') AS nombreProducto,s.*
  FROM Sabor s
  LEFT JOIN Producto p ON s.idProducto = p.id
  WHERE s.estado<>-1
  AND s.nombre LIKE '%'+REPLACE(@parametro,' ','%')+'%'
  OR p.nombre LIKE '%'+REPLACE(@parametro,' ','%')+'%'
  OR p.precio LIKE '%'+REPLACE(@parametro,' ','%')+'%'
  OR s.idProducto LIKE '%'+REPLACE(@parametro,' ','%')+'%'
  OR s.id LIKE '%'+REPLACE(@parametro,' ','%')+'%'
  ORDER BY s.estado DESC, p.nombre ASC;

  EXEC paSaborListar '';

GO
ALTER PROC paClienteListar @parametro VARCHAR(100)
AS
  SELECT * FROM Cliente
  WHERE estado<>-1 AND ci+razonSocial+telefono LIKE '%'+REPLACE(@parametro,' ','%')+'%'
  ORDER BY estado DESC, razonSocial ASC;

  EXEC paClienteListar '';

GO
ALTER PROC paVentaListar @parametro VARCHAR(100)
AS
SELECT 
    ISNULL(u.usuario, '--') AS usuario, 
    ISNULL(c.razonSocial, '--') AS cliente, 
    v.*
FROM Venta v
LEFT JOIN Usuario u ON v.idUsuario = u.id
LEFT JOIN Cliente c ON v.idCliente = c.id
WHERE v.estado = 1
  AND (
    u.usuario LIKE '%' + REPLACE(@parametro, ' ', '%') + '%'
    OR c.razonSocial LIKE '%' + REPLACE(@parametro, ' ', '%') + '%'
    OR CONVERT(VARCHAR(10), v.fecha, 120) LIKE '%' + REPLACE(@parametro, ' ', '%') + '%'
        OR CAST(v.id AS VARCHAR(20)) LIKE '%' + REPLACE(@parametro, ' ', '%') + '%'
    OR CAST(v.idCliente AS VARCHAR(20)) LIKE '%' + REPLACE(@parametro, ' ', '%') + '%'
  )
    ORDER BY v.estado DESC, v.fecha ASC

  EXEC paVentaListar '';

GO
ALTER PROC paVentaDetalleListar @parametro VARCHAR(100)
AS
  SELECT 
    ISNULL(v.id, '--') AS idVenta, 
    ISNULL(p.nombre, '--') AS nombreProducto, 
    ISNULL(s.nombre, '--') AS nombreSabor,
    vd.*
    FROM VentaDetalle vd
    LEFT JOIN Venta v ON vd.idVenta = v.id
    LEFT JOIN Producto p ON vd.idProducto = p.id
    LEFT JOIN Sabor s ON vd.idProducto = s.idProducto
    WHERE vd.estado<>-1
    AND (
      v.id LIKE '%' + REPLACE(@parametro, ' ', '%') + '%'
      OR p.nombre LIKE '%' + REPLACE(@parametro, ' ', '%') + '%'
      OR s.nombre LIKE '%' + REPLACE(@parametro, ' ', '%') + '%'
      OR vd.cantidad LIKE '%' + REPLACE(@parametro, ' ', '%') + '%'
      OR vd.precioUnitario LIKE '%' + REPLACE(@parametro, ' ', '%') + '%'
      OR vd.total LIKE '%' + REPLACE(@parametro, ' ', '%') + '%'
    )
    OR CAST(vd.id AS VARCHAR(20)) LIKE '%' + REPLACE(@parametro, ' ', '%') + '%'
    OR CAST(vd.idVenta AS VARCHAR(20)) LIKE '%' + REPLACE(@parametro, ' ', '%') + '%'
    OR CAST(vd.idProducto AS VARCHAR(20)) LIKE '%' + REPLACE(@parametro, ' ', '%') + '%'
    OR CAST(vd.cantidad AS VARCHAR(20)) LIKE '%' + REPLACE(@parametro, ' ', '%') + '%'
    OR CAST(vd.precioUnitario AS VARCHAR(20)) LIKE '%' + REPLACE(@parametro, ' ', '%') + '%'
    OR CAST(vd.total AS VARCHAR(20)) LIKE '%' + REPLACE(@parametro, ' ', '%') + '%'
  ORDER BY estado DESC, idVenta ASC;

  EXEC paVentaDetalleListar '';

GO
ALTER PROC paPedidoListar @parametro VARCHAR(100)
AS
SELECT 
    ISNULL(c.razonSocial, '--') AS cliente, 
    ISNULL(e.nombres, '--') AS empleado, 
    p.*
    FROM Pedido p
    LEFT JOIN Cliente c ON p.idCliente = c.id
    LEFT JOIN Empleado e ON p.idEmpleado = e.id
    WHERE p.estadoEntrega = 1
    AND (
      c.razonSocial LIKE '%' + REPLACE(@parametro, ' ', '%') + '%'
      OR e.nombres LIKE '%' + REPLACE(@parametro, ' ', '%') + '%'
      OR p.fechaPedido LIKE '%' + REPLACE(@parametro, ' ', '%') + '%'
      OR p.tipoPago LIKE '%' + REPLACE(@parametro, ' ', '%') + '%'
      OR p.estadoEntrega LIKE '%' + REPLACE(@parametro, ' ', '%') + '%'
    )
    OR CAST(p.id AS VARCHAR(20)) LIKE '%' + REPLACE(@parametro, ' ', '%') + '%'
    OR CAST(p.idCliente AS VARCHAR(20)) LIKE '%' + REPLACE(@parametro, ' ', '%') + '%'
    OR CAST(p.idEmpleado AS VARCHAR(20)) LIKE '%' + REPLACE(@parametro, ' ', '%') + '%'
    OR CAST(p.fechaPedido AS VARCHAR(20)) LIKE '%' + REPLACE(@parametro, ' ', '%') + '%'
    OR CAST(p.tipoPago AS VARCHAR(20)) LIKE '%' + REPLACE(@parametro, ' ', '%') + '%'
    OR CAST(p.estadoEntrega AS VARCHAR(20)) LIKE '%' + REPLACE(@parametro, ' ', '%') + '%'
    ORDER BY p.estadoEntrega DESC, p.fechaPedido ASC;

  EXEC paPedidoListar '';

-- DML
INSERT INTO Producto(nombre, precio)
VALUES ('Helado de Fresa', 5.00);

INSERT INTO Empleado(nombres, primerApellido, segundoApellido, cargo, fechaContratacion, telefono, direccion)
VALUES ('Juan', 'Saigua', 'Gómez', 'Vendedor', '2023-01-01', '72345678', 'Calle 4');

INSERT INTO Usuario(idEmpleado, usuario, clave)
VALUES (1, 'jsaigua', '123456');

INSERT INTO Proveedor(nit,telefono,tipoProducto)
VALUES ('10788334', '68902345', 'Frutas');

INSERT INTO Sabor(idProducto, nombre)
VALUES (1, 'Fresa');

INSERT INTO Cliente(ci, razonSocial, telefono)
VALUES ('12345678', 'Helados S.A.', '62345678');

INSERT INTO Venta(idUsuario, idCliente, fecha)
VALUES (2, 1, '2023-01-01');

INSERT INTO VentaDetalle(idVenta, idProducto, cantidad, precioUnitario, total)
VALUES (3, 1, 2, 5.00, 10.00);

INSERT INTO Pedido(idCliente, idEmpleado, fechaPedido, tipoPago, estadoEntrega)
VALUES (1, 1, '2025-04-07', 'Efectivo', 'Entregado');

SELECT * FROM Producto;
SELECT * FROM Empleado;
SELECT * FROM Usuario;
SELECT * FROM Proveedor;
SELECT * FROM Sabor;
SELECT * FROM Cliente;
SELECT * FROM Venta;
SELECT * FROM VentaDetalle;
SELECT * FROM Pedido;

