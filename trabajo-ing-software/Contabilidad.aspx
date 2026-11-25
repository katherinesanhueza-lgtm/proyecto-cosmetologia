<%@ Page Title="Contabilidad" Language="C#" MasterPageFile="~/Contabilidad.Master" CodeBehind="Contabilidad.aspx.cs" Inherits="trabajo_ing_software.Contabilidad" ResponseEncoding="utf-8" %>
<asp:Content ID="Contenido" ContentPlaceHolderID="MainContent" runat="server">
    <div class="dashboard compras-resumen">

        <!-- PANTALLA 1: RESUMEN DE CONTABILIDAD (SEPARADA) -->
        <asp:Panel ID="pnlResumenContabilidad" runat="server">
            <header class="dashboard-header">
                <div>
                    <p class="dashboard-etiqueta">MÓDULO DE CONTABILIDAD</p>
                    <h1>Resumen de Contabilidad</h1>
                    <p class="dashboard-descripcion">Seguimiento de plan contable, libro diario general, cuentas por pagar y cuentas por cobrar.</p>
                </div>
            </header>

            <div class="compras-indicadores">
                <section class="card-dermocosmetica compras-kpi">
                    <h2>Cuentas contables</h2>
                    <strong><asp:Literal ID="litContCuentas" runat="server" Mode="Encode" Text="0" /></strong>
                    <span>Plan de cuentas activo en el ERP</span>
                </section>
                <section class="card-dermocosmetica compras-kpi">
                    <h2>Asientos registrados</h2>
                    <strong><asp:Literal ID="litContAsientos" runat="server" Mode="Encode" Text="0" /></strong>
                    <span>Partidas contabilizadas en Libro Diario</span>
                </section>
                <section class="card-dermocosmetica compras-kpi">
                    <h2>Cuentas por pagar</h2>
                    <strong><asp:Literal ID="litContCxP" runat="server" Mode="Encode" Text="$0" /></strong>
                    <span>Compromisos pendientes con proveedores</span>
                </section>
                <section class="card-dermocosmetica compras-kpi">
                    <h2>Cuentas por cobrar</h2>
                    <strong><asp:Literal ID="litContCxC" runat="server" Mode="Encode" Text="$0" /></strong>
                    <span>Saldos vigentes por cobrar a clientes</span>
                </section>
            </div>

            <div class="compras-paneles">
                <section class="card-dermocosmetica" aria-labelledby="tendencia-contable">
                    <h2 id="tendencia-contable">Movimientos por mes</h2>
                    <p class="compras-nota">Últimos seis meses · total contabilizado al Debe</p>
                    <div class="compras-grafico" role="list" aria-label="Importes contables mensuales">
                        <asp:Repeater ID="rptMesesContabilidad" runat="server">
                            <ItemTemplate>
                                <div class="compras-mes" role="listitem">
                                    <span class="compras-importe"><%#: Eval("Importe") %></span>
                                    <div class="compras-barra-espacio" aria-hidden="true"><span style='height: <%#: Eval("Altura") %>%'></span></div>
                                    <span><%#: Eval("Mes") %></span>
                                </div>
                            </ItemTemplate>
                        </asp:Repeater>
                    </div>
                    <asp:Label ID="lblSinAsientosMes" runat="server" CssClass="compras-nota d-block mt-3" Visible="false"
                        Text="Aún no hay movimientos contables en este período." />
                </section>

                <section class="card-dermocosmetica" aria-labelledby="asientos-recientes">
                    <h2 id="asientos-recientes">Asientos recientes</h2>
                    <p class="compras-nota">Últimas cinco partidas en el Libro Diario</p>
                    <div class="table-responsive">
                        <asp:GridView ID="gvAsientosRecientes" runat="server" AutoGenerateColumns="false" GridLines="None"
                            CssClass="table table-hover" EmptyDataText="Aún no se han registrado asientos contables.">
                            <Columns>
                                <asp:BoundField DataField="IdAsiento" HeaderText="N°" />
                                <asp:BoundField DataField="Fecha" HeaderText="Fecha" />
                                <asp:BoundField DataField="Glosa" HeaderText="Glosa" />
                                <asp:BoundField DataField="Importe" HeaderText="Total" />
                            </Columns>
                        </asp:GridView>
                    </div>
                    <div class="d-flex gap-2 flex-wrap">
                        <a class="btn btn-outline-secondary" href="<%: ResolveUrl("~/Contabilidad.aspx?vista=cuentas") %>">Ver Plan de Cuentas</a>
                        <a class="btn btn-outline-secondary" href="<%: ResolveUrl("~/Contabilidad.aspx?vista=diario") %>">Ir al Libro Diario</a>
                    </div>
                </section>
            </div>
        </asp:Panel>

        <!-- PANTALLA 2: VISTAS OPERATIVAS DE CONTABILIDAD (SEPARADAS) -->
        <asp:Panel ID="pnlVistaContabilidad" runat="server" Visible="false">
            <header class="dashboard-header">
                <div>
                    <p class="dashboard-etiqueta">MÓDULO DE CONTABILIDAD</p>
                    <h1>Gestión de Contabilidad</h1>
                    <p class="dashboard-descripcion">Consulta y registra asientos del libro diario, cobros a clientes y pérdidas financieras conectadas con Compras, Ventas e Inventario.</p>
                </div>
            </header>

            <section class="table-dermo-container">
                <div class="dermo-table-headbar">
                    <div class="dermo-table-headbar-title">
                        <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#7A5E47" stroke-width="2" aria-hidden="true"><path d="M4 19.5A2.5 2.5 0 0 1 6.5 17H20"></path><path d="M6.5 2H20v20H6.5A2.5 2.5 0 0 1 4 19.5v-15A2.5 2.5 0 0 1 6.5 2z"></path></svg>
                        <h2><asp:Literal ID="Titulo" runat="server" Mode="Encode" /></h2>
                    </div>
                    <span class="dermo-pill-neutral">Gesti&oacute;n contable</span>
                </div>
                <div style="padding: 18px 22px 22px 22px;">
                    <asp:Label ID="Mensaje" runat="server" EnableViewState="false" role="status" />
                    <div class="contabilidad-formulario">
                        <asp:PlaceHolder ID="Formulario" runat="server" />
                    </div>
                    <div class="table-dermo-container mt-4" style="box-shadow: none;">
                        <div class="table-responsive">
                            <asp:GridView ID="Registros" runat="server" CssClass="table table-hover align-middle"
                                GridLines="None" EmptyDataText="No hay registros para esta consulta." EnableViewState="false" />
                        </div>
                    </div>
                </div>
            </section>
            <script>
                (function () {
                    var el = document.getElementById('<%= Mensaje.ClientID %>');
                    if (el && el.innerText && el.innerText.trim().length > 0) {
                        var btn = document.createElement('button');
                        btn.type = 'button';
                        btn.className = 'dermo-alert-close';
                        btn.setAttribute('aria-label', 'Cerrar alerta');
                        btn.innerHTML = '&times;';
                        btn.onclick = function () { el.style.display = 'none'; };
                        el.appendChild(btn);
                    }
                })();
            </script>
        </asp:Panel>

    </div>
</asp:Content>
