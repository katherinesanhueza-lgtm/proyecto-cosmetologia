using System;
using System.Data;
using System.Configuration;
using MySql.Data.MySqlClient;
using System.Web.UI.WebControls;

namespace trabajo_ing_software
{
    public partial class ReporteVentas : PaginaVentas
    {
        private string connectionString = ConfigurationManager.ConnectionStrings["DefaultConnection"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                InicializarFechasPorDefecto();
                CargarFiltroClientes();

                string tipoParam = Request.QueryString["tipo"];
                if (!string.IsNullOrEmpty(tipoParam) && ddlTipoReporte.Items.FindByValue(tipoParam) != null)
                {
                    ddlTipoReporte.SelectedValue = tipoParam;
                }

                string docParam = Request.QueryString["doc"];
                if (!string.IsNullOrEmpty(docParam) && ddlFiltroDocumento.Items.FindByValue(docParam) != null)
                {
                    ddlFiltroDocumento.SelectedValue = docParam;
                }

                AlternarPaneles();
                GenerarReporteActivo();
            }
        }

        private void InicializarFechasPorDefecto()
        {
            DateTime inicioMesSeis = new DateTime(DateTime.Today.Year, DateTime.Today.Month, 1).AddMonths(-5);
            txtFechaDesde.Text = inicioMesSeis.ToString("yyyy-MM-dd");
            txtFechaHasta.Text = DateTime.Today.ToString("yyyy-MM-dd");
        }

        public string ObtenerUrlRetorno()
        {
            string origen = (Request.QueryString["origen"] ?? "").ToLowerInvariant();
            switch (origen)
            {
                case "pos": return "Ventas.aspx?vista=pos";
                case "clientes": return "Clientes.aspx";
                case "cotizaciones": return "Cotizaciones.aspx";
                case "despachos": return "Despachos.aspx";
                case "devoluciones": return "Devoluciones.aspx";
                default:
                    switch (ddlTipoReporte.SelectedValue)
                    {
                        case "2": return "Despachos.aspx";
                        case "3": return "Clientes.aspx";
                        case "4": return "Devoluciones.aspx";
                        case "5": return "Cotizaciones.aspx";
                        default: return "Ventas.aspx?vista=pos";
                    }
            }
        }

        public string ObtenerTextoRetorno()
        {
            string origen = (Request.QueryString["origen"] ?? "").ToLowerInvariant();
            switch (origen)
            {
                case "pos": return "Volver a Punto de Venta";
                case "clientes": return "Volver a Clientes";
                case "cotizaciones": return "Volver a Cotizaciones";
                case "despachos": return "Volver a Despachos";
                case "devoluciones": return "Volver a Devoluciones";
                default:
                    switch (ddlTipoReporte.SelectedValue)
                    {
                        case "2": return "Volver a Despachos";
                        case "3": return "Volver a Clientes";
                        case "4": return "Volver a Devoluciones";
                        case "5": return "Volver a Cotizaciones";
                        default: return "Volver a Punto de Venta";
                    }
            }
        }

        private void CargarFiltroClientes()
        {
            ddlFiltroCliente.DataSource = VentaInventario.Consultar("SELECT IdCliente, Nombre FROM cliente ORDER BY Nombre ASC");
            ddlFiltroCliente.DataTextField = "Nombre";
            ddlFiltroCliente.DataValueField = "IdCliente";
            ddlFiltroCliente.DataBind();
            ddlFiltroCliente.Items.Insert(0, new ListItem("Todos los clientes", ""));
        }

        public string GetClaseDoc(string tipo)
        {
            if (string.Equals(tipo, "Boleta", StringComparison.OrdinalIgnoreCase)) return "badge-bol";
            if (string.Equals(tipo, "Factura", StringComparison.OrdinalIgnoreCase)) return "badge-fac";
            return "badge-nc";
        }

        protected void ddlTipoReporte_SelectedIndexChanged(object sender, EventArgs e)
        {
            AlternarPaneles();
            GenerarReporteActivo();
        }

        protected void btnFiltrar_Click(object sender, EventArgs e)
        {
            GenerarReporteActivo();
        }

