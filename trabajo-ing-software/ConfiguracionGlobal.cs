using System;
using System.Configuration;
using MySql.Data.MySqlClient;

namespace trabajo_ing_software
{
    /// <summary>
    /// Clase centralizada para administración de parámetros institucionales (RF-COM-04 / RNF-13).
    /// Elimina el uso de variables fijas quemadas (hardcoded) en el código fuente.
    /// Permite inyección dinámica de tasas y firmas de jefaturas de módulos desde la base de datos MySQL.
    /// </summary>
    public static class ConfiguracionGlobal
    {
        private static string connectionString => ConfigurationManager.ConnectionStrings["DefaultConnection"] != null 
            ? ConfigurationManager.ConnectionStrings["DefaultConnection"].ConnectionString 
            : "Server=localhost;Port=3306;Database=ERP_Dermocosmetica;Uid=root;Pwd=1234;";

        // Fallbacks seguros en memoria por defecto
        private static decimal _tasaIva = 0.19m;
        private static string _nombreJefeCompras = "Javiera Rail Astudillo";
        private static string _nombreJefeVentas = "Camilo Rodríguez Saldaña";
        private static string _nombreJefeInventario = "Katherine Sanhueza Hernández";

        /// <summary>
        /// Método genérico para consultar cualquier valor de configuración en BD
        /// </summary>
        private static string ObtenerValor(string clave, string fallback)
        {
            try
            {
                using (MySqlConnection con = new MySqlConnection(connectionString))
                {
                    con.Open();
                    string sql = "SELECT Valor FROM ConfiguracionGlobal WHERE Clave = @Clave LIMIT 1";
                    using (MySqlCommand cmd = new MySqlCommand(sql, con))
                    {
                        cmd.Parameters.AddWithValue("@Clave", clave);
                        object res = cmd.ExecuteScalar();
                        if (res != null && !string.IsNullOrWhiteSpace(res.ToString()))
                        {
                            return res.ToString().Trim();
                        }
                    }
                }
            }
            catch
            {
                // Fallback silencioso ante cualquier imprevisto
            }
            return fallback;
        }

        /// <summary>
        /// Tasa de IVA dinámica leída desde ConfiguracionGlobal en BD o Web.config.
        /// </summary>
        public static decimal TasaIva
        {
            get
            {
                string valStr = ObtenerValor("TasaIva", "0.19");
                if (decimal.TryParse(valStr.Replace(",", "."), System.Globalization.NumberStyles.Any, System.Globalization.CultureInfo.InvariantCulture, out decimal valBd))
                {
                    return valBd;
                }
                return _tasaIva;
            }
            set
            {
                _tasaIva = value;
            }
        }

        /// <summary>
        /// Jefatura del Módulo de Compras y Abastecimiento para inyección dinámica bajo la firma de OC y Reportes.
        /// </summary>
        public static string NombreJefeCompras
        {
            get => ObtenerValor("NombreJefeCompras", _nombreJefeCompras);
            set => _nombreJefeCompras = value;
        }

        /// <summary>
        /// Jefatura del Módulo de Ventas y Facturación para inyección dinámica en firmas de reportes.
        /// </summary>
        public static string NombreJefeVentas
        {
            get => ObtenerValor("NombreJefeVentas", _nombreJefeVentas);
            set => _nombreJefeVentas = value;
        }

        /// <summary>
        /// Jefatura del Módulo de Inventario y Kardex para inyección dinámica en firmas de reportes.
        /// </summary>
        public static string NombreJefeInventario
        {
            get => ObtenerValor("NombreJefeInventario", _nombreJefeInventario);
            set => _nombreJefeInventario = value;
        }

        /// <summary>
        /// Redirección segura según perfil operativo (RBAC).
        /// </summary>
        public static void RedirigirSegunRol(System.Web.HttpResponse response, string rol)
        {
            if (string.IsNullOrEmpty(rol))
            {
                response.Redirect("Login.aspx");
                return;
            }

            if (rol.Equals("Bodeguero", StringComparison.OrdinalIgnoreCase))
                response.Redirect("Recepciones.aspx");
            else if (rol.Equals("Comprador", StringComparison.OrdinalIgnoreCase))
                response.Redirect("OrdenesCompra.aspx");
            else if (rol.Equals("Contador", StringComparison.OrdinalIgnoreCase))
                response.Redirect("ReporteOrdenesCompra.aspx");
            else if (rol.Equals("Administrador", StringComparison.OrdinalIgnoreCase))
                response.Redirect("Usuarios.aspx");
            else
                response.Redirect("Default.aspx");
        }
    }
}
