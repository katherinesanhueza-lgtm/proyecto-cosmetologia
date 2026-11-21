using System;
using System.Configuration;
using System.Globalization;
using MySql.Data.MySqlClient;

namespace trabajo_ing_software
{
    public partial class _Default : System.Web.UI.Page
    {
        private static readonly CultureInfo CulturaCl = new CultureInfo("es-CL");

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["IdUsuario"] == null)
            {
                Response.Redirect("Login.aspx");
                return;
            }

            if (!IsPostBack)
            {
                MostrarFecha();
                CargarIndicadores();
            }
        }

        protected void btnLogout_Click(object sender, EventArgs e)
        {
            Session.Clear();
            Session.Abandon();
            Response.Redirect("Login.aspx");
        }

        private void MostrarFecha()
        {
            lblFecha.Text = DateTime.Now.ToString("dd-MM-yyyy");
        }

        private void CargarIndicadores()
        {
            lblComprasTotal.Text = "$0";
            lblComprasDetalle.Text = "0 órdenes · 0 laboratorios";
            lblVentasTotal.Text = "$0";
            lblVentasDetalle.Text = "0 documentos · 0 clientes";
            lblProductos.Text = "0";
            lblInventarioDetalle.Text = "0 unidades en stock";
            lblContabilidadTotal.Text = "0";
            lblContabilidadDetalle.Text = "0 CxP · 0 CxC vigentes";
            lblStockBajo.Text = "0";
            lblBodegas.Text = "0";
            lblOperacionesCurso.Text = "0";

            var configuracion = ConfigurationManager.ConnectionStrings["DefaultConnection"];

            if (configuracion == null || string.IsNullOrWhiteSpace(configuracion.ConnectionString))
            {
                MostrarError("No se ha configurado la conexión a la base de datos.");
                return;
            }

            try
            {
                using (MySqlConnection conexion = new MySqlConnection(configuracion.ConnectionString))
                {
                    conexion.Open();

                    // 1. INVENTARIO
                    int productos = EjecutarConteo(conexion, "SELECT COUNT(*) FROM producto WHERE Activo = 1");
                    int unidadesStock = EjecutarConteo(conexion, "SELECT COALESCE(SUM(StockActual), 0) FROM inventario");
                    int stockBajo = EjecutarConteo(conexion, @"
                        SELECT COUNT(DISTINCT p.IdProducto)
                        FROM producto p
                        INNER JOIN varianteproducto v ON p.IdProducto = v.IdProducto
                        INNER JOIN inventario i ON v.IdVariante = i.IdVariante
                        INNER JOIN bodega b ON i.IdBodega = b.IdBodega
                        WHERE p.Activo = 1 AND v.Activo = 1 AND b.Activo = 1
                          AND i.StockActual > 0 AND i.StockActual <= COALESCE(p.StockMinimo, 0)");
                    int bodegas = EjecutarConteo(conexion, "SELECT COUNT(*) FROM bodega WHERE Activo = 1");
                    int lotesActivos = EjecutarConteo(conexion, "SELECT COUNT(*) FROM lote WHERE CantidadDisponible > 0");

                    // 2. COMPRAS
                    decimal totalCompras = EjecutarDecimal(conexion, "SELECT COALESCE(SUM(Total), 0) FROM ordencompra WHERE Estado <> 'Anulada'");
                    int ordenesCompra = EjecutarConteo(conexion, "SELECT COUNT(*) FROM ordencompra WHERE Estado <> 'Anulada'");
                    int labsActivos = EjecutarConteo(conexion, "SELECT COUNT(*) FROM laboratorio WHERE Activo = 1");

                    // 3. VENTAS
                    decimal totalVentas = EjecutarDecimal(conexion, "SELECT COALESCE(SUM(Total), 0) FROM venta WHERE COALESCE(Estado, 'Emitida') <> 'Anulada'");
                    int cantVentas = EjecutarConteo(conexion, "SELECT COUNT(*) FROM venta WHERE COALESCE(Estado, 'Emitida') <> 'Anulada'");
                    int clientesActivos = EjecutarConteo(conexion, "SELECT COUNT(*) FROM cliente");

                    // 4. CONTABILIDAD
                    int asientos = EjecutarConteo(conexion, "SELECT COUNT(*) FROM asientocontable");
                    int cxpPendientes = EjecutarConteo(conexion, "SELECT COUNT(*) FROM cuentaporpagar WHERE Estado <> 'Pagada'");
                    int cxcPendientes = EjecutarConteo(conexion, "SELECT COUNT(*) FROM cuentascobrar WHERE COALESCE(EstadoPago, 'Pendiente') <> 'Pagado'");

                    lblComprasTotal.Text = totalCompras.ToString("C0", CulturaCl);
                    lblComprasDetalle.Text = $"{ordenesCompra} órdenes · {labsActivos} laboratorios";

                    lblVentasTotal.Text = totalVentas.ToString("C0", CulturaCl);
                    lblVentasDetalle.Text = $"{cantVentas} documentos · {clientesActivos} clientes";

                    lblProductos.Text = productos.ToString("N0", CulturaCl);
                    lblInventarioDetalle.Text = $"{unidadesStock.ToString("N0", CulturaCl)} unidades en stock";

                    lblContabilidadTotal.Text = asientos.ToString("N0", CulturaCl);
                    lblContabilidadDetalle.Text = $"{cxpPendientes} CxP · {cxcPendientes} CxC vigentes";

                    lblStockBajo.Text = stockBajo.ToString("N0", CulturaCl);
                    lblBodegas.Text = bodegas.ToString("N0", CulturaCl);
                    lblOperacionesCurso.Text = lotesActivos.ToString("N0", CulturaCl);

                    MostrarEstado("Sistema operativo. Base de datos disponible.");
                }
            }
            catch (MySqlException)
            {
                MostrarError("No fue posible conectar con MySQL.");
            }
            catch (Exception)
            {
                MostrarError("Ocurrió un error al cargar los indicadores.");
            }
        }

        private int EjecutarConteo(MySqlConnection conexion, string consulta)
        {
            try
            {
                using (MySqlCommand comando = new MySqlCommand(consulta, conexion))
                {
                    object val = comando.ExecuteScalar();
                    return val == null || val == DBNull.Value ? 0 : Convert.ToInt32(val);
                }
            }
            catch
            {
                return 0;
            }
        }

        private decimal EjecutarDecimal(MySqlConnection conexion, string consulta)
        {
            try
            {
                using (MySqlCommand comando = new MySqlCommand(consulta, conexion))
                {
                    object val = comando.ExecuteScalar();
                    return val == null || val == DBNull.Value ? 0m : Convert.ToDecimal(val);
                }
            }
            catch
            {
                return 0m;
            }
        }

        private void MostrarError(string mensaje)
        {
            MostrarEstado(mensaje);
        }

        private void MostrarEstado(string mensaje)
        {
            bool conectado = mensaje.StartsWith("Sistema operativo");

            if (conectado)
            {
                lblEstadoSistema.Text = "Sistema operativo";
                lblDescripcionEstado.Text = "La conexión con la base de datos y los módulos del ERP se encuentra disponible.";
                indicadorEstado.Attributes["style"] = "background-color: #27AE60;";
            }
            else
            {
                lblEstadoSistema.Text = "Sistema no disponible";
                lblDescripcionEstado.Text = mensaje;
                indicadorEstado.Attributes["style"] = "background-color: #C0392B;";
            }
        }
    }
}
