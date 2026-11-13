using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using MySql.Data.MySqlClient;

namespace trabajo_ing_software
{
    internal static class VentaInventario
    {
        private static bool _esquemaVerificado = false;
        private static readonly object _bloqueoEsquema = new object();

        internal static MySqlConnection Abrir()
        {
            var conexion = new MySqlConnection(ConfigurationManager.ConnectionStrings["DefaultConnection"].ConnectionString);
            conexion.Open();
            AsegurarEsquema(conexion);
            return conexion;
        }

        internal static void AsegurarEsquema(MySqlConnection con)
        {
            if (_esquemaVerificado) return;
            lock (_bloqueoEsquema)
            {
                if (_esquemaVerificado) return;
                try
                {
                    // 1. Ampliación de la tabla cliente (RF-VEN-01 / RF-VEN-07)
                    AgregarColumnaSiFalta(con, "cliente", "RazonSocial", "VARCHAR(150) NULL");
                    AgregarColumnaSiFalta(con, "cliente", "Giro", "VARCHAR(150) NULL");
                    AgregarColumnaSiFalta(con, "cliente", "Direccion", "VARCHAR(200) NULL");
                    AgregarColumnaSiFalta(con, "cliente", "Contacto", "VARCHAR(100) NULL");
                    AgregarColumnaSiFalta(con, "cliente", "LimiteCredito", "DECIMAL(18,2) NOT NULL DEFAULT 0.00");
                    AgregarColumnaSiFalta(con, "cliente", "DiasCredito", "INT NOT NULL DEFAULT 0");
                    AgregarColumnaSiFalta(con, "cliente", "Activo", "TINYINT(1) NOT NULL DEFAULT 1");

                    // 2. Período de validez para cotizaciones (RF-VEN-02)
                    AgregarColumnaSiFalta(con, "cotizacion", "FechaVencimiento", "DATE NULL");

                    // 3. Folio, impuestos y forma de pago en ventas (RF-VEN-03)
                    AgregarColumnaSiFalta(con, "venta", "Folio", "VARCHAR(50) NULL");
                    AgregarColumnaSiFalta(con, "venta", "Neto", "DECIMAL(18,2) NOT NULL DEFAULT 0.00");
                    AgregarColumnaSiFalta(con, "venta", "Iva", "DECIMAL(18,2) NOT NULL DEFAULT 0.00");
                    AgregarColumnaSiFalta(con, "venta", "Descuento", "DECIMAL(18,2) NOT NULL DEFAULT 0.00");
                    AgregarColumnaSiFalta(con, "venta", "FormaPago", "VARCHAR(50) NOT NULL DEFAULT 'Contado'");
                    AgregarColumnaSiFalta(con, "venta", "IdVentaOrigen", "INT NULL");

                    // 4. Despachos y entregas (RF-VEN-08)
                    AgregarColumnaSiFalta(con, "despacho", "FechaEntrega", "DATE NULL");
                    AgregarColumnaSiFalta(con, "despacho", "Observaciones", "VARCHAR(255) NULL");

                    // 5. Plan de cuentas para ventas (RF-VEN-06)
                    try
                    {
                        using (var cmd = new MySqlCommand(@"INSERT IGNORE INTO cuentacontable (Codigo, Nombre, Tipo, IdCuentaPadre, Nivel, Imputable) VALUES
                            ('1103', 'Clientes por Cobrar', 'Activo', NULL, 1, 1),
                            ('2108', 'IVA Débito Fiscal', 'Pasivo', NULL, 1, 1),
                            ('4101', 'Ingresos por Ventas', 'Resultado Ganancia', NULL, 1, 1),
                            ('5101', 'Costo de Ventas', 'Resultado Pérdida', NULL, 1, 1)", con))
                        {
                            cmd.ExecuteNonQuery();
                        }
                    }
                    catch { }

                    _esquemaVerificado = true;
                }
                catch (Exception ex)
                {
                    System.Diagnostics.Trace.TraceWarning("Error al asegurar esquema de ventas: " + ex.Message);
                }
            }
        }

        private static void AgregarColumnaSiFalta(MySqlConnection con, string tabla, string columna, string definicion)
        {
            try
            {
                using (var cmd = new MySqlCommand(
                    "SELECT COUNT(*) FROM information_schema.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = @tabla AND COLUMN_NAME = @columna", con))
                {
                    cmd.Parameters.AddWithValue("@tabla", tabla);
                    cmd.Parameters.AddWithValue("@columna", columna);
                    long count = Convert.ToInt64(cmd.ExecuteScalar() ?? 0);
                    if (count == 0)
                    {
                        using (var alter = new MySqlCommand($"ALTER TABLE `{tabla}` ADD COLUMN `{columna}` {definicion}", con))
                        {
                            alter.ExecuteNonQuery();
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Trace.TraceWarning($"No se pudo agregar columna {columna} a {tabla}: " + ex.Message);
            }
        }

        internal static MySqlCommand Comando(MySqlConnection conexion, MySqlTransaction transaccion,
            string sql, params object[] valores)
        {
            var comando = new MySqlCommand(sql, conexion, transaccion);
            for (int i = 0; i < valores.Length; i++) comando.Parameters.AddWithValue("@p" + i, valores[i]);
            return comando;
        }

        internal static DataTable Consultar(string sql, params object[] parametros)
        {
            using (var conexion = Abrir())
            using (var comando = Comando(conexion, null, sql, parametros))
            using (var adaptador = new MySqlDataAdapter(comando))
            {
                var tabla = new DataTable();
                adaptador.Fill(tabla);
                return tabla;
            }
        }

        internal static long Registrar(MySqlConnection conexion, MySqlTransaction transaccion,
            int cliente, int usuario, int bodega, SortedDictionary<int, int> carrito, DateTime? vence = null)
        {
            return Registrar(conexion, transaccion, cliente, usuario, bodega, "Boleta", 0, vence.HasValue ? "credito" : "contado", carrito, vence, null);
        }

        internal static long Registrar(MySqlConnection conexion, MySqlTransaction transaccion,
            int cliente, int usuario, int bodega, string tipoDocumento, decimal descuento, string formaPago,
            SortedDictionary<int, int> carrito, DateTime? vence = null, int? idCotizacion = null)
        {
            if (carrito == null || carrito.Count == 0)
                throw new InvalidOperationException("Agrega al menos un producto al detalle de la venta.");

            tipoDocumento = string.IsNullOrEmpty(tipoDocumento) ? "Boleta" : tipoDocumento;
            formaPago = string.IsNullOrEmpty(formaPago) ? "Contado" : formaPago;
            bool esCredito = formaPago.Equals("credito", StringComparison.OrdinalIgnoreCase);

            // 1. RF-VEN-01 y RF-VEN-07: Validación de Cliente y Límite de Crédito
            decimal limiteCredito = 0;
            int diasCredito = 0;
            using (var cmd = Comando(conexion, transaccion,
                "SELECT COALESCE(LimiteCredito, 0), COALESCE(DiasCredito, 0), COALESCE(Activo, 1) FROM cliente WHERE IdCliente = @p0 FOR UPDATE", cliente))
            using (var lector = cmd.ExecuteReader())
            {
                if (!lector.Read())
                    throw new InvalidOperationException("El cliente seleccionado no existe.");

                if (lector.GetInt32(2) == 0)
                    throw new InvalidOperationException("El cliente seleccionado se encuentra inactivo.");

                limiteCredito = lector.GetDecimal(0);
                diasCredito = lector.GetInt32(1);
            }

            // 2. Calcular subtotal preliminar de los productos
            decimal totalBruto = 0;
            var precios = new Dictionary<int, decimal>();
            foreach (var articulo in carrito)
            {
                using (var cmd = Comando(conexion, transaccion,
                    @"SELECT v.PrecioVenta FROM varianteproducto v 
                      JOIN producto p ON p.IdProducto = v.IdProducto 
                      WHERE v.IdVariante = @p0 AND v.Activo = 1 AND p.Activo = 1 FOR UPDATE", articulo.Key))
                {
                    var val = cmd.ExecuteScalar();
                    if (val == null || val == DBNull.Value || Convert.ToDecimal(val) <= 0)
                        throw new InvalidOperationException("Uno de los productos seleccionados no se encuentra activo o no tiene precio.");
                    decimal precio = Convert.ToDecimal(val);
                    precios[articulo.Key] = precio;
                    totalBruto += precio * articulo.Value;
                }
            }

            if (descuento < 0) descuento = 0;
            if (descuento > totalBruto) descuento = totalBruto;

            decimal totalFinal = Math.Round(totalBruto - descuento, 2);
            decimal neto = Math.Round(totalFinal / 1.19m, 2);
            decimal iva = totalFinal - neto;

            // Validación de límite de crédito (RF-VEN-07)
            if (esCredito)
            {
                if (limiteCredito <= 0)
                    throw new InvalidOperationException("Venta rechazada: El cliente no cuenta con línea de crédito autorizada (Límite: $0).");

                decimal deudaActual = 0;
                using (var cmdDeuda = Comando(conexion, transaccion,
                    @"SELECT COALESCE(SUM(cc.MontoPendiente), 0) 
                      FROM cuentascobrar cc 
                      INNER JOIN venta v ON cc.IdVenta = v.IdVenta 
                      WHERE v.IdCliente = @p0 AND cc.EstadoPago <> 'Pagado'", cliente))
                {
                    var deudaObj = cmdDeuda.ExecuteScalar();
                    if (deudaObj != null && deudaObj != DBNull.Value)
                        deudaActual = Convert.ToDecimal(deudaObj);
                }

                decimal disponible = limiteCredito - deudaActual;
                if (totalFinal > disponible)
                {
                    throw new InvalidOperationException(
                        $"Venta a crédito rechazada (RF-VEN-07): El monto (${totalFinal:N0}) supera el crédito disponible del cliente (${disponible:N0}). " +
                        $"Límite total: ${limiteCredito:N0}, Deuda no cancelada: ${deudaActual:N0}.");
                }
            }

            // 3. Generar Folio correlativo (RF-VEN-03)
            string prefijo = tipoDocumento.StartsWith("Factura", StringComparison.OrdinalIgnoreCase) ? "FAC" : "BOL";
            string folio;
            using (var cmdFolio = Comando(conexion, transaccion,
                "SELECT COUNT(IdVenta) + 1001 FROM venta WHERE TipoDocumento = @p0", tipoDocumento))
            {
                long correlativo = Convert.ToInt64(cmdFolio.ExecuteScalar() ?? 1001);
                folio = $"{prefijo}-{correlativo:D6}";
            }

            // 4. Insertar cabecera de la venta (RF-VEN-03)
            long ventaId;
            string insertVentaSql = @"INSERT INTO venta 
                (TipoDocumento, Folio, Fecha, Neto, Iva, Descuento, Total, FormaPago, IdCliente, IdCotizacion, IdUsuario) 
                VALUES (@p0, @p1, CURDATE(), @p2, @p3, @p4, @p5, @p6, @p7, @p8, @p9)";

            using (var cmd = Comando(conexion, transaccion, insertVentaSql,
                tipoDocumento, folio, neto, iva, descuento, totalFinal, formaPago, cliente,
                idCotizacion.HasValue ? (object)idCotizacion.Value : DBNull.Value, usuario))
            {
                cmd.ExecuteNonQuery();
                ventaId = cmd.LastInsertedId;
            }

            // 5. Descuento automático de inventario por FEFO (RF-VEN-05)
            decimal totalCostoVenta = 0;
            foreach (var articulo in carrito)
            {
                totalCostoVenta += DescontarFEFO(conexion, transaccion, ventaId, usuario, bodega, articulo.Key, articulo.Value, precios[articulo.Key]);
            }

            // 6. Integración Contable: Cuentas por Cobrar (RF-VEN-06)
            if (esCredito)
            {
                DateTime fechaVenceCalculada = vence ?? DateTime.Today.AddDays(diasCredito > 0 ? diasCredito : 30);
                using (var cmd = Comando(conexion, transaccion, @"INSERT INTO cuentascobrar
                    (IdVenta, FechaVence, MontoPendiente, EstadoPago, IdUsuario)
                    VALUES (@p0, @p1, @p2, 'Pendiente', @p3)", ventaId, fechaVenceCalculada.Date, totalFinal, usuario))
                {
                    cmd.ExecuteNonQuery();
                }
            }

            // 7. Integración Contable: Generar Asientos Automáticos (RF-VEN-06)
            GenerarAsientosVenta(conexion, transaccion, ventaId, usuario, cliente, folio, tipoDocumento, formaPago, totalFinal, neto, iva, totalCostoVenta);

            // 8. Actualizar estado de Cotización si proviene de una (RF-VEN-02)
            if (idCotizacion.HasValue)
            {
                using (var cmd = Comando(conexion, transaccion,
                    "UPDATE cotizacion SET Estado = 'Aceptado' WHERE IdCotizacion = @p0", idCotizacion.Value))
                {
                    cmd.ExecuteNonQuery();
                }
            }

            return ventaId;
        }

        private static decimal DescontarFEFO(MySqlConnection conexion, MySqlTransaction tx,
            long ventaId, int usuario, int bodega, int variante, int cantidad, decimal precioUnitario)
        {
            // Intentar ejecutar el Procedimiento Almacenado oficial del módulo de Inventario (RF-VEN-05)
            try
            {
                using (var cmdSp = new MySqlCommand("usp_DescontarInventarioFEFO", conexion, tx))
                {
                    cmdSp.CommandType = CommandType.StoredProcedure;
                    cmdSp.Parameters.AddWithValue("p_IdVenta", (int)ventaId);
                    cmdSp.Parameters.AddWithValue("p_IdVariante", variante);
                    cmdSp.Parameters.AddWithValue("p_IdBodega", bodega);
                    cmdSp.Parameters.AddWithValue("p_Cantidad", cantidad);
                    cmdSp.Parameters.AddWithValue("p_PrecioUnitario", precioUnitario);
                    cmdSp.Parameters.AddWithValue("p_IdUsuario", usuario);

                    var paramCosto = new MySqlParameter("p_CostoTotalConsumido", MySqlDbType.Decimal)
                    {
                        Direction = ParameterDirection.Output,
                        Precision = 18,
                        Scale = 2
                    };
                    cmdSp.Parameters.Add(paramCosto);

                    cmdSp.ExecuteNonQuery();

                    if (paramCosto.Value != null && paramCosto.Value != DBNull.Value)
                        return Convert.ToDecimal(paramCosto.Value);

                    return 0;
                }
            }
            catch (MySqlException ex) when (ex.Number == 1305) // SP does not exist yet in DB
            {
                // Fallback transaccional en C# con idéntico criterio FEFO
                return DescontarFEFOEnLinea(conexion, tx, ventaId, usuario, bodega, variante, cantidad, precioUnitario);
            }
        }

        private static decimal DescontarFEFOEnLinea(MySqlConnection conexion, MySqlTransaction tx,
            long venta, int usuario, int bodega, int variante, int cantidad, decimal precio)
        {
            if (cantidad <= 0) throw new InvalidOperationException("La cantidad debe ser mayor a cero.");

            int stock;
            int idInventario;
            using (var cmd = Comando(conexion, tx, @"SELECT IdInventario, COALESCE(StockActual,0), COALESCE(StockReservado,0)
                FROM inventario WHERE IdVariante=@p0 AND IdBodega=@p1 FOR UPDATE", variante, bodega))
            using (var lector = cmd.ExecuteReader())
            {
                if (!lector.Read()) throw new InvalidOperationException("El producto no tiene saldo de inventario en la bodega seleccionada.");
                idInventario = lector.GetInt32(0);
                stock = lector.GetInt32(1);
                if (cantidad > stock - lector.GetInt32(2))
                    throw new InvalidOperationException("Stock disponible insuficiente en la bodega seleccionada.");
            }

            var lotes = new List<Tuple<int, int, decimal>>();
            int pendiente = cantidad;
            using (var cmd = Comando(conexion, tx, @"SELECT IdLote, CantidadDisponible, COALESCE(CostoUnitario, 0) FROM lote
                WHERE IdVariante=@p0 AND IdBodega=@p1 AND Estado='Disponible' AND CantidadDisponible>0
                  AND (FechaVencimiento IS NULL OR FechaVencimiento>=CURDATE())
                ORDER BY FechaVencimiento IS NULL, FechaVencimiento ASC, IdLote ASC FOR UPDATE", variante, bodega))
            using (var lector = cmd.ExecuteReader())
            {
                while (pendiente > 0 && lector.Read())
                {
                    int unidades = Math.Min(pendiente, lector.GetInt32(1));
                    decimal costo = lector.GetDecimal(2);
                    lotes.Add(new Tuple<int, int, decimal>(lector.GetInt32(0), unidades, costo));
                    pendiente -= unidades;
                }
            }
            if (pendiente != 0)
                throw new InvalidOperationException("No hay suficientes unidades vigentes en lotes para cumplir con el criterio FEFO.");

            decimal costoTotalConsumido = 0;
            foreach (var lote in lotes)
            {
                long detalle;
                using (var cmd = Comando(conexion, tx, @"INSERT INTO ventadetalle(IdVenta,IdVariante,Cantidad,PrecioUnitario,Subtotal)
                    VALUES(@p0,@p1,@p2,@p3,@p4)", venta, variante, lote.Item2, precio, Math.Round(precio * lote.Item2, 2)))
                {
                    cmd.ExecuteNonQuery();
                    detalle = cmd.LastInsertedId;
                }

                using (var cmd = Comando(conexion, tx, @"UPDATE lote SET
                    Estado=IF(CantidadDisponible=@p0,'Agotado',Estado), CantidadDisponible=CantidadDisponible-@p0
                    WHERE IdLote=@p1", lote.Item2, lote.Item1))
                {
                    cmd.ExecuteNonQuery();
                }

                using (var cmd = Comando(conexion, tx, @"INSERT INTO movimientoinventario
                    (IdLote,IdBodega,IdTipoMovimiento,IdUsuario,Cantidad,StockAnterior,StockPosterior,Referencia,Observacion,Origen,IdDetalleOrigen)
                    SELECT @p0,@p1,IdTipoMovimiento,@p2,@p3,@p4,@p5,@p6,'Venta confirmada FEFO','Salida',@p7
                    FROM tipomovimiento WHERE Nombre='Salida' ORDER BY IdTipoMovimiento LIMIT 1",
                    lote.Item1, bodega, usuario, lote.Item2, stock, stock - lote.Item2, "Venta #" + venta, detalle))
                {
                    cmd.ExecuteNonQuery();
                }

                stock -= lote.Item2;
                costoTotalConsumido += Math.Round(lote.Item2 * lote.Item3, 2);
            }

            using (var cmd = Comando(conexion, tx,
                "UPDATE inventario SET StockActual=@p0, FechaActualizada=NOW() WHERE IdInventario=@p1", stock, idInventario))
                cmd.ExecuteNonQuery();

            using (var cmd = Comando(conexion, tx, @"UPDATE varianteproducto SET StockTotal=
                (SELECT COALESCE(SUM(StockActual),0) FROM inventario WHERE IdVariante=@p0) WHERE IdVariante=@p0", variante))
                cmd.ExecuteNonQuery();

            return costoTotalConsumido;
        }

        private static void GenerarAsientosVenta(MySqlConnection conexion, MySqlTransaction tx,
            long ventaId, int usuario, int cliente, string folio, string tipoDoc, string formaPago,
            decimal total, decimal neto, decimal iva, decimal costoVenta)
        {
            try
            {
                // Buscar período contable abierto
                int? periodoId = null;
                using (var cmd = Comando(conexion, tx,
                    "SELECT IdPeriodo FROM periodocontable WHERE Estado = 'Abierto' AND CURDATE() BETWEEN FechaInicio AND FechaFin ORDER BY FechaInicio DESC LIMIT 1"))
                {
                    var val = cmd.ExecuteScalar();
                    if (val != null && val != DBNull.Value) periodoId = Convert.ToInt32(val);
                }

                if (!periodoId.HasValue)
                {
                    using (var cmd = Comando(conexion, tx, "SELECT IdPeriodo FROM periodocontable WHERE Estado = 'Abierto' ORDER BY FechaInicio DESC LIMIT 1"))
                    {
                        var val = cmd.ExecuteScalar();
                        if (val != null && val != DBNull.Value) periodoId = Convert.ToInt32(val);
                    }
                }

                if (!periodoId.HasValue) return; // Si no hay períodos abiertos no se bloquea la venta comercial

                // Cuentas Contables
                int ctaCobro = ObtenerIdCuenta(conexion, tx, formaPago.Equals("credito", StringComparison.OrdinalIgnoreCase) ? "1103" : "1101");
                int ctaVentas = ObtenerIdCuenta(conexion, tx, "4101");
                int ctaIvaDebito = ObtenerIdCuenta(conexion, tx, "2108");
                int ctaCostoVentas = ObtenerIdCuenta(conexion, tx, "5101");
                int ctaExistencias = ObtenerIdCuenta(conexion, tx, "1105");

                // Asiento 1: Ingreso por Venta e IVA Débito (RF-VEN-06)
                if (ctaCobro > 0 && ctaVentas > 0)
                {
                    string glosa = $"Venta {tipoDoc} {folio} (Cliente #{cliente})";
                    long idAsiento;
                    using (var cmd = Comando(conexion, tx,
                        @"INSERT INTO asientocontable (IdPeriodo, Fecha, Glosa, IdUsuario, Origen, IdOrigen) 
                          VALUES (@p0, CURDATE(), @p1, @p2, 'Venta', @p3)", periodoId.Value, glosa, usuario, ventaId))
                    {
                        cmd.ExecuteNonQuery();
                        idAsiento = cmd.LastInsertedId;
                    }

                    // Debe: Caja o Clientes por Cobrar (Total)
                    using (var cmd = Comando(conexion, tx,
                        "INSERT INTO detalleasiento (IdAsiento, IdCuentaContable, Debe, Haber) VALUES (@p0, @p1, @p2, 0)", idAsiento, ctaCobro, total))
                        cmd.ExecuteNonQuery();

                    // Haber: Ingresos por Venta (Neto)
                    using (var cmd = Comando(conexion, tx,
                        "INSERT INTO detalleasiento (IdAsiento, IdCuentaContable, Debe, Haber) VALUES (@p0, @p1, 0, @p2)", idAsiento, ctaVentas, neto))
                        cmd.ExecuteNonQuery();

                    // Haber: IVA Débito Fiscal (si aplica)
                    if (iva > 0 && ctaIvaDebito > 0)
                    {
                        using (var cmd = Comando(conexion, tx,
                            "INSERT INTO detalleasiento (IdAsiento, IdCuentaContable, Debe, Haber) VALUES (@p0, @p1, 0, @p2)", idAsiento, ctaIvaDebito, iva))
                            cmd.ExecuteNonQuery();
                    }
                }

                // Asiento 2: Reconocimiento del Costo de Ventas (RF-VEN-06)
                if (costoVenta > 0 && ctaCostoVentas > 0 && ctaExistencias > 0)
                {
                    string glosaCosto = $"Costo de Ventas {folio} · Venta #{ventaId}";
                    long idAsientoCosto;
                    using (var cmd = Comando(conexion, tx,
                        @"INSERT INTO asientocontable (IdPeriodo, Fecha, Glosa, IdUsuario, Origen, IdOrigen) 
                          VALUES (@p0, CURDATE(), @p1, @p2, 'CostoVenta', @p3)", periodoId.Value, glosaCosto, usuario, ventaId))
                    {
                        cmd.ExecuteNonQuery();
                        idAsientoCosto = cmd.LastInsertedId;
                    }

                    // Debe: Costo de Ventas
                    using (var cmd = Comando(conexion, tx,
                        "INSERT INTO detalleasiento (IdAsiento, IdCuentaContable, Debe, Haber) VALUES (@p0, @p1, @p2, 0)", idAsientoCosto, ctaCostoVentas, costoVenta))
                        cmd.ExecuteNonQuery();

                    // Haber: Existencias e Inventario
                    using (var cmd = Comando(conexion, tx,
                        "INSERT INTO detalleasiento (IdAsiento, IdCuentaContable, Debe, Haber) VALUES (@p0, @p1, 0, @p2)", idAsientoCosto, ctaExistencias, costoVenta))
                        cmd.ExecuteNonQuery();
                }
            }
            catch
            {
                // La integración contable no debe detener la transacción si falta parametrización
            }
        }

        private static int ObtenerIdCuenta(MySqlConnection con, MySqlTransaction tx, string codigo)
        {
            using (var cmd = Comando(con, tx, "SELECT IdCuentaContable FROM cuentacontable WHERE Codigo = @p0 AND Imputable = 1 LIMIT 1", codigo))
            {
                var val = cmd.ExecuteScalar();
                if (val != null && val != DBNull.Value) return Convert.ToInt32(val);
                return 0;
            }
        }
    }
}
