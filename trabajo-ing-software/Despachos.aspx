<%@ Page Title="Despachos" Language="C#" MasterPageFile="~/Contabilidad.Master" AutoEventWireup="true" CodeBehind="Despachos.aspx.cs" Inherits="trabajo_ing_software.Despachos" ResponseEncoding="utf-8" %>

<asp:Content ID="Estilos" ContentPlaceHolderID="EstilosPagina" runat="server">
    <link href="<%: ResolveUrl("~/Content/ComprasResumen.css?v=1") %>" rel="stylesheet" />
    <link href="<%: ResolveUrl("~/Content/Estilos.css") %>" rel="stylesheet" type="text/css" />
</asp:Content>

<asp:Content ID="Contenido" ContentPlaceHolderID="MainContent" runat="server">
    <div class="dashboard compras-resumen">
        
        <header class="dashboard-header">
            <div>
                <p class="dashboard-etiqueta">Módulo de ventas · Logística</p>
                <h1>Gestión de Despachos</h1>
                <p class="dashboard-descripcion">Administración de entregas, transportistas y estados de ruta.</p>
            </div>
        </header>

        <!-- TARJETA 1: FORMULARIO -->
        <section class="card-dermocosmetica" style="margin-bottom: 24px;">
            <h2 style="margin-bottom: 16px;">Registrar Nuevo Despacho</h2>
            
            <div class="row g-3">
                <div class="col-md-4">
                    <label class="form-label fw-bold text-secondary">N° Cotización / Venta</label>
                    <asp:DropDownList ID="ddlDocumentoOrigen" runat="server" CssClass="form-select" AutoPostBack="true"></asp:DropDownList>
                </div>
                <div class="col-md-4">
                    <label class="form-label fw-bold text-secondary">Cliente</label>
                    <asp:TextBox ID="txtCliente" runat="server" CssClass="form-control" ReadOnly="true" Placeholder="Se llena automático..."></asp:TextBox>
                </div>
                <div class="col-md-4">
                    <label class="form-label fw-bold text-secondary">Estado del Despacho</label>
                    <asp:DropDownList ID="ddlEstadoDespacho" runat="server" CssClass="form-select">
                        <asp:ListItem Text="Pendiente" Value="Pendiente"></asp:ListItem>
                        <asp:ListItem Text="En Preparación" Value="En Preparacion"></asp:ListItem>
                        <asp:ListItem Text="En Ruta" Value="En Ruta"></asp:ListItem>
                        <asp:ListItem Text="Entregado" Value="Entregado"></asp:ListItem>
                    </asp:DropDownList>
                </div>

                <div class="col-md-6">
                    <label class="form-label fw-bold text-secondary">Fecha Estimada de Entrega</label>
                    <asp:TextBox ID="txtFechaEstimada" runat="server" CssClass="form-control" TextMode="Date"></asp:TextBox>
                </div>
                <div class="col-md-6">
                    <label class="form-label fw-bold text-secondary">Tipo de Despacho / Transportista</label>
                    <asp:DropDownList ID="ddlTransportista" runat="server" CssClass="form-select">
                        <asp:ListItem Text="-- Seleccione --" Value=""></asp:ListItem>
                        <asp:ListItem Text="Starken" Value="Starken"></asp:ListItem>
                        <asp:ListItem Text="Chilexpress" Value="Chilexpress"></asp:ListItem>
                        <asp:ListItem Text="Reparto Propio" Value="Reparto Propio"></asp:ListItem>
                    </asp:DropDownList>
                </div>

                <div class="col-12 text-end mt-4">
                    <asp:Button ID="btnGuardarDespacho" runat="server" Text="Guardar Despacho" CssClass="btn-dermo-primary" OnClick="btnGuardarDespacho_Click" />
                </div>
            </div>
        </section>

        <!-- TARJETA 2: HISTORIAL -->
        <section class="card-dermocosmetica">
            <h2 style="margin-bottom: 16px;">Despachos Activos</h2>
            <div class="table-responsive">
                <asp:GridView ID="gvDespachos" runat="server" CssClass="table table-hover" AutoGenerateColumns="False" GridLines="None" EmptyDataText="No hay despachos registrados.">
                    <Columns>
                        <asp:BoundField DataField="IdDespacho" HeaderText="ID" />
                        <asp:BoundField DataField="IdVenta" HeaderText="Venta N°" />
                        <asp:BoundField DataField="Cliente" HeaderText="Cliente" />
                        <asp:BoundField DataField="Tipo" HeaderText="Transportista" />
                        <asp:BoundField DataField="FechaEstimada" HeaderText="Fecha Estimada" DataFormatString="{0:dd/MM/yyyy}" />
                        <asp:BoundField DataField="Estado" HeaderText="Estado" />
                    </Columns>
                </asp:GridView>
            </div>
        </section>

    </div>
</asp:Content>