<%@ Page Title="Inicio" Language="C#" MasterPageFile="~/Contabilidad.Master"
    AutoEventWireup="true" CodeBehind="Default.aspx.cs" Inherits="trabajo_ing_software._Default" ResponseEncoding="utf-8" %>

<asp:Content ID="EstilosInicio" ContentPlaceHolderID="EstilosPagina" runat="server">
    <link href="<%: ResolveUrl("~/Content/Inicio.css?v=7") %>" rel="stylesheet" />
</asp:Content>

<asp:Content ID="Acciones" ContentPlaceHolderID="AccionesUsuario" runat="server">
    <asp:Button ID="btnLogout" runat="server" Text="Cerrar Sesión" CssClass="btn btn-outline-secondary btn-sm cierre-compras" OnClick="btnLogout_Click" CausesValidation="false" />
</asp:Content>

<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">
    <div class="dashboard inicio-dashboard">
        <header class="dashboard-header">
            <div>
                <p class="dashboard-etiqueta">Panel ejecutivo central</p>
                <h1>Bienvenido a Dermo ERP</h1>
                <p class="dashboard-descripcion"><%: DescripcionInicio %></p>
            </div>
            <div class="inicio-fecha">
                <span>Fecha del sistema</span>
                <asp:Label ID="lblFecha" runat="server" />
            </div>
        </header>

        <section aria-labelledby="resumen-inicio">
            <div class="inicio-seccion-header">
                <div>
                    <h2 id="resumen-inicio">Resumen general de los módulos</h2>
                    <p>Indicadores clave consolidados de cada área operativa del ERP.</p>
                </div>
            </div>

            <div class="inicio-indicadores-4">
                <!-- RESUMEN COMPRAS -->
                <% if (VerArea("Comprador")) { %><div class="card-dermocosmetica inicio-indicador">
                    <span class="inicio-icono" aria-hidden="true">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.75" stroke-linecap="round" stroke-linejoin="round"><path d="M5 7h14v14H5z M9 8V6a3 3 0 0 1 6 0v2" /></svg>
                    </span>
                    <div class="inicio-indicador-cuerpo">
                        <span class="inicio-indicador-titulo">Compras vigentes</span>
                        <asp:Label ID="lblComprasTotal" runat="server" Text="$0" CssClass="inicio-valor" />
                        <asp:Label ID="lblComprasDetalle" runat="server" Text="0 órdenes · 0 laboratorios" CssClass="inicio-detalle" />
                    </div>
                </div><% } %>

                <!-- RESUMEN VENTAS -->
                <% if (VerArea("Vendedor")) { %><div class="card-dermocosmetica inicio-indicador">
                    <span class="inicio-icono" aria-hidden="true">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.75" stroke-linecap="round" stroke-linejoin="round"><path d="M5 9h14l2 4v7H3v-7z M7 9V4h10v5 M7 15h3 M15 15h2" /></svg>
                    </span>
                    <div class="inicio-indicador-cuerpo">
                        <span class="inicio-indicador-titulo">Ventas acumuladas</span>
                        <asp:Label ID="lblVentasTotal" runat="server" Text="$0" CssClass="inicio-valor" />
                        <asp:Label ID="lblVentasDetalle" runat="server" Text="0 documentos · 0 clientes" CssClass="inicio-detalle" />
                    </div>
                </div><% } %>

                <!-- RESUMEN INVENTARIO -->
                <div class="card-dermocosmetica inicio-indicador">
                    <span class="inicio-icono" aria-hidden="true">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.75" stroke-linecap="round" stroke-linejoin="round"><path d="M3 4h18v5H3z M5 9v11h14V9 M10 13h4" /></svg>
                    </span>
                    <div class="inicio-indicador-cuerpo">
                        <span class="inicio-indicador-titulo">Productos activos</span>
                        <asp:Label ID="lblProductos" runat="server" Text="0" CssClass="inicio-valor" />
                        <asp:Label ID="lblInventarioDetalle" runat="server" Text="0 unidades en stock" CssClass="inicio-detalle" />
                    </div>
                </div>

                <!-- RESUMEN CONTABILIDAD -->
                <% if (VerArea("Contador")) { %><div class="card-dermocosmetica inicio-indicador">
                    <span class="inicio-icono" aria-hidden="true">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.75" stroke-linecap="round" stroke-linejoin="round"><path d="M3 9l9-6 9 6H3z M5 20h14 M7 10v7 M12 10v7 M17 10v7" /></svg>
                    </span>
                    <div class="inicio-indicador-cuerpo">
                        <span class="inicio-indicador-titulo">Asientos contables</span>
                        <asp:Label ID="lblContabilidadTotal" runat="server" Text="0" CssClass="inicio-valor" />
                        <asp:Label ID="lblContabilidadDetalle" runat="server" Text="0 CxP · 0 CxC vigentes" CssClass="inicio-detalle" />
                    </div>
                </div><% } %>
            <% if (EsVistaCompleta) { %></div>

            <div class="inicio-indicadores" style="margin-top: 16px;"><% } %>
                <div class="card-dermocosmetica inicio-indicador">
                    <span class="inicio-icono inicio-icono-alerta" aria-hidden="true">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.75" stroke-linecap="round" stroke-linejoin="round"><path d="M10.29 3.86L1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0z M12 9v4 M12 17h.01" /></svg>
                    </span>
                    <div class="inicio-indicador-cuerpo">
                        <span class="inicio-indicador-titulo">Productos con stock bajo</span>
                        <asp:Label ID="lblStockBajo" runat="server" Text="0" CssClass="inicio-valor" />
                        <span class="inicio-detalle">Existencias al mínimo o por debajo</span>
                    </div>
                </div>

                <div class="card-dermocosmetica inicio-indicador">
                    <span class="inicio-icono" aria-hidden="true">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.75" stroke-linecap="round" stroke-linejoin="round"><path d="M3 10 12 4l9 6v10H3zM8 20v-7h8v7M8 16h8" /></svg>
                    </span>
                    <div class="inicio-indicador-cuerpo">
                        <span class="inicio-indicador-titulo">Bodegas activas</span>
                        <asp:Label ID="lblBodegas" runat="server" Text="0" CssClass="inicio-valor" />
                        <span class="inicio-detalle">Puntos de almacenamiento habilitados</span>
                    </div>
                </div>

                <% if (PuedeGestionarInventario) { %><div class="card-dermocosmetica inicio-indicador">
                    <span class="inicio-icono" aria-hidden="true">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.75" stroke-linecap="round" stroke-linejoin="round"><path d="M21 16V8a2 2 0 0 0-1-1.73l-7-4a2 2 0 0 0-2 0l-7 4A2 2 0 0 0 3 8v8a2 2 0 0 0 1 1.73l7 4a2 2 0 0 0 2 0l7-4A2 2 0 0 0 21 16z M3.27 6.96L12 12.01l8.73-5.05 M12 22.08V12" /></svg>
                    </span>
                    <div class="inicio-indicador-cuerpo">
                        <span class="inicio-indicador-titulo">Lotes y logística activa</span>
                        <asp:Label ID="lblOperacionesCurso" runat="server" Text="0" CssClass="inicio-valor" />
                        <span class="inicio-detalle">Lotes vigentes con trazabilidad FEFO</span>
                    </div>
                </div><% } %>
            </div>
        </section>

        <section class="inicio-seccion" aria-labelledby="modulos-inicio">
            <div class="inicio-seccion-header">
                <div>
                    <h2 id="modulos-inicio">Accesos rápidos</h2>
                    <p>Navega directamente al módulo operativo que necesitas gestionar.</p>
                </div>
            </div>
            <div class="inicio-modulos<%: EsVistaCompleta ? "" : " inicio-modulos-2" %>">
                <% if (VerArea("Comprador")) { %><a href="<%: ResolveUrl("~/Compras.aspx") %>" class="inicio-modulo">
                    <span class="inicio-icono" aria-hidden="true">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.75" stroke-linecap="round" stroke-linejoin="round"><path d="M5 7h14v14H5z M9 8V6a3 3 0 0 1 6 0v2" /></svg>
                    </span>
                    <h3>Compras</h3>
                    <p>Administra laboratorios proveedores, cotizaciones de importación, órdenes y recepciones.</p>
                    <span class="inicio-enlace">Ir a compras</span>
                </a><% } %>
                <% if (VerArea("Vendedor")) { %><a href="<%: ResolveUrl("~/Ventas.aspx") %>" class="inicio-modulo">
                    <span class="inicio-icono" aria-hidden="true">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.75" stroke-linecap="round" stroke-linejoin="round"><path d="M5 9h14l2 4v7H3v-7z M7 9V4h10v5 M7 15h3 M15 15h2" /></svg>
                    </span>
                    <h3>Ventas</h3>
                    <p>Gestiona cartera de clientes, presupuestos, emisión de boletas y facturas y despachos.</p>
                    <span class="inicio-enlace">Ir a ventas</span>
                </a><% } %>
                <a href="<%: ResolveUrl("~/Inventario.aspx?vista=resumen") %>" class="inicio-modulo">
                    <span class="inicio-icono" aria-hidden="true">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.75" stroke-linecap="round" stroke-linejoin="round"><path d="M3 4h18v5H3z M5 9v11h14V9 M10 13h4" /></svg>
                    </span>
                    <h3>Inventario</h3>
                    <p><%: PuedeGestionarInventario ? "Consulta existencias por SKU y bodega, control de lotes FEFO y movimientos de kardex." : "Consulta existencias por SKU y bodega, historial de movimientos, alertas y reportes de inventario." %></p>
                    <span class="inicio-enlace">Ver inventario</span>
                </a>
                <% if (EsBodeguero) { %><a href="<%: ResolveUrl("~/Despachos.aspx") %>" class="inicio-modulo">
                    <span class="inicio-icono" aria-hidden="true">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.75" stroke-linecap="round" stroke-linejoin="round"><path d="M1 3h15v13H1z M16 8h4l3 3v5h-7V8z M5.5 18.5m-2 0a2 2 0 1 0 4 0a2 2 0 1 0-4 0 M18.5 18.5m-2 0a2 2 0 1 0 4 0a2 2 0 1 0-4 0" /></svg>
                    </span>
                    <h3>Despachos</h3>
                    <p>Consulta y actualiza el estado de preparación, ruta y entrega de despachos asignados.</p>
                    <span class="inicio-enlace">Ir a despachos</span>
                </a><% } %>
                <% if (VerArea("Contador")) { %><a href="<%: ResolveUrl("~/Contabilidad.aspx?vista=diario") %>" class="inicio-modulo">
                    <span class="inicio-icono" aria-hidden="true">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.75" stroke-linecap="round" stroke-linejoin="round"><path d="M3 9l9-6 9 6H3z M5 20h14 M7 10v7 M12 10v7 M17 10v7" /></svg>
                    </span>
                    <h3>Contabilidad</h3>
                    <p>Consulta libro diario, cuentas por pagar y flujo de caja, cobros a clientes y pérdidas de inventario.</p>
                    <span class="inicio-enlace">Ir a contabilidad</span>
                </a><% } %>
            </div>
        </section>

        <section class="inicio-seccion" aria-labelledby="estado-inicio">
            <h2 id="estado-inicio">Estado del sistema</h2>
            <div class="card-dermocosmetica inicio-estado" role="status">
                <span id="indicadorEstado" runat="server" class="inicio-estado-punto" aria-hidden="true"></span>
                <div>
                    <strong><asp:Label ID="lblEstadoSistema" runat="server" /></strong>
                    <p><asp:Label ID="lblDescripcionEstado" runat="server" /></p>
                </div>
            </div>
        </section>
    </div>
</asp:Content>
