-- MySQL. Ejecutar en erp_dermocosmetica después de la migración de Inventario.
ALTER TABLE venta
    ADD COLUMN IdVentaOrigen INT NULL,
    ADD CONSTRAINT fk_venta_origen FOREIGN KEY (IdVentaOrigen) REFERENCES venta(IdVenta),
    ADD UNIQUE KEY ux_venta_origen (IdVentaOrigen);
