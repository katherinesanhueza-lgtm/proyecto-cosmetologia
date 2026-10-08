<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Perfiles.aspx.cs" Inherits="trabajo_ing_software.Perfiles" %>
<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
  <h2>Gestión de Perfiles (Roles)</h2>
    <hr />
    
    <div class="row">
        <div class="col-md-4">
            <div class="form-group">
                <label>Nombre del Perfil:</label>
                <asp:TextBox ID="txtNombrePerfil" runat="server" CssClass="form-control" placeholder="Ej: Administrador"></asp:TextBox>
            </div>
            <br />
            <asp:Button ID="btnGuardar" runat="server" Text="Guardar Perfil" CssClass="btn btn-primary" OnClick="btnGuardar_Click" />
            <asp:Label ID="lblMensaje" runat="server" ForeColor="Green" CssClass="mt-2 d-block"></asp:Label>
        </div>
        
        <div class="col-md-8">
            <h4>Perfiles Registrados</h4>
            <asp:GridView ID="gvPerfiles" runat="server" CssClass="table table-striped table-bordered" AutoGenerateColumns="False" DataKeyNames="IdRol" OnRowDeleting="gvPerfiles_RowDeleting">
                <Columns>
                    <asp:BoundField DataField="IdRol" HeaderText="ID" ReadOnly="True" />
                    <asp:BoundField DataField="Nombre" HeaderText="Nombre" />
                    <asp:CommandField ShowDeleteButton="True" DeleteText="Eliminar" ControlStyle-CssClass="btn btn-danger btn-sm" />
                </Columns>
            </asp:GridView>
        </div>
    </div>
</asp:Content>
