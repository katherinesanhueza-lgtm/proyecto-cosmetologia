using System;
using System.Data;
using System.Configuration;
using MySql.Data.MySqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace trabajo_ing_software
{
    public partial class Recepciones : System.Web.UI.Page
    {
        private string connectionString = ConfigurationManager.ConnectionStrings["DefaultConnection"] != null ? ConfigurationManager.ConnectionStrings["DefaultConnection"].ConnectionString : "Server=localhost;Port=3306;Database=ERP_Dermocosmetica;Uid=root;Pwd=;";

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["IdUsuario"] == null)
            {
                Response.Redirect("Login.aspx");
                return;
            }

            // Control de acceso RBAC: Solo Administrador y Bodeguero
            string rolUsuario = Session["RolUsuario"] != null ? Session["RolUsuario"].ToString() : "";
            if (!rolUsuario.Equals("Administrador", StringComparison.OrdinalIgnoreCase) && 
                !rolUsuario.Equals("Bodeguero", StringComparison.OrdinalIgnoreCase))
            {
                ConfiguracionGlobal.RedirigirSegunRol(Response, rolUsuario);
                return;
            }

            if (!IsPostBack)
            {
                lblBienvenida.Text = Session["NombreUsuario"] != null ? Session["NombreUsuario"].ToString() : "Usuario";
                txtFechaRecepcion.Text = DateTime.Today.ToString("yyyy-MM-dd");

                CargarOrdenesCompraPendientes();
                CargarBodegas();
                CargarLaboratoriosFiltro();
                CargarRecepciones();
                CalcularKPIs();
                if (int.TryParse(Request.QueryString["orden"], out int orden)
                    && ddlOrdenCompra.Items.FindByValue(orden.ToString()) != null)
                {
                    ddlOrdenCompra.SelectedValue = orden.ToString();
                    pnlFormularioRec.Visible = true;
                    CargarDetalleOrdenParaRecepcion(orden);
                }
            }
        }

        #region Carga de Datos y Selectores
        private void CargarBodegas()
        {
            using (var conexion = new MySqlConnection(connectionString))
            using (var adaptador = new MySqlDataAdapter("SELECT IdBodega, Nombre FROM bodega WHERE Activo=1 ORDER BY Nombre", conexion))
            {
                var bodegas = new DataTable();
                adaptador.Fill(bodegas);
                ddlBodega.DataSource = bodegas;
                ddlBodega.DataTextField = "Nombre";
                ddlBodega.DataValueField = "IdBodega";
                ddlBodega.DataBind();
                ddlBodega.Items.Insert(0, new ListItem("Selecciona una bodega", ""));
            }
        }

        private void CargarLaboratoriosFiltro()
        {
            ddlFiltroLaboratorio.Items.Clear();
            ddlFiltroLaboratorio.Items.Add(new ListItem("Todos los Laboratorios", ""));

            string query = "SELECT IdLaboratorio, RazonSocial FROM Laboratorio WHERE Activo = 1 ORDER BY RazonSocial ASC";
            using (MySqlConnection con = new MySqlConnection(connectionString))
            {
                using (MySqlCommand cmd = new MySqlCommand(query, con))
                {
                    con.Open();
                    using (MySqlDataReader dr = cmd.ExecuteReader())
                    {
                        while (dr.Read())
                        {
                            ddlFiltroLaboratorio.Items.Add(new ListItem(dr["RazonSocial"].ToString(), dr["IdLaboratorio"].ToString()));
                        }
                    }
                }
            }
        }

        private void CargarOrdenesCompraPendientes()
        {
            ddlOrdenCompra.Items.Clear();
            ddlOrdenCompra.Items.Add(new ListItem("-- Seleccione una Orden de Compra Pendiente --", ""));

            string query = @"SELECT oc.IdOC, oc.NumeroOC, l.RazonSocial, oc.Estado
                             FROM OrdenCompra oc
                             INNER JOIN Laboratorio l ON oc.IdLaboratorio = l.IdLaboratorio
                             WHERE oc.Estado IN ('Emitida', 'Parcial')
                             ORDER BY oc.IdOC DESC";

            using (MySqlConnection con = new MySqlConnection(connectionString))
            {
                using (MySqlCommand cmd = new MySqlCommand(query, con))
                {
                    con.Open();
                    using (MySqlDataReader dr = cmd.ExecuteReader())
                    {
                        while (dr.Read())
                        {
                            string texto = string.Format("{0} - {1} ({2})", dr["NumeroOC"], dr["RazonSocial"], dr["Estado"]);
                            ddlOrdenCompra.Items.Add(new ListItem(texto, dr["IdOC"].ToString()));
                        }
                    }
                }
            }
        }

        protected void ddlOrdenCompra_SelectedIndexChanged(object sender, EventArgs e)
        {
            if (!string.IsNullOrEmpty(ddlOrdenCompra.SelectedValue))
            {
                int idOC = Convert.ToInt32(ddlOrdenCompra.SelectedValue);
                CargarDetalleOrdenParaRecepcion(idOC);
            }
            else
            {
                pnlInfoOC.Visible = false;
                gvItemsRecepcion.DataSource = null;
                gvItemsRecepcion.DataBind();
            }
        }

        private void CargarDetalleOrdenParaRecepcion(int idOC)
        {
            // 1. Cargar Cabecera de la OC
            string queryCab = @"SELECT oc.NumeroOC, l.RazonSocial, l.Rut, oc.Fecha, oc.Estado, oc.Total
                                FROM OrdenCompra oc
                                INNER JOIN Laboratorio l ON oc.IdLaboratorio = l.IdLaboratorio
                                WHERE oc.IdOC = @IdOC";

            using (MySqlConnection con = new MySqlConnection(connectionString))
            {
                using (MySqlCommand cmd = new MySqlCommand(queryCab, con))
                {
                    cmd.Parameters.AddWithValue("@IdOC", idOC);
                    con.Open();
                    using (MySqlDataReader dr = cmd.ExecuteReader())
                    {
                        if (dr.Read())
                        {
                            lblInfoLaboratorio.Text = dr["RazonSocial"].ToString();
                            lblInfoRut.Text = dr["Rut"].ToString();
                            lblInfoFechaOC.Text = Convert.ToDateTime(dr["Fecha"]).ToString("dd/MM/yyyy");
                            lblInfoEstadoOC.Text = dr["Estado"].ToString();
                            lblInfoTotalOC.Text = string.Format("{0:C0}", dr["Total"]);
                            pnlInfoOC.Visible = true;
                        }
                    }
                }
            }

            // 2. Cargar Líneas de Productos Pendientes
            string queryItems = @"SELECT doc.IdDetalleOC, doc.IdVariante, v.Sku, p.Nombre AS Producto, v.NombreVariante,
                                         doc.CantidadPedida,
                                         IFNULL(doc.CantidadRecibida, 0) AS CantidadRecibida,
                                         (doc.CantidadPedida - IFNULL(doc.CantidadRecibida, 0)) AS CantidadPendiente,
                                         doc.CostoUnitario,
                                         CONCAT('LOT-', v.Sku, '-', YEAR(NOW())) AS SugerenciaLote,
                                         DATE_FORMAT(DATE_ADD(NOW(), INTERVAL 2 YEAR), '%Y-%m-%d') AS SugerenciaVencimiento
                                  FROM DetalleOrdenCompra doc
                                  INNER JOIN VarianteProducto v ON doc.IdVariante = v.IdVariante
                                  INNER JOIN Producto p ON v.IdProducto = p.IdProducto
                                  WHERE doc.IdOC = @IdOC AND (doc.CantidadPedida - IFNULL(doc.CantidadRecibida, 0)) > 0";

            using (MySqlConnection con = new MySqlConnection(connectionString))
            {
                using (MySqlCommand cmd = new MySqlCommand(queryItems, con))
                {
                    cmd.Parameters.AddWithValue("@IdOC", idOC);
                    using (MySqlDataAdapter da = new MySqlDataAdapter(cmd))
                    {
                        DataTable dt = new DataTable();
                        da.Fill(dt);
                        gvItemsRecepcion.DataSource = dt;
                        gvItemsRecepcion.DataBind();
                    }
                }
            }
        }
        #endregion

        #region Registro de Recepción y Asignación de Lotes (Transaccional)
        protected void btnAprobarRecepcion_Click(object sender, EventArgs e)
        {
            if (!int.TryParse(ddlBodega.SelectedValue, out int idBodega) || idBodega <= 0)
            {
                MostrarMensaje("Selecciona la bodega que recibirá los productos.", false);
                return;
            }
            if (string.IsNullOrEmpty(ddlOrdenCompra.SelectedValue))
            {
                MostrarMensaje("Debe seleccionar una orden de compra para recepcionar.", false);
                return;
            }

            string guia = txtGuiaDespacho.Text.Trim();
            if (string.IsNullOrEmpty(guia))
            {
                MostrarMensaje("Debe ingresar el número de Guía de Despacho o Factura del proveedor (RF-COM-05).", false);
                return;
            }

            DateTime fechaRec;
            if (!DateTime.TryParse(txtFechaRecepcion.Text, out fechaRec))
            {
                MostrarMensaje("Ingrese una fecha de recepción válida.", false);
                return;
            }

            // Validar filas de la grilla
            int totalItemsRecibiendo = 0;
            foreach (GridViewRow row in gvItemsRecepcion.Rows)
            {
                TextBox txtCant = (TextBox)row.FindControl("txtCantRecibir");
                TextBox txtLote = (TextBox)row.FindControl("txtNumeroLote");
                TextBox txtVenc = (TextBox)row.FindControl("txtFechaVencimiento");
                HiddenField hfPend = (HiddenField)row.FindControl("hfCantidadPendiente");

                int cant;
                int.TryParse(txtCant.Text, out cant);

                if (cant > 0)
                {
                    int pend = Convert.ToInt32(hfPend.Value);
                    if (cant > pend)
                    {
                        MostrarMensaje("La cantidad a recibir no puede superar las unidades pendientes de la orden.", false);
                        return;
                    }

                    if (string.IsNullOrWhiteSpace(txtLote.Text))
                    {
                        MostrarMensaje("Debe asignar un número de lote para cada producto que ingrese (RF-COM-06).", false);
                        return;
                    }

                    DateTime fechaVenc;
                    if (!DateTime.TryParse(txtVenc.Text, out fechaVenc))
                    {
                        MostrarMensaje("Debe indicar una fecha de vencimiento válida para los lotes ingresados.", false);
                        return;
                    }

                    if (fechaVenc <= DateTime.Today)
                    {
                        MostrarMensaje("Política FEFO: La fecha de vencimiento del lote debe ser posterior al día de hoy.", false);
                        return;
                    }

                    totalItemsRecibiendo += cant;
                }
            }

            if (totalItemsRecibiendo <= 0)
            {
                MostrarMensaje("Debe ingresar una cantidad mayor a 0 en al menos un producto de la orden.", false);
                return;
            }

            int idOC = Convert.ToInt32(ddlOrdenCompra.SelectedValue);
            int idUsuario = Convert.ToInt32(Session["IdUsuario"]);

            // EJECUCION TRANSACCIONAL ACID
            using (MySqlConnection con = new MySqlConnection(connectionString))
            {
                con.Open();
                using (MySqlTransaction trans = con.BeginTransaction())
                {
                    try
                    {
                        using (var orden = new MySqlCommand(
                            "SELECT IdOC FROM ordencompra WHERE IdOC=@id AND Estado IN ('Emitida','Parcial') FOR UPDATE", con, trans))
                        {
                            orden.Parameters.AddWithValue("@id", idOC);
                            if (orden.ExecuteScalar() == null)
                                throw new InvalidOperationException("La orden ya no admite recepciones.");
                        }

                        // 1. Insertar Cabecera en RecepcionCompra
                        string queryRec = @"INSERT INTO RecepcionCompra (IdOC, GuiaDespacho, FechaRecepcion, Estado, IdUsuario)
                                            VALUES (@IdOC, @Guia, @Fecha, 'Completa', @IdUsuario);
                                            SELECT LAST_INSERT_ID();";

                        int idRecepcion = 0;
                        using (MySqlCommand cmd = new MySqlCommand(queryRec, con, trans))
                        {
                            cmd.Parameters.AddWithValue("@IdOC", idOC);
                            cmd.Parameters.AddWithValue("@Guia", guia);
                            cmd.Parameters.AddWithValue("@Fecha", fechaRec);
                            cmd.Parameters.AddWithValue("@IdUsuario", idUsuario);
                            idRecepcion = Convert.ToInt32(cmd.ExecuteScalar());
                        }

                        // 2. Procesar cada fila de producto
                        foreach (GridViewRow row in gvItemsRecepcion.Rows)
                        {
                            TextBox txtCant = (TextBox)row.FindControl("txtCantRecibir");
                            TextBox txtLote = (TextBox)row.FindControl("txtNumeroLote");
                            TextBox txtVenc = (TextBox)row.FindControl("txtFechaVencimiento");
                            HiddenField hfDetalleOC = (HiddenField)row.FindControl("hfIdDetalleOC");
                            HiddenField hfVariante = (HiddenField)row.FindControl("hfIdVariante");
                            HiddenField hfCosto = (HiddenField)row.FindControl("hfCostoUnitario");

                            int cant = Convert.ToInt32(txtCant.Text);
                            if (cant > 0)
                            {
                                int idDetalleOC = Convert.ToInt32(hfDetalleOC.Value);
                                int idVar = Convert.ToInt32(hfVariante.Value);
                                decimal costo = Convert.ToDecimal(hfCosto.Value);
                                string numLote = txtLote.Text.Trim();
                                DateTime fechaVenc = Convert.ToDateTime(txtVenc.Text);

                                // A. DetalleRecepcion
                                string queryDetRec = @"INSERT INTO DetalleRecepcion (IdRecepcion, IdDetalleOC, IdVariante, NumeroLote, FechaVencimiento, Cantidad, CostoUnitario)
                                                       VALUES (@IdRec, @IdDetOC, @IdVar, @NumLote, @Venc, @Cant, @Costo)";
                                int detalleRecepcion;
                                using (MySqlCommand cmdDet = new MySqlCommand(queryDetRec, con, trans))
                                {
                                    cmdDet.Parameters.AddWithValue("@IdRec", idRecepcion);
                                    cmdDet.Parameters.AddWithValue("@IdDetOC", idDetalleOC);
                                    cmdDet.Parameters.AddWithValue("@IdVar", idVar);
                                    cmdDet.Parameters.AddWithValue("@NumLote", numLote);
                                    cmdDet.Parameters.AddWithValue("@Venc", fechaVenc);
                                    cmdDet.Parameters.AddWithValue("@Cant", cant);
                                    cmdDet.Parameters.AddWithValue("@Costo", costo);
                                    cmdDet.ExecuteNonQuery();
                                    detalleRecepcion = checked((int)cmdDet.LastInsertedId);
                                }

                                // C. Actualizar CantidadRecibida en DetalleOrdenCompra
                                string queryUpdDetOC = @"UPDATE DetalleOrdenCompra 
                                                         SET CantidadRecibida = IFNULL(CantidadRecibida, 0) + @Cant 
                                                         WHERE IdDetalleOC = @IdDetOC AND IdOC=@IdOC AND IdVariante=@IdVar AND CantidadPedida-IFNULL(CantidadRecibida,0)>=@Cant";
                                using (MySqlCommand cmdUpdDet = new MySqlCommand(queryUpdDetOC, con, trans))
                                {
                                    cmdUpdDet.Parameters.AddWithValue("@Cant", cant);
                                    cmdUpdDet.Parameters.AddWithValue("@IdDetOC", idDetalleOC);
                                    cmdUpdDet.Parameters.AddWithValue("@IdOC", idOC);
                                    cmdUpdDet.Parameters.AddWithValue("@IdVar", idVar);
                                    if (cmdUpdDet.ExecuteNonQuery() != 1)
                                        throw new InvalidOperationException("La cantidad pendiente cambió. Vuelve a seleccionar la orden.");
                                }

                                RecepcionInventario.Ingresar(con, trans, idVar, idBodega, detalleRecepcion,
                                    idUsuario, numLote, fechaRec, fechaVenc, cant, costo);
                            }
                        }

                        // 3. Evaluar Estado Global de la Orden de Compra (Recibida o Parcial)
                        string queryCheckOC = @"SELECT SUM(CantidadPedida) AS Pedidas, SUM(IFNULL(CantidadRecibida, 0)) AS Recibidas 
                                                FROM DetalleOrdenCompra WHERE IdOC = @IdOC";
                        bool ordenCompleta = false;
                        using (MySqlCommand cmdCheck = new MySqlCommand(queryCheckOC, con, trans))
                        {
                            cmdCheck.Parameters.AddWithValue("@IdOC", idOC);
                            using (MySqlDataReader dr = cmdCheck.ExecuteReader())
                            {
                                if (dr.Read())
                                {
                                    int pedidas = Convert.ToInt32(dr["Pedidas"]);
                                    int recibidas = Convert.ToInt32(dr["Recibidas"]);
                                    if (recibidas >= pedidas)
                                    {
                                        ordenCompleta = true;
                                    }
                                }
                            }
                        }

                        string nuevoEstadoOC = ordenCompleta ? "Recibida" : "Parcial";
                        string queryUpdOC = "UPDATE OrdenCompra SET Estado = @Estado WHERE IdOC = @IdOC";
                        using (MySqlCommand cmdUpdOC = new MySqlCommand(queryUpdOC, con, trans))
                        {
                            cmdUpdOC.Parameters.AddWithValue("@Estado", nuevoEstadoOC);
                            cmdUpdOC.Parameters.AddWithValue("@IdOC", idOC);
                            cmdUpdOC.ExecuteNonQuery();
                        }

                        // Actualizar estado de la recepción si fue parcial
                        if (!ordenCompleta)
                        {
                            string queryUpdRec = "UPDATE RecepcionCompra SET Estado = 'Parcial' WHERE IdRecepcion = @IdRec";
                            using (MySqlCommand cmdUpdRec = new MySqlCommand(queryUpdRec, con, trans))
                            {
                                cmdUpdRec.Parameters.AddWithValue("@IdRec", idRecepcion);
                                cmdUpdRec.ExecuteNonQuery();
                            }
                        }

                        using (MySqlCommand cmdSp = new MySqlCommand("usp_CrearCuentaPorPagar", con, trans))
                        {
                            cmdSp.CommandType = CommandType.StoredProcedure;
                            cmdSp.Parameters.AddWithValue("p_IdRecepcion", idRecepcion);
                            cmdSp.Parameters.AddWithValue("p_IdUsuario", idUsuario);
                            cmdSp.ExecuteNonQuery();
                        }
                        trans.Commit();

                        MostrarMensaje("Recepción REC-" + idRecepcion.ToString("D4") + " aprobada exitosamente. Se ingresaron " + totalItemsRecibiendo + " unidades a bodega con sus respectivos lotes (RF-COM-05 / RF-COM-06).", true);
                        pnlFormularioRec.Visible = false;

                        LimpiarFormulario();
                        CargarOrdenesCompraPendientes();
                        CargarRecepciones();
                        CalcularKPIs();
                    }
                    catch (Exception ex)
                    {
                        trans.Rollback();
                        MostrarMensaje("Error al procesar el ingreso de mercadería: " + ex.Message, false);
                    }
                }
            }
        }

        private void LimpiarFormulario()
        {
            ddlOrdenCompra.SelectedIndex = 0;
            txtGuiaDespacho.Text = "";
            pnlInfoOC.Visible = false;
            gvItemsRecepcion.DataSource = null;
            gvItemsRecepcion.DataBind();
        }
        #endregion

        #region Visualización y Listado de Recepciones Históricas
        private void CargarRecepciones()
        {
            string filtro = txtBuscar.Text.Trim();
            string idLab = ddlFiltroLaboratorio.SelectedValue;

            string query = @"SELECT r.IdRecepcion, oc.NumeroOC, l.RazonSocial, l.Rut, r.GuiaDespacho, r.FechaRecepcion, r.Estado,
                                    IFNULL((SELECT SUM(dr.Cantidad) FROM DetalleRecepcion dr WHERE dr.IdRecepcion = r.IdRecepcion), 0) AS TotalUnidades,
                                    IFNULL((SELECT SUM(dr.Cantidad * dr.CostoUnitario) FROM DetalleRecepcion dr WHERE dr.IdRecepcion = r.IdRecepcion), 0) AS MontoValorizado
                             FROM RecepcionCompra r
                             INNER JOIN OrdenCompra oc ON r.IdOC = oc.IdOC
                             INNER JOIN Laboratorio l ON oc.IdLaboratorio = l.IdLaboratorio
                             WHERE 1=1";

            if (!string.IsNullOrEmpty(filtro))
            {
                query += " AND (oc.NumeroOC LIKE @Filtro OR l.RazonSocial LIKE @Filtro OR r.GuiaDespacho LIKE @Filtro OR l.Rut LIKE @Filtro)";
            }
            if (!string.IsNullOrEmpty(idLab))
            {
                query += " AND oc.IdLaboratorio = @IdLab";
            }

            query += " ORDER BY r.IdRecepcion DESC";

            using (MySqlConnection con = new MySqlConnection(connectionString))
            {
                using (MySqlCommand cmd = new MySqlCommand(query, con))
                {
                    if (!string.IsNullOrEmpty(filtro))
                        cmd.Parameters.AddWithValue("@Filtro", "%" + filtro + "%");
                    if (!string.IsNullOrEmpty(idLab))
                        cmd.Parameters.AddWithValue("@IdLab", idLab);

                    using (MySqlDataAdapter da = new MySqlDataAdapter(cmd))
                    {
                        DataTable dt = new DataTable();
                        da.Fill(dt);
                        gvRecepciones.DataSource = dt;
                        gvRecepciones.DataBind();
                    }
                }
            }
        }

        private void CalcularKPIs()
        {
            string query = @"SELECT 
                                COUNT(*) AS TotalRec,
                                IFNULL((SELECT SUM(Cantidad) FROM DetalleRecepcion), 0) AS Unidades,
                                IFNULL((SELECT COUNT(*) FROM Lote WHERE Estado = 'Disponible'), 0) AS LotesActivos,
                                IFNULL((SELECT SUM(Cantidad * CostoUnitario) FROM DetalleRecepcion), 0) AS Valorizado
                             FROM RecepcionCompra";

            using (MySqlConnection con = new MySqlConnection(connectionString))
            {
                using (MySqlCommand cmd = new MySqlCommand(query, con))
                {
                    con.Open();
                    using (MySqlDataReader dr = cmd.ExecuteReader())
                    {
                        if (dr.Read())
                        {
                            lblKpiTotalRec.Text = dr["TotalRec"].ToString();
                            lblKpiUnidades.Text = dr["Unidades"].ToString();
                            lblKpiLotes.Text = dr["LotesActivos"].ToString();
                            lblKpiValorizado.Text = string.Format("{0:C0}", dr["Valorizado"]);
                        }
                    }
                }
            }
        }

        protected void gvRecepciones_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            if (e.CommandName == "VerDetalle")
            {
                int idRec = Convert.ToInt32(e.CommandArgument);
                CargarModalDetalleRecepcion(idRec);
            }
        }

        private void CargarModalDetalleRecepcion(int idRec)
        {
            string queryCab = @"SELECT r.IdRecepcion, oc.NumeroOC, l.RazonSocial, r.GuiaDespacho, r.FechaRecepcion, r.Estado
                                FROM RecepcionCompra r
                                INNER JOIN OrdenCompra oc ON r.IdOC = oc.IdOC
                                INNER JOIN Laboratorio l ON oc.IdLaboratorio = l.IdLaboratorio
                                WHERE r.IdRecepcion = @IdRec";

            using (MySqlConnection con = new MySqlConnection(connectionString))
            {
                using (MySqlCommand cmd = new MySqlCommand(queryCab, con))
                {
                    cmd.Parameters.AddWithValue("@IdRec", idRec);
                    con.Open();
                    using (MySqlDataReader dr = cmd.ExecuteReader())
                    {
                        if (dr.Read())
                        {
                            lblModalIdRec.Text = "REC-" + Convert.ToInt32(dr["IdRecepcion"]).ToString("D4");
                            lblModalOC.Text = dr["NumeroOC"].ToString();
                            lblModalProveedor.Text = dr["RazonSocial"].ToString();
                            lblModalGuia.Text = dr["GuiaDespacho"].ToString();
                            lblModalFecha.Text = Convert.ToDateTime(dr["FechaRecepcion"]).ToString("dd/MM/yyyy");
                            lblModalEstado.Text = dr["Estado"].ToString();
                        }
                    }
                }
            }

            string queryDet = @"SELECT v.Sku, p.Nombre AS Producto, v.NombreVariante, dr.NumeroLote, dr.FechaVencimiento,
                                       dr.Cantidad, dr.CostoUnitario, (dr.Cantidad * dr.CostoUnitario) AS SubtotalLinea
                                FROM DetalleRecepcion dr
                                INNER JOIN VarianteProducto v ON dr.IdVariante = v.IdVariante
                                INNER JOIN Producto p ON v.IdProducto = p.IdProducto
                                WHERE dr.IdRecepcion = @IdRec";

            using (MySqlConnection con = new MySqlConnection(connectionString))
            {
                using (MySqlCommand cmd = new MySqlCommand(queryDet, con))
                {
                    cmd.Parameters.AddWithValue("@IdRec", idRec);
                    using (MySqlDataAdapter da = new MySqlDataAdapter(cmd))
                    {
                        DataTable dt = new DataTable();
                        da.Fill(dt);
                        gvModalLotes.DataSource = dt;
                        gvModalLotes.DataBind();
                    }
                }
            }

            pnlModalDetalle.Visible = true;
        }

        protected void btnCerrarModal_Click(object sender, EventArgs e)
        {
            pnlModalDetalle.Visible = false;
        }
        #endregion

        #region Toolbar y Filtros
        protected void btnToggleForm_Click(object sender, EventArgs e)
        {
            pnlFormularioRec.Visible = !pnlFormularioRec.Visible;
            if (pnlFormularioRec.Visible)
            {
                CargarOrdenesCompraPendientes();
            }
        }

        protected void btnCerrarForm_Click(object sender, EventArgs e)
        {
            pnlFormularioRec.Visible = false;
            LimpiarFormulario();
        }

        protected void txtBuscar_TextChanged(object sender, EventArgs e)
        {
            CargarRecepciones();
        }

        protected void ddlFiltroLaboratorio_SelectedIndexChanged(object sender, EventArgs e)
        {
            CargarRecepciones();
        }

        protected void btnLimpiarFiltros_Click(object sender, EventArgs e)
        {
            txtBuscar.Text = "";
            ddlFiltroLaboratorio.SelectedIndex = 0;
            CargarRecepciones();
        }

        private void MostrarMensaje(string mensaje, bool esExito)
        {
            pnlMensaje.Visible = true;
            lblMensaje.Text = mensaje;
            if (esExito)
            {
                pnlMensaje.Style["background-color"] = "#E8F8F0";
                pnlMensaje.Style["border"] = "1px solid #A9DFBF";
                pnlMensaje.Style["color"] = "#27AE60";
            }
            else
            {
                pnlMensaje.Style["background-color"] = "#FDEDEC";
                pnlMensaje.Style["border"] = "1px solid #F5B7B1";
                pnlMensaje.Style["color"] = "#C0392B";
            }
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
