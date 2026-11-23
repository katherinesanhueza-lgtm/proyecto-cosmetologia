using System;
using System.Data;
using System.Web;
using MySql.Data.MySqlClient;

namespace trabajo_ing_software
{
    public static class ConexionErp
    {
        public static MySqlConnection Crear(string cadena)
        {
            var conexion = new MySqlConnection(cadena);
            conexion.StateChange += delegate(object sender, StateChangeEventArgs cambio)
            {
                if (cambio.CurrentState != ConnectionState.Open) return;
                int id;
                object actor = int.TryParse(Convert.ToString(HttpContext.Current?.Session?["IdUsuario"]), out id) ? (object)id : DBNull.Value;
                using (var cmd = new MySqlCommand("CALL usp_UsuarioAuditoria(@actor)", conexion))
                {
                    cmd.Parameters.AddWithValue("@actor", actor);
                    cmd.ExecuteNonQuery();
                }
            };
            return conexion;
        }

        public static string MensajeError(Exception error)
        {
            System.Diagnostics.Trace.TraceError(error.ToString());
            return error is ArgumentException || error is InvalidOperationException
                ? HttpUtility.HtmlEncode(error.Message) : "No se pudo completar la operación. Revisa los datos e inténtalo de nuevo.";
        }
    }
}
