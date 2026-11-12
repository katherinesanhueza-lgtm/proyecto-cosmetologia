using System;
using System.Configuration;
using System.Data;
using System.Globalization;
using System.Web.UI;
using System.Web.UI.WebControls;
using MySql.Data.MySqlClient;

namespace trabajo_ing_software
{
    public partial class CotizacionesImportacion : Page
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
                InicializarTablaDetalle();
                CargarLaboratorios();
                CargarProductos();
                CargarCotizaciones();
                CalcularKPIs();
                ActualizarTipoCambioSegunMoneda(ddlMoneda.SelectedValue, false);
            }
        }

        #region Estructura Temporal de Ítems
        private void InicializarTablaDetalle()
        {
            DataTable dt = new DataTable();
            dt.Columns.Add("IdVariante", typeof(int));
            dt.Columns.Add("Sku", typeof(string));
            dt.Columns.Add("Producto", typeof(string));
            dt.Columns.Add("Cantidad", typeof(int));
            dt.Columns.Add("CostoUnitario", typeof(decimal));
            dt.Columns.Add("SubtotalOrigen", typeof(decimal));
            ViewState["DetalleCotizacion"] = dt;
            gvDetalleCot.DataSource = dt;
            gvDetalleCot.DataBind();
        }

        private DataTable ObtenerTablaDetalle()
        {
            if (ViewState["DetalleCotizacion"] == null) InicializarTablaDetalle();
            return (DataTable)ViewState["DetalleCotizacion"];
        }
        #endregion

        #region Catálogos
        private void CargarLaboratorios()
        {
            ddlLaboratorio.Items.Clear();
            ddlLaboratorio.Items.Add(new ListItem("-- Seleccionar Laboratorio --", ""));
            using (MySqlConnection con = new MySqlConnection(connectionString))
            using (MySqlCommand cmd = new MySqlCommand("SELECT IdLaboratorio, RazonSocial, Pais FROM Laboratorio WHERE Activo = 1 ORDER BY RazonSocial", con))
            {
                con.Open();
                using (MySqlDataReader dr = cmd.ExecuteReader())
                {
                    while (dr.Read())
                    {
                        ddlLaboratorio.Items.Add(new ListItem($"{dr["RazonSocial"]} ({dr["Pais"]})", dr["IdLaboratorio"].ToString()));
                    }
                }
            }
        }

        private void CargarProductos()
        {
            ddlProducto.Items.Clear();
            ddlProducto.Items.Add(new ListItem("-- Seleccionar Producto / Variante --", ""));
            string sql = @"SELECT v.IdVariante, v.Sku, p.Nombre AS Producto, v.NombreVariante
                           FROM VarianteProducto v
                           INNER JOIN Producto p ON v.IdProducto = p.IdProducto
                           WHERE v.Activo = 1 AND p.Activo = 1
                           ORDER BY p.Nombre, v.NombreVariante";
            using (MySqlConnection con = new MySqlConnection(connectionString))
            using (MySqlCommand cmd = new MySqlCommand(sql, con))
            {
                con.Open();
                using (MySqlDataReader dr = cmd.ExecuteReader())
                {
                    while (dr.Read())
                    {
                        ddlProducto.Items.Add(new ListItem($"[{dr["Sku"]}] {dr["Producto"]} - {dr["NombreVariante"]}", dr["IdVariante"].ToString()));
                    }
                }
            }
        }
        #endregion

        #region Eventos de Formulario
        protected void ddlLaboratorio_SelectedIndexChanged(object sender, EventArgs e)
        {
            if (string.IsNullOrEmpty(ddlLaboratorio.SelectedValue))
            {
                lblInfoLab.Text = "Seleccione un proveedor";
                return;
            }
            using (MySqlConnection con = new MySqlConnection(connectionString))
            using (MySqlCommand cmd = new MySqlCommand("SELECT Pais, DiasPago, Contacto FROM Laboratorio WHERE IdLaboratorio = @Id", con))
            {
                cmd.Parameters.AddWithValue("@Id", Convert.ToInt32(ddlLaboratorio.SelectedValue));
                con.Open();
                using (MySqlDataReader dr = cmd.ExecuteReader())
                {
                    if (dr.Read())
                        lblInfoLab.Text = $"Origen: {dr["Pais"]} | Crédito: {dr["DiasPago"]} días | Contacto: {dr["Contacto"]}";
                }
            }
        }

        protected void ddlMoneda_SelectedIndexChanged(object sender, EventArgs e)
        {
            ActualizarTipoCambioSegunMoneda(ddlMoneda.SelectedValue, false);
            RecalcularTotales();
        }

        protected void btnActualizarTC_Click(object sender, EventArgs e)
        {
            ActualizarTipoCambioSegunMoneda(ddlMoneda.SelectedValue, true);
            RecalcularTotales();
            MostrarMensaje($"Tipo de cambio de {ddlMoneda.SelectedValue} actualizado en vivo exitosamente.", true);
        }

        private void ActualizarTipoCambioSegunMoneda(string moneda, bool forzar = false)
        {
            if (string.Equals(moneda, "CLP", StringComparison.OrdinalIgnoreCase))
            {
                txtTipoCambio.Text = "1";
                lblInfoTipoCambio.Text = "Moneda local (1 CLP)";
                lblInfoTipoCambio.ForeColor = System.Drawing.ColorTranslator.FromHtml("#6c757d");
                btnActualizarTC.Visible = false;
                return;
            }

            btnActualizarTC.Visible = true;
            var info = ConfiguracionGlobal.ObtenerTipoCambio(moneda, forzar);
            txtTipoCambio.Text = info.Tasa.ToString("0.##", CultureInfo.InvariantCulture);

            if (info.FueEnVivo)
            {
                lblInfoTipoCambio.Text = $"🟢 Sincronizado hoy ({info.FechaDesc}) · Editable";
                lblInfoTipoCambio.ForeColor = System.Drawing.ColorTranslator.FromHtml("#1E8449");
            }
            else
            {
                lblInfoTipoCambio.Text = $"🟢 Al día ({info.FechaDesc}) · Editable";
                lblInfoTipoCambio.ForeColor = System.Drawing.ColorTranslator.FromHtml("#27AE60");
            }
        }

        protected void ddlProducto_SelectedIndexChanged(object sender, EventArgs e)
        {
            if (string.IsNullOrEmpty(ddlProducto.SelectedValue)) return;

            using (MySqlConnection con = new MySqlConnection(connectionString))
            using (MySqlCommand cmd = new MySqlCommand("SELECT IFNULL(CostoPromedio, 0) FROM VarianteProducto WHERE IdVariante = @Id", con))
            {
                cmd.Parameters.AddWithValue("@Id", Convert.ToInt32(ddlProducto.SelectedValue));
                con.Open();
                decimal costoClp = Convert.ToDecimal(cmd.ExecuteScalar());
                decimal tc = ParseDecimalSeguro(txtTipoCambio.Text, 1m);
                decimal sugerido = tc > 0 ? Math.Round(costoClp / tc, 2) : costoClp;
                txtCostoMoneda.Text = sugerido.ToString("0.00", CultureInfo.InvariantCulture);
            }
        }

        protected void btnAgregarItem_Click(object sender, EventArgs e)
        {
            if (string.IsNullOrEmpty(ddlProducto.SelectedValue))
            {
                MostrarMensaje("Seleccione un producto del catálogo.", false);
                return;
            }
            if (!int.TryParse(txtCantidad.Text, out int cantidad) || cantidad <= 0)
            {
                MostrarMensaje("Ingrese una cantidad válida mayor a 0.", false);
                return;
            }
            decimal costo = ParseDecimalSeguro(txtCostoMoneda.Text, -1m);
            if (costo <= 0)
            {
                MostrarMensaje("Ingrese un costo unitario válido mayor a 0.", false);
                return;
            }

            int idVar = Convert.ToInt32(ddlProducto.SelectedValue);
            string sku = "";
            string prodNombre = "";

            using (MySqlConnection con = new MySqlConnection(connectionString))
            using (MySqlCommand cmd = new MySqlCommand("SELECT v.Sku, CONCAT(p.Nombre, ' - ', IFNULL(v.NombreVariante, '')) AS Nombre FROM VarianteProducto v INNER JOIN Producto p ON p.IdProducto = v.IdProducto WHERE v.IdVariante = @Id", con))
            {
                cmd.Parameters.AddWithValue("@Id", idVar);
                con.Open();
                using (MySqlDataReader dr = cmd.ExecuteReader())
                {
                    if (dr.Read())
                    {
                        sku = dr["Sku"].ToString();
                        prodNombre = dr["Nombre"].ToString();
                    }
                }
            }

            DataTable dt = ObtenerTablaDetalle();
            DataRow fila = dt.NewRow();
            fila["IdVariante"] = idVar;
            fila["Sku"] = sku;
            fila["Producto"] = prodNombre;
            fila["Cantidad"] = cantidad;
            fila["CostoUnitario"] = costo;
            fila["SubtotalOrigen"] = cantidad * costo;
            dt.Rows.Add(fila);

            ViewState["DetalleCotizacion"] = dt;
            gvDetalleCot.DataSource = dt;
            gvDetalleCot.DataBind();
            RecalcularTotales();
        }

        protected void gvDetalleCot_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            if (e.CommandName == "QuitarItem")
            {
                int idx = Convert.ToInt32(e.CommandArgument);
                DataTable dt = ObtenerTablaDetalle();
                if (idx >= 0 && idx < dt.Rows.Count)
                {
                    dt.Rows.RemoveAt(idx);
                    ViewState["DetalleCotizacion"] = dt;
                    gvDetalleCot.DataSource = dt;
                    gvDetalleCot.DataBind();
                    RecalcularTotales();
                }
            }
        }

        private void RecalcularTotales()
        {
            DataTable dt = ObtenerTablaDetalle();
            decimal totalOrigen = 0;
            foreach (DataRow r in dt.Rows)
                totalOrigen += Convert.ToDecimal(r["SubtotalOrigen"]);

            decimal tc = ParseDecimalSeguro(txtTipoCambio.Text, 1m);
            decimal totalClp = Math.Round(totalOrigen * tc, 0);

            lblTotalMoneda.Text = totalOrigen.ToString("N2");
            lblMonedaResumen.Text = ddlMoneda.SelectedValue;
            lblTotalClp.Text = totalClp.ToString("C0");
        }
        #endregion

        #region Guardar Cotización y Convertir a OC
        protected void btnGuardarCot_Click(object sender, EventArgs e)
        {
            if (!PuedeEditar) return;

            if (string.IsNullOrEmpty(ddlLaboratorio.SelectedValue))
            {
                MostrarMensaje("Debe seleccionar un laboratorio.", false);
                return;
            }
            DataTable dt = ObtenerTablaDetalle();
            if (dt.Rows.Count == 0)
            {
                MostrarMensaje("Agregue al menos un producto a la cotización.", false);
                return;
            }
            if (!DateTime.TryParse(txtFecha.Text, out DateTime fecha))
            {
                MostrarMensaje("Ingrese una fecha válida.", false);
                return;
            }
            decimal tc = ParseDecimalSeguro(txtTipoCambio.Text, 0m);
            if (tc <= 0)
            {
                MostrarMensaje("Ingrese un tipo de cambio válido mayor a 0.", false);
                return;
            }

            int idLab = Convert.ToInt32(ddlLaboratorio.SelectedValue);
            int idUsuario = Convert.ToInt32(Session["IdUsuario"]);
            string moneda = ddlMoneda.SelectedValue;

            using (MySqlConnection con = new MySqlConnection(connectionString))
            {
                con.Open();
                using (MySqlTransaction trans = con.BeginTransaction())
                {
                    try
                    {
                        string sqlCab = @"INSERT INTO CotizacionImportacion (IdLaboratorio, Fecha, Moneda, TipoCambio, Estado, IdUsuario)
                                          VALUES (@IdLab, @Fecha, @Moneda, @TC, 'Solicitada', @IdUsuario);
                                          SELECT LAST_INSERT_ID();";
                        int idCot;
                        using (MySqlCommand cmd = new MySqlCommand(sqlCab, con, trans))
                        {
                            cmd.Parameters.AddWithValue("@IdLab", idLab);
                            cmd.Parameters.AddWithValue("@Fecha", fecha);
                            cmd.Parameters.AddWithValue("@Moneda", moneda);
                            cmd.Parameters.AddWithValue("@TC", tc);
                            cmd.Parameters.AddWithValue("@IdUsuario", idUsuario);
                            idCot = Convert.ToInt32(cmd.ExecuteScalar());
                        }

                        string sqlDet = @"INSERT INTO DetalleCotizacion (IdCotizacion, IdVariante, Cantidad, CostoUnitario)
                                          VALUES (@IdCot, @IdVar, @Cant, @Costo)";
                        foreach (DataRow r in dt.Rows)
                        {
                            using (MySqlCommand cmdDet = new MySqlCommand(sqlDet, con, trans))
                            {
                                cmdDet.Parameters.AddWithValue("@IdCot", idCot);
                                cmdDet.Parameters.AddWithValue("@IdVar", Convert.ToInt32(r["IdVariante"]));
                                cmdDet.Parameters.AddWithValue("@Cant", Convert.ToInt32(r["Cantidad"]));
                                cmdDet.Parameters.AddWithValue("@Costo", Convert.ToDecimal(r["CostoUnitario"]));
                                cmdDet.ExecuteNonQuery();
                            }
                        }

                        trans.Commit();
                        LimpiarFormulario();
                        pnlFormulario.Visible = false;
                        MostrarMensaje($"Cotización COT-{idCot:D4} registrada en {moneda} correctamente.", true);
                        CargarCotizaciones();
                        CalcularKPIs();
                    }
                    catch (Exception ex)
                    {
                        trans.Rollback();
                        MostrarMensaje("Error al guardar cotización: " + ex.Message, false);
                    }
                }
            }
        }

        private void ConvertirACompra(int idCot)
        {
            if (!PuedeEditar) return;
            int idUsuario = Convert.ToInt32(Session["IdUsuario"]);

            using (MySqlConnection con = new MySqlConnection(connectionString))
            {
                con.Open();
                using (MySqlTransaction trans = con.BeginTransaction())
                {
                    try
                    {
                        int idLab = 0;
                        decimal tc = 1m;
                        int diasPago = 30;
                        string estado = "";

                        string sqlCab = @"SELECT c.IdLaboratorio, c.TipoCambio, c.Estado, IFNULL(l.DiasPago, 30) AS DiasPago
                                          FROM CotizacionImportacion c
                                          INNER JOIN Laboratorio l ON l.IdLaboratorio = c.IdLaboratorio
                                          WHERE c.IdCotizacion = @Id FOR UPDATE";
                        using (MySqlCommand cmd = new MySqlCommand(sqlCab, con, trans))
                        {
                            cmd.Parameters.AddWithValue("@Id", idCot);
                            using (MySqlDataReader dr = cmd.ExecuteReader())
                            {
                                if (!dr.Read()) throw new InvalidOperationException("Cotización no encontrada.");
                                idLab = Convert.ToInt32(dr["IdLaboratorio"]);
                                tc = Convert.ToDecimal(dr["TipoCambio"]);
                                estado = dr["Estado"].ToString();
                                diasPago = Convert.ToInt32(dr["DiasPago"]);
                            }
                        }

                        if (estado != "Aprobada")
                        {
                            MostrarMensaje("Solo se pueden convertir cotizaciones en estado Aprobada.", false);
                            trans.Rollback();
                            return;
                        }

                        DataTable dtItems = new DataTable();
                        using (MySqlDataAdapter da = new MySqlDataAdapter("SELECT IdVariante, Cantidad, CostoUnitario FROM DetalleCotizacion WHERE IdCotizacion = @Id", con))
                        {
                            da.SelectCommand.Transaction = trans;
                            da.SelectCommand.Parameters.AddWithValue("@Id", idCot);
                            da.Fill(dtItems);
                        }

                        if (dtItems.Rows.Count == 0) throw new InvalidOperationException("La cotización no tiene productos.");

                        decimal netoClp = 0;
                        foreach (DataRow r in dtItems.Rows)
                        {
                            netoClp += Math.Round(Convert.ToInt32(r["Cantidad"]) * Convert.ToDecimal(r["CostoUnitario"]) * tc, 0);
                        }
                        decimal ivaClp = Math.Round(netoClp * ConfiguracionGlobal.TasaIva, 0);
                        decimal totalClp = netoClp + ivaClp;

                        int sigId = 1;
                        using (MySqlCommand cmdMax = new MySqlCommand("SELECT IFNULL(MAX(IdOC), 0) + 1 FROM OrdenCompra", con, trans))
                            sigId = Convert.ToInt32(cmdMax.ExecuteScalar());

                        string numOC = $"OC-{DateTime.Today.Year}-{sigId:D4}";

                        string sqlOC = @"INSERT INTO OrdenCompra (NumeroOC, IdLaboratorio, IdCotizacion, Fecha, FechaEsperada, Estado, Neto, Iva, Total, IdUsuario)
                                         VALUES (@NumOC, @IdLab, @IdCot, @Fecha, @FechaEsp, 'Borrador', @Neto, @Iva, @Total, @IdUsuario);
                                         SELECT LAST_INSERT_ID();";
                        int idOC;
                        using (MySqlCommand cmdOC = new MySqlCommand(sqlOC, con, trans))
                        {
                            cmdOC.Parameters.AddWithValue("@NumOC", numOC);
                            cmdOC.Parameters.AddWithValue("@IdLab", idLab);
                            cmdOC.Parameters.AddWithValue("@IdCot", idCot);
                            cmdOC.Parameters.AddWithValue("@Fecha", DateTime.Today);
                            cmdOC.Parameters.AddWithValue("@FechaEsp", DateTime.Today.AddDays(diasPago));
                            cmdOC.Parameters.AddWithValue("@Neto", netoClp);
                            cmdOC.Parameters.AddWithValue("@Iva", ivaClp);
                            cmdOC.Parameters.AddWithValue("@Total", totalClp);
                            cmdOC.Parameters.AddWithValue("@IdUsuario", idUsuario);
                            idOC = Convert.ToInt32(cmdOC.ExecuteScalar());
                        }

                        foreach (DataRow r in dtItems.Rows)
                        {
                            decimal costoClp = Math.Round(Convert.ToDecimal(r["CostoUnitario"]) * tc, 2);
                            using (MySqlCommand cmdDetOC = new MySqlCommand("INSERT INTO DetalleOrdenCompra (IdOC, IdVariante, CantidadPedida, CantidadRecibida, CostoUnitario) VALUES (@IdOC, @IdVar, @Cant, 0, @Costo)", con, trans))
                            {
                                cmdDetOC.Parameters.AddWithValue("@IdOC", idOC);
                                cmdDetOC.Parameters.AddWithValue("@IdVar", Convert.ToInt32(r["IdVariante"]));
                                cmdDetOC.Parameters.AddWithValue("@Cant", Convert.ToInt32(r["Cantidad"]));
                                cmdDetOC.Parameters.AddWithValue("@Costo", costoClp);
                                cmdDetOC.ExecuteNonQuery();
                            }
                        }

                        using (MySqlCommand cmdUpd = new MySqlCommand("UPDATE CotizacionImportacion SET Estado = 'Convertida' WHERE IdCotizacion = @Id", con, trans))
                        {
                            cmdUpd.Parameters.AddWithValue("@Id", idCot);
                            cmdUpd.ExecuteNonQuery();
                        }

                        trans.Commit();
                        MostrarMensaje($"Orden de Compra {numOC} generada en Borrador por {totalClp:C0} CLP desde COT-{idCot:D4}.", true);
                        CargarCotizaciones();
                        CalcularKPIs();
                    }
                    catch (Exception ex)
                    {
                        trans.Rollback();
                        MostrarMensaje("Error al convertir cotización a OC: " + ex.Message, false);
                    }
                }
            }
        }
        #endregion

        #region Grilla, KPIs y Modal
        private void CargarCotizaciones()
        {
            string sql = @"SELECT c.IdCotizacion, l.RazonSocial, c.Fecha, c.Moneda, c.TipoCambio, c.Estado,
                                  IFNULL(SUM(d.Cantidad * d.CostoUnitario), 0) AS TotalOrigen,
                                  ROUND(IFNULL(SUM(d.Cantidad * d.CostoUnitario), 0) * c.TipoCambio, 0) AS TotalClp
                           FROM CotizacionImportacion c
                           INNER JOIN Laboratorio l ON l.IdLaboratorio = c.IdLaboratorio
                           LEFT JOIN DetalleCotizacion d ON d.IdCotizacion = c.IdCotizacion
                           WHERE 1=1";

            string filtro = txtBuscar.Text.Trim();
            if (!string.IsNullOrEmpty(filtro))
                sql += " AND (l.RazonSocial LIKE @Filtro OR c.Moneda LIKE @Filtro)";

            if (!string.IsNullOrEmpty(ddlFiltroEstado.SelectedValue))
                sql += " AND c.Estado = @Estado";

            sql += " GROUP BY c.IdCotizacion, l.RazonSocial, c.Fecha, c.Moneda, c.TipoCambio, c.Estado ORDER BY c.IdCotizacion DESC";

            using (MySqlConnection con = new MySqlConnection(connectionString))
            using (MySqlCommand cmd = new MySqlCommand(sql, con))
            {
                if (!string.IsNullOrEmpty(filtro)) cmd.Parameters.AddWithValue("@Filtro", "%" + filtro + "%");
                if (!string.IsNullOrEmpty(ddlFiltroEstado.SelectedValue)) cmd.Parameters.AddWithValue("@Estado", ddlFiltroEstado.SelectedValue);

                using (MySqlDataAdapter da = new MySqlDataAdapter(cmd))
                {
                    DataTable dt = new DataTable();
                    da.Fill(dt);
                    gvCotizaciones.DataSource = dt;
                    gvCotizaciones.DataBind();
                }
            }
        }

        private void CalcularKPIs()
        {
            string sql = @"SELECT 
                            COUNT(*) AS Total,
                            SUM(CASE WHEN Estado = 'Solicitada' THEN 1 ELSE 0 END) AS Solicitadas,
                            SUM(CASE WHEN Estado = 'Aprobada' THEN 1 ELSE 0 END) AS Aprobadas,
                            IFNULL((SELECT SUM(d.Cantidad * d.CostoUnitario * c2.TipoCambio)
                                    FROM CotizacionImportacion c2
                                    INNER JOIN DetalleCotizacion d ON d.IdCotizacion = c2.IdCotizacion
                                    WHERE c2.Estado IN ('Solicitada', 'Aprobada')), 0) AS MontoClp
                           FROM CotizacionImportacion";

            using (MySqlConnection con = new MySqlConnection(connectionString))
            using (MySqlCommand cmd = new MySqlCommand(sql, con))
            {
                con.Open();
                using (MySqlDataReader dr = cmd.ExecuteReader())
                {
                    if (dr.Read())
                    {
                        lblKpiTotal.Text = dr["Total"].ToString();
                        lblKpiSolicitadas.Text = dr["Solicitadas"] != DBNull.Value ? dr["Solicitadas"].ToString() : "0";
                        lblKpiAprobadas.Text = dr["Aprobadas"] != DBNull.Value ? dr["Aprobadas"].ToString() : "0";
                        decimal monto = dr["MontoClp"] != DBNull.Value ? Convert.ToDecimal(dr["MontoClp"]) : 0m;
                        lblKpiMontoClp.Text = Math.Round(monto, 0).ToString("C0");
                    }
                }
            }
        }

        protected void gvCotizaciones_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            int idCot = Convert.ToInt32(e.CommandArgument);
            if (e.CommandName == "VerDetalle")
            {
                AbrirModalDetalle(idCot);
            }
            else if (e.CommandName == "AprobarCot" && PuedeEditar)
            {
                CambiarEstadoCotizacion(idCot, "Aprobada");
            }
            else if (e.CommandName == "RechazarCot" && PuedeEditar)
            {
                CambiarEstadoCotizacion(idCot, "Rechazada");
            }
            else if (e.CommandName == "ConvertirOC" && PuedeEditar)
            {
                ConvertirACompra(idCot);
            }
        }

        private void CambiarEstadoCotizacion(int idCot, string nuevoEstado)
        {
            using (MySqlConnection con = new MySqlConnection(connectionString))
            using (MySqlCommand cmd = new MySqlCommand("UPDATE CotizacionImportacion SET Estado = @Estado WHERE IdCotizacion = @Id", con))
            {
                cmd.Parameters.AddWithValue("@Estado", nuevoEstado);
                cmd.Parameters.AddWithValue("@Id", idCot);
                con.Open();
                cmd.ExecuteNonQuery();
            }
            MostrarMensaje($"Cotización COT-{idCot:D4} actualizada a {nuevoEstado}.", true);
            CargarCotizaciones();
            CalcularKPIs();
        }

        private void AbrirModalDetalle(int idCot)
        {
            using (MySqlConnection con = new MySqlConnection(connectionString))
            {
                con.Open();
                decimal tc = 1m;
                string moneda = "USD";

                string sqlCab = "SELECT c.*, l.RazonSocial FROM CotizacionImportacion c INNER JOIN Laboratorio l ON l.IdLaboratorio = c.IdLaboratorio WHERE c.IdCotizacion = @Id";
                using (MySqlCommand cmd = new MySqlCommand(sqlCab, con))
                {
                    cmd.Parameters.AddWithValue("@Id", idCot);
                    using (MySqlDataReader dr = cmd.ExecuteReader())
                    {
                        if (dr.Read())
                        {
                            lblModalId.Text = $"COT-{idCot:D4}";
                            lblModalLab.Text = dr["RazonSocial"].ToString();
                            lblModalFecha.Text = Convert.ToDateTime(dr["Fecha"]).ToString("dd/MM/yyyy");
                            moneda = dr["Moneda"].ToString();
                            tc = Convert.ToDecimal(dr["TipoCambio"]);
                            lblModalMoneda.Text = moneda;
                            lblModalTC.Text = tc.ToString("N2");
                            lblModalEstado.Text = dr["Estado"].ToString();
                        }
                    }
                }

                string sqlDet = @"SELECT v.Sku, CONCAT(p.Nombre, ' - ', IFNULL(v.NombreVariante, '')) AS Producto,
                                         d.Cantidad, d.CostoUnitario, (d.Cantidad * d.CostoUnitario) AS SubtotalOrigen
                                  FROM DetalleCotizacion d
                                  INNER JOIN VarianteProducto v ON v.IdVariante = d.IdVariante
                                  INNER JOIN Producto p ON p.IdProducto = v.IdProducto
                                  WHERE d.IdCotizacion = @Id";
                using (MySqlDataAdapter da = new MySqlDataAdapter(sqlDet, con))
                {
                    da.SelectCommand.Parameters.AddWithValue("@Id", idCot);
                    DataTable dt = new DataTable();
                    da.Fill(dt);
                    gvModalItems.DataSource = dt;
                    gvModalItems.DataBind();

                    decimal sum = 0;
                    foreach (DataRow r in dt.Rows) sum += Convert.ToDecimal(r["SubtotalOrigen"]);
                    lblModalTotalMoneda.Text = $"{sum:N2} {moneda}";
                    lblModalTotalClp.Text = Math.Round(sum * tc, 0).ToString("C0");
                }
            }
            pnlModalDetalle.Visible = true;
        }
        #endregion

        #region Utilidades y Botones
        private decimal ParseDecimalSeguro(string texto, decimal fallback)
        {
            string limpio = (texto ?? "").Trim().Replace(",", ".");
            return decimal.TryParse(limpio, NumberStyles.Any, CultureInfo.InvariantCulture, out decimal res) ? res : fallback;
        }

        private void MostrarMensaje(string msg, bool exito)
        {
            lblMensaje.Text = msg;
            lblMensaje.Visible = true;
            lblMensaje.Style["background-color"] = exito ? "#E8F8F0" : "#FDEDEC";
            lblMensaje.Style["color"] = exito ? "#1E8449" : "#922B21";
            lblMensaje.Style["border"] = exito ? "1px solid #A9DFBF" : "1px solid #F5B7B1";
        }

        private void LimpiarFormulario()
        {
            ddlLaboratorio.SelectedIndex = 0;
            lblInfoLab.Text = "Seleccione un proveedor";
            txtFecha.Text = DateTime.Today.ToString("yyyy-MM-dd");
            ddlMoneda.SelectedValue = "USD";
            ActualizarTipoCambioSegunMoneda("USD", false);
            ddlProducto.SelectedIndex = 0;
            txtCantidad.Text = "10";
            txtCostoMoneda.Text = "";
            InicializarTablaDetalle();
            RecalcularTotales();
        }

        protected void btnToggleForm_Click(object sender, EventArgs e)
        {
            pnlFormulario.Visible = !pnlFormulario.Visible;
            lblMensaje.Visible = false;
            if (pnlFormulario.Visible)
            {
                ActualizarTipoCambioSegunMoneda(ddlMoneda.SelectedValue, false);
            }
        }

        protected void btnCerrarForm_Click(object sender, EventArgs e) => pnlFormulario.Visible = false;
        protected void btnCerrarModal_Click(object sender, EventArgs e) => pnlModalDetalle.Visible = false;
        protected void Filtros_Changed(object sender, EventArgs e) => CargarCotizaciones();

        protected void btnLimpiarFiltros_Click(object sender, EventArgs e)
        {
            txtBuscar.Text = "";
            ddlFiltroEstado.SelectedIndex = 0;
            CargarCotizaciones();
        }

        protected void btnLogout_Click(object sender, EventArgs e)
        {
            Session.Clear();
            Session.Abandon();
            Response.Redirect("Login.aspx");
        }
        #endregion
    }
}