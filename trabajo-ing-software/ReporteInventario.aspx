
<%@ Page Title="Reporte de Inventario"
    Language="C#"
    MasterPageFile="~/Contabilidad.Master"
    AutoEventWireup="true"
    CodeBehind="ReporteInventario.aspx.cs"
    Inherits="trabajo_ing_software.ReporteInventario"
    ResponseEncoding="utf-8" %>

<asp:Content ID="Estilos" ContentPlaceHolderID="EstilosPagina" runat="server">
    <script src="https://cdnjs.cloudflare.com/ajax/libs/html2pdf.js/0.10.1/html2pdf.bundle.min.js"></script>
</asp:Content>

<asp:Content ID="BodyContent"
    ContentPlaceHolderID="MainContent"
    runat="server">

    <div class="dashboard compras-resumen">

        <header class="dashboard-header" style="display: flex; justify-content: space-between; align-items: flex-start; flex-wrap: wrap; gap: 15px;">
            <div>
                <p class="dashboard-etiqueta">
                    M&Oacute;DULO DE INVENTARIO &bull; REPORTABILIDAD
                </p>

                <h1>Reporte de Inventario</h1>

                <p class="dashboard-descripcion">
                    Resumen general de existencias, disponibilidad por bodega y control de stock m&iacute;nimo.
                </p>
            </div>
            <div class="d-flex gap-2">
                <asp:Button ID="btnExportar"
                    runat="server"
                    Text="Exportar Excel"
                    CssClass="btn btn-outline-secondary"
                    OnClick="btnExportar_Click" />
                <button type="button" onclick="exportarPDF();" class="btn btn-primary">
                    <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" aria-hidden="true"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"></path><polyline points="14 2 14 8 20 8"></polyline><line x1="12" y1="18" x2="12" y2="12"></line><line x1="9" y1="15" x2="15" y2="15"></line></svg>
                    Descargar PDF
                </button>
            </div>
        </header>

        <!-- INDICADORES (SOLO PANTALLA, FUERA DEL PDF) -->
        <div class="compras-indicadores no-print" style="margin-bottom: 24px;">
            <section class="card-dermocosmetica compras-kpi">
                <h2>Productos registrados</h2>
                <strong><asp:Label ID="lblTotal" runat="server" Text="0" /></strong>
                <span>Registros totales en bodegas</span>
            </section>

            <section class="card-dermocosmetica compras-kpi">
                <h2>Disponibles</h2>
                <strong><asp:Label ID="lblDisponibles" runat="server" Text="0" /></strong>
                <span>Stock normal sobre el m&iacute;nimo</span>
            </section>

            <section class="card-dermocosmetica compras-kpi">
                <h2>Stock bajo</h2>
                <strong><asp:Label ID="lblStockBajo" runat="server" Text="0" /></strong>
                <span>En nivel de reposici&oacute;n</span>
            </section>

            <section class="card-dermocosmetica compras-kpi">
                <h2>Sin stock</h2>
                <strong><asp:Label ID="lblSinStock" runat="server" Text="0" /></strong>
                <span>Variantes agotadas en bodega</span>
            </section>
        </div>

        <!-- HOJA FORMAL EXPORTABLE A PDF -->
        <section id="areaReporteInventario" class="card-dermocosmetica" style="padding: 32px;">

            <div class="report-header-banner" style="display: flex; justify-content: space-between; align-items: flex-start; border-bottom: 2px solid #8b6f56; padding-bottom: 16px; margin-bottom: 20px;">
                <div>
                    <div style="font-family: 'Playfair Display', Georgia, serif; font-size: 20px; font-weight: 700; color: #24211e;">
                        DERMO ERP - COSMETOLOG&Iacute;A PROFESIONAL
                    </div>
                    <p class="compras-nota" style="margin: 2px 0 6px 0; text-transform: uppercase; letter-spacing: 0.8px; font-size: 11px;">
                        Distribuidora de Dermocosm&eacute;tica y Cosmec&eacute;utica Profesional
                    </p>
                    <h2 style="margin: 0; font-size: 15px; color: #8b6f56;">Informe Oficial de Existencias y Disponibilidad</h2>
                </div>
                <div style="text-align: right; font-size: 11px; color: #7a756c; line-height: 1.6;">
                    <div>Fecha de emisi&oacute;n: <strong><%= DateTime.Now.ToString("dd/MM/yyyy HH:mm") %></strong></div>
                    <div>M&oacute;dulo: Inventario y Control de Stock</div>
                    <div>Sistema: ERP Dermo-Cosm&eacute;tica .NET</div>
                </div>
            </div>

            <!-- DETALLE -->
            <div>
                <h2 style="font-size: 1.15rem; font-weight: 600; margin-bottom: 6px;">Detalle de existencias</h2>

                <p class="compras-nota" style="margin-bottom: 16px;">
                    Estado actual del inventario registrado en las bodegas.
                </p>

                <asp:Label ID="lblMensaje"
                    runat="server"
                    EnableViewState="false" />

                <div class="table-dermo-container" style="box-shadow: none;">
                    <div class="table-responsive">
                        <asp:GridView ID="gvReporte"
                            runat="server"
                            AutoGenerateColumns="False"
                            CssClass="table table-hover align-middle"
                            GridLines="None"
                            EmptyDataText="No hay registros.">

                            <Columns>
                                <asp:BoundField DataField="Producto" HeaderText="Producto" ItemStyle-CssClass="fw-semibold" />
                                <asp:BoundField DataField="SKU" HeaderText="SKU" ItemStyle-CssClass="text-nowrap" />
                                <asp:BoundField DataField="Bodega" HeaderText="Bodega" />
                                <asp:BoundField DataField="StockActual" HeaderText="Stock actual" HeaderStyle-CssClass="text-center" ItemStyle-CssClass="text-center fw-semibold" />
                                <asp:BoundField DataField="StockMinimo" HeaderText="Stock m&#237;nimo" HeaderStyle-CssClass="text-center" ItemStyle-CssClass="text-center" />
                                <asp:TemplateField HeaderText="Estado" HeaderStyle-CssClass="text-center" ItemStyle-CssClass="text-center">
                                    <ItemTemplate>
                                        <span class='<%# Convert.ToString(Eval("EstadoStock")) == "Sin stock" ? "dermo-pill-danger" : Convert.ToString(Eval("EstadoStock")) == "Stock bajo" ? "dermo-pill-warn" : "dermo-pill-ok" %>'>
                                            <%#: Eval("EstadoStock") %>
                                        </span>
                                    </ItemTemplate>
                                </asp:TemplateField>
                            </Columns>

                        </asp:GridView>
                    </div>
                </div>
            </div>

            <!-- FIRMAS INSTITUCIONALES -->
            <div style="display: grid; grid-template-columns: repeat(3, 1fr); gap: 30px; margin-top: 45px; padding-top: 20px; border-top: 1px solid #e5e0d8; text-align: center; font-size: 11px; color: #4a453f;">
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

        </section>

    </div>

    <script>
        function exportarPDF() {
            window.dermoDescargarPDF('areaReporteInventario', 'Reporte_Inventario_DermoERP.pdf');
        }
    </script>

</asp:Content>
