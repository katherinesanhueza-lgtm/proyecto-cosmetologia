<%@ Page Title="Cotizaciones de importación" Language="C#" MasterPageFile="~/Contabilidad.Master" AutoEventWireup="true" CodeBehind="CotizacionesImportacion.aspx.cs" Inherits="trabajo_ing_software.CotizacionesImportacion" ResponseEncoding="utf-8" ContentType="text/html; charset=utf-8" %>

<asp:Content ID="Recursos" ContentPlaceHolderID="EstilosPagina" runat="server">
    <style>
        .cot-container { width: 100%; }

        .kpi-row-4col {
            display: grid;
            grid-template-columns: repeat(4, 1fr);
            gap: 16px;
            margin-bottom: 24px;
        }

        .kpi-card-luxury {
            background: var(--color-blanco);
            border: 1px solid var(--color-borde-suave);
            border-radius: 18px;
            padding: 18px 20px;
            display: flex;
            align-items: center;
            gap: 14px;
        }

        .kpi-icon-wrap {
            width: 44px;
            height: 44px;
            border-radius: 12px;
            display: flex;
            align-items: center;
            justify-content: center;
            flex-shrink: 0;
        }

        .kpi-titulo {
            font-size: 11px;
            text-transform: uppercase;
            letter-spacing: 0.7px;
            color: var(--color-texto-suave);
            font-weight: 700;
        }

        .kpi-valor {
            font-family: 'Playfair Display', Georgia, serif;
            font-size: 24px;
            font-weight: 700;
            color: var(--color-texto);
        }

        .cot-head-row-1 {
            display: grid;
            grid-template-columns: 1.6fr 1fr;
            gap: 14px;
            align-items: start;
            margin-bottom: 12px;
        }
        .cot-head-row-2 {
            display: grid;
            grid-template-columns: 1fr 1.6fr;
            gap: 14px;
            align-items: start;
        }

        .item-add-row {
            display: grid;
            grid-template-columns: minmax(220px, 1fr) 95px 145px auto;
            gap: 12px;
            align-items: end;
            background: #FAF8F5;
            padding: 14px 16px;
            border-radius: 14px;
            border: 1px solid var(--color-borde-suave);
            margin-bottom: 14px;
        }

        .filter-toolbar-row {
            display: grid;
            grid-template-columns: minmax(220px, 1fr) 200px auto;
            gap: 12px;
            align-items: center;
            background-color: var(--color-blanco);
            border: 1px solid var(--color-borde-suave);
            border-radius: 16px;
            padding: 14px 18px !important;
            margin-bottom: 22px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.02);
        }

        .badge-cot {
            padding: 4px 11px;
            border-radius: 14px;
            font-size: 11px;
            font-weight: 600;
            display: inline-block;
        }
        .badge-cot-solicitada { background: #EBF3FA; color: #2980B9; }
        .badge-cot-aprobada { background: #E8F8F0; color: #27AE60; }
        .badge-cot-rechazada { background: #FDEDEC; color: #C0392B; }
        .badge-cot-convertida { background: #F5EFEB; color: #7A5E47; }

        @media (max-width: 960px) {
            .kpi-row-4col { grid-template-columns: repeat(2, 1fr); }
            .cot-head-row-1, .cot-head-row-2, .item-add-row { grid-template-columns: 1fr; }
            .filter-toolbar-row { grid-template-columns: 1fr auto; }
            .filter-toolbar-row > div:first-child { grid-column: 1 / -1; }
        }
    </style>
</asp:Content>

<asp:Content ID="Acciones" ContentPlaceHolderID="AccionesUsuario" runat="server">
    <asp:Label ID="lblBienvenida" Visible="false" runat="server"></asp:Label>
    <asp:Button ID="btnLogout" runat="server" Text="Cerrar Sesi&oacute;n" CssClass="btn btn-outline-secondary btn-sm cierre-compras" OnClick="btnLogout_Click" />
</asp:Content>

<asp:Content ID="Contenido" ContentPlaceHolderID="MainContent" runat="server">
    <div class="dashboard compras-contenido">
        <div class="cot-container">

            <!-- ENCABEZADO -->
            <div style="display: flex; justify-content: space-between; align-items: flex-end; margin-bottom: 24px; flex-wrap: wrap; gap: 14px;">
                <div>
                    <span class="pill-badge" style="font-size: 10px; padding: 4px 12px; margin-bottom: 8px;">M&Oacute;DULO DE COMPRAS - ABASTECIMIENTO</span>
                    <h1>Cotizaciones de Importaci&oacute;n</h1>
                    <p class="text-muted" style="margin-top: 4px;">Evaluaci&oacute;n de costos con proveedores extranjeros, conversi&oacute;n por tipo de cambio y generaci&oacute;n de &Oacute;rdenes de Compra.</p>
                </div>
                <div style="display: flex; gap: 10px; flex-wrap: wrap;">
                    <a href="ReporteCotizaciones.aspx" class="btn btn-outline-secondary">
                        <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" aria-hidden="true"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"></path><polyline points="14 2 14 8 20 8"></polyline><line x1="16" y1="13" x2="8" y2="13"></line><line x1="16" y1="17" x2="8" y2="17"></line><polyline points="10 9 9 9 8 9"></polyline></svg>
                        Reporte Variaci&oacute;n Costos
                    </a>
                    <asp:Button ID="btnToggleForm" runat="server" Text="+ Nueva Cotizaci&oacute;n" CssClass="btn btn-primary" OnClick="btnToggleForm_Click" />
                </div>
            </div>

            <!-- KPIS TARJETAS -->
            <div class="kpi-row-4col">
                <div class="kpi-card-luxury">
                    <div class="kpi-icon-wrap" style="background: #F4EFEB; color: #7A5E47;">
                        <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"></path><polyline points="14 2 14 8 20 8"></polyline></svg>
                    </div>
                    <div>
                        <div class="kpi-titulo">Total Cotizaciones</div>
                        <div class="kpi-valor"><asp:Label ID="lblKpiTotal" runat="server" Text="0"></asp:Label></div>
                    </div>
                </div>

                <div class="kpi-card-luxury">
                    <div class="kpi-icon-wrap" style="background: #EBF5FB; color: #2980B9;">
                        <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="10"></circle><polyline points="12 6 12 12 16 14"></polyline></svg>
                    </div>
                    <div>
                        <div class="kpi-titulo">En Evaluaci&oacute;n</div>
                        <div class="kpi-valor" style="color: #2980B9;"><asp:Label ID="lblKpiSolicitadas" runat="server" Text="0"></asp:Label></div>
                    </div>
                </div>

                <div class="kpi-card-luxury">
                    <div class="kpi-icon-wrap" style="background: #E8F8F0; color: #27AE60;">
                        <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="20 6 9 17 4 12"></polyline></svg>
                    </div>
                    <div>
                        <div class="kpi-titulo">Aprobadas p/ OC</div>
                        <div class="kpi-valor" style="color: #27AE60;"><asp:Label ID="lblKpiAprobadas" runat="server" Text="0"></asp:Label></div>
                    </div>
                </div>

                <div class="kpi-card-luxury">
                    <div class="kpi-icon-wrap" style="background: #F4EFEB; color: #7A5E47;">
                        <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><line x1="12" y1="1" x2="12" y2="23"></line><path d="M17 5H9.5a3.5 3.5 0 0 0 0 7h5a3.5 3.5 0 0 1 0 7H6"></path></svg>
                    </div>
                    <div>
                        <div class="kpi-titulo">Monto Estimado CLP</div>
                        <div class="kpi-valor" style="font-size: 20px;"><asp:Label ID="lblKpiMontoClp" runat="server" Text="$0"></asp:Label></div>
                    </div>
                </div>
            </div>

            <!-- MENSAJES -->
            <asp:Label ID="lblMensaje" runat="server" Visible="false" style="display: block; padding: 12px 16px; border-radius: 12px; margin-bottom: 18px; font-size: 13px; font-weight: 500;"></asp:Label>

            <!-- MODAL FLOTANTE NUEVA COTIZACION -->
            <asp:Panel ID="pnlFormulario" runat="server" Visible="false" CssClass="modal-overlay">
                <div class="modal-content-card modal-lg-card">
                <div class="modal-header-dermo">
                    <div>
                        <span class="pill-badge" style="font-size: 10px; padding: 3px 10px;">IMPORTACI&Oacute;N DE INSUMOS</span>
                        <h2 style="font-size: 22px; margin: 6px 0 2px 0; font-family: 'Playfair Display', Georgia, serif; color: var(--color-texto);">Registrar Cotizaci&oacute;n de Importaci&oacute;n</h2>
                        <div style="font-size: 12px; color: var(--color-texto-suave);">Detalle de proveedor extranjero, divisa y art&iacute;culos cotizados</div>
                    </div>
                    <asp:Button ID="btnCerrarForm" runat="server" Text="&#215;" CssClass="btn btn-outline-secondary btn-sm modal-close-x" OnClick="btnCerrarForm_Click" CausesValidation="false" ToolTip="Cerrar ventana" />
                </div>

                <div class="modal-section-box">
                    <div class="cot-head-row-1">
                        <div>
                            <label class="form-label">Laboratorio / Proveedor Extranjero (*)</label>
                            <asp:DropDownList ID="ddlLaboratorio" runat="server" CssClass="form-select" AutoPostBack="true" OnSelectedIndexChanged="ddlLaboratorio_SelectedIndexChanged"></asp:DropDownList>
                            <small class="text-muted d-block mt-1"><asp:Label ID="lblInfoLab" runat="server" Text="Seleccione un proveedor"></asp:Label></small>
                        </div>
                        <div>
                            <label class="form-label">Fecha Cotizaci&oacute;n (*)</label>
                            <asp:TextBox ID="txtFecha" runat="server" TextMode="Date" CssClass="form-control"></asp:TextBox>
                        </div>
                    </div>

                    <div class="cot-head-row-2">
                        <div>
                            <label class="form-label">Moneda (*)</label>
                            <asp:DropDownList ID="ddlMoneda" runat="server" CssClass="form-select" AutoPostBack="true" OnSelectedIndexChanged="ddlMoneda_SelectedIndexChanged">
                                <asp:ListItem Value="USD" Text="USD ($)" Selected="True"></asp:ListItem>
                                <asp:ListItem Value="EUR" Text="EUR (&euro;)"></asp:ListItem>
                                <asp:ListItem Value="CLP" Text="CLP ($)"></asp:ListItem>
                            </asp:DropDownList>
                        </div>
                        <div>
                            <div style="display: flex; justify-content: space-between; align-items: center; gap: 8px; margin-bottom: 5px;">
                                <label class="form-label" style="margin-bottom: 0;">Tipo Cambio (CLP)</label>
                                <asp:LinkButton ID="btnActualizarTC" runat="server" OnClick="btnActualizarTC_Click" CausesValidation="false"
                                    style="font-size: 0.76rem; color: #7A5E47; text-decoration: none; font-weight: 600; white-space: nowrap;"
                                    ToolTip="Sincronizar tasa oficial en vivo">Actualizar cambio</asp:LinkButton>
                            </div>
                            <asp:TextBox ID="txtTipoCambio" runat="server" CssClass="form-control" Text="950"></asp:TextBox>
                            <small style="display: block; font-size: 0.74rem; margin-top: 4px;">
                                <asp:Label ID="lblInfoTipoCambio" runat="server" Text="Al d&iacute;a · Editable" ForeColor="#27AE60"></asp:Label>
                            </small>
                        </div>
                    </div>
                </div>

                <!-- AGREGAR PRODUCTOS -->
                <div class="item-add-row">
                    <div>
                        <label class="form-label">Producto / Insumo Cosm&eacute;tico</label>
                        <asp:DropDownList ID="ddlProducto" runat="server" CssClass="form-select" AutoPostBack="true" OnSelectedIndexChanged="ddlProducto_SelectedIndexChanged"></asp:DropDownList>
                    </div>
                    <div>
                        <label class="form-label">Cantidad</label>
                        <asp:TextBox ID="txtCantidad" runat="server" TextMode="Number" CssClass="form-control" Text="10"></asp:TextBox>
                    </div>
                    <div>
                        <label class="form-label">Costo Unitario</label>
                        <asp:TextBox ID="txtCostoMoneda" runat="server" CssClass="form-control" placeholder="Ej: 15.50"></asp:TextBox>
                    </div>
                    <div>
                        <asp:Button ID="btnAgregarItem" runat="server" Text="+ Agregar" CssClass="btn btn-primary" style="height: 38px; white-space: nowrap;" OnClick="btnAgregarItem_Click" />
                    </div>
                </div>

                <!-- DETALLE TEMPORAL -->
                <div class="table-dermo-container" style="margin-bottom: 16px;">
                    <asp:GridView ID="gvDetalleCot" runat="server" AutoGenerateColumns="False" CssClass="table table-hover align-middle" GridLines="None" EmptyDataText="No hay productos agregados a la cotizaci&oacute;n." OnRowCommand="gvDetalleCot_RowCommand">
                        <Columns>
                            <asp:BoundField DataField="Sku" HeaderText="SKU" />
                            <asp:BoundField DataField="Producto" HeaderText="Producto" />
                            <asp:BoundField DataField="Cantidad" HeaderText="Cantidad" />
                            <asp:BoundField DataField="CostoUnitario" HeaderText="Costo Unit. (Origen)" DataFormatString="{0:N2}" />
                            <asp:BoundField DataField="SubtotalOrigen" HeaderText="Subtotal (Origen)" DataFormatString="{0:N2}" />
                            <asp:TemplateField HeaderText="Quitar">
                                <ItemTemplate>
                                    <asp:Button ID="btnQuitar" runat="server" Text="Quitar" CommandName="QuitarItem" CommandArgument="<%# Container.DataItemIndex %>" CssClass="btn btn-outline-danger btn-sm" />
                                </ItemTemplate>
                            </asp:TemplateField>
                        </Columns>
                    </asp:GridView>
                </div>

                <!-- RESUMEN Y GUARDAR -->
                <div style="display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 14px; border-top: 1px solid var(--color-borde-suave); padding-top: 16px;">
                    <div style="font-size: 14px;">
                        Total Origen: <strong><asp:Label ID="lblTotalMoneda" runat="server" Text="0.00"></asp:Label> <asp:Label ID="lblMonedaResumen" runat="server" Text="USD"></asp:Label></strong>
                        &nbsp;|&nbsp;
                        Equivalente Neto CLP: <strong style="color: var(--color-acento); font-size: 17px;"><asp:Label ID="lblTotalClp" runat="server" Text="$0"></asp:Label></strong>
                    </div>
                    <div style="display: flex; gap: 10px;">
                        <asp:Button ID="btnCancelarForm" runat="server" Text="Cancelar" CssClass="btn btn-outline-secondary" OnClick="btnCerrarForm_Click" />
                        <asp:Button ID="btnGuardarCot" runat="server" Text="Guardar Cotizaci&oacute;n" CssClass="btn btn-primary" OnClick="btnGuardarCot_Click" />
                    </div>
                </div>
                </div>
            </asp:Panel>

            <!-- FILTROS -->
            <div class="filter-toolbar-row card-dermocosmetica">
                <div style="position: relative; flex: 1; min-width: 240px;">
                    <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" style="position: absolute; left: 14px; top: 50%; transform: translateY(-50%); color: var(--color-texto-suave); pointer-events: none;"><circle cx="11" cy="11" r="8"></circle><line x1="21" y1="21" x2="16.65" y2="16.65"></line></svg>
                    <asp:TextBox ID="txtBuscar" runat="server" CssClass="form-control" style="padding-left: 38px;" placeholder="Buscar por laboratorio o moneda..." AutoPostBack="true" OnTextChanged="Filtros_Changed"></asp:TextBox>
                </div>
                <div>
                    <asp:DropDownList ID="ddlFiltroEstado" runat="server" CssClass="form-select" AutoPostBack="true" OnSelectedIndexChanged="Filtros_Changed">
                        <asp:ListItem Value="" Text="Todos los Estados"></asp:ListItem>
                        <asp:ListItem Value="Solicitada" Text="Solicitada"></asp:ListItem>
                        <asp:ListItem Value="Aprobada" Text="Aprobada"></asp:ListItem>
                        <asp:ListItem Value="Convertida" Text="Convertida a OC"></asp:ListItem>
                        <asp:ListItem Value="Rechazada" Text="Rechazada"></asp:ListItem>
                    </asp:DropDownList>
                </div>
                <asp:Button ID="btnLimpiarFiltros" runat="server" Text="Limpiar filtros" CssClass="btn btn-outline-secondary" OnClick="btnLimpiarFiltros_Click" />
            </div>

            <!-- LISTADO -->
            <div class="table-dermo-container">
                <asp:GridView ID="gvCotizaciones" runat="server" AutoGenerateColumns="False" CssClass="table table-hover align-middle" GridLines="None" EmptyDataText="No hay cotizaciones de importaci&oacute;n registradas." OnRowCommand="gvCotizaciones_RowCommand">
                    <Columns>
                        <asp:TemplateField HeaderText="N&deg; COT">
                            <ItemTemplate>
                                <strong style="color: var(--color-acento);">COT-<%# string.Format("{0:D4}", Eval("IdCotizacion")) %></strong>
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:BoundField DataField="RazonSocial" HeaderText="Laboratorio" />
                        <asp:BoundField DataField="Fecha" HeaderText="Fecha" DataFormatString="{0:dd/MM/yyyy}" />
                        <asp:BoundField DataField="Moneda" HeaderText="Moneda" />
                        <asp:BoundField DataField="TipoCambio" HeaderText="Tipo Cambio" DataFormatString="{0:N2}" />
                        <asp:TemplateField HeaderText="Total Origen">
                            <ItemTemplate>
                                <%# string.Format("{0:N2} {1}", Eval("TotalOrigen"), Eval("Moneda")) %>
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:BoundField DataField="TotalClp" HeaderText="Neto CLP" DataFormatString="{0:C0}" />
                        <asp:TemplateField HeaderText="Estado">
                            <ItemTemplate>
                                <span class='badge-cot badge-cot-<%# Eval("Estado").ToString().ToLower() %>'><%# Eval("Estado") %></span>
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Acciones">
                            <ItemTemplate>
                                <div style="display: flex; gap: 6px; flex-wrap: wrap;">
                                    <asp:LinkButton ID="btnVer" runat="server" CommandName="VerDetalle" CommandArgument='<%# Eval("IdCotizacion") %>' CssClass="btn btn-outline-secondary btn-sm">Ver</asp:LinkButton>
                                    <asp:LinkButton ID="btnAprobar" runat="server" CommandName="AprobarCot" CommandArgument='<%# Eval("IdCotizacion") %>' Visible='<%# PuedeEditar && Eval("Estado").ToString() == "Solicitada" %>' CssClass="btn btn-primary btn-sm">Aprobar</asp:LinkButton>
                                    <asp:LinkButton ID="btnConvertir" runat="server" CommandName="ConvertirOC" CommandArgument='<%# Eval("IdCotizacion") %>' Visible='<%# PuedeEditar && Eval("Estado").ToString() == "Aprobada" %>' CssClass="btn btn-primary btn-sm" OnClientClick="return confirm('&iquest;Generar Orden de Compra en CLP desde esta cotizaci&oacute;n?');">Convertir a OC</asp:LinkButton>
                                    <asp:LinkButton ID="btnRechazar" runat="server" CommandName="RechazarCot" CommandArgument='<%# Eval("IdCotizacion") %>' Visible='<%# PuedeEditar && Eval("Estado").ToString() == "Solicitada" %>' CssClass="btn btn-outline-danger btn-sm">Rechazar</asp:LinkButton>
                                </div>
                            </ItemTemplate>
                        </asp:TemplateField>
                    </Columns>
                </asp:GridView>
            </div>
        </div>

        <!-- MODAL DETALLE -->
        <asp:Panel ID="pnlModalDetalle" runat="server" Visible="false" CssClass="modal-overlay">
            <div class="modal-content-card">
                <div style="display: flex; justify-content: space-between; align-items: center; border-bottom: 1px solid var(--color-borde-suave); padding-bottom: 12px; margin-bottom: 16px;">
                    <h2 style="font-size: 20px; margin: 0;">Detalle Cotizaci&oacute;n <asp:Label ID="lblModalId" runat="server" ForeColor="#7A5E47"></asp:Label></h2>
                    <asp:Button ID="btnCerrarModal" runat="server" Text="Cerrar" CssClass="btn btn-outline-secondary btn-sm" OnClick="btnCerrarModal_Click" />
                </div>

                <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(170px, 1fr)); gap: 10px; background: #FAF8F5; padding: 14px; border-radius: 12px; margin-bottom: 16px; font-size: 13px;">
                    <div><strong>Laboratorio:</strong> <asp:Label ID="lblModalLab" runat="server"></asp:Label></div>
                    <div><strong>Fecha:</strong> <asp:Label ID="lblModalFecha" runat="server"></asp:Label></div>
                    <div><strong>Moneda:</strong> <asp:Label ID="lblModalMoneda" runat="server"></asp:Label></div>
                    <div><strong>Tipo Cambio:</strong> <asp:Label ID="lblModalTC" runat="server"></asp:Label></div>
                    <div><strong>Estado:</strong> <asp:Label ID="lblModalEstado" runat="server" Font-Bold="true"></asp:Label></div>
                </div>

                <div class="table-dermo-container" style="margin-bottom: 16px;">
                    <asp:GridView ID="gvModalItems" runat="server" AutoGenerateColumns="False" CssClass="table table-hover align-middle" GridLines="None">
                        <Columns>
                            <asp:BoundField DataField="Sku" HeaderText="SKU" />
                            <asp:BoundField DataField="Producto" HeaderText="Producto" />
                            <asp:BoundField DataField="Cantidad" HeaderText="Cantidad" />
                            <asp:BoundField DataField="CostoUnitario" HeaderText="Costo Unit." DataFormatString="{0:N2}" />
                            <asp:BoundField DataField="SubtotalOrigen" HeaderText="Subtotal" DataFormatString="{0:N2}" />
                        </Columns>
                    </asp:GridView>
                </div>

                <div style="text-align: right; font-size: 14px;">
                    Total Origen: <strong><asp:Label ID="lblModalTotalMoneda" runat="server"></asp:Label></strong>
                    &nbsp;|&nbsp;
                    Equivalente Neto CLP: <strong style="color: var(--color-acento); font-size: 17px;"><asp:Label ID="lblModalTotalClp" runat="server"></asp:Label></strong>
                </div>

                <div style="text-align: right; margin-top: 20px; border-top: 1px solid var(--color-borde-suave); padding-top: 14px;">
                    <asp:Button ID="btnCerrarModal2" runat="server" Text="Aceptar y Salir" CssClass="btn btn-primary" OnClick="btnCerrarModal_Click" />
                </div>
            </div>
        </asp:Panel>
    </div>
</asp:Content>
