using MySql.Data.MySqlClient;
using System;
using System.Configuration;
using System.Data;
using System.Web.UI.WebControls;

namespace trabajo_ing_software
{
    public partial class Clientes : PaginaVentas
    {
        private string connectionString = ConfigurationManager.ConnectionStrings["DefaultConnection"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                lblBienvenida.Text = Convert.ToString(Session["NombreUsuario"]) ?? "Vendedor";
                CargarClientes();
            }
        }

        protected void ddlFiltroEstado_SelectedIndexChanged(object sender, EventArgs e)
        {
            CargarClientes();
        }

        private void CargarClientes()
        {
            string filtro = "";
            if (ddlFiltroEstado.SelectedValue == "Activos")
                filtro = "WHERE COALESCE(Activo, 1) = 1";
            else if (ddlFiltroEstado.SelectedValue == "Inactivos")
                filtro = "WHERE COALESCE(Activo, 1) = 0";

            string query = $@"SELECT IdCliente, Rut, Nombre, 
                                     COALESCE(RazonSocial, Nombre) AS RazonSocial,
                                     COALESCE(Categoria, 'General') AS Categoria,
                                     COALESCE(Giro, 'Sin Giro') AS Giro,
                                     COALESCE(Direccion, '') AS Direccion,
                                     COALESCE(Contacto, 'Sin Contacto') AS Contacto,
                                     COALESCE(Correo, '') AS Correo,
                                     COALESCE(Telefono, '') AS Telefono,
                                     COALESCE(LimiteCredito, 0) AS LimiteCredito,
                                     COALESCE(DiasCredito, 0) AS DiasCredito,
                                     COALESCE(Activo, 1) AS Activo
                              FROM cliente
                              {filtro}
                              ORDER BY IdCliente DESC";

            try
            {
                using (MySqlConnection con = new MySqlConnection(connectionString))
                {
                    con.Open();
                    VentaInventario.AsegurarEsquema(con);

                    using (MySqlCommand cmd = new MySqlCommand(query, con))
                    using (MySqlDataAdapter da = new MySqlDataAdapter(cmd))
                    {
                        DataTable dt = new DataTable();
                        da.Fill(dt);
                        gvClientes.DataSource = dt;
                        gvClientes.DataBind();
                    }
                }
            }
            catch (Exception ex)
            {
                lblMensaje.Text = "Error al consultar clientes: " + ex.Message;
                lblMensaje.ForeColor = System.Drawing.Color.Red;
            }
        }

        protected void btnGuardar_Click(object sender, EventArgs e)
        {
            string rut = txtRut.Text.Trim();
            string nombre = txtNombre.Text.Trim();
            string categoria = ddlCategoria.SelectedValue;
            string giro = txtGiro.Text.Trim();
            string direccion = txtDireccion.Text.Trim();
            string contacto = txtContacto.Text.Trim();
            string correo = txtCorreo.Text.Trim();
            string telefono = txtTelefono.Text.Trim();

            decimal.TryParse(txtLimiteCredito.Text.Trim(), out decimal limiteCredito);
            int.TryParse(txtDiasCredito.Text.Trim(), out int diasCredito);

            if (string.IsNullOrEmpty(rut) || string.IsNullOrEmpty(nombre))
            {
                lblMensaje.Text = "El RUT y la Razón Social / Nombre son obligatorios.";
                lblMensaje.ForeColor = System.Drawing.Color.Red;
                return;
            }

            bool esEdicion = !string.IsNullOrEmpty(hfIdCliente.Value);

            using (MySqlConnection con = new MySqlConnection(connectionString))
            {
                string query;
                if (!esEdicion)
                {
                    query = @"INSERT INTO cliente 
                              (Rut, Nombre, RazonSocial, Categoria, Giro, Direccion, Contacto, Correo, Telefono, LimiteCredito, DiasCredito, Activo) 
                              VALUES 
                              (@Rut, @Nombre, @RazonSocial, @Categoria, @Giro, @Direccion, @Contacto, @Correo, @Telefono, @LimiteCredito, @DiasCredito, 1)";
                }
                else
                {
                    query = @"UPDATE cliente 
                              SET Rut = @Rut, Nombre = @Nombre, RazonSocial = @RazonSocial, Categoria = @Categoria, 
                                  Giro = @Giro, Direccion = @Direccion, Contacto = @Contacto, Correo = @Correo, 
                                  Telefono = @Telefono, LimiteCredito = @LimiteCredito, DiasCredito = @DiasCredito
                              WHERE IdCliente = @IdCliente";
                }

                using (MySqlCommand cmd = new MySqlCommand(query, con))
                {
                    cmd.Parameters.AddWithValue("@Rut", rut);
                    cmd.Parameters.AddWithValue("@Nombre", nombre);
                    cmd.Parameters.AddWithValue("@RazonSocial", nombre);
                    cmd.Parameters.AddWithValue("@Categoria", categoria);
                    cmd.Parameters.AddWithValue("@Giro", giro);
                    cmd.Parameters.AddWithValue("@Direccion", direccion);
                    cmd.Parameters.AddWithValue("@Contacto", contacto);
                    cmd.Parameters.AddWithValue("@Correo", correo);
                    cmd.Parameters.AddWithValue("@Telefono", telefono);
                    cmd.Parameters.AddWithValue("@LimiteCredito", limiteCredito);
                    cmd.Parameters.AddWithValue("@DiasCredito", diasCredito);

                    if (esEdicion)
                        cmd.Parameters.AddWithValue("@IdCliente", Convert.ToInt32(hfIdCliente.Value));

                    try
                    {
                        con.Open();
                        cmd.ExecuteNonQuery();
                        lblMensaje.Text = esEdicion ? "Cliente modificado con éxito." : "Cliente registrado con éxito.";
                        lblMensaje.ForeColor = System.Drawing.Color.Green;
                        LimpiarFormulario();
                        CargarClientes();
                    }
                    catch (MySqlException ex)
                    {
                        lblMensaje.Text = "Error al guardar cliente: " + ex.Message;
                        lblMensaje.ForeColor = System.Drawing.Color.Red;
                    }
                }
            }
        }

