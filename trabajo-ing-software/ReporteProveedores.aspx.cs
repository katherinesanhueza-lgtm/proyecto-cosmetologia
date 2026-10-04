using System;
using System.Configuration;
using System.Data;
using MySql.Data.MySqlClient; // Librería de MySQL
using System.Web.UI.WebControls;

namespace trabajo_ing_software
{
    public partial class ReporteProveedores : System.Web.UI.Page
    {
        // Traemos la cadena de conexión desde el Web.config
        string connectionString = ConfigurationManager.ConnectionStrings["DefaultConnection"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["IdUsuario"] == null)
            {
                Response.Redirect("Login.aspx");
                return;
            }

            if (!IsPostBack)
            {
                CargarMetricasGenerales();
                CargarTablaReporte();
            }
        }

        // 1. Cargar las tarjetas superiores (KPIs)
        private void CargarMetricasGenerales()
        {
            using (MySqlConnection con = new MySqlConnection(connectionString))
            {
                // En MySQL se usa IFNULL en lugar de ISNULL
                string queryKPIs = @"
                    SELECT 
                        (SELECT COUNT(*) FROM Laboratorio WHERE Activo = 1) AS TotalLabs,
                        (SELECT COUNT(*) FROM OrdenCompra) AS TotalOC,
                        (SELECT IFNULL(AVG(DiasPago), 0) FROM Laboratorio WHERE Activo = 1) AS PromedioDias";

                using (MySqlCommand cmd = new MySqlCommand(queryKPIs, con))
                {
                    con.Open();
                    using (MySqlDataReader reader = cmd.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            lblTotalLaboratorios.Text = reader["TotalLabs"].ToString();
                            lblTotalOC.Text = reader["TotalOC"].ToString();
                            lblPromedioDias.Text = Convert.ToInt32(reader["PromedioDias"]).ToString();
                        }
                    }
                }
            }
        }

        // 2. Cargar la tabla analítica que relaciona Laboratorios, Órdenes y Cumplimiento
        private void CargarTablaReporte()
        {
            using (MySqlConnection con = new MySqlConnection(connectionString))
            {
                // Consulta analítica ajustada para MySQL (IFNULL y CAST AS SIGNED)
                string queryReporte = @"
                    SELECT 
                        l.IdLaboratorio,
                        l.RazonSocial,
                        l.Marca,
                        IFNULL(l.Pais, 'N/A') AS Pais,
                        l.DiasPago,
                        COUNT(DISTINCT oc.IdOC) AS TotalOC,
                        COUNT(DISTINCT rc.IdRecepcion) AS TotalRecepciones,
                        CASE 
                            WHEN COUNT(DISTINCT oc.IdOC) = 0 THEN 100
                            ELSE CAST((COUNT(DISTINCT rc.IdRecepcion) * 100.0 / COUNT(DISTINCT oc.IdOC)) AS SIGNED)
                        END AS PorcentajeCumplimiento,
                        CASE 
                            WHEN COUNT(DISTINCT oc.IdOC) = 0 THEN 'Excelente'
                            WHEN (COUNT(DISTINCT rc.IdRecepcion) * 100.0 / COUNT(DISTINCT oc.IdOC)) >= 90 THEN 'Excelente'
                            WHEN (COUNT(DISTINCT rc.IdRecepcion) * 100.0 / COUNT(DISTINCT oc.IdOC)) >= 70 THEN 'Aceptable'
                            ELSE 'Crítico'
                        END AS Calificacion
                    FROM Laboratorio l
                    LEFT JOIN OrdenCompra oc ON l.IdLaboratorio = oc.IdLaboratorio
                    LEFT JOIN RecepcionCompra rc ON oc.IdOC = rc.IdOC
                    WHERE l.Activo = 1
                    GROUP BY l.IdLaboratorio, l.RazonSocial, l.Marca, l.Pais, l.DiasPago
                    ORDER BY TotalOC DESC, l.RazonSocial ASC";

                using (MySqlCommand cmd = new MySqlCommand(queryReporte, con))
                {
                    using (MySqlDataAdapter da = new MySqlDataAdapter(cmd))
                    {
                        DataTable dt = new DataTable();
                        da.Fill(dt);
                        gvReporte.DataSource = dt;
                        gvReporte.DataBind();
                    }
                }
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