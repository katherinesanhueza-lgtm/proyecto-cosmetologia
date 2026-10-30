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

            if (!ValidarEmail(correo))
            {
                lblMensaje.Text = "El formato del correo electrónico no es válido.";
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
                                string rol = reader["Rol"] != null ? reader["Rol"].ToString() : "";
                                Session["IdUsuario"] = reader["IdUsuario"].ToString();
                                Session["NombreUsuario"] = reader["Nombre"].ToString();
                                Session["RolUsuario"] = rol;

                                // Redireccionamiento segun perfil (RBAC)
                                if (rol.Equals("Administrador", StringComparison.OrdinalIgnoreCase))
                                {
                                    Response.Redirect("Usuarios.aspx");
                                }
                                else if (rol.Equals("Bodeguero", StringComparison.OrdinalIgnoreCase))
                                {
                                    Response.Redirect("Recepciones.aspx");
                                }
                                else if (rol.Equals("Comprador", StringComparison.OrdinalIgnoreCase))
                                {
                                    Response.Redirect("OrdenesCompra.aspx");
                                }
                                else if (rol.Equals("Contador", StringComparison.OrdinalIgnoreCase))
                                {
                                    Response.Redirect("ReporteOrdenesCompra.aspx");
                                }
                                else
                                {
                                    Response.Redirect("Default.aspx");
                                }
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

        private bool ValidarEmail(string email)
        {
            if (string.IsNullOrWhiteSpace(email)) return false;
            string patron = @"^[^@\s]+@[^@\s]+\.[a-zA-Z]{2,}$";
            return System.Text.RegularExpressions.Regex.IsMatch(email.Trim(), patron);
        }
    }
}