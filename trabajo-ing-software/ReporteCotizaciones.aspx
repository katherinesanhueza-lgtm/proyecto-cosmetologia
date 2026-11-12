<%@ Page Title="Variación de costos de insumos" MasterPageFile="~/Contabilidad.Master" Language="C#" AutoEventWireup="true" CodeBehind="ReporteCotizaciones.aspx.cs" Inherits="trabajo_ing_software.ReporteCotizaciones" ResponseEncoding="utf-8" ContentType="text/html; charset=utf-8" %>
<asp:Content ID="Recursos" ContentPlaceHolderID="EstilosPagina" runat="server">
<script src="https://cdnjs.cloudflare.com/ajax/libs/html2pdf.js/0.10.1/html2pdf.bundle.min.js"></script>
<style>
        .report-container {
            max-width: 1400px;
            margin: 25px auto 50px auto;
            padding: 0 24px;
        }

        .filter-card {
            background-color: var(--color-blanco);
            border: 1px solid var(--color-borde-suave);
            border-radius: 20px;
            padding: 20px 24px;
            margin-bottom: 25px;
            box-shadow: 0 4px 15px rgba(0,0,0,0.02);
        }

        .cost-filter-grid {
            display: grid;
            grid-template-columns: 155px 155px 1.35fr 1.15fr 170px;
            gap: 14px;
            align-items: end;
        }

        .cost-filter-grid > .compras-acciones {
            grid-column: 1 / -1;
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

        .badge-op {
            padding: 4px 10px;
            border-radius: 15px;
            font-size: 11px;
            font-weight: 600;
            display: inline-block;
        }
        .badge-op-cot { background: #EBF3FA; color: #2980B9; }
        .badge-op-oc { background: #F5EFEB; color: #7A5E47; }

        .badge-var {
            padding: 4px 10px;
            border-radius: 15px;
            font-size: 11px;
            font-weight: 600;
            display: inline-block;
        }
        .badge-var-alza { background: #FDEDEC; color: #C0392B; }
        .badge-var-baja { background: #E8F8F0; color: #27AE60; }
        .badge-var-estable { background: #F0EFEB; color: #7A756D; }

        .printable-sheet .table th,
        .printable-sheet .table td {
            padding: 10px 8px;
            font-size: 12.5px;
        }

        @media (max-width: 1120px) {
            .cost-filter-grid {
                grid-template-columns: repeat(auto-fit, minmax(min(100%, 190px), 1fr));
            }
            .kpi-grid-4col {
                grid-template-columns: repeat(2, 1fr);
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
        <div class="report-container">

            <!-- ENCABEZADO Y ACCIONES DE EXPORTACION -->
            <div style="display: flex; justify-content: space-between; align-items: flex-end; margin-bottom: 24px; flex-wrap: wrap; gap: 14px;">
                <div>
                    <span class="pill-badge" style="font-size: 10px; padding: 4px 12px; margin-bottom: 8px;">REPORTE ANAL&Iacute;TICO N&deg; 2 - COMPRAS</span>
                    <h1>Historial de Variaci&oacute;n de Costos de Insumos</h1>
                    <p class="text-muted" style="margin-top: 4px;">Comparativa hist&oacute;rica de costos cotizados en importaci&oacute;n y adquiridos en &oacute;rdenes de compra por SKU, laboratorio y tipo de cambio (RF-COM-03 / RF-COM-11).</p>
                </div>
                <div class="compras-acciones">
                    <a href="CotizacionesImportacion.aspx" class="btn btn-outline-secondary">
                        <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="15 18 9 12 15 6"></polyline></svg>
                        Volver a Cotizaciones
                    </a>
                    <button type="button" onclick="exportarPDF();" class="btn btn-primary">
                        <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"></path><polyline points="14 2 14 8 20 8"></polyline><line x1="12" y1="18" x2="12" y2="12"></line><line x1="9" y1="15" x2="15" y2="15"></line></svg>
                        Descargar PDF
                    </button>
                    <asp:Button ID="btnExportarExcel" runat="server" Text="Exportar CSV" CssClass="btn btn-outline-secondary" OnClick="btnExportarExcel_Click" />
                </div>
            </div>

            <!-- TARJETAS DE KPIS ANALITICOS -->
            <div class="kpi-grid-4col">
                <div class="kpi-card">
                    <div class="kpi-titulo">Registros Hist&oacute;ricos</div>
                    <div class="kpi-valor"><asp:Label ID="lblKpiRegistros" runat="server" Text="0"></asp:Label></div>
                    <div style="font-size: 11px; color: var(--color-texto-suave);"><asp:Label ID="lblKpiSkus" runat="server" Text="0"></asp:Label> insumos (SKU) distintos</div>
                </div>

                <div class="kpi-card">
                    <div class="kpi-titulo">Variaci&oacute;n Prom. Hist&oacute;rica</div>
                    <div class="kpi-valor" style="color: #2980B9;"><asp:Label ID="lblKpiVarPromedio" runat="server" Text="0.0%"></asp:Label></div>
                    <div style="font-size: 11px; color: #2980B9;">Respecto al registro previo por SKU</div>
                </div>

                <div class="kpi-card">
                    <div class="kpi-titulo">Mayor Alza Detectada</div>
                    <div class="kpi-valor" style="color: #C0392B; font-size: 24px;"><asp:Label ID="lblKpiMayorAlza" runat="server" Text="0.0%"></asp:Label></div>
                    <div style="font-size: 11px; color: var(--color-texto-suave);"><asp:Label ID="lblKpiSkuAlza" runat="server" Text="Sin incrementos"></asp:Label></div>
                </div>

                <div class="kpi-card">
                    <div class="kpi-titulo">Costo Unit. Promedio (CLP)</div>
                    <div class="kpi-valor" style="font-size: 24px;"><asp:Label ID="lblKpiCostoPromedio" runat="server" Text="$0"></asp:Label></div>
                    <div style="font-size: 11px; color: var(--color-texto-suave);">Promedio en el per&iacute;odo filtrado</div>
                </div>
            </div>

            <!-- BARRA DE FILTROS -->
            <section class="filter-card card-dermocosmetica" aria-label="Filtros del historial de costos">
                <div class="cost-filter-grid">
                    <div class="form-group-dermo" style="margin-bottom: 0;">
                        <asp:Label runat="server" CssClass="form-label" AssociatedControlID="txtFechaDesde">Fecha Desde</asp:Label>
                        <asp:TextBox ID="txtFechaDesde" runat="server" TextMode="Date" CssClass="form-control"></asp:TextBox>
                    </div>

                    <div class="form-group-dermo" style="margin-bottom: 0;">
                        <asp:Label runat="server" CssClass="form-label" AssociatedControlID="txtFechaHasta">Fecha Hasta</asp:Label>
                        <asp:TextBox ID="txtFechaHasta" runat="server" TextMode="Date" CssClass="form-control"></asp:TextBox>
                    </div>

                    <div class="form-group-dermo" style="margin-bottom: 0;">
                        <asp:Label runat="server" CssClass="form-label" AssociatedControlID="ddlVariante">Insumo / SKU</asp:Label>
                        <asp:DropDownList ID="ddlVariante" runat="server" CssClass="form-select"></asp:DropDownList>
                    </div>

                    <div class="form-group-dermo" style="margin-bottom: 0;">
                        <asp:Label runat="server" CssClass="form-label" AssociatedControlID="ddlLaboratorio">Laboratorio / Proveedor</asp:Label>
                        <asp:DropDownList ID="ddlLaboratorio" runat="server" CssClass="form-select"></asp:DropDownList>
                    </div>

                    <div class="form-group-dermo" style="margin-bottom: 0;">
                        <asp:Label runat="server" CssClass="form-label" AssociatedControlID="ddlTipoOperacion">Origen</asp:Label>
                        <asp:DropDownList ID="ddlTipoOperacion" runat="server" CssClass="form-select">
                            <asp:ListItem Value="" Text="Cotizaciones y OC"></asp:ListItem>
                            <asp:ListItem Value="Cotizaci&#243;n" Text="Solo Cotizaciones"></asp:ListItem>
                            <asp:ListItem Value="Orden de Compra" Text="Solo &#211;rdenes de Compra"></asp:ListItem>
                        </asp:DropDownList>
                    </div>

                    <div class="compras-acciones">
                        <asp:Button ID="btnFiltrar" runat="server" Text="Filtrar" CssClass="btn btn-primary" OnClick="btnFiltrar_Click" />
                        <asp:Button ID="btnLimpiar" runat="server" Text="Limpiar filtros" CssClass="btn btn-outline-secondary" OnClick="btnLimpiar_Click" />
                    </div>
                </div>
            </section>

            <!-- HOJA FORMAL DEL REPORTE (EXPORTABLE A PDF) -->
            <div id="reporte-imprimible" class="printable-sheet">

                <!-- ENCABEZADO FORMAL -->
                <div class="report-header-banner">
                    <div>
                        <div style="font-family: 'Playfair Display', serif; font-size: 20px; font-weight: 700; color: var(--color-texto);">
                            DERMO ERP - COSMETOLOG&Iacute;A PROFESIONAL
                        </div>
                        <div style="font-size: 11px; color: var(--color-texto-suave); letter-spacing: 1px; text-transform: uppercase; margin-top: 2px;">
                            Distribuidora de Dermocosm&eacute;tica y Cosmec&eacute;utica Profesional
                        </div>
                        <div style="font-size: 12px; margin-top: 8px; color: var(--color-acento); font-weight: 600;">
                            INFORME ANAL&Iacute;TICO: HISTORIAL DE VARIACI&Oacute;N DE COSTOS DE INSUMOS (RF-COM-03)
                        </div>
                    </div>
                    <div style="text-align: right; font-size: 11px; color: var(--color-texto-suave); line-height: 1.6;">
                        <div><strong>Fecha Reporte:</strong> <%= DateTime.Now.ToString("dd/MM/yyyy HH:mm") %></div>
                        <div><strong>Auditor:</strong> <asp:Label ID="lblAuditor" runat="server"></asp:Label></div>
                        <div><strong>Sistema:</strong> ERP Dermo-Cosm&eacute;tica .NET</div>
                    </div>
                </div>

                <!-- GRILLA DE VARIACION DE COSTOS -->
                <div class="table-dermo-container" style="border: none; box-shadow: none;">
                    <asp:GridView ID="gvReporte" runat="server" AutoGenerateColumns="False" CssClass="table table-hover align-middle" GridLines="None" EmptyDataText="No se registran movimientos de costos de insumos para los par&aacute;metros seleccionados.">
                        <Columns>
                            <asp:BoundField DataField="Fecha" HeaderText="Fecha" DataFormatString="{0:dd/MM/yyyy}" />

                            <asp:TemplateField HeaderText="Insumo / SKU">
                                <ItemTemplate>
                                    <div style="font-weight: 600;"><%# Eval("Producto") %></div>
                                    <div style="font-size: 10px; color: var(--color-texto-suave);">SKU: <%# Eval("Sku") %></div>
                                </ItemTemplate>
                            </asp:TemplateField>

                            <asp:BoundField DataField="Laboratorio" HeaderText="Laboratorio" />

                            <asp:TemplateField HeaderText="Origen / Doc.">
                                <ItemTemplate>
                                    <span class='badge-op <%# Eval("ClaseOrigen") %>'><%# Eval("TipoOperacion") %></span>
                                    <div style="font-size: 10px; color: var(--color-texto-suave); margin-top: 2px;">
                                        <%# Eval("Documento") %> (<%# Eval("EstadoDoc") %>)
                                    </div>
                                </ItemTemplate>
                            </asp:TemplateField>

                            <asp:TemplateField HeaderText="Costo Origen / T.C.">
                                <ItemTemplate>
                                    <div><%# string.Format("{0:N2} {1}", Eval("CostoOrigen"), Eval("Moneda")) %></div>
                                    <div style="font-size: 10px; color: var(--color-texto-suave);">T.C. <%# string.Format("{0:N2}", Eval("TipoCambio")) %></div>
                                </ItemTemplate>
                            </asp:TemplateField>

                            <asp:TemplateField HeaderText="Costo Unit. (CLP)">
                                <ItemTemplate>
                                    <strong style="color: var(--color-acento);"><%# string.Format("{0:C0}", Eval("CostoUnitarioCLP")) %></strong>
                                </ItemTemplate>
                            </asp:TemplateField>

                            <asp:TemplateField HeaderText="CPP Actual">
                                <ItemTemplate>
                                    <%# string.Format("{0:C0}", Eval("CostoPromedioActual")) %>
                                </ItemTemplate>
                            </asp:TemplateField>

                            <asp:TemplateField HeaderText="Var. Hist&oacute;rica">
                                <ItemTemplate>
                                    <span class='badge-var <%# Eval("ClaseVariacion") %>'><%# Eval("VariacionTxt") %></span>
                                    <div style="font-size: 10px; color: var(--color-texto-suave); margin-top: 2px;"><%# Eval("VariacionDetalle") %></div>
                                </ItemTemplate>
                            </asp:TemplateField>

                            <asp:TemplateField HeaderText="Margen Est.">
                                <ItemTemplate>
                                    <span><%# Eval("MargenTxt") %></span>
                                </ItemTemplate>
                            </asp:TemplateField>
                        </Columns>
                    </asp:GridView>
                </div>

                <!-- PIE DE REPORTE -->
                <div style="display: flex; justify-content: space-between; align-items: flex-end; margin-top: 30px; border-top: 1px solid var(--color-borde-suave); padding-top: 20px; flex-wrap: wrap; gap: 12px;">
                    <div style="font-size: 11px; color: var(--color-texto-suave); max-width: 560px;">
                        <em>Documento anal&iacute;tico generado autom&aacute;ticamente por el m&oacute;dulo de Compras y Abastecimiento (RF-COM-03). Compara precios unitarios cotizados en divisa extranjera (convertidos a CLP seg&uacute;n tipo de cambio) y costos adquiridos en &oacute;rdenes de compra frente al registro previo del mismo SKU y su Costo Promedio Ponderado actual.</em>
                    </div>
                    <div style="text-align: right; font-size: 13px;">
                        <div>Costo Unit. Promedio Per&iacute;odo: <strong style="font-size: 18px; color: var(--color-acento);"><asp:Label ID="lblResumenPromedio" runat="server" Text="$0"></asp:Label></strong></div>
                    </div>
                </div>

                <!-- FIRMAS DE RESPONSABILIDAD DEL EQUIPO (DINÁMICAS DESDE CONFIGURACIONGLOBAL) -->
                <div style="display: grid; grid-template-columns: repeat(3, 1fr); gap: 30px; margin-top: 50px; text-align: center; font-size: 11px;">
                    <div>
                        <div style="border-top: 1px solid #736E67; width: 80%; margin: 0 auto 6px auto;"></div>
                        <strong><asp:Label ID="lblFirmaCompras" runat="server"></asp:Label></strong><br />
                        M&oacute;dulo de Compras y Abastecimiento
                    </div>
                    <div>
                        <div style="border-top: 1px solid #736E67; width: 80%; margin: 0 auto 6px auto;"></div>
                        <strong><asp:Label ID="lblFirmaVentas" runat="server"></asp:Label></strong><br />
                        M&oacute;dulo de Ventas y Facturaci&oacute;n
                    </div>
                    <div>
                        <div style="border-top: 1px solid #736E67; width: 80%; margin: 0 auto 6px auto;"></div>
                        <strong><asp:Label ID="lblFirmaInventario" runat="server"></asp:Label></strong><br />
                        M&oacute;dulo de Inventario y Kardex
                    </div>
                </div>

            </div>

        </div>
        <script>
        function exportarPDF() {
            var elemento = document.getElementById('reporte-imprimible');
            var opt = {
                margin: [10, 10, 10, 10],
                filename: 'Reporte_Variacion_Costos_Insumos.pdf',
                image: { type: 'jpeg', quality: 0.98 },
                html2canvas: { scale: 2, useCORS: true },
                jsPDF: { unit: 'mm', format: 'letter', orientation: 'landscape' }
            };
            html2pdf().set(opt).from(elemento).save();
        }
        </script>
    </div>
</asp:Content>
