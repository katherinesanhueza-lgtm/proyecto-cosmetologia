using System;
using System.Configuration;
using System.Data;
using System.Web.UI;
using System.Web.UI.WebControls;
using MySql.Data.MySqlClient;

namespace trabajo_ing_software
{
    public partial class DevolucionesProveedor : Page
    {
        private readonly string connectionString = ConfigurationManager.ConnectionStrings["DefaultConnection"] != null
            ? ConfigurationManager.ConnectionStrings["DefaultConnection"].ConnectionString
            : "Server=localhost;Port=3306;Database=ERP_Dermocosmetica;Uid=root;Pwd=;";

        protected bool PuedeEditar
        {
            get
            {
                string rol = Convert.ToString(Session["RolUsuario"]);
                return rol.Equals("Administrador", StringComparison.OrdinalIgnoreCase)
                    || rol.Equals("Comprador", StringComparison.OrdinalIgnoreCase);
            }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["IdUsuario"] == null)
            {
                Response.Redirect("Login.aspx");
                return;
            }

            string rol = Convert.ToString(Session["RolUsuario"]);
            if (!rol.Equals("Administrador", StringComparison.OrdinalIgnoreCase) &&
                !rol.Equals("Comprador", StringComparison.OrdinalIgnoreCase) &&
                !rol.Equals("Contador", StringComparison.OrdinalIgnoreCase))
            {
                ConfiguracionGlobal.RedirigirSegunRol(Response, rol);
                return;
            }

            btnToggleForm.Visible = PuedeEditar;

            if (!IsPostBack)
            {
                lblBienvenida.Text = Convert.ToString(Session["NombreUsuario"]);
                txtFecha.Text = DateTime.Today.ToString("yyyy-MM-dd");
                CargarRecepciones();
                CargarLotesPorRecepcion();
                CargarDevoluciones();
                CalcularKPIs();
            }
        }

        private void CargarRecepciones()
        {
            ddlRecepcion.Items.Clear();
            ddlRecepcion.Items.Add(new ListItem("-- Seleccionar Recepción / OC --", ""));

            string sql = @"SELECT r.IdRecepcion, oc.NumeroOC, IFNULL(r.GuiaDespacho, 'S/G') AS GuiaDespacho, l.RazonSocial
                           FROM RecepcionCompra r
                           INNER JOIN OrdenCompra oc ON oc.IdOC = r.IdOC
                           INNER JOIN Laboratorio l ON l.IdLaboratorio = oc.IdLaboratorio
                           WHERE IFNULL(r.Estado, 'Aprobada') = 'Aprobada'
                           ORDER BY r.FechaRecepcion DESC, r.IdRecepcion DESC";

            using (MySqlConnection con = new MySqlConnection(connectionString))
            using (MySqlCommand cmd = new MySqlCommand(sql, con))
            {
                con.Open();
                using (MySqlDataReader dr = cmd.ExecuteReader())
                {
                    while (dr.Read())
                    {
                        string texto = string.Format("REC-{0:D4} | {1} (Guía {2}) - {3}",
                            Convert.ToInt32(dr["IdRecepcion"]),
                            dr["NumeroOC"],
                            dr["GuiaDespacho"],
                            dr["RazonSocial"]);
                        ddlRecepcion.Items.Add(new ListItem(texto, dr["IdRecepcion"].ToString()));
                    }
                }
            }
        }

