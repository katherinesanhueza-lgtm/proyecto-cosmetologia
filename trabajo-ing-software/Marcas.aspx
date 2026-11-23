<%@ Page Title="Marcas" Language="C#" MasterPageFile="~/Contabilidad.Master" Inherits="trabajo_ing_software.PaginaCompras" ResponseEncoding="utf-8" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="trabajo_ing_software.CapaNegocio" %>
<script runat="server">
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            CargarMarcas();
        }
    }

    protected override void OnPreRender(EventArgs e)
    {
        base.OnPreRender(e);
        btnNuevaMarca.Visible = PuedeGuardarCompras;
        if (!PuedeGuardarCompras) formulario.Visible = false;
        if (lista.HeaderRow != null)
            lista.HeaderRow.TableSection = TableRowSection.TableHeader;
    }

    private void CargarMarcas()
    {
        lista.DataSource = ComprasServicio.ListarMarcas();
        lista.DataBind();
        if (lista.HeaderRow != null)
            lista.HeaderRow.TableSection = TableRowSection.TableHeader;
    }

    protected void NuevaMarca(object sender, EventArgs e)
    {
        ExigirEscrituraCompras();
        hfIdMarca.Value = "";
        nombre.Text = "";
        descripcion.Text = "";
        activa.Checked = true;
        lblTituloForm.Text = "Registrar nueva marca";
        lblSubtituloForm.Text = "Ingreso de marca dermocosmética al catálogo de compras.";
        mensaje.Visible = false;
        formulario.Visible = true;
    }

    protected void Cancelar(object sender, EventArgs e)
    {
        hfIdMarca.Value = "";
        nombre.Text = "";
        descripcion.Text = "";
        activa.Checked = true;
        mensaje.Visible = false;
        formulario.Visible = false;
    }

    protected void Lista_RowCommand(object sender, GridViewCommandEventArgs e)
    {
        if (e.CommandName == "EditarMarca")
        {
            int id;
            if (!int.TryParse(Convert.ToString(e.CommandArgument), out id))
                return;

            DataRow r = ComprasServicio.ObtenerMarca(id);
            if (r != null)
            {
                hfIdMarca.Value = id.ToString();
                nombre.Text = Convert.ToString(r["Nombre"]);
                descripcion.Text = Convert.ToString(r["Descripcion"]);
                activa.Checked = Convert.ToBoolean(r["Activo"]);
                lblTituloForm.Text = "Editar marca seleccionada";
                lblSubtituloForm.Text = "Actualice el nombre, la descripción comercial o la vigencia de la marca.";
                mensaje.Visible = false;
                formulario.Visible = true;
            }
        }
    }

    protected void Guardar(object sender, EventArgs e)
    {
        ExigirEscrituraCompras();
        try
        {
            int idParsed;
            int? idEditado = int.TryParse(hfIdMarca.Value, out idParsed) && idParsed > 0 ? (int?)idParsed : null;
            ComprasServicio.GuardarMarca(idEditado, nombre.Text, descripcion.Text, activa.Checked);
            hfIdMarca.Value = "";
            nombre.Text = "";
            descripcion.Text = "";
            activa.Checked = true;
            formulario.Visible = false;
            CargarMarcas();
            lblEstado.Text = idEditado.HasValue ? "Marca actualizada correctamente." : "Nueva marca registrada correctamente.";
            lblEstado.CssClass = "alert alert-success d-block mb-3";
            lblEstado.Visible = true;
        }
        catch (Exception ex)
        {
            mensaje.Text = trabajo_ing_software.ConexionErp.MensajeError(ex);
            mensaje.CssClass = "alert alert-danger d-block mt-3 mb-0";
            mensaje.Visible = true;
            formulario.Visible = true;
        }
    }
</script>

<asp:Content ID="Estilos" ContentPlaceHolderID="EstilosPagina" runat="server">
    <style>
        .chk-marca-wrap {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            height: 38px;
            padding: 0 12px;
            border: 1px solid #dcd3ca;
            border-radius: 9px;
            background: #fbfaf8;
            font-size: 0.85rem;
            font-weight: 500;
            color: #24211e;
            white-space: nowrap;
        }
        .chk-marca-wrap input[type="checkbox"] {
            width: 16px;
            height: 16px;
            accent-color: #796047;
            margin: 0;
            cursor: pointer;
        }
        .badge-marca-activa {
            background: #E8F8F0;
            color: #27AE60;
            padding: 4px 12px;
            border-radius: 12px;
            font-size: 12px;
            font-weight: 600;
            display: inline-block;
        }
        .badge-marca-inactiva {
            background: #FDEDEC;
            color: #C0392B;
            padding: 4px 12px;
            border-radius: 12px;
            font-size: 12px;
            font-weight: 600;
            display: inline-block;
        }
    </style>
</asp:Content>

