# Política de Protección de Datos Personales — Dermo ERP

## 1. Marco normativo
El tratamiento de datos personales en **Dermo ERP** se rige por la normativa chilena vigente sobre protección de la vida privada (**Ley N° 19.628** y sus modificaciones introducidas por la **Ley N° 21.719**), así como por las obligaciones legales de conservación documental del **Código Tributario** (Art. 17 y Art. 200).

## 2. Datos tratados y principio de minimización
El sistema registra únicamente los datos estrictamente necesarios para la operación comercial, logística y contable de la distribuidora dermocosmética:
- **Clientes:** RUT, nombre o razón social, giro, dirección de despacho, contacto, correo electrónico, teléfono y condiciones comerciales.
- **Usuarios internos:** nombre, correo corporativo, rol asignado y credencial cifrada (`PBKDF2-SHA256`).
- **Proveedores/Laboratorios:** razón social, RUT tributario, país, representante comercial, correo y teléfono de facturación.

El sistema **no almacena** datos sensibles de salud ni fichas clínicas de pacientes.

## 3. Medidas técnicas y organizativas de seguridad
- **Credenciales protegidas:** todas las contraseñas se derivan mediante `PBKDF2-SHA256` (600.000 iteraciones y sal criptográfica de 128 bits en `ClaveUsuario.cs`), sin almacenamiento en texto plano.
- **Control de acceso basado en roles (RBAC):** el acceso a cada módulo y operación se valida en servidor (`PaginaCompras`, `PaginaVentas`, `PaginaInventario`, `Contabilidad`, `Usuarios`, `Auditoria`, `Privacidad`).
- **Prevención de vulnerabilidades:** consultas SQL parametrizadas, codificación de salida contra XSS, `ViewStateUserKey` global contra CSRF (`Global.asax.cs`) y ocultamiento de detalles técnicos en mensajes de error (`ConexionErp.MensajeError`).
- **Trazabilidad inmutable:** todas las inserciones, actualizaciones y eliminaciones sobre tablas críticas se registran automáticamente en `auditoriaerp` (con triggers que bloquean su edición o borrado).
- **Transporte cifrado:** en entorno de despliegue en IIS se exige habilitación de HTTPS/TLS.

## 4. Conservación y supresión (anonimización)
- Los documentos tributarios (boletas, facturas, notas de crédito, órdenes de compra y asientos contables) se conservan por el plazo mínimo legal de **6 años** según normativa tributaria chilena.
- Cuando un cliente solicita la cancelación de sus datos personales, el administrador puede desactivar su ficha y ejecutar la **anonimización** desde `Privacidad.aspx` (`CapaNegocio/ProteccionDatosServicio.cs`), eliminando nombre, razón social, correo, teléfono, dirección y persona de contacto, sin alterar la integridad contable ni tributaria histórica.

## 5. Ejercicio de derechos ARCO
Los titulares pueden ejercer sus derechos de **Acceso**, **Rectificación**, **Cancelación** y **Oposición**:
- **Acceso:** exportación estructurada de datos personales en formato JSON desde `Privacidad.aspx` (excluyendo credenciales y secretos técnicos).
- **Rectificación:** actualización de ficha en los módulos de `Clientes` o `Usuarios`.
- **Cancelación / Oposición:** desactivación de cuenta y anonimización controlada desde `Privacidad.aspx`.
- **Canal de atención:** `contacto@dermoerp.cl` (Administrador del sistema).
