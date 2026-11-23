<%@ Page Title="Devoluciones y reclamos" Language="C#" MasterPageFile="~/Contabilidad.Master" AutoEventWireup="true" CodeBehind="DevolucionesProveedor.aspx.cs" Inherits="trabajo_ing_software.DevolucionesProveedor" ResponseEncoding="utf-8" ContentType="text/html; charset=utf-8" %>

<asp:Content ID="Recursos" ContentPlaceHolderID="EstilosPagina" runat="server">
    <style>
        .dev-container { width: 100%; }

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

        .form-grid-2col {
            display: grid;
            grid-template-columns: 1.7fr 1fr;
            gap: 14px;
            align-items: end;
        }

        .form-grid-3col {
            display: grid;
            grid-template-columns: 1.55fr 110px 1.35fr;
            gap: 14px;
            align-items: end;
        }

        .filter-toolbar-row {
            display: grid;
            grid-template-columns: minmax(220px, 1fr) 210px auto;
            gap: 12px;
            align-items: center;
            background-color: var(--color-blanco);
            border: 1px solid var(--color-borde-suave);
            border-radius: 16px;
            padding: 14px 18px !important;
            margin-bottom: 20px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.02);
        }

        .badge-dev {
            padding: 4px 11px;
            border-radius: 14px;
            font-size: 11px;
            font-weight: 600;
            display: inline-block;
        }
        .badge-dev-pendiente { background: #FEF9E7; color: #B7950B; }
        .badge-dev-revision { background: #EBF3FA; color: #2980B9; }
        .badge-dev-aceptado { background: #E8F8F0; color: #27AE60; }
        .badge-dev-rechazado { background: #FDEDEC; color: #C0392B; }

        @media (max-width: 960px) {
            .kpi-row-4col { grid-template-columns: repeat(2, 1fr); }
            .form-grid-2col, .form-grid-3col { grid-template-columns: 1fr; }
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
        <div class="dev-container">

            <!-- ENCABEZADO -->
            <div style="display: flex; justify-content: space-between; align-items: flex-end; margin-bottom: 24px; flex-wrap: wrap; gap: 14px;">
                <div>
                    <span class="pill-badge" style="font-size: 10px; padding: 4px 12px; margin-bottom: 8px;">M&Oacute;DULO DE COMPRAS - CONTROL DE CALIDAD</span>
                    <h1>Devoluciones y Reclamos a Proveedor</h1>
                    <p class="text-muted" style="margin-top: 4px;">Registro de no conformidades sobre recepciones y lotes, seguimiento de reclamos y compensaciones de proveedor.</p>
                </div>
                <div style="display: flex; gap: 10px; flex-wrap: wrap;">
                    <a href="ReporteComprasLaboratorio.aspx" class="btn btn-outline-secondary">
                        <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" aria-hidden="true"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"></path><polyline points="14 2 14 8 20 8"></polyline><line x1="16" y1="13" x2="8" y2="13"></line><line x1="16" y1="17" x2="8" y2="17"></line><polyline points="10 9 9 9 8 9"></polyline></svg>
                        Reporte Lab. y Marca
                    </a>
                    <a href="Recepciones.aspx" class="btn btn-outline-secondary">Ir a Recepciones</a>
                    <asp:Button ID="btnToggleForm" runat="server" Text="+ Nuevo Reclamo / Devoluci&oacute;n" CssClass="btn btn-primary" OnClick="btnToggleForm_Click" />
                </div>
            </div>

            <!-- KPIS -->
            <div class="kpi-row-4col">
                <div class="kpi-card-luxury">
                    <div class="kpi-icon-wrap" style="background: #F4EFEB; color: #7A5E47;">
                        <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"></path><polyline points="14 2 14 8 20 8"></polyline></svg>
                    </div>
                    <div>
                        <div class="kpi-titulo">Total Reclamos</div>
                        <div class="kpi-valor"><asp:Label ID="lblKpiTotal" runat="server" Text="0"></asp:Label></div>
                    </div>
                </div>
                <div class="kpi-card-luxury">
                    <div class="kpi-icon-wrap" style="background: #EBF3FA; color: #2980B9;">
                        <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="10"></circle><polyline points="12 6 12 12 16 14"></polyline></svg>
                    </div>
                    <div>
                        <div class="kpi-titulo">Pendientes / Revisi&oacute;n</div>
                        <div class="kpi-valor" style="color: #2980B9;"><asp:Label ID="lblKpiPendientes" runat="server" Text="0"></asp:Label></div>
                    </div>
                </div>
                <div class="kpi-card-luxury">
                    <div class="kpi-icon-wrap" style="background: #E8F8F0; color: #27AE60;">
                        <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="20 6 9 17 4 12"></polyline></svg>
                    </div>
                    <div>
                        <div class="kpi-titulo">Aceptados</div>
                        <div class="kpi-valor" style="color: #27AE60;"><asp:Label ID="lblKpiAceptados" runat="server" Text="0"></asp:Label></div>
                    </div>
                </div>
                <div class="kpi-card-luxury">
                    <div class="kpi-icon-wrap" style="background: #FDEDEC; color: #C0392B;">
                        <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><line x1="12" y1="1" x2="12" y2="23"></line><path d="M17 5H9.5a3.5 3.5 0 0 0 0 7h5a3.5 3.5 0 0 1 0 7H6"></path></svg>
                    </div>
                    <div>
                        <div class="kpi-titulo">Monto Reclamado (CLP)</div>
                        <div class="kpi-valor" style="font-size: 20px;"><asp:Label ID="lblKpiMonto" runat="server" Text="$0"></asp:Label></div>
                    </div>
                </div>
            </div>

            <!-- ALERTAS -->
            <asp:Label ID="lblMensaje" runat="server" Visible="false" style="display: block; padding: 14px 18px; border-radius: 14px; margin-bottom: 18px; font-weight: 500;"></asp:Label>

            <!-- MODAL FLOTANTE NUEVO RECLAMO -->
            <asp:Panel ID="pnlFormulario" runat="server" Visible="false" CssClass="modal-overlay">
                <div class="modal-content-card modal-md-card">
                    <div class="modal-header-dermo">
                        <div>
                            <span class="pill-badge" style="font-size: 10px; padding: 3px 10px;">CALIDAD Y PROVEEDORES</span>
                            <h2 style="font-size: 22px; margin: 6px 0 2px 0; font-family: 'Playfair Display', Georgia, serif; color: var(--color-texto);">Registrar Reclamo / Devoluci&oacute;n a Proveedor</h2>
                        </div>
                        <asp:LinkButton ID="btnCerrarForm" runat="server" CssClass="btn btn-outline-secondary btn-sm modal-close-x" OnClick="btnCancelarForm_Click" CausesValidation="false" ToolTip="Cerrar ventana">&times;</asp:LinkButton>
                    </div>

                    <div class="modal-section-box" style="margin-bottom: 12px;">
                        <div class="form-grid-2col" style="margin-bottom: 14px;">
                            <div>
                                <label class="form-label">1. Recepci&oacute;n / Orden de Compra *</label>
                                <asp:DropDownList ID="ddlRecepcion" runat="server" CssClass="form-select" AutoPostBack="true" OnSelectedIndexChanged="ddlRecepcion_SelectedIndexChanged"></asp:DropDownList>
                            </div>
                            <div>
                                <label class="form-label">Fecha del Reclamo *</label>
                                <asp:TextBox ID="txtFecha" runat="server" TextMode="Date" CssClass="form-control"></asp:TextBox>
                            </div>
                        </div>

                        <div class="form-grid-3col" style="margin-bottom: 14px;">
                            <div>
                                <label class="form-label">2. Lote e Insumo Afectado *</label>
                                <asp:DropDownList ID="ddlLote" runat="server" CssClass="form-select"></asp:DropDownList>
                            </div>
                            <div>
                                <label class="form-label">Cantidad *</label>
                                <asp:TextBox ID="txtCantidad" runat="server" TextMode="Number" CssClass="form-control" Text="1" min="1"></asp:TextBox>
                            </div>
                            <div>
                                <label class="form-label">Motivo de No Conformidad *</label>
                                <asp:DropDownList ID="ddlMotivoTipo" runat="server" CssClass="form-select">
                                    <asp:ListItem Value="Rotura de empaque" Text="Rotura de empaque"></asp:ListItem>
                                    <asp:ListItem Value="Producto dañado / envase defectuoso" Text="Producto da&#241;ado / envase defectuoso"></asp:ListItem>
                                    <asp:ListItem Value="Sello de seguridad violado" Text="Sello de seguridad violado"></asp:ListItem>
                                    <asp:ListItem Value="Discrepancia de lote / cantidad" Text="Discrepancia de lote / cantidad"></asp:ListItem>
                                    <asp:ListItem Value="Fecha de vencimiento próxima" Text="Fecha de vencimiento pr&#243;xima"></asp:ListItem>
                                    <asp:ListItem Value="Otro motivo" Text="Otro motivo"></asp:ListItem>
                                </asp:DropDownList>
                            </div>
                        </div>

                        <div>
                            <label class="form-label">Observaciones / Detalle del Reclamo</label>
                            <asp:TextBox ID="txtObservaciones" runat="server" CssClass="form-control" MaxLength="130" placeholder="Ej: Envases golpeados en recepci&oacute;n, se solicita Nota de Cr&eacute;dito o reposici&oacute;n"></asp:TextBox>
                        </div>
                    </div>

                    <div class="modal-footer-dermo">
                        <asp:Button ID="btnCancelarForm" runat="server" Text="Cancelar" CssClass="btn btn-outline-secondary" OnClick="btnCancelarForm_Click" CausesValidation="false" />
                        <asp:Button ID="btnGuardar" runat="server" Text="Guardar Reclamo" CssClass="btn btn-primary" OnClick="btnGuardar_Click" />
                    </div>
                </div>
            </asp:Panel>

            <!-- FILTROS -->
            <div class="filter-toolbar-row card-dermocosmetica">
                <div style="position: relative; display: flex; align-items: center; width: 100%;">
                    <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" style="position: absolute; left: 14px; color: var(--color-texto-suave); pointer-events: none;"><circle cx="11" cy="11" r="8"></circle><line x1="21" y1="21" x2="16.65" y2="16.65"></line></svg>
                    <asp:TextBox ID="txtBuscar" runat="server" CssClass="form-control" style="padding-left: 38px;" placeholder="Buscar por OC, recepci&oacute;n, lote o laboratorio..." AutoPostBack="true" OnTextChanged="Filtro_Changed"></asp:TextBox>
                </div>
                <div>
                    <asp:DropDownList ID="ddlFiltroEstado" runat="server" CssClass="form-select" AutoPostBack="true" OnSelectedIndexChanged="Filtro_Changed">
                        <asp:ListItem Value="" Text="Todos los Estados"></asp:ListItem>
                        <asp:ListItem Value="Pendiente" Text="Pendiente"></asp:ListItem>
                        <asp:ListItem Value="En Revisi&#243;n" Text="En Revisi&#243;n"></asp:ListItem>
                        <asp:ListItem Value="Aceptado" Text="Aceptado"></asp:ListItem>
                        <asp:ListItem Value="Rechazado" Text="Rechazado"></asp:ListItem>
                    </asp:DropDownList>
                </div>
                <div>
                    <asp:Button ID="btnLimpiarFiltros" runat="server" Text="Limpiar filtros" CssClass="btn btn-outline-secondary" OnClick="btnLimpiarFiltros_Click" CausesValidation="false" />
                </div>
            </div>

            <!-- LISTADO -->
            <div class="card-dermocosmetica">
                <div class="table-dermo-container" style="border: none; box-shadow: none;">
                    <asp:GridView ID="gvDevoluciones" runat="server" AutoGenerateColumns="False" CssClass="table table-hover align-middle" GridLines="None"
                        OnRowCommand="gvDevoluciones_RowCommand"
                        EmptyDataText="No se registran devoluciones o reclamos a proveedores para los filtros seleccionados.">
                        <Columns>
                            <asp:TemplateField HeaderText="N&deg; Reclamo">
                                <ItemTemplate>
                                    <strong style="color: var(--color-acento);"><%# string.Format("DEV-{0:D4}", Eval("IdDevolucion")) %></strong>
                                </ItemTemplate>
                            </asp:TemplateField>

                            <asp:BoundField DataField="Fecha" HeaderText="Fecha" DataFormatString="{0:dd/MM/yyyy}" />

                            <asp:TemplateField HeaderText="Recepci&oacute;n / OC">
                                <ItemTemplate>
                                    <div style="font-weight: 600;"><%# string.Format("REC-{0:D4}", Eval("IdRecepcion")) %></div>
                                    <div style="font-size: 11px; color: var(--color-texto-suave);"><%# Eval("NumeroOC") %></div>
                                </ItemTemplate>
                            </asp:TemplateField>

                            <asp:BoundField DataField="Laboratorio" HeaderText="Laboratorio" />

                            <asp:TemplateField HeaderText="Insumo y Lote">
                                <ItemTemplate>
                                    <div style="font-weight: 600;"><%# Eval("Producto") %></div>
                                    <div style="font-size: 11px; color: var(--color-texto-suave);">SKU: <%# Eval("Sku") %> &bull; Lote: <%# Eval("NumeroLote") %></div>
                                </ItemTemplate>
                            </asp:TemplateField>

                            <asp:TemplateField HeaderText="Cant.">
                                <ItemTemplate>
                                    <strong><%# Eval("Cantidad") %></strong> u.
                                </ItemTemplate>
                            </asp:TemplateField>

                            <asp:TemplateField HeaderText="Valor Est.">
                                <ItemTemplate>
                                    <strong><%# string.Format("{0:C0}", Eval("MontoReclamado")) %></strong>
                                </ItemTemplate>
                            </asp:TemplateField>

                            <asp:BoundField DataField="Motivo" HeaderText="Motivo" />

                            <asp:TemplateField HeaderText="Estado">
                                <ItemTemplate>
                                    <span class='badge-dev <%# GetClaseEstado(Eval("Estado")) %>'><%# Eval("Estado") %></span>
                                </ItemTemplate>
                            </asp:TemplateField>

                            <asp:TemplateField HeaderText="Acciones">
                                <ItemTemplate>
                                    <div style="display: flex; gap: 6px; flex-wrap: wrap;">
                                        <asp:LinkButton ID="btnVer" runat="server" CommandName="VerDetalle" CommandArgument='<%# Eval("IdDevolucion") %>' CssClass="btn btn-outline-secondary btn-sm">Detalle</asp:LinkButton>
                                        <asp:LinkButton ID="btnRevisar" runat="server" CommandName="Revisar" CommandArgument='<%# Eval("IdDevolucion") %>' Visible='<%# PuedeEditar && Eval("Estado").ToString() == "Pendiente" %>' CssClass="btn btn-outline-secondary btn-sm">En Revisi&oacute;n</asp:LinkButton>
                                        <asp:LinkButton ID="btnAceptar" runat="server" CommandName="Aceptar" CommandArgument='<%# Eval("IdDevolucion") %>' Visible='<%# PuedeEditar && (Eval("Estado").ToString() == "Pendiente" || Eval("Estado").ToString() == "En Revisi\u00f3n") %>' CssClass="btn btn-primary btn-sm" OnClientClick="return confirm('&iquest;Aceptar devoluci&oacute;n y rebajar las unidades devueltas del lote en Kardex?');">Aceptar</asp:LinkButton>
                                        <asp:LinkButton ID="btnRechazar" runat="server" CommandName="Rechazar" CommandArgument='<%# Eval("IdDevolucion") %>' Visible='<%# PuedeEditar && (Eval("Estado").ToString() == "Pendiente" || Eval("Estado").ToString() == "En Revisi\u00f3n") %>' CssClass="btn btn-outline-danger btn-sm">Rechazar</asp:LinkButton>
                                    </div>
                                </ItemTemplate>
                            </asp:TemplateField>
                        </Columns>
                    </asp:GridView>
                </div>
            </div>

        </div>
    </div>

    <!-- MODAL DETALLE -->
    <asp:Panel ID="pnlModalDetalle" runat="server" Visible="false" CssClass="modal-overlay">
        <div class="modal-content-card modal-md-card">
            <div class="modal-header-dermo">
                <div>
                    <span class="pill-badge" style="font-size: 10px; padding: 3px 10px;">FICHA DE RECLAMO A PROVEEDOR</span>
                    <h2 style="font-size: 22px; margin: 6px 0 2px 0; font-family: 'Playfair Display', Georgia, serif; color: var(--color-texto);">
                        <asp:Label ID="lblModalCodigo" runat="server"></asp:Label>
                    </h2>
                    <div style="font-size: 12px; color: var(--color-texto-suave);">Antecedentes del reclamo, lote afectado y valorizaci&oacute;n estimada</div>
                </div>
                <asp:Button ID="btnCerrarModal" runat="server" Text="&#215;" CssClass="btn btn-outline-secondary btn-sm modal-close-x" OnClick="btnCerrarModal_Click" CausesValidation="false" ToolTip="Cerrar ventana" />
            </div>

            <div class="modal-section-box" style="display: grid; grid-template-columns: repeat(2, minmax(0, 1fr)); gap: 12px 20px;">
                <div>
                    <div style="font-size: 10.5px; text-transform: uppercase; letter-spacing: 0.6px; color: var(--color-texto-suave); font-weight: 700;">Laboratorio</div>
                    <div style="font-size: 13.5px; font-weight: 600; color: var(--color-texto); margin-top: 2px;"><asp:Label ID="lblModalLab" runat="server"></asp:Label></div>
                </div>
                <div>
                    <div style="font-size: 10.5px; text-transform: uppercase; letter-spacing: 0.6px; color: var(--color-texto-suave); font-weight: 700;">Estado</div>
                    <div style="margin-top: 2px;"><span class="pill-badge" style="font-size: 11px; padding: 3px 10px;"><asp:Label ID="lblModalEstado" runat="server"></asp:Label></span></div>
                </div>
                <div>
                    <div style="font-size: 10.5px; text-transform: uppercase; letter-spacing: 0.6px; color: var(--color-texto-suave); font-weight: 700;">Orden de Compra</div>
                    <div style="font-size: 13.5px; font-weight: 600; color: var(--color-texto); margin-top: 2px;"><asp:Label ID="lblModalOC" runat="server"></asp:Label></div>
                </div>
                <div>
                    <div style="font-size: 10.5px; text-transform: uppercase; letter-spacing: 0.6px; color: var(--color-texto-suave); font-weight: 700;">Recepci&oacute;n / Gu&iacute;a</div>
                    <div style="font-size: 13.5px; font-weight: 500; color: var(--color-texto); margin-top: 2px;"><asp:Label ID="lblModalRec" runat="server"></asp:Label></div>
                </div>
                <div>
                    <div style="font-size: 10.5px; text-transform: uppercase; letter-spacing: 0.6px; color: var(--color-texto-suave); font-weight: 700;">Insumo (SKU)</div>
                    <div style="font-size: 13px; font-weight: 500; color: var(--color-texto); margin-top: 2px;"><asp:Label ID="lblModalProducto" runat="server"></asp:Label></div>
                </div>
                <div>
                    <div style="font-size: 10.5px; text-transform: uppercase; letter-spacing: 0.6px; color: var(--color-texto-suave); font-weight: 700;">Lote / Vencimiento</div>
                    <div style="font-size: 13px; font-weight: 500; color: var(--color-texto); margin-top: 2px;"><asp:Label ID="lblModalLote" runat="server"></asp:Label></div>
                </div>
                <div>
                    <div style="font-size: 10.5px; text-transform: uppercase; letter-spacing: 0.6px; color: var(--color-texto-suave); font-weight: 700;">Cantidad Devuelta</div>
                    <div style="font-size: 13.5px; font-weight: 700; color: var(--color-texto); margin-top: 2px;"><asp:Label ID="lblModalCantidad" runat="server"></asp:Label></div>
                </div>
                <div>
                    <div style="font-size: 10.5px; text-transform: uppercase; letter-spacing: 0.6px; color: var(--color-texto-suave); font-weight: 700;">Monto Reclamado</div>
                    <div style="font-size: 15px; font-weight: 700; color: var(--color-acento); margin-top: 2px;"><asp:Label ID="lblModalMonto" runat="server"></asp:Label></div>
                </div>
                <div>
                    <div style="font-size: 10.5px; text-transform: uppercase; letter-spacing: 0.6px; color: var(--color-texto-suave); font-weight: 700;">Fecha Reclamo</div>
                    <div style="font-size: 13px; color: var(--color-texto); margin-top: 2px;"><asp:Label ID="lblModalFecha" runat="server"></asp:Label></div>
                </div>
                <div>
                    <div style="font-size: 10.5px; text-transform: uppercase; letter-spacing: 0.6px; color: var(--color-texto-suave); font-weight: 700;">Registrado por</div>
                    <div style="font-size: 13px; color: var(--color-texto); margin-top: 2px;"><asp:Label ID="lblModalUsuario" runat="server"></asp:Label></div>
                </div>
            </div>

            <div style="background: #FFFFFF; padding: 14px 16px; border-radius: 12px; border: 1px solid var(--color-borde-suave); font-size: 13px;">
                <div style="font-size: 10.5px; text-transform: uppercase; letter-spacing: 0.6px; color: var(--color-texto-suave); font-weight: 700; margin-bottom: 4px;">Motivo y Observaciones</div>
                <div style="color: var(--color-texto); line-height: 1.5;"><asp:Label ID="lblModalMotivo" runat="server"></asp:Label></div>
            </div>

            <div class="modal-footer-dermo">
                <asp:Button ID="btnCerrarModalPie" runat="server" Text="Cerrar" CssClass="btn btn-primary" OnClick="btnCerrarModal_Click" CausesValidation="false" />
            </div>
        </div>
    </asp:Panel>
</asp:Content>
