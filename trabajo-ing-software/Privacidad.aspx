<%@ Page Title="Protección de Datos Personales" Language="C#" MasterPageFile="~/Contabilidad.Master" ResponseEncoding="utf-8" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Text" %>
<%@ Import Namespace="trabajo_ing_software.CapaNegocio" %>
<script runat="server">
    protected bool EsAdmin => string.Equals(Convert.ToString(Session["RolUsuario"]), "Administrador", StringComparison.OrdinalIgnoreCase);

    protected override void OnPreRender(EventArgs e)
    {
        base.OnPreRender(e);
        pnlArcoAdmin.Visible = EsAdmin;
        if (EsAdmin)
        {
            gvClientesPrivacidad.DataSource = ProteccionDatosServicio.ListarClientes();
            gvClientesPrivacidad.DataBind();
            if (gvClientesPrivacidad.HeaderRow != null)
                gvClientesPrivacidad.HeaderRow.TableSection = TableRowSection.TableHeader;
        }
    }

    protected void gvClientesPrivacidad_RowCommand(object sender, GridViewCommandEventArgs e)
    {
        if (!EsAdmin)
            throw new HttpException(403, "Acción reservada para administración.");

        if (!int.TryParse(Convert.ToString(e.CommandArgument), out int idCliente) || idCliente <= 0)
            return;

        try
        {
            if (e.CommandName == "ExportarJson")
            {
                string json = ProteccionDatosServicio.ExportarFichaPersonalJson(idCliente);
                byte[] bytes = new UTF8Encoding(false).GetBytes(json);
                Response.Clear();
                Response.ContentType = "application/json; charset=utf-8";
                Response.AddHeader("Content-Disposition", "attachment; filename=Datos_Personales_Cliente_" + idCliente + ".json");
                Response.BinaryWrite(bytes);
                Response.Flush();
                Response.SuppressContent = true;
                Context.ApplicationInstance.CompleteRequest();
            }
            else if (e.CommandName == "Anonimizar")
            {
                ProteccionDatosServicio.AnonimizarClienteInactivo(idCliente);
                lblMensajeArco.Text = "Datos personales identificables del cliente #" + idCliente + " anonimizados correctamente (se conserva la trazabilidad tributaria legal).";
                lblMensajeArco.CssClass = "alert alert-success d-block mb-3";
                lblMensajeArco.Visible = true;
            }
        }
        catch (Exception ex)
        {
            lblMensajeArco.Text = trabajo_ing_software.ConexionErp.MensajeError(ex);
            lblMensajeArco.CssClass = "alert alert-danger d-block mb-3";
            lblMensajeArco.Visible = true;
        }
    }
</script>

<asp:Content ID="Estilos" ContentPlaceHolderID="EstilosPagina" runat="server">
    <style>
        .priv-grid {
            display: grid;
            grid-template-columns: repeat(2, 1fr);
            gap: 18px;
            margin-bottom: 24px;
        }
        @media (max-width: 820px) {
            .priv-grid {
                grid-template-columns: 1fr;
            }
        }
        .priv-card h2 {
            font-size: 1.05rem;
            font-weight: 700;
            color: #24211e;
            margin-bottom: 8px;
        }
        .priv-card p, .priv-card li {
            font-size: 0.87rem;
            color: #5c564f;
            line-height: 1.6;
        }
        .badge-estado-activo {
            background: #E8F8F0;
            color: #27AE60;
            padding: 3px 10px;
            border-radius: 10px;
            font-size: 11px;
            font-weight: 600;
        }
        .badge-estado-inactivo {
            background: #FDEDEC;
            color: #C0392B;
            padding: 3px 10px;
            border-radius: 10px;
            font-size: 11px;
            font-weight: 600;
        }
    </style>
</asp:Content>

