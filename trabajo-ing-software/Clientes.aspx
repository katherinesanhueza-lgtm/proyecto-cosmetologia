<%@ Page Title="Mantenedor de Clientes" Language="C#" MasterPageFile="~/Contabilidad.Master" AutoEventWireup="true" CodeBehind="Clientes.aspx.cs" Inherits="trabajo_ing_software.Clientes" ResponseEncoding="utf-8" %>

<asp:Content ID="Estilos" ContentPlaceHolderID="EstilosPagina" runat="server">
    <link href="<%: ResolveUrl("~/Content/ComprasResumen.css?v=1") %>" rel="stylesheet" />
    <style>
        .card-dermocosmetica h2 { font-size: 1.25rem; font-weight: 600; margin-bottom: 14px; }
        .form-label { font-size: 0.875rem; font-weight: 500; color: #24211e; margin-bottom: 6px; }
        .table { font-size: 0.77rem; }
        .table th { font-size: 0.72rem; white-space: nowrap; text-transform: uppercase; letter-spacing: 0.3px; padding: 9px 5px !important; }
        .table td { font-size: 0.77rem; padding: 9px 5px !important; vertical-align: middle; }
        .badge-activo { background-color: #E8F8F0; color: #27AE60; padding: 3px 8px; border-radius: 12px; font-weight: 600; font-size: 11px; display: inline-block; white-space: nowrap; }
        .badge-inactivo { background-color: #FDEDEC; color: #C0392B; padding: 3px 8px; border-radius: 12px; font-weight: 600; font-size: 11px; display: inline-block; white-space: nowrap; }
        .badge-tipo-cli { background-color: #F5EFEB; color: #5C4533; border: 1px solid #E4DDD3; padding: 2px 7px; border-radius: 10px; font-size: 10.5px; font-weight: 600; display: inline-block; white-space: nowrap; }
        .cli-acciones-fila {
            display: inline-flex;
            align-items: center;
            gap: 4px;
            flex-wrap: nowrap;
            white-space: nowrap;
        }
        .cli-btn-sm {
            padding: 4px 7px !important;
            font-size: 0.71rem !important;
            white-space: nowrap !important;
        }
        .btn-cli-reactivar {
            background-color: #E8F8F0 !important;
            border: 1px solid #A9DFBF !important;
            color: #1E8449 !important;
        }
        .btn-cli-reactivar:hover {
            background-color: #D4EFDF !important;
            border-color: #27AE60 !important;
            color: #196F3D !important;
        }
    </style>
</asp:Content>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <div class="dashboard compras-resumen">
        
        <div style="margin-bottom: 22px;">
            <span class="pill-badge" style="font-size: 10px; padding: 4px 12px; margin-bottom: 8px;">
                M&Oacute;DULO DE VENTAS &amp; COMERCIAL &bull; CARTERA DE CLIENTES
            </span>
            <div style="display: flex; justify-content: space-between; align-items: flex-end; flex-wrap: wrap; gap: 15px;">
                <div>
                    <h1>Mantenedor de Clientes</h1>
                    <p class="text-muted" style="margin: 0; max-width: 750px; line-height: 1.5;">
                        Administraci&oacute;n de cartera de clientes, giro comercial, condiciones de pago y l&iacute;mites de cr&eacute;dito autorizados.
                    </p>
                </div>
                <div style="display: flex; gap: 12px; flex-wrap: wrap;">
                    <a href="ReporteVentas.aspx?tipo=6&amp;origen=clientes" class="btn btn-outline-secondary">
                        <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" aria-hidden="true"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"></path><polyline points="14 2 14 8 20 8"></polyline><line x1="16" y1="13" x2="8" y2="13"></line><line x1="16" y1="17" x2="8" y2="17"></line><polyline points="10 9 9 9 8 9"></polyline></svg>
                        Reporte de Evaluaci&oacute;n
                    </a>
                    <% if (PuedeGuardarVentas) { %>
                    <button type="button" class="btn btn-primary" onclick="abrirModalCliente();">+ Nuevo Cliente</button>
                    <% } %>
                </div>
            </div>
            <!-- Controles antiguos ocultos para compatibilidad -->
            <div class="d-none">
                <asp:Label ID="lblBienvenida" runat="server" Text="Usuario"></asp:Label>
                <asp:Button ID="btnIrVentas" runat="server" OnClick="btnIrVentas_Click" />
                <asp:Button ID="btnLogout" runat="server" OnClick="btnLogout_Click" />
            </div>
        </div>

        <input type="hidden" id="hdnModalClienteAbierto" name="modalClienteAbierto" value="<%= (!string.IsNullOrEmpty(hfIdCliente.Value) || (Request.Form["modalClienteAbierto"] == "1" && lblMensaje.ForeColor != System.Drawing.Color.Green)) ? "1" : "0" %>" />
        <div id="bannerEstadoCliente" style="display:none; margin-bottom: 16px;" class="alert alert-success"></div>

        <!-- MODAL FLOTANTE: FORMULARIO DE CLIENTE -->
        <div id="modalCliente" class="modal-overlay" style="<%= (!string.IsNullOrEmpty(hfIdCliente.Value) || (Request.Form["modalClienteAbierto"] == "1" && lblMensaje.ForeColor != System.Drawing.Color.Green)) ? "display:flex;" : "display:none;" %>">
        <section class="modal-content-card modal-lg-card">
            <div class="modal-header-dermo">
                <div>
                    <span class="pill-badge" style="font-size: 10px; padding: 3px 10px;">CARTERA DE CLIENTES</span>
                    <h2 id="lblTituloForm" runat="server" style="font-size: 22px; margin: 6px 0 2px 0; font-family: 'Playfair Display', Georgia, serif; color: var(--color-texto);">Registrar Nuevo Cliente</h2>
                    <div style="font-size: 12px; color: var(--color-texto-suave);">Datos tributarios, contacto comercial y l&iacute;mite de cr&eacute;dito autorizado</div>
                </div>
                <button type="button" class="btn btn-outline-secondary btn-sm modal-close-x" onclick="cerrarModalCliente();" title="Cerrar ventana">&times;</button>
            </div>
            <asp:HiddenField ID="hfIdCliente" runat="server" />
            
            <div class="row g-3">
                <div class="col-md-3">
                    <label class="form-label">RUT Cliente *</label>
                    <asp:TextBox ID="txtRut" runat="server" CssClass="form-control" Placeholder="Ej: 76.123.456-7"></asp:TextBox>
                </div>
                <div class="col-md-5">
                    <label class="form-label">Razón Social o Nombre Completo *</label>
                    <asp:TextBox ID="txtNombre" runat="server" CssClass="form-control" Placeholder="Ej: Clínica DermoSalud SpA"></asp:TextBox>
                </div>
                <div class="col-md-4">
                    <label class="form-label">Tipo de Cliente</label>
                    <asp:DropDownList ID="ddlCategoria" runat="server" CssClass="form-select">
                        <asp:ListItem Text="Clínica / Centro Estético" Value="Clinica"></asp:ListItem>
                        <asp:ListItem Text="Farmacia / Botica" Value="Farmacia"></asp:ListItem>
                        <asp:ListItem Text="Distribuidor Mayorista" Value="Mayorista"></asp:ListItem>
                        <asp:ListItem Text="Profesional Independiente" Value="Profesional"></asp:ListItem>
                        <asp:ListItem Text="Cliente Particular / Frecuente" Value="Particular"></asp:ListItem>
                    </asp:DropDownList>
                </div>

                <div class="col-md-4">
                    <label class="form-label">Giro Comercial</label>
                    <asp:TextBox ID="txtGiro" runat="server" CssClass="form-control" Placeholder="Ej: Servicios Médicos y Cosmetología"></asp:TextBox>
                </div>
                <div class="col-md-5">
                    <label class="form-label">Dirección Comercial</label>
                    <asp:TextBox ID="txtDireccion" runat="server" CssClass="form-control" Placeholder="Av. Providencia 1234, Of. 502, Santiago"></asp:TextBox>
                </div>
                <div class="col-md-3">
                    <label class="form-label">Persona de Contacto</label>
                    <asp:TextBox ID="txtContacto" runat="server" CssClass="form-control" Placeholder="Dra. Andrea Valenzuela"></asp:TextBox>
                </div>

                <div class="col-md-3">
                    <label class="form-label">Correo Electrónico</label>
                    <asp:TextBox ID="txtCorreo" runat="server" CssClass="form-control" TextMode="Email" Placeholder="contacto@clinica.cl"></asp:TextBox>
                </div>
                <div class="col-md-3">
                    <label class="form-label">Teléfono</label>
                    <asp:TextBox ID="txtTelefono" runat="server" CssClass="form-control" Placeholder="+56 9 8765 4321"></asp:TextBox>
                </div>
                <div class="col-md-3">
                    <label class="form-label">Límite de Crédito ($)</label>
                    <asp:TextBox ID="txtLimiteCredito" runat="server" CssClass="form-control" TextMode="Number" Placeholder="0"></asp:TextBox>
                    <small class="text-muted">Monto máximo autorizado para compras a crédito.</small>
                </div>
                <div class="col-md-3">
                    <label class="form-label">Días de Crédito (Plazo)</label>
                    <asp:TextBox ID="txtDiasCredito" runat="server" CssClass="form-control" TextMode="Number" Placeholder="30"></asp:TextBox>
                    <small class="text-muted">Días habituales de pago acordados.</small>
                </div>

                <div class="col-12 modal-footer-dermo align-items-center justify-content-between">
                    <div>
                        <asp:Label ID="lblMensaje" runat="server" style="font-weight:600; font-size: 13.5px;"></asp:Label>
                    </div>
                    <div class="d-flex gap-2">
                        <button type="button" class="btn btn-outline-secondary" onclick="cerrarModalCliente();" style="<%= string.IsNullOrEmpty(hfIdCliente.Value) ? "" : "display:none;" %>">Cancelar</button>
                        <asp:Button ID="btnCancelar" runat="server" Text="Cancelar Edici&oacute;n" CssClass="btn btn-outline-secondary" Visible="false" OnClick="btnCancelar_Click" />
                        <asp:Button ID="btnGuardar" runat="server" Text="Guardar Cliente" CssClass="btn btn-primary" OnClick="btnGuardar_Click" />
                    </div>
                </div>
            </div>
        </section>
        </div>

        <script>
            function abrirModalCliente() {
                document.getElementById('hdnModalClienteAbierto').value = '1';
                document.getElementById('modalCliente').style.display = 'flex';
                var inp = document.getElementById('<%= txtRut.ClientID %>');
                if (inp) inp.focus();
            }
            function cerrarModalCliente() {
                document.getElementById('hdnModalClienteAbierto').value = '0';
                var btnSrv = document.getElementById('<%= btnCancelar.ClientID %>');
                if (btnSrv) {
                    btnSrv.click();
                    return;
                }
                document.getElementById('modalCliente').style.display = 'none';
            }
            (function () {
                var m = document.getElementById('modalCliente');
                var lbl = document.getElementById('<%= lblMensaje.ClientID %>');
                var b = document.getElementById('bannerEstadoCliente');
                if (m && m.style.display === 'none' && lbl && lbl.innerText.trim().length > 0 && b) {
                    b.innerText = lbl.innerText.trim();
                    b.style.display = 'block';
                }
            })();
        </script>

        <!-- TARJETA 2: LISTADO DE CLIENTES -->
        <section class="card-dermocosmetica">
            <div class="d-flex justify-content-between align-items-center mb-3">
                <h2 style="margin: 0;">Cartera de Clientes Registrados</h2>
                <asp:DropDownList ID="ddlFiltroEstado" runat="server" CssClass="form-select form-select-sm" AutoPostBack="true" OnSelectedIndexChanged="ddlFiltroEstado_SelectedIndexChanged" style="width: auto;">
                    <asp:ListItem Text="Todos los clientes" Value="Todos"></asp:ListItem>
                    <asp:ListItem Text="Solo Activos" Value="Activos" Selected="True"></asp:ListItem>
                    <asp:ListItem Text="Solo Inactivos" Value="Inactivos"></asp:ListItem>
                </asp:DropDownList>
            </div>
            <div class="table-responsive">
                <asp:GridView ID="gvClientes" runat="server" CssClass="table table-hover" AutoGenerateColumns="False" GridLines="None" OnRowCommand="gvClientes_RowCommand" EmptyDataText="No hay clientes registrados en la base de datos.">
                    <Columns>
                        <asp:BoundField DataField="IdCliente" HeaderText="ID" HeaderStyle-CssClass="text-center" ItemStyle-CssClass="text-center" />
                        <asp:BoundField DataField="Rut" HeaderText="RUT" ItemStyle-CssClass="text-nowrap" />
                        <asp:BoundField DataField="Nombre" HeaderText="Raz&oacute;n Social / Nombre" HtmlEncode="false" ItemStyle-CssClass="fw-semibold" />
                        <asp:TemplateField HeaderText="Tipo" HeaderStyle-CssClass="text-center" ItemStyle-CssClass="text-center">
                            <ItemTemplate>
                                <span class="badge-tipo-cli"><%# Eval("Categoria") %></span>
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:BoundField DataField="Giro" HeaderText="Giro" />
                        <asp:BoundField DataField="Contacto" HeaderText="Contacto" />
                        <asp:BoundField DataField="Telefono" HeaderText="Tel&eacute;fono" HtmlEncode="false" ItemStyle-CssClass="text-nowrap" />
                        <asp:BoundField DataField="LimiteCredito" HeaderText="L&iacute;mite" HtmlEncode="false" DataFormatString="${0:N0}" HeaderStyle-CssClass="text-end" ItemStyle-CssClass="text-end text-nowrap fw-semibold" />
                        <asp:TemplateField HeaderText="Plazo" HeaderStyle-CssClass="text-center" ItemStyle-CssClass="text-center text-nowrap">
                            <ItemTemplate><%# Eval("DiasCredito") %> d.</ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Estado" HeaderStyle-CssClass="text-center" ItemStyle-CssClass="text-center">
                            <ItemTemplate>
                                <span class='<%# Convert.ToInt32(Eval("Activo")) == 1 ? "badge-activo" : "badge-inactivo" %>'>
                                    <%# Convert.ToInt32(Eval("Activo")) == 1 ? "Activo" : "Inactivo" %>
                                </span>
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Acciones" HeaderStyle-CssClass="text-center" ItemStyle-CssClass="text-center text-nowrap">
                            <ItemTemplate>
                                <div class="cli-acciones-fila">
                                    <asp:LinkButton ID="btnEditar" runat="server" CssClass="btn btn-outline-secondary btn-sm cli-btn-sm" CommandName="Editar" CommandArgument='<%# Eval("IdCliente") %>'>Editar</asp:LinkButton>
                                    <asp:LinkButton ID="btnEstado" runat="server" CssClass='<%# Convert.ToInt32(Eval("Activo")) == 1 ? "btn btn-outline-danger btn-sm cli-btn-sm" : "btn btn-cli-reactivar btn-sm cli-btn-sm" %>'
                                        CommandName='<%# Convert.ToInt32(Eval("Activo")) == 1 ? "Desactivar" : "Activar" %>'
                                        CommandArgument='<%# Eval("IdCliente") %>'>
                                        <%# Convert.ToInt32(Eval("Activo")) == 1 ? "Desactivar" : "Reactivar" %>
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
