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

DROP TABLE VentaDetalle;
DROP TABLE Venta;
DROP TABLE Cliente;
DROP TABLE Usuario;
DROP TABLE Empleado;
DROP TABLE Producto;
DROP TABLE Proveedor;
DROP TABLE Sabor;

CREATE TABLE Sabor (
  id INT NOT NULL PRIMARY KEY IDENTITY(1,1),
  nombre VARCHAR(100) NULL
);
CREATE TABLE Proveedor (
  id INT NOT NULL PRIMARY KEY IDENTITY(1,1),
  razonSocial VARCHAR(100) NOT NULL,
  nit VARCHAR(20) NOT NULL,
  telefono VARCHAR(15) NOT NULL,
  direccion VARCHAR(250) NULL,
  tipoProducto VARCHAR(100) NOT NULL
);
CREATE TABLE Producto (
  id INT NOT NULL PRIMARY KEY IDENTITY(1,1),
  nombre VARCHAR(100) NOT NULL,
  sabor VARCHAR(50) NOT NULL,
  proveedor VARCHAR(100) NOT NULL,
  presentacion VARCHAR(100) NULL,
  precio DECIMAL(10,2) NOT NULL CHECK (precio > 0),
);
CREATE TABLE Empleado (
  id INT NOT NULL PRIMARY KEY IDENTITY(1,1),
  nombres VARCHAR(100) NOT NULL,
  primerApellido VARCHAR(100) NULL,
  segundoApellido VARCHAR(100) NULL,
  telefono VARCHAR(15) NOT NULL,
  direccion VARCHAR(250) NOT NULL,
  cargo VARCHAR(50) NOT NULL,
  fechaContratacion DATE NOT NULL DEFAULT GETDATE(),
);
CREATE TABLE Usuario (
  id INT NOT NULL PRIMARY KEY IDENTITY(1,1),
  idEmpleado INT NOT NULL,
  usuario VARCHAR(20) NOT NULL,
  clave VARCHAR(250) NOT NULL,
  CONSTRAINT fk_Usuario_Empleado FOREIGN KEY(idEmpleado) REFERENCES Empleado(id)
);
CREATE TABLE Cliente (
  id INT NOT NULL PRIMARY KEY IDENTITY(1,1),
  nombre VARCHAR(100) NOT NULL,
  nit VARCHAR(20) NOT NULL,
  celular VARCHAR(15) NOT NULL
);
CREATE TABLE Venta (
  id INT NOT NULL PRIMARY KEY IDENTITY(1,1),
  idUsuario INT NOT NULL,
  idCliente INT NOT NULL,
  tipoPago VARCHAR(50) NOT NULL,
  fecha DATE NOT NULL DEFAULT GETDATE(),
  CONSTRAINT fk_Venta_Usuario FOREIGN KEY(idUsuario) REFERENCES Usuario(id),
  CONSTRAINT fk_Venta_Cliente FOREIGN KEY(idCliente) REFERENCES Cliente(id)
);
CREATE TABLE VentaDetalle (
  id INT NOT NULL PRIMARY KEY IDENTITY(1,1),
  idVenta INT NOT NULL,
  idProducto INT NOT NULL,
  cantidad INT NOT NULL CHECK (cantidad > 0),
  precioUnitario DECIMAL(10,2) NOT NULL,
  total DECIMAL(10,2) NOT NULL,
  CONSTRAINT fk_VentaDetalle_Venta FOREIGN KEY(idVenta) REFERENCES Venta(id),
  CONSTRAINT fk_VentaDetalle_Producto FOREIGN KEY(idProducto) REFERENCES Producto(id)
);

ALTER TABLE Sabor ADD usuarioRegistro VARCHAR(50) NOT NULL DEFAULT SUSER_NAME();
ALTER TABLE Sabor ADD fechaRegistro DATETIME NOT NULL DEFAULT GETDATE();
ALTER TABLE Sabor ADD estado SMALLINT NOT NULL DEFAULT 1; -- -1:Eliminado, 0: Inactivo, 1: Activo

ALTER TABLE Proveedor ADD usuarioRegistro VARCHAR(50) NOT NULL DEFAULT SUSER_NAME();
ALTER TABLE Proveedor ADD fechaRegistro DATETIME NOT NULL DEFAULT GETDATE();
ALTER TABLE Proveedor ADD estado SMALLINT NOT NULL DEFAULT 1; -- -1:Eliminado, 0: Inactivo, 1: Activo

