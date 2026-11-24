<%@ Page Title="Asignación de accesos" MasterPageFile="~/Contabilidad.Master" Language="C#" AutoEventWireup="true" CodeBehind="Accesos.aspx.cs" Inherits="trabajo_ing_software.Accesos" ResponseEncoding="utf-8" ContentType="text/html; charset=utf-8" %>
<asp:Content ID="Acciones" ContentPlaceHolderID="AccionesUsuario" runat="server">
    <a href="Usuarios.aspx" class="btn btn-outline-secondary btn-sm">Volver a Usuarios</a>
</asp:Content>
<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <div class="dashboard compras-contenido">
        <div style="display: flex; justify-content: space-between; align-items: flex-end; margin-bottom: 22px; flex-wrap: wrap; gap: 14px;">
            <div>
                <span class="pill-badge" style="font-size: 10px; padding: 4px 12px; margin-bottom: 8px;">ADMINISTRACI&Oacute;N &amp; SEGURIDAD</span>
                <h1>Gesti&oacute;n de Accesos</h1>
                <p class="text-muted" style="margin: 0;">Asignaci&oacute;n de perfiles y permisos operativos por usuario en el sistema.</p>
            </div>
            <div style="display: flex; gap: 10px; flex-wrap: wrap;">
                <a href="Usuarios.aspx" class="btn btn-outline-secondary">Ir a Usuarios</a>
                <button type="button" class="btn btn-primary" onclick="abrirModalAcceso();">+ Asignar Perfil</button>
            </div>
        </div>

        <asp:Label ID="lblMensaje" runat="server" CssClass="mb-3 d-block fw-semibold" Font-Size="13px"></asp:Label>

        <!-- MODAL FLOTANTE ASIGNAR PERFIL -->
        <div id="modalAsignarAcceso" class="modal-overlay" style="display:none;">
            <div class="modal-content-card modal-sm-card">
                <div class="modal-header-dermo">
                    <div>
                        <span class="pill-badge" style="font-size: 10px; padding: 3px 10px;">CONTROL DE ACCESO</span>
                        <h2 style="font-size: 22px; margin: 6px 0 2px 0; font-family: 'Playfair Display', Georgia, serif; color: var(--color-texto);">Asignar Perfil de Usuario</h2>
                        <div style="font-size: 12px; color: var(--color-texto-suave);">Actualiza el rol y los permisos de m&oacute;dulos de un usuario</div>
                    </div>
                    <button type="button" class="btn btn-outline-secondary btn-sm modal-close-x" onclick="cerrarModalAcceso();" title="Cerrar ventana">&times;</button>
                </div>

                <div class="modal-section-box" style="margin-bottom: 12px;">
                    <div class="mb-3">
                        <label class="form-label">Seleccionar Usuario *</label>
                        <asp:DropDownList ID="ddlUsuarios" runat="server" CssClass="form-select"></asp:DropDownList>
                    </div>
                    <div>
                        <label class="form-label">Asignar Perfil (Rol) *</label>
                        <asp:DropDownList ID="ddlPerfiles" runat="server" CssClass="form-select"></asp:DropDownList>
                    </div>
                </div>

                <div class="modal-footer-dermo">
                    <button type="button" class="btn btn-outline-secondary" onclick="cerrarModalAcceso();">Cancelar</button>
                    <asp:Button ID="btnGuardarAcceso" runat="server" Text="Actualizar Acceso" CssClass="btn btn-primary" OnClick="btnGuardarAcceso_Click" />
                </div>
            </div>
        </div>

        <div class="table-dermo-container">
            <div class="dermo-table-headbar">
                <div class="dermo-table-headbar-title">
                    <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#7A5E47" stroke-width="2" aria-hidden="true"><path d="M21 2l-2 2m-7.61 7.61a5.5 5.5 0 1 1-7.778 7.778 5.5 5.5 0 0 1 7.777-7.777zm0 0L15.5 7.5m0 0l3 3L22 7l-3-3m-3.5 3.5L19 4"></path></svg>
                    <h2>Accesos Actuales</h2>
                </div>
                <span class="dermo-pill-ok">Permisos vigentes</span>
            </div>
            <div class="table-responsive">
                <asp:GridView ID="gvAccesos" runat="server" CssClass="table table-hover align-middle" GridLines="None" AutoGenerateColumns="False" EmptyDataText="No hay usuarios registrados.">
                    <Columns>
                        <asp:BoundField DataField="Nombre" HeaderText="Usuario" ItemStyle-CssClass="fw-semibold" />
                        <asp:BoundField DataField="Correo" HeaderText="Correo Electr&oacute;nico" HtmlEncode="false" />
                        <asp:TemplateField HeaderText="Perfil Asignado" HeaderStyle-CssClass="text-center" ItemStyle-CssClass="text-center">
                            <ItemTemplate>
                                <span class="dermo-pill-neutral"><%# Eval("Perfil") %></span>
                            </ItemTemplate>
                        </asp:TemplateField>
                    </Columns>
                </asp:GridView>
            </div>
        </div>

        <script>
            function abrirModalAcceso() {
                var m = document.getElementById('modalAsignarAcceso');
                if (m) m.style.display = 'flex';
            }
            function cerrarModalAcceso() {
                var m = document.getElementById('modalAsignarAcceso');
                if (m) m.style.display = 'none';
            }
        </script>
    </div>
</asp:Content>
