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
    public partial class Devoluciones : PaginaVentas
    {
        string connectionString = ConfigurationManager.ConnectionStrings["DefaultConnection"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            // Conexión manual infalible del evento
            ddlVentaOrigen.SelectedIndexChanged += new EventHandler(ddlVentaOrigen_SelectedIndexChanged);

            if (!IsPostBack)
            {
                CargarVentasDisponibles();
                CargarHistorialNotasCredito();
            }
        }

        private void CargarVentasDisponibles()
        {
            using (MySqlConnection con = new MySqlConnection(connectionString))
            {
                // Solo cargamos Ventas reales (excluimos las Notas de Crédito)
                string query = "SELECT IdVenta, CONCAT('Venta N° ', IdVenta) AS NombreVenta FROM Venta WHERE TipoDocumento != 'Nota de Credito' ORDER BY IdVenta DESC";
                using (MySqlCommand cmd = new MySqlCommand(query, con))
                {
                    con.Open();
                    using (MySqlDataReader sdr = cmd.ExecuteReader())
                    {
                        ddlVentaOrigen.DataSource = sdr;
                        ddlVentaOrigen.DataTextField = "NombreVenta";
                        ddlVentaOrigen.DataValueField = "IdVenta";
                        ddlVentaOrigen.DataBind();
                    }
                }
            }
            ddlVentaOrigen.Items.Insert(0, new ListItem("-- Seleccione una Venta --", ""));
        }

        protected void ddlVentaOrigen_SelectedIndexChanged(object sender, EventArgs e)
        {
            if (ddlVentaOrigen.SelectedValue != "")
            {
                using (MySqlConnection con = new MySqlConnection(connectionString))
                {
                    // Buscamos al cliente y el total de la venta original
                    string query = @"SELECT c.IdCliente, c.Nombre, v.Total 
                                     FROM Venta v 
                                     INNER JOIN Cliente c ON v.IdCliente = c.IdCliente 
                                     WHERE v.IdVenta = @id";

                    using (MySqlCommand cmd = new MySqlCommand(query, con))
                    {
                        cmd.Parameters.AddWithValue("@id", ddlVentaOrigen.SelectedValue);
                        con.Open();
                        using (MySqlDataReader sdr = cmd.ExecuteReader())
                        {
                            if (sdr.Read())
                            {
                                txtCliente.Text = sdr["Nombre"].ToString();
                                txtTotalVenta.Text = Convert.ToDecimal(sdr["Total"]).ToString("N2");

                                // Guardamos el IdCliente en memoria para usarlo al guardar
                                ViewState["IdClienteAfectado"] = sdr["IdCliente"].ToString();
                            }
                        }
                    }
                }
            }
            else
            {
                txtCliente.Text = "";
                txtTotalVenta.Text = "";
            }
        }

        protected void btnGuardarDevolucion_Click(object sender, EventArgs e)
        {
            if (ddlVentaOrigen.SelectedValue == "" || string.IsNullOrEmpty(txtCliente.Text))
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('Seleccione una venta válida primero.');", true);
                return;
            }

            if (!int.TryParse(ddlVentaOrigen.SelectedValue, out int origen)) return;
            try
            {
                using (var con = VentaInventario.Abrir())
                using (var cmd = VentaInventario.Comando(con, null, @"INSERT INTO venta
                    (TipoDocumento,Fecha,Total,IdCliente,IdUsuario,IdVentaOrigen)
                    SELECT 'Nota de Credito',CURDATE(),Total,IdCliente,@p0,IdVenta
                    FROM venta WHERE IdVenta=@p1 AND TipoDocumento<>'Nota de Credito'", UsuarioVenta, origen))
                {
                    if (cmd.ExecuteNonQuery() != 1) return;
                }
                CargarVentasDisponibles();
                LimpiarPantalla();
                CargarHistorialNotasCredito();
                ScriptManager.RegisterStartupScript(this, GetType(), "alert", "alert('Nota de crédito registrada. Revisa la mercadería antes de ajustar existencias.');", true);
            }
            catch (MySqlException ex)
            {
                System.Diagnostics.Trace.TraceError(ex.ToString());
                string mensaje = ex.Number == 1062 ? "Esta venta ya tiene una devolución." : "No se pudo registrar la devolución.";
                ScriptManager.RegisterStartupScript(this, GetType(), "alert", "alert('" + mensaje + "');", true);
            }
        }

        private void CargarHistorialNotasCredito()
        {
            using (MySqlConnection con = new MySqlConnection(connectionString))
            {
                // Consultamos solo los registros que son Notas de Crédito
                string query = @"SELECT v.IdVenta AS IdNotaCredito, '—' AS IdVenta, c.Nombre AS Cliente, v.Fecha, v.Total AS TotalDevuelto 
                                 FROM Venta v 
                                 INNER JOIN Cliente c ON v.IdCliente = c.IdCliente 
                                 WHERE v.TipoDocumento = 'Nota de Credito'
                                 ORDER BY v.IdVenta DESC";
                using (MySqlCommand cmd = new MySqlCommand(query, con))
                {
                    using (MySqlDataAdapter sda = new MySqlDataAdapter(cmd))
                    {
                        DataTable dt = new DataTable();
                        sda.Fill(dt);
                        gvDevoluciones.DataSource = dt;
                        gvDevoluciones.DataBind();
                    }
                }
            }
        }

        private void LimpiarPantalla()
        {
            ddlVentaOrigen.SelectedIndex = 0;
            txtCliente.Text = "";
            txtTotalVenta.Text = "";
            txtMotivo.Text = "";
            ddlTipoDevolucion.SelectedIndex = 0;
        }
    }
}