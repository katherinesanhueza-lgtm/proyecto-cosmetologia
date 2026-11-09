using System;
using System.Data;
using System.Configuration;
using MySql.Data.MySqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace trabajo_ing_software
{
    public partial class OrdenesCompra : System.Web.UI.Page
    {
        private string connectionString = ConfigurationManager.ConnectionStrings["DefaultConnection"] != null ? ConfigurationManager.ConnectionStrings["DefaultConnection"].ConnectionString : "Server=localhost;Port=3306;Database=ERP_Dermocosmetica;Uid=root;Pwd=;";

        protected void Page_Load(object sender, EventArgs e)
        {
            // Verificaci�n de seguridad de sesi�n
            if (Session["IdUsuario"] == null)
            {
                Response.Redirect("Login.aspx");
                return;
            }

            ActualizarTextosIvaDinamicos();

            // Control de acceso por perfil (RBAC): S�lo Administrador y Contador pueden gestionar par�metros legales
            string rolUsuario = Session["RolUsuario"] != null ? Session["RolUsuario"].ToString() : "";
            btnAbrirConfig.Visible = rolUsuario.Equals("Administrador", StringComparison.OrdinalIgnoreCase) || 
                                     rolUsuario.Equals("Contador", StringComparison.OrdinalIgnoreCase);

            if (!IsPostBack)
            {
                lblBienvenida.Text = Session["NombreUsuario"] != null ? Session["NombreUsuario"].ToString() : "Usuario";
                txtUsuarioEmisor.Text = lblBienvenida.Text;

                InicializarTablaDetalle();
                CargarLaboratoriosFiltro();
                CargarLaboratoriosFormulario();
                CargarCatalogoProductos();
                
                txtFechaEmision.Text = DateTime.Today.ToString("yyyy-MM-dd");
                txtFechaEsperada.Text = DateTime.Today.AddDays(30).ToString("yyyy-MM-dd");
                txtNumeroOC.Text = GenerarSiguienteNumeroOC();

                CargarOrdenes();
                CalcularKPIs();
            }
        }

        #region Inicializaci�n y Estructura Temporal de �tems
        public string GetIniciales(string nombre)
        {
            if (string.IsNullOrWhiteSpace(nombre)) return "OC";
            string[] partes = nombre.Trim().Split(new char[] { ' ' }, StringSplitOptions.RemoveEmptyEntries);
            if (partes.Length >= 2)
                return (partes[0][0].ToString() + partes[1][0].ToString()).ToUpper();
            return partes[0].Substring(0, Math.Min(2, partes[0].Length)).ToUpper();
        }

        private void InicializarTablaDetalle()
        {
            DataTable dt = new DataTable();
            dt.Columns.Add("IdVariante", typeof(int));
            dt.Columns.Add("Sku", typeof(string));
            dt.Columns.Add("Producto", typeof(string));
            dt.Columns.Add("NombreVariante", typeof(string));
            dt.Columns.Add("CantidadPedida", typeof(int));
            dt.Columns.Add("CostoUnitario", typeof(decimal));
            dt.Columns.Add("Subtotal", typeof(decimal));

            ViewState["DetalleOC"] = dt;
        }

        private DataTable ObtenerTablaDetalle()
        {
            if (ViewState["DetalleOC"] == null)
            {
                InicializarTablaDetalle();
            }
            return (DataTable)ViewState["DetalleOC"];
        }
        #endregion

        #region Carga de Datos y Cat�logos
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

        private void CargarLaboratoriosFormulario()
        {
            ddlLaboratorio.Items.Clear();
            ddlLaboratorio.Items.Add(new ListItem("-- Seleccione un Laboratorio --", ""));

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
                            ddlLaboratorio.Items.Add(new ListItem(dr["RazonSocial"].ToString(), dr["IdLaboratorio"].ToString()));
                        }
                    }
                }
            }
        }

        private void CargarCatalogoProductos()
        {
            ddlProductoVariante.Items.Clear();
            ddlProductoVariante.Items.Add(new ListItem("-- Seleccionar Insumo / Producto --", ""));

            string query = @"SELECT v.IdVariante, v.Sku, p.Nombre AS Producto, v.NombreVariante, IFNULL(v.CostoPromedio, 0) AS CostoPromedio
                             FROM VarianteProducto v
                             INNER JOIN Producto p ON v.IdProducto = p.IdProducto
                             WHERE v.Activo = 1 AND p.Activo = 1
                             ORDER BY p.Nombre, v.NombreVariante";

            using (MySqlConnection con = new MySqlConnection(connectionString))
            {
                using (MySqlCommand cmd = new MySqlCommand(query, con))
                {
                    con.Open();
                    using (MySqlDataReader dr = cmd.ExecuteReader())
                    {
                        while (dr.Read())
                        {
                            string texto = string.Format("[{0}] {1} - {2} | Ref: {3:C0}", 
                                dr["Sku"], dr["Producto"], dr["NombreVariante"], dr["CostoPromedio"]);
                            ddlProductoVariante.Items.Add(new ListItem(texto, dr["IdVariante"].ToString()));
                        }
                    }
                }
            }
        }

        private string GenerarSiguienteNumeroOC()
        {
            string query = "SELECT IFNULL(MAX(IdOC), 0) + 1 AS SiguienteId FROM OrdenCompra";
            using (MySqlConnection con = new MySqlConnection(connectionString))
            {
                using (MySqlCommand cmd = new MySqlCommand(query, con))
                {
                    con.Open();
                    int siguiente = Convert.ToInt32(cmd.ExecuteScalar());
                    return string.Format("OC-{0}-{1:D4}", DateTime.Today.Year, siguiente);
                }
            }
        }
        #endregion

        #region Eventos de Formulario de Orden
        protected void ddlLaboratorio_SelectedIndexChanged(object sender, EventArgs e)
        {
            if (!string.IsNullOrEmpty(ddlLaboratorio.SelectedValue))
            {
                int idLab = Convert.ToInt32(ddlLaboratorio.SelectedValue);
                string query = "SELECT Rut, DiasPago, Contacto, Pais FROM Laboratorio WHERE IdLaboratorio = @IdLab";

                using (MySqlConnection con = new MySqlConnection(connectionString))
                {
                    using (MySqlCommand cmd = new MySqlCommand(query, con))
                    {
                        cmd.Parameters.AddWithValue("@IdLab", idLab);
                        con.Open();
                        using (MySqlDataReader dr = cmd.ExecuteReader())
                        {
                            if (dr.Read())
                            {
                                lblInfoRut.Text = dr["Rut"].ToString();
                                int dias = dr["DiasPago"] != DBNull.Value ? Convert.ToInt32(dr["DiasPago"]) : 30;
                                lblInfoDiasPago.Text = dias + " d�as de cr�dito";
                                lblInfoContacto.Text = dr["Contacto"].ToString();
                                lblInfoPais.Text = dr["Pais"].ToString();

                                DateTime fechaEmision;
                                if (!DateTime.TryParse(txtFechaEmision.Text, out fechaEmision))
                                    fechaEmision = DateTime.Today;

                                txtFechaEsperada.Text = fechaEmision.AddDays(dias).ToString("yyyy-MM-dd");
                            }
                        }
                    }
                }
            }
            else
            {
                lblInfoRut.Text = "Seleccione un laboratorio";
                lblInfoDiasPago.Text = "-";
                lblInfoContacto.Text = "-";
                lblInfoPais.Text = "-";
            }
        }

        protected void ddlProductoVariante_SelectedIndexChanged(object sender, EventArgs e)
        {
            if (!string.IsNullOrEmpty(ddlProductoVariante.SelectedValue))
            {
                int idVariante = Convert.ToInt32(ddlProductoVariante.SelectedValue);
                string query = "SELECT IFNULL(CostoPromedio, 0) AS Costo FROM VarianteProducto WHERE IdVariante = @IdVar";

                using (MySqlConnection con = new MySqlConnection(connectionString))
                {
                    using (MySqlCommand cmd = new MySqlCommand(query, con))
                    {
                        cmd.Parameters.AddWithValue("@IdVar", idVariante);
                        con.Open();
                        object resultado = cmd.ExecuteScalar();
                        if (resultado != null)
                        {
                            decimal costo = Convert.ToDecimal(resultado);
                            txtCostoUnitario.Text = Math.Round(costo, 0).ToString();
                        }
                    }
                }
            }
            else
            {
                txtCostoUnitario.Text = "";
            }
        }

        protected void btnAgregarItem_Click(object sender, EventArgs e)
        {
            if (string.IsNullOrEmpty(ddlProductoVariante.SelectedValue))
            {
                MostrarMensaje("Debe seleccionar un producto del cat�logo para agregarlo a la orden.", false);
                return;
            }

            int cantidad;
            if (!int.TryParse(txtCantidad.Text, out cantidad) || cantidad <= 0)
            {
                MostrarMensaje("Ingrese una cantidad v�lida mayor a 0.", false);
                return;
            }

            decimal costo;
            if (!decimal.TryParse(txtCostoUnitario.Text, out costo) || costo < 0)
            {
                MostrarMensaje("Ingrese un costo unitario v�lido.", false);
                return;
            }

            int idVar = Convert.ToInt32(ddlProductoVariante.SelectedValue);
            string sku = "";
            string producto = "";
            string variante = "";

            string query = @"SELECT v.Sku, p.Nombre AS Producto, v.NombreVariante 
                             FROM VarianteProducto v
                             INNER JOIN Producto p ON v.IdProducto = p.IdProducto
                             WHERE v.IdVariante = @IdVar";

            using (MySqlConnection con = new MySqlConnection(connectionString))
            {
                using (MySqlCommand cmd = new MySqlCommand(query, con))
                {
                    cmd.Parameters.AddWithValue("@IdVar", idVar);
                    con.Open();
                    using (MySqlDataReader dr = cmd.ExecuteReader())
                    {
                        if (dr.Read())
                        {
                            sku = dr["Sku"].ToString();
                            producto = dr["Producto"].ToString();
                            variante = dr["NombreVariante"].ToString();
                        }
                    }
                }
            }

            DataTable dt = ObtenerTablaDetalle();

            // Verificar si el SKU ya existe en la orden para sumar cantidades
            DataRow[] existentes = dt.Select("IdVariante = " + idVar);
            if (existentes.Length > 0)
            {
                existentes[0]["CantidadPedida"] = Convert.ToInt32(existentes[0]["CantidadPedida"]) + cantidad;
                existentes[0]["CostoUnitario"] = costo;
                existentes[0]["Subtotal"] = Convert.ToInt32(existentes[0]["CantidadPedida"]) * costo;
            }
            else
            {
                DataRow drNuevo = dt.NewRow();
                drNuevo["IdVariante"] = idVar;
                drNuevo["Sku"] = sku;
                drNuevo["Producto"] = producto;
                drNuevo["NombreVariante"] = variante;
                drNuevo["CantidadPedida"] = cantidad;
                drNuevo["CostoUnitario"] = costo;
                drNuevo["Subtotal"] = cantidad * costo;
                dt.Rows.Add(drNuevo);
            }

            ViewState["DetalleOC"] = dt;
            gvDetalleOC.DataSource = dt;
            gvDetalleOC.DataBind();

            RecalcularTotalesFinancieros();

            // Restablecer inputs de �tem
            ddlProductoVariante.SelectedIndex = 0;
            txtCantidad.Text = "1";
            txtCostoUnitario.Text = "";
            pnlMensaje.Visible = false;
        }

        protected void gvDetalleOC_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            if (e.CommandName == "EliminarItem")
            {
                int index = Convert.ToInt32(e.CommandArgument);
                DataTable dt = ObtenerTablaDetalle();
                if (index >= 0 && index < dt.Rows.Count)
                {
                    dt.Rows.RemoveAt(index);
                    ViewState["DetalleOC"] = dt;
                    gvDetalleOC.DataSource = dt;
                    gvDetalleOC.DataBind();
                    RecalcularTotalesFinancieros();
                }
            }
        }

        private void RecalcularTotalesFinancieros()
        {
            DataTable dt = ObtenerTablaDetalle();
            decimal neto = 0;

            foreach (DataRow row in dt.Rows)
            {
                neto += Convert.ToDecimal(row["Subtotal"]);
            }

            // C�lculo din�mico seg�n tasa de IVA consultada desde ConfiguracionGlobal (Ajuste L�gico RF-COM-04)
            decimal iva = neto * ConfiguracionGlobal.TasaIva;
            decimal total = neto + iva;

            lblNeto.Text = string.Format("{0:C0}", neto);
            lblIva.Text = string.Format("{0:C0}", iva);
            lblTotal.Text = string.Format("{0:C0}", total);
        }
        #endregion

        #region Guardar Orden de Compra (Transaccional ADO.NET)
        protected void btnGuardarOC_Click(object sender, EventArgs e)
        {
            if (string.IsNullOrEmpty(ddlLaboratorio.SelectedValue))
            {
                MostrarMensaje("Debe seleccionar un Laboratorio / Proveedor.", false);
                return;
            }

            DataTable dt = ObtenerTablaDetalle();
            if (dt.Rows.Count == 0)
            {
                MostrarMensaje("La orden de compra debe contener al menos un producto en el detalle.", false);
                return;
            }

            DateTime fechaEmision;
            if (!DateTime.TryParse(txtFechaEmision.Text, out fechaEmision))
            {
                MostrarMensaje("Seleccione una fecha de emisi�n v�lida.", false);
                return;
            }

            DateTime fechaEsperada;
            if (!DateTime.TryParse(txtFechaEsperada.Text, out fechaEsperada))
            {
                fechaEsperada = fechaEmision.AddDays(30);
            }

            decimal neto = 0;
            foreach (DataRow row in dt.Rows)
            {
                neto += Convert.ToDecimal(row["Subtotal"]);
            }
            // C�lculo din�mico seg�n tasa de IVA consultada desde ConfiguracionGlobal (Ajuste L�gico RF-COM-04)
            decimal iva = neto * ConfiguracionGlobal.TasaIva;
            decimal total = neto + iva;

            int idLab = Convert.ToInt32(ddlLaboratorio.SelectedValue);
            string estado = ddlEstado.SelectedValue;
            string numOC = txtNumeroOC.Text.Trim();
            if (string.IsNullOrEmpty(numOC))
            {
                numOC = GenerarSiguienteNumeroOC();
            }

            int idUsuario = Convert.ToInt32(Session["IdUsuario"]);

            using (MySqlConnection con = new MySqlConnection(connectionString))
            {
                con.Open();
                using (MySqlTransaction trans = con.BeginTransaction())
                {
                    try
                    {
                        string queryCabecera = @"INSERT INTO OrdenCompra (NumeroOC, IdLaboratorio, Fecha, FechaEsperada, Estado, Neto, Iva, Total, IdUsuario)
                                                 VALUES (@NumeroOC, @IdLab, @Fecha, @FechaEsp, @Estado, @Neto, @Iva, @Total, @IdUsuario);
                                                 SELECT LAST_INSERT_ID();";

                        int idOC = 0;
                        using (MySqlCommand cmd = new MySqlCommand(queryCabecera, con, trans))
                        {
                            cmd.Parameters.AddWithValue("@NumeroOC", numOC);
                            cmd.Parameters.AddWithValue("@IdLab", idLab);
                            cmd.Parameters.AddWithValue("@Fecha", fechaEmision);
                            cmd.Parameters.AddWithValue("@FechaEsp", fechaEsperada);
                            cmd.Parameters.AddWithValue("@Estado", estado);
                            cmd.Parameters.AddWithValue("@Neto", neto);
                            cmd.Parameters.AddWithValue("@Iva", iva);
                            cmd.Parameters.AddWithValue("@Total", total);
                            cmd.Parameters.AddWithValue("@IdUsuario", idUsuario);

                            idOC = Convert.ToInt32(cmd.ExecuteScalar());
                        }

                        string queryDetalle = @"INSERT INTO DetalleOrdenCompra (IdOC, IdVariante, CantidadPedida, CantidadRecibida, CostoUnitario)
                                                VALUES (@IdOC, @IdVar, @CantidadPedida, @CantidadRecibida, @CostoUnitario)";

                        foreach (DataRow row in dt.Rows)
                        {
                            using (MySqlCommand cmdDet = new MySqlCommand(queryDetalle, con, trans))
                            {
                                int cantidadPedida = Convert.ToInt32(row["CantidadPedida"]);
                                int cantidadRecibida = (estado == "Recibida") ? cantidadPedida : 0;

                                cmdDet.Parameters.AddWithValue("@IdOC", idOC);
                                cmdDet.Parameters.AddWithValue("@IdVar", Convert.ToInt32(row["IdVariante"]));
                                cmdDet.Parameters.AddWithValue("@CantidadPedida", cantidadPedida);
                                cmdDet.Parameters.AddWithValue("@CantidadRecibida", cantidadRecibida);
                                cmdDet.Parameters.AddWithValue("@CostoUnitario", Convert.ToDecimal(row["CostoUnitario"]));

                                cmdDet.ExecuteNonQuery();
                            }
                        }

                        trans.Commit();

                        LimpiarFormulario();
                        pnlFormularioOC.Visible = false;
                        MostrarMensaje("Orden de Compra " + numOC + " guardada exitosamente con estado " + estado + ".", true);

                        CargarOrdenes();
                        CalcularKPIs();
                    }
                    catch (Exception ex)
                    {
                        trans.Rollback();
                        MostrarMensaje("Error al registrar la orden de compra: " + ex.Message, false);
                    }
                }
            }
        }

        private void LimpiarFormulario()
        {
            ddlLaboratorio.SelectedIndex = 0;
            lblInfoRut.Text = "Seleccione un laboratorio";
            lblInfoDiasPago.Text = "-";
            lblInfoContacto.Text = "-";
            lblInfoPais.Text = "-";
            ddlEstado.SelectedValue = "Emitida";
            ddlProductoVariante.SelectedIndex = 0;
            txtCantidad.Text = "1";
            txtCostoUnitario.Text = "";

            InicializarTablaDetalle();
            gvDetalleOC.DataSource = null;
            gvDetalleOC.DataBind();

            RecalcularTotalesFinancieros();
            txtNumeroOC.Text = GenerarSiguienteNumeroOC();
        }
        #endregion

        #region Visualizaci�n y Listado de �rdenes (GridView Principal)
        private void ActualizarTextosIvaDinamicos()
        {
            decimal tasa = ConfiguracionGlobal.TasaIva;
            string pctStr = (tasa * 100m).ToString("0.#");

            if (lblIvaSubtitulo != null) lblIvaSubtitulo.Text = pctStr;
            if (lblIvaPctNota != null) lblIvaPctNota.Text = pctStr;
            if (lblIvaPctCreacion != null) lblIvaPctCreacion.Text = pctStr;
            if (lblModalIvaPct != null) lblModalIvaPct.Text = pctStr;

            foreach (DataControlField col in gvOrdenes.Columns)
            {
                if (col.HeaderText != null && col.HeaderText.StartsWith("IVA"))
                {
                    col.HeaderText = "IVA " + pctStr + "%";
                    break;
                }
            }
        }

        private void CargarOrdenes()
        {
            ActualizarTextosIvaDinamicos();
            string filtro = txtBuscar.Text.Trim();
            string estado = ddlFiltroEstado.SelectedValue;
            string idLab = ddlFiltroLaboratorio.SelectedValue;

            string query = @"SELECT oc.IdOC, oc.NumeroOC, l.RazonSocial, l.Rut, oc.Fecha, oc.FechaEsperada, oc.Estado, oc.Neto, oc.Iva, oc.Total
                             FROM OrdenCompra oc
                             INNER JOIN Laboratorio l ON oc.IdLaboratorio = l.IdLaboratorio
                             WHERE 1=1";

            if (!string.IsNullOrEmpty(filtro))
            {
                query += " AND (oc.NumeroOC LIKE @Filtro OR l.RazonSocial LIKE @Filtro OR l.Rut LIKE @Filtro)";
            }
            if (!string.IsNullOrEmpty(estado))
            {
                query += " AND oc.Estado = @Estado";
            }
            if (!string.IsNullOrEmpty(idLab))
            {
                query += " AND oc.IdLaboratorio = @IdLab";
            }

            query += " ORDER BY oc.IdOC DESC";

            using (MySqlConnection con = new MySqlConnection(connectionString))
            {
                using (MySqlCommand cmd = new MySqlCommand(query, con))
                {
                    if (!string.IsNullOrEmpty(filtro))
                        cmd.Parameters.AddWithValue("@Filtro", "%" + filtro + "%");
                    if (!string.IsNullOrEmpty(estado))
                        cmd.Parameters.AddWithValue("@Estado", estado);
                    if (!string.IsNullOrEmpty(idLab))
                        cmd.Parameters.AddWithValue("@IdLab", idLab);

                    using (MySqlDataAdapter da = new MySqlDataAdapter(cmd))
                    {
                        DataTable dt = new DataTable();
                        da.Fill(dt);
                        gvOrdenes.DataSource = dt;
                        gvOrdenes.DataBind();
                    }
                }
            }
        }

        private void CalcularKPIs()
        {
            string query = @"SELECT 
                                COUNT(*) AS TotalOC,
                                IFNULL(SUM(CASE WHEN Estado = 'Emitida' OR Estado = 'Parcial' THEN 1 ELSE 0 END), 0) AS Emitidas,
                                IFNULL(SUM(CASE WHEN Estado = 'Recibida' THEN 1 ELSE 0 END), 0) AS Recibidas,
                                IFNULL(SUM(Total), 0) AS TotalMonto
                             FROM OrdenCompra";

            using (MySqlConnection con = new MySqlConnection(connectionString))
            {
                using (MySqlCommand cmd = new MySqlCommand(query, con))
                {
                    con.Open();
                    using (MySqlDataReader dr = cmd.ExecuteReader())
                    {
                        if (dr.Read())
                        {
                            lblKpiTotalOC.Text = dr["TotalOC"].ToString();
                            lblKpiEmitidas.Text = dr["Emitidas"].ToString();
                            lblKpiRecibidas.Text = dr["Recibidas"].ToString();
                            lblKpiTotalMonto.Text = string.Format("{0:C0}", dr["TotalMonto"]);
                        }
                    }
                }
            }
        }

        protected void gvOrdenes_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            if (e.CommandName == "VerDetalle")
            {
                int idOC = Convert.ToInt32(e.CommandArgument);
                CargarModalDetalle(idOC);
            }
            else if (e.CommandName == "AprobarOC")
            {
                int idOC = Convert.ToInt32(e.CommandArgument);
                ActualizarEstadoOrden(idOC, "Emitida");
            }
            else if (e.CommandName == "RecibirOC")
            {
                int idOC = Convert.ToInt32(e.CommandArgument);
                string rol = Convert.ToString(Session["RolUsuario"]);
                if (string.Equals(rol, "Administrador", StringComparison.OrdinalIgnoreCase))
                    Response.Redirect("Recepciones.aspx?orden=" + idOC);
                else
                    MostrarMensaje("El encargado de bodega debe registrar la recepción para actualizar el inventario.", false);
            }
            else if (e.CommandName == "AnularOC")
            {
                int idOC = Convert.ToInt32(e.CommandArgument);
                ActualizarEstadoOrden(idOC, "Anulada");
            }
        }

        private void ActualizarEstadoOrden(int idOC, string nuevoEstado)
        {
            using (MySqlConnection con = new MySqlConnection(connectionString))
            {
                con.Open();
                using (MySqlTransaction trans = con.BeginTransaction())
                {
                    try
                    {
                        string query = "UPDATE OrdenCompra SET Estado = @Estado WHERE IdOC = @IdOC";
                        using (MySqlCommand cmd = new MySqlCommand(query, con, trans))
                        {
                            cmd.Parameters.AddWithValue("@Estado", nuevoEstado);
                            cmd.Parameters.AddWithValue("@IdOC", idOC);
                            cmd.ExecuteNonQuery();
                        }


                        trans.Commit();
                        MostrarMensaje("Orden de compra actualizada al estado: " + nuevoEstado + ".", true);
                        CargarOrdenes();
                        CalcularKPIs();
                    }
                    catch (Exception ex)
                    {
                        trans.Rollback();
                        MostrarMensaje("Error al actualizar estado: " + ex.Message, false);
                    }
                }
            }
        }

        private void CargarModalDetalle(int idOC)
        {
            string queryCab = @"SELECT oc.NumeroOC, l.RazonSocial, l.Rut, oc.Fecha, oc.FechaEsperada, oc.Estado, oc.Neto, oc.Iva, oc.Total
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
                            lblModalNumeroOC.Text = dr["NumeroOC"].ToString();
                            lblModalLaboratorio.Text = dr["RazonSocial"].ToString();
                            lblModalRut.Text = dr["Rut"].ToString();
                            lblModalFecha.Text = Convert.ToDateTime(dr["Fecha"]).ToString("dd/MM/yyyy");
                            lblModalFechaEsperada.Text = Convert.ToDateTime(dr["FechaEsperada"]).ToString("dd/MM/yyyy");
                            lblModalEstado.Text = dr["Estado"].ToString();
                            lblModalNeto.Text = string.Format("{0:C0}", dr["Neto"]);
                            lblModalIva.Text = string.Format("{0:C0}", dr["Iva"]);
                            lblModalTotal.Text = string.Format("{0:C0}", dr["Total"]);
                            if (lblModalIvaPct != null)
                            {
                                lblModalIvaPct.Text = (ConfiguracionGlobal.TasaIva * 100m).ToString("0.#");
                            }
                            // Inyecci�n din�mica de Jefatura de Compras bajo la firma (Ajuste L�gico)
                            lblModalFirmaJefe.Text = ConfiguracionGlobal.NombreJefeCompras;
                        }
                    }
                }
            }

            string queryDet = @"SELECT v.Sku, p.Nombre AS Producto, v.NombreVariante, doc.CantidadPedida, 
                                       IFNULL(doc.CantidadRecibida, 0) AS CantidadRecibida, doc.CostoUnitario,
                                       (doc.CantidadPedida * doc.CostoUnitario) AS SubtotalLinea
                                FROM DetalleOrdenCompra doc
                                INNER JOIN VarianteProducto v ON doc.IdVariante = v.IdVariante
                                INNER JOIN Producto p ON v.IdProducto = p.IdProducto
                                WHERE doc.IdOC = @IdOC";

            using (MySqlConnection con = new MySqlConnection(connectionString))
            {
                using (MySqlCommand cmd = new MySqlCommand(queryDet, con))
                {
                    cmd.Parameters.AddWithValue("@IdOC", idOC);
                    using (MySqlDataAdapter da = new MySqlDataAdapter(cmd))
                    {
                        DataTable dt = new DataTable();
                        da.Fill(dt);
                        gvModalItems.DataSource = dt;
                        gvModalItems.DataBind();
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

        #region Acciones de Toolbar y Filtros
        protected void btnToggleForm_Click(object sender, EventArgs e)
        {
            pnlFormularioOC.Visible = !pnlFormularioOC.Visible;
            if (pnlFormularioOC.Visible)
            {
                txtNumeroOC.Text = GenerarSiguienteNumeroOC();
            }
        }

        protected void btnCerrarForm_Click(object sender, EventArgs e)
        {
            pnlFormularioOC.Visible = false;
            LimpiarFormulario();
        }

        protected void txtBuscar_TextChanged(object sender, EventArgs e)
        {
            CargarOrdenes();
        }

        protected void ddlFiltroEstado_SelectedIndexChanged(object sender, EventArgs e)
        {
            CargarOrdenes();
        }

        protected void ddlFiltroLaboratorio_SelectedIndexChanged(object sender, EventArgs e)
        {
            CargarOrdenes();
        }

        protected void btnLimpiarFiltros_Click(object sender, EventArgs e)
        {
            txtBuscar.Text = "";
            ddlFiltroEstado.SelectedIndex = 0;
            ddlFiltroLaboratorio.SelectedIndex = 0;
            CargarOrdenes();
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

        #region Configuración Global - Tasa de IVA (Admin / Contador)
        protected void btnAbrirConfig_Click(object sender, EventArgs e)
        {
            string rolUsuario = Session["RolUsuario"] != null ? Session["RolUsuario"].ToString() : "";
            if (!rolUsuario.Equals("Administrador", StringComparison.OrdinalIgnoreCase) && !rolUsuario.Equals("Contador", StringComparison.OrdinalIgnoreCase))
            {
                MostrarMensaje("Acceso restringido: Solo el Administrador y el Contador pueden configurar la tasa de IVA.", false);
                return;
            }

            decimal iva = ConfiguracionGlobal.TasaIva;
            txtConfigIva.Text = (iva * 100m).ToString("0.0");
            lblIvaActualDb.Text = (iva * 100m).ToString("0.0") + "% (" + iva.ToString("0.00", System.Globalization.CultureInfo.InvariantCulture) + " en BD)";

            lblConfigMensaje.Text = "";
            pnlModalConfig.Visible = true;
        }

        protected void btnCerrarConfig_Click(object sender, EventArgs e)
        {
            pnlModalConfig.Visible = false;
        }

        protected void btnGuardarConfig_Click(object sender, EventArgs e)
        {
            string rolUsuario = Session["RolUsuario"] != null ? Session["RolUsuario"].ToString() : "";
            if (!rolUsuario.Equals("Administrador", StringComparison.OrdinalIgnoreCase) && !rolUsuario.Equals("Contador", StringComparison.OrdinalIgnoreCase))
            {
                lblConfigMensaje.Text = "No tiene permisos para modificar la tasa de IVA.";
                lblConfigMensaje.ForeColor = System.Drawing.Color.Red;
                return;
            }

            string ivaIngresado = txtConfigIva.Text.Trim().Replace("%", "").Replace(",", ".");
            if (!decimal.TryParse(ivaIngresado, System.Globalization.NumberStyles.Any, System.Globalization.CultureInfo.InvariantCulture, out decimal tasaDecimal) || tasaDecimal <= 0)
            {
                lblConfigMensaje.Text = "Ingrese una tasa de IVA válida (ej: 19 o 20).";
                lblConfigMensaje.ForeColor = System.Drawing.Color.Red;
                return;
            }

            if (tasaDecimal > 1.0m)
            {
                tasaDecimal = tasaDecimal / 100m;
            }

            using (MySqlConnection con = new MySqlConnection(connectionString))
            {
                con.Open();
                string sql = @"
                    UPDATE ConfiguracionGlobal SET Valor = @TasaIva WHERE Clave = 'TasaIva';
                    
                    UPDATE OrdenCompra 
                    SET Iva = ROUND(Neto * @TasaDecimal, 0),
                        Total = Neto + ROUND(Neto * @TasaDecimal, 0)
                    WHERE Estado <> 'Anulada';";

                using (MySqlCommand cmd = new MySqlCommand(sql, con))
                {
                    cmd.Parameters.AddWithValue("@TasaIva", tasaDecimal.ToString("0.00", System.Globalization.CultureInfo.InvariantCulture));
                    
                    MySqlParameter pDecimal = cmd.Parameters.Add("@TasaDecimal", MySqlDbType.Decimal);
                    pDecimal.Precision = 18;
                    pDecimal.Scale = 4;
                    pDecimal.Value = tasaDecimal;

                    cmd.ExecuteNonQuery();
                }
            }

            ActualizarTextosIvaDinamicos();
            CargarOrdenes();
            CalcularKPIs();
            RecalcularTotalesFinancieros();

            string pctStr = (tasaDecimal * 100m).ToString("0.#");
            lblConfigMensaje.Text = "¡Tasa de IVA actualizada! La nueva tasa (" + pctStr + "%) se aplicó exitosamente a todas las órdenes y cálculos.";
            lblConfigMensaje.ForeColor = System.Drawing.Color.Green;
            lblIvaActualDb.Text = pctStr + "% (" + tasaDecimal.ToString("0.00", System.Globalization.CultureInfo.InvariantCulture) + " en BD)";
        }
        #endregion

        protected void btnLogout_Click(object sender, EventArgs e)
        {
            Session.Clear();
            Session.Abandon();
            Response.Redirect("Login.aspx");
        }
        #endregion
    }
}
