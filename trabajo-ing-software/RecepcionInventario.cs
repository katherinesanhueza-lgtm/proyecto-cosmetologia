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
            using (var cmd = new MySqlCommand("CALL usp_IngresarRecepcionCompra(@v,@b,@d,@u,@numero,@ingreso,@vence,@cantidad,@costo)", conexion, transaccion))
            {
                cmd.Parameters.AddWithValue("@v", variante);
                cmd.Parameters.AddWithValue("@b", bodega);
                cmd.Parameters.AddWithValue("@d", detalle);
                cmd.Parameters.AddWithValue("@u", usuario);
                cmd.Parameters.AddWithValue("@numero", numeroLote);
                cmd.Parameters.AddWithValue("@ingreso", ingreso.Date);
                cmd.Parameters.AddWithValue("@vence", vencimiento.Date);
                cmd.Parameters.AddWithValue("@cantidad", cantidad);
                cmd.Parameters.AddWithValue("@costo", costo);
                cmd.ExecuteNonQuery();
            }
        }
    }
}
