<%@ Page Title="Compras por laboratorio y marca" MasterPageFile="~/Contabilidad.Master" Language="C#" AutoEventWireup="true" CodeBehind="ReporteComprasLaboratorio.aspx.cs" Inherits="trabajo_ing_software.ReporteComprasLaboratorio" ResponseEncoding="utf-8" ContentType="text/html; charset=utf-8" %>
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

        .lab-filter-grid {
            display: grid;
            grid-template-columns: 155px 155px 1.3fr 1.1fr 180px;
            gap: 14px;
            align-items: end;
        }

        .lab-filter-grid > .compras-acciones {
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

        .badge-claim-ok { background: #E8F8F0; color: #27AE60; padding: 3px 10px; border-radius: 12px; font-size: 11px; font-weight: 600; }
        .badge-claim-warn { background: #FDEDEC; color: #C0392B; padding: 3px 10px; border-radius: 12px; font-size: 11px; font-weight: 600; }

        .printable-sheet .table th,
        .printable-sheet .table td {
            padding: 10px 8px;
            font-size: 12.5px;
        }

        @media (max-width: 1120px) {
            .lab-filter-grid {
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

            <!-- ENCABEZADO Y ACCIONES -->
            <div style="display: flex; justify-content: space-between; align-items: flex-end; margin-bottom: 24px; flex-wrap: wrap; gap: 14px;">
                <div>
                    <span class="pill-badge" style="font-size: 10px; padding: 4px 12px; margin-bottom: 8px;">REPORTE ANAL&Iacute;TICO N&deg; 5 - COMPRAS</span>
                    <h1>An&aacute;lisis de Compras por Laboratorio y Marca</h1>
                    <p class="text-muted" style="margin-top: 4px;">Consolidado de inversi&oacute;n neta, IVA, participaci&oacute;n presupuestaria y reclamos asociados por laboratorio proveedor y marca (RF-COM-11 / RNF-14).</p>
                </div>
                <div class="compras-acciones">
                    <a href="DevolucionesProveedor.aspx" class="btn btn-outline-secondary">
                        <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="15 18 9 12 15 6"></polyline></svg>
                        Volver a Devoluciones
                    </a>
                    <button type="button" onclick="exportarPDF();" class="btn btn-primary">
                        <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"></path><polyline points="14 2 14 8 20 8"></polyline><line x1="12" y1="18" x2="12" y2="12"></line><line x1="9" y1="15" x2="15" y2="15"></line></svg>
                        Descargar PDF
                    </button>
                    <asp:Button ID="btnExportarExcel" runat="server" Text="Exportar CSV" CssClass="btn btn-outline-secondary" OnClick="btnExportarExcel_Click" />
                </div>
            </div>

            <!-- KPIS -->
            <div class="kpi-grid-4col">
                <div class="kpi-card">
                    <div class="kpi-titulo">Inversi&oacute;n Total (c/ IVA)</div>
                    <div class="kpi-valor" style="font-size: 24px;"><asp:Label ID="lblKpiTotal" runat="server" Text="$0"></asp:Label></div>
                    <div style="font-size: 11px; color: var(--color-texto-suave);">Compras en el per&iacute;odo</div>
                </div>

                <div class="kpi-card">
                    <div class="kpi-titulo">Laboratorios Activos</div>
                    <div class="kpi-valor"><asp:Label ID="lblKpiLabs" runat="server" Text="0"></asp:Label></div>
                    <div style="font-size: 11px; color: var(--color-texto-suave);">Proveedores con compras</div>
                </div>

                <div class="kpi-card">
                    <div class="kpi-titulo">Unidades Adquiridas</div>
                    <div class="kpi-valor" style="color: #2980B9;"><asp:Label ID="lblKpiUnidades" runat="server" Text="0"></asp:Label></div>
                    <div style="font-size: 11px; color: #2980B9;">Volumen total de insumos</div>
                </div>

                <div class="kpi-card">
                    <div class="kpi-titulo">Participaci&oacute;n L&iacute;der</div>
                    <div class="kpi-valor" style="color: #27AE60;"><asp:Label ID="lblKpiLider" runat="server" Text="0%"></asp:Label></div>
                    <div style="font-size: 11px; color: var(--color-texto-suave);"><asp:Label ID="lblKpiLiderNombre" runat="server" Text="Sin registros"></asp:Label></div>
                </div>
            </div>

            <!-- FILTROS -->
            <section class="filter-card card-dermocosmetica" aria-label="Filtros por laboratorio y marca">
                <div class="lab-filter-grid">
                    <div class="form-group-dermo" style="margin-bottom: 0;">
                        <asp:Label runat="server" CssClass="form-label" AssociatedControlID="txtFechaDesde">Fecha Desde</asp:Label>
                        <asp:TextBox ID="txtFechaDesde" runat="server" TextMode="Date" CssClass="form-control"></asp:TextBox>
                    </div>

                    <div class="form-group-dermo" style="margin-bottom: 0;">
                        <asp:Label runat="server" CssClass="form-label" AssociatedControlID="txtFechaHasta">Fecha Hasta</asp:Label>
                        <asp:TextBox ID="txtFechaHasta" runat="server" TextMode="Date" CssClass="form-control"></asp:TextBox>
                    </div>

                    <div class="form-group-dermo" style="margin-bottom: 0;">
                        <asp:Label runat="server" CssClass="form-label" AssociatedControlID="ddlLaboratorio">Laboratorio</asp:Label>
                        <asp:DropDownList ID="ddlLaboratorio" runat="server" CssClass="form-select"></asp:DropDownList>
                    </div>

                    <div class="form-group-dermo" style="margin-bottom: 0;">
                        <asp:Label runat="server" CssClass="form-label" AssociatedControlID="ddlMarca">Marca</asp:Label>
                        <asp:DropDownList ID="ddlMarca" runat="server" CssClass="form-select"></asp:DropDownList>
                    </div>

                    <div class="form-group-dermo" style="margin-bottom: 0;">
                        <asp:Label runat="server" CssClass="form-label" AssociatedControlID="ddlEstadoOC">Estado &Oacute;rdenes</asp:Label>
                        <asp:DropDownList ID="ddlEstadoOC" runat="server" CssClass="form-select">
                            <asp:ListItem Value="VALIDAS" Text="V&#225;lidas (Sin Anuladas)"></asp:ListItem>
                            <asp:ListItem Value="Recibida" Text="Solo Recibidas"></asp:ListItem>
                            <asp:ListItem Value="TODAS" Text="Todas las &#211;rdenes"></asp:ListItem>
                        </asp:DropDownList>
                    </div>

                    <div class="compras-acciones">
                        <asp:Button ID="btnFiltrar" runat="server" Text="Filtrar" CssClass="btn btn-primary" OnClick="btnFiltrar_Click" />
                        <asp:Button ID="btnLimpiar" runat="server" Text="Limpiar filtros" CssClass="btn btn-outline-secondary" OnClick="btnLimpiar_Click" />
                    </div>
                </div>
            </section>

            <!-- HOJA IMPRIMIBLE -->
            <div id="reporte-imprimible" class="printable-sheet">

                <div class="report-header-banner">
                    <div>
                        <div style="font-family: 'Playfair Display', serif; font-size: 20px; font-weight: 700; color: var(--color-texto);">
                            DERMO ERP - COSMETOLOG&Iacute;A PROFESIONAL
                        </div>
                        <div style="font-size: 11px; color: var(--color-texto-suave); letter-spacing: 1px; text-transform: uppercase; margin-top: 2px;">
                            Distribuidora de Dermocosm&eacute;tica y Cosmec&eacute;utica Profesional
                        </div>
                        <div style="font-size: 12px; margin-top: 8px; color: var(--color-acento); font-weight: 600;">
                            INFORME GERENCIAL: AN&Aacute;LISIS DE COMPRAS POR LABORATORIO Y MARCA (RF-COM-11)
                        </div>
                    </div>
                    <div style="text-align: right; font-size: 11px; color: var(--color-texto-suave); line-height: 1.6;">
                        <div><strong>Fecha Reporte:</strong> <%= DateTime.Now.ToString("dd/MM/yyyy HH:mm") %></div>
                        <div><strong>Auditor:</strong> <asp:Label ID="lblAuditor" runat="server"></asp:Label></div>
                        <div><strong>Sistema:</strong> ERP Dermo-Cosm&eacute;tica .NET</div>
                    </div>
                </div>

                <div class="table-dermo-container" style="border: none; box-shadow: none;">
                    <asp:GridView ID="gvReporte" runat="server" AutoGenerateColumns="False" CssClass="table table-hover align-middle" GridLines="None" EmptyDataText="No se registran compras por laboratorio o marca para los par&aacute;metros seleccionados.">
                        <Columns>
                            <asp:TemplateField HeaderText="Laboratorio">
                                <ItemTemplate>
                                    <div style="font-weight: 600;"><%# Eval("RazonSocial") %></div>
                                    <div style="font-size: 10px; color: var(--color-texto-suave);"><%# Eval("Pais") %></div>
                                </ItemTemplate>
                            </asp:TemplateField>

                            <asp:BoundField DataField="MarcaEfectiva" HeaderText="Marca" />
                            <asp:BoundField DataField="TotalOC" HeaderText="N&deg; OC" />
                            <asp:BoundField DataField="UnidadesTotales" HeaderText="Unidades" />
                            <asp:BoundField DataField="Neto" HeaderText="Neto ($)" DataFormatString="{0:C0}" />
                            <asp:BoundField DataField="Iva" HeaderText="IVA ($)" DataFormatString="{0:C0}" />

                            <asp:TemplateField HeaderText="Total ($)">
                                <ItemTemplate>
                                    <strong style="color: var(--color-acento);"><%# string.Format("{0:C0}", Eval("Total")) %></strong>
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

                            <asp:TemplateField HeaderText="Reclamos">
                                <ItemTemplate>
                                    <span class='<%# Convert.ToInt32(Eval("TotalReclamos")) > 0 ? "badge-claim-warn" : "badge-claim-ok" %>'>
                                        <%# Eval("TotalReclamos") %> dev.
                                    </span>
                                </ItemTemplate>
                            </asp:TemplateField>
                        </Columns>
                    </asp:GridView>
                </div>

                <!-- PIE DE REPORTE -->
                <div style="display: flex; justify-content: space-between; align-items: flex-end; margin-top: 30px; border-top: 1px solid var(--color-borde-suave); padding-top: 20px; flex-wrap: wrap; gap: 12px;">
                    <div style="font-size: 11px; color: var(--color-texto-suave); max-width: 540px;">
                        <em>Documento anal&iacute;tico generado autom&aacute;ticamente por el m&oacute;dulo de Compras y Abastecimiento para concentraci&oacute;n de compras por laboratorio/marca y monitoreo de reclamos de calidad. Taller de Ingenier&iacute;a de Software.</em>
                    </div>
                    <div style="text-align: right; font-size: 13px;">
                        <div>Inversi&oacute;n Consolidada Per&iacute;odo: <strong style="font-size: 18px; color: var(--color-acento);"><asp:Label ID="lblResumenTotal" runat="server" Text="$0"></asp:Label></strong></div>
                    </div>
                </div>

                <!-- FIRMAS DINAMICAS -->
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
                filename: 'Reporte_Compras_Laboratorio_Marca.pdf',
                image: { type: 'jpeg', quality: 0.98 },
                html2canvas: { scale: 2, useCORS: true },
                jsPDF: { unit: 'mm', format: 'letter', orientation: 'landscape' }
            };
            html2pdf().set(opt).from(elemento).save();
        }
        </script>
    </div>
</asp:Content>
