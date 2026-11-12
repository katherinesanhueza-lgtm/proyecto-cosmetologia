<%@ Page Title="Cotizaciones" Language="C#" MasterPageFile="~/Contabilidad.Master" AutoEventWireup="true" CodeBehind="Cotizaciones.aspx.cs" Inherits="trabajo_ing_software.Cotizaciones" ResponseEncoding="utf-8" %>

<asp:Content ID="Estilos" ContentPlaceHolderID="EstilosPagina" runat="server">
    <link href="<%: ResolveUrl("~/Content/ComprasResumen.css?v=1") %>" rel="stylesheet" />
    <link href="<%: ResolveUrl("~/Content/Estilos.css") %>" rel="stylesheet" type="text/css" />
</asp:Content>

<asp:Content ID="Contenido" ContentPlaceHolderID="MainContent" runat="server">
    <div class="dashboard compras-resumen">
        
        <header class="dashboard-header">
            <div>
                <p class="dashboard-etiqueta">Módulo de ventas</p>
                <h1>Presupuestos y Cotizaciones</h1>
                <p class="dashboard-descripcion">Generación de documentos comerciales y valorización de productos.</p>
            </div>
        </header>

        <!-- TARJETA 1: FORMULARIO -->
        <section class="card-dermocosmetica" style="margin-bottom: 24px;">
            <h2 style="margin-bottom: 16px;">Generar Nueva Cotización</h2>
            
            <div class="row g-3">
                <div class="col-md-6">
                    <label class="form-label fw-bold text-secondary">Cliente</label>
                    <asp:DropDownList ID="ddlClientes" runat="server" CssClass="form-select"></asp:DropDownList>
                </div>
                <div class="col-md-6">
                    <label class="form-label fw-bold text-secondary">Estado</label>
                    <asp:DropDownList ID="ddlEstado" runat="server" CssClass="form-select">
                        <asp:ListItem Text="Vigente" Value="Vigente"></asp:ListItem>
                        <asp:ListItem Text="Aceptado" Value="Aceptado"></asp:ListItem>
                        <asp:ListItem Text="Vencido" Value="Vencido"></asp:ListItem>
                        <asp:ListItem Text="Rechazado" Value="Rechazado"></asp:ListItem>
                    </asp:DropDownList>
                </div>
                
                <div class="col-12 mt-4">
                    <h6 class="text-secondary fw-bold border-bottom pb-2">Agregar Productos al Presupuesto</h6>
                </div>
                
                <div class="col-md-5">
                    <label class="form-label">Producto</label>
                    <asp:DropDownList ID="ddlProductos" runat="server" CssClass="form-select" AutoPostBack="true" OnSelectedIndexChanged="ddlProductos_SelectedIndexChanged"></asp:DropDownList>
                </div>
                <div class="col-md-2">
                    <label class="form-label">Cantidad</label>
                    <asp:TextBox ID="txtCantidad" runat="server" CssClass="form-control" TextMode="Number" Text="1" AutoPostBack="true"></asp:TextBox>
                </div>
                <div class="col-md-3">
                    <label class="form-label">Precio Unitario ($)</label>
                    <asp:TextBox ID="txtPrecio" runat="server" CssClass="form-control" TextMode="Number" ReadOnly="true"></asp:TextBox>
                </div>
                <div class="col-md-2 d-flex align-items-end">
                    <asp:Button ID="btnAgregarProducto" runat="server" Text="Añadir" CssClass="btn btn-outline-secondary w-100" OnClick="btnAgregarProducto_Click" />
                </div>

                <div class="col-12 mt-4">
                    <div class="table-responsive">
                        <asp:GridView ID="gvDetalleCotizacion" runat="server" CssClass="table table-hover" AutoGenerateColumns="False" GridLines="None" EmptyDataText="Aún no hay productos en esta cotización.">
                            <Columns>
                                <asp:BoundField DataField="Producto" HeaderText="Producto" />
                                <asp:BoundField DataField="Cantidad" HeaderText="Cantidad" />
                                <asp:BoundField DataField="Precio" HeaderText="Precio Unit." />
                                <asp:BoundField DataField="Subtotal" HeaderText="Subtotal" />
                            </Columns>
                        </asp:GridView>
                    </div>
                </div>

                <div class="col-12 text-end mt-4 border-top pt-3">
                    <h3 style="margin-bottom: 15px;">Total: $<asp:Label ID="lblTotal" runat="server" Text="0"></asp:Label></h3>
                    <asp:Button ID="btnGuardarCotizacion" runat="server" Text="Guardar Cotización" CssClass="btn-dermo-primary" OnClick="btnGuardarCotizacion_Click" />
                </div>
            </div>
        </section>

        <!-- TARJETA 2: HISTORIAL -->
        <section class="card-dermocosmetica">
            <h2 style="margin-bottom: 16px;">Historial de Cotizaciones</h2>
            <div class="table-responsive">
                <asp:GridView ID="gvHistorialCotizaciones" runat="server" CssClass="table table-hover" AutoGenerateColumns="False" GridLines="None" OnRowCommand="gvHistorialCotizaciones_RowCommand" EmptyDataText="No hay cotizaciones registradas.">
                    <Columns>
                        <asp:BoundField DataField="IdCotizacion" HeaderText="ID" />
                        <asp:BoundField DataField="Cliente" HeaderText="Cliente" />
                        <asp:BoundField DataField="FechaEmision" HeaderText="Fecha" DataFormatString="{0:dd/MM/yyyy}" />
                        <asp:BoundField DataField="Estado" HeaderText="Estado" />
                        <asp:BoundField DataField="Total" HeaderText="Total ($)" DataFormatString="{0:N0}" />
                        <asp:TemplateField HeaderText="Acciones">
                            <ItemTemplate>
                                <asp:LinkButton ID="btnVer" runat="server" CssClass="btn btn-outline-secondary btn-sm" CommandName="VerDetalle" CommandArgument='<%# Eval("IdCotizacion") %>'>Ver</asp:LinkButton>
                            </ItemTemplate>
                        </asp:TemplateField>
                    </Columns>
                </asp:GridView>
            </div>
        </section>

    </div>
</asp:Content>