<asp:Content runat="server" ContentPlaceHolderID="MainContent">
    <div class="dashboard compras-resumen">
        <header class="dashboard-header" style="display: flex; justify-content: space-between; align-items: flex-end; flex-wrap: wrap; gap: 14px;">
            <div>
                <p class="dashboard-etiqueta">SEGURIDAD Y CUMPLIMIENTO &bull; NORMATIVA CHILENA</p>
                <h1>Protecci&oacute;n de Datos Personales</h1>
                <p class="dashboard-descripcion">Pol&iacute;tica de tratamiento, seguridad, conservaci&oacute;n y ejercicio de derechos ARCO conforme a la Ley N&deg; 19.628 y Ley N&deg; 21.719 de la Rep&uacute;blica de Chile.</p>
            </div>
            <div>
                <% if (Session["IdUsuario"] == null) { %>
                <a href="Login.aspx" class="btn btn-outline-secondary">Volver al Inicio de Sesi&oacute;n</a>
                <% } else { %>
                <a href="Default.aspx" class="btn btn-outline-secondary">Volver al Inicio</a>
                <% } %>
            </div>
        </header>

        <div class="priv-grid">
            <section class="card-dermocosmetica priv-card">
                <h2>1. Finalidad y minimizaci&oacute;n</h2>
                <p>Dermo ERP recopila exclusivamente los datos necesarios para facturaci&oacute;n tributaria (RUT, raz&oacute;n social, giro y domicilio comercial), coordinaci&oacute;n de despachos y administraci&oacute;n de cuentas de acceso internas. No se tratan datos sensibles de salud ni historiales cl&iacute;nicos de pacientes.</p>
            </section>

            <section class="card-dermocosmetica priv-card">
                <h2>2. Seguridad y confidencialidad</h2>
                <p>Las contrase&ntilde;as se almacenan mediante hash criptogr&aacute;fico PBKDF2-SHA256 con sal individual. El acceso est&aacute; restringido por perfil (RBAC), protegido con consultas parametrizadas, tokens antifalsificaci&oacute;n (CSRF) y bit&aacute;cora inmutable de auditor&iacute;a. Los mensajes de error omiten informaci&oacute;n t&eacute;cnica o personal.</p>
            </section>

            <section class="card-dermocosmetica priv-card">
                <h2>3. Plazos de conservaci&oacute;n</h2>
                <p>Los documentos tributarios, asientos contables y respaldos comerciales se conservan durante el plazo legal de 6 a&ntilde;os exigido por el C&oacute;digo Tributario chileno. Cuando un titular solicita cancelaci&oacute;n, sus datos identificables de contacto se anonimizan preservando la integridad contable.</p>
            </section>

            <section class="card-dermocosmetica priv-card">
                <h2>4. Derechos ARCO del titular</h2>
                <p>Clientes y usuarios pueden solicitar <strong>Acceso</strong> (copia estructurada de sus datos), <strong>Rectificaci&oacute;n</strong> (actualizaci&oacute;n en ficha de Clientes o Usuarios), <strong>Cancelaci&oacute;n/Anonimizaci&oacute;n</strong> y <strong>Oposici&oacute;n</strong> escribiendo al administrador del sistema en <strong>contacto@dermoerp.cl</strong>.</p>
            </section>
        </div>

        <asp:Panel runat="server" ID="pnlArcoAdmin" CssClass="card-dermocosmetica" Visible="false">
            <h2 style="font-size: 1.15rem; font-weight: 600; margin-bottom: 6px;">Gesti&oacute;n administrativa de derechos ARCO (Clientes)</h2>
            <p class="compras-nota" style="margin-bottom: 16px;">Exporta la ficha personal en JSON (Derecho de Acceso) o anonimiza datos de contacto de clientes inactivos preservando la integridad tributaria (Derecho de Cancelaci&oacute;n). Cada acci&oacute;n queda registrada en Auditor&iacute;a.</p>

            <asp:Label runat="server" ID="lblMensajeArco" Visible="false" />

            <div class="table-responsive">
                <asp:GridView runat="server" ID="gvClientesPrivacidad" CssClass="table table-hover align-middle" GridLines="None"
                    AutoGenerateColumns="False" OnRowCommand="gvClientesPrivacidad_RowCommand"
                    EmptyDataText="No existen clientes registrados.">
                    <Columns>
                        <asp:BoundField DataField="IdCliente" HeaderText="ID" />
                        <asp:BoundField DataField="Rut" HeaderText="RUT" />
                        <asp:BoundField DataField="Nombre" HeaderText="Titular / Cliente" />
                        <asp:BoundField DataField="Correo" HeaderText="Correo" />
                        <asp:BoundField DataField="Telefono" HeaderText="Tel&eacute;fono" />
                        <asp:TemplateField HeaderText="Estado">
                            <ItemTemplate>
                                <span class='<%# Convert.ToInt32(Eval("Activo")) == 1 ? "badge-estado-activo" : "badge-estado-inactivo" %>'>
                                    <%#: Eval("Estado") %>
                                </span>
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Acciones ARCO">
                            <ItemTemplate>
                                <div class="d-flex gap-2 flex-wrap">
                                    <asp:Button runat="server" Text="Exportar JSON" CommandName="ExportarJson"
                                        CommandArgument='<%# Eval("IdCliente") %>' CssClass="btn btn-outline-secondary btn-sm" />
                                    <asp:Button runat="server" Text="Anonimizar" CommandName="Anonimizar"
                                        CommandArgument='<%# Eval("IdCliente") %>'
                                        Enabled='<%# Convert.ToInt32(Eval("Activo")) == 0 %>'
                                        ToolTip="Disponible para clientes inactivos"
                                        CssClass="btn btn-outline-danger btn-sm" />
                                </div>
                            </ItemTemplate>
                        </asp:TemplateField>
                    </Columns>
                </asp:GridView>
            </div>
        </asp:Panel>
    </div>
</asp:Content>
