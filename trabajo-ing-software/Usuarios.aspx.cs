using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI.WebControls;

namespace trabajo_ing_software
{
    public partial class Usuarios : System.Web.UI.Page
    {
        string connectionString = @"Data Source=(localdb)\MSSQLLocalDB;Initial Catalog=ingsofDB;Integrated Security=True;TrustServerCertificate=True;";

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["IdUsuario"] == null)
            {
                Response.Redirect("Login.aspx");
                return;
            }

            if (!IsPostBack)
            {
                lblBienvenida.Text = "👤 " + Session["NombreUsuario"].ToString();
                CargarUsuarios();
            }
        }

        private void CargarUsuarios()
        {
            string query = "SELECT IdUsuario, Nombre, Correo, Rol, Activo FROM Usuario ORDER BY IdUsuario DESC";

            using (SqlConnection con = new SqlConnection(connectionString))
            {
                using (SqlCommand cmd = new SqlCommand(query, con))
                {
                    using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                    {
                        DataTable dt = new DataTable();
                        da.Fill(dt);
                        gvUsuarios.DataSource = dt;
                        gvUsuarios.DataBind();
                    }
                }
            }
        }

        // GUARDAR O ACTUALIZAR
        protected void btnGuardar_Click(object sender, EventArgs e)
        {
            string nombre = txtNombre.Text.Trim();
            string correo = txtCorreo.Text.Trim();
            string password = txtPassword.Text.Trim();
            string rol = ddlRol.SelectedValue;

            if (string.IsNullOrEmpty(nombre) || string.IsNullOrEmpty(correo) || string.IsNullOrEmpty(rol))
            {
                lblMensaje.Text = "Nombre, correo y rol son obligatorios.";
                lblMensaje.ForeColor = System.Drawing.Color.Red;
                return;
            }

            // ¿Estamos creando o editando?
            bool esEdicion = !string.IsNullOrEmpty(hfIdUsuario.Value);

            using (SqlConnection con = new SqlConnection(connectionString))
            {
                string query = "";

                if (!esEdicion)
                {
                    // CREATE: Crear nuevo usuario
                    if (string.IsNullOrEmpty(password))
                    {
                        lblMensaje.Text = "La contraseña es obligatoria para nuevos usuarios.";
                        lblMensaje.ForeColor = System.Drawing.Color.Red;
                        return;
                    }
                    query = "INSERT INTO Usuario (Nombre, Correo, Password, Rol, Activo) VALUES (@Nombre, @Correo, @Password, @Rol, 1)";
                }
                else
                {
                    // UPDATE: Modificar usuario existente
                    if (string.IsNullOrEmpty(password))
                    {
                        // Si dejó la clave vacía, no cambiamos la clave actual
                        query = "UPDATE Usuario SET Nombre=@Nombre, Correo=@Correo, Rol=@Rol WHERE IdUsuario=@IdUsuario";
                    }
                    else
                    {
                        // Si escribió clave nueva, la actualizamos
                        query = "UPDATE Usuario SET Nombre=@Nombre, Correo=@Correo, Password=@Password, Rol=@Rol WHERE IdUsuario=@IdUsuario";
                    }
                }

                using (SqlCommand cmd = new SqlCommand(query, con))
                {
                    cmd.Parameters.AddWithValue("@Nombre", nombre);
                    cmd.Parameters.AddWithValue("@Correo", correo);
                    cmd.Parameters.AddWithValue("@Rol", rol);

                    if (!string.IsNullOrEmpty(password))
                    {
                        cmd.Parameters.AddWithValue("@Password", password);
                    }

                    if (esEdicion)
                    {
                        cmd.Parameters.AddWithValue("@IdUsuario", Convert.ToInt32(hfIdUsuario.Value));
                    }

                    try
                    {
                        con.Open();
                        cmd.ExecuteNonQuery();

                        lblMensaje.Text = esEdicion ? "Usuario modificado con éxito." : "Usuario creado con éxito.";
                        lblMensaje.ForeColor = System.Drawing.Color.Green;

                        LimpiarFormulario();
                        CargarUsuarios();
                    }
                    catch (SqlException ex)
                    {
                        lblMensaje.Text = (ex.Number == 2627) ? "Ya existe un usuario con ese correo." : "❌ Error: " + ex.Message;
                        lblMensaje.ForeColor = System.Drawing.Color.Red;
                    }
                }
            }
        }

        // ACCIONES DE LA TABLA (Editar, CambiarEstado, Eliminar)
        protected void gvUsuarios_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            int idUsuario = 0;

            if (e.CommandName == "Editar")
            {
                idUsuario = Convert.ToInt32(e.CommandArgument);
                CargarDatosParaEditar(idUsuario);
            }
            else if (e.CommandName == "CambiarEstado")
            {
                string[] args = e.CommandArgument.ToString().Split(';');
                idUsuario = Convert.ToInt32(args[0]);
                bool estadoActual = Convert.ToBoolean(args[1]);
                CambiarEstadoUsuario(idUsuario, !estadoActual);
            }
            else if (e.CommandName == "Eliminar")
            {
                idUsuario = Convert.ToInt32(e.CommandArgument);
                EliminarUsuario(idUsuario);
            }
        }

        private void CargarDatosParaEditar(int idUsuario)
        {
            string query = "SELECT IdUsuario, Nombre, Correo, Rol FROM Usuario WHERE IdUsuario = @Id";

            using (SqlConnection con = new SqlConnection(connectionString))
            {
                using (SqlCommand cmd = new SqlCommand(query, con))
                {
                    cmd.Parameters.AddWithValue("@Id", idUsuario);
                    con.Open();
                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            hfIdUsuario.Value = reader["IdUsuario"].ToString();
                            txtNombre.Text = reader["Nombre"].ToString();
                            txtCorreo.Text = reader["Correo"].ToString();
                            ddlRol.SelectedValue = reader["Rol"].ToString();
                            txtPassword.Text = ""; // Por seguridad se deja en blanco

                            // Cambiar textos a modo edición
                            lblTituloForm.InnerText = "✏️ Modificar Usuario (ID: " + hfIdUsuario.Value + ")";
                            btnGuardar.Text = "Guardar Cambios";
                            btnCancelar.Visible = true;
                            lblMensaje.Text = "";
                        }
                    }
                }
            }
        }

        private void CambiarEstadoUsuario(int idUsuario, bool nuevoEstado)
        {
            string query = "UPDATE Usuario SET Activo = @NuevoEstado WHERE IdUsuario = @IdUsuario";
            using (SqlConnection con = new SqlConnection(connectionString))
            {
                using (SqlCommand cmd = new SqlCommand(query, con))
                {
                    cmd.Parameters.AddWithValue("@NuevoEstado", nuevoEstado);
                    cmd.Parameters.AddWithValue("@IdUsuario", idUsuario);
                    con.Open();
                    cmd.ExecuteNonQuery();
                    CargarUsuarios();
                }
            }
        }

        private void EliminarUsuario(int idUsuario)
        {
            // Seguridad: no dejar que el usuario se elimine a sí mismo
            if (Session["IdUsuario"].ToString() == idUsuario.ToString())
            {
                lblMensaje.Text = "No puedes eliminar tu propio usuario mientras tienes la sesión activa.";
                lblMensaje.ForeColor = System.Drawing.Color.Red;
                return;
            }

            string query = "DELETE FROM Usuario WHERE IdUsuario = @IdUsuario";

            using (SqlConnection con = new SqlConnection(connectionString))
            {
                using (SqlCommand cmd = new SqlCommand(query, con))
                {
                    cmd.Parameters.AddWithValue("@IdUsuario", idUsuario);
                    try
                    {
                        con.Open();
                        cmd.ExecuteNonQuery();

                        lblMensaje.Text = "Usuario eliminado con éxito.";
                        lblMensaje.ForeColor = System.Drawing.Color.Green;
                        CargarUsuarios();
                    }
                    catch (SqlException)
                    {
                        lblMensaje.Text = "No se puede eliminar este usuario porque ya tiene registros o compras asociadas. En su lugar, usa el botón 'Desactivar'.";
                        lblMensaje.ForeColor = System.Drawing.Color.Red;
                    }
                }
            }
        }

        protected void btnCancelar_Click(object sender, EventArgs e)
        {
            LimpiarFormulario();
        }

        private void LimpiarFormulario()
        {
            hfIdUsuario.Value = "";
            txtNombre.Text = "";
            txtCorreo.Text = "";
            txtPassword.Text = "";
            ddlRol.SelectedIndex = 0;
            lblTituloForm.InnerText = "Registrar Nuevo Usuario";
            btnGuardar.Text = "Guardar Usuario +";
            btnCancelar.Visible = false;
        }

        protected void btnIrLaboratorios_Click(object sender, EventArgs e)
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