<%@ Page Title="Resumen de Inventario" Language="C#"
    MasterPageFile="~/Contabilidad.Master"
    AutoEventWireup="true"
    CodeBehind="Inventario.aspx.cs"
    Inherits="trabajo_ing_software.Inventario" %>

<asp:Content ID="BodyContent"
    ContentPlaceHolderID="MainContent"
    runat="server">

    <div class="dashboard compras-resumen">

        <!-- PANTALLA 1: RESUMEN DE INVENTARIO (SEPARADA) -->
        <asp:Panel ID="pnlResumenInventario" runat="server">
            <div class="dashboard-header">
                <div>
                    <p class="dashboard-etiqueta">
                        MÓDULO DE INVENTARIO
                    </p>
                    <h1>Resumen de Inventario</h1>
                    <p class="dashboard-descripcion">
                        Seguimiento de catálogo de productos, stock disponible por bodega, alertas y lotes con criterio FEFO.
                    </p>
                </div>
            </div>

            <div class="compras-indicadores">
                <section class="card-dermocosmetica compras-kpi">
                    <h2>Productos activos</h2>
                    <strong><asp:Literal ID="litInvProductos" runat="server" Mode="Encode" Text="0" /></strong>
                    <span>Catálogo de productos habilitados</span>
                </section>
                <section class="card-dermocosmetica compras-kpi">
                    <h2>Stock disponible</h2>
                    <strong><asp:Literal ID="litInvStockTotal" runat="server" Mode="Encode" Text="0" /></strong>
                    <span>Unidades físicas en bodegas</span>
                </section>
                <section class="card-dermocosmetica compras-kpi">
                    <h2>Alertas de stock</h2>
                    <strong><asp:Literal ID="litInvStockBajo" runat="server" Mode="Encode" Text="0" /></strong>
                    <span>Variantes en nivel mínimo o crítico</span>
                </section>
                <section class="card-dermocosmetica compras-kpi">
                    <h2>Lotes vigentes FEFO</h2>
                    <strong><asp:Literal ID="litInvLotes" runat="server" Mode="Encode" Text="0" /></strong>
                    <span>Lotes activos con control de caducidad</span>
                </section>
            </div>

            <div class="compras-paneles">
                <section class="card-dermocosmetica" aria-labelledby="distribucion-inventario">
                    <h2 id="distribucion-inventario">Existencias por producto</h2>
                    <p class="compras-nota">Principales productos en stock · unidades disponibles</p>
                    <div class="compras-grafico" role="list" aria-label="Unidades en stock por producto">
                        <asp:Repeater ID="rptBarrasInventario" runat="server">
                            <ItemTemplate>
                                <div class="compras-mes" role="listitem">
                                    <span class="compras-importe"><%#: Eval("Unidades") %></span>
                                    <div class="compras-barra-espacio" aria-hidden="true"><span style='height: <%#: Eval("Altura") %>%'></span></div>
                                    <span><%#: Eval("Etiqueta") %></span>
                                </div>
                            </ItemTemplate>
                        </asp:Repeater>
                    </div>
                    <asp:Label ID="lblSinStockGrafico" runat="server" CssClass="compras-nota d-block mt-3" Visible="false"
                        Text="Aún no hay existencias registradas en bodega." />
                </section>

                <section class="card-dermocosmetica" aria-labelledby="lotes-recientes">
                    <h2 id="lotes-recientes">Lotes vigentes (FEFO)</h2>
                    <p class="compras-nota">Próximos lotes según orden de vencimiento</p>
                    <div class="table-responsive">
                        <asp:GridView ID="gvLotesRecientes" runat="server" AutoGenerateColumns="false" GridLines="None"
                            CssClass="table table-hover" EmptyDataText="No hay lotes vigentes registrados.">
                            <Columns>
                                <asp:BoundField DataField="NumeroLote" HeaderText="Lote" />
                                <asp:BoundField DataField="Producto" HeaderText="Producto" />
                                <asp:BoundField DataField="Vencimiento" HeaderText="Vence" />
                                <asp:BoundField DataField="Disponible" HeaderText="Unid." />
                            </Columns>
                        </asp:GridView>
                    </div>
                    <a class="btn btn-outline-secondary" href="<%: ResolveUrl("~/Inventario.aspx?vista=existencias") %>">Ver existencias</a>
                </section>
            </div>
        </asp:Panel>

        <!-- PANTALLA 2: EXISTENCIAS DE INVENTARIO (SEPARADA) -->
        <asp:Panel ID="pnlExistenciasInventario" runat="server" Visible="false">
            <div class="dashboard-header">
                <div>
                    <p class="dashboard-etiqueta">
                        MÓDULO DE INVENTARIO · EXISTENCIAS
                    </p>
                    <h1>Existencias en Bodega</h1>
                    <p class="dashboard-descripcion">
                        Consulta detallada de productos, variantes y existencias disponibles en las distintas bodegas.
                    </p>
                </div>
            </div>

            <section class="dashboard-seccion">
                <div class="card-dermocosmetica">
                    <h2>Productos en inventario</h2>
                    <p class="text-muted mb-3">
                        Filtra y consulta las existencias disponibles por SKU, bodega y estado de reposici&oacute;n.
                    </p>

                    <!-- BUSCADOR Y FILTROS -->
                    <div class="inv-filter-bar mb-4">
                        <div>
                            <label for="<%= txtBuscar.ClientID %>" class="form-label">Buscar producto</label>
                            <div style="position: relative; display: flex; align-items: center;">
                                <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" style="position: absolute; left: 12px; color: #736E67; pointer-events: none;" aria-hidden="true"><circle cx="11" cy="11" r="8"></circle><line x1="21" y1="21" x2="16.65" y2="16.65"></line></svg>
                                <asp:TextBox
                                    ID="txtBuscar"
                                    runat="server"
                                    CssClass="form-control"
                                    style="padding-left: 36px;"
                                    placeholder="Nombre o SKU"
                                    MaxLength="100">
                                </asp:TextBox>
                            </div>
                        </div>

                        <div>
                            <label class="form-label">Bodega</label>
                            <asp:DropDownList
                                ID="ddlBodega"
                                runat="server"
                                CssClass="form-select">
                            </asp:DropDownList>
                        </div>

                        <div>
                            <label class="form-label">Estado del stock</label>
                            <asp:DropDownList
                                ID="ddlEstado"
                                runat="server"
                                CssClass="form-select">
                                <asp:ListItem Value="">Todos</asp:ListItem>
                                <asp:ListItem Value="Disponible">Disponible</asp:ListItem>
                                <asp:ListItem Value="Stock bajo">Stock bajo</asp:ListItem>
                                <asp:ListItem Value="Sin stock">Sin stock</asp:ListItem>
                            </asp:DropDownList>
                        </div>

                        <div class="inv-filter-actions">
                            <asp:Button
                                ID="btnBuscar"
                                runat="server"
                                Text="Buscar"
                                CssClass="btn btn-primary"
                                OnClick="btnBuscar_Click" />
                            <asp:Button
                                ID="btnLimpiar"
                                runat="server"
                                Text="Limpiar filtros"
                                CssClass="btn btn-outline-secondary"
                                OnClick="btnLimpiar_Click" />
                        </div>
                    </div>

                    <!-- MENSAJES -->
                    <asp:Label
                        ID="lblMensaje"
                        runat="server"
                        EnableViewState="false"
                        role="status">
                    </asp:Label>

                    <!-- TABLA DE INVENTARIO -->
                    <div class="table-dermo-container" style="box-shadow: none;">
                        <div class="dermo-table-headbar">
                            <div class="dermo-table-headbar-title">
                                <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#7A5E47" stroke-width="2" aria-hidden="true"><path d="M21 16V8a2 2 0 0 0-1-1.73l-7-4a2 2 0 0 0-2 0l-7 4A2 2 0 0 0 3 8v8a2 2 0 0 0 1 1.73l7 4a2 2 0 0 0 2 0l7-4A2 2 0 0 0 21 16z"></path><polyline points="3.27 6.96 12 12.01 20.73 6.96"></polyline><line x1="12" y1="22.08" x2="12" y2="12"></line></svg>
                                <h3>Detalle de Existencias por Bodega</h3>
                            </div>
                            <span class="dermo-pill-ok">Control de stock</span>
                        </div>
                        <div class="table-responsive">
                            <asp:GridView
                                ID="gvInventario"
                                runat="server"
                                AutoGenerateColumns="False"
                                CssClass="table table-hover align-middle"
                                GridLines="None"
                                EmptyDataText="No se encontraron productos.">
                                <Columns>
                                    <asp:BoundField DataField="Producto" HeaderText="Producto" ItemStyle-CssClass="fw-semibold" />
                                    <asp:BoundField DataField="SKU" HeaderText="SKU" ItemStyle-CssClass="text-nowrap" />
                                    <asp:BoundField DataField="Presentacion" HeaderText="Presentaci&oacute;n" HtmlEncode="false" />
                                    <asp:BoundField DataField="Bodega" HeaderText="Bodega" />
                                    <asp:BoundField DataField="StockActual" HeaderText="Stock actual" HeaderStyle-CssClass="text-center" ItemStyle-CssClass="text-center fw-semibold" />
                                    <asp:BoundField DataField="StockMinimo" HeaderText="Stock m&iacute;nimo" HtmlEncode="false" HeaderStyle-CssClass="text-center" ItemStyle-CssClass="text-center" />
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
            </section>
        </asp:Panel>

    </div>

</asp:Content>
