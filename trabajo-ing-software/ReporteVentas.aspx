<%@ Page Title="Reportes de Ventas" Language="C#" MasterPageFile="~/Contabilidad.Master" AutoEventWireup="true" CodeBehind="ReporteVentas.aspx.cs" Inherits="trabajo_ing_software.ReporteVentas" ResponseEncoding="utf-8" %>

<asp:Content ID="Estilos" ContentPlaceHolderID="EstilosPagina" runat="server">
    <link href="<%: ResolveUrl("~/Content/ComprasResumen.css?v=1") %>" rel="stylesheet" />
    <script src="https://cdnjs.cloudflare.com/ajax/libs/html2pdf.js/0.10.1/html2pdf.bundle.min.js"></script>
    <style>
        .card-dermocosmetica h2 { font-size: 1.25rem; font-weight: 600; margin-bottom: 14px; }
        .card-dermocosmetica h3 { font-size: 1.05rem; font-weight: 600; margin-bottom: 12px; color: #24211e; }
        .filter-card { background-color: #fff; border: 1px solid #e5e0d8; border-radius: 12px; padding: 20px; margin-bottom: 24px; }
        .filter-card h2 { font-size: 1.25rem; font-weight: 600; margin-bottom: 14px; color: #29231e; }
        .form-label { font-size: 0.875rem; font-weight: 500; color: #24211e; margin-bottom: 6px; }
        .table { font-size: 0.85rem; }
        .table th { font-size: 0.85rem; }
        .table td { font-size: 0.85rem; }
        .badge-bol { background-color: #EBF3FA; color: #2980B9; padding: 3px 8px; border-radius: 8px; font-weight: 600; font-size: 11px; }
        .badge-fac { background-color: #E8F8F0; color: #27AE60; padding: 3px 8px; border-radius: 8px; font-weight: 600; font-size: 11px; }
        .badge-nc { background-color: #FDEDEC; color: #C0392B; padding: 3px 8px; border-radius: 8px; font-weight: 600; font-size: 11px; }
    </style>
</asp:Content>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <div class="dashboard compras-resumen">
        
        <header class="dashboard-header" style="display: flex; justify-content: space-between; align-items: flex-start; flex-wrap: wrap; gap: 15px;">
            <div>
                <p class="dashboard-etiqueta">Módulo de ventas · Analítica y reportabilidad (RF-VEN-10)</p>
                <h1>Informes Comerciales de Ventas</h1>
                <p class="dashboard-descripcion">Cinco reportes especializados con filtros dinámicos y exportación oficial a PDF y Excel.</p>
            </div>
            <div class="d-flex gap-2">
                <asp:Button ID="btnExportarExcel" runat="server" Text="📊 Exportar Excel" CssClass="btn btn-outline-success" OnClick="btnExportarExcel_Click" />
                <asp:Button ID="btnDescargarPDF" runat="server" Text="📄 Descargar PDF" CssClass="btn btn-primary" OnClientClick="generarPDF(); return false;" />
            </div>
        </header>

        <!-- TARJETA DE FILTROS PARAMÉTRICOS (RF-VEN-10) -->
        <section class="filter-card">
            <h2 style="font-size: 1.25rem; font-weight: 600; margin-bottom: 14px;">Filtros de Reportabilidad</h2>
            <div class="row g-3 align-items-end">
                <div class="col-md-3">
                    <label class="form-label">Tipo de Reporte (5 Informes)</label>
                    <asp:DropDownList ID="ddlTipoReporte" runat="server" CssClass="form-select" AutoPostBack="true" OnSelectedIndexChanged="ddlTipoReporte_SelectedIndexChanged">
                        <asp:ListItem Text="1. Historial de Ventas y Comprobantes" Value="1" Selected="True"></asp:ListItem>
                        <asp:ListItem Text="2. Ventas y Rentabilidad por Producto" Value="2"></asp:ListItem>
                        <asp:ListItem Text="3. Comportamiento y Créditos por Cliente" Value="3"></asp:ListItem>
                        <asp:ListItem Text="4. Rendimiento Comercial por Vendedor" Value="4"></asp:ListItem>
                        <asp:ListItem Text="5. Presupuestos y Tasa de Conversión" Value="5"></asp:ListItem>
                    </asp:DropDownList>
                </div>
                <div class="col-md-2">
                    <label class="form-label">Fecha Desde</label>
                    <asp:TextBox ID="txtFechaDesde" runat="server" CssClass="form-control" TextMode="Date"></asp:TextBox>
                </div>
                <div class="col-md-2">
                    <label class="form-label">Fecha Hasta</label>
                    <asp:TextBox ID="txtFechaHasta" runat="server" CssClass="form-control" TextMode="Date"></asp:TextBox>
                </div>
                <div class="col-md-2">
                    <label class="form-label">Cliente</label>
                    <asp:DropDownList ID="ddlFiltroCliente" runat="server" CssClass="form-select"></asp:DropDownList>
                </div>
                <div class="col-md-2">
                    <label class="form-label">Tipo Documento</label>
                    <asp:DropDownList ID="ddlFiltroDocumento" runat="server" CssClass="form-select">
                        <asp:ListItem Text="Todos los tipos" Value="Todos"></asp:ListItem>
                        <asp:ListItem Text="Solo Boletas" Value="Boleta"></asp:ListItem>
                        <asp:ListItem Text="Solo Facturas" Value="Factura"></asp:ListItem>
                        <asp:ListItem Text="Solo Notas de Crédito" Value="Nota de Credito"></asp:ListItem>
                    </asp:DropDownList>
                </div>
                <div class="col-md-1">
                    <asp:Button ID="btnFiltrar" runat="server" Text="Filtrar" CssClass="btn btn-secondary w-100" OnClick="btnFiltrar_Click" />
                </div>
            </div>
        </section>

        <!-- TARJETAS DE KPIS SUPERIORES -->
        <div class="compras-indicadores">
            <section class="card-dermocosmetica compras-kpi">
                <h2>Total Transacciones</h2>
                <strong><asp:Label ID="lblTotalTransacciones" runat="server" Text="0"></asp:Label></strong>
                <span>Operaciones en el período</span>
            </section>
            <section class="card-dermocosmetica compras-kpi">
                <h2>Ingresos Totales</h2>
                <strong><asp:Label ID="Label1" runat="server" Text="$0"></asp:Label></strong>
                <span>Monto facturado bruto</span>
            </section>
            <section class="card-dermocosmetica compras-kpi">
                <h2>IVA Débito Fiscal</h2>
                <strong><asp:Label ID="lblIvaTotal" runat="server" Text="$0"></asp:Label></strong>
                <span>Impuesto fiscal 19%</span>
            </section>
            <section class="card-dermocosmetica compras-kpi">
                <h2>Venta Neta</h2>
                <strong><asp:Label ID="lblNetoTotal" runat="server" Text="$0"></asp:Label></strong>
                <span>Base imponible neta</span>
            </section>
        </div>

        <!-- ÁREA IMPRIMIBLE / EXPORTABLE -->
        <section id="areaReporte" class="card-dermocosmetica">
            <div style="display: flex; justify-content: space-between; align-items: flex-start; border-bottom: 1px solid #e5e0d8; padding-bottom: 16px; margin-bottom: 24px;">
                <div>
                    <h2 id="lblTituloReporte" runat="server" style="margin: 0;">Informe Comercial de Ventas</h2>
                    <p class="compras-nota" style="margin: 4px 0 0 0;">Dermo ERP · Distribución Dermatológica y Cosmecéutica Oficial</p>
                </div>
                <div style="text-align: right; font-size: 12px; color: #7a756c;">
                    <div>Fecha de emisión: <strong><%= DateTime.Now.ToString("dd/MM/yyyy HH:mm") %></strong></div>
                    <div>Período: <asp:Label ID="lblPeriodoTexto" runat="server"></asp:Label></div>
                </div>
            </div>

            <!-- Labels ocultos de compatibilidad -->
            <div class="d-none">
                <asp:Label ID="lblCantidadVentas" runat="server" Text="0"></asp:Label>
                <asp:Label ID="lblIngresosTotales" runat="server" Text="$0"></asp:Label>
            </div>

            <!-- REPORTE 1: GENERAL DE VENTAS Y COMPROBANTES -->
            <asp:Panel ID="pnlReporte1" runat="server">
                <h3 style="font-size: 16px; margin-bottom: 12px;">Historial de Documentos de Venta</h3>
                <div class="table-responsive">
                    <asp:GridView ID="gvReporteVentas" runat="server" CssClass="table table-hover" AutoGenerateColumns="False" GridLines="None" EmptyDataText="No se encontraron operaciones de venta con los filtros aplicados.">
                        <Columns>
                            <asp:BoundField DataField="IdVenta" HeaderText="ID" />
                            <asp:BoundField DataField="Folio" HeaderText="Folio" NullDisplayText="—" />
                            <asp:TemplateField HeaderText="Tipo Doc.">
                                <ItemTemplate>
                                    <span class='<%# GetClaseDoc(Eval("TipoDocumento").ToString()) %>'>
                                        <%# Eval("TipoDocumento") %>
                                    </span>
                                </ItemTemplate>
                            </asp:TemplateField>
                            <asp:BoundField DataField="Fecha" HeaderText="Fecha" DataFormatString="{0:dd/MM/yyyy}" />
                            <asp:BoundField DataField="Cliente" HeaderText="Cliente" />
                            <asp:BoundField DataField="Vendedor" HeaderText="Vendedor" NullDisplayText="Sistema" />
                            <asp:BoundField DataField="FormaPago" HeaderText="Pago" NullDisplayText="Contado" />
                            <asp:BoundField DataField="Neto" HeaderText="Neto" DataFormatString="${0:N0}" />
                            <asp:BoundField DataField="Iva" HeaderText="IVA" DataFormatString="${0:N0}" />
                            <asp:BoundField DataField="Total" HeaderText="Total" DataFormatString="${0:N0}" />
                        </Columns>
                    </asp:GridView>
                </div>
            </asp:Panel>

            <!-- REPORTE 2: VENTAS Y RENTABILIDAD POR PRODUCTO -->
            <asp:Panel ID="pnlReporte2" runat="server" Visible="false">
                <h3 style="font-size: 16px; margin-bottom: 12px;">Desempeño y Salida por Producto / SKU</h3>
                <div class="table-responsive">
                    <asp:GridView ID="gvTopProductos" runat="server" CssClass="table table-hover" AutoGenerateColumns="False" GridLines="None" EmptyDataText="Sin datos de productos para este período.">
                        <Columns>
                            <asp:BoundField DataField="Producto" HeaderText="Producto" />
                            <asp:BoundField DataField="Sku" HeaderText="SKU" />
                            <asp:BoundField DataField="UnidadesVendidas" HeaderText="Unidades" />
                            <asp:BoundField DataField="PrecioPromedio" HeaderText="Precio Prom." DataFormatString="${0:N0}" />
                            <asp:BoundField DataField="IngresoTotal" HeaderText="Ingresos Totales" DataFormatString="${0:N0}" />
                            <asp:BoundField DataField="CostoTotal" HeaderText="Costo Estimado" DataFormatString="${0:N0}" />
                            <asp:BoundField DataField="MargenBruto" HeaderText="Margen Comercial" DataFormatString="${0:N0}" />
                        </Columns>
                    </asp:GridView>
                </div>
            </asp:Panel>

            <!-- REPORTE 3: CLIENTES Y CRÉDITOS -->
            <asp:Panel ID="pnlReporte3" runat="server" Visible="false">
                <h3 style="font-size: 16px; margin-bottom: 12px;">Comportamiento de Clientes y Estado de Crédito</h3>
                <div class="table-responsive">
                    <asp:GridView ID="gvTopClientes" runat="server" CssClass="table table-hover" AutoGenerateColumns="False" GridLines="None" EmptyDataText="Sin datos de clientes para este período.">
                        <Columns>
                            <asp:BoundField DataField="Cliente" HeaderText="Razón Social / Cliente" />
                            <asp:BoundField DataField="Rut" HeaderText="RUT" />
                            <asp:BoundField DataField="Categoria" HeaderText="Tipo Cliente" />
                            <asp:BoundField DataField="Compras" HeaderText="N° Compras" />
                            <asp:BoundField DataField="TotalGastado" HeaderText="Total Comprado" DataFormatString="${0:N0}" />
                            <asp:BoundField DataField="DeudaPendiente" HeaderText="Deuda CxC Vigente" DataFormatString="${0:N0}" />
                            <asp:BoundField DataField="LimiteCredito" HeaderText="Límite Autorizado" DataFormatString="${0:N0}" />
                        </Columns>
                    </asp:GridView>
                </div>
            </asp:Panel>

            <!-- REPORTE 4: RENDIMIENTO POR VENDEDOR -->
            <asp:Panel ID="pnlReporte4" runat="server" Visible="false">
                <h3 style="font-size: 16px; margin-bottom: 12px;">Efectividad Comercial por Vendedor</h3>
                <div class="table-responsive">
                    <asp:GridView ID="gvVendedores" runat="server" CssClass="table table-hover" AutoGenerateColumns="False" GridLines="None" EmptyDataText="Sin registros de ventas por vendedor.">
                        <Columns>
                            <asp:BoundField DataField="Vendedor" HeaderText="Vendedor" />
                            <asp:BoundField DataField="Rol" HeaderText="Perfil" />
                            <asp:BoundField DataField="CantidadOperaciones" HeaderText="Ventas Realizadas" />
                            <asp:BoundField DataField="TotalVendido" HeaderText="Total Facturado" DataFormatString="${0:N0}" />
                            <asp:BoundField DataField="TicketPromedio" HeaderText="Ticket Promedio" DataFormatString="${0:N0}" />
                        </Columns>
                    </asp:GridView>
                </div>
            </asp:Panel>

            <!-- REPORTE 5: PRESUPUESTOS Y CONVERSIÓN -->
            <asp:Panel ID="pnlReporte5" runat="server" Visible="false">
                <h3 style="font-size: 16px; margin-bottom: 12px;">Presupuestos Emitidos y Tasa de Conversión a Venta</h3>
                <div class="table-responsive">
                    <asp:GridView ID="gvCotizacionesReporte" runat="server" CssClass="table table-hover" AutoGenerateColumns="False" GridLines="None" EmptyDataText="Sin cotizaciones en el período seleccionado.">
                        <Columns>
                            <asp:BoundField DataField="IdCotizacion" HeaderText="N° Presupuesto" />
                            <asp:BoundField DataField="Cliente" HeaderText="Cliente" />
                            <asp:BoundField DataField="FechaEmision" HeaderText="Emisión" DataFormatString="{0:dd/MM/yyyy}" />
                            <asp:BoundField DataField="FechaVencimiento" HeaderText="Vence" DataFormatString="{0:dd/MM/yyyy}" NullDisplayText="Sin plazo" />
                            <asp:BoundField DataField="Estado" HeaderText="Estado" />
                            <asp:BoundField DataField="Total" HeaderText="Monto Cotizado" DataFormatString="${0:N0}" />
                            <asp:BoundField DataField="VentaConcretada" HeaderText="Conversión a Venta" />
                        </Columns>
                    </asp:GridView>
                </div>
            </asp:Panel>
        </section>

    </div>

    <script>
        function generarPDF() {
            var elemento = document.getElementById('areaReporte');
            var opciones = {
                margin: 8,
                filename: 'Informe_Ventas_DermoERP.pdf',
                image: { type: 'jpeg', quality: 0.98 },
                html2canvas: { scale: 2, useCORS: true },
                jsPDF: { unit: 'mm', format: 'letter', orientation: 'landscape' }
            };
            html2pdf().set(opciones).from(elemento).save();
        }
    </script>
</asp:Content>
