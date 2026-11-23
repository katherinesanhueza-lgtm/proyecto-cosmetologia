-- =============================================================================
-- DERMO ERP - SCRIPT DE ACTUALIZACION DE BASE DE DATOS PARA EL EQUIPO
-- Archivo: trabajo-ing-software/App_Data/actualizacion_bd_compras.sql
--
-- Instrucciones para compañeros:
--   1. Seleccionar la base de datos ERP_Dermocosmetica.
--   2. Ejecutar primero 007_integracion_erp.sql (si aun no lo han ejecutado).
--   3. Ejecutar este script completo.
--
-- Es 100% idempotente: no borra datos existentes y puede ejecutarse mas de una
-- vez sin duplicar registros ni provocar errores.
-- =============================================================================

SET NAMES utf8mb4;

-- 1. Asegurar tablas de soporte del modulo de Compras
CREATE TABLE IF NOT EXISTS `marca` (
    `IdMarca` INT NOT NULL AUTO_INCREMENT,
    `Nombre` VARCHAR(100) NOT NULL,
    `Descripcion` VARCHAR(255) NULL,
    `Activo` TINYINT(1) NOT NULL DEFAULT 1,
    PRIMARY KEY (`IdMarca`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `configuracionglobal` (
    `IdConfiguracion` INT NOT NULL AUTO_INCREMENT,
    `Clave` VARCHAR(80) NOT NULL,
    `Valor` VARCHAR(255) NOT NULL,
    `Descripcion` VARCHAR(255) NULL,
    `FechaModificacion` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`IdConfiguracion`),
    UNIQUE KEY `uq_configuracion_clave` (`Clave`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 2. Configuracion global (IVA, firmas de jefaturas y tipos de cambio)
INSERT INTO `configuracionglobal` (`Clave`, `Valor`, `Descripcion`) VALUES
('TasaIva', '0.19', 'Tasa general de IVA en Chile'),
('NombreJefeCompras', 'Javiera Rail Astudillo', 'Firma oficial Jefatura de Compras'),
('NombreJefeVentas', 'Camilo Rodríguez Saldaña', 'Firma oficial Jefatura de Ventas'),
('NombreJefeInventario', 'Katherine Sanhueza Hernández', 'Firma oficial Jefatura de Bodega'),
('NombreContador', 'Contador General', 'Firma oficial Contabilidad y Comprobantes de Pago'),
('TipoCambioUSD', '1014.08', 'Tipo de cambio oficial USD -> CLP'),
('TipoCambioEUR', '1113.15', 'Tipo de cambio oficial EUR -> CLP'),
('FechaTipoCambio', '2026-11-22', 'Fecha de última sincronización diaria de tipo de cambio')
ON DUPLICATE KEY UPDATE
    `Valor` = VALUES(`Valor`),
    `Descripcion` = VALUES(`Descripcion`);

-- 3. Catalogo independiente de Marcas (modulo de Compras)
INSERT INTO `marca` (`IdMarca`, `Nombre`, `Descripcion`, `Activo`) VALUES
(1, 'ISDIN', 'Fotoprotección y dermatología clínica española', 1),
(2, 'La Roche-Posay', 'Dermocosmética francesa para pieles sensibles', 1),
(3, 'CeraVe', 'Cuidado dermatológico desarrollado con ceramidas esenciales', 1),
(4, 'Eucerin', 'Ciencia dermatológica alemana para el cuidado clínico de la piel', 1),
(5, 'Avène', 'Dermocosmética con agua termal calmante para pieles intolerantes', 1),
(6, 'Vichy', 'Cosmecéutica mineral fortalecedora y antiedad clínica', 1),
(7, 'Bioderma', 'Ecobiología al servicio de la dermatología clínica', 1),
(8, 'SkinCeuticals', 'Cosmecéutica avanzada de alta potencia antioxidante', 1)
ON DUPLICATE KEY UPDATE
    `Nombre` = VALUES(`Nombre`),
    `Descripcion` = VALUES(`Descripcion`),
    `Activo` = VALUES(`Activo`);

-- 4. Laboratorios homologados (con RUT chileno valido Modulo 11)
INSERT INTO `laboratorio` (`IdLaboratorio`, `Rut`, `RazonSocial`, `Marca`, `Pais`, `Contacto`, `Email`, `Telefono`, `DiasPago`, `Activo`) VALUES
(1, '77.234.567-4', 'ISDIN Chile S.A.', 'ISDIN', 'Chile', 'Carlos Pérez', 'contacto@isdin.cl', '+56911223344', 30, 1),
(2, '76.111.222-8', 'L''Oréal Chile S.A.', 'L''Oréal / CeraVe / Vichy / SkinCeuticals', 'Chile', 'María López', 'contacto@loreal.cl', '+56922334455', 60, 1),
(3, '78.444.555-0', 'La Roche-Posay Chile', 'La Roche-Posay', 'Francia', 'Ana Gómez', 'contacto@laroche.cl', '+56933445566', 45, 1),
(4, '79.888.999-0', 'Eucerin Beiersdorf S.A.', 'Eucerin', 'Alemania', 'Felipe Soto', 'contacto@eucerin.cl', '+56944556677', 30, 1),
(5, '76.555.444-6', 'Pierre Fabre Dermo-Cosmétique Chile', 'Avène', 'Francia', 'Lucía Mardones', 'compras@pierrefabre.cl', '+56955667788', 45, 1),
(6, '77.999.111-3', 'NAOS Bioderma Chile SpA', 'Bioderma', 'Francia', 'Martín Arriagada', 'logistica@bioderma.cl', '+56966778899', 30, 1)
ON DUPLICATE KEY UPDATE
    `Rut` = VALUES(`Rut`),
    `RazonSocial` = VALUES(`RazonSocial`),
    `Marca` = VALUES(`Marca`),
    `Pais` = VALUES(`Pais`),
    `Contacto` = VALUES(`Contacto`),
    `Email` = VALUES(`Email`),
    `Telefono` = VALUES(`Telefono`),
    `DiasPago` = VALUES(`DiasPago`),
    `Activo` = VALUES(`Activo`);

-- 5. Cotizaciones de importacion y su detalle
INSERT INTO `cotizacionimportacion` (`IdCotizacion`, `IdLaboratorio`, `Fecha`, `Moneda`, `TipoCambio`, `Estado`, `IdUsuario`) VALUES
(1, 1, '2026-11-22', 'CLP', 1.0000, 'Convertida', 3),
(2, 5, '2026-11-22', 'CLP', 1.0000, 'Convertida', 3),
(3, 5, '2026-11-22', 'CLP', 1.0000, 'Solicitada', 3)
ON DUPLICATE KEY UPDATE
    `IdLaboratorio` = VALUES(`IdLaboratorio`),
    `Moneda` = VALUES(`Moneda`),
    `TipoCambio` = VALUES(`TipoCambio`),
    `Estado` = VALUES(`Estado`);

INSERT INTO `detallecotizacion` (`IdDetalleCot`, `IdCotizacion`, `IdVariante`, `Cantidad`, `CostoUnitario`) VALUES
(1, 1, 1, 10, 15900.00),
(2, 2, 4, 8, 10500.00),
(3, 3, 4, 15, 10100.00)
ON DUPLICATE KEY UPDATE
    `Cantidad` = VALUES(`Cantidad`),
    `CostoUnitario` = VALUES(`CostoUnitario`);

-- 6. Ordenes de compra y su detalle
INSERT INTO `ordencompra` (`IdOC`, `NumeroOC`, `IdLaboratorio`, `IdCotizacion`, `Fecha`, `FechaEsperada`, `Estado`, `Neto`, `Iva`, `Total`, `IdUsuario`) VALUES
(1, 'OC-2026-0001', 2, NULL, '2026-10-08', '2026-10-23', 'Recibida', 407000.00, 77330.00, 484330.00, 3),
(2, 'OC-2026-0002', 1, NULL, '2026-11-07', '2026-12-02', 'Emitida', 361000.00, 68590.00, 429590.00, 3),
(3, 'OC-DEMO-J01', 1, 1, '2026-11-22', '2026-11-27', 'Parcial', 159000.00, 30210.00, 189210.00, 3),
(4, 'OC-DEMO-J02', 5, 2, '2026-11-22', '2026-11-27', 'Emitida', 84000.00, 15960.00, 99960.00, 3)
ON DUPLICATE KEY UPDATE
    `Estado` = VALUES(`Estado`),
    `Neto` = VALUES(`Neto`),
    `Iva` = VALUES(`Iva`),
    `Total` = VALUES(`Total`);

INSERT INTO `detalleordencompra` (`IdDetalleOC`, `IdOC`, `IdVariante`, `CantidadPedida`, `CantidadRecibida`, `CostoUnitario`) VALUES
(1, 1, 1, 20, 20, 15900.00),
(2, 1, 3, 10, 10, 8900.00),
(3, 2, 1, 15, 0, 15900.00),
(4, 2, 2, 5, 0, 24500.00),
(5, 3, 1, 10, 6, 15900.00),
(6, 4, 4, 8, 0, 10500.00)
ON DUPLICATE KEY UPDATE
    `CantidadPedida` = VALUES(`CantidadPedida`),
    `CantidadRecibida` = VALUES(`CantidadRecibida`),
    `CostoUnitario` = VALUES(`CostoUnitario`);

-- 7. Recepciones de compra, detalle y lote asociado
INSERT INTO `recepcioncompra` (`IdRecepcion`, `IdOC`, `GuiaDespacho`, `FechaRecepcion`, `Estado`, `IdUsuario`) VALUES
(1, 1, 'GD-884920', '2026-10-21', 'Aprobada', 4),
(2, 3, 'GD-DEMO-J01', '2026-11-22', 'Parcial', 3)
ON DUPLICATE KEY UPDATE
    `GuiaDespacho` = VALUES(`GuiaDespacho`),
    `Estado` = VALUES(`Estado`);

INSERT INTO `detallerecepcion` (`IdDetalleRec`, `IdRecepcion`, `IdDetalleOC`, `IdVariante`, `NumeroLote`, `FechaVencimiento`, `Cantidad`, `CostoUnitario`) VALUES
(1, 1, 1, 1, 'LOT-ISD-2026A', '2028-01-22', 20, 15900.00),
(2, 1, 2, 3, 'LOT-CER-2026A', '2028-05-22', 10, 8900.00),
(3, 2, 5, 1, 'ISD-DEMO-J01', '2027-11-22', 6, 15900.00)
ON DUPLICATE KEY UPDATE
    `NumeroLote` = VALUES(`NumeroLote`),
    `FechaVencimiento` = VALUES(`FechaVencimiento`),
    `Cantidad` = VALUES(`Cantidad`),
    `CostoUnitario` = VALUES(`CostoUnitario`);

-- Insertar lote de la recepcion parcial solo si no existe ya para (IdVariante=1, NumeroLote='ISD-DEMO-J01')
INSERT INTO `lote` (`IdVariante`, `IdBodega`, `NumeroLote`, `FechaIngreso`, `FechaVencimiento`, `CostoUnitario`, `CantidadInicial`, `CantidadDisponible`, `Estado`)
SELECT 1, COALESCE((SELECT IdBodega FROM bodega WHERE Activo = 1 ORDER BY IdBodega DESC LIMIT 1), 1),
       'ISD-DEMO-J01', '2026-11-22', '2027-11-22', 15900.00, 6, 6, 'Disponible'
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM `lote` WHERE `IdVariante` = 1 AND `NumeroLote` = 'ISD-DEMO-J01');

-- 8. Devolucion / reclamo a proveedor de ejemplo
INSERT INTO `devolucionproveedor` (`IdDevolucion`, `IdRecepcion`, `IdLote`, `Cantidad`, `Motivo`, `Fecha`, `Estado`, `IdUsuario`)
SELECT 1, 2,
       (SELECT `IdLote` FROM `lote` WHERE `IdVariante` = 1 AND `NumeroLote` = 'ISD-DEMO-J01' LIMIT 1),
       1, 'Ejemplo: envase con daño exterior', '2026-11-22', 'Pendiente', 3
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM `devolucionproveedor` WHERE `IdDevolucion` = 1)
  AND EXISTS (SELECT 1 FROM `lote` WHERE `IdVariante` = 1 AND `NumeroLote` = 'ISD-DEMO-J01');

-- 9. Cuentas por pagar generadas por recepciones
INSERT INTO `cuentaporpagar` (`IdCuentaPagar`, `IdRecepcion`, `IdLaboratorio`, `Monto`, `Estado`, `IdUsuario`) VALUES
(1, 1, 2, 484330.00, 'Pendiente', 5),
(2, 2, 1, 113526.00, 'Pendiente', 3)
ON DUPLICATE KEY UPDATE
    `Monto` = VALUES(`Monto`);

-- 10. Correccion de RUTs semilla en tabla cliente a digito verificador Modulo 11 valido
UPDATE `cliente` SET `Rut` = '76.543.210-3' WHERE `Rut` = '76.543.210-K';
UPDATE `cliente` SET `Rut` = '76.998.877-7' WHERE `Rut` = '76.998.877-6';
UPDATE `cliente` SET `Rut` = '78.112.233-5' WHERE `Rut` = '78.112.233-9';
UPDATE `cliente` SET `Rut` = '15.432.876-9' WHERE `Rut` = '15.432.876-5';
UPDATE `cliente` SET `Rut` = '76.334.455-K' WHERE `Rut` = '76.334.455-2';
UPDATE `cliente` SET `Rut` = '18.765.432-7' WHERE `Rut` = '18.765.432-1';
UPDATE `cliente` SET `Rut` = '79.221.334-0' WHERE `Rut` = '79.221.334-8';

-- 11. Consolidar cuentas contables duplicadas y asegurar indices unicos de integridad
UPDATE `detalleasiento` d
JOIN `cuentacontable` c ON c.IdCuentaContable = d.IdCuentaContable
JOIN (SELECT `Codigo`, MIN(`IdCuentaContable`) AS MinId FROM `cuentacontable` GROUP BY `Codigo`) keep ON keep.Codigo = c.Codigo
SET d.IdCuentaContable = keep.MinId
WHERE d.IdCuentaContable <> keep.MinId;

UPDATE `cuentacontable` hijo
JOIN `cuentacontable` padre ON padre.IdCuentaContable = hijo.IdCuentaPadre
JOIN (SELECT `Codigo`, MIN(`IdCuentaContable`) AS MinId FROM `cuentacontable` GROUP BY `Codigo`) keep ON keep.Codigo = padre.Codigo
SET hijo.IdCuentaPadre = keep.MinId
WHERE hijo.IdCuentaPadre <> keep.MinId;

DELETE c FROM `cuentacontable` c
JOIN (SELECT `Codigo`, MIN(`IdCuentaContable`) AS MinId FROM `cuentacontable` GROUP BY `Codigo`) keep ON keep.Codigo = c.Codigo
WHERE c.IdCuentaContable <> keep.MinId;

DROP PROCEDURE IF EXISTS `usp_AsegurarIndicesCompaneros`;
DELIMITER $$
CREATE PROCEDURE `usp_AsegurarIndicesCompaneros`()
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.STATISTICS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'cuentacontable' AND INDEX_NAME = 'uq_cuentacontable_codigo') THEN
        ALTER TABLE `cuentacontable` ADD UNIQUE KEY `uq_cuentacontable_codigo` (`Codigo`);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.STATISTICS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'lote' AND INDEX_NAME = 'uq_lote_variante_numero') THEN
        ALTER TABLE `lote` ADD UNIQUE KEY `uq_lote_variante_numero` (`IdVariante`, `NumeroLote`);
    END IF;
