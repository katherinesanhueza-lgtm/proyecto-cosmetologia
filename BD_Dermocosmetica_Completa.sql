/*M!999999\- enable the sandbox mode */ 
-- MariaDB dump 10.19  Distrib 10.11.16-MariaDB, for Win64 (AMD64)
--
-- Host: localhost    Database: ERP_Dermocosmetica
-- ------------------------------------------------------
-- Server version	10.11.16-MariaDB

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Current Database: `ERP_Dermocosmetica`
--

/*!40000 DROP DATABASE IF EXISTS `ERP_Dermocosmetica`*/;

CREATE DATABASE /*!32312 IF NOT EXISTS*/ `erp_dermocosmetica` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci */;

USE `ERP_Dermocosmetica`;

--
-- Table structure for table `asientocontable`
--

DROP TABLE IF EXISTS `asientocontable`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `asientocontable` (
  `IdAsiento` int(11) NOT NULL AUTO_INCREMENT,
  `IdPeriodo` int(11) NOT NULL,
  `Fecha` date NOT NULL,
  `Glosa` varchar(255) DEFAULT NULL,
  `IdUsuario` int(11) NOT NULL,
  `IdAsientoRevertido` int(11) DEFAULT NULL,
  `FechaRegistro` datetime NOT NULL DEFAULT current_timestamp(),
  `Origen` varchar(20) DEFAULT NULL,
  `IdOrigen` int(11) DEFAULT NULL,
  PRIMARY KEY (`IdAsiento`),
  KEY `IdPeriodo` (`IdPeriodo`),
  KEY `IdUsuario` (`IdUsuario`),
  CONSTRAINT `asientocontable_ibfk_1` FOREIGN KEY (`IdPeriodo`) REFERENCES `periodocontable` (`IdPeriodo`),
  CONSTRAINT `asientocontable_ibfk_2` FOREIGN KEY (`IdUsuario`) REFERENCES `usuario` (`IdUsuario`)
) ENGINE=InnoDB AUTO_INCREMENT=28 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `asientocontable`
--

LOCK TABLES `asientocontable` WRITE;
/*!40000 ALTER TABLE `asientocontable` DISABLE KEYS */;
INSERT INTO `asientocontable` VALUES
(1,1,'2026-10-21','Compra Recepción REC-0001 · OC-2026-0001 (L\'Oréal Chile S.A.)',5,NULL,'2026-11-22 22:19:35','Compra',1),
(2,1,'2026-11-22','Compra Recepción REC-0002 · OC-DEMO-J01 (ISDIN Chile S.A.)',3,NULL,'2026-11-22 19:24:49','Compra',2),
(18,1,'2026-11-25','Compra Recepción REC-0007 · OC-2026-0006 (Laboratorio DermoPrueba SpA)',1,NULL,'2026-11-25 18:06:59','Compra',7),
(19,1,'2026-11-25','Nota de crédito proveedor DEV-0002',1,NULL,'2026-11-25 18:16:00','DevProveedor',2),
(20,1,'2026-11-25','[Transferencia Bancaria] Pago total CXP-0001 (OC-2026-0001) - L\'Oréal Chile S.A.',1,NULL,'2026-11-25 19:52:13','PagoProv',1),
(21,1,'2026-11-25','Venta BOL-001003',1,NULL,'2026-11-25 22:10:54','Venta',17),
(22,1,'2026-11-25','Costo de venta BOL-001003',1,NULL,'2026-11-25 22:10:54','CostoVenta',17),
(23,1,'2026-11-25','Venta BOL-001004',1,NULL,'2026-11-25 22:21:38','Venta',18),
(24,1,'2026-11-25','Costo de venta BOL-001004',1,NULL,'2026-11-25 22:21:38','CostoVenta',18),
(25,1,'2026-11-25','Cobro de venta #5',1,NULL,'2026-11-25 22:35:06','Cobro',2),
(26,1,'2026-11-25','Venta FAC-001008',1,NULL,'2026-11-25 22:48:09','Venta',19),
(27,1,'2026-11-25','Costo de venta FAC-001008',1,NULL,'2026-11-25 22:48:09','CostoVenta',19);
/*!40000 ALTER TABLE `asientocontable` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 */ /*!50003 TRIGGER aud_asientocontable_insert AFTER INSERT ON asientocontable FOR EACH ROW INSERT INTO auditoriaerp(IdUsuario,Modulo,Entidad,Accion,Registro) VALUES (@erp_actor,'Contabilidad','asientocontable','INSERT',NEW.IdAsiento) */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 */ /*!50003 TRIGGER aud_asientocontable_update AFTER UPDATE ON asientocontable FOR EACH ROW INSERT INTO auditoriaerp(IdUsuario,Modulo,Entidad,Accion,Registro) VALUES (@erp_actor,'Contabilidad','asientocontable','UPDATE',NEW.IdAsiento) */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 */ /*!50003 TRIGGER aud_asientocontable_delete AFTER DELETE ON asientocontable FOR EACH ROW INSERT INTO auditoriaerp(IdUsuario,Modulo,Entidad,Accion,Registro) VALUES (@erp_actor,'Contabilidad','asientocontable','DELETE',OLD.IdAsiento) */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `auditoriaerp`
--

DROP TABLE IF EXISTS `auditoriaerp`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `auditoriaerp` (
  `IdEvento` bigint(20) NOT NULL AUTO_INCREMENT,
  `Fecha` datetime(6) NOT NULL DEFAULT current_timestamp(6),
  `IdUsuario` int(11) DEFAULT NULL,
  `Modulo` varchar(24) NOT NULL,
  `Entidad` varchar(48) NOT NULL,
  `Accion` varchar(12) NOT NULL,
  `Registro` bigint(20) NOT NULL,
  PRIMARY KEY (`IdEvento`),
  KEY `ix_auditoria_fecha` (`Fecha`),
  KEY `ix_auditoria_usuario` (`IdUsuario`)
) ENGINE=InnoDB AUTO_INCREMENT=166 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `auditoriaerp`
--

LOCK TABLES `auditoriaerp` WRITE;
/*!40000 ALTER TABLE `auditoriaerp` DISABLE KEYS */;
INSERT INTO `auditoriaerp` VALUES
(1,'2026-11-22 19:45:25.902639',NULL,'Seguridad','usuario','UPDATE',1),
(2,'2026-11-22 20:30:39.539381',NULL,'Contabilidad','cuentacontable','DELETE',9),
(3,'2026-11-22 20:30:39.539381',NULL,'Contabilidad','cuentacontable','DELETE',10),
(4,'2026-11-22 20:30:39.539381',NULL,'Contabilidad','cuentacontable','DELETE',11),
(5,'2026-11-22 20:30:39.539381',NULL,'Contabilidad','cuentacontable','DELETE',12),
(6,'2026-11-22 20:30:39.539381',NULL,'Contabilidad','cuentacontable','DELETE',13),
(7,'2026-11-22 20:30:39.539381',NULL,'Contabilidad','cuentacontable','DELETE',14),
(8,'2026-11-22 20:30:39.539381',NULL,'Contabilidad','cuentacontable','DELETE',15),
(9,'2026-11-22 20:30:39.539381',NULL,'Contabilidad','cuentacontable','DELETE',16),
(10,'2026-11-22 20:30:39.610087',NULL,'Seguridad','usuario','UPDATE',2),
(11,'2026-11-22 20:30:39.610087',NULL,'Seguridad','usuario','UPDATE',3),
(12,'2026-11-22 20:30:39.610087',NULL,'Seguridad','usuario','UPDATE',4),
(13,'2026-11-22 20:30:39.610087',NULL,'Seguridad','usuario','UPDATE',5),
(14,'2026-11-22 20:30:39.610087',NULL,'Seguridad','usuario','UPDATE',6),
(15,'2026-11-22 21:47:08.091754',1,'Seguridad','usuario','UPDATE',1),
(16,'2026-11-22 21:47:15.249220',1,'Seguridad','usuario','UPDATE',1),
(17,'2026-11-22 21:47:32.933909',1,'Seguridad','usuario','UPDATE',1),
(18,'2026-11-22 21:49:30.165897',1,'Seguridad','usuario','UPDATE',1),
(19,'2026-11-22 21:54:47.872190',1,'Seguridad','usuario','UPDATE',1),
(20,'2026-11-22 21:55:06.194754',1,'Seguridad','usuario','UPDATE',1),
(21,'2026-11-22 22:17:39.146030',1,'Seguridad','usuario','UPDATE',1),
(22,'2026-11-22 22:17:47.225718',1,'Seguridad','usuario','UPDATE',1),
(23,'2026-11-22 22:20:36.051098',1,'Compras','marca','UPDATE',5),
(24,'2026-11-22 22:20:47.535659',1,'Compras','marca','UPDATE',5),
(25,'2026-11-22 22:21:52.912562',1,'Ventas','cliente','UPDATE',2),
(26,'2026-11-22 22:22:09.600145',1,'Ventas','cliente','UPDATE',2),
(27,'2026-11-22 22:24:42.369557',NULL,'Ventas','cliente','UPDATE',1),
(28,'2026-11-22 22:24:42.372633',NULL,'Ventas','cliente','UPDATE',3),
(29,'2026-11-22 22:24:42.374697',NULL,'Ventas','cliente','UPDATE',4),
(30,'2026-11-22 22:24:42.377213',NULL,'Ventas','cliente','UPDATE',5),
(31,'2026-11-22 22:24:42.379434',NULL,'Ventas','cliente','UPDATE',6),
(32,'2026-11-22 22:24:42.381818',NULL,'Ventas','cliente','UPDATE',7),
(33,'2026-11-22 22:24:42.386597',NULL,'Ventas','cliente','UPDATE',8),
(34,'2026-11-22 22:24:42.389792',NULL,'Compras','laboratorio','UPDATE',1),
(35,'2026-11-22 22:24:42.392516',NULL,'Compras','laboratorio','UPDATE',2),
(36,'2026-11-22 22:24:42.394953',NULL,'Compras','laboratorio','UPDATE',3),
(37,'2026-11-22 22:24:42.397300',NULL,'Compras','laboratorio','UPDATE',4),
(38,'2026-11-22 22:24:42.399507',NULL,'Compras','laboratorio','UPDATE',5),
(39,'2026-11-22 22:24:42.401800',NULL,'Compras','laboratorio','UPDATE',6),
(40,'2026-11-22 22:27:24.003309',1,'Ventas','cliente','UPDATE',2),
(41,'2026-11-22 22:27:36.353877',1,'Ventas','cliente','UPDATE',7),
(42,'2026-11-22 22:28:09.803823',1,'Compras','laboratorio','UPDATE',6),
(43,'2026-11-22 23:29:32.747077',1,'Compras','marca','UPDATE',5),
(44,'2026-11-22 23:29:49.024318',1,'Compras','marca','UPDATE',5),
(45,'2026-11-22 23:30:17.848773',1,'Compras','laboratorio','UPDATE',6),
(46,'2026-11-22 23:30:30.510247',1,'Compras','laboratorio','UPDATE',6),
(47,'2026-11-23 00:30:57.491515',1,'Compras','cotizacionimportacion','UPDATE',3),
(48,'2026-11-23 00:31:00.874140',1,'Compras','ordencompra','INSERT',5),
(49,'2026-11-23 00:31:00.877405',1,'Compras','cotizacionimportacion','UPDATE',3),
(50,'2026-11-23 00:41:09.376534',1,'Compras','marca','UPDATE',5),
(51,'2026-11-23 00:41:11.565925',1,'Compras','marca','UPDATE',5),
(52,'2026-11-23 01:25:00.972831',1,'Compras','devolucionproveedor','UPDATE',1),
(53,'2026-11-23 01:31:47.435446',1,'Contabilidad','cuentacontable','INSERT',17),
(54,'2026-11-23 19:16:28.485265',1,'Compras','ordencompra','UPDATE',1),
(55,'2026-11-23 19:16:28.485265',1,'Compras','ordencompra','UPDATE',2),
(56,'2026-11-23 19:16:28.485265',1,'Compras','ordencompra','UPDATE',3),
(57,'2026-11-23 19:16:28.485265',1,'Compras','ordencompra','UPDATE',4),
(58,'2026-11-23 19:16:28.485265',1,'Compras','ordencompra','UPDATE',5),
(59,'2026-11-23 19:16:38.300557',1,'Compras','ordencompra','UPDATE',1),
(60,'2026-11-23 19:16:38.300557',1,'Compras','ordencompra','UPDATE',2),
(61,'2026-11-23 19:16:38.300557',1,'Compras','ordencompra','UPDATE',3),
(62,'2026-11-23 19:16:38.300557',1,'Compras','ordencompra','UPDATE',4),
(63,'2026-11-23 19:16:38.300557',1,'Compras','ordencompra','UPDATE',5),
(64,'2026-11-23 19:22:03.155047',1,'Ventas','despacho','UPDATE',5),
(65,'2026-11-23 19:22:05.963260',1,'Ventas','despacho','UPDATE',4),
(66,'2026-11-24 15:07:30.509776',NULL,'Contabilidad','cuentacontable','INSERT',18),
(67,'2026-11-24 15:07:30.515938',NULL,'Contabilidad','cuentacontable','INSERT',19),
(68,'2026-11-24 15:07:30.517227',NULL,'Contabilidad','cuentacontable','INSERT',20),
(111,'2026-11-25 12:39:18.342837',1,'Seguridad','usuario','UPDATE',3),
(112,'2026-11-25 18:03:37.696160',1,'Compras','laboratorio','INSERT',7),
(113,'2026-11-25 18:04:50.309084',1,'Compras','cotizacionimportacion','INSERT',4),
(114,'2026-11-25 18:04:59.362784',1,'Compras','cotizacionimportacion','UPDATE',4),
(115,'2026-11-25 18:05:01.736571',1,'Compras','ordencompra','INSERT',6),
(116,'2026-11-25 18:05:01.739020',1,'Compras','cotizacionimportacion','UPDATE',4),
(117,'2026-11-25 18:05:43.038210',1,'Compras','ordencompra','UPDATE',6),
(118,'2026-11-25 18:06:59.690008',1,'Compras','recepcioncompra','INSERT',7),
(119,'2026-11-25 18:06:59.696588',1,'Compras','ordencompra','UPDATE',6),
(120,'2026-11-25 18:06:59.755977',1,'Contabilidad','cuentaporpagar','INSERT',4),
(121,'2026-11-25 18:06:59.765599',1,'Contabilidad','asientocontable','INSERT',18),
(122,'2026-11-25 18:15:54.344392',1,'Compras','devolucionproveedor','INSERT',2),
(123,'2026-11-25 18:16:00.993720',1,'Compras','devolucionproveedor','UPDATE',2),
(124,'2026-11-25 18:16:00.995914',1,'Contabilidad','asientocontable','INSERT',19),
(125,'2026-11-25 18:16:00.996437',1,'Compras','devolucionproveedor','UPDATE',2),
(126,'2026-11-25 18:16:00.998106',1,'Contabilidad','cuentaporpagar','UPDATE',4),
(127,'2026-11-25 19:52:13.549286',1,'Contabilidad','asientocontable','INSERT',20),
(128,'2026-11-25 19:52:13.550582',1,'Contabilidad','pagoproveedor','INSERT',1),
(129,'2026-11-25 19:52:13.552029',1,'Contabilidad','asientocontable','UPDATE',20),
(130,'2026-11-25 19:52:13.552411',1,'Contabilidad','cuentaporpagar','UPDATE',1),
(131,'2026-11-25 22:10:54.441478',1,'Ventas','venta','INSERT',17),
(132,'2026-11-25 22:10:54.486865',1,'Contabilidad','asientocontable','INSERT',21),
(133,'2026-11-25 22:10:54.487679',1,'Contabilidad','asientocontable','INSERT',22),
(134,'2026-11-25 22:15:36.194428',1,'Ventas','cliente','UPDATE',7),
(135,'2026-11-25 22:15:48.181808',1,'Ventas','cliente','UPDATE',2),
(136,'2026-11-25 22:16:01.421438',1,'Ventas','cliente','UPDATE',2),
(137,'2026-11-25 22:16:02.333524',1,'Ventas','cliente','UPDATE',8),
(138,'2026-11-25 22:18:16.195008',1,'Ventas','cliente','INSERT',9),
(139,'2026-11-25 22:18:53.155217',1,'Ventas','cliente','UPDATE',9),
(140,'2026-11-25 22:19:38.259522',1,'Ventas','cliente','UPDATE',9),
(141,'2026-11-25 22:21:22.306233',1,'Ventas','cotizacion','INSERT',7),
(142,'2026-11-25 22:21:38.377111',1,'Ventas','venta','INSERT',18),
(143,'2026-11-25 22:21:38.468724',1,'Contabilidad','asientocontable','INSERT',23),
(144,'2026-11-25 22:21:38.469535',1,'Contabilidad','asientocontable','INSERT',24),
(145,'2026-11-25 22:21:38.469916',1,'Ventas','cotizacion','UPDATE',7),
(146,'2026-11-25 22:35:06.741997',1,'Contabilidad','asientocontable','INSERT',25),
(147,'2026-11-25 22:35:06.742228',1,'Contabilidad','cobrocliente','INSERT',2),
(148,'2026-11-25 22:35:06.743711',1,'Contabilidad','asientocontable','UPDATE',25),
(149,'2026-11-25 22:35:06.743925',1,'Contabilidad','cuentascobrar','UPDATE',3),
(150,'2026-11-25 22:44:49.502023',1,'Compras','ordencompra','UPDATE',1),
(151,'2026-11-25 22:44:49.502023',1,'Compras','ordencompra','UPDATE',2),
(152,'2026-11-25 22:44:49.502023',1,'Compras','ordencompra','UPDATE',3),
(153,'2026-11-25 22:44:49.502023',1,'Compras','ordencompra','UPDATE',4),
(154,'2026-11-25 22:44:49.502023',1,'Compras','ordencompra','UPDATE',5),
(155,'2026-11-25 22:44:49.502023',1,'Compras','ordencompra','UPDATE',6),
(156,'2026-11-25 22:44:59.621361',1,'Compras','ordencompra','UPDATE',1),
(157,'2026-11-25 22:44:59.621361',1,'Compras','ordencompra','UPDATE',2),
(158,'2026-11-25 22:44:59.621361',1,'Compras','ordencompra','UPDATE',3),
(159,'2026-11-25 22:44:59.621361',1,'Compras','ordencompra','UPDATE',4),
(160,'2026-11-25 22:44:59.621361',1,'Compras','ordencompra','UPDATE',5),
(161,'2026-11-25 22:44:59.621361',1,'Compras','ordencompra','UPDATE',6),
(162,'2026-11-25 22:48:09.450885',1,'Ventas','venta','INSERT',19),
(163,'2026-11-25 22:48:09.453836',1,'Contabilidad','cuentascobrar','INSERT',9),
(164,'2026-11-25 22:48:09.455474',1,'Contabilidad','asientocontable','INSERT',26),
(165,'2026-11-25 22:48:09.456203',1,'Contabilidad','asientocontable','INSERT',27);
/*!40000 ALTER TABLE `auditoriaerp` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 */ /*!50003 TRIGGER aud_impedir_edicion BEFORE UPDATE ON auditoriaerp FOR EACH ROW SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='La bitácora es de solo lectura' */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 */ /*!50003 TRIGGER aud_impedir_borrado BEFORE DELETE ON auditoriaerp FOR EACH ROW SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='La bitácora es de solo lectura' */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `bodega`
--

