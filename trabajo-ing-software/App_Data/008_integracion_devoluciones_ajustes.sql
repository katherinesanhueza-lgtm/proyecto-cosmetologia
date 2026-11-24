-- Migración 008: conecta devoluciones a proveedor y ajustes de inventario con Contabilidad.
-- Ejecutar una sola vez después de 007_integracion_erp.sql.

ALTER TABLE devolucionproveedor
    ADD COLUMN MontoCredito DECIMAL(18,2) NOT NULL DEFAULT 0,
    ADD COLUMN MontoAplicado DECIMAL(18,2) NOT NULL DEFAULT 0,
    ADD COLUMN IdAsiento INT NULL,
    ADD KEY ix_devolucionproveedor_cxp (IdRecepcion,Estado),
    ADD KEY ix_devolucionproveedor_asiento (IdAsiento),
    ADD CONSTRAINT fk_devolucionproveedor_asiento
        FOREIGN KEY (IdAsiento) REFERENCES asientocontable(IdAsiento);

INSERT INTO cuentacontable (Codigo,Nombre,Tipo,IdCuentaPadre,Nivel,Imputable)
SELECT '1199','Créditos a favor de proveedores','Activo',NULL,1,1
WHERE NOT EXISTS (SELECT 1 FROM cuentacontable WHERE Codigo='1199');

INSERT INTO cuentacontable (Codigo,Nombre,Tipo,IdCuentaPadre,Nivel,Imputable)
SELECT '4901','Recuperación por ajustes de inventario','Ingreso',NULL,1,1
WHERE NOT EXISTS (SELECT 1 FROM cuentacontable WHERE Codigo='4901');

INSERT INTO cuentacontable (Codigo,Nombre,Tipo,IdCuentaPadre,Nivel,Imputable)
SELECT '5102','Pérdidas por mermas y ajustes de inventario','Costo',NULL,1,1
WHERE NOT EXISTS (SELECT 1 FROM cuentacontable WHERE Codigo='5102');

DROP PROCEDURE IF EXISTS usp_AceptarDevolucionProveedor;
DELIMITER $$
CREATE PROCEDURE usp_AceptarDevolucionProveedor(IN reclamo INT, IN responsable INT)
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
END$$
DELIMITER ;
