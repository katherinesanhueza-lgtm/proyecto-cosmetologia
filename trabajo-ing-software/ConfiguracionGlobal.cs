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
            : "Server=localhost;Port=3306;Database=ERP_Dermocosmetica;Uid=root;Pwd=;";

        // Fallbacks seguros en memoria por defecto
        private static decimal _tasaIva = 0.19m;
        private static string _nombreJefeCompras = "Javiera Rail Astudillo";
        private static string _nombreJefeVentas = "Camilo Rodríguez Saldaña";
        private static string _nombreJefeInventario = "Katherine Sanhueza Hernández";
        private static string _nombreContador = "Contador General";

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
        /// Guarda o actualiza un parámetro global en la base de datos MySQL (RF-COM-04 / RNF-13).
        /// </summary>
        public static void GuardarValor(string clave, string valor, string descripcion = null)
        {
            try
            {
                using (MySqlConnection con = new MySqlConnection(connectionString))
                {
                    con.Open();
                    string sql = @"INSERT INTO configuracionglobal (Clave, Valor, Descripcion) 
                                   VALUES (@Clave, @Valor, @Descripcion)
                                   ON DUPLICATE KEY UPDATE Valor = VALUES(Valor), Descripcion = COALESCE(VALUES(Descripcion), Descripcion);";
                    using (MySqlCommand cmd = new MySqlCommand(sql, con))
                    {
                        cmd.Parameters.AddWithValue("@Clave", clave);
                        cmd.Parameters.AddWithValue("@Valor", valor);
                        cmd.Parameters.AddWithValue("@Descripcion", descripcion ?? (object)DBNull.Value);
                        cmd.ExecuteNonQuery();
                    }
                }
            }
            catch
            {
                // Fallback silencioso ante cualquier imprevisto
            }
        }

        /// <summary>
        /// Obtiene el tipo de cambio oficial respecto al CLP (USD o EUR) con actualización diaria automática.
        /// Si ya fue consultado hoy, se recupera directamente de la base de datos en 0 ms.
        /// Si es la primera consulta del día (o se fuerza), consulta la API de divisas y guarda en BD.
        /// En caso de corte de internet o timeout, recurre a un fallback seguro y nunca arroja excepción.
        /// </summary>
        public static (decimal Tasa, string FechaDesc, bool FueEnVivo) ObtenerTipoCambio(string moneda, bool forzarActualizacion = false)
        {
            if (string.Equals(moneda, "CLP", StringComparison.OrdinalIgnoreCase))
            {
                return (1m, DateTime.Today.ToString("dd-MM-yyyy"), false);
            }

            string hoyStr = DateTime.Today.ToString("yyyy-MM-dd");
            string fechaGuardada = ObtenerValor("FechaTipoCambio", "");

            // 1. Si no se fuerza y ya se actualizó hoy, retornar valor de BD inmediatamente (0 ms)
            if (!forzarActualizacion && string.Equals(fechaGuardada, hoyStr, StringComparison.OrdinalIgnoreCase))
            {
                decimal tasaBd = ObtenerTasaGuardada(moneda);
                return (tasaBd, DateTime.Today.ToString("dd-MM-yyyy"), false);
            }

            // 2. Consulta a API en tiempo real (una sola vez por día)
            bool sincronizado = false;
            try
            {
                System.Net.ServicePointManager.SecurityProtocol = System.Net.SecurityProtocolType.Tls12;
                var request = (System.Net.HttpWebRequest)System.Net.WebRequest.Create("https://api.exchangerate-api.com/v4/latest/USD");
                request.Timeout = 2500; // 2.5 segundos máximo para evitar demoras
                request.UserAgent = "DermoERP/1.0";

                using (var response = (System.Net.HttpWebResponse)request.GetResponse())
                using (var stream = response.GetResponseStream())
                using (var reader = new System.IO.StreamReader(stream))
                {
                    string json = reader.ReadToEnd();
                    var obj = Newtonsoft.Json.Linq.JObject.Parse(json);
                    if (obj["rates"]?["CLP"] != null)
                    {
                        decimal usdClp = Convert.ToDecimal(obj["rates"]["CLP"], System.Globalization.CultureInfo.InvariantCulture);
                        decimal eurUsd = obj["rates"]?["EUR"] != null 
                            ? Convert.ToDecimal(obj["rates"]["EUR"], System.Globalization.CultureInfo.InvariantCulture) 
                            : 0.9m;
                        decimal eurClp = eurUsd > 0 ? Math.Round(usdClp / eurUsd, 2) : 1020m;
                        usdClp = Math.Round(usdClp, 2);

                        GuardarValor("TipoCambioUSD", usdClp.ToString(System.Globalization.CultureInfo.InvariantCulture), "Tipo de cambio oficial USD -> CLP");
                        GuardarValor("TipoCambioEUR", eurClp.ToString(System.Globalization.CultureInfo.InvariantCulture), "Tipo de cambio oficial EUR -> CLP");
                        GuardarValor("FechaTipoCambio", hoyStr, "Fecha de última sincronización diaria de tipo de cambio");
                        sincronizado = true;
                    }
                }
            }
            catch
            {
                // Fallback silencioso: sin internet o timeout, el sistema usa el valor de BD sin caerse
            }

            decimal tasaFinal = ObtenerTasaGuardada(moneda);
            string fechaRetorno = sincronizado ? DateTime.Today.ToString("dd-MM-yyyy") : (string.IsNullOrEmpty(fechaGuardada) ? DateTime.Today.ToString("dd-MM-yyyy") : fechaGuardada);
            return (tasaFinal, fechaRetorno, sincronizado);
        }

        private static decimal ObtenerTasaGuardada(string moneda)
        {
            if (string.Equals(moneda, "EUR", StringComparison.OrdinalIgnoreCase))
            {
                string valStr = ObtenerValor("TipoCambioEUR", "1020");
                return decimal.TryParse(valStr.Replace(",", "."), System.Globalization.NumberStyles.Any, System.Globalization.CultureInfo.InvariantCulture, out decimal eur) ? eur : 1020m;
            }
            else
            {
                string valStr = ObtenerValor("TipoCambioUSD", "950");
                return decimal.TryParse(valStr.Replace(",", "."), System.Globalization.NumberStyles.Any, System.Globalization.CultureInfo.InvariantCulture, out decimal usd) ? usd : 950m;
            }
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
        /// Jefatura / Contador General del Módulo de Contabilidad para firmas de comprobantes de pago y reportes financieros.
        /// </summary>
        public static string NombreContador
        {
            get => ObtenerValor("NombreContador", _nombreContador);
            set => _nombreContador = value;
        }

                /// <summary>
        /// Recarga parametros (las propiedades consultan directamente la base de datos).
        /// </summary>
        public static void Recargar()
        {
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
