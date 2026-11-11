using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using MySql.Data.MySqlClient;

namespace trabajo_ing_software
{
    internal static class VentaInventario
    {
        internal static MySqlConnection Abrir()
        {
            var conexion = new MySqlConnection(ConfigurationManager.ConnectionStrings["DefaultConnection"].ConnectionString);
            conexion.Open();
            return conexion;
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
            if (carrito.Count == 0) throw new InvalidOperationException("Agrega al menos un producto.");
            long venta;
            using (var cmd = Comando(conexion, transaccion,
                "INSERT INTO venta(TipoDocumento,Fecha,Total,IdCliente,IdUsuario) VALUES('Boleta',CURDATE(),0,@p0,@p1)", cliente, usuario))
            {
                cmd.ExecuteNonQuery();
                venta = cmd.LastInsertedId;
            }

            decimal total = 0;
            foreach (var articulo in carrito)
                total += Retirar(conexion, transaccion, venta, usuario, bodega, articulo.Key, articulo.Value);

            using (var cmd = Comando(conexion, transaccion, "UPDATE venta SET Total=@p0 WHERE IdVenta=@p1", total, venta))
                cmd.ExecuteNonQuery();
            if (vence.HasValue)
            {
                using (var cmd = Comando(conexion, transaccion, @"INSERT INTO cuentascobrar
                    (IdVenta,FechaVence,MontoPendiente,EstadoPago,IdUsuario)
                    VALUES(@p0,@p1,@p2,'Pendiente',@p3)", venta, vence.Value.Date, total, usuario))
                    cmd.ExecuteNonQuery();
            }
            return venta;
        }

        private static decimal Retirar(MySqlConnection conexion, MySqlTransaction tx,
            long venta, int usuario, int bodega, int variante, int cantidad)
        {
            if (cantidad <= 0) throw new InvalidOperationException("La cantidad debe ser mayor a cero.");
            decimal precio;
            using (var cmd = Comando(conexion, tx, @"SELECT v.PrecioVenta FROM varianteproducto v
                JOIN producto p ON p.IdProducto=v.IdProducto
                WHERE v.IdVariante=@p0 AND v.Activo=1 AND p.Activo=1 FOR UPDATE", variante))
            {
                var valor = cmd.ExecuteScalar();
                if (valor == null || valor == DBNull.Value || Convert.ToDecimal(valor) <= 0)
                    throw new InvalidOperationException("El SKU ya no está activo o no tiene precio de venta.");
                precio = Convert.ToDecimal(valor);
            }

            using (var cmd = Comando(conexion, tx, "SELECT IdBodega FROM bodega WHERE IdBodega=@p0 AND Activo=1 FOR UPDATE", bodega))
                if (cmd.ExecuteScalar() == null) throw new InvalidOperationException("Selecciona una bodega activa.");

            int stock;
            int idInventario;
            using (var cmd = Comando(conexion, tx, @"SELECT IdInventario, COALESCE(StockActual,0), COALESCE(StockReservado,0)
                FROM inventario WHERE IdVariante=@p0 AND IdBodega=@p1 FOR UPDATE", variante, bodega))
            using (var lector = cmd.ExecuteReader())
            {
                if (!lector.Read()) throw new InvalidOperationException("El SKU no tiene existencias en esta bodega.");
                idInventario = lector.GetInt32(0);
                stock = lector.GetInt32(1);
                if (cantidad > stock - lector.GetInt32(2))
                    throw new InvalidOperationException("Stock disponible insuficiente en la bodega elegida.");
                if (lector.Read()) throw new InvalidOperationException("Hay saldos duplicados para ese SKU y bodega.");
            }

            var lotes = new List<KeyValuePair<int, int>>();
            int pendiente = cantidad;
            using (var cmd = Comando(conexion, tx, @"SELECT IdLote,CantidadDisponible FROM lote
                WHERE IdVariante=@p0 AND IdBodega=@p1 AND Estado='Disponible' AND CantidadDisponible>0
                  AND (FechaVencimiento IS NULL OR FechaVencimiento>=CURDATE())
                ORDER BY FechaVencimiento IS NULL,FechaVencimiento,IdLote FOR UPDATE", variante, bodega))
            using (var lector = cmd.ExecuteReader())
            {
                while (pendiente > 0 && lector.Read())
                {
                    int unidades = Math.Min(pendiente, lector.GetInt32(1));
                    lotes.Add(new KeyValuePair<int, int>(lector.GetInt32(0), unidades));
                    pendiente -= unidades;
                }
            }
            if (pendiente != 0)
                throw new InvalidOperationException("No hay suficientes unidades asignadas a lotes disponibles. Revisa los lotes de la bodega.");

            foreach (var lote in lotes)
            {
                long detalle;
                using (var cmd = Comando(conexion, tx, @"INSERT INTO ventadetalle(IdVenta,IdVariante,Cantidad,PrecioUnitario,Subtotal)
                    VALUES(@p0,@p1,@p2,@p3,@p4)", venta, variante, lote.Value, precio, precio * lote.Value))
                {
                    cmd.ExecuteNonQuery();
                    detalle = cmd.LastInsertedId;
                }
                using (var cmd = Comando(conexion, tx, @"UPDATE lote SET
                    Estado=IF(CantidadDisponible=@p0,'Agotado',Estado),CantidadDisponible=CantidadDisponible-@p0
                    WHERE IdLote=@p1", lote.Value, lote.Key))
                    cmd.ExecuteNonQuery();

                using (var cmd = Comando(conexion, tx, @"INSERT INTO movimientoinventario
                    (IdLote,IdBodega,IdTipoMovimiento,IdUsuario,Cantidad,StockAnterior,StockPosterior,Referencia,Observacion,Origen,IdDetalleOrigen)
                    SELECT @p0,@p1,IdTipoMovimiento,@p2,@p3,@p4,@p5,@p6,'Venta confirmada','Salida',@p7
                    FROM tipomovimiento WHERE Nombre='Salida' ORDER BY IdTipoMovimiento LIMIT 1",
                    lote.Key, bodega, usuario, lote.Value, stock, stock - lote.Value, "Venta #" + venta, detalle))
                {
                    if (cmd.ExecuteNonQuery() != 1) throw new InvalidOperationException("Falta el tipo de movimiento Salida.");
                }
                stock -= lote.Value;
            }

            using (var cmd = Comando(conexion, tx,
                "UPDATE inventario SET StockActual=@p0,FechaActualizada=NOW() WHERE IdInventario=@p1", stock, idInventario))
                cmd.ExecuteNonQuery();
            using (var cmd = Comando(conexion, tx, @"UPDATE varianteproducto SET StockTotal=
                (SELECT COALESCE(SUM(StockActual),0) FROM inventario WHERE IdVariante=@p0) WHERE IdVariante=@p0", variante))
                cmd.ExecuteNonQuery();
            return precio * cantidad;
        }
    }
}
