-- Esquema inicial sin datos. Ejecutar en una base MySQL 8 vacía.
SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS=0;

CREATE TABLE `asientocontable` (
  `IdAsiento` int NOT NULL AUTO_INCREMENT,
  `IdPeriodo` int NOT NULL,
  `Fecha` date NOT NULL,
  `Glosa` varchar(255) DEFAULT NULL,
  `IdUsuario` int NOT NULL,
  PRIMARY KEY (`IdAsiento`),
  KEY `IdPeriodo` (`IdPeriodo`),
  KEY `IdUsuario` (`IdUsuario`),
  CONSTRAINT `asientocontable_ibfk_1` FOREIGN KEY (`IdPeriodo`) REFERENCES `periodocontable` (`IdPeriodo`),
  CONSTRAINT `asientocontable_ibfk_2` FOREIGN KEY (`IdUsuario`) REFERENCES `usuario` (`IdUsuario`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `bodega` (
  `IdBodega` int NOT NULL AUTO_INCREMENT,
  `Nombre` varchar(100) NOT NULL,
  `Ubicacion` varchar(150) DEFAULT NULL,
  `Activo` tinyint(1) DEFAULT '1',
  PRIMARY KEY (`IdBodega`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `categoria` (
  `IdCategoria` int NOT NULL AUTO_INCREMENT,
  `Nombre` varchar(100) NOT NULL,
  `Descripcion` varchar(255) DEFAULT NULL,
  `Activo` tinyint(1) DEFAULT '1',
  PRIMARY KEY (`IdCategoria`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `cliente` (
  `IdCliente` int NOT NULL AUTO_INCREMENT,
  `Rut` varchar(20) NOT NULL,
  `Nombre` varchar(150) NOT NULL,
  `Categoria` varchar(50) DEFAULT NULL,
  `Correo` varchar(100) DEFAULT NULL,
  `Telefono` varchar(30) DEFAULT NULL,
  PRIMARY KEY (`IdCliente`),
  UNIQUE KEY `Rut` (`Rut`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `cotizacion` (
  `IdCotizacion` int NOT NULL AUTO_INCREMENT,
  `FechaEmision` date NOT NULL,
  `Estado` varchar(50) DEFAULT NULL,
  `Total` decimal(18,2) DEFAULT '0.00',
  `IdCliente` int NOT NULL,
  `IdUsuario` int NOT NULL,
  PRIMARY KEY (`IdCotizacion`),
  KEY `IdCliente` (`IdCliente`),
  KEY `IdUsuario` (`IdUsuario`),
  CONSTRAINT `cotizacion_ibfk_1` FOREIGN KEY (`IdCliente`) REFERENCES `cliente` (`IdCliente`),
  CONSTRAINT `cotizacion_ibfk_2` FOREIGN KEY (`IdUsuario`) REFERENCES `usuario` (`IdUsuario`),
  CONSTRAINT `cotizacion_chk_1` CHECK ((`Estado` in (_utf8mb4'Vigente',_utf8mb4'Aceptado',_utf8mb4'Vencido',_utf8mb4'Rechazado')))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `cotizaciondetalle` (
  `IdCotizacionDetalle` int NOT NULL AUTO_INCREMENT,
  `IdCotizacion` int NOT NULL,
  `IdVariante` int NOT NULL,
  `Cantidad` int NOT NULL,
  `PrecioUnitario` decimal(18,2) NOT NULL,
  PRIMARY KEY (`IdCotizacionDetalle`),
  KEY `IdCotizacion` (`IdCotizacion`),
  KEY `IdVariante` (`IdVariante`),
  CONSTRAINT `cotizaciondetalle_ibfk_1` FOREIGN KEY (`IdCotizacion`) REFERENCES `cotizacion` (`IdCotizacion`),
  CONSTRAINT `cotizaciondetalle_ibfk_2` FOREIGN KEY (`IdVariante`) REFERENCES `varianteproducto` (`IdVariante`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `cotizacionimportacion` (
  `IdCotizacion` int NOT NULL AUTO_INCREMENT,
  `IdLaboratorio` int NOT NULL,
  `Fecha` date NOT NULL,
  `Moneda` varchar(10) DEFAULT NULL,
  `TipoCambio` decimal(10,4) DEFAULT NULL,
  `Estado` varchar(20) DEFAULT NULL,
  `IdUsuario` int NOT NULL,
  PRIMARY KEY (`IdCotizacion`),
  KEY `IdLaboratorio` (`IdLaboratorio`),
  KEY `IdUsuario` (`IdUsuario`),
  CONSTRAINT `cotizacionimportacion_ibfk_1` FOREIGN KEY (`IdLaboratorio`) REFERENCES `laboratorio` (`IdLaboratorio`),
  CONSTRAINT `cotizacionimportacion_ibfk_2` FOREIGN KEY (`IdUsuario`) REFERENCES `usuario` (`IdUsuario`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `cuentacontable` (
  `IdCuentaContable` int NOT NULL AUTO_INCREMENT,
  `Codigo` varchar(50) NOT NULL,
  `Nombre` varchar(100) NOT NULL,
  `Tipo` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`IdCuentaContable`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `cuentaporpagar` (
  `IdCuentaPagar` int NOT NULL AUTO_INCREMENT,
  `IdRecepcion` int NOT NULL,
  `IdLaboratorio` int NOT NULL,
  `Monto` decimal(18,2) DEFAULT NULL,
  `Estado` varchar(20) DEFAULT NULL,
  `IdUsuario` int NOT NULL,
  PRIMARY KEY (`IdCuentaPagar`),
  KEY `IdRecepcion` (`IdRecepcion`),
  KEY `IdLaboratorio` (`IdLaboratorio`),
  KEY `IdUsuario` (`IdUsuario`),
  CONSTRAINT `cuentaporpagar_ibfk_1` FOREIGN KEY (`IdRecepcion`) REFERENCES `recepcioncompra` (`IdRecepcion`),
  CONSTRAINT `cuentaporpagar_ibfk_2` FOREIGN KEY (`IdLaboratorio`) REFERENCES `laboratorio` (`IdLaboratorio`),
  CONSTRAINT `cuentaporpagar_ibfk_3` FOREIGN KEY (`IdUsuario`) REFERENCES `usuario` (`IdUsuario`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `cuentascobrar` (
  `IdCuenta` int NOT NULL AUTO_INCREMENT,
  `IdVenta` int NOT NULL,
  `FechaVence` date DEFAULT NULL,
  `MontoPendiente` decimal(18,2) DEFAULT NULL,
  `EstadoPago` varchar(50) DEFAULT NULL,
  `IdUsuario` int NOT NULL,
  PRIMARY KEY (`IdCuenta`),
  KEY `IdVenta` (`IdVenta`),
  KEY `IdUsuario` (`IdUsuario`),
  CONSTRAINT `cuentascobrar_ibfk_1` FOREIGN KEY (`IdVenta`) REFERENCES `venta` (`IdVenta`),
  CONSTRAINT `cuentascobrar_ibfk_2` FOREIGN KEY (`IdUsuario`) REFERENCES `usuario` (`IdUsuario`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `declaracioniva` (
  `IdDeclaracionIVA` int NOT NULL AUTO_INCREMENT,
  `IdPeriodo` int NOT NULL,
  `Monto` decimal(18,2) DEFAULT NULL,
  `Fecha` date DEFAULT NULL,
  `IdUsuario` int NOT NULL,
  PRIMARY KEY (`IdDeclaracionIVA`),
  KEY `IdPeriodo` (`IdPeriodo`),
  KEY `IdUsuario` (`IdUsuario`),
  CONSTRAINT `declaracioniva_ibfk_1` FOREIGN KEY (`IdPeriodo`) REFERENCES `periodocontable` (`IdPeriodo`),
  CONSTRAINT `declaracioniva_ibfk_2` FOREIGN KEY (`IdUsuario`) REFERENCES `usuario` (`IdUsuario`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `despacho` (
  `IdDespacho` int NOT NULL AUTO_INCREMENT,
  `IdVenta` int NOT NULL,
  `Estado` varchar(50) DEFAULT NULL,
  `FechaEstimada` date DEFAULT NULL,
  `Tipo` varchar(50) DEFAULT NULL,
  `IdUsuario` int NOT NULL,
  PRIMARY KEY (`IdDespacho`),
  KEY `IdVenta` (`IdVenta`),
  KEY `IdUsuario` (`IdUsuario`),
  CONSTRAINT `despacho_ibfk_1` FOREIGN KEY (`IdVenta`) REFERENCES `venta` (`IdVenta`),
  CONSTRAINT `despacho_ibfk_2` FOREIGN KEY (`IdUsuario`) REFERENCES `usuario` (`IdUsuario`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `detalleasiento` (
  `IdDetalleAsiento` int NOT NULL AUTO_INCREMENT,
  `IdAsiento` int NOT NULL,
  `IdCuentaContable` int NOT NULL,
  `Debe` decimal(18,2) DEFAULT '0.00',
  `Haber` decimal(18,2) DEFAULT '0.00',
  PRIMARY KEY (`IdDetalleAsiento`),
  KEY `IdAsiento` (`IdAsiento`),
  KEY `IdCuentaContable` (`IdCuentaContable`),
  CONSTRAINT `detalleasiento_ibfk_1` FOREIGN KEY (`IdAsiento`) REFERENCES `asientocontable` (`IdAsiento`),
  CONSTRAINT `detalleasiento_ibfk_2` FOREIGN KEY (`IdCuentaContable`) REFERENCES `cuentacontable` (`IdCuentaContable`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `detallecotizacion` (
  `IdDetalleCot` int NOT NULL AUTO_INCREMENT,
  `IdCotizacion` int NOT NULL,
  `IdVariante` int NOT NULL,
  `Cantidad` int NOT NULL,
  `CostoUnitario` decimal(18,2) NOT NULL,
  PRIMARY KEY (`IdDetalleCot`),
  KEY `IdCotizacion` (`IdCotizacion`),
  KEY `IdVariante` (`IdVariante`),
  CONSTRAINT `detallecotizacion_ibfk_1` FOREIGN KEY (`IdCotizacion`) REFERENCES `cotizacionimportacion` (`IdCotizacion`),
  CONSTRAINT `detallecotizacion_ibfk_2` FOREIGN KEY (`IdVariante`) REFERENCES `varianteproducto` (`IdVariante`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `detalleordencompra` (
  `IdDetalleOC` int NOT NULL AUTO_INCREMENT,
  `IdOC` int NOT NULL,
  `IdVariante` int NOT NULL,
  `CantidadPedida` int NOT NULL,
  `CantidadRecibida` int DEFAULT '0',
  `CostoUnitario` decimal(18,2) NOT NULL,
  PRIMARY KEY (`IdDetalleOC`),
  KEY `IdOC` (`IdOC`),
  KEY `IdVariante` (`IdVariante`),
  CONSTRAINT `detalleordencompra_ibfk_1` FOREIGN KEY (`IdOC`) REFERENCES `ordencompra` (`IdOC`),
  CONSTRAINT `detalleordencompra_ibfk_2` FOREIGN KEY (`IdVariante`) REFERENCES `varianteproducto` (`IdVariante`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `detallerecepcion` (
  `IdDetalleRec` int NOT NULL AUTO_INCREMENT,
  `IdRecepcion` int NOT NULL,
  `IdDetalleOC` int NOT NULL,
  `IdVariante` int NOT NULL,
  `NumeroLote` varchar(30) DEFAULT NULL,
  `FechaVencimiento` date DEFAULT NULL,
  `Cantidad` int NOT NULL,
  `CostoUnitario` decimal(18,2) NOT NULL,
  PRIMARY KEY (`IdDetalleRec`),
  KEY `IdRecepcion` (`IdRecepcion`),
  KEY `IdDetalleOC` (`IdDetalleOC`),
  KEY `IdVariante` (`IdVariante`),
  CONSTRAINT `detallerecepcion_ibfk_1` FOREIGN KEY (`IdRecepcion`) REFERENCES `recepcioncompra` (`IdRecepcion`),
  CONSTRAINT `detallerecepcion_ibfk_2` FOREIGN KEY (`IdDetalleOC`) REFERENCES `detalleordencompra` (`IdDetalleOC`),
  CONSTRAINT `detallerecepcion_ibfk_3` FOREIGN KEY (`IdVariante`) REFERENCES `varianteproducto` (`IdVariante`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `devolucionproveedor` (
  `IdDevolucion` int NOT NULL AUTO_INCREMENT,
  `IdRecepcion` int NOT NULL,
  `IdLote` int NOT NULL,
  `Cantidad` int NOT NULL,
  `Motivo` varchar(200) DEFAULT NULL,
  `Fecha` date NOT NULL,
  `Estado` varchar(20) DEFAULT NULL,
  `IdUsuario` int NOT NULL,
  PRIMARY KEY (`IdDevolucion`),
  KEY `IdRecepcion` (`IdRecepcion`),
  KEY `IdLote` (`IdLote`),
  KEY `IdUsuario` (`IdUsuario`),
  CONSTRAINT `devolucionproveedor_ibfk_1` FOREIGN KEY (`IdRecepcion`) REFERENCES `recepcioncompra` (`IdRecepcion`),
  CONSTRAINT `devolucionproveedor_ibfk_2` FOREIGN KEY (`IdLote`) REFERENCES `lote` (`IdLote`),
  CONSTRAINT `devolucionproveedor_ibfk_3` FOREIGN KEY (`IdUsuario`) REFERENCES `usuario` (`IdUsuario`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `inventario` (
  `IdInventario` int NOT NULL AUTO_INCREMENT,
  `IdVariante` int NOT NULL,
  `IdBodega` int NOT NULL,
  `StockActual` int DEFAULT '0',
  `StockReservado` int DEFAULT '0',
  `FechaActualizada` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`IdInventario`),
  KEY `IdVariante` (`IdVariante`),
  KEY `IdBodega` (`IdBodega`),
  CONSTRAINT `inventario_ibfk_1` FOREIGN KEY (`IdVariante`) REFERENCES `varianteproducto` (`IdVariante`),
  CONSTRAINT `inventario_ibfk_2` FOREIGN KEY (`IdBodega`) REFERENCES `bodega` (`IdBodega`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `laboratorio` (
  `IdLaboratorio` int NOT NULL AUTO_INCREMENT,
  `Rut` varchar(12) NOT NULL,
  `RazonSocial` varchar(150) NOT NULL,
  `Marca` varchar(100) DEFAULT NULL,
  `Pais` varchar(50) DEFAULT NULL,
  `Contacto` varchar(100) DEFAULT NULL,
  `Email` varchar(100) DEFAULT NULL,
  `Telefono` varchar(20) DEFAULT NULL,
  `DiasPago` int DEFAULT '30',
  `Activo` tinyint(1) DEFAULT '1',
  PRIMARY KEY (`IdLaboratorio`),
  UNIQUE KEY `Rut` (`Rut`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `lote` (
  `IdLote` int NOT NULL AUTO_INCREMENT,
  `IdVariante` int NOT NULL,
  `NumeroLote` varchar(50) NOT NULL,
  `FechaIngreso` date DEFAULT NULL,
  `FechaVencimiento` date DEFAULT NULL,
  `CostoUnitario` decimal(18,2) DEFAULT NULL,
  `CantidadInicial` int DEFAULT NULL,
  `CantidadDisponible` int DEFAULT NULL,
  `Estado` varchar(20) DEFAULT NULL,
  PRIMARY KEY (`IdLote`),
  KEY `IdVariante` (`IdVariante`),
  CONSTRAINT `lote_ibfk_1` FOREIGN KEY (`IdVariante`) REFERENCES `varianteproducto` (`IdVariante`),
  CONSTRAINT `lote_chk_1` CHECK ((`Estado` in (_utf8mb4'Disponible',_utf8mb4'Cuarentena',_utf8mb4'Vencido',_utf8mb4'Agotado')))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `marca` (
  `IdMarca` int NOT NULL AUTO_INCREMENT,
  `Nombre` varchar(100) NOT NULL,
  `Descripcion` varchar(255) DEFAULT NULL,
  `Activo` tinyint(1) DEFAULT '1',
  PRIMARY KEY (`IdMarca`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `merma` (
  `IdMerma` int NOT NULL AUTO_INCREMENT,
  `IdLote` int NOT NULL,
  `IdUsuario` int NOT NULL,
  `Cantidad` int NOT NULL,
  `Motivo` varchar(200) DEFAULT NULL,
  `Fecha` date DEFAULT NULL,
  `CostoPerdida` decimal(18,2) DEFAULT NULL,
  `Observacion` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`IdMerma`),
  KEY `IdLote` (`IdLote`),
  KEY `IdUsuario` (`IdUsuario`),
  CONSTRAINT `merma_ibfk_1` FOREIGN KEY (`IdLote`) REFERENCES `lote` (`IdLote`),
  CONSTRAINT `merma_ibfk_2` FOREIGN KEY (`IdUsuario`) REFERENCES `usuario` (`IdUsuario`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `movimientoinventario` (
  `IdMovimiento` int NOT NULL AUTO_INCREMENT,
  `IdLote` int NOT NULL,
  `IdTipoMovimiento` int NOT NULL,
  `IdUsuario` int NOT NULL,
  `FechaMovimiento` datetime DEFAULT CURRENT_TIMESTAMP,
  `Cantidad` int NOT NULL,
  `StockAnterior` int DEFAULT NULL,
  `StockPosterior` int DEFAULT NULL,
  `Referencia` varchar(100) DEFAULT NULL,
  `Observacion` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`IdMovimiento`),
  KEY `IdLote` (`IdLote`),
  KEY `IdTipoMovimiento` (`IdTipoMovimiento`),
  KEY `IdUsuario` (`IdUsuario`),
  CONSTRAINT `movimientoinventario_ibfk_1` FOREIGN KEY (`IdLote`) REFERENCES `lote` (`IdLote`),
  CONSTRAINT `movimientoinventario_ibfk_2` FOREIGN KEY (`IdTipoMovimiento`) REFERENCES `tipomovimiento` (`IdTipoMovimiento`),
  CONSTRAINT `movimientoinventario_ibfk_3` FOREIGN KEY (`IdUsuario`) REFERENCES `usuario` (`IdUsuario`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `ordencompra` (
  `IdOC` int NOT NULL AUTO_INCREMENT,
  `NumeroOC` varchar(20) NOT NULL,
  `IdLaboratorio` int NOT NULL,
  `IdCotizacion` int DEFAULT NULL,
  `Fecha` date NOT NULL,
  `FechaEsperada` date DEFAULT NULL,
  `Estado` varchar(20) DEFAULT NULL,
  `Neto` decimal(18,2) DEFAULT NULL,
  `Iva` decimal(18,2) DEFAULT NULL,
  `Total` decimal(18,2) DEFAULT NULL,
  `IdUsuario` int NOT NULL,
  PRIMARY KEY (`IdOC`),
  UNIQUE KEY `NumeroOC` (`NumeroOC`),
  KEY `IdLaboratorio` (`IdLaboratorio`),
  KEY `IdCotizacion` (`IdCotizacion`),
  KEY `IdUsuario` (`IdUsuario`),
  CONSTRAINT `ordencompra_ibfk_1` FOREIGN KEY (`IdLaboratorio`) REFERENCES `laboratorio` (`IdLaboratorio`),
  CONSTRAINT `ordencompra_ibfk_2` FOREIGN KEY (`IdCotizacion`) REFERENCES `cotizacionimportacion` (`IdCotizacion`),
  CONSTRAINT `ordencompra_ibfk_3` FOREIGN KEY (`IdUsuario`) REFERENCES `usuario` (`IdUsuario`),
  CONSTRAINT `ordencompra_chk_1` CHECK ((`Estado` in (_utf8mb4'Borrador',_utf8mb4'Emitida',_utf8mb4'Parcial',_utf8mb4'Recibida',_utf8mb4'Anulada')))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `pagoproveedor` (
  `IdPagoProveedor` int NOT NULL AUTO_INCREMENT,
  `IdCuentaPagar` int NOT NULL,
  `IdAsiento` int NOT NULL,
  `Monto` decimal(18,2) DEFAULT NULL,
  `Fecha` date DEFAULT NULL,
  `IdUsuario` int NOT NULL,
  PRIMARY KEY (`IdPagoProveedor`),
  KEY `IdCuentaPagar` (`IdCuentaPagar`),
  KEY `IdAsiento` (`IdAsiento`),
  KEY `IdUsuario` (`IdUsuario`),
  CONSTRAINT `pagoproveedor_ibfk_1` FOREIGN KEY (`IdCuentaPagar`) REFERENCES `cuentaporpagar` (`IdCuentaPagar`),
  CONSTRAINT `pagoproveedor_ibfk_2` FOREIGN KEY (`IdAsiento`) REFERENCES `asientocontable` (`IdAsiento`),
  CONSTRAINT `pagoproveedor_ibfk_3` FOREIGN KEY (`IdUsuario`) REFERENCES `usuario` (`IdUsuario`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `periodocontable` (
  `IdPeriodo` int NOT NULL AUTO_INCREMENT,
  `Nombre` varchar(50) NOT NULL,
  `FechaInicio` date NOT NULL,
  `FechaFin` date NOT NULL,
  `Estado` varchar(20) DEFAULT NULL,
  PRIMARY KEY (`IdPeriodo`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `producto` (
  `IdProducto` int NOT NULL AUTO_INCREMENT,
  `IdCategoria` int DEFAULT NULL,
  `IdMarca` int DEFAULT NULL,
  `Nombre` varchar(150) NOT NULL,
  `Descripcion` varchar(255) DEFAULT NULL,
  `StockMinimo` int DEFAULT '0',
  `PuntoReOrden` int DEFAULT '0',
  `Activo` tinyint(1) DEFAULT '1',
  PRIMARY KEY (`IdProducto`),
  KEY `IdCategoria` (`IdCategoria`),
  KEY `IdMarca` (`IdMarca`),
  CONSTRAINT `producto_ibfk_1` FOREIGN KEY (`IdCategoria`) REFERENCES `categoria` (`IdCategoria`),
  CONSTRAINT `producto_ibfk_2` FOREIGN KEY (`IdMarca`) REFERENCES `marca` (`IdMarca`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `recepcioncompra` (
  `IdRecepcion` int NOT NULL AUTO_INCREMENT,
  `IdOC` int NOT NULL,
  `GuiaDespacho` varchar(30) DEFAULT NULL,
  `FechaRecepcion` date NOT NULL,
  `Estado` varchar(20) DEFAULT NULL,
  `IdUsuario` int NOT NULL,
  PRIMARY KEY (`IdRecepcion`),
  KEY `IdOC` (`IdOC`),
  KEY `IdUsuario` (`IdUsuario`),
  CONSTRAINT `recepcioncompra_ibfk_1` FOREIGN KEY (`IdOC`) REFERENCES `ordencompra` (`IdOC`),
  CONSTRAINT `recepcioncompra_ibfk_2` FOREIGN KEY (`IdUsuario`) REFERENCES `usuario` (`IdUsuario`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `rol` (
  `IdRol` int NOT NULL AUTO_INCREMENT,
  `Nombre` varchar(50) NOT NULL,
  PRIMARY KEY (`IdRol`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `tipomovimiento` (
  `IdTipoMovimiento` int NOT NULL AUTO_INCREMENT,
  `Nombre` varchar(100) NOT NULL,
  `Naturaleza` varchar(50) DEFAULT NULL,
  `Descripcion` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`IdTipoMovimiento`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `usuario` (
  `IdUsuario` int NOT NULL AUTO_INCREMENT,
  `IdRol` int DEFAULT NULL,
  `Nombre` varchar(100) NOT NULL,
  `Correo` varchar(100) NOT NULL,
  `Password` varchar(255) DEFAULT NULL,
  `Rol` varchar(50) DEFAULT NULL,
  `Activo` tinyint(1) DEFAULT '1',
  PRIMARY KEY (`IdUsuario`),
  UNIQUE KEY `Correo` (`Correo`),
  KEY `IdRol` (`IdRol`),
  CONSTRAINT `usuario_ibfk_1` FOREIGN KEY (`IdRol`) REFERENCES `rol` (`IdRol`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `varianteproducto` (
  `IdVariante` int NOT NULL AUTO_INCREMENT,
  `IdProducto` int NOT NULL,
  `Sku` varchar(50) NOT NULL,
  `NombreVariante` varchar(100) DEFAULT NULL,
  `AtributoValor` varchar(200) DEFAULT NULL,
  `Presentacion` varchar(100) DEFAULT NULL,
  `Color` varchar(50) DEFAULT NULL,
  `PrecioVenta` decimal(18,2) DEFAULT '0.00',
  `CostoPromedio` decimal(18,2) DEFAULT '0.00',
  `StockTotal` int DEFAULT '0',
  `Activo` tinyint(1) DEFAULT '1',
  PRIMARY KEY (`IdVariante`),
  UNIQUE KEY `Sku` (`Sku`),
  KEY `IdProducto` (`IdProducto`),
  CONSTRAINT `varianteproducto_ibfk_1` FOREIGN KEY (`IdProducto`) REFERENCES `producto` (`IdProducto`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `venta` (
  `IdVenta` int NOT NULL AUTO_INCREMENT,
  `TipoDocumento` varchar(50) NOT NULL,
  `Fecha` date NOT NULL,
  `Total` decimal(18,2) DEFAULT '0.00',
  `IdCliente` int NOT NULL,
  `IdCotizacion` int DEFAULT NULL,
  `IdUsuario` int NOT NULL,
  PRIMARY KEY (`IdVenta`),
  KEY `IdCliente` (`IdCliente`),
  KEY `IdCotizacion` (`IdCotizacion`),
  KEY `IdUsuario` (`IdUsuario`),
  CONSTRAINT `venta_ibfk_1` FOREIGN KEY (`IdCliente`) REFERENCES `cliente` (`IdCliente`),
  CONSTRAINT `venta_ibfk_2` FOREIGN KEY (`IdCotizacion`) REFERENCES `cotizacion` (`IdCotizacion`),
  CONSTRAINT `venta_ibfk_3` FOREIGN KEY (`IdUsuario`) REFERENCES `usuario` (`IdUsuario`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `ventadetalle` (
  `IdVentaDetalle` int NOT NULL AUTO_INCREMENT,
  `IdVenta` int NOT NULL,
  `IdVariante` int NOT NULL,
  `Cantidad` int NOT NULL,
  `PrecioUnitario` decimal(18,2) NOT NULL,
  `Subtotal` decimal(18,2) NOT NULL,
  PRIMARY KEY (`IdVentaDetalle`),
  KEY `IdVenta` (`IdVenta`),
  KEY `IdVariante` (`IdVariante`),
  CONSTRAINT `ventadetalle_ibfk_1` FOREIGN KEY (`IdVenta`) REFERENCES `venta` (`IdVenta`),
  CONSTRAINT `ventadetalle_ibfk_2` FOREIGN KEY (`IdVariante`) REFERENCES `varianteproducto` (`IdVariante`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE configuracionglobal (
  Clave VARCHAR(100) NOT NULL PRIMARY KEY,
  Valor VARCHAR(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

SET FOREIGN_KEY_CHECKS=1;
