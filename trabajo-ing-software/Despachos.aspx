<%@ Page Title="Gestión de Despachos" Language="C#" MasterPageFile="~/Contabilidad.Master" AutoEventWireup="true" CodeBehind="Despachos.aspx.cs" Inherits="trabajo_ing_software.Despachos" ResponseEncoding="utf-8" %>

<asp:Content ID="Estilos" ContentPlaceHolderID="EstilosPagina" runat="server">
    <link href="<%: ResolveUrl("~/Content/ComprasResumen.css?v=1") %>" rel="stylesheet" />
    <style>
        .card-dermocosmetica h2 { font-size: 1.25rem; font-weight: 600; margin-bottom: 14px; }
        .form-label { font-size: 0.875rem; font-weight: 500; color: #24211e; margin-bottom: 6px; }
        .table { font-size: 0.79rem; }
        .table th { font-size: 0.73rem; white-space: nowrap; text-transform: uppercase; letter-spacing: 0.35px; padding: 9px 6px !important; }
        .table td { font-size: 0.79rem; padding: 9px 6px !important; vertical-align: middle; }
        .badge-pendiente { background-color: #FFF3CD; color: #856404; padding: 3px 9px; border-radius: 12px; font-weight: 600; font-size: 11px; display: inline-block; white-space: nowrap; }
        .badge-preparacion { background-color: #EBF3FA; color: #2980B9; padding: 3px 9px; border-radius: 12px; font-weight: 600; font-size: 11px; display: inline-block; white-space: nowrap; }
        .badge-ruta { background-color: #F3E5F5; color: #6A1B9A; padding: 3px 9px; border-radius: 12px; font-weight: 600; font-size: 11px; display: inline-block; white-space: nowrap; }
        .badge-entregado { background-color: #E8F8F0; color: #27AE60; padding: 3px 9px; border-radius: 12px; font-weight: 600; font-size: 11px; display: inline-block; white-space: nowrap; }
        .badge-cancelado { background-color: #FDEDEC; color: #C0392B; padding: 3px 9px; border-radius: 12px; font-weight: 600; font-size: 11px; display: inline-block; white-space: nowrap; }
        .desp-acciones-fila {
            display: inline-flex;
            align-items: center;
            gap: 4px;
            flex-wrap: nowrap;
            white-space: nowrap;
        }
        .desp-btn-sm {
            padding: 4px 8px !important;
            font-size: 0.72rem !important;
            white-space: nowrap !important;
        }
    </style>
</asp:Content>

<asp:Content ID="Contenido" ContentPlaceHolderID="MainContent" runat="server">
    <div class="dashboard compras-resumen">
        
        <div style="display: flex; justify-content: space-between; align-items: flex-end; margin-bottom: 24px; flex-wrap: wrap; gap: 14px;">
            <div>
                <span class="pill-badge" style="font-size: 10px; padding: 4px 12px; margin-bottom: 8px;">M&Oacute;DULO DE VENTAS - LOG&Iacute;STICA Y DISTRIBUCI&Oacute;N</span>
                <h1>Gesti&oacute;n y Control de Despachos</h1>
                <p class="text-muted" style="margin-top: 4px;">Programaci&oacute;n de env&iacute;os, asignaci&oacute;n de transportistas, seguimiento de ruta y registro de entregas.</p>
            </div>
            <div class="compras-acciones" style="display: flex; gap: 10px; flex-wrap: wrap;">
                <% if (!EsBodegueroVentas) { %>
                <a href="ReporteVentas.aspx?tipo=8&amp;origen=despachos" class="btn btn-outline-secondary">
                    <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" aria-hidden="true"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"></path><polyline points="14 2 14 8 20 8"></polyline><line x1="16" y1="13" x2="8" y2="13"></line><line x1="16" y1="17" x2="8" y2="17"></line></svg>
                    Efectividad de Entregas
                </a>
                <% } %>
                <% if (PuedeGuardarVentas) { %>
                <button type="button" class="btn btn-primary" onclick="abrirModalDespacho();">+ Programar Despacho</button>
                <% } %>
            </div>
        </div>

        <input type="hidden" id="hdnModalDespAbierto" name="modalDespAbierto" value="<%= (Request.Form["modalDespAbierto"] == "1" && lblMensajeDespacho.ForeColor != System.Drawing.Color.Green) ? "1" : "0" %>" />
        <div id="bannerEstadoDesp" style="display:none; margin-bottom: 16px;" class="alert alert-success"></div>

        <!-- MODAL FLOTANTE: FORMULARIO DE PROGRAMACIÓN -->
        <div id="modalDespacho" class="modal-overlay" style="<%= (Request.Form["modalDespAbierto"] == "1" && lblMensajeDespacho.ForeColor != System.Drawing.Color.Green) ? "display:flex;" : "display:none;" %>">
        <section class="modal-content-card modal-lg-card">
            <div class="modal-header-dermo">
                <div>
                    <span class="pill-badge" style="font-size: 10px; padding: 3px 10px;">LOG&Iacute;STICA Y DISTRIBUCI&Oacute;N</span>
                    <h2 style="font-size: 22px; margin: 6px 0 2px 0; font-family: 'Playfair Display', Georgia, serif; color: var(--color-texto);">Programar Nuevo Despacho</h2>
                    <div style="font-size: 12px; color: var(--color-texto-suave);">Asignaci&oacute;n de documento de venta, transportista y fecha estimada</div>
                </div>
                <button type="button" class="btn btn-outline-secondary btn-sm modal-close-x" onclick="cerrarModalDespacho();" title="Cerrar ventana">&times;</button>
            </div>
            
            <div class="row g-3">
                <div class="col-md-4">
                    <label class="form-label">Documento de Venta *</label>
                    <asp:DropDownList ID="ddlDocumentoOrigen" runat="server" CssClass="form-select" AutoPostBack="true"></asp:DropDownList>
                </div>
                <div class="col-md-4">
                    <label class="form-label">Cliente Destinatario</label>
                    <asp:TextBox ID="txtCliente" runat="server" CssClass="form-control" ReadOnly="true" Placeholder="Se completa automáticamente..."></asp:TextBox>
                </div>
                <div class="col-md-4">
                    <label class="form-label">Estado Inicial del Despacho</label>
                    <asp:DropDownList ID="ddlEstadoDespacho" runat="server" CssClass="form-select">
                        <asp:ListItem Text="Pendiente de Preparación" Value="Pendiente"></asp:ListItem>
                        <asp:ListItem Text="En Preparación (Bodega)" Value="En Preparacion"></asp:ListItem>
                        <asp:ListItem Text="En Ruta / Despachado" Value="En Ruta"></asp:ListItem>
                        <asp:ListItem Text="Entregado al Cliente" Value="Entregado"></asp:ListItem>
                    </asp:DropDownList>
                </div>

                <div class="col-md-4">
                    <label class="form-label">Fecha Estimada de Entrega *</label>
                    <asp:TextBox ID="txtFechaEstimada" runat="server" CssClass="form-control" TextMode="Date"></asp:TextBox>
                </div>
                <div class="col-md-4">
                    <label class="form-label">Transportista Asignado *</label>
                    <asp:DropDownList ID="ddlTransportista" runat="server" CssClass="form-select">
                        <asp:ListItem Text="-- Seleccione Transportista --" Value=""></asp:ListItem>
                        <asp:ListItem Text="Starken Express" Value="Starken"></asp:ListItem>
                        <asp:ListItem Text="Chilexpress Courier" Value="Chilexpress"></asp:ListItem>
                        <asp:ListItem Text="Blue Express" Value="Blue Express"></asp:ListItem>
                        <asp:ListItem Text="Flota Propia Dermo" Value="Reparto Propio"></asp:ListItem>
                    </asp:DropDownList>
                </div>
                <div class="col-md-4">
                    <label class="form-label">Observaciones / Dirección Entrega</label>
                    <asp:TextBox ID="txtObservaciones" runat="server" CssClass="form-control" Placeholder="Ej: Dejar en conserjería..."></asp:TextBox>
                </div>

                <div class="col-12 modal-footer-dermo align-items-center justify-content-between">
                    <div>
                        <asp:Label ID="lblMensajeDespacho" runat="server" style="font-weight:600;"></asp:Label>
                    </div>
                    <div class="d-flex gap-2">
                        <button type="button" class="btn btn-outline-secondary" onclick="cerrarModalDespacho();">Cancelar</button>
                        <asp:Button ID="btnGuardarDespacho" runat="server" Text="Programar Despacho" CssClass="btn btn-primary" OnClick="btnGuardarDespacho_Click" />
                    </div>
                </div>
            </div>
        </section>
        </div>

        <script>
            function abrirModalDespacho() {
                document.getElementById('hdnModalDespAbierto').value = '1';
                document.getElementById('modalDespacho').style.display = 'flex';
            }
            function cerrarModalDespacho() {
                document.getElementById('hdnModalDespAbierto').value = '0';
                document.getElementById('modalDespacho').style.display = 'none';
            }
            (function () {
                var m = document.getElementById('modalDespacho');
                var lbl = document.getElementById('<%= lblMensajeDespacho.ClientID %>');
                var b = document.getElementById('bannerEstadoDesp');
                if (m && m.style.display === 'none' && lbl && lbl.innerText.trim().length > 0 && b) {
                    b.innerText = lbl.innerText.trim();
                    b.style.display = 'block';
                }
            })();
        </script>

        <!-- TARJETA 2: CONTROL DE ESTADOS Y REGISTRO DE ENTREGAS -->
        <section class="card-dermocosmetica">
            <div class="d-flex justify-content-between align-items-center mb-3">
                <h2 style="margin: 0;">Seguimiento y Registro de Entregas</h2>
                <div class="d-flex align-items-center gap-2">
                    <label class="text-secondary small fw-bold mb-0">Filtrar por Estado:</label>
                    <asp:DropDownList ID="ddlFiltroEstado" runat="server" CssClass="form-select form-select-sm" AutoPostBack="true" OnSelectedIndexChanged="ddlFiltroEstado_SelectedIndexChanged" style="width:auto;">
                        <asp:ListItem Text="Todos los despachos" Value="Todos"></asp:ListItem>
                        <asp:ListItem Text="Pendientes" Value="Pendiente"></asp:ListItem>
                        <asp:ListItem Text="En Preparación" Value="En Preparacion"></asp:ListItem>
                        <asp:ListItem Text="En Ruta" Value="En Ruta"></asp:ListItem>
                        <asp:ListItem Text="Entregados" Value="Entregado"></asp:ListItem>
                    </asp:DropDownList>
                </div>
            </div>

            <div class="table-responsive">
                <asp:GridView ID="gvDespachos" runat="server" CssClass="table table-hover" AutoGenerateColumns="False" GridLines="None" OnRowCommand="gvDespachos_RowCommand" EmptyDataText="No hay despachos registrados.">
                    <Columns>
                        <asp:BoundField DataField="IdDespacho" HeaderText="ID" HeaderStyle-CssClass="text-center" ItemStyle-CssClass="text-center" />
                        <asp:BoundField DataField="Documento" HeaderText="Documento" ItemStyle-CssClass="text-nowrap fw-semibold" />
                        <asp:BoundField DataField="Cliente" HeaderText="Cliente" />
                        <asp:BoundField DataField="Tipo" HeaderText="Transportista" ItemStyle-CssClass="text-nowrap" />
                        <asp:BoundField DataField="FechaEstimada" HeaderText="F. Estimada" DataFormatString="{0:dd/MM/yyyy}" HeaderStyle-CssClass="text-center" ItemStyle-CssClass="text-center text-nowrap" />
                        <asp:BoundField DataField="FechaEntrega" HeaderText="F. Entrega" DataFormatString="{0:dd/MM/yyyy}" NullDisplayText="Pendiente" HeaderStyle-CssClass="text-center" ItemStyle-CssClass="text-center text-nowrap" />
                        <asp:TemplateField HeaderText="Estado" HeaderStyle-CssClass="text-center" ItemStyle-CssClass="text-center">
                            <ItemTemplate>
                                <span class='<%# GetClaseEstado(Eval("Estado").ToString()) %>'>
                                    <%# Eval("Estado").ToString() == "En Preparacion" ? "En Preparaci&oacute;n" : Eval("Estado") %>
                                </span>
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:BoundField DataField="Observaciones" HeaderText="Observaciones" NullDisplayText="—" />
                        <asp:TemplateField HeaderText="Acciones" HeaderStyle-CssClass="text-center" ItemStyle-CssClass="text-center text-nowrap">
                            <ItemTemplate>
                                <div class="desp-acciones-fila">
                                    <asp:LinkButton ID="btnPreparar" runat="server" CssClass="btn btn-outline-secondary btn-sm desp-btn-sm"
                                        CommandName="CambiarEstado" CommandArgument='<%# Eval("IdDespacho") + "|En Preparacion" %>'
                                        Visible='<%# Eval("Estado").ToString() == "Pendiente" %>'>
                                        Preparar
                                    </asp:LinkButton>
                                    <asp:LinkButton ID="btnRuta" runat="server" CssClass="btn btn-outline-secondary btn-sm desp-btn-sm"
                                        CommandName="CambiarEstado" CommandArgument='<%# Eval("IdDespacho") + "|En Ruta" %>'
                                        Visible='<%# Eval("Estado").ToString() == "En Preparacion" %>'>
                                        En Ruta
                                    </asp:LinkButton>
                                    <asp:LinkButton ID="btnEntregar" runat="server" CssClass="btn btn-primary btn-sm desp-btn-sm"
                                        CommandName="RegistrarEntrega" CommandArgument='<%# Eval("IdDespacho") %>'
                                        Visible='<%# Eval("Estado").ToString() == "En Ruta" || Eval("Estado").ToString() == "En Preparacion" || Eval("Estado").ToString() == "Pendiente" %>'>
                                        Entregar
                                    </asp:LinkButton>
                                    <asp:LinkButton ID="btnCancelar" runat="server" CssClass="btn btn-outline-danger btn-sm desp-btn-sm"
                                        CommandName="CambiarEstado" CommandArgument='<%# Eval("IdDespacho") + "|Cancelado" %>'
                                        Visible='<%# Eval("Estado").ToString() != "Entregado" && Eval("Estado").ToString() != "Cancelado" %>'
                                        OnClientClick="return confirm('&iquest;Seguro que deseas anular este despacho?');">
                                        Anular
                                    </asp:LinkButton>
                                </div>
                            </ItemTemplate>
                        </asp:TemplateField>
                    </Columns>
                </asp:GridView>
            </div>
        </section>

    </div>
</asp:Content>