<asp:Content runat="server" ContentPlaceHolderID="MainContent">
    <div class="dashboard compras-resumen">
        <asp:HiddenField runat="server" ID="hfIdMarca" Value="" />

        <header class="dashboard-header" style="display: flex; justify-content: space-between; align-items: flex-end; flex-wrap: wrap; gap: 14px;">
            <div>
                <p class="dashboard-etiqueta">M&Oacute;DULO DE COMPRAS &bull; CAT&Aacute;LOGO DE MARCAS</p>
                <h1>Marcas</h1>
                <p class="dashboard-descripcion">Administraci&oacute;n independiente de marcas dermocosm&eacute;ticas homologadas, su descripci&oacute;n comercial y vigencia.</p>
            </div>
            <div class="d-flex gap-2 flex-wrap">
                <a href="Laboratorios.aspx" class="btn btn-outline-secondary">Ir a Laboratorios</a>
                <asp:Button runat="server" ID="btnNuevaMarca" OnClick="NuevaMarca" Text="+ Nueva Marca" CssClass="btn btn-primary" CausesValidation="false" />
            </div>
        </header>

        <asp:Label runat="server" ID="lblEstado" Visible="false" EnableViewState="false" />

        <!-- MODAL FLOTANTE CON ANIMACION DE MARCAS -->
        <asp:Panel runat="server" ID="formulario" CssClass="modal-overlay" Visible="false">
            <div class="modal-content-card modal-sm-card">
                <div class="modal-header-dermo">
                    <div>
                        <span class="pill-badge" style="font-size: 10px; padding: 3px 10px;">CAT&Aacute;LOGO DE MARCAS</span>
                        <h2 style="font-size: 22px; margin: 6px 0 2px 0; font-family: 'Playfair Display', Georgia, serif; color: var(--color-texto);">
                            <asp:Literal runat="server" ID="lblTituloForm" Text="Registrar nueva marca" />
                        </h2>
                        <div style="font-size: 12px; color: var(--color-texto-suave);">
                            <asp:Literal runat="server" ID="lblSubtituloForm" Text="Ingreso de marca dermocosm&eacute;tica al cat&aacute;logo de compras." />
                        </div>
                    </div>
                    <asp:LinkButton runat="server" ID="btnCerrarModalX" OnClick="Cancelar" CausesValidation="false"
                        CssClass="btn btn-outline-secondary btn-sm modal-close-x" ToolTip="Cerrar ventana">&times;</asp:LinkButton>
                </div>

                <div class="mb-3">
                    <asp:Label runat="server" AssociatedControlID="nombre" CssClass="form-label" Text="Nombre de la marca *" />
                    <asp:TextBox runat="server" ID="nombre" MaxLength="100" CssClass="form-control" placeholder="Ej: La Roche-Posay, ISDIN, CeraVe..." />
                </div>

                <div class="mb-3">
                    <asp:Label runat="server" AssociatedControlID="descripcion" CssClass="form-label" Text="Descripci&oacute;n" />
                    <asp:TextBox runat="server" ID="descripcion" MaxLength="255" CssClass="form-control" placeholder="L&iacute;nea dermocosm&eacute;tica o especialidad..." />
                </div>

                <div class="mb-2">
                    <span class="chk-marca-wrap">
                        <asp:CheckBox runat="server" ID="activa" Checked="true" Text="Marca activa en el cat&aacute;logo" />
                    </span>
                </div>

                <asp:Label runat="server" ID="mensaje" Visible="false" />

                <div class="modal-footer-dermo">
                    <asp:Button runat="server" ID="btnCancelarMarca" OnClick="Cancelar" Text="Cancelar" CssClass="btn btn-outline-secondary" CausesValidation="false" />
                    <asp:Button runat="server" ID="btnGuardarMarca" OnClick="Guardar" Text="Guardar marca" CssClass="btn btn-primary" />
                </div>
            </div>
        </asp:Panel>

        <section class="card-dermocosmetica">
            <h2 style="font-size: 1.15rem; font-weight: 600; margin-bottom: 14px;">Listado de marcas registradas</h2>
            <div class="table-responsive">
                <asp:GridView runat="server" ID="lista" CssClass="table table-hover align-middle" GridLines="None"
                    AutoGenerateColumns="False" DataKeyNames="IdMarca" OnRowCommand="Lista_RowCommand"
                    EmptyDataText="No hay marcas registradas en el cat&aacute;logo.">
                    <Columns>
                        <asp:BoundField DataField="IdMarca" HeaderText="ID" />
                        <asp:TemplateField HeaderText="Marca">
                            <ItemTemplate>
                                <strong style="color: #24211e;"><%#: Eval("Nombre") %></strong>
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:BoundField DataField="Descripcion" HeaderText="Descripci&oacute;n" />
                        <asp:TemplateField HeaderText="Estado">
                            <ItemTemplate>
                                <span class='<%# Convert.ToBoolean(Eval("Activo")) ? "badge-marca-activa" : "badge-marca-inactiva" %>'>
                                    <%#: Eval("Estado") %>
                                </span>
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Acci&oacute;n">
                            <ItemTemplate>
                                <asp:Button runat="server" ID="btnEditarMarca" CommandName="EditarMarca"
                                    CommandArgument='<%# Eval("IdMarca") %>' Text="Editar"
                                    CssClass="btn btn-outline-secondary btn-sm" CausesValidation="false" />
                            </ItemTemplate>
                        </asp:TemplateField>
                    </Columns>
                </asp:GridView>
            </div>
        </section>
    </div>
</asp:Content>