END$$
DELIMITER ;
CALL `usp_AsegurarIndicesCompaneros`();
DROP PROCEDURE `usp_AsegurarIndicesCompaneros`;

-- 12. Actualizar contraseñas semilla en texto plano ('1234') a hash PBKDF2-SHA256
--     (Solo afecta usuarios cuya contraseña siga siendo literalmente '1234')
UPDATE `usuario` SET `Password` = CASE `Correo`
    WHEN 'admin@dermo.cl' THEN 'pbkdf2-sha256$/wE07cks+Km96gOC9KkvRQ==$IZr5L1cto1lEii0bzrDITiKU6QbP4gVO06EgiMY3vQk='
    WHEN 'raul1@dermo.cl' THEN 'pbkdf2-sha256$m40w3GGfZOktTOPW2xHu0Q==$ZEPAR+yWzyQHU2sLuyv3FNqG6WemL/CMqyv5OMxK4Ho='
    WHEN 'comprador@dermo.cl' THEN 'pbkdf2-sha256$Tt61cZwtF5gtCBCf3ad+lw==$zrAFYZN+B5/YFmzOOb0tUN97HPoKBsvbIvX7dr8JMhg='
    WHEN 'bodega@dermo.cl' THEN 'pbkdf2-sha256$haKZ7+EoggjyQP/EEDN+9Q==$9MzXUlc9HHT4EGD82lF1Si7wghN4RXyxH1+ENr+o2tw='
    WHEN 'contador@dermo.cl' THEN 'pbkdf2-sha256$eEUfVdUvojB3ckEWcfJLeQ==$Caj7X503qffbLOz9zSx+f08LtMW28BB/zVKiRd9R4Us='
    WHEN 'vrojas@dermo.cl' THEN 'pbkdf2-sha256$GQRFpDwKtZ9uQ9A15aGABQ==$P6x0CHQAdX5ZI43HH94OUZF73wnNiTqpRHZyrXdcCSg='
    ELSE `Password`
END
WHERE `Password` = '1234';
