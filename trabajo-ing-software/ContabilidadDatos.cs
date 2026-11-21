using System;
using System.Data;
using MySql.Data.MySqlClient;

namespace trabajo_ing_software
{
    internal static class ContabilidadDatos
    {
        internal static DataTable Consultar(string sql, params MySqlParameter[] parametros)
        {
            using (var conexion = VentaInventario.Abrir())
            using (var comando = new MySqlCommand(sql, conexion))
            using (var adaptador = new MySqlDataAdapter(comando))
            {
                comando.Parameters.AddRange(parametros);
                var tabla = new DataTable();
                adaptador.Fill(tabla);
                return tabla;
            }
        }

        internal static DataTable InventarioValorizado(string buscar)
        {
            return Consultar(@"SELECT p.Nombre AS Producto,v.Sku AS SKU,b.Nombre AS Bodega,
                COALESCE(i.StockActual,0) AS Existencias,NULLIF(v.CostoPromedio,0) AS CostoPromedio,
                ROUND(COALESCE(i.StockActual,0)*NULLIF(v.CostoPromedio,0),2) AS ValorInventario
                FROM inventario i JOIN varianteproducto v ON v.IdVariante=i.IdVariante
                JOIN producto p ON p.IdProducto=v.IdProducto JOIN bodega b ON b.IdBodega=i.IdBodega
                WHERE p.Activo=1 AND v.Activo=1 AND b.Activo=1
                AND (p.Nombre LIKE @Buscar OR v.Sku LIKE @Buscar OR b.Nombre LIKE @Buscar)
                ORDER BY p.Nombre,v.Sku,b.Nombre", new MySqlParameter("@Buscar", "%" + buscar + "%"));
        }

        internal const string Operaciones = @"
            SELECT 'Compra' AS Origen,r.IdRecepcion AS IdOrigen,r.FechaRecepcion AS Fecha,
                CONCAT('Recepción #',r.IdRecepcion) AS Documento,cp.Monto AS Importe
            FROM recepcioncompra r LEFT JOIN cuentaporpagar cp ON cp.IdRecepcion=r.IdRecepcion
            UNION ALL
            SELECT IF(v.TipoDocumento='Nota de Credito','Devolución','Venta'),v.IdVenta,v.Fecha,
                CONCAT(v.TipoDocumento,' #',v.IdVenta),v.Total FROM venta v
            UNION ALL
            SELECT 'Ajuste',m.IdMovimiento,DATE(m.FechaMovimiento),CONCAT(t.Nombre,' #',m.IdMovimiento),
                ROUND(m.Cantidad*l.CostoUnitario,2)
            FROM movimientoinventario m JOIN tipomovimiento t ON t.IdTipoMovimiento=m.IdTipoMovimiento
            JOIN lote l ON l.IdLote=m.IdLote WHERE t.Nombre IN ('Ajuste positivo','Ajuste negativo')";

        internal static int Ejecutar(string sql, params MySqlParameter[] parametros)
        {
            using (var conexion = VentaInventario.Abrir())
            using (var comando = new MySqlCommand(sql, conexion))
            {
                comando.Parameters.AddRange(parametros);
                return comando.ExecuteNonQuery();
            }
        }

        internal static void AbrirPeriodo(string nombre, DateTime inicio, DateTime fin)
        {
            using (var conexion = VentaInventario.Abrir())
            using (var tx = conexion.BeginTransaction())
            {
                using (var cmd = VentaInventario.Comando(conexion, tx,
                    "SELECT IdPeriodo FROM periodocontable WHERE FechaInicio<=@p0 AND FechaFin>=@p1 LIMIT 1 FOR UPDATE", fin, inicio))
                    if (cmd.ExecuteScalar() != null)
                        throw new ArgumentException("Ya hay un período que coincide con esas fechas.");

                using (var cmd = VentaInventario.Comando(conexion, tx,
                    "INSERT INTO periodocontable(Nombre,FechaInicio,FechaFin,Estado) VALUES(@p0,@p1,@p2,'Abierto')",
                    nombre, inicio, fin))
                    cmd.ExecuteNonQuery();
                tx.Commit();
            }
        }

        internal static void EditarCuenta(int id, string codigo, string nombre, string tipo, bool imputable)
        {
            using (var conexion = VentaInventario.Abrir())
            using (var tx = conexion.BeginTransaction())
            {
                string actual;
                using (var cmd = VentaInventario.Comando(conexion, tx,
                    "SELECT COALESCE(Tipo,'') FROM cuentacontable WHERE IdCuentaContable=@p0 FOR UPDATE", id))
                {
                    var valor = cmd.ExecuteScalar();
                    if (valor == null) throw new ArgumentException("La cuenta no existe.");
                    actual = Convert.ToString(valor);
                }
                if (!string.Equals(actual, tipo, StringComparison.OrdinalIgnoreCase))
                {
                    using (var cmd = VentaInventario.Comando(conexion, tx,
                        "SELECT 1 FROM detalleasiento WHERE IdCuentaContable=@p0 LIMIT 1", id))
                        if (cmd.ExecuteScalar() != null)
                            throw new ArgumentException("El tipo de una cuenta con movimientos se conserva.");
                }
                if (imputable)
                {
                    using (var cmd = VentaInventario.Comando(conexion, tx,
                        "SELECT 1 FROM cuentacontable WHERE IdCuentaPadre=@p0 LIMIT 1", id))
                        if (cmd.ExecuteScalar() != null)
                            throw new ArgumentException("Una cuenta con subcuentas debe seguir siendo agrupadora.");
                }
                using (var cmd = VentaInventario.Comando(conexion, tx,
                    "UPDATE cuentacontable SET Codigo=@p0,Nombre=@p1,Tipo=@p2,Imputable=@p3 WHERE IdCuentaContable=@p4",
                    codigo,nombre,tipo,imputable,id))
                    cmd.ExecuteNonQuery();
                tx.Commit();
            }
        }

        internal static int RegistrarAsiento(int periodo, DateTime fecha, string glosa, int usuario,
            DataTable lineas, int? reverso, string origen = null, int? idOrigen = null)
        {
            using (var conexion = VentaInventario.Abrir())
            using (var tx = conexion.BeginTransaction())
            {
                using (var cmd = VentaInventario.Comando(conexion, tx, @"SELECT IdPeriodo FROM periodocontable
                    WHERE IdPeriodo=@p0 AND Estado='Abierto' AND @p1 BETWEEN FechaInicio AND FechaFin FOR UPDATE", periodo,fecha))
                    if (cmd.ExecuteScalar() == null) throw new ArgumentException("La fecha debe pertenecer a un período abierto.");

                if (reverso.HasValue)
                {
                    using (var cmd = VentaInventario.Comando(conexion, tx, @"SELECT IdAsiento FROM asientocontable
                        WHERE IdAsiento=@p0 AND IdAsientoRevertido IS NULL AND Fecha<=@p1 FOR UPDATE",reverso.Value,fecha))
                        if (cmd.ExecuteScalar() == null) throw new ArgumentException("Selecciona un asiento original válido.");

                    using (var cmd = VentaInventario.Comando(conexion, tx, @"SELECT IdCuentaContable,Haber,Debe
                        FROM detalleasiento WHERE IdAsiento=@p0 ORDER BY IdDetalleAsiento",reverso.Value))
                    using (var lector = cmd.ExecuteReader())
                        while (lector.Read()) lineas.Rows.Add(lector.GetInt32(0), lector.GetDecimal(1), lector.GetDecimal(2));
                }

                if (origen != null)
                {
                    using (var cmd = VentaInventario.Comando(conexion, tx,
                        "SELECT 1 FROM (" + Operaciones + ") o WHERE o.Origen=@p0 AND o.IdOrigen=@p1", origen,idOrigen.Value))
                        if (cmd.ExecuteScalar() == null) throw new ArgumentException("La operación de origen ya no existe.");
                }

                decimal debe = 0, haber = 0;
                foreach (DataRow linea in lineas.Rows)
                {
                    decimal d = (decimal)linea["Debe"], h = (decimal)linea["Haber"];
                    if (!((d > 0 && h == 0) || (h > 0 && d == 0)))
                        throw new ArgumentException("Cada línea debe tener un monto positivo en Debe o Haber.");
                    debe += d;
                    haber += h;
                    using (var cmd = VentaInventario.Comando(conexion, tx,
                        "SELECT IdCuentaContable FROM cuentacontable WHERE IdCuentaContable=@p0 AND (Imputable=1 OR @p1) FOR UPDATE",
                        linea["Cuenta"],reverso.HasValue))
                        if (cmd.ExecuteScalar() == null) throw new ArgumentException("Selecciona cuentas imputables.");
                }
                if (lineas.Rows.Count < 2 || debe != haber)
                    throw new ArgumentException("Agrega al menos dos líneas y cuadra el Debe con el Haber.");

                int asiento;
                using (var cmd = VentaInventario.Comando(conexion, tx, @"INSERT INTO asientocontable
                    (IdPeriodo,Fecha,Glosa,IdUsuario,IdAsientoRevertido,Origen,IdOrigen)
                    VALUES(@p0,@p1,@p2,@p3,@p4,@p5,@p6)", periodo,fecha,glosa,usuario,
                    (object)reverso ?? DBNull.Value,(object)origen ?? DBNull.Value,(object)idOrigen ?? DBNull.Value))
                {
                    cmd.ExecuteNonQuery();
                    asiento = checked((int)cmd.LastInsertedId);
                }

                foreach (DataRow linea in lineas.Rows)
                    using (var cmd = VentaInventario.Comando(conexion, tx, @"INSERT INTO detalleasiento
                        (IdAsiento,IdCuentaContable,Debe,Haber) VALUES(@p0,@p1,@p2,@p3)",
                        asiento,linea["Cuenta"],linea["Debe"],linea["Haber"]))
                        cmd.ExecuteNonQuery();

                tx.Commit();
                return asiento;
            }
        }
    }
}
