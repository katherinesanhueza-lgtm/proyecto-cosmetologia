-- Ejecutar con la base del ERP seleccionada. Conserva los documentos existentes.
INSERT INTO configuracionglobal(Clave,Valor,Descripcion) SELECT 'TipoCambioEUR','1020','CLP por EUR. Referencia inicial editable, pendiente de sincronizar' FROM DUAL WHERE NOT EXISTS(SELECT 1 FROM configuracionglobal WHERE Clave='TipoCambioEUR');
DELETE FROM configuracionglobal WHERE Clave IN ('TipoCambioARG','TipoCambioARS');

CREATE TABLE IF NOT EXISTS cobrocliente (
 IdCobro INT PRIMARY KEY AUTO_INCREMENT,
 IdCuenta INT NOT NULL, IdAsiento INT NOT NULL UNIQUE, IdUsuario INT NOT NULL,
 Fecha DATE NOT NULL, Medio VARCHAR(30) NOT NULL, Monto DECIMAL(18,2) NOT NULL,
 Solicitud CHAR(36) NOT NULL UNIQUE,
 FOREIGN KEY(IdCuenta) REFERENCES cuentascobrar(IdCuenta),
 FOREIGN KEY(IdAsiento) REFERENCES asientocontable(IdAsiento),
 FOREIGN KEY(IdUsuario) REFERENCES usuario(IdUsuario)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS secuenciafolio (
 TipoDocumento VARCHAR(50) PRIMARY KEY, Ultimo BIGINT NOT NULL
) ENGINE=InnoDB;
INSERT INTO secuenciafolio(TipoDocumento,Ultimo)
SELECT TipoDocumento,MAX(CAST(SUBSTRING_INDEX(Folio,'-',-1) AS UNSIGNED))
FROM venta WHERE Folio REGEXP '^[A-Za-z]+-[0-9]+$' GROUP BY TipoDocumento
ON DUPLICATE KEY UPDATE Ultimo=GREATEST(Ultimo,VALUES(Ultimo));

DROP PROCEDURE IF EXISTS usp_ConfigurarFolios;
DELIMITER $$
CREATE PROCEDURE usp_ConfigurarFolios()
BEGIN
 IF NOT EXISTS(SELECT 1 FROM information_schema.statistics WHERE table_schema=DATABASE()
 AND table_name='venta' AND index_name='uq_venta_documento_folio') THEN
   ALTER TABLE venta ADD UNIQUE KEY uq_venta_documento_folio(TipoDocumento,Folio);
 END IF;
END$$
DELIMITER ;
CALL usp_ConfigurarFolios();
DROP PROCEDURE usp_ConfigurarFolios;

DROP PROCEDURE IF EXISTS usp_IngresarRecepcionCompra;
DELIMITER $$
CREATE PROCEDURE usp_IngresarRecepcionCompra(IN v INT, IN b INT, IN d INT, IN u INT,
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
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS usp_RegistrarCobro;
DELIMITER $$
CREATE PROCEDURE usp_RegistrarCobro(IN cuenta INT, IN importe DECIMAL(18,2), IN medioPago VARCHAR(30),
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
END$$
DELIMITER ;

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
END $$
DELIMITER ;

CREATE TABLE IF NOT EXISTS auditoriaerp (
 IdEvento BIGINT PRIMARY KEY AUTO_INCREMENT, Fecha DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
 IdUsuario INT NULL, Modulo VARCHAR(24) NOT NULL, Entidad VARCHAR(48) NOT NULL,
 Accion VARCHAR(12) NOT NULL, Registro BIGINT NOT NULL,
 INDEX ix_auditoria_fecha(Fecha), INDEX ix_auditoria_usuario(IdUsuario)
) ENGINE=InnoDB;
DROP PROCEDURE IF EXISTS usp_UsuarioAuditoria;
CREATE PROCEDURE usp_UsuarioAuditoria(IN actor INT) SET @erp_actor=actor;
DROP TRIGGER IF EXISTS aud_laboratorio_insert;
CREATE TRIGGER aud_laboratorio_insert AFTER INSERT ON laboratorio FOR EACH ROW INSERT INTO auditoriaerp(IdUsuario,Modulo,Entidad,Accion,Registro) VALUES (@erp_actor,'Compras','laboratorio','INSERT',NEW.IdLaboratorio);
DROP TRIGGER IF EXISTS aud_laboratorio_update;
CREATE TRIGGER aud_laboratorio_update AFTER UPDATE ON laboratorio FOR EACH ROW INSERT INTO auditoriaerp(IdUsuario,Modulo,Entidad,Accion,Registro) VALUES (@erp_actor,'Compras','laboratorio','UPDATE',NEW.IdLaboratorio);
DROP TRIGGER IF EXISTS aud_laboratorio_delete;
CREATE TRIGGER aud_laboratorio_delete AFTER DELETE ON laboratorio FOR EACH ROW INSERT INTO auditoriaerp(IdUsuario,Modulo,Entidad,Accion,Registro) VALUES (@erp_actor,'Compras','laboratorio','DELETE',OLD.IdLaboratorio);
DROP TRIGGER IF EXISTS aud_marca_insert;
CREATE TRIGGER aud_marca_insert AFTER INSERT ON marca FOR EACH ROW INSERT INTO auditoriaerp(IdUsuario,Modulo,Entidad,Accion,Registro) VALUES (@erp_actor,'Compras','marca','INSERT',NEW.IdMarca);
DROP TRIGGER IF EXISTS aud_marca_update;
CREATE TRIGGER aud_marca_update AFTER UPDATE ON marca FOR EACH ROW INSERT INTO auditoriaerp(IdUsuario,Modulo,Entidad,Accion,Registro) VALUES (@erp_actor,'Compras','marca','UPDATE',NEW.IdMarca);
DROP TRIGGER IF EXISTS aud_marca_delete;
CREATE TRIGGER aud_marca_delete AFTER DELETE ON marca FOR EACH ROW INSERT INTO auditoriaerp(IdUsuario,Modulo,Entidad,Accion,Registro) VALUES (@erp_actor,'Compras','marca','DELETE',OLD.IdMarca);
DROP TRIGGER IF EXISTS aud_cotizacionimportacion_insert;
CREATE TRIGGER aud_cotizacionimportacion_insert AFTER INSERT ON cotizacionimportacion FOR EACH ROW INSERT INTO auditoriaerp(IdUsuario,Modulo,Entidad,Accion,Registro) VALUES (@erp_actor,'Compras','cotizacionimportacion','INSERT',NEW.IdCotizacion);
DROP TRIGGER IF EXISTS aud_cotizacionimportacion_update;
CREATE TRIGGER aud_cotizacionimportacion_update AFTER UPDATE ON cotizacionimportacion FOR EACH ROW INSERT INTO auditoriaerp(IdUsuario,Modulo,Entidad,Accion,Registro) VALUES (@erp_actor,'Compras','cotizacionimportacion','UPDATE',NEW.IdCotizacion);
DROP TRIGGER IF EXISTS aud_cotizacionimportacion_delete;
CREATE TRIGGER aud_cotizacionimportacion_delete AFTER DELETE ON cotizacionimportacion FOR EACH ROW INSERT INTO auditoriaerp(IdUsuario,Modulo,Entidad,Accion,Registro) VALUES (@erp_actor,'Compras','cotizacionimportacion','DELETE',OLD.IdCotizacion);
DROP TRIGGER IF EXISTS aud_ordencompra_insert;
CREATE TRIGGER aud_ordencompra_insert AFTER INSERT ON ordencompra FOR EACH ROW INSERT INTO auditoriaerp(IdUsuario,Modulo,Entidad,Accion,Registro) VALUES (@erp_actor,'Compras','ordencompra','INSERT',NEW.IdOC);
DROP TRIGGER IF EXISTS aud_ordencompra_update;
CREATE TRIGGER aud_ordencompra_update AFTER UPDATE ON ordencompra FOR EACH ROW INSERT INTO auditoriaerp(IdUsuario,Modulo,Entidad,Accion,Registro) VALUES (@erp_actor,'Compras','ordencompra','UPDATE',NEW.IdOC);
DROP TRIGGER IF EXISTS aud_ordencompra_delete;
CREATE TRIGGER aud_ordencompra_delete AFTER DELETE ON ordencompra FOR EACH ROW INSERT INTO auditoriaerp(IdUsuario,Modulo,Entidad,Accion,Registro) VALUES (@erp_actor,'Compras','ordencompra','DELETE',OLD.IdOC);
DROP TRIGGER IF EXISTS aud_recepcioncompra_insert;
CREATE TRIGGER aud_recepcioncompra_insert AFTER INSERT ON recepcioncompra FOR EACH ROW INSERT INTO auditoriaerp(IdUsuario,Modulo,Entidad,Accion,Registro) VALUES (@erp_actor,'Compras','recepcioncompra','INSERT',NEW.IdRecepcion);
DROP TRIGGER IF EXISTS aud_recepcioncompra_update;
CREATE TRIGGER aud_recepcioncompra_update AFTER UPDATE ON recepcioncompra FOR EACH ROW INSERT INTO auditoriaerp(IdUsuario,Modulo,Entidad,Accion,Registro) VALUES (@erp_actor,'Compras','recepcioncompra','UPDATE',NEW.IdRecepcion);
DROP TRIGGER IF EXISTS aud_recepcioncompra_delete;
CREATE TRIGGER aud_recepcioncompra_delete AFTER DELETE ON recepcioncompra FOR EACH ROW INSERT INTO auditoriaerp(IdUsuario,Modulo,Entidad,Accion,Registro) VALUES (@erp_actor,'Compras','recepcioncompra','DELETE',OLD.IdRecepcion);
DROP TRIGGER IF EXISTS aud_devolucionproveedor_insert;
CREATE TRIGGER aud_devolucionproveedor_insert AFTER INSERT ON devolucionproveedor FOR EACH ROW INSERT INTO auditoriaerp(IdUsuario,Modulo,Entidad,Accion,Registro) VALUES (@erp_actor,'Compras','devolucionproveedor','INSERT',NEW.IdDevolucion);
DROP TRIGGER IF EXISTS aud_devolucionproveedor_update;
CREATE TRIGGER aud_devolucionproveedor_update AFTER UPDATE ON devolucionproveedor FOR EACH ROW INSERT INTO auditoriaerp(IdUsuario,Modulo,Entidad,Accion,Registro) VALUES (@erp_actor,'Compras','devolucionproveedor','UPDATE',NEW.IdDevolucion);
DROP TRIGGER IF EXISTS aud_devolucionproveedor_delete;
CREATE TRIGGER aud_devolucionproveedor_delete AFTER DELETE ON devolucionproveedor FOR EACH ROW INSERT INTO auditoriaerp(IdUsuario,Modulo,Entidad,Accion,Registro) VALUES (@erp_actor,'Compras','devolucionproveedor','DELETE',OLD.IdDevolucion);
DROP TRIGGER IF EXISTS aud_cliente_insert;
CREATE TRIGGER aud_cliente_insert AFTER INSERT ON cliente FOR EACH ROW INSERT INTO auditoriaerp(IdUsuario,Modulo,Entidad,Accion,Registro) VALUES (@erp_actor,'Ventas','cliente','INSERT',NEW.IdCliente);
DROP TRIGGER IF EXISTS aud_cliente_update;
CREATE TRIGGER aud_cliente_update AFTER UPDATE ON cliente FOR EACH ROW INSERT INTO auditoriaerp(IdUsuario,Modulo,Entidad,Accion,Registro) VALUES (@erp_actor,'Ventas','cliente','UPDATE',NEW.IdCliente);
DROP TRIGGER IF EXISTS aud_cliente_delete;
CREATE TRIGGER aud_cliente_delete AFTER DELETE ON cliente FOR EACH ROW INSERT INTO auditoriaerp(IdUsuario,Modulo,Entidad,Accion,Registro) VALUES (@erp_actor,'Ventas','cliente','DELETE',OLD.IdCliente);
DROP TRIGGER IF EXISTS aud_cotizacion_insert;
CREATE TRIGGER aud_cotizacion_insert AFTER INSERT ON cotizacion FOR EACH ROW INSERT INTO auditoriaerp(IdUsuario,Modulo,Entidad,Accion,Registro) VALUES (@erp_actor,'Ventas','cotizacion','INSERT',NEW.IdCotizacion);
DROP TRIGGER IF EXISTS aud_cotizacion_update;
CREATE TRIGGER aud_cotizacion_update AFTER UPDATE ON cotizacion FOR EACH ROW INSERT INTO auditoriaerp(IdUsuario,Modulo,Entidad,Accion,Registro) VALUES (@erp_actor,'Ventas','cotizacion','UPDATE',NEW.IdCotizacion);
DROP TRIGGER IF EXISTS aud_cotizacion_delete;
CREATE TRIGGER aud_cotizacion_delete AFTER DELETE ON cotizacion FOR EACH ROW INSERT INTO auditoriaerp(IdUsuario,Modulo,Entidad,Accion,Registro) VALUES (@erp_actor,'Ventas','cotizacion','DELETE',OLD.IdCotizacion);
DROP TRIGGER IF EXISTS aud_venta_insert;
CREATE TRIGGER aud_venta_insert AFTER INSERT ON venta FOR EACH ROW INSERT INTO auditoriaerp(IdUsuario,Modulo,Entidad,Accion,Registro) VALUES (@erp_actor,'Ventas','venta','INSERT',NEW.IdVenta);
DROP TRIGGER IF EXISTS aud_venta_update;
CREATE TRIGGER aud_venta_update AFTER UPDATE ON venta FOR EACH ROW INSERT INTO auditoriaerp(IdUsuario,Modulo,Entidad,Accion,Registro) VALUES (@erp_actor,'Ventas','venta','UPDATE',NEW.IdVenta);
DROP TRIGGER IF EXISTS aud_venta_delete;
CREATE TRIGGER aud_venta_delete AFTER DELETE ON venta FOR EACH ROW INSERT INTO auditoriaerp(IdUsuario,Modulo,Entidad,Accion,Registro) VALUES (@erp_actor,'Ventas','venta','DELETE',OLD.IdVenta);
DROP TRIGGER IF EXISTS aud_despacho_insert;
CREATE TRIGGER aud_despacho_insert AFTER INSERT ON despacho FOR EACH ROW INSERT INTO auditoriaerp(IdUsuario,Modulo,Entidad,Accion,Registro) VALUES (@erp_actor,'Ventas','despacho','INSERT',NEW.IdDespacho);
DROP TRIGGER IF EXISTS aud_despacho_update;
CREATE TRIGGER aud_despacho_update AFTER UPDATE ON despacho FOR EACH ROW INSERT INTO auditoriaerp(IdUsuario,Modulo,Entidad,Accion,Registro) VALUES (@erp_actor,'Ventas','despacho','UPDATE',NEW.IdDespacho);
DROP TRIGGER IF EXISTS aud_despacho_delete;
CREATE TRIGGER aud_despacho_delete AFTER DELETE ON despacho FOR EACH ROW INSERT INTO auditoriaerp(IdUsuario,Modulo,Entidad,Accion,Registro) VALUES (@erp_actor,'Ventas','despacho','DELETE',OLD.IdDespacho);
DROP TRIGGER IF EXISTS aud_asientocontable_insert;
CREATE TRIGGER aud_asientocontable_insert AFTER INSERT ON asientocontable FOR EACH ROW INSERT INTO auditoriaerp(IdUsuario,Modulo,Entidad,Accion,Registro) VALUES (@erp_actor,'Contabilidad','asientocontable','INSERT',NEW.IdAsiento);
DROP TRIGGER IF EXISTS aud_asientocontable_update;
CREATE TRIGGER aud_asientocontable_update AFTER UPDATE ON asientocontable FOR EACH ROW INSERT INTO auditoriaerp(IdUsuario,Modulo,Entidad,Accion,Registro) VALUES (@erp_actor,'Contabilidad','asientocontable','UPDATE',NEW.IdAsiento);
DROP TRIGGER IF EXISTS aud_asientocontable_delete;
CREATE TRIGGER aud_asientocontable_delete AFTER DELETE ON asientocontable FOR EACH ROW INSERT INTO auditoriaerp(IdUsuario,Modulo,Entidad,Accion,Registro) VALUES (@erp_actor,'Contabilidad','asientocontable','DELETE',OLD.IdAsiento);
DROP TRIGGER IF EXISTS aud_periodocontable_insert;
CREATE TRIGGER aud_periodocontable_insert AFTER INSERT ON periodocontable FOR EACH ROW INSERT INTO auditoriaerp(IdUsuario,Modulo,Entidad,Accion,Registro) VALUES (@erp_actor,'Contabilidad','periodocontable','INSERT',NEW.IdPeriodo);
DROP TRIGGER IF EXISTS aud_periodocontable_update;
CREATE TRIGGER aud_periodocontable_update AFTER UPDATE ON periodocontable FOR EACH ROW INSERT INTO auditoriaerp(IdUsuario,Modulo,Entidad,Accion,Registro) VALUES (@erp_actor,'Contabilidad','periodocontable','UPDATE',NEW.IdPeriodo);
DROP TRIGGER IF EXISTS aud_periodocontable_delete;
CREATE TRIGGER aud_periodocontable_delete AFTER DELETE ON periodocontable FOR EACH ROW INSERT INTO auditoriaerp(IdUsuario,Modulo,Entidad,Accion,Registro) VALUES (@erp_actor,'Contabilidad','periodocontable','DELETE',OLD.IdPeriodo);
DROP TRIGGER IF EXISTS aud_cuentacontable_insert;
CREATE TRIGGER aud_cuentacontable_insert AFTER INSERT ON cuentacontable FOR EACH ROW INSERT INTO auditoriaerp(IdUsuario,Modulo,Entidad,Accion,Registro) VALUES (@erp_actor,'Contabilidad','cuentacontable','INSERT',NEW.IdCuentaContable);
DROP TRIGGER IF EXISTS aud_cuentacontable_update;
CREATE TRIGGER aud_cuentacontable_update AFTER UPDATE ON cuentacontable FOR EACH ROW INSERT INTO auditoriaerp(IdUsuario,Modulo,Entidad,Accion,Registro) VALUES (@erp_actor,'Contabilidad','cuentacontable','UPDATE',NEW.IdCuentaContable);
DROP TRIGGER IF EXISTS aud_cuentacontable_delete;
CREATE TRIGGER aud_cuentacontable_delete AFTER DELETE ON cuentacontable FOR EACH ROW INSERT INTO auditoriaerp(IdUsuario,Modulo,Entidad,Accion,Registro) VALUES (@erp_actor,'Contabilidad','cuentacontable','DELETE',OLD.IdCuentaContable);
DROP TRIGGER IF EXISTS aud_cuentaporpagar_insert;
CREATE TRIGGER aud_cuentaporpagar_insert AFTER INSERT ON cuentaporpagar FOR EACH ROW INSERT INTO auditoriaerp(IdUsuario,Modulo,Entidad,Accion,Registro) VALUES (@erp_actor,'Contabilidad','cuentaporpagar','INSERT',NEW.IdCuentaPagar);
DROP TRIGGER IF EXISTS aud_cuentaporpagar_update;
CREATE TRIGGER aud_cuentaporpagar_update AFTER UPDATE ON cuentaporpagar FOR EACH ROW INSERT INTO auditoriaerp(IdUsuario,Modulo,Entidad,Accion,Registro) VALUES (@erp_actor,'Contabilidad','cuentaporpagar','UPDATE',NEW.IdCuentaPagar);
DROP TRIGGER IF EXISTS aud_cuentaporpagar_delete;
CREATE TRIGGER aud_cuentaporpagar_delete AFTER DELETE ON cuentaporpagar FOR EACH ROW INSERT INTO auditoriaerp(IdUsuario,Modulo,Entidad,Accion,Registro) VALUES (@erp_actor,'Contabilidad','cuentaporpagar','DELETE',OLD.IdCuentaPagar);
DROP TRIGGER IF EXISTS aud_cuentascobrar_insert;
CREATE TRIGGER aud_cuentascobrar_insert AFTER INSERT ON cuentascobrar FOR EACH ROW INSERT INTO auditoriaerp(IdUsuario,Modulo,Entidad,Accion,Registro) VALUES (@erp_actor,'Contabilidad','cuentascobrar','INSERT',NEW.IdCuenta);
DROP TRIGGER IF EXISTS aud_cuentascobrar_update;
CREATE TRIGGER aud_cuentascobrar_update AFTER UPDATE ON cuentascobrar FOR EACH ROW INSERT INTO auditoriaerp(IdUsuario,Modulo,Entidad,Accion,Registro) VALUES (@erp_actor,'Contabilidad','cuentascobrar','UPDATE',NEW.IdCuenta);
DROP TRIGGER IF EXISTS aud_cuentascobrar_delete;
CREATE TRIGGER aud_cuentascobrar_delete AFTER DELETE ON cuentascobrar FOR EACH ROW INSERT INTO auditoriaerp(IdUsuario,Modulo,Entidad,Accion,Registro) VALUES (@erp_actor,'Contabilidad','cuentascobrar','DELETE',OLD.IdCuenta);
DROP TRIGGER IF EXISTS aud_pagoproveedor_insert;
CREATE TRIGGER aud_pagoproveedor_insert AFTER INSERT ON pagoproveedor FOR EACH ROW INSERT INTO auditoriaerp(IdUsuario,Modulo,Entidad,Accion,Registro) VALUES (@erp_actor,'Contabilidad','pagoproveedor','INSERT',NEW.IdPagoProveedor);
DROP TRIGGER IF EXISTS aud_pagoproveedor_update;
CREATE TRIGGER aud_pagoproveedor_update AFTER UPDATE ON pagoproveedor FOR EACH ROW INSERT INTO auditoriaerp(IdUsuario,Modulo,Entidad,Accion,Registro) VALUES (@erp_actor,'Contabilidad','pagoproveedor','UPDATE',NEW.IdPagoProveedor);
DROP TRIGGER IF EXISTS aud_pagoproveedor_delete;
CREATE TRIGGER aud_pagoproveedor_delete AFTER DELETE ON pagoproveedor FOR EACH ROW INSERT INTO auditoriaerp(IdUsuario,Modulo,Entidad,Accion,Registro) VALUES (@erp_actor,'Contabilidad','pagoproveedor','DELETE',OLD.IdPagoProveedor);
DROP TRIGGER IF EXISTS aud_cobrocliente_insert;
CREATE TRIGGER aud_cobrocliente_insert AFTER INSERT ON cobrocliente FOR EACH ROW INSERT INTO auditoriaerp(IdUsuario,Modulo,Entidad,Accion,Registro) VALUES (@erp_actor,'Contabilidad','cobrocliente','INSERT',NEW.IdCobro);
DROP TRIGGER IF EXISTS aud_cobrocliente_update;
CREATE TRIGGER aud_cobrocliente_update AFTER UPDATE ON cobrocliente FOR EACH ROW INSERT INTO auditoriaerp(IdUsuario,Modulo,Entidad,Accion,Registro) VALUES (@erp_actor,'Contabilidad','cobrocliente','UPDATE',NEW.IdCobro);
DROP TRIGGER IF EXISTS aud_cobrocliente_delete;
CREATE TRIGGER aud_cobrocliente_delete AFTER DELETE ON cobrocliente FOR EACH ROW INSERT INTO auditoriaerp(IdUsuario,Modulo,Entidad,Accion,Registro) VALUES (@erp_actor,'Contabilidad','cobrocliente','DELETE',OLD.IdCobro);
DROP TRIGGER IF EXISTS aud_declaracioniva_insert;
CREATE TRIGGER aud_declaracioniva_insert AFTER INSERT ON declaracioniva FOR EACH ROW INSERT INTO auditoriaerp(IdUsuario,Modulo,Entidad,Accion,Registro) VALUES (@erp_actor,'Contabilidad','declaracioniva','INSERT',NEW.IdDeclaracionIVA);
DROP TRIGGER IF EXISTS aud_declaracioniva_update;
CREATE TRIGGER aud_declaracioniva_update AFTER UPDATE ON declaracioniva FOR EACH ROW INSERT INTO auditoriaerp(IdUsuario,Modulo,Entidad,Accion,Registro) VALUES (@erp_actor,'Contabilidad','declaracioniva','UPDATE',NEW.IdDeclaracionIVA);
DROP TRIGGER IF EXISTS aud_declaracioniva_delete;
CREATE TRIGGER aud_declaracioniva_delete AFTER DELETE ON declaracioniva FOR EACH ROW INSERT INTO auditoriaerp(IdUsuario,Modulo,Entidad,Accion,Registro) VALUES (@erp_actor,'Contabilidad','declaracioniva','DELETE',OLD.IdDeclaracionIVA);
DROP TRIGGER IF EXISTS aud_usuario_insert;
CREATE TRIGGER aud_usuario_insert AFTER INSERT ON usuario FOR EACH ROW INSERT INTO auditoriaerp(IdUsuario,Modulo,Entidad,Accion,Registro) VALUES (@erp_actor,'Seguridad','usuario','INSERT',NEW.IdUsuario);
DROP TRIGGER IF EXISTS aud_usuario_update;
CREATE TRIGGER aud_usuario_update AFTER UPDATE ON usuario FOR EACH ROW INSERT INTO auditoriaerp(IdUsuario,Modulo,Entidad,Accion,Registro) VALUES (@erp_actor,'Seguridad','usuario','UPDATE',NEW.IdUsuario);
DROP TRIGGER IF EXISTS aud_usuario_delete;
CREATE TRIGGER aud_usuario_delete AFTER DELETE ON usuario FOR EACH ROW INSERT INTO auditoriaerp(IdUsuario,Modulo,Entidad,Accion,Registro) VALUES (@erp_actor,'Seguridad','usuario','DELETE',OLD.IdUsuario);
DROP TRIGGER IF EXISTS aud_rol_insert;
CREATE TRIGGER aud_rol_insert AFTER INSERT ON rol FOR EACH ROW INSERT INTO auditoriaerp(IdUsuario,Modulo,Entidad,Accion,Registro) VALUES (@erp_actor,'Seguridad','rol','INSERT',NEW.IdRol);
DROP TRIGGER IF EXISTS aud_rol_update;
CREATE TRIGGER aud_rol_update AFTER UPDATE ON rol FOR EACH ROW INSERT INTO auditoriaerp(IdUsuario,Modulo,Entidad,Accion,Registro) VALUES (@erp_actor,'Seguridad','rol','UPDATE',NEW.IdRol);
DROP TRIGGER IF EXISTS aud_rol_delete;
CREATE TRIGGER aud_rol_delete AFTER DELETE ON rol FOR EACH ROW INSERT INTO auditoriaerp(IdUsuario,Modulo,Entidad,Accion,Registro) VALUES (@erp_actor,'Seguridad','rol','DELETE',OLD.IdRol);
DROP TRIGGER IF EXISTS aud_impedir_edicion;
CREATE TRIGGER aud_impedir_edicion BEFORE UPDATE ON auditoriaerp FOR EACH ROW SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='La bitácora es de solo lectura';
DROP TRIGGER IF EXISTS aud_impedir_borrado;
CREATE TRIGGER aud_impedir_borrado BEFORE DELETE ON auditoriaerp FOR EACH ROW SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='La bitácora es de solo lectura';

CREATE TABLE IF NOT EXISTS devolucionlineaventa (
 IdDetalleNC INT PRIMARY KEY, IdDetalleOriginal INT NOT NULL,
 FOREIGN KEY(IdDetalleNC) REFERENCES ventadetalle(IdVentaDetalle),
 FOREIGN KEY(IdDetalleOriginal) REFERENCES ventadetalle(IdVentaDetalle)
) ENGINE=InnoDB;

DROP PROCEDURE IF EXISTS usp_AsientoAutomatico;
DELIMITER $$
CREATE PROCEDURE usp_AsientoAutomatico(IN origenDoc VARCHAR(20), IN documento INT, IN glosaDoc VARCHAR(255),
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
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS usp_CrearCuentaPorCobrar;
CREATE PROCEDURE usp_CrearCuentaPorCobrar(IN documento INT, IN vencimiento DATE, IN importe DECIMAL(18,2), IN responsable INT)
 INSERT INTO cuentascobrar(IdVenta,FechaVence,MontoPendiente,EstadoPago,IdUsuario)
 VALUES(documento,vencimiento,importe,'Pendiente',responsable);

DROP PROCEDURE IF EXISTS usp_AceptarDevolucionProveedor;
DELIMITER $$
CREATE PROCEDURE usp_AceptarDevolucionProveedor(IN reclamo INT, IN responsable INT)
BEGIN
 DECLARE loteId,bodegaId,variante,unidades,disponible,anterior,reservado,tipo,inv INT;
 DECLARE estadoActual VARCHAR(30);
 SELECT IdLote,Cantidad,Estado INTO loteId,unidades,estadoActual FROM devolucionproveedor WHERE IdDevolucion=reclamo FOR UPDATE;
 IF estadoActual IS NULL OR estadoActual NOT IN ('Pendiente','En Revisión') THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Este reclamo no está pendiente'; END IF;
 SELECT IdVariante,IdBodega,CantidadDisponible INTO variante,bodegaId,disponible FROM lote WHERE IdLote=loteId FOR UPDATE;
 SELECT IdInventario,StockActual,COALESCE(StockReservado,0) INTO inv,anterior,reservado FROM inventario WHERE IdVariante=variante AND IdBodega=bodegaId FOR UPDATE;
 SELECT MIN(IdTipoMovimiento) INTO tipo FROM tipomovimiento WHERE Nombre='Ajuste negativo';
 IF inv IS NULL OR tipo IS NULL OR unidades<=0 OR disponible<unidades OR anterior-reservado<unidades THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='El lote no tiene saldo disponible para el reclamo'; END IF;
 UPDATE lote SET Estado=IF(disponible=unidades,'Agotado',Estado),CantidadDisponible=disponible-unidades WHERE IdLote=loteId;
 UPDATE inventario SET StockActual=anterior-unidades,FechaActualizada=NOW() WHERE IdInventario=inv;
 UPDATE varianteproducto SET StockTotal=(SELECT SUM(StockActual) FROM inventario WHERE IdVariante=variante) WHERE IdVariante=variante;
 INSERT INTO movimientoinventario(IdLote,IdBodega,IdTipoMovimiento,IdUsuario,Cantidad,StockAnterior,StockPosterior,Referencia,Observacion,Origen,IdDetalleOrigen)
 SELECT loteId,bodegaId,tipo,responsable,unidades,anterior,anterior-unidades,CONCAT('DEV-',reclamo),LEFT(Motivo,255),'DevProveedor',reclamo FROM devolucionproveedor WHERE IdDevolucion=reclamo;
 UPDATE devolucionproveedor SET Estado='Aceptado' WHERE IdDevolucion=reclamo;
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS usp_DevolverVenta;
DELIMITER $$
CREATE PROCEDURE usp_DevolverVenta(IN ventaOrigen INT, IN responsable INT, IN folioNC VARCHAR(50), IN bodegaDestino INT, IN motivoDoc VARCHAR(255), IN articulos JSON)
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
END$$
DELIMITER ;

-- Consolidar cuentas contables duplicadas y garantizar índices únicos de integridad (RNF-08)
UPDATE detalleasiento d
JOIN cuentacontable c ON c.IdCuentaContable = d.IdCuentaContable
JOIN (SELECT Codigo, MIN(IdCuentaContable) AS MinId FROM cuentacontable GROUP BY Codigo) keep ON keep.Codigo = c.Codigo
SET d.IdCuentaContable = keep.MinId
WHERE d.IdCuentaContable <> keep.MinId;

UPDATE cuentacontable hijo
JOIN cuentacontable padre ON padre.IdCuentaContable = hijo.IdCuentaPadre
JOIN (SELECT Codigo, MIN(IdCuentaContable) AS MinId FROM cuentacontable GROUP BY Codigo) keep ON keep.Codigo = padre.Codigo
SET hijo.IdCuentaPadre = keep.MinId
WHERE hijo.IdCuentaPadre <> keep.MinId;

DELETE c FROM cuentacontable c
JOIN (SELECT Codigo, MIN(IdCuentaContable) AS MinId FROM cuentacontable GROUP BY Codigo) keep ON keep.Codigo = c.Codigo
WHERE c.IdCuentaContable <> keep.MinId;

DROP PROCEDURE IF EXISTS usp_ConfigurarIndicesUnicos;
DELIMITER $$
CREATE PROCEDURE usp_ConfigurarIndicesUnicos()
BEGIN
 IF NOT EXISTS(SELECT 1 FROM information_schema.statistics WHERE table_schema=DATABASE()
 AND table_name='cuentacontable' AND index_name='uq_cuentacontable_codigo') THEN
   ALTER TABLE cuentacontable ADD UNIQUE KEY uq_cuentacontable_codigo(Codigo);
 END IF;
 IF NOT EXISTS(SELECT 1 FROM information_schema.statistics WHERE table_schema=DATABASE()
 AND table_name='lote' AND index_name='uq_lote_variante_numero') THEN
   ALTER TABLE lote ADD UNIQUE KEY uq_lote_variante_numero(IdVariante,NumeroLote);
 END IF;
END$$
DELIMITER ;
CALL usp_ConfigurarIndicesUnicos();
DROP PROCEDURE usp_ConfigurarIndicesUnicos;
