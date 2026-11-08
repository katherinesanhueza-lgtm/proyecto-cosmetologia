using System;
using System.Data;
using System.Configuration;
using MySql.Data.MySqlClient;
using System.Text;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace trabajo_ing_software
{
    public partial class ReporteOrdenesCompra : System.Web.UI.Page
    {
        private string connectionString = ConfigurationManager.ConnectionStrings["DefaultConnection"] != null ? ConfigurationManager.ConnectionStrings["DefaultConnection"].ConnectionString : "Server=localhost;Port=3306;Database=ERP_Dermocosmetica;Uid=root;Pwd=;";

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["IdUsuario"] == null)
            {
                Response.Redirect("Login.aspx");
                return;
            }

            // Control de acceso RBAC: Administrador, Comprador y Contador
            string rolUsuario = Session["RolUsuario"] != null ? Session["RolUsuario"].ToString() : "";
            if (!rolUsuario.Equals("Administrador", StringComparison.OrdinalIgnoreCase) && 
                !rolUsuario.Equals("Comprador", StringComparison.OrdinalIgnoreCase) &&
                !rolUsuario.Equals("Contador", StringComparison.OrdinalIgnoreCase))
            {
                ConfiguracionGlobal.RedirigirSegunRol(Response, rolUsuario);
                return;
            }

            ActualizarTextosIvaDinamicos();

            if (!IsPostBack)
            {
                lblBienvenida.Text = Session["NombreUsuario"] != null ? Session["NombreUsuario"].ToString() : "Usuario";
                lblAuditor.Text = lblBienvenida.Text;

                // Inyección dinámica de jefaturas de módulos para firmas formales desde ConfiguracionGlobal
                lblFirmaCompras.Text = ConfiguracionGlobal.NombreJefeCompras;
                lblFirmaVentas.Text = ConfiguracionGlobal.NombreJefeVentas;
                lblFirmaInventario.Text = ConfiguracionGlobal.NombreJefeInventario;

                txtFechaDesde.Text = DateTime.Today.AddMonths(-3).ToString("yyyy-MM-01");
                txtFechaHasta.Text = DateTime.Today.ToString("yyyy-MM-dd");

                CargarLaboratoriosDropdown();
                CargarReporte();
            }
        }

        private void ActualizarTextosIvaDinamicos()
        {
            decimal tasa = ConfiguracionGlobal.TasaIva;
            string pctStr = (tasa * 100m).ToString("0.#");
            if (lblKpiIvaPct != null) lblKpiIvaPct.Text = pctStr;

            foreach (DataControlField col in gvReporte.Columns)
            {
                if (col.HeaderText != null && col.HeaderText.StartsWith("IVA"))
                {
                    col.HeaderText = "IVA " + pctStr + "% ($)";
                    break;
                }
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
            string estado = ddlEstado.SelectedValue;

            string query = @"SELECT oc.IdOC, oc.NumeroOC, l.RazonSocial, l.Rut, oc.Fecha, oc.FechaEsperada, oc.Estado,
                                    oc.Neto, oc.Iva, oc.Total,
                                    IFNULL((SELECT SUM(doc.CantidadPedida) FROM DetalleOrdenCompra doc WHERE doc.IdOC = oc.IdOC), 0) AS ItemsTotales
                             FROM OrdenCompra oc
                             INNER JOIN Laboratorio l ON oc.IdLaboratorio = l.IdLaboratorio
                             WHERE 1=1";

            if (fDesde != DateTime.MinValue)
                query += " AND oc.Fecha >= @FDesde";
            if (fHasta != DateTime.MinValue)
                query += " AND oc.Fecha <= @FHasta";
            if (!string.IsNullOrEmpty(idLab))
                query += " AND oc.IdLaboratorio = @IdLab";
            if (!string.IsNullOrEmpty(estado))
                query += " AND oc.Estado = @Estado";

            query += " ORDER BY oc.Fecha DESC, oc.IdOC DESC";

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
                    if (!string.IsNullOrEmpty(estado))
                        cmd.Parameters.AddWithValue("@Estado", estado);

                    using (MySqlDataAdapter da = new MySqlDataAdapter(cmd))
                    {
                        DataTable dt = new DataTable();
                        da.Fill(dt);
                        ActualizarTextosIvaDinamicos();
                        gvReporte.DataSource = dt;
                        gvReporte.DataBind();

                        CalcularMetricas(dt);
                    }
                }
            }
        }

        private void CalcularMetricas(DataTable dt)
        {
            int totalOC = dt.Rows.Count;
            decimal netoTotal = 0;
            decimal ivaTotal = 0;
            decimal totalMonto = 0;
            int recibidas = 0;

            foreach (DataRow row in dt.Rows)
            {
                netoTotal += Convert.ToDecimal(row["Neto"]);
                ivaTotal += Convert.ToDecimal(row["Iva"]);
                totalMonto += Convert.ToDecimal(row["Total"]);
                if (row["Estado"].ToString() == "Recibida")
                {
                    recibidas++;
                }
            }

            lblKpiTotalOC.Text = totalOC.ToString();
            lblKpiNeto.Text = string.Format("{0:C0}", netoTotal);
            lblKpiIva.Text = string.Format("{0:C0}", ivaTotal);
            lblResumenTotal.Text = string.Format("{0:C0}", totalMonto);

            double porcentaje = totalOC > 0 ? (double)recibidas / totalOC * 100 : 0;
            lblKpiCumplimiento.Text = string.Format("{0:0.0}%", porcentaje);
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
            ddlEstado.SelectedIndex = 0;
            CargarReporte();
        }

        protected void btnExportarExcel_Click(object sender, EventArgs e)
        {
            DateTime fDesde;
            DateTime fHasta;
            DateTime.TryParse(txtFechaDesde.Text, out fDesde);
            DateTime.TryParse(txtFechaHasta.Text, out fHasta);

            string idLab = ddlLaboratorio.SelectedValue;
            string estado = ddlEstado.SelectedValue;

            string query = @"SELECT oc.NumeroOC, l.RazonSocial, l.Rut, oc.Fecha, oc.FechaEsperada, oc.Estado,
                                    IFNULL((SELECT SUM(doc.CantidadPedida) FROM DetalleOrdenCompra doc WHERE doc.IdOC = oc.IdOC), 0) AS ItemsTotales,
                                    oc.Neto, oc.Iva, oc.Total
                             FROM OrdenCompra oc
                             INNER JOIN Laboratorio l ON oc.IdLaboratorio = l.IdLaboratorio
                             WHERE 1=1";

            if (fDesde != DateTime.MinValue)
                query += " AND oc.Fecha >= @FDesde";
            if (fHasta != DateTime.MinValue)
                query += " AND oc.Fecha <= @FHasta";
            if (!string.IsNullOrEmpty(idLab))
                query += " AND oc.IdLaboratorio = @IdLab";
            if (!string.IsNullOrEmpty(estado))
                query += " AND oc.Estado = @Estado";

            query += " ORDER BY oc.Fecha DESC";

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
                    if (!string.IsNullOrEmpty(estado))
                        cmd.Parameters.AddWithValue("@Estado", estado);

                    using (MySqlDataAdapter da = new MySqlDataAdapter(cmd))
                    {
                        DataTable dt = new DataTable();
                        da.Fill(dt);

                        decimal tasa = ConfiguracionGlobal.TasaIva;
                        string pctStr = (tasa * 100m).ToString("0.#");

                        StringBuilder sb = new StringBuilder();
                        sb.AppendLine(string.Format("N° Orden;Proveedor;RUT;Fecha Emisión;Fecha Entrega;Estado;Ítems;Neto ($);IVA {0}% ($);Total ($)", pctStr));

                        foreach (DataRow dr in dt.Rows)
                        {
                            sb.AppendLine(string.Format("{0};\"{1}\";{2};{3:dd/MM/yyyy};{4:dd/MM/yyyy};{5};{6};{7};{8};{9}",
                                dr["NumeroOC"],
                                dr["RazonSocial"],
                                dr["Rut"],
                                dr["Fecha"],
                                dr["FechaEsperada"],
                                dr["Estado"],
                                dr["ItemsTotales"],
                                dr["Neto"],
                                dr["Iva"],
                                dr["Total"]
                            ));
                        }

                        Response.Clear();
                        Response.Buffer = true;
                        Response.AddHeader("content-disposition", "attachment;filename=Reporte_Estado_Ordenes_Compra.csv");
                        Response.Charset = "utf-8";
                        Response.ContentType = "text/csv";
                        Response.ContentEncoding = Encoding.UTF8;
                        Response.BinaryWrite(Encoding.UTF8.GetPreamble());
                        Response.Output.Write(sb.ToString());
                        Response.Flush();
                        Response.End();
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
