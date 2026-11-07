# Inventario Dermo ERP

Proyecto ASP.NET Web Forms, C#, .NET Framework 4.7.2 y MySQL. Abrir `Cosmetologia.sln` con Visual Studio Community. La solución utiliza los ensamblados existentes de `bin` cuando no está disponible la carpeta `packages`; se conserva la configuración NuGet para su restauración normal.

## Comparación con la imagen

| Requerimiento | Estado anterior | Implementación |
|---|---|---|
| Gestión de productos | Solo consulta indirecta | Productos: registro, consulta, edición y desactivación; categoría, marca, descripción y mínimo. SKU y presentación se administran por variante. |
| Gestión de variantes | Solo consulta | Variantes: SKU único, nombre, volumen/tamaño, presentación, color y activación. |
| Gestión de existencias | Consulta con filtros | Consulta existente y reportes que incluyen variantes sin stock por bodega. Movimientos actualizan existencias, lotes y total de variante en una transacción. |
| Registro de entradas | Sin pantalla | Movimientos: Entrada vinculada a un detalle de recepción de Compras; se valida variante, cantidad, lote, vencimiento y duplicación. |
| Registro de salidas | Sin pantalla | Movimientos: Salida vinculada a un detalle de Ventas; comprueba stock disponible descontando reservas, saldo del lote, estado y vencimiento. |
| Gestión de lotes | Sin pantalla | Lotes: registro, edición, bodega, fechas y estado; cantidades mediante movimientos. |
| Alertas de inventario | Indicador de stock bajo | Alertas filtrables: stock bajo, sin stock, vencido y próximo a vencer en 30 días. |
| Registro de movimientos | Sin pantalla | Fecha automática, responsable seleccionado, tipo, cantidad, saldos anterior/posterior, referencia y motivo. |
| Ajustes de inventario | Sin pantalla | Ajustes positivos y negativos con motivo obligatorio; no permiten stock negativo ni consumir reservas. |
| Configuración de stock mínimo | Solo lectura | Se modifica por producto desde Productos. Aplica a sus variantes. |
| Historial de movimientos | Sin pantalla | Historial por producto/SKU/lote, bodega, fechas y tipo; exportación de resultados filtrados. |
| Generación de reportes | Reporte básico | Reportes con filtros por producto/SKU/lote, bodega y estado; CSV. Historial exportable. Botón anterior corregido de PDF a CSV. |

## Uso

1. Registrar un producto y configurar su stock mínimo.
2. Crear sus variantes con SKU único.
3. Crear un lote con la variante, bodega, ingreso y vencimiento. Comienza en cero unidades.
4. En Movimientos registrar la entrada, salida o ajuste. Para entradas y salidas se elige un detalle existente de recepción de compra o venta y su cantidad completa. La actualización del inventario ocurre al pulsar Registrar y no requiere modificar cantidades manualmente.
5. Consultar Alertas, Historial y Reportes desde el menú lateral.

Las pantallas completas de Compras y Ventas no forman parte de estos requerimientos de inventario y siguen sin implementarse; se consumen sus tablas existentes. Registrar una compra o venta directamente en MySQL no ejecuta automáticamente un movimiento: debe confirmarse desde Movimientos o invocarse `InventarioDatos.Mover` desde el futuro módulo correspondiente. Una línea de documento se procesa una sola vez y sobre un lote; repartir una línea entre varios lotes requerirá ampliar ese flujo.

El responsable se selecciona entre los usuarios existentes: el proyecto todavía no dispone de inicio de sesión. Se conserva la validación de eventos y de ViewState con clave de sesión en las pantallas nuevas.

## Base de datos

Se aplicó `Cosmetologia/App_Data/001_inventario.sql` en la base local. No volver a ejecutarlo sobre esa misma base: agrega columnas, referencias y un índice único de origen. En otra instalación, realizar primero un respaldo y ejecutarlo una sola vez.

Respaldo local previo: `Cosmetologia/App_Data/antes_inventario.sql` (no está incluido como contenido del proyecto). No se eliminaron ni reasignaron las existencias anteriores. Los lotes preexistentes sin bodega requieren asignar su ubicación real; las existencias antiguas sin lote requieren conciliación antes de utilizarlas en salidas por lote. No se debe registrar una entrada para representar stock ya contabilizado.

## Verificación

Compilación con MSBuild de Visual Studio Community. `verificar-inventario.ps1` prueba formularios Web Forms con datos temporales: productos, variantes, lotes, ajustes, stock insuficiente, sincronización de saldos, historial, alerta de vencimiento y CSV sin HTML. Elimina los datos temporales al finalizar. Requiere IIS Express activo en `http://localhost:8085` y MySQL local.
