using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Globalization;
using System.Text;
using System.Web.UI;
using System.Web.UI.WebControls;
using MySql.Data.MySqlClient;

namespace trabajo_ing_software
{
    public partial class ReporteComprasLaboratorio : Page
    {
        private readonly string connectionString = ConfigurationManager.ConnectionStrings["DefaultConnection"] != null
            ? ConfigurationManager.ConnectionStrings["DefaultConnection"].ConnectionString
            : "Server=localhost;Port=3306;Database=ERP_Dermocosmetica;Uid=root;Pwd=;";

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["IdUsuario"] == null)
            {
                Response.Redirect("Login.aspx");
                return;
            }

            string rol = Convert.ToString(Session["RolUsuario"]);
            if (!rol.Equals("Administrador", StringComparison.OrdinalIgnoreCase) &&
                !rol.Equals("Comprador", StringComparison.OrdinalIgnoreCase) &&
                !rol.Equals("Contador", StringComparison.OrdinalIgnoreCase))
            {
                ConfiguracionGlobal.RedirigirSegunRol(Response, rol);
                return;
            }

            if (!IsPostBack)
            {
                string nombre = Convert.ToString(Session["NombreUsuario"]);
                lblBienvenida.Text = nombre;
                lblAuditor.Text = string.IsNullOrEmpty(nombre) ? "Auditor Sistema" : nombre;

                lblFirmaCompras.Text = ConfiguracionGlobal.NombreJefeCompras;
                lblFirmaVentas.Text = ConfiguracionGlobal.NombreJefeVentas;
                lblFirmaInventario.Text = ConfiguracionGlobal.NombreJefeInventario;

                txtFechaDesde.Text = DateTime.Today.AddMonths(-3).ToString("yyyy-MM-01");
                txtFechaHasta.Text = DateTime.Today.ToString("yyyy-MM-dd");

                CargarLaboratorios();
                CargarMarcas();
                CargarReporte();
            }
        }

        private void CargarLaboratorios()
        {
            ddlLaboratorio.Items.Clear();
            ddlLaboratorio.Items.Add(new ListItem("Todos los Laboratorios", ""));

            using (MySqlConnection con = new MySqlConnection(connectionString))
            using (MySqlCommand cmd = new MySqlCommand("SELECT IdLaboratorio, RazonSocial FROM Laboratorio ORDER BY RazonSocial", con))
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

        private void CargarMarcas()
        {
            ddlMarca.Items.Clear();
            ddlMarca.Items.Add(new ListItem("Todas las Marcas", ""));

            string sql = @"SELECT DISTINCT MarcaNom FROM (
                               SELECT Nombre AS MarcaNom FROM Marca WHERE Activo = 1 AND IFNULL(Nombre, '') <> ''
                               UNION
                               SELECT Marca AS MarcaNom FROM Laboratorio WHERE Activo = 1 AND IFNULL(Marca, '') <> ''
                           ) t
                           ORDER BY MarcaNom";

            using (MySqlConnection con = new MySqlConnection(connectionString))
            using (MySqlCommand cmd = new MySqlCommand(sql, con))
            {
                con.Open();
                using (MySqlDataReader dr = cmd.ExecuteReader())
                {
                    while (dr.Read())
                    {
                        string m = dr["MarcaNom"].ToString();
                        ddlMarca.Items.Add(new ListItem(m, m));
                    }
                }
            }
        }

        private DataTable ConsultarComprasAgrupadas()
        {
            DateTime fDesde;
            DateTime fHasta;
            DateTime.TryParse(txtFechaDesde.Text, out fDesde);
            DateTime.TryParse(txtFechaHasta.Text, out fHasta);

            string idLab = ddlLaboratorio.SelectedValue;
            string marca = ddlMarca.SelectedValue;
            string estadoOc = ddlEstadoOC.SelectedValue;
            string tasaIvaStr = ConfiguracionGlobal.TasaIva.ToString("0.####", CultureInfo.InvariantCulture);

            string query = string.Format(@"
                SELECT l.IdLaboratorio,
                       l.RazonSocial,
                       IFNULL(l.Pais, 'Chile') AS Pais,
                       COALESCE(NULLIF(m.Nombre, ''), NULLIF(l.Marca, ''), 'Sin marca') AS MarcaEfectiva,
                       COUNT(DISTINCT oc.IdOC) AS TotalOC,
                       IFNULL(SUM(doc.CantidadPedida), 0) AS UnidadesTotales,
                       ROUND(IFNULL(SUM(doc.CantidadPedida * doc.CostoUnitario), 0), 0) AS Neto,
                       ROUND(IFNULL(SUM(doc.CantidadPedida * doc.CostoUnitario), 0) * {0}, 0) AS Iva,
                       ROUND(IFNULL(SUM(doc.CantidadPedida * doc.CostoUnitario), 0) * (1 + {0}), 0) AS Total,
                       MAX(IFNULL(rec.TotalReclamos, 0)) AS TotalReclamos
                FROM OrdenCompra oc
                INNER JOIN Laboratorio l ON l.IdLaboratorio = oc.IdLaboratorio
                INNER JOIN DetalleOrdenCompra doc ON doc.IdOC = oc.IdOC
                INNER JOIN VarianteProducto v ON v.IdVariante = doc.IdVariante
                INNER JOIN Producto p ON p.IdProducto = v.IdProducto
                LEFT JOIN Marca m ON m.IdMarca = p.IdMarca
                LEFT JOIN (
                    SELECT oc2.IdLaboratorio, COUNT(DISTINCT dp.IdDevolucion) AS TotalReclamos
                    FROM DevolucionProveedor dp
                    INNER JOIN RecepcionCompra rc ON rc.IdRecepcion = dp.IdRecepcion
                    INNER JOIN OrdenCompra oc2 ON oc2.IdOC = rc.IdOC
                    GROUP BY oc2.IdLaboratorio
                ) rec ON rec.IdLaboratorio = l.IdLaboratorio
                WHERE 1=1", tasaIvaStr);

            if (fDesde != DateTime.MinValue)
                query += " AND oc.Fecha >= @FDesde";
            if (fHasta != DateTime.MinValue)
                query += " AND oc.Fecha <= @FHasta";
            if (!string.IsNullOrEmpty(idLab))
                query += " AND oc.IdLaboratorio = @IdLab";
            if (!string.IsNullOrEmpty(marca))
                query += " AND COALESCE(NULLIF(m.Nombre, ''), NULLIF(l.Marca, ''), 'Sin marca') = @Marca";

            if (estadoOc == "VALIDAS")
                query += " AND IFNULL(oc.Estado, '') <> 'Anulada'";
            else if (estadoOc != "TODAS")
                query += " AND oc.Estado = @EstadoOC";

            query += @" GROUP BY l.IdLaboratorio, l.RazonSocial, IFNULL(l.Pais, 'Chile'), COALESCE(NULLIF(m.Nombre, ''), NULLIF(l.Marca, ''), 'Sin marca')
                        ORDER BY Total DESC, l.RazonSocial ASC";

            DataTable dt = new DataTable();
            using (MySqlConnection con = new MySqlConnection(connectionString))
            using (MySqlCommand cmd = new MySqlCommand(query, con))
            {
                if (fDesde != DateTime.MinValue)
                    cmd.Parameters.AddWithValue("@FDesde", fDesde);
                if (fHasta != DateTime.MinValue)
                    cmd.Parameters.AddWithValue("@FHasta", fHasta);
                if (!string.IsNullOrEmpty(idLab))
                    cmd.Parameters.AddWithValue("@IdLab", idLab);
                if (!string.IsNullOrEmpty(marca))
                    cmd.Parameters.AddWithValue("@Marca", marca);
                if (estadoOc != "VALIDAS" && estadoOc != "TODAS")
                    cmd.Parameters.AddWithValue("@EstadoOC", estadoOc);

                using (MySqlDataAdapter da = new MySqlDataAdapter(cmd))
                {
                    da.Fill(dt);
                }
            }

            dt.Columns.Add("ParticipacionPct", typeof(decimal));
            decimal granTotal = 0m;
            foreach (DataRow dr in dt.Rows)
            {
                granTotal += Convert.ToDecimal(dr["Total"]);
            }

            foreach (DataRow dr in dt.Rows)
            {
                decimal rowTotal = Convert.ToDecimal(dr["Total"]);
                dr["ParticipacionPct"] = granTotal > 0 ? Math.Round((rowTotal / granTotal) * 100m, 1) : 0m;
            }

            return dt;
        }

        private void CargarReporte()
        {
            DataTable dt = ConsultarComprasAgrupadas();
            gvReporte.DataSource = dt;
            gvReporte.DataBind();

            decimal inversionTotal = 0m;
            int unidadesTotales = 0;
            HashSet<int> labs = new HashSet<int>();
            string liderNombre = "Sin registros";
            decimal liderPct = 0m;

            foreach (DataRow dr in dt.Rows)
            {
                labs.Add(Convert.ToInt32(dr["IdLaboratorio"]));
                unidadesTotales += Convert.ToInt32(dr["UnidadesTotales"]);
                inversionTotal += Convert.ToDecimal(dr["Total"]);
            }

            if (dt.Rows.Count > 0)
            {
                DataRow top = dt.Rows[0];
                liderPct = Convert.ToDecimal(top["ParticipacionPct"]);
                liderNombre = string.Format("{0} ({1})", top["RazonSocial"], top["MarcaEfectiva"]);
            }

            lblKpiTotal.Text = string.Format("{0:C0}", inversionTotal);
            lblResumenTotal.Text = string.Format("{0:C0}", inversionTotal);
            lblKpiLabs.Text = labs.Count.ToString();
            lblKpiUnidades.Text = unidadesTotales.ToString("N0");
            lblKpiLider.Text = string.Format("{0:0.0}%", liderPct);
            lblKpiLiderNombre.Text = liderNombre;
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
            ddlMarca.SelectedIndex = 0;
            ddlEstadoOC.SelectedIndex = 0;
            CargarReporte();
        }

        protected void btnExportarExcel_Click(object sender, EventArgs e)
        {
            DataTable dt = ConsultarComprasAgrupadas();

            StringBuilder sb = new StringBuilder();
            sb.AppendLine("Laboratorio;País;Marca;N° Órdenes;Unidades;Neto ($);IVA ($);Total ($);Participación (%);Reclamos");

            foreach (DataRow dr in dt.Rows)
            {
                sb.AppendLine(string.Format("\"{0}\";\"{1}\";\"{2}\";{3};{4};{5};{6};{7};{8};{9}",
                    dr["RazonSocial"],
                    dr["Pais"],
                    dr["MarcaEfectiva"],
                    dr["TotalOC"],
                    dr["UnidadesTotales"],
                    dr["Neto"],
                    dr["Iva"],
                    dr["Total"],
                    dr["ParticipacionPct"],
                    dr["TotalReclamos"]
                ));
            }

            Response.Clear();
            Response.Buffer = true;
            Response.AddHeader("content-disposition", "attachment;filename=Reporte_Compras_Laboratorio_Marca.csv");
            Response.Charset = "utf-8";
            Response.ContentType = "text/csv";
            Response.ContentEncoding = Encoding.UTF8;
            Response.BinaryWrite(Encoding.UTF8.GetPreamble());
            Response.Output.Write(sb.ToString());
            Response.Flush();
            Response.End();
        }

        protected void btnLogout_Click(object sender, EventArgs e)
        {
            Session.Clear();
            Session.Abandon();
            Response.Redirect("Login.aspx");
        }
    }
}
