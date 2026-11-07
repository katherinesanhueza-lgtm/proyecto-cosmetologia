using System;
using System.Configuration;
using MySql.Data.MySqlClient;

namespace Cosmetologia
{
    public partial class PruebaConexion : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            string cadena = ConfigurationManager
                .ConnectionStrings["ConexionMySQL"]
                .ConnectionString;

            using (MySqlConnection conexion = new MySqlConnection(cadena))
            {
                try
                {
                    conexion.Open();

                    Response.Write("<h1>Conexión exitosa</h1>");
                    Response.Write("<p>Visual Studio está conectado a MySQL correctamente.</p>");
                    Response.Write("<p>Base de datos: " + conexion.Database + "</p>");
                }
                catch (Exception ex)
                {
                    Response.Write("<h1>Error de conexión</h1>");
                    Response.Write("<p>" + ex.Message + "</p>");
                }
            }
        }
    }
}