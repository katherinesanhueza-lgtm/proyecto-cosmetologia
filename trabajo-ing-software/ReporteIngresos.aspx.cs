using System;
using System.Data;
using System.Configuration;
using MySql.Data.MySqlClient;
using System.Text;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace trabajo_ing_software
{
    public partial class ReporteIngresos : PaginaCompras
    {
        private string connectionString = ConfigurationManager.ConnectionStrings["DefaultConnection"] != null ? ConfigurationManager.ConnectionStrings["DefaultConnection"].ConnectionString : "Server=localhost;Port=3306;Database=ERP_Dermocosmetica;Uid=root;Pwd=;";

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["IdUsuario"] == null)
            {
                Response.Redirect("Login.aspx");
                return;
            }

            // Control de acceso RBAC: Administrador, Bodeguero y Contador
            string rolUsuario = Session["RolUsuario"] != null ? Session["RolUsuario"].ToString() : "";
            if (!rolUsuario.Equals("Administrador", StringComparison.OrdinalIgnoreCase) && 
                !rolUsuario.Equals("Comprador", StringComparison.OrdinalIgnoreCase) &&
                !rolUsuario.Equals("Contador", StringComparison.OrdinalIgnoreCase))
            {
                ConfiguracionGlobal.RedirigirSegunRol(Response, rolUsuario);
                return;
            }

            if (!IsPostBack)
            {
                lblBienvenida.Text = Session["NombreUsuario"] != null ? Session["NombreUsuario"].ToString() : "Usuario";
                lblAuditor.Text = lblBienvenida.Text;

                txtFechaDesde.Text = DateTime.Today.AddMonths(-3).ToString("yyyy-MM-01");
                txtFechaHasta.Text = DateTime.Today.ToString("yyyy-MM-dd");

                CargarLaboratoriosDropdown();
                CargarReporte();
            }
        }

        private void CargarLaboratoriosDropdown()
        {
            ddlLaboratorio.Items.Clear();
            ddlLaboratorio.Items.Add(new ListItem("Todos los Laboratorios", ""));

            string query = "SELECT IdLaboratorio, RazonSocial FROM Laboratorio WHERE Activo = 1 ORDER BY RazonSocial ASC";
            using (MySqlConnection con = new MySqlConnection(connectionString))
            {
                using (MySqlCommand cmd = new MySqlCommand(query, con))
                {
                    con.Open();
                    using (MySqlDataReader dr = cmd.ExecuteReader())
                    {
                        while (dr.Read())
                        {
                            ddlLaboratorio.Items.Add(new ListItem(dr["RazonSocial"].ToString(), dr["IdLaboratorio"].ToString()));
                        }
                    }
                }
            }
        }

        private void CargarReporte()
        {
            DateTime fDesde;
            DateTime fHasta;
            DateTime.TryParse(txtFechaDesde.Text, out fDesde);
            DateTime.TryParse(txtFechaHasta.Text, out fHasta);

            string idLab = ddlLaboratorio.SelectedValue;
            string estadoLote = ddlEstadoLote.SelectedValue;

            string query = @"SELECT r.IdRecepcion, oc.NumeroOC, r.GuiaDespacho, l.RazonSocial, l.Rut,
                                    r.FechaRecepcion, v.Sku, p.Nombre AS Producto, v.NombreVariante,
                                    dr.NumeroLote, dr.FechaVencimiento, dr.Cantidad, dr.CostoUnitario,
                                    (dr.Cantidad * dr.CostoUnitario) AS SubtotalLinea,
                                    IFNULL(lot.Estado, 'Disponible') AS EstadoLote
                             FROM DetalleRecepcion dr
                             INNER JOIN RecepcionCompra r ON dr.IdRecepcion = r.IdRecepcion
                             INNER JOIN OrdenCompra oc ON r.IdOC = oc.IdOC
                             INNER JOIN Laboratorio l ON oc.IdLaboratorio = l.IdLaboratorio
                             INNER JOIN VarianteProducto v ON dr.IdVariante = v.IdVariante
                             INNER JOIN Producto p ON v.IdProducto = p.IdProducto
                             LEFT JOIN Lote lot ON dr.IdVariante = lot.IdVariante AND dr.NumeroLote = lot.NumeroLote
                             WHERE 1=1";

            if (fDesde != DateTime.MinValue)
                query += " AND r.FechaRecepcion >= @FDesde";
            if (fHasta != DateTime.MinValue)
                query += " AND r.FechaRecepcion <= @FHasta";
            if (!string.IsNullOrEmpty(idLab))
                query += " AND oc.IdLaboratorio = @IdLab";
            if (!string.IsNullOrEmpty(estadoLote))
                query += " AND lot.Estado = @EstadoLote";

            query += " ORDER BY r.FechaRecepcion DESC, r.IdRecepcion DESC";

            using (MySqlConnection con = new MySqlConnection(connectionString))
            {
                using (MySqlCommand cmd = new MySqlCommand(query, con))
                {
                    if (fDesde != DateTime.MinValue)
                        cmd.Parameters.AddWithValue("@FDesde", fDesde);
                    if (fHasta != DateTime.MinValue)
                        cmd.Parameters.AddWithValue("@FHasta", fHasta);
                    if (!string.IsNullOrEmpty(idLab))
                        cmd.Parameters.AddWithValue("@IdLab", idLab);
                    if (!string.IsNullOrEmpty(estadoLote))
                        cmd.Parameters.AddWithValue("@EstadoLote", estadoLote);

                    using (MySqlDataAdapter da = new MySqlDataAdapter(cmd))
                    {
                        DataTable dt = new DataTable();
                        da.Fill(dt);
                        gvReporte.DataSource = dt;
                        gvReporte.DataBind();

                        CalcularMetricas(dt);
                    }
                }
            }
        }

        private void CalcularMetricas(DataTable dt)
        {
            System.Collections.Generic.HashSet<int> recepcionesUnicas = new System.Collections.Generic.HashSet<int>();
            int totalUnidades = 0;
            decimal totalMonto = 0;
            int lotesActivos = 0;

            foreach (DataRow row in dt.Rows)
            {
                recepcionesUnicas.Add(Convert.ToInt32(row["IdRecepcion"]));
                totalUnidades += Convert.ToInt32(row["Cantidad"]);
                totalMonto += Convert.ToDecimal(row["SubtotalLinea"]);
                if (row["EstadoLote"].ToString() == "Disponible")
                {
                    lotesActivos++;
                }
            }

            lblKpiTotalRec.Text = recepcionesUnicas.Count.ToString();
            lblKpiTotalUnidades.Text = totalUnidades.ToString();
            lblKpiMontoTotal.Text = string.Format("{0:C0}", totalMonto);
            lblKpiLotes.Text = lotesActivos.ToString();
            lblResumenTotal.Text = string.Format("{0:C0}", totalMonto);
        }

        protected void btnFiltrar_Click(object sender, EventArgs e)
        {
            CargarReporte();
        }

        protected void btnLimpiar_Click(object sender, EventArgs e)
        {
            txtFechaDesde.Text = DateTime.Today.AddMonths(-3).ToString("yyyy-MM-01");
            txtFechaHasta.Text = DateTime.Today.ToString("yyyy-MM-dd");
            ddlLaboratorio.SelectedIndex = 0;
            ddlEstadoLote.SelectedIndex = 0;
            CargarReporte();
        }

        protected void btnExportarExcel_Click(object sender, EventArgs e)
        {
            DateTime fDesde;
            DateTime fHasta;
            DateTime.TryParse(txtFechaDesde.Text, out fDesde);
            DateTime.TryParse(txtFechaHasta.Text, out fHasta);

            string idLab = ddlLaboratorio.SelectedValue;
            string estadoLote = ddlEstadoLote.SelectedValue;

            string query = @"SELECT r.IdRecepcion, oc.NumeroOC, r.GuiaDespacho, l.RazonSocial, l.Rut,
                                    r.FechaRecepcion, v.Sku, p.Nombre AS Producto, v.NombreVariante,
                                    dr.NumeroLote, dr.FechaVencimiento, dr.Cantidad, dr.CostoUnitario,
                                    (dr.Cantidad * dr.CostoUnitario) AS SubtotalLinea
                             FROM DetalleRecepcion dr
                             INNER JOIN RecepcionCompra r ON dr.IdRecepcion = r.IdRecepcion
                             INNER JOIN OrdenCompra oc ON r.IdOC = oc.IdOC
                             INNER JOIN Laboratorio l ON oc.IdLaboratorio = l.IdLaboratorio
                             INNER JOIN VarianteProducto v ON dr.IdVariante = v.IdVariante
                             INNER JOIN Producto p ON v.IdProducto = p.IdProducto
                             LEFT JOIN Lote lot ON dr.IdVariante = lot.IdVariante AND dr.NumeroLote = lot.NumeroLote
                             WHERE 1=1";

            if (fDesde != DateTime.MinValue)
                query += " AND r.FechaRecepcion >= @FDesde";
            if (fHasta != DateTime.MinValue)
                query += " AND r.FechaRecepcion <= @FHasta";
            if (!string.IsNullOrEmpty(idLab))
                query += " AND oc.IdLaboratorio = @IdLab";
            if (!string.IsNullOrEmpty(estadoLote))
                query += " AND lot.Estado = @EstadoLote";

            query += " ORDER BY r.FechaRecepcion DESC";

            using (MySqlConnection con = new MySqlConnection(connectionString))
            {
                using (MySqlCommand cmd = new MySqlCommand(query, con))
                {
                    if (fDesde != DateTime.MinValue)
                        cmd.Parameters.AddWithValue("@FDesde", fDesde);
                    if (fHasta != DateTime.MinValue)
                        cmd.Parameters.AddWithValue("@FHasta", fHasta);
                    if (!string.IsNullOrEmpty(idLab))
                        cmd.Parameters.AddWithValue("@IdLab", idLab);
                    if (!string.IsNullOrEmpty(estadoLote))
                        cmd.Parameters.AddWithValue("@EstadoLote", estadoLote);

                    using (MySqlDataAdapter da = new MySqlDataAdapter(cmd))
                    {
                        DataTable dt = new DataTable();
                        da.Fill(dt);

                        DataTable limpio = new DataTable();
                        limpio.Columns.Add("N° Recepción", typeof(string));
                        limpio.Columns.Add("N° OC", typeof(string));
                        limpio.Columns.Add("Guía Despacho", typeof(string));
                        limpio.Columns.Add("Proveedor", typeof(string));
                        limpio.Columns.Add("RUT", typeof(string));
                        limpio.Columns.Add("Fecha Ingreso", typeof(DateTime));
                        limpio.Columns.Add("SKU", typeof(string));
                        limpio.Columns.Add("Producto", typeof(string));
                        limpio.Columns.Add("Variante", typeof(string));
                        limpio.Columns.Add("Lote Asignado", typeof(string));
                        limpio.Columns.Add("Fecha Vencimiento", typeof(string));
                        limpio.Columns.Add("Cantidad", typeof(int));
                        limpio.Columns.Add("Costo Unitario (CLP)", typeof(decimal));
                        limpio.Columns.Add("Total Línea (CLP)", typeof(decimal));

                        foreach (DataRow r in dt.Rows)
                        {
                            string venc = r["FechaVencimiento"] != DBNull.Value
                                ? Convert.ToDateTime(r["FechaVencimiento"]).ToString("dd/MM/yyyy")
                                : "";
                            limpio.Rows.Add(
                                "REC-" + Convert.ToInt32(r["IdRecepcion"]).ToString("D4"),
                                Convert.ToString(r["NumeroOC"]),
                                Convert.ToString(r["GuiaDespacho"]),
                                Convert.ToString(r["RazonSocial"]),
                                Convert.ToString(r["Rut"]),
                                Convert.ToDateTime(r["FechaRecepcion"]),
                                Convert.ToString(r["Sku"]),
                                Convert.ToString(r["Producto"]),
                                Convert.ToString(r["NombreVariante"]),
                                Convert.ToString(r["NumeroLote"]),
                                venc,
                                Convert.ToInt32(r["Cantidad"]),
                                Convert.ToDecimal(r["CostoUnitario"]),
                                Convert.ToDecimal(r["SubtotalLinea"])
                            );
                        }

                        ContabilidadExportacion.DescargarExcel(Response, limpio, "Consolidado_Ingresos_Lotes");
                    }
                }
            }
        }

        protected void btnLogout_Click(object sender, EventArgs e)
        {
            Session.Clear();
            Session.Abandon();
            Response.Redirect("Login.aspx");
        }
    }
}
