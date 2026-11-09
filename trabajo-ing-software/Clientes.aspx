<%@ Page Title="Mantenedor de Clientes" Language="C#" MasterPageFile="~/Contabilidad.Master" AutoEventWireup="true" CodeBehind="Clientes.aspx.cs" Inherits="trabajo_ing_software.Clientes" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    
    <!-- ENLACES DE TIPOGRAFÍA Y ESTILOS LUXURY -->
    <link rel="preconnect" href="https://fonts.googleapis.com" />
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin="anonymous" />
    <link href="https://fonts.googleapis.com/css2?family=Playfair+Display:ital,wght@0,500;0,600;0,700;1,400;1,500;1,600&family=Plus+Jakarta+Sans:wght@300;400;500;600;700&display=swap" rel="stylesheet" />

    <div class="card-dermo-luxury" style="max-width: 1200px; margin: 30px auto;">
        
        <!-- CABECERA CON BOTONES SUPERIORES -->
        <div style="display: flex; justify-content: space-between; align-items: flex-start; margin-bottom: 25px; flex-wrap: wrap; gap: 15px;">
            <div>
                <span class="pill-badge" style="margin-bottom: 8px;">M&oacute;dulo de Ventas &bull; Gesti&oacute;n Comercial</span>
                <h1 style="font-size: 28px; margin: 4px 0 6px 0; font-family: 'Playfair Display', serif;">Mantenedor de Clientes</h1>
                <p class="text-muted" style="margin: 0;">Administraci&oacute;n de cartera de clientes y datos de contacto.</p>
            </div>
            <div style="display: flex; gap: 12px; align-items: center;">
                <!-- Información de Usuario Oculta (Mantenida de tu código original) -->
                <div class="user-info d-none" style="font-weight: 600; color: var(--color-texto); margin-right: 10px;">
                    <asp:Label ID="lblBienvenida" runat="server" Text="👤 Usuario"></asp:Label>
                </div>
                <asp:Button ID="btnIrVentas" runat="server" Text="Ir a Ventas" CssClass="btn-dermo-secondary" OnClick="btnIrVentas_Click" />
                <asp:Button ID="btnLogout" runat="server" Text="Cerrar Sesi&oacute;n" CssClass="btn-dermo-primary" style="background-color: #d9534f; border-color: #d43f3a;" OnClick="btnLogout_Click" />
            </div>
        </div>

        <!-- FORMULARIO DE REGISTRO / EDICIÓN -->
        <div style="background-color: var(--color-blanco); border-radius: 20px; border: 1px solid var(--color-borde-suave); padding: 30px; margin-bottom: 30px;">
            <h3 id="lblTituloForm" runat="server" style="font-size: 18px; margin: 0 0 20px 0; font-family: 'Playfair Display', serif;">Registrar Nuevo Cliente</h3>
            <asp:HiddenField ID="hfIdCliente" runat="server" />
            
            <div class="row g-3">
                <div class="col-md-3">
                    <label class="form-label fw-bold text-secondary">RUT Cliente</label>
                    <asp:TextBox ID="txtRut" runat="server" CssClass="form-control" Placeholder="Ej: 12345678-9"></asp:TextBox>
                </div>
                <div class="col-md-5">
                    <label class="form-label fw-bold text-secondary">Nombre o Raz&oacute;n Social</label>
                    <asp:TextBox ID="txtNombre" runat="server" CssClass="form-control" Placeholder="Ej: Empresa S.A. o Juan P&eacute;rez"></asp:TextBox>
                </div>
                <div class="col-md-4">
                    <label class="form-label fw-bold text-secondary">Categor&iacute;a</label>
                    <asp:DropDownList ID="ddlCategoria" runat="server" CssClass="form-select">
                        <asp:ListItem Text="General" Value="General"></asp:ListItem>
                        <asp:ListItem Text="Frecuente" Value="Frecuente"></asp:ListItem>
                        <asp:ListItem Text="Mayorista" Value="Mayorista"></asp:ListItem>
                    </asp:DropDownList>
                </div>
                <div class="col-md-6">
                    <label class="form-label fw-bold text-secondary">Correo Electr&oacute;nico</label>
                    <asp:TextBox ID="txtCorreo" runat="server" CssClass="form-control" Placeholder="cliente@correo.cl"></asp:TextBox>
                </div>
                <div class="col-md-6">
                    <label class="form-label fw-bold text-secondary">Tel&eacute;fono de Contacto</label>
                    <asp:TextBox ID="txtTelefono" runat="server" CssClass="form-control" Placeholder="+56 9..."></asp:TextBox>
                </div>

                <!-- CONTENEDOR DE BOTONES Y MENSAJES -->
                <div class="col-12 text-end mt-4 d-flex justify-content-end align-items-center">
                    <asp:Label ID="lblMensaje" runat="server" CssClass="me-3" style="font-weight:600; color: #d9534f; font-size: 14px;"></asp:Label>
                    <asp:Button ID="btnCancelar" runat="server" Text="Cancelar Edición" CssClass="btn-dermo-secondary me-2" Visible="false" OnClick="btnCancelar_Click" />
                    <asp:Button ID="btnGuardar" runat="server" Text="Guardar Cliente" CssClass="btn-dermo-primary" OnClick="btnGuardar_Click" />
                </div>
            </div>
        </div>

        <!-- TABLA DE CLIENTES REGISTRADOS -->
        <div style="background-color: var(--color-blanco); border-radius: 20px; border: 1px solid var(--color-borde-suave); padding: 30px;">
            <h3 style="font-size: 18px; margin: 0 0 20px 0; font-family: 'Playfair Display', serif;">Clientes Registrados</h3>
            <div class="table-dermo-container">
                <asp:GridView ID="gvClientes" runat="server" CssClass="table-dermo-modern" AutoGenerateColumns="False" GridLines="None" OnRowCommand="gvClientes_RowCommand">
                    <Columns>
                        <asp:BoundField DataField="IdCliente" HeaderText="ID" />
                        <asp:BoundField DataField="Rut" HeaderText="RUT" />
                        <asp:BoundField DataField="Nombre" HeaderText="Nombre" />
                        <asp:BoundField DataField="Categoria" HeaderText="Categor&iacute;a" />
                        <asp:BoundField DataField="Correo" HeaderText="Correo" />
                        <asp:BoundField DataField="Telefono" HeaderText="Tel&eacute;fono" />
                        <asp:TemplateField HeaderText="Acciones">
                            <ItemTemplate>
                                <!-- Cambié los botones antiguos por LinkButtons con las clases luxury -->
                                <asp:LinkButton ID="btnEditar" runat="server" CssClass="btn-dermo-secondary" style="padding: 4px 10px; font-size: 12px; margin-right: 5px;" CommandName="Editar" CommandArgument='<%# Eval("IdCliente") %>'>Editar</asp:LinkButton>
                                <asp:LinkButton ID="btnEliminar" runat="server" CssClass="btn-dermo-primary" style="background-color: #d9534f; border-color: #d43f3a; padding: 4px 10px; font-size: 12px;" CommandName="Eliminar" CommandArgument='<%# Eval("IdCliente") %>' OnClientClick="return confirm('¿Estás seguro de que deseas eliminar este cliente?');">Eliminar</asp:LinkButton>
                            </ItemTemplate>
                        </asp:TemplateField>
                    </Columns>
                    <EmptyDataTemplate>
                        <div class="text-center text-muted" style="padding: 15px;">No hay clientes registrados en la base de datos.</div>
                    </EmptyDataTemplate>
                </asp:GridView>
            </div>
        </div>
    </div>
</asp:Content>