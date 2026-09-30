<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Laboratorios.aspx.cs" Inherits="trabajo_ing_software.Laboratorios" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Gestión de Laboratorios - Dermocosmética</title>
    <link href="Content/Estilos.css" rel="stylesheet" type="text/css" />
    <style>
        .container {
            max-width: 1200px;
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
        .nav-links {
            display: flex;
            align-items: center;
            gap: 12px;
        }
        .grid-formulario {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(240px, 1fr));
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
            padding: 5px 10px;
            font-size: 12px;
            margin-right: 3px;
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
        <asp:HiddenField ID="hfIdLaboratorio" runat="server" Value="" />

        <div class="container">
            <div class="header-top">
                <div>
                    <h1 style="margin: 0; font-size: 26px;">Gestión de Laboratorios y Marcas</h1>
                    <span style="font-size: 13px; color: var(--color-secundario);">MÓDULO DE COMPRAS • DIRECTO DE PROVEEDORES</span>
                </div>
                <div class="nav-links">
                    <asp:Button ID="btnIrUsuarios" runat="server" Text="Usuarios" CssClass="btn-secundario" style="padding: 7px 15px; font-size: 13px;" OnClick="btnIrUsuarios_Click" />
                    <asp:Button ID="btnIrReporte" runat="server" Text="Reporte Evaluación" CssClass="btn-secundario" style="padding: 7px 15px; font-size: 13px;" OnClick="btnIrReporte_Click" />
                    <asp:Label ID="lblBienvenida" runat="server" Font-Bold="true"></asp:Label>
                    <asp:Button ID="btnLogout" runat="server" Text="Cerrar Sesión" CssClass="btn-secundario" style="padding: 7px 15px; font-size: 13px;" OnClick="btnLogout_Click" />
                </div>
            </div>

            <!-- Formulario de Registro / Modificación -->
            <div class="card-dermocosmetica" style="margin-bottom: 30px;">
                <h3 id="lblTituloForm" runat="server" style="margin-top: 0; margin-bottom: 15px;">Registrar Nuevo Laboratorio</h3>
                
                <div class="grid-formulario">
                    <div class="form-group">
                        <label>RUT Proveedor *:</label>
                        <asp:TextBox ID="txtRut" runat="server" CssClass="input-dermo" placeholder="Ej: 76.111.222-3"></asp:TextBox>
                    </div>
                    <div class="form-group">
                        <label>Razón Social *:</label>
                        <asp:TextBox ID="txtRazonSocial" runat="server" CssClass="input-dermo" placeholder="Ej: L'Oréal Chile S.A."></asp:TextBox>
                    </div>
                    <div class="form-group">
                        <label>Marca Representada *:</label>
                        <asp:TextBox ID="txtMarca" runat="server" CssClass="input-dermo" placeholder="Ej: La Roche-Posay / CeraVe"></asp:TextBox>
                    </div>
                    <div class="form-group">
                        <label>País de Origen:</label>
                        <asp:TextBox ID="txtPais" runat="server" CssClass="input-dermo" placeholder="Ej: Francia"></asp:TextBox>
                    </div>
                    <div class="form-group">
                        <label>Nombre de Contacto:</label>
                        <asp:TextBox ID="txtContacto" runat="server" CssClass="input-dermo" placeholder="Ej: Juan Pérez"></asp:TextBox>
                    </div>
                    <div class="form-group">
                        <label>Email de Contacto *:</label>
                        <asp:TextBox ID="txtEmail" runat="server" CssClass="input-dermo" placeholder="ventas@laboratorio.cl"></asp:TextBox>
                    </div>
                    <div class="form-group">
                        <label>Teléfono:</label>
                        <asp:TextBox ID="txtTelefono" runat="server" CssClass="input-dermo" placeholder="+56 9 1234 5678"></asp:TextBox>
                    </div>
                    <div class="form-group">
                        <label>Días de Crédito / Pago:</label>
                        <asp:TextBox ID="txtDiasPago" runat="server" CssClass="input-dermo" TextMode="Number" Text="30"></asp:TextBox>
                    </div>
                </div>

                <div style="margin-top: 15px; display: flex; align-items: center; gap: 15px;">
                    <asp:Button ID="btnGuardar" runat="server" Text="Guardar Laboratorio +" CssClass="btn-principal" OnClick="btnGuardar_Click" />
                    <asp:Button ID="btnCancelar" runat="server" Text="Cancelar Edición" CssClass="btn-secundario" Visible="false" OnClick="btnCancelar_Click" />
                    <asp:Label ID="lblMensaje" runat="server" Font-Size="14px"></asp:Label>
                </div>
            </div>

            <!-- Listado de Laboratorios Registrados -->
            <div class="card-dermocosmetica">
                <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 15px;">
                    <h3 style="margin: 0;">Directorio de Laboratorios</h3>
                    <span style="font-size: 13px; color: var(--color-secundario);">Total en sistema</span>
                </div>
                
                <asp:GridView ID="gvLaboratorios" runat="server" AutoGenerateColumns="False" 
                    CssClass="tabla-dermo" GridLines="None" EmptyDataText="No hay laboratorios registrados aún."
                    OnRowCommand="gvLaboratorios_RowCommand" DataKeyNames="IdLaboratorio">
                    <Columns>
                        <asp:BoundField DataField="IdLaboratorio" HeaderText="ID" />
                        <asp:BoundField DataField="Rut" HeaderText="RUT" />
                        <asp:BoundField DataField="RazonSocial" HeaderText="Razón Social" />
                        <asp:BoundField DataField="Marca" HeaderText="Marca" />
                        <asp:BoundField DataField="Pais" HeaderText="País" />
                        <asp:BoundField DataField="Contacto" HeaderText="Contacto" />
                        <asp:BoundField DataField="Email" HeaderText="Email" />
                        <asp:BoundField DataField="Telefono" HeaderText="Teléfono" />
                        <asp:BoundField DataField="DiasPago" HeaderText="Días Crédito" />
                        <asp:TemplateField HeaderText="Estado">
                            <ItemTemplate>
                                <span class='<%# Convert.ToBoolean(Eval("Activo")) ? "badge-activo" : "badge-inactivo" %>'>
                                    <%# Convert.ToBoolean(Eval("Activo")) ? "Activo" : "Inactivo" %>
                                </span>
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Acciones">
                            <ItemTemplate>
                                <asp:Button ID="btnEditar" runat="server" Text="✏️ Editar" 
                                    CommandName="Editar" CommandArgument='<%# Eval("IdLaboratorio") %>'
                                    CssClass="btn-accion btn-editar" />
                                <asp:Button ID="btnCambiarEstado" runat="server" 
                                    Text='<%# Convert.ToBoolean(Eval("Activo")) ? "Desactivar" : "Activar" %>' 
                                    CommandName="CambiarEstado" 
                                    CommandArgument='<%# Eval("IdLaboratorio") + ";" + Eval("Activo") %>'
                                    CssClass="btn-accion btn-editar" />
                                <asp:Button ID="btnEliminar" runat="server" Text="🗑️ Eliminar" 
                                    CommandName="Eliminar" CommandArgument='<%# Eval("IdLaboratorio") %>'
                                    CssClass="btn-accion btn-eliminar"
                                    OnClientClick="return confirm('¿Estás seguro de eliminar este laboratorio?');" />
                            </ItemTemplate>
                        </asp:TemplateField>
                    </Columns>
                </asp:GridView>
            </div>
        </div>
    </form>
</body>
</html>