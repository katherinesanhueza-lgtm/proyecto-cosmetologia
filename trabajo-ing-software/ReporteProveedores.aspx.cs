using System;
using System.Data;
using System.Configuration;
using System.Text;
using System.Web.UI.WebControls;
using MySql.Data.MySqlClient;


namespace trabajo_ing_software

{

    public partial class ReporteProveedores : System.Web.UI.Page

    {

        string connectionString = ConfigurationManager.ConnectionStrings["DefaultConnection"] != null ? ConfigurationManager.ConnectionStrings["DefaultConnection"].ConnectionString : "Server=localhost;Port=3306;Database=ERP_Dermocosmetica;Uid=root;Pwd=;";


        protected void Page_Load(object sender, EventArgs e)

        {

            if (Session["IdUsuario"] == null)

            {

                Response.Redirect("Login.aspx");

                return;

            }


            // Control de acceso RBAC: Solo Administrador y Comprador

            string rolUsuario = Session["RolUsuario"] != null ? Session["RolUsuario"].ToString() : "";

            if (!rolUsuario.Equals("Administrador", StringComparison.OrdinalIgnoreCase) && 

                !rolUsuario.Equals("Comprador", StringComparison.OrdinalIgnoreCase))

            {

                ConfiguracionGlobal.RedirigirSegunRol(Response, rolUsuario);

                return;

            }


            if (!IsPostBack)

            {

                lblBienvenida.Text = Session["NombreUsuario"] != null ? Session["NombreUsuario"].ToString() : "Usuario";

                lblFirmaCompras.Text = ConfiguracionGlobal.NombreJefeCompras;
                lblFirmaVentas.Text = ConfiguracionGlobal.NombreJefeVentas;
                lblFirmaInventario.Text = ConfiguracionGlobal.NombreJefeInventario;

                CargarPaises();
                CargarMetricasGenerales();

                CargarTablaReporte();

            }

        }


        // 1. Cargar las tarjetas superiores (KPIs y Ajustes de BI)

        private void CargarMetricasGenerales()

        {

            using (MySqlConnection con = new MySqlConnection(connectionString))

            {

                con.Open();


                // 1. Total Labs y Total OC

                string queryConteo = @"

                    SELECT 

                        (SELECT COUNT(*) FROM Laboratorio WHERE Activo = 1) AS TotalLabs,

                        (SELECT COUNT(*) FROM OrdenCompra) AS TotalOC,

                        (SELECT IFNULL(AVG(DiasPago), 0) FROM Laboratorio WHERE Activo = 1) AS PromedioDias";


                using (MySqlCommand cmd = new MySqlCommand(queryConteo, con))

                {

                    using (MySqlDataReader reader = cmd.ExecuteReader())

                    {

                        if (reader.Read())

                        {

                            lblTotalLaboratorios.Text = reader["TotalLabs"].ToString();

                            lblTotalOC.Text = reader["TotalOC"].ToString();

                            if (lblPromedioDias != null)

                            {

                                lblPromedioDias.Text = Convert.ToInt32(reader["PromedioDias"]).ToString();

                            }

                        }

                    }

                }


                // 2. Ajuste BI: Lead Time Global (Días promedio entre OC y Recepción)

                string queryLeadTime = @"

                    SELECT IFNULL(AVG(DATEDIFF(rc.FechaRecepcion, oc.Fecha)), 0)

                    FROM RecepcionCompra rc

                    INNER JOIN OrdenCompra oc ON rc.IdOC = oc.IdOC";


                using (MySqlCommand cmd = new MySqlCommand(queryLeadTime, con))

                {

                    object res = cmd.ExecuteScalar();

                    double leadTimePromedio = (res != null && res != DBNull.Value) ? Convert.ToDouble(res) : 0.0;

                    lblLeadTimeGlobal.Text = leadTimePromedio.ToString("F1");

                }


                // 3. Ajuste BI: Tasa Global de Defectos (% devoluciones vs recepciones)

                string queryDefectos = @"

                    SELECT 

                        CASE 

                            WHEN COUNT(DISTINCT rc.IdRecepcion) = 0 THEN 0.0

                            ELSE ROUND((COUNT(DISTINCT dp.IdDevolucion) * 100.0 / COUNT(DISTINCT rc.IdRecepcion)), 1)

                        END

                    FROM RecepcionCompra rc

                    LEFT JOIN DevolucionProveedor dp ON rc.IdRecepcion = dp.IdRecepcion";


                using (MySqlCommand cmd = new MySqlCommand(queryDefectos, con))

                {

                    object res = cmd.ExecuteScalar();

                    double tasa = (res != null && res != DBNull.Value) ? Convert.ToDouble(res) : 0.0;

                    lblTasaDefectosGlobal.Text = tasa.ToString("F1") + "%";

                }


                // 4. Cumplimiento Global

                string queryCumplimiento = @"

                    SELECT 

                        CASE 

                            WHEN COUNT(DISTINCT oc.IdOC) = 0 THEN 100

                            ELSE ROUND(COUNT(DISTINCT rc.IdRecepcion) * 100.0 / COUNT(DISTINCT oc.IdOC))

                        END

                    FROM OrdenCompra oc

                    LEFT JOIN RecepcionCompra rc ON oc.IdOC = rc.IdOC";


                using (MySqlCommand cmd = new MySqlCommand(queryCumplimiento, con))

                {

                    object res = cmd.ExecuteScalar();

                    int cumplimiento = (res != null && res != DBNull.Value) ? Convert.ToInt32(res) : 100;

                    lblCumplimientoGlobal.Text = cumplimiento.ToString() + "%";

                }

            }

        }


