<%@ Page Title="Laboratorios y proveedores" MasterPageFile="~/Contabilidad.Master" Language="C#" AutoEventWireup="true" CodeBehind="Laboratorios.aspx.cs" Inherits="trabajo_ing_software.Laboratorios" ResponseEncoding="utf-8" ContentType="text/html; charset=utf-8" %>
<asp:Content ID="Recursos" ContentPlaceHolderID="EstilosPagina" runat="server">
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
            margin-bottom: 22px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.02);
        }

        /* Banner de alerta y notificación (Estética Dermo) */
        .alerta-dermo-notificacion {
            background: #E8F8F0;
            border: 1px solid #A9DFBF;
            color: #1E8449;
            border-radius: 16px;
            padding: 14px 20px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 22px;
            box-shadow: 0 4px 15px rgba(39, 174, 96, 0.08);
            animation: fadeIn 0.3s ease;
        }
        .alerta-dermo-error {
            background: #FDEDEC !important;
            border: 1px solid #F5B7B1 !important;
            color: #C0392B !important;
            box-shadow: 0 4px 15px rgba(192, 57, 43, 0.08) !important;
        }
        .alerta-icon-wrap {
            width: 36px;
            height: 36px;
            border-radius: 10px;
            background: rgba(39, 174, 96, 0.15);
            display: flex;
            align-items: center;
            justify-content: center;
            flex-shrink: 0;
        }
        .alerta-dermo-error .alerta-icon-wrap {
            background: rgba(192, 57, 43, 0.15) !important;
        }
        .alerta-btn-cerrar {
            background: none;
            border: none;
            font-size: 20px;
            line-height: 1;
            color: inherit;
            cursor: pointer;
            opacity: 0.6;
            padding: 4px 8px;
            border-radius: 8px;
            text-decoration: none !important;
            transition: all 0.2s ease;
        }
        .alerta-btn-cerrar:hover {
            opacity: 1;
            background: rgba(0,0,0,0.05);
        }

        /* Modal Overlay y Tarjeta Flotante */
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
            padding: 20px;
        }
        .modal-content-card {
            background: var(--color-blanco);
            border-radius: 22px;
            width: 100%;
            max-width: 680px;
            max-height: 90vh;
            overflow-y: auto;
            box-shadow: 0 10px 40px rgba(0,0,0,0.15);
            border: 1px solid var(--color-borde-suave);
            padding: 28px 32px;
            animation: modalPop 0.25s ease-out;
        }
        @keyframes modalPop {
            from { transform: scale(0.96); opacity: 0; }
            to { transform: scale(1); opacity: 1; }
        }

        /* Estilos de tabla centrada y armoniosa */
        .table-dermo-modern th {
            padding: 14px 12px !important;
            font-size: 11px !important;
            letter-spacing: 0.8px !important;
        }
        .table-dermo-modern td {
            padding: 14px 12px !important;
            vertical-align: middle !important;
        }
        .col-center {
            text-align: center !important;
            vertical-align: middle !important;
            white-space: nowrap !important;
        }
        .col-left {
            text-align: left !important;
            vertical-align: middle !important;
        }

        /* Badge Plazo de Pago con máximo contraste y centrado */
        .plazo-badge-pill {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            gap: 6px;
            white-space: nowrap !important;
            background-color: #F5EFEB;
            border: 1px solid #D8C7B5;
            border-radius: 18px;
            padding: 6px 14px;
            box-shadow: 0 1px 3px rgba(0, 0, 0, 0.03);
            transition: all 0.2s ease;
        }
        .plazo-badge-pill:hover {
            background-color: #ECE3DA;
            border-color: #9C8573;
        }

        /* Tag Marcas Clave */
        .marca-tag-pill {
            display: inline-block;
            background-color: #FAF8F5;
            border: 1px solid #E4DDD3;
            border-radius: 14px;
            padding: 6px 12px;
            font-size: 11.5px;
            font-weight: 600;
            color: #4A3B32;
            text-align: center;
            line-height: 1.35;
            box-shadow: 0 1px 2px rgba(0, 0, 0, 0.02);
            max-width: 220px;
        }

        .form-row-2col {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 14px;
        }

        .kpi-row-3col {
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            gap: 18px;
            margin-top: 25px;
        }

        @media (max-width: 1050px) {
            .filter-toolbar-row {
                grid-template-columns: 1fr;
            }
            .kpi-row-3col {
                grid-template-columns: 1fr;
            }
        }
    </style>
