-- MySQL. Ejecutar sobre el esquema de ERP existente, después de 001 y 003.
ALTER TABLE cuentacontable
    ADD COLUMN IdCuentaPadre INT NULL,
    ADD COLUMN Nivel INT NOT NULL DEFAULT 1,
    ADD COLUMN Imputable BOOLEAN NOT NULL DEFAULT TRUE,
    ADD UNIQUE KEY ux_cuenta_codigo (Codigo),
    ADD CONSTRAINT fk_cuenta_padre FOREIGN KEY (IdCuentaPadre) REFERENCES cuentacontable(IdCuentaContable);

ALTER TABLE asientocontable
    ADD COLUMN IdAsientoRevertido INT NULL,
    ADD COLUMN FechaRegistro DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    ADD COLUMN Origen VARCHAR(20) NULL,
    ADD COLUMN IdOrigen INT NULL,
    ADD UNIQUE KEY ux_asiento_reverso (IdAsientoRevertido),
    ADD UNIQUE KEY ux_asiento_origen (Origen,IdOrigen),
    ADD CONSTRAINT fk_asiento_reverso FOREIGN KEY (IdAsientoRevertido) REFERENCES asientocontable(IdAsiento);

ALTER TABLE cuentaporpagar ADD UNIQUE KEY ux_cuentapagar_recepcion (IdRecepcion);
ALTER TABLE cuentascobrar ADD UNIQUE KEY ux_cuentacobrar_venta (IdVenta);
