<%@ Page Title="Mantenedor de Clientes" Language="C#" MasterPageFile="~/Contabilidad.Master" AutoEventWireup="true" CodeBehind="Clientes.aspx.cs" Inherits="trabajo_ing_software.Clientes" ResponseEncoding="utf-8" %>

<asp:Content ID="Estilos" ContentPlaceHolderID="EstilosPagina" runat="server">
    <link href="<%: ResolveUrl("~/Content/ComprasResumen.css?v=1") %>" rel="stylesheet" />
    <link href="<%: ResolveUrl("~/Content/Estilos.css") %>" rel="stylesheet" type="text/css" />
</asp:Content>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <div class="dashboard compras-resumen">
        
        <header class="dashboard-header">
            <div>
                <p class="dashboard-etiqueta">Módulo de ventas · Gestión comercial</p>
                <h1>Mantenedor de Clientes</h1>
                <p class="dashboard-descripcion">Administración de cartera de clientes y datos de contacto.</p>
            </div>
            <!-- Controles antiguos ocultos para no romper el código C# -->
            <div class="d-none">
                <asp:Label ID="lblBienvenida" runat="server" Text="Usuario"></asp:Label>
                <asp:Button ID="btnIrVentas" runat="server" OnClick="btnIrVentas_Click" />
                <asp:Button ID="btnLogout" runat="server" OnClick="btnLogout_Click" />
            </div>
        </header>

        <!-- TARJETA 1: FORMULARIO -->
        <section class="card-dermocosmetica" style="margin-bottom: 24px;">
            <h2 id="lblTituloForm" runat="server" style="margin-bottom: 16px;">Registrar Nuevo Cliente</h2>
            <asp:HiddenField ID="hfIdCliente" runat="server" />
            
            <div class="row g-3">
                <div class="col-md-3">
                    <label class="form-label fw-bold text-secondary">RUT Cliente</label>
                    <asp:TextBox ID="txtRut" runat="server" CssClass="form-control" Placeholder="Ej: 12345678-9"></asp:TextBox>
                </div>
                <div class="col-md-5">
                    <label class="form-label fw-bold text-secondary">Nombre o Razón Social</label>
                    <asp:TextBox ID="txtNombre" runat="server" CssClass="form-control" Placeholder="Ej: Empresa S.A. o Juan Pérez"></asp:TextBox>
                </div>
                <div class="col-md-4">
                    <label class="form-label fw-bold text-secondary">Categoría</label>
                    <asp:DropDownList ID="ddlCategoria" runat="server" CssClass="form-select">
                        <asp:ListItem Text="General" Value="General"></asp:ListItem>
                        <asp:ListItem Text="Frecuente" Value="Frecuente"></asp:ListItem>
                        <asp:ListItem Text="Mayorista" Value="Mayorista"></asp:ListItem>
                    </asp:DropDownList>
                </div>
                <div class="col-md-6">
                    <label class="form-label fw-bold text-secondary">Correo Electrónico</label>
                    <asp:TextBox ID="txtCorreo" runat="server" CssClass="form-control" Placeholder="cliente@correo.cl"></asp:TextBox>
                </div>
                <div class="col-md-6">
                    <label class="form-label fw-bold text-secondary">Teléfono de Contacto</label>
                    <asp:TextBox ID="txtTelefono" runat="server" CssClass="form-control" Placeholder="+56 9..."></asp:TextBox>
                </div>

                <div class="col-12 text-end mt-4 d-flex justify-content-end align-items-center">
                    <asp:Label ID="lblMensaje" runat="server" CssClass="me-3" style="font-weight:600; color: #d9534f; font-size: 14px;"></asp:Label>
                    <asp:Button ID="btnCancelar" runat="server" Text="Cancelar Edición" CssClass="btn btn-outline-secondary me-2" Visible="false" OnClick="btnCancelar_Click" />
                    <asp:Button ID="btnGuardar" runat="server" Text="Guardar Cliente" CssClass="btn btn-primary" OnClick="btnGuardar_Click" />
                </div>
            </div>
        </section>

        <!-- TARJETA 2: LISTADO -->
        <section class="card-dermocosmetica">
            <h2 style="margin-bottom: 16px;">Clientes Registrados</h2>
            <div class="table-responsive">
                <asp:GridView ID="gvClientes" runat="server" CssClass="table table-hover" AutoGenerateColumns="False" GridLines="None" OnRowCommand="gvClientes_RowCommand" EmptyDataText="No hay clientes registrados en la base de datos.">
                    <Columns>
                        <asp:BoundField DataField="IdCliente" HeaderText="ID" />
                        <asp:BoundField DataField="Rut" HeaderText="RUT" />
                        <asp:BoundField DataField="Nombre" HeaderText="Nombre" />
                        <asp:BoundField DataField="Categoria" HeaderText="Categoría" />
                        <asp:BoundField DataField="Correo" HeaderText="Correo" />
                        <asp:BoundField DataField="Telefono" HeaderText="Teléfono" />
                        <asp:TemplateField HeaderText="Acciones">
                            <ItemTemplate>
                                <asp:LinkButton ID="btnEditar" runat="server" CssClass="btn btn-outline-secondary btn-sm me-1" CommandName="Editar" CommandArgument='<%# Eval("IdCliente") %>'>Editar</asp:LinkButton>
                                <asp:LinkButton ID="btnEliminar" runat="server" CssClass="btn btn-outline-danger btn-sm" CommandName="Eliminar" CommandArgument='<%# Eval("IdCliente") %>' OnClientClick="return confirm('¿Estás seguro de que deseas eliminar este cliente?');">Eliminar</asp:LinkButton>
                            </ItemTemplate>
                        </asp:TemplateField>
                    </Columns>
                </asp:GridView>
            </div>
        </section>

    </div>
</asp:Content>