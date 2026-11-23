<%@ Page Title="Cotizaciones y Presupuestos" Language="C#" MasterPageFile="~/Contabilidad.Master" AutoEventWireup="true" CodeBehind="Cotizaciones.aspx.cs" Inherits="trabajo_ing_software.Cotizaciones" ResponseEncoding="utf-8" %>

<asp:Content ID="Estilos" ContentPlaceHolderID="EstilosPagina" runat="server">
    <link href="<%: ResolveUrl("~/Content/ComprasResumen.css?v=1") %>" rel="stylesheet" />
    <style>
        .card-dermocosmetica h2 { font-size: 1.25rem; font-weight: 600; margin-bottom: 14px; }
        .card-dermocosmetica h3 { font-size: 1.25rem; font-weight: 700; color: #24211e; }
        .form-label { font-size: 0.875rem; font-weight: 500; color: #24211e; margin-bottom: 6px; }
        .table { font-size: 0.85rem; }
        .table th { font-size: 0.85rem; }
        .table td { font-size: 0.85rem; }
        .badge-vigente { background-color: #EBF3FA; color: #2980B9; padding: 4px 10px; border-radius: 12px; font-weight: 600; font-size: 12px; }
        .badge-aceptado { background-color: #E8F8F0; color: #27AE60; padding: 4px 10px; border-radius: 12px; font-weight: 600; font-size: 12px; }
        .badge-vencido { background-color: #FFF3CD; color: #856404; padding: 4px 10px; border-radius: 12px; font-weight: 600; font-size: 12px; }
        .badge-rechazado { background-color: #FDEDEC; color: #C0392B; padding: 4px 10px; border-radius: 12px; font-weight: 600; font-size: 12px; }
    </style>
</asp:Content>

<asp:Content ID="Contenido" ContentPlaceHolderID="MainContent" runat="server">
    <div class="dashboard compras-resumen">
        
        <div style="display: flex; justify-content: space-between; align-items: flex-end; margin-bottom: 24px; flex-wrap: wrap; gap: 14px;">
            <div>
                <span class="pill-badge" style="font-size: 10px; padding: 4px 12px; margin-bottom: 8px;">M&Oacute;DULO DE VENTAS - GESTI&Oacute;N COMERCIAL</span>
                <h1>Presupuestos y Cotizaciones</h1>
                <p class="text-muted" style="margin-top: 4px;">Generaci&oacute;n de presupuestos con per&iacute;odos de validez y conversi&oacute;n directa a ventas.</p>
            </div>
            <div style="display: flex; gap: 10px; flex-wrap: wrap;">
                <a href="ReporteVentas.aspx?tipo=5&amp;origen=cotizaciones" class="btn btn-outline-secondary">
                    <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" aria-hidden="true"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"></path><polyline points="14 2 14 8 20 8"></polyline><line x1="16" y1="13" x2="8" y2="13"></line><line x1="16" y1="17" x2="8" y2="17"></line><polyline points="10 9 9 9 8 9"></polyline></svg>
                    Reporte Tasa Conversi&oacute;n
                </a>
                <button type="button" class="btn btn-primary" onclick="abrirModalCotizacion();">+ Nueva Cotizaci&oacute;n</button>
            </div>
        </div>

        <input type="hidden" id="hdnModalCotAbierto" name="modalCotAbierto" value="<%= (Request.Form["modalCotAbierto"] == "1" && lblMensajeCotizacion.ForeColor != System.Drawing.Color.Green) ? "1" : "0" %>" />
        <div id="bannerEstadoCot" style="display:none; margin-bottom: 16px;" class="alert alert-success"></div>

        <!-- MODAL FLOTANTE: FORMULARIO DE COTIZACIÓN -->
        <div id="modalCotizacion" class="modal-overlay" style="<%= (Request.Form["modalCotAbierto"] == "1" && lblMensajeCotizacion.ForeColor != System.Drawing.Color.Green) ? "display:flex;" : "display:none;" %>">
        <section class="modal-content-card modal-lg-card">
            <div class="modal-header-dermo">
                <div>
                    <span class="pill-badge" style="font-size: 10px; padding: 3px 10px;">GESTI&Oacute;N COMERCIAL</span>
                    <h2 style="font-size: 22px; margin: 6px 0 2px 0; font-family: 'Playfair Display', Georgia, serif; color: var(--color-texto);">Generar Nueva Cotizaci&oacute;n</h2>
                    <div style="font-size: 12px; color: var(--color-texto-suave);">Selecci&oacute;n de cliente, vigencia y productos del presupuesto</div>
                </div>
                <button type="button" class="btn btn-outline-secondary btn-sm modal-close-x" onclick="cerrarModalCotizacion();" title="Cerrar ventana">&times;</button>
            </div>
            
            <div class="row g-3">
                <div class="col-md-4">
                    <label class="form-label">Cliente *</label>
                    <asp:DropDownList ID="ddlClientes" runat="server" CssClass="form-select"></asp:DropDownList>
                </div>
                <div class="col-md-4">
                    <label class="form-label">Período de Validez (Vence) *</label>
                    <asp:TextBox ID="txtFechaVencimiento" runat="server" CssClass="form-control" TextMode="Date"></asp:TextBox>
                    <small class="text-muted">Fecha límite de vigencia de las condiciones y precios.</small>
                </div>
                <div class="col-md-4">
                    <label class="form-label">Estado Inicial</label>
                    <asp:DropDownList ID="ddlEstado" runat="server" CssClass="form-select">
                        <asp:ListItem Text="Vigente" Value="Vigente"></asp:ListItem>
                        <asp:ListItem Text="Aceptado" Value="Aceptado"></asp:ListItem>
                        <asp:ListItem Text="Vencido" Value="Vencido"></asp:ListItem>
                        <asp:ListItem Text="Rechazado" Value="Rechazado"></asp:ListItem>
                    </asp:DropDownList>
                </div>
                
                <div class="col-12 mt-4">
                    <h6 class="text-secondary fw-bold border-bottom pb-2">Agregar Productos al Presupuesto</h6>
                </div>
                
                <div class="col-md-5">
                    <label class="form-label">Producto / SKU</label>
                    <asp:DropDownList ID="ddlProductos" runat="server" CssClass="form-select" AutoPostBack="true" OnSelectedIndexChanged="ddlProductos_SelectedIndexChanged"></asp:DropDownList>
                </div>
                <div class="col-md-2">
                    <label class="form-label">Cantidad</label>
                    <asp:TextBox ID="txtCantidad" runat="server" CssClass="form-control" TextMode="Number" Text="1"></asp:TextBox>
                </div>
                <div class="col-md-3">
                    <label class="form-label">Precio Unitario ($)</label>
                    <asp:TextBox ID="txtPrecio" runat="server" CssClass="form-control" TextMode="Number" ReadOnly="true"></asp:TextBox>
                </div>
                <div class="col-md-2 d-flex align-items-end">
                    <asp:Button ID="btnAgregarProducto" runat="server" Text="Añadir +" CssClass="btn btn-outline-secondary w-100" OnClick="btnAgregarProducto_Click" />
                </div>

                <div class="col-12 mt-4">
                    <div class="table-responsive">
                        <asp:GridView ID="gvDetalleCotizacion" runat="server" CssClass="table table-hover" AutoGenerateColumns="False" GridLines="None" EmptyDataText="Aún no hay productos en esta cotización.">
                            <Columns>
                                <asp:BoundField DataField="Producto" HeaderText="Producto" />
                                <asp:BoundField DataField="Cantidad" HeaderText="Cantidad" />
                                <asp:BoundField DataField="Precio" HeaderText="Precio Unit." DataFormatString="${0:N0}" />
                                <asp:BoundField DataField="Subtotal" HeaderText="Subtotal" DataFormatString="${0:N0}" />
                            </Columns>
                        </asp:GridView>
                    </div>
                </div>

                <div class="col-12 modal-footer-dermo align-items-center justify-content-between">
                    <div>
                        <asp:Label ID="lblMensajeCotizacion" runat="server" style="font-weight:600;"></asp:Label>
                    </div>
                    <div class="d-flex align-items-center gap-3 flex-wrap">
                        <h3 style="margin: 0;">Total Cotizado: $<asp:Label ID="lblTotal" runat="server" Text="0"></asp:Label></h3>
                        <button type="button" class="btn btn-outline-secondary" onclick="cerrarModalCotizacion();">Cancelar</button>
                        <asp:Button ID="btnGuardarCotizacion" runat="server" Text="Guardar Cotizaci&oacute;n" CssClass="btn btn-primary" OnClick="btnGuardarCotizacion_Click" />
                    </div>
                </div>
            </div>
        </section>
        </div>

        <script>
            function abrirModalCotizacion() {
                document.getElementById('hdnModalCotAbierto').value = '1';
                document.getElementById('modalCotizacion').style.display = 'flex';
            }
            function cerrarModalCotizacion() {
                document.getElementById('hdnModalCotAbierto').value = '0';
                document.getElementById('modalCotizacion').style.display = 'none';
            }
            (function () {
                var m = document.getElementById('modalCotizacion');
                var lbl = document.getElementById('<%= lblMensajeCotizacion.ClientID %>');
                var b = document.getElementById('bannerEstadoCot');
                if (m && m.style.display === 'none' && lbl && lbl.innerText.trim().length > 0 && b) {
                    b.innerText = lbl.innerText.trim();
                    b.style.display = 'block';
                }
            })();
        </script>

        <!-- TARJETA 2: HISTORIAL Y CONVERSIÓN A VENTAS -->
        <section class="card-dermocosmetica">
            <h2 style="margin-bottom: 16px;">Historial de Cotizaciones y Conversión</h2>
            <div class="table-responsive">
                <asp:GridView ID="gvHistorialCotizaciones" runat="server" CssClass="table table-hover" AutoGenerateColumns="False" GridLines="None" OnRowCommand="gvHistorialCotizaciones_RowCommand" EmptyDataText="No hay cotizaciones registradas.">
                    <Columns>
                        <asp:BoundField DataField="IdCotizacion" HeaderText="N° Cot." />
                        <asp:BoundField DataField="Cliente" HeaderText="Cliente" />
                        <asp:BoundField DataField="FechaEmision" HeaderText="Emisión" DataFormatString="{0:dd/MM/yyyy}" />
                        <asp:BoundField DataField="FechaVencimiento" HeaderText="Vencimiento" DataFormatString="{0:dd/MM/yyyy}" NullDisplayText="Sin plazo" />
                        <asp:TemplateField HeaderText="Estado">
                            <ItemTemplate>
                                <span class='<%# GetClaseEstado(Eval("Estado").ToString()) %>'>
                                    <%# Eval("Estado") %>
                                </span>
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:BoundField DataField="Total" HeaderText="Total" DataFormatString="${0:N0}" />
                        <asp:TemplateField HeaderText="Acciones">
                            <ItemTemplate>
                                <asp:LinkButton ID="btnConvertir" runat="server" CssClass="btn btn-primary btn-sm me-1" 
                                    CommandName="ConvertirVenta" CommandArgument='<%# Eval("IdCotizacion") %>'
                                    Visible='<%# Eval("Estado").ToString() == "Vigente" || Eval("Estado").ToString() == "Aceptado" %>'>
                                    Convertir a Venta
                                </asp:LinkButton>
                                <asp:LinkButton ID="btnAceptar" runat="server" CssClass="btn btn-outline-success btn-sm me-1" 
                                    CommandName="MarcarAceptado" CommandArgument='<%# Eval("IdCotizacion") %>'
                                    Visible='<%# Eval("Estado").ToString() == "Vigente" %>'>
                                    Aceptar
                                </asp:LinkButton>
                                <asp:LinkButton ID="btnRechazar" runat="server" CssClass="btn btn-outline-danger btn-sm" 
                                    CommandName="MarcarRechazado" CommandArgument='<%# Eval("IdCotizacion") %>'
                                    Visible='<%# Eval("Estado").ToString() == "Vigente" %>'>
                                    Rechazar
                                </asp:LinkButton>
                            </ItemTemplate>
                        </asp:TemplateField>
                    </Columns>
                </asp:GridView>
            </div>
        </section>

    </div>
</asp:Content>
