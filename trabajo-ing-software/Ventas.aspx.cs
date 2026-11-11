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
            CargarLista(ddlClientes, "SELECT IdCliente AS Id,Nombre FROM cliente ORDER BY Nombre", "Selecciona un cliente");
            CargarLista(ddlBodega, "SELECT IdBodega AS Id,Nombre FROM bodega WHERE Activo=1 ORDER BY Nombre", "Selecciona una bodega");
            CargarProductos();
            InicializarCarrito();
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
                CONCAT(p.Nombre,' · ',v.Sku,' · $',v.PrecioVenta) AS Nombre
                FROM varianteproducto v JOIN producto p ON p.IdProducto=v.IdProducto
                WHERE v.Activo=1 AND p.Activo=1 AND v.PrecioVenta>0 ORDER BY p.Nombre,v.Sku", "Selecciona un SKU");
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

        protected void btnAgregar_Click(object sender, EventArgs e)
        {
            if (!int.TryParse(ddlProductos.SelectedValue, out int variante)
                || !int.TryParse(txtCantidad.Text, out int cantidad) || cantidad <= 0)
            {
                Mostrar("Selecciona un SKU e ingresa una cantidad mayor que cero.", false);
                return;
            }

            var datos = VentaInventario.Consultar(@"SELECT CONCAT(p.Nombre,' · ',v.Sku) AS Nombre,v.PrecioVenta
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
            DataRow fila = Carrito.Rows.Find(variante);
            int anterior = fila == null ? 0 : (int)fila["Cantidad"];
            if (cantidad > int.MaxValue - anterior)
            {
                Mostrar("La cantidad supera el máximo permitido.", false);
                return;
            }

            int total = anterior + cantidad;
            if (fila == null) Carrito.Rows.Add(variante, producto["Nombre"], precio, total, precio * total);
            else
            {
                fila["Precio"] = precio;
                fila["Cantidad"] = total;
                fila["Subtotal"] = precio * total;
            }
            lblMensajeVenta.Text = "";
            ActualizarCarrito();
        }

        protected void gvCarrito_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            if (e.CommandName == "Quitar" && int.TryParse(Convert.ToString(e.CommandArgument), out int indice)
                && indice >= 0 && indice < Carrito.Rows.Count)
            {
                Carrito.Rows.RemoveAt(indice);
                ActualizarCarrito();
            }
        }

        private void ActualizarCarrito()
        {
            gvCarrito.DataSource = Carrito;
            gvCarrito.DataBind();
            decimal total = 0;
            foreach (DataRow fila in Carrito.Rows) total += (decimal)fila["Subtotal"];
            lblTotal.Text = "$" + total.ToString("N2");
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
                Mostrar("Selecciona un cliente, una bodega y al menos un producto.", false);
                return;
            }

            var cantidades = new SortedDictionary<int, int>();
            foreach (DataRow fila in Carrito.Rows)
                cantidades.Add((int)fila["IdVariante"], (int)fila["Cantidad"]);

            DateTime? vence = null;
            if (ddlPago.SelectedValue == "credito")
            {
                if (!DateTime.TryParseExact(txtVence.Text, "yyyy-MM-dd", System.Globalization.CultureInfo.InvariantCulture,
                    System.Globalization.DateTimeStyles.None, out DateTime fecha) || fecha.Date < DateTime.Today)
                {
                    Mostrar("Indica una fecha de vencimiento válida para la venta a crédito.", false);
                    return;
                }
                vence = fecha;
            }

            try
            {
                long venta;
                using (var conexion = VentaInventario.Abrir())
                using (var transaccion = conexion.BeginTransaction())
                {
                    venta = VentaInventario.Registrar(conexion, transaccion, cliente, UsuarioVenta, bodega, cantidades, vence);
                    transaccion.Commit();
                }
                InicializarCarrito();
                Mostrar("Venta #" + venta + " registrada. Se actualizaron las existencias de la bodega.", true);
            }
            catch (InvalidOperationException ex)
            {
                Mostrar(ex.Message, false);
            }
            catch (MySqlException ex)
            {
                System.Diagnostics.Trace.TraceError(ex.ToString());
                Mostrar("No se pudo registrar la venta. Revisa los datos y vuelve a intentarlo.", false);
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
