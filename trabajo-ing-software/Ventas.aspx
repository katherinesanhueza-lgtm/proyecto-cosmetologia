<%@ Page Title="Resumen de Ventas" Language="C#" MasterPageFile="~/Contabilidad.Master" AutoEventWireup="true" CodeBehind="Ventas.aspx.cs" Inherits="trabajo_ing_software.Ventas" ResponseEncoding="utf-8" %>

<asp:Content ID="Estilos" ContentPlaceHolderID="EstilosPagina" runat="server">
    <link href="<%: ResolveUrl("~/Content/ComprasResumen.css?v=3") %>" rel="stylesheet" />
    <style>
        .card-dermocosmetica h2 { font-size: 1.25rem; font-weight: 600; margin-bottom: 14px; }
        .form-label { font-size: 0.875rem; font-weight: 500; color: #24211e; margin-bottom: 6px; }
        .table { font-size: 0.85rem; }
        .table th { font-size: 0.85rem; }
        .table td { font-size: 0.85rem; }
        .resumen-totales-fila { display: flex; justify-content: space-between; margin-bottom: 7px; font-size: 0.875rem; color: #555; }
        .resumen-totales-fila.destacado { font-weight: 700; color: #24211e; font-size: 1.2rem; border-top: 1px solid #dfd7cc; padding-top: 10px; margin-top: 8px; margin-bottom: 0; }
        .badge-credito-ok { background-color: #E8F8F0; color: #27AE60; padding: 4px 10px; border-radius: 8px; font-weight: 600; font-size: 12px; display: inline-block; }
        .badge-credito-alerta { background-color: #FDEDEC; color: #C0392B; padding: 4px 10px; border-radius: 8px; font-weight: 600; font-size: 12px; display: inline-block; }
        .badge-stock { background-color: #EBF3FA; color: #2980B9; padding: 4px 10px; border-radius: 8px; font-weight: 600; font-size: 12px; display: inline-block; }
        .pos-section-box {
            background-color: #FAF8F5;
            border: 1px solid #E8E3DA;
            border-radius: 14px;
            padding: 16px 18px;
            margin-bottom: 14px;
        }
        .pos-section-box h2 {
            font-size: 1.05rem;
            color: #7A5E47;
            margin-bottom: 12px;
            padding-bottom: 6px;
            border-bottom: 1px dashed #D7C9B8;
        }
        .pos-item-grid {
            display: grid;
            grid-template-columns: minmax(180px, 1fr) 86px auto;
            gap: 10px;
            align-items: end;
        }
        .pos-descuento-grid {
            display: grid;
            grid-template-columns: 200px 1fr;
            gap: 14px;
            align-items: center;
        }
        .pos-totales-box {
            background-color: #FAF8F5;
            border: 1px solid #E8E3DA;
            border-radius: 14px;
            padding: 16px 18px;
        }
        @media (max-width: 680px) {
            .pos-item-grid, .pos-descuento-grid { grid-template-columns: 1fr; }
        }
    </style>
</asp:Content>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <div class="dashboard compras-resumen">

        <!-- Botón oculto para compatibilidad -->
        <div class="d-none">
            <asp:Button ID="btnIrReporte" runat="server" Text="Ver Reportes" OnClick="btnIrReporte_Click" />
        </div>

        <!-- PANTALLA 1: RESUMEN DE VENTAS (SEPARADA) -->
        <asp:Panel ID="pnlResumenVentas" runat="server">
            <header class="dashboard-header">
                <div>
                    <p class="dashboard-etiqueta">MÓDULO DE VENTAS &amp; FACTURACIÓN &bull; RESUMEN EJECUTIVO</p>
                    <h1>Resumen de Ventas</h1>
                    <p class="dashboard-descripcion">Seguimiento de facturación comercial, documentos emitidos, despachos y cartera de clientes.</p>
                </div>
            </header>

            <div class="compras-indicadores">
                <section class="card-dermocosmetica compras-kpi">
                    <h2>Ventas del mes</h2>
                    <strong><asp:Literal ID="litVentasMes" runat="server" Mode="Encode" Text="$0" /></strong>
                    <span>Importe facturado vigente, con IVA</span>
                </section>
                <section class="card-dermocosmetica compras-kpi">
                    <h2>Documentos emitidos</h2>
                    <strong><asp:Literal ID="litDocsEmitidos" runat="server" Mode="Encode" Text="0" /></strong>
                    <span>Boletas y facturas registradas</span>
                </section>
                <section class="card-dermocosmetica compras-kpi">
                    <h2>Por despachar</h2>
                    <strong><asp:Literal ID="litPorDespachar" runat="server" Mode="Encode" Text="0" /></strong>
                    <span>Pedidos pendientes o en ruta</span>
                </section>
                <section class="card-dermocosmetica compras-kpi">
                    <h2>Clientes activos</h2>
                    <strong><asp:Literal ID="litClientesActivos" runat="server" Mode="Encode" Text="0" /></strong>
                    <span>Cartera comercial habilitada</span>
                </section>
            </div>

            <div class="compras-paneles">
                <section class="card-dermocosmetica" aria-labelledby="tendencia-ventas">
                    <h2 id="tendencia-ventas">Ventas por mes</h2>
                    <p class="compras-nota">Últimos seis meses · total con IVA</p>
                    <div class="compras-grafico" role="list" aria-label="Importes mensuales de ventas">
                        <asp:Repeater ID="rptMesesVentas" runat="server">
                            <ItemTemplate>
                                <div class="compras-mes" role="listitem">
                                    <span class="compras-importe"><%#: Eval("Importe") %></span>
                                    <div class="compras-barra-espacio" aria-hidden="true"><span style='height: <%#: Eval("Altura") %>%'></span></div>
                                    <span><%#: Eval("Mes") %></span>
                                </div>
                            </ItemTemplate>
                        </asp:Repeater>
                    </div>
                    <asp:Label ID="lblSinVentasMes" runat="server" CssClass="compras-nota d-block mt-3" Visible="false"
                        Text="Aún no hay ventas vigentes registradas en este período." />
                </section>

                <section class="card-dermocosmetica" aria-labelledby="recientes-ventas">
                    <h2 id="recientes-ventas">Ventas recientes</h2>
                    <p class="compras-nota">Últimos cinco documentos emitidos</p>
                    <div class="table-responsive">
                        <asp:GridView ID="gvVentasRecientes" runat="server" AutoGenerateColumns="false" GridLines="None"
                            CssClass="table table-hover" EmptyDataText="Aún no se han emitido documentos de venta.">
                            <Columns>
                                <asp:BoundField DataField="Folio" HeaderText="Documento" />
                                <asp:BoundField DataField="Cliente" HeaderText="Cliente" />
                                <asp:BoundField DataField="FormaPago" HeaderText="Pago" />
                                <asp:BoundField DataField="Importe" HeaderText="Total" />
                            </Columns>
                        </asp:GridView>
                    </div>
                    <% if (PuedeGuardarVentas) { %>
                    <a class="btn btn-outline-secondary" href="<%: ResolveUrl("~/Ventas.aspx?vista=pos") %>">Ir a Punto de Venta</a>
                    <% } else { %>
                    <a class="btn btn-outline-secondary" href="<%: ResolveUrl("~/ReporteVentas.aspx?origen=resumen") %>">Ver Reporte de Ventas</a>
                    <% } %>
                </section>
            </div>
        </asp:Panel>

        <!-- PANTALLA 2: PUNTO DE VENTA (SEPARADA) -->
        <asp:Panel ID="pnlPuntoVenta" runat="server" Visible="false">
            <div style="display: flex; justify-content: space-between; align-items: flex-end; margin-bottom: 24px; flex-wrap: wrap; gap: 14px;">
                <div>
                    <span class="pill-badge" style="font-size: 10px; padding: 4px 12px; margin-bottom: 8px;">M&Oacute;DULO DE VENTAS - FACTURACI&Oacute;N</span>
                    <h1>Punto de Venta (POS)</h1>
                    <p class="text-muted" style="margin-top: 4px;">Emisi&oacute;n de facturas y boletas, verificaci&oacute;n de stock en tiempo real, validaci&oacute;n de cr&eacute;dito y salida FEFO.</p>
                </div>
                <div style="display: flex; gap: 10px; align-items: center; flex-wrap: wrap;">
                    <a href="ReporteVentas.aspx?tipo=7&amp;origen=pos" class="btn btn-outline-secondary">
                        <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" aria-hidden="true"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"></path><polyline points="14 2 14 8 20 8"></polyline><line x1="16" y1="13" x2="8" y2="13"></line><line x1="16" y1="17" x2="8" y2="17"></line><polyline points="10 9 9 9 8 9"></polyline></svg>
                        Reporte Ingresos por Categor&iacute;a
                    </a>
                </div>
            </div>

            <asp:Panel ID="pnlCotizacionInfo" runat="server" Visible="false" CssClass="alert alert-info d-flex justify-content-between align-items-center mb-4">
                <div>
                    <strong>Presupuesto cargado:</strong> <asp:Label ID="lblCotizacionInfo" runat="server"></asp:Label>
                </div>
                <asp:Button ID="btnDesvincularCotizacion" runat="server" Text="Descartar Presupuesto" CssClass="btn btn-sm btn-outline-secondary" OnClick="btnDesvincularCotizacion_Click" />
            </asp:Panel>

            <div class="compras-paneles">
                <!-- TARJETA IZQUIERDA: FORMULARIO DE CARGA -->
                <section class="card-dermocosmetica">
                    <div class="pos-section-box">
                        <h2>1. Datos de la Operaci&oacute;n y Cliente</h2>

                        <div class="row g-3 mb-2">
                            <div class="col-md-6">
                                <label class="form-label">Tipo de Documento</label>
                                <asp:DropDownList ID="ddlTipoDocumento" runat="server" CssClass="form-select">
                                    <asp:ListItem Text="Boleta Electrónica" Value="Boleta"></asp:ListItem>
                                    <asp:ListItem Text="Factura Electrónica" Value="Factura"></asp:ListItem>
                                </asp:DropDownList>
                            </div>
                            <div class="col-md-6">
                                <label class="form-label">Bodega de Salida</label>
                                <asp:DropDownList ID="ddlBodega" runat="server" CssClass="form-select" AutoPostBack="true" OnSelectedIndexChanged="ddlBodega_SelectedIndexChanged" />
                            </div>
                        </div>

                        <div class="mb-2">
                            <label class="form-label">Seleccionar Cliente</label>
                            <asp:DropDownList ID="ddlClientes" runat="server" CssClass="form-select" AutoPostBack="true" OnSelectedIndexChanged="ddlClientes_SelectedIndexChanged"></asp:DropDownList>
                            <div class="mt-2">
                                <asp:Label ID="lblInfoCredito" runat="server" CssClass="d-block" style="font-size: 12.5px;"></asp:Label>
                            </div>
                        </div>

                        <div class="row g-3">
                            <div class="col-md-6">
                                <label class="form-label">Forma de Pago</label>
                                <asp:DropDownList ID="ddlPago" runat="server" CssClass="form-select" AutoPostBack="true" OnSelectedIndexChanged="ddlPago_SelectedIndexChanged">
                                    <asp:ListItem Value="contado">Contado</asp:ListItem>
                                    <asp:ListItem Value="credito">Crédito</asp:ListItem>
                                </asp:DropDownList>
                            </div>
                            <div class="col-md-6">
                                <label class="form-label">Vencimiento si es a Cr&eacute;dito</label>
                                <asp:TextBox ID="txtVence" runat="server" TextMode="Date" CssClass="form-control" />
                            </div>
                        </div>
                    </div>

                    <div class="pos-section-box">
                        <h2>2. Buscar Producto y Validaci&oacute;n de Stock</h2>
                        <div class="pos-item-grid">
                            <div>
                                <label class="form-label">Producto / SKU</label>
                                <asp:DropDownList ID="ddlProductos" runat="server" CssClass="form-select" AutoPostBack="true" OnSelectedIndexChanged="ddlProductos_SelectedIndexChanged"></asp:DropDownList>
                            </div>
                            <div>
                                <label class="form-label">Cantidad</label>
                                <asp:TextBox ID="txtCantidad" runat="server" CssClass="form-control" TextMode="Number" Text="1"></asp:TextBox>
                            </div>
                            <div>
                                <asp:Button ID="btnAgregar" runat="server" Text="+ A&ntilde;adir" CssClass="btn btn-primary" style="height: 38px; white-space: nowrap;" OnClick="btnAgregar_Click" />
                            </div>
                        </div>
                        <div class="mt-2">
                            <asp:Label ID="lblStockDisponible" runat="server" CssClass="badge-stock" Text="Selecciona bodega y producto para ver stock"></asp:Label>
                        </div>
                    </div>

                    <div class="pos-section-box" style="margin-bottom: 0;">
                        <h2>3. Descuentos Comerciales</h2>
                        <div class="pos-descuento-grid">
                            <div>
                                <label class="form-label" for="<%= txtDescuento.ClientID %>">Descuento Comercial (%)</label>
                                <div class="input-group">
                                    <asp:TextBox ID="txtDescuento" runat="server" CssClass="form-control" TextMode="Number" min="0" max="100" step="0.5" Text="0" AutoPostBack="true" OnTextChanged="txtDescuento_TextChanged"></asp:TextBox>
                                    <span class="input-group-text" style="background-color: #F4EFEA; border-color: #dcd3ca; color: #5C4533; font-weight: 600;">%</span>
                                </div>
                            </div>
                            <div style="font-size: 12.5px; color: #736E67; padding-top: 18px;">
                                Porcentaje de rebaja comercial (0% a 100%) aplicado sobre el subtotal bruto antes de emitir el documento.
                            </div>
                        </div>
                    </div>
                </section>

                <!-- TARJETA DERECHA: CARRITO Y TOTALES -->
                <section class="card-dermocosmetica" style="display: flex; flex-direction: column; justify-content: space-between;">
                    <div>
                        <h2 style="margin-bottom: 4px;">Detalle de la Venta</h2>
                        <p class="compras-nota" style="margin-bottom: 14px;">Productos agregados a la transacci&oacute;n actual (descuento FEFO autom&aacute;tico)</p>

                        <div class="table-responsive" style="border: 1px solid #ece7e1; border-radius: 12px;">
                            <asp:GridView ID="gvCarrito" runat="server" CssClass="table table-hover mb-0" AutoGenerateColumns="False" GridLines="None" OnRowCommand="gvCarrito_RowCommand" EmptyDataText="A&uacute;n no hay productos en el carrito.">
                                <Columns>
                                    <asp:BoundField DataField="Nombre" HeaderText="Producto / SKU" />
                                    <asp:BoundField DataField="Precio" HeaderText="Precio" DataFormatString="${0:N0}" HeaderStyle-CssClass="text-end" ItemStyle-CssClass="text-end text-nowrap" />
                                    <asp:BoundField DataField="Cantidad" HeaderText="Cant." HeaderStyle-CssClass="text-center" ItemStyle-CssClass="text-center" />
                                    <asp:BoundField DataField="Subtotal" HeaderText="Subtotal" DataFormatString="${0:N0}" HeaderStyle-CssClass="text-end" ItemStyle-CssClass="text-end text-nowrap fw-semibold" />
                                    <asp:TemplateField>
                                        <ItemTemplate>
                                            <asp:Button ID="btnQuitar" runat="server" CommandName="Quitar" CommandArgument='<%# Container.DataItemIndex %>' Text="Quitar" CssClass="btn btn-outline-danger btn-sm" />
                                        </ItemTemplate>
                                    </asp:TemplateField>
                                </Columns>
                            </asp:GridView>
                        </div>
                    </div>

                    <div style="margin-top: 18px;">
                        <div class="pos-totales-box">
                            <div class="resumen-totales-fila">
                                <span>Subtotal Bruto:</span>
                                <asp:Label ID="lblSubtotalBruto" runat="server" Text="$0"></asp:Label>
                            </div>
                            <div class="resumen-totales-fila">
                                <span>Descuento Aplicado (<asp:Label ID="lblDescuentoPct" runat="server" Text="0%"></asp:Label>):</span>
                                <asp:Label ID="lblDescuento" runat="server" Text="-$0"></asp:Label>
                            </div>
                            <div class="resumen-totales-fila">
                                <span>Monto Neto (Base Imponible):</span>
                                <asp:Label ID="lblNeto" runat="server" Text="$0"></asp:Label>
                            </div>
                            <div class="resumen-totales-fila">
                                <span>IVA D&eacute;bito Fiscal (19%):</span>
                                <asp:Label ID="lblIva" runat="server" Text="$0"></asp:Label>
                            </div>
                            <div class="resumen-totales-fila destacado">
                                <span>Total a Facturar:</span>
                                <asp:Label ID="lblTotal" runat="server" Text="$0"></asp:Label>
                            </div>
                        </div>

                        <div class="mt-3">
                            <asp:Button ID="btnFinalizarVenta" runat="server" Text="Emitir Documento de Venta" CssClass="btn btn-primary w-100" style="padding: 11px 16px;" OnClick="btnFinalizarVenta_Click" />
                        </div>
                        <asp:Label ID="lblMensajeVenta" runat="server" style="display:block; margin-top:10px; font-weight:600;"></asp:Label>
                    </div>
                </section>
            </div>
        </asp:Panel>

    </div>
</asp:Content>
