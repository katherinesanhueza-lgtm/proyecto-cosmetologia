<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Recepciones.aspx.cs" Inherits="trabajo_ing_software.Recepciones" ResponseEncoding="utf-8" ContentType="text/html; charset=utf-8" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml" lang="es">
<head runat="server">
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Recepci&oacute;n y Asignaci&oacute;n de Lotes - Cosmetolog&iacute;a Profesional</title>
    <link rel="preconnect" href="https://fonts.googleapis.com" />
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin="anonymous" />
    <link href="https://fonts.googleapis.com/css2?family=Playfair+Display:ital,wght@0,500;0,600;0,700;1,400;1,500;1,600&family=Plus+Jakarta+Sans:wght@300;400;500;600;700&display=swap" rel="stylesheet" />
    <link href="Content/Estilos.css" rel="stylesheet" type="text/css" />
    <style>
        .rec-container {
            max-width: 1440px;
            margin: 25px auto 50px auto;
            padding: 0 24px;
        }

        .kpi-row-4col {
            display: grid;
            grid-template-columns: repeat(4, 1fr);
            gap: 18px;
            margin-bottom: 25px;
        }

        .filter-toolbar-row {
            display: grid;
            grid-template-columns: 1fr 240px auto;
            gap: 14px;
            align-items: center;
            background-color: var(--color-blanco);
            border: 1px solid var(--color-borde-suave);
            border-radius: 25px;
            padding: 8px 18px;
            margin-bottom: 25px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.02);
        }

        .form-rec-card {
            background-color: var(--color-blanco);
            border-radius: 22px;
            border: 1px solid var(--color-borde-suave);
            padding: 28px;
            margin-bottom: 30px;
            box-shadow: 0 6px 20px rgba(122, 94, 71, 0.05);
        }

        .form-section-title {
            font-family: 'Playfair Display', Georgia, serif;
            font-size: 16px;
            color: var(--color-acento);
            margin-bottom: 14px;
            padding-bottom: 6px;
            border-bottom: 1px dashed var(--color-primario);
            display: flex;
            align-items: center;
            gap: 8px;
        }

        .form-grid-3col {
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            gap: 16px;
            margin-bottom: 18px;
        }

        .info-oc-banner {
            background-color: var(--color-pill-bg);
            border: 1px solid var(--color-borde-suave);
            border-radius: 14px;
            padding: 14px 18px;
            font-size: 13px;
            display: flex;
            gap: 24px;
            flex-wrap: wrap;
            margin-bottom: 20px;
        }

        .badge-rec-completa {
            background-color: #E8F8F0;
            color: #27AE60;
            border: 1px solid #A9DFBF;
            padding: 4px 10px;
            border-radius: 14px;
            font-size: 11px;
            font-weight: 600;
        }

        .badge-rec-parcial {
            background-color: #FEF9E7;
            color: #B7950B;
            border: 1px solid #F9E79F;
            padding: 4px 10px;
            border-radius: 14px;
            font-size: 11px;
            font-weight: 600;
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
            max-width: 900px;
            max-height: 90vh;
            overflow-y: auto;
            box-shadow: 0 10px 40px rgba(0,0,0,0.15);
            border: 1px solid var(--color-borde-suave);
            padding: 30px;
        }

        @media (max-width: 1024px) {
            .kpi-row-4col {
                grid-template-columns: repeat(2, 1fr);
            }
            .form-grid-3col {
                grid-template-columns: 1fr;
            }
            .filter-toolbar-row {
                grid-template-columns: 1fr;
            }
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">

        <!-- HEADER GLOBAL DE MARCA -->
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

                    <%-- INVENTARIO (Bodeguero Escritura; Admin Total; Comprador y Contador Consulta) --%>
                    <% if (esAdmin || esBodeguero || esComprador) { %>
                    <li><a href="Recepciones.aspx" class="nav-item-link">Recepci&oacute;n y Lotes</a></li>
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

        <!-- CONTENEDOR PRINCIPAL -->
        <div class="rec-container">

            <!-- SUBHEADER Y ENCABEZADO -->
            <div style="display: flex; justify-content: space-between; align-items: flex-end; margin-bottom: 24px; flex-wrap: wrap; gap: 14px;">
                <div>
                    <span class="pill-badge" style="font-size: 10px; padding: 4px 12px; margin-bottom: 8px;">M&Oacute;DULO DE COMPRAS - RECEPCI&Oacute;N Y BODEGA</span>
                    <h1 style="font-size: 26px; margin-top: 4px;">Recepci&oacute;n de Mercader&iacute;a y Asignaci&oacute;n de Lotes</h1>
                    <p class="text-muted" style="margin-top: 4px;">Registro de gu&iacute;a de despacho, control f&iacute;sico de insumos contra &Oacute;rdenes de Compra, y asignaci&oacute;n de lotes y fechas de vencimiento bajo criterio FEFO (RF-COM-05 / RF-COM-06 / RF-COM-07).</p>
                </div>
                <div style="display: flex; gap: 10px;">
                    <a href="ReporteIngresos.aspx" class="btn-dermo-secondary" style="text-decoration: none; display: inline-flex; align-items: center; gap: 6px;">
                        <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"></path><polyline points="14 2 14 8 20 8"></polyline><line x1="16" y1="13" x2="8" y2="13"></line><line x1="16" y1="17" x2="8" y2="17"></line></svg>
                        Reporte Consolidado
                    </a>
                    <asp:Button ID="btnToggleForm" runat="server" Text="Nueva Recepci&oacute;n de Mercader&iacute;a" CssClass="btn-dermo-primary" OnClick="btnToggleForm_Click" />
                </div>
            </div>

            <!-- TARJETAS DE INDICADORES (KPIS) -->
            <div class="kpi-row-4col">
                <div class="kpi-card" style="padding: 16px; border-radius: 16px; background: #fff; border: 1px solid var(--color-borde-suave); box-shadow: 0 2px 8px rgba(0,0,0,0.02);">
                    <div class="kpi-titulo" style="font-size: 11px; color: var(--color-texto-suave); text-transform: uppercase;">Total Recepciones</div>
                    <div class="kpi-valor" style="font-size: 26px; font-weight: 700; color: var(--color-acento); font-family: 'Playfair Display', Georgia, serif;">
                        <asp:Label ID="lblKpiTotalRec" runat="server" Text="0"></asp:Label>
                    </div>
                    <div style="font-size: 11px; color: var(--color-texto-suave);">Ingresos registrados</div>
                </div>

                <div class="kpi-card" style="padding: 16px; border-radius: 16px; background: #fff; border: 1px solid var(--color-borde-suave); box-shadow: 0 2px 8px rgba(0,0,0,0.02);">
                    <div class="kpi-titulo" style="font-size: 11px; color: var(--color-texto-suave); text-transform: uppercase;">Unidades Ingresadas</div>
                    <div class="kpi-valor" style="font-size: 26px; font-weight: 700; color: #27AE60; font-family: 'Playfair Display', Georgia, serif;">
                        <asp:Label ID="lblKpiUnidades" runat="server" Text="0"></asp:Label>
                    </div>
                    <div style="font-size: 11px; color: #27AE60;">Productos en stock f&iacute;sico</div>
                </div>

                <div class="kpi-card" style="padding: 16px; border-radius: 16px; background: #fff; border: 1px solid var(--color-borde-suave); box-shadow: 0 2px 8px rgba(0,0,0,0.02);">
                    <div class="kpi-titulo" style="font-size: 11px; color: var(--color-texto-suave); text-transform: uppercase;">Lotes Activos FEFO</div>
                    <div class="kpi-valor" style="font-size: 26px; font-weight: 700; color: #2980B9; font-family: 'Playfair Display', Georgia, serif;">
                        <asp:Label ID="lblKpiLotes" runat="server" Text="0"></asp:Label>
                    </div>
                    <div style="font-size: 11px; color: #2980B9;">Con fecha de caducidad vigente</div>
                </div>

                <div class="kpi-card" style="padding: 16px; border-radius: 16px; background: #fff; border: 1px solid var(--color-borde-suave); box-shadow: 0 2px 8px rgba(0,0,0,0.02);">
                    <div class="kpi-titulo" style="font-size: 11px; color: var(--color-texto-suave); text-transform: uppercase;">Inversi&oacute;n en Bodega</div>
                    <div class="kpi-valor" style="font-size: 24px; font-weight: 700; color: var(--color-acento); font-family: 'Playfair Display', Georgia, serif;">
                        <asp:Label ID="lblKpiValorizado" runat="server" Text="$0"></asp:Label>
                    </div>
                    <div style="font-size: 11px; color: var(--color-texto-suave);">Valorizado costo de adquisici&oacute;n</div>
                </div>
            </div>

            <!-- PANEL DE NOTIFICACIONES -->
            <asp:Panel ID="pnlMensaje" runat="server" Visible="false" style="margin-bottom: 20px; border-radius: 14px; padding: 12px 18px; font-size: 13px;">
                <asp:Label ID="lblMensaje" runat="server"></asp:Label>
            </asp:Panel>

            <!-- FORMULARIO DE RECEPCION Y ASIGNACION DE LOTES -->
            <asp:Panel ID="pnlFormularioRec" runat="server" Visible="false" CssClass="form-rec-card">
                <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px; border-bottom: 1px solid var(--color-borde-suave); padding-bottom: 12px;">
                    <div>
                        <span class="pill-badge" style="font-size: 10px; padding: 3px 10px;">RECEPCI&Oacute;N F&Iacute;SICA</span>
                        <h2 style="font-size: 20px; margin-top: 4px;">Ingreso de Mercader&iacute;a contra &Oacute;rden de Compra</h2>
                    </div>
                    <asp:Button ID="btnCerrarForm" runat="server" Text="Cerrar Formulario" CssClass="btn-dermo-secondary" style="font-size: 12px; padding: 6px 14px;" OnClick="btnCerrarForm_Click" />
                </div>

                <!-- 1. CABECERA DE LA RECEPCION -->
                <div class="form-section-title">
                    <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"></path><polyline points="14 2 14 8 20 8"></polyline></svg>
                    1. Datos de la &Oacute;rden de Compra y Documento Tributario del Proveedor
                </div>

                <div class="form-grid-3col">
                    <div class="form-group-dermo">
                        <label class="label-dermo">Seleccionar &Oacute;rden de Compra (*)</label>
                        <asp:DropDownList ID="ddlOrdenCompra" runat="server" CssClass="select-dermo" AutoPostBack="true" OnSelectedIndexChanged="ddlOrdenCompra_SelectedIndexChanged"></asp:DropDownList>
                    </div>

                    <div class="form-group-dermo">
                        <label class="label-dermo">N&deg; Gu&iacute;a de Despacho / Factura Proveedor (*)</label>
                        <asp:TextBox ID="txtGuiaDespacho" runat="server" CssClass="input-dermo" placeholder="Ej: GD-884920"></asp:TextBox>
                    </div>

                    <div class="form-group-dermo">
                        <label class="label-dermo">Fecha de Recepci&oacute;n (*)</label>
                        <asp:TextBox ID="txtFechaRecepcion" runat="server" TextMode="Date" CssClass="input-dermo"></asp:TextBox>
                    </div>
                </div>

                <!-- BANNER DE RESUMEN DE LA OC SELECCIONADA -->
                <asp:Panel ID="pnlInfoOC" runat="server" Visible="false" CssClass="info-oc-banner">
                    <div><strong>Laboratorio:</strong> <asp:Label ID="lblInfoLaboratorio" runat="server"></asp:Label></div>
                    <div><strong>RUT Proveedor:</strong> <asp:Label ID="lblInfoRut" runat="server"></asp:Label></div>
                    <div><strong>Fecha Emisi&oacute;n OC:</strong> <asp:Label ID="lblInfoFechaOC" runat="server"></asp:Label></div>
                    <div><strong>Estado Actual:</strong> <asp:Label ID="lblInfoEstadoOC" runat="server" Font-Bold="true"></asp:Label></div>
                    <div><strong>Monto Total OC:</strong> <asp:Label ID="lblInfoTotalOC" runat="server" ForeColor="#7A5E47" Font-Bold="true"></asp:Label></div>
                </asp:Panel>

                <!-- 2. DETALLE DE PRODUCTOS A RECEPCIONAR Y ASIGNACION DE LOTES -->
                <div class="form-section-title">
                    <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M21 16V8a2 2 0 0 0-1-1.73l-7-4a2 2 0 0 0-2 0l-7 4A2 2 0 0 0 3 8v8a2 2 0 0 0 1 1.73l7 4a2 2 0 0 0 2 0l7-4A2 2 0 0 0 21 16z"></path><polyline points="3.27 6.96 12 12.01 20.73 6.96"></polyline><line x1="12" y1="22.08" x2="12" y2="12"></line></svg>
                    2. Asignaci&oacute;n de Lotes, Vencimientos y Conteo F&iacute;sico (RF-COM-06 / FEFO)
                </div>

                <p class="text-muted" style="margin-bottom: 12px; font-size: 12px;">
                    Indique la cantidad recepcionada efectivamente en bodega, el c&oacute;digo de lote impreso en el empaque y la fecha de caducidad exigida para el control de inventario FEFO.
                </p>

                <div class="table-dermo-container" style="margin-bottom: 20px;">
                    <asp:GridView ID="gvItemsRecepcion" runat="server" AutoGenerateColumns="False" CssClass="table-dermo-modern" EmptyDataText="Seleccione una orden de compra para cargar sus l&iacute;neas de productos.">
                        <Columns>
                            <asp:BoundField DataField="Sku" HeaderText="SKU" />
                            <asp:BoundField DataField="Producto" HeaderText="Producto e Insumo" />
                            <asp:BoundField DataField="NombreVariante" HeaderText="Variante / Presentaci&oacute;n" />
                            <asp:BoundField DataField="CantidadPedida" HeaderText="Pedidas" />
                            <asp:BoundField DataField="CantidadRecibida" HeaderText="Ya Recibidas" />
                            <asp:BoundField DataField="CantidadPendiente" HeaderText="Pendientes" />

                            <asp:TemplateField HeaderText="Cant. a Recibir (*)">
                                <ItemTemplate>
                                    <asp:HiddenField ID="hfIdDetalleOC" runat="server" Value='<%# Eval("IdDetalleOC") %>' />
                                    <asp:HiddenField ID="hfIdVariante" runat="server" Value='<%# Eval("IdVariante") %>' />
                                    <asp:HiddenField ID="hfCostoUnitario" runat="server" Value='<%# Eval("CostoUnitario") %>' />
                                    <asp:HiddenField ID="hfCantidadPendiente" runat="server" Value='<%# Eval("CantidadPendiente") %>' />
                                    <asp:TextBox ID="txtCantRecibir" runat="server" Text='<%# Eval("CantidadPendiente") %>' TextMode="Number" min="0" max='<%# Eval("CantidadPendiente") %>' CssClass="input-dermo" style="width: 80px; padding: 6px;"></asp:TextBox>
                                </ItemTemplate>
                            </asp:TemplateField>

                            <asp:TemplateField HeaderText="N&deg; Lote (*)">
                                <ItemTemplate>
                                    <asp:TextBox ID="txtNumeroLote" runat="server" Text='<%# Eval("SugerenciaLote") %>' CssClass="input-dermo" placeholder="Ej: LOT-2026-A" style="width: 140px; padding: 6px; font-weight: 600;"></asp:TextBox>
                                </ItemTemplate>
                            </asp:TemplateField>

                            <asp:TemplateField HeaderText="Fecha Vencimiento (*)">
                                <ItemTemplate>
                                    <asp:TextBox ID="txtFechaVencimiento" runat="server" Text='<%# Eval("SugerenciaVencimiento") %>' TextMode="Date" CssClass="input-dermo" style="width: 135px; padding: 6px;"></asp:TextBox>
                                </ItemTemplate>
                            </asp:TemplateField>

                            <asp:BoundField DataField="CostoUnitario" HeaderText="Costo Unit." DataFormatString="{0:C0}" />
                        </Columns>
                    </asp:GridView>
                </div>

                <div style="background-color: #FAF8F5; border-radius: 12px; padding: 14px 18px; border: 1px solid var(--color-borde-suave); margin-bottom: 20px;">
                    <strong style="color: var(--color-acento); font-size: 12px;">Regla de Integraci&oacute;n Transaccional (ACID):</strong>
                    <span style="font-size: 12px; color: var(--color-texto-suave);">
                        Al aprobar la recepci&oacute;n, el sistema registrar&aacute; el movimiento f&iacute;sico en `RecepcionCompra`, dar&aacute; de alta los lotes disponibles en `Lote` (Inventario), recalcular&aacute; el stock total y actualizar&aacute; el estado de la &Oacute;rden de Compra a `Recibida` o `Parcial` de forma simult&aacute;nea.
                    </span>
                </div>

                <!-- BOTONES DE ACCION -->
                <div style="display: flex; justify-content: flex-end; gap: 12px;">
                    <asp:Button ID="btnCancelarForm" runat="server" Text="Cancelar" CssClass="btn-dermo-secondary" OnClick="btnCerrarForm_Click" />
                    <asp:Button ID="btnAprobarRecepcion" runat="server" Text="Aprobar e Ingresar a Bodega" CssClass="btn-dermo-primary" style="padding: 12px 28px; background: #27AE60;" OnClick="btnAprobarRecepcion_Click" />
                </div>
            </asp:Panel>

            <!-- BARRA DE BUSQUEDA Y FILTROS -->
            <div class="filter-toolbar-row">
                <div style="position: relative; display: flex; align-items: center;">
                    <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" style="position: absolute; left: 14px; color: var(--color-texto-suave);"><circle cx="11" cy="11" r="8"></circle><line x1="21" y1="21" x2="16.65" y2="16.65"></line></svg>
                    <asp:TextBox ID="txtBuscar" runat="server" CssClass="input-dermo" placeholder="Buscar por N&deg; recepci&oacute;n, gu&iacute;a, OC o proveedor..." style="padding-left: 38px; border-radius: 20px;" AutoPostBack="true" OnTextChanged="txtBuscar_TextChanged"></asp:TextBox>
                </div>

                <div>
                    <asp:DropDownList ID="ddlFiltroLaboratorio" runat="server" CssClass="select-dermo" style="border-radius: 20px;" AutoPostBack="true" OnSelectedIndexChanged="ddlFiltroLaboratorio_SelectedIndexChanged"></asp:DropDownList>
                </div>

                <div>
                    <asp:Button ID="btnLimpiarFiltros" runat="server" Text="Limpiar" CssClass="btn-dermo-secondary" style="border-radius: 20px; padding: 10px 16px; font-size: 12px;" OnClick="btnLimpiarFiltros_Click" />
                </div>
            </div>

            <!-- TABLA PRINCIPAL DE RECEPCIONES HISTORICAS -->
            <div class="table-dermo-container">
                <asp:GridView ID="gvRecepciones" runat="server" AutoGenerateColumns="False" CssClass="table-dermo-modern" EmptyDataText="No se registran recepciones de mercader&iacute;a para los criterios seleccionados." OnRowCommand="gvRecepciones_RowCommand">
                    <Columns>
                        <asp:TemplateField HeaderText="N&deg; Recepci&oacute;n">
                            <ItemTemplate>
                                <strong style="color: var(--color-acento); font-size: 14px;">REC-<%# string.Format("{0:D4}", Eval("IdRecepcion")) %></strong>
                            </ItemTemplate>
                        </asp:TemplateField>

                        <asp:TemplateField HeaderText="&Oacute;rden de Compra">
                            <ItemTemplate>
                                <strong><%# Eval("NumeroOC") %></strong>
                            </ItemTemplate>
                        </asp:TemplateField>

                        <asp:TemplateField HeaderText="Laboratorio / Proveedor">
                            <ItemTemplate>
                                <div style="font-weight: 600;"><%# Eval("RazonSocial") %></div>
                                <div class="text-muted" style="font-size: 11px;">RUT: <%# Eval("Rut") %></div>
                            </ItemTemplate>
                        </asp:TemplateField>

                        <asp:BoundField DataField="GuiaDespacho" HeaderText="N&deg; Gu&iacute;a Despacho" />
                        <asp:BoundField DataField="FechaRecepcion" HeaderText="Fecha Recepci&oacute;n" DataFormatString="{0:dd/MM/yyyy}" />
                        <asp:BoundField DataField="TotalUnidades" HeaderText="Unidades Recibidas" />

                        <asp:TemplateField HeaderText="Estado">
                            <ItemTemplate>
                                <span class='<%# Eval("Estado").ToString() == "Completa" ? "badge-rec-completa" : "badge-rec-parcial" %>'>
                                    <%# Eval("Estado") %>
                                </span>
                            </ItemTemplate>
                        </asp:TemplateField>

                        <asp:TemplateField HeaderText="Total Valorizado ($)">
                            <ItemTemplate>
                                <strong style="font-family: 'Playfair Display', serif; font-size: 14px;"><%# string.Format("{0:C0}", Eval("MontoValorizado")) %></strong>
                            </ItemTemplate>
                        </asp:TemplateField>

                        <asp:TemplateField HeaderText="Acciones">
                            <ItemTemplate>
                                <asp:LinkButton ID="btnVer" runat="server" CommandName="VerDetalle" CommandArgument='<%# Eval("IdRecepcion") %>' CssClass="btn-dermo-secondary" style="padding: 4px 10px; font-size: 11px; text-decoration: none;">
                                    Ver Lotes y Detalle
                                </asp:LinkButton>
                            </ItemTemplate>
                        </asp:TemplateField>
                    </Columns>
                </asp:GridView>
            </div>

        </div>

        <!-- MODAL DE CONSULTA DE LOTES RECIBIDOS (SOLO LECTURA) -->
        <asp:Panel ID="pnlModalDetalle" runat="server" Visible="false" CssClass="modal-overlay">
            <div class="modal-content-card">
                <div style="display: flex; justify-content: space-between; align-items: center; border-bottom: 1px solid var(--color-borde-suave); padding-bottom: 14px; margin-bottom: 20px;">
                    <div>
                        <span class="pill-badge" style="font-size: 10px; padding: 3px 10px;">DETALLE DE INGRESO</span>
                        <h2 style="font-size: 22px; margin-top: 4px;">
                            Recepci&oacute;n <asp:Label ID="lblModalIdRec" runat="server" ForeColor="#7A5E47"></asp:Label>
                        </h2>
                    </div>
                    <asp:Button ID="btnCerrarModal" runat="server" Text="Cerrar" CssClass="btn-dermo-secondary" style="padding: 6px 16px; font-size: 12px;" OnClick="btnCerrarModal_Click" />
                </div>

                <div class="info-oc-banner" style="margin-bottom: 20px;">
                    <div><strong>&Oacute;rden de Compra:</strong> <asp:Label ID="lblModalOC" runat="server"></asp:Label></div>
                    <div><strong>Proveedor:</strong> <asp:Label ID="lblModalProveedor" runat="server"></asp:Label></div>
                    <div><strong>Gu&iacute;a Despacho:</strong> <asp:Label ID="lblModalGuia" runat="server" Font-Bold="true"></asp:Label></div>
                    <div><strong>Fecha:</strong> <asp:Label ID="lblModalFecha" runat="server"></asp:Label></div>
                    <div><strong>Estado:</strong> <asp:Label ID="lblModalEstado" runat="server" Font-Bold="true"></asp:Label></div>
                </div>

                <div class="table-dermo-container" style="margin-bottom: 20px;">
                    <asp:GridView ID="gvModalLotes" runat="server" AutoGenerateColumns="False" CssClass="table-dermo-modern" EmptyDataText="No hay productos registrados en esta recepci&oacute;n.">
                        <Columns>
                            <asp:BoundField DataField="Sku" HeaderText="SKU" />
                            <asp:BoundField DataField="Producto" HeaderText="Producto" />
                            <asp:BoundField DataField="NombreVariante" HeaderText="Variante" />
                            <asp:BoundField DataField="NumeroLote" HeaderText="N&deg; Lote Asignado" />
                            <asp:BoundField DataField="FechaVencimiento" HeaderText="Vencimiento (FEFO)" DataFormatString="{0:dd/MM/yyyy}" />
                            <asp:BoundField DataField="Cantidad" HeaderText="Unidades" />
                            <asp:BoundField DataField="CostoUnitario" HeaderText="Costo Unit." DataFormatString="{0:C0}" />
                            <asp:BoundField DataField="SubtotalLinea" HeaderText="Total Línea" DataFormatString="{0:C0}" />
                        </Columns>
                    </asp:GridView>
                </div>

                <div style="text-align: right; margin-top: 25px; border-top: 1px solid var(--color-borde-suave); padding-top: 15px;">
                    <button type="button" onclick="window.print();" class="btn-dermo-secondary" style="cursor: pointer; padding: 10px 20px;">
                        Imprimir Comprobante de Entrada
                    </button>
                    <asp:Button ID="btnCerrarModal2" runat="server" Text="Aceptar y Salir" CssClass="btn-dermo-primary" style="margin-left: 10px; padding: 10px 22px;" OnClick="btnCerrarModal_Click" />
                </div>
            </div>
        </asp:Panel>

    </form>
</body>
</html>
