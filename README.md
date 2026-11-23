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

## Plataforma y arquitectura por capas

Por decisión del equipo, los cuatro módulos comparten **ASP.NET Web Forms sobre .NET Framework 4.7.2**, sesión de IIS y base de datos relacional **MySQL / MariaDB**, alineados con la especificación actualizada de plataforma y seguridad. Las claves utilizan hash criptográfico `PBKDF2-SHA256` con sal individual (600.000 iteraciones) y en el despliegue productivo se habilita HTTPS en IIS.

La solución organiza el código por módulos y capas:
- **Presentación:** formularios `.aspx` y `Contabilidad.Master` con control de roles (`PaginaCompras`, `PaginaVentas`, `PaginaInventario`).
- **Lógica de negocio (`CapaNegocio/`):** validaciones de dominio, reglas tributarias y de protección de datos (`ComprasServicio.cs`, `ProteccionDatosServicio.cs`).
- **Acceso a datos (`CapaDatos/`):** repositorios parametrizados y procedimientos almacenados (`ComprasRepositorio.cs`, `ConexionErp.cs`, `RecepcionInventario.cs`, `VentaInventario.cs`, `ContabilidadDatos.cs`).

Para actualizar una base existente de esta rama, ejecuta en orden los scripts `trabajo-ing-software/App_Data/007_integracion_erp.sql` y `trabajo-ing-software/App_Data/actualizacion_bd_compras.sql` antes de iniciar la aplicación (ambos son idempotentes y conservan los datos existentes). Para una instalación nueva con datos de prueba, carga primero `BD_Dermocosmetica_Completa.sql` y después las migraciones `007_integracion_erp.sql` y `actualizacion_bd_compras.sql`.

### Protección de datos personales

El ERP incorpora la página `Privacidad.aspx` (accesible desde el inicio de sesión y la barra lateral) y el documento `docs/Politica_Proteccion_Datos_Personales.md` conforme a la normativa chilena vigente (Ley N° 19.628 y Ley N° 21.719), incluyendo consulta/exportación de datos personales y anonimización controlada para clientes inactivos preservando la trazabilidad tributaria.

### Respaldo y recuperación (ejecución manual)

El repositorio incluye el script manual `scripts/Respaldar-Erp.ps1`, el cual **no se ejecuta automáticamente** ni genera archivos en disco mientras no sea invocado expresamente por un administrador autorizado en el servidor de despliegue:

`scripts/Respaldar-Erp.ps1 -Destino <ruta_respaldo> -DirectorioMySql <ruta_bin_mysql>`

El script lee la conexión local, respalda datos, rutinas y disparadores, y valida la restauración antes de confirmar el archivo.
