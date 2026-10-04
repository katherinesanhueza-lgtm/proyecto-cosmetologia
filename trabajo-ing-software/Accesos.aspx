<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Accesos.aspx.cs" Inherits="trabajo_ing_software.Accesos" %>
<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <h2>Gestión de Accesos</h2>
    <hr />
    
    <div class="row">
        <div class="col-md-4">
            <div class="form-group">
                <label>Seleccionar Usuario:</label>
                <asp:DropDownList ID="ddlUsuarios" runat="server" CssClass="form-control"></asp:DropDownList>
            </div>
            <div class="form-group mt-2">
                <label>Asignar Perfil (Rol):</label>
                <asp:DropDownList ID="ddlPerfiles" runat="server" CssClass="form-control"></asp:DropDownList>
            </div>
            <br />
            <asp:Button ID="btnGuardarAcceso" runat="server" Text="Actualizar Acceso" CssClass="btn btn-primary" OnClick="btnGuardarAcceso_Click" />
            <asp:Label ID="lblMensaje" runat="server" CssClass="mt-2 d-block"></asp:Label>
        </div>
        
        <div class="col-md-8">
            <h4>Accesos Actuales</h4>
            <asp:GridView ID="gvAccesos" runat="server" CssClass="table table-striped table-bordered" AutoGenerateColumns="False">
                <Columns>
                    <asp:BoundField DataField="Nombre" HeaderText="Usuario" />
                    <asp:BoundField DataField="Correo" HeaderText="Correo" />
                    <asp:BoundField DataField="Perfil" HeaderText="Perfil Asignado" />
                </Columns>
            </asp:GridView>
        </div>
    </div>
</asp:Content>

