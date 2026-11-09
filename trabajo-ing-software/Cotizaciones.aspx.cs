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
    public partial class Cotizaciones : PaginaVentas
    {
        string connectionString = ConfigurationManager.ConnectionStrings["DefaultConnection"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                // 1. Llenar listas desde MySQL
                CargarClientes();
                CargarProductos();

                // 2. Crear estructura vacía del carrito (Ahora incluye IdVariante para la BD)
                DataTable dtDetalle = new DataTable();
                dtDetalle.Columns.Add("IdVariante");
                dtDetalle.Columns.Add("Producto");
                dtDetalle.Columns.Add("Cantidad", typeof(int));
                dtDetalle.Columns.Add("Precio", typeof(int));
                dtDetalle.Columns.Add("Subtotal", typeof(int));

                ViewState["DetalleCotizacion"] = dtDetalle;
                gvDetalleCotizacion.DataSource = dtDetalle;
                gvDetalleCotizacion.DataBind();

                // 3. Cargar el historial de cotizaciones de la tabla inferior
                CargarHistorial();
            }
        }

        private void CargarClientes()
        {
            using (MySqlConnection con = new MySqlConnection(connectionString))
            {
                string query = "SELECT IdCliente, Nombre FROM Cliente ORDER BY Nombre ASC";
                using (MySqlCommand cmd = new MySqlCommand(query, con))
                {
                    con.Open();
                    using (MySqlDataReader sdr = cmd.ExecuteReader())
                    {
                        ddlClientes.DataSource = sdr;
                        ddlClientes.DataTextField = "Nombre";
                        ddlClientes.DataValueField = "IdCliente";
                        ddlClientes.DataBind();
                    }
                }
            }
            ddlClientes.Items.Insert(0, new ListItem("-- Seleccione un Cliente --", ""));
        }

        private void CargarProductos()
        {
            using (MySqlConnection con = new MySqlConnection(connectionString))
            {
                // Volvemos a leer de VarianteProducto respetando la BD original
                string query = "SELECT IdVariante, NombreVariante FROM VarianteProducto ORDER BY NombreVariante ASC";
                using (MySqlCommand cmd = new MySqlCommand(query, con))
                {
                    con.Open();
                    using (MySqlDataReader sdr = cmd.ExecuteReader())
                    {
                        ddlProductos.DataSource = sdr;
                        ddlProductos.DataTextField = "NombreVariante";
                        ddlProductos.DataValueField = "IdVariante";
                        ddlProductos.DataBind();
                    }
                }
            }
            ddlProductos.Items.Insert(0, new ListItem("-- Seleccione un Producto --", ""));
        }

        private void CargarHistorial()
        {
            // Este método llena la grilla inferior con las cotizaciones guardadas
            using (MySqlConnection con = new MySqlConnection(connectionString))
            {
                string query = @"SELECT c.IdCotizacion, cl.Nombre AS Cliente, c.FechaEmision, c.Estado, c.Total 
                                 FROM Cotizacion c 
                                 INNER JOIN Cliente cl ON c.IdCliente = cl.IdCliente 
                                 ORDER BY c.IdCotizacion DESC";
                using (MySqlCommand cmd = new MySqlCommand(query, con))
                {
                    using (MySqlDataAdapter sda = new MySqlDataAdapter(cmd))
                    {
                        DataTable dtHistorial = new DataTable();
                        sda.Fill(dtHistorial);
                        gvHistorialCotizaciones.DataSource = dtHistorial;
                        gvHistorialCotizaciones.DataBind();
                    }
                }
            }
        }
        

        protected void btnAgregarProducto_Click(object sender, EventArgs e)
        {
            // Validaciones
            if (ddlClientes.SelectedValue == "")
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('Seleccione un cliente primero.');", true);
                return;
            }
            if (ddlProductos.SelectedValue == "" || string.IsNullOrEmpty(txtCantidad.Text) || string.IsNullOrEmpty(txtPrecio.Text))
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('Seleccione producto, cantidad y precio.');", true);
                return;
            }

            // BLOQUEAR CLIENTE: Ya no se puede cambiar porque la cotización inició
            ddlClientes.Enabled = false;

            DataTable dtDetalle = (DataTable)ViewState["DetalleCotizacion"];

            string idVariante = ddlProductos.SelectedValue;
            string nombreProducto = ddlProductos.SelectedItem.Text;
            int cantidad = int.Parse(txtCantidad.Text);
            int precio = int.Parse(txtPrecio.Text);
            int subtotal = cantidad * precio;

            dtDetalle.Rows.Add(idVariante, nombreProducto, cantidad, precio, subtotal);
            ViewState["DetalleCotizacion"] = dtDetalle;

            gvDetalleCotizacion.DataSource = dtDetalle;
            gvDetalleCotizacion.DataBind();

            ActualizarTotal(dtDetalle);

            ddlProductos.SelectedIndex = 0;
            txtCantidad.Text = "1";
            txtPrecio.Text = "";
        }

        private void ActualizarTotal(DataTable dt)
        {
            int totalGeneral = 0;
            foreach (DataRow row in dt.Rows)
            {
                totalGeneral += Convert.ToInt32(row["Subtotal"]);
            }
            lblTotal.Text = totalGeneral.ToString("N0");
        }

        protected void btnGuardarCotizacion_Click(object sender, EventArgs e)
        {
            DataTable dtDetalle = (DataTable)ViewState["DetalleCotizacion"];

            if (ddlClientes.SelectedValue == "" || dtDetalle.Rows.Count == 0)
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('Seleccione un cliente y agregue productos.');", true);
                return;
            }

            string idCliente = ddlClientes.SelectedValue;
            string estado = ddlEstado.SelectedValue;
            decimal totalFinal = 0;
            foreach (DataRow fila in dtDetalle.Rows) totalFinal += Convert.ToDecimal(fila["Subtotal"]);

            using (MySqlConnection con = new MySqlConnection(connectionString))
            {
                con.Open();
                using (MySqlTransaction tr = con.BeginTransaction())
                {
                    try
                    {
                        // 1. INSERTAR CABECERA (Acorde a tu modelo de BD)
                        string queryCabecera = @"INSERT INTO Cotizacion (FechaEmision, Estado, Total, IdCliente, IdUsuario) 
                                                 VALUES (NOW(), @estado, @total, @idCliente, @idUsuario);
                                                 SELECT LAST_INSERT_ID();";

                        int idCotizacion;
                        using (MySqlCommand cmdCab = new MySqlCommand(queryCabecera, con, tr))
                        {
                            cmdCab.Parameters.AddWithValue("@estado", estado);
                            cmdCab.Parameters.AddWithValue("@total", totalFinal);
                            cmdCab.Parameters.AddWithValue("@idCliente", idCliente);
                            cmdCab.Parameters.AddWithValue("@idUsuario", UsuarioVenta);

                            idCotizacion = Convert.ToInt32(cmdCab.ExecuteScalar());
                        }

                        // 2. INSERTAR DETALLE
                        string queryDetalle = @"INSERT INTO CotizacionDetalle (IdCotizacion, IdVariante, Cantidad, PrecioUnitario) 
                                                VALUES (@idCot, @idVar, @cant, @precio)";

                        using (MySqlCommand cmdDet = new MySqlCommand(queryDetalle, con, tr))
                        {
                            foreach (DataRow fila in dtDetalle.Rows)
                            {
                                cmdDet.Parameters.Clear();
                                cmdDet.Parameters.AddWithValue("@idCot", idCotizacion);
                                cmdDet.Parameters.AddWithValue("@idVar", fila["IdVariante"].ToString());
                                cmdDet.Parameters.AddWithValue("@cant", Convert.ToInt32(fila["Cantidad"]));
                                cmdDet.Parameters.AddWithValue("@precio", Convert.ToInt32(fila["Precio"]));
                                cmdDet.ExecuteNonQuery();
                            }
                        }

                        tr.Commit();
                        LimpiarPantalla();
                        CargarHistorial(); // Refresca la tabla inferior automáticamente
                        ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('¡Cotización N° " + idCotizacion + " guardada exitosamente!');", true);
                    }
                    catch (Exception ex)
                    {
                        tr.Rollback();
                        ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('Error: " + ex.Message.Replace("'", "") + "');", true);
                    }
                }
            }
        }

        // EVENTOS DE LA GRILLA INFERIOR (Ver y Editar)
        protected void gvHistorialCotizaciones_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            if (e.CommandName == "VerDetalle")
            {
                string idCotizacion = e.CommandArgument.ToString();
                // Lógica para abrir un modal o redireccionar a la vista de detalle
                ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('Funcionalidad Ver Detalle para Cotización N° " + idCotizacion + " en construcción');", true);
            }
            else if (e.CommandName == "EditarCotizacion")
            {
                string idCotizacion = e.CommandArgument.ToString();
                // Lógica para cargar los datos nuevamente en el formulario de arriba
                ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('Funcionalidad Editar para Cotización N° " + idCotizacion + " en construcción');", true);
            }
        }

        private void LimpiarPantalla()
        {
            ddlClientes.SelectedIndex = 0;
            ddlClientes.Enabled = true; // DESBLOQUEAR EL CLIENTE

            ddlEstado.SelectedIndex = 0;
            lblTotal.Text = "0";

            DataTable dt = (DataTable)ViewState["DetalleCotizacion"];
            dt.Clear();
            ViewState["DetalleCotizacion"] = dt;
            gvDetalleCotizacion.DataSource = dt;
            gvDetalleCotizacion.DataBind();
        }

        protected void ddlProductos_SelectedIndexChanged(object sender, EventArgs e)
        {
            if (ddlProductos.SelectedValue != "")
            {
                using (MySqlConnection con = new MySqlConnection(connectionString))
                {
                    // Volvemos a buscar el PrecioVenta en VarianteProducto
                    string query = "SELECT PrecioVenta FROM VarianteProducto WHERE IdVariante = @id";
                    using (MySqlCommand cmd = new MySqlCommand(query, con))
                    {
                        cmd.Parameters.AddWithValue("@id", ddlProductos.SelectedValue);
                        con.Open();
                        object result = cmd.ExecuteScalar();
                        if (result != null)
                        {
                            txtPrecio.Text = result.ToString();
                        }
                    }
                }
            }
            else
            {
                txtPrecio.Text = "";
            }
        }

        protected void txtCantidad_TextChanged(object sender, EventArgs e)
        {

        }
    }
}