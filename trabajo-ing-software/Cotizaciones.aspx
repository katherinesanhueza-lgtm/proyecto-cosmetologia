<%@ Page Title="Cotizaciones" Language="C#" MasterPageFile="~/Contabilidad.Master" AutoEventWireup="true" CodeBehind="Cotizaciones.aspx.cs" Inherits="trabajo_ing_software.Cotizaciones" %>

<asp:Content ID="Content1" ContentPlaceHolderID="EstilosPagina" runat="server">
    <link rel="preconnect" href="https://fonts.googleapis.com" />
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin="anonymous" />
    <link href="https://fonts.googleapis.com/css2?family=Playfair+Display:ital,wght@0,500;0,600;0,700;1,400;1,500;1,600&family=Plus+Jakarta+Sans:wght@300;400;500;600;700&display=swap" rel="stylesheet" />
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    
    <div class="card-dermo-luxury" style="max-width: 1200px; margin: 30px auto;">
        
        <!-- CABECERA -->
        <div style="margin-bottom: 25px;">
            <span class="pill-badge" style="margin-bottom: 8px;">M&oacute;dulo de Ventas &bull; Gesti&oacute;n Comercial</span>
            <h1 style="font-size: 28px; margin: 4px 0 6px 0; font-family: 'Playfair Display', serif;">Presupuestos y Cotizaciones</h1>
            <p class="text-muted" style="margin: 0;">Generaci&oacute;n de documentos comerciales y valorizaci&oacute;n de productos.</p>
        </div>

        <!-- FORMULARIO SUPERIOR -->
        <div style="background-color: var(--color-blanco); border-radius: 20px; border: 1px solid var(--color-borde-suave); padding: 30px; margin-bottom: 30px;">
            <h3 style="font-size: 18px; margin: 0 0 20px 0; font-family: 'Playfair Display', serif;">Generar Nueva Cotizaci&oacute;n</h3>
            
            <div class="row g-3">
                <div class="col-md-6">
                    <label class="form-label fw-bold text-secondary">Cliente</label>
                    <asp:DropDownList ID="ddlClientes" runat="server" CssClass="form-select"></asp:DropDownList>
                </div>
                <div class="col-md-6">
                    <label class="form-label fw-bold text-secondary">Estado</label>
                    <asp:DropDownList ID="ddlEstado" runat="server" CssClass="form-select">
                        <asp:ListItem Text="Vigente" Value="Vigente"></asp:ListItem>
                        <asp:ListItem Text="Aceptado" Value="Aceptado"></asp:ListItem>
                        <asp:ListItem Text="Vencido" Value="Vencido"></asp:ListItem>
                        <asp:ListItem Text="Rechazado" Value="Rechazado"></asp:ListItem>
                    </asp:DropDownList>
                </div>
                
                <div class="col-12 mt-4">
                    <h6 class="text-secondary fw-bold border-bottom pb-2">Agregar Productos al Presupuesto</h6>
                </div>
                
                <div class="col-md-5">
                    <label class="form-label">Producto</label>
                    <asp:DropDownList ID="ddlProductos" runat="server" CssClass="form-select" AutoPostBack="true" OnSelectedIndexChanged="ddlProductos_SelectedIndexChanged"></asp:DropDownList>
                </div>
                <div class="col-md-2">
                    <label class="form-label">Cantidad</label>
                    <asp:TextBox ID="txtCantidad" runat="server" CssClass="form-control" TextMode="Number" Text="1" AutoPostBack="true"></asp:TextBox>
                </div>
                <div class="col-md-3">
                    <label class="form-label">Precio Unitario ($)</label>
                    <asp:TextBox ID="txtPrecio" runat="server" CssClass="form-control" TextMode="Number" ReadOnly="true"></asp:TextBox>
                </div>
                <div class="col-md-2 d-flex align-items-end">
                    <asp:Button ID="btnAgregarProducto" runat="server" Text="Añadir" CssClass="btn-dermo-secondary w-100" OnClick="btnAgregarProducto_Click" />
                </div>

                <!-- CARRITO -->
                <div class="col-12 mt-4">
                    <div class="table-dermo-container">
                        <asp:GridView ID="gvDetalleCotizacion" runat="server" CssClass="table-dermo-modern" AutoGenerateColumns="False" GridLines="None">
                            <Columns>
                                <asp:BoundField DataField="Producto" HeaderText="Producto" />
                                <asp:BoundField DataField="Cantidad" HeaderText="Cantidad" />
                                <asp:BoundField DataField="Precio" HeaderText="Precio Unit." />
                                <asp:BoundField DataField="Subtotal" HeaderText="Subtotal" />
                            </Columns>
                            <EmptyDataTemplate>
                                <div class="text-center text-muted" style="padding: 15px;">A&uacute;n no hay productos en esta cotizaci&oacute;n.</div>
                            </EmptyDataTemplate>
                        </asp:GridView>
                    </div>
                </div>

                <div class="col-12 text-end mt-4 border-top pt-3">
                    <h3 style="color: var(--color-acento); font-family: 'Playfair Display', serif; margin-bottom: 15px;">Total: $<asp:Label ID="lblTotal" runat="server" Text="0"></asp:Label></h3>
                    <asp:Button ID="btnGuardarCotizacion" runat="server" Text="Guardar Cotizaci&oacute;n" CssClass="btn-dermo-primary" OnClick="btnGuardarCotizacion_Click" />
                </div>
            </div>
        </div>

        <!-- HISTORIAL -->
        <div style="background-color: var(--color-blanco); border-radius: 20px; border: 1px solid var(--color-borde-suave); padding: 30px;">
            <h3 style="font-size: 18px; margin: 0 0 20px 0; font-family: 'Playfair Display', serif;">Historial de Cotizaciones</h3>
            <div class="table-dermo-container">
                <asp:GridView ID="gvHistorialCotizaciones" runat="server" CssClass="table-dermo-modern" AutoGenerateColumns="False" GridLines="None" OnRowCommand="gvHistorialCotizaciones_RowCommand">
                    <Columns>
                        <asp:BoundField DataField="IdCotizacion" HeaderText="ID" />
                        <asp:BoundField DataField="Cliente" HeaderText="Cliente" />
                        <asp:BoundField DataField="FechaEmision" HeaderText="Fecha" DataFormatString="{0:dd/MM/yyyy}" />
                        <asp:BoundField DataField="Estado" HeaderText="Estado" />
                        <asp:BoundField DataField="Total" HeaderText="Total ($)" DataFormatString="{0:N0}" />
                        <asp:TemplateField HeaderText="Acciones">
                            <ItemTemplate>
                                <asp:LinkButton ID="btnVer" runat="server" CssClass="btn-dermo-secondary" style="padding: 4px 10px; font-size: 12px;" CommandName="VerDetalle" CommandArgument='<%# Eval("IdCotizacion") %>'>Ver</asp:LinkButton>
                            </ItemTemplate>
                        </asp:TemplateField>
                    </Columns>
                    <EmptyDataTemplate>
                        <div class="text-center text-muted" style="padding: 15px;">No hay cotizaciones registradas.</div>
                    </EmptyDataTemplate>
                </asp:GridView>
            </div>
        </div>
    </div>
</asp:Content>