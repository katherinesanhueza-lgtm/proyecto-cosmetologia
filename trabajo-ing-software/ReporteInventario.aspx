
<%@ Page Title="Reporte de Inventario"
    Language="C#"
    MasterPageFile="~/Contabilidad.Master"
    AutoEventWireup="true"
    CodeBehind="ReporteInventario.aspx.cs"
    Inherits="trabajo_ing_software.ReporteInventario" %>

<asp:Content ID="BodyContent"
    ContentPlaceHolderID="MainContent"
    runat="server">

    <div class="dashboard">

        <div class="dashboard-header">
            <div>
                <p class="dashboard-etiqueta">
                    MÓDULO DE INVENTARIO
                </p>

                <h1>Reporte de Inventario</h1>

                <p class="dashboard-descripcion">
                    Resumen general de existencias
                    y disponibilidad de productos.
                </p>
            </div>
        </div>

        <!-- INDICADORES -->
        <section class="dashboard-seccion">

            <div class="row g-3 mb-4">

                <div class="col-md-3">
                    <div class="card-dermocosmetica">
                        <h3>Productos registrados</h3>
                        <asp:Label ID="lblTotal"
                            runat="server"
                            Font-Size="XX-Large"
                            Text="0" />
                    </div>
                </div>

                <div class="col-md-3">
                    <div class="card-dermocosmetica">
                        <h3>Disponibles</h3>
                        <asp:Label ID="lblDisponibles"
                            runat="server"
                            Font-Size="XX-Large"
                            Text="0" />
                    </div>
                </div>

                <div class="col-md-3">
                    <div class="card-dermocosmetica">
                        <h3>Stock bajo</h3>
                        <asp:Label ID="lblStockBajo"
                            runat="server"
                            Font-Size="XX-Large"
                            Text="0" />
                    </div>
                </div>

                <div class="col-md-3">
                    <div class="card-dermocosmetica">
                        <h3>Sin stock</h3>
                        <asp:Label ID="lblSinStock"
                            runat="server"
                            Font-Size="XX-Large"
                            Text="0" />
                    </div>
                </div>

            </div>

            <!-- DETALLE -->
            <div class="card-dermocosmetica">

                <h2>Detalle de existencias</h2>

                <p>
                    Estado actual del inventario
                    registrado en las bodegas.
                </p>

                <asp:Label ID="lblMensaje"
                    runat="server"
                    EnableViewState="false" />

                <div class="table-responsive">

                    <asp:GridView ID="gvReporte"
                        runat="server"
                        AutoGenerateColumns="False"
                        CssClass="table table-hover"
                        GridLines="None"
                        EmptyDataText="No hay registros.">

                        <Columns>
                            <asp:BoundField
                                DataField="Producto"
                                HeaderText="Producto" />

                            <asp:BoundField
                                DataField="SKU"
                                HeaderText="SKU" />

                            <asp:BoundField
                                DataField="Bodega"
                                HeaderText="Bodega" />

                            <asp:BoundField
                                DataField="StockActual"
                                HeaderText="Stock actual" />

                            <asp:BoundField
                                DataField="StockMinimo"
                                HeaderText="Stock mínimo" />

                            <asp:BoundField
                                DataField="EstadoStock"
                                HeaderText="Estado" />
                        </Columns>

                    </asp:GridView>

                </div>

                <asp:Button ID="btnExportar"
                    runat="server"
                    Text="Exportar CSV"
                    CssClass="btn btn-primary mt-3"
                    OnClick="btnExportar_Click" />

            </div>

        </section>

    </div>

</asp:Content>
