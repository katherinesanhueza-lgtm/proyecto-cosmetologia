using System;
using System.Data;
using System.Configuration;
using MySql.Data.MySqlClient;
using System.Web.UI.WebControls;

namespace trabajo_ing_software
{
    public partial class ReporteVentas : PaginaVentas
    {
        private string connectionString = ConfigurationManager.ConnectionStrings["DefaultConnection"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                txtFechaDesde.Text = new DateTime(DateTime.Today.Year, DateTime.Today.Month, 1).ToString("yyyy-MM-dd");
                txtFechaHasta.Text = DateTime.Today.ToString("yyyy-MM-dd");
                CargarFiltroClientes();
                GenerarReporteActivo();
            }
        }

        private void CargarFiltroClientes()
        {
            ddlFiltroCliente.DataSource = VentaInventario.Consultar("SELECT IdCliente, Nombre FROM cliente ORDER BY Nombre ASC");
            ddlFiltroCliente.DataTextField = "Nombre";
            ddlFiltroCliente.DataValueField = "IdCliente";
            ddlFiltroCliente.DataBind();
            ddlFiltroCliente.Items.Insert(0, new ListItem("Todos los clientes", ""));
        }

        public string GetClaseDoc(string tipo)
        {
            if (string.Equals(tipo, "Boleta", StringComparison.OrdinalIgnoreCase)) return "badge-bol";
            if (string.Equals(tipo, "Factura", StringComparison.OrdinalIgnoreCase)) return "badge-fac";
            return "badge-nc";
        }

        protected void ddlTipoReporte_SelectedIndexChanged(object sender, EventArgs e)
        {
            AlternarPaneles();
            GenerarReporteActivo();
        }

        protected void btnFiltrar_Click(object sender, EventArgs e)
        {
            GenerarReporteActivo();
        }

        private void AlternarPaneles()
        {
            pnlReporte1.Visible = ddlTipoReporte.SelectedValue == "1";
            pnlReporte2.Visible = ddlTipoReporte.SelectedValue == "2";
            pnlReporte3.Visible = ddlTipoReporte.SelectedValue == "3";
            pnlReporte4.Visible = ddlTipoReporte.SelectedValue == "4";
            pnlReporte5.Visible = ddlTipoReporte.SelectedValue == "5";

            switch (ddlTipoReporte.SelectedValue)
            {
                case "1": lblTituloReporte.InnerText = "1. Historial General de Comprobantes de Venta"; break;
                case "2": lblTituloReporte.InnerText = "2. Ventas y Rentabilidad Comercial por Producto"; break;
                case "3": lblTituloReporte.InnerText = "3. Comportamiento y Créditos por Cliente"; break;
                case "4": lblTituloReporte.InnerText = "4. Rendimiento Comercial por Vendedor"; break;
                case "5": lblTituloReporte.InnerText = "5. Presupuestos y Tasa de Conversión a Venta"; break;
            }
        }

        private void GenerarReporteActivo()
        {
            DateTime.TryParse(txtFechaDesde.Text, out DateTime desde);
            if (desde == DateTime.MinValue) desde = new DateTime(DateTime.Today.Year, 1, 1);

            DateTime.TryParse(txtFechaHasta.Text, out DateTime hasta);
            if (hasta == DateTime.MinValue) hasta = DateTime.Today;

            lblPeriodoTexto.Text = $"{desde:dd/MM/yyyy} al {hasta:dd/MM/yyyy}";

            CargarKPIs(desde, hasta);

            switch (ddlTipoReporte.SelectedValue)
            {
                case "1": CargarReporte1(desde, hasta); break;
                case "2": CargarReporte2(desde, hasta); break;
                case "3": CargarReporte3(desde, hasta); break;
                case "4": CargarReporte4(desde, hasta); break;
                case "5": CargarReporte5(desde, hasta); break;
                default: CargarReporte1(desde, hasta); break;
            }
        }

