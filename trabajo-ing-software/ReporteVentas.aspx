<%@ Page Title="Reporte de Ventas" Language="C#" MasterPageFile="~/Contabilidad.Master" AutoEventWireup="true" CodeBehind="ReporteVentas.aspx.cs" Inherits="trabajo_ing_software.ReporteVentas" %>
<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    
    <link rel="preconnect" href="https://fonts.googleapis.com" />
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin="anonymous" />
    <link href="https://fonts.googleapis.com/css2?family=Playfair+Display:ital,wght@0,500;0,600;0,700;1,400;1,500;1,600&family=Plus+Jakarta+Sans:wght@300;400;500;600;700&display=swap" rel="stylesheet" />

    <script src="https://cdnjs.cloudflare.com/ajax/libs/html2pdf.js/0.10.1/html2pdf.bundle.min.js"></script>

    <div class="card-dermo-luxury" style="max-width: 1200px; margin: 30px auto;">
        
        <!-- CABECERA DE LA PANTALLA -->
        <div style="display: flex; justify-content: space-between; align-items: flex-start; margin-bottom: 25px; flex-wrap: wrap; gap: 15px;">
            <div>
                <span class="pill-badge" style="margin-bottom: 8px;">M&oacute;dulo de Ventas &bull; Anal&iacute;tica</span>
                <h1 style="font-size: 28px; margin: 4px 0 6px 0;">Reporte General de Ventas</h1>
                <p class="text-muted" style="margin: 0;">M&eacute;tricas consolidadas, historial de transacciones y an&aacute;lisis comercial.</p>
            </div>
            <div style="display: flex; gap: 12px; align-items: center;">
                <asp:Button ID="btnVolverVentas" runat="server" Text="&larr; Volver a Ventas" CssClass="btn-dermo-secondary" OnClick="btnVolverVentas_Click" />
                <asp:Button ID="btnDescargarPDF" runat="server" Text="Descargar PDF" CssClass="btn-dermo-primary" OnClientClick="generarPDF(); return false;" />
            </div>
        </div>

        <!-- TARJETAS DE KPIS SUPERIORES (TABLERO RAPIDO) -->
        <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(260px, 1fr)); gap: 20px; margin-bottom: 30px;">
            <div class="kpi-mini-card" style="text-align: center; padding: 22px;">
                <div class="kpi-mini-title">Total Transacciones</div>
                <div class="kpi-mini-value" style="font-size: 32px; color: var(--color-acento); margin: 6px 0;">
                    <asp:Label ID="lblTotalTransacciones" runat="server" Text="0"></asp:Label>
                </div>
                <div class="kpi-mini-sub">Operaciones registradas</div>
            </div>
            
            <div class="kpi-mini-card" style="text-align: center; padding: 22px;">
                <div class="kpi-mini-title">Ingresos Totales</div>
                <div class="kpi-mini-value" style="font-size: 32px; color: var(--color-acento); margin: 6px 0;">
                    <asp:Label ID="Label1" runat="server" Text="$0"></asp:Label>
                </div>
                <div class="kpi-mini-sub">Volumen facturado bruto</div>
            </div>
        </div>

        <!-- HOJA DE REPORTE IMPRIMIBLE -->
        <div id="areaReporte" style="background-color: var(--color-blanco); border-radius: 20px; border: 1px solid var(--color-borde-suave); padding: 30px; box-shadow: 0 4px 15px rgba(0,0,0,0.02);">
            
            <!-- ENCABEZADO DEL REPORTE IMPRESO -->
            <div style="display: flex; justify-content: space-between; align-items: flex-start; border-bottom: 2px solid var(--color-acento); padding-bottom: 16px; margin-bottom: 25px;">
                <div>
                    <div style="font-family: 'Playfair Display', Georgia, serif; font-size: 18px; font-weight: 700; letter-spacing: 2px; color: var(--color-texto);">
                        DISTRIBUIDORA DE DERMOCOSM&Eacute;TICA
                    </div>
                    <div style="font-size: 10px; font-weight: 600; letter-spacing: 1.5px; color: var(--color-texto-suave); text-transform: uppercase;">
                        M&oacute;dulo de Ventas &bull; Informe Comercial
                    </div>
                </div>
                <div style="text-align: right; font-size: 11px; color: var(--color-texto-suave);">
                    <div>Documento Oficial de Liquidaci&oacute;n</div>
                    <div>Fecha de emisi&oacute;n: <strong><%= DateTime.Now.ToString("dd/MM/yyyy HH:mm") %></strong></div>
                </div>
            </div>

            <!-- RESUMEN METRICO DEL REPORTE -->
            <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(240px, 1fr)); gap: 18px; margin-bottom: 25px;">
                <div class="kpi-mini-card" style="background-color: #FAF8F5;">
                    <div class="kpi-mini-title">Transacciones Validadas</div>
                    <div class="kpi-mini-value" style="font-size: 26px; color: var(--color-acento);">
                        <asp:Label ID="lblCantidadVentas" runat="server" Text="0"></asp:Label>
                    </div>
                    <div class="kpi-mini-sub">Total emitido en per&iacute;odo</div>
                </div>
                <div class="kpi-mini-card" style="background-color: #FAF8F5;">
                    <div class="kpi-mini-title">Ingresos Brutos</div>
                    <div class="kpi-mini-value" style="font-size: 26px; color: var(--color-acento);">
                        <asp:Label ID="lblIngresosTotales" runat="server" Text="$0"></asp:Label>
                    </div>
                    <div class="kpi-mini-sub">Recaudaci&oacute;n total</div>
                </div>
            </div>

            <!-- SECCION: HISTORIAL DE OPERACIONES -->
            <div style="margin-bottom: 30px;">
                <h3 style="font-size: 18px; margin: 0 0 14px 0;">Historial de Operaciones</h3>
                <div class="table-dermo-container">
                    <asp:GridView ID="gvReporteVentas" runat="server" CssClass="table-dermo-modern" AutoGenerateColumns="False" GridLines="None">
                        <Columns>
                            <asp:BoundField DataField="IdVenta" HeaderText="N&deg; Boleta" />
                            <asp:BoundField DataField="Fecha" HeaderText="Fecha y Hora" DataFormatString="{0:dd/MM/yyyy HH:mm}" />
                            <asp:BoundField DataField="Cliente" HeaderText="Cliente" />
                            <asp:BoundField DataField="Vendedor" HeaderText="Vendedor" />
                            <asp:BoundField DataField="Total" HeaderText="Total Venta" DataFormatString="${0:N0}" />
                        </Columns>
                    </asp:GridView>
                </div>
            </div>

            <div style="border-top: 1px solid var(--color-borde-suave); margin: 30px 0;"></div>

            <!-- SECCIONES PARALELAS: TOP PRODUCTOS Y TOP CLIENTES -->
            <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(420px, 1fr)); gap: 24px;">
                <!-- REPORTE: PRODUCTOS MAS VENDIDOS -->
                <div>
                    <h3 style="font-size: 16px; margin: 0 0 12px 0;">Reporte: Productos M&aacute;s Vendidos</h3>
                    <div class="table-dermo-container">
                        <asp:GridView ID="gvTopProductos" runat="server" CssClass="table-dermo-modern" AutoGenerateColumns="False" GridLines="None">
                            <Columns>
                                <asp:BoundField DataField="Producto" HeaderText="Producto" />
                                <asp:BoundField DataField="UnidadesVendidas" HeaderText="Unidades" />
                                <asp:BoundField DataField="IngresoTotal" HeaderText="Ingresos" DataFormatString="${0:N0}" />
                            </Columns>
                        </asp:GridView>
                    </div>
                </div>

                <!-- REPORTE: MEJORES CLIENTES -->
                <div>
                    <h3 style="font-size: 16px; margin: 0 0 12px 0;">Reporte: Mejores Clientes</h3>
                    <div class="table-dermo-container">
                        <asp:GridView ID="gvTopClientes" runat="server" CssClass="table-dermo-modern" AutoGenerateColumns="False" GridLines="None">
                            <Columns>
                                <asp:BoundField DataField="Cliente" HeaderText="Cliente" />
                                <asp:BoundField DataField="Compras" HeaderText="N&deg; Compras" />
                                <asp:BoundField DataField="TotalGastado" HeaderText="Total Gastado" DataFormatString="${0:N0}" />
                            </Columns>
                        </asp:GridView>
                    </div>
                </div>
            </div>

            <!-- PIE DE REPORTE -->
            <div style="margin-top: 30px; border-top: 1px solid var(--color-borde-suave); padding-top: 16px; font-size: 11px; color: var(--color-texto-suave); text-align: center;">
                <em>Reporte anal&iacute;tico oficial generado por el M&oacute;dulo de Ventas y Facturaci&oacute;n. Cosmetolog&iacute;a Profesional.</em>
            </div>

        </div>
    </div>

    <script>
        function generarPDF() {
            var elemento = document.getElementById('areaReporte');
            var opciones = {
                margin: 10,
                filename: 'Reporte_Ventas_Dermocosmetica.pdf',
                image: { type: 'jpeg', quality: 0.98 },
                html2canvas: { scale: 2, useCORS: true },
                jsPDF: { unit: 'mm', format: 'letter', orientation: 'portrait' }
            };
            html2pdf().set(opciones).from(elemento).save();
        }
    </script>
</asp:Content>
