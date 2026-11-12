
using System;
using System.Configuration;
using MySql.Data.MySqlClient;

namespace trabajo_ing_software
{
    public partial class _Default : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                MostrarFecha();
                CargarIndicadores();
            }
        }

        private void MostrarFecha()
        {
            lblFecha.Text = DateTime.Now.ToString("dd/MM/yyyy");
        }

        private void CargarIndicadores()
        {
            lblProductos.Text = "-";
            lblStockBajo.Text = "-";
            lblBodegas.Text = "-";

            var configuracion = ConfigurationManager
                .ConnectionStrings["DefaultConnection"];

            if (configuracion == null ||
                string.IsNullOrWhiteSpace(configuracion.ConnectionString))
            {
                MostrarError("No se ha configurado la conexión a la base de datos.");
                return;
            }

            try
            {
                using (MySqlConnection conexion =
                    new MySqlConnection(configuracion.ConnectionString))
                {
                    conexion.Open();

                    // PRODUCTOS ACTIVOS
                    string sqlProductos = @"
                        SELECT COUNT(*)
                        FROM producto
                        WHERE Activo = 1";

                    // PRODUCTOS CON STOCK BAJO
                    // No incluye productos agotados.
                    string sqlStock = @"
                        SELECT COUNT(DISTINCT p.IdProducto)
                        FROM producto p
                        INNER JOIN varianteproducto v
                            ON p.IdProducto = v.IdProducto
                        INNER JOIN inventario i
                            ON v.IdVariante = i.IdVariante
                        INNER JOIN bodega b
                            ON i.IdBodega = b.IdBodega
                        WHERE p.Activo = 1
                          AND v.Activo = 1
                          AND b.Activo = 1
                          AND i.StockActual > 0
                          AND i.StockActual <= COALESCE(p.StockMinimo, 0)";

                    // BODEGAS ACTIVAS
                    string sqlBodegas = @"
                        SELECT COUNT(*)
                        FROM bodega
                        WHERE Activo = 1";

                    int productos = EjecutarConteo(conexion, sqlProductos);
                    int stockBajo = EjecutarConteo(conexion, sqlStock);
                    int bodegas = EjecutarConteo(conexion, sqlBodegas);

                    lblProductos.Text = productos.ToString();
                    lblStockBajo.Text = stockBajo.ToString();
                    lblBodegas.Text = bodegas.ToString();

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

        private int EjecutarConteo(
            MySqlConnection conexion, string consulta)
        {
            using (MySqlCommand comando =
                new MySqlCommand(consulta, conexion))
            {
                return Convert.ToInt32(comando.ExecuteScalar());
            }
        }

        private void MostrarError(string mensaje) { MostrarEstado(mensaje);
            lblProductos.Text = "-";
            lblStockBajo.Text = "-";
            lblBodegas.Text = "-";

        }
private void MostrarEstado(string mensaje)
        {
            bool conectado = mensaje.StartsWith("Sistema operativo");

            if (conectado)
            {
                lblEstadoSistema.Text = "Sistema operativo";

                lblDescripcionEstado.Text =
                    "La conexión con la base de datos se encuentra disponible.";

                indicadorEstado.Attributes["style"] =
                    "background-color: #8B6F56;";
            }
            else
            {
                lblEstadoSistema.Text = "Sistema no disponible";

                lblDescripcionEstado.Text = mensaje;

                indicadorEstado.Attributes["style"] =
                    "background-color: #C65B5B;";
            }
        }

    } }
   
