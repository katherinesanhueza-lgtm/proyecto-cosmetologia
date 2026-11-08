using System;
using System.Data;
using System.Configuration;
using MySql.Data.MySqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace trabajo_ing_software
{
    public partial class Accesos : System.Web.UI.Page
    {
        string connectionString = ConfigurationManager.ConnectionStrings["DefaultConnection"] != null ? ConfigurationManager.ConnectionStrings["DefaultConnection"].ConnectionString : "Server=localhost;Port=3306;Database=ERP_Dermocosmetica;Uid=root;Pwd=1234;";

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["IdUsuario"] == null)
            {
                Response.Redirect("Login.aspx");
                return;
            }

            // Control de acceso RBAC: Solo Administrador puede gestionar y asignar perfiles
            string rolUsuario = Session["RolUsuario"] != null ? Session["RolUsuario"].ToString() : "";
            if (!rolUsuario.Equals("Administrador", StringComparison.OrdinalIgnoreCase))
            {
                if (rolUsuario.Equals("Bodeguero", StringComparison.OrdinalIgnoreCase))
                {
                    Response.Redirect("Recepciones.aspx");
                }
                else if (rolUsuario.Equals("Comprador", StringComparison.OrdinalIgnoreCase))
                {
                    Response.Redirect("OrdenesCompra.aspx");
                }
                else if (rolUsuario.Equals("Contador", StringComparison.OrdinalIgnoreCase))
                {
                    Response.Redirect("ReporteOrdenesCompra.aspx");
                }
                else
                {
                    Response.Redirect("Default.aspx");
                }
                return;
            }

            if (!IsPostBack)
            {
                CargarUsuarios();
                CargarPerfiles();
                CargarTablaAccesos();
            }
        }

        private void CargarUsuarios()
        {
            using (MySqlConnection con = new MySqlConnection(connectionString))
            {
                string query = "SELECT IdUsuario, Nombre FROM Usuario WHERE Activo = 1";
                using (MySqlCommand cmd = new MySqlCommand(query, con))
                {
                    using (MySqlDataAdapter sda = new MySqlDataAdapter(cmd))
                    {
                        DataTable dt = new DataTable();
                        sda.Fill(dt);
                        ddlUsuarios.DataSource = dt;
                        ddlUsuarios.DataTextField = "Nombre";
                        ddlUsuarios.DataValueField = "IdUsuario";
                        ddlUsuarios.DataBind();
                    }
                }
            }
        }

        private void CargarPerfiles()
        {
            using (MySqlConnection con = new MySqlConnection(connectionString))
            {
                string query = "SELECT IdRol, Nombre FROM Rol";
                using (MySqlCommand cmd = new MySqlCommand(query, con))
                {
                    using (MySqlDataAdapter sda = new MySqlDataAdapter(cmd))
                    {
                        DataTable dt = new DataTable();
                        sda.Fill(dt);
                        ddlPerfiles.DataSource = dt;
                        ddlPerfiles.DataTextField = "Nombre";
                        ddlPerfiles.DataValueField = "IdRol";
                        ddlPerfiles.DataBind();
                    }
                }
            }
        }

        private void CargarTablaAccesos()
        {
            using (MySqlConnection con = new MySqlConnection(connectionString))
            {
                string query = @"SELECT u.Nombre, u.Correo, IFNULL(r.Nombre, 'Sin Asignar') AS Perfil
                                 FROM Usuario u
                                 LEFT JOIN Rol r ON u.IdRol = r.IdRol";
                using (MySqlCommand cmd = new MySqlCommand(query, con))
                {
                    using (MySqlDataAdapter sda = new MySqlDataAdapter(cmd))
                    {
                        DataTable dt = new DataTable();
                        sda.Fill(dt);
                        gvAccesos.DataSource = dt;
                        gvAccesos.DataBind();
                    }
                }
            }
        }

        protected void btnGuardarAcceso_Click(object sender, EventArgs e)
        {
            string rolUsuario = Session["RolUsuario"] != null ? Session["RolUsuario"].ToString() : "";
            if (!rolUsuario.Equals("Administrador", StringComparison.OrdinalIgnoreCase))
            {
                lblMensaje.Text = "Acceso denegado: Solo el Administrador puede asignar perfiles.";
                lblMensaje.ForeColor = System.Drawing.Color.Red;
                return;
            }

            if (ddlUsuarios.Items.Count == 0 || ddlPerfiles.Items.Count == 0)
            {
                lblMensaje.Text = "Faltan usuarios o perfiles en la base de datos.";
                lblMensaje.ForeColor = System.Drawing.Color.Red;
                return;
            }

            using (MySqlConnection con = new MySqlConnection(connectionString))
            {
                string query = "UPDATE Usuario SET IdRol = @IdRol, Rol = @NombreRol WHERE IdUsuario = @IdUsuario";
                using (MySqlCommand cmd = new MySqlCommand(query, con))
                {
                    cmd.Parameters.AddWithValue("@IdRol", ddlPerfiles.SelectedValue);
                    cmd.Parameters.AddWithValue("@NombreRol", ddlPerfiles.SelectedItem.Text);
                    cmd.Parameters.AddWithValue("@IdUsuario", ddlUsuarios.SelectedValue);

                    con.Open();
                    cmd.ExecuteNonQuery();
                }
            }

            lblMensaje.Text = "Acceso actualizado con éxito.";
            lblMensaje.ForeColor = System.Drawing.Color.Green;
            CargarTablaAccesos();
        }
    }
}
