<%@ Page Title="Inicio" Language="C#" MasterPageFile="~/Site.Master"
    AutoEventWireup="true" CodeBehind="Default.aspx.cs"
    Inherits="Cosmetologia._Default" %>

<asp:Content ID="BodyContent"
    ContentPlaceHolderID="MainContent"
    runat="server">

    <div class="dashboard">

        <!-- ==========================================
             ENCABEZADO
        =========================================== -->

        <div class="dashboard-header">

            <div>
                <p class="dashboard-etiqueta">
                    PANEL DE ADMINISTRACIÓN
                </p>

                <h1>Bienvenido a Dermo ERP</h1>

                <p class="dashboard-descripcion">
                    Gestión integral para las operaciones del sistema dermocosmético.
                </p>
            </div>

            <div class="dashboard-fecha">
                <span>Fecha</span>
                <asp:Label
                    ID="lblFecha"
                    runat="server">
                </asp:Label>
            </div>

        </div>


        <!-- ==========================================
             INDICADORES
        =========================================== -->

        <div class="dashboard-indicadores">

            <!-- PRODUCTOS -->

            <div class="card-dermocosmetica indicador-card">

                <div class="indicador-icono">
                    ▦
                </div>

                <div>
                    <span class="indicador-titulo">
                        Productos activos
                    </span>

                    <asp:Label
                        ID="lblProductos"
                        runat="server"
                        Text="0"
                        CssClass="indicador-valor">
                    </asp:Label>

                    <span class="indicador-detalle">
                        Registrados en el sistema
                    </span>
                </div>

            </div>


            <!-- STOCK BAJO -->

            <div class="card-dermocosmetica indicador-card">

                <div class="indicador-icono">
                    !
                </div>

                <div>
                    <span class="indicador-titulo">
                        Stock bajo
                    </span>

                    <asp:Label
                        ID="lblStockBajo"
                        runat="server"
                        Text="0"
                        CssClass="indicador-valor">
                    </asp:Label>

                    <span class="indicador-detalle">
                        Productos que requieren atención
                    </span>
                </div>

            </div>


            <!-- BODEGAS -->

            <div class="card-dermocosmetica indicador-card">

                <div class="indicador-icono">
                    □
                </div>

                <div>
                    <span class="indicador-titulo">
                        Bodegas activas
                    </span>

                    <asp:Label
                        ID="lblBodegas"
                        runat="server"
                        Text="0"
                        CssClass="indicador-valor">
                    </asp:Label>

                    <span class="indicador-detalle">
                        Puntos de almacenamiento
                    </span>
                </div>

            </div>

        </div>


        <!-- ==========================================
             ACCESOS RÁPIDOS
        =========================================== -->

        <section class="dashboard-seccion">

            <div class="dashboard-seccion-header">

                <div>
                    <h2>Accesos rápidos</h2>

                    <p>
                        Ingresa a los módulos disponibles del sistema.
                    </p>
                </div>

            </div>


            <div class="dashboard-modulos">

                <!-- INVENTARIO -->

                <a href="Inventario.aspx"
                   class="acceso-card">

                    <div class="acceso-icono">
                        ▦
                    </div>

                    <div>
                        <h3>Inventario</h3>

                        <p>
                            Consulta productos, existencias,
                            bodegas y niveles de stock.
                        </p>

                        <span class="acceso-link">
                            Ir al módulo →
                        </span>
                    </div>

                </a>


                <!-- REPORTE -->

                <a href="ReporteInventario.aspx"
                   class="acceso-card">

                    <div class="acceso-icono">
                        ▤
                    </div>

                    <div>
                        <h3>Reportes</h3>

                        <p>
                            Consulta el estado actual del
                            inventario y niveles de existencias.
                        </p>

                        <span class="acceso-link">
                            Ver reportes →
                        </span>
                    </div>

                </a>


                <!-- OTROS MÓDULOS -->

                <div class="acceso-card acceso-inactivo">

                    <div class="acceso-icono">
                        ◇
                    </div>

                    <div>
                        <h3>Otros módulos</h3>

                        <p>
                            Acceso a las demás áreas
                            administrativas del ERP.
                        </p>

                        <span class="acceso-link">
                            Próximamente
                        </span>
                    </div>

                </div>

            </div>

        </section>



<!-- ==========================================
     ESTADO DEL SISTEMA
=========================================== -->

<section class="dashboard-seccion">

    <div class="dashboard-seccion-header">
        <div>
            <h2>Estado del sistema</h2>
            <p>
                Información general de funcionamiento.
            </p>
        </div>
    </div>

    <div class="card-dermocosmetica estado-card">

        <asp:Panel
            ID="pnlEstado"
            runat="server"
            CssClass="estado-contenido">

            <div
                id="indicadorEstado"
                runat="server"
                class="estado-indicador">
            </div>

            <div>
                <strong>
                    <asp:Label
                        ID="lblEstadoSistema"
                        runat="server" />
                </strong>

                <p>
                    <asp:Label
                        ID="lblDescripcionEstado"
                        runat="server" />
                </p>
            </div>

        </asp:Panel>

    </div>

</section>

</div>

</asp:Content>
