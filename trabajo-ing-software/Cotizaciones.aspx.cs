using MySql.Data.MySqlClient;
using System;
using System.Configuration;
using System.Data;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace trabajo_ing_software
{
    public partial class Cotizaciones : PaginaVentas
    {
        private string connectionString = ConfigurationManager.ConnectionStrings["DefaultConnection"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                using (var con = new MySqlConnection(connectionString))
                {
                    con.Open();
                    VentaInventario.AsegurarEsquema(con);
                }
                CargarClientes();
                CargarProductos();
                txtFechaVencimiento.Text = DateTime.Today.AddDays(15).ToString("yyyy-MM-dd");

                DataTable dtDetalle = new DataTable();
                dtDetalle.Columns.Add("IdVariante");
                dtDetalle.Columns.Add("Producto");
                dtDetalle.Columns.Add("Cantidad", typeof(int));
                dtDetalle.Columns.Add("Precio", typeof(int));
                dtDetalle.Columns.Add("Subtotal", typeof(int));

                ViewState["DetalleCotizacion"] = dtDetalle;
                gvDetalleCotizacion.DataSource = dtDetalle;
                gvDetalleCotizacion.DataBind();

                CargarHistorial();
            }
        }

        public string GetClaseEstado(string estado)
        {
            switch (estado)
            {
                case "Vigente": return "badge-vigente";
                case "Aceptado": return "badge-aceptado";
                case "Vencido": return "badge-vencido";
                case "Rechazado": return "badge-rechazado";
                default: return "badge-vigente";
            }
        }

        private void CargarClientes()
        {
            using (MySqlConnection con = new MySqlConnection(connectionString))
            {
                string query = "SELECT IdCliente, Nombre FROM cliente ORDER BY Nombre ASC";
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
                string query = @"SELECT v.IdVariante, CONCAT(p.Nombre, ' (', v.NombreVariante, ' - SKU: ', v.Sku, ')') AS NombreCompleto 
                                 FROM varianteproducto v 
                                 INNER JOIN producto p ON v.IdProducto = p.IdProducto 
                                 WHERE v.Activo = 1 AND p.Activo = 1 AND v.PrecioVenta > 0 
                                 ORDER BY p.Nombre ASC, v.NombreVariante ASC";
                using (MySqlCommand cmd = new MySqlCommand(query, con))
                {
                    con.Open();
                    using (MySqlDataReader sdr = cmd.ExecuteReader())
                    {
                        ddlProductos.DataSource = sdr;
                        ddlProductos.DataTextField = "NombreCompleto";
                        ddlProductos.DataValueField = "IdVariante";
                        ddlProductos.DataBind();
                    }
                }
            }
            ddlProductos.Items.Insert(0, new ListItem("-- Seleccione un Producto --", ""));
        }

        private void CargarHistorial()
        {
            using (MySqlConnection con = new MySqlConnection(connectionString))
            {
                // Auto-actualiza a 'Vencido' aquellas cotizaciones vigentes cuya fecha de vencimiento ya pasó
                string actualizaVencidos = @"UPDATE cotizacion 
                                             SET Estado = 'Vencido' 
                                             WHERE Estado = 'Vigente' AND FechaVencimiento IS NOT NULL AND FechaVencimiento < CURDATE()";
                try
                {
                    con.Open();
                    using (MySqlCommand cmdUpd = new MySqlCommand(actualizaVencidos, con))
                    {
                        cmdUpd.ExecuteNonQuery();
                    }
                }
                catch { }

                string query = @"SELECT c.IdCotizacion, cl.Nombre AS Cliente, c.FechaEmision, 
                                        c.FechaVencimiento, c.Estado, c.Total 
                                 FROM cotizacion c 
                                 INNER JOIN cliente cl ON c.IdCliente = cl.IdCliente 
                                 ORDER BY c.IdCotizacion DESC";
                using (MySqlCommand cmd = new MySqlCommand(query, con))
                using (MySqlDataAdapter sda = new MySqlDataAdapter(cmd))
                {
                    DataTable dtHistorial = new DataTable();
                    sda.Fill(dtHistorial);
                    gvHistorialCotizaciones.DataSource = dtHistorial;
                    gvHistorialCotizaciones.DataBind();
                }
            }
        }

        protected void btnAgregarProducto_Click(object sender, EventArgs e)
        {
            if (ddlClientes.SelectedValue == "")
            {
                MostrarMensaje("Seleccione un cliente primero.", false);
                return;
            }
            if (ddlProductos.SelectedValue == "" || string.IsNullOrEmpty(txtCantidad.Text) || string.IsNullOrEmpty(txtPrecio.Text))
            {
                MostrarMensaje("Seleccione producto, cantidad y precio válido.", false);
                return;
            }

            int cantidad;
            int precio;
            if (!int.TryParse(txtCantidad.Text, out cantidad) || cantidad <= 0 || !int.TryParse(txtPrecio.Text, out precio) || precio <= 0)
            {
                MostrarMensaje("La cantidad y precio deben ser mayores a cero.", false);
                return;
            }

            ddlClientes.Enabled = false;

            DataTable dtDetalle = (DataTable)ViewState["DetalleCotizacion"];
            string idVariante = ddlProductos.SelectedValue;
            string nombreProducto = ddlProductos.SelectedItem.Text;
            int subtotal = cantidad * precio;

            dtDetalle.Rows.Add(idVariante, nombreProducto, cantidad, precio, subtotal);
            ViewState["DetalleCotizacion"] = dtDetalle;

            gvDetalleCotizacion.DataSource = dtDetalle;
            gvDetalleCotizacion.DataBind();

            ActualizarTotal(dtDetalle);

            ddlProductos.SelectedIndex = 0;
            txtCantidad.Text = "1";
            txtPrecio.Text = "";
            lblMensajeCotizacion.Text = "";
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
                MostrarMensaje("Seleccione un cliente y agregue al menos un producto al presupuesto.", false);
                return;
            }

            string idCliente = ddlClientes.SelectedValue;
            string estado = ddlEstado.SelectedValue;

            DateTime? fechaVence = null;
            if (DateTime.TryParse(txtFechaVencimiento.Text, out DateTime parsedVence))
                fechaVence = parsedVence;

            decimal totalFinal = 0;
            foreach (DataRow fila in dtDetalle.Rows) totalFinal += Convert.ToDecimal(fila["Subtotal"]);

            using (MySqlConnection con = new MySqlConnection(connectionString))
            {
                con.Open();
                using (MySqlTransaction tr = con.BeginTransaction())
                {
                    try
                    {
                        string queryCabecera = @"INSERT INTO cotizacion (FechaEmision, FechaVencimiento, Estado, Total, IdCliente, IdUsuario) 
                                                 VALUES (NOW(), @vence, @estado, @total, @idCliente, @idUsuario);
                                                 SELECT LAST_INSERT_ID();";

                        int idCotizacion;
                        using (MySqlCommand cmdCab = new MySqlCommand(queryCabecera, con, tr))
                        {
                            cmdCab.Parameters.AddWithValue("@vence", (object)fechaVence ?? DBNull.Value);
                            cmdCab.Parameters.AddWithValue("@estado", estado);
                            cmdCab.Parameters.AddWithValue("@total", totalFinal);
                            cmdCab.Parameters.AddWithValue("@idCliente", idCliente);
                            cmdCab.Parameters.AddWithValue("@idUsuario", UsuarioVenta);

                            idCotizacion = Convert.ToInt32(cmdCab.ExecuteScalar());
                        }

                        string queryDetalle = @"INSERT INTO cotizaciondetalle (IdCotizacion, IdVariante, Cantidad, PrecioUnitario) 
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
                        CargarHistorial();
                        MostrarMensaje("¡Cotización N° " + idCotizacion + " registrada exitosamente!", true);
                    }
                    catch (Exception ex)
                    {
                        tr.Rollback();
                        MostrarMensaje("Error al guardar cotización: " + ex.Message, false);
                    }
                }
            }
        }

        protected void gvHistorialCotizaciones_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            if (e.CommandName == "ConvertirVenta")
            {
                string idCotizacion = e.CommandArgument.ToString();
                // Redirige al punto de venta cargando esta cotización
                Response.Redirect("Ventas.aspx?idCotizacion=" + idCotizacion);
            }
            else if (e.CommandName == "MarcarAceptado")
            {
                CambiarEstado(Convert.ToInt32(e.CommandArgument), "Aceptado");
            }
            else if (e.CommandName == "MarcarRechazado")
            {
                CambiarEstado(Convert.ToInt32(e.CommandArgument), "Rechazado");
            }
        }

        private void CambiarEstado(int idCotizacion, string nuevoEstado)
        {
            string query = "UPDATE cotizacion SET Estado = @Estado WHERE IdCotizacion = @Id";
            using (MySqlConnection con = new MySqlConnection(connectionString))
            using (MySqlCommand cmd = new MySqlCommand(query, con))
            {
                cmd.Parameters.AddWithValue("@Estado", nuevoEstado);
                cmd.Parameters.AddWithValue("@Id", idCotizacion);
                con.Open();
                cmd.ExecuteNonQuery();
            }
            CargarHistorial();
            MostrarMensaje("Cotización N° " + idCotizacion + " marcada como " + nuevoEstado + ".", true);
        }

        private void MostrarMensaje(string texto, bool exito)
        {
            lblMensajeCotizacion.Text = texto;
            lblMensajeCotizacion.ForeColor = exito ? System.Drawing.Color.Green : System.Drawing.Color.Red;
        }

        private void LimpiarPantalla()
        {
            ddlClientes.SelectedIndex = 0;
            ddlClientes.Enabled = true;
            ddlEstado.SelectedIndex = 0;
            txtFechaVencimiento.Text = DateTime.Today.AddDays(15).ToString("yyyy-MM-dd");
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
                    string query = "SELECT PrecioVenta FROM varianteproducto WHERE IdVariante = @id";
                    using (MySqlCommand cmd = new MySqlCommand(query, con))
                    {
                        cmd.Parameters.AddWithValue("@id", ddlProductos.SelectedValue);
                        con.Open();
                        object result = cmd.ExecuteScalar();
                        if (result != null)
                        {
                            txtPrecio.Text = Convert.ToInt32(Convert.ToDecimal(result)).ToString();
                        }
                    }
                }
            }
            else
            {
                txtPrecio.Text = "";
            }
        }
    }
}
