using System;
using System.Configuration;
using MySql.Data.MySqlClient;

namespace trabajo_ing_software
{
    public partial class Login : System.Web.UI.Page
    {
        string connectionString = ConfigurationManager.ConnectionStrings["DefaultConnection"].ConnectionString;

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
            string query = "SELECT IdUsuario, Nombre, Rol, Password FROM Usuario WHERE Correo = @Correo AND Activo = 1";

            using (MySqlConnection con = ConexionErp.Crear(connectionString))
            {
                using (MySqlCommand cmd = new MySqlCommand(query, con))
                {
                    cmd.Parameters.AddWithValue("@Correo", correo);


                    try
                    {
                        con.Open();
                        using (MySqlDataReader reader = cmd.ExecuteReader())
                        {
                            if (reader.Read() && ClaveUsuario.Verificar(clave, Convert.ToString(reader["Password"])))
                            {
                                // Usuario encontrado: Guardamos los datos en la Sesión
                                string rol = reader["Rol"] != null ? reader["Rol"].ToString() : "";
                                var id = reader["IdUsuario"].ToString();
                                var nombre = reader["Nombre"].ToString();
                                var anterior = Convert.ToString(reader["Password"]);
                                reader.Close();
                                if (!anterior.StartsWith(ClaveUsuario.Prefijo, StringComparison.Ordinal))
                                {
                                    using (var migrar = new MySqlCommand("UPDATE usuario SET Password=@nueva WHERE IdUsuario=@id AND BINARY Password=BINARY @anterior AND Activo=1", con))
                                    {
                                        migrar.Parameters.AddWithValue("@id", id);
                                        migrar.Parameters.AddWithValue("@anterior", anterior);
                                        migrar.Parameters.AddWithValue("@nueva", ClaveUsuario.Crear(clave));
                                        if (migrar.ExecuteNonQuery() != 1) { lblMensaje.Text = "Vuelve a iniciar sesión."; return; }
                                    }
                                }
                                Session["IdUsuario"] = id;
                                Session["NombreUsuario"] = nombre;
                                Session["RolUsuario"] = rol;

                                // Redireccionamiento segun perfil (RBAC)
                                Response.Redirect("Default.aspx", false);
                                Context.ApplicationInstance.CompleteRequest();
                            }
                            else
                            {
                                lblMensaje.Text = "Correo o contraseña incorrectos, o usuario inactivo.";
                            }
                        }
                    }
                    catch (Exception ex)
                    {
                        System.Diagnostics.Trace.TraceError(ex.ToString());
                        lblMensaje.Text = "No se pudo iniciar sesión. Inténtalo de nuevo.";
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