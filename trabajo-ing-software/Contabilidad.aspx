<%@ Page Title="Contabilidad" Language="C#" MasterPageFile="~/Contabilidad.Master" CodeBehind="Contabilidad.aspx.cs" Inherits="trabajo_ing_software.Contabilidad" ResponseEncoding="utf-8" %>
<asp:Content ID="Contenido" ContentPlaceHolderID="MainContent" runat="server">
    <div class="dashboard">
        <header class="dashboard-header">
            <div>
                <p class="dashboard-etiqueta">MÓDULO DE CONTABILIDAD</p>
                <h1>Gestión de Contabilidad</h1>
                <p class="dashboard-descripcion">Administra tus cuentas, períodos y asientos. Consulta los reportes del módulo.</p>
            </div>
        </header>
        <section class="card-dermocosmetica">
            <h2><asp:Literal ID="Titulo" runat="server" Mode="Encode" /></h2>
            <asp:Label ID="Mensaje" runat="server" EnableViewState="false" role="status" />
            <div class="contabilidad-formulario">
                <asp:PlaceHolder ID="Formulario" runat="server" />
            </div>
            <div class="table-responsive mt-4">
                <asp:GridView ID="Registros" runat="server" CssClass="table table-hover"
                    GridLines="None" EmptyDataText="No hay registros para esta consulta." EnableViewState="false" />
            </div>
        </section>
    </div>
</asp:Content>
