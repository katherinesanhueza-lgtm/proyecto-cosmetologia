CREATE DATABASE IF NOT EXISTS ERP_Dermocosmetica CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
USE ERP_Dermocosmetica;
-- MySQL dump 10.13  Distrib 8.0.46, for Win64 (x86_64)
--
-- Host: 127.0.0.1    Database: ERP_Dermocosmetica
-- ------------------------------------------------------
-- Server version	8.0.46

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `asientocontable`
--

DROP TABLE IF EXISTS `asientocontable`;
CREATE TABLE `asientocontable` (
  `IdAsiento` int NOT NULL AUTO_INCREMENT,
  `IdPeriodo` int NOT NULL,
  `Fecha` date NOT NULL,
  `Glosa` varchar(255) DEFAULT NULL,
  `IdUsuario` int NOT NULL,
  `IdAsientoRevertido` int DEFAULT NULL,
  `FechaRegistro` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `Origen` varchar(20) DEFAULT NULL,
  `IdOrigen` int DEFAULT NULL,
  PRIMARY KEY (`IdAsiento`),
  KEY `IdPeriodo` (`IdPeriodo`),
  KEY `IdUsuario` (`IdUsuario`),
  CONSTRAINT `asientocontable_ibfk_1` FOREIGN KEY (`IdPeriodo`) REFERENCES `periodocontable` (`IdPeriodo`),
  CONSTRAINT `asientocontable_ibfk_2` FOREIGN KEY (`IdUsuario`) REFERENCES `usuario` (`IdUsuario`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Table structure for table `bodega`
--

DROP TABLE IF EXISTS `bodega`;
CREATE TABLE `bodega` (
  `IdBodega` int NOT NULL AUTO_INCREMENT,
  `Nombre` varchar(100) NOT NULL,
  `Ubicacion` varchar(150) DEFAULT NULL,
  `Activo` tinyint(1) DEFAULT '1',
  PRIMARY KEY (`IdBodega`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Table structure for table `categoria`
--

DROP TABLE IF EXISTS `categoria`;
CREATE TABLE `categoria` (
  `IdCategoria` int NOT NULL AUTO_INCREMENT,
  `Nombre` varchar(100) NOT NULL,
  `Descripcion` varchar(255) DEFAULT NULL,
  `Activo` tinyint(1) DEFAULT '1',
  PRIMARY KEY (`IdCategoria`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Table structure for table `cliente`
--

DROP TABLE IF EXISTS `cliente`;
CREATE TABLE `cliente` (
  `IdCliente` int NOT NULL AUTO_INCREMENT,
  `Rut` varchar(20) NOT NULL,
  `Nombre` varchar(150) NOT NULL,
  `RazonSocial` varchar(150) DEFAULT NULL,
  `Categoria` varchar(50) DEFAULT NULL,
  `Giro` varchar(150) DEFAULT NULL,
  `Direccion` varchar(200) DEFAULT NULL,
  `Contacto` varchar(100) DEFAULT NULL,
  `Correo` varchar(100) DEFAULT NULL,
  `Telefono` varchar(30) DEFAULT NULL,
  `LimiteCredito` decimal(18,2) NOT NULL DEFAULT '0.00',
  `DiasCredito` int NOT NULL DEFAULT '0',
  `Activo` tinyint(1) NOT NULL DEFAULT '1',
  PRIMARY KEY (`IdCliente`),
  UNIQUE KEY `Rut` (`Rut`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Table structure for table `cotizacion`
--

DROP TABLE IF EXISTS `cotizacion`;
CREATE TABLE `cotizacion` (
  `IdCotizacion` int NOT NULL AUTO_INCREMENT,
  `FechaEmision` date NOT NULL,
  `FechaVencimiento` date DEFAULT NULL,
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Table structure for table `cotizaciondetalle`
--

DROP TABLE IF EXISTS `cotizaciondetalle`;
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Table structure for table `cotizacionimportacion`
--

DROP TABLE IF EXISTS `cotizacionimportacion`;
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Table structure for table `cuentacontable`
--

DROP TABLE IF EXISTS `cuentacontable`;
CREATE TABLE `cuentacontable` (
  `IdCuentaContable` int NOT NULL AUTO_INCREMENT,
  `Codigo` varchar(50) NOT NULL,
  `Nombre` varchar(100) NOT NULL,
  `Tipo` varchar(50) DEFAULT NULL,
  `IdCuentaPadre` int DEFAULT NULL,
  `Nivel` int NOT NULL DEFAULT '1',
  `Imputable` tinyint(1) NOT NULL DEFAULT '1',
  PRIMARY KEY (`IdCuentaContable`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Table structure for table `cuentaporpagar`
--

DROP TABLE IF EXISTS `cuentaporpagar`;
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Table structure for table `cuentascobrar`
--

DROP TABLE IF EXISTS `cuentascobrar`;
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Table structure for table `declaracioniva`
--

DROP TABLE IF EXISTS `declaracioniva`;
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Table structure for table `despacho`
--

DROP TABLE IF EXISTS `despacho`;
CREATE TABLE `despacho` (
  `IdDespacho` int NOT NULL AUTO_INCREMENT,
  `IdVenta` int NOT NULL,
  `Estado` varchar(50) DEFAULT NULL,
  `FechaEstimada` date DEFAULT NULL,
  `FechaEntrega` date DEFAULT NULL,
  `Tipo` varchar(50) DEFAULT NULL,
  `Observaciones` varchar(255) DEFAULT NULL,
  `IdUsuario` int NOT NULL,
  PRIMARY KEY (`IdDespacho`),
  KEY `IdVenta` (`IdVenta`),
  KEY `IdUsuario` (`IdUsuario`),
  CONSTRAINT `despacho_ibfk_1` FOREIGN KEY (`IdVenta`) REFERENCES `venta` (`IdVenta`),
  CONSTRAINT `despacho_ibfk_2` FOREIGN KEY (`IdUsuario`) REFERENCES `usuario` (`IdUsuario`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Table structure for table `detalleasiento`
--

DROP TABLE IF EXISTS `detalleasiento`;
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Table structure for table `detallecotizacion`
--

DROP TABLE IF EXISTS `detallecotizacion`;
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Table structure for table `detalleordencompra`
--

DROP TABLE IF EXISTS `detalleordencompra`;
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Table structure for table `detallerecepcion`
--

DROP TABLE IF EXISTS `detallerecepcion`;
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Table structure for table `devolucionproveedor`
--

DROP TABLE IF EXISTS `devolucionproveedor`;
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Table structure for table `inventario`
--

DROP TABLE IF EXISTS `inventario`;
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Table structure for table `laboratorio`
--

DROP TABLE IF EXISTS `laboratorio`;
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Table structure for table `lote`
--

DROP TABLE IF EXISTS `lote`;
CREATE TABLE `lote` (
  `IdLote` int NOT NULL AUTO_INCREMENT,
  `IdVariante` int NOT NULL,
  `IdBodega` int DEFAULT NULL,
  `NumeroLote` varchar(50) NOT NULL,
  `FechaIngreso` date DEFAULT NULL,
  `FechaVencimiento` date DEFAULT NULL,
  `CostoUnitario` decimal(18,2) DEFAULT NULL,
  `CantidadInicial` int DEFAULT NULL,
  `CantidadDisponible` int DEFAULT NULL,
  `Estado` varchar(20) DEFAULT NULL,
  PRIMARY KEY (`IdLote`),
  KEY `IdVariante` (`IdVariante`),
  KEY `IdBodega` (`IdBodega`),
  CONSTRAINT `lote_ibfk_1` FOREIGN KEY (`IdVariante`) REFERENCES `varianteproducto` (`IdVariante`),
  CONSTRAINT `lote_chk_1` CHECK ((`Estado` in (_utf8mb4'Disponible',_utf8mb4'Cuarentena',_utf8mb4'Vencido',_utf8mb4'Agotado')))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Table structure for table `marca`
--

DROP TABLE IF EXISTS `marca`;
CREATE TABLE `marca` (
  `IdMarca` int NOT NULL AUTO_INCREMENT,
  `Nombre` varchar(100) NOT NULL,
  `Descripcion` varchar(255) DEFAULT NULL,
  `Activo` tinyint(1) DEFAULT '1',
  PRIMARY KEY (`IdMarca`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Table structure for table `merma`
--

DROP TABLE IF EXISTS `merma`;
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Table structure for table `movimientoinventario`
--

DROP TABLE IF EXISTS `movimientoinventario`;
CREATE TABLE `movimientoinventario` (
  `IdMovimiento` int NOT NULL AUTO_INCREMENT,
  `IdLote` int DEFAULT NULL,
  `IdBodega` int DEFAULT NULL,
  `IdTipoMovimiento` int NOT NULL,
  `IdUsuario` int NOT NULL,
  `FechaMovimiento` datetime DEFAULT CURRENT_TIMESTAMP,
  `Cantidad` int NOT NULL,
  `StockAnterior` int DEFAULT NULL,
  `StockPosterior` int DEFAULT NULL,
  `Referencia` varchar(100) DEFAULT NULL,
  `Observacion` varchar(255) DEFAULT NULL,
  `Origen` varchar(20) DEFAULT NULL,
  `IdDetalleOrigen` int DEFAULT NULL,
  PRIMARY KEY (`IdMovimiento`),
  KEY `IdLote` (`IdLote`),
  KEY `IdBodega` (`IdBodega`),
  KEY `IdTipoMovimiento` (`IdTipoMovimiento`),
  KEY `IdUsuario` (`IdUsuario`),
  CONSTRAINT `movimientoinventario_ibfk_1` FOREIGN KEY (`IdLote`) REFERENCES `lote` (`IdLote`),
  CONSTRAINT `movimientoinventario_ibfk_2` FOREIGN KEY (`IdTipoMovimiento`) REFERENCES `tipomovimiento` (`IdTipoMovimiento`),
  CONSTRAINT `movimientoinventario_ibfk_3` FOREIGN KEY (`IdUsuario`) REFERENCES `usuario` (`IdUsuario`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Table structure for table `ordencompra`
--

DROP TABLE IF EXISTS `ordencompra`;
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Table structure for table `pagoproveedor`
--

DROP TABLE IF EXISTS `pagoproveedor`;
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Table structure for table `periodocontable`
--

DROP TABLE IF EXISTS `periodocontable`;
CREATE TABLE `periodocontable` (
  `IdPeriodo` int NOT NULL AUTO_INCREMENT,
  `Nombre` varchar(50) NOT NULL,
  `FechaInicio` date NOT NULL,
  `FechaFin` date NOT NULL,
  `Estado` varchar(20) DEFAULT NULL,
  PRIMARY KEY (`IdPeriodo`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Table structure for table `producto`
--

DROP TABLE IF EXISTS `producto`;
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Table structure for table `recepcioncompra`
--

DROP TABLE IF EXISTS `recepcioncompra`;
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Table structure for table `rol`
--

DROP TABLE IF EXISTS `rol`;
CREATE TABLE `rol` (
  `IdRol` int NOT NULL AUTO_INCREMENT,
  `Nombre` varchar(50) NOT NULL,
  PRIMARY KEY (`IdRol`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Table structure for table `tipomovimiento`
--

DROP TABLE IF EXISTS `tipomovimiento`;
CREATE TABLE `tipomovimiento` (
  `IdTipoMovimiento` int NOT NULL AUTO_INCREMENT,
  `Nombre` varchar(100) NOT NULL,
  `Naturaleza` varchar(50) DEFAULT NULL,
  `Descripcion` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`IdTipoMovimiento`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Table structure for table `usuario`
--

DROP TABLE IF EXISTS `usuario`;
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Table structure for table `varianteproducto`
--

DROP TABLE IF EXISTS `varianteproducto`;
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Table structure for table `venta`
--

DROP TABLE IF EXISTS `venta`;
CREATE TABLE `venta` (
  `IdVenta` int NOT NULL AUTO_INCREMENT,
  `TipoDocumento` varchar(50) NOT NULL,
  `Folio` varchar(50) DEFAULT NULL,
  `Fecha` date NOT NULL,
  `Neto` decimal(18,2) NOT NULL DEFAULT '0.00',
  `Iva` decimal(18,2) NOT NULL DEFAULT '0.00',
  `Descuento` decimal(18,2) NOT NULL DEFAULT '0.00',
  `Total` decimal(18,2) DEFAULT '0.00',
  `FormaPago` varchar(50) NOT NULL DEFAULT 'Contado',
  `Estado` varchar(30) NOT NULL DEFAULT 'Emitida',
  `IdCliente` int NOT NULL,
  `IdCotizacion` int DEFAULT NULL,
  `IdUsuario` int NOT NULL,
  `IdVentaOrigen` int DEFAULT NULL,
  PRIMARY KEY (`IdVenta`),
  KEY `IdCliente` (`IdCliente`),
  KEY `IdCotizacion` (`IdCotizacion`),
  KEY `IdUsuario` (`IdUsuario`),
  CONSTRAINT `venta_ibfk_1` FOREIGN KEY (`IdCliente`) REFERENCES `cliente` (`IdCliente`),
  CONSTRAINT `venta_ibfk_2` FOREIGN KEY (`IdCotizacion`) REFERENCES `cotizacion` (`IdCotizacion`),
  CONSTRAINT `venta_ibfk_3` FOREIGN KEY (`IdUsuario`) REFERENCES `usuario` (`IdUsuario`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Table structure for table `ventadetalle`
--

DROP TABLE IF EXISTS `ventadetalle`;
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- =========================================================================
-- TABLA: configuracionglobal (Parámetros dinámicos de IVA y Firmas)
-- =========================================================================
DROP TABLE IF EXISTS `configuracionglobal`;
CREATE TABLE `configuracionglobal` (
  `IdConfiguracion` int NOT NULL AUTO_INCREMENT,
  `Clave` varchar(50) NOT NULL UNIQUE,
  `Valor` varchar(255) NOT NULL,
  `Descripcion` varchar(255) DEFAULT NULL,
  `FechaModificacion` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`IdConfiguracion`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

INSERT INTO `configuracionglobal` (`Clave`, `Valor`, `Descripcion`) VALUES 
('TasaIva', '0.19', 'Tasa general de IVA en Chile (RF-COM-04)'),
('NombreJefeCompras', 'Javiera Rail Astudillo', 'Firma oficial Jefatura de Compras'),
('NombreJefeVentas', 'Camilo Rodríguez Saldaña', 'Firma oficial Jefatura de Ventas'),
('NombreJefeInventario', 'Katherine Sanhueza Hernández', 'Firma oficial Jefatura de Bodega'),
('NombreContador', 'Contador General', 'Firma oficial Contabilidad y Comprobantes de Pago')
ON DUPLICATE KEY UPDATE `Valor` = VALUES(`Valor`);

-- =========================================================================
-- SEED DATA: Roles del sistema (RBAC)
-- =========================================================================
INSERT INTO `rol` (`IdRol`, `Nombre`) VALUES 
(1, 'Administrador'),
(2, 'Vendedor'),
(3, 'Comprador'),
(4, 'Bodeguero'),
(5, 'Contador')
ON DUPLICATE KEY UPDATE `Nombre` = VALUES(`Nombre`);

-- =========================================================================
-- SEED DATA: Usuarios con acceso a cada módulo (Password: 1234)
-- =========================================================================
INSERT INTO `usuario` (`IdUsuario`, `IdRol`, `Nombre`, `Correo`, `Password`, `Rol`, `Activo`) VALUES 
(1, 1, 'Camilo Admin', 'admin@dermo.cl', '1234', 'Administrador', 1),
(2, 2, 'Raul Martinez', 'raul1@dermo.cl', '1234', 'Vendedor', 1),
(3, 3, 'Javiera Rail (Compras)', 'comprador@dermo.cl', '1234', 'Comprador', 1),
(4, 4, 'Bodeguero Central', 'bodega@dermo.cl', '1234', 'Bodeguero', 1),
(5, 5, 'Contador General', 'contador@dermo.cl', '1234', 'Contador', 1),
(6, 2, 'Valentina Rojas (Ventas)', 'vrojas@dermo.cl', '1234', 'Vendedor', 1)
ON DUPLICATE KEY UPDATE `Password` = VALUES(`Password`), `Activo` = VALUES(`Activo`);

-- =========================================================================
-- SEED DATA: Bodegas de Almacenamiento y Despacho
-- =========================================================================
INSERT INTO `bodega` (`IdBodega`, `Nombre`, `Ubicacion`, `Activo`) VALUES
(1, 'Bodega Central Santiago', 'Av. Américo Vespucio 1450, Quilicura, Santiago', 1),
(2, 'Bodega Sucursal Providencia', 'Av. Providencia 2124, Local 4, Providencia, Santiago', 1),
(3, 'Bodega Distribución Zona Sur', 'Av. Paicaví 1890, Concepción', 1)
ON DUPLICATE KEY UPDATE `Nombre` = VALUES(`Nombre`), `Activo` = 1;

-- =========================================================================
-- SEED DATA: Tipos de Movimiento de Inventario
-- =========================================================================
INSERT INTO `tipomovimiento` (`IdTipoMovimiento`, `Nombre`, `Naturaleza`, `Descripcion`) VALUES
(1, 'Entrada', 'Entrada', 'Recepción de compra'),
(2, 'Salida', 'Salida', 'Salida por venta'),
(3, 'Ajuste positivo', 'Entrada', 'Diferencia justificada de inventario'),
(4, 'Ajuste negativo', 'Salida', 'Pérdida, daño o vencimiento justificado')
ON DUPLICATE KEY UPDATE `Naturaleza` = VALUES(`Naturaleza`), `Descripcion` = VALUES(`Descripcion`);

-- =========================================================================
-- SEED DATA: Laboratorios y Proveedores
-- =========================================================================
INSERT INTO `laboratorio` (`IdLaboratorio`, `Rut`, `RazonSocial`, `Marca`, `Pais`, `Contacto`, `Email`, `Telefono`, `DiasPago`, `Activo`) VALUES 
(1, '77.234.567-9', 'ISDIN Chile S.A.', 'ISDIN', 'Chile', 'Carlos Pérez', 'contacto@isdin.cl', '+56911223344', 30, 1),
(2, '76.111.222-5', 'L''Oréal Chile S.A.', 'L''Oréal / CeraVe / Vichy / SkinCeuticals', 'Chile', 'María López', 'contacto@loreal.cl', '+56922334455', 60, 1),
(3, '78.444.555-K', 'La Roche-Posay Chile', 'La Roche-Posay', 'Francia', 'Ana Gómez', 'contacto@laroche.cl', '+56933445566', 45, 1),
(4, '79.888.999-1', 'Eucerin Beiersdorf S.A.', 'Eucerin', 'Alemania', 'Felipe Soto', 'contacto@eucerin.cl', '+56944556677', 30, 1),
(5, '76.555.444-3', 'Pierre Fabre Dermo-Cosmétique Chile', 'Avène', 'Francia', 'Lucía Mardones', 'compras@pierrefabre.cl', '+56955667788', 45, 1),
(6, '77.999.111-2', 'NAOS Bioderma Chile SpA', 'Bioderma', 'Francia', 'Martín Arriagada', 'logistica@bioderma.cl', '+56966778899', 30, 1)
ON DUPLICATE KEY UPDATE `Activo` = 1;

-- =========================================================================
-- SEED DATA: Marcas de Dermocosmética
-- =========================================================================
INSERT INTO `marca` (`IdMarca`, `Nombre`, `Descripcion`, `Activo`) VALUES
(1, 'ISDIN', 'Fotoprotección y dermatología clínica española', 1),
(2, 'La Roche-Posay', 'Dermocosmética francesa para pieles sensibles', 1),
(3, 'CeraVe', 'Cuidado dermatológico desarrollado con ceramidas esenciales', 1),
(4, 'Eucerin', 'Ciencia dermatológica alemana para el cuidado clínico de la piel', 1),
(5, 'Avène', 'Dermocosmética con agua termal calmante para pieles intolerantes', 1),
(6, 'Vichy', 'Cosmecéutica mineral fortalecedora y antiedad clínica', 1),
(7, 'Bioderma', 'Ecobiología al servicio de la dermatología clínica', 1),
(8, 'SkinCeuticals', 'Cosmecéutica avanzada de alta potencia antioxidante', 1)
ON DUPLICATE KEY UPDATE `Nombre` = VALUES(`Nombre`), `Activo` = 1;

-- =========================================================================
-- SEED DATA: Categorías de Cosmecéutica
-- =========================================================================
INSERT INTO `categoria` (`IdCategoria`, `Nombre`, `Descripcion`, `Activo`) VALUES 
(1, 'Protección Solar', 'Fotoprotectores solares faciales y corporales dermatológicos', 1),
(2, 'Cuidado Facial y Sérums', 'Sérums concentrados, hidratantes y tratamientos anti-edad', 1),
(3, 'Limpieza Dermo', 'Geles limpiadores dermatológicos, espumas y aguas micelares', 1),
(4, 'Tratamientos Clínicos y Acné', 'Cremas reparadoras, despigmentantes y control seborreico', 1),
(5, 'Hidratación Corporal', 'Lociones, bálsamos emolientes y reparación de barrera cutánea', 1)
ON DUPLICATE KEY UPDATE `Activo` = 1;

-- =========================================================================
-- SEED DATA: Productos Dermocosméticos
-- =========================================================================
INSERT INTO `producto` (`IdProducto`, `IdCategoria`, `IdMarca`, `Nombre`, `Descripcion`, `StockMinimo`, `PuntoReOrden`, `Activo`) VALUES 
(1, 1, 1, 'Fusion Water Magic SPF 50', 'Fotoprotector solar facial ultraligero de absorción inmediata', 15, 25, 1),
(2, 2, 2, 'Sérum Hyalu B5 Concentrado', 'Sérum anti-arrugas reparador y rellenador con ácido hialurónico puro y vitamina B5', 10, 20, 1),
(3, 3, 3, 'Gel Limpiador Espumoso', 'Limpiador dermatológico con 3 ceramidas esenciales y niacinamida para piel normal a grasa', 20, 35, 1),
(4, 4, 5, 'Cicalfate+ Crema Reparadora', 'Crema reparadora y protectora calmante para pieles irritadas o post-procedimiento', 12, 20, 1),
(5, 1, 2, 'Anthelios UVMune 400 Fluido Invisible SPF 50+', 'Fotoprotector facial de amplio espectro contra rayos UVA ultra-largos', 15, 30, 1),
(6, 4, 4, 'Anti-Pigment Dual Sérum', 'Sérum despigmentante clínico con Thiamidol patentado y ácido hialurónico', 10, 18, 1),
(7, 2, 6, 'Minéral 89 Booster Hidratante', 'Concentrado fortificante y rellenador diario con 89% agua volcánica mineralizante', 15, 25, 1),
(8, 3, 7, 'Sensibio H2O Agua Micelar', 'Agua micelar dermatológica limpiadora y desmaquillante para piel sensible', 20, 35, 1),
(9, 5, 3, 'Crema Hidratante Piel Seca a Muy Seca', 'Crema rica restauradora de la barrera cutánea con tecnología MVE y ceramidas', 15, 25, 1),
(10, 4, 2, 'Effaclar Duo+M Tratamiento Anti-Imperfecciones', 'Corrector triple acción para piel grasa con tendencia acneica', 12, 22, 1),
(11, 1, 4, 'Sun Face Oil Control Gel-Crema Toque Seco FPS 50+', 'Protector solar facial matificante anti-brillo por 12 horas', 15, 25, 1),
(12, 2, 8, 'C E Ferulic Sérum Antioxidante', 'Sérum antioxidante de alta potencia con 15% Vitamina C pura, Vitamina E y Ácido Ferúlico', 5, 10, 1)
ON DUPLICATE KEY UPDATE `Nombre` = VALUES(`Nombre`), `IdMarca` = VALUES(`IdMarca`), `Activo` = 1;

-- =========================================================================
-- SEED DATA: Variantes de Producto con Precios Chilenos (CLP)
-- =========================================================================
INSERT INTO `varianteproducto` (`IdVariante`, `IdProducto`, `Sku`, `NombreVariante`, `AtributoValor`, `Presentacion`, `Color`, `CostoPromedio`, `PrecioVenta`, `StockTotal`, `Activo`) VALUES 
(1, 1, 'ISD-FW-50ML', 'Frasco 50ml', 'SPF 50 · Sin Color', 'Frasco 50ml', 'Incoloro', 15900.00, 23990.00, 65, 1),
(2, 2, 'LRP-HB5-30ML', 'Gotero 30ml', 'Ácido Hialurónico + Vit B5', 'Gotero 30ml', 'Traslúcido', 24500.00, 36990.00, 40, 1),
(3, 3, 'CER-GEL-236ML', 'Dispensador 236ml', 'Piel Normal a Grasa', 'Dispensador 236ml', 'Neutro', 8900.00, 14990.00, 70, 1),
(4, 4, 'AVE-CIC-40ML', 'Tubo 40ml', 'Cobre-Zinc + C+-Restore', 'Tubo 40ml', 'Blanco', 10500.00, 16990.00, 45, 1),
(5, 5, 'LRP-ANT-50ML', 'Frasco 50ml', 'SPF 50+ Fluido Invisible', 'Frasco 50ml', 'Invisible', 16200.00, 24990.00, 50, 1),
(6, 6, 'EUC-APG-30ML', 'Dispensador Dual 30ml', 'Thiamidol + Ác. Hialurónico', 'Dispensador 30ml', 'Blanco/Rosa', 25900.00, 38990.00, 35, 1),
(7, 7, 'VIC-M89-50ML', 'Frasco Dosificador 50ml', '89% Agua Volcánica + Hialurónico', 'Frasco 50ml', 'Transparente', 20500.00, 31990.00, 45, 1),
(8, 8, 'BIO-SEN-500ML', 'Botella 500ml', 'Piel Sensible / Reactiva', 'Botella 500ml', 'Incoloro', 12400.00, 19490.00, 60, 1),
(9, 9, 'CER-CRE-454G', 'Pote 454g', '3 Ceramidas Esenciales', 'Pote 454g', 'Blanco', 13800.00, 21990.00, 55, 1),
(10, 10, 'LRP-EFF-40ML', 'Tubo 40ml', 'Phylobioma + Niacinamida', 'Tubo 40ml', 'Blanco', 15600.00, 23490.00, 40, 1),
(11, 11, 'EUC-OIL-50ML', 'Frasco 50ml', 'L-Carnitina Toque Seco FPS 50+', 'Frasco 50ml', 'Sin Color', 14900.00, 22490.00, 50, 1),
(12, 12, 'SKC-CEF-30ML', 'Gotero 30ml', '15% L-Ácido Ascórbico + Ferúlico', 'Gotero 30ml', 'Ámbar', 92000.00, 139990.00, 20, 1)
ON DUPLICATE KEY UPDATE 
  `NombreVariante` = VALUES(`NombreVariante`),
  `CostoPromedio` = VALUES(`CostoPromedio`),
  `PrecioVenta` = VALUES(`PrecioVenta`),
  `StockTotal` = VALUES(`StockTotal`),
  `Activo` = 1;

-- =========================================================================
-- SEED DATA: Inventario por Bodega (Stock disponible para ventas)
-- =========================================================================
INSERT INTO `inventario` (`IdInventario`, `IdVariante`, `IdBodega`, `StockActual`, `StockReservado`, `FechaActualizada`) VALUES
-- Bodega Central Santiago (IdBodega = 1)
(1, 1, 1, 45, 0, NOW()),
(2, 2, 1, 25, 0, NOW()),
(3, 3, 1, 50, 0, NOW()),
(4, 4, 1, 30, 0, NOW()),
(5, 5, 1, 35, 0, NOW()),
(6, 6, 1, 25, 0, NOW()),
(7, 7, 1, 30, 0, NOW()),
(8, 8, 1, 40, 0, NOW()),
(9, 9, 1, 35, 0, NOW()),
(10, 10, 1, 25, 0, NOW()),
(11, 11, 1, 35, 0, NOW()),
(12, 12, 1, 12, 0, NOW()),
-- Bodega Sucursal Providencia (IdBodega = 2)
(13, 1, 2, 20, 0, NOW()),
(14, 2, 2, 15, 0, NOW()),
(15, 3, 2, 20, 0, NOW()),
(16, 4, 2, 15, 0, NOW()),
(17, 5, 2, 15, 0, NOW()),
(18, 6, 2, 10, 0, NOW()),
(19, 7, 2, 15, 0, NOW()),
(20, 8, 2, 20, 0, NOW()),
(21, 9, 2, 20, 0, NOW()),
(22, 10, 2, 15, 0, NOW()),
(23, 11, 2, 15, 0, NOW()),
(24, 12, 2, 8, 0, NOW())
ON DUPLICATE KEY UPDATE `StockActual` = VALUES(`StockActual`), `StockReservado` = VALUES(`StockReservado`), `FechaActualizada` = NOW();

-- =========================================================================
-- SEED DATA: Lotes en Bodega con Vencimientos Vigentes (Criterio FEFO)
-- =========================================================================
INSERT INTO `lote` (`IdLote`, `IdVariante`, `IdBodega`, `NumeroLote`, `FechaIngreso`, `FechaVencimiento`, `CostoUnitario`, `CantidadInicial`, `CantidadDisponible`, `Estado`) VALUES 
-- Lotes en Bodega Central Santiago (IdBodega = 1)
(1, 1, 1, 'LOT-ISD-2026A', DATE_SUB(CURDATE(), INTERVAL 40 DAY), DATE_ADD(CURDATE(), INTERVAL 14 MONTH), 15900.00, 30, 20, 'Disponible'),
(2, 1, 1, 'LOT-ISD-2026B', DATE_SUB(CURDATE(), INTERVAL 10 DAY), DATE_ADD(CURDATE(), INTERVAL 22 MONTH), 15900.00, 25, 25, 'Disponible'),
(3, 2, 1, 'LOT-LRP-HB5-01', DATE_SUB(CURDATE(), INTERVAL 35 DAY), DATE_ADD(CURDATE(), INTERVAL 16 MONTH), 24500.00, 30, 25, 'Disponible'),
(4, 3, 1, 'LOT-CER-2026A', DATE_SUB(CURDATE(), INTERVAL 45 DAY), DATE_ADD(CURDATE(), INTERVAL 18 MONTH), 8900.00, 60, 50, 'Disponible'),
(5, 4, 1, 'LOT-AVE-CIC-01', DATE_SUB(CURDATE(), INTERVAL 30 DAY), DATE_ADD(CURDATE(), INTERVAL 15 MONTH), 10500.00, 35, 30, 'Disponible'),
(6, 5, 1, 'LOT-LRP-ANT-01', DATE_SUB(CURDATE(), INTERVAL 25 DAY), DATE_ADD(CURDATE(), INTERVAL 19 MONTH), 16200.00, 40, 35, 'Disponible'),
(7, 6, 1, 'LOT-EUC-APG-01', DATE_SUB(CURDATE(), INTERVAL 20 DAY), DATE_ADD(CURDATE(), INTERVAL 17 MONTH), 25900.00, 30, 25, 'Disponible'),
(8, 7, 1, 'LOT-VIC-M89-01', DATE_SUB(CURDATE(), INTERVAL 28 DAY), DATE_ADD(CURDATE(), INTERVAL 20 MONTH), 20500.00, 35, 30, 'Disponible'),
(9, 8, 1, 'LOT-BIO-SEN-01', DATE_SUB(CURDATE(), INTERVAL 22 DAY), DATE_ADD(CURDATE(), INTERVAL 24 MONTH), 12400.00, 45, 40, 'Disponible'),
(10, 9, 1, 'LOT-CER-CRE-01', DATE_SUB(CURDATE(), INTERVAL 18 DAY), DATE_ADD(CURDATE(), INTERVAL 21 MONTH), 13800.00, 40, 35, 'Disponible'),
(11, 10, 1, 'LOT-LRP-EFF-01', DATE_SUB(CURDATE(), INTERVAL 15 DAY), DATE_ADD(CURDATE(), INTERVAL 16 MONTH), 15600.00, 30, 25, 'Disponible'),
(12, 11, 1, 'LOT-EUC-OIL-01', DATE_SUB(CURDATE(), INTERVAL 12 DAY), DATE_ADD(CURDATE(), INTERVAL 18 MONTH), 14900.00, 40, 35, 'Disponible'),
(13, 12, 1, 'LOT-SKC-CEF-01', DATE_SUB(CURDATE(), INTERVAL 10 DAY), DATE_ADD(CURDATE(), INTERVAL 12 MONTH), 92000.00, 15, 12, 'Disponible'),
-- Lotes en Bodega Sucursal Providencia (IdBodega = 2)
(14, 1, 2, 'LOT-ISD-PRV-01', DATE_SUB(CURDATE(), INTERVAL 20 DAY), DATE_ADD(CURDATE(), INTERVAL 18 MONTH), 15900.00, 20, 20, 'Disponible'),
(15, 2, 2, 'LOT-LRP-PRV-02', DATE_SUB(CURDATE(), INTERVAL 20 DAY), DATE_ADD(CURDATE(), INTERVAL 18 MONTH), 24500.00, 15, 15, 'Disponible'),
(16, 3, 2, 'LOT-CER-PRV-03', DATE_SUB(CURDATE(), INTERVAL 20 DAY), DATE_ADD(CURDATE(), INTERVAL 20 MONTH), 8900.00, 20, 20, 'Disponible'),
(17, 4, 2, 'LOT-AVE-PRV-04', DATE_SUB(CURDATE(), INTERVAL 15 DAY), DATE_ADD(CURDATE(), INTERVAL 17 MONTH), 10500.00, 15, 15, 'Disponible'),
(18, 5, 2, 'LOT-LRP-PRV-05', DATE_SUB(CURDATE(), INTERVAL 15 DAY), DATE_ADD(CURDATE(), INTERVAL 19 MONTH), 16200.00, 15, 15, 'Disponible'),
(19, 6, 2, 'LOT-EUC-PRV-06', DATE_SUB(CURDATE(), INTERVAL 15 DAY), DATE_ADD(CURDATE(), INTERVAL 16 MONTH), 25900.00, 10, 10, 'Disponible'),
(20, 7, 2, 'LOT-VIC-PRV-07', DATE_SUB(CURDATE(), INTERVAL 12 DAY), DATE_ADD(CURDATE(), INTERVAL 21 MONTH), 20500.00, 15, 15, 'Disponible'),
(21, 8, 2, 'LOT-BIO-PRV-08', DATE_SUB(CURDATE(), INTERVAL 12 DAY), DATE_ADD(CURDATE(), INTERVAL 22 MONTH), 12400.00, 20, 20, 'Disponible'),
(22, 9, 2, 'LOT-CER-PRV-09', DATE_SUB(CURDATE(), INTERVAL 10 DAY), DATE_ADD(CURDATE(), INTERVAL 20 MONTH), 13800.00, 20, 20, 'Disponible'),
(23, 10, 2, 'LOT-LRP-PRV-10', DATE_SUB(CURDATE(), INTERVAL 10 DAY), DATE_ADD(CURDATE(), INTERVAL 18 MONTH), 15600.00, 15, 15, 'Disponible'),
(24, 11, 2, 'LOT-EUC-PRV-11', DATE_SUB(CURDATE(), INTERVAL 8 DAY), DATE_ADD(CURDATE(), INTERVAL 19 MONTH), 14900.00, 15, 15, 'Disponible'),
(25, 12, 2, 'LOT-SKC-PRV-12', DATE_SUB(CURDATE(), INTERVAL 8 DAY), DATE_ADD(CURDATE(), INTERVAL 14 MONTH), 92000.00, 8, 8, 'Disponible')
ON DUPLICATE KEY UPDATE `IdBodega` = VALUES(`IdBodega`), `CantidadDisponible` = VALUES(`CantidadDisponible`), `FechaVencimiento` = VALUES(`FechaVencimiento`), `Estado` = VALUES(`Estado`);

-- =========================================================================
-- SEED DATA: Órdenes de Compra y Recepciones de Prueba
-- =========================================================================
INSERT INTO `ordencompra` (`IdOC`, `NumeroOC`, `IdLaboratorio`, `IdCotizacion`, `Fecha`, `FechaEsperada`, `Estado`, `Neto`, `Iva`, `Total`, `IdUsuario`) VALUES 
(1, 'OC-2026-0001', 2, NULL, DATE_SUB(CURDATE(), INTERVAL 45 DAY), DATE_SUB(CURDATE(), INTERVAL 30 DAY), 'Recibida', 407000.00, 77330.00, 484330.00, 3),
(2, 'OC-2026-0002', 1, NULL, DATE_SUB(CURDATE(), INTERVAL 15 DAY), DATE_ADD(CURDATE(), INTERVAL 10 DAY), 'Emitida', 361000.00, 68590.00, 429590.00, 3)
ON DUPLICATE KEY UPDATE `Estado` = VALUES(`Estado`);

INSERT INTO `detalleordencompra` (`IdDetalleOC`, `IdOC`, `IdVariante`, `CantidadPedida`, `CantidadRecibida`, `CostoUnitario`) VALUES 
(1, 1, 1, 20, 20, 15900.00),
(2, 1, 3, 10, 10, 8900.00),
(3, 2, 1, 15, 0, 15900.00),
(4, 2, 2, 5, 0, 24500.00)
ON DUPLICATE KEY UPDATE `CantidadRecibida` = VALUES(`CantidadRecibida`);

INSERT INTO `recepcioncompra` (`IdRecepcion`, `IdOC`, `GuiaDespacho`, `FechaRecepcion`, `Estado`, `IdUsuario`) VALUES 
(1, 1, 'GD-884920', DATE_SUB(CURDATE(), INTERVAL 32 DAY), 'Aprobada', 4)
ON DUPLICATE KEY UPDATE `Estado` = VALUES(`Estado`);

INSERT INTO `detallerecepcion` (`IdDetalleRec`, `IdRecepcion`, `IdDetalleOC`, `IdVariante`, `NumeroLote`, `FechaVencimiento`, `Cantidad`, `CostoUnitario`) VALUES 
(1, 1, 1, 1, 'LOT-ISD-2026A', DATE_ADD(CURDATE(), INTERVAL 14 MONTH), 20, 15900.00),
(2, 1, 2, 3, 'LOT-CER-2026A', DATE_ADD(CURDATE(), INTERVAL 18 MONTH), 10, 8900.00)
ON DUPLICATE KEY UPDATE `Cantidad` = VALUES(`Cantidad`);

-- =========================================================================
-- SEED DATA: Cartera de Clientes Chilenos (Módulo de Ventas RF-VEN-01 y RF-VEN-07)
-- =========================================================================
INSERT INTO `cliente` (`IdCliente`, `Rut`, `Nombre`, `RazonSocial`, `Categoria`, `Giro`, `Direccion`, `Contacto`, `Correo`, `Telefono`, `LimiteCredito`, `DiasCredito`, `Activo`) VALUES
(1, '76.543.210-K', 'Clínica Estética DermoSalud SpA', 'Clínica Estética DermoSalud SpA', 'Clinica', 'Servicios Médicos y Dermatología Clínica', 'Av. Providencia 2345, Of. 801, Providencia, Santiago', 'Dra. Andrea Valenzuela', 'contacto@dermosalud.cl', '+56 9 8765 4321', 3500000.00, 30, 1),
(2, '77.890.123-4', 'Farmacias Dermocare Chile Ltda.', 'Farmacias Dermocare Chile Ltda.', 'Farmacia', 'Comercio Minorista de Productos Farmacéuticos y Dermocosméticos', 'Av. Apoquindo 4501, Local 12, Las Condes, Santiago', 'Roberto Fuenzalida', 'adquisiciones@dermocare.cl', '+56 9 7654 3210', 5000000.00, 45, 1),
(3, '76.998.877-6', 'Distribuidora Belleza & Salud Sur S.A.', 'Distribuidora Belleza & Salud Sur S.A.', 'Mayorista', 'Distribución Mayorista de Insumos Cosmecéuticos', 'Av. Bernardo O''Higgins 1120, Concepción', 'Marcela Riquelme', 'compras@bellezasur.cl', '+56 9 6543 2109', 8000000.00, 60, 1),
(4, '78.112.233-9', 'Centro Dermatológico SkinClinic Vitacura', 'Centro Dermatológico SkinClinic Vitacura SpA', 'Clinica', 'Clínica Estética Integral y Procedimientos Láser', 'Av. Nueva Costanera 3900, Of. 402, Vitacura, Santiago', 'Dr. Sebastián Morales', 'smorales@skinclinic.cl', '+56 9 5432 1098', 4200000.00, 30, 1),
(5, '15.432.876-5', 'Camila Ignacia Fernández Rojas', 'Camila Ignacia Fernández Rojas', 'Profesional', 'Cosmetóloga y Esteticista Clínica Independiente', 'Av. Libertad 840, Of. 304, Viña del Mar', 'Camila Fernández', 'camila.cosmetologia@gmail.com', '+56 9 4321 0987', 1200000.00, 30, 1),
(6, '76.334.455-2', 'Botica Natural & Dermo Boutique SpA', 'Botica Natural & Dermo Boutique SpA', 'Farmacia', 'Venta Especializada de Productos Dermocosméticos', 'Av. Pedro de Valdivia 1780, Ñuñoa, Santiago', 'Francisca Lagos', 'contacto@dermoboutique.cl', '+56 9 3210 9876', 2500000.00, 30, 1),
(7, '18.765.432-1', 'Valentina Paz Soto Mardones', 'Valentina Paz Soto Mardones', 'Particular', 'Consumidor Final / Cliente Frecuente', 'Los Militares 5620, Depto. 1102, Las Condes, Santiago', 'Valentina Soto', 'valesoto.m@gmail.com', '+56 9 2109 8765', 0.00, 0, 1),
(8, '79.221.334-8', 'Estética Avanzada Las Condes Ltda.', 'Estética Avanzada Las Condes Ltda.', 'Clinica', 'Tratamientos Faciales y Corporales', 'Av. Presidente Kennedy 7100, Of. 505, Las Condes, Santiago', 'Paulina Echeverría', 'admin@esteticalascondes.cl', '+56 9 9123 4567', 1500000.00, 30, 0)
ON DUPLICATE KEY UPDATE
  `Nombre` = VALUES(`Nombre`),
  `RazonSocial` = VALUES(`RazonSocial`),
  `Categoria` = VALUES(`Categoria`),
  `Giro` = VALUES(`Giro`),
  `Direccion` = VALUES(`Direccion`),
  `Contacto` = VALUES(`Contacto`),
  `Correo` = VALUES(`Correo`),
  `Telefono` = VALUES(`Telefono`),
  `LimiteCredito` = VALUES(`LimiteCredito`),
  `DiasCredito` = VALUES(`DiasCredito`),
  `Activo` = VALUES(`Activo`);

-- =========================================================================
-- SEED DATA: Cotizaciones y Presupuestos de Ventas (RF-VEN-02)
-- =========================================================================
INSERT INTO `cotizacion` (`IdCotizacion`, `FechaEmision`, `FechaVencimiento`, `Estado`, `Total`, `IdCliente`, `IdUsuario`) VALUES
(1, DATE_SUB(CURDATE(), INTERVAL 25 DAY), DATE_SUB(CURDATE(), INTERVAL 10 DAY), 'Aceptado', 311870.00, 1, 2),
(2, DATE_SUB(CURDATE(), INTERVAL 18 DAY), DATE_SUB(CURDATE(), INTERVAL 3 DAY), 'Aceptado', 534780.00, 2, 2),
(3, DATE_SUB(CURDATE(), INTERVAL 5 DAY), DATE_ADD(CURDATE(), INTERVAL 15 DAY), 'Vigente', 258890.00, 4, 2),
(4, DATE_SUB(CURDATE(), INTERVAL 2 DAY), DATE_ADD(CURDATE(), INTERVAL 20 DAY), 'Vigente', 494830.00, 3, 1),
(5, DATE_SUB(CURDATE(), INTERVAL 35 DAY), DATE_SUB(CURDATE(), INTERVAL 20 DAY), 'Vencido', 159930.00, 5, 6),
(6, DATE_SUB(CURDATE(), INTERVAL 12 DAY), DATE_ADD(CURDATE(), INTERVAL 3 DAY), 'Rechazado', 279980.00, 6, 6)
ON DUPLICATE KEY UPDATE `Estado` = VALUES(`Estado`), `FechaVencimiento` = VALUES(`FechaVencimiento`), `Total` = VALUES(`Total`);

INSERT INTO `cotizaciondetalle` (`IdCotizacionDetalle`, `IdCotizacion`, `IdVariante`, `Cantidad`, `PrecioUnitario`) VALUES
-- Cotización 1 (Clínica Estética DermoSalud SpA - Aceptada)
(1, 1, 1, 8, 23990.00),
(2, 1, 3, 8, 14990.00),
-- Cotización 2 (Farmacias Dermocare Chile Ltda. - Aceptada)
(3, 2, 2, 10, 36990.00),
(4, 2, 4, 5, 16990.00),
(5, 2, 7, 2, 31990.00),
(6, 2, 3, 1, 15950.00),
-- Cotización 3 (Centro Dermatológico SkinClinic Vitacura - Vigente, lista para convertir a venta)
(7, 3, 5, 6, 24990.00),
(8, 3, 6, 2, 38990.00),
(9, 3, 7, 1, 30970.00),
-- Cotización 4 (Distribuidora Belleza & Salud Sur S.A. - Vigente, lista para convertir a venta)
(10, 4, 1, 10, 23990.00),
(11, 4, 8, 8, 19490.00),
(12, 4, 9, 4, 21990.00),
(13, 4, 4, 1, 11050.00),
-- Cotización 5 (Camila Fernández - Vencida)
(14, 5, 10, 4, 23490.00),
(15, 5, 9, 3, 21990.00),
-- Cotización 6 (Botica Natural & Dermo Boutique - Rechazada)
(16, 6, 12, 2, 139990.00)
ON DUPLICATE KEY UPDATE `Cantidad` = VALUES(`Cantidad`), `PrecioUnitario` = VALUES(`PrecioUnitario`);

-- =========================================================================
-- SEED DATA: Ventas Históricas y del Mes Actual (Boletas, Facturas y Nota de Crédito)
-- =========================================================================
INSERT INTO `venta` (`IdVenta`, `TipoDocumento`, `Folio`, `Fecha`, `Neto`, `Iva`, `Descuento`, `Total`, `FormaPago`, `Estado`, `IdCliente`, `IdCotizacion`, `IdUsuario`, `IdVentaOrigen`) VALUES
-- Ventas de meses anteriores para el gráfico de tendencia de 6 meses
(1, 'Factura', 'FAC-001001', DATE_SUB(CURDATE(), INTERVAL 5 MONTH), 241933.00, 45967.00, 0.00, 287900.00, 'Contado', 'Emitida', 1, NULL, 2, NULL),
(2, 'Factura', 'FAC-001002', DATE_SUB(CURDATE(), INTERVAL 4 MONTH), 352840.00, 67040.00, 0.00, 419880.00, 'Credito', 'Emitida', 2, NULL, 2, NULL),
(3, 'Factura', 'FAC-001003', DATE_SUB(CURDATE(), INTERVAL 3 MONTH), 478824.00, 90976.00, 10000.00, 569800.00, 'Credito', 'Emitida', 3, NULL, 1, NULL),
(4, 'Boleta',  'BOL-001001', DATE_SUB(CURDATE(), INTERVAL 2 MONTH), 184790.00, 35110.00, 0.00, 219900.00, 'Contado', 'Emitida', 5, NULL, 6, NULL),
(5, 'Factura', 'FAC-001004', DATE_SUB(CURDATE(), INTERVAL 1 MONTH), 411639.00, 78211.00, 5000.00, 489850.00, 'Credito', 'Emitida', 4, NULL, 2, NULL),
-- Ventas del mes en curso
(6, 'Factura', 'FAC-001005', DATE_SUB(CURDATE(), INTERVAL 8 DAY), 262076.00, 49794.00, 0.00, 311870.00, 'Credito', 'Emitida', 1, 1, 2, NULL),
(7, 'Factura', 'FAC-001006', DATE_SUB(CURDATE(), INTERVAL 5 DAY), 449395.00, 85385.00, 0.00, 534780.00, 'Credito', 'Emitida', 2, 2, 2, NULL),
(8, 'Boleta',  'BOL-001002', DATE_SUB(CURDATE(), INTERVAL 3 DAY), 119286.00, 22664.00, 0.00, 141950.00, 'Contado', 'Emitida', 7, NULL, 6, NULL),
(9, 'Factura', 'FAC-001007', DATE_SUB(CURDATE(), INTERVAL 1 DAY), 386504.00, 73436.00, 0.00, 459940.00, 'Contado', 'Emitida', 6, NULL, 1, NULL),
-- Nota de Crédito de prueba asociada a la Venta #6
(10, 'Nota de Credito', 'NC-005001', CURDATE(), 37798.00, 7182.00, 0.00, 44980.00, 'Devolucion', 'Emitida', 1, NULL, 2, 6)
ON DUPLICATE KEY UPDATE
  `Folio` = VALUES(`Folio`),
  `Fecha` = VALUES(`Fecha`),
  `Neto` = VALUES(`Neto`),
  `Iva` = VALUES(`Iva`),
  `Total` = VALUES(`Total`),
  `FormaPago` = VALUES(`FormaPago`),
  `Estado` = VALUES(`Estado`);

INSERT INTO `ventadetalle` (`IdVentaDetalle`, `IdVenta`, `IdVariante`, `Cantidad`, `PrecioUnitario`, `Subtotal`) VALUES
-- Venta 1
(1, 1, 1, 10, 23990.00, 239900.00),
(2, 1, 3, 3, 16000.00, 48000.00),
-- Venta 2
(3, 2, 2, 8, 36990.00, 295920.00),
(4, 2, 5, 5, 24792.00, 123960.00),
-- Venta 3
(5, 3, 6, 10, 38990.00, 389900.00),
(6, 3, 8, 10, 18990.00, 189900.00),
-- Venta 4
(7, 4, 9, 10, 21990.00, 219900.00),
-- Venta 5
(8, 5, 12, 2, 139990.00, 279980.00),
(9, 5, 7, 5, 31990.00, 159950.00),
(10, 5, 5, 2, 27460.00, 54920.00),
-- Venta 6 (Factura FAC-001005)
(11, 6, 1, 8, 23990.00, 191920.00),
(12, 6, 3, 8, 14993.75, 119950.00),
-- Venta 7 (Factura FAC-001006)
(13, 7, 2, 10, 36990.00, 369900.00),
(14, 7, 4, 5, 16990.00, 84950.00),
(15, 7, 7, 2, 39965.00, 79930.00),
-- Venta 8 (Boleta BOL-001002)
(16, 8, 11, 3, 22490.00, 67470.00),
(17, 8, 10, 2, 23490.00, 46980.00),
(18, 8, 4, 1, 27500.00, 27500.00),
-- Venta 9 (Factura FAC-001007)
(19, 9, 12, 2, 139990.00, 279980.00),
(20, 9, 6, 4, 38990.00, 155960.00),
(21, 9, 1, 1, 24000.00, 24000.00),
-- Venta 10 (Nota de Crédito NC-005001 sobre Venta 6)
(22, 10, 3, 3, 14993.33, 44980.00)
ON DUPLICATE KEY UPDATE `Cantidad` = VALUES(`Cantidad`), `PrecioUnitario` = VALUES(`PrecioUnitario`), `Subtotal` = VALUES(`Subtotal`);

-- =========================================================================
-- SEED DATA: Cuentas por Cobrar de Clientes (RF-VEN-06 y RF-VEN-07)
-- =========================================================================
INSERT INTO `cuentascobrar` (`IdCuenta`, `IdVenta`, `FechaVence`, `MontoPendiente`, `EstadoPago`, `IdUsuario`) VALUES
(1, 2, DATE_SUB(CURDATE(), INTERVAL 60 DAY), 0.00, 'Pagado', 2),
(2, 3, DATE_SUB(CURDATE(), INTERVAL 30 DAY), 0.00, 'Pagado', 1),
(3, 5, DATE_ADD(CURDATE(), INTERVAL 10 DAY), 489850.00, 'Pendiente', 2),
(4, 6, DATE_ADD(CURDATE(), INTERVAL 22 DAY), 266890.00, 'Pendiente', 2),
(5, 7, DATE_ADD(CURDATE(), INTERVAL 40 DAY), 534780.00, 'Pendiente', 2)
ON DUPLICATE KEY UPDATE `MontoPendiente` = VALUES(`MontoPendiente`), `EstadoPago` = VALUES(`EstadoPago`);

-- =========================================================================
-- SEED DATA: Gestión y Seguimiento de Despachos (RF-VEN-08)
-- =========================================================================
INSERT INTO `despacho` (`IdDespacho`, `IdVenta`, `Estado`, `FechaEstimada`, `FechaEntrega`, `Tipo`, `Observaciones`, `IdUsuario`) VALUES
(1, 5, 'Entregado', DATE_SUB(CURDATE(), INTERVAL 25 DAY), DATE_SUB(CURDATE(), INTERVAL 26 DAY), 'Reparto Propio', 'Entregado conforme en recepción de clínica Vitacura', 4),
(2, 6, 'Entregado', DATE_SUB(CURDATE(), INTERVAL 6 DAY), DATE_SUB(CURDATE(), INTERVAL 6 DAY), 'Chilexpress', 'Recibido por Dra. Andrea Valenzuela (OT #994821)', 4),
(3, 7, 'En Ruta', DATE_ADD(CURDATE(), INTERVAL 1 DAY), NULL, 'Starken', 'Despacho prioritario refrigerado a sucursal Las Condes', 2),
(4, 8, 'En Preparacion', DATE_ADD(CURDATE(), INTERVAL 2 DAY), NULL, 'Blue Express', 'Embalaje reforzado para frascos de vidrio', 4),
(5, 9, 'Pendiente', DATE_ADD(CURDATE(), INTERVAL 3 DAY), NULL, 'Reparto Propio', 'Coordinar entrega horario mañana en Ñuñoa', 1)
ON DUPLICATE KEY UPDATE `Estado` = VALUES(`Estado`), `FechaEstimada` = VALUES(`FechaEstimada`), `FechaEntrega` = VALUES(`FechaEntrega`);

-- =========================================================================
-- SEED DATA: Período Contable Abierto y Plan de Cuentas Integral
-- =========================================================================
INSERT INTO `periodocontable` (`IdPeriodo`, `Nombre`, `FechaInicio`, `FechaFin`, `Estado`) VALUES
(1, 'Año Comercial Vigente', DATE_SUB(CURDATE(), INTERVAL 1 YEAR), DATE_ADD(CURDATE(), INTERVAL 1 YEAR), 'Abierto')
ON DUPLICATE KEY UPDATE `FechaInicio` = VALUES(`FechaInicio`), `FechaFin` = VALUES(`FechaFin`), `Estado` = 'Abierto';

INSERT INTO `cuentacontable` (`IdCuentaContable`, `Codigo`, `Nombre`, `Tipo`, `IdCuentaPadre`, `Nivel`, `Imputable`) VALUES
(1, '1101', 'Caja y Bancos', 'Activo', NULL, 1, 1),
(2, '1103', 'Clientes por Cobrar', 'Activo', NULL, 1, 1),
(3, '1105', 'Existencias e Inventario', 'Activo', NULL, 1, 1),
(4, '1109', 'IVA Crédito Fiscal', 'Activo', NULL, 1, 1),
(5, '2101', 'Proveedores por Pagar', 'Pasivo', NULL, 1, 1),
(6, '2108', 'IVA Débito Fiscal', 'Pasivo', NULL, 1, 1),
(7, '4101', 'Ingresos por Ventas', 'Resultado Ganancia', NULL, 1, 1),
(8, '5101', 'Costo de Ventas', 'Resultado Pérdida', NULL, 1, 1)
ON DUPLICATE KEY UPDATE `Nombre` = VALUES(`Nombre`), `Tipo` = VALUES(`Tipo`), `Imputable` = 1;

-- =========================================================================
-- STORED PROCEDURE: Cuentas por Pagar y Asiento Contable Automático (RF-COM-08 / RF-CON-05)
-- =========================================================================
DROP PROCEDURE IF EXISTS `usp_CrearCuentaPorPagar`;
DELIMITER $$
CREATE PROCEDURE `usp_CrearCuentaPorPagar`(IN p_IdRecepcion INT, IN p_IdUsuario INT)
BEGIN
    DECLARE v_IdLaboratorio INT;
    DECLARE v_NumeroOC VARCHAR(20);
    DECLARE v_RazonSocial VARCHAR(150);
    DECLARE v_FechaRec DATE;
    DECLARE v_Neto DECIMAL(18,2);
    DECLARE v_Total DECIMAL(18,2);
    DECLARE v_Iva DECIMAL(18,2);
    DECLARE v_IdPeriodo INT;
    DECLARE v_CtaExistencias INT;
    DECLARE v_CtaIva INT;
    DECLARE v_CtaProveedores INT;
    DECLARE v_IdAsiento INT;

    SELECT oc.IdLaboratorio,
           oc.NumeroOC,
           l.RazonSocial,
           r.FechaRecepcion,
           ROUND(SUM(d.Cantidad * d.CostoUnitario), 2),
           ROUND(SUM(d.Cantidad * d.CostoUnitario) * (1 + COALESCE(oc.Iva / NULLIF(oc.Neto, 0), 0)), 2)
    INTO v_IdLaboratorio, v_NumeroOC, v_RazonSocial, v_FechaRec, v_Neto, v_Total
    FROM recepcioncompra r
    INNER JOIN ordencompra oc ON oc.IdOC = r.IdOC
    INNER JOIN laboratorio l ON l.IdLaboratorio = oc.IdLaboratorio
    INNER JOIN detallerecepcion d ON d.IdRecepcion = r.IdRecepcion
    WHERE r.IdRecepcion = p_IdRecepcion
    GROUP BY r.IdRecepcion, oc.IdLaboratorio, oc.NumeroOC, l.RazonSocial, r.FechaRecepcion, oc.Iva, oc.Neto
    LIMIT 1;

    IF v_IdLaboratorio IS NULL OR v_Total IS NULL OR v_Total <= 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La recepción no tiene detalle valorizable para generar la Cuenta por Pagar.';
    END IF;

    SET v_Iva = ROUND(v_Total - v_Neto, 2);

    -- 1. Crear o actualizar Cuenta por Pagar (RF-COM-08 / RF-CON-05)
    INSERT INTO cuentaporpagar (IdRecepcion, IdLaboratorio, Monto, Estado, IdUsuario)
    VALUES (p_IdRecepcion, v_IdLaboratorio, v_Total, 'Pendiente', p_IdUsuario)
    ON DUPLICATE KEY UPDATE
        IdLaboratorio = VALUES(IdLaboratorio),
        Monto = VALUES(Monto);

    -- 2. Generar Asiento Contable automático de compra si no existe aún (RF-COM-08)
    IF NOT EXISTS (SELECT 1 FROM asientocontable WHERE Origen = 'Compra' AND IdOrigen = p_IdRecepcion) THEN
        SELECT IdPeriodo INTO v_IdPeriodo
        FROM periodocontable
        WHERE Estado = 'Abierto' AND v_FechaRec BETWEEN FechaInicio AND FechaFin
        ORDER BY FechaInicio DESC LIMIT 1;

        IF v_IdPeriodo IS NULL THEN
            SELECT IdPeriodo INTO v_IdPeriodo
            FROM periodocontable
            WHERE Estado = 'Abierto'
            ORDER BY FechaInicio DESC LIMIT 1;
        END IF;

        SELECT IdCuentaContable INTO v_CtaExistencias FROM cuentacontable WHERE Imputable = 1 AND Codigo = '1105' LIMIT 1;
        SELECT IdCuentaContable INTO v_CtaIva         FROM cuentacontable WHERE Imputable = 1 AND Codigo = '1109' LIMIT 1;
        SELECT IdCuentaContable INTO v_CtaProveedores FROM cuentacontable WHERE Imputable = 1 AND Codigo = '2101' LIMIT 1;

        IF v_IdPeriodo IS NOT NULL AND v_CtaExistencias IS NOT NULL AND v_CtaProveedores IS NOT NULL THEN
            INSERT INTO asientocontable (IdPeriodo, Fecha, Glosa, IdUsuario, Origen, IdOrigen)
            VALUES (
                v_IdPeriodo,
                v_FechaRec,
                LEFT(CONCAT('Compra Recepción REC-', LPAD(p_IdRecepcion, 4, '0'), ' · ', v_NumeroOC, ' (', v_RazonSocial, ')'), 255),
                p_IdUsuario,
                'Compra',
                p_IdRecepcion
            );
            SET v_IdAsiento = LAST_INSERT_ID();

            IF v_Iva > 0 AND v_CtaIva IS NOT NULL THEN
                INSERT INTO detalleasiento (IdAsiento, IdCuentaContable, Debe, Haber) VALUES (v_IdAsiento, v_CtaExistencias, v_Neto, 0);
                INSERT INTO detalleasiento (IdAsiento, IdCuentaContable, Debe, Haber) VALUES (v_IdAsiento, v_CtaIva, v_Iva, 0);
            ELSE
                INSERT INTO detalleasiento (IdAsiento, IdCuentaContable, Debe, Haber) VALUES (v_IdAsiento, v_CtaExistencias, v_Total, 0);
            END IF;

            INSERT INTO detalleasiento (IdAsiento, IdCuentaContable, Debe, Haber) VALUES (v_IdAsiento, v_CtaProveedores, 0, v_Total);
        END IF;
    END IF;
END $$
DELIMITER ;

CALL usp_CrearCuentaPorPagar(1, 5);

-- =========================================================================
-- STORED PROCEDURE: Descuento de Inventario por FEFO en Ventas (RF-VEN-05)
-- =========================================================================
DROP PROCEDURE IF EXISTS `usp_DescontarInventarioFEFO`;
DELIMITER $$
CREATE PROCEDURE `usp_DescontarInventarioFEFO`(
    IN p_IdVenta INT,
    IN p_IdVariante INT,
    IN p_IdBodega INT,
    IN p_Cantidad INT,
    IN p_PrecioUnitario DECIMAL(18,2),
    IN p_IdUsuario INT,
    OUT p_CostoTotalConsumido DECIMAL(18,2)
)
BEGIN
    DECLARE v_Pendiente INT;
    DECLARE v_StockBodega INT;
    DECLARE v_StockReservado INT;
    DECLARE v_IdLote INT;
    DECLARE v_CantDisp INT;
    DECLARE v_CostoUnit DECIMAL(18,2);
    DECLARE v_Tomar INT;
    DECLARE v_DetalleId INT;
    DECLARE v_FinCursor INT DEFAULT 0;

    -- Cursor ordenado según FEFO (Fecha de Vencimiento más próxima primero)
    DECLARE curLotes CURSOR FOR
        SELECT IdLote, CantidadDisponible, CostoUnitario
        FROM lote
        WHERE IdVariante = p_IdVariante
          AND IdBodega = p_IdBodega
          AND Estado = 'Disponible'
          AND CantidadDisponible > 0
          AND (FechaVencimiento IS NULL OR FechaVencimiento >= CURDATE())
        ORDER BY (FechaVencimiento IS NULL), FechaVencimiento ASC, IdLote ASC
        FOR UPDATE;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_FinCursor = 1;

    SET p_CostoTotalConsumido = 0.00;
    SET v_Pendiente = p_Cantidad;

    IF p_Cantidad <= 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La cantidad a descontar debe ser mayor a cero.';
    END IF;

    -- 1. Validar existencias generales en la bodega
    SELECT COALESCE(StockActual, 0), COALESCE(StockReservado, 0)
    INTO v_StockBodega, v_StockReservado
    FROM inventario
    WHERE IdVariante = p_IdVariante AND IdBodega = p_IdBodega
    FOR UPDATE;

    IF v_StockBodega IS NULL OR (v_StockBodega - v_StockReservado) < p_Cantidad THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Stock insuficiente en la bodega seleccionada para cumplir con la venta.';
    END IF;

    -- 2. Consumir lotes aplicando criterio FEFO
    OPEN curLotes;
    bucle_lotes: LOOP
        FETCH curLotes INTO v_IdLote, v_CantDisp, v_CostoUnit;
        IF v_FinCursor = 1 OR v_Pendiente <= 0 THEN
            LEAVE bucle_lotes;
        END IF;

        SET v_Tomar = LEAST(v_Pendiente, v_CantDisp);

        -- Insertar detalle de venta asociado al lote
        INSERT INTO ventadetalle (IdVenta, IdVariante, Cantidad, PrecioUnitario, Subtotal)
        VALUES (p_IdVenta, p_IdVariante, v_Tomar, p_PrecioUnitario, ROUND(v_Tomar * p_PrecioUnitario, 2));
        SET v_DetalleId = LAST_INSERT_ID();

        -- Actualizar lote
        UPDATE lote
        SET CantidadDisponible = CantidadDisponible - v_Tomar,
            Estado = IF(CantidadDisponible - v_Tomar <= 0, 'Agotado', Estado)
        WHERE IdLote = v_IdLote;

        -- Registrar movimiento de inventario (Salida por Venta)
        INSERT INTO movimientoinventario
            (IdLote, IdBodega, IdTipoMovimiento, IdUsuario, Cantidad, StockAnterior, StockPosterior, Referencia, Observacion, Origen, IdDetalleOrigen)
        SELECT v_IdLote, p_IdBodega, IdTipoMovimiento, p_IdUsuario, v_Tomar, v_StockBodega, (v_StockBodega - v_Tomar),
               CONCAT('Venta #', p_IdVenta), 'Descuento automático FEFO (RF-VEN-05)', 'Salida', v_DetalleId
        FROM tipomovimiento
        WHERE Nombre = 'Salida'
        LIMIT 1;

        SET v_StockBodega = v_StockBodega - v_Tomar;
        SET p_CostoTotalConsumido = p_CostoTotalConsumido + ROUND(v_Tomar * COALESCE(v_CostoUnit, 0), 2);
        SET v_Pendiente = v_Pendiente - v_Tomar;
    END LOOP bucle_lotes;
    CLOSE curLotes;

    IF v_Pendiente > 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No hay suficientes unidades en lotes vigentes disponibles para completar la salida FEFO.';
    END IF;

    -- 3. Actualizar tabla global de Inventario por bodega
    UPDATE inventario
    SET StockActual = v_StockBodega, FechaActualizada = NOW()
    WHERE IdVariante = p_IdVariante AND IdBodega = p_IdBodega;

    -- 4. Actualizar stock consolidado en VarianteProducto
    UPDATE varianteproducto
    SET StockTotal = (SELECT COALESCE(SUM(StockActual), 0) FROM inventario WHERE IdVariante = p_IdVariante)
    WHERE IdVariante = p_IdVariante;

END $$
DELIMITER ;

/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;
/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;
