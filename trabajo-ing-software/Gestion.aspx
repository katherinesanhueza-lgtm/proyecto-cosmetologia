<%@ Page Title="Gestión de inventario" ResponseEncoding="utf-8" Language="C#" MasterPageFile="~/Contabilidad.Master" AutoEventWireup="true" CodeBehind="Gestion.aspx.cs" Inherits="trabajo_ing_software.Gestion" %>
<asp:Content ID="Contenido" ContentPlaceHolderID="MainContent" runat="server">
    <asp:PlaceHolder ID="Interfaz" runat="server" />
    <script>
        function abrirModalGestion() {
            var m = document.getElementById('modalGestion');
            if (m) m.style.display = 'flex';
        }
        function cerrarModalGestion(urlBase, esEdicion) {
            if (esEdicion && urlBase) {
                window.location.href = urlBase;
                return;
            }
            var m = document.getElementById('modalGestion');
            if (m) m.style.display = 'none';
        }
    </script>
</asp:Content>
