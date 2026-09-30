<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Usuarios.aspx.cs" Inherits="trabajo_ing_software.Usuarios" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Mantenedor de Usuarios - Dermocosmética</title>
    <link href="Content/Estilos.css" rel="stylesheet" type="text/css" />
    <style>
        .container {
            max-width: 1150px;
            margin: 30px auto;
            padding: 0 20px;
        }
        .header-top {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 25px;
            padding-bottom: 15px;
            border-bottom: 1px solid var(--color-primario);
        }
        .grid-formulario {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
            gap: 15px;
        }
        .form-group {
            display: flex;
            flex-direction: column;
        }
        .form-group label {
            font-size: 13px;
            font-weight: 500;
            color: var(--color-texto);
            margin-bottom: 3px;
        }
        .badge-activo {
            background-color: #E8F8F0;
            color: #27AE60;
            padding: 4px 10px;
            border-radius: 12px;
            font-size: 12px;
            font-weight: 600;
        }
        .badge-inactivo {
            background-color: #FDEDEC;
            color: #C0392B;
            padding: 4px 10px;
            border-radius: 12px;
            font-size: 12px;
            font-weight: 600;
        }
        .btn-accion {
            padding: 5px 12px;
            font-size: 12px;
            margin-right: 4px;
            cursor: pointer;
            border-radius: 15px;
            transition: all 0.2s;
        }
        .btn-editar {
            background-color: transparent;
            color: var(--color-acento);
            border: 1px solid var(--color-acento);
        }
        .btn-editar:hover {
            background-color: var(--color-primario);
        }
        .btn-eliminar {
            background-color: transparent;
            color: #C0392B;
            border: 1px solid #C0392B;
        }
        .btn-eliminar:hover {
            background-color: #FDEDEC;
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <asp:HiddenField ID="hfIdUsuario" runat="server" Value="" />

        <div class="container">
        <div class="container">
            <div class="header-top">
                <div>
                    <h1 style="margin: 0; font-size: 26px;">Mantenedor de Usuarios</h1>
                    <span style="font-size: 13px; color: var(--color-secundario);">ADMINISTRACIÓN DEL SISTEMA • CONTROL DE ACCESOS</span>
                </div>
                <div>
                    <asp:Button ID="btnIrLaboratorios" runat="server" Text="Ir a Laboratorios →" CssClass="btn-principal" style="padding: 8px 18px; font-size: 13px; margin-right: 15px;" OnClick="btnIrLaboratorios_Click" />
                    <asp:Label ID="lblBienvenida" runat="server" Font-Bold="true" style="margin-right: 15px;"></asp:Label>
                    <asp:Button ID="btnLogout" runat="server" Text="Cerrar Sesión" CssClass="btn-secundario" OnClick="btnLogout_Click" />
                </div>
            </div>

            <!-- Formulario de Registro / Modificación -->
            <div class="card-dermocosmetica" style="margin-bottom: 30px;">
                <h3 id="lblTituloForm" runat="server" style="margin-top: 0; margin-bottom: 15px;">Registrar Nuevo Usuario</h3>
                
                <div class="grid-formulario">
                    <div class="form-group">
                        <label>Nombre Completo:</label>
                        <asp:TextBox ID="txtNombre" runat="server" CssClass="input-dermo" placeholder="Ej: Javiera González"></asp:TextBox>
                    </div>
                    <div class="form-group">
                        <label>Correo Electrónico:</label>
                        <asp:TextBox ID="txtCorreo" runat="server" CssClass="input-dermo" placeholder="usuario@dermo.cl"></asp:TextBox>
                    </div>
                    <div class="form-group">
                        <label>Contraseña: <small style="color: gray;">(Dejar vacía al editar para no cambiar)</small></label>
                        <asp:TextBox ID="txtPassword" runat="server" TextMode="Password" CssClass="input-dermo" placeholder="••••••••"></asp:TextBox>
                    </div>
                    <div class="form-group">
                        <label>Rol en el Sistema:</label>
                        <asp:DropDownList ID="ddlRol" runat="server" CssClass="input-dermo">
                            <asp:ListItem Text="-- Seleccione Rol --" Value="" />
                            <asp:ListItem Text="Administrador" Value="Administrador" />
                            <asp:ListItem Text="Encargado de Compras" Value="Compras" />
                            <asp:ListItem Text="Encargado de Ventas" Value="Ventas" />
                            <asp:ListItem Text="Encargado de Bodega" Value="Bodega" />
                            <asp:ListItem Text="Contabilidad" Value="Contabilidad" />
                        </asp:DropDownList>
                    </div>
                </div>

                <div style="margin-top: 15px; display: flex; align-items: center; gap: 15px;">
                    <asp:Button ID="btnGuardar" runat="server" Text="Guardar Usuario +" CssClass="btn-principal" OnClick="btnGuardar_Click" />
                    <asp:Button ID="btnCancelar" runat="server" Text="Cancelar Edición" CssClass="btn-secundario" Visible="false" OnClick="btnCancelar_Click" />
                    <asp:Label ID="lblMensaje" runat="server" Font-Size="14px"></asp:Label>
                </div>
            </div>

            <!-- Listado de Usuarios -->
            <div class="card-dermocosmetica">
                <h3 style="margin-top: 0;">Usuarios Registrados</h3>
                
                <asp:GridView ID="gvUsuarios" runat="server" AutoGenerateColumns="False" 
                    CssClass="tabla-dermo" GridLines="None" OnRowCommand="gvUsuarios_RowCommand" DataKeyNames="IdUsuario">
                    <Columns>
                        <asp:BoundField DataField="IdUsuario" HeaderText="ID" />
                        <asp:BoundField DataField="Nombre" HeaderText="Nombre" />
                        <asp:BoundField DataField="Correo" HeaderText="Correo" />
                        <asp:BoundField DataField="Rol" HeaderText="Rol Asignado" />
                        <asp:TemplateField HeaderText="Estado">
                            <ItemTemplate>
                                <span class='<%# Convert.ToBoolean(Eval("Activo")) ? "badge-activo" : "badge-inactivo" %>'>
                                    <%# Convert.ToBoolean(Eval("Activo")) ? "Activo" : "Inactivo" %>
                                </span>
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Acciones">
                            <ItemTemplate>
                                <!-- Botón Editar -->
                                <asp:Button ID="btnEditar" runat="server" Text="✏️ Editar" 
                                    CommandName="Editar" CommandArgument='<%# Eval("IdUsuario") %>'
                                    CssClass="btn-accion btn-editar" />

                                <!-- Botón Activar / Desactivar -->
                                <asp:Button ID="btnCambiarEstado" runat="server" 
                                    Text='<%# Convert.ToBoolean(Eval("Activo")) ? "Desactivar" : "Activar" %>' 
                                    CommandName="CambiarEstado" 
                                    CommandArgument='<%# Eval("IdUsuario") + ";" + Eval("Activo") %>'
                                    CssClass="btn-accion btn-editar" />

                                <!-- Botón Eliminar -->
                                <asp:Button ID="btnEliminar" runat="server" Text="🗑️ Eliminar" 
                                    CommandName="Eliminar" CommandArgument='<%# Eval("IdUsuario") %>'
                                    CssClass="btn-accion btn-eliminar"
                                    OnClientClick="return confirm('¿Estás seguro de que deseas eliminar permanentemente este usuario?');" />
                            </ItemTemplate>
                        </asp:TemplateField>
                    </Columns>
                </asp:GridView>
            </div>
        </div>
    </form>
</body>
</html>