-- Migración 005: Stored Procedure de Cuentas por Pagar y Asiento Contable desde Recepción (RF-COM-08 / RF-CON-05),
-- Firma NombreContador en ConfiguracionGlobal y datos base de Contabilidad.

INSERT INTO configuracionglobal (Clave, Valor, Descripcion)
VALUES ('NombreContador', 'Contador General', 'Firma oficial Contabilidad y Comprobantes de Pago')
ON DUPLICATE KEY UPDATE Descripcion = VALUES(Descripcion);

INSERT INTO periodocontable (Nombre, FechaInicio, FechaFin, Estado)
SELECT 'Año Comercial 2026', '2026-01-01', '2026-12-31', 'Abierto'
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM periodocontable WHERE Estado = 'Abierto');

INSERT IGNORE INTO cuentacontable (Codigo, Nombre, Tipo, IdCuentaPadre, Nivel, Imputable) VALUES
('1101', 'Caja y Bancos', 'Activo', NULL, 1, 1),
('1105', 'Existencias e Inventario', 'Activo', NULL, 1, 1),
('1109', 'IVA Crédito Fiscal', 'Activo', NULL, 1, 1),
('2101', 'Proveedores por Pagar', 'Pasivo', NULL, 1, 1);

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

-- Sincronizar cuenta por pagar y asiento contable de la recepción de prueba existente
CALL usp_CrearCuentaPorPagar(1, 5);