ALTER TABLE Producto ADD usuarioRegistro VARCHAR(50) NOT NULL DEFAULT SUSER_NAME();
ALTER TABLE Producto ADD fechaRegistro DATETIME NOT NULL DEFAULT GETDATE();
ALTER TABLE Producto ADD estado SMALLINT NOT NULL DEFAULT 1; -- -1:Eliminado, 0: Inactivo, 1: Activo

ALTER TABLE Empleado ADD usuarioRegistro VARCHAR(50) NOT NULL DEFAULT SUSER_NAME();
ALTER TABLE Empleado ADD fechaRegistro DATETIME NOT NULL DEFAULT GETDATE();
ALTER TABLE Empleado ADD estado SMALLINT NOT NULL DEFAULT 1; -- -1:Eliminado, 0: Inactivo, 1: Activo

ALTER TABLE Usuario ADD usuarioRegistro VARCHAR(50) NOT NULL DEFAULT SUSER_NAME();
ALTER TABLE Usuario ADD fechaRegistro DATETIME NOT NULL DEFAULT GETDATE();
ALTER TABLE Usuario ADD estado SMALLINT NOT NULL DEFAULT 1; -- -1:Eliminado, 0: Inactivo, 1: Activo

ALTER TABLE Cliente ADD usuarioRegistro VARCHAR(50) NOT NULL DEFAULT SUSER_NAME();
ALTER TABLE Cliente ADD fechaRegistro DATETIME NOT NULL DEFAULT GETDATE();
ALTER TABLE Cliente ADD estado SMALLINT NOT NULL DEFAULT 1; -- -1:Eliminado, 0: Inactivo, 1: Activo

ALTER TABLE Venta ADD usuarioRegistro VARCHAR(50) NOT NULL DEFAULT SUSER_NAME();
ALTER TABLE Venta ADD fechaRegistro DATETIME NOT NULL DEFAULT GETDATE();
ALTER TABLE Venta ADD estado SMALLINT NOT NULL DEFAULT 1; -- -1:Eliminado, 0: Inactivo, 1: Activo

ALTER TABLE VentaDetalle ADD usuarioRegistro VARCHAR(50) NOT NULL DEFAULT SUSER_NAME();
ALTER TABLE VentaDetalle ADD fechaRegistro DATETIME NOT NULL DEFAULT GETDATE();
ALTER TABLE VentaDetalle ADD estado SMALLINT NOT NULL DEFAULT 1; -- -1:NoEntergado, 0: Entregado, 1: Pendiente

-- Procedimientos Almacenados
GO
ALTER PROC paSaborListar @parametro VARCHAR(100)
AS
  SELECT * FROM Sabor
  WHERE estado<>-1 AND nombre LIKE '%'+REPLACE(@parametro,' ','%')+'%'
  ORDER BY estado DESC, nombre ASC;

GO
ALTER PROC paProveedorListar @parametro VARCHAR(100)
AS
  SELECT * FROM Proveedor
  WHERE estado<>-1 AND razonSocial+nit+telefono LIKE '%'+REPLACE(@parametro,' ','%')+'%'
  ORDER BY estado DESC, nombre ASC;

GO
ALTER PROC paProductoListar @parametro VARCHAR(100)
AS
  SELECT * FROM Producto
  WHERE estado<>-1 AND nombre+sabor LIKE '%'+REPLACE(@parametro,' ','%')+'%'
  ORDER BY estado DESC, nombre ASC;

GO
ALTER PROC paEmpleadoListar @parametro VARCHAR(100)
AS
  SELECT ISNULL(u.usuario,'--') AS usuario,e.* 
  FROM Empleado e
  LEFT JOIN Usuario u ON e.id = u.idEmpleado
  WHERE e.estado<>-1 
	AND e.nombres+ISNULL(e.primerApellido,'')+ISNULL(e.segundoApellido,'') LIKE '%'+REPLACE(@parametro,' ','%')+'%'
  ORDER BY e.estado DESC, e.nombres ASC, e.primerApellido ASC;

