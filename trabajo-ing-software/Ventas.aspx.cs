using System;
using System.Collections.Generic;
using System.Data;
using System.Web.UI.WebControls;
using MySql.Data.MySqlClient;

namespace trabajo_ing_software
{
    public partial class Ventas : PaginaVentas
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (IsPostBack) return;

            CargarLista(ddlClientes, "SELECT IdCliente AS Id, Nombre FROM cliente ORDER BY Nombre", "Selecciona un cliente");
            CargarLista(ddlBodega, "SELECT IdBodega AS Id, Nombre FROM bodega WHERE Activo=1 ORDER BY Nombre", "Selecciona una bodega");
            CargarProductos();
            InicializarCarrito();

            // Seleccionar primera bodega activa si existe
            if (ddlBodega.Items.Count > 1)
            {
                ddlBodega.SelectedIndex = 1;
            }

            // RF-VEN-02: Cargar cotización si proviene del botón "Convertir a Venta"
            if (!string.IsNullOrEmpty(Request.QueryString["idCotizacion"]) && int.TryParse(Request.QueryString["idCotizacion"], out int idCot))
            {
                CargarDesdeCotizacion(idCot);
            }
        }

        private static void CargarLista(DropDownList lista, string consulta, string opcion)
        {
            lista.DataSource = VentaInventario.Consultar(consulta);
            lista.DataTextField = "Nombre";
            lista.DataValueField = "Id";
            lista.DataBind();
            lista.Items.Insert(0, new ListItem(opcion, ""));
        }

        private void CargarProductos()
        {
            CargarLista(ddlProductos, @"SELECT v.IdVariante AS Id,
                CONCAT(p.Nombre, ' · ', v.NombreVariante, ' (SKU: ', v.Sku, ') · $', v.PrecioVenta) AS Nombre
                FROM varianteproducto v JOIN producto p ON p.IdProducto=v.IdProducto
                WHERE v.Activo=1 AND p.Activo=1 AND v.PrecioVenta>0 ORDER BY p.Nombre, v.Sku", "Selecciona un SKU / Producto");
        }

        private DataTable Carrito => (DataTable)ViewState["Carrito"];

        private void InicializarCarrito()
        {
            var tabla = new DataTable();
            tabla.Columns.Add("IdVariante", typeof(int));
            tabla.Columns.Add("Nombre", typeof(string));
            tabla.Columns.Add("Precio", typeof(decimal));
            tabla.Columns.Add("Cantidad", typeof(int));
            tabla.Columns.Add("Subtotal", typeof(decimal));
            tabla.PrimaryKey = new[] { tabla.Columns["IdVariante"] };
            ViewState["Carrito"] = tabla;
            var token = Guid.NewGuid().ToString("N");
            Session["VentaEnCurso"] = token;
            ViewState["VentaEnCurso"] = token;
            ActualizarCarrito();
        }

        private void CargarDesdeCotizacion(int idCotizacion)
        {
            var dtCot = VentaInventario.Consultar(
                "SELECT IdCotizacion, IdCliente, Total FROM cotizacion WHERE IdCotizacion = @p0", idCotizacion);

            if (dtCot.Rows.Count == 0) return;

            int idCliente = Convert.ToInt32(dtCot.Rows[0]["IdCliente"]);
            if (ddlClientes.Items.FindByValue(idCliente.ToString()) != null)
            {
                ddlClientes.SelectedValue = idCliente.ToString();
                ActualizarInfoCreditoCliente(idCliente);
            }

            var dtDet = VentaInventario.Consultar(
                @"SELECT cd.IdVariante, CONCAT(p.Nombre, ' · ', v.NombreVariante) AS Nombre, 
                         cd.Cantidad, cd.PrecioUnitario, (cd.Cantidad * cd.PrecioUnitario) AS Subtotal
                  FROM cotizaciondetalle cd
                  JOIN varianteproducto v ON cd.IdVariante = v.IdVariante
                  JOIN producto p ON v.IdProducto = p.IdProducto
                  WHERE cd.IdCotizacion = @p0", idCotizacion);

            foreach (DataRow row in dtDet.Rows)
            {
                int varId = Convert.ToInt32(row["IdVariante"]);
                string nombre = row["Nombre"].ToString();
                decimal precio = Convert.ToDecimal(row["PrecioUnitario"]);
                int cant = Convert.ToInt32(row["Cantidad"]);
                Carrito.Rows.Add(varId, nombre, precio, cant, precio * cant);
            }

            ViewState["IdCotizacionOrigen"] = idCotizacion;
            pnlCotizacionInfo.Visible = true;
            lblCotizacionInfo.Text = $"Cotización N° {idCotizacion} (Cliente vinculado, {dtDet.Rows.Count} producto(s) agregados).";
            ActualizarCarrito();
        }

        protected void btnDesvincularCotizacion_Click(object sender, EventArgs e)
        {
            ViewState["IdCotizacionOrigen"] = null;
            pnlCotizacionInfo.Visible = false;
        }

        protected void ddlClientes_SelectedIndexChanged(object sender, EventArgs e)
        {
            if (int.TryParse(ddlClientes.SelectedValue, out int idCliente))
            {
                ActualizarInfoCreditoCliente(idCliente);
            }
            else
            {
                lblInfoCredito.Text = "";
            }
        }

        private void ActualizarInfoCreditoCliente(int idCliente)
        {
            var dt = VentaInventario.Consultar("SELECT * FROM cliente WHERE IdCliente = @p0", idCliente);
            if (dt.Rows.Count == 0) return;

            DataRow r = dt.Rows[0];
            decimal limite = dt.Columns.Contains("LimiteCredito") && r["LimiteCredito"] != DBNull.Value ? Convert.ToDecimal(r["LimiteCredito"]) : 0;
            int dias = dt.Columns.Contains("DiasCredito") && r["DiasCredito"] != DBNull.Value ? Convert.ToInt32(r["DiasCredito"]) : 0;
            int activo = dt.Columns.Contains("Activo") && r["Activo"] != DBNull.Value ? Convert.ToInt32(r["Activo"]) : 1;

            if (activo == 0)
            {
                lblInfoCredito.Text = "<span class='badge-credito-alerta'>⚠️ Cliente Inactivo</span>";
                return;
            }

            // Consultar saldo pendiente en cuentascobrar
            var dtDeuda = VentaInventario.Consultar(
                @"SELECT COALESCE(SUM(cc.MontoPendiente), 0) AS Deuda 
                  FROM cuentascobrar cc 
                  INNER JOIN venta v ON cc.IdVenta = v.IdVenta 
                  WHERE v.IdCliente = @p0 AND cc.EstadoPago <> 'Pagado'", idCliente);

            decimal deuda = Convert.ToDecimal(dtDeuda.Rows[0]["Deuda"]);
            decimal disponible = limite - deuda;

            if (limite > 0)
            {
                string clase = disponible > 0 ? "badge-credito-ok" : "badge-credito-alerta";
                lblInfoCredito.Text = $"<span class='{clase}'>💳 Línea de Crédito: ${limite:N0} | Deuda Vigente: ${deuda:N0} | Disponible: ${disponible:N0} (Plazo habitual: {dias} días)</span>";
                if (ddlPago.SelectedValue == "credito" && string.IsNullOrEmpty(txtVence.Text))
                {
                    txtVence.Text = DateTime.Today.AddDays(dias > 0 ? dias : 30).ToString("yyyy-MM-dd");
                }
            }
            else
            {
                lblInfoCredito.Text = "<span class='text-muted' style='font-size:12px;'>El cliente no registra línea de crédito autorizada ($0). Ventas solo al contado.</span>";
            }
        }

        protected void ddlPago_SelectedIndexChanged(object sender, EventArgs e)
        {
            if (ddlPago.SelectedValue == "credito")
            {
                if (int.TryParse(ddlClientes.SelectedValue, out int idCliente))
                {
                    ActualizarInfoCreditoCliente(idCliente);
                }
            }
        }

        protected void ddlBodega_SelectedIndexChanged(object sender, EventArgs e)
        {
            ConsultarStockTiempoReal();
        }

        protected void ddlProductos_SelectedIndexChanged(object sender, EventArgs e)
        {
            ConsultarStockTiempoReal();
        }

        private int ConsultarStockTiempoReal()
        {
            if (!int.TryParse(ddlBodega.SelectedValue, out int bodega) || !int.TryParse(ddlProductos.SelectedValue, out int variante))
            {
                lblStockDisponible.Text = "Selecciona bodega y producto para ver stock";
                lblStockDisponible.CssClass = "badge-stock";
                return 0;
            }

            var dtStock = VentaInventario.Consultar(
                @"SELECT COALESCE(StockActual, 0) - COALESCE(StockReservado, 0) AS Disponible
                  FROM inventario WHERE IdVariante = @p0 AND IdBodega = @p1", variante, bodega);

            int disponible = 0;
            if (dtStock.Rows.Count > 0)
            {
                disponible = Convert.ToInt32(dtStock.Rows[0]["Disponible"]);
            }

            if (disponible > 0)
            {
                lblStockDisponible.Text = $"✓ Stock disponible en bodega: {disponible} unidad(es)";
                lblStockDisponible.CssClass = "badge-stock";
            }
            else
            {
                lblStockDisponible.Text = "⚠️ Sin stock disponible en esta bodega";
                lblStockDisponible.CssClass = "badge-credito-alerta";
            }
            return disponible;
        }

        protected void btnAgregar_Click(object sender, EventArgs e)
        {
            if (!int.TryParse(ddlProductos.SelectedValue, out int variante)
                || !int.TryParse(txtCantidad.Text, out int cantidad) || cantidad <= 0)
            {
                Mostrar("Selecciona un SKU e ingresa una cantidad mayor que cero.", false);
                return;
            }

            if (!int.TryParse(ddlBodega.SelectedValue, out int bodega))
            {
                Mostrar("Selecciona una bodega de salida para validar existencias.", false);
                return;
            }

            // RF-VEN-04: Validación de stock en tiempo real
            int stockDisponible = ConsultarStockTiempoReal();
            DataRow filaExistente = Carrito.Rows.Find(variante);
            int cantidadPrevia = filaExistente == null ? 0 : (int)filaExistente["Cantidad"];

            if (cantidad + cantidadPrevia > stockDisponible)
            {
                Mostrar($"Stock insuficiente en bodega (RF-VEN-04): Disponible: {stockDisponible}, solicitado: {cantidad + cantidadPrevia}.", false);
                return;
            }

            var datos = VentaInventario.Consultar(@"SELECT CONCAT(p.Nombre, ' · ', v.NombreVariante) AS Nombre, v.PrecioVenta
                FROM varianteproducto v JOIN producto p ON p.IdProducto=v.IdProducto
                WHERE v.IdVariante=@p0 AND v.Activo=1 AND p.Activo=1 AND v.PrecioVenta>0", variante);
            if (datos.Rows.Count != 1)
            {
                Mostrar("El SKU ya no está disponible para venta.", false);
                CargarProductos();
                return;
            }

            var producto = datos.Rows[0];
            decimal precio = Convert.ToDecimal(producto["PrecioVenta"]);
            int total = cantidadPrevia + cantidad;

            if (filaExistente == null)
                Carrito.Rows.Add(variante, producto["Nombre"], precio, total, precio * total);
            else
            {
                filaExistente["Precio"] = precio;
                filaExistente["Cantidad"] = total;
                filaExistente["Subtotal"] = precio * total;
            }

            lblMensajeVenta.Text = "";
            txtCantidad.Text = "1";
            ActualizarCarrito();
            ConsultarStockTiempoReal();
        }

        protected void gvCarrito_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            if (e.CommandName == "Quitar" && int.TryParse(Convert.ToString(e.CommandArgument), out int indice)
                && indice >= 0 && indice < Carrito.Rows.Count)
            {
                Carrito.Rows.RemoveAt(indice);
                ActualizarCarrito();
                ConsultarStockTiempoReal();
            }
        }

        protected void txtDescuento_TextChanged(object sender, EventArgs e)
        {
            ActualizarCarrito();
        }

        private void ActualizarCarrito()
        {
            gvCarrito.DataSource = Carrito;
            gvCarrito.DataBind();

            decimal subtotalBruto = 0;
            foreach (DataRow fila in Carrito.Rows)
                subtotalBruto += Convert.ToDecimal(fila["Subtotal"]);

            decimal.TryParse(txtDescuento.Text.Trim(), out decimal descuento);
            if (descuento < 0) descuento = 0;
            if (descuento > subtotalBruto) descuento = subtotalBruto;

            decimal totalNeto = Math.Round((subtotalBruto - descuento) / 1.19m, 2);
            decimal totalIva = (subtotalBruto - descuento) - totalNeto;
            decimal totalPagar = subtotalBruto - descuento;

            lblSubtotalBruto.Text = "$" + subtotalBruto.ToString("N0");
            lblDescuento.Text = "-$" + descuento.ToString("N0");
            lblNeto.Text = "$" + totalNeto.ToString("N0");
            lblIva.Text = "$" + totalIva.ToString("N0");
            lblTotal.Text = "$" + totalPagar.ToString("N0");
        }

        protected void btnFinalizarVenta_Click(object sender, EventArgs e)
        {
            if (!Equals(ViewState["VentaEnCurso"], Session["VentaEnCurso"]))
            {
                Mostrar("Este carrito ya fue procesado o se abrió otro. Recarga antes de continuar.", false);
                return;
            }

            if (Carrito.Rows.Count == 0 || !int.TryParse(ddlClientes.SelectedValue, out int cliente)
                || !int.TryParse(ddlBodega.SelectedValue, out int bodega))
            {
                Mostrar("Selecciona un cliente, una bodega y al menos un producto en el carrito.", false);
                return;
            }

            var cantidades = new SortedDictionary<int, int>();
            foreach (DataRow fila in Carrito.Rows)
                cantidades.Add((int)fila["IdVariante"], (int)fila["Cantidad"]);

            string tipoDoc = ddlTipoDocumento.SelectedValue;
            string formaPago = ddlPago.SelectedValue;
            decimal.TryParse(txtDescuento.Text.Trim(), out decimal descuento);

            DateTime? vence = null;
            if (formaPago == "credito")
            {
                if (!DateTime.TryParse(txtVence.Text, out DateTime fecha) || fecha.Date < DateTime.Today)
                {
                    Mostrar("Indica una fecha de vencimiento válida para la venta a crédito.", false);
                    return;
                }
                vence = fecha;
            }

            int? idCotizacionOrigen = null;
            if (ViewState["IdCotizacionOrigen"] != null && int.TryParse(ViewState["IdCotizacionOrigen"].ToString(), out int idCot))
            {
                idCotizacionOrigen = idCot;
            }

            try
            {
                long venta;
                using (var conexion = VentaInventario.Abrir())
                using (var transaccion = conexion.BeginTransaction())
                {
                    venta = VentaInventario.Registrar(
                        conexion,
                        transaccion,
                        cliente,
                        UsuarioVenta,
                        bodega,
                        tipoDoc,
                        descuento,
                        formaPago,
                        cantidades,
                        vence,
                        idCotizacionOrigen
                    );
                    transaccion.Commit();
                }

                InicializarCarrito();
                txtDescuento.Text = "0";
                pnlCotizacionInfo.Visible = false;
                ViewState["IdCotizacionOrigen"] = null;

                Mostrar($"¡{tipoDoc} emitida exitosamente bajo N° {venta}! Se aplicó descuento FEFO y la integración contable automática.", true);
            }
            catch (InvalidOperationException ex)
            {
                Mostrar(ex.Message, false);
            }
            catch (MySqlException ex)
            {
                System.Diagnostics.Trace.TraceError(ex.ToString());
                Mostrar("No se pudo registrar la venta: " + ex.Message, false);
            }
        }

        private void Mostrar(string mensaje, bool exito)
        {
            lblMensajeVenta.Text = Server.HtmlEncode(mensaje);
            lblMensajeVenta.CssClass = exito ? "alert alert-success d-block mt-3" : "alert alert-danger d-block mt-3";
        }

        protected void btnIrReporte_Click(object sender, EventArgs e)
        {
            Response.Redirect("ReporteVentas.aspx");
        }
    }
}