DROP TABLE IF EXISTS `bodega`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `bodega` (
  `IdBodega` int(11) NOT NULL AUTO_INCREMENT,
  `Nombre` varchar(100) NOT NULL,
  `Ubicacion` varchar(150) DEFAULT NULL,
  `Activo` tinyint(1) DEFAULT 1,
  PRIMARY KEY (`IdBodega`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `bodega`
--

LOCK TABLES `bodega` WRITE;
/*!40000 ALTER TABLE `bodega` DISABLE KEYS */;
INSERT INTO `bodega` VALUES
(1,'Bodega Central Santiago','Av. Américo Vespucio 1450, Quilicura, Santiago',1),
(2,'Bodega Sucursal Providencia','Av. Providencia 2124, Local 4, Providencia, Santiago',1),
(3,'Bodega Distribución Zona Sur','Av. Paicaví 1890, Concepción',1);
/*!40000 ALTER TABLE `bodega` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `categoria`
--

DROP TABLE IF EXISTS `categoria`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `categoria` (
  `IdCategoria` int(11) NOT NULL AUTO_INCREMENT,
  `Nombre` varchar(100) NOT NULL,
  `Descripcion` varchar(255) DEFAULT NULL,
  `Activo` tinyint(1) DEFAULT 1,
  PRIMARY KEY (`IdCategoria`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `categoria`
--

LOCK TABLES `categoria` WRITE;
/*!40000 ALTER TABLE `categoria` DISABLE KEYS */;
INSERT INTO `categoria` VALUES
(1,'Protección Solar','Fotoprotectores solares faciales y corporales dermatológicos',1),
(2,'Cuidado Facial y Sérums','Sérums concentrados, hidratantes y tratamientos anti-edad',1),
(3,'Limpieza Dermo','Geles limpiadores dermatológicos, espumas y aguas micelares',1),
(4,'Tratamientos Clínicos y Acné','Cremas reparadoras, despigmentantes y control seborreico',1),
(5,'Hidratación Corporal','Lociones, bálsamos emolientes y reparación de barrera cutánea',1);
/*!40000 ALTER TABLE `categoria` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `cliente`
--

DROP TABLE IF EXISTS `cliente`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `cliente` (
  `IdCliente` int(11) NOT NULL AUTO_INCREMENT,
  `Rut` varchar(20) NOT NULL,
  `Nombre` varchar(150) NOT NULL,
  `RazonSocial` varchar(150) DEFAULT NULL,
  `Categoria` varchar(50) DEFAULT NULL,
  `Giro` varchar(150) DEFAULT NULL,
  `Direccion` varchar(200) DEFAULT NULL,
  `Contacto` varchar(100) DEFAULT NULL,
  `Correo` varchar(100) DEFAULT NULL,
  `Telefono` varchar(30) DEFAULT NULL,
  `LimiteCredito` decimal(18,2) NOT NULL DEFAULT 0.00,
  `DiasCredito` int(11) NOT NULL DEFAULT 0,
  `Activo` tinyint(1) NOT NULL DEFAULT 1,
  PRIMARY KEY (`IdCliente`),
  UNIQUE KEY `Rut` (`Rut`)
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cliente`
--

LOCK TABLES `cliente` WRITE;
/*!40000 ALTER TABLE `cliente` DISABLE KEYS */;
INSERT INTO `cliente` VALUES
(1,'76.543.210-3','Clínica Estética DermoSalud SpA','Clínica Estética DermoSalud SpA','Clinica','Servicios Médicos y Dermatología Clínica','Av. Providencia 2345, Of. 801, Providencia, Santiago','Dra. Andrea Valenzuela','contacto@dermosalud.cl','+56 9 8765 4321',3500000.00,30,1),
(2,'77.890.123-4','Farmacias Dermocare Chile Ltda.','Farmacias Dermocare Chile Ltda.','Farmacia','Comercio Minorista de Productos Farmacéuticos y Dermocosméticos','Av. Apoquindo 4501, Local 12, Las Condes, Santiago','Roberto Fuenzalida','adquisiciones@dermocare.cl','+56 9 7654 3210',5000000.00,45,1),
(3,'76.998.877-7','Distribuidora Belleza & Salud Sur S.A.','Distribuidora Belleza & Salud Sur S.A.','Mayorista','Distribución Mayorista de Insumos Cosmecéuticos','Av. Bernardo O\'Higgins 1120, Concepción','Marcela Riquelme','compras@bellezasur.cl','+56 9 6543 2109',8000000.00,60,1),
(4,'78.112.233-5','Centro Dermatológico SkinClinic Vitacura','Centro Dermatológico SkinClinic Vitacura SpA','Clinica','Clínica Estética Integral y Procedimientos Láser','Av. Nueva Costanera 3900, Of. 402, Vitacura, Santiago','Dr. Sebastián Morales','smorales@skinclinic.cl','+56 9 5432 1098',4200000.00,30,1),
(5,'15.432.876-9','Camila Ignacia Fernández Rojas','Camila Ignacia Fernández Rojas','Profesional','Cosmetóloga y Esteticista Clínica Independiente','Av. Libertad 840, Of. 304, Viña del Mar','Camila Fernández','camila.cosmetologia@gmail.com','+56 9 4321 0987',1200000.00,30,1),
(6,'76.334.455-K','Botica Natural & Dermo Boutique SpA','Botica Natural & Dermo Boutique SpA','Farmacia','Venta Especializada de Productos Dermocosméticos','Av. Pedro de Valdivia 1780, Ñuñoa, Santiago','Francisca Lagos','contacto@dermoboutique.cl','+56 9 3210 9876',2500000.00,30,1),
(7,'18.765.432-7','Valentina Paz Soto Mardones','Valentina Paz Soto Mardones','Particular','Consumidor Final / Cliente Frecuente','Los Militares 5620, Depto. 1102, Las Condes, Santiago','Valentina Soto','valesoto.m@gmail.com','+56 9 2109 8765',0.00,0,0),
(8,'79.221.334-0','Estética Avanzada Las Condes Ltda.','Estética Avanzada Las Condes Ltda.','Clinica','Tratamientos Faciales y Corporales','Av. Presidente Kennedy 7100, Of. 505, Las Condes, Santiago','Paulina Echeverría','admin@esteticalascondes.cl','+56 9 9123 4567',1500000.00,30,1),
(9,'21.622.810-3','prueba','prueba','Mayorista','prueba','prueba 123','Camilosky','losky@gmail.com','977666543',7000000.00,90,1);
/*!40000 ALTER TABLE `cliente` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 */ /*!50003 TRIGGER aud_cliente_insert AFTER INSERT ON cliente FOR EACH ROW INSERT INTO auditoriaerp(IdUsuario,Modulo,Entidad,Accion,Registro) VALUES (@erp_actor,'Ventas','cliente','INSERT',NEW.IdCliente) */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 */ /*!50003 TRIGGER aud_cliente_update AFTER UPDATE ON cliente FOR EACH ROW INSERT INTO auditoriaerp(IdUsuario,Modulo,Entidad,Accion,Registro) VALUES (@erp_actor,'Ventas','cliente','UPDATE',NEW.IdCliente) */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 */ /*!50003 TRIGGER aud_cliente_delete AFTER DELETE ON cliente FOR EACH ROW INSERT INTO auditoriaerp(IdUsuario,Modulo,Entidad,Accion,Registro) VALUES (@erp_actor,'Ventas','cliente','DELETE',OLD.IdCliente) */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `cobrocliente`
--

DROP TABLE IF EXISTS `cobrocliente`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `cobrocliente` (
  `IdCobro` int(11) NOT NULL AUTO_INCREMENT,
  `IdCuenta` int(11) NOT NULL,
  `IdAsiento` int(11) NOT NULL,
  `IdUsuario` int(11) NOT NULL,
  `Fecha` date NOT NULL,
  `Medio` varchar(30) NOT NULL,
  `Monto` decimal(18,2) NOT NULL,
  `Solicitud` char(36) NOT NULL,
  PRIMARY KEY (`IdCobro`),
  UNIQUE KEY `IdAsiento` (`IdAsiento`),
  UNIQUE KEY `Solicitud` (`Solicitud`),
  KEY `IdCuenta` (`IdCuenta`),
  KEY `IdUsuario` (`IdUsuario`),
  CONSTRAINT `cobrocliente_ibfk_1` FOREIGN KEY (`IdCuenta`) REFERENCES `cuentascobrar` (`IdCuenta`),
  CONSTRAINT `cobrocliente_ibfk_2` FOREIGN KEY (`IdAsiento`) REFERENCES `asientocontable` (`IdAsiento`),
  CONSTRAINT `cobrocliente_ibfk_3` FOREIGN KEY (`IdUsuario`) REFERENCES `usuario` (`IdUsuario`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cobrocliente`
--

LOCK TABLES `cobrocliente` WRITE;
/*!40000 ALTER TABLE `cobrocliente` DISABLE KEYS */;
INSERT INTO `cobrocliente` VALUES
(2,3,25,1,'2026-11-25','Transferencia',266890.00,'b96e58a3-f1c4-4749-8320-a4739c7469ba');
/*!40000 ALTER TABLE `cobrocliente` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 */ /*!50003 TRIGGER aud_cobrocliente_insert AFTER INSERT ON cobrocliente FOR EACH ROW INSERT INTO auditoriaerp(IdUsuario,Modulo,Entidad,Accion,Registro) VALUES (@erp_actor,'Contabilidad','cobrocliente','INSERT',NEW.IdCobro) */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 */ /*!50003 TRIGGER aud_cobrocliente_update AFTER UPDATE ON cobrocliente FOR EACH ROW INSERT INTO auditoriaerp(IdUsuario,Modulo,Entidad,Accion,Registro) VALUES (@erp_actor,'Contabilidad','cobrocliente','UPDATE',NEW.IdCobro) */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 */ /*!50003 TRIGGER aud_cobrocliente_delete AFTER DELETE ON cobrocliente FOR EACH ROW INSERT INTO auditoriaerp(IdUsuario,Modulo,Entidad,Accion,Registro) VALUES (@erp_actor,'Contabilidad','cobrocliente','DELETE',OLD.IdCobro) */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `configuracionglobal`
--

DROP TABLE IF EXISTS `configuracionglobal`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `configuracionglobal` (
  `IdConfiguracion` int(11) NOT NULL AUTO_INCREMENT,
  `Clave` varchar(50) NOT NULL,
  `Valor` varchar(255) NOT NULL,
  `Descripcion` varchar(255) DEFAULT NULL,
  `FechaModificacion` datetime DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`IdConfiguracion`),
  UNIQUE KEY `Clave` (`Clave`)
) ENGINE=InnoDB AUTO_INCREMENT=29 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `configuracionglobal`
--

LOCK TABLES `configuracionglobal` WRITE;
/*!40000 ALTER TABLE `configuracionglobal` DISABLE KEYS */;
INSERT INTO `configuracionglobal` VALUES
(1,'TasaIva','0.19','Tasa general de IVA en Chile','2026-11-25 22:44:59'),
(2,'NombreJefeCompras','Javiera Rail Astudillo','Firma oficial Jefatura de Compras','2026-11-22 22:19:35'),
(3,'NombreJefeVentas','Camilo Rodríguez Saldaña','Firma oficial Jefatura de Ventas','2026-11-22 22:19:35'),
(4,'NombreJefeInventario','Katherine Sanhueza Hernández','Firma oficial Jefatura de Bodega','2026-11-22 22:19:35'),
(5,'NombreContador','Contador General','Firma oficial Contabilidad y Comprobantes de Pago','2026-11-22 22:19:35'),
(6,'TipoCambioUSD','1033.12','Tipo de cambio oficial USD -> CLP','2026-11-25 22:43:56'),
(7,'TipoCambioEUR','1132.81','Tipo de cambio oficial EUR -> CLP','2026-11-25 22:43:56'),
(8,'FechaTipoCambio','2026-11-25','Fecha de última sincronización diaria de tipo de cambio','2026-11-25 12:40:41');
/*!40000 ALTER TABLE `configuracionglobal` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `cotizacion`
--

DROP TABLE IF EXISTS `cotizacion`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `cotizacion` (
  `IdCotizacion` int(11) NOT NULL AUTO_INCREMENT,
  `FechaEmision` date NOT NULL,
  `FechaVencimiento` date DEFAULT NULL,
  `Estado` varchar(50) DEFAULT NULL,
  `Total` decimal(18,2) DEFAULT 0.00,
  `IdCliente` int(11) NOT NULL,
  `IdUsuario` int(11) NOT NULL,
  PRIMARY KEY (`IdCotizacion`),
  KEY `IdCliente` (`IdCliente`),
  KEY `IdUsuario` (`IdUsuario`),
  CONSTRAINT `cotizacion_ibfk_1` FOREIGN KEY (`IdCliente`) REFERENCES `cliente` (`IdCliente`),
  CONSTRAINT `cotizacion_ibfk_2` FOREIGN KEY (`IdUsuario`) REFERENCES `usuario` (`IdUsuario`),
  CONSTRAINT `cotizacion_chk_1` CHECK (`Estado` in (_utf8mb4'Vigente',_utf8mb4'Aceptado',_utf8mb4'Vencido',_utf8mb4'Rechazado'))
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cotizacion`
--

LOCK TABLES `cotizacion` WRITE;
/*!40000 ALTER TABLE `cotizacion` DISABLE KEYS */;
INSERT INTO `cotizacion` VALUES
(1,'2026-10-28','2026-11-12','Aceptado',311870.00,1,2),
(2,'2026-11-04','2026-11-19','Aceptado',534780.00,2,2),
(3,'2026-11-17','2026-12-07','Vigente',258890.00,4,2),
(4,'2026-11-20','2026-12-12','Vigente',494830.00,3,1),
(5,'2026-10-18','2026-11-02','Vencido',159930.00,5,6),
(6,'2026-11-10','2026-11-25','Rechazado',279980.00,6,6),
(7,'2026-11-25','2026-12-10','Aceptado',153930.00,9,1);
/*!40000 ALTER TABLE `cotizacion` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 */ /*!50003 TRIGGER aud_cotizacion_insert AFTER INSERT ON cotizacion FOR EACH ROW INSERT INTO auditoriaerp(IdUsuario,Modulo,Entidad,Accion,Registro) VALUES (@erp_actor,'Ventas','cotizacion','INSERT',NEW.IdCotizacion) */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 */ /*!50003 TRIGGER aud_cotizacion_update AFTER UPDATE ON cotizacion FOR EACH ROW INSERT INTO auditoriaerp(IdUsuario,Modulo,Entidad,Accion,Registro) VALUES (@erp_actor,'Ventas','cotizacion','UPDATE',NEW.IdCotizacion) */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 */ /*!50003 TRIGGER aud_cotizacion_delete AFTER DELETE ON cotizacion FOR EACH ROW INSERT INTO auditoriaerp(IdUsuario,Modulo,Entidad,Accion,Registro) VALUES (@erp_actor,'Ventas','cotizacion','DELETE',OLD.IdCotizacion) */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `cotizaciondetalle`
--

DROP TABLE IF EXISTS `cotizaciondetalle`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `cotizaciondetalle` (
  `IdCotizacionDetalle` int(11) NOT NULL AUTO_INCREMENT,
  `IdCotizacion` int(11) NOT NULL,
  `IdVariante` int(11) NOT NULL,
  `Cantidad` int(11) NOT NULL,
  `PrecioUnitario` decimal(18,2) NOT NULL,
  PRIMARY KEY (`IdCotizacionDetalle`),
  KEY `IdCotizacion` (`IdCotizacion`),
  KEY `IdVariante` (`IdVariante`),
  CONSTRAINT `cotizaciondetalle_ibfk_1` FOREIGN KEY (`IdCotizacion`) REFERENCES `cotizacion` (`IdCotizacion`),
  CONSTRAINT `cotizaciondetalle_ibfk_2` FOREIGN KEY (`IdVariante`) REFERENCES `varianteproducto` (`IdVariante`)
) ENGINE=InnoDB AUTO_INCREMENT=18 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cotizaciondetalle`
--

LOCK TABLES `cotizaciondetalle` WRITE;
/*!40000 ALTER TABLE `cotizaciondetalle` DISABLE KEYS */;
INSERT INTO `cotizaciondetalle` VALUES
(1,1,1,8,23990.00),
(2,1,3,8,14990.00),
(3,2,2,10,36990.00),
(4,2,4,5,16990.00),
(5,2,7,2,31990.00),
(6,2,3,1,15950.00),
(7,3,5,6,24990.00),
(8,3,6,2,38990.00),
(9,3,7,1,30970.00),
(10,4,1,10,23990.00),
(11,4,8,8,19490.00),
(12,4,9,4,21990.00),
(13,4,4,1,11050.00),
(14,5,10,4,23490.00),
(15,5,9,3,21990.00),
(16,6,12,2,139990.00),
(17,7,9,7,21990.00);
/*!40000 ALTER TABLE `cotizaciondetalle` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `cotizacionimportacion`
--

DROP TABLE IF EXISTS `cotizacionimportacion`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `cotizacionimportacion` (
  `IdCotizacion` int(11) NOT NULL AUTO_INCREMENT,
  `IdLaboratorio` int(11) NOT NULL,
  `Fecha` date NOT NULL,
  `Moneda` varchar(10) DEFAULT NULL,
  `TipoCambio` decimal(10,4) DEFAULT NULL,
  `Estado` varchar(20) DEFAULT NULL,
  `IdUsuario` int(11) NOT NULL,
  PRIMARY KEY (`IdCotizacion`),
  KEY `IdLaboratorio` (`IdLaboratorio`),
  KEY `IdUsuario` (`IdUsuario`),
  CONSTRAINT `cotizacionimportacion_ibfk_1` FOREIGN KEY (`IdLaboratorio`) REFERENCES `laboratorio` (`IdLaboratorio`),
  CONSTRAINT `cotizacionimportacion_ibfk_2` FOREIGN KEY (`IdUsuario`) REFERENCES `usuario` (`IdUsuario`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cotizacionimportacion`
--

LOCK TABLES `cotizacionimportacion` WRITE;
/*!40000 ALTER TABLE `cotizacionimportacion` DISABLE KEYS */;
INSERT INTO `cotizacionimportacion` VALUES
(1,1,'2026-11-22','CLP',1.0000,'Convertida',3),
(2,5,'2026-11-22','CLP',1.0000,'Convertida',3),
(3,5,'2026-11-22','CLP',1.0000,'Convertida',3),
(4,7,'2026-11-25','EUR',1114.3100,'Convertida',1);
/*!40000 ALTER TABLE `cotizacionimportacion` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 */ /*!50003 TRIGGER aud_cotizacionimportacion_insert AFTER INSERT ON cotizacionimportacion FOR EACH ROW INSERT INTO auditoriaerp(IdUsuario,Modulo,Entidad,Accion,Registro) VALUES (@erp_actor,'Compras','cotizacionimportacion','INSERT',NEW.IdCotizacion) */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 */ /*!50003 TRIGGER aud_cotizacionimportacion_update AFTER UPDATE ON cotizacionimportacion FOR EACH ROW INSERT INTO auditoriaerp(IdUsuario,Modulo,Entidad,Accion,Registro) VALUES (@erp_actor,'Compras','cotizacionimportacion','UPDATE',NEW.IdCotizacion) */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 */ /*!50003 TRIGGER aud_cotizacionimportacion_delete AFTER DELETE ON cotizacionimportacion FOR EACH ROW INSERT INTO auditoriaerp(IdUsuario,Modulo,Entidad,Accion,Registro) VALUES (@erp_actor,'Compras','cotizacionimportacion','DELETE',OLD.IdCotizacion) */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `cuentacontable`
--

DROP TABLE IF EXISTS `cuentacontable`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `cuentacontable` (
  `IdCuentaContable` int(11) NOT NULL AUTO_INCREMENT,
  `Codigo` varchar(50) NOT NULL,
  `Nombre` varchar(100) NOT NULL,
  `Tipo` varchar(50) DEFAULT NULL,
  `IdCuentaPadre` int(11) DEFAULT NULL,
  `Nivel` int(11) NOT NULL DEFAULT 1,
  `Imputable` tinyint(1) NOT NULL DEFAULT 1,
  PRIMARY KEY (`IdCuentaContable`),
  UNIQUE KEY `uq_cuentacontable_codigo` (`Codigo`)
) ENGINE=InnoDB AUTO_INCREMENT=21 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cuentacontable`
--

LOCK TABLES `cuentacontable` WRITE;
/*!40000 ALTER TABLE `cuentacontable` DISABLE KEYS */;
INSERT INTO `cuentacontable` VALUES
(1,'1101','Caja y Bancos','Activo',NULL,1,1),
(2,'1103','Clientes por Cobrar','Activo',NULL,1,1),
(3,'1105','Existencias e Inventario','Activo',NULL,1,1),
(4,'1109','IVA Crédito Fiscal','Activo',NULL,1,1),
(5,'2101','Proveedores por Pagar','Pasivo',NULL,1,1),
(6,'2108','IVA Débito Fiscal','Pasivo',NULL,1,1),
(7,'4101','Ingresos por Ventas','Resultado Ganancia',NULL,1,1),
(8,'5101','Costo de Ventas','Resultado Pérdida',NULL,1,1),
(17,'4546','prueba','Activo',NULL,1,1),
(18,'1199','Créditos a favor de proveedores','Activo',NULL,1,1),
(19,'4901','Recuperación por ajustes de inventario','Ingreso',NULL,1,1),
(20,'5102','Pérdidas por mermas y ajustes de inventario','Costo',NULL,1,1);
/*!40000 ALTER TABLE `cuentacontable` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 */ /*!50003 TRIGGER aud_cuentacontable_insert AFTER INSERT ON cuentacontable FOR EACH ROW INSERT INTO auditoriaerp(IdUsuario,Modulo,Entidad,Accion,Registro) VALUES (@erp_actor,'Contabilidad','cuentacontable','INSERT',NEW.IdCuentaContable) */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 */ /*!50003 TRIGGER aud_cuentacontable_update AFTER UPDATE ON cuentacontable FOR EACH ROW INSERT INTO auditoriaerp(IdUsuario,Modulo,Entidad,Accion,Registro) VALUES (@erp_actor,'Contabilidad','cuentacontable','UPDATE',NEW.IdCuentaContable) */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 */ /*!50003 TRIGGER aud_cuentacontable_delete AFTER DELETE ON cuentacontable FOR EACH ROW INSERT INTO auditoriaerp(IdUsuario,Modulo,Entidad,Accion,Registro) VALUES (@erp_actor,'Contabilidad','cuentacontable','DELETE',OLD.IdCuentaContable) */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `cuentaporpagar`
--

DROP TABLE IF EXISTS `cuentaporpagar`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `cuentaporpagar` (
  `IdCuentaPagar` int(11) NOT NULL AUTO_INCREMENT,
  `IdRecepcion` int(11) NOT NULL,
  `IdLaboratorio` int(11) NOT NULL,
  `Monto` decimal(18,2) DEFAULT NULL,
  `Estado` varchar(20) DEFAULT NULL,
  `IdUsuario` int(11) NOT NULL,
  PRIMARY KEY (`IdCuentaPagar`),
  KEY `IdRecepcion` (`IdRecepcion`),
  KEY `IdLaboratorio` (`IdLaboratorio`),
  KEY `IdUsuario` (`IdUsuario`),
  CONSTRAINT `cuentaporpagar_ibfk_1` FOREIGN KEY (`IdRecepcion`) REFERENCES `recepcioncompra` (`IdRecepcion`),
  CONSTRAINT `cuentaporpagar_ibfk_2` FOREIGN KEY (`IdLaboratorio`) REFERENCES `laboratorio` (`IdLaboratorio`),
  CONSTRAINT `cuentaporpagar_ibfk_3` FOREIGN KEY (`IdUsuario`) REFERENCES `usuario` (`IdUsuario`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cuentaporpagar`
--

LOCK TABLES `cuentaporpagar` WRITE;
/*!40000 ALTER TABLE `cuentaporpagar` DISABLE KEYS */;
INSERT INTO `cuentaporpagar` VALUES
(1,1,2,484330.00,'Pagada',5),
(2,2,1,113526.00,'Pendiente',3),
(4,7,7,397809.00,'Parcial',1);
/*!40000 ALTER TABLE `cuentaporpagar` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 */ /*!50003 TRIGGER aud_cuentaporpagar_insert AFTER INSERT ON cuentaporpagar FOR EACH ROW INSERT INTO auditoriaerp(IdUsuario,Modulo,Entidad,Accion,Registro) VALUES (@erp_actor,'Contabilidad','cuentaporpagar','INSERT',NEW.IdCuentaPagar) */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 */ /*!50003 TRIGGER aud_cuentaporpagar_update AFTER UPDATE ON cuentaporpagar FOR EACH ROW INSERT INTO auditoriaerp(IdUsuario,Modulo,Entidad,Accion,Registro) VALUES (@erp_actor,'Contabilidad','cuentaporpagar','UPDATE',NEW.IdCuentaPagar) */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 */ /*!50003 TRIGGER aud_cuentaporpagar_delete AFTER DELETE ON cuentaporpagar FOR EACH ROW INSERT INTO auditoriaerp(IdUsuario,Modulo,Entidad,Accion,Registro) VALUES (@erp_actor,'Contabilidad','cuentaporpagar','DELETE',OLD.IdCuentaPagar) */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `cuentascobrar`
--

DROP TABLE IF EXISTS `cuentascobrar`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `cuentascobrar` (
  `IdCuenta` int(11) NOT NULL AUTO_INCREMENT,
  `IdVenta` int(11) NOT NULL,
  `FechaVence` date DEFAULT NULL,
  `MontoPendiente` decimal(18,2) DEFAULT NULL,
  `EstadoPago` varchar(50) DEFAULT NULL,
  `IdUsuario` int(11) NOT NULL,
  PRIMARY KEY (`IdCuenta`),
  KEY `IdVenta` (`IdVenta`),
  KEY `IdUsuario` (`IdUsuario`),
  CONSTRAINT `cuentascobrar_ibfk_1` FOREIGN KEY (`IdVenta`) REFERENCES `venta` (`IdVenta`),
  CONSTRAINT `cuentascobrar_ibfk_2` FOREIGN KEY (`IdUsuario`) REFERENCES `usuario` (`IdUsuario`)
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cuentascobrar`
--

LOCK TABLES `cuentascobrar` WRITE;
/*!40000 ALTER TABLE `cuentascobrar` DISABLE KEYS */;
INSERT INTO `cuentascobrar` VALUES
(1,2,'2026-09-23',0.00,'Pagado',2),
(2,3,'2026-10-23',0.00,'Pagado',1),
(3,5,'2026-12-02',222960.00,'Parcial',2),
(4,6,'2026-12-14',266890.00,'Pendiente',2),
(5,7,'2027-01-01',534780.00,'Pendiente',2),
(9,19,'2026-12-25',191920.00,'Pendiente',1);
/*!40000 ALTER TABLE `cuentascobrar` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 */ /*!50003 TRIGGER aud_cuentascobrar_insert AFTER INSERT ON cuentascobrar FOR EACH ROW INSERT INTO auditoriaerp(IdUsuario,Modulo,Entidad,Accion,Registro) VALUES (@erp_actor,'Contabilidad','cuentascobrar','INSERT',NEW.IdCuenta) */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 */ /*!50003 TRIGGER aud_cuentascobrar_update AFTER UPDATE ON cuentascobrar FOR EACH ROW INSERT INTO auditoriaerp(IdUsuario,Modulo,Entidad,Accion,Registro) VALUES (@erp_actor,'Contabilidad','cuentascobrar','UPDATE',NEW.IdCuenta) */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 */ /*!50003 TRIGGER aud_cuentascobrar_delete AFTER DELETE ON cuentascobrar FOR EACH ROW INSERT INTO auditoriaerp(IdUsuario,Modulo,Entidad,Accion,Registro) VALUES (@erp_actor,'Contabilidad','cuentascobrar','DELETE',OLD.IdCuenta) */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `declaracioniva`
--

DROP TABLE IF EXISTS `declaracioniva`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `declaracioniva` (
  `IdDeclaracionIVA` int(11) NOT NULL AUTO_INCREMENT,
  `IdPeriodo` int(11) NOT NULL,
  `Monto` decimal(18,2) DEFAULT NULL,
  `Fecha` date DEFAULT NULL,
  `IdUsuario` int(11) NOT NULL,
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
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 */ /*!50003 TRIGGER aud_declaracioniva_insert AFTER INSERT ON declaracioniva FOR EACH ROW INSERT INTO auditoriaerp(IdUsuario,Modulo,Entidad,Accion,Registro) VALUES (@erp_actor,'Contabilidad','declaracioniva','INSERT',NEW.IdDeclaracionIVA) */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 */ /*!50003 TRIGGER aud_declaracioniva_update AFTER UPDATE ON declaracioniva FOR EACH ROW INSERT INTO auditoriaerp(IdUsuario,Modulo,Entidad,Accion,Registro) VALUES (@erp_actor,'Contabilidad','declaracioniva','UPDATE',NEW.IdDeclaracionIVA) */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 */ /*!50003 TRIGGER aud_declaracioniva_delete AFTER DELETE ON declaracioniva FOR EACH ROW INSERT INTO auditoriaerp(IdUsuario,Modulo,Entidad,Accion,Registro) VALUES (@erp_actor,'Contabilidad','declaracioniva','DELETE',OLD.IdDeclaracionIVA) */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `despacho`
--

DROP TABLE IF EXISTS `despacho`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `despacho` (
  `IdDespacho` int(11) NOT NULL AUTO_INCREMENT,
  `IdVenta` int(11) NOT NULL,
  `Estado` varchar(50) DEFAULT NULL,
  `FechaEstimada` date DEFAULT NULL,
  `FechaEntrega` date DEFAULT NULL,
  `Tipo` varchar(50) DEFAULT NULL,
  `Observaciones` varchar(255) DEFAULT NULL,
  `IdUsuario` int(11) NOT NULL,
  PRIMARY KEY (`IdDespacho`),
  KEY `IdVenta` (`IdVenta`),
  KEY `IdUsuario` (`IdUsuario`),
  CONSTRAINT `despacho_ibfk_1` FOREIGN KEY (`IdVenta`) REFERENCES `venta` (`IdVenta`),
  CONSTRAINT `despacho_ibfk_2` FOREIGN KEY (`IdUsuario`) REFERENCES `usuario` (`IdUsuario`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `despacho`
--

LOCK TABLES `despacho` WRITE;
/*!40000 ALTER TABLE `despacho` DISABLE KEYS */;
INSERT INTO `despacho` VALUES
(1,5,'Entregado','2026-10-28','2026-10-27','Reparto Propio','Entregado conforme en recepción de clínica Vitacura',4),
(2,6,'Entregado','2026-11-16','2026-11-16','Chilexpress','Recibido por Dra. Andrea Valenzuela (OT #994821)',4),
(3,7,'En Ruta','2026-11-23',NULL,'Starken','Despacho prioritario refrigerado a sucursal Las Condes',2),
(4,8,'Entregado','2026-11-24','2026-11-23','Blue Express','Embalaje reforzado para frascos de vidrio',4),
(5,9,'En Preparacion','2026-11-25',NULL,'Reparto Propio','Coordinar entrega horario mañana en Ñuñoa',1);
/*!40000 ALTER TABLE `despacho` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 */ /*!50003 TRIGGER aud_despacho_insert AFTER INSERT ON despacho FOR EACH ROW INSERT INTO auditoriaerp(IdUsuario,Modulo,Entidad,Accion,Registro) VALUES (@erp_actor,'Ventas','despacho','INSERT',NEW.IdDespacho) */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 */ /*!50003 TRIGGER aud_despacho_update AFTER UPDATE ON despacho FOR EACH ROW INSERT INTO auditoriaerp(IdUsuario,Modulo,Entidad,Accion,Registro) VALUES (@erp_actor,'Ventas','despacho','UPDATE',NEW.IdDespacho) */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 */ /*!50003 TRIGGER aud_despacho_delete AFTER DELETE ON despacho FOR EACH ROW INSERT INTO auditoriaerp(IdUsuario,Modulo,Entidad,Accion,Registro) VALUES (@erp_actor,'Ventas','despacho','DELETE',OLD.IdDespacho) */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `detalleasiento`
--

DROP TABLE IF EXISTS `detalleasiento`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `detalleasiento` (
  `IdDetalleAsiento` int(11) NOT NULL AUTO_INCREMENT,
  `IdAsiento` int(11) NOT NULL,
  `IdCuentaContable` int(11) NOT NULL,
  `Debe` decimal(18,2) DEFAULT 0.00,
  `Haber` decimal(18,2) DEFAULT 0.00,
  PRIMARY KEY (`IdDetalleAsiento`),
  KEY `IdAsiento` (`IdAsiento`),
  KEY `IdCuentaContable` (`IdCuentaContable`),
  CONSTRAINT `detalleasiento_ibfk_1` FOREIGN KEY (`IdAsiento`) REFERENCES `asientocontable` (`IdAsiento`),
  CONSTRAINT `detalleasiento_ibfk_2` FOREIGN KEY (`IdCuentaContable`) REFERENCES `cuentacontable` (`IdCuentaContable`)
) ENGINE=InnoDB AUTO_INCREMENT=77 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `detalleasiento`
--

LOCK TABLES `detalleasiento` WRITE;
/*!40000 ALTER TABLE `detalleasiento` DISABLE KEYS */;
INSERT INTO `detalleasiento` VALUES
(1,1,3,407000.00,0.00),
(2,1,4,77330.00,0.00),
(3,1,5,0.00,484330.00),
(4,2,3,95400.00,0.00),
(5,2,4,18126.00,0.00),
(6,2,5,0.00,113526.00),
(49,18,3,334293.00,0.00),
(50,18,4,63516.00,0.00),
(51,18,5,0.00,397809.00),
(52,19,5,26520.60,0.00),
(53,19,3,0.00,22286.20),
(54,19,4,0.00,4234.40),
(55,20,5,484330.00,0.00),
(56,20,1,0.00,484330.00),
(57,21,1,199880.00,0.00),
(58,21,7,0.00,167966.39),
(59,21,6,0.00,31913.61),
(60,22,8,194400.00,0.00),
(61,22,3,0.00,194400.00),
(63,23,1,153930.00,0.00),
(64,23,7,0.00,129352.94),
(65,23,6,0.00,24577.06),
(66,24,8,96600.00,0.00),
(67,24,3,0.00,96600.00),
(69,25,1,266890.00,0.00),
(70,25,2,0.00,266890.00),
(71,26,2,191920.00,0.00),
(72,26,7,0.00,161277.31),
(73,26,6,0.00,30642.69),
(74,27,8,159000.00,0.00),
(75,27,3,0.00,159000.00);
/*!40000 ALTER TABLE `detalleasiento` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `detallecotizacion`
--

DROP TABLE IF EXISTS `detallecotizacion`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `detallecotizacion` (
  `IdDetalleCot` int(11) NOT NULL AUTO_INCREMENT,
  `IdCotizacion` int(11) NOT NULL,
  `IdVariante` int(11) NOT NULL,
  `Cantidad` int(11) NOT NULL,
  `CostoUnitario` decimal(18,2) NOT NULL,
  PRIMARY KEY (`IdDetalleCot`),
  KEY `IdCotizacion` (`IdCotizacion`),
  KEY `IdVariante` (`IdVariante`),
  CONSTRAINT `detallecotizacion_ibfk_1` FOREIGN KEY (`IdCotizacion`) REFERENCES `cotizacionimportacion` (`IdCotizacion`),
  CONSTRAINT `detallecotizacion_ibfk_2` FOREIGN KEY (`IdVariante`) REFERENCES `varianteproducto` (`IdVariante`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `detallecotizacion`
--

LOCK TABLES `detallecotizacion` WRITE;
/*!40000 ALTER TABLE `detallecotizacion` DISABLE KEYS */;
INSERT INTO `detallecotizacion` VALUES
(1,1,1,10,15900.00),
(2,2,4,8,10500.00),
(3,3,4,15,10100.00),
(4,4,5,15,20.00);
/*!40000 ALTER TABLE `detallecotizacion` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `detalleordencompra`
--

DROP TABLE IF EXISTS `detalleordencompra`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `detalleordencompra` (
  `IdDetalleOC` int(11) NOT NULL AUTO_INCREMENT,
  `IdOC` int(11) NOT NULL,
  `IdVariante` int(11) NOT NULL,
  `CantidadPedida` int(11) NOT NULL,
  `CantidadRecibida` int(11) DEFAULT 0,
  `CostoUnitario` decimal(18,2) NOT NULL,
  PRIMARY KEY (`IdDetalleOC`),
  KEY `IdOC` (`IdOC`),
  KEY `IdVariante` (`IdVariante`),
  CONSTRAINT `detalleordencompra_ibfk_1` FOREIGN KEY (`IdOC`) REFERENCES `ordencompra` (`IdOC`),
  CONSTRAINT `detalleordencompra_ibfk_2` FOREIGN KEY (`IdVariante`) REFERENCES `varianteproducto` (`IdVariante`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `detalleordencompra`
--

LOCK TABLES `detalleordencompra` WRITE;
/*!40000 ALTER TABLE `detalleordencompra` DISABLE KEYS */;
INSERT INTO `detalleordencompra` VALUES
(1,1,1,20,20,15900.00),
(2,1,3,10,10,8900.00),
(3,2,1,15,0,15900.00),
(4,2,2,5,0,24500.00),
(5,3,1,10,6,15900.00),
(6,4,4,8,0,10500.00),
(7,5,4,15,0,10100.00),
(8,6,5,15,15,22286.20);
/*!40000 ALTER TABLE `detalleordencompra` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `detallerecepcion`
--

DROP TABLE IF EXISTS `detallerecepcion`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `detallerecepcion` (
  `IdDetalleRec` int(11) NOT NULL AUTO_INCREMENT,
  `IdRecepcion` int(11) NOT NULL,
  `IdDetalleOC` int(11) NOT NULL,
  `IdVariante` int(11) NOT NULL,
  `NumeroLote` varchar(30) DEFAULT NULL,
  `FechaVencimiento` date DEFAULT NULL,
  `Cantidad` int(11) NOT NULL,
  `CostoUnitario` decimal(18,2) NOT NULL,
  PRIMARY KEY (`IdDetalleRec`),
  KEY `IdRecepcion` (`IdRecepcion`),
  KEY `IdDetalleOC` (`IdDetalleOC`),
  KEY `IdVariante` (`IdVariante`),
  CONSTRAINT `detallerecepcion_ibfk_1` FOREIGN KEY (`IdRecepcion`) REFERENCES `recepcioncompra` (`IdRecepcion`),
  CONSTRAINT `detallerecepcion_ibfk_2` FOREIGN KEY (`IdDetalleOC`) REFERENCES `detalleordencompra` (`IdDetalleOC`),
  CONSTRAINT `detallerecepcion_ibfk_3` FOREIGN KEY (`IdVariante`) REFERENCES `varianteproducto` (`IdVariante`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `detallerecepcion`
--

LOCK TABLES `detallerecepcion` WRITE;
/*!40000 ALTER TABLE `detallerecepcion` DISABLE KEYS */;
INSERT INTO `detallerecepcion` VALUES
(1,1,1,1,'LOT-ISD-2026A','2028-01-22',20,15900.00),
(2,1,2,3,'LOT-CER-2026A','2028-05-22',10,8900.00),
(3,2,5,1,'ISD-DEMO-J01','2027-11-22',6,15900.00),
(7,7,8,5,'LOT-LRP-ANT-50ML-2026','2028-12-30',15,22286.20);
/*!40000 ALTER TABLE `detallerecepcion` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `devolucionlineaventa`
--

DROP TABLE IF EXISTS `devolucionlineaventa`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `devolucionlineaventa` (
  `IdDetalleNC` int(11) NOT NULL,
  `IdDetalleOriginal` int(11) NOT NULL,
  PRIMARY KEY (`IdDetalleNC`),
  KEY `IdDetalleOriginal` (`IdDetalleOriginal`),
  CONSTRAINT `devolucionlineaventa_ibfk_1` FOREIGN KEY (`IdDetalleNC`) REFERENCES `ventadetalle` (`IdVentaDetalle`),
  CONSTRAINT `devolucionlineaventa_ibfk_2` FOREIGN KEY (`IdDetalleOriginal`) REFERENCES `ventadetalle` (`IdVentaDetalle`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `devolucionlineaventa`
--

LOCK TABLES `devolucionlineaventa` WRITE;
/*!40000 ALTER TABLE `devolucionlineaventa` DISABLE KEYS */;
/*!40000 ALTER TABLE `devolucionlineaventa` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `devolucionproveedor`
--

DROP TABLE IF EXISTS `devolucionproveedor`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `devolucionproveedor` (
  `IdDevolucion` int(11) NOT NULL AUTO_INCREMENT,
  `IdRecepcion` int(11) NOT NULL,
  `IdLote` int(11) NOT NULL,
  `Cantidad` int(11) NOT NULL,
  `Motivo` varchar(200) DEFAULT NULL,
  `Fecha` date NOT NULL,
  `Estado` varchar(20) DEFAULT NULL,
  `IdUsuario` int(11) NOT NULL,
  `MontoCredito` decimal(18,2) NOT NULL DEFAULT 0.00,
  `MontoAplicado` decimal(18,2) NOT NULL DEFAULT 0.00,
  `IdAsiento` int(11) DEFAULT NULL,
  PRIMARY KEY (`IdDevolucion`),
  KEY `IdRecepcion` (`IdRecepcion`),
  KEY `IdLote` (`IdLote`),
  KEY `IdUsuario` (`IdUsuario`),
  KEY `ix_devolucionproveedor_cxp` (`IdRecepcion`,`Estado`),
  KEY `ix_devolucionproveedor_asiento` (`IdAsiento`),
  CONSTRAINT `devolucionproveedor_ibfk_1` FOREIGN KEY (`IdRecepcion`) REFERENCES `recepcioncompra` (`IdRecepcion`),
  CONSTRAINT `devolucionproveedor_ibfk_2` FOREIGN KEY (`IdLote`) REFERENCES `lote` (`IdLote`),
  CONSTRAINT `devolucionproveedor_ibfk_3` FOREIGN KEY (`IdUsuario`) REFERENCES `usuario` (`IdUsuario`),
  CONSTRAINT `fk_devolucionproveedor_asiento` FOREIGN KEY (`IdAsiento`) REFERENCES `asientocontable` (`IdAsiento`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `devolucionproveedor`
--

LOCK TABLES `devolucionproveedor` WRITE;
/*!40000 ALTER TABLE `devolucionproveedor` DISABLE KEYS */;
INSERT INTO `devolucionproveedor` VALUES
(1,2,26,1,'Ejemplo: envase con daño exterior','2026-11-22','En Revisión',3,0.00,0.00,NULL),
(2,7,29,1,'Discrepancia de lote / cantidad: pruebaaaaaa','2026-11-25','Aceptado',1,26520.60,26520.60,19);
/*!40000 ALTER TABLE `devolucionproveedor` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 */ /*!50003 TRIGGER aud_devolucionproveedor_insert AFTER INSERT ON devolucionproveedor FOR EACH ROW INSERT INTO auditoriaerp(IdUsuario,Modulo,Entidad,Accion,Registro) VALUES (@erp_actor,'Compras','devolucionproveedor','INSERT',NEW.IdDevolucion) */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 */ /*!50003 TRIGGER aud_devolucionproveedor_update AFTER UPDATE ON devolucionproveedor FOR EACH ROW INSERT INTO auditoriaerp(IdUsuario,Modulo,Entidad,Accion,Registro) VALUES (@erp_actor,'Compras','devolucionproveedor','UPDATE',NEW.IdDevolucion) */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 */ /*!50003 TRIGGER aud_devolucionproveedor_delete AFTER DELETE ON devolucionproveedor FOR EACH ROW INSERT INTO auditoriaerp(IdUsuario,Modulo,Entidad,Accion,Registro) VALUES (@erp_actor,'Compras','devolucionproveedor','DELETE',OLD.IdDevolucion) */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `inventario`
--

DROP TABLE IF EXISTS `inventario`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `inventario` (
  `IdInventario` int(11) NOT NULL AUTO_INCREMENT,
  `IdVariante` int(11) NOT NULL,
  `IdBodega` int(11) NOT NULL,
  `StockActual` int(11) DEFAULT 0,
  `StockReservado` int(11) DEFAULT 0,
  `FechaActualizada` datetime DEFAULT current_timestamp(),
  PRIMARY KEY (`IdInventario`),
  KEY `IdVariante` (`IdVariante`),
  KEY `IdBodega` (`IdBodega`),
  CONSTRAINT `inventario_ibfk_1` FOREIGN KEY (`IdVariante`) REFERENCES `varianteproducto` (`IdVariante`),
  CONSTRAINT `inventario_ibfk_2` FOREIGN KEY (`IdBodega`) REFERENCES `bodega` (`IdBodega`)
) ENGINE=InnoDB AUTO_INCREMENT=26 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `inventario`
--

LOCK TABLES `inventario` WRITE;
/*!40000 ALTER TABLE `inventario` DISABLE KEYS */;
INSERT INTO `inventario` VALUES
(1,1,1,35,0,'2026-11-25 22:48:09'),
(2,2,1,25,0,'2026-11-22 22:19:35'),
(3,3,1,50,0,'2026-11-22 22:19:35'),
(4,4,1,30,0,'2026-11-22 22:19:35'),
(5,5,1,37,0,'2026-11-25 22:10:54'),
(6,6,1,25,0,'2026-11-22 22:19:35'),
(7,7,1,30,0,'2026-11-22 22:19:35'),
(8,8,1,40,0,'2026-11-22 22:19:35'),
(9,9,1,28,0,'2026-11-25 22:21:38'),
(10,10,1,25,0,'2026-11-22 22:19:35'),
(11,11,1,35,0,'2026-11-22 22:19:35'),
(12,12,1,12,0,'2026-11-22 22:19:35'),
(13,1,2,20,0,'2026-11-22 22:19:35'),
(14,2,2,15,0,'2026-11-22 22:19:35'),
(15,3,2,20,0,'2026-11-22 22:19:35'),
(16,4,2,15,0,'2026-11-22 22:19:35'),
(17,5,2,15,0,'2026-11-22 22:19:35'),
(18,6,2,10,0,'2026-11-22 22:19:35'),
(19,7,2,15,0,'2026-11-22 22:19:35'),
(20,8,2,20,0,'2026-11-22 22:19:35'),
(21,9,2,20,0,'2026-11-22 22:19:35'),
(22,10,2,15,0,'2026-11-22 22:19:35'),
(23,11,2,15,0,'2026-11-22 22:19:35'),
(24,12,2,8,0,'2026-11-22 22:19:35'),
(25,1,3,6,0,'2026-11-22 19:24:49');
/*!40000 ALTER TABLE `inventario` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `laboratorio`
--

DROP TABLE IF EXISTS `laboratorio`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `laboratorio` (
  `IdLaboratorio` int(11) NOT NULL AUTO_INCREMENT,
  `Rut` varchar(12) NOT NULL,
  `RazonSocial` varchar(150) NOT NULL,
  `Marca` varchar(100) DEFAULT NULL,
  `Pais` varchar(50) DEFAULT NULL,
  `Contacto` varchar(100) DEFAULT NULL,
  `Email` varchar(100) DEFAULT NULL,
  `Telefono` varchar(20) DEFAULT NULL,
  `DiasPago` int(11) DEFAULT 30,
  `Activo` tinyint(1) DEFAULT 1,
  PRIMARY KEY (`IdLaboratorio`),
  UNIQUE KEY `Rut` (`Rut`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `laboratorio`
--

LOCK TABLES `laboratorio` WRITE;
/*!40000 ALTER TABLE `laboratorio` DISABLE KEYS */;
INSERT INTO `laboratorio` VALUES
(1,'77.234.567-4','ISDIN Chile S.A.','ISDIN','Chile','Carlos Pérez','contacto@isdin.cl','+56911223344',30,1),
(2,'76.111.222-8','L\'Oréal Chile S.A.','L\'Oréal / CeraVe / Vichy / SkinCeuticals','Chile','María López','contacto@loreal.cl','+56922334455',60,1),
(3,'78.444.555-0','La Roche-Posay Chile','La Roche-Posay','Francia','Ana Gómez','contacto@laroche.cl','+56933445566',45,1),
(4,'79.888.999-0','Eucerin Beiersdorf S.A.','Eucerin','Alemania','Felipe Soto','contacto@eucerin.cl','+56944556677',30,1),
(5,'76.555.444-6','Pierre Fabre Dermo-Cosmétique Chile','Avène','Francia','Lucía Mardones','compras@pierrefabre.cl','+56955667788',45,1),
(6,'77.999.111-3','NAOS Bioderma Chile SpA','Bioderma','Francia','Martín Arriagada','logistica@bioderma.cl','+56966778899',30,1),
(7,'77.123.456-9','Laboratorio DermoPrueba SpA','DermoTest','Francia','Camila Soto','contacto@dermoprueba.cl','+56 9 8765 4321',30,1);
/*!40000 ALTER TABLE `laboratorio` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 */ /*!50003 TRIGGER aud_laboratorio_insert AFTER INSERT ON laboratorio FOR EACH ROW INSERT INTO auditoriaerp(IdUsuario,Modulo,Entidad,Accion,Registro) VALUES (@erp_actor,'Compras','laboratorio','INSERT',NEW.IdLaboratorio) */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 */ /*!50003 TRIGGER aud_laboratorio_update AFTER UPDATE ON laboratorio FOR EACH ROW INSERT INTO auditoriaerp(IdUsuario,Modulo,Entidad,Accion,Registro) VALUES (@erp_actor,'Compras','laboratorio','UPDATE',NEW.IdLaboratorio) */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 */ /*!50003 TRIGGER aud_laboratorio_delete AFTER DELETE ON laboratorio FOR EACH ROW INSERT INTO auditoriaerp(IdUsuario,Modulo,Entidad,Accion,Registro) VALUES (@erp_actor,'Compras','laboratorio','DELETE',OLD.IdLaboratorio) */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `lote`
--

DROP TABLE IF EXISTS `lote`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `lote` (
  `IdLote` int(11) NOT NULL AUTO_INCREMENT,
  `IdVariante` int(11) NOT NULL,
  `IdBodega` int(11) DEFAULT NULL,
  `NumeroLote` varchar(50) NOT NULL,
  `FechaIngreso` date DEFAULT NULL,
  `FechaVencimiento` date DEFAULT NULL,
  `CostoUnitario` decimal(18,2) DEFAULT NULL,
  `CantidadInicial` int(11) DEFAULT NULL,
  `CantidadDisponible` int(11) DEFAULT NULL,
  `Estado` varchar(20) DEFAULT NULL,
  PRIMARY KEY (`IdLote`),
  UNIQUE KEY `uq_lote_variante_numero` (`IdVariante`,`NumeroLote`),
  KEY `IdVariante` (`IdVariante`),
  KEY `IdBodega` (`IdBodega`),
  CONSTRAINT `lote_ibfk_1` FOREIGN KEY (`IdVariante`) REFERENCES `varianteproducto` (`IdVariante`),
  CONSTRAINT `lote_chk_1` CHECK (`Estado` in (_utf8mb4'Disponible',_utf8mb4'Cuarentena',_utf8mb4'Vencido',_utf8mb4'Agotado'))
) ENGINE=InnoDB AUTO_INCREMENT=30 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `lote`
--

LOCK TABLES `lote` WRITE;
/*!40000 ALTER TABLE `lote` DISABLE KEYS */;
INSERT INTO `lote` VALUES
(1,1,1,'LOT-ISD-2026A','2026-10-13','2028-01-22',15900.00,30,10,'Agotado'),
(2,1,1,'LOT-ISD-2026B','2026-11-12','2028-09-22',15900.00,25,25,'Disponible'),
(3,2,1,'LOT-LRP-HB5-01','2026-10-18','2028-03-22',24500.00,30,25,'Disponible'),
(4,3,1,'LOT-CER-2026A','2026-10-08','2028-05-22',8900.00,60,50,'Disponible'),
(5,4,1,'LOT-AVE-CIC-01','2026-10-23','2028-02-22',10500.00,35,30,'Disponible'),
(6,5,1,'LOT-LRP-ANT-01','2026-10-28','2028-06-22',16200.00,40,23,'Disponible'),
(7,6,1,'LOT-EUC-APG-01','2026-11-02','2028-04-22',25900.00,30,25,'Disponible'),
(8,7,1,'LOT-VIC-M89-01','2026-10-25','2028-07-22',20500.00,35,30,'Disponible'),
(9,8,1,'LOT-BIO-SEN-01','2026-10-31','2028-11-22',12400.00,45,40,'Disponible'),
(10,9,1,'LOT-CER-CRE-01','2026-11-04','2028-08-22',13800.00,40,28,'Disponible'),
(11,10,1,'LOT-LRP-EFF-01','2026-11-07','2028-03-22',15600.00,30,25,'Disponible'),
(12,11,1,'LOT-EUC-OIL-01','2026-11-10','2028-05-22',14900.00,40,35,'Disponible'),
(13,12,1,'LOT-SKC-CEF-01','2026-11-12','2027-11-22',92000.00,15,12,'Disponible'),
(14,1,2,'LOT-ISD-PRV-01','2026-11-02','2028-05-22',15900.00,20,20,'Disponible'),
(15,2,2,'LOT-LRP-PRV-02','2026-11-02','2028-05-22',24500.00,15,15,'Disponible'),
(16,3,2,'LOT-CER-PRV-03','2026-11-02','2028-07-22',8900.00,20,20,'Disponible'),
(17,4,2,'LOT-AVE-PRV-04','2026-11-07','2028-04-22',10500.00,15,15,'Disponible'),
(18,5,2,'LOT-LRP-PRV-05','2026-11-07','2028-06-22',16200.00,15,15,'Disponible'),
(19,6,2,'LOT-EUC-PRV-06','2026-11-07','2028-03-22',25900.00,10,10,'Disponible'),
(20,7,2,'LOT-VIC-PRV-07','2026-11-10','2028-08-22',20500.00,15,15,'Disponible'),
(21,8,2,'LOT-BIO-PRV-08','2026-11-10','2028-09-22',12400.00,20,20,'Disponible'),
(22,9,2,'LOT-CER-PRV-09','2026-11-12','2028-07-22',13800.00,20,20,'Disponible'),
(23,10,2,'LOT-LRP-PRV-10','2026-11-12','2028-05-22',15600.00,15,15,'Disponible'),
(24,11,2,'LOT-EUC-PRV-11','2026-11-14','2028-06-22',14900.00,15,15,'Disponible'),
(25,12,2,'LOT-SKC-PRV-12','2026-11-14','2028-01-22',92000.00,8,8,'Disponible'),
(26,1,3,'ISD-DEMO-J01','2026-11-22','2027-11-22',15900.00,6,6,'Disponible'),
(29,5,1,'LOT-LRP-ANT-50ML-2026','2026-11-25','2028-12-30',22286.20,15,14,'Disponible');
/*!40000 ALTER TABLE `lote` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `marca`
--

DROP TABLE IF EXISTS `marca`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `marca` (
  `IdMarca` int(11) NOT NULL AUTO_INCREMENT,
  `Nombre` varchar(100) NOT NULL,
  `Descripcion` varchar(255) DEFAULT NULL,
  `Activo` tinyint(1) DEFAULT 1,
  PRIMARY KEY (`IdMarca`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `marca`
--

LOCK TABLES `marca` WRITE;
/*!40000 ALTER TABLE `marca` DISABLE KEYS */;
INSERT INTO `marca` VALUES
(1,'ISDIN','Fotoprotección y dermatología clínica española',1),
(2,'La Roche-Posay','Dermocosmética francesa para pieles sensibles',1),
(3,'CeraVe','Cuidado dermatológico desarrollado con ceramidas esenciales',1),
(4,'Eucerin','Ciencia dermatológica alemana para el cuidado clínico de la piel',1),
(5,'Avène','Dermocosmética con agua termal calmante para pieles intolerantes',1),
(6,'Vichy','Cosmecéutica mineral fortalecedora y antiedad clínica',1),
(7,'Bioderma','Ecobiología al servicio de la dermatología clínica',1),
(8,'SkinCeuticals','Cosmecéutica avanzada de alta potencia antioxidante',1);
/*!40000 ALTER TABLE `marca` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 */ /*!50003 TRIGGER aud_marca_insert AFTER INSERT ON marca FOR EACH ROW INSERT INTO auditoriaerp(IdUsuario,Modulo,Entidad,Accion,Registro) VALUES (@erp_actor,'Compras','marca','INSERT',NEW.IdMarca) */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 */ /*!50003 TRIGGER aud_marca_update AFTER UPDATE ON marca FOR EACH ROW INSERT INTO auditoriaerp(IdUsuario,Modulo,Entidad,Accion,Registro) VALUES (@erp_actor,'Compras','marca','UPDATE',NEW.IdMarca) */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 */ /*!50003 TRIGGER aud_marca_delete AFTER DELETE ON marca FOR EACH ROW INSERT INTO auditoriaerp(IdUsuario,Modulo,Entidad,Accion,Registro) VALUES (@erp_actor,'Compras','marca','DELETE',OLD.IdMarca) */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `merma`
--

DROP TABLE IF EXISTS `merma`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `merma` (
  `IdMerma` int(11) NOT NULL AUTO_INCREMENT,
  `IdLote` int(11) NOT NULL,
  `IdUsuario` int(11) NOT NULL,
  `Cantidad` int(11) NOT NULL,
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
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `movimientoinventario` (
  `IdMovimiento` int(11) NOT NULL AUTO_INCREMENT,
  `IdLote` int(11) DEFAULT NULL,
  `IdBodega` int(11) DEFAULT NULL,
  `IdTipoMovimiento` int(11) NOT NULL,
  `IdUsuario` int(11) NOT NULL,
  `FechaMovimiento` datetime DEFAULT current_timestamp(),
  `Cantidad` int(11) NOT NULL,
  `StockAnterior` int(11) DEFAULT NULL,
  `StockPosterior` int(11) DEFAULT NULL,
  `Referencia` varchar(100) DEFAULT NULL,
  `Observacion` varchar(255) DEFAULT NULL,
  `Origen` varchar(20) DEFAULT NULL,
  `IdDetalleOrigen` int(11) DEFAULT NULL,
  PRIMARY KEY (`IdMovimiento`),
  KEY `IdLote` (`IdLote`),
  KEY `IdBodega` (`IdBodega`),
  KEY `IdTipoMovimiento` (`IdTipoMovimiento`),
  KEY `IdUsuario` (`IdUsuario`),
  CONSTRAINT `movimientoinventario_ibfk_1` FOREIGN KEY (`IdLote`) REFERENCES `lote` (`IdLote`),
  CONSTRAINT `movimientoinventario_ibfk_2` FOREIGN KEY (`IdTipoMovimiento`) REFERENCES `tipomovimiento` (`IdTipoMovimiento`),
  CONSTRAINT `movimientoinventario_ibfk_3` FOREIGN KEY (`IdUsuario`) REFERENCES `usuario` (`IdUsuario`)
) ENGINE=InnoDB AUTO_INCREMENT=17 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `movimientoinventario`
--

LOCK TABLES `movimientoinventario` WRITE;
/*!40000 ALTER TABLE `movimientoinventario` DISABLE KEYS */;
INSERT INTO `movimientoinventario` VALUES
(1,26,3,1,3,'2026-11-22 19:24:49',6,0,6,'Entrada #3','Recepción de compra','Entrada',3),
(12,29,1,1,1,'2026-11-25 18:06:59',15,35,50,'Entrada #7','Recepción de compra','Entrada',7),
(13,29,1,4,1,'2026-11-25 18:16:00',1,50,49,'DEV-2','Discrepancia de lote / cantidad: pruebaaaaaa','DevProveedor',2),
(14,6,1,2,1,'2026-11-25 22:10:54',12,49,37,'Venta #17','Descuento automático FEFO (RF-VEN-05)','Salida',28),
(15,10,1,2,1,'2026-11-25 22:21:38',7,35,28,'Venta #18','Descuento automático FEFO (RF-VEN-05)','Salida',29),
(16,1,1,2,1,'2026-11-25 22:48:09',10,45,35,'Venta #19','Descuento automático FEFO (RF-VEN-05)','Salida',30);
/*!40000 ALTER TABLE `movimientoinventario` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `ordencompra`
--

DROP TABLE IF EXISTS `ordencompra`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `ordencompra` (
  `IdOC` int(11) NOT NULL AUTO_INCREMENT,
  `NumeroOC` varchar(20) NOT NULL,
  `IdLaboratorio` int(11) NOT NULL,
  `IdCotizacion` int(11) DEFAULT NULL,
  `Fecha` date NOT NULL,
  `FechaEsperada` date DEFAULT NULL,
  `Estado` varchar(20) DEFAULT NULL,
  `Neto` decimal(18,2) DEFAULT NULL,
  `Iva` decimal(18,2) DEFAULT NULL,
  `Total` decimal(18,2) DEFAULT NULL,
  `IdUsuario` int(11) NOT NULL,
  PRIMARY KEY (`IdOC`),
  UNIQUE KEY `NumeroOC` (`NumeroOC`),
  KEY `IdLaboratorio` (`IdLaboratorio`),
  KEY `IdCotizacion` (`IdCotizacion`),
  KEY `IdUsuario` (`IdUsuario`),
  CONSTRAINT `ordencompra_ibfk_1` FOREIGN KEY (`IdLaboratorio`) REFERENCES `laboratorio` (`IdLaboratorio`),
  CONSTRAINT `ordencompra_ibfk_2` FOREIGN KEY (`IdCotizacion`) REFERENCES `cotizacionimportacion` (`IdCotizacion`),
  CONSTRAINT `ordencompra_ibfk_3` FOREIGN KEY (`IdUsuario`) REFERENCES `usuario` (`IdUsuario`),
  CONSTRAINT `ordencompra_chk_1` CHECK (`Estado` in (_utf8mb4'Borrador',_utf8mb4'Emitida',_utf8mb4'Parcial',_utf8mb4'Recibida',_utf8mb4'Anulada'))
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ordencompra`
--

LOCK TABLES `ordencompra` WRITE;
/*!40000 ALTER TABLE `ordencompra` DISABLE KEYS */;
INSERT INTO `ordencompra` VALUES
(1,'OC-2026-0001',2,NULL,'2026-10-08','2026-10-23','Recibida',407000.00,77330.00,484330.00,3),
(2,'OC-2026-0002',1,NULL,'2026-11-07','2026-12-02','Emitida',361000.00,68590.00,429590.00,3),
(3,'OC-DEMO-J01',1,1,'2026-11-22','2026-11-27','Parcial',159000.00,30210.00,189210.00,3),
(4,'OC-DEMO-J02',5,2,'2026-11-22','2026-11-27','Emitida',84000.00,15960.00,99960.00,3),
(5,'OC-2026-0005',5,3,'2026-11-23','2027-01-07','Borrador',151500.00,28785.00,180285.00,1),
(6,'OC-2026-0006',7,4,'2026-11-25','2026-12-25','Recibida',334293.00,63516.00,397809.00,1);
/*!40000 ALTER TABLE `ordencompra` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 */ /*!50003 TRIGGER aud_ordencompra_insert AFTER INSERT ON ordencompra FOR EACH ROW INSERT INTO auditoriaerp(IdUsuario,Modulo,Entidad,Accion,Registro) VALUES (@erp_actor,'Compras','ordencompra','INSERT',NEW.IdOC) */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 */ /*!50003 TRIGGER aud_ordencompra_update AFTER UPDATE ON ordencompra FOR EACH ROW INSERT INTO auditoriaerp(IdUsuario,Modulo,Entidad,Accion,Registro) VALUES (@erp_actor,'Compras','ordencompra','UPDATE',NEW.IdOC) */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 */ /*!50003 TRIGGER aud_ordencompra_delete AFTER DELETE ON ordencompra FOR EACH ROW INSERT INTO auditoriaerp(IdUsuario,Modulo,Entidad,Accion,Registro) VALUES (@erp_actor,'Compras','ordencompra','DELETE',OLD.IdOC) */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `pagoproveedor`
--

DROP TABLE IF EXISTS `pagoproveedor`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `pagoproveedor` (
  `IdPagoProveedor` int(11) NOT NULL AUTO_INCREMENT,
  `IdCuentaPagar` int(11) NOT NULL,
  `IdAsiento` int(11) NOT NULL,
  `Monto` decimal(18,2) DEFAULT NULL,
  `Fecha` date DEFAULT NULL,
  `IdUsuario` int(11) NOT NULL,
  PRIMARY KEY (`IdPagoProveedor`),
  KEY `IdCuentaPagar` (`IdCuentaPagar`),
  KEY `IdAsiento` (`IdAsiento`),
  KEY `IdUsuario` (`IdUsuario`),
  CONSTRAINT `pagoproveedor_ibfk_1` FOREIGN KEY (`IdCuentaPagar`) REFERENCES `cuentaporpagar` (`IdCuentaPagar`),
  CONSTRAINT `pagoproveedor_ibfk_2` FOREIGN KEY (`IdAsiento`) REFERENCES `asientocontable` (`IdAsiento`),
  CONSTRAINT `pagoproveedor_ibfk_3` FOREIGN KEY (`IdUsuario`) REFERENCES `usuario` (`IdUsuario`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `pagoproveedor`
--

LOCK TABLES `pagoproveedor` WRITE;
/*!40000 ALTER TABLE `pagoproveedor` DISABLE KEYS */;
INSERT INTO `pagoproveedor` VALUES
(1,1,20,484330.00,'2026-11-25',1);
/*!40000 ALTER TABLE `pagoproveedor` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 */ /*!50003 TRIGGER aud_pagoproveedor_insert AFTER INSERT ON pagoproveedor FOR EACH ROW INSERT INTO auditoriaerp(IdUsuario,Modulo,Entidad,Accion,Registro) VALUES (@erp_actor,'Contabilidad','pagoproveedor','INSERT',NEW.IdPagoProveedor) */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 */ /*!50003 TRIGGER aud_pagoproveedor_update AFTER UPDATE ON pagoproveedor FOR EACH ROW INSERT INTO auditoriaerp(IdUsuario,Modulo,Entidad,Accion,Registro) VALUES (@erp_actor,'Contabilidad','pagoproveedor','UPDATE',NEW.IdPagoProveedor) */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 */ /*!50003 TRIGGER aud_pagoproveedor_delete AFTER DELETE ON pagoproveedor FOR EACH ROW INSERT INTO auditoriaerp(IdUsuario,Modulo,Entidad,Accion,Registro) VALUES (@erp_actor,'Contabilidad','pagoproveedor','DELETE',OLD.IdPagoProveedor) */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `periodocontable`
--

DROP TABLE IF EXISTS `periodocontable`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `periodocontable` (
  `IdPeriodo` int(11) NOT NULL AUTO_INCREMENT,
  `Nombre` varchar(50) NOT NULL,
  `FechaInicio` date NOT NULL,
  `FechaFin` date NOT NULL,
  `Estado` varchar(20) DEFAULT NULL,
  PRIMARY KEY (`IdPeriodo`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `periodocontable`
--

LOCK TABLES `periodocontable` WRITE;
/*!40000 ALTER TABLE `periodocontable` DISABLE KEYS */;
INSERT INTO `periodocontable` VALUES
(1,'Año Comercial Vigente','2025-11-22','2027-11-22','Abierto');
/*!40000 ALTER TABLE `periodocontable` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 */ /*!50003 TRIGGER aud_periodocontable_insert AFTER INSERT ON periodocontable FOR EACH ROW INSERT INTO auditoriaerp(IdUsuario,Modulo,Entidad,Accion,Registro) VALUES (@erp_actor,'Contabilidad','periodocontable','INSERT',NEW.IdPeriodo) */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 */ /*!50003 TRIGGER aud_periodocontable_update AFTER UPDATE ON periodocontable FOR EACH ROW INSERT INTO auditoriaerp(IdUsuario,Modulo,Entidad,Accion,Registro) VALUES (@erp_actor,'Contabilidad','periodocontable','UPDATE',NEW.IdPeriodo) */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 */ /*!50003 TRIGGER aud_periodocontable_delete AFTER DELETE ON periodocontable FOR EACH ROW INSERT INTO auditoriaerp(IdUsuario,Modulo,Entidad,Accion,Registro) VALUES (@erp_actor,'Contabilidad','periodocontable','DELETE',OLD.IdPeriodo) */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `producto`
--

DROP TABLE IF EXISTS `producto`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `producto` (
  `IdProducto` int(11) NOT NULL AUTO_INCREMENT,
  `IdCategoria` int(11) DEFAULT NULL,
  `IdMarca` int(11) DEFAULT NULL,
  `Nombre` varchar(150) NOT NULL,
  `Descripcion` varchar(255) DEFAULT NULL,
  `StockMinimo` int(11) DEFAULT 0,
  `PuntoReOrden` int(11) DEFAULT 0,
  `Activo` tinyint(1) DEFAULT 1,
  PRIMARY KEY (`IdProducto`),
  KEY `IdCategoria` (`IdCategoria`),
  KEY `IdMarca` (`IdMarca`),
  CONSTRAINT `producto_ibfk_1` FOREIGN KEY (`IdCategoria`) REFERENCES `categoria` (`IdCategoria`),
  CONSTRAINT `producto_ibfk_2` FOREIGN KEY (`IdMarca`) REFERENCES `marca` (`IdMarca`)
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `producto`
--

LOCK TABLES `producto` WRITE;
/*!40000 ALTER TABLE `producto` DISABLE KEYS */;
INSERT INTO `producto` VALUES
(1,1,1,'Fusion Water Magic SPF 50','Fotoprotector solar facial ultraligero de absorción inmediata',15,25,1),
(2,2,2,'Sérum Hyalu B5 Concentrado','Sérum anti-arrugas reparador y rellenador con ácido hialurónico puro y vitamina B5',10,20,1),
(3,3,3,'Gel Limpiador Espumoso','Limpiador dermatológico con 3 ceramidas esenciales y niacinamida para piel normal a grasa',20,35,1),
(4,4,5,'Cicalfate+ Crema Reparadora','Crema reparadora y protectora calmante para pieles irritadas o post-procedimiento',12,20,1),
(5,1,2,'Anthelios UVMune 400 Fluido Invisible SPF 50+','Fotoprotector facial de amplio espectro contra rayos UVA ultra-largos',15,30,1),
(6,4,4,'Anti-Pigment Dual Sérum','Sérum despigmentante clínico con Thiamidol patentado y ácido hialurónico',10,18,1),
(7,2,6,'Minéral 89 Booster Hidratante','Concentrado fortificante y rellenador diario con 89% agua volcánica mineralizante',15,25,1),
(8,3,7,'Sensibio H2O Agua Micelar','Agua micelar dermatológica limpiadora y desmaquillante para piel sensible',20,35,1),
(9,5,3,'Crema Hidratante Piel Seca a Muy Seca','Crema rica restauradora de la barrera cutánea con tecnología MVE y ceramidas',15,25,1),
(10,4,2,'Effaclar Duo+M Tratamiento Anti-Imperfecciones','Corrector triple acción para piel grasa con tendencia acneica',12,22,1),
(11,1,4,'Sun Face Oil Control Gel-Crema Toque Seco FPS 50+','Protector solar facial matificante anti-brillo por 12 horas',15,25,1),
(12,2,8,'C E Ferulic Sérum Antioxidante','Sérum antioxidante de alta potencia con 15% Vitamina C pura, Vitamina E y Ácido Ferúlico',5,10,1);
/*!40000 ALTER TABLE `producto` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `recepcioncompra`
--

DROP TABLE IF EXISTS `recepcioncompra`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `recepcioncompra` (
  `IdRecepcion` int(11) NOT NULL AUTO_INCREMENT,
  `IdOC` int(11) NOT NULL,
  `GuiaDespacho` varchar(30) DEFAULT NULL,
  `FechaRecepcion` date NOT NULL,
  `Estado` varchar(20) DEFAULT NULL,
  `IdUsuario` int(11) NOT NULL,
  PRIMARY KEY (`IdRecepcion`),
  KEY `IdOC` (`IdOC`),
  KEY `IdUsuario` (`IdUsuario`),
  CONSTRAINT `recepcioncompra_ibfk_1` FOREIGN KEY (`IdOC`) REFERENCES `ordencompra` (`IdOC`),
  CONSTRAINT `recepcioncompra_ibfk_2` FOREIGN KEY (`IdUsuario`) REFERENCES `usuario` (`IdUsuario`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `recepcioncompra`
--

LOCK TABLES `recepcioncompra` WRITE;
/*!40000 ALTER TABLE `recepcioncompra` DISABLE KEYS */;
INSERT INTO `recepcioncompra` VALUES
(1,1,'GD-884920','2026-10-21','Aprobada',4),
(2,3,'GD-DEMO-J01','2026-11-22','Parcial',3),
(7,6,'GD-PRUEBA-01','2026-11-25','Completa',1);
/*!40000 ALTER TABLE `recepcioncompra` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 */ /*!50003 TRIGGER aud_recepcioncompra_insert AFTER INSERT ON recepcioncompra FOR EACH ROW INSERT INTO auditoriaerp(IdUsuario,Modulo,Entidad,Accion,Registro) VALUES (@erp_actor,'Compras','recepcioncompra','INSERT',NEW.IdRecepcion) */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 */ /*!50003 TRIGGER aud_recepcioncompra_update AFTER UPDATE ON recepcioncompra FOR EACH ROW INSERT INTO auditoriaerp(IdUsuario,Modulo,Entidad,Accion,Registro) VALUES (@erp_actor,'Compras','recepcioncompra','UPDATE',NEW.IdRecepcion) */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 */ /*!50003 TRIGGER aud_recepcioncompra_delete AFTER DELETE ON recepcioncompra FOR EACH ROW INSERT INTO auditoriaerp(IdUsuario,Modulo,Entidad,Accion,Registro) VALUES (@erp_actor,'Compras','recepcioncompra','DELETE',OLD.IdRecepcion) */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `rol`
--

DROP TABLE IF EXISTS `rol`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `rol` (
  `IdRol` int(11) NOT NULL AUTO_INCREMENT,
  `Nombre` varchar(50) NOT NULL,
  PRIMARY KEY (`IdRol`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `rol`
--

LOCK TABLES `rol` WRITE;
/*!40000 ALTER TABLE `rol` DISABLE KEYS */;
INSERT INTO `rol` VALUES
(1,'Administrador'),
(2,'Vendedor'),
(3,'Comprador'),
(4,'Bodeguero'),
(5,'Contador');
/*!40000 ALTER TABLE `rol` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 */ /*!50003 TRIGGER aud_rol_insert AFTER INSERT ON rol FOR EACH ROW INSERT INTO auditoriaerp(IdUsuario,Modulo,Entidad,Accion,Registro) VALUES (@erp_actor,'Seguridad','rol','INSERT',NEW.IdRol) */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 */ /*!50003 TRIGGER aud_rol_update AFTER UPDATE ON rol FOR EACH ROW INSERT INTO auditoriaerp(IdUsuario,Modulo,Entidad,Accion,Registro) VALUES (@erp_actor,'Seguridad','rol','UPDATE',NEW.IdRol) */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 */ /*!50003 TRIGGER aud_rol_delete AFTER DELETE ON rol FOR EACH ROW INSERT INTO auditoriaerp(IdUsuario,Modulo,Entidad,Accion,Registro) VALUES (@erp_actor,'Seguridad','rol','DELETE',OLD.IdRol) */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `secuenciafolio`
--

DROP TABLE IF EXISTS `secuenciafolio`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `secuenciafolio` (
  `TipoDocumento` varchar(50) NOT NULL,
  `Ultimo` bigint(20) NOT NULL,
  PRIMARY KEY (`TipoDocumento`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `secuenciafolio`
--

LOCK TABLES `secuenciafolio` WRITE;
/*!40000 ALTER TABLE `secuenciafolio` DISABLE KEYS */;
INSERT INTO `secuenciafolio` VALUES
('Boleta',1004),
('Factura',1008),
('Nota de Credito',5001);
/*!40000 ALTER TABLE `secuenciafolio` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `tipomovimiento`
--

DROP TABLE IF EXISTS `tipomovimiento`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `tipomovimiento` (
  `IdTipoMovimiento` int(11) NOT NULL AUTO_INCREMENT,
  `Nombre` varchar(100) NOT NULL,
  `Naturaleza` varchar(50) DEFAULT NULL,
  `Descripcion` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`IdTipoMovimiento`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tipomovimiento`
--

LOCK TABLES `tipomovimiento` WRITE;
/*!40000 ALTER TABLE `tipomovimiento` DISABLE KEYS */;
INSERT INTO `tipomovimiento` VALUES
(1,'Entrada','Entrada','Recepción de compra'),
(2,'Salida','Salida','Salida por venta'),
(3,'Ajuste positivo','Entrada','Diferencia justificada de inventario'),
(4,'Ajuste negativo','Salida','Pérdida, daño o vencimiento justificado');
/*!40000 ALTER TABLE `tipomovimiento` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `usuario`
--

DROP TABLE IF EXISTS `usuario`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `usuario` (
  `IdUsuario` int(11) NOT NULL AUTO_INCREMENT,
  `IdRol` int(11) DEFAULT NULL,
  `Nombre` varchar(100) NOT NULL,
  `Correo` varchar(100) NOT NULL,
  `Password` varchar(255) DEFAULT NULL,
  `Rol` varchar(50) DEFAULT NULL,
  `Activo` tinyint(1) DEFAULT 1,
  PRIMARY KEY (`IdUsuario`),
  UNIQUE KEY `Correo` (`Correo`),
  KEY `IdRol` (`IdRol`),
  CONSTRAINT `usuario_ibfk_1` FOREIGN KEY (`IdRol`) REFERENCES `rol` (`IdRol`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `usuario`
--

LOCK TABLES `usuario` WRITE;
/*!40000 ALTER TABLE `usuario` DISABLE KEYS */;
INSERT INTO `usuario` VALUES
(1,1,'Admin','admin@dermo.cl','pbkdf2-sha256$dmqmtATs7uL5c4Ef0DWUWA==$i8iuVg1uJslmvBkOSbUIRX2v807QOqKviWOYhitaW/4=','Administrador',1),
(2,2,'Raul Martinez','raul1@dermo.cl','pbkdf2-sha256$m40w3GGfZOktTOPW2xHu0Q==$ZEPAR+yWzyQHU2sLuyv3FNqG6WemL/CMqyv5OMxK4Ho=','Vendedor',1),
(3,3,'Compras','comprador@dermo.cl','pbkdf2-sha256$Tt61cZwtF5gtCBCf3ad+lw==$zrAFYZN+B5/YFmzOOb0tUN97HPoKBsvbIvX7dr8JMhg=','Comprador',1),
(4,4,'Bodeguero Central','bodega@dermo.cl','pbkdf2-sha256$haKZ7+EoggjyQP/EEDN+9Q==$9MzXUlc9HHT4EGD82lF1Si7wghN4RXyxH1+ENr+o2tw=','Bodeguero',1),
(5,5,'Contador General','contador@dermo.cl','pbkdf2-sha256$eEUfVdUvojB3ckEWcfJLeQ==$Caj7X503qffbLOz9zSx+f08LtMW28BB/zVKiRd9R4Us=','Contador',1),
(6,2,'Valentina Rojas (Ventas)','vrojas@dermo.cl','pbkdf2-sha256$GQRFpDwKtZ9uQ9A15aGABQ==$P6x0CHQAdX5ZI43HH94OUZF73wnNiTqpRHZyrXdcCSg=','Vendedor',1);
/*!40000 ALTER TABLE `usuario` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 */ /*!50003 TRIGGER aud_usuario_insert AFTER INSERT ON usuario FOR EACH ROW INSERT INTO auditoriaerp(IdUsuario,Modulo,Entidad,Accion,Registro) VALUES (@erp_actor,'Seguridad','usuario','INSERT',NEW.IdUsuario) */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 */ /*!50003 TRIGGER aud_usuario_update AFTER UPDATE ON usuario FOR EACH ROW INSERT INTO auditoriaerp(IdUsuario,Modulo,Entidad,Accion,Registro) VALUES (@erp_actor,'Seguridad','usuario','UPDATE',NEW.IdUsuario) */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 */ /*!50003 TRIGGER aud_usuario_delete AFTER DELETE ON usuario FOR EACH ROW INSERT INTO auditoriaerp(IdUsuario,Modulo,Entidad,Accion,Registro) VALUES (@erp_actor,'Seguridad','usuario','DELETE',OLD.IdUsuario) */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `varianteproducto`
--

DROP TABLE IF EXISTS `varianteproducto`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `varianteproducto` (
  `IdVariante` int(11) NOT NULL AUTO_INCREMENT,
  `IdProducto` int(11) NOT NULL,
  `Sku` varchar(50) NOT NULL,
  `NombreVariante` varchar(100) DEFAULT NULL,
  `AtributoValor` varchar(200) DEFAULT NULL,
  `Presentacion` varchar(100) DEFAULT NULL,
  `Color` varchar(50) DEFAULT NULL,
  `PrecioVenta` decimal(18,2) DEFAULT 0.00,
  `CostoPromedio` decimal(18,2) DEFAULT 0.00,
  `StockTotal` int(11) DEFAULT 0,
  `Activo` tinyint(1) DEFAULT 1,
  PRIMARY KEY (`IdVariante`),
  UNIQUE KEY `Sku` (`Sku`),
  KEY `IdProducto` (`IdProducto`),
  CONSTRAINT `varianteproducto_ibfk_1` FOREIGN KEY (`IdProducto`) REFERENCES `producto` (`IdProducto`)
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `varianteproducto`
--

LOCK TABLES `varianteproducto` WRITE;
/*!40000 ALTER TABLE `varianteproducto` DISABLE KEYS */;
INSERT INTO `varianteproducto` VALUES
(1,1,'ISD-FW-50ML','Frasco 50ml','SPF 50 · Sin Color','Frasco 50ml','Incoloro',23990.00,15900.00,61,1),
(2,2,'LRP-HB5-30ML','Gotero 30ml','Ácido Hialurónico + Vit B5','Gotero 30ml','Traslúcido',36990.00,24500.00,40,1),
(3,3,'CER-GEL-236ML','Dispensador 236ml','Piel Normal a Grasa','Dispensador 236ml','Neutro',14990.00,8900.00,70,1),
(4,4,'AVE-CIC-40ML','Tubo 40ml','Cobre-Zinc + C+-Restore','Tubo 40ml','Blanco',16990.00,10500.00,45,1),
(5,5,'LRP-ANT-50ML','Frasco 50ml','SPF 50+ Fluido Invisible','Frasco 50ml','Invisible',24990.00,17604.51,52,1),
(6,6,'EUC-APG-30ML','Dispensador Dual 30ml','Thiamidol + Ác. Hialurónico','Dispensador 30ml','Blanco/Rosa',38990.00,25900.00,35,1),
(7,7,'VIC-M89-50ML','Frasco Dosificador 50ml','89% Agua Volcánica + Hialurónico','Frasco 50ml','Transparente',31990.00,20500.00,45,1),
(8,8,'BIO-SEN-500ML','Botella 500ml','Piel Sensible / Reactiva','Botella 500ml','Incoloro',19490.00,12400.00,60,1),
(9,9,'CER-CRE-454G','Pote 454g','3 Ceramidas Esenciales','Pote 454g','Blanco',21990.00,13800.00,48,1),
(10,10,'LRP-EFF-40ML','Tubo 40ml','Phylobioma + Niacinamida','Tubo 40ml','Blanco',23490.00,15600.00,40,1),
(11,11,'EUC-OIL-50ML','Frasco 50ml','L-Carnitina Toque Seco FPS 50+','Frasco 50ml','Sin Color',22490.00,14900.00,50,1),
(12,12,'SKC-CEF-30ML','Gotero 30ml','15% L-Ácido Ascórbico + Ferúlico','Gotero 30ml','Ámbar',139990.00,92000.00,20,1);
/*!40000 ALTER TABLE `varianteproducto` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `venta`
--

DROP TABLE IF EXISTS `venta`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `venta` (
  `IdVenta` int(11) NOT NULL AUTO_INCREMENT,
  `TipoDocumento` varchar(50) NOT NULL,
  `Folio` varchar(50) DEFAULT NULL,
  `Fecha` date NOT NULL,
  `Neto` decimal(18,2) NOT NULL DEFAULT 0.00,
  `Iva` decimal(18,2) NOT NULL DEFAULT 0.00,
  `Descuento` decimal(18,2) NOT NULL DEFAULT 0.00,
  `Total` decimal(18,2) DEFAULT 0.00,
  `FormaPago` varchar(50) NOT NULL DEFAULT 'Contado',
  `Estado` varchar(30) NOT NULL DEFAULT 'Emitida',
  `IdCliente` int(11) NOT NULL,
  `IdCotizacion` int(11) DEFAULT NULL,
  `IdUsuario` int(11) NOT NULL,
  `IdVentaOrigen` int(11) DEFAULT NULL,
  PRIMARY KEY (`IdVenta`),
  UNIQUE KEY `uq_venta_documento_folio` (`TipoDocumento`,`Folio`),
  KEY `IdCliente` (`IdCliente`),
  KEY `IdCotizacion` (`IdCotizacion`),
  KEY `IdUsuario` (`IdUsuario`),
  CONSTRAINT `venta_ibfk_1` FOREIGN KEY (`IdCliente`) REFERENCES `cliente` (`IdCliente`),
  CONSTRAINT `venta_ibfk_2` FOREIGN KEY (`IdCotizacion`) REFERENCES `cotizacion` (`IdCotizacion`),
  CONSTRAINT `venta_ibfk_3` FOREIGN KEY (`IdUsuario`) REFERENCES `usuario` (`IdUsuario`)
) ENGINE=InnoDB AUTO_INCREMENT=20 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `venta`
--

LOCK TABLES `venta` WRITE;
/*!40000 ALTER TABLE `venta` DISABLE KEYS */;
INSERT INTO `venta` VALUES
(1,'Factura','FAC-001001','2026-06-22',241933.00,45967.00,0.00,287900.00,'Contado','Emitida',1,NULL,2,NULL),
(2,'Factura','FAC-001002','2026-07-22',352840.00,67040.00,0.00,419880.00,'Credito','Emitida',2,NULL,2,NULL),
(3,'Factura','FAC-001003','2026-08-22',478824.00,90976.00,10000.00,569800.00,'Credito','Emitida',3,NULL,1,NULL),
(4,'Boleta','BOL-001001','2026-09-22',184790.00,35110.00,0.00,219900.00,'Contado','Emitida',5,NULL,6,NULL),
(5,'Factura','FAC-001004','2026-10-22',411639.00,78211.00,5000.00,489850.00,'Credito','Emitida',4,NULL,2,NULL),
(6,'Factura','FAC-001005','2026-11-14',262076.00,49794.00,0.00,311870.00,'Credito','Emitida',1,1,2,NULL),
(7,'Factura','FAC-001006','2026-11-17',449395.00,85385.00,0.00,534780.00,'Credito','Emitida',2,2,2,NULL),
(8,'Boleta','BOL-001002','2026-11-19',119286.00,22664.00,0.00,141950.00,'Contado','Emitida',7,NULL,6,NULL),
(9,'Factura','FAC-001007','2026-11-21',386504.00,73436.00,0.00,459940.00,'Contado','Emitida',6,NULL,1,NULL),
(10,'Nota de Credito','NC-005001','2026-11-22',37798.00,7182.00,0.00,44980.00,'Devolucion','Emitida',1,NULL,2,6),
(17,'Boleta','BOL-001003','2026-11-25',167966.39,31913.61,100000.00,199880.00,'contado','Emitida',6,NULL,1,NULL),
(18,'Boleta','BOL-001004','2026-11-25',129352.94,24577.06,0.00,153930.00,'contado','Emitida',9,7,1,NULL),
(19,'Factura','FAC-001008','2026-11-25',161277.31,30642.69,47980.00,191920.00,'credito','Emitida',4,NULL,1,NULL);
/*!40000 ALTER TABLE `venta` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 */ /*!50003 TRIGGER aud_venta_insert AFTER INSERT ON venta FOR EACH ROW INSERT INTO auditoriaerp(IdUsuario,Modulo,Entidad,Accion,Registro) VALUES (@erp_actor,'Ventas','venta','INSERT',NEW.IdVenta) */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 */ /*!50003 TRIGGER aud_venta_update AFTER UPDATE ON venta FOR EACH ROW INSERT INTO auditoriaerp(IdUsuario,Modulo,Entidad,Accion,Registro) VALUES (@erp_actor,'Ventas','venta','UPDATE',NEW.IdVenta) */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 */ /*!50003 TRIGGER aud_venta_delete AFTER DELETE ON venta FOR EACH ROW INSERT INTO auditoriaerp(IdUsuario,Modulo,Entidad,Accion,Registro) VALUES (@erp_actor,'Ventas','venta','DELETE',OLD.IdVenta) */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `ventadetalle`
--

DROP TABLE IF EXISTS `ventadetalle`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `ventadetalle` (
  `IdVentaDetalle` int(11) NOT NULL AUTO_INCREMENT,
  `IdVenta` int(11) NOT NULL,
  `IdVariante` int(11) NOT NULL,
  `Cantidad` int(11) NOT NULL,
  `PrecioUnitario` decimal(18,2) NOT NULL,
  `Subtotal` decimal(18,2) NOT NULL,
  PRIMARY KEY (`IdVentaDetalle`),
  KEY `IdVenta` (`IdVenta`),
  KEY `IdVariante` (`IdVariante`),
  CONSTRAINT `ventadetalle_ibfk_1` FOREIGN KEY (`IdVenta`) REFERENCES `venta` (`IdVenta`),
  CONSTRAINT `ventadetalle_ibfk_2` FOREIGN KEY (`IdVariante`) REFERENCES `varianteproducto` (`IdVariante`)
) ENGINE=InnoDB AUTO_INCREMENT=31 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ventadetalle`
--

LOCK TABLES `ventadetalle` WRITE;
/*!40000 ALTER TABLE `ventadetalle` DISABLE KEYS */;
INSERT INTO `ventadetalle` VALUES
(1,1,1,10,23990.00,239900.00),
(2,1,3,3,16000.00,48000.00),
(3,2,2,8,36990.00,295920.00),
(4,2,5,5,24792.00,123960.00),
(5,3,6,10,38990.00,389900.00),
(6,3,8,10,18990.00,189900.00),
(7,4,9,10,21990.00,219900.00),
(8,5,12,2,139990.00,279980.00),
(9,5,7,5,31990.00,159950.00),
(10,5,5,2,27460.00,54920.00),
(11,6,1,8,23990.00,191920.00),
(12,6,3,8,14993.75,119950.00),
(13,7,2,10,36990.00,369900.00),
(14,7,4,5,16990.00,84950.00),
(15,7,7,2,39965.00,79930.00),
(16,8,11,3,22490.00,67470.00),
(17,8,10,2,23490.00,46980.00),
(18,8,4,1,27500.00,27500.00),
(19,9,12,2,139990.00,279980.00),
(20,9,6,4,38990.00,155960.00),
(21,9,1,1,24000.00,24000.00),
(22,10,3,3,14993.33,44980.00),
(28,17,5,12,24990.00,299880.00),
(29,18,9,7,21990.00,153930.00),
(30,19,1,10,23990.00,239900.00);
/*!40000 ALTER TABLE `ventadetalle` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping events for database 'ERP_Dermocosmetica'
--

--
-- Dumping routines for database 'ERP_Dermocosmetica'
--
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `usp_AceptarDevolucionProveedor` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
DELIMITER ;;
CREATE PROCEDURE `usp_AceptarDevolucionProveedor`(IN reclamo INT, IN responsable INT)
BEGIN
    DECLARE loteId,bodegaId,variante,unidades,disponible,anterior,reservado,tipo,inv,recepcion,cuenta,asiento INT;
    DECLARE estadoActual VARCHAR(30);
    DECLARE costoUnitario,costoNeto,ivaCredito,totalCredito,pagado,creditosPrevios,saldoDisponible,creditoAplicado,creditoFavor DECIMAL(18,2) DEFAULT 0;
    DECLARE ivaRatio DECIMAL(18,8) DEFAULT 0;

    SELECT dp.IdLote,dp.Cantidad,dp.Estado,dp.IdRecepcion,l.IdVariante,l.IdBodega,
           COALESCE(l.CantidadDisponible,0),COALESCE(l.CostoUnitario,0),
           COALESCE(oc.Iva/NULLIF(oc.Neto,0),0)
    INTO loteId,unidades,estadoActual,recepcion,variante,bodegaId,disponible,costoUnitario,ivaRatio
    FROM devolucionproveedor dp
    JOIN lote l ON l.IdLote=dp.IdLote
    JOIN recepcioncompra r ON r.IdRecepcion=dp.IdRecepcion
    JOIN ordencompra oc ON oc.IdOC=r.IdOC
    WHERE dp.IdDevolucion=reclamo
    FOR UPDATE;

    IF estadoActual IS NULL OR estadoActual NOT IN ('Pendiente','En Revisión') THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Este reclamo no está pendiente';
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM detallerecepcion d
        JOIN lote l ON l.IdLote=loteId
        WHERE d.IdRecepcion=recepcion AND d.IdVariante=variante
          AND (d.NumeroLote IS NULL OR d.NumeroLote='' OR d.NumeroLote=l.NumeroLote)
          AND (d.FechaVencimiento IS NULL OR d.FechaVencimiento=l.FechaVencimiento)
    ) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='El lote no pertenece a la recepción indicada';
    END IF;

    SELECT IdInventario,StockActual,COALESCE(StockReservado,0)
    INTO inv,anterior,reservado
    FROM inventario WHERE IdVariante=variante AND IdBodega=bodegaId FOR UPDATE;

    SELECT MIN(IdTipoMovimiento) INTO tipo FROM tipomovimiento WHERE Nombre='Ajuste negativo';
    IF inv IS NULL OR tipo IS NULL OR unidades<=0 OR disponible<unidades OR anterior-reservado<unidades THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='El lote no tiene saldo disponible para el reclamo';
    END IF;

    SET costoNeto=ROUND(unidades*costoUnitario,2);
    IF costoNeto<=0 THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='El lote no tiene costo para valorizar el crédito del proveedor'; END IF;
    SET totalCredito=ROUND(costoNeto*(1+ivaRatio),2);
    SET ivaCredito=totalCredito-costoNeto;

    SELECT IdCuentaPagar,Monto INTO cuenta,saldoDisponible
    FROM cuentaporpagar WHERE IdRecepcion=recepcion FOR UPDATE;
    IF cuenta IS NULL THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='La recepción no tiene una cuenta por pagar asociada'; END IF;

    SELECT COALESCE(SUM(Monto),0) INTO pagado FROM pagoproveedor WHERE IdCuentaPagar=cuenta;
    SELECT COALESCE(SUM(MontoAplicado),0) INTO creditosPrevios
    FROM devolucionproveedor WHERE IdRecepcion=recepcion AND Estado='Aceptado';
    SET saldoDisponible=GREATEST(saldoDisponible-pagado-creditosPrevios,0);
    SET creditoAplicado=LEAST(saldoDisponible,totalCredito);
    SET creditoFavor=totalCredito-creditoAplicado;

    UPDATE lote SET Estado=IF(disponible=unidades,'Agotado',Estado),CantidadDisponible=disponible-unidades WHERE IdLote=loteId;
    UPDATE inventario SET StockActual=anterior-unidades,FechaActualizada=NOW() WHERE IdInventario=inv;
    UPDATE varianteproducto SET StockTotal=(SELECT COALESCE(SUM(StockActual),0) FROM inventario WHERE IdVariante=variante) WHERE IdVariante=variante;
    INSERT INTO movimientoinventario(IdLote,IdBodega,IdTipoMovimiento,IdUsuario,Cantidad,StockAnterior,StockPosterior,Referencia,Observacion,Origen,IdDetalleOrigen)
    SELECT loteId,bodegaId,tipo,responsable,unidades,anterior,anterior-unidades,CONCAT('DEV-',reclamo),LEFT(Motivo,255),'DevProveedor',reclamo
    FROM devolucionproveedor WHERE IdDevolucion=reclamo;

    UPDATE devolucionproveedor
    SET Estado='Aceptado',MontoCredito=totalCredito,MontoAplicado=creditoAplicado
    WHERE IdDevolucion=reclamo;

    CALL usp_AsientoAutomatico('DevProveedor',reclamo,CONCAT('Nota de crédito proveedor DEV-',LPAD(reclamo,4,'0')),
        responsable,CURDATE(),JSON_ARRAY(
            JSON_OBJECT('codigo','2101','monto',creditoAplicado),
            JSON_OBJECT('codigo','1199','monto',creditoFavor),
            JSON_OBJECT('codigo','1105','monto',-costoNeto),
            JSON_OBJECT('codigo','1109','monto',-ivaCredito)
        ));

    SELECT IdAsiento INTO asiento FROM asientocontable WHERE Origen='DevProveedor' AND IdOrigen=reclamo;
    UPDATE devolucionproveedor SET IdAsiento=asiento WHERE IdDevolucion=reclamo;
    UPDATE cuentaporpagar cp
    SET cp.Estado=CASE
        WHEN cp.Monto<=pagado+creditosPrevios+creditoAplicado THEN 'Pagada'
        WHEN pagado+creditosPrevios+creditoAplicado>0 THEN 'Parcial'
        ELSE 'Pendiente' END
    WHERE cp.IdCuentaPagar=cuenta;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `usp_AsientoAutomatico` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
DELIMITER ;;
CREATE PROCEDURE `usp_AsientoAutomatico`(IN origenDoc VARCHAR(20), IN documento INT, IN glosaDoc VARCHAR(255),
 IN responsable INT, IN fechaDoc DATE, IN lineas JSON)
BEGIN
 DECLARE periodo,asiento,esperadas,validas INT;
 DECLARE balance DECIMAL(18,2);
 SELECT IdPeriodo INTO periodo FROM periodocontable WHERE Estado='Abierto' AND fechaDoc BETWEEN FechaInicio AND FechaFin FOR UPDATE;
 IF periodo IS NULL THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='La fecha requiere un período abierto'; END IF;
 SELECT COUNT(*),SUM(t.monto),COUNT(c.id) INTO esperadas,balance,validas
 FROM JSON_TABLE(lineas,'$[*]' COLUMNS(codigo VARCHAR(15) PATH '$.codigo', monto DECIMAL(18,2) PATH '$.monto')) t
 LEFT JOIN (SELECT Codigo,MIN(IdCuentaContable) id FROM cuentacontable WHERE Imputable=1 GROUP BY Codigo)c ON c.Codigo=t.codigo
 WHERE t.monto<>0;
 IF esperadas<2 OR validas<>esperadas OR balance<>0 THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Revisa las cuentas y la partida doble'; END IF;
 INSERT INTO asientocontable(IdPeriodo,Fecha,Glosa,IdUsuario,Origen,IdOrigen) VALUES(periodo,fechaDoc,glosaDoc,responsable,origenDoc,documento);
 SET asiento=LAST_INSERT_ID();
 INSERT INTO detalleasiento(IdAsiento,IdCuentaContable,Debe,Haber)
 SELECT asiento,c.id,GREATEST(t.monto,0),GREATEST(-t.monto,0)
 FROM JSON_TABLE(lineas,'$[*]' COLUMNS(codigo VARCHAR(15) PATH '$.codigo', monto DECIMAL(18,2) PATH '$.monto')) t
 JOIN (SELECT Codigo,MIN(IdCuentaContable) id FROM cuentacontable WHERE Imputable=1 GROUP BY Codigo)c ON c.Codigo=t.codigo WHERE t.monto<>0;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `usp_CrearCuentaPorCobrar` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
DELIMITER ;;
CREATE PROCEDURE `usp_CrearCuentaPorCobrar`(IN documento INT, IN vencimiento DATE, IN importe DECIMAL(18,2), IN responsable INT)
INSERT INTO cuentascobrar(IdVenta,FechaVence,MontoPendiente,EstadoPago,IdUsuario)
 VALUES(documento,vencimiento,importe,'Pendiente',responsable) ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `usp_CrearCuentaPorPagar` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
DELIMITER ;;
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

    
    INSERT INTO cuentaporpagar (IdRecepcion, IdLaboratorio, Monto, Estado, IdUsuario)
    VALUES (p_IdRecepcion, v_IdLaboratorio, v_Total, 'Pendiente', p_IdUsuario)
    ON DUPLICATE KEY UPDATE
        IdLaboratorio = VALUES(IdLaboratorio),
        Monto = VALUES(Monto);

    
    IF NOT EXISTS (SELECT 1 FROM asientocontable WHERE Origen = 'Compra' AND IdOrigen = p_IdRecepcion) THEN
        SELECT IdPeriodo INTO v_IdPeriodo
        FROM periodocontable
        WHERE Estado = 'Abierto' AND v_FechaRec BETWEEN FechaInicio AND FechaFin
        ORDER BY FechaInicio DESC LIMIT 1 FOR UPDATE;

        IF v_IdPeriodo IS NULL THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='No hay período abierto para esta recepción'; END IF;

        SELECT IdCuentaContable INTO v_CtaExistencias FROM cuentacontable WHERE Imputable = 1 AND Codigo = '1105' LIMIT 1;
        SELECT IdCuentaContable INTO v_CtaIva         FROM cuentacontable WHERE Imputable = 1 AND Codigo = '1109' LIMIT 1;
        SELECT IdCuentaContable INTO v_CtaProveedores FROM cuentacontable WHERE Imputable = 1 AND Codigo = '2101' LIMIT 1;

        IF v_CtaExistencias IS NULL OR v_CtaProveedores IS NULL OR (v_Iva>0 AND v_CtaIva IS NULL) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Falta una cuenta contable de compras'; END IF;
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
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `usp_DescontarInventarioFEFO` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
DELIMITER ;;
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

    
    SELECT COALESCE(StockActual, 0), COALESCE(StockReservado, 0)
    INTO v_StockBodega, v_StockReservado
    FROM inventario
    WHERE IdVariante = p_IdVariante AND IdBodega = p_IdBodega
    FOR UPDATE;

    IF v_StockBodega IS NULL OR (v_StockBodega - v_StockReservado) < p_Cantidad THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Stock insuficiente en la bodega seleccionada para cumplir con la venta.';
    END IF;

    
    OPEN curLotes;
    bucle_lotes: LOOP
        FETCH curLotes INTO v_IdLote, v_CantDisp, v_CostoUnit;
        IF v_FinCursor = 1 OR v_Pendiente <= 0 THEN
            LEAVE bucle_lotes;
        END IF;

        SET v_Tomar = LEAST(v_Pendiente, v_CantDisp);

        
        INSERT INTO ventadetalle (IdVenta, IdVariante, Cantidad, PrecioUnitario, Subtotal)
        VALUES (p_IdVenta, p_IdVariante, v_Tomar, p_PrecioUnitario, ROUND(v_Tomar * p_PrecioUnitario, 2));
        SET v_DetalleId = LAST_INSERT_ID();

        
        UPDATE lote
        SET CantidadDisponible = CantidadDisponible - v_Tomar,
            Estado = IF(CantidadDisponible - v_Tomar <= 0, 'Agotado', Estado)
        WHERE IdLote = v_IdLote;

        
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

    
    UPDATE inventario
    SET StockActual = v_StockBodega, FechaActualizada = NOW()
    WHERE IdVariante = p_IdVariante AND IdBodega = p_IdBodega;

    
    UPDATE varianteproducto
    SET StockTotal = (SELECT COALESCE(SUM(StockActual), 0) FROM inventario WHERE IdVariante = p_IdVariante)
    WHERE IdVariante = p_IdVariante;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `usp_DevolverVenta` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
DELIMITER ;;
CREATE PROCEDURE `usp_DevolverVenta`(IN ventaOrigen INT, IN responsable INT, IN folioNC VARCHAR(50), IN bodegaDestino INT, IN motivoDoc VARCHAR(255), IN articulos JSON)
BEGIN
 DECLARE cliente,cuenta,nc,detalle,unidades,variante,loteId,bodegaId,inv,saldoStock,devAnterior,devSku,vendidoSku,cantOriginal,tipo,indice INT;
 DECLARE precio,totalOrigen,netoOrigen,baseOrigen,subtotalLinea,bruto,neto,iva,totalNC,saldoCuenta,abono,totalPrevio,netoPrevio DECIMAL(18,2);
 DECLARE fechaDoc DATE;
 SET indice=0, bruto=0;
 SELECT v.IdCliente,v.Total,v.Neto INTO cliente,totalOrigen,netoOrigen FROM venta v WHERE IdVenta=ventaOrigen AND TipoDocumento IN ('Boleta','Factura') AND COALESCE(Estado,'Emitida')<>'Anulada' FOR UPDATE;
 SELECT SUM(Subtotal) INTO baseOrigen FROM ventadetalle WHERE IdVenta=ventaOrigen;
 IF cliente IS NULL OR baseOrigen<=0 OR totalOrigen<=0 OR JSON_LENGTH(articulos)=0 OR CHAR_LENGTH(TRIM(motivoDoc))=0 THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Venta o detalle de devolución inválido'; END IF;
 SELECT COALESCE(SUM(ABS(v.Total)),0),COALESCE(SUM(ABS(v.Neto)),0) INTO totalPrevio,netoPrevio FROM venta v WHERE IdVentaOrigen=ventaOrigen AND TipoDocumento='Nota de Credito';
 INSERT INTO venta(TipoDocumento,Folio,Fecha,Neto,Iva,Descuento,Total,FormaPago,IdCliente,IdUsuario,IdVentaOrigen)
 VALUES('Nota de Credito',folioNC,CURDATE(),0,0,0,0,'Devolucion',cliente,responsable,ventaOrigen);
 SET nc=LAST_INSERT_ID();
 WHILE indice<JSON_LENGTH(articulos) DO
   SET detalle=JSON_EXTRACT(articulos,CONCAT('$[',indice,'].detalle')), unidades=JSON_EXTRACT(articulos,CONCAT('$[',indice,'].cantidad'));
   SET variante=NULL;
   SELECT IdVariante,Cantidad,PrecioUnitario,Subtotal INTO variante,cantOriginal,precio,subtotalLinea
   FROM ventadetalle WHERE IdVentaDetalle=detalle AND IdVenta=ventaOrigen;
   SELECT COALESCE(SUM(d.Cantidad),0) INTO devAnterior FROM devolucionlineaventa x JOIN ventadetalle d ON d.IdVentaDetalle=x.IdDetalleNC WHERE x.IdDetalleOriginal=detalle;
   SELECT COALESCE(SUM(d.Cantidad),0) INTO devSku FROM venta n JOIN ventadetalle d USING(IdVenta) WHERE n.IdVentaOrigen=ventaOrigen AND n.TipoDocumento='Nota de Credito' AND d.IdVariante=variante;
   SELECT SUM(Cantidad) INTO vendidoSku FROM ventadetalle WHERE IdVenta=ventaOrigen AND IdVariante=variante;
   IF variante IS NULL OR unidades IS NULL OR unidades<=0 OR unidades>cantOriginal-devAnterior OR unidades>vendidoSku-devSku THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Cantidad superior al saldo por devolver'; END IF;
   INSERT INTO ventadetalle(IdVenta,IdVariante,Cantidad,PrecioUnitario,Subtotal) VALUES(nc,variante,unidades,precio,ROUND(unidades*subtotalLinea/cantOriginal,2));
   INSERT INTO devolucionlineaventa(IdDetalleNC,IdDetalleOriginal) VALUES(LAST_INSERT_ID(),detalle);
   SET bruto=bruto+ROUND(unidades*subtotalLinea/cantOriginal,2);
   IF bodegaDestino IS NOT NULL THEN
     SET loteId=NULL;
     SELECT m.IdLote,m.IdBodega INTO loteId,bodegaId FROM movimientoinventario m WHERE m.Origen='Salida' AND m.IdDetalleOrigen=detalle
     AND m.Referencia=CONCAT('Venta #',ventaOrigen) LIMIT 1 FOR UPDATE;
     IF loteId IS NULL OR bodegaId<>bodegaDestino THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Selecciona la bodega de salida. El reingreso requiere el lote original trazable'; END IF;
     SELECT IdInventario,StockActual INTO inv,saldoStock FROM inventario WHERE IdVariante=variante AND IdBodega=bodegaId FOR UPDATE;
     UPDATE lote SET CantidadDisponible=CantidadDisponible+unidades,Estado=IF(Estado='Agotado','Disponible',Estado) WHERE IdLote=loteId;
     UPDATE inventario SET StockActual=saldoStock+unidades,FechaActualizada=NOW() WHERE IdInventario=inv;
     UPDATE varianteproducto SET StockTotal=(SELECT SUM(StockActual) FROM inventario WHERE IdVariante=variante) WHERE IdVariante=variante;
     SELECT MIN(IdTipoMovimiento) INTO tipo FROM tipomovimiento WHERE Nombre='Entrada';
     INSERT INTO movimientoinventario(IdLote,IdBodega,IdTipoMovimiento,IdUsuario,Cantidad,StockAnterior,StockPosterior,Referencia,Observacion,Origen,IdDetalleOrigen)
     VALUES(loteId,bodegaId,tipo,responsable,unidades,saldoStock,saldoStock+unidades,folioNC,motivoDoc,'Devolucion',nc);
   END IF;
   SET indice=indice+1;
 END WHILE;
 IF (SELECT COALESCE(SUM(d.Cantidad),0) FROM ventadetalle d JOIN venta v USING(IdVenta) WHERE v.IdVentaOrigen=ventaOrigen AND v.TipoDocumento='Nota de Credito')
    = (SELECT SUM(d.Cantidad) FROM ventadetalle d WHERE d.IdVenta=ventaOrigen) THEN
   SET totalNC=totalOrigen-totalPrevio;
 ELSE SET totalNC=LEAST(totalOrigen-totalPrevio,ROUND(bruto*totalOrigen/baseOrigen,2)); END IF;
 IF totalNC<=0 THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='La venta ya fue abonada por completo'; END IF;
 SET neto=LEAST(netoOrigen-netoPrevio,ROUND(totalNC*netoOrigen/totalOrigen,2)), iva=totalNC-neto;
 UPDATE venta SET Neto=neto,Iva=iva,Total=totalNC WHERE IdVenta=nc;
 SELECT IdCuenta,MontoPendiente INTO cuenta,saldoCuenta FROM cuentascobrar WHERE IdVenta=ventaOrigen FOR UPDATE;
 SET abono=LEAST(totalNC,COALESCE(saldoCuenta,0));
 IF abono>0 THEN UPDATE cuentascobrar SET EstadoPago=IF(saldoCuenta=abono,'Pagado','Parcial'),MontoPendiente=saldoCuenta-abono WHERE IdCuenta=cuenta; END IF;
 CALL usp_AsientoAutomatico('Devolución',nc,CONCAT('Nota de crédito ',folioNC),responsable,CURDATE(),
 JSON_ARRAY(JSON_OBJECT('codigo','4101','monto',neto),JSON_OBJECT('codigo','2108','monto',iva),JSON_OBJECT('codigo','1103','monto',-abono),JSON_OBJECT('codigo','1101','monto',abono-totalNC)));
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `usp_IngresarRecepcionCompra` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
DELIMITER ;;
CREATE PROCEDURE `usp_IngresarRecepcionCompra`(IN v INT, IN b INT, IN d INT, IN u INT,
 IN numero VARCHAR(100), IN ingreso DATE, IN vence DATE, IN cantidad INT, IN costo DECIMAL(18,2))
BEGIN
 DECLARE inv, anterior, nuevoLote, tipo, varianteActiva, bodegaActiva INT;
 DECLARE stockTotalActual INT;
 IF cantidad<=0 OR costo<0 OR vence<ingreso THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Detalle de recepción inválido'; END IF;
 SELECT vp.IdVariante INTO varianteActiva FROM varianteproducto vp JOIN producto p USING(IdProducto)
 WHERE vp.IdVariante=v AND vp.Activo=1 AND p.Activo=1 FOR UPDATE;
 SELECT IdBodega INTO bodegaActiva FROM bodega WHERE IdBodega=b AND Activo=1 FOR UPDATE;
 IF varianteActiva IS NULL OR bodegaActiva IS NULL THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Variante o bodega inactiva'; END IF;
 SELECT IdInventario,COALESCE(StockActual,0) INTO inv,anterior FROM inventario WHERE IdVariante=v AND IdBodega=b FOR UPDATE;
 SET anterior=COALESCE(anterior,0);
 IF inv IS NULL THEN
   INSERT INTO inventario(IdVariante,IdBodega,StockActual,StockReservado,FechaActualizada) VALUES(v,b,cantidad,0,NOW());
 ELSE
   UPDATE inventario SET StockActual=anterior+cantidad,FechaActualizada=NOW() WHERE IdInventario=inv;
 END IF;
 INSERT INTO lote(IdVariante,IdBodega,NumeroLote,FechaIngreso,FechaVencimiento,CostoUnitario,CantidadInicial,CantidadDisponible,Estado)
 VALUES(v,b,numero,ingreso,vence,costo,cantidad,cantidad,'Disponible');
 SET nuevoLote=LAST_INSERT_ID();
 SELECT MIN(IdTipoMovimiento) INTO tipo FROM tipomovimiento WHERE Nombre='Entrada';
 IF tipo IS NULL THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Falta el tipo Entrada'; END IF;
 INSERT INTO movimientoinventario(IdLote,IdBodega,IdTipoMovimiento,IdUsuario,Cantidad,StockAnterior,StockPosterior,Referencia,Observacion,Origen,IdDetalleOrigen)
 VALUES(nuevoLote,b,tipo,u,cantidad,anterior,anterior+cantidad,CONCAT('Entrada #',d),'Recepción de compra','Entrada',d);
 SELECT SUM(StockActual) INTO stockTotalActual FROM inventario WHERE IdVariante=v;
 UPDATE varianteproducto SET CostoPromedio=ROUND((COALESCE(CostoPromedio,0)*(stockTotalActual-cantidad)+costo*cantidad)/stockTotalActual,2),
 StockTotal=stockTotalActual WHERE IdVariante=v;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `usp_RegistrarCobro` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
DELIMITER ;;
CREATE PROCEDURE `usp_RegistrarCobro`(IN cuenta INT, IN importe DECIMAL(18,2), IN medioPago VARCHAR(30),
 IN fechaPago DATE, IN usuario INT, IN solicitudPago CHAR(36))
BEGIN
 DECLARE saldo DECIMAL(18,2);
 DECLARE periodo,caja,clientes,asiento,ventaId,cobro INT;
 SELECT MontoPendiente,IdVenta INTO saldo,ventaId FROM cuentascobrar WHERE IdCuenta=cuenta FOR UPDATE;
 IF saldo IS NULL OR importe<=0 OR importe>saldo OR medioPago NOT IN ('Efectivo','Transferencia','Tarjeta') THEN
 SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Revisa el saldo y el medio de pago'; END IF;
 SELECT IdPeriodo INTO periodo FROM periodocontable WHERE Estado='Abierto' AND fechaPago BETWEEN FechaInicio AND FechaFin FOR UPDATE;
 SELECT MIN(IdCuentaContable) INTO caja FROM cuentacontable WHERE Codigo='1101' AND Imputable=1;
 SELECT MIN(IdCuentaContable) INTO clientes FROM cuentacontable WHERE Codigo='1103' AND Imputable=1;
 IF periodo IS NULL OR caja IS NULL OR clientes IS NULL THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Revisa el período y las cuentas de cobro'; END IF;
 INSERT INTO asientocontable(IdPeriodo,Fecha,Glosa,IdUsuario,Origen) VALUES(periodo,fechaPago,CONCAT('Cobro de venta #',ventaId),usuario,'Cobro');
 SET asiento=LAST_INSERT_ID();
 INSERT INTO detalleasiento(IdAsiento,IdCuentaContable,Debe,Haber) VALUES(asiento,caja,importe,0),(asiento,clientes,0,importe);
 INSERT INTO cobrocliente(IdCuenta,IdAsiento,IdUsuario,Fecha,Medio,Monto,Solicitud) VALUES(cuenta,asiento,usuario,fechaPago,medioPago,importe,solicitudPago);
 SET cobro=LAST_INSERT_ID();
 UPDATE asientocontable SET IdOrigen=cobro WHERE IdAsiento=asiento;
 UPDATE cuentascobrar SET MontoPendiente=saldo-importe, EstadoPago=IF(saldo=importe,'Pagado','Parcial') WHERE IdCuenta=cuenta;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `usp_UsuarioAuditoria` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
DELIMITER ;;
CREATE PROCEDURE `usp_UsuarioAuditoria`(IN actor INT)
SET @erp_actor=actor ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-11-25 22:54:46
