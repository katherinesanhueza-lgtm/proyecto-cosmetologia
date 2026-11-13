-- =========================================================================
-- MIGRACIÓN 006: Requerimientos Funcionales del Módulo de Ventas (RF-VEN-01 al RF-VEN-10)
-- Dermo ERP - Cosmecéutica y Dermocosmética
-- =========================================================================

-- 1. RF-VEN-01 y RF-VEN-07: Ampliación de la tabla Cliente (Giro, Dirección, Contacto, Límites de Crédito, Activo)
ALTER TABLE `cliente` ADD COLUMN IF NOT EXISTS `RazonSocial` VARCHAR(150) NULL;
ALTER TABLE `cliente` ADD COLUMN IF NOT EXISTS `Giro` VARCHAR(150) NULL;
ALTER TABLE `cliente` ADD COLUMN IF NOT EXISTS `Direccion` VARCHAR(200) NULL;
ALTER TABLE `cliente` ADD COLUMN IF NOT EXISTS `Contacto` VARCHAR(100) NULL;
ALTER TABLE `cliente` ADD COLUMN IF NOT EXISTS `LimiteCredito` DECIMAL(18,2) NOT NULL DEFAULT 0.00;
ALTER TABLE `cliente` ADD COLUMN IF NOT EXISTS `DiasCredito` INT NOT NULL DEFAULT 0;
ALTER TABLE `cliente` ADD COLUMN IF NOT EXISTS `Activo` TINYINT(1) NOT NULL DEFAULT 1;

-- Actualizar RazonSocial con el Nombre existente si está vacía
UPDATE `cliente` SET `RazonSocial` = `Nombre` WHERE `RazonSocial` IS NULL OR `RazonSocial` = '';

-- 2. RF-VEN-02: Período de Validez para Cotizaciones / Presupuestos
ALTER TABLE `cotizacion` ADD COLUMN IF NOT EXISTS `FechaVencimiento` DATE NULL;

-- 3. RF-VEN-03: Folio, Descuento, Neto, IVA y Forma de Pago en Venta
ALTER TABLE `venta` ADD COLUMN IF NOT EXISTS `Folio` VARCHAR(50) NULL;
ALTER TABLE `venta` ADD COLUMN IF NOT EXISTS `Neto` DECIMAL(18,2) NOT NULL DEFAULT 0.00;
ALTER TABLE `venta` ADD COLUMN IF NOT EXISTS `Iva` DECIMAL(18,2) NOT NULL DEFAULT 0.00;
ALTER TABLE `venta` ADD COLUMN IF NOT EXISTS `Descuento` DECIMAL(18,2) NOT NULL DEFAULT 0.00;
ALTER TABLE `venta` ADD COLUMN IF NOT EXISTS `FormaPago` VARCHAR(50) NOT NULL DEFAULT 'Contado';
ALTER TABLE `venta` ADD COLUMN IF NOT EXISTS `IdVentaOrigen` INT NULL;

-- 4. RF-VEN-08: Gestión de Despachos y Registro de Entregas
ALTER TABLE `despacho` ADD COLUMN IF NOT EXISTS `FechaEntrega` DATE NULL;
ALTER TABLE `despacho` ADD COLUMN IF NOT EXISTS `Observaciones` VARCHAR(255) NULL;

-- 5. RF-VEN-06: Plan de Cuentas Contable para Ventas (cuentacontable)
INSERT IGNORE INTO `cuentacontable` (`Codigo`, `Nombre`, `Tipo`, `IdCuentaPadre`, `Nivel`, `Imputable`) VALUES
('1103', 'Clientes por Cobrar', 'Activo', NULL, 1, 1),
('2108', 'IVA Débito Fiscal', 'Pasivo', NULL, 1, 1),
('4101', 'Ingresos por Ventas', 'Resultado Ganancia', NULL, 1, 1),
('5101', 'Costo de Ventas', 'Resultado Pérdida', NULL, 1, 1);

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
