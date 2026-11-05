using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace trabajo_ing_software
{
    public partial class Perfiles : System.Web.UI.Page
    {
        string connectionString = @"Data Source=(localdb)\MSSQLLocalDB;Initial Catalog=ingsofDB;Integrated Security=True;TrustServerCertificate=True;";

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                CargarPerfiles();
            }
        }

        private void CargarPerfiles()
        {
            using (SqlConnection conn = new SqlConnection(connectionString))
            {
                string query = "SELECT IdRol, Nombre FROM Rol";
                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    using (SqlDataAdapter sda = new SqlDataAdapter(cmd))
                    {
                        DataTable dt = new DataTable();
                        sda.Fill(dt);
                        gvPerfiles.DataSource = dt;
                        gvPerfiles.DataBind();
                    }
                }
            }
        }

        protected void btnGuardar_Click(object sender, EventArgs e)
        {
            if (string.IsNullOrWhiteSpace(txtNombrePerfil.Text))
            {
                lblMensaje.Text = "El nombre del perfil es obligatorio.";
                lblMensaje.ForeColor = System.Drawing.Color.Red;
                return;
            }

            using (SqlConnection conn = new SqlConnection(connectionString))
            {
                string query = "INSERT INTO Rol (Nombre) VALUES (@Nombre)";
                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    cmd.Parameters.AddWithValue("@Nombre", txtNombrePerfil.Text.Trim());

                    conn.Open();
                    cmd.ExecuteNonQuery();
                }
            }

            lblMensaje.Text = "Perfil guardado con éxito.";
            lblMensaje.ForeColor = System.Drawing.Color.Green;

            txtNombrePerfil.Text = "";
            CargarPerfiles();
        }

        protected void gvPerfiles_RowDeleting(object sender, GridViewDeleteEventArgs e)
        {
            int idRol = Convert.ToInt32(gvPerfiles.DataKeys[e.RowIndex].Value);

            using (SqlConnection conn = new SqlConnection(connectionString))
            {
                string query = "DELETE FROM Rol WHERE IdRol = @IdRol";
                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    cmd.Parameters.AddWithValue("@IdRol", idRol);
                    try
                    {
                        conn.Open();
                        cmd.ExecuteNonQuery();
                        lblMensaje.Text = "Perfil eliminado correctamente.";
                        lblMensaje.ForeColor = System.Drawing.Color.Blue;
                    }
                    catch (SqlException)
                    {
                        lblMensaje.Text = "No se puede eliminar este perfil porque está asignado a uno o más usuarios.";
                        lblMensaje.ForeColor = System.Drawing.Color.Red;
                    }
                }
            }

            CargarPerfiles();
        }
    }
}
