<%@ Page Title="Punto de Venta" Language="C#" MasterPageFile="~/Contabilidad.Master" AutoEventWireup="true" CodeBehind="Ventas.aspx.cs" Inherits="trabajo_ing_software.Ventas" ResponseEncoding="utf-8" %>

<asp:Content ID="Estilos" ContentPlaceHolderID="EstilosPagina" runat="server">
    <link href="<%: ResolveUrl("~/Content/ComprasResumen.css?v=1") %>" rel="stylesheet" />
    <link href="<%: ResolveUrl("~/Content/Estilos.css") %>" rel="stylesheet" type="text/css" />
</asp:Content>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <div class="dashboard compras-resumen">
        
        <header class="dashboard-header">
            <div>
                <p class="dashboard-etiqueta">Módulo de ventas · Transacciones</p>
                <h1>Punto de Venta</h1>
                <p class="dashboard-descripcion">Registro de ventas, selección de lotes por vencimiento y facturación.</p>
            </div>
            <!-- Botón oculto porque ya existe en el menú lateral -->
            <div class="d-none">
                <asp:Button ID="btnIrReporte" runat="server" Text="Ver Reportes" OnClick="btnIrReporte_Click" />
            </div>
        </header>

        <div class="compras-paneles">
            <!-- TARJETA IZQUIERDA: FORMULARIO DE CARGA -->
            <section class="card-dermocosmetica">
                <h2 style="margin-bottom: 16px;">1. Datos de la Operación</h2>
                
                <div class="mb-3">
                    <label class="form-label fw-bold text-secondary">Seleccionar Cliente</label>
                    <asp:DropDownList ID="ddlClientes" runat="server" CssClass="form-select"></asp:DropDownList>
                </div>

                <div class="mb-3">
                    <asp:Label runat="server" AssociatedControlID="ddlBodega" CssClass="form-label fw-bold text-secondary">Bodega de salida</asp:Label>
                    <asp:DropDownList ID="ddlBodega" runat="server" CssClass="form-select" />
                    <p class="compras-nota" style="margin-top: 4px; margin-bottom: 0;">Se utilizan primero los lotes con vencimiento más próximo.</p>
                </div>

                <div class="row g-3 mb-3">
                    <div class="col-md-6">
                        <asp:Label runat="server" AssociatedControlID="ddlPago" CssClass="form-label fw-bold text-secondary">Forma de pago</asp:Label>
                        <asp:DropDownList ID="ddlPago" runat="server" CssClass="form-select">
                            <asp:ListItem Value="contado">Contado</asp:ListItem>
                            <asp:ListItem Value="credito">Crédito</asp:ListItem>
                        </asp:DropDownList>
                    </div>
                    <div class="col-md-6">
                        <asp:Label runat="server" AssociatedControlID="txtVence" CssClass="form-label fw-bold text-secondary">Vencimiento si es a crédito</asp:Label>
                        <asp:TextBox ID="txtVence" runat="server" TextMode="Date" CssClass="form-control" />
                    </div>
                </div>

                <hr style="border: 0; border-top: 1px solid #e5e0d8; margin: 24px 0;" />

                <h2 style="margin-bottom: 16px;">2. Buscar Producto</h2>
                
                <div class="row g-3 align-items-end">
                    <div class="col-md-8">
                        <label class="form-label fw-bold text-secondary">Producto / SKU</label>
                        <asp:DropDownList ID="ddlProductos" runat="server" CssClass="form-select"></asp:DropDownList>
                    </div>
                    <div class="col-md-4">
                        <label class="form-label fw-bold text-secondary">Cantidad</label>
                        <asp:TextBox ID="txtCantidad" runat="server" CssClass="form-control" TextMode="Number" Text="1"></asp:TextBox>
                    </div>
                    <div class="col-12 mt-3">
                        <asp:Button ID="btnAgregar" runat="server" Text="Agregar al Carrito" CssClass="btn btn-primary" OnClick="btnAgregar_Click" />
                    </div>
                </div>
            </section>

            <!-- TARJETA DERECHA: CARRITO Y TOTAL -->
            <section class="card-dermocosmetica">
                <h2 style="margin-bottom: 6px;">Detalle de la Venta</h2>
                <p class="compras-nota" style="margin-bottom: 16px;">Productos agregados a la transacción actual</p>
                
                <div class="table-responsive">
                    <asp:GridView ID="gvCarrito" runat="server" CssClass="table table-hover" AutoGenerateColumns="False" GridLines="None" OnRowCommand="gvCarrito_RowCommand" EmptyDataText="Aún no hay productos en el carrito.">
                        <Columns>
                            <asp:BoundField DataField="Nombre" HeaderText="Producto" />
                            <asp:BoundField DataField="Precio" HeaderText="Precio" DataFormatString="${0:N0}" />
                            <asp:BoundField DataField="Cantidad" HeaderText="Cant." />
                            <asp:BoundField DataField="Subtotal" HeaderText="Subtotal" DataFormatString="${0:N0}" />
                            <asp:TemplateField>
                                <ItemTemplate>
                                    <asp:Button ID="btnQuitar" runat="server" CommandName="Quitar" CommandArgument='<%# Container.DataItemIndex %>' Text="Quitar" CssClass="btn btn-outline-secondary btn-sm" />
                                </ItemTemplate>
                            </asp:TemplateField>
                        </Columns>
                    </asp:GridView>
                </div>

                <div style="text-align: right; margin-top: 24px; border-top: 1px solid #e5e0d8; padding-top: 20px;">
                    <h3 style="font-family: 'Playfair Display', Georgia, serif; font-size: 26px; margin-bottom: 16px;">
                        Total: <asp:Label ID="lblTotal" runat="server" Text="$0"></asp:Label>
                    </h3>
                    <asp:Button ID="btnFinalizarVenta" runat="server" Text="Finalizar Venta" CssClass="btn btn-primary" OnClick="btnFinalizarVenta_Click" />
                    <asp:Label ID="lblMensajeVenta" runat="server" style="display:block; margin-top:12px; font-weight:600;"></asp:Label>
                </div>
            </section>
        </div>

    </div>
</asp:Content>