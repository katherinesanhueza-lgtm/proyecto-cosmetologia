<%@ Page Title="Flujo de caja y proyección de pagos" Language="C#" MasterPageFile="~/Contabilidad.Master" AutoEventWireup="true" CodeBehind="ReporteFlujoCaja.aspx.cs" Inherits="trabajo_ing_software.ReporteFlujoCaja" ResponseEncoding="utf-8" ContentType="text/html; charset=utf-8" %>

<asp:Content ID="Recursos" ContentPlaceHolderID="EstilosPagina" runat="server">
    <script src="https://cdnjs.cloudflare.com/ajax/libs/html2pdf.js/0.10.1/html2pdf.bundle.min.js"></script>
    <style>
        .flujo-container { max-width: 1400px; margin: 0 auto; }

        .btn-primary {
            background-color: var(--color-acento);
            border-color: var(--color-acento);
            color: var(--color-blanco);
        }
        .btn-primary:hover {
            background-color: #725943;
            border-color: #725943;
            color: var(--color-blanco);
        }
        .btn-outline-secondary {
            border-color: var(--color-primario);
            color: var(--color-acento);
            background-color: var(--color-blanco);
        }
        .btn-outline-secondary:hover {
            background-color: var(--color-fondo);
            border-color: var(--color-acento);
            color: var(--color-acento);
        }

        .kpi-row-4col {
            display: grid;
            grid-template-columns: repeat(4, 1fr);
            gap: 16px;
            margin-bottom: 24px;
        }

        .kpi-card-cont {
            background: var(--color-blanco);
            border: 1px solid var(--color-primario);
            border-radius: 18px;
            padding: 18px 20px;
            text-align: center;
            box-shadow: 0 6px 20px rgba(139, 111, 86, 0.06);
        }

        .kpi-titulo {
            font-size: 11px;
            text-transform: uppercase;
            letter-spacing: 0.7px;
            color: var(--color-secundario);
            font-weight: 700;
        }

        .kpi-valor {
            font-family: 'Playfair Display', Georgia, serif;
            font-size: 24px;
            font-weight: 700;
            color: var(--color-acento);
            margin: 6px 0;
        }

        .flujo-filter-grid {
            display: grid;
            grid-template-columns: 1.4fr 1.2fr 200px auto;
            gap: 14px;
            align-items: end;
        }

        .printable-sheet {
            background-color: var(--color-blanco);
            border-radius: 20px;
            border: 1px solid var(--color-primario);
            padding: 35px;
            box-shadow: 0 10px 30px rgba(139, 111, 86, 0.08);
        }

        .report-header-banner {
            display: flex;
            justify-content: space-between;
            align-items: flex-start;
            border-bottom: 2px solid var(--color-acento);
            padding-bottom: 18px;
            margin-bottom: 24px;
        }

        .printable-sheet .table th,
        .printable-sheet .table td {
            padding: 10px 8px;
            font-size: 12.5px;
        }

        @media (max-width: 1050px) {
            .kpi-row-4col { grid-template-columns: repeat(2, 1fr); }
            .flujo-filter-grid { grid-template-columns: 1fr; }
        }
    </style>
</asp:Content>

<asp:Content ID="Acciones" ContentPlaceHolderID="AccionesUsuario" runat="server">
    <asp:Label ID="lblBienvenida" Visible="false" runat="server"></asp:Label>
    <asp:Button ID="btnLogout" runat="server" Text="Cerrar Sesi&oacute;n" CssClass="btn btn-outline-secondary btn-sm" OnClick="btnLogout_Click" />
</asp:Content>

