<%@ Page Title="Punto de Venta" Language="C#" MasterPageFile="~/Contabilidad.Master" AutoEventWireup="true" CodeBehind="Ventas.aspx.cs" Inherits="trabajo_ing_software.Ventas" %>
<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">

    <div class="card-dermocosmetica" style="max-width: 1100px; margin: 40px auto;">
    
    <div style="display: flex; justify-content: space-between; align-items: flex-start;">
        <div>
            <h2 class="titulo-elegante" style="margin-top: 0;">Punto de Venta</h2>
            <p style="color: var(--color-secundario); margin-bottom: 25px; font-size: 13px; letter-spacing: 1px;">MÓDULO DE VENTAS • TRANSACCIONES</p>
        </div>
        
        <asp:Button ID="btnIrReporte" runat="server" Text="Ver Reportes" CssClass="btn btn-outline-secondary" style="padding: 8px 16px; font-size: 14px;" OnClick="btnIrReporte_Click" />
    </div>
    
    <div style="display: flex; gap: 40px; flex-wrap: wrap;">
            
            <div style="flex: 1; min-width: min(100%, 280px);">
                <label style="font-weight: 600; color: var(--color-acento); font-size: 14px; margin-bottom: 8px; display: block;">1. Seleccionar Cliente:</label>
                <asp:DropDownList ID="ddlClientes" runat="server" CssClass="form-select"></asp:DropDownList>
                <asp:Label runat="server" AssociatedControlID="ddlBodega" CssClass="form-label mt-3">Bodega de salida</asp:Label>
                <asp:DropDownList ID="ddlBodega" runat="server" CssClass="form-select" />
                <p class="form-text">Se utilizan primero los lotes con vencimiento más próximo.</p>
                <asp:Label runat="server" AssociatedControlID="ddlPago" CssClass="form-label">Forma de pago</asp:Label>
                <asp:DropDownList ID="ddlPago" runat="server" CssClass="form-select">
                    <asp:ListItem Value="contado">Contado</asp:ListItem>
                    <asp:ListItem Value="credito">Crédito</asp:ListItem>
                </asp:DropDownList>
                <asp:Label runat="server" AssociatedControlID="txtVence" CssClass="form-label mt-3">Vencimiento si es a crédito</asp:Label>
                <asp:TextBox ID="txtVence" runat="server" TextMode="Date" CssClass="form-control" />
                
                <hr style="border: 0; border-top: 1px solid #e5e0d8; margin: 25px 0;" />
                
                <label style="font-weight: 600; color: var(--color-acento); font-size: 14px; margin-bottom: 8px; display: block;">2. Buscar Producto:</label>
                <asp:DropDownList ID="ddlProductos" runat="server" CssClass="form-select"></asp:DropDownList>
                
                <label style="font-weight: 600; color: var(--color-acento); font-size: 14px; margin-bottom: 8px; display: block;">Cantidad:</label>
                <asp:TextBox ID="txtCantidad" runat="server" CssClass="form-control" TextMode="Number" Text="1"></asp:TextBox>
                
                <asp:Button ID="btnAgregar" runat="server" Text="Agregar al Carrito" CssClass="btn btn-outline-secondary" style="width: 100%; margin-top: 10px;" OnClick="btnAgregar_Click" />
            </div>

           <div style="flex: 2; min-width: min(100%, 360px); background: #faf8f5; padding: 25px; border-radius: 15px; border: 1px solid #e5e0d8;">
                <h3 class="titulo-elegante" style="font-size: 18px; margin-top: 0;">Detalle de la Venta</h3>
                
                <asp:GridView ID="gvCarrito" runat="server" CssClass="table table-hover" AutoGenerateColumns="False" GridLines="None" OnRowCommand="gvCarrito_RowCommand">
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

                <div style="text-align: right; margin-top: 25px;">
                    <h3 class="titulo-elegante" style="font-size: 24px; margin-bottom: 15px;">Total: <asp:Label ID="lblTotal" runat="server" Text="$0"></asp:Label></h3>
                    <asp:Button ID="btnFinalizarVenta" runat="server" Text="Finalizar Venta" CssClass="btn btn-primary" OnClick="btnFinalizarVenta_Click" />
                    <br />
                    <asp:Label ID="lblMensajeVenta" runat="server" style="display:block; margin-top:15px; font-weight:600;"></asp:Label>
                </div>
            </div>
            
        </div>
    </div>
</asp:Content>
