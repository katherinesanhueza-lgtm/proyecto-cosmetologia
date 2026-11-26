<%@ Page Title="Reportes de Ventas" Language="C#" MasterPageFile="~/Contabilidad.Master" AutoEventWireup="true" CodeBehind="ReporteVentas.aspx.cs" Inherits="trabajo_ing_software.ReporteVentas" ResponseEncoding="utf-8" ContentType="text/html; charset=utf-8" %>

<asp:Content ID="Estilos" ContentPlaceHolderID="EstilosPagina" runat="server">
    <script src="https://cdnjs.cloudflare.com/ajax/libs/html2pdf.js/0.10.1/html2pdf.bundle.min.js"></script>
    <style>
        .report-container {
            max-width: 1400px;
            margin: 25px auto 50px auto;
            padding: 0 24px;
        }

        .filter-card {
            background-color: var(--color-blanco);
            border: 1px solid var(--color-primario);
            border-radius: 16px;
            padding: 16px 20px !important;
            margin-bottom: 22px;
            box-shadow: 0 3px 12px rgba(50, 38, 27, 0.04);
        }

        .filter-grid-5col {
            display: grid !important;
            grid-template-columns: repeat(3, minmax(0, 1fr)) !important;
            gap: 12px 16px;
            align-items: end;
        }
        .filter-grid-5col > .compras-acciones {
            grid-column: 2 / -1 !important;
            display: flex !important;
            justify-content: flex-end;
            gap: 10px;
        }
        .filter-grid-5col > .compras-acciones .btn {
            height: 38px;
            min-width: 140px;
        }

        .kpi-grid-4col {
            display: grid;
            grid-template-columns: repeat(4, 1fr);
            gap: 18px;
            margin-bottom: 25px;
        }

        .kpi-card {
            background-color: var(--color-blanco);
            border-radius: 18px;
            padding: 20px;
            border: 1px solid var(--color-borde-suave);
            box-shadow: 0 4px 15px rgba(122, 94, 71, 0.04);
            text-align: center;
        }

        .kpi-valor {
            font-family: 'Playfair Display', Georgia, serif;
            font-size: 28px;
            font-weight: 700;
            color: var(--color-acento);
            margin: 6px 0;
        }

        .kpi-titulo {
            font-size: 11px;
            color: var(--color-texto-suave);
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }

        /* Hoja formal de reporte para pantalla e impresión PDF */
        .printable-sheet {
            background-color: var(--color-blanco);
            border-radius: 20px;
            border: 1px solid var(--color-borde-suave);
            padding: 35px;
            box-shadow: 0 4px 20px rgba(0,0,0,0.03);
        }

        .report-header-banner {
            display: flex;
            justify-content: space-between;
            align-items: flex-start;
            border-bottom: 2px solid var(--color-acento);
            padding-bottom: 18px;
            margin-bottom: 25px;
        }

        .badge-bol { background-color: #EBF3FA; color: #2980B9; padding: 4px 10px; border-radius: 15px; font-weight: 600; font-size: 11px; display: inline-block; white-space: nowrap; }
        .badge-fac { background-color: #E8F8F0; color: #27AE60; padding: 4px 10px; border-radius: 15px; font-weight: 600; font-size: 11px; display: inline-block; white-space: nowrap; }
        .badge-nc { background-color: #FDEDEC; color: #C0392B; padding: 4px 10px; border-radius: 15px; font-weight: 600; font-size: 11px; display: inline-block; white-space: nowrap; }
        .badge-warn { background-color: #FEF9E7; color: #B7950B; padding: 4px 10px; border-radius: 15px; font-weight: 600; font-size: 11px; display: inline-block; white-space: nowrap; }

        .share-bar-wrap {
            width: 100%;
            max-width: 110px;
            height: 7px;
            background: #EFEBE6;
            border-radius: 6px;
            overflow: hidden;
            margin-top: 4px;
        }
        .share-bar-fill {
            height: 100%;
            background: var(--color-acento);
            border-radius: 6px;
        }

        .printable-sheet .table th,
        .printable-sheet .table td {
            padding: 10px 8px;
            font-size: 12.5px;
        }

        @media (max-width: 960px) {
            .filter-grid-5col {
                grid-template-columns: repeat(2, minmax(0, 1fr)) !important;
            }
            .filter-grid-5col > .compras-acciones {
                grid-column: 1 / -1 !important;
                justify-content: flex-start;
            }
            .kpi-grid-4col {
                grid-template-columns: repeat(2, 1fr);
            }
        }
        @media (max-width: 600px) {
            .filter-grid-5col {
                grid-template-columns: 1fr !important;
            }
        }
    </style>
</asp:Content>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <div class="dashboard compras-contenido">
        <div class="report-container">

            <!-- Selector interno oculto para mantener compatibilidad -->
            <div class="d-none">
                <asp:DropDownList ID="ddlTipoReporte" runat="server" AutoPostBack="true" OnSelectedIndexChanged="ddlTipoReporte_SelectedIndexChanged">
                    <asp:ListItem Text="1. Historial de Ventas y Comprobantes" Value="1" Selected="True"></asp:ListItem>
                    <asp:ListItem Text="2. Ventas y Rentabilidad por Producto" Value="2"></asp:ListItem>
                    <asp:ListItem Text="3. Comportamiento y Créditos por Cliente" Value="3"></asp:ListItem>
                    <asp:ListItem Text="4. Rendimiento Comercial por Vendedor" Value="4"></asp:ListItem>
                    <asp:ListItem Text="5. Presupuestos y Tasa de Conversión" Value="5"></asp:ListItem>
                    <asp:ListItem Text="Pareto de clientes mayoristas" Value="6" />
                    <asp:ListItem Text="Ingresos por categoría" Value="7" />
                    <asp:ListItem Text="Efectividad de entregas" Value="8" />
                </asp:DropDownList>
                <asp:Button ID="btnDescargarPDF" runat="server" Visible="false" />
                <asp:Label ID="lblCantidadVentas" runat="server" Text="0"></asp:Label>
                <asp:Label ID="lblIngresosTotales" runat="server" Text="$0"></asp:Label>
            </div>

            <!-- ENCABEZADO Y ACCIONES DE EXPORTACION (IDÉNTICO AL MÓDULO DE COMPRAS) -->
            <div class="no-print" style="display: flex; justify-content: space-between; align-items: flex-end; margin-bottom: 24px; flex-wrap: wrap; gap: 14px;">
                <div>
                    <span class="pill-badge" style="font-size: 10px; padding: 4px 12px; margin-bottom: 8px;"><asp:Label ID="lblBadgeReporte" runat="server" Text="REPORTE ANALÍTICO N° 1 - VENTAS"></asp:Label></span>
                    <h1><asp:Label ID="lblTituloPagina" runat="server" Text="Estado de Documentos de Venta"></asp:Label></h1>
                    <p class="text-muted" style="margin-top: 4px;"><asp:Label ID="lblSubtituloPagina" runat="server" Text="Monitoreo analítico de boletas, facturas y notas de crédito emitidas, con liquidación de IVA Débito Fiscal."></asp:Label></p>
                </div>
                <div class="compras-acciones">
                    <a href="<%: ObtenerUrlRetorno() %>" class="btn btn-outline-secondary">
                        <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" aria-hidden="true"><polyline points="15 18 9 12 15 6"></polyline></svg>
                        <%: ObtenerTextoRetorno() %>
                    </a>
                    <button type="button" onclick="generarPDF();" class="btn btn-primary">
                        <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" aria-hidden="true"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"></path><polyline points="14 2 14 8 20 8"></polyline><line x1="12" y1="18" x2="12" y2="12"></line><line x1="9" y1="15" x2="15" y2="15"></line></svg>
                        Descargar PDF
                    </button>
                    <asp:Button ID="btnExportarExcel" runat="server" Text="Exportar Excel" CssClass="btn btn-outline-secondary" OnClick="btnExportarExcel_Click" />
                </div>
            </div>

            <!-- TARJETAS DE KPIS ANALITICOS (ARRIBA DE LOS FILTROS, IGUAL QUE EN COMPRAS) -->
            <div runat="server" id="indicadoresDetalle" class="kpi-grid-4col no-print">
                <div class="kpi-card">
                    <div class="kpi-titulo"><asp:Label ID="lblKpi1Titulo" runat="server" Text="Total Documentos"></asp:Label></div>
                    <div class="kpi-valor"><asp:Label ID="lblTotalTransacciones" runat="server" Text="0"></asp:Label></div>
                    <div style="font-size: 11px; color: var(--color-texto-suave);"><asp:Label ID="lblKpi1Sub" runat="server" Text="En el período seleccionado"></asp:Label></div>
                </div>

                <div class="kpi-card">
                    <div class="kpi-titulo"><asp:Label ID="lblKpi2Titulo" runat="server" Text="Total Neto Ventas"></asp:Label></div>
                    <div class="kpi-valor" style="font-size: 24px;"><asp:Label ID="lblNetoTotal" runat="server" Text="$0"></asp:Label></div>
                    <div style="font-size: 11px; color: var(--color-texto-suave);"><asp:Label ID="lblKpi2Sub" runat="server" Text="Base imponible sin IVA"></asp:Label></div>
                </div>

                <div class="kpi-card">
                    <div class="kpi-titulo"><asp:Label ID="lblKpi3Titulo" runat="server" Text="IVA Débito Fiscal (19%)"></asp:Label></div>
                    <div class="kpi-valor" style="font-size: 24px; color: #2980B9;"><asp:Label ID="lblIvaTotal" runat="server" Text="$0"></asp:Label></div>
                    <div style="font-size: 11px; color: #2980B9;"><asp:Label ID="lblKpi3Sub" runat="server" Text="Impuesto fiscal devengado"></asp:Label></div>
                </div>

                <div class="kpi-card">
                    <div class="kpi-titulo"><asp:Label ID="lblKpi4Titulo" runat="server" Text="Total Facturado (c/ IVA)"></asp:Label></div>
                    <div class="kpi-valor" style="font-size: 24px; color: #27AE60;"><asp:Label ID="Label1" runat="server" Text="$0"></asp:Label></div>
                    <div style="font-size: 11px; color: #27AE60;"><asp:Label ID="lblKpi4Sub" runat="server" Text="Ingresos brutos del período"></asp:Label></div>
                </div>
            </div>

            <!-- BARRA DE FILTROS AVANZADOS (DEBAJO DE KPIS, CON FILTRAR Y LIMPIAR FILTROS) -->
            <section class="filter-card card-dermocosmetica no-print" aria-label="Filtros del reporte">
                <div class="filter-grid-5col">
                    <div class="form-group-dermo" style="margin-bottom: 0;">
                        <asp:Label runat="server" CssClass="form-label" AssociatedControlID="txtFechaDesde">Fecha Desde</asp:Label>
                        <asp:TextBox ID="txtFechaDesde" runat="server" CssClass="form-control" TextMode="Date"></asp:TextBox>
                    </div>

                    <div class="form-group-dermo" style="margin-bottom: 0;">
                        <asp:Label runat="server" CssClass="form-label" AssociatedControlID="txtFechaHasta">Fecha Hasta</asp:Label>
                        <asp:TextBox ID="txtFechaHasta" runat="server" CssClass="form-control" TextMode="Date"></asp:TextBox>
                    </div>

                    <div class="form-group-dermo" style="margin-bottom: 0;">
                        <asp:Label runat="server" CssClass="form-label" AssociatedControlID="ddlFiltroCliente">Cliente / Raz&oacute;n Social</asp:Label>
                        <asp:DropDownList ID="ddlFiltroCliente" runat="server" CssClass="form-select"></asp:DropDownList>
                    </div>

                    <div class="form-group-dermo" style="margin-bottom: 0;">
                        <asp:Label runat="server" CssClass="form-label" AssociatedControlID="ddlFiltroDocumento">Tipo Documento</asp:Label>
                        <asp:DropDownList ID="ddlFiltroDocumento" runat="server" CssClass="form-select">
                            <asp:ListItem Text="Todos los Documentos" Value="Todos"></asp:ListItem>
                            <asp:ListItem Text="Solo Boletas" Value="Boleta"></asp:ListItem>
                            <asp:ListItem Text="Solo Facturas" Value="Factura"></asp:ListItem>
                            <asp:ListItem Text="Solo Notas de Cr&#233;dito" Value="Nota de Credito"></asp:ListItem>
                        </asp:DropDownList>
                    </div>

                    <div class="compras-acciones">
                        <asp:Button ID="btnFiltrar" runat="server" Text="Filtrar" CssClass="btn btn-primary" OnClick="btnFiltrar_Click" />
                        <asp:Button ID="btnLimpiar" runat="server" Text="Limpiar filtros" CssClass="btn btn-outline-secondary" OnClick="btnLimpiar_Click" />
                    </div>
                </div>
            </section>

            <!-- HOJA FORMAL DEL REPORTE (EXPORTABLE A PDF, IDÉNTICA A COMPRAS) -->
            <div id="areaReporte" class="printable-sheet">

                <!-- ENCABEZADO FORMAL CORPORATIVO -->
                <div class="report-header-banner">
                    <div>
                        <div style="font-family: 'Playfair Display', serif; font-size: 20px; font-weight: 700; color: var(--color-texto);">
                            DERMO ERP - COSMETOLOG&Iacute;A PROFESIONAL
                        </div>
                        <div style="font-size: 11px; color: var(--color-texto-suave); letter-spacing: 1px; text-transform: uppercase; margin-top: 2px;">
                            Distribuidora de Dermocosm&eacute;tica y Cosmec&eacute;utica Profesional
                        </div>
                        <div id="lblTituloReporte" runat="server" style="font-size: 12px; margin-top: 8px; color: var(--color-acento); font-weight: 600;">
                            INFORME GERENCIAL: ESTADO E HISTORIAL DE COMPROBANTES DE VENTA
                        </div>
                    </div>
                    <div style="text-align: right; font-size: 11px; color: var(--color-texto-suave); line-height: 1.6;">
                        <div><strong>Fecha Reporte:</strong> <%= DateTime.Now.ToString("dd/MM/yyyy HH:mm") %></div>
                        <div><strong>Per&iacute;odo:</strong> <asp:Label ID="lblPeriodoTexto" runat="server"></asp:Label></div>
                        <div><strong>M&oacute;dulo:</strong> Ventas y Facturaci&oacute;n</div>
                    </div>
                </div>

                <!-- REPORTE 1: GENERAL DE VENTAS Y COMPROBANTES -->
                <asp:Panel ID="pnlReporte1" runat="server">
                    <div class="table-dermo-container" style="border: none; box-shadow: none;">
                        <asp:GridView ID="gvReporteVentas" runat="server" CssClass="table table-hover align-middle" AutoGenerateColumns="False" GridLines="None" EmptyDataText="No se registran documentos de venta para los par&aacute;metros seleccionados.">
                            <Columns>
                                <asp:TemplateField HeaderText="Folio Doc.">
                                    <ItemTemplate>
                                        <strong style="color: var(--color-acento);"><%# Eval("Folio") %></strong>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Tipo Doc.">
                                    <ItemTemplate>
                                        <span class='<%# GetClaseDoc(Eval("TipoDocumento").ToString()) %>'>
                                            <%# Eval("TipoDocumento") %>
                                        </span>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:BoundField DataField="Fecha" HeaderText="Emisi&oacute;n" DataFormatString="{0:dd/MM/yyyy}" />
                                <asp:BoundField DataField="Cliente" HeaderText="Cliente / Raz&oacute;n Social" />
                                <asp:BoundField DataField="Vendedor" HeaderText="Ejecutivo" NullDisplayText="Sistema" />
                                <asp:BoundField DataField="FormaPago" HeaderText="Condici&oacute;n" NullDisplayText="Contado" />
                                <asp:BoundField DataField="Neto" HeaderText="Neto ($)" DataFormatString="${0:N0}" />
                                <asp:BoundField DataField="Iva" HeaderText="IVA ($)" DataFormatString="${0:N0}" />
                                <asp:TemplateField HeaderText="Total Venta ($)">
                                    <ItemTemplate>
                                        <strong><%# string.Format("${0:N0}", Eval("Total")) %></strong>
                                    </ItemTemplate>
                                </asp:TemplateField>
                            </Columns>
                        </asp:GridView>
                    </div>
                </asp:Panel>

                <!-- REPORTE 2: VENTAS, SALIDAS Y RENTABILIDAD POR PRODUCTO -->
                <asp:Panel ID="pnlReporte2" runat="server" Visible="false">
                    <div class="table-dermo-container" style="border: none; box-shadow: none;">
                        <asp:GridView ID="gvTopProductos" runat="server" CssClass="table table-hover align-middle" AutoGenerateColumns="False" GridLines="None" EmptyDataText="No se registran salidas de productos para los criterios seleccionados.">
                            <Columns>
                                <asp:TemplateField HeaderText="SKU">
                                    <ItemTemplate>
                                        <strong style="color: var(--color-acento);"><%# Eval("Sku") %></strong>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:BoundField DataField="Producto" HeaderText="Producto Dermocosm&eacute;tico" />
                                <asp:BoundField DataField="UnidadesVendidas" HeaderText="Unidades Salida" />
                                <asp:BoundField DataField="PrecioPromedio" HeaderText="Precio Unit. Prom." DataFormatString="${0:N0}" />
                                <asp:BoundField DataField="IngresoTotal" HeaderText="Ingresos ($)" DataFormatString="${0:N0}" />
                                <asp:BoundField DataField="CostoTotal" HeaderText="Costo Prom. Total ($)" DataFormatString="${0:N0}" />
                                <asp:TemplateField HeaderText="Margen Comercial ($)">
                                    <ItemTemplate>
                                        <strong style="color: #27AE60;"><%# string.Format("${0:N0}", Eval("MargenBruto")) %></strong>
                                    </ItemTemplate>
                                </asp:TemplateField>
                            </Columns>
                        </asp:GridView>
                    </div>
                </asp:Panel>

                <!-- REPORTE 3: CLIENTES Y CRÉDITOS -->
                <asp:Panel ID="pnlReporte3" runat="server" Visible="false">
                    <div class="table-dermo-container" style="border: none; box-shadow: none;">
                        <asp:GridView ID="gvTopClientes" runat="server" CssClass="table table-hover align-middle" AutoGenerateColumns="False" GridLines="None" EmptyDataText="No se registran operaciones de clientes para el per&iacute;odo.">
                            <Columns>
                                <asp:TemplateField HeaderText="Cliente / Raz&oacute;n Social">
                                    <ItemTemplate>
                                        <div style="font-weight: 600;"><%# Eval("Cliente") %></div>
                                        <div style="font-size: 10px; color: var(--color-texto-suave);">RUT: <%# Eval("Rut") %></div>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:BoundField DataField="Categoria" HeaderText="Segmento" />
                                <asp:BoundField DataField="Compras" HeaderText="N&deg; Docs." />
                                <asp:BoundField DataField="TotalGastado" HeaderText="Total Comprado ($)" DataFormatString="${0:N0}" />
                                <asp:BoundField DataField="DeudaPendiente" HeaderText="Deuda CxC Vigente ($)" DataFormatString="${0:N0}" />
                                <asp:BoundField DataField="LimiteCredito" HeaderText="L&iacute;mite Cr&eacute;dito ($)" DataFormatString="${0:N0}" />
                                <asp:TemplateField HeaderText="Estado Cr&eacute;dito">
                                    <ItemTemplate>
                                        <span class='<%# Convert.ToDecimal(Eval("DeudaPendiente")) > 0 ? "badge-warn" : "badge-fac" %>'>
                                            <%# Convert.ToDecimal(Eval("DeudaPendiente")) > 0 ? "Con Saldo CxC" : "Al Día" %>
                                        </span>
                                    </ItemTemplate>
                                </asp:TemplateField>
                            </Columns>
                        </asp:GridView>
                    </div>
                </asp:Panel>

                <!-- REPORTE 4: RENDIMIENTO POR VENDEDOR Y DEVOLUCIONES -->
                <asp:Panel ID="pnlReporte4" runat="server" Visible="false">
                    <div class="table-dermo-container" style="border: none; box-shadow: none;">
                        <asp:GridView ID="gvVendedores" runat="server" CssClass="table table-hover align-middle" AutoGenerateColumns="False" GridLines="None" EmptyDataText="Sin registros de ventas por vendedor en este per&iacute;odo.">
                            <Columns>
                                <asp:TemplateField HeaderText="Ejecutivo Comercial">
                                    <ItemTemplate>
                                        <div style="font-weight: 600;"><%# Eval("Vendedor") %></div>
                                        <div style="font-size: 10px; color: var(--color-texto-suave);"><%# Eval("Rol") %></div>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:BoundField DataField="CantidadOperaciones" HeaderText="N&deg; Ventas" />
                                <asp:BoundField DataField="TicketPromedio" HeaderText="Ticket Promedio ($)" DataFormatString="${0:N0}" />
                                <asp:TemplateField HeaderText="Total Facturado ($)">
                                    <ItemTemplate>
                                        <strong style="color: var(--color-acento);"><%# string.Format("${0:N0}", Eval("TotalVendido")) %></strong>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Participaci&oacute;n">
                                    <ItemTemplate>
                                        <div style="font-size: 12px; font-weight: 600;"><%# string.Format("{0:0.0}%", Eval("ParticipacionPct")) %></div>
                                        <div class="share-bar-wrap">
                                            <div class="share-bar-fill" style='<%# string.Format("width:{0:0}%;", Eval("ParticipacionPct")) %>'></div>
                                        </div>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Devoluciones (NC)">
                                    <ItemTemplate>
                                        <span class='<%# Convert.ToInt32(Eval("TotalDevoluciones")) > 0 ? "badge-nc" : "badge-fac" %>'>
                                            <%# Eval("TotalDevoluciones") %> NC
                                        </span>
                                    </ItemTemplate>
                                </asp:TemplateField>
                            </Columns>
                        </asp:GridView>
                    </div>
                </asp:Panel>

                <!-- REPORTE 5: PRESUPUESTOS Y CONVERSIÓN -->
                <asp:GridView ID="gvAnalisis" runat="server" AutoGenerateColumns="true" CssClass="table" Visible="false" EmptyDataText="Sin registros en el período." />
                <asp:Panel ID="pnlReporte5" runat="server" Visible="false">
                    <div class="table-dermo-container" style="border: none; box-shadow: none;">
                        <asp:GridView ID="gvCotizacionesReporte" runat="server" CssClass="table table-hover align-middle" AutoGenerateColumns="False" GridLines="None" EmptyDataText="No se registran cotizaciones en el per&iacute;odo seleccionado.">
                            <Columns>
                                <asp:TemplateField HeaderText="N&deg; Cotizaci&oacute;n">
                                    <ItemTemplate>
                                        <strong style="color: var(--color-acento);">COT-<%# string.Format("{0:D4}", Eval("IdCotizacion")) %></strong>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:BoundField DataField="Cliente" HeaderText="Cliente / Raz&oacute;n Social" />
                                <asp:BoundField DataField="FechaEmision" HeaderText="F. Emisi&oacute;n" DataFormatString="{0:dd/MM/yyyy}" />
                                <asp:BoundField DataField="FechaVencimiento" HeaderText="Vigencia Hasta" DataFormatString="{0:dd/MM/yyyy}" NullDisplayText="Sin plazo" />
                                <asp:TemplateField HeaderText="Estado">
                                    <ItemTemplate>
                                        <span class='<%# Eval("Estado").ToString() == "Aceptado" ? "badge-fac" : Eval("Estado").ToString() == "Vigente" ? "badge-bol" : "badge-nc" %>'>
                                            <%# Eval("Estado") %>
                                        </span>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Monto Cotizado ($)">
                                    <ItemTemplate>
                                        <strong><%# string.Format("${0:N0}", Eval("Total")) %></strong>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Conversi&oacute;n a Venta">
                                    <ItemTemplate>
                                        <span class='<%# Eval("VentaConcretada").ToString().Contains("Concretada") ? "badge-fac" : "badge-warn" %>'>
                                            <%# Eval("VentaConcretada") %>
                                        </span>
                                    </ItemTemplate>
                                </asp:TemplateField>
                            </Columns>
                        </asp:GridView>
                    </div>
                </asp:Panel>

                <!-- REPORTE 6: RANKING PARETO 80/20 DE MEJORES CLIENTES MAYORISTAS -->
                <asp:Panel ID="pnlReporte6" runat="server" Visible="false">
                    <div class="table-dermo-container" style="border: none; box-shadow: none;">
                        <asp:GridView ID="gvPareto" runat="server" CssClass="table table-hover align-middle" AutoGenerateColumns="False" GridLines="None" EmptyDataText="No se registran compras de clientes mayoristas / B2B en el per&iacute;odo seleccionado.">
                            <Columns>
                                <asp:TemplateField HeaderText="#">
                                    <ItemTemplate>
                                        <strong style="color: var(--color-acento);">#<%# Eval("Ranking") %></strong>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Cliente Mayorista / B2B">
                                    <ItemTemplate>
                                        <div style="font-weight: 600;"><%# Eval("Cliente") %></div>
                                        <div style="font-size: 10px; color: var(--color-texto-suave);">RUT: <%# Eval("Rut") %></div>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:BoundField DataField="Categoria" HeaderText="Segmento" />
                                <asp:BoundField DataField="CantidadDocs" HeaderText="N&deg; Docs." HeaderStyle-CssClass="text-center" ItemStyle-CssClass="text-center" />
                                <asp:TemplateField HeaderText="Facturaci&oacute;n Neta ($)" HeaderStyle-CssClass="text-end" ItemStyle-CssClass="text-end text-nowrap">
                                    <ItemTemplate>
                                        <strong style="color: var(--color-acento);"><%# string.Format("${0:N0}", Eval("Monto")) %></strong>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="% Part.">
                                    <ItemTemplate>
                                        <div style="font-size: 12px; font-weight: 600;"><%# string.Format("{0:0.0}%", Eval("ParticipacionPct")) %></div>
                                        <div class="share-bar-wrap">
                                            <div class="share-bar-fill" style='<%# string.Format("width:{0:0}%;", Eval("ParticipacionPct")) %>'></div>
                                        </div>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="% Acumulado" HeaderStyle-CssClass="text-center" ItemStyle-CssClass="text-center">
                                    <ItemTemplate>
                                        <strong><%# string.Format("{0:0.0}%", Eval("PorcentajeAcumulado")) %></strong>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Clasificaci&oacute;n 80/20" HeaderStyle-CssClass="text-center" ItemStyle-CssClass="text-center">
                                    <ItemTemplate>
                                        <span class='<%# Eval("Grupo80").ToString().StartsWith("Top 80%") ? "badge-fac" : "badge-bol" %>'>
                                            <%# Eval("Grupo80") %>
                                        </span>
                                    </ItemTemplate>
                                </asp:TemplateField>
                            </Columns>
                        </asp:GridView>
                    </div>
                </asp:Panel>

                <!-- REPORTE 7: INGRESOS POR CATEGORÍA (SKINCARE VS. INSUMOS DE SALÓN) -->
                <asp:Panel ID="pnlReporte7" runat="server" Visible="false">
                    <div class="table-dermo-container" style="border: none; box-shadow: none;">
                        <asp:GridView ID="gvCategorias" runat="server" CssClass="table table-hover align-middle" AutoGenerateColumns="False" GridLines="None" EmptyDataText="No se registran ingresos por categor&iacute;a en el per&iacute;odo seleccionado.">
                            <Columns>
                                <asp:TemplateField HeaderText="Categor&iacute;a Cosmec&eacute;utica">
                                    <ItemTemplate>
                                        <strong style="color: var(--color-texto);"><%# Eval("Categoria") %></strong>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:BoundField DataField="Documentos" HeaderText="N&deg; Ventas" HeaderStyle-CssClass="text-center" ItemStyle-CssClass="text-center" />
                                <asp:BoundField DataField="Unidades" HeaderText="Unidades" HeaderStyle-CssClass="text-center" ItemStyle-CssClass="text-center" />
                                <asp:BoundField DataField="IngresoNeto" HeaderText="Ingreso Neto ($)" DataFormatString="${0:N0}" HeaderStyle-CssClass="text-end" ItemStyle-CssClass="text-end text-nowrap" />
                                <asp:BoundField DataField="IvaCalculado" HeaderText="IVA ($)" DataFormatString="${0:N0}" HeaderStyle-CssClass="text-end" ItemStyle-CssClass="text-end text-nowrap" />
                                <asp:TemplateField HeaderText="Total Facturado ($)" HeaderStyle-CssClass="text-end" ItemStyle-CssClass="text-end text-nowrap">
                                    <ItemTemplate>
                                        <strong style="color: var(--color-acento);"><%# string.Format("${0:N0}", Eval("IngresoTotal")) %></strong>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Participaci&oacute;n">
                                    <ItemTemplate>
                                        <div style="font-size: 12px; font-weight: 600;"><%# string.Format("{0:0.0}%", Eval("ParticipacionPct")) %></div>
                                        <div class="share-bar-wrap">
                                            <div class="share-bar-fill" style='<%# string.Format("width:{0:0}%;", Eval("ParticipacionPct")) %>'></div>
                                        </div>
                                    </ItemTemplate>
                                </asp:TemplateField>
                            </Columns>
                        </asp:GridView>
                    </div>
                </asp:Panel>

                <!-- REPORTE 8: TASA DE EFECTIVIDAD EN TIEMPOS DE ENTREGA -->
                <asp:Panel ID="pnlReporte8" runat="server" Visible="false">
                    <div class="table-dermo-container" style="border: none; box-shadow: none;">
                        <asp:GridView ID="gvEntregas" runat="server" CssClass="table table-hover align-middle" AutoGenerateColumns="False" GridLines="None" EmptyDataText="No se registran despachos evaluables en el per&iacute;odo seleccionado.">
                            <Columns>
                                <asp:TemplateField HeaderText="Transportista / Operador">
                                    <ItemTemplate>
                                        <strong style="color: var(--color-texto);"><%# Eval("Transportista") %></strong>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:BoundField DataField="Programados" HeaderText="Despachos Evaluados" HeaderStyle-CssClass="text-center" ItemStyle-CssClass="text-center" />
                                <asp:BoundField DataField="Entregados" HeaderText="Entregados" HeaderStyle-CssClass="text-center" ItemStyle-CssClass="text-center" />
                                <asp:BoundField DataField="ATiempo" HeaderText="A Tiempo" HeaderStyle-CssClass="text-center" ItemStyle-CssClass="text-center fw-semibold" />
                                <asp:BoundField DataField="ConRetraso" HeaderText="Retraso / Pend." HeaderStyle-CssClass="text-center" ItemStyle-CssClass="text-center" />
                                <asp:TemplateField HeaderText="Efectividad (%)">
                                    <ItemTemplate>
                                        <div style="font-size: 12px; font-weight: 600;"><%# string.Format("{0:0.0}%", Eval("PorcentajeATiempo")) %></div>
                                        <div class="share-bar-wrap">
                                            <div class="share-bar-fill" style='<%# string.Format("width:{0:0}%;", Eval("PorcentajeATiempo")) %>'></div>
                                        </div>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Evaluaci&oacute;n SLA" HeaderStyle-CssClass="text-center" ItemStyle-CssClass="text-center">
                                    <ItemTemplate>
                                        <span class='<%# Convert.ToDecimal(Eval("PorcentajeATiempo")) >= 80m ? "badge-fac" : Convert.ToDecimal(Eval("PorcentajeATiempo")) >= 50m ? "badge-warn" : "badge-nc" %>'>
                                            <%# Convert.ToDecimal(Eval("PorcentajeATiempo")) >= 80m ? "Óptimo" : Convert.ToDecimal(Eval("PorcentajeATiempo")) >= 50m ? "En Observación" : "Crítico" %>
                                        </span>
                                    </ItemTemplate>
                                </asp:TemplateField>
                            </Columns>
                        </asp:GridView>
                    </div>
                </asp:Panel>

                <!-- PIE DE REPORTE CON RESUMEN LIQUIDATORIO (IDÉNTICO AL MÓDULO DE COMPRAS) -->
                <div style="display: flex; justify-content: space-between; align-items: flex-end; margin-top: 30px; border-top: 1px solid var(--color-borde-suave); padding-top: 20px; flex-wrap: wrap; gap: 12px;">
                    <div style="font-size: 11px; color: var(--color-texto-suave); max-width: 540px;">
                        <em>Documento anal&iacute;tico generado autom&aacute;ticamente por el m&oacute;dulo de Ventas y Facturaci&oacute;n para control tributario, auditor&iacute;a comercial y evaluaci&oacute;n presupuestaria. Taller de Ingenier&iacute;a de Software.</em>
                    </div>
                    <div style="text-align: right; font-size: 13px;">
                        <div><asp:Label ID="lblResumenEtiqueta" runat="server" Text="Total Facturado Período:"></asp:Label> <strong style="font-size: 18px; color: var(--color-acento);"><asp:Label ID="lblResumenTotal" runat="server" Text="$0"></asp:Label></strong></div>
                    </div>
                </div>

                <!-- FIRMAS INSTITUCIONALES -->
                <div style="display: grid; grid-template-columns: repeat(3, 1fr); gap: 30px; margin-top: 50px; text-align: center; font-size: 11px;">
                    <div>
                        <div style="border-top: 1px solid #736E67; width: 80%; margin: 0 auto 6px auto;"></div>
                        <strong><%: trabajo_ing_software.ConfiguracionGlobal.NombreJefeCompras %></strong><br />
                        M&oacute;dulo de Compras y Abastecimiento
                    </div>
                    <div>
                        <div style="border-top: 1px solid #736E67; width: 80%; margin: 0 auto 6px auto;"></div>
                        <strong><%: trabajo_ing_software.ConfiguracionGlobal.NombreJefeVentas %></strong><br />
                        M&oacute;dulo de Ventas y Facturaci&oacute;n
                    </div>
                    <div>
                        <div style="border-top: 1px solid #736E67; width: 80%; margin: 0 auto 6px auto;"></div>
                        <strong><%: trabajo_ing_software.ConfiguracionGlobal.NombreJefeInventario %></strong><br />
                        M&oacute;dulo de Inventario y Kardex
                    </div>
                </div>

            </div>

        </div>
    </div>

    <script>
        function generarPDF() {
            window.dermoDescargarPDF('areaReporte', 'Reporte_Ventas_DermoERP.pdf');
        }
    </script>
</asp:Content>
