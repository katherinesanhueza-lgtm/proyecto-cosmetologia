<%@ Page Title="Perfiles y roles" MasterPageFile="~/Contabilidad.Master" Language="C#" AutoEventWireup="true" CodeBehind="Perfiles.aspx.cs" Inherits="trabajo_ing_software.Perfiles" ResponseEncoding="utf-8" ContentType="text/html; charset=utf-8" %>
<asp:Content ID="Acciones" ContentPlaceHolderID="AccionesUsuario" runat="server">
    <a href="Usuarios.aspx" class="btn btn-outline-secondary btn-sm">Volver a Usuarios</a>
</asp:Content>
<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <div class="dashboard compras-contenido">
        <div style="margin-bottom: 22px;">
            <span class="pill-badge" style="font-size: 10px; padding: 4px 12px; margin-bottom: 8px;">ADMINISTRACI&Oacute;N &amp; SEGURIDAD</span>
            <h1>Gesti&oacute;n de Perfiles (Roles)</h1>
            <p class="text-muted" style="margin: 0;">Creaci&oacute;n y mantenci&oacute;n de roles operativos registrados en el ERP.</p>
        </div>

        <div class="row g-4">
            <div class="col-md-4">
                <div class="card-dermocosmetica">
                    <h2 style="font-size: 18px; margin-bottom: 16px;">Nuevo Perfil</h2>
                    <div class="mb-3">
                        <label class="form-label">Nombre del Perfil:</label>
                        <asp:TextBox ID="txtNombrePerfil" runat="server" CssClass="form-control" placeholder="Ej: Administrador"></asp:TextBox>
                    </div>
                    <asp:Button ID="btnGuardar" runat="server" Text="Guardar Perfil" CssClass="btn btn-primary w-100" OnClick="btnGuardar_Click" />
                    <asp:Label ID="lblMensaje" runat="server" ForeColor="Green" CssClass="mt-3 d-block" Font-Size="13px"></asp:Label>
                </div>
            </div>

            <div class="col-md-8">
                <div class="table-dermo-container p-3">
                    <h2 style="font-size: 18px; margin-bottom: 14px;">Perfiles Registrados</h2>
                    <asp:GridView ID="gvPerfiles" runat="server" CssClass="table table-hover align-middle" GridLines="None" AutoGenerateColumns="False" DataKeyNames="IdRol" OnRowDeleting="gvPerfiles_RowDeleting">
                        <Columns>
                            <asp:BoundField DataField="IdRol" HeaderText="ID" ReadOnly="True" />
                            <asp:BoundField DataField="Nombre" HeaderText="Nombre" />
                            <asp:CommandField ShowDeleteButton="True" DeleteText="Eliminar" ControlStyle-CssClass="btn btn-outline-danger btn-sm" />
                        </Columns>
                    </asp:GridView>
                </div>
            </div>
        </div>
    </div>
</asp:Content>
