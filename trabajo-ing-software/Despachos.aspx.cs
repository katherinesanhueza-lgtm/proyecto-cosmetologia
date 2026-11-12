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
    public partial class Despachos : PaginaVentas
    {
        string connectionString = ConfigurationManager.ConnectionStrings["DefaultConnection"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            // Conexión manual de eventos (Método infalible)
            ddlDocumentoOrigen.SelectedIndexChanged += new EventHandler(ddlDocumentoOrigen_SelectedIndexChanged);

            if (!IsPostBack)
            {
                CargarVentas();
                CargarHistorial();
                txtFechaEstimada.Text = DateTime.Now.AddDays(3).ToString("yyyy-MM-dd"); // Sugiere fecha 3 días después
            }
        }

        private void CargarVentas()
        {
            using (MySqlConnection con = new MySqlConnection(connectionString))
            {
                // Carga las ventas disponibles desde la tabla Venta
                string query = "SELECT IdVenta, CONCAT('Venta N° ', IdVenta) AS NombreVenta FROM Venta WHERE TipoDocumento <> 'Nota de Credito' ORDER BY IdVenta DESC";
                using (MySqlCommand cmd = new MySqlCommand(query, con))
                {
                    con.Open();
                    using (MySqlDataReader sdr = cmd.ExecuteReader())
                    {
                        ddlDocumentoOrigen.DataSource = sdr;
                        ddlDocumentoOrigen.DataTextField = "NombreVenta";
                        ddlDocumentoOrigen.DataValueField = "IdVenta";
                        ddlDocumentoOrigen.DataBind();
                    }
                }
            }
            ddlDocumentoOrigen.Items.Insert(0, new ListItem("-- Seleccione una Venta --", ""));
        }

        protected void ddlDocumentoOrigen_SelectedIndexChanged(object sender, EventArgs e)
        {
            if (ddlDocumentoOrigen.SelectedValue != "")
            {
                using (MySqlConnection con = new MySqlConnection(connectionString))
                {
                    // Busca el nombre del cliente asociado a esa venta
                    string query = @"SELECT c.Nombre 
                                     FROM Venta v 
                                     INNER JOIN Cliente c ON v.IdCliente = c.IdCliente 
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
                ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('Complete todos los campos obligatorios.');", true);
                return;
            }

            using (MySqlConnection con = new MySqlConnection(connectionString))
            {
                // INSERT exactamente igual a tu tabla Despacho en bd.sql
                string query = @"INSERT INTO Despacho (IdVenta, Estado, FechaEstimada, Tipo, IdUsuario) 
                                 VALUES (@idVenta, @estado, @fecha, @tipo, @idUsuario)";

                using (MySqlCommand cmd = new MySqlCommand(query, con))
                {
                    cmd.Parameters.AddWithValue("@idVenta", ddlDocumentoOrigen.SelectedValue);
                    cmd.Parameters.AddWithValue("@estado", ddlEstadoDespacho.SelectedValue);
                    cmd.Parameters.AddWithValue("@fecha", Convert.ToDateTime(txtFechaEstimada.Text).ToString("yyyy-MM-dd"));
                    cmd.Parameters.AddWithValue("@tipo", ddlTransportista.SelectedValue);
                    cmd.Parameters.AddWithValue("@idUsuario", UsuarioVenta);

                    try
                    {
                        con.Open();
                        cmd.ExecuteNonQuery();

                        LimpiarFormulario();
                        CargarHistorial();
                        ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('Despacho registrado correctamente.');", true);
                    }
                    catch (Exception ex)
                    {
                        ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('Error: " + ex.Message.Replace("'", "") + "');", true);
                    }
                }
            }
        }

        private void CargarHistorial()
        {
            using (MySqlConnection con = new MySqlConnection(connectionString))
            {
                string query = @"SELECT d.IdDespacho, d.IdVenta, c.Nombre AS Cliente, d.Tipo, d.FechaEstimada, d.Estado 
                                 FROM Despacho d 
                                 INNER JOIN Venta v ON d.IdVenta = v.IdVenta 
                                 INNER JOIN Cliente c ON v.IdCliente = c.IdCliente 
                                 ORDER BY d.IdDespacho DESC";
                using (MySqlCommand cmd = new MySqlCommand(query, con))
                {
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

        private void LimpiarFormulario()
        {
            ddlDocumentoOrigen.SelectedIndex = 0;
            txtCliente.Text = "";
            ddlEstadoDespacho.SelectedIndex = 0;
            ddlTransportista.SelectedIndex = 0;
            txtFechaEstimada.Text = DateTime.Now.AddDays(3).ToString("yyyy-MM-dd");
        }
    }
}