<asp:Content ID="Contenido" ContentPlaceHolderID="MainContent" runat="server">
    <div class="dashboard flujo-container">

        <!-- ENCABEZADO -->
        <header class="dashboard-header" style="flex-wrap: wrap; gap: 14px;">
            <div>
                <p class="dashboard-etiqueta">M&Oacute;DULO DE CONTABILIDAD &bull; FLUJO DE CAJA BI</p>
                <h1>Proyecci&oacute;n de Pagos a Laboratorios</h1>
                <p class="dashboard-descripcion">Distribuci&oacute;n anal&iacute;tica de deuda pendiente en 4 tramos de vencimiento mediante agrupaci&oacute;n SQL (vencida, 30 d&iacute;as, 60 d&iacute;as y 90+ d&iacute;as).</p>
            </div>
            <div style="display: flex; gap: 10px; flex-wrap: wrap;">
                <a href="CuentasPagar.aspx" class="btn btn-outline-secondary">Volver a Cuentas por Pagar</a>
                <button type="button" onclick="exportarPDF();" class="btn btn-primary">Descargar PDF</button>
                <asp:Button ID="btnExportarExcel" runat="server" Text="Exportar CSV" CssClass="btn btn-outline-secondary" OnClick="btnExportarExcel_Click" />
            </div>
        </header>

        <!-- KPIS DE LOS 4 TRAMOS DE FLUJO DE CAJA -->
        <div class="kpi-row-4col">
            <div class="kpi-card-cont">
                <div class="kpi-titulo">Deuda Vencida</div>
                <div class="kpi-valor" style="color: #C0392B;"><asp:Label ID="lblKpiVencida" runat="server" Text="$0"></asp:Label></div>
                <div style="font-size: 11px; color: #C0392B;">Plazo expirado (&lt; 0 d&iacute;as)</div>
            </div>
            <div class="kpi-card-cont">
                <div class="kpi-titulo">A Pagar 30 D&iacute;as</div>
                <div class="kpi-valor" style="color: #D35400;"><asp:Label ID="lblKpi30Dias" runat="server" Text="$0"></asp:Label></div>
                <div style="font-size: 11px; color: #D35400;">Vencimiento entre 0 y 30 d&iacute;as</div>
            </div>
            <div class="kpi-card-cont">
                <div class="kpi-titulo">A Pagar 60 D&iacute;as</div>
                <div class="kpi-valor" style="color: #2980B9;"><asp:Label ID="lblKpi60Dias" runat="server" Text="$0"></asp:Label></div>
                <div style="font-size: 11px; color: #2980B9;">Vencimiento entre 31 y 60 d&iacute;as</div>
            </div>
            <div class="kpi-card-cont">
                <div class="kpi-titulo">90+ D&iacute;as (&gt; 60 d.)</div>
                <div class="kpi-valor" style="color: #27AE60;"><asp:Label ID="lblKpi90Mas" runat="server" Text="$0"></asp:Label></div>
                <div style="font-size: 11px; color: #27AE60;">Compromisos de largo plazo</div>
            </div>
        </div>

        <!-- BARRA DE FILTROS -->
        <section class="card-dermocosmetica" style="padding: 20px 24px; margin-bottom: 24px;">
            <div class="flujo-filter-grid">
                <div>
                    <label class="form-label fw-bold">Laboratorio / Proveedor</label>
                    <asp:DropDownList ID="ddlLaboratorio" runat="server" CssClass="form-select"></asp:DropDownList>
                </div>
                <div>
                    <label class="form-label fw-bold">B&uacute;squeda por Nombre o RUT</label>
                    <asp:TextBox ID="txtBuscar" runat="server" CssClass="form-control" placeholder="Ej: L'Or&eacute;al, ISDIN o RUT..."></asp:TextBox>
                </div>
                <div>
                    <label class="form-label fw-bold">Enfoque de Tramo</label>
                    <asp:DropDownList ID="ddlEnfoque" runat="server" CssClass="form-select">
                        <asp:ListItem Value="" Text="Todos los Tramos"></asp:ListItem>
                        <asp:ListItem Value="VENCIDA" Text="Con Deuda Vencida"></asp:ListItem>
                        <asp:ListItem Value="30DIAS" Text="Con Pagos 0-30 D&iacute;as"></asp:ListItem>
                        <asp:ListItem Value="60DIAS" Text="Con Pagos 31-60 D&iacute;as"></asp:ListItem>
                        <asp:ListItem Value="90MAS" Text="Con Pagos 90+ D&iacute;as"></asp:ListItem>
                    </asp:DropDownList>
                </div>
                <div style="display: flex; gap: 8px; flex-wrap: wrap;">
                    <asp:Button ID="btnFiltrar" runat="server" Text="Filtrar" CssClass="btn btn-primary" OnClick="btnFiltrar_Click" />
                    <asp:Button ID="btnLimpiar" runat="server" Text="Limpiar" CssClass="btn btn-outline-secondary" OnClick="btnLimpiar_Click" />
                </div>
            </div>
        </section>

        <!-- HOJA FORMAL DE PROYECCION DE PAGOS (4 COLUMNAS AGING SQL) -->
        <div id="reporte-imprimible" class="printable-sheet">

            <div class="report-header-banner">
                <div>
                    <div style="font-family: 'Playfair Display', serif; font-size: 20px; font-weight: 700; color: var(--color-texto);">
                        DERMO ERP - COSMETOLOG&Iacute;A PROFESIONAL
                    </div>
                    <div style="font-size: 11px; color: #777; letter-spacing: 1px; text-transform: uppercase; margin-top: 2px;">
                        Departamento de Contabilidad y Finanzas &bull; Flujo de Caja
                    </div>
                    <div style="font-size: 12px; margin-top: 8px; color: var(--color-acento); font-weight: 600;">
                        REPORTE BI: PROYECCI&Oacute;N DE PAGOS A LABORATORIOS POR VENCIMIENTO (30 / 60 / 90+ D&Iacute;AS)
                    </div>
                </div>
                <div style="text-align: right; font-size: 11px; color: #777; line-height: 1.6;">
                    <div><strong>Fecha Corte:</strong> <%= DateTime.Now.ToString("dd/MM/yyyy HH:mm") %></div>
                    <div><strong>Contador Responsable:</strong> <asp:Label ID="lblAuditor" runat="server"></asp:Label></div>
                    <div><strong>Sistema:</strong> ERP Dermo-Cosm&eacute;tica .NET</div>
                </div>
            </div>

            <div class="table-responsive">
                <asp:GridView ID="gvFlujo" runat="server" AutoGenerateColumns="False" CssClass="table table-hover align-middle" GridLines="None" EmptyDataText="No existen saldos pendientes con proveedores para los filtros seleccionados.">
                    <Columns>
                        <asp:TemplateField HeaderText="Laboratorio Proveedor">
                            <ItemTemplate>
                                <div style="font-weight: 600;"><%# Eval("Laboratorio") %></div>
                                <div style="font-size: 10px; color: #777;"><%# Eval("Rut") %> &bull; Cr&eacute;dito <%# Eval("DiasPago") %> d.</div>
                            </ItemTemplate>
                        </asp:TemplateField>

                        <asp:BoundField DataField="CuentasPendientes" HeaderText="Docs." />

                        <asp:TemplateField HeaderText="Deuda Vencida">
                            <ItemTemplate>
                                <span style='color: <%# Convert.ToDecimal(Eval("DeudaVencida")) > 0 ? "#C0392B; font-weight:700;" : "#777;" %>'>
                                    <%# string.Format("{0:C0}", Eval("DeudaVencida")) %>
                                </span>
                            </ItemTemplate>
                        </asp:TemplateField>

                        <asp:TemplateField HeaderText="A Pagar 30 D&iacute;as">
                            <ItemTemplate>
                                <span style='color: <%# Convert.ToDecimal(Eval("Pagar30Dias")) > 0 ? "#D35400; font-weight:700;" : "#777;" %>'>
                                    <%# string.Format("{0:C0}", Eval("Pagar30Dias")) %>
                                </span>
                            </ItemTemplate>
                        </asp:TemplateField>

                        <asp:TemplateField HeaderText="A Pagar 60 D&iacute;as">
                            <ItemTemplate>
                                <span style='color: <%# Convert.ToDecimal(Eval("Pagar60Dias")) > 0 ? "#2980B9; font-weight:700;" : "#777;" %>'>
                                    <%# string.Format("{0:C0}", Eval("Pagar60Dias")) %>
                                </span>
                            </ItemTemplate>
                        </asp:TemplateField>

                        <asp:TemplateField HeaderText="90+ D&iacute;as">
                            <ItemTemplate>
                                <span style='color: <%# Convert.ToDecimal(Eval("Pagar90MasDias")) > 0 ? "#27AE60; font-weight:700;" : "#777;" %>'>
                                    <%# string.Format("{0:C0}", Eval("Pagar90MasDias")) %>
                                </span>
                            </ItemTemplate>
                        </asp:TemplateField>

                        <asp:TemplateField HeaderText="Total Pendiente">
                            <ItemTemplate>
                                <strong style="color: var(--color-acento);"><%# string.Format("{0:C0}", Eval("TotalPendiente")) %></strong>
                            </ItemTemplate>
                        </asp:TemplateField>
                    </Columns>
                </asp:GridView>
            </div>

            <!-- PIE DE REPORTE -->
            <div style="display: flex; justify-content: space-between; align-items: flex-end; margin-top: 30px; border-top: 1px solid var(--color-primario); padding-top: 20px; flex-wrap: wrap; gap: 12px;">
                <div style="font-size: 11px; color: #777; max-width: 560px;">
                    <em>Proyecci&oacute;n de flujo de caja calculada sobre Cuentas por Pagar pendientes (Monto - Abonos) agrupadas por fecha de vencimiento (Recepci&oacute;n + D&iacute;as de cr&eacute;dito pactados con el laboratorio).</em>
                </div>
                <div style="text-align: right; font-size: 13px;">
                    <div>Deuda Total Proyectada: <strong style="font-size: 18px; color: var(--color-acento);"><asp:Label ID="lblResumenTotal" runat="server" Text="$0"></asp:Label></strong></div>
                </div>
            </div>

            <!-- FIRMAS CON NombreContador DESDE ConfiguracionGlobal -->
            <div style="display: grid; grid-template-columns: repeat(2, 1fr); gap: 50px; margin-top: 50px; text-align: center; font-size: 11px;">
                <div>
                    <div style="border-top: 1px solid #736E67; width: 70%; margin: 0 auto 6px auto;"></div>
                    <strong><asp:Label ID="lblFirmaContador" runat="server"></asp:Label></strong><br />
                    Contador General &bull; M&oacute;dulo de Contabilidad
                </div>
                <div>
                    <div style="border-top: 1px solid #736E67; width: 70%; margin: 0 auto 6px auto;"></div>
                    <strong><asp:Label ID="lblFirmaCompras" runat="server"></asp:Label></strong><br />
                    M&oacute;dulo de Compras y Abastecimiento
                </div>
            </div>

        </div>

        <script>
            function exportarPDF() {
                var elemento = document.getElementById('reporte-imprimible');
                var opt = {
                    margin: [10, 10, 10, 10],
                    filename: 'Reporte_Flujo_Caja_Laboratorios.pdf',
                    image: { type: 'jpeg', quality: 0.98 },
                    html2canvas: { scale: 2, useCORS: true },
                    jsPDF: { unit: 'mm', format: 'letter', orientation: 'landscape' }
                };
                html2pdf().set(opt).from(elemento).save();
            }
        </script>
    </div>
</asp:Content>
