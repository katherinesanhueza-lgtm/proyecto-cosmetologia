using MySql.Data.MySqlClient;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace trabajo_ing_software
{
    public partial class Perfiles : System.Web.UI.Page
    {
        string connectionString = ConfigurationManager.ConnectionStrings["DefaultConnection"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                CargarPerfiles();
            }
        }

        private void CargarPerfiles()
        {
            using (MySqlConnection conn = new MySqlConnection(connectionString))
            {
                string query = "SELECT IdRol, Nombre FROM Rol";
                using (MySqlCommand cmd = new MySqlCommand(query, conn))
                {
                    using (MySqlDataAdapter sda = new MySqlDataAdapter(cmd))
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

            using (MySqlConnection conn = new MySqlConnection(connectionString))
            {
                string query = "INSERT INTO Rol (Nombre) VALUES (@Nombre)";
                using (MySqlCommand cmd = new MySqlCommand(query, conn))
                {
                    cmd.Parameters.AddWithValue("@Nombre", txtNombrePerfil.Text.Trim());

                    conn.Open();
                    cmd.ExecuteNonQuery();
                    conn.Close();
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

            using (MySqlConnection conn = new MySqlConnection(connectionString))
            {
                string query = "DELETE FROM Rol WHERE IdRol = @IdRol";
                using (MySqlCommand cmd = new MySqlCommand(query, conn))
                {
                    cmd.Parameters.AddWithValue("@IdRol", idRol);
                    conn.Open();
                    cmd.ExecuteNonQuery();
                    conn.Close();
                }
            }

            lblMensaje.Text = "Perfil eliminado correctamente.";
            lblMensaje.ForeColor = System.Drawing.Color.Blue;
            CargarPerfiles();
        }
    }
}