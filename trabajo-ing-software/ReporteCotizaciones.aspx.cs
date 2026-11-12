using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Text;
using System.Web.UI;
using System.Web.UI.WebControls;
using MySql.Data.MySqlClient;

namespace trabajo_ing_software
{
    public partial class ReporteCotizaciones : Page
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

                CargarInsumos();
                CargarLaboratorios();
                CargarReporte();
            }
        }

        private void CargarInsumos()
        {
            ddlVariante.Items.Clear();
            ddlVariante.Items.Add(new ListItem("Todos los Insumos (SKU)", ""));

            string sql = @"SELECT v.IdVariante, v.Sku, p.Nombre, IFNULL(v.NombreVariante, '') AS Variante
                           FROM VarianteProducto v
                           INNER JOIN Producto p ON p.IdProducto = v.IdProducto
                           ORDER BY p.Nombre, v.Sku";

            using (MySqlConnection con = new MySqlConnection(connectionString))
            using (MySqlCommand cmd = new MySqlCommand(sql, con))
            {
                con.Open();
                using (MySqlDataReader dr = cmd.ExecuteReader())
                {
                    while (dr.Read())
                    {
                        string texto = string.Format("[{0}] {1} {2}", dr["Sku"], dr["Nombre"], dr["Variante"]).Trim();
                        ddlVariante.Items.Add(new ListItem(texto, dr["IdVariante"].ToString()));
                    }
                }
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

        private DataTable ConsultarHistorialRaw()
        {
            DateTime fDesde;
            DateTime fHasta;
            DateTime.TryParse(txtFechaDesde.Text, out fDesde);
            DateTime.TryParse(txtFechaHasta.Text, out fHasta);

            string idVar = ddlVariante.SelectedValue;
            string idLab = ddlLaboratorio.SelectedValue;
            string tipoOp = ddlTipoOperacion.SelectedValue;

            string query = @"SELECT t.IdVariante, t.Sku, t.Producto, t.Laboratorio, t.IdLaboratorio, t.Fecha,
                                    t.TipoOperacion, t.Documento, t.EstadoDoc,
                                    t.Moneda, t.TipoCambio, t.CostoOrigen, t.CostoUnitarioCLP,
                                    t.Cantidad, t.CostoPromedioActual, t.PrecioVenta, t.OrdenCronologico
                             FROM (
                                 SELECT d.IdVariante,
                                        v.Sku,
                                        CONCAT(p.Nombre, ' - ', IFNULL(v.NombreVariante, '')) AS Producto,
                                        l.RazonSocial AS Laboratorio,
                                        c.IdLaboratorio,
                                        c.Fecha,
                                        'Cotización' AS TipoOperacion,
                                        CONCAT('COT-', LPAD(c.IdCotizacion, 4, '0')) AS Documento,
                                        IFNULL(c.Estado, 'Solicitada') AS EstadoDoc,
                                        IFNULL(c.Moneda, 'USD') AS Moneda,
                                        IFNULL(c.TipoCambio, 1) AS TipoCambio,
                                        d.CostoUnitario AS CostoOrigen,
                                        ROUND(d.CostoUnitario * IFNULL(c.TipoCambio, 1), 0) AS CostoUnitarioCLP,
                                        d.Cantidad,
                                        IFNULL(v.CostoPromedio, 0) AS CostoPromedioActual,
                                        IFNULL(v.PrecioVenta, 0) AS PrecioVenta,
                                        1 AS OrdenCronologico
                                 FROM DetalleCotizacion d
                                 INNER JOIN CotizacionImportacion c ON c.IdCotizacion = d.IdCotizacion
                                 INNER JOIN Laboratorio l ON l.IdLaboratorio = c.IdLaboratorio
                                 INNER JOIN VarianteProducto v ON v.IdVariante = d.IdVariante
                                 INNER JOIN Producto p ON p.IdProducto = v.IdProducto

                                 UNION ALL

                                 SELECT doc.IdVariante,
                                        v.Sku,
                                        CONCAT(p.Nombre, ' - ', IFNULL(v.NombreVariante, '')) AS Producto,
                                        l.RazonSocial AS Laboratorio,
                                        oc.IdLaboratorio,
                                        oc.Fecha,
                                        'Orden de Compra' AS TipoOperacion,
                                        oc.NumeroOC AS Documento,
                                        IFNULL(oc.Estado, 'Emitida') AS EstadoDoc,
                                        'CLP' AS Moneda,
                                        1.0000 AS TipoCambio,
                                        doc.CostoUnitario AS CostoOrigen,
                                        ROUND(doc.CostoUnitario, 0) AS CostoUnitarioCLP,
                                        doc.CantidadPedida AS Cantidad,
                                        IFNULL(v.CostoPromedio, 0) AS CostoPromedioActual,
                                        IFNULL(v.PrecioVenta, 0) AS PrecioVenta,
                                        2 AS OrdenCronologico
                                 FROM DetalleOrdenCompra doc
                                 INNER JOIN OrdenCompra oc ON oc.IdOC = doc.IdOC
                                 INNER JOIN Laboratorio l ON l.IdLaboratorio = oc.IdLaboratorio
                                 INNER JOIN VarianteProducto v ON v.IdVariante = doc.IdVariante
                                 INNER JOIN Producto p ON p.IdProducto = v.IdProducto
                                 WHERE IFNULL(oc.Estado, '') <> 'Anulada'
                             ) t
                             WHERE 1=1";

            if (fDesde != DateTime.MinValue)
                query += " AND t.Fecha >= @FDesde";
            if (fHasta != DateTime.MinValue)
                query += " AND t.Fecha <= @FHasta";
            if (!string.IsNullOrEmpty(idVar))
                query += " AND t.IdVariante = @IdVar";
            if (!string.IsNullOrEmpty(idLab))
                query += " AND t.IdLaboratorio = @IdLab";
            if (!string.IsNullOrEmpty(tipoOp))
                query += " AND t.TipoOperacion = @TipoOp";

            query += " ORDER BY t.IdVariante ASC, t.Fecha ASC, t.OrdenCronologico ASC, t.Documento ASC";

            using (MySqlConnection con = new MySqlConnection(connectionString))
            using (MySqlCommand cmd = new MySqlCommand(query, con))
            {
                if (fDesde != DateTime.MinValue)
                    cmd.Parameters.AddWithValue("@FDesde", fDesde);
                if (fHasta != DateTime.MinValue)
                    cmd.Parameters.AddWithValue("@FHasta", fHasta);
                if (!string.IsNullOrEmpty(idVar))
                    cmd.Parameters.AddWithValue("@IdVar", idVar);
                if (!string.IsNullOrEmpty(idLab))
                    cmd.Parameters.AddWithValue("@IdLab", idLab);
                if (!string.IsNullOrEmpty(tipoOp))
                    cmd.Parameters.AddWithValue("@TipoOp", tipoOp);

                using (MySqlDataAdapter da = new MySqlDataAdapter(cmd))
                {
                    DataTable dt = new DataTable();
                    da.Fill(dt);
                    return dt;
                }
            }
        }

        private DataTable ConstruirTablaConVariaciones(out int totalRegistros, out int totalSkus, out decimal varPromPct, out decimal mayorAlzaPct, out string skuMayorAlza, out decimal costoPromClp)
        {
            DataTable dtRaw = ConsultarHistorialRaw();

            DataTable dtOut = new DataTable();
            dtOut.Columns.Add("Fecha", typeof(DateTime));
            dtOut.Columns.Add("Sku", typeof(string));
            dtOut.Columns.Add("Producto", typeof(string));
            dtOut.Columns.Add("Laboratorio", typeof(string));
            dtOut.Columns.Add("TipoOperacion", typeof(string));
            dtOut.Columns.Add("ClaseOrigen", typeof(string));
            dtOut.Columns.Add("Documento", typeof(string));
            dtOut.Columns.Add("EstadoDoc", typeof(string));
            dtOut.Columns.Add("Moneda", typeof(string));
            dtOut.Columns.Add("TipoCambio", typeof(decimal));
            dtOut.Columns.Add("CostoOrigen", typeof(decimal));
            dtOut.Columns.Add("CostoUnitarioCLP", typeof(decimal));
            dtOut.Columns.Add("CostoPromedioActual", typeof(decimal));
            dtOut.Columns.Add("VariacionPct", typeof(decimal));
            dtOut.Columns.Add("VariacionTxt", typeof(string));
            dtOut.Columns.Add("VariacionDetalle", typeof(string));
            dtOut.Columns.Add("ClaseVariacion", typeof(string));
            dtOut.Columns.Add("MargenTxt", typeof(string));

            Dictionary<int, decimal> ultimoCostoSku = new Dictionary<int, decimal>();
            HashSet<int> skusDistintos = new HashSet<int>();

            decimal sumaVarPct = 0m;
            int conteoPares = 0;
            mayorAlzaPct = 0m;
            skuMayorAlza = "Sin incrementos";
            decimal sumaCostoClp = 0m;

            foreach (DataRow dr in dtRaw.Rows)
            {
                int idVar = Convert.ToInt32(dr["IdVariante"]);
                string sku = Convert.ToString(dr["Sku"]);
                decimal costoClp = Convert.ToDecimal(dr["CostoUnitarioCLP"]);
                decimal cppActual = Convert.ToDecimal(dr["CostoPromedioActual"]);
                decimal precioVenta = Convert.ToDecimal(dr["PrecioVenta"]);
                string tipoOp = Convert.ToString(dr["TipoOperacion"]);

                skusDistintos.Add(idVar);
                sumaCostoClp += costoClp;

                decimal varPct = 0m;
                string varTxt;
                string varDetalle;
                string claseVar;

                if (ultimoCostoSku.ContainsKey(idVar) && ultimoCostoSku[idVar] > 0)
                {
                    decimal prev = ultimoCostoSku[idVar];
                    decimal diff = costoClp - prev;
                    varPct = (diff / prev) * 100m;

                    sumaVarPct += varPct;
                    conteoPares++;

                    if (varPct > mayorAlzaPct)
                    {
                        mayorAlzaPct = varPct;
                        skuMayorAlza = sku;
                    }

                    if (varPct > 0.005m)
                    {
                        varTxt = string.Format("+{0:0.00}%", varPct);
                        varDetalle = string.Format("+{0:C0} vs anterior", diff);
                        claseVar = "badge-var-alza";
                    }
                    else if (varPct < -0.005m)
                    {
                        varTxt = string.Format("{0:0.00}%", varPct);
                        varDetalle = string.Format("{0:C0} vs anterior", diff);
                        claseVar = "badge-var-baja";
                    }
                    else
                    {
                        varTxt = "0,00%";
                        varDetalle = "Sin variación";
                        claseVar = "badge-var-estable";
                    }
                }
                else
                {
                    varTxt = "Base inicial";
                    if (cppActual > 0)
                    {
                        decimal vsCpp = ((costoClp - cppActual) / cppActual) * 100m;
                        varDetalle = string.Format("{0:+0.0;-0.0;0.0}% vs CPP", vsCpp);
                    }
                    else
                    {
                        varDetalle = "Primer registro";
                    }
                    claseVar = "badge-var-estable";
                }

                ultimoCostoSku[idVar] = costoClp;

                string margenTxt = precioVenta > 0
                    ? string.Format("{0:0.0}%", ((precioVenta - costoClp) / precioVenta) * 100m)
                    : "N/D";

                string claseOrigen = tipoOp.StartsWith("Cotiz", StringComparison.OrdinalIgnoreCase)
                    ? "badge-op-cot"
                    : "badge-op-oc";

                dtOut.Rows.Add(
                    Convert.ToDateTime(dr["Fecha"]),
                    sku,
                    Convert.ToString(dr["Producto"]),
                    Convert.ToString(dr["Laboratorio"]),
                    tipoOp,
                    claseOrigen,
                    Convert.ToString(dr["Documento"]),
                    Convert.ToString(dr["EstadoDoc"]),
                    Convert.ToString(dr["Moneda"]),
                    Convert.ToDecimal(dr["TipoCambio"]),
                    Convert.ToDecimal(dr["CostoOrigen"]),
                    costoClp,
                    cppActual,
                    varPct,
                    varTxt,
                    varDetalle,
                    claseVar,
                    margenTxt
                );
            }

            totalRegistros = dtOut.Rows.Count;
            totalSkus = skusDistintos.Count;
            varPromPct = conteoPares > 0 ? sumaVarPct / conteoPares : 0m;
            costoPromClp = totalRegistros > 0 ? sumaCostoClp / totalRegistros : 0m;

            DataView dv = dtOut.DefaultView;
            dv.Sort = "Fecha DESC, Documento DESC";
            return dv.ToTable();
        }

        private void CargarReporte()
        {
            int totalRegistros, totalSkus;
            decimal varPromPct, mayorAlzaPct, costoPromClp;
            string skuMayorAlza;

            DataTable dt = ConstruirTablaConVariaciones(out totalRegistros, out totalSkus, out varPromPct, out mayorAlzaPct, out skuMayorAlza, out costoPromClp);
            gvReporte.DataSource = dt;
            gvReporte.DataBind();

            lblKpiRegistros.Text = totalRegistros.ToString();
            lblKpiSkus.Text = totalSkus.ToString();
            lblKpiVarPromedio.Text = string.Format("{0:+0.00;-0.00;0.00}%", varPromPct);
            lblKpiMayorAlza.Text = mayorAlzaPct > 0 ? string.Format("+{0:0.00}%", mayorAlzaPct) : "0.00%";
            lblKpiSkuAlza.Text = mayorAlzaPct > 0 ? "SKU: " + skuMayorAlza : "Sin incrementos";
            lblKpiCostoPromedio.Text = string.Format("{0:C0}", costoPromClp);
            lblResumenPromedio.Text = string.Format("{0:C0}", costoPromClp);
        }

        protected void btnFiltrar_Click(object sender, EventArgs e)
        {
            CargarReporte();
        }

        protected void btnLimpiar_Click(object sender, EventArgs e)
        {
            txtFechaDesde.Text = DateTime.Today.AddMonths(-3).ToString("yyyy-MM-01");
            txtFechaHasta.Text = DateTime.Today.ToString("yyyy-MM-dd");
            ddlVariante.SelectedIndex = 0;
            ddlLaboratorio.SelectedIndex = 0;
            ddlTipoOperacion.SelectedIndex = 0;
            CargarReporte();
        }

        protected void btnExportarExcel_Click(object sender, EventArgs e)
        {
            int totalRegistros, totalSkus;
            decimal varPromPct, mayorAlzaPct, costoPromClp;
            string skuMayorAlza;

            DataTable dt = ConstruirTablaConVariaciones(out totalRegistros, out totalSkus, out varPromPct, out mayorAlzaPct, out skuMayorAlza, out costoPromClp);

            StringBuilder sb = new StringBuilder();
            sb.AppendLine("Fecha;SKU;Producto;Laboratorio;Origen;Documento;Estado;Moneda;Tipo Cambio (CLP);Costo Origen;Costo Unitario (CLP);CPP Actual (CLP);Variación Histórica;Detalle Variación;Margen Est.");

            foreach (DataRow dr in dt.Rows)
            {
                sb.AppendLine(string.Format("{0:dd/MM/yyyy};{1};\"{2}\";\"{3}\";{4};{5};{6};{7};{8};{9};{10};{11};{12};\"{13}\";{14}",
                    dr["Fecha"],
                    dr["Sku"],
                    dr["Producto"],
                    dr["Laboratorio"],
                    dr["TipoOperacion"],
                    dr["Documento"],
                    dr["EstadoDoc"],
                    dr["Moneda"],
                    dr["TipoCambio"],
                    dr["CostoOrigen"],
                    dr["CostoUnitarioCLP"],
                    dr["CostoPromedioActual"],
                    dr["VariacionTxt"],
                    dr["VariacionDetalle"],
                    dr["MargenTxt"]
                ));
            }

            Response.Clear();
            Response.Buffer = true;
            Response.AddHeader("content-disposition", "attachment;filename=Reporte_Variacion_Costos_Insumos.csv");
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
