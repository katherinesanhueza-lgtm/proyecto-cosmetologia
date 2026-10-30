using System;
using System.Data;
using System.Data.SqlClient;

namespace trabajo_ing_software
{
    public partial class ReporteProveedores : System.Web.UI.Page
    {
        string connectionString = @"Data Source=(localdb)\MSSQLLocalDB;Initial Catalog=ingsofDB;Integrated Security=True;TrustServerCertificate=True;";

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
                CargarMetricasGenerales();
                CargarTablaReporte();
            }
        }

        // 1. Cargar las tarjetas superiores (KPIs y Ajustes de BI)
        private void CargarMetricasGenerales()
        {
            using (SqlConnection con = new SqlConnection(connectionString))
            {
                con.Open();

                // 1. Total Labs y Total OC
                string queryConteo = @"
                    SELECT 
                        (SELECT COUNT(*) FROM Laboratorio WHERE Activo = 1) AS TotalLabs,
                        (SELECT COUNT(*) FROM OrdenCompra) AS TotalOC,
                        (SELECT ISNULL(AVG(DiasPago), 0) FROM Laboratorio WHERE Activo = 1) AS PromedioDias";

                using (SqlCommand cmd = new SqlCommand(queryConteo, con))
                {
                    using (SqlDataReader reader = cmd.ExecuteReader())
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
                    SELECT ISNULL(AVG(CAST(DATEDIFF(day, oc.Fecha, rc.FechaRecepcion) AS FLOAT)), 0)
                    FROM RecepcionCompra rc
                    INNER JOIN OrdenCompra oc ON rc.IdOC = oc.IdOC";

                using (SqlCommand cmd = new SqlCommand(queryLeadTime, con))
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

                using (SqlCommand cmd = new SqlCommand(queryDefectos, con))
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
                            ELSE CAST((COUNT(DISTINCT rc.IdRecepcion) * 100.0 / COUNT(DISTINCT oc.IdOC)) AS INT)
                        END
                    FROM OrdenCompra oc
                    LEFT JOIN RecepcionCompra rc ON oc.IdOC = rc.IdOC";

                using (SqlCommand cmd = new SqlCommand(queryCumplimiento, con))
                {
                    object res = cmd.ExecuteScalar();
                    int cumplimiento = (res != null && res != DBNull.Value) ? Convert.ToInt32(res) : 100;
                    lblCumplimientoGlobal.Text = cumplimiento.ToString() + "%";
                }
            }
        }

        // 2. Cargar la tabla analítica con métricas de BI por proveedor
        private void CargarTablaReporte()
        {
            using (SqlConnection con = new SqlConnection(connectionString))
            {
                // Consulta analítica completa con BI
                string queryReporte = @"
                    SELECT 
                        l.IdLaboratorio,
                        l.RazonSocial,
                        l.Marca,
                        ISNULL(l.Pais, 'N/A') AS Pais,
                        l.DiasPago,
                        COUNT(DISTINCT oc.IdOC) AS TotalOC,
                        COUNT(DISTINCT rc.IdRecepcion) AS TotalRecepciones,
                        COUNT(DISTINCT dp.IdDevolucion) AS TotalDevoluciones,
                        ISNULL(AVG(CAST(DATEDIFF(day, oc.Fecha, rc.FechaRecepcion) AS FLOAT)), 0) AS LeadTimePromedioDias,
                        CASE 
                            WHEN COUNT(DISTINCT rc.IdRecepcion) = 0 THEN 0.0
                            ELSE ROUND((COUNT(DISTINCT dp.IdDevolucion) * 100.0 / COUNT(DISTINCT rc.IdRecepcion)), 1)
                        END AS TasaDefectosPorcentaje,
                        CASE 
                            WHEN COUNT(DISTINCT oc.IdOC) = 0 THEN 100
                            ELSE CAST((COUNT(DISTINCT rc.IdRecepcion) * 100.0 / COUNT(DISTINCT oc.IdOC)) AS INT)
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
                    ORDER BY TotalOC DESC, l.RazonSocial ASC";

                using (SqlCommand cmd = new SqlCommand(queryReporte, con))
                {
                    using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                    {
                        DataTable dt = new DataTable();
                        da.Fill(dt);
                        gvReporte.DataSource = dt;
                        gvReporte.DataBind();
                    }
                }
            }
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
