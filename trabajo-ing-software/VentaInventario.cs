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
            var conexion = ConexionErp.Crear(ConfigurationManager.ConnectionStrings["DefaultConnection"].ConnectionString);
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
                    AgregarColumnaSiFalta(con, "venta", "Estado", "VARCHAR(30) NOT NULL DEFAULT 'Emitida'");
                    AgregarColumnaSiFalta(con, "venta", "IdVentaOrigen", "INT NULL");

                    // 4. Despachos y entregas (RF-VEN-08)
                    AgregarColumnaSiFalta(con, "despacho", "FechaEntrega", "DATE NULL");
                    AgregarColumnaSiFalta(con, "despacho", "Observaciones", "VARCHAR(255) NULL");

                    // Permitir IdLote NULL en movimientoinventario para devoluciones generales
                    try
                    {
                        using (var cmdMod = new MySqlCommand("ALTER TABLE `movimientoinventario` MODIFY COLUMN `IdLote` INT NULL", con))
                        {
                            cmdMod.ExecuteNonQuery();
                        }
                    }
                    catch { }

                    // 5. Plan de cuentas para ventas (RF-VEN-06)
                    // El plan de cuentas se carga al instalar la base.

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

            if (idCotizacion.HasValue)
            {
                using (var cmd = Comando(conexion, transaccion, @"SELECT Estado FROM cotizacion WHERE IdCotizacion=@p0
                    AND IdCliente=@p1 AND (FechaVencimiento IS NULL OR FechaVencimiento>=CURDATE()) FOR UPDATE", idCotizacion.Value, cliente))
                {
                    string estado = Convert.ToString(cmd.ExecuteScalar());
                    if (estado != "Vigente" && estado != "Aceptado") throw new InvalidOperationException("La cotización ya no está vigente para este cliente.");
                }
                using (var cmd = Comando(conexion, transaccion, "SELECT IdVenta FROM venta WHERE IdCotizacion=@p0 LIMIT 1 FOR UPDATE", idCotizacion.Value))
                    if (cmd.ExecuteScalar()!=null) throw new InvalidOperationException("La cotización ya tiene una venta.");
            }
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
                        $"Venta a crédito rechazada: El monto (${totalFinal:N0}) supera el crédito disponible del cliente (${disponible:N0}). " +
                        $"Límite total: ${limiteCredito:N0}, Deuda no cancelada: ${deudaActual:N0}.");
                }
            }

            // 3. Generar Folio correlativo (RF-VEN-03)
            string prefijo = tipoDocumento.StartsWith("Factura", StringComparison.OrdinalIgnoreCase) ? "FAC" : "BOL";
            string folio = NuevoFolio(conexion, transaccion, tipoDocumento, prefijo, 1000);

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
                DescontarFEFO(conexion, transaccion, ventaId, usuario, bodega, articulo.Key, articulo.Value, precios[articulo.Key]);
                using (var cmd = Comando(conexion, transaccion, "SELECT CostoPromedio FROM varianteproducto WHERE IdVariante=@p0", articulo.Key))
                    totalCostoVenta += Math.Round(Convert.ToDecimal(cmd.ExecuteScalar()) * articulo.Value, 2);
            }

            // 6. Integración Contable: Cuentas por Cobrar (RF-VEN-06)
            if (esCredito)
            {
                DateTime fechaVenceCalculada = vence ?? DateTime.Today.AddDays(diasCredito > 0 ? diasCredito : 30);
                using (var cmd = Comando(conexion, transaccion, "CALL usp_CrearCuentaPorCobrar(@p0,@p1,@p2,@p3)", ventaId, fechaVenceCalculada.Date, totalFinal, usuario))
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
            if (total > 0)
                Contabilizar(conexion,tx,"Venta",ventaId,"Venta "+folio,usuario,
                    new[] { formaPago.Equals("credito",StringComparison.OrdinalIgnoreCase)?"1103":"1101","4101","2108" },new[] { total,-neto,-iva });
            if (costoVenta > 0)
                Contabilizar(conexion,tx,"CostoVenta",ventaId,"Costo de venta "+folio,usuario,
                    new[] {"5101","1105"},new[] {costoVenta,-costoVenta});
        }

        internal static void Contabilizar(MySqlConnection con,MySqlTransaction tx,string origen,long id,string glosa,int usuario,string[] cuentas,decimal[] importes)
        {
            var lineas = new Newtonsoft.Json.Linq.JArray();
            for(int i=0;i<cuentas.Length;i++)
                lineas.Add(new Newtonsoft.Json.Linq.JObject { ["codigo"]=cuentas[i], ["monto"]=importes[i] });
            using(var cmd=Comando(con,tx,"CALL usp_AsientoAutomatico(@p0,@p1,@p2,@p3,CURDATE(),@p4)",origen,id,glosa,usuario,lineas.ToString()))
                cmd.ExecuteNonQuery();
        }

        internal static string NuevoFolio(MySqlConnection con, MySqlTransaction tx, string tipo, string prefijo, int inicial)
        {
            using (var cmd = Comando(con, tx, @"INSERT INTO secuenciafolio(TipoDocumento,Ultimo) VALUES(@p0,@p1+1)
                ON DUPLICATE KEY UPDATE Ultimo=GREATEST(Ultimo,@p1)+1", tipo, inicial))
                cmd.ExecuteNonQuery();
            using (var cmd = Comando(con, tx, "SELECT Ultimo FROM secuenciafolio WHERE TipoDocumento=@p0", tipo))
                return prefijo + "-" + Convert.ToInt64(cmd.ExecuteScalar()).ToString("D6");
        }

    }
}
