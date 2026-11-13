<%@ Page Title="Mantenedor de Clientes" Language="C#" MasterPageFile="~/Contabilidad.Master" AutoEventWireup="true" CodeBehind="Clientes.aspx.cs" Inherits="trabajo_ing_software.Clientes" ResponseEncoding="utf-8" %>

<asp:Content ID="Estilos" ContentPlaceHolderID="EstilosPagina" runat="server">
    <link href="<%: ResolveUrl("~/Content/ComprasResumen.css?v=1") %>" rel="stylesheet" />
    <style>
        .card-dermocosmetica h2 { font-size: 1.25rem; font-weight: 600; margin-bottom: 14px; }
        .form-label { font-size: 0.875rem; font-weight: 500; color: #24211e; margin-bottom: 6px; }
        .table { font-size: 0.85rem; }
        .table th { font-size: 0.85rem; }
        .table td { font-size: 0.85rem; }
        .badge-activo { background-color: #E8F8F0; color: #27AE60; padding: 4px 10px; border-radius: 12px; font-weight: 600; font-size: 12px; display: inline-block; }
        .badge-inactivo { background-color: #FDEDEC; color: #C0392B; padding: 4px 10px; border-radius: 12px; font-weight: 600; font-size: 12px; display: inline-block; }
    </style>
</asp:Content>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <div class="dashboard compras-resumen">
        
        <header class="dashboard-header">
            <div>
                <p class="dashboard-etiqueta">Módulo de ventas · Gestión comercial</p>
                <h1>Mantenedor de Clientes</h1>
                <p class="dashboard-descripcion">Administración de cartera de clientes, giro comercial, condiciones y límites de crédito.</p>
            </div>
            <!-- Controles antiguos ocultos para compatibilidad -->
            <div class="d-none">
                <asp:Label ID="lblBienvenida" runat="server" Text="Usuario"></asp:Label>
                <asp:Button ID="btnIrVentas" runat="server" OnClick="btnIrVentas_Click" />
                <asp:Button ID="btnLogout" runat="server" OnClick="btnLogout_Click" />
            </div>
        </header>

        <!-- TARJETA 1: FORMULARIO DE CLIENTE -->
        <section class="card-dermocosmetica" style="margin-bottom: 24px;">
            <h2 id="lblTituloForm" runat="server" style="margin-bottom: 16px;">Registrar Nuevo Cliente</h2>
            <asp:HiddenField ID="hfIdCliente" runat="server" />
            
            <div class="row g-3">
                <div class="col-md-3">
                    <label class="form-label">RUT Cliente *</label>
                    <asp:TextBox ID="txtRut" runat="server" CssClass="form-control" Placeholder="Ej: 76.123.456-7"></asp:TextBox>
                </div>
                <div class="col-md-5">
                    <label class="form-label">Razón Social o Nombre Completo *</label>
                    <asp:TextBox ID="txtNombre" runat="server" CssClass="form-control" Placeholder="Ej: Clínica DermoSalud SpA"></asp:TextBox>
                </div>
                <div class="col-md-4">
                    <label class="form-label">Tipo de Cliente</label>
                    <asp:DropDownList ID="ddlCategoria" runat="server" CssClass="form-select">
                        <asp:ListItem Text="Clínica / Centro Estético" Value="Clinica"></asp:ListItem>
                        <asp:ListItem Text="Farmacia / Botica" Value="Farmacia"></asp:ListItem>
                        <asp:ListItem Text="Distribuidor Mayorista" Value="Mayorista"></asp:ListItem>
                        <asp:ListItem Text="Profesional Independiente" Value="Profesional"></asp:ListItem>
                        <asp:ListItem Text="Cliente Particular / Frecuente" Value="Particular"></asp:ListItem>
                    </asp:DropDownList>
                </div>

                <div class="col-md-4">
                    <label class="form-label">Giro Comercial</label>
                    <asp:TextBox ID="txtGiro" runat="server" CssClass="form-control" Placeholder="Ej: Servicios Médicos y Cosmetología"></asp:TextBox>
                </div>
                <div class="col-md-5">
                    <label class="form-label">Dirección Comercial</label>
                    <asp:TextBox ID="txtDireccion" runat="server" CssClass="form-control" Placeholder="Av. Providencia 1234, Of. 502, Santiago"></asp:TextBox>
                </div>
                <div class="col-md-3">
                    <label class="form-label">Persona de Contacto</label>
                    <asp:TextBox ID="txtContacto" runat="server" CssClass="form-control" Placeholder="Dra. Andrea Valenzuela"></asp:TextBox>
                </div>

                <div class="col-md-3">
                    <label class="form-label">Correo Electrónico</label>
                    <asp:TextBox ID="txtCorreo" runat="server" CssClass="form-control" TextMode="Email" Placeholder="contacto@clinica.cl"></asp:TextBox>
                </div>
                <div class="col-md-3">
                    <label class="form-label">Teléfono</label>
                    <asp:TextBox ID="txtTelefono" runat="server" CssClass="form-control" Placeholder="+56 9 8765 4321"></asp:TextBox>
                </div>
                <div class="col-md-3">
                    <label class="form-label">Límite de Crédito ($)</label>
                    <asp:TextBox ID="txtLimiteCredito" runat="server" CssClass="form-control" TextMode="Number" Placeholder="0"></asp:TextBox>
                    <small class="text-muted">Monto máximo autorizado para compras a crédito.</small>
                </div>
                <div class="col-md-3">
                    <label class="form-label">Días de Crédito (Plazo)</label>
                    <asp:TextBox ID="txtDiasCredito" runat="server" CssClass="form-control" TextMode="Number" Placeholder="30"></asp:TextBox>
                    <small class="text-muted">Días habituales de pago acordados.</small>
                </div>

                <div class="col-12 text-end mt-4 d-flex justify-content-end align-items-center">
                    <asp:Label ID="lblMensaje" runat="server" CssClass="me-3" style="font-weight:600; font-size: 14px;"></asp:Label>
                    <asp:Button ID="btnCancelar" runat="server" Text="Cancelar Edición" CssClass="btn btn-outline-secondary me-2" Visible="false" OnClick="btnCancelar_Click" />
                    <asp:Button ID="btnGuardar" runat="server" Text="Guardar Cliente" CssClass="btn btn-primary" OnClick="btnGuardar_Click" />
                </div>
            </div>
        </section>

        <!-- TARJETA 2: LISTADO DE CLIENTES -->
        <section class="card-dermocosmetica">
            <div class="d-flex justify-content-between align-items-center mb-3">
                <h2 style="margin: 0;">Cartera de Clientes Registrados</h2>
                <asp:DropDownList ID="ddlFiltroEstado" runat="server" CssClass="form-select form-select-sm" AutoPostBack="true" OnSelectedIndexChanged="ddlFiltroEstado_SelectedIndexChanged" style="width: auto;">
                    <asp:ListItem Text="Todos los clientes" Value="Todos"></asp:ListItem>
                    <asp:ListItem Text="Solo Activos" Value="Activos" Selected="True"></asp:ListItem>
                    <asp:ListItem Text="Solo Inactivos" Value="Inactivos"></asp:ListItem>
                </asp:DropDownList>
            </div>
            <div class="table-responsive">
                <asp:GridView ID="gvClientes" runat="server" CssClass="table table-hover" AutoGenerateColumns="False" GridLines="None" OnRowCommand="gvClientes_RowCommand" EmptyDataText="No hay clientes registrados en la base de datos.">
                    <Columns>
                        <asp:BoundField DataField="IdCliente" HeaderText="ID" />
                        <asp:BoundField DataField="Rut" HeaderText="RUT" />
                        <asp:BoundField DataField="Nombre" HeaderText="Razón Social / Nombre" />
                        <asp:BoundField DataField="Categoria" HeaderText="Tipo" />
                        <asp:BoundField DataField="Giro" HeaderText="Giro" />
                        <asp:BoundField DataField="Contacto" HeaderText="Contacto" />
                        <asp:BoundField DataField="Telefono" HeaderText="Teléfono" />
                        <asp:BoundField DataField="LimiteCredito" HeaderText="Límite Crédito" DataFormatString="${0:N0}" />
                        <asp:BoundField DataField="DiasCredito" HeaderText="Días Créd." />
                        <asp:TemplateField HeaderText="Estado">
                            <ItemTemplate>
                                <span class='<%# Convert.ToInt32(Eval("Activo")) == 1 ? "badge-activo" : "badge-inactivo" %>'>
                                    <%# Convert.ToInt32(Eval("Activo")) == 1 ? "Activo" : "Inactivo" %>
                                </span>
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Acciones">
                            <ItemTemplate>
                                <asp:LinkButton ID="btnEditar" runat="server" CssClass="btn btn-outline-secondary btn-sm me-1" CommandName="Editar" CommandArgument='<%# Eval("IdCliente") %>'>Editar</asp:LinkButton>
                                <asp:LinkButton ID="btnEstado" runat="server" CssClass='<%# Convert.ToInt32(Eval("Activo")) == 1 ? "btn btn-outline-warning btn-sm" : "btn btn-outline-success btn-sm" %>' 
                                    CommandName='<%# Convert.ToInt32(Eval("Activo")) == 1 ? "Desactivar" : "Activar" %>' 
                                    CommandArgument='<%# Eval("IdCliente") %>'>
                                    <%# Convert.ToInt32(Eval("Activo")) == 1 ? "Desactivar" : "Reactivar" %>
                                </asp:LinkButton>
                            </ItemTemplate>
                        </asp:TemplateField>
                    </Columns>
                </asp:GridView>
            </div>
        </section>

    </div>
</asp:Content>
