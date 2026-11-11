<%@ Page Title="Despachos" Language="C#" MasterPageFile="~/Contabilidad.Master" AutoEventWireup="true" CodeBehind="Despachos.aspx.cs" Inherits="trabajo_ing_software.Despachos" %>

<asp:Content ID="Content1" ContentPlaceHolderID="EstilosPagina" runat="server">
    <link rel="preconnect" href="https://fonts.googleapis.com" />
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin="anonymous" />
    <link href="https://fonts.googleapis.com/css2?family=Playfair+Display:ital,wght@0,500;0,600;0,700;1,400;1,500;1,600&family=Plus+Jakarta+Sans:wght@300;400;500;600;700&display=swap" rel="stylesheet" />
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    
    <div class="card-dermo-luxury" style="max-width: 1200px; margin: 30px auto;">
        
        <div style="margin-bottom: 25px;">
            <span class="pill-badge" style="margin-bottom: 8px;">M&oacute;dulo de Log&iacute;stica &bull; Env&iacute;os</span>
            <h1 style="font-size: 28px; margin: 4px 0 6px 0; font-family: 'Playfair Display', serif;">Gesti&oacute;n de Despachos</h1>
            <p class="text-muted" style="margin: 0;">Administraci&oacute;n de entregas y estados de ruta.</p>
        </div>

        <div style="background-color: var(--color-blanco); border-radius: 20px; border: 1px solid var(--color-borde-suave); padding: 30px; margin-bottom: 30px;">
            <h3 style="font-size: 18px; margin: 0 0 20px 0; font-family: 'Playfair Display', serif;">Registrar Nuevo Despacho</h3>
            
            <div class="row g-3">
                <div class="col-md-4">
                    <label class="form-label fw-bold text-secondary">N&deg; Cotizaci&oacute;n / Venta</label>
                    <asp:DropDownList ID="ddlDocumentoOrigen" runat="server" CssClass="form-select" AutoPostBack="true"></asp:DropDownList>
                </div>
                <div class="col-md-4">
                    <label class="form-label fw-bold text-secondary">Cliente</label>
                    <asp:TextBox ID="txtCliente" runat="server" CssClass="form-control" ReadOnly="true" Placeholder="Se llena autom&aacute;tico..."></asp:TextBox>
                </div>
                <div class="col-md-4">
                    <label class="form-label fw-bold text-secondary">Estado del Despacho</label>
                    <asp:DropDownList ID="ddlEstadoDespacho" runat="server" CssClass="form-select">
                        <asp:ListItem Text="Pendiente" Value="Pendiente"></asp:ListItem>
                        <asp:ListItem Text="En Preparaci&oacute;n" Value="En Preparacion"></asp:ListItem>
                        <asp:ListItem Text="En Ruta" Value="En Ruta"></asp:ListItem>
                        <asp:ListItem Text="Entregado" Value="Entregado"></asp:ListItem>
                    </asp:DropDownList>
                </div>

                <div class="col-12 mt-3">
                    <h6 class="text-secondary fw-bold border-bottom pb-2">Datos de Entrega</h6>
                </div>
                <div class="col-md-6">
                    <label class="form-label">Fecha Estimada de Entrega</label>
                    <asp:TextBox ID="txtFechaEstimada" runat="server" CssClass="form-control" TextMode="Date"></asp:TextBox>
                </div>
                <div class="col-md-6">
                    <label class="form-label">Tipo de Despacho / Transportista</label>
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
        </div>

        <div style="background-color: var(--color-blanco); border-radius: 20px; border: 1px solid var(--color-borde-suave); padding: 30px;">
            <h3 style="font-size: 18px; margin: 0 0 20px 0; font-family: 'Playfair Display', serif;">Despachos Activos</h3>
            <div class="table-dermo-container">
                <asp:GridView ID="gvDespachos" runat="server" CssClass="table-dermo-modern" AutoGenerateColumns="False" GridLines="None">
                    <Columns>
                        <asp:BoundField DataField="IdDespacho" HeaderText="ID" />
                        <asp:BoundField DataField="IdVenta" HeaderText="Venta N&deg;" />
                        <asp:BoundField DataField="Cliente" HeaderText="Cliente" />
                        <asp:BoundField DataField="Tipo" HeaderText="Transportista" />
                        <asp:BoundField DataField="FechaEstimada" HeaderText="Fecha Estimada" DataFormatString="{0:dd/MM/yyyy}" />
                        <asp:BoundField DataField="Estado" HeaderText="Estado" />
                    </Columns>
                    <EmptyDataTemplate>
                        <div class="text-center text-muted" style="padding: 15px;">No hay despachos registrados.</div>
                    </EmptyDataTemplate>
                </asp:GridView>
            </div>
        </div>
    </div>
</asp:Content>