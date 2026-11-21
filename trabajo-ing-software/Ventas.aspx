<%@ Page Title="Resumen de Ventas" Language="C#" MasterPageFile="~/Contabilidad.Master" AutoEventWireup="true" CodeBehind="Ventas.aspx.cs" Inherits="trabajo_ing_software.Ventas" ResponseEncoding="utf-8" %>

<asp:Content ID="Estilos" ContentPlaceHolderID="EstilosPagina" runat="server">
    <link href="<%: ResolveUrl("~/Content/ComprasResumen.css?v=3") %>" rel="stylesheet" />
    <style>
        .card-dermocosmetica h2 { font-size: 1.25rem; font-weight: 600; margin-bottom: 14px; }
        .form-label { font-size: 0.875rem; font-weight: 500; color: #24211e; margin-bottom: 6px; }
        .table { font-size: 0.85rem; }
        .table th { font-size: 0.85rem; }
        .table td { font-size: 0.85rem; }
        .resumen-totales-fila { display: flex; justify-content: space-between; margin-bottom: 6px; font-size: 0.875rem; color: #555; }
        .resumen-totales-fila.destacado { font-weight: 700; color: #24211e; font-size: 1.25rem; border-top: 1px solid #e5e0d8; padding-top: 10px; margin-top: 8px; }
        .badge-credito-ok { background-color: #E8F8F0; color: #27AE60; padding: 4px 10px; border-radius: 8px; font-weight: 600; font-size: 12px; }
        .badge-credito-alerta { background-color: #FDEDEC; color: #C0392B; padding: 4px 10px; border-radius: 8px; font-weight: 600; font-size: 12px; }
        .badge-stock { background-color: #EBF3FA; color: #2980B9; padding: 4px 10px; border-radius: 8px; font-weight: 600; font-size: 12px; }
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
                    <p class="dashboard-etiqueta">Módulo de ventas</p>
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
                    <a class="btn btn-outline-secondary" href="<%: ResolveUrl("~/Ventas.aspx?vista=pos") %>">Ir a Punto de Venta</a>
                </section>
            </div>
        </asp:Panel>

        <!-- PANTALLA 2: PUNTO DE VENTA (SEPARADA) -->
        <asp:Panel ID="pnlPuntoVenta" runat="server" Visible="false">
            <header class="dashboard-header">
                <div>
                    <p class="dashboard-etiqueta">Módulo de ventas · Emisión de documentos</p>
                    <h1>Punto de Venta</h1>
                    <p class="dashboard-descripcion">Emisión de facturas y boletas, verificación de stock en tiempo real, validación de crédito y salida FEFO.</p>
                </div>
            </header>

            <asp:Panel ID="pnlCotizacionInfo" runat="server" Visible="false" CssClass="alert alert-info d-flex justify-content-between align-items-center mb-4">
                <div>
                    <strong>Presupuesto cargado:</strong> <asp:Label ID="lblCotizacionInfo" runat="server"></asp:Label>
                </div>
                <asp:Button ID="btnDesvincularCotizacion" runat="server" Text="Descartar Presupuesto" CssClass="btn btn-sm btn-outline-secondary" OnClick="btnDesvincularCotizacion_Click" />
            </asp:Panel>

            <div class="compras-paneles">
                <!-- TARJETA IZQUIERDA: FORMULARIO DE CARGA -->
                <section class="card-dermocosmetica">
                    <h2 style="margin-bottom: 16px;">1. Datos de la Operación y Cliente</h2>
                    
                    <div class="row g-3 mb-3">
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

                    <div class="mb-3">
                        <label class="form-label">Seleccionar Cliente</label>
                        <asp:DropDownList ID="ddlClientes" runat="server" CssClass="form-select" AutoPostBack="true" OnSelectedIndexChanged="ddlClientes_SelectedIndexChanged"></asp:DropDownList>
                        <div class="mt-2">
                            <asp:Label ID="lblInfoCredito" runat="server" CssClass="d-block" style="font-size: 13px;"></asp:Label>
                        </div>
                    </div>

                    <div class="row g-3 mb-3">
                        <div class="col-md-6">
                            <label class="form-label">Forma de Pago</label>
                            <asp:DropDownList ID="ddlPago" runat="server" CssClass="form-select" AutoPostBack="true" OnSelectedIndexChanged="ddlPago_SelectedIndexChanged">
                                <asp:ListItem Value="contado">Contado</asp:ListItem>
                                <asp:ListItem Value="credito">Crédito</asp:ListItem>
                            </asp:DropDownList>
                        </div>
                        <div class="col-md-6">
                            <label class="form-label">Vencimiento si es a Crédito</label>
                            <asp:TextBox ID="txtVence" runat="server" TextMode="Date" CssClass="form-control" />
                        </div>
                    </div>

                    <hr style="border: 0; border-top: 1px solid #e5e0d8; margin: 24px 0;" />

                    <h2 style="margin-bottom: 16px;">2. Buscar Producto y Validación de Stock</h2>
                    
                    <div class="row g-3">
                        <div class="col-md-8">
                            <label class="form-label">Producto / SKU</label>
                            <asp:DropDownList ID="ddlProductos" runat="server" CssClass="form-select" AutoPostBack="true" OnSelectedIndexChanged="ddlProductos_SelectedIndexChanged"></asp:DropDownList>
                            <div class="mt-1">
                                <asp:Label ID="lblStockDisponible" runat="server" CssClass="badge-stock" Text="Selecciona bodega y producto para ver stock"></asp:Label>
                            </div>
                        </div>
                        <div class="col-md-4">
                            <label class="form-label">Cantidad</label>
                            <asp:TextBox ID="txtCantidad" runat="server" CssClass="form-control" TextMode="Number" Text="1"></asp:TextBox>
                        </div>
                        <div class="col-12 mt-3 text-end">
                            <asp:Button ID="btnAgregar" runat="server" Text="Añadir al Carrito +" CssClass="btn btn-outline-secondary" OnClick="btnAgregar_Click" />
                        </div>
                    </div>

                    <hr style="border: 0; border-top: 1px solid #e5e0d8; margin: 24px 0;" />

                    <h2 style="margin-bottom: 16px;">3. Descuentos Comerciales</h2>
                    <div class="row g-3">
                        <div class="col-md-6">
                            <label class="form-label">Descuento Global ($)</label>
                            <asp:TextBox ID="txtDescuento" runat="server" CssClass="form-control" TextMode="Number" Text="0" AutoPostBack="true" OnTextChanged="txtDescuento_TextChanged"></asp:TextBox>
                            <small class="text-muted">Rebaja comercial directa al valor de la venta.</small>
                        </div>
                    </div>
                </section>

                <!-- TARJETA DERECHA: CARRITO Y TOTALES -->
                <section class="card-dermocosmetica">
                    <h2 style="margin-bottom: 6px;">Detalle de la Venta</h2>
                    <p class="compras-nota" style="margin-bottom: 16px;">Productos agregados a la transacción actual (Descuento FEFO automático)</p>
                    
                    <div class="table-responsive">
                        <asp:GridView ID="gvCarrito" runat="server" CssClass="table table-hover" AutoGenerateColumns="False" GridLines="None" OnRowCommand="gvCarrito_RowCommand" EmptyDataText="Aún no hay productos en el carrito.">
                            <Columns>
                                <asp:BoundField DataField="Nombre" HeaderText="Producto / SKU" />
                                <asp:BoundField DataField="Precio" HeaderText="Precio" DataFormatString="${0:N0}" />
                                <asp:BoundField DataField="Cantidad" HeaderText="Cant." />
                                <asp:BoundField DataField="Subtotal" HeaderText="Subtotal" DataFormatString="${0:N0}" />
                                <asp:TemplateField>
                                    <ItemTemplate>
                                        <asp:Button ID="btnQuitar" runat="server" CommandName="Quitar" CommandArgument='<%# Container.DataItemIndex %>' Text="Quitar" CssClass="btn btn-outline-danger btn-sm" />
                                    </ItemTemplate>
                                </asp:TemplateField>
                            </Columns>
                        </asp:GridView>
                    </div>

                    <div style="margin-top: 24px; border-top: 1px solid #e5e0d8; padding-top: 16px;">
                        <div class="resumen-totales-fila">
                            <span>Subtotal Bruto:</span>
                            <asp:Label ID="lblSubtotalBruto" runat="server" Text="$0"></asp:Label>
                        </div>
                        <div class="resumen-totales-fila">
                            <span>Descuento Aplicado:</span>
                            <asp:Label ID="lblDescuento" runat="server" Text="-$0"></asp:Label>
                        </div>
                        <div class="resumen-totales-fila">
                            <span>Monto Neto (Base Imponible):</span>
                            <asp:Label ID="lblNeto" runat="server" Text="$0"></asp:Label>
                        </div>
                        <div class="resumen-totales-fila">
                            <span>IVA Débito Fiscal (19%):</span>
                            <asp:Label ID="lblIva" runat="server" Text="$0"></asp:Label>
                        </div>
                        <div class="resumen-totales-fila destacado">
                            <span>Total a Facturar:</span>
                            <asp:Label ID="lblTotal" runat="server" Text="$0"></asp:Label>
                        </div>

                        <div class="text-end mt-4">
                            <asp:Button ID="btnFinalizarVenta" runat="server" Text="Emitir Documento de Venta" CssClass="btn btn-primary w-100" OnClick="btnFinalizarVenta_Click" />
                        </div>
                        <asp:Label ID="lblMensajeVenta" runat="server" style="display:block; margin-top:12px; font-weight:600;"></asp:Label>
                    </div>
                </section>
            </div>
        </asp:Panel>

    </div>
</asp:Content>