        protected void btnLimpiar_Click(object sender, EventArgs e)
        {
            InicializarFechasPorDefecto();
            if (ddlFiltroCliente.Items.Count > 0) ddlFiltroCliente.SelectedIndex = 0;
            if (ddlFiltroDocumento.Items.Count > 0) ddlFiltroDocumento.SelectedIndex = 0;
            GenerarReporteActivo();
        }

        private void AlternarPaneles()
        {
            pnlReporte1.Visible = ddlTipoReporte.SelectedValue == "1";
            pnlReporte2.Visible = ddlTipoReporte.SelectedValue == "2";
            pnlReporte3.Visible = ddlTipoReporte.SelectedValue == "3";
            pnlReporte4.Visible = ddlTipoReporte.SelectedValue == "4";
            pnlReporte5.Visible = ddlTipoReporte.SelectedValue == "5";

            switch (ddlTipoReporte.SelectedValue)
            {
                case "1":
                    Page.Title = "Reporte de documentos de venta";
                    lblBadgeReporte.Text = "REPORTE ANALÍTICO N° 1 - VENTAS";
                    lblTituloPagina.Text = "Estado de Documentos de Venta";
                    lblSubtituloPagina.Text = "Monitoreo analítico de boletas, facturas y notas de crédito emitidas, con liquidación de IVA Débito Fiscal.";
                    lblTituloReporte.InnerText = "INFORME GERENCIAL: ESTADO E HISTORIAL DE COMPROBANTES DE VENTA";
                    lblResumenEtiqueta.Text = "Total Facturado Período:";
                    break;
                case "2":
                    Page.Title = "Reporte de salidas y productos";
                    lblBadgeReporte.Text = "REPORTE ANALÍTICO N° 2 - VENTAS Y LOGÍSTICA";
                    lblTituloPagina.Text = "Consolidado de Salidas y Rentabilidad por Producto";
                    lblSubtituloPagina.Text = "Auditoría de salidas de insumos por SKU bajo rotación FEFO, ingresos brutos, costo estimado y margen comercial.";
                    lblTituloReporte.InnerText = "INFORME CONSOLIDADO DE SALIDAS A CLIENTES Y RENTABILIDAD POR SKU";
                    lblResumenEtiqueta.Text = "Total Ingresos por Productos:";
                    break;
                case "3":
                    Page.Title = "Evaluación de clientes";
                    lblBadgeReporte.Text = "REPORTE ANALÍTICO N° 3 - VENTAS";
                    lblTituloPagina.Text = "Reporte: Evaluación Comercial de Clientes";
                    lblSubtituloPagina.Text = "Análisis de comportamiento de compra, utilización de línea de crédito autorizada y saldos pendientes en cuentas por cobrar.";
                    lblTituloReporte.InnerText = "INFORME ANALÍTICO: EVALUACIÓN DE CARTERA DE CLIENTES Y CRÉDITOS";
                    lblResumenEtiqueta.Text = "Total Comprado Cartera:";
                    break;
                case "4":
                    Page.Title = "Rendimiento por vendedor y NC";
                    lblBadgeReporte.Text = "REPORTE ANALÍTICO N° 4 - VENTAS";
                    lblTituloPagina.Text = "Análisis de Ventas por Ejecutivo y Devoluciones";
                    lblSubtituloPagina.Text = "Consolidado de facturación, ticket promedio, participación comercial y notas de crédito asociadas por vendedor.";
                    lblTituloReporte.InnerText = "INFORME GERENCIAL: RENDIMIENTO POR EJECUTIVO Y NOTAS DE CRÉDITO";
                    lblResumenEtiqueta.Text = "Facturación Consolidada Período:";
                    break;
                case "5":
                    Page.Title = "Reporte de cotizaciones";
                    lblBadgeReporte.Text = "REPORTE ANALÍTICO N° 5 - VENTAS";
                    lblTituloPagina.Text = "Historial de Presupuestos y Tasa de Conversión";
                    lblSubtituloPagina.Text = "Evaluación de cotizaciones comerciales emitidas, control de plazos de validez y efectividad de cierre en ventas.";
                    lblTituloReporte.InnerText = "INFORME ANALÍTICO: HISTORIAL DE PRESUPUESTOS Y TASA DE CONVERSIÓN";
                    lblResumenEtiqueta.Text = "Total Presupuestado Período:";
                    break;
            }
        }

