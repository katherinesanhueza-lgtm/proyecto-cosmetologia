CREATE DATABASE IF NOT EXISTS ERP_Dermocosmetica CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
USE ERP_Dermocosmetica;
-- MySQL dump 10.13  Distrib 8.0.46, for Win64 (x86_64)
--
-- Host: 127.0.0.1    Database: erp_dermocosmetica
-- ------------------------------------------------------
-- Server version	8.0.46

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8 */;
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
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `asientocontable`
--

LOCK TABLES `asientocontable` WRITE;
/*!40000 ALTER TABLE `asientocontable` DISABLE KEYS */;
/*!40000 ALTER TABLE `asientocontable` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `bodega`
--

DROP TABLE IF EXISTS `bodega`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `bodega` (
  `IdBodega` int NOT NULL AUTO_INCREMENT,
  `Nombre` varchar(100) NOT NULL,
  `Ubicacion` varchar(150) DEFAULT NULL,
  `Activo` tinyint(1) DEFAULT '1',
  PRIMARY KEY (`IdBodega`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `bodega`
--

LOCK TABLES `bodega` WRITE;
/*!40000 ALTER TABLE `bodega` DISABLE KEYS */;
/*!40000 ALTER TABLE `bodega` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `categoria`
--

DROP TABLE IF EXISTS `categoria`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `categoria` (
  `IdCategoria` int NOT NULL AUTO_INCREMENT,
  `Nombre` varchar(100) NOT NULL,
  `Descripcion` varchar(255) DEFAULT NULL,
  `Activo` tinyint(1) DEFAULT '1',
  PRIMARY KEY (`IdCategoria`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `categoria`
--

LOCK TABLES `categoria` WRITE;
/*!40000 ALTER TABLE `categoria` DISABLE KEYS */;
/*!40000 ALTER TABLE `categoria` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `cliente`
--

DROP TABLE IF EXISTS `cliente`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `cliente` (
  `IdCliente` int NOT NULL AUTO_INCREMENT,
  `Rut` varchar(20) NOT NULL,
  `Nombre` varchar(150) NOT NULL,
  `Categoria` varchar(50) DEFAULT NULL,
  `Correo` varchar(100) DEFAULT NULL,
  `Telefono` varchar(30) DEFAULT NULL,
  PRIMARY KEY (`IdCliente`),
  UNIQUE KEY `Rut` (`Rut`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cliente`
--

LOCK TABLES `cliente` WRITE;
/*!40000 ALTER TABLE `cliente` DISABLE KEYS */;
/*!40000 ALTER TABLE `cliente` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `cotizacion`
--

DROP TABLE IF EXISTS `cotizacion`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cotizacion`
--

LOCK TABLES `cotizacion` WRITE;
/*!40000 ALTER TABLE `cotizacion` DISABLE KEYS */;
/*!40000 ALTER TABLE `cotizacion` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `cotizaciondetalle`
--

DROP TABLE IF EXISTS `cotizaciondetalle`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
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
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cotizaciondetalle`
--

LOCK TABLES `cotizaciondetalle` WRITE;
/*!40000 ALTER TABLE `cotizaciondetalle` DISABLE KEYS */;
/*!40000 ALTER TABLE `cotizaciondetalle` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `cotizacionimportacion`
--

DROP TABLE IF EXISTS `cotizacionimportacion`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
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
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cotizacionimportacion`
--

LOCK TABLES `cotizacionimportacion` WRITE;
/*!40000 ALTER TABLE `cotizacionimportacion` DISABLE KEYS */;
/*!40000 ALTER TABLE `cotizacionimportacion` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `cuentacontable`
--

DROP TABLE IF EXISTS `cuentacontable`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `cuentacontable` (
  `IdCuentaContable` int NOT NULL AUTO_INCREMENT,
  `Codigo` varchar(50) NOT NULL,
  `Nombre` varchar(100) NOT NULL,
  `Tipo` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`IdCuentaContable`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cuentacontable`
--

LOCK TABLES `cuentacontable` WRITE;
/*!40000 ALTER TABLE `cuentacontable` DISABLE KEYS */;
/*!40000 ALTER TABLE `cuentacontable` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `cuentaporpagar`
--

DROP TABLE IF EXISTS `cuentaporpagar`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
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
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cuentaporpagar`
--

LOCK TABLES `cuentaporpagar` WRITE;
/*!40000 ALTER TABLE `cuentaporpagar` DISABLE KEYS */;
/*!40000 ALTER TABLE `cuentaporpagar` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `cuentascobrar`
--

DROP TABLE IF EXISTS `cuentascobrar`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
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
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cuentascobrar`
--

LOCK TABLES `cuentascobrar` WRITE;
/*!40000 ALTER TABLE `cuentascobrar` DISABLE KEYS */;
/*!40000 ALTER TABLE `cuentascobrar` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `declaracioniva`
--

DROP TABLE IF EXISTS `declaracioniva`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
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
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `declaracioniva`
--

LOCK TABLES `declaracioniva` WRITE;
/*!40000 ALTER TABLE `declaracioniva` DISABLE KEYS */;
/*!40000 ALTER TABLE `declaracioniva` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `despacho`
--

DROP TABLE IF EXISTS `despacho`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `despacho`
--

LOCK TABLES `despacho` WRITE;
/*!40000 ALTER TABLE `despacho` DISABLE KEYS */;
/*!40000 ALTER TABLE `despacho` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `detalleasiento`
--

DROP TABLE IF EXISTS `detalleasiento`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
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
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `detalleasiento`
--

LOCK TABLES `detalleasiento` WRITE;
/*!40000 ALTER TABLE `detalleasiento` DISABLE KEYS */;
/*!40000 ALTER TABLE `detalleasiento` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `detallecotizacion`
--

DROP TABLE IF EXISTS `detallecotizacion`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
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
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `detallecotizacion`
--

LOCK TABLES `detallecotizacion` WRITE;
/*!40000 ALTER TABLE `detallecotizacion` DISABLE KEYS */;
/*!40000 ALTER TABLE `detallecotizacion` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `detalleordencompra`
--

DROP TABLE IF EXISTS `detalleordencompra`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
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
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `detalleordencompra`
--

LOCK TABLES `detalleordencompra` WRITE;
/*!40000 ALTER TABLE `detalleordencompra` DISABLE KEYS */;
/*!40000 ALTER TABLE `detalleordencompra` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `detallerecepcion`
--

DROP TABLE IF EXISTS `detallerecepcion`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
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
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `detallerecepcion`
--

LOCK TABLES `detallerecepcion` WRITE;
/*!40000 ALTER TABLE `detallerecepcion` DISABLE KEYS */;
/*!40000 ALTER TABLE `detallerecepcion` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `devolucionproveedor`
--

DROP TABLE IF EXISTS `devolucionproveedor`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
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
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `devolucionproveedor`
--

LOCK TABLES `devolucionproveedor` WRITE;
/*!40000 ALTER TABLE `devolucionproveedor` DISABLE KEYS */;
/*!40000 ALTER TABLE `devolucionproveedor` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `inventario`
--

DROP TABLE IF EXISTS `inventario`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
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
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `inventario`
--

LOCK TABLES `inventario` WRITE;
/*!40000 ALTER TABLE `inventario` DISABLE KEYS */;
/*!40000 ALTER TABLE `inventario` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `laboratorio`
--

DROP TABLE IF EXISTS `laboratorio`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
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
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `laboratorio`
--

LOCK TABLES `laboratorio` WRITE;
/*!40000 ALTER TABLE `laboratorio` DISABLE KEYS */;
/*!40000 ALTER TABLE `laboratorio` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `lote`
--

DROP TABLE IF EXISTS `lote`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `lote`
--

LOCK TABLES `lote` WRITE;
/*!40000 ALTER TABLE `lote` DISABLE KEYS */;
/*!40000 ALTER TABLE `lote` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `marca`
--

DROP TABLE IF EXISTS `marca`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `marca` (
  `IdMarca` int NOT NULL AUTO_INCREMENT,
  `Nombre` varchar(100) NOT NULL,
  `Descripcion` varchar(255) DEFAULT NULL,
  `Activo` tinyint(1) DEFAULT '1',
  PRIMARY KEY (`IdMarca`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `marca`
--

LOCK TABLES `marca` WRITE;
/*!40000 ALTER TABLE `marca` DISABLE KEYS */;
/*!40000 ALTER TABLE `marca` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `merma`
--

DROP TABLE IF EXISTS `merma`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
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
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `merma`
--

LOCK TABLES `merma` WRITE;
/*!40000 ALTER TABLE `merma` DISABLE KEYS */;
/*!40000 ALTER TABLE `merma` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `movimientoinventario`
--

DROP TABLE IF EXISTS `movimientoinventario`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `movimientoinventario`
--

LOCK TABLES `movimientoinventario` WRITE;
/*!40000 ALTER TABLE `movimientoinventario` DISABLE KEYS */;
/*!40000 ALTER TABLE `movimientoinventario` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `ordencompra`
--

DROP TABLE IF EXISTS `ordencompra`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
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
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ordencompra`
--

LOCK TABLES `ordencompra` WRITE;
/*!40000 ALTER TABLE `ordencompra` DISABLE KEYS */;
/*!40000 ALTER TABLE `ordencompra` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `pagoproveedor`
--

DROP TABLE IF EXISTS `pagoproveedor`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
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
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `pagoproveedor`
--

LOCK TABLES `pagoproveedor` WRITE;
/*!40000 ALTER TABLE `pagoproveedor` DISABLE KEYS */;
/*!40000 ALTER TABLE `pagoproveedor` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `periodocontable`
--

DROP TABLE IF EXISTS `periodocontable`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `periodocontable` (
  `IdPeriodo` int NOT NULL AUTO_INCREMENT,
  `Nombre` varchar(50) NOT NULL,
  `FechaInicio` date NOT NULL,
  `FechaFin` date NOT NULL,
  `Estado` varchar(20) DEFAULT NULL,
  PRIMARY KEY (`IdPeriodo`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `periodocontable`
--

LOCK TABLES `periodocontable` WRITE;
/*!40000 ALTER TABLE `periodocontable` DISABLE KEYS */;
/*!40000 ALTER TABLE `periodocontable` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `producto`
--

DROP TABLE IF EXISTS `producto`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
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
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `producto`
--

LOCK TABLES `producto` WRITE;
/*!40000 ALTER TABLE `producto` DISABLE KEYS */;
/*!40000 ALTER TABLE `producto` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `recepcioncompra`
--

DROP TABLE IF EXISTS `recepcioncompra`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
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
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `recepcioncompra`
--

LOCK TABLES `recepcioncompra` WRITE;
/*!40000 ALTER TABLE `recepcioncompra` DISABLE KEYS */;
/*!40000 ALTER TABLE `recepcioncompra` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `rol`
--

DROP TABLE IF EXISTS `rol`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `rol` (
  `IdRol` int NOT NULL AUTO_INCREMENT,
  `Nombre` varchar(50) NOT NULL,
  PRIMARY KEY (`IdRol`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `rol`
--

LOCK TABLES `rol` WRITE;
/*!40000 ALTER TABLE `rol` DISABLE KEYS */;
INSERT INTO `rol` VALUES (1,'Administrador'),(2,'Vendedor'),(3,'Comprador'),(4,'Bodeguero'),(5,'Contador');
/*!40000 ALTER TABLE `rol` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `tipomovimiento`
--

DROP TABLE IF EXISTS `tipomovimiento`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tipomovimiento` (
  `IdTipoMovimiento` int NOT NULL AUTO_INCREMENT,
  `Nombre` varchar(100) NOT NULL,
  `Naturaleza` varchar(50) DEFAULT NULL,
  `Descripcion` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`IdTipoMovimiento`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tipomovimiento`
--

LOCK TABLES `tipomovimiento` WRITE;
/*!40000 ALTER TABLE `tipomovimiento` DISABLE KEYS */;
/*!40000 ALTER TABLE `tipomovimiento` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `usuario`
--

DROP TABLE IF EXISTS `usuario`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
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
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `usuario`
--

LOCK TABLES `usuario` WRITE;
/*!40000 ALTER TABLE `usuario` DISABLE KEYS */;
INSERT INTO `usuario` VALUES (1,1,'Camilo Admin','admin@dermo.cl','1234','Administrador',1),(2,2,'Raul Martinez','raul1@dermo.cl','1234','Vendedor',1),(3,3,'Javiera Rail (Compras)','comprador@dermo.cl','1234','Comprador',1),(4,4,'Bodeguero Central','bodega@dermo.cl','1234','Bodeguero',1),(5,5,'Contador General','contador@dermo.cl','1234','Contador',1);
/*!40000 ALTER TABLE `usuario` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `varianteproducto`
--

DROP TABLE IF EXISTS `varianteproducto`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
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
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `varianteproducto`
--

LOCK TABLES `varianteproducto` WRITE;
/*!40000 ALTER TABLE `varianteproducto` DISABLE KEYS */;
/*!40000 ALTER TABLE `varianteproducto` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `venta`
--

DROP TABLE IF EXISTS `venta`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `venta`
--

LOCK TABLES `venta` WRITE;
/*!40000 ALTER TABLE `venta` DISABLE KEYS */;
/*!40000 ALTER TABLE `venta` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `ventadetalle`
--

DROP TABLE IF EXISTS `ventadetalle`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
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
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ventadetalle`
--

LOCK TABLES `ventadetalle` WRITE;
/*!40000 ALTER TABLE `ventadetalle` DISABLE KEYS */;
/*!40000 ALTER TABLE `ventadetalle` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-10-03 20:34:53

-- =========================================================================
-- TABLA: configuracionglobal (Parámetros dinámicos de IVA y Firmas)
-- =========================================================================
DROP TABLE IF EXISTS configuracionglobal;
CREATE TABLE configuracionglobal (
  IdConfiguracion int NOT NULL AUTO_INCREMENT,
  Clave varchar(50) NOT NULL UNIQUE,
  Valor varchar(255) NOT NULL,
  Descripcion varchar(255) DEFAULT NULL,
  FechaModificacion datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (IdConfiguracion)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

INSERT INTO configuracionglobal (Clave, Valor, Descripcion) VALUES 
('TasaIva', '0.19', 'Tasa general de IVA en Chile (RF-COM-04)'),
('NombreJefeCompras', 'Javiera Rail Astudillo', 'Firma oficial Jefatura de Compras'),
('NombreJefeVentas', 'Camilo Rodríguez Saldaña', 'Firma oficial Jefatura de Ventas'),
('NombreJefeInventario', 'Katherine Sanhueza Hernández', 'Firma oficial Jefatura de Bodega'),
('NombreContador', 'Contador General', 'Firma oficial Contabilidad y Comprobantes de Pago')
ON DUPLICATE KEY UPDATE Valor = VALUES(Valor);

-- =========================================================================
-- SEED DATA: Roles del sistema (RBAC)
-- =========================================================================
INSERT INTO rol (IdRol, Nombre) VALUES 
(1, 'Administrador'),
(2, 'Vendedor'),
(3, 'Comprador'),
(4, 'Bodeguero'),
(5, 'Contador')
ON DUPLICATE KEY UPDATE Nombre = VALUES(Nombre);

-- =========================================================================
-- SEED DATA: Usuarios con acceso a cada módulo (Password: 1234)
-- =========================================================================
INSERT INTO usuario (IdUsuario, IdRol, Nombre, Correo, Password, Rol, Activo) VALUES 
(1, 1, 'Camilo Admin', 'admin@dermo.cl', '1234', 'Administrador', 1),
(2, 2, 'Raul Martinez', 'raul1@dermo.cl', '1234', 'Vendedor', 1),
(3, 3, 'Javiera Rail (Compras)', 'comprador@dermo.cl', '1234', 'Comprador', 1),
(4, 4, 'Bodeguero Central', 'bodega@dermo.cl', '1234', 'Bodeguero', 1),
(5, 5, 'Contador General', 'contador@dermo.cl', '1234', 'Contador', 1)
ON DUPLICATE KEY UPDATE Password = VALUES(Password), Activo = VALUES(Activo);

-- =========================================================================
-- SEED DATA: Laboratorios y Proveedores
-- =========================================================================
INSERT INTO laboratorio (IdLaboratorio, Rut, RazonSocial, Marca, Pais, Contacto, Email, Telefono, DiasPago, Activo) VALUES 
(1, '77.234.567-9', 'ISDIN Chile S.A.', 'ISDIN', 'Chile', 'Carlos Pérez', 'contacto@isdin.cl', '+56911223344', 30, 1),
(2, '76.111.222-5', 'L''Oréal Chile S.A.', 'L''Oréal Paris / CeraVe', 'Chile', 'María López', 'contacto@loreal.cl', '+56922334455', 60, 1),
(3, '78.444.555-K', 'La Roche-Posay Chile', 'La Roche-Posay', 'Chile', 'Ana Gómez', 'contacto@laroche.cl', '+56933445566', 45, 1),
(4, '79.888.999-1', 'Eucerin Beiersdorf S.A.', 'Eucerin', 'Chile', 'Felipe Soto', 'contacto@eucerin.cl', '+56944556677', 30, 1)
ON DUPLICATE KEY UPDATE Activo = 1;

-- =========================================================================
-- SEED DATA: Categorías de Cosmecéutica
-- =========================================================================
INSERT INTO categoria (IdCategoria, Nombre, Descripcion, Activo) VALUES 
(1, 'Protección Solar', 'Fotoprotectores solares faciales y corporales dermatológicos', 1),
(2, 'Cuidado Facial', 'Sérums, hidratantes y tratamientos anti-edad', 1),
(3, 'Limpieza Dermo', 'Geles limpiadores dermatológicos y aguas micelares', 1)
ON DUPLICATE KEY UPDATE Activo = 1;

-- =========================================================================
-- SEED DATA: Productos e Insumos
-- =========================================================================
INSERT INTO producto (IdProducto, IdCategoria, Nombre, Descripcion, Activo) VALUES 
(1, 1, 'Fusion Water SPF 50', 'Fotoprotector solar facial textura ultraligera', 1),
(2, 2, 'Sérum Hyalu B5', 'Sérum anti-arrugas reparador con ácido hialurónico', 1),
(3, 3, 'Gel Limpiador Espumoso', 'Limpiador dermatológico para piel normal a grasa', 1),
(4, 2, 'Cicalfate+ Crema', 'Crema reparadora y protectora calmante', 1)
ON DUPLICATE KEY UPDATE Activo = 1;

-- =========================================================================
-- SEED DATA: Variantes de Producto con Costo Promedio y SKU
-- =========================================================================
INSERT INTO varianteproducto (IdVariante, IdProducto, Sku, NombreVariante, Presentacion, CostoPromedio, PrecioVenta, StockTotal, Activo) VALUES 
(1, 1, 'ISD-FW-50ML', 'Frasco 50ml', 'Frasco 50ml', 15900.00, 22990.00, 20, 1),
(2, 2, 'LRP-HB5-30ML', 'Gotero 30ml', 'Gotero 30ml', 24500.00, 34990.00, 0, 1),
(3, 3, 'CER-GEL-236ML', 'Dispensador 236ml', 'Dispensador 236ml', 7400.00, 12990.00, 10, 1),
(4, 4, 'AVE-CIC-40ML', 'Tubo 40ml', 'Tubo 40ml', 11200.00, 16490.00, 0, 1)
ON DUPLICATE KEY UPDATE CostoPromedio = VALUES(CostoPromedio);

-- =========================================================================
-- SEED DATA: Órdenes de Compra de Prueba
-- =========================================================================
INSERT INTO ordencompra (IdOC, NumeroOC, IdLaboratorio, IdCotizacion, Fecha, FechaEsperada, Estado, Neto, Iva, Total, IdUsuario) VALUES 
(1, 'OC-2026-0001', 2, NULL, '2026-10-15', '2026-10-30', 'Recibida', 392000.00, 74480.00, 466480.00, 3),
(2, 'OC-2026-0002', 1, NULL, '2026-10-20', '2026-11-05', 'Emitida', 298000.00, 56620.00, 354620.00, 3)
ON DUPLICATE KEY UPDATE Estado = VALUES(Estado);

-- =========================================================================
-- SEED DATA: Detalle de Órdenes de Compra
-- =========================================================================
INSERT INTO detalleordencompra (IdDetalleOC, IdOC, IdVariante, CantidadPedida, CantidadRecibida, CostoUnitario) VALUES 
(1, 1, 1, 20, 20, 15900.00),
(2, 1, 3, 10, 10, 7400.00),
(3, 2, 1, 15, 0, 15900.00),
(4, 2, 2, 5, 0, 11900.00)
ON DUPLICATE KEY UPDATE CantidadRecibida = VALUES(CantidadRecibida);

-- =========================================================================
-- SEED DATA: Recepciones de Mercadería
-- =========================================================================
INSERT INTO recepcioncompra (IdRecepcion, IdOC, GuiaDespacho, FechaRecepcion, Estado, IdUsuario) VALUES 
(1, 1, 'GD-884920', '2026-10-28', 'Aprobada', 4)
ON DUPLICATE KEY UPDATE Estado = VALUES(Estado);

-- =========================================================================
-- SEED DATA: Detalle de Recepción
-- =========================================================================
INSERT INTO detallerecepcion (IdDetalleRec, IdRecepcion, IdDetalleOC, IdVariante, NumeroLote, FechaVencimiento, Cantidad, CostoUnitario) VALUES 
(1, 1, 1, 1, 'LOT-ISD-2026A', '2028-10-28', 20, 15900.00),
(2, 1, 2, 3, 'LOT-CER-2026B', '2028-11-15', 10, 7400.00)
ON DUPLICATE KEY UPDATE Cantidad = VALUES(Cantidad);

-- =========================================================================
-- SEED DATA: Lotes en Bodega (FEFO)
-- =========================================================================
INSERT INTO lote (IdLote, IdVariante, NumeroLote, FechaIngreso, FechaVencimiento, CostoUnitario, CantidadInicial, CantidadDisponible, Estado) VALUES 
(1, 1, 'LOT-ISD-2026A', '2026-10-28', '2028-10-28', 15900.00, 20, 20, 'Disponible'),
(2, 3, 'LOT-CER-2026B', '2026-10-28', '2028-11-15', 7400.00, 10, 10, 'Disponible')
ON DUPLICATE KEY UPDATE CantidadDisponible = VALUES(CantidadDisponible);


-- =========================================================================
-- EXTENSIONES Y MIGRACIONES: Inventario, Ventas, Contabilidad y Cuentas por Pagar
-- =========================================================================

-- 1. Inventario y Bodega (001_inventario.sql)
ALTER TABLE lote ADD COLUMN IF NOT EXISTS IdBodega INT NULL;
ALTER TABLE movimientoinventario ADD COLUMN IF NOT EXISTS IdBodega INT NULL;
ALTER TABLE movimientoinventario ADD COLUMN IF NOT EXISTS Origen VARCHAR(20) NULL;
ALTER TABLE movimientoinventario ADD COLUMN IF NOT EXISTS IdDetalleOrigen INT NULL;

INSERT INTO tipomovimiento (Nombre, Naturaleza, Descripcion)
SELECT 'Entrada', 'Entrada', 'Recepción de compra' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM tipomovimiento WHERE Nombre = 'Entrada');

INSERT INTO tipomovimiento (Nombre, Naturaleza, Descripcion)
SELECT 'Salida', 'Salida', 'Salida por venta' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM tipomovimiento WHERE Nombre = 'Salida');

INSERT INTO tipomovimiento (Nombre, Naturaleza, Descripcion)
SELECT 'Ajuste positivo', 'Entrada', 'Diferencia justificada de inventario' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM tipomovimiento WHERE Nombre = 'Ajuste positivo');

INSERT INTO tipomovimiento (Nombre, Naturaleza, Descripcion)
SELECT 'Ajuste negativo', 'Salida', 'Pérdida, daño o vencimiento justificado' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM tipomovimiento WHERE Nombre = 'Ajuste negativo');

-- 2. Ventas y Notas de Crédito (003_ventas.sql)
ALTER TABLE venta ADD COLUMN IF NOT EXISTS IdVentaOrigen INT NULL;

-- 3. Contabilidad Integral (004_contabilidad_mysql.sql)
ALTER TABLE cuentacontable ADD COLUMN IF NOT EXISTS IdCuentaPadre INT NULL;
ALTER TABLE cuentacontable ADD COLUMN IF NOT EXISTS Nivel INT NOT NULL DEFAULT 1;
ALTER TABLE cuentacontable ADD COLUMN IF NOT EXISTS Imputable BOOLEAN NOT NULL DEFAULT TRUE;

ALTER TABLE asientocontable ADD COLUMN IF NOT EXISTS IdAsientoRevertido INT NULL;
ALTER TABLE asientocontable ADD COLUMN IF NOT EXISTS FechaRegistro DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP;
ALTER TABLE asientocontable ADD COLUMN IF NOT EXISTS Origen VARCHAR(20) NULL;
ALTER TABLE asientocontable ADD COLUMN IF NOT EXISTS IdOrigen INT NULL;

-- 4. Período Contable y Plan de Cuentas Base (005_cuentas_por_pagar_sp.sql)
INSERT INTO periodocontable (Nombre, FechaInicio, FechaFin, Estado)
SELECT 'Año Comercial 2026', '2026-01-01', '2026-12-31', 'Abierto'
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM periodocontable WHERE Estado = 'Abierto');

INSERT IGNORE INTO cuentacontable (Codigo, Nombre, Tipo, IdCuentaPadre, Nivel, Imputable) VALUES
('1101', 'Caja y Bancos', 'Activo', NULL, 1, 1),
('1105', 'Existencias e Inventario', 'Activo', NULL, 1, 1),
('1109', 'IVA Crédito Fiscal', 'Activo', NULL, 1, 1),
('2101', 'Proveedores por Pagar', 'Pasivo', NULL, 1, 1);

-- 5. Stored Procedure: Cuentas por Pagar y Asiento Contable Automático (RF-COM-08 / RF-CON-05)
DROP PROCEDURE IF EXISTS usp_CrearCuentaPorPagar;
DELIMITER $$
CREATE PROCEDURE usp_CrearCuentaPorPagar(IN p_IdRecepcion INT, IN p_IdUsuario INT)
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

-- 6. Sincronizar cuenta por pagar y asiento contable de la recepción de prueba existente
CALL usp_CrearCuentaPorPagar(1, 5);
-- =========================================================================
-- MIGRACIÃ“N 006: Requerimientos Funcionales del MÃ³dulo de Ventas (RF-VEN-01 al RF-VEN-10)
-- Dermo ERP - CosmecÃ©utica y DermocosmÃ©tica
-- =========================================================================

-- 1. RF-VEN-01 y RF-VEN-07: AmpliaciÃ³n de la tabla Cliente (Giro, DirecciÃ³n, Contacto, LÃ­mites de CrÃ©dito, Activo)
ALTER TABLE `cliente` ADD COLUMN IF NOT EXISTS `RazonSocial` VARCHAR(150) NULL;
ALTER TABLE `cliente` ADD COLUMN IF NOT EXISTS `Giro` VARCHAR(150) NULL;
ALTER TABLE `cliente` ADD COLUMN IF NOT EXISTS `Direccion` VARCHAR(200) NULL;
ALTER TABLE `cliente` ADD COLUMN IF NOT EXISTS `Contacto` VARCHAR(100) NULL;
ALTER TABLE `cliente` ADD COLUMN IF NOT EXISTS `LimiteCredito` DECIMAL(18,2) NOT NULL DEFAULT 0.00;
ALTER TABLE `cliente` ADD COLUMN IF NOT EXISTS `DiasCredito` INT NOT NULL DEFAULT 0;
ALTER TABLE `cliente` ADD COLUMN IF NOT EXISTS `Activo` TINYINT(1) NOT NULL DEFAULT 1;

-- Actualizar RazonSocial con el Nombre existente si estÃ¡ vacÃ­a
UPDATE `cliente` SET `RazonSocial` = `Nombre` WHERE `RazonSocial` IS NULL OR `RazonSocial` = '';

-- 2. RF-VEN-02: PerÃ­odo de Validez para Cotizaciones / Presupuestos
ALTER TABLE `cotizacion` ADD COLUMN IF NOT EXISTS `FechaVencimiento` DATE NULL;

-- 3. RF-VEN-03: Folio, Descuento, Neto, IVA y Forma de Pago en Venta
ALTER TABLE `venta` ADD COLUMN IF NOT EXISTS `Folio` VARCHAR(50) NULL;
ALTER TABLE `venta` ADD COLUMN IF NOT EXISTS `Neto` DECIMAL(18,2) NOT NULL DEFAULT 0.00;
ALTER TABLE `venta` ADD COLUMN IF NOT EXISTS `Iva` DECIMAL(18,2) NOT NULL DEFAULT 0.00;
ALTER TABLE `venta` ADD COLUMN IF NOT EXISTS `Descuento` DECIMAL(18,2) NOT NULL DEFAULT 0.00;
ALTER TABLE `venta` ADD COLUMN IF NOT EXISTS `FormaPago` VARCHAR(50) NOT NULL DEFAULT 'Contado';
ALTER TABLE `venta` ADD COLUMN IF NOT EXISTS `IdVentaOrigen` INT NULL;

-- 4. RF-VEN-08: GestiÃ³n de Despachos y Registro de Entregas
ALTER TABLE `despacho` ADD COLUMN IF NOT EXISTS `FechaEntrega` DATE NULL;
ALTER TABLE `despacho` ADD COLUMN IF NOT EXISTS `Observaciones` VARCHAR(255) NULL;

-- 5. RF-VEN-06: Plan de Cuentas Contable para Ventas (cuentacontable)
INSERT IGNORE INTO `cuentacontable` (`Codigo`, `Nombre`, `Tipo`, `IdCuentaPadre`, `Nivel`, `Imputable`) VALUES
('1103', 'Clientes por Cobrar', 'Activo', NULL, 1, 1),
('2108', 'IVA DÃ©bito Fiscal', 'Pasivo', NULL, 1, 1),
('4101', 'Ingresos por Ventas', 'Resultado Ganancia', NULL, 1, 1),
('5101', 'Costo de Ventas', 'Resultado PÃ©rdida', NULL, 1, 1);

-- 6. RF-VEN-05: Procedimiento Almacenado de Descuento de Inventario por FEFO
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

    -- Cursor ordenado segÃºn FEFO (Fecha de Vencimiento mÃ¡s prÃ³xima primero)
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
               CONCAT('Venta #', p_IdVenta), 'Descuento automÃ¡tico FEFO (RF-VEN-05)', 'Salida', v_DetalleId
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