        private void CargarPaises()
        {
            ddlFiltroPais.Items.Clear();
            ddlFiltroPais.Items.Add(new ListItem("Todos los Países", ""));
            using (MySqlConnection con = new MySqlConnection(connectionString))
            using (MySqlCommand cmd = new MySqlCommand("SELECT DISTINCT IFNULL(Pais, 'N/A') AS Pais FROM Laboratorio WHERE Activo = 1 ORDER BY Pais", con))
            {
                con.Open();
                using (MySqlDataReader dr = cmd.ExecuteReader())
                {
                    while (dr.Read())
                    {
                        string p = dr["Pais"].ToString();
                        ddlFiltroPais.Items.Add(new ListItem(p, p));
                    }
                }
            }
        }

        // 2. Consultar tabla analítica con métricas de BI por proveedor y filtros
        private DataTable ConsultarTablaProveedores()
        {
            string busq = (txtBuscar.Text ?? "").Trim();
            string pais = ddlFiltroPais.SelectedValue;
            string calif = ddlFiltroCalificacion.SelectedValue;

            using (MySqlConnection con = new MySqlConnection(connectionString))
            {
                string queryReporte = @"
                    SELECT * FROM (
                        SELECT 
                            l.IdLaboratorio,
                            l.RazonSocial,
                            l.Marca,
                            IFNULL(l.Pais, 'N/A') AS Pais,
                            l.DiasPago,
                            COUNT(DISTINCT oc.IdOC) AS TotalOC,
                            COUNT(DISTINCT rc.IdRecepcion) AS TotalRecepciones,
                            COUNT(DISTINCT dp.IdDevolucion) AS TotalDevoluciones,
                            IFNULL(AVG(DATEDIFF(rc.FechaRecepcion, oc.Fecha)), 0) AS LeadTimePromedioDias,
                            CASE 
                                WHEN COUNT(DISTINCT rc.IdRecepcion) = 0 THEN 0.0
                                ELSE ROUND((COUNT(DISTINCT dp.IdDevolucion) * 100.0 / COUNT(DISTINCT rc.IdRecepcion)), 1)
                            END AS TasaDefectosPorcentaje,
                            CASE 
                                WHEN COUNT(DISTINCT oc.IdOC) = 0 THEN 100
                                ELSE ROUND(COUNT(DISTINCT rc.IdRecepcion) * 100.0 / COUNT(DISTINCT oc.IdOC))
                            END AS PorcentajeCumplimiento,
                            CASE 
                                WHEN COUNT(DISTINCT oc.IdOC) = 0 THEN 'Excelente'
                                WHEN (COUNT(DISTINCT rc.IdRecepcion) * 100.0 / COUNT(DISTINCT oc.IdOC)) >= 90 
                                     AND (CASE WHEN COUNT(DISTINCT rc.IdRecepcion) = 0 THEN 0.0 ELSE (COUNT(DISTINCT dp.IdDevolucion) * 100.0 / COUNT(DISTINCT rc.IdRecepcion)) END) < 5 THEN 'Excelente'
                                WHEN (COUNT(DISTINCT rc.IdRecepcion) * 100.0 / COUNT(DISTINCT oc.IdOC)) >= 70 THEN 'Aceptable'
                                ELSE 'Crítico'
                            END AS Calificacion
                        FROM Laboratorio l
                        LEFT JOIN OrdenCompra oc ON l.IdLaboratorio = oc.IdLaboratorio
                        LEFT JOIN RecepcionCompra rc ON oc.IdOC = rc.IdOC
                        LEFT JOIN DevolucionProveedor dp ON rc.IdRecepcion = dp.IdRecepcion
                        WHERE l.Activo = 1
                        GROUP BY l.IdLaboratorio, l.RazonSocial, l.Marca, l.Pais, l.DiasPago
                    ) t
                    WHERE 1=1";

                if (!string.IsNullOrEmpty(busq))
                    queryReporte += " AND (t.RazonSocial LIKE @Busq OR t.Marca LIKE @Busq)";
                if (!string.IsNullOrEmpty(pais))
                    queryReporte += " AND t.Pais = @Pais";
                if (!string.IsNullOrEmpty(calif))
                    queryReporte += " AND t.Calificacion = @Calif";

                queryReporte += " ORDER BY t.TotalOC DESC, t.RazonSocial ASC";

                using (MySqlCommand cmd = new MySqlCommand(queryReporte, con))
                {
                    if (!string.IsNullOrEmpty(busq))
                        cmd.Parameters.AddWithValue("@Busq", "%" + busq + "%");
                    if (!string.IsNullOrEmpty(pais))
                        cmd.Parameters.AddWithValue("@Pais", pais);
                    if (!string.IsNullOrEmpty(calif))
                        cmd.Parameters.AddWithValue("@Calif", calif);

                    using (MySqlDataAdapter da = new MySqlDataAdapter(cmd))
                    {
                        DataTable dt = new DataTable();
                        da.Fill(dt);
                        return dt;
                    }
                }
            }
        }

