<%@ Page Title="Devoluciones" Language="C#" MasterPageFile="~/Contabilidad.Master" AutoEventWireup="true" CodeBehind="Devoluciones.aspx.cs" Inherits="trabajo_ing_software.Devoluciones" %>

<asp:Content ID="Content1" ContentPlaceHolderID="EstilosPagina" runat="server">
    <link rel="preconnect" href="https://fonts.googleapis.com" />
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin="anonymous" />
    <link href="https://fonts.googleapis.com/css2?family=Playfair+Display:ital,wght@0,500;0,600;0,700;1,400;1,500;1,600&family=Plus+Jakarta+Sans:wght@300;400;500;600;700&display=swap" rel="stylesheet" />
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    
    <div class="card-dermo-luxury" style="max-width: 1200px; margin: 30px auto;">
        
        <div style="margin-bottom: 25px;">
            <span class="pill-badge" style="margin-bottom: 8px;">M&oacute;dulo de Ventas &bull; Servicio al Cliente</span>
            <h1 style="font-size: 28px; margin: 4px 0 6px 0; font-family: 'Playfair Display', serif;">Notas de Cr&eacute;dito y Devoluciones</h1>
            <p class="text-muted" style="margin: 0;">Reversas contables y gesti&oacute;n de devoluciones de clientes.</p>
        </div>

        <div style="background-color: var(--color-blanco); border-radius: 20px; border: 1px solid var(--color-borde-suave); padding: 30px; margin-bottom: 30px;">
            <h3 style="font-size: 18px; margin: 0 0 20px 0; font-family: 'Playfair Display', serif;">Registrar Nueva Devoluci&oacute;n</h3>
            
            <div class="row g-3">
                <div class="col-md-4">
                    <label class="form-label fw-bold text-secondary">N&deg; Venta / Boleta Original</label>
                    <asp:DropDownList ID="ddlVentaOrigen" runat="server" CssClass="form-select" AutoPostBack="true"></asp:DropDownList>
                </div>
                <div class="col-md-4">
                    <label class="form-label fw-bold text-secondary">Cliente Afectado</label>
                    <asp:TextBox ID="txtCliente" runat="server" CssClass="form-control" ReadOnly="true" Placeholder="Se carga autom&aacute;tico..."></asp:TextBox>
                </div>
                <div class="col-md-4">
                    <label class="form-label fw-bold text-secondary">Total Original de la Venta</label>
                    <asp:TextBox ID="txtTotalVenta" runat="server" CssClass="form-control" ReadOnly="true" Placeholder="$ 0"></asp:TextBox>
                </div>

                <div class="col-12 mt-4">
                    <h6 class="text-secondary fw-bold border-bottom pb-2">Motivo y Detalles</h6>
                </div>
                <div class="col-md-4">
                    <label class="form-label">Tipo de Devoluci&oacute;n</label>
                    <asp:DropDownList ID="ddlTipoDevolucion" runat="server" CssClass="form-select">
                        <asp:ListItem Text="Devoluci&oacute;n Total (Nota de Cr&eacute;dito)" Value="Total"></asp:ListItem>
                        <asp:ListItem Text="Devoluci&oacute;n Parcial" Value="Parcial"></asp:ListItem>
                    </asp:DropDownList>
                </div>
                <div class="col-md-8">
                    <label class="form-label">Motivo (Observaci&oacute;n)</label>
                    <asp:TextBox ID="txtMotivo" runat="server" CssClass="form-control" Placeholder="Ej: Producto da&ntilde;ado en el traslado..."></asp:TextBox>
                </div>

                <div class="col-12 text-end mt-4">
                    <asp:Button ID="btnGuardarDevolucion" runat="server" Text="Generar Nota de Cr&eacute;dito" CssClass="btn-dermo-primary" style="background-color: #d9534f; border-color: #d43f3a;" OnClick="btnGuardarDevolucion_Click" />
                </div>
            </div>
        </div>

        <div style="background-color: var(--color-blanco); border-radius: 20px; border: 1px solid var(--color-borde-suave); padding: 30px;">
            <h3 style="font-size: 18px; margin: 0 0 20px 0; font-family: 'Playfair Display', serif;">Historial de Notas de Cr&eacute;dito</h3>
            <div class="table-dermo-container">
                <asp:GridView ID="gvDevoluciones" runat="server" CssClass="table-dermo-modern" AutoGenerateColumns="False" GridLines="None">
                    <Columns>
                        <asp:BoundField DataField="IdNotaCredito" HeaderText="ID N.C." />
                        <asp:BoundField DataField="IdVenta" HeaderText="Venta Ref." />
                        <asp:BoundField DataField="Cliente" HeaderText="Cliente" />
                        <asp:BoundField DataField="Fecha" HeaderText="Fecha" DataFormatString="{0:dd/MM/yyyy}" />
                        <asp:BoundField DataField="TotalDevuelto" HeaderText="Total Devuelto ($)" DataFormatString="{0:N0}" />
                    </Columns>
                    <EmptyDataTemplate>
                        <div class="text-center text-muted" style="padding: 15px;">No hay devoluciones registradas.</div>
                    </EmptyDataTemplate>
                </asp:GridView>
            </div>
        </div>
    </div>
</asp:Content>