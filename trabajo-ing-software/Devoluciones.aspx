<%@ Page Title="Notas de Crédito y Devoluciones" Language="C#" MasterPageFile="~/Contabilidad.Master" AutoEventWireup="true" CodeBehind="Devoluciones.aspx.cs" Inherits="trabajo_ing_software.Devoluciones" ResponseEncoding="utf-8" %>

<asp:Content ID="Estilos" ContentPlaceHolderID="EstilosPagina" runat="server">
    <link href="<%: ResolveUrl("~/Content/ComprasResumen.css?v=1") %>" rel="stylesheet" />
    <style>
        .card-dermocosmetica h2 { font-size: 1.25rem; font-weight: 600; margin-bottom: 14px; }
        .card-dermocosmetica h3 { font-size: 1.05rem; font-weight: 600; margin-bottom: 12px; color: #24211e; }
        .form-label { font-size: 0.875rem; font-weight: 500; color: #24211e; margin-bottom: 6px; }
        .table { font-size: 0.85rem; }
        .table th { font-size: 0.85rem; }
        .table td { font-size: 0.85rem; }
        .badge-nc { background-color: #FDEDEC; color: #C0392B; padding: 4px 10px; border-radius: 12px; font-weight: 600; font-size: 12px; }
        .badge-reingreso-si { background-color: #E8F8F0; color: #27AE60; padding: 4px 10px; border-radius: 12px; font-weight: 600; font-size: 12px; }
        .badge-reingreso-no { background-color: #F8F9FA; color: #6C757D; padding: 4px 10px; border-radius: 12px; font-weight: 600; font-size: 12px; }
    </style>
</asp:Content>

<asp:Content ID="Contenido" ContentPlaceHolderID="MainContent" runat="server">
    <div class="dashboard compras-resumen">
        
        <header class="dashboard-header">
            <div>
                <p class="dashboard-etiqueta">Módulo de ventas · Devoluciones y notas de crédito</p>
                <h1>Notas de Crédito y Devoluciones</h1>
                <p class="dashboard-descripcion">Emisión de notas de crédito totales o parciales con opción de reingreso al inventario.</p>
            </div>
        </header>

        <!-- TARJETA 1: FORMULARIO -->
        <section class="card-dermocosmetica" style="margin-bottom: 24px;">
            <h2 style="margin-bottom: 16px;">1. Seleccionar Venta Original</h2>
            
            <div class="row g-3">
                <div class="col-md-5">
                    <label class="form-label">Venta de Origen (Boleta / Factura) *</label>
                    <asp:DropDownList ID="ddlVentaOrigen" runat="server" CssClass="form-select" AutoPostBack="true"></asp:DropDownList>
                </div>
                <div class="col-md-4">
                    <label class="form-label">Cliente</label>
                    <asp:TextBox ID="txtCliente" runat="server" CssClass="form-control" ReadOnly="true" Placeholder="Se carga automático..."></asp:TextBox>
                </div>
                <div class="col-md-3">
                    <label class="form-label">Total Venta Original</label>
                    <asp:TextBox ID="txtTotalVenta" runat="server" CssClass="form-control" ReadOnly="true" Placeholder="$ 0"></asp:TextBox>
                </div>

                <div class="col-md-4">
                    <label class="form-label">Modalidad de Devolución</label>
                    <asp:DropDownList ID="ddlTipoDevolucion" runat="server" CssClass="form-select" AutoPostBack="true" OnSelectedIndexChanged="ddlTipoDevolucion_SelectedIndexChanged">
                        <asp:ListItem Text="Devolución Total (Toda la Venta)" Value="Total"></asp:ListItem>
                        <asp:ListItem Text="Devolución Parcial (Seleccionar cantidades)" Value="Parcial"></asp:ListItem>
                    </asp:DropDownList>
                </div>
                <div class="col-md-8">
                    <label class="form-label">Motivo de la Devolución *</label>
                    <asp:TextBox ID="txtMotivo" runat="server" CssClass="form-control" Placeholder="Ej: Producto con empaque dañado, cambio de producto o insatisfacción..."></asp:TextBox>
                </div>
            </div>

            <!-- TABLA DE PRODUCTOS PARA SELECCIONAR DEVOLUCIÓN TOTAL O PARCIAL (RF-VEN-09) -->
            <div class="mt-4">
                <h6 class="text-secondary fw-bold border-bottom pb-2">2. Detalle de Ítems a Devolver</h6>
                <div class="table-responsive">
                    <asp:GridView ID="gvItemsVenta" runat="server" CssClass="table table-hover" AutoGenerateColumns="False" GridLines="None" EmptyDataText="Seleccione una venta para listar los productos adquiridos.">
                        <Columns>
                            <asp:BoundField DataField="IdVariante" HeaderText="ID SKU" />
                            <asp:BoundField DataField="Producto" HeaderText="Producto / Variante" />
                            <asp:BoundField DataField="CantidadOriginal" HeaderText="Cant. Vendida" />
                            <asp:BoundField DataField="PrecioUnitario" HeaderText="Precio Unit." DataFormatString="${0:N0}" />
                            <asp:TemplateField HeaderText="Cant. a Devolver">
                                <ItemTemplate>
                                    <asp:HiddenField ID="hfIdVariante" runat="server" Value='<%# Eval("IdVariante") %>' />
                                    <asp:HiddenField ID="hfPrecioUnitario" runat="server" Value='<%# Eval("PrecioUnitario") %>' />
                                    <asp:HiddenField ID="hfCantOriginal" runat="server" Value='<%# Eval("CantidadOriginal") %>' />
                                    <asp:TextBox ID="txtCantDevolver" runat="server" CssClass="form-control form-control-sm" TextMode="Number" Text='<%# Eval("CantidadDevolver") %>' style="width: 100px;"></asp:TextBox>
                                </ItemTemplate>
                            </asp:TemplateField>
                        </Columns>
                    </asp:GridView>
                </div>
            </div>

            <!-- CONTROL DE REINGRESO AL INVENTARIO (RF-VEN-09) -->
            <div class="mt-4 p-3" style="background-color: #faf8f5; border: 1px solid #e5e0d8; border-radius: 8px;">
                <h3 style="font-size: 1.05rem; font-weight: 600; margin-bottom: 12px; color: #24211e;">3. Reingreso al Inventario (Opcional)</h3>
                <div class="row g-3 align-items-center">
                    <div class="col-md-6">
                        <div class="form-check form-switch">
                            <asp:CheckBox ID="chkReingresoInventario" runat="server" CssClass="form-check-input" Checked="true" AutoPostBack="true" OnCheckedChanged="chkReingresoInventario_CheckedChanged" />
                            <label class="form-check-label" style="font-size: 0.875rem; font-weight: 500; color: #24211e;" for="<%= chkReingresoInventario.ClientID %>">
                                Reingresar físicamente los productos devueltos a la bodega
                            </label>
                        </div>
                        <small class="text-muted d-block mt-1">Si está marcado, se incrementará el stock y se registrará un movimiento de inventario de entrada.</small>
                    </div>
                    <div class="col-md-6" id="secBodegaReingreso" runat="server">
                        <label class="form-label">Bodega de Destino</label>
                        <asp:DropDownList ID="ddlBodegaReingreso" runat="server" CssClass="form-select"></asp:DropDownList>
                    </div>
                </div>
            </div>

            <div class="col-12 text-end mt-4 d-flex justify-content-between align-items-center">
                <div>
                    <asp:Label ID="lblMensajeDevolucion" runat="server" style="font-weight:600;"></asp:Label>
                </div>
                <div>
                    <asp:Button ID="btnGuardarDevolucion" runat="server" Text="Generar Nota de Crédito" CssClass="btn btn-primary" OnClick="btnGuardarDevolucion_Click" />
                </div>
            </div>
        </section>

        <!-- TARJETA 2: HISTORIAL -->
        <section class="card-dermocosmetica">
            <h2 style="margin-bottom: 16px;">Historial de Notas de Crédito Registradas</h2>
            <div class="table-responsive">
                <asp:GridView ID="gvDevoluciones" runat="server" CssClass="table table-hover" AutoGenerateColumns="False" GridLines="None" EmptyDataText="No hay devoluciones registradas.">
                    <Columns>
                        <asp:BoundField DataField="IdNotaCredito" HeaderText="ID N.C." />
                        <asp:BoundField DataField="Folio" HeaderText="Folio N.C." NullDisplayText="—" />
                        <asp:BoundField DataField="VentaRef" HeaderText="Doc. Original" />
                        <asp:BoundField DataField="Cliente" HeaderText="Cliente" />
                        <asp:BoundField DataField="Fecha" HeaderText="Fecha Emisión" DataFormatString="{0:dd/MM/yyyy}" />
                        <asp:BoundField DataField="TotalDevuelto" HeaderText="Total Devuelto" DataFormatString="${0:N0}" />
                        <asp:TemplateField HeaderText="Tipo">
                            <ItemTemplate>
                                <span class="badge-nc">Nota de Crédito</span>
                            </ItemTemplate>
                        </asp:TemplateField>
                    </Columns>
                </asp:GridView>
            </div>
        </section>

    </div>
</asp:Content>
