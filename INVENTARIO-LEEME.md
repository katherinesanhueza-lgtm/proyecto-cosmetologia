# Avances de Katherine: inventario

La solución `Cosmetologia.sln` contiene los avances del módulo de inventario. Se añade como solución independiente para conservar el proyecto compartido `trabajo-ing-software`, sus pantallas de Compras y Login y su solución original. Las tablas de MySQL son el punto de conexión con los documentos de compras y ventas; todavía no se han unificado las interfaces ni la autenticación de ambas soluciones.

## Ejecutar en Visual Studio Community

1. Instalar la carga de trabajo de desarrollo web ASP.NET y el paquete de destino .NET Framework 4.7.2.
2. Abrir `Cosmetologia.sln` y restaurar los paquetes NuGet de la solución.
3. Copiar `Cosmetologia/Web.ConnectionStrings.example.config` a `Cosmetologia/Web.ConnectionStrings.local.config`. Completar el usuario y contraseña de MySQL en esa copia local, excluida de Git.
4. Utilizar una base `erp_dermocosmetica` con el esquema del ERP existente. El SQL incluido es una ampliación del esquema, no una base completa ni datos de ejemplo.
5. Respaldar la base y ejecutar una sola vez `Cosmetologia/App_Data/001_inventario.sql` si esas columnas no están instaladas. En el equipo de Katherine ya se aplicó.
6. Establecer `Cosmetologia` como proyecto de inicio y `Default.aspx` como página de inicio. Ejecutar con IIS Express mediante Ctrl+F5.

La configuración que se sube no incluye credenciales. Tampoco se incluyen `bin`, `obj`, `.vs`, configuraciones personales ni el respaldo de datos.

Ver `REQUERIMIENTOS.md` para la comparación de los doce requerimientos y el funcionamiento de cada pantalla. Para ejecutar las pruebas, configurar IIS Express en localhost:8085 y adaptar en `verificar-inventario.ps1` la ruta de MySQL si fuese necesario. Las pruebas utilizan registros temporales y los eliminan al terminar.
