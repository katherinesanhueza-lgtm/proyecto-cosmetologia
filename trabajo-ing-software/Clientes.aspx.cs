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
    public partial class Clientes : PaginaVentas
    {
        string connectionString = ConfigurationManager.ConnectionStrings["DefaultConnection"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
       // {
          //  if (Session["IdUsuario"] == null)
           // {
             //   Response.Redirect("Login.aspx");
              //  return;
           // }

           // if (!IsPostBack)
            {
                lblBienvenida.Text = "modo test" ;
                CargarClientes();
            }
       // }

        private void CargarClientes()
        {
            string query = "SELECT IdCliente, Rut, Nombre, Categoria, Correo, Telefono FROM Cliente ORDER BY IdCliente DESC";

            using (MySqlConnection con = new MySqlConnection(connectionString))
            {
                using (MySqlCommand cmd = new MySqlCommand(query, con))
                {
                    using (MySqlDataAdapter da = new MySqlDataAdapter(cmd))
                    {
                        DataTable dt = new DataTable();
                        da.Fill(dt);
                        gvClientes.DataSource = dt;
                        gvClientes.DataBind();
                    }
                }
            }
        }

        protected void btnGuardar_Click(object sender, EventArgs e)
        {
            string rut = txtRut.Text.Trim();
            string nombre = txtNombre.Text.Trim();
            string categoria = ddlCategoria.SelectedValue;
            string correo = txtCorreo.Text.Trim();
            string telefono = txtTelefono.Text.Trim();

            if (string.IsNullOrEmpty(rut) || string.IsNullOrEmpty(nombre))
            {
                lblMensaje.Text = "El RUT y el Nombre son obligatorios.";
                lblMensaje.ForeColor = System.Drawing.Color.Red;
                return;
            }

            bool esEdicion = !string.IsNullOrEmpty(hfIdCliente.Value);

            using (MySqlConnection con = new MySqlConnection(connectionString))
            {
                string query = "";
                if (!esEdicion)
                {
                    query = "INSERT INTO Cliente (Rut, Nombre, Categoria, Correo, Telefono) VALUES (@Rut, @Nombre, @Categoria, @Correo, @Telefono)";
                }
                else
                {
                    query = "UPDATE Cliente SET Rut=@Rut, Nombre=@Nombre, Categoria=@Categoria, Correo=@Correo, Telefono=@Telefono WHERE IdCliente=@IdCliente";
                }

                using (MySqlCommand cmd = new MySqlCommand(query, con))
                {
                    cmd.Parameters.AddWithValue("@Rut", rut);
                    cmd.Parameters.AddWithValue("@Nombre", nombre);
                    cmd.Parameters.AddWithValue("@Categoria", categoria);
                    cmd.Parameters.AddWithValue("@Correo", correo);
                    cmd.Parameters.AddWithValue("@Telefono", telefono);

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
                        lblMensaje.Text = "Error al guardar: " + ex.Message;
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
          
            else if (e.CommandName == "Eliminar")
            {
                int idCliente = Convert.ToInt32(e.CommandArgument);
                EliminarCliente(idCliente);
            }
        }
        private void EliminarCliente(int idCliente)
        {
            string query = "DELETE FROM Cliente WHERE IdCliente = @IdCliente";

            using (MySqlConnection con = new MySqlConnection(connectionString))
            {
                using (MySqlCommand cmd = new MySqlCommand(query, con))
                {
                    cmd.Parameters.AddWithValue("@IdCliente", idCliente);
                    try
                    {
                        con.Open();
                        cmd.ExecuteNonQuery();
                        lblMensaje.Text = "Cliente eliminado correctamente.";
                        lblMensaje.ForeColor = System.Drawing.Color.Green;
                        CargarClientes(); 
                    }
                    catch (MySqlException)
                    {
                        lblMensaje.Text = "No se puede eliminar este cliente porque ya tiene ventas o registros asociados.";
                        lblMensaje.ForeColor = System.Drawing.Color.Red;
                    }
                }
            }
        }

        private void CargarDatosParaEditar(int idCliente)
        {
            string query = "SELECT IdCliente, Rut, Nombre, Categoria, Correo, Telefono FROM Cliente WHERE IdCliente = @Id";

            using (MySqlConnection con = new MySqlConnection(connectionString))
            {
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
                            ddlCategoria.SelectedValue = reader["Categoria"].ToString();
                            txtCorreo.Text = reader["Correo"].ToString();
                            txtTelefono.Text = reader["Telefono"].ToString();

                            lblTituloForm.InnerText = "✏️ Modificar Cliente (ID: " + hfIdCliente.Value + ")";
                            btnGuardar.Text = "Guardar Cambios";
                            btnCancelar.Visible = true;
                            lblMensaje.Text = "";
                        }
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
            txtCorreo.Text = "";
            txtTelefono.Text = "";
            lblTituloForm.InnerText = "Registrar Nuevo Cliente";
            btnGuardar.Text = "Guardar Cliente +";
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