        private void GenerarReporteActivo()
        {
            DateTime.TryParse(txtFechaDesde.Text, out DateTime desde);
            if (desde == DateTime.MinValue) desde = new DateTime(DateTime.Today.Year, 1, 1);

            DateTime.TryParse(txtFechaHasta.Text, out DateTime hasta);
            if (hasta == DateTime.MinValue) hasta = DateTime.Today;

            lblPeriodoTexto.Text = $"{desde:dd/MM/yyyy} al {hasta:dd/MM/yyyy}";

            switch (ddlTipoReporte.SelectedValue)
            {
                case "1": CargarReporte1(desde, hasta); break;
                case "2": CargarReporte2(desde, hasta); break;
                case "3": CargarReporte3(desde, hasta); break;
                case "4": CargarReporte4(desde, hasta); break;
                case "5": CargarReporte5(desde, hasta); break;
                default: CargarReporte1(desde, hasta); break;
            }
        }

        // Reporte 1: Historial General de Comprobantes
        private DataTable CargarReporte1(DateTime desde, DateTime hasta)
        {
            string filtroExtra = "";
            if (!string.IsNullOrEmpty(ddlFiltroCliente.SelectedValue))
                filtroExtra += " AND v.IdCliente = @IdCliente";

            if (ddlFiltroDocumento.SelectedValue != "Todos")
                filtroExtra += " AND v.TipoDocumento = @TipoDoc";

            string query = $@"SELECT v.IdVenta, 
                                     COALESCE(v.Folio, CONCAT('V-', v.IdVenta)) AS Folio,
                                     v.TipoDocumento,
                                     v.Fecha, 
                                     c.Nombre AS Cliente, 
                                     COALESCE(u.Nombre, 'Vendedor') AS Vendedor, 
                                     COALESCE(v.FormaPago, 'Contado') AS FormaPago,
                                     COALESCE(v.Neto, ROUND(v.Total / 1.19, 2)) AS Neto,
                                     COALESCE(v.Iva, v.Total - ROUND(v.Total / 1.19, 2)) AS Iva,
                                     v.Total 
                              FROM venta v
                              INNER JOIN cliente c ON v.IdCliente = c.IdCliente
                              LEFT JOIN usuario u ON v.IdUsuario = u.IdUsuario
                              WHERE v.Fecha BETWEEN @Desde AND @Hasta {filtroExtra}
                              ORDER BY v.IdVenta DESC";

            DataTable dt = new DataTable();
            using (MySqlConnection con = new MySqlConnection(connectionString))
            using (MySqlCommand cmd = new MySqlCommand(query, con))
            {
                cmd.Parameters.AddWithValue("@Desde", desde.Date);
                cmd.Parameters.AddWithValue("@Hasta", hasta.Date);
                if (!string.IsNullOrEmpty(ddlFiltroCliente.SelectedValue))
                    cmd.Parameters.AddWithValue("@IdCliente", ddlFiltroCliente.SelectedValue);
                if (ddlFiltroDocumento.SelectedValue != "Todos")
                    cmd.Parameters.AddWithValue("@TipoDoc", ddlFiltroDocumento.SelectedValue);

                using (MySqlDataAdapter sda = new MySqlDataAdapter(cmd))
                {
                    sda.Fill(dt);
                    gvReporteVentas.DataSource = dt;
                    gvReporteVentas.DataBind();
                }
            }

            decimal totalFacturado = 0, totalNeto = 0, totalIva = 0;
            foreach (DataRow row in dt.Rows)
            {
                totalFacturado += Convert.ToDecimal(row["Total"]);
                totalNeto += Convert.ToDecimal(row["Neto"]);
                totalIva += Convert.ToDecimal(row["Iva"]);
            }

            lblKpi1Titulo.Text = "Total Documentos";
            lblTotalTransacciones.Text = dt.Rows.Count.ToString("N0");
            lblKpi1Sub.Text = "En el período seleccionado";

            lblKpi2Titulo.Text = "Total Neto Ventas";
            lblNetoTotal.Text = "$" + totalNeto.ToString("N0");
            lblKpi2Sub.Text = "Base imponible sin IVA";

            lblKpi3Titulo.Text = "IVA Débito Fiscal (19%)";
            lblIvaTotal.Text = "$" + totalIva.ToString("N0");
            lblKpi3Sub.Text = "Impuesto fiscal devengado";

            lblKpi4Titulo.Text = "Total Facturado (c/ IVA)";
            Label1.Text = "$" + totalFacturado.ToString("N0");
            lblKpi4Sub.Text = "Ingresos brutos del período";

            lblResumenTotal.Text = "$" + totalFacturado.ToString("N0");
            return dt;
        }