        private void CargarTablaReporte()
        {
            gvReporte.DataSource = ConsultarTablaProveedores();
            gvReporte.DataBind();
        }
        // Formato para Lead Time Promedio (BI)

        public string FormatLeadTime(object val, object rec)

        {

            int recepciones = Convert.ToInt32(rec);

            if (recepciones == 0)

            {

                return "<span style='color: #8C827A; font-size: 11px;'>Sin recepciones</span>";

            }

            double dias = Convert.ToDouble(val);

            return $"<strong>{dias:F1}</strong> <span style='font-size: 11px; color: #8C827A;'>días</span>";

        }


        // Formato para Tasa de Defectos (BI)

        public string FormatTasaDefectos(object val, object dev, object rec)

        {

            int recepciones = Convert.ToInt32(rec);

            if (recepciones == 0)

            {

                return "<span style='color: #8C827A; font-size: 11px;'>N/A (0 rec.)</span>";

            }

            double tasa = Convert.ToDouble(val);

            int totalDev = Convert.ToInt32(dev);


            if (tasa == 0.0)

            {

                return "<span class='badge-excelente' style='font-size: 11px;'>0.0% (0 def.)</span>";

            }

            else if (tasa <= 5.0)

            {

                return $"<span class='badge-aceptable' style='font-size: 11px;'>{tasa:F1}% ({totalDev} def.)</span>";

            }

            else

            {

                return $"<span class='badge-critico' style='font-size: 11px;'>{tasa:F1}% ({totalDev} def.)</span>";

            }

        }


        // Método auxiliar para pintar los badges de calificación

        public string GetClaseCalificacion(string calificacion)

        {

            switch (calificacion)

            {

                case "Excelente":

                    return "badge-excelente";

                case "Aceptable":

                    return "badge-aceptable";

                default:

                    return "badge-critico";

            }

        }


        protected void btnFiltrar_Click(object sender, EventArgs e)
        {
            CargarTablaReporte();
        }
        protected void btnLimpiar_Click(object sender, EventArgs e)
        {
            txtBuscar.Text = "";
            ddlFiltroPais.SelectedIndex = 0;
            ddlFiltroCalificacion.SelectedIndex = 0;
            CargarTablaReporte();
        }
        protected void btnExportarExcel_Click(object sender, EventArgs e)
        {
            DataTable dt = ConsultarTablaProveedores();
            StringBuilder sb = new StringBuilder();
            sb.AppendLine("Laboratorio;Marca;País;Plazo Crédito (días);Órdenes;Recepciones;Devoluciones;Lead Time Promedio (días);Tasa Defectos (%);Cumplimiento (%);Calificación");

            foreach (DataRow dr in dt.Rows)
            {
                sb.AppendLine(string.Format("\"{0}\";\"{1}\";\"{2}\";{3};{4};{5};{6};{7:F1};{8:F1};{9};{10}",
                    dr["RazonSocial"],
                    dr["Marca"],
                    dr["Pais"],
                    dr["DiasPago"],
                    dr["TotalOC"],
                    dr["TotalRecepciones"],
                    dr["TotalDevoluciones"],
                    Convert.ToDouble(dr["LeadTimePromedioDias"]),
                    Convert.ToDouble(dr["TasaDefectosPorcentaje"]),
                    dr["PorcentajeCumplimiento"],
                    dr["Calificacion"]
                ));
            }
            Response.Clear();
            Response.Buffer = true;
            Response.AddHeader("content-disposition", "attachment;filename=Reporte_Evaluacion_Proveedores_BI.csv");
            Response.Charset = "utf-8";
            Response.ContentType = "text/csv";
            Response.ContentEncoding = Encoding.UTF8;
            Response.BinaryWrite(Encoding.UTF8.GetPreamble());
            Response.Output.Write(sb.ToString());
            Response.Flush();
            Response.End();
        }
        protected void btnVolver_Click(object sender, EventArgs e)
        {
            Response.Redirect("Laboratorios.aspx");
        }

        protected void btnLogout_Click(object sender, EventArgs e)
        {
            Session.Clear();
            Session.Abandon();
            Response.Redirect("Login.aspx");
        }
    }
}