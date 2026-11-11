<%@ Page Title="Evaluación de proveedores" MasterPageFile="~/Contabilidad.Master" Language="C#" AutoEventWireup="true" CodeBehind="ReporteProveedores.aspx.cs" Inherits="trabajo_ing_software.ReporteProveedores" ResponseEncoding="utf-8" ContentType="text/html; charset=utf-8" %>
<asp:Content ID="Recursos" ContentPlaceHolderID="EstilosPagina" runat="server">
<script src="https://cdnjs.cloudflare.com/ajax/libs/html2pdf.js/0.10.1/html2pdf.bundle.min.js"></script>
<style>
        .container {
            max-width: 1320px;
            margin: 30px auto;
            padding: 0 24px;
        }
        .header-top {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 25px;
            padding-bottom: 15px;
            border-bottom: 1px solid var(--color-borde-suave);
        }
        .nav-links {
            display: flex;
            align-items: center;
            gap: 12px;
        }
        /* Tarjetas de Metricas (KPIs) */
        .kpi-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 18px;
            margin-bottom: 30px;
        }
        .kpi-card {
            background-color: var(--color-blanco);
            border-radius: 18px;
            padding: 20px 16px;
            border: 1px solid var(--color-borde-suave);
            box-shadow: 0 4px 15px rgba(122, 94, 71, 0.05);
            text-align: center;
        }
        .kpi-valor {
            font-family: 'Playfair Display', Georgia, serif;
            font-size: 30px;
            font-weight: 700;
            color: var(--color-acento);
            margin: 8px 0;
        }
        .kpi-titulo {
            font-size: 12px;
            color: var(--color-secundario);
            text-transform: uppercase;
            letter-spacing: 0.5px;
            font-weight: 600;
        }
        .badge-excelente {
            background-color: #E8F8F0;
            color: #27AE60;
            padding: 4px 12px;
            border-radius: 12px;
            font-size: 12px;
            font-weight: 600;
            display: inline-block;
        }
        .badge-aceptable {
            background-color: #FEF9E7;
            color: #D4AC0D;
            padding: 4px 12px;
            border-radius: 12px;
            font-size: 12px;
            font-weight: 600;
            display: inline-block;
        }
        .badge-critico {
            background-color: #FDEDEC;
            color: #C0392B;
            padding: 4px 12px;
            border-radius: 12px;
            font-size: 12px;
            font-weight: 600;
            display: inline-block;
        }
        .table-dermo-container .table th,
        .table-dermo-container .table td {
            padding: 10px 8px;
            font-size: 12.5px;
        }
        @media print {
            .no-print {
                display: none !important;
            }
            .container {
                max-width: 100%;
                margin: 0;
                padding: 0;
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
        <div class="container" id="reporte-proveedores">
            <div class="header-top no-print">
                <div>
                    <h1>Reporte: Evaluaci&oacute;n de Proveedores</h1>
                    <span style="font-size: 13px; color: var(--color-texto-suave);">M&Oacute;DULO DE COMPRAS &bull; CUMPLIMIENTO, TIEMPOS Y AJUSTES DE BUSINESS INTELLIGENCE (BI)</span>
                </div>
                <div class="nav-links">
                    <a href="Laboratorios.aspx" class="btn btn-outline-secondary">Volver a Laboratorios</a>
                    <button type="button" class="btn btn-primary" onclick="descargarPDF();">Descargar PDF</button>
                </div>
            </div>

            <!-- Titulo del informe -->
            <div style="margin-bottom: 20px;">
                <h2 style="margin-bottom: 5px;">Distribuidora de Dermocosm&eacute;tica Profesional</h2>
                <p style="margin: 0; font-size: 14px; color: var(--color-texto-suave);">Informe Anal&iacute;tico de Rendimiento, Lead Time y Control de Calidad</p>
                <small style="color: gray;">Fecha de emisi&oacute;n: <%= DateTime.Now.ToString("dd/MM/yyyy HH:mm") %></small>
            </div>

            <!-- Fila de Tarjetas KPI con Ajustes de BI -->
            <div class="kpi-grid">
                <div class="kpi-card">
                    <span class="kpi-titulo">Laboratorios Activos</span>
                    <div class="kpi-valor"><asp:Label ID="lblTotalLaboratorios" runat="server" Text="0"></asp:Label></div>
                    <small style="color: gray;">En cat&aacute;logo homologado</small>
                </div>
                <div class="kpi-card">
                    <span class="kpi-titulo">&Oacute;rdenes de Compra</span>
                    <div class="kpi-valor"><asp:Label ID="lblTotalOC" runat="server" Text="0"></asp:Label></div>
                    <small style="color: gray;">Emitidas hist&oacute;ricamente</small>
                </div>
                <div class="kpi-card">
                    <span class="kpi-titulo">Lead Time Promedio (BI)</span>
                    <div class="kpi-valor"><asp:Label ID="lblLeadTimeGlobal" runat="server" Text="0"></asp:Label> <small style="font-size: 13px; font-weight: normal; color: gray;">d&iacute;as</small></div>
                    <small style="color: gray;">Tiempo entre OC y Recepci&oacute;n</small>
                </div>
                <div class="kpi-card">
                    <span class="kpi-titulo">Tasa de Defectos (BI)</span>
                    <div class="kpi-valor" style="color: #27AE60;"><asp:Label ID="lblTasaDefectosGlobal" runat="server" Text="0.0%"></asp:Label></div>
                    <small style="color: gray;">Devoluciones vs recepciones</small>
                </div>
                <div class="kpi-card">
                    <span class="kpi-titulo">Cumplimiento Global</span>
                    <div class="kpi-valor" style="color: #27AE60;"><asp:Label ID="lblCumplimientoGlobal" runat="server" Text="100%"></asp:Label></div>
                    <small style="color: gray;">Puntualidad en despachos</small>
                </div>
            </div>

            <asp:Label ID="lblPromedioDias" runat="server" Visible="false" Text="0"></asp:Label>

            <!-- Tabla de Evaluacion Analítica con Métricas BI -->
            <div class="table-dermo-container" style="margin-bottom: 30px;">
                <asp:GridView ID="gvReporte" runat="server" AutoGenerateColumns="False" 
                    CssClass="table table-hover align-middle" GridLines="None" EmptyDataText="No hay datos de compras u &oacute;rdenes registradas para evaluar.">
                    <Columns>
                        <asp:BoundField DataField="RazonSocial" HeaderText="LABORATORIO" />
                        <asp:BoundField DataField="Marca" HeaderText="MARCA" />
                        <asp:BoundField DataField="Pais" HeaderText="PA&Iacute;S" HtmlEncode="false" />
                        <asp:BoundField DataField="DiasPago" HeaderText="PLAZO CR&Eacute;DITO" HtmlEncode="false" />
                        <asp:BoundField DataField="TotalOC" HeaderText="&Oacute;RDENES" HtmlEncode="false" />
                        <asp:BoundField DataField="TotalRecepciones" HeaderText="RECEPCIONES" HtmlEncode="false" />
                        
                        <asp:TemplateField HeaderText="LEAD TIME PROMEDIO (BI)">
                            <ItemTemplate>
                                <%# FormatLeadTime(Eval("LeadTimePromedioDias"), Eval("TotalRecepciones")) %>
                            </ItemTemplate>
                        </asp:TemplateField>

                        <asp:TemplateField HeaderText="TASA DEFECTOS (BI)">
                            <ItemTemplate>
                                <%# FormatTasaDefectos(Eval("TasaDefectosPorcentaje"), Eval("TotalDevoluciones"), Eval("TotalRecepciones")) %>
                            </ItemTemplate>
                        </asp:TemplateField>

                        <asp:TemplateField HeaderText="% CUMPLIMIENTO">
                            <ItemTemplate>
                                <strong><%# Eval("PorcentajeCumplimiento") %>%</strong>
                            </ItemTemplate>
                        </asp:TemplateField>

                        <asp:TemplateField HeaderText="CALIFICACI&Oacute;N">
                            <ItemTemplate>
                                <span class='<%# GetClaseCalificacion(Eval("Calificacion").ToString()) %>'>
                                    <%# Eval("Calificacion") %>
                                </span>
                            </ItemTemplate>
                        </asp:TemplateField>
                    </Columns>
                </asp:GridView>
            </div>

            <!-- Resumen explicativo de Business Intelligence -->
            <div style="background-color: var(--color-blanco); border: 1px solid var(--color-borde-suave); border-radius: 16px; padding: 22px; font-size: 13px; line-height: 1.6; color: var(--color-texto-suave);">
                <div style="font-weight: 700; color: var(--color-acento); font-size: 14px; margin-bottom: 8px;">
                    Indicadores de Business Intelligence (BI) y Criterios de Evaluaci&oacute;n:
                </div>
                <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 20px;">
                    <div>
                        <strong>&bull; Lead Time Promedio (Ajuste BI):</strong> Mide los d&iacute;as corridos transcurridos entre la emisi&oacute;n de la Orden de Compra (<code>OrdenCompra.Fecha</code>) y el ingreso f&iacute;sico a bodega (<code>RecepcionCompra.FechaRecepcion</code>). Permite fiscalizar los tiempos de respuesta reales de cada laboratorio.<br />
                        <strong>&bull; Tasa de Defectos (Ajuste BI):</strong> Porcentaje de incidencias y devoluciones por no-conformidad sanitaria o roturas (<code>DevolucionProveedor</code>) respecto al total de recepciones registradas. Una tasa de 0% indica calidad y lote &iacute;ntegro.
                    </div>
                    <div>
                        <strong>&bull; Calificaci&oacute;n Global del Proveedor:</strong><br />
                        <span class="badge-excelente" style="font-size: 11px;">Excelente</span> Cumplimiento &ge; 90% y tasa de defectos &lt; 5%.<br />
                        <span class="badge-aceptable" style="font-size: 11px; margin-top: 4px;">Aceptable</span> Cumplimiento entre 70% y 89% dentro de la ventana de tolerancia.<br />
                        <span class="badge-critico" style="font-size: 11px; margin-top: 4px;">Cr&iacute;tico</span> Cumplimiento &lt; 70% o alta tasa de no conformidades.
                    </div>
                </div>
            </div>
        </div>

        <!-- Boton de respaldo para el diseñador -->
        <asp:Button ID="btnVolver" runat="server" Visible="false" OnClick="btnVolver_Click" />

        <script>
            function descargarPDF() {
                var elemento = document.getElementById('reporte-proveedores');
                var opt = {
                    margin:       [10, 10, 10, 10],
                    filename:     'Reporte_Evaluacion_Proveedores_BI.pdf',
                    image:        { type: 'jpeg', quality: 0.98 },
                    html2canvas:  { scale: 2 },
                    jsPDF:        { unit: 'mm', format: 'a4', orientation: 'landscape' }
                };
                html2pdf().set(opt).from(elemento).save();
            }
        </script>
        
    </div>
</asp:Content>