        // Reporte 2: Ventas, Salidas y Rentabilidad por Producto
        private DataTable CargarReporte2(DateTime desde, DateTime hasta)
        {
            string filtroExtra = "";
            if (!string.IsNullOrEmpty(ddlFiltroCliente.SelectedValue))
                filtroExtra += " AND vt.IdCliente = @IdCliente";
            if (ddlFiltroDocumento.SelectedValue != "Todos")
                filtroExtra += " AND vt.TipoDocumento = @TipoDoc";
            else
                filtroExtra += " AND vt.TipoDocumento <> 'Nota de Credito'";

            string query = $@"SELECT p.Nombre AS Producto, 
                                    v.Sku,
                                    SUM(vd.Cantidad) AS UnidadesVendidas, 
                                    ROUND(AVG(vd.PrecioUnitario), 0) AS PrecioPromedio,
                                    SUM(vd.Subtotal) AS IngresoTotal,
                                    ROUND(SUM(vd.Cantidad * COALESCE(v.CostoPromedio, 0)), 0) AS CostoTotal,
                                    ROUND(SUM(vd.Subtotal) - SUM(vd.Cantidad * COALESCE(v.CostoPromedio, 0)), 0) AS MargenBruto
                             FROM ventadetalle vd
                             INNER JOIN varianteproducto v ON vd.IdVariante = v.IdVariante
                             INNER JOIN producto p ON v.IdProducto = p.IdProducto
                             INNER JOIN venta vt ON vd.IdVenta = vt.IdVenta
                             WHERE vt.Fecha BETWEEN @Desde AND @Hasta {filtroExtra}
                             GROUP BY p.IdProducto, p.Nombre, v.IdVariante, v.Sku
                             ORDER BY UnidadesVendidas DESC";

            DataTable dt = new DataTable();
            using (MySqlConnection con = new MySqlConnection(connectionString))
            using (MySqlCommand cmd = new MySqlCommand(query, con))
            {
                cmd.Parameters.AddWithValue("@Desde", desde.Date);
                cmd.Parameters.AddWithValue("@Hasta", hasta.Date);
                if (!string.IsNullOrEmpty(ddlFiltroCliente.SelectedValue))
                    cmd.Parameters.AddWithValue("@IdCliente", ddlFiltroCliente.SelectedValue);
                if (ddlFiltroDocumento.SelectedValue != "Todos")
                    cmd.Parameters.AddWithValue("@TipoDoc", ddlFiltroDocumento.SelectedValue);

                using (MySqlDataAdapter sda = new MySqlDataAdapter(cmd))
                {
                    sda.Fill(dt);
                    gvTopProductos.DataSource = dt;
                    gvTopProductos.DataBind();
                }
            }

            int totalUnidades = 0;
            decimal totalIngreso = 0, totalCosto = 0, totalMargen = 0;
            foreach (DataRow row in dt.Rows)
            {
                totalUnidades += Convert.ToInt32(row["UnidadesVendidas"]);
                totalIngreso += Convert.ToDecimal(row["IngresoTotal"]);
                totalCosto += Convert.ToDecimal(row["CostoTotal"]);
                totalMargen += Convert.ToDecimal(row["MargenBruto"]);
            }

            lblKpi1Titulo.Text = "SKUs Movilizados";
            lblTotalTransacciones.Text = dt.Rows.Count.ToString("N0");
            lblKpi1Sub.Text = "Insumos con salida efectiva";

            lblKpi2Titulo.Text = "Unidades Despachadas";
            lblNetoTotal.Text = totalUnidades.ToString("N0");
            lblKpi2Sub.Text = "Productos físicos entregados";

            lblKpi3Titulo.Text = "Costo Total Estimado";
            lblIvaTotal.Text = "$" + totalCosto.ToString("N0");
            lblKpi3Sub.Text = "Valorizado a costo promedio";

            lblKpi4Titulo.Text = "Margen Comercial Bruto";
            Label1.Text = "$" + totalMargen.ToString("N0");
            lblKpi4Sub.Text = "Rentabilidad directa del período";

            lblResumenTotal.Text = "$" + totalIngreso.ToString("N0");
            return dt;
        }

