<%@ Page Title="Perfiles y roles" MasterPageFile="~/Contabilidad.Master" Language="C#" AutoEventWireup="true" CodeBehind="Perfiles.aspx.cs" Inherits="trabajo_ing_software.Perfiles" ResponseEncoding="utf-8" ContentType="text/html; charset=utf-8" %>
<asp:Content ID="Acciones" ContentPlaceHolderID="AccionesUsuario" runat="server">
    <a href="Usuarios.aspx" class="btn btn-outline-secondary btn-sm">Volver a Usuarios</a>
</asp:Content>
<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <div class="dashboard compras-contenido">
        <div style="display: flex; justify-content: space-between; align-items: flex-end; margin-bottom: 22px; flex-wrap: wrap; gap: 14px;">
            <div>
                <span class="pill-badge" style="font-size: 10px; padding: 4px 12px; margin-bottom: 8px;">ADMINISTRACI&Oacute;N &amp; SEGURIDAD</span>
                <h1>Gesti&oacute;n de Perfiles (Roles)</h1>
                <p class="text-muted" style="margin: 0;">Creaci&oacute;n y mantenci&oacute;n de roles operativos registrados en el ERP.</p>
            </div>
            <div>
                <button type="button" class="btn btn-primary" onclick="abrirModalPerfil();">+ Nuevo Perfil</button>
            </div>
        </div>

        <asp:Label ID="lblMensaje" runat="server" ForeColor="Green" CssClass="mb-3 d-block fw-semibold" Font-Size="13px"></asp:Label>

        <!-- MODAL FLOTANTE NUEVO PERFIL -->
        <div id="modalNuevoPerfil" class="modal-overlay" style="display:none;">
            <div class="modal-content-card modal-sm-card">
                <div class="modal-header-dermo">
                    <div>
                        <span class="pill-badge" style="font-size: 10px; padding: 3px 10px;">ADMINISTRACI&Oacute;N &amp; ROLES</span>
                        <h2 style="font-size: 22px; margin: 6px 0 2px 0; font-family: 'Playfair Display', Georgia, serif; color: var(--color-texto);">Registrar Nuevo Perfil</h2>
                        <div style="font-size: 12px; color: var(--color-texto-suave);">Definici&oacute;n de roles operativos disponibles en el ERP</div>
                    </div>
                    <button type="button" class="btn btn-outline-secondary btn-sm modal-close-x" onclick="cerrarModalPerfil();" title="Cerrar ventana">&times;</button>
                </div>

                <div class="mb-3">
                    <label class="form-label">Nombre del Perfil *</label>
                    <asp:TextBox ID="txtNombrePerfil" runat="server" CssClass="form-control" placeholder="Ej: Supervisor de Compras"></asp:TextBox>
                </div>

                <div class="modal-footer-dermo">
                    <button type="button" class="btn btn-outline-secondary" onclick="cerrarModalPerfil();">Cancelar</button>
                    <asp:Button ID="btnGuardar" runat="server" Text="Guardar Perfil" CssClass="btn btn-primary" OnClick="btnGuardar_Click" />
                </div>
            </div>
        </div>

        <div class="card-dermocosmetica">
            <h2 style="font-size: 18px; margin-bottom: 14px;">Perfiles Registrados</h2>
            <div class="table-responsive">
                <asp:GridView ID="gvPerfiles" runat="server" CssClass="table table-hover align-middle" GridLines="None" AutoGenerateColumns="False" DataKeyNames="IdRol" OnRowDeleting="gvPerfiles_RowDeleting">
                    <Columns>
                        <asp:BoundField DataField="IdRol" HeaderText="ID" ReadOnly="True" />
                        <asp:BoundField DataField="Nombre" HeaderText="Nombre" />
                        <asp:CommandField ShowDeleteButton="True" DeleteText="Eliminar" ControlStyle-CssClass="btn btn-outline-danger btn-sm" />
                    </Columns>
                </asp:GridView>
            </div>
        </div>

        <script>
            function abrirModalPerfil() {
                var m = document.getElementById('modalNuevoPerfil');
                if (m) m.style.display = 'flex';
                var inp = document.getElementById('<%= txtNombrePerfil.ClientID %>');
                if (inp) inp.focus();
            }
            function cerrarModalPerfil() {
                var m = document.getElementById('modalNuevoPerfil');
                if (m) m.style.display = 'none';
            }
        </script>
    </div>
</asp:Content>