        protected void gvClientes_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            if (e.CommandName == "Editar")
            {
                int idCliente = Convert.ToInt32(e.CommandArgument);
                CargarDatosParaEditar(idCliente);
            }
            else if (e.CommandName == "Desactivar")
            {
                int idCliente = Convert.ToInt32(e.CommandArgument);
                CambiarEstadoCliente(idCliente, 0);
            }
            else if (e.CommandName == "Activar")
            {
                int idCliente = Convert.ToInt32(e.CommandArgument);
                CambiarEstadoCliente(idCliente, 1);
            }
        }

        private void CambiarEstadoCliente(int idCliente, int nuevoEstado)
        {
            string query = "UPDATE cliente SET Activo = @Activo WHERE IdCliente = @IdCliente";
            using (MySqlConnection con = new MySqlConnection(connectionString))
            using (MySqlCommand cmd = new MySqlCommand(query, con))
            {
                cmd.Parameters.AddWithValue("@Activo", nuevoEstado);
                cmd.Parameters.AddWithValue("@IdCliente", idCliente);
                try
                {
                    con.Open();
                    cmd.ExecuteNonQuery();
                    lblMensaje.Text = nuevoEstado == 1 ? "Cliente reactivado exitosamente." : "Cliente desactivado correctamente.";
                    lblMensaje.ForeColor = System.Drawing.Color.Green;
                    CargarClientes();
                }
                catch (Exception ex)
                {
                    lblMensaje.Text = "Error al actualizar estado: " + ex.Message;
                    lblMensaje.ForeColor = System.Drawing.Color.Red;
                }
            }
        }

        private void CargarDatosParaEditar(int idCliente)
        {
            string query = @"SELECT IdCliente, Rut, Nombre, 
                                    COALESCE(RazonSocial, Nombre) AS RazonSocial,
                                    COALESCE(Categoria, 'General') AS Categoria,
                                    COALESCE(Giro, '') AS Giro,
                                    COALESCE(Direccion, '') AS Direccion,
                                    COALESCE(Contacto, '') AS Contacto,
                                    COALESCE(Correo, '') AS Correo,
                                    COALESCE(Telefono, '') AS Telefono,
                                    COALESCE(LimiteCredito, 0) AS LimiteCredito,
                                    COALESCE(DiasCredito, 0) AS DiasCredito
                             FROM cliente WHERE IdCliente = @Id";

            using (MySqlConnection con = new MySqlConnection(connectionString))
            using (MySqlCommand cmd = new MySqlCommand(query, con))
            {
                cmd.Parameters.AddWithValue("@Id", idCliente);
                con.Open();
                using (MySqlDataReader reader = cmd.ExecuteReader())
                {
                    if (reader.Read())
                    {
                        hfIdCliente.Value = reader["IdCliente"].ToString();
                        txtRut.Text = reader["Rut"].ToString();
                        txtNombre.Text = reader["Nombre"].ToString();

                        string cat = reader["Categoria"].ToString();
                        if (ddlCategoria.Items.FindByValue(cat) != null)
                            ddlCategoria.SelectedValue = cat;

                        txtGiro.Text = reader["Giro"].ToString();
                        txtDireccion.Text = reader["Direccion"].ToString();
                        txtContacto.Text = reader["Contacto"].ToString();
                        txtCorreo.Text = reader["Correo"].ToString();
                        txtTelefono.Text = reader["Telefono"].ToString();
                        txtLimiteCredito.Text = reader["LimiteCredito"].ToString();
                        txtDiasCredito.Text = reader["DiasCredito"].ToString();

                        lblTituloForm.InnerText = "✏️ Modificar Cliente (ID: " + hfIdCliente.Value + ")";
                        btnGuardar.Text = "Guardar Cambios";
                        btnCancelar.Visible = true;
                        lblMensaje.Text = "";
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
            hfIdCliente.Value = "";
            txtRut.Text = "";
            txtNombre.Text = "";
            ddlCategoria.SelectedIndex = 0;
            txtGiro.Text = "";
            txtDireccion.Text = "";
            txtContacto.Text = "";
            txtCorreo.Text = "";
            txtTelefono.Text = "";
            txtLimiteCredito.Text = "";
            txtDiasCredito.Text = "";
            lblTituloForm.InnerText = "Registrar Nuevo Cliente";
            btnGuardar.Text = "Guardar Cliente";
            btnCancelar.Visible = false;
        }

        protected void btnIrVentas_Click(object sender, EventArgs e)
        {
            Response.Redirect("Ventas.aspx");
        }

        protected void btnLogout_Click(object sender, EventArgs e)
        {
            Session.Clear();
            Session.Abandon();
            Response.Redirect("Login.aspx");
        }
    }
}
