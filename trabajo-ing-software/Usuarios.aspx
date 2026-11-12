<%@ Page Title="Gestión de usuarios" MasterPageFile="~/Contabilidad.Master" Language="C#" AutoEventWireup="true" CodeBehind="Usuarios.aspx.cs" Inherits="trabajo_ing_software.Usuarios" ResponseEncoding="utf-8" ContentType="text/html; charset=utf-8" %>
<asp:Content ID="Recursos" ContentPlaceHolderID="EstilosPagina" runat="server">
    <style>
        .usuarios-container {
            width: 100%;
        }

        .search-bar-wrapper {
            position: relative;
            margin-bottom: 20px;
        }

        .search-icon-pos {
            position: absolute;
            left: 16px;
            top: 50%;
            transform: translateY(-50%);
            color: var(--color-texto-suave);
            display: flex;
            align-items: center;
            pointer-events: none;
        }

        .search-input-pill {
            width: 100%;
            padding: 11px 18px 11px 44px;
            border-radius: 12px;
            border: 1px solid var(--color-borde-suave);
            background-color: var(--color-blanco);
            font-family: inherit;
            font-size: 13px;
            outline: none;
            transition: all 0.2s ease;
        }

        .search-input-pill:focus {
            border-color: var(--color-acento);
            box-shadow: 0 0 0 3px rgba(122, 94, 71, 0.1);
        }

        .modal-overlay {
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: rgba(46, 46, 46, 0.45);
            backdrop-filter: blur(4px);
            display: flex;
            align-items: center;
            justify-content: center;
            z-index: 2000;
        }

        .modal-content-card {
            background: var(--color-blanco);
            border-radius: 22px;
            width: 90%;
            max-width: 560px;
            max-height: 90vh;
            overflow-y: auto;
            box-shadow: 0 10px 40px rgba(0,0,0,0.15);
            border: 1px solid var(--color-borde-suave);
            padding: 30px;
        }
    </style>
</asp:Content>

<asp:Content ID="Acciones" ContentPlaceHolderID="AccionesUsuario" runat="server">
    <asp:Label ID="lblBienvenida" Visible="false" runat="server" Font-Bold="true" Font-Size="13px"></asp:Label>
    <asp:Button ID="btnLogout" runat="server" Text="Cerrar Sesi&oacute;n" CssClass="btn btn-outline-secondary btn-sm cierre-compras" OnClick="btnLogout_Click" />
</asp:Content>

