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
    public partial class Accesos : System.Web.UI.Page
    {
        string connectionString = ConfigurationManager.ConnectionStrings["DefaultConnection"].ConnectionString;

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
                        ddlUsuarios.DataTextField = "Nombre";    // Lo que ve el usuario
                        ddlUsuarios.DataValueField = "IdUsuario"; // El ID oculto
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
                // Unimos la tabla Usuario con Rol para ver qué perfil tiene cada uno
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
            if (ddlUsuarios.Items.Count == 0 || ddlPerfiles.Items.Count == 0)
            {
                lblMensaje.Text = "Faltan usuarios o perfiles en la base de datos.";
                lblMensaje.ForeColor = System.Drawing.Color.Red;
                return;
            }

            using (MySqlConnection con = new MySqlConnection(connectionString))
            {
                // Actualizamos el usuario con su nuevo IdRol
                string query = "UPDATE Usuario SET IdRol = @IdRol, Rol = @NombreRol WHERE IdUsuario = @IdUsuario";
                using (MySqlCommand cmd = new MySqlCommand(query, con))
                {
                    cmd.Parameters.AddWithValue("@IdRol", ddlPerfiles.SelectedValue);
                    cmd.Parameters.AddWithValue("@NombreRol", ddlPerfiles.SelectedItem.Text);
                    cmd.Parameters.AddWithValue("@IdUsuario", ddlUsuarios.SelectedValue);

                    con.Open();
                    cmd.ExecuteNonQuery();
                    con.Close();
                }
            }

            lblMensaje.Text = "Acceso actualizado con éxito.";
            lblMensaje.ForeColor = System.Drawing.Color.Green;
            CargarTablaAccesos(); // Recargar la tabla para ver el cambio
        }
    }
}