        private void CargarKPIs(DateTime desde, DateTime hasta)
        {
            using (MySqlConnection con = new MySqlConnection(connectionString))
            {
                string query = @"SELECT COUNT(IdVenta) AS Cantidad, 
                                        IFNULL(SUM(Total), 0) AS Ingresos,
                                        IFNULL(SUM(Neto), 0) AS Neto,
                                        IFNULL(SUM(Iva), 0) AS Iva
                                 FROM venta 
                                 WHERE TipoDocumento <> 'Nota de Credito'
                                   AND Fecha BETWEEN @Desde AND @Hasta";

                using (MySqlCommand cmd = new MySqlCommand(query, con))
                {
                    cmd.Parameters.AddWithValue("@Desde", desde.Date);
                    cmd.Parameters.AddWithValue("@Hasta", hasta.Date);
                    con.Open();
                    using (MySqlDataReader reader = cmd.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            int cant = Convert.ToInt32(reader["Cantidad"]);
                            decimal ingresos = Convert.ToDecimal(reader["Ingresos"]);
                            decimal neto = Convert.ToDecimal(reader["Neto"]);
                            decimal iva = Convert.ToDecimal(reader["Iva"]);

                            lblTotalTransacciones.Text = cant.ToString("N0");
                            Label1.Text = "$" + ingresos.ToString("N0");
                            lblIngresosTotales.Text = Label1.Text;
                            lblCantidadVentas.Text = cant.ToString();

                            lblNetoTotal.Text = "$" + (neto > 0 ? neto : Math.Round(ingresos / 1.19m, 2)).ToString("N0");
                            lblIvaTotal.Text = "$" + (iva > 0 ? iva : ingresos - Math.Round(ingresos / 1.19m, 2)).ToString("N0");
                        }
                    }
                }
            }
        }

        // Reporte 1: Historial General de Comprobantes
        private DataTable CargarReporte1(DateTime desde, DateTime hasta)
        {
            string filtroExtra = "";
            if (!string.IsNullOrEmpty(ddlFiltroCliente.SelectedValue))
                filtroExtra += " AND v.IdCliente = @IdCliente";

            if (ddlFiltroDocumento.SelectedValue != "Todos")
                filtroExtra += " AND v.TipoDocumento = @TipoDoc";

            string query = $@"SELECT v.IdVenta, 
                                     COALESCE(v.Folio, CONCAT('V-', v.IdVenta)) AS Folio,
                                     v.TipoDocumento,
                                     v.Fecha, 
                                     c.Nombre AS Cliente, 
                                     COALESCE(u.Nombre, 'Vendedor') AS Vendedor, 
                                     COALESCE(v.FormaPago, 'Contado') AS FormaPago,
                                     COALESCE(v.Neto, ROUND(v.Total / 1.19, 2)) AS Neto,
                                     COALESCE(v.Iva, v.Total - ROUND(v.Total / 1.19, 2)) AS Iva,
                                     v.Total 
                              FROM venta v
                              INNER JOIN cliente c ON v.IdCliente = c.IdCliente
                              LEFT JOIN usuario u ON v.IdUsuario = u.IdUsuario
                              WHERE v.Fecha BETWEEN @Desde AND @Hasta {filtroExtra}
                              ORDER BY v.IdVenta DESC";

            using (MySqlConnection con = new MySqlConnection(connectionString))
            using (MySqlCommand cmd = new MySqlCommand(query, con))
            {
                cmd.Parameters.AddWithValue("@Desde", desde.Date);
                cmd.Parameters.AddWithValue("@Hasta", hasta.Date);
                if (!string.IsNullOrEmpty(ddlFiltroCliente.SelectedValue))
                    cmd.Parameters.AddWithValue("@IdCliente", ddlFiltroCliente.SelectedValue);
                if (ddlFiltroDocumento.SelectedValue != "Todos")
                    cmd.Parameters.AddWithValue("@TipoDoc", ddlFiltroDocumento.SelectedValue);

                using (MySqlDataAdapter sda = new MySqlDataAdapter(cmd))
                {
                    DataTable dt = new DataTable();
                    sda.Fill(dt);
                    gvReporteVentas.DataSource = dt;
                    gvReporteVentas.DataBind();
                    return dt;
                }
            }
        }

        // Reporte 2: Ventas y Rentabilidad por Producto
        private DataTable CargarReporte2(DateTime desde, DateTime hasta)
        {
            string query = @"SELECT p.Nombre AS Producto, 
                                    v.Sku,
                                    SUM(vd.Cantidad) AS UnidadesVendidas, 
                                    ROUND(AVG(vd.PrecioUnitario), 0) AS PrecioPromedio,
                                    SUM(vd.Subtotal) AS IngresoTotal,
                                    ROUND(SUM(vd.Cantidad * COALESCE(v.CostoPromedio, 0)), 0) AS CostoTotal,
                                    ROUND(SUM(vd.Subtotal) - SUM(vd.Cantidad * COALESCE(v.CostoPromedio, 0)), 0) AS MargenBruto
                             FROM ventadetalle vd
                             INNER JOIN varianteproducto v ON vd.IdVariante = v.IdVariante
                             INNER JOIN producto p ON v.IdProducto = p.IdProducto
                             INNER JOIN venta vt ON vd.IdVenta = vt.IdVenta
                             WHERE vt.TipoDocumento <> 'Nota de Credito'
                               AND vt.Fecha BETWEEN @Desde AND @Hasta
                             GROUP BY p.IdProducto, p.Nombre, v.IdVariante, v.Sku
                             ORDER BY UnidadesVendidas DESC";

            using (MySqlConnection con = new MySqlConnection(connectionString))
            using (MySqlCommand cmd = new MySqlCommand(query, con))
            {
                cmd.Parameters.AddWithValue("@Desde", desde.Date);
                cmd.Parameters.AddWithValue("@Hasta", hasta.Date);
                using (MySqlDataAdapter sda = new MySqlDataAdapter(cmd))
                {
                    DataTable dt = new DataTable();
                    sda.Fill(dt);
                    gvTopProductos.DataSource = dt;
                    gvTopProductos.DataBind();
                    return dt;
                }
            }
        }

        // Reporte 3: Comportamiento y Créditos por Cliente
        private DataTable CargarReporte3(DateTime desde, DateTime hasta)
        {
            string query = @"SELECT c.Nombre AS Cliente, 
                                    c.Rut,
                                    COALESCE(c.Categoria, 'General') AS Categoria,
                                    COUNT(v.IdVenta) AS Compras, 
                                    SUM(v.Total) AS TotalGastado,
                                    (SELECT COALESCE(SUM(cc.MontoPendiente), 0) FROM cuentascobrar cc JOIN venta vt ON cc.IdVenta = vt.IdVenta WHERE vt.IdCliente = c.IdCliente AND cc.EstadoPago <> 'Pagado') AS DeudaPendiente,
                                    COALESCE(c.LimiteCredito, 0) AS LimiteCredito
                             FROM venta v 
                             INNER JOIN cliente c ON v.IdCliente = c.IdCliente 
                             WHERE v.TipoDocumento <> 'Nota de Credito'
                               AND v.Fecha BETWEEN @Desde AND @Hasta
                             GROUP BY c.IdCliente, c.Nombre, c.Rut, c.Categoria, c.LimiteCredito
                             ORDER BY TotalGastado DESC";

            using (MySqlConnection con = new MySqlConnection(connectionString))
            using (MySqlCommand cmd = new MySqlCommand(query, con))
            {
                cmd.Parameters.AddWithValue("@Desde", desde.Date);
                cmd.Parameters.AddWithValue("@Hasta", hasta.Date);
                using (MySqlDataAdapter sda = new MySqlDataAdapter(cmd))
                {
                    DataTable dt = new DataTable();
                    sda.Fill(dt);
                    gvTopClientes.DataSource = dt;
                    gvTopClientes.DataBind();
                    return dt;
                }
            }
        }

        // Reporte 4: Rendimiento Comercial por Vendedor
        private DataTable CargarReporte4(DateTime desde, DateTime hasta)
        {
            string query = @"SELECT u.Nombre AS Vendedor,
                                    u.Rol,
                                    COUNT(v.IdVenta) AS CantidadOperaciones,
                                    SUM(v.Total) AS TotalVendido,
                                    ROUND(AVG(v.Total), 0) AS TicketPromedio
                             FROM venta v
                             INNER JOIN usuario u ON v.IdUsuario = u.IdUsuario
                             WHERE v.TipoDocumento <> 'Nota de Credito'
                               AND v.Fecha BETWEEN @Desde AND @Hasta
                             GROUP BY u.IdUsuario, u.Nombre, u.Rol
                             ORDER BY TotalVendido DESC";

            using (MySqlConnection con = new MySqlConnection(connectionString))
            using (MySqlCommand cmd = new MySqlCommand(query, con))
            {
                cmd.Parameters.AddWithValue("@Desde", desde.Date);
                cmd.Parameters.AddWithValue("@Hasta", hasta.Date);
                using (MySqlDataAdapter sda = new MySqlDataAdapter(cmd))
                {
                    DataTable dt = new DataTable();
                    sda.Fill(dt);
                    gvVendedores.DataSource = dt;
                    gvVendedores.DataBind();
                    return dt;
                }
            }
        }

        // Reporte 5: Presupuestos y Tasa de Conversión
        private DataTable CargarReporte5(DateTime desde, DateTime hasta)
        {
            string query = @"SELECT c.IdCotizacion,
                                    cl.Nombre AS Cliente,
                                    c.FechaEmision,
                                    c.FechaVencimiento,
                                    c.Estado,
                                    c.Total,
                                    IF(EXISTS(SELECT 1 FROM venta v WHERE v.IdCotizacion = c.IdCotizacion), 'Concretada en Venta', 'Sin Venta') AS VentaConcretada
                             FROM cotizacion c
                             INNER JOIN cliente cl ON c.IdCliente = cl.IdCliente
                             WHERE c.FechaEmision BETWEEN @Desde AND @Hasta
                             ORDER BY c.IdCotizacion DESC";

            using (MySqlConnection con = new MySqlConnection(connectionString))
            using (MySqlCommand cmd = new MySqlCommand(query, con))
            {
                cmd.Parameters.AddWithValue("@Desde", desde.Date);
                cmd.Parameters.AddWithValue("@Hasta", hasta.Date);
                using (MySqlDataAdapter sda = new MySqlDataAdapter(cmd))
                {
                    DataTable dt = new DataTable();
                    sda.Fill(dt);
                    gvCotizacionesReporte.DataSource = dt;
                    gvCotizacionesReporte.DataBind();
                    return dt;
                }
            }
        }

        protected void btnExportarExcel_Click(object sender, EventArgs e)
        {
            DateTime.TryParse(txtFechaDesde.Text, out DateTime desde);
            if (desde == DateTime.MinValue) desde = new DateTime(DateTime.Today.Year, 1, 1);

            DateTime.TryParse(txtFechaHasta.Text, out DateTime hasta);
            if (hasta == DateTime.MinValue) hasta = DateTime.Today;

            DataTable dtExportar;
            string nombreArchivo;

            switch (ddlTipoReporte.SelectedValue)
            {
                case "2":
                    dtExportar = CargarReporte2(desde, hasta);
                    nombreArchivo = "Ventas_Rentabilidad_Productos";
                    break;
                case "3":
                    dtExportar = CargarReporte3(desde, hasta);
                    nombreArchivo = "Ventas_Credito_Clientes";
                    break;
                case "4":
                    dtExportar = CargarReporte4(desde, hasta);
                    nombreArchivo = "Rendimiento_Vendedores";
                    break;
                case "5":
                    dtExportar = CargarReporte5(desde, hasta);
                    nombreArchivo = "Presupuestos_Tasa_Conversion";
                    break;
                default:
                    dtExportar = CargarReporte1(desde, hasta);
                    nombreArchivo = "Historial_Ventas_Comprobantes";
                    break;
            }

            byte[] excelBytes = ContabilidadExportacion.Excel(dtExportar);

            Response.Clear();
            Response.Buffer = true;
            Response.ContentType = "application/vnd.ms-excel";
            Response.AddHeader("content-disposition", $"attachment;filename={nombreArchivo}_{DateTime.Now:yyyyMMdd}.xls");
            Response.Charset = "utf-8";
            Response.BinaryWrite(excelBytes);
            Response.End();
        }
    }
}
