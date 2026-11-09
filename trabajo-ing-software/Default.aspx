<%@ Page Title="Inicio" Language="C#" MasterPageFile="~/Contabilidad.Master"
    AutoEventWireup="true" CodeBehind="Default.aspx.cs" Inherits="trabajo_ing_software._Default" ResponseEncoding="utf-8" %>

<asp:Content ID="EstilosInicio" ContentPlaceHolderID="EstilosPagina" runat="server">
    <link href="<%: ResolveUrl("~/Content/Inicio.css?v=3") %>" rel="stylesheet" />
</asp:Content>

<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">
    <div class="dashboard inicio-dashboard">
        <header class="dashboard-header">
            <div>
                <p class="dashboard-etiqueta">Panel de administración</p>
                <h1>Bienvenido a Dermo ERP</h1>
                <p class="dashboard-descripcion">Gestiona inventario, compras, ventas y contabilidad desde un mismo lugar.</p>
            </div>
            <div class="inicio-fecha">
                <span>Fecha</span>
                <asp:Label ID="lblFecha" runat="server" />
            </div>
        </header>

        <section aria-labelledby="resumen-inicio">
            <h2 id="resumen-inicio">Resumen de inventario</h2>
            <div class="inicio-indicadores">
                <div class="card-dermocosmetica inicio-indicador">
                    <span class="inicio-icono" aria-hidden="true">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.7"><rect x="4" y="4" width="16" height="16" rx="2" /><path d="M4 10h16M10 10v10" /></svg>
                    </span>
                    <div>
                        <span class="inicio-indicador-titulo">Productos activos</span>
                        <asp:Label ID="lblProductos" runat="server" Text="—" CssClass="inicio-valor" />
                        <span class="inicio-detalle">En el catálogo</span>
                    </div>
                </div>
                <div class="card-dermocosmetica inicio-indicador">
                    <span class="inicio-icono inicio-icono-alerta" aria-hidden="true">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.7"><path d="M12 3 2.5 20h19L12 3Zm0 6v5m0 2v1" /></svg>
                    </span>
                    <div>
                        <span class="inicio-indicador-titulo">Productos con stock bajo</span>
                        <asp:Label ID="lblStockBajo" runat="server" Text="—" CssClass="inicio-valor" />
                        <span class="inicio-detalle">Existencias al mínimo o por debajo</span>
                    </div>
                </div>
                <div class="card-dermocosmetica inicio-indicador">
                    <span class="inicio-icono" aria-hidden="true">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.7"><path d="M3 10 12 4l9 6v10H3zM8 20v-7h8v7M8 16h8" /></svg>
                    </span>
                    <div>
                        <span class="inicio-indicador-titulo">Bodegas activas</span>
                        <asp:Label ID="lblBodegas" runat="server" Text="—" CssClass="inicio-valor" />
                        <span class="inicio-detalle">Puntos de almacenamiento</span>
                    </div>
                </div>
            </div>
        </section>

        <section class="inicio-seccion" aria-labelledby="modulos-inicio">
            <div class="inicio-seccion-header">
                <div>
                    <h2 id="modulos-inicio">Accesos rápidos</h2>
                    <p>Abre el módulo que necesitas.</p>
                </div>
                <a class="btn btn-outline-secondary" href="<%: ResolveUrl("~/ReporteInventario.aspx") %>">Reporte de inventario</a>
            </div>
            <div class="inicio-modulos">
                <a href="<%: ResolveUrl("~/Inventario.aspx") %>" class="inicio-modulo">
                    <span class="inicio-icono" aria-hidden="true">▦</span>
                    <h3>Inventario</h3>
                    <p>Consulta existencias por SKU y bodega, lotes y movimientos.</p>
                    <span class="inicio-enlace">Ver inventario →</span>
                </a>
                <a href="<%: ResolveUrl("~/Compras.aspx") %>" class="inicio-modulo">
                    <span class="inicio-icono" aria-hidden="true">□</span>
                    <h3>Compras</h3>
                    <p>Administra proveedores, órdenes de compra y recepciones.</p>
                    <span class="inicio-enlace">Ir a compras →</span>
                </a>
                <a href="<%: ResolveUrl("~/Ventas.aspx") %>" class="inicio-modulo">
                    <span class="inicio-icono" aria-hidden="true">◇</span>
                    <h3>Ventas</h3>
                    <p>Gestiona clientes, cotizaciones, ventas y despachos.</p>
                    <span class="inicio-enlace">Ir a ventas →</span>
                </a>
                <a href="<%: ResolveUrl("~/Contabilidad.aspx") %>" class="inicio-modulo">
                    <span class="inicio-icono" aria-hidden="true">▤</span>
                    <h3>Contabilidad</h3>
                    <p>Consulta asientos, cuentas por pagar y por cobrar, y reportes.</p>
                    <span class="inicio-enlace">Ir a contabilidad →</span>
                </a>
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
