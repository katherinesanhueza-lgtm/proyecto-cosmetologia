using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace trabajo_ing_software
{
    public partial class Accesos : System.Web.UI.Page
    {
        string connectionString = @"Data Source=(localdb)\MSSQLLocalDB;Initial Catalog=ingsofDB;Integrated Security=True;TrustServerCertificate=True;";

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                CargarUsuarios();
                CargarPerfiles();
                CargarTablaAccesos();
            }
        }

        private void CargarUsuarios()
        {
            using (SqlConnection con = new SqlConnection(connectionString))
            {
                string query = "SELECT IdUsuario, Nombre FROM Usuario WHERE Activo = 1";
                using (SqlCommand cmd = new SqlCommand(query, con))
                {
                    using (SqlDataAdapter sda = new SqlDataAdapter(cmd))
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
            using (SqlConnection con = new SqlConnection(connectionString))
            {
                string query = "SELECT IdRol, Nombre FROM Rol";
                using (SqlCommand cmd = new SqlCommand(query, con))
                {
                    using (SqlDataAdapter sda = new SqlDataAdapter(cmd))
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
            using (SqlConnection con = new SqlConnection(connectionString))
            {
                string query = @"SELECT u.Nombre, u.Correo, ISNULL(r.Nombre, 'Sin Asignar') AS Perfil
                                 FROM Usuario u
                                 LEFT JOIN Rol r ON u.IdRol = r.IdRol";
                using (SqlCommand cmd = new SqlCommand(query, con))
                {
                    using (SqlDataAdapter sda = new SqlDataAdapter(cmd))
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
            if (ddlUsuarios.Items.Count == 0 || ddlPerfiles.Items.Count == 0)
            {
                lblMensaje.Text = "Faltan usuarios o perfiles en la base de datos.";
                lblMensaje.ForeColor = System.Drawing.Color.Red;
                return;
            }

            using (SqlConnection con = new SqlConnection(connectionString))
            {
                string query = "UPDATE Usuario SET IdRol = @IdRol, Rol = @NombreRol WHERE IdUsuario = @IdUsuario";
                using (SqlCommand cmd = new SqlCommand(query, con))
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