<asp:Content ID="Contenido" ContentPlaceHolderID="MainContent" runat="server">
    <div class="dashboard compras-contenido">
        <asp:HiddenField ID="hfIdUsuario" runat="server" Value="" />

        <div class="usuarios-container">
            <!-- TITULO Y BOTONES -->
            <div style="display: flex; justify-content: space-between; align-items: flex-end; margin-bottom: 22px; flex-wrap: wrap; gap: 14px;">
                <div>
                    <span class="pill-badge" style="font-size: 10px; padding: 4px 12px; margin-bottom: 8px;">ADMINISTRACI&Oacute;N &amp; SEGURIDAD</span>
                    <h1>Gesti&oacute;n de Usuarios</h1>
                    <p class="text-muted" style="margin: 0;">Administraci&oacute;n de cuentas comerciales, permisos y roles de la distribuidora.</p>
                </div>
                <div style="display: flex; gap: 10px; align-items: center; flex-wrap: wrap;">
                    <asp:LinkButton ID="btnAbrirJefaturas" runat="server" CssClass="btn btn-outline-secondary" OnClick="btnAbrirJefaturas_Click" style="display: inline-flex; align-items: center; gap: 6px;">
                        <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M12 11c0 3.517-1.009 6.799-2.753 9.571m-3.44-2.04l.054-.09A13.916 13.916 0 008 11a4 4 0 118 0c0 1.017-.07 2.019-.203 3m-2.118 6.844A21.88 21.88 0 0015.171 17m3.839 1.132c.645-2.266.99-4.659.99-7.132A8 8 0 004 11m0 0a8 8 0 0014.288 5.67"></path></svg>
                        Firmas y Jefaturas
                    </asp:LinkButton>
                    <button type="button" class="btn btn-primary" onclick="toggleFormulario();">
                        + Crear Nuevo Usuario
                    </button>
                </div>
            </div>

            <!-- FORMULARIO DESPLEGABLE DE REGISTRO & EDICION -->
            <div id="panelFormulario" class="card-dermocosmetica" style="margin-bottom: 25px; <%= string.IsNullOrEmpty(hfIdUsuario.Value) ? "display:none;" : "display:block;" %>">
                <h3 id="lblTituloForm" runat="server" style="font-size: 18px; margin-bottom: 16px;">
                    Registrar Nuevo Usuario
                </h3>

                <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 15px;">
                    <div class="form-group-dermo">
                        <label class="form-label">Nombre Completo *</label>
                        <asp:TextBox ID="txtNombre" runat="server" CssClass="form-control" placeholder="Ej: Ana Garc&iacute;a"></asp:TextBox>
                    </div>
                    <div class="form-group-dermo">
                        <label class="form-label">Correo Electr&oacute;nico *</label>
                        <asp:TextBox ID="txtCorreo" runat="server" CssClass="form-control" placeholder="ana.garcia@dermo.cl"></asp:TextBox>
                    </div>
                    <div class="form-group-dermo">
                        <label class="form-label">Contrase&ntilde;a <small class="text-muted">(opcional al editar)</small></label>
                        <asp:TextBox ID="txtPassword" runat="server" TextMode="Password" CssClass="form-control" placeholder="••••••••"></asp:TextBox>
                    </div>
                    <div class="form-group-dermo">
                        <label class="form-label">Rol Asignado *</label>
                        <asp:DropDownList ID="ddlRol" runat="server" CssClass="form-select">
                            <asp:ListItem Text="-- Seleccione Rol --" Value="" />
                            <asp:ListItem Text="Administrador" Value="Administrador" />
                            <asp:ListItem Text="Comprador" Value="Comprador" />
                            <asp:ListItem Text="Vendedor" Value="Vendedor" />
                            <asp:ListItem Text="Contador" Value="Contador" />
                            <asp:ListItem Text="Bodeguero" Value="Bodeguero" />
                            <asp:ListItem Text="Usuario general" Value="Usuario general" />
                        </asp:DropDownList>
                    </div>
                </div>

                <div style="display: flex; gap: 10px; margin-top: 15px;">
                    <asp:Button ID="btnGuardar" runat="server" Text="Guardar Usuario" CssClass="btn btn-primary" OnClick="btnGuardar_Click" />
                    <asp:Button ID="btnCancelar" runat="server" Text="Cancelar" CssClass="btn btn-outline-secondary" Visible="false" OnClick="btnCancelar_Click" />
                </div>
            </div>

            <asp:Label ID="lblMensaje" runat="server" Font-Size="13px" style="display: block; margin-bottom: 14px; font-weight: 500;"></asp:Label>

            <!-- BARRA DE BUSQUEDA -->
            <div class="search-bar-wrapper">
                <span class="search-icon-pos">
                    <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="11" cy="11" r="8"></circle><line x1="21" y1="21" x2="16.65" y2="16.65"></line></svg>
                </span>
                <asp:TextBox ID="txtBuscarUsuario" runat="server" CssClass="search-input-pill" placeholder="Buscar por nombre, correo o rol..." AutoPostBack="true" OnTextChanged="txtBuscarUsuario_TextChanged"></asp:TextBox>
            </div>

            <!-- TABLA DE USUARIOS -->
            <div class="table-dermo-container">
                <asp:GridView ID="gvUsuarios" runat="server" AutoGenerateColumns="False"
                    CssClass="table table-hover align-middle" GridLines="None" OnRowCommand="gvUsuarios_RowCommand" DataKeyNames="IdUsuario">
                    <Columns>
                        <asp:TemplateField HeaderText="NOMBRE COMPLETO">
                            <ItemTemplate>
                                <div style="display: flex; align-items: center;">
                                    <div class="avatar-circle">
                                        <%# GetIniciales(Eval("Nombre").ToString()) %>
                                    </div>
                                    <div>
                                        <span style="font-weight: 600; color: var(--color-texto);"><%# Eval("Nombre") %></span>
                                    </div>
                                </div>
                            </ItemTemplate>
                        </asp:TemplateField>

                        <asp:BoundField DataField="Correo" HeaderText="CORREO ELECTR&Oacute;NICO" HtmlEncode="false" />
                        <asp:BoundField DataField="Rol" HeaderText="ROL" />

                        <asp:TemplateField HeaderText="ESTADO">
                            <ItemTemplate>
                                <span class='<%# Convert.ToBoolean(Eval("Activo")) ? "badge-status-activo" : "badge-status-inactivo" %>'>
                                    <%# Convert.ToBoolean(Eval("Activo")) ? "Activo" : "Inactivo" %>
                                </span>
                            </ItemTemplate>
                        </asp:TemplateField>

                        <asp:TemplateField HeaderText="ACCIONES">
                            <ItemTemplate>
                                <div style="display: flex; gap: 6px; flex-wrap: wrap;">
                                    <asp:Button ID="btnEditar" runat="server" Text="Editar"
                                        CommandName="Editar" CommandArgument='<%# Eval("IdUsuario") %>'
                                        CssClass="btn btn-outline-secondary btn-sm" ToolTip="Editar usuario" />

                                    <asp:Button ID="btnCambiarEstado" runat="server"
                                        Text='<%# Convert.ToBoolean(Eval("Activo")) ? "Desactivar" : "Activar" %>'
                                        CommandName="CambiarEstado"
                                        CommandArgument='<%# Eval("IdUsuario") + ";" + Eval("Activo") %>'
                                        CssClass="btn btn-outline-secondary btn-sm" />

                                    <asp:Button ID="btnEliminar" runat="server" Text="Eliminar"
                                        CommandName="Eliminar" CommandArgument='<%# Eval("IdUsuario") %>'
                                        CssClass="btn btn-outline-danger btn-sm" ToolTip="Eliminar permanentemente"
                                        OnClientClick="return confirm('&iquest;Desea eliminar permanentemente este usuario?');" />
                                </div>
                            </ItemTemplate>
                        </asp:TemplateField>
                    </Columns>
                </asp:GridView>
            </div>

            <!-- BARRA INFERIOR -->
            <div style="display: flex; justify-content: space-between; align-items: center; margin-top: 20px; font-size: 13px; flex-wrap: wrap; gap: 10px;">
                <div style="display: flex; gap: 10px;">
                    <a href="Accesos.aspx" class="btn btn-outline-secondary btn-sm">Asignar Roles</a>
                    <a href="Perfiles.aspx" class="btn btn-outline-secondary btn-sm">Administrar Perfiles</a>
                </div>
                <div style="color: var(--color-texto-suave);">
                    <span>Gesti&oacute;n centralizada de usuarios y jefaturas &bull; Dermo ERP</span>
                </div>
            </div>
        </div>

        <script>
            function toggleFormulario() {
                var p = document.getElementById('panelFormulario');
                if (p.style.display === 'none' || p.style.display === '') {
                    p.style.display = 'block';
                    document.getElementById('<%= txtNombre.ClientID %>').focus();
                } else {
                    p.style.display = 'none';
                }
            }
        </script>

        <!-- MODAL DE CONFIGURACION DE FIRMAS Y JEFATURAS INSTITUCIONALES -->
        <asp:Panel ID="pnlModalJefaturas" runat="server" Visible="false" CssClass="modal-overlay">
            <div class="modal-content-card">
                <div style="display: flex; justify-content: space-between; align-items: center; border-bottom: 1px solid var(--color-borde-suave); padding-bottom: 14px; margin-bottom: 20px;">
                    <div>
                        <span class="pill-badge" style="font-size: 10px; padding: 3px 10px;">RESPONSABLES INSTITUCIONALES</span>
                        <h2 style="font-size: 20px; margin-top: 4px; color: var(--color-texto);">Firmas Oficiales de Jefatura</h2>
                    </div>
                    <asp:Button ID="btnCerrarJefaturas" runat="server" Text="Cerrar" CssClass="btn btn-outline-secondary btn-sm" OnClick="btnCerrarJefaturas_Click" />
                </div>

                <p class="text-muted" style="font-size: 13px; line-height: 1.5; margin-bottom: 20px;">
                    Administraci&oacute;n de los nombres institucionales registrados en <code>ConfiguracionGlobal</code>. Estos nombres figuran oficialmente al pie de las firmas en las &Oacute;rdenes de Compra, Gu&iacute;as de Recepci&oacute;n y Reportes.
                </p>

                <div class="form-group-dermo" style="margin-bottom: 16px;">
                    <label class="form-label" style="font-weight: 700;">Jefatura M&oacute;dulo de Compras y Abastecimiento</label>
                    <asp:TextBox ID="txtJefeCompras" runat="server" CssClass="form-control" placeholder="Nombre completo para firmas de OC"></asp:TextBox>
                </div>

                <div class="form-group-dermo" style="margin-bottom: 16px;">
                    <label class="form-label" style="font-weight: 700;">Jefatura M&oacute;dulo de Ventas y Facturaci&oacute;n</label>
                    <asp:TextBox ID="txtJefeVentas" runat="server" CssClass="form-control" placeholder="Nombre completo para firmas de reportes"></asp:TextBox>
                </div>

                <div class="form-group-dermo" style="margin-bottom: 16px;">
                    <label class="form-label" style="font-weight: 700;">Jefatura M&oacute;dulo de Inventario y Kardex</label>
                    <asp:TextBox ID="txtJefeInventario" runat="server" CssClass="form-control" placeholder="Nombre completo para firmas de reportes"></asp:TextBox>
                </div>

                <div class="form-group-dermo" style="margin-bottom: 16px;">
                    <label class="form-label" style="font-weight: 700;">Contador General (Contabilidad y Recibos)</label>
                    <asp:TextBox ID="txtNombreContador" runat="server" CssClass="form-control" placeholder="Nombre del Contador para comprobantes de pago"></asp:TextBox>
                </div>

                <asp:Label ID="lblMensajeJefaturas" runat="server" Font-Size="12.5px" style="display: block; margin-top: 14px;"></asp:Label>

                <div style="display: flex; justify-content: flex-end; gap: 10px; margin-top: 25px; border-top: 1px solid var(--color-borde-suave); padding-top: 15px;">
                    <asp:Button ID="btnCancelarJefaturas" runat="server" Text="Cancelar" CssClass="btn btn-outline-secondary" OnClick="btnCerrarJefaturas_Click" />
                    <asp:Button ID="btnGuardarJefaturas" runat="server" Text="Guardar Firmas" CssClass="btn btn-primary" OnClick="btnGuardarJefaturas_Click" />
                </div>
            </div>
        </asp:Panel>
    </div>
</asp:Content>
