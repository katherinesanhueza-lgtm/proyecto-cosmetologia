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

        <section class="card-dermocosmetica mb-4">
            <div style="display: flex; justify-content: space-between; align-items: flex-end; flex-wrap: wrap; gap: 14px;">
                <div style="min-width: 240px;">
                    <asp:Label runat="server" AssociatedControlID="modulo" CssClass="form-label" Text="Filtrar por m&oacute;dulo" />
                    <asp:DropDownList runat="server" ID="modulo" AutoPostBack="true" CssClass="form-select">
                        <asp:ListItem Value="">Todos los m&oacute;dulos</asp:ListItem>
                        <asp:ListItem Value="Compras">Compras</asp:ListItem>
                        <asp:ListItem Value="Ventas">Ventas</asp:ListItem>
                        <asp:ListItem Value="Contabilidad">Contabilidad</asp:ListItem>
                        <asp:ListItem Value="Seguridad">Seguridad</asp:ListItem>
                    </asp:DropDownList>
                </div>
                <div style="font-size: 0.85rem; color: #7a756c;">
                    Mostrando <strong style="color: #24211e;"><asp:Literal runat="server" ID="lblTotalEventos" Text="0" /></strong> eventos recientes (m&aacute;x. 500)
                </div>
            </div>
        </section>

        <section class="card-dermocosmetica">
            <h2 style="font-size: 1.15rem; font-weight: 600; margin-bottom: 14px;">Registro de eventos</h2>
            <div class="table-responsive">
                <asp:GridView runat="server" ID="eventos" CssClass="table table-hover align-middle" GridLines="None"
                    AutoGenerateColumns="False" EmptyDataText="Sin operaciones registradas para el filtro seleccionado.">
                    <Columns>
                        <asp:BoundField DataField="Fecha" HeaderText="Fecha y hora" DataFormatString="{0:dd/MM/yyyy HH:mm:ss}" />
                        <asp:BoundField DataField="Responsable" HeaderText="Responsable" />
                        <asp:BoundField DataField="Modulo" HeaderText="M&oacute;dulo" />
                        <asp:BoundField DataField="Entidad" HeaderText="Entidad" />
                        <asp:TemplateField HeaderText="Acci&oacute;n">
                            <ItemTemplate>
                                <span class='<%# ClaseAccion(Eval("Accion")) %>'><%#: Eval("Accion") %></span>
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:BoundField DataField="Registro" HeaderText="ID Registro" />
                    </Columns>
                </asp:GridView>
            </div>
        </section>
    </div>
</asp:Content>