        // Reporte 3: Comportamiento y Créditos por Cliente
        private DataTable CargarReporte3(DateTime desde, DateTime hasta)
        {
            string filtroExtra = "";
            if (!string.IsNullOrEmpty(ddlFiltroCliente.SelectedValue))
                filtroExtra += " AND c.IdCliente = @IdCliente";

            string query = $@"SELECT c.Nombre AS Cliente, 
                                    c.Rut,
                                    COALESCE(c.Categoria, 'General') AS Categoria,
                                    COUNT(v.IdVenta) AS Compras, 
                                    COALESCE(SUM(v.Total), 0) AS TotalGastado,
                                    (SELECT COALESCE(SUM(cc.MontoPendiente), 0) FROM cuentascobrar cc JOIN venta vt ON cc.IdVenta = vt.IdVenta WHERE vt.IdCliente = c.IdCliente AND cc.EstadoPago <> 'Pagado') AS DeudaPendiente,
                                    COALESCE(c.LimiteCredito, 0) AS LimiteCredito
                             FROM cliente c
                             LEFT JOIN venta v ON v.IdCliente = c.IdCliente
                               AND v.TipoDocumento <> 'Nota de Credito'
                               AND v.Fecha BETWEEN @Desde AND @Hasta
                             WHERE COALESCE(c.Activo, 1) = 1 {filtroExtra}
                             GROUP BY c.IdCliente, c.Nombre, c.Rut, c.Categoria, c.LimiteCredito
                             ORDER BY TotalGastado DESC";

            DataTable dt = new DataTable();
            using (MySqlConnection con = new MySqlConnection(connectionString))
            using (MySqlCommand cmd = new MySqlCommand(query, con))
            {
                cmd.Parameters.AddWithValue("@Desde", desde.Date);
                cmd.Parameters.AddWithValue("@Hasta", hasta.Date);
                if (!string.IsNullOrEmpty(ddlFiltroCliente.SelectedValue))
                    cmd.Parameters.AddWithValue("@IdCliente", ddlFiltroCliente.SelectedValue);

                using (MySqlDataAdapter sda = new MySqlDataAdapter(cmd))
                {
                    sda.Fill(dt);
                    gvTopClientes.DataSource = dt;
                    gvTopClientes.DataBind();
                }
            }

            decimal totalGastado = 0, totalDeuda = 0, totalLimite = 0;
            foreach (DataRow row in dt.Rows)
            {
                totalGastado += Convert.ToDecimal(row["TotalGastado"]);
                totalDeuda += Convert.ToDecimal(row["DeudaPendiente"]);
                totalLimite += Convert.ToDecimal(row["LimiteCredito"]);
            }

            lblKpi1Titulo.Text = "Clientes Activos";
            lblTotalTransacciones.Text = dt.Rows.Count.ToString("N0");
            lblKpi1Sub.Text = "En cartera comercial homologada";

            lblKpi2Titulo.Text = "Total Facturado Cartera";
            lblNetoTotal.Text = "$" + totalGastado.ToString("N0");
            lblKpi2Sub.Text = "Compras en el período";

            lblKpi3Titulo.Text = "Deuda CxC Vigente";
            lblIvaTotal.Text = "$" + totalDeuda.ToString("N0");
            lblKpi3Sub.Text = "Saldo pendiente por cobrar";

            lblKpi4Titulo.Text = "Crédito Autorizado";
            Label1.Text = "$" + totalLimite.ToString("N0");
            lblKpi4Sub.Text = "Líneas aprobadas en cartera";

            lblResumenTotal.Text = "$" + totalGastado.ToString("N0");
            return dt;
        }

