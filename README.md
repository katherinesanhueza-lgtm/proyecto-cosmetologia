# Dermo ERP

Aplicación ASP.NET Web Forms para gestionar Inventario, Compras, Ventas y Contabilidad desde una sola sesión.

## Ejecutar en Windows

1. Abre `trabajo-ing-software.slnx` en Visual Studio con la carga de trabajo **Desarrollo de ASP.NET y web** y el paquete de destino de **.NET Framework 4.7.2**. Restaura los paquetes NuGet.
2. Para una instalación nueva, crea una base MySQL 8 vacía llamada `erp_dermocosmetica`. Selecciónala en tu cliente SQL y ejecuta, en orden, los scripts de `trabajo-ing-software/App_Data`: `000_esquema_mysql.sql`, `001_inventario.sql`, `003_ventas.sql` y `004_contabilidad_mysql.sql`. Si ya tienes una base ERP, aplica solo las migraciones que falten. El script `000` está destinado a bases vacías.
3. Copia `trabajo-ing-software/Web.ConnectionStrings.example.config` como `trabajo-ing-software/Web.ConnectionStrings.local.config` y completa la conexión a tu instancia MySQL. Git ignora ese archivo local.
4. En una base nueva, crea la primera cuenta administradora desde tu cliente MySQL. Sustituye los valores de ejemplo por tu correo y una clave propia. Guarda la clave solo en tu entorno local.

   ```sql
   INSERT INTO usuario (Nombre, Correo, Password, Rol, Activo)
   VALUES ('Administrador ERP', 'TU_CORREO', 'TU_CLAVE_LOCAL', 'Administrador', 1);
   ```

5. Inicia el proyecto con IIS Express desde Visual Studio. Entra con la cuenta administradora y configura los catálogos, bodegas y usuarios que usará tu equipo.

Los asientos se registran en **Contabilidad → Libro diario**. Allí se puede asociar un asiento con una operación de Compras, Ventas o Inventario.
