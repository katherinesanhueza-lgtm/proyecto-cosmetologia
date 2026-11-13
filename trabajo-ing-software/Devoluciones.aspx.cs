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
            using (MySqlConnection con = new MySqlConnection(connectionString))
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
            using (MySqlConnection con = new MySqlConnection(connectionString))
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
                string queryItems = @"SELECT vd.IdVariante, 
                                             CONCAT(p.Nombre, ' · ', v.NombreVariante, ' (SKU: ', v.Sku, ')') AS Producto,
                                             vd.Cantidad AS CantidadOriginal, 
                                             vd.PrecioUnitario,
                                             vd.Cantidad AS CantidadDevolver
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
                    }
                }
            }
        }

        protected void ddlTipoDevolucion_SelectedIndexChanged(object sender, EventArgs e)
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

            // Calcular ítems y montos devueltos
            decimal totalDevuelto = 0;
            var itemsADevolver = new System.Collections.Generic.List<Tuple<int, int, decimal>>();

            foreach (GridViewRow row in gvItemsVenta.Rows)
            {
                HiddenField hfIdVariante = (HiddenField)row.FindControl("hfIdVariante");
                HiddenField hfPrecioUnitario = (HiddenField)row.FindControl("hfPrecioUnitario");
                HiddenField hfCantOriginal = (HiddenField)row.FindControl("hfCantOriginal");
                TextBox txtCantDevolver = (TextBox)row.FindControl("txtCantDevolver");

                if (hfIdVariante != null && txtCantDevolver != null && int.TryParse(txtCantDevolver.Text.Trim(), out int cantDev) && cantDev > 0)
                {
                    int idVariante = Convert.ToInt32(hfIdVariante.Value);
                    decimal precioUnit = Convert.ToDecimal(hfPrecioUnitario.Value);
                    int cantOrig = Convert.ToInt32(hfCantOriginal.Value);

                    if (cantDev > cantOrig)
                    {
                        MostrarMensaje($"No puedes devolver {cantDev} unidades de un producto cuando solo se compraron {cantOrig}.", false);
                        return;
                    }

                    totalDevuelto += cantDev * precioUnit;
                    itemsADevolver.Add(new Tuple<int, int, decimal>(idVariante, cantDev, precioUnit));
                }
            }

            if (itemsADevolver.Count == 0 || totalDevuelto <= 0)
            {
                MostrarMensaje("Debe indicar al menos una unidad a devolver en los productos.", false);
                return;
            }

            decimal netoDevuelto = Math.Round(totalDevuelto / 1.19m, 2);
            decimal ivaDevuelto = totalDevuelto - netoDevuelto;

            using (var con = VentaInventario.Abrir())
            using (var tr = con.BeginTransaction())
            {
                try
                {
                    // 1. Generar Folio para Nota de Crédito (RF-VEN-09)
                    string folioNC;
                    using (var cmdF = VentaInventario.Comando(con, tr, "SELECT COUNT(IdVenta) + 5001 FROM venta WHERE TipoDocumento = 'Nota de Credito'"))
                    {
                        long correlativo = Convert.ToInt64(cmdF.ExecuteScalar() ?? 5001);
                        folioNC = $"NC-{correlativo:D6}";
                    }

                    // 2. Insertar cabecera Nota de Crédito
                    long idNotaCredito;
                    string sqlNC = @"INSERT INTO venta 
                        (TipoDocumento, Folio, Fecha, Neto, Iva, Descuento, Total, FormaPago, IdCliente, IdUsuario, IdVentaOrigen) 
                        VALUES ('Nota de Credito', @p0, CURDATE(), @p1, @p2, 0, @p3, 'Devolucion', @p4, @p5, @p6)";

                    using (var cmdNC = VentaInventario.Comando(con, tr, sqlNC,
                        folioNC, netoDevuelto, ivaDevuelto, totalDevuelto, idCliente, UsuarioVenta, idVentaOrigen))
                    {
                        cmdNC.ExecuteNonQuery();
                        idNotaCredito = cmdNC.LastInsertedId;
                    }

                    // 3. Insertar detalle devuelto y reingreso opcional a inventario (RF-VEN-09)
                    foreach (var item in itemsADevolver)
                    {
                        using (var cmdDet = VentaInventario.Comando(con, tr,
                            @"INSERT INTO ventadetalle (IdVenta, IdVariante, Cantidad, PrecioUnitario, Subtotal) 
                              VALUES (@p0, @p1, @p2, @p3, @p4)",
                            idNotaCredito, item.Item1, item.Item2, item.Item3, item.Item2 * item.Item3))
                        {
                            cmdDet.ExecuteNonQuery();
                        }

                        if (reingresarStock && bodegaReingreso > 0)
                        {
                            // Incrementar existencias en la bodega elegida
                            using (var cmdInv = VentaInventario.Comando(con, tr,
                                @"UPDATE inventario 
                                  SET StockActual = StockActual + @p0, FechaActualizada = NOW() 
                                  WHERE IdVariante = @p1 AND IdBodega = @p2",
                                item.Item2, item.Item1, bodegaReingreso))
                            {
                                cmdInv.ExecuteNonQuery();
                            }

                            // Incrementar stock total en variante
                            using (var cmdVar = VentaInventario.Comando(con, tr,
                                @"UPDATE varianteproducto 
                                  SET StockTotal = StockTotal + @p0 
                                  WHERE IdVariante = @p1", item.Item2, item.Item1))
                            {
                                cmdVar.ExecuteNonQuery();
                            }

                            // Registrar movimiento de inventario de entrada por devolución
                            using (var cmdMov = VentaInventario.Comando(con, tr,
                                @"INSERT INTO movimientoinventario 
                                  (IdBodega, IdTipoMovimiento, IdUsuario, Cantidad, StockAnterior, StockPosterior, Referencia, Observacion, Origen, IdDetalleOrigen) 
                                  SELECT @p0, IdTipoMovimiento, @p1, @p2, 0, @p2, @p3, @p4, 'Devolucion', @p5
                                  FROM tipomovimiento WHERE Nombre IN ('Entrada', 'Ajuste positivo') LIMIT 1",
                                bodegaReingreso, UsuarioVenta, item.Item2, folioNC, txtMotivo.Text.Trim(), idNotaCredito))
                            {
                                cmdMov.ExecuteNonQuery();
                            }
                        }
                    }

                    // 4. Si la venta original tenía saldo pendiente en cuentascobrar, rebajarlo
                    using (var cmdCc = VentaInventario.Comando(con, tr,
                        @"UPDATE cuentascobrar 
                          SET MontoPendiente = GREATEST(0, MontoPendiente - @p0),
                              EstadoPago = IF(MontoPendiente - @p0 <= 0, 'Pagado', EstadoPago) 
                          WHERE IdVenta = @p1", totalDevuelto, idVentaOrigen))
                    {
                        cmdCc.ExecuteNonQuery();
                    }

                    tr.Commit();

                    CargarVentasDisponibles();
                    LimpiarPantalla();
                    CargarHistorialNotasCredito();
                    string mensajeStock = reingresarStock ? "Se reingresó la mercadería devuelta a la bodega." : "No se reingresó mercadería a inventario.";
                    MostrarMensaje($"¡Nota de Crédito {folioNC} registrada exitosamente por ${totalDevuelto:N0}! {mensajeStock}", true);
                }
                catch (Exception ex)
                {
                    tr.Rollback();
                    MostrarMensaje("Error al generar nota de crédito: " + ex.Message, false);
                }
            }
        }

        private void CargarHistorialNotasCredito()
        {
            using (MySqlConnection con = new MySqlConnection(connectionString))
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
