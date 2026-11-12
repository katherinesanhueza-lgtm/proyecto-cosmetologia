<%@ Page Title="Devoluciones" Language="C#" MasterPageFile="~/Contabilidad.Master" AutoEventWireup="true" CodeBehind="Devoluciones.aspx.cs" Inherits="trabajo_ing_software.Devoluciones" ResponseEncoding="utf-8" %>

<asp:Content ID="Estilos" ContentPlaceHolderID="EstilosPagina" runat="server">
    <link href="<%: ResolveUrl("~/Content/ComprasResumen.css?v=1") %>" rel="stylesheet" />
    <link href="<%: ResolveUrl("~/Content/Estilos.css") %>" rel="stylesheet" type="text/css" />
</asp:Content>

<asp:Content ID="Contenido" ContentPlaceHolderID="MainContent" runat="server">
    <div class="dashboard compras-resumen">
        
        <header class="dashboard-header">
            <div>
                <p class="dashboard-etiqueta">Módulo de ventas · Servicio al cliente</p>
                <h1>Notas de Crédito y Devoluciones</h1>
                <p class="dashboard-descripcion">Reversas contables y gestión de devoluciones de clientes.</p>
            </div>
        </header>

        <!-- TARJETA 1: FORMULARIO -->
        <section class="card-dermocosmetica" style="margin-bottom: 24px;">
            <h2 style="margin-bottom: 16px;">Registrar Nueva Devolución</h2>
            
            <div class="row g-3">
                <div class="col-md-4">
                    <label class="form-label fw-bold text-secondary">N° Venta / Boleta Original</label>
                    <asp:DropDownList ID="ddlVentaOrigen" runat="server" CssClass="form-select" AutoPostBack="true"></asp:DropDownList>
                </div>
                <div class="col-md-4">
                    <label class="form-label fw-bold text-secondary">Cliente Afectado</label>
                    <asp:TextBox ID="txtCliente" runat="server" CssClass="form-control" ReadOnly="true" Placeholder="Se carga automático..."></asp:TextBox>
                </div>
                <div class="col-md-4">
                    <label class="form-label fw-bold text-secondary">Total Original de la Venta</label>
                    <asp:TextBox ID="txtTotalVenta" runat="server" CssClass="form-control" ReadOnly="true" Placeholder="$ 0"></asp:TextBox>
                </div>

                <div class="col-md-4">
                    <label class="form-label fw-bold text-secondary">Tipo de Devolución</label>
                    <asp:DropDownList ID="ddlTipoDevolucion" runat="server" CssClass="form-select">
                        <asp:ListItem Text="Devolución Total (Nota de Crédito)" Value="Total"></asp:ListItem>
                        <asp:ListItem Text="Devolución Parcial" Value="Parcial"></asp:ListItem>
                    </asp:DropDownList>
                </div>
                <div class="col-md-8">
                    <label class="form-label fw-bold text-secondary">Motivo (Observación)</label>
                    <asp:TextBox ID="txtMotivo" runat="server" CssClass="form-control" Placeholder="Ej: Producto dañado en el traslado..."></asp:TextBox>
                </div>

                <div class="col-12 text-end mt-4">
                    <asp:Button ID="btnGuardarDevolucion" runat="server" Text="Generar Nota de Crédito" CssClass="btn-dermo-primary" OnClick="btnGuardarDevolucion_Click" />
                </div>
            </div>
        </section>

        <!-- TARJETA 2: HISTORIAL -->
        <section class="card-dermocosmetica">
            <h2 style="margin-bottom: 16px;">Historial de Notas de Crédito</h2>
            <div class="table-responsive">
                <asp:GridView ID="gvDevoluciones" runat="server" CssClass="table table-hover" AutoGenerateColumns="False" GridLines="None" EmptyDataText="No hay devoluciones registradas.">
                    <Columns>
                        <asp:BoundField DataField="IdNotaCredito" HeaderText="ID N.C." />
                        <asp:BoundField DataField="IdVenta" HeaderText="Venta Ref." />
                        <asp:BoundField DataField="Cliente" HeaderText="Cliente" />
                        <asp:BoundField DataField="Fecha" HeaderText="Fecha" DataFormatString="{0:dd/MM/yyyy}" />
                        <asp:BoundField DataField="TotalDevuelto" HeaderText="Total Devuelto ($)" DataFormatString="{0:N0}" />
                    </Columns>
                </asp:GridView>
            </div>
        </section>

    </div>
</asp:Content>