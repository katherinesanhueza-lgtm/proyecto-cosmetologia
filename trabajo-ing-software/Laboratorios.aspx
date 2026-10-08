<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Laboratorios.aspx.cs" Inherits="trabajo_ing_software.Laboratorios" ResponseEncoding="utf-8" ContentType="text/html; charset=utf-8" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml" lang="es">
<head runat="server">
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Proveedores y Laboratorios - Cosmetolog&iacute;a Profesional</title>
    <link rel="preconnect" href="https://fonts.googleapis.com" />
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin="anonymous" />
    <link href="https://fonts.googleapis.com/css2?family=Playfair+Display:ital,wght@0,500;0,600;0,700;1,400;1,500;1,600&family=Plus+Jakarta+Sans:wght@300;400;500;600;700&display=swap" rel="stylesheet" />
    <link href="Content/Estilos.css" rel="stylesheet" type="text/css" />
    <style>
        .labs-container-2col {
            max-width: 1420px;
            margin: 25px auto 40px auto;
            padding: 0 24px;
        }

        .filter-toolbar-row {
            display: grid;
            grid-template-columns: 1fr 180px 140px auto;
            gap: 14px;
            align-items: center;
            background-color: var(--color-blanco);
            border: 1px solid var(--color-borde-suave);
            border-radius: 25px;
            padding: 8px 18px;
            margin-bottom: 25px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.02);
        }

        .split-labs-grid {
            display: grid;
            grid-template-columns: 1.25fr 0.95fr;
            gap: 25px;
            align-items: start;
        }

        .form-row-2col {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 14px;
        }

        .kpi-row-3col {
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            gap: 15px;
            margin-top: 20px;
        }

        @media (max-width: 1050px) {
            .split-labs-grid {
                grid-template-columns: 1fr;
            }
            .filter-toolbar-row {
                grid-template-columns: 1fr;
            }
            .kpi-row-3col {
                grid-template-columns: 1fr;
            }
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <asp:HiddenField ID="hfIdLaboratorio" runat="server" Value="" />

        <!-- HEADER GLOBAL -->
        <header class="top-header">
            <div class="brand-block">
                <span class="brand-logo">NOMBRE</span>
                <span class="brand-sub">COSMETOLOG&Iacute;A PROFESIONAL</span>
            </div>
            <nav>
                <ul class="nav-links-menu">
                    <li><a href="Default.aspx" class="nav-item-link">Inicio</a></li>
                    <li><a href="Usuarios.aspx" class="nav-item-link">Usuarios</a></li>
                    <li><a href="Laboratorios.aspx" class="nav-item-link active">Laboratorios</a></li>
                    <li><a href="ReporteProveedores.aspx" class="nav-item-link">Reporte Evaluaci&oacute;n</a></li>
                    <li><a href="Accesos.aspx" class="nav-item-link">Accesos</a></li>
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

        <!-- CUERPO PRINCIPAL DEL MODULO -->
        <div class="labs-container-2col">

            <!-- SUBHEADER Y ENCABEZADO -->
            <div style="margin-bottom: 22px;">
                <span class="pill-badge" style="font-size: 10px; padding: 4px 12px; margin-bottom: 8px;">
                    M&Oacute;DULO DE COMPRAS &amp; SUMINISTROS &bull; COSMEC&Eacute;UTICA CL&Iacute;NICA
                </span>
                <div style="display: flex; justify-content: space-between; align-items: flex-end; flex-wrap: wrap; gap: 15px;">
                    <div>
                        <h1 style="font-size: 32px; margin: 4px 0 6px 0;">Proveedores y Laboratorios</h1>
                        <p class="text-muted" style="margin: 0; max-width: 750px; line-height: 1.5;">
                            Directorio comercial, condiciones de cr&eacute;dito y cat&aacute;logo de marcas cosmec&eacute;uticas aliadas bajo est&aacute;ndares GMP e ISO 22716.
                        </p>
                    </div>
                    <div style="display: flex; gap: 12px;">
                        <asp:Button ID="btnIrReporte" runat="server" Text="Exportar Cat&aacute;logo (Reporte)" CssClass="btn-dermo-secondary" OnClick="btnIrReporte_Click" />
                        <button type="button" class="btn-dermo-primary" onclick="nuevoLaboratorioFocus();">
                            + Agregar Nuevo Laboratorio
                        </button>
                    </div>
                </div>
            </div>

            <!-- BARRA DE FILTROS Y BUSQUEDA DEL MOCKUP -->
            <div class="filter-toolbar-row">
                <div style="display: flex; align-items: center; gap: 10px;">
                    <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" style="color: var(--color-texto-suave); flex-shrink: 0;"><circle cx="11" cy="11" r="8"></circle><line x1="21" y1="21" x2="16.65" y2="16.65"></line></svg>
                    <asp:TextBox ID="txtBuscar" runat="server" CssClass="input-pill-dermo" style="border: none; background: transparent; padding: 6px 0;" placeholder="Buscar por laboratorio, marca o representante comercial..." AutoPostBack="true" OnTextChanged="txtBuscar_TextChanged"></asp:TextBox>
                </div>
                <div>
                    <asp:DropDownList ID="ddlFiltroPais" runat="server" CssClass="input-pill-dermo" style="padding: 6px 14px; font-size: 12px;" AutoPostBack="true" OnSelectedIndexChanged="ddlFiltroPais_SelectedIndexChanged">
                        <asp:ListItem Text="Pa&iacute;s: Todos" Value="" />
                        <asp:ListItem Text="Francia" Value="Francia" />
                        <asp:ListItem Text="Alemania" Value="Alemania" />
                        <asp:ListItem Text="Espa&ntilde;a" Value="España" />
                        <asp:ListItem Text="Suiza" Value="Suiza" />
                        <asp:ListItem Text="Estados Unidos" Value="Estados Unidos" />
                        <asp:ListItem Text="Argentina" Value="Argentina" />
                        <asp:ListItem Text="Chile" Value="Chile" />
                        <asp:ListItem Text="Corea del Sur" Value="Corea del Sur" />
                    </asp:DropDownList>
                </div>
                <div>
                    <asp:DropDownList ID="ddlFiltroEstado" runat="server" CssClass="input-pill-dermo" style="padding: 6px 14px; font-size: 12px;" AutoPostBack="true" OnSelectedIndexChanged="ddlFiltroEstado_SelectedIndexChanged">
                        <asp:ListItem Text="Estado: Todos" Value="" />
                        <asp:ListItem Text="Activo" Value="1" Selected="True" />
                        <asp:ListItem Text="Inactivo" Value="0" />
                    </asp:DropDownList>
                </div>
                <div style="text-align: right;">
                    <span class="pill-badge" style="background-color: #FAF8F5; font-size: 11px;">
                        &bull; <asp:Label ID="lblTotalHomologados" runat="server" Text="0"></asp:Label> Laboratorios Homologados
                    </span>
                </div>
            </div>

            <!-- LAYOUT EN 2 COLUMNAS -->
            <div class="split-labs-grid">

                <!-- COLUMNA IZQUIERDA: DIRECTORIO COMERCIAL (TABLA) -->
                <div>
                    <div class="table-dermo-container">
                        <div style="padding: 16px 22px; border-bottom: 1px solid var(--color-borde-suave); display: flex; justify-content: space-between; align-items: center;">
                            <h3 style="font-size: 16px; margin: 0;">Directorio Comercial</h3>
                            <span class="text-muted" style="font-size: 12px;">Cat&aacute;logo activo</span>
                        </div>

                        <asp:GridView ID="gvLaboratorios" runat="server" AutoGenerateColumns="False" 
                            CssClass="table-dermo-modern" GridLines="None" EmptyDataText="No hay laboratorios registrados a&uacute;n."
                            OnRowCommand="gvLaboratorios_RowCommand" DataKeyNames="IdLaboratorio">
                            <Columns>
                                <asp:TemplateField HeaderText="LABORATORIO">
                                    <ItemTemplate>
                                        <div style="display: flex; align-items: center;">
                                            <div class="avatar-circle">
                                                <%# GetIniciales(Eval("RazonSocial").ToString()) %>
                                            </div>
                                            <div>
                                                <div style="font-weight: 700; color: var(--color-texto);">
                                                    <%# Eval("RazonSocial") %>
                                                </div>
                                                <small class="text-muted"><%# Eval("Pais") %> &middot; RUT: <%# Eval("Rut") %></small>
                                            </div>
                                        </div>
                                    </ItemTemplate>
                                </asp:TemplateField>

                                <asp:TemplateField HeaderText="REPRESENTANTE">
                                    <ItemTemplate>
                                        <div style="font-weight: 600; font-size: 12px;"><%# Eval("Contacto") %></div>
                                        <div class="text-muted" style="font-size: 11px;"><%# Eval("Email") %></div>
                                        <div class="text-muted" style="font-size: 10px;"><%# Eval("Telefono") %></div>
                                    </ItemTemplate>
                                </asp:TemplateField>

                                <asp:TemplateField HeaderText="PLAZO DE PAGO">
                                    <ItemTemplate>
                                        <span class="pill-badge" style="font-size: 10px; padding: 4px 10px;">
                                            <%# Eval("DiasPago") %> d&iacute;as neto
                                        </span>
                                    </ItemTemplate>
                                </asp:TemplateField>

                                <asp:TemplateField HeaderText="MARCAS CLAVE">
                                    <ItemTemplate>
                                        <span class="tag-pill-sm"><%# Eval("Marca") %></span>
                                    </ItemTemplate>
                                </asp:TemplateField>

                                <asp:TemplateField HeaderText="ACCIONES">
                                    <ItemTemplate>
                                        <asp:Button ID="btnEditar" runat="server" Text="Editar" 
                                            CommandName="Editar" CommandArgument='<%# Eval("IdLaboratorio") %>'
                                            CssClass="btn-action-pill" ToolTip="Editar laboratorio" />

                                        <asp:Button ID="btnCambiarEstado" runat="server" 
                                            Text='<%# Convert.ToBoolean(Eval("Activo")) ? "Desactivar" : "Activar" %>' 
                                            CommandName="CambiarEstado" 
                                            CommandArgument='<%# Eval("IdLaboratorio") + ";" + Eval("Activo") %>'
                                            CssClass="btn-action-pill btn-toggle" />

                                        <asp:Button ID="btnEliminar" runat="server" Text="Eliminar" 
                                            CommandName="Eliminar" CommandArgument='<%# Eval("IdLaboratorio") %>'
                                            CssClass="btn-action-pill btn-delete" ToolTip="Eliminar"
                                            OnClientClick="return confirm('&iquest;Desea eliminar permanentemente este laboratorio?');" />
                                    </ItemTemplate>
                                </asp:TemplateField>
                            </Columns>
                        </asp:GridView>
                    </div>

                    <!-- MINI CARDS INFERIORES DE KPI DEL MOCKUP -->
                    <div class="kpi-row-3col">
                        <div class="kpi-mini-card">
                            <div class="kpi-mini-title">CR&Eacute;DITO COMERCIAL ACTIVO</div>
                            <div class="kpi-mini-value">$245,000 <small style="font-size: 13px; font-weight: normal; color: var(--color-texto-suave);">USD</small></div>
                            <div class="kpi-mini-sub">L&iacute;neas aprobadas 100%</div>
                        </div>

                        <div class="kpi-mini-card">
                            <div class="kpi-mini-title">PLAZO PROMEDIO PONDERADO</div>
                            <div class="kpi-mini-value"><asp:Label ID="lblPlazoPromedio" runat="server" Text="30"></asp:Label> <small style="font-size: 13px; font-weight: normal; color: var(--color-texto-suave);">D&iacute;as</small></div>
                            <div class="kpi-mini-sub">Acuerdos fecha de recepci&oacute;n</div>
                        </div>

                        <div class="kpi-mini-card">
                            <div class="kpi-mini-title">LABORATORIOS EN CERTIFICACI&Oacute;N</div>
                            <div class="kpi-mini-value">3 <small style="font-size: 13px; font-weight: normal; color: var(--color-texto-suave);">En curso</small></div>
                            <div class="kpi-mini-sub">Dossier t&eacute;cnico ANMAT / EU</div>
                        </div>
                    </div>
                </div>

                <!-- COLUMNA DERECHA: FICHA TECNICA Y COMERCIAL (FORMULARIO) -->
                <div>
                    <div class="card-dermo-luxury" style="margin-bottom: 22px;">
                        <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 12px;">
                            <span class="pill-badge" style="font-size: 10px;">Ficha T&eacute;cnica &amp; Comercial</span>
                            <span style="font-size: 12px; color: var(--color-texto-suave); font-weight: 600;">Registro</span>
                        </div>

                        <h2 id="lblTituloForm" runat="server" style="font-size: 22px; margin-bottom: 4px;">Detalle de Laboratorio</h2>
                        <p class="text-muted" style="margin-bottom: 20px;">
                            Gesti&oacute;n de condiciones comerciales y cat&aacute;logo de marcas cosmec&eacute;uticas.
                        </p>

                        <div class="form-group-dermo">
                            <label class="form-label-dermo">Raz&oacute;n Social / Nombre Laboratorio *</label>
                            <asp:TextBox ID="txtRazonSocial" runat="server" CssClass="input-pill-dermo" placeholder="Ej: Laboratoires DermAlliance S.A.S."></asp:TextBox>
                        </div>

                        <div class="form-row-2col">
                            <div class="form-group-dermo">
                                <label class="form-label-dermo">Pa&iacute;s de Origen</label>
                                <asp:TextBox ID="txtPais" runat="server" CssClass="input-pill-dermo" placeholder="Ej: Francia (UE)"></asp:TextBox>
                            </div>
                            <div class="form-group-dermo">
                                <label class="form-label-dermo">Plazo de Pago (D&iacute;as)</label>
                                <asp:TextBox ID="txtDiasPago" runat="server" CssClass="input-pill-dermo" TextMode="Number" Text="30"></asp:TextBox>
                            </div>
                        </div>

                        <div class="form-group-dermo">
                            <label class="form-label-dermo">Representante Comercial Autorizado</label>
                            <asp:TextBox ID="txtContacto" runat="server" CssClass="input-pill-dermo" placeholder="Ej: Dr. Antoine Laurent"></asp:TextBox>
                        </div>

                        <div class="form-group-dermo">
                            <label class="form-label-dermo">Correo Electr&oacute;nico de Compras / Facturaci&oacute;n *</label>
                            <asp:TextBox ID="txtEmail" runat="server" CssClass="input-pill-dermo" placeholder="compras.latam@laboratorio.com"></asp:TextBox>
                        </div>

                        <div class="form-row-2col">
                            <div class="form-group-dermo">
                                <label class="form-label-dermo">RUT Proveedor *</label>
                                <asp:TextBox ID="txtRut" runat="server" CssClass="input-pill-dermo" placeholder="76.111.222-3"></asp:TextBox>
                            </div>
                            <div class="form-group-dermo">
                                <label class="form-label-dermo">Tel&eacute;fono de Contacto</label>
                                <asp:TextBox ID="txtTelefono" runat="server" CssClass="input-pill-dermo" placeholder="+33 1 42 68 55 00"></asp:TextBox>
                            </div>
                        </div>

                        <div class="form-group-dermo">
                            <label class="form-label-dermo">Marcas Cosmec&eacute;uticas Distribuidas *</label>
                            <asp:TextBox ID="txtMarca" runat="server" CssClass="input-pill-dermo" placeholder="Ej: Aura Lumi&egrave;re Pro, BioRetinol FX Clinical"></asp:TextBox>
                        </div>

                        <div style="display: flex; gap: 12px; margin-top: 20px;">
                            <asp:Button ID="btnGuardar" runat="server" Text="Guardar Cambios" CssClass="btn-dermo-primary" OnClick="btnGuardar_Click" style="flex: 1;" />
                            <asp:Button ID="btnCancelar" runat="server" Text="Cancelar" CssClass="btn-dermo-secondary" Visible="false" OnClick="btnCancelar_Click" />
                        </div>

                        <asp:Label ID="lblMensaje" runat="server" Font-Size="13px" style="display: block; margin-top: 14px; font-weight: 500;"></asp:Label>
                    </div>
                </div>

            </div>

        </div>

        <!-- ENLACE OCULTO REQUERIDO POR CODE-BEHIND -->
        <asp:Button ID="btnIrUsuarios" runat="server" Visible="false" OnClick="btnIrUsuarios_Click" />

        <script>
            function nuevoLaboratorioFocus() {
                document.getElementById('<%= txtRazonSocial.ClientID %>').focus();
                document.getElementById('<%= txtRazonSocial.ClientID %>').scrollIntoView({ behavior: 'smooth' });
            }
        </script>
    </form>
</body>
</html>