using System;
using System.Data;
using System.Configuration;
using MySql.Data.MySqlClient;

namespace trabajo_ing_software
{
    public partial class ReporteVentas : PaginaVentas
    {
        string connectionString = ConfigurationManager.ConnectionStrings["DefaultConnection"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                CargarKPIs();
                CargarHistorial();
                CargarReporteClientes();
                CargarReporteProductos();
            }
        }

        private void CargarKPIs()
        {
            using (MySqlConnection con = new MySqlConnection(connectionString))
            {
                string query = "SELECT COUNT(IdVenta) AS Cantidad, IFNULL(SUM(Total), 0) AS Ingresos FROM Venta WHERE TipoDocumento <> 'Nota de Credito'";
                using (MySqlCommand cmd = new MySqlCommand(query, con))
                {
                    con.Open();
                    using (MySqlDataReader reader = cmd.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            lblCantidadVentas.Text = reader["Cantidad"].ToString();
                            lblIngresosTotales.Text = "$" + Convert.ToInt32(reader["Ingresos"]).ToString("N0");
                        }
                    }
                }
            }
        }

        private void CargarHistorial()
        {
            using (MySqlConnection con = new MySqlConnection(connectionString))
            {
                string query = @"SELECT v.IdVenta, v.Fecha, c.Nombre AS Cliente, u.Nombre AS Vendedor, v.Total 
                                 FROM Venta v
                                 INNER JOIN Cliente c ON v.IdCliente = c.IdCliente
                                 LEFT JOIN Usuario u ON v.IdUsuario = u.IdUsuario
                                 WHERE v.TipoDocumento <> 'Nota de Credito' ORDER BY v.IdVenta DESC";
                using (MySqlCommand cmd = new MySqlCommand(query, con))
                {
                    using (MySqlDataAdapter sda = new MySqlDataAdapter(cmd))
                    {
                        DataTable dt = new DataTable();
                        sda.Fill(dt);
                        gvReporteVentas.DataSource = dt;
                        gvReporteVentas.DataBind();
                    }
                }
            }
        }
        private void CargarReporteProductos()
        {
            using (MySqlConnection con = new MySqlConnection(connectionString))
            {
                string query = @"SELECT p.Nombre AS Producto, SUM(vd.Cantidad) AS UnidadesVendidas, SUM(vd.Subtotal) AS IngresoTotal 
                 FROM VentaDetalle vd 
                 INNER JOIN VarianteProducto vp ON vd.IdVariante = vp.IdVariante
                 INNER JOIN Producto p ON vp.IdProducto = p.IdProducto 
                 GROUP BY p.IdProducto 
                 ORDER BY UnidadesVendidas DESC LIMIT 5";

                using (MySqlCommand cmd = new MySqlCommand(query, con))
                {
                    using (MySqlDataAdapter sda = new MySqlDataAdapter(cmd))
                    {
                        DataTable dt = new DataTable();
                        sda.Fill(dt);
                        gvTopProductos.DataSource = dt;
                        gvTopProductos.DataBind();
                    }
                }
            }
        }
        private void CargarReporteClientes()
        {
            using (MySqlConnection con = new MySqlConnection(connectionString))
            {
                string query = @"SELECT c.Nombre AS Cliente, COUNT(v.IdVenta) AS Compras, SUM(v.Total) AS TotalGastado 
                                 FROM Venta v 
                                 INNER JOIN Cliente c ON v.IdCliente = c.IdCliente 
                                 WHERE v.TipoDocumento <> 'Nota de Credito' GROUP BY c.IdCliente 
                                 ORDER BY TotalGastado DESC LIMIT 5";
                using (MySqlCommand cmd = new MySqlCommand(query, con))
                {
                    using (MySqlDataAdapter sda = new MySqlDataAdapter(cmd))
                    {
                        DataTable dt = new DataTable();
                        sda.Fill(dt);
                        gvTopClientes.DataSource = dt;
                        gvTopClientes.DataBind();
                    }
                }
            }
        }
        protected void btnVolverVentas_Click(object sender, EventArgs e)
        {
            Response.Redirect("Ventas.aspx");
        }
    }
}