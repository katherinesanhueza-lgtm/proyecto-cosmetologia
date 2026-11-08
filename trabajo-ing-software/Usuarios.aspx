<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Usuarios.aspx.cs" Inherits="trabajo_ing_software.Usuarios" ResponseEncoding="utf-8" ContentType="text/html; charset=utf-8" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml" lang="es">
<head runat="server">
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Gesti&oacute;n de Usuarios - Cosmetolog&iacute;a Profesional</title>
    <link rel="preconnect" href="https://fonts.googleapis.com" />
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin="anonymous" />
    <link href="https://fonts.googleapis.com/css2?family=Playfair+Display:ital,wght@0,500;0,600;0,700;1,400;1,500;1,600&family=Plus+Jakarta+Sans:wght@300;400;500;600;700&display=swap" rel="stylesheet" />
    <link href="Content/Estilos.css" rel="stylesheet" type="text/css" />
    <style>
        .usuarios-layout-3col {
            display: grid;
            grid-template-columns: 240px 1fr 310px;
            gap: 25px;
            max-width: 1440px;
            margin: 25px auto 40px auto;
            padding: 0 24px;
            align-items: start;
        }

        .search-bar-wrapper {
            position: relative;
            margin-bottom: 20px;
        }

        .search-icon-pos {
            position: absolute;
            left: 18px;
            top: 50%;
            transform: translateY(-50%);
            color: var(--color-texto-suave);
            display: flex;
            align-items: center;
        }

        .search-input-pill {
            width: 100%;
            padding: 12px 20px 12px 48px;
            border-radius: 25px;
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

        .side-info-card {
            background-color: var(--color-blanco);
            border-radius: 20px;
            border: 1px solid var(--color-borde-suave);
            overflow: hidden;
            margin-bottom: 20px;
            box-shadow: 0 4px 15px rgba(0,0,0,0.02);
        }

        .side-info-img {
            width: 100%;
            height: 140px;
            object-fit: cover;
        }

        .side-info-body {
            padding: 18px 20px;
        }

        @media (max-width: 1100px) {
            .usuarios-layout-3col {
                grid-template-columns: 220px 1fr;
            }
            .right-sidebar-col {
                display: none;
            }
        }

        @media (max-width: 768px) {
            .usuarios-layout-3col {
                grid-template-columns: 1fr;
            }
        }
        /* Modal Overlay */
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
</head>
<body>
    <form id="form1" runat="server">
        <asp:HiddenField ID="hfIdUsuario" runat="server" Value="" />

        <!-- HEADER GLOBAL -->
        <header class="top-header">
            <div class="brand-block">
                <span class="brand-logo">NOMBRE</span>
                <span class="brand-sub">COSMETOLOG&Iacute;A PROFESIONAL</span>
            </div>
            <nav>
                <ul class="nav-links-menu">
                    <% 
                        string rolNav = Session["RolUsuario"] != null ? Session["RolUsuario"].ToString() : "";
                        bool esAdmin = rolNav.Equals("Administrador", StringComparison.OrdinalIgnoreCase);
                        bool esComprador = rolNav.Equals("Comprador", StringComparison.OrdinalIgnoreCase);
                        bool esBodeguero = rolNav.Equals("Bodeguero", StringComparison.OrdinalIgnoreCase);
                        bool esContador = rolNav.Equals("Contador", StringComparison.OrdinalIgnoreCase);
                        bool esVendedor = rolNav.Equals("Vendedor", StringComparison.OrdinalIgnoreCase);

                        // Matriz Oficial RBAC 6.1.2
                        bool puedeVerCompras = esAdmin || esComprador || esContador;
                        bool puedeVerInventario = esAdmin || esBodeguero || esComprador || esContador || esVendedor;
                    %>
                    <li><a href="Default.aspx" class="nav-item-link">Inicio</a></li>

                    <%-- ADMINISTRACIÃ“N (Solo Administrador General) --%>
                    <% if (esAdmin) { %>
                    <li><a href="Usuarios.aspx" class="nav-item-link">Usuarios</a></li>
                    <% } %>

                    <%-- COMPRAS (Admin y Comprador Escritura; Contador Solo Consulta) --%>
                    <% if (esAdmin || esComprador || esContador) { %>
                    <li><a href="Laboratorios.aspx" class="nav-item-link">Laboratorios</a></li>
                    <% } %>
                    <% if (puedeVerCompras) { %>
                    <li><a href="OrdenesCompra.aspx" class="nav-item-link">&Oacute;rdenes de Compra</a></li>
                    <% } %>
                    <% if (esAdmin || esComprador) { %>
                    <li><a href="ReporteProveedores.aspx" class="nav-item-link">Reporte Evaluaci&oacute;n</a></li>
                    <% } %>
                    <% if (puedeVerCompras) { %>
                    <li><a href="ReporteOrdenesCompra.aspx" class="nav-item-link">Reporte &Oacute;rdenes</a></li>
                    <% } %>

                    <%-- INVENTARIO (Bodeguero Escritura; Admin Total; Comprador y Contador Consulta) --%>
                    <% if (esAdmin || esBodeguero || esComprador) { %>
                    <li><a href="Recepciones.aspx" class="nav-item-link">Recepci&oacute;n y Lotes</a></li>
                    <% } %>
                    <% if (puedeVerInventario) { %>
                    <li><a href="ReporteIngresos.aspx" class="nav-item-link">Reporte Ingresos</a></li>
                    <% } %>

                    <%-- ACCESOS (Solo Administrador General) --%>
                    <% if (esAdmin) { %>
                    <li><a href="Accesos.aspx" class="nav-item-link">Accesos</a></li>
                    <% } %>
                </ul>
            </nav>
            <div class="header-actions">
                <asp:Label ID="lblBienvenida" runat="server" Font-Bold="true" Font-Size="13px"></asp:Label>
                <asp:Button ID="btnLogout" runat="server" Text="Cerrar Sesi&oacute;n" CssClass="btn-dermo-secondary" style="padding: 7px 16px; font-size: 12px;" OnClick="btnLogout_Click" />
                <div class="user-avatar-btn" title="Usuario">
                    <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"></path><circle cx="12" cy="7" r="4"></circle></svg>
                </div>
            </div>
        </header>

        <!-- CONTENEDOR 3 COLUMNAS DEL MOCKUP -->
        <div class="usuarios-layout-3col">

            <!-- COLUMNA 1: SIDEBAR IZQUIERDO -->
            <aside class="sidebar-dermo">
                <div class="sidebar-title">DISTRIBUIDORA</div>
                <nav class="sidebar-nav">
                    <a href="Default.aspx" class="sidebar-item">
                        <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="3" y="3" width="7" height="7"></rect><rect x="14" y="3" width="7" height="7"></rect><rect x="14" y="14" width="7" height="7"></rect><rect x="3" y="14" width="7" height="7"></rect></svg>
                        Dashboard
                    </a>
                    <a href="Laboratorios.aspx" class="sidebar-item">
                        <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M21 16V8a2 2 0 0 0-1-1.73l-7-4a2 2 0 0 0-2 0l-7 4A2 2 0 0 0 3 8v8a2 2 0 0 0 1 1.73l7 4a2 2 0 0 0 2 0l7-4A2 2 0 0 0 21 16z"></path></svg>
                        Cat&aacute;logo / Productos
                    </a>
                    <a href="Laboratorios.aspx" class="sidebar-item">
                        <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"></path><polyline points="14 2 14 8 20 8"></polyline><line x1="16" y1="13" x2="8" y2="13"></line><line x1="16" y1="17" x2="8" y2="17"></line><polyline points="10 9 9 9 8 9"></polyline></svg>
                        &Oacute;rdenes &amp; Pedidos
                    </a>
                    <a href="Usuarios.aspx" class="sidebar-item">
                        <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"></path><circle cx="9" cy="7" r="4"></circle><path d="M23 21v-2a4 4 0 0 0-3-3.87"></path><path d="M16 3.13a4 4 0 0 1 0 7.75"></path></svg>
                        Clientes
                    </a>
                    <a href="Usuarios.aspx" class="sidebar-item active">
                        <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"></path><circle cx="12" cy="7" r="4"></circle></svg>
                        Gesti&oacute;n de Usuarios
                    </a>
                    <a href="Laboratorios.aspx" class="sidebar-item">
                        <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="3"></circle><path d="M19.4 15a1.65 1.65 0 0 0 .33 1.82l.06.06a2 2 0 0 1 0 2.83 2 2 0 0 1-2.83 0l-.06-.06a1.65 1.65 0 0 0-1.82-.33 1.65 1.65 0 0 0-1 1.51V21a2 2 0 0 1-2 2 2 2 0 0 1-2-2v-.09A1.65 1.65 0 0 0 9 19.4a1.65 1.65 0 0 0-1.82.33l-.06.06a2 2 0 0 1-2.83 0 2 2 0 0 1 0-2.83l.06-.06a1.65 1.65 0 0 0 .33-1.82 1.65 1.65 0 0 0-1.51-1H3a2 2 0 0 1-2-2 2 2 0 0 1 2-2h.09A1.65 1.65 0 0 0 4.6 9a1.65 1.65 0 0 0-.33-1.82l-.06-.06a2 2 0 0 1 0-2.83 2 2 0 0 1 2.83 0l.06.06a1.65 1.65 0 0 0 1.82.33H9a1.65 1.65 0 0 0 1-1.51V3a2 2 0 0 1 2-2 2 2 0 0 1 2 2v.09a1.65 1.65 0 0 0 1 1.51 1.65 1.65 0 0 0 1.82-.33l.06-.06a2 2 0 0 1 2.83 0 2 2 0 0 1 0 2.83l-.06.06a1.65 1.65 0 0 0-.33 1.82V9a1.65 1.65 0 0 0 1.51 1H21a2 2 0 0 1 2 2 2 2 0 0 1-2 2h-.09a1.65 1.65 0 0 0-1.51 1z"></path></svg>
                        Configuraci&oacute;n
                    </a>
                    <a href="#" class="sidebar-item">
                        <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M3 18v-6a9 9 0 0 1 18 0v6"></path><path d="M21 19a2 2 0 0 1-2 2h-1a2 2 0 0 1-2-2v-3a2 2 0 0 1 2-2h3zM3 19a2 2 0 0 0 2 2h1a2 2 0 0 0 2-2v-3a2 2 0 0 0-2-2H3z"></path></svg>
                        Soporte
                    </a>
                </nav>

                <div style="background-color: #FAF8F5; border: 1px solid var(--color-borde-suave); border-radius: 16px; padding: 16px; margin-top: 30px;">
                    <div style="font-size: 11px; font-weight: 700; color: var(--color-acento); margin-bottom: 6px; display: flex; align-items: center; gap: 6px;">
                        <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"></path></svg>
                        Canal Autorizado
                    </div>
                    <div class="text-muted" style="font-size: 11px; line-height: 1.5;">
                        Garant&iacute;a y trazabilidad farmac&eacute;utica certificada para cl&iacute;nicas y profesionales.
                    </div>
                </div>
            </aside>

            <!-- COLUMNA 2: AREA PRINCIPAL DE GESTION -->
            <main>
                <!-- TITULO Y BOTON CREAR -->
                <div style="display: flex; justify-content: space-between; align-items: flex-start; margin-bottom: 20px;">
                    <div>
                        <h1 style="font-size: 28px; margin-bottom: 6px;">Gesti&oacute;n de Usuarios</h1>
                        <p class="text-muted" style="margin: 0;">Administraci&oacute;n de cuentas comerciales, permisos y roles de la distribuidora.</p>
                    </div>
                    <div style="display: flex; gap: 10px; align-items: center; flex-wrap: wrap;">
                        <asp:LinkButton ID="btnAbrirJefaturas" runat="server" CssClass="btn-dermo-secondary" OnClick="btnAbrirJefaturas_Click" style="border-radius: 25px; padding: 9px 18px; font-size: 13px; text-decoration: none; display: inline-flex; align-items: center; gap: 6px;">
                            <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M12 11c0 3.517-1.009 6.799-2.753 9.571m-3.44-2.04l.054-.09A13.916 13.916 0 008 11a4 4 0 118 0c0 1.017-.07 2.019-.203 3m-2.118 6.844A21.88 21.88 0 0015.171 17m3.839 1.132c.645-2.266.99-4.659.99-7.132A8 8 0 004 11m0 0a8 8 0 0014.288 5.67"></path></svg>
                            Firmas y Jefaturas
                        </asp:LinkButton>
                        <button type="button" class="btn-dermo-primary" onclick="toggleFormulario();" style="border-radius: 25px; padding: 10px 22px; font-size: 13px;">
                            + Crear Nuevo Usuario
                        </button>
                    </div>
                </div>

                <!-- FORMULARIO DESPLEGABLE / MODAL DE REGISTRO & EDICION -->
                <div id="panelFormulario" class="card-dermo-luxury" style="margin-bottom: 25px; <%= string.IsNullOrEmpty(hfIdUsuario.Value) ? "display:none;" : "display:block;" %>">
                    <h3 id="lblTituloForm" runat="server" style="font-size: 18px; margin-bottom: 16px;">
                        Registrar Nuevo Usuario
                    </h3>

                    <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 15px;">
                        <div class="form-group-dermo">
                            <label class="form-label-dermo">Nombre Completo *</label>
                            <asp:TextBox ID="txtNombre" runat="server" CssClass="input-pill-dermo" placeholder="Ej: Ana Garc&iacute;a"></asp:TextBox>
                        </div>
                        <div class="form-group-dermo">
                            <label class="form-label-dermo">Correo Electr&oacute;nico *</label>
                            <asp:TextBox ID="txtCorreo" runat="server" CssClass="input-pill-dermo" placeholder="ana.garcia@dermo.cl"></asp:TextBox>
                        </div>
                        <div class="form-group-dermo">
                            <label class="form-label-dermo">Contrase&ntilde;a <small style="color:gray;">(opcional al editar)</small></label>
                            <asp:TextBox ID="txtPassword" runat="server" TextMode="Password" CssClass="input-pill-dermo" placeholder="••••••••"></asp:TextBox>
                        </div>
                        <div class="form-group-dermo">
                            <label class="form-label-dermo">Rol Asignado *</label>
                            <asp:DropDownList ID="ddlRol" runat="server" CssClass="input-pill-dermo">
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

                    <div style="display: flex; gap: 12px; margin-top: 15px;">
                        <asp:Button ID="btnGuardar" runat="server" Text="Guardar Usuario" CssClass="btn-dermo-primary" OnClick="btnGuardar_Click" style="padding: 10px 24px; font-size: 13px;" />
                        <asp:Button ID="btnCancelar" runat="server" Text="Cancelar" CssClass="btn-dermo-secondary" Visible="false" OnClick="btnCancelar_Click" style="padding: 10px 20px; font-size: 13px;" />
                    </div>

                    <asp:Label ID="lblMensaje" runat="server" Font-Size="13px" style="display: block; margin-top: 12px; font-weight: 500;"></asp:Label>
                </div>

                <!-- BARRA DE BUSQUEDA  -->
                <div class="search-bar-wrapper">
                    <span class="search-icon-pos">
                        <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="11" cy="11" r="8"></circle><line x1="21" y1="21" x2="16.65" y2="16.65"></line></svg>
                    </span>
                    <asp:TextBox ID="txtBuscarUsuario" runat="server" CssClass="search-input-pill" placeholder="Buscar por nombre, correo o rol..." AutoPostBack="true" OnTextChanged="txtBuscarUsuario_TextChanged"></asp:TextBox>
                </div>

                <!-- TABLA ESTILO MOCKUP (AVATARES CON INICIALES) -->
                <div class="table-dermo-container">
                    <asp:GridView ID="gvUsuarios" runat="server" AutoGenerateColumns="False" 
                        CssClass="table-dermo-modern" GridLines="None" OnRowCommand="gvUsuarios_RowCommand" DataKeyNames="IdUsuario">
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
                                    <asp:Button ID="btnEditar" runat="server" Text="Editar" 
                                        CommandName="Editar" CommandArgument='<%# Eval("IdUsuario") %>'
                                        CssClass="btn-action-pill" ToolTip="Editar usuario" />

                                    <asp:Button ID="btnCambiarEstado" runat="server" 
                                        Text='<%# Convert.ToBoolean(Eval("Activo")) ? "Desactivar" : "Activar" %>' 
                                        CommandName="CambiarEstado" 
                                        CommandArgument='<%# Eval("IdUsuario") + ";" + Eval("Activo") %>'
                                        CssClass="btn-action-pill btn-toggle" />

                                    <asp:Button ID="btnEliminar" runat="server" Text="Eliminar" 
                                        CommandName="Eliminar" CommandArgument='<%# Eval("IdUsuario") %>'
                                        CssClass="btn-action-pill btn-delete" ToolTip="Eliminar permanentemente"
                                        OnClientClick="return confirm('&iquest;Desea eliminar permanentemente este usuario?');" />
                                </ItemTemplate>
                            </asp:TemplateField>
                        </Columns>
                    </asp:GridView>
                </div>

                <!-- BARRA INFERIOR DE ACCIONES Y PAGINACION -->
                <div style="display: flex; justify-content: space-between; align-items: center; margin-top: 20px; font-size: 13px;">
                    <div style="display: flex; gap: 10px;">
                        <a href="Accesos.aspx" class="btn-dermo-secondary" style="padding: 8px 16px; font-size: 12px; text-decoration: none;">Asignar Roles</a>
                        <a href="#" class="btn-dermo-secondary" style="padding: 8px 16px; font-size: 12px; text-decoration: none;">Ver Bit&aacute;cora de Auditor&iacute;a</a>
                    </div>
                    <div style="color: var(--color-texto-suave);">
                        <span>P&aacute;gina 1 de 1</span> &bull; <span>Anterior</span> | <span>Siguiente</span>
                    </div>
                </div>
            </main>

            <!-- COLUMNA 3: SIDEBAR DERECHO DE CONTROL Y CALIDAD -->
            <aside class="right-sidebar-col">
                <!-- TARJETA 1: DISTRIBUCION MAYORISTA -->
                <div class="side-info-card">
                    <img src="https://images.unsplash.com/photo-1570172619644-dfd03ed5d881?auto=format&fit=crop&w=500&q=80" alt="Catalogo Mayorista" class="side-info-img" />
                    <div class="side-info-body">
                        <div style="font-size: 10px; font-weight: 700; color: var(--color-secundario); letter-spacing: 0.8px; margin-bottom: 4px;">
                            CAT&Aacute;LOGO EXCLUSIVO
                        </div>
                        <div style="font-weight: 700; font-size: 14px; margin-bottom: 6px;">Distribuci&oacute;n Mayorista</div>
                        <p class="text-muted" style="margin: 0; font-size: 11px; line-height: 1.5;">
                            Acceso a lotes certificados de alta potencia solo habilitados para cuentas verificadas.
                        </p>
                    </div>
                </div>
            </aside>

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

        <!-- MODAL DE CONFIGURACIÓN DE FIRMAS Y JEFATURAS INSTITUCIONALES -->
        <asp:Panel ID="pnlModalJefaturas" runat="server" Visible="false" CssClass="modal-overlay">
            <div class="modal-content-card">
                <div style="display: flex; justify-content: space-between; align-items: center; border-bottom: 1px solid var(--color-borde-suave); padding-bottom: 14px; margin-bottom: 20px;">
                    <div>
                        <span class="pill-badge" style="font-size: 10px; padding: 3px 10px;">RESPONSABLES INSTITUCIONALES</span>
                        <h2 style="font-size: 20px; margin-top: 4px; color: var(--color-texto);">Firmas Oficiales de Jefatura</h2>
                    </div>
                    <asp:Button ID="btnCerrarJefaturas" runat="server" Text="Cerrar" CssClass="btn-dermo-secondary" style="padding: 6px 14px; font-size: 12px;" OnClick="btnCerrarJefaturas_Click" />
                </div>

                <p class="text-muted" style="font-size: 13px; line-height: 1.5; margin-bottom: 20px;">
                    Administraci&oacute;n de los nombres institucionales registrados en <code>ConfiguracionGlobal</code>. Estos nombres figuran oficialmente al pie de las firmas en las &Oacute;rdenes de Compra, Gu&iacute;as de Recepci&oacute;n y Reportes.
                </p>

                <div class="form-group-dermo" style="margin-bottom: 16px;">
                    <label class="form-label-dermo" style="font-weight: 700;">Jefatura M&oacute;dulo de Compras y Abastecimiento</label>
                    <asp:TextBox ID="txtJefeCompras" runat="server" CssClass="input-pill-dermo" placeholder="Nombre completo para firmas de OC"></asp:TextBox>
                </div>

                <div class="form-group-dermo" style="margin-bottom: 16px;">
                    <label class="form-label-dermo" style="font-weight: 700;">Jefatura M&oacute;dulo de Ventas y Facturaci&oacute;n</label>
                    <asp:TextBox ID="txtJefeVentas" runat="server" CssClass="input-pill-dermo" placeholder="Nombre completo para firmas de reportes"></asp:TextBox>
                </div>

                <div class="form-group-dermo" style="margin-bottom: 16px;">
                    <label class="form-label-dermo" style="font-weight: 700;">Jefatura M&oacute;dulo de Inventario y Kardex</label>
                    <asp:TextBox ID="txtJefeInventario" runat="server" CssClass="input-pill-dermo" placeholder="Nombre completo para firmas de reportes"></asp:TextBox>
                </div>

                <asp:Label ID="lblMensajeJefaturas" runat="server" Font-Size="12.5px" style="display: block; margin-top: 14px;"></asp:Label>

                <div style="display: flex; justify-content: flex-end; gap: 10px; margin-top: 25px; border-top: 1px solid var(--color-borde-suave); padding-top: 15px;">
                    <asp:Button ID="btnCancelarJefaturas" runat="server" Text="Cancelar" CssClass="btn-dermo-secondary" OnClick="btnCerrarJefaturas_Click" />
                    <asp:Button ID="btnGuardarJefaturas" runat="server" Text="Guardar Firmas" CssClass="btn-dermo-primary" OnClick="btnGuardarJefaturas_Click" />
                </div>
            </div>
        </asp:Panel>
    </form>
</body>
</html>