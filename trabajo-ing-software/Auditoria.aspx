<%@ Page Title="Auditoría de operaciones" Language="C#" MasterPageFile="~/Contabilidad.Master" ResponseEncoding="utf-8" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="MySql.Data.MySqlClient" %>
<script runat="server">
    protected override void OnInit(EventArgs e)
    {
        if (Session["IdUsuario"] == null) { Response.Redirect("~/Login.aspx"); return; }
        if (Convert.ToString(Session["RolUsuario"]) != "Administrador") throw new HttpException(403, "Acceso reservado a administración.");
        ViewStateUserKey = Session.SessionID;
        base.OnInit(e);
    }

    protected override void OnPreRender(EventArgs e)
    {
        base.OnPreRender(e);
        using (var con = trabajo_ing_software.ConexionErp.Crear(System.Configuration.ConfigurationManager.ConnectionStrings["DefaultConnection"].ConnectionString))
        using (var cmd = new MySqlCommand(@"SELECT a.Fecha, COALESCE(u.Nombre, CAST(a.IdUsuario AS CHAR), 'Proceso de base de datos') AS Responsable,
            a.Modulo, a.Entidad, a.Accion, a.Registro FROM auditoriaerp a LEFT JOIN usuario u USING(IdUsuario)
            WHERE (@m='' OR a.Modulo=@m) ORDER BY a.IdEvento DESC LIMIT 500", con))
        using (var da = new MySqlDataAdapter(cmd))
        {
            cmd.Parameters.AddWithValue("@m", modulo.SelectedValue);
            var tabla = new DataTable();
            da.Fill(tabla);
            lblTotalEventos.Text = tabla.Rows.Count.ToString();
            eventos.DataSource = tabla;
            eventos.DataBind();
            if (eventos.HeaderRow != null)
                eventos.HeaderRow.TableSection = TableRowSection.TableHeader;
        }
    }

    protected string ClaseAccion(object accion)
    {
        string valor = Convert.ToString(accion).ToUpperInvariant();
        if (valor == "INSERT") return "badge-aud-insert";
        if (valor == "DELETE") return "badge-aud-delete";
        return "badge-aud-update";
    }
</script>

<asp:Content ID="Estilos" ContentPlaceHolderID="EstilosPagina" runat="server">
    <style>
        .badge-aud-insert { background: #E8F8F0; color: #27AE60; padding: 3px 10px; border-radius: 10px; font-size: 11px; font-weight: 600; display: inline-block; }
        .badge-aud-update { background: #EBF3FA; color: #2980B9; padding: 3px 10px; border-radius: 10px; font-size: 11px; font-weight: 600; display: inline-block; }
        .badge-aud-delete { background: #FDEDEC; color: #C0392B; padding: 3px 10px; border-radius: 10px; font-size: 11px; font-weight: 600; display: inline-block; }
    </style>
</asp:Content>

<asp:Content runat="server" ContentPlaceHolderID="MainContent">
    <div class="dashboard compras-resumen">
        <header class="dashboard-header" style="display: flex; justify-content: space-between; align-items: flex-end; flex-wrap: wrap; gap: 14px;">
            <div>
                <p class="dashboard-etiqueta">M&Oacute;DULO DE SEGURIDAD &bull; TRAZABILIDAD INMUTABLE</p>
                <h1>Auditor&iacute;a de operaciones</h1>
                <p class="dashboard-descripcion">Bit&aacute;cora protegida de solo lectura con registro autom&aacute;tico de usuario, m&oacute;dulo, entidad, acci&oacute;n y fecha de cada operaci&oacute;n.</p>
            </div>
        </header>

        <section class="card-dermocosmetica mb-4" style="padding: 14px 20px;">
            <div style="display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 14px;">
                <div style="display: flex; align-items: center; gap: 12px; flex-wrap: wrap;">
                    <asp:Label runat="server" AssociatedControlID="modulo" CssClass="form-label mb-0 fw-semibold" Text="Filtrar por m&oacute;dulo:" />
                    <asp:DropDownList runat="server" ID="modulo" AutoPostBack="true" CssClass="form-select" style="min-width: 220px; width: auto;">
                        <asp:ListItem Value="">Todos los m&oacute;dulos</asp:ListItem>
                        <asp:ListItem Value="Compras">Compras</asp:ListItem>
                        <asp:ListItem Value="Ventas">Ventas</asp:ListItem>
                        <asp:ListItem Value="Contabilidad">Contabilidad</asp:ListItem>
                        <asp:ListItem Value="Seguridad">Seguridad</asp:ListItem>
                    </asp:DropDownList>
                </div>
                <span class="pill-badge" style="background-color: #FAF8F5; font-size: 11px;">
                    &bull; <asp:Literal runat="server" ID="lblTotalEventos" Text="0" /> Eventos recientes (m&aacute;x. 500)
                </span>
            </div>
        </section>

        <section class="table-dermo-container">
            <div class="dermo-table-headbar">
                <div class="dermo-table-headbar-title">
                    <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#7A5E47" stroke-width="2" aria-hidden="true"><path d="M9 5H7a2 2 0 0 0-2 2v12a2 2 0 0 0 2 2h10a2 2 0 0 0 2-2V7a2 2 0 0 0-2-2h-2"></path><rect x="9" y="3" width="6" height="4" rx="1"></rect><path d="M9 14l2 2 4-4"></path></svg>
                    <h2>Registro de Eventos</h2>
                </div>
                <span class="dermo-pill-info">Solo lectura</span>
            </div>
            <div class="table-responsive">
                <asp:GridView runat="server" ID="eventos" CssClass="table table-hover align-middle" GridLines="None"
                    AutoGenerateColumns="False" EmptyDataText="Sin operaciones registradas para el filtro seleccionado.">
                    <Columns>
                        <asp:BoundField DataField="Fecha" HeaderText="Fecha y hora" DataFormatString="{0:dd/MM/yyyy HH:mm:ss}" ItemStyle-CssClass="text-nowrap" />
                        <asp:BoundField DataField="Responsable" HeaderText="Responsable" ItemStyle-CssClass="fw-semibold" />
                        <asp:TemplateField HeaderText="M&oacute;dulo" HeaderStyle-CssClass="text-center" ItemStyle-CssClass="text-center">
                            <ItemTemplate>
                                <span class="dermo-pill-neutral"><%#: Eval("Modulo") %></span>
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:BoundField DataField="Entidad" HeaderText="Entidad" />
                        <asp:TemplateField HeaderText="Acci&oacute;n" HeaderStyle-CssClass="text-center" ItemStyle-CssClass="text-center">
                            <ItemTemplate>
                                <span class='<%# ClaseAccion(Eval("Accion")) %>'><%#: Eval("Accion") %></span>
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:BoundField DataField="Registro" HeaderText="ID Registro" HeaderStyle-CssClass="text-center" ItemStyle-CssClass="text-center text-nowrap" />
                    </Columns>
                </asp:GridView>
            </div>
        </section>
    </div>
</asp:Content>
