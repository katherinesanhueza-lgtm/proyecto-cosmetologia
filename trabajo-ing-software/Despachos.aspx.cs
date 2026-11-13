using MySql.Data.MySqlClient;
using System;
using System.Configuration;
using System.Data;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace trabajo_ing_software
{
    public partial class Despachos : PaginaVentas
    {
        private string connectionString = ConfigurationManager.ConnectionStrings["DefaultConnection"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            ddlDocumentoOrigen.SelectedIndexChanged += new EventHandler(ddlDocumentoOrigen_SelectedIndexChanged);

            if (!IsPostBack)
            {
                using (var con = new MySqlConnection(connectionString))
                {
                    con.Open();
                    VentaInventario.AsegurarEsquema(con);
                }
                CargarVentas();
                CargarHistorial();
                txtFechaEstimada.Text = DateTime.Now.AddDays(3).ToString("yyyy-MM-dd");
            }
        }

        public string GetClaseEstado(string estado)
        {
            switch (estado)
            {
                case "Pendiente": return "badge-pendiente";
                case "En Preparacion": return "badge-preparacion";
                case "En Ruta": return "badge-ruta";
                case "Entregado": return "badge-entregado";
                case "Cancelado": return "badge-cancelado";
                default: return "badge-pendiente";
            }
        }

        private void CargarVentas()
        {
            using (MySqlConnection con = new MySqlConnection(connectionString))
            {
                string query = @"SELECT IdVenta, 
                                 CONCAT(TipoDocumento, ' N° ', COALESCE(Folio, IdVenta), ' · Total: $', FORMAT(Total, 0)) AS DescripcionVenta 
                                 FROM venta 
                                 WHERE TipoDocumento <> 'Nota de Credito' 
                                 ORDER BY IdVenta DESC LIMIT 50";

                using (MySqlCommand cmd = new MySqlCommand(query, con))
                {
                    con.Open();
                    using (MySqlDataReader sdr = cmd.ExecuteReader())
                    {
                        ddlDocumentoOrigen.DataSource = sdr;
                        ddlDocumentoOrigen.DataTextField = "DescripcionVenta";
                        ddlDocumentoOrigen.DataValueField = "IdVenta";
                        ddlDocumentoOrigen.DataBind();
                    }
                }
            }
            ddlDocumentoOrigen.Items.Insert(0, new ListItem("-- Seleccione un Documento de Venta --", ""));
        }

        protected void ddlDocumentoOrigen_SelectedIndexChanged(object sender, EventArgs e)
        {
            if (ddlDocumentoOrigen.SelectedValue != "")
            {
                using (MySqlConnection con = new MySqlConnection(connectionString))
                {
                    string query = @"SELECT c.Nombre 
                                     FROM venta v 
                                     INNER JOIN cliente c ON v.IdCliente = c.IdCliente 
                                     WHERE v.IdVenta = @idVenta";
                    using (MySqlCommand cmd = new MySqlCommand(query, con))
                    {
                        cmd.Parameters.AddWithValue("@idVenta", ddlDocumentoOrigen.SelectedValue);
                        con.Open();
                        object result = cmd.ExecuteScalar();
                        if (result != null)
                        {
                            txtCliente.Text = result.ToString();
                        }
                    }
                }
            }
            else
            {
                txtCliente.Text = "";
            }
        }

        protected void btnGuardarDespacho_Click(object sender, EventArgs e)
        {
            if (ddlDocumentoOrigen.SelectedValue == "" || ddlTransportista.SelectedValue == "" || string.IsNullOrEmpty(txtFechaEstimada.Text))
            {
                MostrarMensaje("Complete todos los campos obligatorios del despacho.", false);
                return;
            }

            using (MySqlConnection con = new MySqlConnection(connectionString))
            {
                string query = @"INSERT INTO despacho (IdVenta, Estado, FechaEstimada, Tipo, Observaciones, IdUsuario) 
                                 VALUES (@idVenta, @estado, @fecha, @tipo, @obs, @idUsuario)";

                using (MySqlCommand cmd = new MySqlCommand(query, con))
                {
                    cmd.Parameters.AddWithValue("@idVenta", ddlDocumentoOrigen.SelectedValue);
                    cmd.Parameters.AddWithValue("@estado", ddlEstadoDespacho.SelectedValue);
                    cmd.Parameters.AddWithValue("@fecha", Convert.ToDateTime(txtFechaEstimada.Text).ToString("yyyy-MM-dd"));
                    cmd.Parameters.AddWithValue("@tipo", ddlTransportista.SelectedValue);
                    cmd.Parameters.AddWithValue("@obs", txtObservaciones.Text.Trim());
                    cmd.Parameters.AddWithValue("@idUsuario", UsuarioVenta);

                    try
                    {
                        con.Open();
                        cmd.ExecuteNonQuery();

                        LimpiarFormulario();
                        CargarHistorial();
                        MostrarMensaje("Despacho programado correctamente.", true);
                    }
                    catch (Exception ex)
                    {
                        MostrarMensaje("Error al programar despacho: " + ex.Message, false);
                    }
                }
            }
        }

        protected void ddlFiltroEstado_SelectedIndexChanged(object sender, EventArgs e)
        {
            CargarHistorial();
        }

        private void CargarHistorial()
        {
            string filtro = "";
            if (ddlFiltroEstado.SelectedValue != "Todos")
            {
                filtro = "WHERE d.Estado = @EstadoFiltro";
            }

            using (MySqlConnection con = new MySqlConnection(connectionString))
            {
                string query = $@"SELECT d.IdDespacho, 
                                         CONCAT(v.TipoDocumento, ' #', COALESCE(v.Folio, v.IdVenta)) AS Documento,
                                         c.Nombre AS Cliente, 
                                         d.Tipo, 
                                         d.FechaEstimada, 
                                         d.FechaEntrega,
                                         d.Estado,
                                         d.Observaciones 
                                  FROM despacho d 
                                  INNER JOIN venta v ON d.IdVenta = v.IdVenta 
                                  INNER JOIN cliente c ON v.IdCliente = c.IdCliente 
                                  {filtro}
                                  ORDER BY d.IdDespacho DESC";

                using (MySqlCommand cmd = new MySqlCommand(query, con))
                {
                    if (ddlFiltroEstado.SelectedValue != "Todos")
                    {
                        cmd.Parameters.AddWithValue("@EstadoFiltro", ddlFiltroEstado.SelectedValue);
                    }

                    using (MySqlDataAdapter sda = new MySqlDataAdapter(cmd))
                    {
                        DataTable dt = new DataTable();
                        sda.Fill(dt);
                        gvDespachos.DataSource = dt;
                        gvDespachos.DataBind();
                    }
                }
            }
        }

        protected void gvDespachos_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            if (e.CommandName == "CambiarEstado")
            {
                string[] partes = Convert.ToString(e.CommandArgument).Split('|');
                if (partes.Length == 2)
                {
                    int idDespacho = Convert.ToInt32(partes[0]);
                    string nuevoEstado = partes[1];
                    ActualizarEstadoDespacho(idDespacho, nuevoEstado, null);
                }
            }
            else if (e.CommandName == "RegistrarEntrega")
            {
                int idDespacho = Convert.ToInt32(e.CommandArgument);
                // RF-VEN-08: Registrar entrega con fecha efectiva
                ActualizarEstadoDespacho(idDespacho, "Entregado", DateTime.Today);
            }
        }

        private void ActualizarEstadoDespacho(int idDespacho, string nuevoEstado, DateTime? fechaEntrega)
        {
            using (MySqlConnection con = new MySqlConnection(connectionString))
            {
                string query = "UPDATE despacho SET Estado = @Estado, FechaEntrega = @FechaEntrega WHERE IdDespacho = @Id";
                using (MySqlCommand cmd = new MySqlCommand(query, con))
                {
                    cmd.Parameters.AddWithValue("@Estado", nuevoEstado);
                    cmd.Parameters.AddWithValue("@FechaEntrega", (object)fechaEntrega ?? DBNull.Value);
                    cmd.Parameters.AddWithValue("@Id", idDespacho);

                    try
                    {
                        con.Open();
                        cmd.ExecuteNonQuery();
                        CargarHistorial();
                        MostrarMensaje($"Despacho #{idDespacho} actualizado a '{nuevoEstado}'.", true);
                    }
                    catch (Exception ex)
                    {
                        MostrarMensaje("Error al actualizar despacho: " + ex.Message, false);
                    }
                }
            }
        }

        private void MostrarMensaje(string texto, bool exito)
        {
            lblMensajeDespacho.Text = texto;
            lblMensajeDespacho.ForeColor = exito ? System.Drawing.Color.Green : System.Drawing.Color.Red;
        }

        private void LimpiarFormulario()
        {
            ddlDocumentoOrigen.SelectedIndex = 0;
            txtCliente.Text = "";
            ddlEstadoDespacho.SelectedIndex = 0;
            ddlTransportista.SelectedIndex = 0;
            txtObservaciones.Text = "";
            txtFechaEstimada.Text = DateTime.Now.AddDays(3).ToString("yyyy-MM-dd");
        }
    }
}
