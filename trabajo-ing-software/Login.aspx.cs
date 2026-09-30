using System;
using System.Data.SqlClient;

namespace trabajo_ing_software
{
    public partial class Login : System.Web.UI.Page
    {
        string connectionString = @"Data Source=(localdb)\MSSQLLocalDB;Initial Catalog=ingsofDB;Integrated Security=True;TrustServerCertificate=True;";

        protected void Page_Load(object sender, EventArgs e)
        {
        }

        protected void btnLogin_Click(object sender, EventArgs e)
        {
            string correo = txtCorreo.Text.Trim();
            string clave = txtPassword.Text.Trim();

            // 1. Validaciones básicas de entrada
            if (string.IsNullOrEmpty(correo) || string.IsNullOrEmpty(clave))
            {
                lblMensaje.Text = "Por favor, completa todos los campos.";
                return;
            }

            // 2. Consulta a la tabla Usuario
            string query = "SELECT IdUsuario, Nombre, Rol FROM Usuario WHERE Correo = @Correo AND Password = @Password AND Activo = 1";

            using (SqlConnection con = new SqlConnection(connectionString))
            {
                using (SqlCommand cmd = new SqlCommand(query, con))
                {
                    cmd.Parameters.AddWithValue("@Correo", correo);
                    cmd.Parameters.AddWithValue("@Password", clave);

                    try
                    {
                        con.Open();
                        using (SqlDataReader reader = cmd.ExecuteReader())
                        {
                            if (reader.Read())
                            {
                                // Usuario encontrado: Guardamos los datos en la Sesión
                                Session["IdUsuario"] = reader["IdUsuario"].ToString();
                                Session["NombreUsuario"] = reader["Nombre"].ToString();
                                Session["RolUsuario"] = reader["Rol"].ToString();

                                // Redireccionamiento a la pagina x que quiera
                                Response.Redirect("Usuarios.aspx");
                            }
                            else
                            {
                                lblMensaje.Text = "Correo o contraseña incorrectos, o usuario inactivo.";
                            }
                        }
                    }
                    catch (Exception ex)
                    {
                        lblMensaje.Text = "Error de conexión: " + ex.Message;
                    }
                }
            }
        }
    }
}