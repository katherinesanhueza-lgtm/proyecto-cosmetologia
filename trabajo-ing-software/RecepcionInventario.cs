using System;
using MySql.Data.MySqlClient;

namespace trabajo_ing_software
{
    internal static class RecepcionInventario
    {
        internal static void Ingresar(MySqlConnection conexion, MySqlTransaction transaccion,
            int variante, int bodega, int detalle, int usuario, string numeroLote,
            DateTime ingreso, DateTime vencimiento, int cantidad, decimal costo)
        {
            if (cantidad <= 0 || vencimiento.Date < ingreso.Date || costo < 0)
                throw new InvalidOperationException("Revisa cantidad, costo y fecha de vencimiento.");

            // Usa el mismo bloqueo de variante que los movimientos de Inventario.
            using (var cmd = Crear(conexion, transaccion,
                @"SELECT v.IdVariante FROM varianteproducto v JOIN producto p ON p.IdProducto=v.IdProducto
                  WHERE v.IdVariante=@variante AND v.Activo=1 AND p.Activo=1 FOR UPDATE", variante, bodega))
                if (cmd.ExecuteScalar() == null) throw new InvalidOperationException("La variante ya no está activa.");

            using (var cmd = Crear(conexion, transaccion,
                "SELECT IdBodega FROM bodega WHERE IdBodega=@bodega AND Activo=1 FOR UPDATE", variante, bodega))
                if (cmd.ExecuteScalar() == null) throw new InvalidOperationException("Selecciona una bodega activa.");

            int inventario = 0;
            int anterior = 0;
            using (var cmd = Crear(conexion, transaccion,
                @"SELECT IdInventario, COALESCE(StockActual,0) FROM inventario
                  WHERE IdVariante=@variante AND IdBodega=@bodega FOR UPDATE", variante, bodega))
            using (var lector = cmd.ExecuteReader())
            {
                if (lector.Read())
                {
                    inventario = lector.GetInt32(0);
                    anterior = lector.GetInt32(1);
                    if (lector.Read()) throw new InvalidOperationException("Hay más de un saldo para esa variante y bodega.");
                }
            }

            int posterior = checked(anterior + cantidad);
            using (var cmd = Crear(conexion, transaccion, inventario == 0
                ? "INSERT INTO inventario(IdVariante,IdBodega,StockActual,StockReservado,FechaActualizada) VALUES(@variante,@bodega,@stock,0,NOW())"
                : "UPDATE inventario SET StockActual=@stock,FechaActualizada=NOW() WHERE IdInventario=@id", variante, bodega))
            {
                cmd.Parameters.AddWithValue("@stock", posterior);
                cmd.Parameters.AddWithValue("@id", inventario);
                cmd.ExecuteNonQuery();
            }

            long lote;
            using (var cmd = Crear(conexion, transaccion,
                @"INSERT INTO lote(IdVariante,IdBodega,NumeroLote,FechaIngreso,FechaVencimiento,CostoUnitario,CantidadInicial,CantidadDisponible,Estado)
                  VALUES(@variante,@bodega,@numero,@ingreso,@vence,@costo,@cantidad,@cantidad,'Disponible')", variante, bodega))
            {
                cmd.Parameters.AddWithValue("@numero", numeroLote);
                cmd.Parameters.AddWithValue("@ingreso", ingreso.Date);
                cmd.Parameters.AddWithValue("@vence", vencimiento.Date);
                cmd.Parameters.AddWithValue("@costo", costo);
                cmd.Parameters.AddWithValue("@cantidad", cantidad);
                cmd.ExecuteNonQuery();
                lote = cmd.LastInsertedId;
            }

            using (var cmd = Crear(conexion, transaccion,
                @"INSERT INTO movimientoinventario(IdLote,IdBodega,IdTipoMovimiento,IdUsuario,Cantidad,StockAnterior,StockPosterior,Referencia,Observacion,Origen,IdDetalleOrigen)
                  SELECT @lote,@bodega,IdTipoMovimiento,@usuario,@cantidad,@anterior,@posterior,@referencia,'Recepción de compra','Entrada',@detalle
                  FROM tipomovimiento WHERE Nombre='Entrada' ORDER BY IdTipoMovimiento LIMIT 1", variante, bodega))
            {
                cmd.Parameters.AddWithValue("@lote", lote);
                cmd.Parameters.AddWithValue("@usuario", usuario);
                cmd.Parameters.AddWithValue("@cantidad", cantidad);
                cmd.Parameters.AddWithValue("@anterior", anterior);
                cmd.Parameters.AddWithValue("@posterior", posterior);
                cmd.Parameters.AddWithValue("@referencia", "Entrada #" + detalle);
                cmd.Parameters.AddWithValue("@detalle", detalle);
                if (cmd.ExecuteNonQuery() != 1) throw new InvalidOperationException("Falta el tipo de movimiento Entrada de Inventario.");
            }

            using (var cmd = Crear(conexion, transaccion, @"UPDATE varianteproducto v
                JOIN (SELECT COALESCE(SUM(StockActual),0) AS Total FROM inventario WHERE IdVariante=@variante) s
                SET v.CostoPromedio=CASE
                        WHEN s.Total=@cantidad THEN @costo
                        WHEN COALESCE(v.CostoPromedio,0)>0
                            THEN ROUND((v.CostoPromedio*(s.Total-@cantidad)+@costo*@cantidad)/NULLIF(s.Total,0),2)
                        ELSE v.CostoPromedio END,
                    v.StockTotal=s.Total
                WHERE v.IdVariante=@variante", variante, bodega))
            {
                cmd.Parameters.AddWithValue("@cantidad", cantidad);
                cmd.Parameters.AddWithValue("@costo", costo);
                cmd.ExecuteNonQuery();
            }
        }

        private static MySqlCommand Crear(MySqlConnection conexion, MySqlTransaction transaccion,
            string sql, int variante, int bodega)
        {
            var comando = new MySqlCommand(sql, conexion, transaccion);
            comando.Parameters.AddWithValue("@variante", variante);
            comando.Parameters.AddWithValue("@bodega", bodega);
            return comando;
        }
    }
}