GO
ALTER PROC paClienteListar @parametro VARCHAR(100)
AS
  SELECT * FROM Cliente
  WHERE estado<>-1 AND nombre+nit+celular LIKE '%'+REPLACE(@parametro,' ','%')+'%'
  ORDER BY nombre ASC;

GO
ALTER PROC paVentaListar @parametro VARCHAR(100)
AS
  SELECT v.id, v.fecha, v.tipoPago, ISNULL(u.usuario, '--') AS usuario, c.nombre AS Cliente
  FROM Venta v
  LEFT JOIN Usuario u ON v.idUsuario = u.id
  LEFT JOIN Cliente c ON v.idCliente = c.id
  WHERE v.estado<>-1
   AND ISNULL(u.usuario, '') + ISNULL(v.tipoPago, '') + ISNULL(c.nombre, '') LIKE '%'+REPLACE(@parametro,' ','%')+'%'
  ORDER BY v.tipoPago DESC;

GO
ALTER PROC paVentaDetalleListar @parametro VARCHAR(100)
AS
  SELECT vd.id, v.tipoPago, p.nombre AS Producto, vd.cantidad, vd.precioUnitario, vd.total
  FROM VentaDetalle vd
  JOIN Venta v ON vd.idVenta = v.id
  JOIN Producto p ON vd.idProducto = p.id
  WHERE vd.estado<>-1 
   AND ISNULL(vd.cantidad, '') + ISNULL(p.nombre, '') + ISNULL(v.tipoPago, '') LIKE '%'+REPLACE(@parametro,' ','%')+'%'
  ORDER BY vd.cantidad DESC;

-- DML
--INSERT INTO Sabor (nombre)
--VALUES ('Manzana'), ('Frutilla'), ('Naranja'), ('Banana'), ('Limón');

--INSERT INTO Proveedor(razonSocial, nit, telefono, direccion, tipoProducto)
--VALUES ('Frutas Frescas S.A.', '456789123', '555-111', 'Calle 1', 'Frutas Dulces'),  --Frutas dulces: Banana, Manzana roja
--	   ('Cítricos del Sol S.R.L.', '987654321', '555-2222', 'Avenida 2', 'Frutas Cítricas'), --Frutas cítricas: Naranja, Limón
--	   ('Exquisitas Frutas S.A.', '800654321', '555-3333', 'Boulevard 3', 'Frutas Semiácidas'); --Frutas semiácidas: Frutilla

INSERT INTO Producto (nombre, sabor, proveedor, presentacion, precio)
VALUES ('Helado', 'Manzana', 'Frutas Frescas S.A.', 'Vaso de plástico 250 ml', 12.00),
	   ('Helado', 'Frutilla', 'Exquisitas Frutas S.A.', 'Cono', 8.00);

	   --('Helado', 'Naranja', 'Cítricos del Sol S.R.L.', 'Vasito de plástico 500 ml', 15.00),
	   --('Helado', 'Banana', 'Frutas Frescas S.A.', 'Tarrina de cartón 1 L', 20.00),
	   --('Helado', 'Limón', 'Cítricos del Sol S.R.L.', 'Cono', 8.00);

INSERT INTO Empleado (nombres, primerApellido, segundoApellido, telefono, direccion, cargo)
VALUES ('Rami', 'Saigua', 'López', '72345678', 'Calle 4', 'Gerente');

INSERT INTO Usuario (idEmpleado, usuario, clave)
VALUES (1, 'rsaigua', '');

UPDATE Usuario SET clave = 'Fo29nhWFgz6S2F47mbGlbA==' WHERE idEmpleado = 1;

INSERT INTO Cliente (nombre, nit, celular)
VALUES ('Mateo', '987654321', '72345678');

INSERT INTO Venta (idUsuario, idCliente, tipoPago)
VALUES (1, 1, 'Efectivo');

INSERT INTO VentaDetalle (idVenta, idProducto, cantidad, precioUnitario, total)
VALUES (1, 1, 2, 12.00, 24.00),
	   (1, 2, 1, 8.00, 8.00);

SELECT * FROM Sabor;
SELECT * FROM Proveedor;
SELECT * FROM Producto;
SELECT * FROM Empleado;
SELECT * FROM Usuario;
SELECT * FROM Cliente;
SELECT * FROM Venta;
SELECT * FROM VentaDetalle;