        private void CargarLotesPorRecepcion()
        {
            ddlLote.Items.Clear();
            ddlLote.Items.Add(new ListItem("-- Seleccionar Lote --", ""));

            int idRecepcion;
            if (!int.TryParse(ddlRecepcion.SelectedValue, out idRecepcion))
                return;

            string sql = @"SELECT l.IdLote, v.Sku, CONCAT(p.Nombre, ' - ', IFNULL(v.NombreVariante, '')) AS Producto,
                                  l.NumeroLote, IFNULL(l.CantidadDisponible, 0) AS Disponible,
                                  IFNULL(l.CostoUnitario, 0) AS CostoUnitario, l.Estado
                           FROM DetalleRecepcion dr
                           INNER JOIN Lote l ON l.IdVariante = dr.IdVariante
                                AND (dr.NumeroLote IS NULL OR dr.NumeroLote = '' OR l.NumeroLote = dr.NumeroLote)
                           INNER JOIN VarianteProducto v ON v.IdVariante = l.IdVariante
                           INNER JOIN Producto p ON p.IdProducto = v.IdProducto
                           WHERE dr.IdRecepcion = @IdRec
                           GROUP BY l.IdLote, v.Sku, p.Nombre, v.NombreVariante, l.NumeroLote, l.CantidadDisponible, l.CostoUnitario, l.Estado
                           ORDER BY p.Nombre, l.NumeroLote";

            using (MySqlConnection con = new MySqlConnection(connectionString))
            using (MySqlCommand cmd = new MySqlCommand(sql, con))
            {
                cmd.Parameters.AddWithValue("@IdRec", idRecepcion);
                con.Open();
                using (MySqlDataReader dr = cmd.ExecuteReader())
                {
                    while (dr.Read())
                    {
                        string texto = string.Format("[{0}] {1} | Lote: {2} (Disp: {3} u. | Costo: {4:C0})",
                            dr["Sku"],
                            dr["Producto"],
                            dr["NumeroLote"],
                            dr["Disponible"],
                            Convert.ToDecimal(dr["CostoUnitario"]));
                        ddlLote.Items.Add(new ListItem(texto, dr["IdLote"].ToString()));
                    }
                }
            }
        }

        protected void ddlRecepcion_SelectedIndexChanged(object sender, EventArgs e)
        {
            CargarLotesPorRecepcion();
        }

        private void CargarDevoluciones()
        {
            string busqueda = (txtBuscar.Text ?? "").Trim();
            string estado = ddlFiltroEstado.SelectedValue;

            string sql = @"SELECT dp.IdDevolucion, dp.Fecha, dp.IdRecepcion, oc.NumeroOC,
                                  lab.RazonSocial AS Laboratorio, v.Sku,
                                  CONCAT(p.Nombre, ' - ', IFNULL(v.NombreVariante, '')) AS Producto,
                                  l.NumeroLote, dp.Cantidad,
                                  ROUND(dp.Cantidad * IFNULL(l.CostoUnitario, 0), 0) AS MontoReclamado,
                                  IFNULL(dp.Motivo, '') AS Motivo,
                                  IFNULL(dp.Estado, 'Pendiente') AS Estado
                           FROM DevolucionProveedor dp
                           INNER JOIN RecepcionCompra rc ON rc.IdRecepcion = dp.IdRecepcion
                           INNER JOIN OrdenCompra oc ON oc.IdOC = rc.IdOC
                           INNER JOIN Laboratorio lab ON lab.IdLaboratorio = oc.IdLaboratorio
                           INNER JOIN Lote l ON l.IdLote = dp.IdLote
                           INNER JOIN VarianteProducto v ON v.IdVariante = l.IdVariante
                           INNER JOIN Producto p ON p.IdProducto = v.IdProducto
                           WHERE 1=1";

            if (!string.IsNullOrEmpty(busqueda))
            {
                sql += @" AND (oc.NumeroOC LIKE @Busq
                              OR lab.RazonSocial LIKE @Busq
                              OR l.NumeroLote LIKE @Busq
                              OR v.Sku LIKE @Busq
                              OR dp.Motivo LIKE @Busq
                              OR CONCAT('REC-', LPAD(dp.IdRecepcion, 4, '0')) LIKE @Busq
                              OR CONCAT('DEV-', LPAD(dp.IdDevolucion, 4, '0')) LIKE @Busq)";
            }

            if (!string.IsNullOrEmpty(estado))
            {
                sql += " AND dp.Estado = @Estado";
            }

            sql += " ORDER BY dp.Fecha DESC, dp.IdDevolucion DESC";