        // Reporte 4: Rendimiento Comercial por Vendedor y Notas de Crédito
        private DataTable CargarReporte4(DateTime desde, DateTime hasta)
        {
            string filtroCliente = !string.IsNullOrEmpty(ddlFiltroCliente.SelectedValue) ? " AND v.IdCliente = @IdCliente" : "";

            string query = $@"SELECT u.Nombre AS Vendedor,
                                    u.Rol,
                                    COUNT(CASE WHEN v.TipoDocumento <> 'Nota de Credito' THEN 1 END) AS CantidadOperaciones,
                                    COALESCE(SUM(CASE WHEN v.TipoDocumento <> 'Nota de Credito' THEN v.Total ELSE 0 END), 0) AS TotalVendido,
                                    ROUND(COALESCE(AVG(CASE WHEN v.TipoDocumento <> 'Nota de Credito' THEN v.Total END), 0), 0) AS TicketPromedio,
                                    COUNT(CASE WHEN v.TipoDocumento = 'Nota de Credito' THEN 1 END) AS TotalDevoluciones
                             FROM venta v
                             INNER JOIN usuario u ON v.IdUsuario = u.IdUsuario
                             WHERE v.Fecha BETWEEN @Desde AND @Hasta {filtroCliente}
                             GROUP BY u.IdUsuario, u.Nombre, u.Rol
                             ORDER BY TotalVendido DESC";

            DataTable dt = new DataTable();
            using (MySqlConnection con = new MySqlConnection(connectionString))
            using (MySqlCommand cmd = new MySqlCommand(query, con))
            {
                cmd.Parameters.AddWithValue("@Desde", desde.Date);
                cmd.Parameters.AddWithValue("@Hasta", hasta.Date);
                if (!string.IsNullOrEmpty(ddlFiltroCliente.SelectedValue))
                    cmd.Parameters.AddWithValue("@IdCliente", ddlFiltroCliente.SelectedValue);

                using (MySqlDataAdapter sda = new MySqlDataAdapter(cmd))
                {
                    sda.Fill(dt);
                }
            }

            dt.Columns.Add("ParticipacionPct", typeof(decimal));
            decimal sumaTotal = 0;
            int totalOps = 0, totalNC = 0;
            foreach (DataRow r in dt.Rows)
            {
                sumaTotal += Convert.ToDecimal(r["TotalVendido"]);
                totalOps += Convert.ToInt32(r["CantidadOperaciones"]);
                totalNC += Convert.ToInt32(r["TotalDevoluciones"]);
            }
            foreach (DataRow r in dt.Rows)
            {
                decimal vendido = Convert.ToDecimal(r["TotalVendido"]);
                r["ParticipacionPct"] = sumaTotal > 0 ? Math.Round(vendido / sumaTotal * 100m, 1) : 0m;
            }

            gvVendedores.DataSource = dt;
            gvVendedores.DataBind();

            decimal ticketGlobal = totalOps > 0 ? Math.Round(sumaTotal / totalOps, 0) : 0;

            lblKpi1Titulo.Text = "Ejecutivos con Ventas";
            lblTotalTransacciones.Text = dt.Rows.Count.ToString("N0");
            lblKpi1Sub.Text = "Vendedores activos en período";

            lblKpi2Titulo.Text = "Operaciones Emitidas";
            lblNetoTotal.Text = totalOps.ToString("N0");
            lblKpi2Sub.Text = "Boletas y facturas válidas";

            lblKpi3Titulo.Text = "Ticket Promedio Global";
            lblIvaTotal.Text = "$" + ticketGlobal.ToString("N0");
            lblKpi3Sub.Text = "Promedio por venta cerrada";

            lblKpi4Titulo.Text = "Devoluciones (N.C.)";
            Label1.Text = totalNC.ToString("N0") + " N.C.";
            lblKpi4Sub.Text = "Notas de crédito registradas";

            lblResumenTotal.Text = "$" + sumaTotal.ToString("N0");
            return dt;
        }