</asp:Content>
<asp:Content ID="Acciones" ContentPlaceHolderID="AccionesUsuario" runat="server">
    <asp:Label ID="lblBienvenida" Visible="false" runat="server" Font-Bold="true" Font-Size="13px"></asp:Label>
                <asp:Button ID="btnLogout" runat="server" Text="Cerrar Sesi&oacute;n" CssClass="btn btn-outline-secondary btn-sm cierre-compras" OnClick="btnLogout_Click" />
</asp:Content>
<asp:Content ID="Contenido" ContentPlaceHolderID="MainContent" runat="server">
    <div class="dashboard compras-contenido">
        <asp:HiddenField ID="hfIdLaboratorio" runat="server" Value="" />
        <!-- CUERPO PRINCIPAL DEL MODULO -->
        <div class="labs-container-2col">

            <!-- SUBHEADER Y ENCABEZADO -->
            <div style="margin-bottom: 22px;">
                <span class="pill-badge" style="font-size: 10px; padding: 4px 12px; margin-bottom: 8px;">
                    M&Oacute;DULO DE COMPRAS &amp; SUMINISTROS &bull; COSMEC&Eacute;UTICA CL&Iacute;NICA
                </span>
                <div style="display: flex; justify-content: space-between; align-items: flex-end; flex-wrap: wrap; gap: 15px;">
                    <div>
                        <h1>Proveedores y Laboratorios</h1>
                        <p class="text-muted" style="margin: 0; max-width: 750px; line-height: 1.5;">
                            Directorio comercial, condiciones de cr&eacute;dito y cat&aacute;logo de marcas cosmec&eacute;uticas aliadas bajo est&aacute;ndares GMP e ISO 22716.
                        </p>
                    </div>
                    <div style="display: flex; gap: 12px;">
                        <a href="ReporteProveedores.aspx" class="btn btn-outline-secondary"><svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"></path><polyline points="14 2 14 8 20 8"></polyline><line x1="16" y1="13" x2="8" y2="13"></line><line x1="16" y1="17" x2="8" y2="17"></line><polyline points="10 9 9 9 8 9"></polyline></svg>Reporte de Evaluaci&oacute;n</a>
                        <asp:Button ID="btnIrReporte" runat="server" Visible="false" OnClick="btnIrReporte_Click" />
                        <asp:Button ID="btnNuevoLaboratorio" runat="server" Text="+ Agregar Nuevo Laboratorio" CssClass="btn btn-primary" OnClick="btnNuevoLaboratorio_Click" />
                    </div>
                </div>
            </div>

            <!-- BARRA DE FILTROS Y BUSQUEDA -->
            <div class="filter-toolbar-row card-dermocosmetica">
                <div style="display: flex; align-items: center; gap: 10px;">
                    <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" style="color: var(--color-texto-suave); flex-shrink: 0;"><circle cx="11" cy="11" r="8"></circle><line x1="21" y1="21" x2="16.65" y2="16.65"></line></svg>
                    <asp:TextBox ID="txtBuscar" runat="server" CssClass="form-control" placeholder="Buscar por laboratorio, marca o representante comercial..." AutoPostBack="true" OnTextChanged="txtBuscar_TextChanged"></asp:TextBox>
                </div>
                <div>
                    <asp:DropDownList ID="ddlFiltroPais" runat="server" CssClass="form-select" AutoPostBack="true" OnSelectedIndexChanged="ddlFiltroPais_SelectedIndexChanged">
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
                    <asp:DropDownList ID="ddlFiltroEstado" runat="server" CssClass="form-select" AutoPostBack="true" OnSelectedIndexChanged="ddlFiltroEstado_SelectedIndexChanged">
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

            <!-- PANEL DE ALERTA Y NOTIFICACIÓN (ESTÉTICA DERMO ELEGANTE) -->
            <asp:Panel ID="pnlAlerta" runat="server" Visible="false" CssClass="alerta-dermo-notificacion">
                <div style="display: flex; align-items: center; gap: 14px;">
                    <div class="alerta-icon-wrap">
                        <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><polyline points="20 6 9 17 4 12"></polyline></svg>
                    </div>
                    <div>
                        <div style="font-weight: 700; font-size: 14px;" id="alertaTitulo" runat="server">Operaci&oacute;n Exitosa</div>
                        <div style="font-size: 12.5px; opacity: 0.95;"><asp:Label ID="lblAlerta" runat="server"></asp:Label></div>
                    </div>
                </div>
                <asp:LinkButton ID="btnCerrarAlerta" runat="server" CssClass="alerta-btn-cerrar" OnClick="btnCerrarAlerta_Click" ToolTip="Cerrar notificaci&oacute;n">&times;</asp:LinkButton>
            </asp:Panel>

            <!-- DIRECTORIO COMERCIAL A ANCHO COMPLETO -->
            <div class="table-dermo-container">
                <div style="padding: 16px 22px; border-bottom: 1px solid var(--color-borde-suave); display: flex; justify-content: space-between; align-items: center; background-color: #FCFBF9;">
                    <div style="display: flex; align-items: center; gap: 10px;">
                        <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#7A5E47" stroke-width="2"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"></path><circle cx="9" cy="7" r="4"></circle><path d="M23 21v-2a4 4 0 0 0-3-3.87"></path><path d="M16 3.13a4 4 0 0 1 0 7.75"></path></svg>
                        <h3 style="font-size: 16px; margin: 0; font-family: 'Playfair Display', Georgia, serif; font-weight: 600; color: #2E2E2E;">Directorio Comercial</h3>
                    </div>
                    <span class="badge-status-activo" style="font-size: 11px; padding: 4px 12px; border-radius: 12px;">Cat&aacute;logo activo</span>
                </div>

                <asp:GridView ID="gvLaboratorios" runat="server" AutoGenerateColumns="False" 
                    CssClass="table table-hover align-middle" GridLines="None" EmptyDataText="No hay laboratorios registrados a&uacute;n."
                    OnRowCommand="gvLaboratorios_RowCommand" DataKeyNames="IdLaboratorio">
                    <Columns>
                        <asp:TemplateField HeaderText="LABORATORIO" HeaderStyle-CssClass="col-left" ItemStyle-CssClass="col-left">
                            <ItemTemplate>
                                <div style="display: flex; align-items: center;">
                                    <div class="avatar-circle">
                                        <%# GetIniciales(Eval("RazonSocial").ToString()) %>
                                    </div>
                                    <div>
                                        <div style="font-weight: 700; color: #2E2E2E; font-size: 13.5px; line-height: 1.3;">
                                            <%# Eval("RazonSocial") %>
                                        </div>
                                        <div style="font-size: 11.5px; color: #736E67; margin-top: 3px;">
                                            <%# Eval("Pais") %> &middot; RUT: <%# Eval("Rut") %>
                                        </div>
                                    </div>
                                </div>
                            </ItemTemplate>
                        </asp:TemplateField>

                        <asp:TemplateField HeaderText="REPRESENTANTE" HeaderStyle-CssClass="col-left" ItemStyle-CssClass="col-left">
                            <ItemTemplate>
                                <div style="font-weight: 600; font-size: 12.5px; color: #3A2A1D;"><%# Eval("Contacto") %></div>
                                <div style="font-size: 11px; color: #736E67; margin-top: 2px;"><%# Eval("Email") %></div>
                                <div style="font-size: 10.5px; color: #8C827A; margin-top: 1px;"><%# Eval("Telefono") %></div>
                            </ItemTemplate>
                        </asp:TemplateField>

                        <asp:TemplateField HeaderText="PLAZO DE PAGO" HeaderStyle-CssClass="col-center" ItemStyle-CssClass="col-center">
                            <ItemTemplate>
                                <span class="plazo-badge-pill" title="Plazo de cr&eacute;dito comercial acordado">
                                    <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="#4A3B32" stroke-width="2.2" style="flex-shrink: 0;"><circle cx="12" cy="12" r="10"></circle><polyline points="12 6 12 12 16 14"></polyline></svg>
                                    <strong style="color: #1F1A16 !important; font-size: 13.5px; font-weight: 800; line-height: 1;"><%# Eval("DiasPago") %></strong>
                                    <span style="color: #4A3B32 !important; font-size: 10.5px; font-weight: 700; text-transform: uppercase; letter-spacing: 0.5px; line-height: 1;">d&iacute;as neto</span>
                                </span>
                            </ItemTemplate>
                        </asp:TemplateField>

                        <asp:TemplateField HeaderText="MARCAS CLAVE" HeaderStyle-CssClass="col-center" ItemStyle-CssClass="col-center">
                            <ItemTemplate>
                                <span class="marca-tag-pill">
                                    <%# Eval("Marca") %>
                                </span>
                            </ItemTemplate>
                        </asp:TemplateField>

                        <asp:TemplateField HeaderText="ACCIONES" HeaderStyle-CssClass="col-center" ItemStyle-CssClass="col-center">
                            <ItemTemplate>
                                <div style="display: flex; gap: 8px; align-items: center; justify-content: center;">
                                    <asp:Button ID="btnEditar" runat="server" Text="Editar" 
                                        CommandName="Editar" CommandArgument='<%# Eval("IdLaboratorio") %>'
                                        CssClass="btn btn-outline-secondary btn-sm" ToolTip="Editar laboratorio" />

                                    <asp:Button ID="btnCambiarEstado" runat="server" 
                                        Text='<%# Convert.ToBoolean(Eval("Activo")) ? "Desactivar" : "Activar" %>' 
                                        CommandName="CambiarEstado" 
                                        CommandArgument='<%# Eval("IdLaboratorio") + ";" + Eval("Activo") %>'
                                        CssClass='<%# Convert.ToBoolean(Eval("Activo")) ? "btn btn-outline-danger btn-sm" : "btn btn-outline-secondary btn-sm" %>' />
                                </div>
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

            <!-- MODAL FLOTANTE: FICHA TÉCNICA & COMERCIAL -->
            <asp:Panel ID="pnlModalForm" runat="server" Visible="false" CssClass="modal-overlay">
                <div class="modal-content-card">
                    <div style="display: flex; justify-content: space-between; align-items: flex-start; margin-bottom: 16px; border-bottom: 1px solid var(--color-borde-suave); padding-bottom: 14px;">
                        <div>
                            <span class="pill-badge" style="font-size: 10px; padding: 3px 10px;">FICHA T&Eacute;CNICA &amp; COMERCIAL</span>
                            <h2 id="lblTituloForm" runat="server" style="font-size: 22px; margin: 6px 0 2px 0; font-family: 'Playfair Display', Georgia, serif; color: var(--color-texto);">Registrar Nuevo Laboratorio</h2>
                            <div style="font-size: 12px; color: var(--color-texto-suave);">Gesti&oacute;n de condiciones comerciales y cat&aacute;logo de marcas cosmec&eacute;uticas</div>
                        </div>
                        <asp:LinkButton ID="btnCerrarModalX" runat="server" CssClass="btn btn-outline-secondary btn-sm" OnClick="btnCancelar_Click" ToolTip="Cerrar ventana" style="border-radius: 50%; width: 34px; height: 34px; display: inline-flex; align-items: center; justify-content: center; padding: 0; font-size: 18px; line-height: 1;">&times;</asp:LinkButton>
                    </div>

                    <asp:Panel ID="pnlMensajeModal" runat="server" Visible="false" CssClass="alerta-dermo-notificacion alerta-dermo-error" style="margin-bottom: 18px;">
                        <div style="display: flex; align-items: center; gap: 10px;">
                            <div class="alerta-icon-wrap" style="width: 28px; height: 28px;">
                                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><circle cx="12" cy="12" r="10"></circle><line x1="12" y1="8" x2="12" y2="12"></line><line x1="12" y1="16" x2="12.01" y2="16"></line></svg>
                            </div>
                            <asp:Label ID="lblMensaje" runat="server" Font-Size="12.5px" Font-Bold="true"></asp:Label>
                        </div>
                    </asp:Panel>

                    <div class="form-group-dermo">
                        <asp:Label runat="server" CssClass="form-label" AssociatedControlID="txtRazonSocial">Raz&oacute;n Social / Nombre Laboratorio *</asp:Label>
                        <asp:TextBox ID="txtRazonSocial" runat="server" CssClass="form-control" placeholder="Ej: Laboratoires DermAlliance S.A.S."></asp:TextBox>
                    </div>

                    <div class="form-row-2col">
                        <div class="form-group-dermo">
                            <asp:Label runat="server" CssClass="form-label" AssociatedControlID="txtPais">Pa&iacute;s de Origen</asp:Label>
                            <asp:TextBox ID="txtPais" runat="server" CssClass="form-control" placeholder="Ej: Francia (UE)"></asp:TextBox>
                        </div>
                        <div class="form-group-dermo">
                            <asp:Label runat="server" CssClass="form-label" AssociatedControlID="txtDiasPago">Plazo de Pago (D&iacute;as)</asp:Label>
                            <asp:TextBox ID="txtDiasPago" runat="server" CssClass="form-control" TextMode="Number" Text="30"></asp:TextBox>
                        </div>
                    </div>

                    <div class="form-group-dermo">
                        <asp:Label runat="server" CssClass="form-label" AssociatedControlID="txtContacto">Representante Comercial Autorizado</asp:Label>
                        <asp:TextBox ID="txtContacto" runat="server" CssClass="form-control" placeholder="Ej: Dr. Antoine Laurent"></asp:TextBox>
                    </div>

                    <div class="form-group-dermo">
                        <asp:Label runat="server" CssClass="form-label" AssociatedControlID="txtEmail">Correo Electr&oacute;nico de Compras / Facturaci&oacute;n *</asp:Label>
                        <asp:TextBox ID="txtEmail" runat="server" CssClass="form-control" placeholder="compras.latam@laboratorio.com"></asp:TextBox>
                    </div>

                    <div class="form-row-2col">
                        <div class="form-group-dermo">
                            <asp:Label runat="server" CssClass="form-label" AssociatedControlID="txtRut">RUT Proveedor *</asp:Label>
                            <asp:TextBox ID="txtRut" runat="server" CssClass="form-control" placeholder="76.111.222-8"></asp:TextBox>
                        </div>
                        <div class="form-group-dermo">
                            <asp:Label runat="server" CssClass="form-label" AssociatedControlID="txtTelefono">Tel&eacute;fono de Contacto</asp:Label>
                            <asp:TextBox ID="txtTelefono" runat="server" CssClass="form-control" placeholder="+33 1 42 68 55 00"></asp:TextBox>
                        </div>
                    </div>

                    <div class="form-group-dermo">
                        <asp:Label runat="server" CssClass="form-label" AssociatedControlID="txtMarca">Marcas Cosmec&eacute;uticas Distribuidas *</asp:Label>
                        <asp:TextBox ID="txtMarca" runat="server" CssClass="form-control" placeholder="Ej: Aura Lumi&egrave;re Pro, BioRetinol FX Clinical"></asp:TextBox>
                    </div>

                    <div style="display: flex; justify-content: flex-end; gap: 12px; margin-top: 24px; border-top: 1px solid var(--color-borde-suave); padding-top: 16px;">
                        <asp:Button ID="btnCancelar" runat="server" Text="Cancelar" CssClass="btn btn-outline-secondary" OnClick="btnCancelar_Click" />
                        <asp:Button ID="btnGuardar" runat="server" Text="Guardar Cambios" CssClass="btn btn-primary" OnClick="btnGuardar_Click" />
                    </div>
                </div>
            </asp:Panel>

        </div>

        <!-- ENLACE OCULTO REQUERIDO POR CODE-BEHIND -->
        <asp:Button ID="btnIrUsuarios" runat="server" Visible="false" OnClick="btnIrUsuarios_Click" />

        <script>
            function nuevoLaboratorioFocus() {
                document.getElementById('<%= txtRazonSocial.ClientID %>').focus();
                document.getElementById('<%= txtRazonSocial.ClientID %>').scrollIntoView({ behavior: 'smooth' });
            }
        </script>
        
    </div>
</asp:Content>