            using (MySqlConnection con = new MySqlConnection(connectionString))
            using (MySqlCommand cmd = new MySqlCommand(sql, con))
            {
                if (!string.IsNullOrEmpty(busqueda))
                    cmd.Parameters.AddWithValue("@Busq", "%" + busqueda + "%");
                if (!string.IsNullOrEmpty(estado))
                    cmd.Parameters.AddWithValue("@Estado", estado);

                using (MySqlDataAdapter da = new MySqlDataAdapter(cmd))
                {
                    DataTable dt = new DataTable();
                    da.Fill(dt);
                    gvDevoluciones.DataSource = dt;
                    gvDevoluciones.DataBind();
                }
            }
        }

        private void CalcularKPIs()
        {
            string sql = @"SELECT COUNT(*) AS Total,
                                  SUM(CASE WHEN IFNULL(dp.Estado, 'Pendiente') IN ('Pendiente', 'En Revisión') THEN 1 ELSE 0 END) AS Pendientes,
                                  SUM(CASE WHEN dp.Estado = 'Aceptado' THEN 1 ELSE 0 END) AS Aceptados,
                                  IFNULL(SUM(CASE WHEN IFNULL(dp.Estado, 'Pendiente') <> 'Rechazado' THEN dp.Cantidad * IFNULL(l.CostoUnitario, 0) ELSE 0 END), 0) AS MontoTotal
                           FROM DevolucionProveedor dp
                           INNER JOIN Lote l ON l.IdLote = dp.IdLote";

            using (MySqlConnection con = new MySqlConnection(connectionString))
            using (MySqlCommand cmd = new MySqlCommand(sql, con))
            {
                con.Open();
                using (MySqlDataReader dr = cmd.ExecuteReader())
                {
                    if (dr.Read())
                    {
                        lblKpiTotal.Text = dr["Total"].ToString();
                        lblKpiPendientes.Text = dr["Pendientes"] != DBNull.Value ? dr["Pendientes"].ToString() : "0";
                        lblKpiAceptados.Text = dr["Aceptados"] != DBNull.Value ? dr["Aceptados"].ToString() : "0";
                        decimal monto = dr["MontoTotal"] != DBNull.Value ? Convert.ToDecimal(dr["MontoTotal"]) : 0m;
                        lblKpiMonto.Text = string.Format("{0:C0}", monto);
                    }
                }
            }
        }

        protected void btnToggleForm_Click(object sender, EventArgs e)
        {
            if (!PuedeEditar) return;
            pnlFormulario.Visible = !pnlFormulario.Visible;
            lblMensaje.Visible = false;
        }

        protected void btnCancelarForm_Click(object sender, EventArgs e)
        {
            pnlFormulario.Visible = false;
        }

        protected void btnGuardar_Click(object sender, EventArgs e)
        {
            if (!PuedeEditar)
            {
                MostrarMensaje("No tienes permisos para registrar reclamos a proveedor.", false);
                return;
            }

            int idRecepcion, idLote, cantidad;
            DateTime fecha;

            if (!int.TryParse(ddlRecepcion.SelectedValue, out idRecepcion))
            {
                MostrarMensaje("Selecciona una recepción / orden de compra asociada.", false);
                return;
            }

            if (!int.TryParse(ddlLote.SelectedValue, out idLote))
            {
                MostrarMensaje("Selecciona el lote afectado por la no conformidad.", false);
                return;
            }

            if (!int.TryParse(txtCantidad.Text, out cantidad) || cantidad <= 0)
            {
                MostrarMensaje("Ingresa una cantidad válida mayor a 0.", false);
                return;
            }

            if (!DateTime.TryParse(txtFecha.Text, out fecha))
            {
                fecha = DateTime.Today;
            }

            string tipoMotivo = ddlMotivoTipo.SelectedValue;
            string obs = (txtObservaciones.Text ?? "").Trim();
            string motivoFinal = string.IsNullOrEmpty(obs) ? tipoMotivo : string.Format("{0}: {1}", tipoMotivo, obs);
            if (motivoFinal.Length > 200)
                motivoFinal = motivoFinal.Substring(0, 200);

            // Validar cantidad máxima disponible del lote o recibida en esa recepción
            using (MySqlConnection con = new MySqlConnection(connectionString))
            {
                con.Open();
                string sqlVal = @"SELECT IFNULL(CantidadDisponible, 0) FROM Lote WHERE IdLote = @IdLote";
                using (MySqlCommand cmdVal = new MySqlCommand(sqlVal, con))
                {
                    cmdVal.Parameters.AddWithValue("@IdLote", idLote);
                    object res = cmdVal.ExecuteScalar();
                    if (res == null)
                    {
                        MostrarMensaje("El lote seleccionado no existe.", false);
                        return;
                    }
                    int disponible = Convert.ToInt32(res);
                    if (cantidad > disponible)
                    {
                        MostrarMensaje(string.Format("La cantidad a devolver ({0}) supera el stock disponible actual del lote ({1} u.).", cantidad, disponible), false);
                        return;
                    }
                }

                string sqlIns = @"INSERT INTO DevolucionProveedor (IdRecepcion, IdLote, Cantidad, Motivo, Fecha, Estado, IdUsuario)
                                  VALUES (@IdRec, @IdLote, @Cant, @Motivo, @Fecha, 'Pendiente', @IdUsu);
                                  SELECT LAST_INSERT_ID();";
                long nuevoId;
                using (MySqlCommand cmd = new MySqlCommand(sqlIns, con))
                {
                    cmd.Parameters.AddWithValue("@IdRec", idRecepcion);
                    cmd.Parameters.AddWithValue("@IdLote", idLote);
                    cmd.Parameters.AddWithValue("@Cant", cantidad);
                    cmd.Parameters.AddWithValue("@Motivo", motivoFinal);
                    cmd.Parameters.AddWithValue("@Fecha", fecha.Date);
                    cmd.Parameters.AddWithValue("@IdUsu", Convert.ToInt32(Session["IdUsuario"]));
                    nuevoId = Convert.ToInt64(cmd.ExecuteScalar());
                }

                MostrarMensaje(string.Format("Reclamo DEV-{0:D4} registrado correctamente en estado Pendiente.", nuevoId), true);
            }

            txtCantidad.Text = "1";
            txtObservaciones.Text = "";
            pnlFormulario.Visible = false;
            CargarLotesPorRecepcion();
            CargarDevoluciones();
            CalcularKPIs();
        }

        protected void gvDevoluciones_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            int idDev;
            if (!int.TryParse(Convert.ToString(e.CommandArgument), out idDev))
                return;

            if (e.CommandName == "VerDetalle")
            {
                AbrirModalDetalle(idDev);
                return;
            }

            if (!PuedeEditar)
            {
                MostrarMensaje("No tienes permisos para modificar el estado de un reclamo.", false);
                return;
            }

            if (e.CommandName == "Revisar")
            {
                ActualizarEstado(idDev, "En Revisión");
            }
            else if (e.CommandName == "Rechazar")
            {
                ActualizarEstado(idDev, "Rechazado");
            }
            else if (e.CommandName == "Aceptar")
            {
                AceptarDevolucionConInventario(idDev);
            }
        }

        private void ActualizarEstado(int idDev, string nuevoEstado)
        {
            using (MySqlConnection con = new MySqlConnection(connectionString))
            using (MySqlCommand cmd = new MySqlCommand("UPDATE DevolucionProveedor SET Estado = @Estado WHERE IdDevolucion = @Id", con))
            {
                cmd.Parameters.AddWithValue("@Estado", nuevoEstado);
                cmd.Parameters.AddWithValue("@Id", idDev);
                con.Open();
                cmd.ExecuteNonQuery();
            }

            MostrarMensaje(string.Format("Reclamo DEV-{0:D4} actualizado a {1}.", idDev, nuevoEstado), true);
            CargarDevoluciones();
            CalcularKPIs();
        }

        private void AceptarDevolucionConInventario(int idDev)
        {
            int idLote = 0;
            int idBodega = 0;
            int cantidad = 0;
            string motivo = "";
            string estadoActual = "";

            using (MySqlConnection con = new MySqlConnection(connectionString))
            {
                con.Open();
                string sql = @"SELECT dp.IdLote, dp.Cantidad, IFNULL(dp.Motivo, ''), IFNULL(dp.Estado, 'Pendiente'), IFNULL(l.IdBodega, 0)
                               FROM DevolucionProveedor dp
                               INNER JOIN Lote l ON l.IdLote = dp.IdLote
                               WHERE dp.IdDevolucion = @Id";
                using (MySqlCommand cmd = new MySqlCommand(sql, con))
                {
                    cmd.Parameters.AddWithValue("@Id", idDev);
                    using (MySqlDataReader dr = cmd.ExecuteReader())
                    {
                        if (!dr.Read())
                        {
                            MostrarMensaje("No se encontró el reclamo seleccionado.", false);
                            return;
                        }
                        idLote = Convert.ToInt32(dr[0]);
                        cantidad = Convert.ToInt32(dr[1]);
                        motivo = Convert.ToString(dr[2]);
                        estadoActual = Convert.ToString(dr[3]);
                        idBodega = Convert.ToInt32(dr[4]);
                    }
                }
            }

            if (estadoActual != "Pendiente" && estadoActual != "En Revisión")
            {
                MostrarMensaje("Solo se pueden aceptar reclamos en estado Pendiente o En Revisión.", false);
                return;
            }

            try
            {
                if (idBodega > 0)
                {
                    int idUsuario = Convert.ToInt32(Session["IdUsuario"]);
                    string obsMov = string.Format("Devolución a proveedor DEV-{0:D4}: {1}", idDev, motivo);
                    if (obsMov.Length > 255) obsMov = obsMov.Substring(0, 255);
                    InventarioDatos.Mover(idLote, idBodega, idUsuario, "Ajuste negativo", cantidad, obsMov, 0);
                }

                using (MySqlConnection con = new MySqlConnection(connectionString))
                using (MySqlCommand cmd = new MySqlCommand("UPDATE DevolucionProveedor SET Estado = 'Aceptado' WHERE IdDevolucion = @Id", con))
                {
                    cmd.Parameters.AddWithValue("@Id", idDev);
                    con.Open();
                    cmd.ExecuteNonQuery();
                }

                MostrarMensaje(string.Format("Devolución DEV-{0:D4} aceptada. Se descontaron {1} unidades del lote y se registró la salida en Kardex.", idDev, cantidad), true);
            }
            catch (Exception ex)
            {
                MostrarMensaje("No fue posible aceptar la devolución: " + ex.Message, false);
            }

            CargarLotesPorRecepcion();
            CargarDevoluciones();
            CalcularKPIs();
        }

        private void AbrirModalDetalle(int idDev)
        {
            string sql = @"SELECT dp.IdDevolucion, dp.Fecha, IFNULL(dp.Estado, 'Pendiente') AS Estado,
                                  IFNULL(dp.Motivo, '') AS Motivo, dp.Cantidad,
                                  rc.IdRecepcion, IFNULL(rc.GuiaDespacho, 'S/G') AS GuiaDespacho,
                                  oc.NumeroOC, lab.RazonSocial AS Laboratorio,
                                  v.Sku, CONCAT(p.Nombre, ' - ', IFNULL(v.NombreVariante, '')) AS Producto,
                                  l.NumeroLote, l.FechaVencimiento, IFNULL(l.CostoUnitario, 0) AS CostoUnitario,
                                  u.Nombre AS Usuario
                           FROM DevolucionProveedor dp
                           INNER JOIN RecepcionCompra rc ON rc.IdRecepcion = dp.IdRecepcion
                           INNER JOIN OrdenCompra oc ON oc.IdOC = rc.IdOC
                           INNER JOIN Laboratorio lab ON lab.IdLaboratorio = oc.IdLaboratorio
                           INNER JOIN Lote l ON l.IdLote = dp.IdLote
                           INNER JOIN VarianteProducto v ON v.IdVariante = l.IdVariante
                           INNER JOIN Producto p ON p.IdProducto = v.IdProducto
                           INNER JOIN Usuario u ON u.IdUsuario = dp.IdUsuario
                           WHERE dp.IdDevolucion = @Id";

            using (MySqlConnection con = new MySqlConnection(connectionString))
            using (MySqlCommand cmd = new MySqlCommand(sql, con))
            {
                cmd.Parameters.AddWithValue("@Id", idDev);
                con.Open();
                using (MySqlDataReader dr = cmd.ExecuteReader())
                {
                    if (dr.Read())
                    {
                        int cant = Convert.ToInt32(dr["Cantidad"]);
                        decimal costo = Convert.ToDecimal(dr["CostoUnitario"]);
                        lblModalCodigo.Text = string.Format("DEV-{0:D4}", idDev);
                        lblModalLab.Text = dr["Laboratorio"].ToString();
                        lblModalEstado.Text = dr["Estado"].ToString();
                        lblModalOC.Text = dr["NumeroOC"].ToString();
                        lblModalRec.Text = string.Format("REC-{0:D4} (Guía {1})", Convert.ToInt32(dr["IdRecepcion"]), dr["GuiaDespacho"]);
                        lblModalProducto.Text = string.Format("[{0}] {1}", dr["Sku"], dr["Producto"]);
                        string vence = dr["FechaVencimiento"] != DBNull.Value
                            ? Convert.ToDateTime(dr["FechaVencimiento"]).ToString("dd/MM/yyyy")
                            : "S/F";
                        lblModalLote.Text = string.Format("{0} (Vence: {1})", dr["NumeroLote"], vence);
                        lblModalCantidad.Text = string.Format("{0} u.", cant);
                        lblModalMonto.Text = string.Format("{0:C0}", cant * costo);
                        lblModalFecha.Text = Convert.ToDateTime(dr["Fecha"]).ToString("dd/MM/yyyy");
                        lblModalUsuario.Text = dr["Usuario"].ToString();
                        lblModalMotivo.Text = dr["Motivo"].ToString();
                    }
                }
            }

            pnlModalDetalle.Visible = true;
        }

        protected void btnCerrarModal_Click(object sender, EventArgs e)
        {
            pnlModalDetalle.Visible = false;
        }

        protected void Filtro_Changed(object sender, EventArgs e)
        {
            CargarDevoluciones();
        }

        protected void btnLimpiarFiltros_Click(object sender, EventArgs e)
        {
            txtBuscar.Text = "";
            ddlFiltroEstado.SelectedIndex = 0;
            CargarDevoluciones();
        }

        protected string GetClaseEstado(object estadoObj)
        {
            string estado = Convert.ToString(estadoObj).ToLowerInvariant();
            if (estado.Contains("revisi")) return "badge-dev-revision";
            if (estado.Contains("acept")) return "badge-dev-aceptado";
            if (estado.Contains("rechaz")) return "badge-dev-rechazado";
            return "badge-dev-pendiente";
        }

        private void MostrarMensaje(string msg, bool exito)
        {
            lblMensaje.Text = msg;
            lblMensaje.Visible = true;
            lblMensaje.Style["background-color"] = exito ? "#E8F8F0" : "#FDEDEC";
            lblMensaje.Style["color"] = exito ? "#1E8449" : "#922B21";
            lblMensaje.Style["border"] = exito ? "1px solid #A9DFBF" : "1px solid #F5B7B1";
        }

        protected void btnLogout_Click(object sender, EventArgs e)
        {
            Session.Clear();
            Session.Abandon();
            Response.Redirect("Login.aspx");
        }
    }
}