        // Reporte 5: Presupuestos y Tasa de Conversión
        private DataTable CargarReporte5(DateTime desde, DateTime hasta)
        {
            string filtroCliente = !string.IsNullOrEmpty(ddlFiltroCliente.SelectedValue) ? " AND c.IdCliente = @IdCliente" : "";

            string query = $@"SELECT c.IdCotizacion,
                                    cl.Nombre AS Cliente,
                                    c.FechaEmision,
                                    c.FechaVencimiento,
                                    c.Estado,
                                    c.Total,
                                    IF(c.Estado = 'Aceptado' OR EXISTS(SELECT 1 FROM venta v WHERE v.IdCotizacion = c.IdCotizacion), 'Concretada en Venta', 'En Seguimiento') AS VentaConcretada
                             FROM cotizacion c
                             INNER JOIN cliente cl ON c.IdCliente = cl.IdCliente
                             WHERE c.FechaEmision BETWEEN @Desde AND @Hasta {filtroCliente}
                             ORDER BY c.IdCotizacion DESC";

            DataTable dt = new DataTable();
            using (MySqlConnection con = new MySqlConnection(connectionString))
            using (MySqlCommand cmd = new MySqlCommand(query, con))
            {
                cmd.Parameters.AddWithValue("@Desde", desde.Date);
                cmd.Parameters.AddWithValue("@Hasta", hasta.Date);
                if (!string.IsNullOrEmpty(ddlFiltroCliente.SelectedValue))
                    cmd.Parameters.AddWithValue("@IdCliente", ddlFiltroCliente.SelectedValue);

                using (MySqlDataAdapter sda = new MySqlDataAdapter(cmd))
                {
                    sda.Fill(dt);
                    gvCotizacionesReporte.DataSource = dt;
                    gvCotizacionesReporte.DataBind();
                }
            }

            int totalCot = dt.Rows.Count;
            int aceptadas = 0;
            decimal montoTotal = 0;
            foreach (DataRow row in dt.Rows)
            {
                montoTotal += Convert.ToDecimal(row["Total"]);
                if (row["VentaConcretada"].ToString().Contains("Concretada"))
                    aceptadas++;
            }
            decimal tasa = totalCot > 0 ? Math.Round((decimal)aceptadas / totalCot * 100m, 1) : 0m;

            lblKpi1Titulo.Text = "Total Presupuestos";
            lblTotalTransacciones.Text = totalCot.ToString("N0");
            lblKpi1Sub.Text = "Emitidos en el período";

            lblKpi2Titulo.Text = "Aceptadas / Convertidas";
            lblNetoTotal.Text = aceptadas.ToString("N0");
            lblKpi2Sub.Text = "Concretadas en venta";

            lblKpi3Titulo.Text = "Tasa de Conversión";
            lblIvaTotal.Text = tasa.ToString("0.0") + "%";
            lblKpi3Sub.Text = "Efectividad comercial";

            lblKpi4Titulo.Text = "Monto Total Cotizado";
            Label1.Text = "$" + montoTotal.ToString("N0");
            lblKpi4Sub.Text = "Valor bruto presupuestado";

            lblResumenTotal.Text = "$" + montoTotal.ToString("N0");
            return dt;
        }

        protected void btnExportarExcel_Click(object sender, EventArgs e)
        {
            DateTime.TryParse(txtFechaDesde.Text, out DateTime desde);
            if (desde == DateTime.MinValue) desde = new DateTime(DateTime.Today.Year, 1, 1);

            DateTime.TryParse(txtFechaHasta.Text, out DateTime hasta);
            if (hasta == DateTime.MinValue) hasta = DateTime.Today;

            DataTable dtExportar;
            string nombreArchivo;

            switch (ddlTipoReporte.SelectedValue)
            {
                case "2":
                    dtExportar = CargarReporte2(desde, hasta);
                    nombreArchivo = "Ventas_Rentabilidad_Productos";
                    break;
                case "3":
                    dtExportar = CargarReporte3(desde, hasta);
                    nombreArchivo = "Evaluacion_Clientes_Creditos";
                    break;
                case "4":
                    dtExportar = CargarReporte4(desde, hasta);
                    nombreArchivo = "Rendimiento_Vendedores_Devoluciones";
                    break;
                case "5":
                    dtExportar = CargarReporte5(desde, hasta);
                    nombreArchivo = "Presupuestos_Tasa_Conversion";
                    break;
                default:
                    dtExportar = CargarReporte1(desde, hasta);
                    nombreArchivo = "Estado_Documentos_Ventas";
                    break;
            }

            byte[] excelBytes = ContabilidadExportacion.Excel(dtExportar);

            Response.Clear();
            Response.Buffer = true;
            Response.ContentType = "application/vnd.ms-excel";
            Response.AddHeader("content-disposition", $"attachment;filename={nombreArchivo}_{DateTime.Now:yyyyMMdd}.xls");
            Response.Charset = "utf-8";
            Response.BinaryWrite(excelBytes);
            Response.End();
        }
    }
}
