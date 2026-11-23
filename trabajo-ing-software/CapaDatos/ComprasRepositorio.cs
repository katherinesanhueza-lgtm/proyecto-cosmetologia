using System;
using System.Configuration;
using System.Data;
using MySql.Data.MySqlClient;

namespace trabajo_ing_software.CapaDatos
{
    public static class ComprasRepositorio
    {
        private static string CadenaConexion()
        {
            var entry = ConfigurationManager.ConnectionStrings["DefaultConnection"];
            return entry != null
                ? entry.ConnectionString
                : "Server=localhost;Port=3306;Database=ERP_Dermocosmetica;Uid=root;Pwd=;";
        }

        public static DataTable ListarMarcas()
        {
            using (var con = ConexionErp.Crear(CadenaConexion()))
            using (var da = new MySqlDataAdapter(
                "SELECT IdMarca, Nombre, IFNULL(Descripcion, '') AS Descripcion, Activo, IF(Activo=1,'Activa','Inactiva') AS Estado FROM marca ORDER BY Nombre", con))
            {
                var tabla = new DataTable();
                da.Fill(tabla);
                return tabla;
            }
        }

        public static DataRow ObtenerMarca(int idMarca)
        {
            using (var con = ConexionErp.Crear(CadenaConexion()))
            using (var cmd = new MySqlCommand(
                "SELECT IdMarca, Nombre, IFNULL(Descripcion, '') AS Descripcion, Activo FROM marca WHERE IdMarca=@id", con))
            {
                cmd.Parameters.AddWithValue("@id", idMarca);
                using (var da = new MySqlDataAdapter(cmd))
                {
                    var tabla = new DataTable();
                    da.Fill(tabla);
                    return tabla.Rows.Count > 0 ? tabla.Rows[0] : null;
                }
            }
        }

        public static void GuardarMarca(int? idMarca, string nombre, string descripcion, bool activa)
        {
            string sql = idMarca.HasValue
                ? "UPDATE marca SET Nombre=@n, Descripcion=@d, Activo=@a WHERE IdMarca=@id"
                : "INSERT INTO marca(Nombre, Descripcion, Activo) VALUES(@n, @d, @a)";

            using (var con = ConexionErp.Crear(CadenaConexion()))
            using (var cmd = new MySqlCommand(sql, con))
            {
                cmd.Parameters.AddWithValue("@n", nombre);
                cmd.Parameters.AddWithValue("@d", descripcion);
                cmd.Parameters.AddWithValue("@a", activa);
                if (idMarca.HasValue)
                    cmd.Parameters.AddWithValue("@id", idMarca.Value);

                con.Open();
                cmd.ExecuteNonQuery();
            }
        }

        public static DataTable ListarLaboratorios(string filtro, string pais, string estado)
        {
            string query = "SELECT IdLaboratorio, Rut, RazonSocial, Marca, Pais, Contacto, Email, Telefono, DiasPago, Activo FROM Laboratorio WHERE 1=1";
            if (!string.IsNullOrEmpty(filtro))
                query += " AND (RazonSocial LIKE @Filtro OR Marca LIKE @Filtro OR Contacto LIKE @Filtro OR Rut LIKE @Filtro)";
            if (!string.IsNullOrEmpty(pais))
                query += " AND Pais LIKE @Pais";
            if (!string.IsNullOrEmpty(estado))
                query += " AND Activo = @Estado";
            query += " ORDER BY IdLaboratorio DESC";

            using (var con = ConexionErp.Crear(CadenaConexion()))
            using (var cmd = new MySqlCommand(query, con))
            {
                if (!string.IsNullOrEmpty(filtro))
                    cmd.Parameters.AddWithValue("@Filtro", "%" + filtro + "%");
                if (!string.IsNullOrEmpty(pais))
                    cmd.Parameters.AddWithValue("@Pais", "%" + pais + "%");
                if (!string.IsNullOrEmpty(estado))
                    cmd.Parameters.AddWithValue("@Estado", estado == "1");

                using (var da = new MySqlDataAdapter(cmd))
                {
                    var tabla = new DataTable();
                    da.Fill(tabla);
                    return tabla;
                }
            }
        }
    }
}
