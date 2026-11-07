-- Ejecutar una sola vez sobre erp_dermocosmetica. No elimina datos.
-- Los lotes anteriores quedan sin bodega hasta que se asigne su ubicación real.
ALTER TABLE lote ADD COLUMN IdBodega INT NULL,
 ADD CONSTRAINT fk_lote_bodega FOREIGN KEY (IdBodega) REFERENCES bodega(IdBodega);
ALTER TABLE movimientoinventario ADD COLUMN IdBodega INT NULL,
 ADD COLUMN Origen VARCHAR(20) NULL,
 ADD COLUMN IdDetalleOrigen INT NULL,
 ADD UNIQUE KEY ux_movimiento_origen (Origen,IdDetalleOrigen),
 ADD CONSTRAINT fk_movimiento_bodega FOREIGN KEY (IdBodega) REFERENCES bodega(IdBodega);
INSERT INTO tipomovimiento(Nombre,Naturaleza,Descripcion)
SELECT 'Entrada','Entrada','Recepción de compra' WHERE NOT EXISTS(SELECT 1 FROM tipomovimiento WHERE Nombre='Entrada');
INSERT INTO tipomovimiento(Nombre,Naturaleza,Descripcion)
SELECT 'Salida','Salida','Salida por venta' WHERE NOT EXISTS(SELECT 1 FROM tipomovimiento WHERE Nombre='Salida');
INSERT INTO tipomovimiento(Nombre,Naturaleza,Descripcion)
SELECT 'Ajuste positivo','Entrada','Diferencia justificada de inventario' WHERE NOT EXISTS(SELECT 1 FROM tipomovimiento WHERE Nombre='Ajuste positivo');
INSERT INTO tipomovimiento(Nombre,Naturaleza,Descripcion)
SELECT 'Ajuste negativo','Salida','Pérdida, daño o vencimiento justificado' WHERE NOT EXISTS(SELECT 1 FROM tipomovimiento WHERE Nombre='Ajuste negativo');
