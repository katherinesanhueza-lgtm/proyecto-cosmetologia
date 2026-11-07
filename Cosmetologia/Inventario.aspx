
<%@ Page Title="Inventario" Language="C#"
    MasterPageFile="~/Site.Master"
    AutoEventWireup="true"
    CodeBehind="Inventario.aspx.cs"
    Inherits="Cosmetologia.Inventario" %>

<asp:Content ID="BodyContent"
    ContentPlaceHolderID="MainContent"
    runat="server">

    <div class="dashboard">

        <div class="dashboard-header">
            <div>
                <p class="dashboard-etiqueta">
                    MÓDULO DE INVENTARIO
                </p>

                <h1>Gestión de Inventario</h1>

                <p class="dashboard-descripcion">
                    Consulta de productos, variantes y
                    existencias registradas en el sistema.
                </p>
            </div>
        </div>

        <section class="dashboard-seccion">

            <div class="card-dermocosmetica">

                <h2>Productos en inventario</h2>

                <p>
                    Consulta las existencias disponibles
                    en las distintas bodegas.
                </p>

                <!-- BUSCADOR Y FILTROS -->
                <div class="row g-3 mb-4">

                    <div class="col-md-4">
                        <label for="txtBuscar" class="form-label">
                            Buscar producto
                        </label>

                        <asp:TextBox
                            ID="txtBuscar"
                            runat="server"
                            CssClass="form-control"
                            placeholder="Nombre o SKU"
                            MaxLength="100">
                        </asp:TextBox>
                    </div>

                    <div class="col-md-3">
                        <label class="form-label">
                            Bodega
                        </label>

                        <asp:DropDownList
                            ID="ddlBodega"
                            runat="server"
                            CssClass="form-select">
                        </asp:DropDownList>
                    </div>

                    <div class="col-md-3">
                        <label class="form-label">
                            Estado del stock
                        </label>

                        <asp:DropDownList
                            ID="ddlEstado"
                            runat="server"
                            CssClass="form-select">

                            <asp:ListItem Value="">
                                Todos
                            </asp:ListItem>

                            <asp:ListItem Value="Disponible">
                                Disponible
                            </asp:ListItem>

                            <asp:ListItem Value="Stock bajo">
                                Stock bajo
                            </asp:ListItem>

                            <asp:ListItem Value="Sin stock">
                                Sin stock
                            </asp:ListItem>

                        </asp:DropDownList>
                    </div>

                    <div class="col-md-2 d-flex align-items-end">
                        <asp:Button
                            ID="btnBuscar"
                            runat="server"
                            Text="Buscar"
                            CssClass="btn btn-primary w-100"
                            OnClick="btnBuscar_Click" />
                    </div>

                </div>

                <div class="mb-3">
                    <asp:Button
                        ID="btnLimpiar"
                        runat="server"
                        Text="Limpiar filtros"
                        CssClass="btn btn-outline-secondary"
                        OnClick="btnLimpiar_Click" />
                </div>

                <!-- MENSAJES -->
                <asp:Label
                    ID="lblMensaje"
                    runat="server"
                    EnableViewState="false"
                    role="status">
                </asp:Label>

                <!-- TABLA DE INVENTARIO -->
                <div class="table-responsive">

                    <asp:GridView
                        ID="gvInventario"
                        runat="server"
                        AutoGenerateColumns="False"
                        CssClass="table table-hover"
                        GridLines="None"
                        EmptyDataText="No se encontraron productos.">

                        <Columns>

                            <asp:BoundField
                                DataField="Producto"
                                HeaderText="Producto" />

                            <asp:BoundField
                                DataField="SKU"
                                HeaderText="SKU" />

                            <asp:BoundField
                                DataField="Presentacion"
                                HeaderText="Presentación" />

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

            </div>

        </section>

    </div>

</asp:Content>
