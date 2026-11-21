using System;
using System.Configuration;
using System.Data;
using System.Text;
using System.Web.UI;
using System.Web.UI.WebControls;
using MySql.Data.MySqlClient;

namespace trabajo_ing_software
{
    public partial class ReporteFlujoCaja : Page
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

            string rol = Convert.ToString(Session["RolUsuario"]).Trim();
            if (!rol.Equals("Administrador", StringComparison.OrdinalIgnoreCase) &&
                !rol.Equals("Administrador General", StringComparison.OrdinalIgnoreCase) &&
                !rol.Equals("Contador", StringComparison.OrdinalIgnoreCase))
            {
                ConfiguracionGlobal.RedirigirSegunRol(Response, rol);
                return;
            }

            if (!IsPostBack)
            {
                string nombre = Convert.ToString(Session["NombreUsuario"]);
                lblBienvenida.Text = nombre;

                // Inyectar firma oficial NombreContador desde ConfiguracionGlobal
                string nombreContador = ConfiguracionGlobal.NombreContador;
                lblAuditor.Text = string.IsNullOrEmpty(nombre) ? nombreContador : nombre;
                lblFirmaContador.Text = nombreContador;
                lblFirmaCompras.Text = ConfiguracionGlobal.NombreJefeCompras;

                CargarLaboratorios();
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

        private DataTable ConsultarProyeccionSQL()
        {
            string idLab = ddlLaboratorio.SelectedValue;
            string busq = (txtBuscar.Text ?? "").Trim();
            string enfoque = ddlEnfoque.SelectedValue;

            // Lógica BI CASE WHEN agrupando la deuda pendiente en 4 columnas de vencimiento por proveedor
            string query = @"
                SELECT l.IdLaboratorio,
                       l.RazonSocial AS Laboratorio,
                       IFNULL(l.Rut, '') AS Rut,
                       IFNULL(l.DiasPago, 30) AS DiasPago,
                       COUNT(*) AS CuentasPendientes,
                       ROUND(SUM(CASE
                           WHEN DATEDIFF(DATE_ADD(r.FechaRecepcion, INTERVAL COALESCE(l.DiasPago, 30) DAY), CURDATE()) < 0
                           THEN (cp.Monto - COALESCE(p.Pagado, 0)) ELSE 0 END), 0) AS DeudaVencida,
                       ROUND(SUM(CASE
                           WHEN DATEDIFF(DATE_ADD(r.FechaRecepcion, INTERVAL COALESCE(l.DiasPago, 30) DAY), CURDATE()) BETWEEN 0 AND 30
                           THEN (cp.Monto - COALESCE(p.Pagado, 0)) ELSE 0 END), 0) AS Pagar30Dias,
                       ROUND(SUM(CASE
                           WHEN DATEDIFF(DATE_ADD(r.FechaRecepcion, INTERVAL COALESCE(l.DiasPago, 30) DAY), CURDATE()) BETWEEN 31 AND 60
                           THEN (cp.Monto - COALESCE(p.Pagado, 0)) ELSE 0 END), 0) AS Pagar60Dias,
                       ROUND(SUM(CASE
                           WHEN DATEDIFF(DATE_ADD(r.FechaRecepcion, INTERVAL COALESCE(l.DiasPago, 30) DAY), CURDATE()) > 60
                           THEN (cp.Monto - COALESCE(p.Pagado, 0)) ELSE 0 END), 0) AS Pagar90MasDias,
                       ROUND(SUM(cp.Monto - COALESCE(p.Pagado, 0)), 0) AS TotalPendiente
                FROM cuentaporpagar cp
                INNER JOIN recepcioncompra r ON r.IdRecepcion = cp.IdRecepcion
                INNER JOIN laboratorio l ON l.IdLaboratorio = cp.IdLaboratorio
                LEFT JOIN (
                    SELECT IdCuentaPagar, SUM(Monto) AS Pagado
                    FROM pagoproveedor
                    GROUP BY IdCuentaPagar
                ) p ON p.IdCuentaPagar = cp.IdCuentaPagar
                WHERE (cp.Monto - COALESCE(p.Pagado, 0)) > 0";

            if (!string.IsNullOrEmpty(idLab))
                query += " AND l.IdLaboratorio = @IdLab";

            if (!string.IsNullOrEmpty(busq))
                query += " AND (l.RazonSocial LIKE @Busq OR l.Rut LIKE @Busq)";

            query += " GROUP BY l.IdLaboratorio, l.RazonSocial, IFNULL(l.Rut, ''), IFNULL(l.DiasPago, 30)";

            if (enfoque == "VENCIDA")
                query += " HAVING DeudaVencida > 0";
            else if (enfoque == "30DIAS")
                query += " HAVING Pagar30Dias > 0";
            else if (enfoque == "60DIAS")
                query += " HAVING Pagar60Dias > 0";
            else if (enfoque == "90MAS")
                query += " HAVING Pagar90MasDias > 0";

            query += " ORDER BY DeudaVencida DESC, Pagar30Dias DESC, TotalPendiente DESC";

            using (MySqlConnection con = new MySqlConnection(connectionString))
            using (MySqlCommand cmd = new MySqlCommand(query, con))
            {
                if (!string.IsNullOrEmpty(idLab))
                    cmd.Parameters.AddWithValue("@IdLab", idLab);
                if (!string.IsNullOrEmpty(busq))
                    cmd.Parameters.AddWithValue("@Busq", "%" + busq + "%");

                using (MySqlDataAdapter da = new MySqlDataAdapter(cmd))
                {
                    DataTable dt = new DataTable();
                    da.Fill(dt);
                    return dt;
                }
            }
        }

        private void CargarReporte()
        {
            DataTable dt = ConsultarProyeccionSQL();
            gvFlujo.DataSource = dt;
            gvFlujo.DataBind();

            decimal vencida = 0m, d30 = 0m, d60 = 0m, d90 = 0m, total = 0m;
            foreach (DataRow dr in dt.Rows)
            {
                vencida += Convert.ToDecimal(dr["DeudaVencida"]);
                d30 += Convert.ToDecimal(dr["Pagar30Dias"]);
                d60 += Convert.ToDecimal(dr["Pagar60Dias"]);
                d90 += Convert.ToDecimal(dr["Pagar90MasDias"]);
                total += Convert.ToDecimal(dr["TotalPendiente"]);
            }

            lblKpiVencida.Text = string.Format("{0:C0}", vencida);
            lblKpi30Dias.Text = string.Format("{0:C0}", d30);
            lblKpi60Dias.Text = string.Format("{0:C0}", d60);
            lblKpi90Mas.Text = string.Format("{0:C0}", d90);
            lblResumenTotal.Text = string.Format("{0:C0}", total);
        }

        protected void btnFiltrar_Click(object sender, EventArgs e)
        {
            CargarReporte();
        }

        protected void btnLimpiar_Click(object sender, EventArgs e)
        {
            ddlLaboratorio.SelectedIndex = 0;
            txtBuscar.Text = "";
            ddlEnfoque.SelectedIndex = 0;
            CargarReporte();
        }

        protected void btnExportarExcel_Click(object sender, EventArgs e)
        {
            DataTable dt = ConsultarProyeccionSQL();

            StringBuilder sb = new StringBuilder();
            sb.AppendLine("Laboratorio;RUT;Plazo Pago (días);Documentos;Deuda Vencida ($);A Pagar 30 Días ($);A Pagar 60 Días ($);90+ Días ($);Total Pendiente ($)");

            foreach (DataRow dr in dt.Rows)
            {
                sb.AppendLine(string.Format("\"{0}\";{1};{2};{3};{4};{5};{6};{7};{8}",
                    dr["Laboratorio"],
                    dr["Rut"],
                    dr["DiasPago"],
                    dr["CuentasPendientes"],
                    dr["DeudaVencida"],
                    dr["Pagar30Dias"],
                    dr["Pagar60Dias"],
                    dr["Pagar90MasDias"],
                    dr["TotalPendiente"]
                ));
            }

            Response.Clear();
            Response.Buffer = true;
            Response.AddHeader("content-disposition", "attachment;filename=Reporte_Flujo_Caja_Laboratorios.csv");
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
