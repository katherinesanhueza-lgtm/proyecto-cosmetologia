<%@ Page Title="Gestión de Despachos" Language="C#" MasterPageFile="~/Contabilidad.Master" AutoEventWireup="true" CodeBehind="Despachos.aspx.cs" Inherits="trabajo_ing_software.Despachos" ResponseEncoding="utf-8" %>

<asp:Content ID="Estilos" ContentPlaceHolderID="EstilosPagina" runat="server">
    <link href="<%: ResolveUrl("~/Content/ComprasResumen.css?v=1") %>" rel="stylesheet" />
    <style>
        .card-dermocosmetica h2 { font-size: 1.25rem; font-weight: 600; margin-bottom: 14px; }
        .form-label { font-size: 0.875rem; font-weight: 500; color: #24211e; margin-bottom: 6px; }
        .table { font-size: 0.85rem; }
        .table th { font-size: 0.85rem; }
        .table td { font-size: 0.85rem; }
        .badge-pendiente { background-color: #FFF3CD; color: #856404; padding: 4px 10px; border-radius: 12px; font-weight: 600; font-size: 12px; display: inline-block; }
        .badge-preparacion { background-color: #EBF3FA; color: #2980B9; padding: 4px 10px; border-radius: 12px; font-weight: 600; font-size: 12px; display: inline-block; }
        .badge-ruta { background-color: #F3E5F5; color: #6A1B9A; padding: 4px 10px; border-radius: 12px; font-weight: 600; font-size: 12px; display: inline-block; }
        .badge-entregado { background-color: #E8F8F0; color: #27AE60; padding: 4px 10px; border-radius: 12px; font-weight: 600; font-size: 12px; display: inline-block; }
        .badge-cancelado { background-color: #FDEDEC; color: #C0392B; padding: 4px 10px; border-radius: 12px; font-weight: 600; font-size: 12px; display: inline-block; }
    </style>
</asp:Content>

<asp:Content ID="Contenido" ContentPlaceHolderID="MainContent" runat="server">
    <div class="dashboard compras-resumen">
        
        <header class="dashboard-header">
            <div>
                <p class="dashboard-etiqueta">Módulo de ventas · Logística y distribución (RF-VEN-08)</p>
                <h1>Gestión y Control de Despachos</h1>
                <p class="dashboard-descripcion">Programación de envíos, asignación de transportistas, seguimiento de ruta y registro de entregas.</p>
            </div>
        </header>

        <!-- TARJETA 1: FORMULARIO DE PROGRAMACIÓN -->
        <section class="card-dermocosmetica" style="margin-bottom: 24px;">
            <h2 style="margin-bottom: 16px;">Programar Nuevo Despacho</h2>
            
            <div class="row g-3">
                <div class="col-md-4">
                    <label class="form-label">Documento de Venta *</label>
                    <asp:DropDownList ID="ddlDocumentoOrigen" runat="server" CssClass="form-select" AutoPostBack="true"></asp:DropDownList>
                </div>
                <div class="col-md-4">
                    <label class="form-label">Cliente Destinatario</label>
                    <asp:TextBox ID="txtCliente" runat="server" CssClass="form-control" ReadOnly="true" Placeholder="Se completa automáticamente..."></asp:TextBox>
                </div>
                <div class="col-md-4">
                    <label class="form-label">Estado Inicial del Despacho</label>
                    <asp:DropDownList ID="ddlEstadoDespacho" runat="server" CssClass="form-select">
                        <asp:ListItem Text="Pendiente de Preparación" Value="Pendiente"></asp:ListItem>
                        <asp:ListItem Text="En Preparación (Bodega)" Value="En Preparacion"></asp:ListItem>
                        <asp:ListItem Text="En Ruta / Despachado" Value="En Ruta"></asp:ListItem>
                        <asp:ListItem Text="Entregado al Cliente" Value="Entregado"></asp:ListItem>
                    </asp:DropDownList>
                </div>

                <div class="col-md-4">
                    <label class="form-label">Fecha Estimada de Entrega *</label>
                    <asp:TextBox ID="txtFechaEstimada" runat="server" CssClass="form-control" TextMode="Date"></asp:TextBox>
                </div>
                <div class="col-md-4">
                    <label class="form-label">Transportista Asignado *</label>
                    <asp:DropDownList ID="ddlTransportista" runat="server" CssClass="form-select">
                        <asp:ListItem Text="-- Seleccione Transportista --" Value=""></asp:ListItem>
                        <asp:ListItem Text="Starken Express" Value="Starken"></asp:ListItem>
                        <asp:ListItem Text="Chilexpress Courier" Value="Chilexpress"></asp:ListItem>
                        <asp:ListItem Text="Blue Express" Value="Blue Express"></asp:ListItem>
                        <asp:ListItem Text="Flota Propia Dermo" Value="Reparto Propio"></asp:ListItem>
                    </asp:DropDownList>
                </div>
                <div class="col-md-4">
                    <label class="form-label">Observaciones / Dirección Entrega</label>
                    <asp:TextBox ID="txtObservaciones" runat="server" CssClass="form-control" Placeholder="Ej: Dejar en conserjería..."></asp:TextBox>
                </div>

                <div class="col-12 text-end mt-4 d-flex justify-content-between align-items-center">
                    <div>
                        <asp:Label ID="lblMensajeDespacho" runat="server" style="font-weight:600;"></asp:Label>
                    </div>
                    <div>
                        <asp:Button ID="btnGuardarDespacho" runat="server" Text="Programar Despacho" CssClass="btn btn-primary" OnClick="btnGuardarDespacho_Click" />
                    </div>
                </div>
            </div>
        </section>

        <!-- TARJETA 2: CONTROL DE ESTADOS Y REGISTRO DE ENTREGAS -->
        <section class="card-dermocosmetica">
            <div class="d-flex justify-content-between align-items-center mb-3">
                <h2 style="margin: 0;">Seguimiento y Registro de Entregas (RF-VEN-08)</h2>
                <div class="d-flex align-items-center gap-2">
                    <label class="text-secondary small fw-bold mb-0">Filtrar por Estado:</label>
                    <asp:DropDownList ID="ddlFiltroEstado" runat="server" CssClass="form-select form-select-sm" AutoPostBack="true" OnSelectedIndexChanged="ddlFiltroEstado_SelectedIndexChanged" style="width:auto;">
                        <asp:ListItem Text="Todos los despachos" Value="Todos"></asp:ListItem>
                        <asp:ListItem Text="Pendientes" Value="Pendiente"></asp:ListItem>
                        <asp:ListItem Text="En Preparación" Value="En Preparacion"></asp:ListItem>
                        <asp:ListItem Text="En Ruta" Value="En Ruta"></asp:ListItem>
                        <asp:ListItem Text="Entregados" Value="Entregado"></asp:ListItem>
                    </asp:DropDownList>
                </div>
            </div>

            <div class="table-responsive">
                <asp:GridView ID="gvDespachos" runat="server" CssClass="table table-hover" AutoGenerateColumns="False" GridLines="None" OnRowCommand="gvDespachos_RowCommand" EmptyDataText="No hay despachos registrados.">
                    <Columns>
                        <asp:BoundField DataField="IdDespacho" HeaderText="ID" />
                        <asp:BoundField DataField="Documento" HeaderText="Documento Venta" />
                        <asp:BoundField DataField="Cliente" HeaderText="Cliente" />
                        <asp:BoundField DataField="Tipo" HeaderText="Transportista" />
                        <asp:BoundField DataField="FechaEstimada" HeaderText="F. Estimada" DataFormatString="{0:dd/MM/yyyy}" />
                        <asp:BoundField DataField="FechaEntrega" HeaderText="F. Entrega Real" DataFormatString="{0:dd/MM/yyyy}" NullDisplayText="Pendiente" />
                        <asp:TemplateField HeaderText="Estado">
                            <ItemTemplate>
                                <span class='<%# GetClaseEstado(Eval("Estado").ToString()) %>'>
                                    <%# Eval("Estado") %>
                                </span>
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:BoundField DataField="Observaciones" HeaderText="Observaciones" NullDisplayText="—" />
                        <asp:TemplateField HeaderText="Acciones / Control de Ruta">
                            <ItemTemplate>
                                <asp:LinkButton ID="btnPreparar" runat="server" CssClass="btn btn-outline-primary btn-sm me-1" 
                                    CommandName="CambiarEstado" CommandArgument='<%# Eval("IdDespacho") + "|En Preparacion" %>'
                                    Visible='<%# Eval("Estado").ToString() == "Pendiente" %>'>
                                    📦 A Preparación
                                </asp:LinkButton>
                                <asp:LinkButton ID="btnRuta" runat="server" CssClass="btn btn-outline-info btn-sm me-1" 
                                    CommandName="CambiarEstado" CommandArgument='<%# Eval("IdDespacho") + "|En Ruta" %>'
                                    Visible='<%# Eval("Estado").ToString() == "En Preparacion" %>'>
                                    🚚 Enviar a Ruta
                                </asp:LinkButton>
                                <asp:LinkButton ID="btnEntregar" runat="server" CssClass="btn btn-success btn-sm me-1" 
                                    CommandName="RegistrarEntrega" CommandArgument='<%# Eval("IdDespacho") %>'
                                    Visible='<%# Eval("Estado").ToString() == "En Ruta" || Eval("Estado").ToString() == "En Preparacion" || Eval("Estado").ToString() == "Pendiente" %>'>
                                    ✓ Registrar Entrega
                                </asp:LinkButton>
                                <asp:LinkButton ID="btnCancelar" runat="server" CssClass="btn btn-outline-danger btn-sm" 
                                    CommandName="CambiarEstado" CommandArgument='<%# Eval("IdDespacho") + "|Cancelado" %>'
                                    Visible='<%# Eval("Estado").ToString() != "Entregado" && Eval("Estado").ToString() != "Cancelado" %>'
                                    OnClientClick="return confirm('¿Seguro que deseas anular este despacho?');">
                                    Anular
                                </asp:LinkButton>
                            </ItemTemplate>
                        </asp:TemplateField>
                    </Columns>
                </asp:GridView>
            </div>
        </section>

    </div>
</asp:Content>
