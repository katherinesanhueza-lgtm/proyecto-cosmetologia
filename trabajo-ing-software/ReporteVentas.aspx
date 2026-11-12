<%@ Page Title="Reporte de Ventas" Language="C#" MasterPageFile="~/Contabilidad.Master" AutoEventWireup="true" CodeBehind="ReporteVentas.aspx.cs" Inherits="trabajo_ing_software.ReporteVentas" ResponseEncoding="utf-8" %>

<asp:Content ID="Estilos" ContentPlaceHolderID="EstilosPagina" runat="server">
    <link href="<%: ResolveUrl("~/Content/ComprasResumen.css?v=1") %>" rel="stylesheet" />
    <link href="<%: ResolveUrl("~/Content/Estilos.css") %>" rel="stylesheet" type="text/css" />
    <script src="https://cdnjs.cloudflare.com/ajax/libs/html2pdf.js/0.10.1/html2pdf.bundle.min.js"></script>
</asp:Content>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <div class="dashboard compras-resumen">
        
        <header class="dashboard-header" style="display: flex; justify-content: space-between; align-items: flex-start; flex-wrap: wrap; gap: 15px;">
            <div>
                <p class="dashboard-etiqueta">Módulo de ventas · Analítica</p>
                <h1>Reporte General de Ventas</h1>
                <p class="dashboard-descripcion">Métricas consolidadas, historial de transacciones y análisis comercial.</p>
            </div>
            <div>
                <!-- Botón Volver a Ventas oculto para no romper el evento en C# -->
                <asp:Button ID="btnDescargarPDF" runat="server" Text="Descargar PDF" CssClass="btn btn-primary" OnClientClick="generarPDF(); return false;" />
            </div>
        </header>

        <!-- TARJETAS DE KPIS SUPERIORES ESTILO COMPRAS -->
        <div class="compras-indicadores">
            <section class="card-dermocosmetica compras-kpi">
                <h2>Total Transacciones</h2>
                <strong><asp:Label ID="lblTotalTransacciones" runat="server" Text="0"></asp:Label></strong>
                <span>Operaciones registradas</span>
            </section>
            <section class="card-dermocosmetica compras-kpi">
                <h2>Ingresos Totales</h2>
                <strong><asp:Label ID="Label1" runat="server" Text="$0"></asp:Label></strong>
                <span>Volumen facturado bruto</span>
            </section>
        </div>

        <!-- ÁREA DE REPORTE IMPRIMIBLE -->
        <section id="areaReporte" class="card-dermocosmetica">
            
            <div style="display: flex; justify-content: space-between; align-items: flex-start; border-bottom: 1px solid #e5e0d8; padding-bottom: 16px; margin-bottom: 24px;">
                <div>
                    <h2 style="margin: 0;">Informe Comercial de Ventas</h2>
                    <p class="compras-nota" style="margin: 4px 0 0 0;">Distribuidora de Dermocosmética · Documento Oficial</p>
                </div>
                <div style="text-align: right; font-size: 12px; color: #7a756c;">
                    <div>Fecha de emisión: <strong><%= DateTime.Now.ToString("dd/MM/yyyy HH:mm") %></strong></div>
                </div>
            </div>

            <!-- Labels secundarios del reporte mantenidos ocultos para que el C# no falle al asignarlos -->
            <div class="d-none">
                <asp:Label ID="lblCantidadVentas" runat="server" Text="0"></asp:Label>
                <asp:Label ID="lblIngresosTotales" runat="server" Text="$0"></asp:Label>
            </div>

            <!-- HISTORIAL DE OPERACIONES -->
            <div style="margin-bottom: 28px;">
                <h2 style="margin-bottom: 12px;">Historial de Operaciones</h2>
                <div class="table-responsive">
                    <asp:GridView ID="gvReporteVentas" runat="server" CssClass="table table-hover" AutoGenerateColumns="False" GridLines="None" EmptyDataText="No hay ventas registradas.">
                        <Columns>
                            <asp:BoundField DataField="IdVenta" HeaderText="N° Boleta" />
                            <asp:BoundField DataField="Fecha" HeaderText="Fecha y Hora" DataFormatString="{0:dd/MM/yyyy HH:mm}" />
                            <asp:BoundField DataField="Cliente" HeaderText="Cliente" />
                            <asp:BoundField DataField="Vendedor" HeaderText="Vendedor" />
                            <asp:BoundField DataField="Total" HeaderText="Total Venta" DataFormatString="${0:N0}" />
                        </Columns>
                    </asp:GridView>
                </div>
            </div>

            <!-- SECCIONES PARALELAS: TOP PRODUCTOS Y MEJORES CLIENTES -->
            <div class="compras-paneles">
                <div>
                    <h2 style="margin-bottom: 12px;">Productos Más Vendidos</h2>
                    <div class="table-responsive">
                        <asp:GridView ID="gvTopProductos" runat="server" CssClass="table table-hover" AutoGenerateColumns="False" GridLines="None" EmptyDataText="Sin datos de productos.">
                            <Columns>
                                <asp:BoundField DataField="Producto" HeaderText="Producto" />
                                <asp:BoundField DataField="UnidadesVendidas" HeaderText="Unidades" />
                                <asp:BoundField DataField="IngresoTotal" HeaderText="Ingresos" DataFormatString="${0:N0}" />
                            </Columns>
                        </asp:GridView>
                    </div>
                </div>

                <div>
                    <h2 style="margin-bottom: 12px;">Mejores Clientes</h2>
                    <div class="table-responsive">
                        <asp:GridView ID="gvTopClientes" runat="server" CssClass="table table-hover" AutoGenerateColumns="False" GridLines="None" EmptyDataText="Sin datos de clientes.">
                            <Columns>
                                <asp:BoundField DataField="Cliente" HeaderText="Cliente" />
                                <asp:BoundField DataField="Compras" HeaderText="N° Compras" />
                                <asp:BoundField DataField="TotalGastado" HeaderText="Total Gastado" DataFormatString="${0:N0}" />
                            </Columns>
                        </asp:GridView>
                    </div>
                </div>
            </div>

        </section>

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