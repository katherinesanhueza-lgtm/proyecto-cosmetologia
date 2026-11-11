<%@ Page Title="Asignación de accesos" MasterPageFile="~/Contabilidad.Master" Language="C#" AutoEventWireup="true" CodeBehind="Accesos.aspx.cs" Inherits="trabajo_ing_software.Accesos" ResponseEncoding="utf-8" ContentType="text/html; charset=utf-8" %>
<asp:Content ID="Acciones" ContentPlaceHolderID="AccionesUsuario" runat="server">
    <a href="Usuarios.aspx" class="btn btn-outline-secondary btn-sm">Volver a Usuarios</a>
</asp:Content>
<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <div class="dashboard compras-contenido">
        <div style="margin-bottom: 22px;">
            <span class="pill-badge" style="font-size: 10px; padding: 4px 12px; margin-bottom: 8px;">ADMINISTRACI&Oacute;N &amp; SEGURIDAD</span>
            <h1>Gesti&oacute;n de Accesos</h1>
            <p class="text-muted" style="margin: 0;">Asignaci&oacute;n de perfiles y permisos por usuario en el sistema.</p>
        </div>

        <div class="row g-4">
            <div class="col-md-4">
                <div class="card-dermocosmetica">
                    <h2 style="font-size: 18px; margin-bottom: 16px;">Asignar Perfil</h2>
                    <div class="mb-3">
                        <label class="form-label">Seleccionar Usuario:</label>
                        <asp:DropDownList ID="ddlUsuarios" runat="server" CssClass="form-select"></asp:DropDownList>
                    </div>
                    <div class="mb-3">
                        <label class="form-label">Asignar Perfil (Rol):</label>
                        <asp:DropDownList ID="ddlPerfiles" runat="server" CssClass="form-select"></asp:DropDownList>
                    </div>
                    <asp:Button ID="btnGuardarAcceso" runat="server" Text="Actualizar Acceso" CssClass="btn btn-primary w-100" OnClick="btnGuardarAcceso_Click" />
                    <asp:Label ID="lblMensaje" runat="server" CssClass="mt-3 d-block" Font-Size="13px"></asp:Label>
                </div>
            </div>

            <div class="col-md-8">
                <div class="table-dermo-container p-3">
                    <h2 style="font-size: 18px; margin-bottom: 14px;">Accesos Actuales</h2>
                    <asp:GridView ID="gvAccesos" runat="server" CssClass="table table-hover align-middle" GridLines="None" AutoGenerateColumns="False">
                        <Columns>
                            <asp:BoundField DataField="Nombre" HeaderText="Usuario" />
                            <asp:BoundField DataField="Correo" HeaderText="Correo" />
                            <asp:BoundField DataField="Perfil" HeaderText="Perfil Asignado" />
                        </Columns>
                    </asp:GridView>
                </div>
            </div>
        </div>
    </div>
</asp:Content>
