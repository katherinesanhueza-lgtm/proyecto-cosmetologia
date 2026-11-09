<%@ Page Title="Resumen de Compras" Language="C#" MasterPageFile="~/Contabilidad.Master"
    CodeBehind="Compras.aspx.cs" Inherits="trabajo_ing_software.Compras" ResponseEncoding="utf-8" %>
<asp:Content ID="Estilos" ContentPlaceHolderID="EstilosPagina" runat="server">
    <link href="<%: ResolveUrl("~/Content/ComprasResumen.css?v=1") %>" rel="stylesheet" />
</asp:Content>
<asp:Content ID="Contenido" ContentPlaceHolderID="MainContent" runat="server">
    <div class="dashboard compras-resumen">
        <header class="dashboard-header">
            <div>
                <p class="dashboard-etiqueta">Módulo de compras</p>
                <h1>Resumen de Compras</h1>
                <p class="dashboard-descripcion">Seguimiento de órdenes, proveedores y recepciones.</p>
            </div>
        </header>
        <asp:PlaceHolder ID="Acceso" runat="server" Visible="false">
            <section class="card-dermocosmetica">
                <h2>Consulta el resumen de Compras</h2>
                <p>Inicia sesión con una cuenta autorizada para ver los indicadores.</p>
                <a class="btn btn-primary" href="<%: ResolveUrl("~/Login.aspx") %>">Iniciar sesión</a>
            </section>
        </asp:PlaceHolder>
        <asp:Label ID="Mensaje" runat="server" CssClass="alert alert-warning d-block" Visible="false" />
        <asp:PlaceHolder ID="Panel" runat="server" Visible="false">
            <div class="compras-indicadores">
                <section class="card-dermocosmetica compras-kpi">
                    <h2>Compras del mes</h2>
                    <strong><asp:Literal ID="Importe" runat="server" Mode="Encode" /></strong>
                    <span>Importe de órdenes vigentes, con IVA</span>
                </section>
                <section class="card-dermocosmetica compras-kpi">
                    <h2>Por recibir</h2>
                    <strong><asp:Literal ID="Pendientes" runat="server" Mode="Encode" /></strong>
                    <span>Órdenes emitidas o parciales</span>
                </section>
                <section class="card-dermocosmetica compras-kpi">
                    <h2>Recepciones del mes</h2>
                    <strong><asp:Literal ID="RecepcionesMes" runat="server" Mode="Encode" /></strong>
                    <span>Ingresos registrados en bodega</span>
                </section>
                <section class="card-dermocosmetica compras-kpi">
                    <h2>Proveedores activos</h2>
                    <strong><asp:Literal ID="Proveedores" runat="server" Mode="Encode" /></strong>
                    <span>Laboratorios habilitados</span>
                </section>
            </div>

            <div class="compras-paneles">
                <section class="card-dermocosmetica" aria-labelledby="tendencia-compras">
                    <h2 id="tendencia-compras">Compras por mes</h2>
                    <p class="compras-nota">Últimos seis meses · total con IVA</p>
                    <div class="compras-grafico" role="list" aria-label="Importes mensuales">
                        <asp:Repeater ID="Meses" runat="server">
                            <ItemTemplate>
                                <div class="compras-mes" role="listitem">
                                    <span class="compras-importe"><%#: Eval("Importe") %></span>
                                    <div class="compras-barra-espacio" aria-hidden="true"><span style='height: <%#: Eval("Altura") %>%'></span></div>
                                    <span><%#: Eval("Mes") %></span>
                                </div>
                            </ItemTemplate>
                        </asp:Repeater>
                    </div>
                    <asp:Label ID="SinCompras" runat="server" CssClass="compras-nota d-block mt-3" Visible="false"
                        Text="Aún no hay compras vigentes en este período." />
                </section>
                <section class="card-dermocosmetica" aria-labelledby="ordenes-compras">
                    <h2 id="ordenes-compras">Órdenes recientes</h2>
                    <p class="compras-nota">Últimas cinco órdenes registradas</p>
                    <div class="table-responsive">
                        <asp:GridView ID="Ordenes" runat="server" AutoGenerateColumns="false" GridLines="None"
                            CssClass="table table-hover" EmptyDataText="Aún no se han registrado órdenes de compra.">
                            <Columns>
                                <asp:BoundField DataField="NumeroOC" HeaderText="Orden" />
                                <asp:BoundField DataField="Proveedor" HeaderText="Proveedor" />
                                <asp:BoundField DataField="Estado" HeaderText="Estado" />
                                <asp:BoundField DataField="Importe" HeaderText="Total" />
                            </Columns>
                        </asp:GridView>
                    </div>
                    <a class="btn btn-outline-secondary" href="<%: ResolveUrl("~/OrdenesCompra.aspx") %>">Ver órdenes de compra</a>
                </section>
            </div>
        </asp:PlaceHolder>
    </div>
</asp:Content>
