<%@ Page Title="Recepciones y lotes" MasterPageFile="~/Contabilidad.Master" Language="C#" AutoEventWireup="true" CodeBehind="Recepciones.aspx.cs" Inherits="trabajo_ing_software.Recepciones" ResponseEncoding="utf-8" ContentType="text/html; charset=utf-8" %>
<asp:Content ID="Recursos" ContentPlaceHolderID="EstilosPagina" runat="server">
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
            grid-template-columns: minmax(220px, 1fr) 240px auto;
            gap: 12px;
            align-items: center;
            background-color: var(--color-blanco);
            border: 1px solid var(--color-borde-suave);
            border-radius: 16px;
            padding: 14px 18px !important;
            margin-bottom: 24px;
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

        .form-grid-2x2 {
            display: grid;
            grid-template-columns: 1.35fr 1fr;
            gap: 12px 16px;
            align-items: end;
        }
        @media (max-width: 760px) {
            .form-grid-2x2 {
                grid-template-columns: 1fr;
            }
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

        @media (max-width: 1024px) {
            .kpi-row-4col {
                grid-template-columns: repeat(2, 1fr);
            }
            .form-grid-3col {
                grid-template-columns: 1fr;
            }
            .filter-toolbar-row {
                grid-template-columns: 1fr auto;
            }
            .filter-toolbar-row > div:first-child {
                grid-column: 1 / -1;
            }
        }
        @media print {
            @page { size: A4 landscape; margin: 10mm; }
            body.imprimiendo-comprobante-entrada * { visibility: hidden !important; }
            body.imprimiendo-comprobante-entrada #pnlModalDetalle,
            body.imprimiendo-comprobante-entrada #pnlModalDetalle * { visibility: visible !important; }
            body.imprimiendo-comprobante-entrada #pnlModalDetalle {
                position: static !important;
                top: auto !important;
                left: auto !important;
                display: block !important;
                width: 100% !important;
                min-height: 0 !important;
                height: auto !important;
                padding: 0 !important;
                margin: 0 !important;
                overflow: visible !important;
                background: #fff !important;
                backdrop-filter: none !important;
                animation: none !important;
            }
            body.imprimiendo-comprobante-entrada #pnlModalDetalle .modal-content-card {
                width: 100% !important;
                max-width: none !important;
                max-height: none !important;
                height: auto !important;
                margin: 0 !important;
                padding: 0 !important;
                overflow: visible !important;
                border: 0 !important;
                box-shadow: none !important;
                animation: none !important;
            }
            body.imprimiendo-comprobante-entrada #pnlModalDetalle .modal-close-x,
            body.imprimiendo-comprobante-entrada #pnlModalDetalle .modal-footer-dermo,
            body.imprimiendo-comprobante-entrada .erp-header,
            body.imprimiendo-comprobante-entrada .erp-sidebar { display: none !important; }
            body.imprimiendo-comprobante-entrada #pnlModalDetalle .table-dermo-container,
            body.imprimiendo-comprobante-entrada #pnlModalDetalle .table-responsive {
                max-height: none !important;
                overflow: visible !important;
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
        <!-- CONTENEDOR PRINCIPAL -->
        <div class="rec-container">

            <!-- SUBHEADER Y ENCABEZADO -->
            <div style="display: flex; justify-content: space-between; align-items: flex-end; margin-bottom: 24px; flex-wrap: wrap; gap: 14px;">
                <div>
                    <span class="pill-badge" style="font-size: 10px; padding: 4px 12px; margin-bottom: 8px;">M&Oacute;DULO DE COMPRAS - RECEPCI&Oacute;N Y BODEGA</span>
                    <h1>Recepci&oacute;n de Mercader&iacute;a y Asignaci&oacute;n de Lotes</h1>
                    <p class="text-muted" style="margin-top: 4px;">Registro de gu&iacute;a de despacho, control f&iacute;sico de insumos contra &Oacute;rdenes de Compra, y asignaci&oacute;n de lotes y fechas de vencimiento bajo criterio FEFO.</p>
                </div>
                <div class="compras-acciones">
                    <a href="ReporteIngresos.aspx" class="btn btn-outline-secondary">
                        <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"></path><polyline points="14 2 14 8 20 8"></polyline><line x1="16" y1="13" x2="8" y2="13"></line><line x1="16" y1="17" x2="8" y2="17"></line></svg>
                        Reporte Consolidado
                    </a>
                    <asp:Button ID="btnToggleForm" runat="server" Text="Nueva Recepci&oacute;n de Mercader&iacute;a" CssClass="btn btn-primary" OnClick="btnToggleForm_Click" />
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

            <!-- MODAL FLOTANTE DE RECEPCION Y ASIGNACION DE LOTES -->
            <asp:Panel ID="pnlFormularioRec" runat="server" Visible="false" CssClass="modal-overlay">
                <div class="modal-content-card modal-lg-card" style="max-width: 980px;">
                <div class="modal-header-dermo">
                    <div>
                        <span class="pill-badge" style="font-size: 10px; padding: 3px 10px;">RECEPCI&Oacute;N F&Iacute;SICA</span>
                        <h2 style="font-size: 22px; margin: 6px 0 2px 0; font-family: 'Playfair Display', Georgia, serif; color: var(--color-texto);">Ingreso de Mercader&iacute;a contra &Oacute;rden de Compra</h2>
                    </div>
                    <asp:Button ID="btnCerrarForm" runat="server" Text="&#215;" CssClass="btn btn-outline-secondary btn-sm modal-close-x" OnClick="btnCerrarForm_Click" CausesValidation="false" ToolTip="Cerrar ventana" />
                </div>

                <!-- 1. CABECERA DE LA RECEPCION -->
                <div class="modal-section-box">
                    <div class="form-section-title" style="margin-bottom: 10px;">
                        <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"></path><polyline points="14 2 14 8 20 8"></polyline></svg>
                        1. Datos de la Orden de Compra y Documento del Proveedor
                    </div>

                    <div class="form-grid-2x2">
                        <div class="form-group-dermo">
                            <asp:Label runat="server" CssClass="form-label" AssociatedControlID="ddlOrdenCompra">Orden de Compra (*)</asp:Label>
                            <asp:DropDownList ID="ddlOrdenCompra" runat="server" CssClass="form-select" AutoPostBack="true" OnSelectedIndexChanged="ddlOrdenCompra_SelectedIndexChanged"></asp:DropDownList>
                        </div>

                        <div class="form-group-dermo">
                            <asp:Label runat="server" CssClass="form-label" AssociatedControlID="txtGuiaDespacho">N&deg; Gu&iacute;a / Factura Proveedor (*)</asp:Label>
                            <asp:TextBox ID="txtGuiaDespacho" runat="server" CssClass="form-control" placeholder="Ej: GD-884920"></asp:TextBox>
                        </div>

                        <div class="form-group-dermo">
                            <asp:Label runat="server" AssociatedControlID="ddlBodega" CssClass="form-label">Bodega de Destino (*)</asp:Label>
                            <asp:DropDownList ID="ddlBodega" runat="server" CssClass="form-select" />
                        </div>

                        <div class="form-group-dermo">
                            <asp:Label runat="server" CssClass="form-label" AssociatedControlID="txtFechaRecepcion">Fecha de Recepci&oacute;n (*)</asp:Label>
                            <asp:TextBox ID="txtFechaRecepcion" runat="server" TextMode="Date" CssClass="form-control"></asp:TextBox>
                        </div>
                    </div>

                    <!-- BANNER DE RESUMEN DE LA OC SELECCIONADA -->
                    <asp:Panel ID="pnlInfoOC" runat="server" Visible="false" CssClass="info-oc-banner" style="margin-top: 12px; margin-bottom: 0; background-color: #FFFFFF;">
                        <div><strong>Laboratorio:</strong> <asp:Label ID="lblInfoLaboratorio" runat="server"></asp:Label></div>
                        <div><strong>RUT Proveedor:</strong> <asp:Label ID="lblInfoRut" runat="server"></asp:Label></div>
                        <div><strong>Emisi&oacute;n OC:</strong> <asp:Label ID="lblInfoFechaOC" runat="server"></asp:Label></div>
                        <div><strong>Estado:</strong> <asp:Label ID="lblInfoEstadoOC" runat="server" Font-Bold="true"></asp:Label></div>
                        <div><strong>Total OC:</strong> <asp:Label ID="lblInfoTotalOC" runat="server" ForeColor="#7A5E47" Font-Bold="true"></asp:Label></div>
                    </asp:Panel>
                </div>

                <!-- 2. DETALLE DE PRODUCTOS A RECEPCIONAR Y ASIGNACION DE LOTES -->
                <div class="modal-section-box" style="margin-bottom: 12px;">
                    <div class="form-section-title" style="margin-bottom: 8px;">
                        <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M21 16V8a2 2 0 0 0-1-1.73l-7-4a2 2 0 0 0-2 0l-7 4A2 2 0 0 0 3 8v8a2 2 0 0 0 1 1.73l7 4a2 2 0 0 0 2 0l7-4A2 2 0 0 0 21 16z"></path><polyline points="3.27 6.96 12 12.01 20.73 6.96"></polyline><line x1="12" y1="22.08" x2="12" y2="12"></line></svg>
                        2. Asignaci&oacute;n de Lotes, Vencimientos y Conteo F&iacute;sico (FEFO)
                    </div>

                    <p class="text-muted" style="margin-bottom: 10px; font-size: 12px;">
                        Indique la cantidad recepcionada en bodega, el c&oacute;digo de lote impreso en el empaque y la fecha de caducidad para el control FEFO.
                    </p>

                    <div class="table-dermo-container" style="margin-bottom: 0; border-radius: 12px; overflow-x: auto;">
                        <asp:GridView ID="gvItemsRecepcion" runat="server" AutoGenerateColumns="False" CssClass="table table-hover align-middle mb-0" GridLines="None" ShowHeaderWhenEmpty="True" style="margin-bottom: 0; font-size: 13px;">
                            <EmptyDataTemplate>
                                <div style="padding: 18px 16px; text-align: center; color: #736E67; font-size: 13px; background: #FFFFFF;">
                                    Seleccione una <strong>Orden de Compra pendiente</strong> en el paso 1 para cargar los productos, asignar el <strong>N&deg; de lote</strong> y definir la <strong>fecha de vencimiento (FEFO)</strong>.
                                </div>
                            </EmptyDataTemplate>
                            <Columns>
                                <asp:TemplateField HeaderText="Producto / SKU">
                                    <ItemTemplate>
                                        <div style="font-weight: 700; color: #24211E; line-height: 1.3;"><%# Eval("Producto") %></div>
                                        <div style="font-size: 11.5px; color: #736E67; margin-top: 2px;">
                                            <span style="font-weight: 600; color: #7A5E47;"><%# Eval("Sku") %></span> &middot; <%# Eval("NombreVariante") %>
                                        </div>
                                        <div style="font-size: 11px; color: #8C827A; margin-top: 2px;">
                                            Costo unit.: <strong><%# string.Format("{0:C0}", Eval("CostoUnitario")) %></strong>
                                        </div>
                                    </ItemTemplate>
                                </asp:TemplateField>

                                <asp:TemplateField HeaderText="Saldo OC" HeaderStyle-CssClass="text-center" ItemStyle-CssClass="text-center text-nowrap">
                                    <ItemTemplate>
                                        <span class="pill-badge" style="font-size: 11px; padding: 3px 9px; background-color: #F4EFEA; color: #5C4533;">
                                            Pend.: <strong><%# Eval("CantidadPendiente") %></strong>
                                        </span>
                                        <div style="font-size: 11px; color: #736E67; margin-top: 4px;">
                                            Ped.: <%# Eval("CantidadPedida") %> &middot; Rec.: <%# Eval("CantidadRecibida") %>
                                        </div>
                                    </ItemTemplate>
                                </asp:TemplateField>

                                <asp:TemplateField HeaderText="Cant. a Recibir (*)" HeaderStyle-CssClass="text-center" ItemStyle-CssClass="text-center">
                                    <ItemTemplate>
                                        <asp:HiddenField ID="hfIdDetalleOC" runat="server" Value='<%# Eval("IdDetalleOC") %>' />
                                        <asp:HiddenField ID="hfIdVariante" runat="server" Value='<%# Eval("IdVariante") %>' />
                                        <asp:HiddenField ID="hfCostoUnitario" runat="server" Value='<%# Eval("CostoUnitario") %>' />
                                        <asp:HiddenField ID="hfCantidadPendiente" runat="server" Value='<%# Eval("CantidadPendiente") %>' />
                                        <asp:TextBox ID="txtCantRecibir" runat="server" Text='<%# Eval("CantidadPendiente") %>' TextMode="Number" min="0" max='<%# Eval("CantidadPendiente") %>' CssClass="form-control form-control-sm text-center" style="width: 78px; margin: 0 auto;"></asp:TextBox>
                                    </ItemTemplate>
                                </asp:TemplateField>

                                <asp:TemplateField HeaderText="N&deg; Lote (*)">
                                    <ItemTemplate>
                                        <asp:TextBox ID="txtNumeroLote" runat="server" Text='<%# Eval("SugerenciaLote") %>' CssClass="form-control form-control-sm" placeholder="Ej: LOT-2026-A" style="width: 155px;"></asp:TextBox>
                                    </ItemTemplate>
                                </asp:TemplateField>

                                <asp:TemplateField HeaderText="Vencimiento (*)">
                                    <ItemTemplate>
                                        <asp:TextBox ID="txtFechaVencimiento" runat="server" Text='<%# Eval("SugerenciaVencimiento") %>' TextMode="Date" CssClass="form-control form-control-sm" style="width: 145px;"></asp:TextBox>
                                    </ItemTemplate>
                                </asp:TemplateField>
                            </Columns>
                        </asp:GridView>
                    </div>
                </div>

                <div style="background-color: #FAF8F5; border-radius: 12px; padding: 10px 14px; border: 1px solid var(--color-borde-suave); font-size: 12px; color: var(--color-texto-suave); line-height: 1.45;">
                    <strong style="color: var(--color-acento);">Integraci&oacute;n autom&aacute;tica de bodega:</strong>
                    Al aprobar la recepci&oacute;n se registrar&aacute; el ingreso f&iacute;sico, se dar&aacute;n de alta los lotes en inventario, se actualizar&aacute; el stock total y la orden pasar&aacute; a <strong>Recibida</strong> o <strong>Parcial</strong> de forma simult&aacute;nea.
                </div>

                <!-- BOTONES DE ACCION -->
                <div class="modal-footer-dermo">
                    <asp:Button ID="btnCancelarForm" runat="server" Text="Cancelar" CssClass="btn btn-outline-secondary" OnClick="btnCerrarForm_Click" />
                    <asp:Button ID="btnAprobarRecepcion" runat="server" Text="Aprobar e Ingresar a Bodega" CssClass="btn btn-primary" OnClick="btnAprobarRecepcion_Click" />
                </div>
                </div>
            </asp:Panel>

            <!-- BARRA DE BUSQUEDA Y FILTROS -->
            <div class="filter-toolbar-row card-dermocosmetica">
                <div style="position: relative; display: flex; align-items: center;">
                    <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" style="position: absolute; left: 14px; color: var(--color-texto-suave);"><circle cx="11" cy="11" r="8"></circle><line x1="21" y1="21" x2="16.65" y2="16.65"></line></svg>
                    <asp:TextBox ID="txtBuscar" runat="server" CssClass="form-control" style="padding-left: 38px;" placeholder="Buscar por N&deg; recepci&oacute;n, gu&iacute;a, OC o proveedor..." AutoPostBack="true" OnTextChanged="txtBuscar_TextChanged"></asp:TextBox>
                </div>

                <div>
                    <asp:DropDownList ID="ddlFiltroLaboratorio" runat="server" CssClass="form-select" AutoPostBack="true" OnSelectedIndexChanged="ddlFiltroLaboratorio_SelectedIndexChanged"></asp:DropDownList>
                </div>

                <div>
                    <asp:Button ID="btnLimpiarFiltros" runat="server" Text="Limpiar filtros" CssClass="btn btn-outline-secondary" OnClick="btnLimpiarFiltros_Click" />
                </div>
            </div>

            <!-- TABLA PRINCIPAL DE RECEPCIONES HISTORICAS -->
            <div class="table-dermo-container">
                <asp:GridView ID="gvRecepciones" runat="server" AutoGenerateColumns="False" CssClass="table table-hover align-middle" GridLines="None" EmptyDataText="No se registran recepciones de mercader&iacute;a para los criterios seleccionados." OnRowCommand="gvRecepciones_RowCommand">
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
                                <asp:LinkButton ID="btnVer" runat="server" CommandName="VerDetalle" CommandArgument='<%# Eval("IdRecepcion") %>' CssClass="btn btn-outline-secondary" style="padding: 4px 10px; font-size: 11px; text-decoration: none;">
                                    Ver Lotes y Detalle
                                </asp:LinkButton>
                            </ItemTemplate>
                        </asp:TemplateField>
                    </Columns>
                </asp:GridView>
            </div>

        </div>

        <!-- MODAL DE CONSULTA DE LOTES RECIBIDOS (SOLO LECTURA) -->
        <asp:Panel ID="pnlModalDetalle" runat="server" ClientIDMode="Static" Visible="false" CssClass="modal-overlay">
            <div class="modal-content-card modal-lg-card">
                <div class="modal-header-dermo">
                    <div>
                        <span class="pill-badge" style="font-size: 10px; padding: 3px 10px;">DETALLE DE INGRESO</span>
                        <h2 style="font-size: 22px; margin: 6px 0 2px 0; font-family: 'Playfair Display', Georgia, serif; color: var(--color-texto);">
                            Recepci&oacute;n <asp:Label ID="lblModalIdRec" runat="server" ForeColor="#7A5E47"></asp:Label>
                        </h2>
                        <div style="font-size: 12px; color: var(--color-texto-suave);">Detalle de lotes ingresados a bodega y trazabilidad FEFO</div>
                    </div>
                    <asp:Button ID="btnCerrarModal" runat="server" Text="&#215;" CssClass="btn btn-outline-secondary btn-sm modal-close-x" OnClick="btnCerrarModal_Click" CausesValidation="false" ToolTip="Cerrar ventana" />
                </div>

                <div class="modal-section-box" style="display: grid; grid-template-columns: repeat(auto-fit, minmax(155px, 1fr)); gap: 12px 16px;">
                    <div>
                        <div style="font-size: 10.5px; text-transform: uppercase; letter-spacing: 0.6px; color: var(--color-texto-suave); font-weight: 700;">Orden de Compra</div>
                        <div style="font-size: 13.5px; font-weight: 600; color: var(--color-texto); margin-top: 2px;"><asp:Label ID="lblModalOC" runat="server"></asp:Label></div>
                    </div>
                    <div>
                        <div style="font-size: 10.5px; text-transform: uppercase; letter-spacing: 0.6px; color: var(--color-texto-suave); font-weight: 700;">Proveedor</div>
                        <div style="font-size: 13.5px; font-weight: 600; color: var(--color-texto); margin-top: 2px;"><asp:Label ID="lblModalProveedor" runat="server"></asp:Label></div>
                    </div>
                    <div>
                        <div style="font-size: 10.5px; text-transform: uppercase; letter-spacing: 0.6px; color: var(--color-texto-suave); font-weight: 700;">Gu&iacute;a Despacho</div>
                        <div style="font-size: 13.5px; font-weight: 700; color: var(--color-acento); margin-top: 2px;"><asp:Label ID="lblModalGuia" runat="server"></asp:Label></div>
                    </div>
                    <div>
                        <div style="font-size: 10.5px; text-transform: uppercase; letter-spacing: 0.6px; color: var(--color-texto-suave); font-weight: 700;">Fecha</div>
                        <div style="font-size: 13.5px; font-weight: 600; color: var(--color-texto); margin-top: 2px;"><asp:Label ID="lblModalFecha" runat="server"></asp:Label></div>
                    </div>
                    <div>
                        <div style="font-size: 10.5px; text-transform: uppercase; letter-spacing: 0.6px; color: var(--color-texto-suave); font-weight: 700;">Estado</div>
                        <div style="margin-top: 2px;"><span class="badge-rec-completa"><asp:Label ID="lblModalEstado" runat="server"></asp:Label></span></div>
                    </div>
                </div>

                <div class="table-dermo-container" style="margin-bottom: 12px; border-radius: 14px;">
                    <asp:GridView ID="gvModalLotes" runat="server" AutoGenerateColumns="False" CssClass="table table-hover align-middle" GridLines="None" EmptyDataText="No hay productos registrados en esta recepci&oacute;n.">
                        <Columns>
                            <asp:BoundField DataField="Sku" HeaderText="SKU" HeaderStyle-CssClass="text-nowrap" ItemStyle-CssClass="text-nowrap fw-semibold" />
                            <asp:BoundField DataField="Producto" HeaderText="Producto" />
                            <asp:BoundField DataField="NombreVariante" HeaderText="Variante" HeaderStyle-CssClass="text-nowrap" ItemStyle-CssClass="text-nowrap" />
                            <asp:BoundField DataField="NumeroLote" HeaderText="N&deg; Lote" HeaderStyle-CssClass="text-nowrap" ItemStyle-CssClass="text-nowrap" />
                            <asp:BoundField DataField="FechaVencimiento" HeaderText="Vencimiento" DataFormatString="{0:dd/MM/yyyy}" HeaderStyle-CssClass="text-nowrap text-center" ItemStyle-CssClass="text-nowrap text-center" />
                            <asp:BoundField DataField="Cantidad" HeaderText="Unid." HeaderStyle-CssClass="text-nowrap text-center" ItemStyle-CssClass="text-nowrap text-center fw-semibold" />
                            <asp:BoundField DataField="CostoUnitario" HeaderText="Costo Unit." DataFormatString="{0:C0}" HeaderStyle-CssClass="text-nowrap text-end" ItemStyle-CssClass="text-nowrap text-end" />
                            <asp:BoundField DataField="SubtotalLinea" HeaderText="Subtotal" DataFormatString="{0:C0}" HeaderStyle-CssClass="text-nowrap text-end" ItemStyle-CssClass="text-nowrap text-end fw-semibold" />
                        </Columns>
                    </asp:GridView>
                </div>

                <div class="modal-footer-dermo">
                    <button type="button" onclick="imprimirComprobanteEntrada();" class="btn btn-outline-secondary">
                        Imprimir Comprobante de Entrada
                    </button>
                    <asp:Button ID="btnCerrarModal2" runat="server" Text="Aceptar y Salir" CssClass="btn btn-primary" OnClick="btnCerrarModal_Click" />
                </div>
            </div>
        </asp:Panel>
        
    </div>
    <script>
        function imprimirComprobanteEntrada() {
            var modal = document.getElementById('pnlModalDetalle');
            if (!modal) return;
            var elementosOcultos = [];
            var actual = modal;
            while (actual && actual !== document.body) {
                var padre = actual.parentElement;
                if (!padre) break;
                Array.prototype.forEach.call(padre.children, function (hermano) {
                    if (hermano !== actual) {
                        elementosOcultos.push({ elemento: hermano, display: hermano.style.display });
                        hermano.style.display = 'none';
                    }
                });
                actual = padre;
            }
            document.body.classList.add('imprimiendo-comprobante-entrada');
            var limpiar = function () {
                elementosOcultos.forEach(function (registro) {
                    registro.elemento.style.display = registro.display;
                });
                document.body.classList.remove('imprimiendo-comprobante-entrada');
                window.removeEventListener('afterprint', limpiar);
            };
            window.addEventListener('afterprint', limpiar);
            window.print();
        }
    </script>
</asp:Content>
