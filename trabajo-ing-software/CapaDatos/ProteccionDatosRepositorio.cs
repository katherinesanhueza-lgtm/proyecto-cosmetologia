using System;
using System.Configuration;
using System.Data;
using MySql.Data.MySqlClient;

namespace trabajo_ing_software.CapaDatos
{
    public static class ProteccionDatosRepositorio
    {
        private static string CadenaConexion()
        {
            var entry = ConfigurationManager.ConnectionStrings["DefaultConnection"];
            return entry != null
                ? entry.ConnectionString
                : "Server=localhost;Port=3306;Database=ERP_Dermocosmetica;Uid=root;Pwd=;";
        }

        public static DataTable ListarClientesParaPrivacidad()
        {
            using (var con = ConexionErp.Crear(CadenaConexion()))
            using (var da = new MySqlDataAdapter(
                @"SELECT IdCliente, IFNULL(Rut,'') AS Rut, Nombre, IFNULL(Correo,'') AS Correo,
                         IFNULL(Telefono,'') AS Telefono, COALESCE(Activo,1) AS Activo,
                         IF(COALESCE(Activo,1)=1,'Activo','Inactivo') AS Estado
                  FROM cliente
                  ORDER BY IdCliente DESC", con))
            {
                var tabla = new DataTable();
                da.Fill(tabla);
                return tabla;
            }
        }

        public static DataRow ObtenerFichaCliente(int idCliente)
        {
            using (var con = ConexionErp.Crear(CadenaConexion()))
            using (var cmd = new MySqlCommand(
                @"SELECT IdCliente, IFNULL(Rut,'') AS Rut, Nombre, IFNULL(RazonSocial,'') AS RazonSocial,
                         IFNULL(Categoria,'') AS Categoria, IFNULL(Giro,'') AS Giro,
                         IFNULL(Direccion,'') AS Direccion, IFNULL(Contacto,'') AS Contacto,
                         IFNULL(Correo,'') AS Correo, IFNULL(Telefono,'') AS Telefono,
                         COALESCE(Activo,1) AS Activo
                  FROM cliente
                  WHERE IdCliente = @Id", con))
            {
                cmd.Parameters.AddWithValue("@Id", idCliente);
                using (var da = new MySqlDataAdapter(cmd))
                {
                    var tabla = new DataTable();
                    da.Fill(tabla);
                    return tabla.Rows.Count > 0 ? tabla.Rows[0] : null;
                }
            }
        }

        public static int AnonimizarClienteInactivo(int idCliente)
        {
            using (var con = ConexionErp.Crear(CadenaConexion()))
            using (var cmd = new MySqlCommand(
                @"UPDATE cliente
                  SET Nombre = CONCAT('Cliente Anonimizado #', IdCliente),
                      RazonSocial = CONCAT('Cliente Anonimizado #', IdCliente),
                      Correo = NULL,
                      Telefono = NULL,
                      Direccion = NULL,
                      Contacto = NULL
                  WHERE IdCliente = @Id AND COALESCE(Activo, 1) = 0", con))
            {
                cmd.Parameters.AddWithValue("@Id", idCliente);
                con.Open();
                return cmd.ExecuteNonQuery();
            }
        }
    }
}
