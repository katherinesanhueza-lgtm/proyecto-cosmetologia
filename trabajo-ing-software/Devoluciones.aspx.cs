using MySql.Data.MySqlClient;
using System;
using System.Configuration;
using System.Data;
using System.Web.UI.WebControls;

namespace trabajo_ing_software
{
    public partial class Devoluciones : PaginaVentas
    {
        private string connectionString = ConfigurationManager.ConnectionStrings["DefaultConnection"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            ddlVentaOrigen.SelectedIndexChanged += new EventHandler(ddlVentaOrigen_SelectedIndexChanged);

            if (!IsPostBack)
            {
                CargarVentasDisponibles();
                CargarBodegas();
                CargarHistorialNotasCredito();
            }
        }

        private void CargarBodegas()
        {
            ddlBodegaReingreso.DataSource = VentaInventario.Consultar("SELECT IdBodega, Nombre FROM bodega WHERE Activo = 1 ORDER BY Nombre");
            ddlBodegaReingreso.DataTextField = "Nombre";
            ddlBodegaReingreso.DataValueField = "IdBodega";
            ddlBodegaReingreso.DataBind();
        }

        private void CargarVentasDisponibles()
        {
            using (MySqlConnection con = ConexionErp.Crear(connectionString))
            {
                string query = @"SELECT IdVenta, 
                                 CONCAT(TipoDocumento, ' #', COALESCE(Folio, IdVenta), ' · Fecha: ', DATE_FORMAT(Fecha, '%d/%m/%Y'), ' · Total: $', FORMAT(Total, 0)) AS Descripcion
                                 FROM venta 
                                 WHERE TipoDocumento <> 'Nota de Credito' 
                                 ORDER BY IdVenta DESC LIMIT 60";

                using (MySqlCommand cmd = new MySqlCommand(query, con))
                {
                    con.Open();
                    using (MySqlDataReader sdr = cmd.ExecuteReader())
                    {
                        ddlVentaOrigen.DataSource = sdr;
                        ddlVentaOrigen.DataTextField = "Descripcion";
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
                CargarDetalleVenta(Convert.ToInt32(ddlVentaOrigen.SelectedValue));
            }
            else
            {
                txtCliente.Text = "";
                txtTotalVenta.Text = "";
                gvItemsVenta.DataSource = null;
                gvItemsVenta.DataBind();
            }
        }

        private void CargarDetalleVenta(int idVenta)
        {
            using (MySqlConnection con = ConexionErp.Crear(connectionString))
            {
                string queryCab = @"SELECT c.IdCliente, c.Nombre, v.Total 
                                    FROM venta v 
                                    INNER JOIN cliente c ON v.IdCliente = c.IdCliente 
                                    WHERE v.IdVenta = @id";

                using (MySqlCommand cmd = new MySqlCommand(queryCab, con))
                {
                    cmd.Parameters.AddWithValue("@id", idVenta);
                    con.Open();
                    using (MySqlDataReader sdr = cmd.ExecuteReader())
                    {
                        if (sdr.Read())
                        {
                            txtCliente.Text = sdr["Nombre"].ToString();
                            txtTotalVenta.Text = Convert.ToDecimal(sdr["Total"]).ToString("N0");
                            ViewState["IdClienteAfectado"] = sdr["IdCliente"].ToString();
                        }
                    }
                }

                // Cargar ítems comprados en esa venta
                string queryItems = @"SELECT vd.IdVentaDetalle,vd.IdVariante, 
                                             CONCAT(p.Nombre, ' · ', v.NombreVariante, ' (SKU: ', v.Sku, ')') AS Producto,
                                             GREATEST(0,vd.Cantidad-COALESCE((SELECT SUM(dd.Cantidad) FROM devolucionlineaventa l JOIN ventadetalle dd ON dd.IdVentaDetalle=l.IdDetalleNC WHERE l.IdDetalleOriginal=vd.IdVentaDetalle),0)) AS CantidadOriginal, 
                                             vd.PrecioUnitario,
                                             GREATEST(0,vd.Cantidad-COALESCE((SELECT SUM(dd.Cantidad) FROM devolucionlineaventa l JOIN ventadetalle dd ON dd.IdVentaDetalle=l.IdDetalleNC WHERE l.IdDetalleOriginal=vd.IdVentaDetalle),0)) AS CantidadDevolver
                                      FROM ventadetalle vd
                                      INNER JOIN varianteproducto v ON vd.IdVariante = v.IdVariante
                                      INNER JOIN producto p ON v.IdProducto = p.IdProducto
                                      WHERE vd.IdVenta = @id";

                using (MySqlCommand cmdItems = new MySqlCommand(queryItems, con))
                {
                    cmdItems.Parameters.AddWithValue("@id", idVenta);
                    using (MySqlDataAdapter sda = new MySqlDataAdapter(cmdItems))
                    {
                        DataTable dtItems = new DataTable();
                        sda.Fill(dtItems);
                        gvItemsVenta.DataSource = dtItems;
                        gvItemsVenta.DataBind();
                        AplicarModoDevolucion();
                    }
                }
            }
        }

        protected void ddlTipoDevolucion_SelectedIndexChanged(object sender, EventArgs e)
        {
            AplicarModoDevolucion();
        }

        private void AplicarModoDevolucion()
        {
            bool esTotal = ddlTipoDevolucion.SelectedValue == "Total";
            foreach (GridViewRow row in gvItemsVenta.Rows)
            {
                HiddenField hfCantOriginal = (HiddenField)row.FindControl("hfCantOriginal");
                TextBox txtCantDevolver = (TextBox)row.FindControl("txtCantDevolver");

                if (hfCantOriginal != null && txtCantDevolver != null)
                {
                    if (esTotal)
                    {
                        txtCantDevolver.Text = hfCantOriginal.Value;
                        txtCantDevolver.ReadOnly = true;
                    }
                    else
                    {
                        txtCantDevolver.ReadOnly = false;
                    }
                }
            }
        }

        protected void chkReingresoInventario_CheckedChanged(object sender, EventArgs e)
        {
            secBodegaReingreso.Visible = chkReingresoInventario.Checked;
        }

        protected void btnGuardarDevolucion_Click(object sender, EventArgs e)
        {
            ExigirEscrituraVentas();
            if (ddlVentaOrigen.SelectedValue == "" || string.IsNullOrEmpty(txtCliente.Text))
            {
                MostrarMensaje("Seleccione una venta válida primero.", false);
                return;
            }

            if (string.IsNullOrEmpty(txtMotivo.Text.Trim()))
            {
                MostrarMensaje("Debe especificar el motivo de la devolución.", false);
                return;
            }

            if (!int.TryParse(ddlVentaOrigen.SelectedValue, out int idVentaOrigen)) return;
            int idCliente = Convert.ToInt32(ViewState["IdClienteAfectado"]);
            bool reingresarStock = chkReingresoInventario.Checked;
            int.TryParse(ddlBodegaReingreso.SelectedValue, out int bodegaReingreso);

            var articulos = new Newtonsoft.Json.Linq.JArray();
            foreach (GridViewRow row in gvItemsVenta.Rows)
            {
                var texto = (TextBox)row.FindControl("txtCantDevolver");
                if (!int.TryParse(texto.Text,out int cantidad) || cantidad<0) { MostrarMensaje("Revisa las cantidades.",false); return; }
                if (cantidad>0) articulos.Add(new Newtonsoft.Json.Linq.JObject {
                    ["detalle"]=Convert.ToInt32(gvItemsVenta.DataKeys[row.RowIndex].Value),["cantidad"]=cantidad });
            }
            if (articulos.Count==0 || (reingresarStock && bodegaReingreso<=0)) { MostrarMensaje("Revisa los productos y la bodega de reingreso.",false); return; }
            string folio;
            try
            {
                using(var con=VentaInventario.Abrir())
                using(var tx=con.BeginTransaction())
                {
                    folio=VentaInventario.NuevoFolio(con,tx,"Nota de Credito","NC",5000);
                    using(var cmd=VentaInventario.Comando(con,tx,"CALL usp_DevolverVenta(@p0,@p1,@p2,@p3,@p4,@p5)",
                        idVentaOrigen,UsuarioVenta,folio,reingresarStock?(object)bodegaReingreso:DBNull.Value,txtMotivo.Text.Trim(),articulos.ToString()))
                        cmd.ExecuteNonQuery();
                    tx.Commit();
                }
            }
            catch(MySqlException ex) { MostrarMensaje(ConexionErp.MensajeError(ex),false);return; }
            CargarVentasDisponibles();
            LimpiarPantalla();
            CargarHistorialNotasCredito();
            MostrarMensaje("Nota de crédito registrada: "+folio,true);
        }

        private void CargarHistorialNotasCredito()
        {
            using (MySqlConnection con = ConexionErp.Crear(connectionString))
            {
                string query = @"SELECT v.IdVenta AS IdNotaCredito, 
                                        COALESCE(v.Folio, CONCAT('NC-', v.IdVenta)) AS Folio,
                                        CONCAT('Venta #', v.IdVentaOrigen) AS VentaRef, 
                                        c.Nombre AS Cliente, 
                                        v.Fecha, 
                                        v.Total AS TotalDevuelto 
                                 FROM venta v 
                                 INNER JOIN cliente c ON v.IdCliente = c.IdCliente 
                                 WHERE v.TipoDocumento = 'Nota de Credito'
                                 ORDER BY v.IdVenta DESC";

                using (MySqlCommand cmd = new MySqlCommand(query, con))
                using (MySqlDataAdapter sda = new MySqlDataAdapter(cmd))
                {
                    DataTable dt = new DataTable();
                    sda.Fill(dt);
                    gvDevoluciones.DataSource = dt;
                    gvDevoluciones.DataBind();
                }
            }
        }

        private void MostrarMensaje(string texto, bool exito)
        {
            lblMensajeDevolucion.Text = texto;
            lblMensajeDevolucion.ForeColor = exito ? System.Drawing.Color.Green : System.Drawing.Color.Red;
        }

        private void LimpiarPantalla()
        {
            ddlVentaOrigen.SelectedIndex = 0;
            txtCliente.Text = "";
            txtTotalVenta.Text = "";
            txtMotivo.Text = "";
            ddlTipoDevolucion.SelectedIndex = 0;
            gvItemsVenta.DataSource = null;
            gvItemsVenta.DataBind();
        }
    }
}
