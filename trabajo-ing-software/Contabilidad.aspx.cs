using System;
using System.Collections.Generic;
using System.Data;
using MySql.Data.MySqlClient;
using System.Globalization;
using System.Linq;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace trabajo_ing_software
{
    public partial class Contabilidad : Page
    {
        private readonly Dictionary<string, WebControl> campos = new Dictionary<string, WebControl>();
        private string vista;
        private int usuario;
        private bool autorizado;
        private int cuentaEditada;

        protected override void OnInit(EventArgs e)
        {
            base.OnInit(e);
            if (!int.TryParse(Convert.ToString(Session["IdUsuario"]), out usuario) || usuario <= 0)
            {
                Response.Redirect("~/Login.aspx");
                return;
            }

            string rol = Convert.ToString(Session["RolUsuario"]).Trim();
            autorizado = string.Equals(rol, "Administrador", StringComparison.OrdinalIgnoreCase)
                || string.Equals(rol, "Administrador General", StringComparison.OrdinalIgnoreCase)
                || string.Equals(rol, "Contador", StringComparison.OrdinalIgnoreCase);
            if (!autorizado)
            {
                Response.StatusCode = 403;
                Mostrar("Tu perfil no tiene acceso a Contabilidad.", false);
                return;
            }

            ViewStateUserKey = Session.SessionID;
            vista = (Request.QueryString["vista"] ?? "diario").Trim().ToLowerInvariant();
            string[] vistasHabilitadas = { "diario", "tesoreria", "perdidas" };
            if (!vistasHabilitadas.Contains(vista, StringComparer.OrdinalIgnoreCase))
                vista = "diario";

            pnlResumenContabilidad.Visible = false;
            pnlVistaContabilidad.Visible = true;
            Page.Title = "Contabilidad";

            try
            {
                CrearFormulario();
            }
            catch (MySqlException ex)
            {
                autorizado = false;
                ErrorSql(ex);
            }
        }

        private void CrearFormulario()
        {
            switch (vista)
            {
                case "periodos":
                    Titulo.Text = "Períodos contables";
                    Texto("Nombre", "Nombre del período", 50);
                    Texto("Inicio", "Fecha de inicio", 10, TextBoxMode.Date);
                    Texto("Fin", "Fecha de término", 10, TextBoxMode.Date);
                    Boton("Abrir período", AbrirPeriodo);
                    Periodos(false);
                    Boton("Cerrar período seleccionado", CerrarPeriodo);
                    break;
                case "diario":
                    Titulo.Text = "Libro diario";
                    Periodos(false);
                    var origen = Lista("Origen", "Operación del ERP (opcional)");
                    origen.DataSource = ContabilidadDatos.Consultar(@"SELECT CONCAT(o.Origen,':',o.IdOrigen) AS Id,
                        CONCAT(o.Documento,' · ',DATE_FORMAT(o.Fecha,'%d/%m/%Y'),' · ',COALESCE(CAST(o.Importe AS CHAR),'sin importe')) AS Nombre
                        FROM (" + ContabilidadDatos.Operaciones + @") o LEFT JOIN asientocontable a
                        ON a.Origen=o.Origen AND a.IdOrigen=o.IdOrigen WHERE a.IdAsiento IS NULL
                        ORDER BY o.Fecha DESC,o.IdOrigen DESC");
                    origen.DataValueField = "Id";
                    origen.DataTextField = "Nombre";
                    origen.DataBind();
                    origen.Items.Insert(0, new ListItem("Asiento manual sin documento", ""));
                    Texto("Fecha", "Fecha del asiento", 10, TextBoxMode.Date);
                    ((TextBox)campos["Fecha"]).Text = DateTime.Today.ToString("yyyy-MM-dd");
                    Texto("Glosa", "Glosa", 255);
                    Texto("Lineas", "Una línea por cuenta: código;debe;haber", 8000, TextBoxMode.MultiLine);
                    Formulario.Controls.Add(new LiteralControl("<p class='form-text'>Ejemplo: 1101;1000;0 y, en otra línea, 2101;0;1000. Usa coma o punto decimal sin separador de miles.</p>"));
                    Boton("Contabilizar asiento", Registrar);
                    Texto("Reverso", "Número del asiento original para revertir", 10, TextBoxMode.Number);
                    Boton("Contabilizar reverso", Revertir);
                    Boton("Exportar PDF", () => Exportar(true), false);
                    Boton("Exportar Excel", () => Exportar(false), false);
                    break;
                case "operaciones":
                    Titulo.Text = "Operaciones del ERP";
                    Formulario.Controls.Add(new LiteralControl("<p>Consulta los documentos de Compras, Ventas y los ajustes de Inventario. Vincula cada operación con su asiento desde el Libro diario.</p>"));
                    break;
                case "balance":
                case "resultados":
                    Titulo.Text = vista == "balance" ? "Balance de comprobación y saldos" : "Estado de resultados";
                    Periodos(true);
                    AccionesReporte();
                    break;
                case "pagos":
                    Titulo.Text = "Proyección de pagos a laboratorios";
                    Periodos(true);
                    Texto("Buscar", "Laboratorio", 100);
                    AccionesReporte();
                    break;
                case "tesoreria":
                    Titulo.Text = "Cobros a clientes";
                    var pendientes = Lista("Cuenta", "Documento pendiente");
                    pendientes.DataSource = ContabilidadDatos.Consultar(@"SELECT cc.IdCuenta, CONCAT(v.Folio,' · ',c.Nombre,' · $',cc.MontoPendiente) Documento
                        FROM cuentascobrar cc JOIN venta v USING(IdVenta) JOIN cliente c USING(IdCliente) WHERE cc.MontoPendiente>0 ORDER BY cc.FechaVence");
                    pendientes.DataValueField = "IdCuenta";
                    pendientes.DataTextField = "Documento";
                    pendientes.DataBind();
                    Texto("Importe","Monto a cobrar (CLP)",18);
                    Texto("Fecha","Fecha del cobro",10,TextBoxMode.Date);
                    ((TextBox)campos["Fecha"]).Text = DateTime.Today.ToString("yyyy-MM-dd");
                    var medio = Lista("Medio","Medio de pago");
                    foreach (string m in new[]{"Transferencia","Efectivo","Tarjeta"}) medio.Items.Add(m);

                    Boton("Registrar cobro", RegistrarCobro);
                    Boton("Exportar PDF", () => Exportar(true), false);
                    Boton("Exportar Excel", () => Exportar(false), false);
                    break;
                case "iva":
                    Titulo.Text = "Declaración de IVA";
                    Periodos(false);
                    Boton("Consultar", delegate { });
                    Boton("Registrar declaración y cerrar período", CerrarPeriodo);
                    break;
                case "cobros":
                    Titulo.Text = "Antigüedad de saldos y morosidad";
                    Periodos(true);
                    Texto("Buscar", "Cliente", 100);
                    AccionesReporte();
                    break;
                case "perdidas":
                    Titulo.Text = "Pérdidas por vencimiento, daño y ajustes negativos";
                    Texto("Buscar", "SKU, producto o motivo", 100);
                    Periodos(true);
                    AccionesReporte();
                    break;
                case "inventario":
                    Titulo.Text = "Inventario valorizado";
                    Formulario.Controls.Add(new LiteralControl("<p class='form-text'>Existencias y costos promedio consultados desde Inventario. Las filas sin costo no tienen valorización.</p>"));
                    Texto("Buscar", "Producto, SKU o bodega", 100);
                    AccionesReporte();
                    break;
                default:
                    vista = "cuentas";
                    Titulo.Text = "Plan de cuentas";
                    Texto("Codigo", "Código", 50);
                    Texto("Nombre", "Nombre", 100);
                    var tipo = Lista("Tipo", "Tipo de cuenta");
                    foreach (string valor in new[] { "Activo", "Pasivo", "Patrimonio", "Ingreso", "Costo", "Gasto", "Resultado Ganancia", "Resultado Pérdida" })
                        tipo.Items.Add(valor);
                    var padre = Lista("Padre", "Cuenta superior");
                    padre.DataSource = ContabilidadDatos.Consultar("SELECT IdCuentaContable AS Id, CONCAT(Codigo,' · ',Nombre) AS Nombre FROM cuentacontable WHERE Imputable=0 ORDER BY Codigo");
                    padre.DataValueField = "Id";
                    padre.DataTextField = "Nombre";
                    padre.DataBind();
                    padre.Items.Insert(0, new ListItem("Cuenta raíz", ""));
                    var imputable = Lista("Imputable", "¿Acepta movimientos?");
                    imputable.Items.Add(new ListItem("Sí", "1"));
                    imputable.Items.Add(new ListItem("No, agrupa otras cuentas", "0"));
                    if (int.TryParse(Request.QueryString["cuenta"], out cuentaEditada) && cuentaEditada > 0)
                    {
                        Titulo.Text = "Plan de cuentas · Editando cuenta #" + cuentaEditada;
                        padre.Enabled = false;
                        Boton("Guardar cambios", EditarCuenta);
                        var btnCancelar = new HyperLink
                        {
                            Text = "Cancelar",
                            NavigateUrl = "~/Contabilidad.aspx?vista=cuentas",
                            CssClass = "btn btn-outline-secondary contabilidad-accion"
                        };
                        Formulario.Controls.Add(btnCancelar);
                        if (!IsPostBack) CargarCuenta();
                    }
                    else
                    {
                        Boton("Crear cuenta", CrearCuenta);
                    }
                    var colEditar = new HyperLinkField
                    {
                        HeaderText = "Acción",
                        Text = "Editar",
                        DataNavigateUrlFields = new[] { "Id" },
                        DataNavigateUrlFormatString = "Contabilidad.aspx?vista=cuentas&cuenta={0}"
                    };
                    colEditar.ControlStyle.CssClass = "btn btn-outline-secondary btn-sm";
                    Registros.Columns.Add(colEditar);
                    break;
            }
        }

        private void Periodos(bool todos)
        {
            var selector = Lista("Periodo", "Período");
            selector.DataSource = ContabilidadDatos.Consultar("SELECT IdPeriodo, CONCAT(Nombre,' · ',COALESCE(Estado,'')) AS Nombre FROM periodocontable ORDER BY FechaInicio DESC");
            selector.DataValueField = "IdPeriodo";
            selector.DataTextField = "Nombre";
            selector.DataBind();
            if (todos) selector.Items.Insert(0, new ListItem("Todos los períodos", ""));
        }

        private void AccionesReporte()
        {
            Boton("Consultar", delegate { });
            Boton("Exportar PDF", () => Exportar(true), false);
            Boton("Exportar Excel", () => Exportar(false), false);
        }

        private void Agregar(WebControl control, string id, string etiqueta)
        {
            control.ID = id;
            control.CssClass = control is DropDownList ? "form-select" : "form-control";
            var grupo = new Panel { CssClass = control is TextBox caja && caja.TextMode == TextBoxMode.MultiLine
                ? "contabilidad-campo contabilidad-campo-ancho" : "contabilidad-campo" };
            grupo.Controls.Add(new Label { Text = etiqueta, AssociatedControlID = id, CssClass = "form-label" });
            grupo.Controls.Add(control);
            Formulario.Controls.Add(grupo);
            campos.Add(id, control);
        }

        private void Texto(string id, string etiqueta, int largo, TextBoxMode modo = TextBoxMode.SingleLine)
        {
            Agregar(new TextBox { TextMode = modo, MaxLength = largo, Rows = 5 }, id, etiqueta);
        }

        private DropDownList Lista(string id, string etiqueta)
        {
            var lista = new DropDownList();
            Agregar(lista, id, etiqueta);
            return lista;
        }

        private void Boton(string titulo, Action accion, bool primario = true)
        {
            var boton = new Button { Text = titulo, CssClass = primario ? "btn btn-primary contabilidad-accion" : "btn btn-outline-secondary contabilidad-accion" };
            boton.Click += delegate
            {
                if (!autorizado) return;
                try { accion(); }
                catch (ArgumentException ex) { Mostrar(ex.Message, false); }
                catch (MySqlException ex) { ErrorSql(ex); }
                catch (System.Data.Common.DbException ex) { ErrorInventario(ex); }
                catch (InvalidOperationException ex) when (vista == "inventario") { ErrorInventario(ex); }
            };
            Formulario.Controls.Add(boton);
        }

        private string Valor(string id)
        {
            return campos[id] is TextBox caja ? caja.Text.Trim() : ((DropDownList)campos[id]).SelectedValue;
        }

        private string Obligatorio(string id, int largo)
        {
            string valor = Valor(id);
            if (valor.Length == 0 || valor.Length > largo)
                throw new ArgumentException("Completa " + id + " con un máximo de " + largo + " caracteres.");
            return valor;
        }

        private int Entero(string id)
        {
            if (!int.TryParse(Valor(id), out int valor) || valor <= 0)
                throw new ArgumentException("Selecciona un valor válido para " + id + ".");
            return valor;
        }

        private DateTime Fecha(string id)
        {
            if (!DateTime.TryParseExact(Valor(id), "yyyy-MM-dd", CultureInfo.InvariantCulture, DateTimeStyles.None, out DateTime fecha))
                throw new ArgumentException("Ingresa una fecha válida para " + id + ".");
            return fecha;
        }

        private void CrearCuenta()
        {
            int? padre = Valor("Padre") == "" ? (int?)null : Entero("Padre");
            int filas = ContabilidadDatos.Ejecutar(@"INSERT INTO cuentacontable(Codigo,Nombre,Tipo,IdCuentaPadre,Nivel,Imputable)
                SELECT @Codigo,@Nombre,@Tipo,@Padre,COALESCE(p.Nivel+1,1),@Imputable
                FROM (SELECT 1 AS Fila) f LEFT JOIN cuentacontable p
                ON p.IdCuentaContable=@Padre AND p.Imputable=0
                WHERE @Padre IS NULL OR p.IdCuentaContable IS NOT NULL;",
                new MySqlParameter("@Codigo", Obligatorio("Codigo",50)), new MySqlParameter("@Nombre", Obligatorio("Nombre",100)),
                new MySqlParameter("@Tipo", Valor("Tipo")),
                new MySqlParameter("@Padre", MySqlDbType.Int32) { Value = (object)padre ?? DBNull.Value },
                new MySqlParameter("@Imputable", Valor("Imputable") == "1"));
            if (filas != 1) throw new ArgumentException("La cuenta superior debe ser agrupadora.");
            Mostrar("Cuenta registrada.", true);
        }

        private void AbrirPeriodo()
        {
            DateTime inicio = Fecha("Inicio");
            DateTime fin = Fecha("Fin");
            if (inicio > fin) throw new ArgumentException("El término debe ser igual o posterior al inicio.");
            ContabilidadDatos.AbrirPeriodo(Obligatorio("Nombre", 50), inicio, fin);
            Mostrar("Período abierto. Vuelve a cargar la página para seleccionarlo.", true);
        }

        private void CargarCuenta()
        {
            var datos = ContabilidadDatos.Consultar(@"SELECT Codigo,Nombre,Tipo,IdCuentaPadre,Imputable
                FROM cuentacontable WHERE IdCuentaContable=@Id", new MySqlParameter("@Id", cuentaEditada));
            if (datos.Rows.Count == 0)
            {
                Mostrar("La cuenta seleccionada no existe.", false);
                return;
            }
            DataRow cuenta = datos.Rows[0];
            ((TextBox)campos["Codigo"]).Text = Convert.ToString(cuenta["Codigo"]);
            ((TextBox)campos["Nombre"]).Text = Convert.ToString(cuenta["Nombre"]);
            var tipos = (DropDownList)campos["Tipo"];
            string tipo = Convert.ToString(cuenta["Tipo"]);
            if (!string.IsNullOrEmpty(tipo) && tipos.Items.FindByValue(tipo) == null)
                tipos.Items.Add(new ListItem(tipo, tipo));
            if (tipos.Items.FindByValue(tipo) != null)
                tipos.SelectedValue = tipo;
            var padres = (DropDownList)campos["Padre"];
            string padre = cuenta["IdCuentaPadre"] == DBNull.Value ? "" : Convert.ToString(cuenta["IdCuentaPadre"]);
            if (padres.Items.FindByValue(padre) != null)
                padres.SelectedValue = padre;
            bool esImputable = cuenta["Imputable"] == DBNull.Value || Convert.ToInt32(cuenta["Imputable"]) != 0;
            ((DropDownList)campos["Imputable"]).SelectedValue = esImputable ? "1" : "0";
        }

        private void EditarCuenta()
        {
            ContabilidadDatos.EditarCuenta(cuentaEditada, Obligatorio("Codigo", 50),
                Obligatorio("Nombre", 100), Valor("Tipo"), Valor("Imputable") == "1");
            Mostrar("Cuenta contable actualizada correctamente.", true);
        }

        private void RegistrarCobro()
        {
            using (var con = VentaInventario.Abrir())
            using (var tx = con.BeginTransaction())
            using (var cmd = VentaInventario.Comando(con, tx,"CALL usp_RegistrarCobro(@p0,@p1,@p2,@p3,@p4,@p5)",
                Entero("Cuenta"),Monto(Valor("Importe")),Valor("Medio"),Fecha("Fecha"),usuario,ViewState["SolicitudCobro"]))
            {
                cmd.ExecuteNonQuery();
                tx.Commit();
            }
            Response.Redirect("Contabilidad.aspx?vista=tesoreria");
        }

        private void CerrarPeriodo()
        {
            using (var con = VentaInventario.Abrir())
            using (var tx = con.BeginTransaction())
            {
                int periodo = Entero("Periodo");
                using (var cmd = VentaInventario.Comando(con, tx, "SELECT Estado FROM periodocontable WHERE IdPeriodo=@p0 FOR UPDATE", periodo))
                    if (Convert.ToString(cmd.ExecuteScalar()) != "Abierto") throw new ArgumentException("Selecciona un período abierto.");
                using (var cmd = VentaInventario.Comando(con, tx, @"INSERT INTO declaracioniva(IdPeriodo,Monto,Fecha,IdUsuario)
                    SELECT @p0,COALESCE(SUM(CASE WHEN c.Codigo IN ('2108','1109') THEN d.Haber-d.Debe ELSE 0 END),0),CURDATE(),@p1
                    FROM asientocontable a JOIN detalleasiento d USING(IdAsiento) JOIN cuentacontable c USING(IdCuentaContable) WHERE a.IdPeriodo=@p0", periodo,usuario))
                    cmd.ExecuteNonQuery();
                using (var cmd = VentaInventario.Comando(con, tx, "UPDATE periodocontable SET Estado='Cerrado' WHERE IdPeriodo=@p0",periodo)) cmd.ExecuteNonQuery();
                tx.Commit();
            }
            Mostrar("Declaración registrada y período cerrado.",true);
        }

        private static decimal Monto(string valor)
        {
            if (!decimal.TryParse(valor.Trim().Replace(',', '.'), NumberStyles.AllowDecimalPoint, CultureInfo.InvariantCulture, out decimal monto)
                || monto < 0 || monto > 9999999999999999.99m || decimal.Round(monto, 2) != monto)
                throw new ArgumentException("Usa montos positivos o cero, con hasta dos decimales.");
            return monto;
        }

        private void Registrar() { GuardarAsiento(null); }
        private void Revertir() { GuardarAsiento(Entero("Reverso")); }

        private void GuardarAsiento(int? reverso)
        {
            var lineas = new DataTable();
            lineas.Columns.Add("Cuenta", typeof(int));
            lineas.Columns.Add("Debe", typeof(decimal));
            lineas.Columns.Add("Haber", typeof(decimal));
            if (!reverso.HasValue)
            {
                string[] texto = Obligatorio("Lineas", 8000).Split(new[] { '\r', '\n' }, StringSplitOptions.RemoveEmptyEntries);
                var cuentas = ContabilidadDatos.Consultar("SELECT IdCuentaContable, Codigo FROM cuentacontable WHERE Imputable=1");
                var codigos = new Dictionary<string, int>(StringComparer.OrdinalIgnoreCase);
                foreach (DataRow cuenta in cuentas.Rows)
                    codigos.Add((string)cuenta["Codigo"], (int)cuenta["IdCuentaContable"]);
                foreach (string linea in texto)
                {
                    string[] valores = linea.Split(';');
                    if (valores.Length != 3 || !codigos.TryGetValue(valores[0].Trim(), out int cuenta))
                        throw new ArgumentException("Cada línea debe indicar un código imputable, Debe y Haber separados por punto y coma.");
                    lineas.Rows.Add(cuenta, Monto(valores[1]), Monto(valores[2]));
                }
            }
            string origen = null;
            int? idOrigen = null;
            if (!reverso.HasValue && Valor("Origen") != "")
            {
                string[] clave = Valor("Origen").Split(':');
                if (clave.Length != 2 || !int.TryParse(clave[1], out int id))
                    throw new ArgumentException("Selecciona una operación válida.");
                origen = clave[0];
                idOrigen = id;
            }
            int asiento = ContabilidadDatos.RegistrarAsiento(Entero("Periodo"), Fecha("Fecha"),
                Obligatorio("Glosa", 255), usuario, lineas, reverso, origen, idOrigen);
            ((TextBox)campos["Glosa"]).Text = "";
            ((TextBox)campos["Lineas"]).Text = "";
            ((TextBox)campos["Reverso"]).Text = "";
            Mostrar("Asiento contabilizado con el número " + asiento + ".", true);
        }

        protected override void OnPreRender(EventArgs e)
        {
            base.OnPreRender(e);
            if (!autorizado) return;
            if (vista == "tesoreria" && ViewState["SolicitudCobro"] == null) ViewState["SolicitudCobro"] = Guid.NewGuid().ToString();
            if (string.Equals(vista, "resumen", StringComparison.OrdinalIgnoreCase))
            {
                CargarResumenContabilidad();
                return;
            }
            try
            {
                Registros.DataSource = ObtenerRegistros();
                Registros.DataBind();
                if (Registros.HeaderRow != null)
                    Registros.HeaderRow.TableSection = TableRowSection.TableHeader;
            }
            catch (MySqlException ex) { ErrorSql(ex); }
            catch (System.Data.Common.DbException ex) { ErrorInventario(ex); }
            catch (InvalidOperationException ex) when (vista == "inventario") { ErrorInventario(ex); }
        }

        private void CargarResumenContabilidad()
        {
            try
            {
                var cultura = new CultureInfo("es-CL");
                DataTable dt = ContabilidadDatos.Consultar(@"
                    SELECT
                        COALESCE((SELECT COUNT(*) FROM cuentacontable), 0) AS Cuentas,
                        COALESCE((SELECT COUNT(*) FROM asientocontable), 0) AS Asientos,
                        COALESCE((SELECT SUM(GREATEST(cp.Monto
                            - COALESCE((SELECT SUM(p.Monto) FROM pagoproveedor p WHERE p.IdCuentaPagar = cp.IdCuentaPagar), 0)
                            - COALESCE((SELECT SUM(dp.MontoAplicado) FROM devolucionproveedor dp WHERE dp.IdRecepcion=cp.IdRecepcion AND dp.Estado='Aceptado'), 0),0))
                            FROM cuentaporpagar cp WHERE COALESCE(cp.Estado,'Pendiente') <> 'Pagada'), 0) AS TotalCxP,
                        COALESCE((SELECT SUM(MontoPendiente) FROM cuentascobrar WHERE COALESCE(EstadoPago,'Pendiente') <> 'Pagado'), 0) AS TotalCxC");
                if (dt.Rows.Count > 0)
                {
                    DataRow r = dt.Rows[0];
                    litContCuentas.Text = Convert.ToInt32(r["Cuentas"]).ToString("N0", cultura);
                    litContAsientos.Text = Convert.ToInt32(r["Asientos"]).ToString("N0", cultura);
                    litContCxP.Text = Convert.ToDecimal(r["TotalCxP"]).ToString("C0", cultura);
                    litContCxC.Text = Convert.ToDecimal(r["TotalCxC"]).ToString("C0", cultura);
                }

                // Gráfico de 6 meses de movimientos contables
                DateTime hoy = DateTime.Today;
                DateTime mes = new DateTime(hoy.Year, hoy.Month, 1);
                DateTime primero = mes.AddMonths(-5);
                var datosMeses = ContabilidadDatos.Consultar(@"
                    SELECT EXTRACT(YEAR_MONTH FROM a.Fecha) AS Mes, COALESCE(SUM(d.Debe), 0) AS Total
                    FROM asientocontable a
                    LEFT JOIN detalleasiento d ON d.IdAsiento = a.IdAsiento
                    WHERE a.Fecha >= @Inicio AND a.Fecha < @Fin
                    GROUP BY EXTRACT(YEAR_MONTH FROM a.Fecha)",
                    new MySqlParameter("@Inicio", primero),
                    new MySqlParameter("@Fin", mes.AddMonths(1)));
                var totales = datosMeses.AsEnumerable().ToDictionary(
                    fila => Convert.ToInt32(fila["Mes"]),
                    fila => Convert.ToDecimal(fila["Total"]));
                decimal maximo = totales.Count == 0 ? 0 : totales.Values.Max();
                rptMesesContabilidad.DataSource = Enumerable.Range(0, 6).Select(indice =>
                {
                    DateTime fecha = primero.AddMonths(indice);
                    totales.TryGetValue(fecha.Year * 100 + fecha.Month, out decimal valor);
                    return new
                    {
                        Mes = fecha.ToString("MMM", cultura),
                        Importe = valor.ToString("C0", cultura),
                        Altura = maximo > 0 ? Math.Round(valor / maximo * 100).ToString(CultureInfo.InvariantCulture) : "0"
                    };
                }).ToList();
                rptMesesContabilidad.DataBind();
                lblSinAsientosMes.Visible = maximo <= 0;

                // Últimos 5 asientos del libro diario
                var recientes = ContabilidadDatos.Consultar(@"
                    SELECT a.IdAsiento,
                           DATE_FORMAT(a.Fecha, '%d-%m-%Y') AS Fecha,
                           a.Glosa,
                           COALESCE(SUM(d.Debe), 0) AS TotalDebe
                    FROM asientocontable a
                    LEFT JOIN detalleasiento d ON d.IdAsiento = a.IdAsiento
                    GROUP BY a.IdAsiento, a.Fecha, a.Glosa
                    ORDER BY a.Fecha DESC, a.IdAsiento DESC
                    LIMIT 5");
                recientes.Columns.Add("Importe", typeof(string));
                foreach (DataRow fila in recientes.Rows)
                    fila["Importe"] = Convert.ToDecimal(fila["TotalDebe"]).ToString("C0", cultura);
                gvAsientosRecientes.DataSource = recientes;
                gvAsientosRecientes.DataBind();
                if (gvAsientosRecientes.HeaderRow != null)
                    gvAsientosRecientes.HeaderRow.TableSection = TableRowSection.TableHeader;
            }
            catch
            {
                litContCuentas.Text = "0";
                litContAsientos.Text = "0";
                litContCxP.Text = "$0";
                litContCxC.Text = "$0";
            }
        }

        private DataTable ObtenerRegistros()
        {
            switch (vista)
            {
                case "periodos":
                    return ContabilidadDatos.Consultar("SELECT Nombre, DATE_FORMAT(FechaInicio,'%d/%m/%Y') AS Inicio, DATE_FORMAT(FechaFin,'%d/%m/%Y') AS Término, Estado FROM periodocontable ORDER BY FechaInicio DESC");
                case "diario":
                    return ContabilidadDatos.Consultar(@"SELECT a.IdAsiento AS Asiento, DATE_FORMAT(a.Fecha,'%d/%m/%Y') AS Fecha, a.Glosa,
                        c.Codigo AS Código, c.Nombre AS Cuenta, d.Debe, d.Haber, a.IdUsuario AS Responsable, a.IdAsientoRevertido AS ReversoDe, a.Origen, a.IdOrigen
                        FROM asientocontable a LEFT JOIN detalleasiento d ON d.IdAsiento=a.IdAsiento
                        LEFT JOIN cuentacontable c ON c.IdCuentaContable=d.IdCuentaContable
                        ORDER BY a.Fecha DESC,a.IdAsiento DESC,d.IdDetalleAsiento");
                case "operaciones":
                    return ContabilidadDatos.Consultar(@"SELECT o.Origen,o.Documento,DATE_FORMAT(o.Fecha,'%d/%m/%Y') AS Fecha,
                        o.Importe,a.IdAsiento AS Asiento,IF(a.IdAsiento IS NULL,'Pendiente','Contabilizado') AS Estado
                        FROM (" + ContabilidadDatos.Operaciones + @") o LEFT JOIN asientocontable a
                        ON a.Origen=o.Origen AND a.IdOrigen=o.IdOrigen ORDER BY o.Fecha DESC,o.IdOrigen DESC");
                case "balance":
                case "resultados":
                    int? periodo = Valor("Periodo") == "" ? (int?)null : Entero("Periodo");
                    string filtro = vista == "resultados" ? " AND c.Tipo IN (N'Ingreso',N'Costo',N'Gasto',N'Resultado Ganancia',N'Resultado Pérdida')" : "";
                    return ContabilidadDatos.Consultar(@"SELECT c.Codigo AS Código,c.Nombre AS Cuenta,c.Tipo,
                        SUM(d.Debe) AS Debe,SUM(d.Haber) AS Haber,
                        SUM(CASE WHEN c.Tipo IN (N'Pasivo',N'Patrimonio',N'Ingreso',N'Resultado Ganancia') THEN d.Haber-d.Debe ELSE d.Debe-d.Haber END) AS Saldo
                        FROM detalleasiento d JOIN asientocontable a ON a.IdAsiento=d.IdAsiento
                        JOIN cuentacontable c ON c.IdCuentaContable=d.IdCuentaContable
                        WHERE (@Periodo IS NULL OR a.IdPeriodo=@Periodo)" + filtro + " GROUP BY c.Codigo,c.Nombre,c.Tipo ORDER BY c.Codigo",
                        new MySqlParameter("@Periodo", MySqlDbType.Int32) { Value = (object)periodo ?? DBNull.Value });
                case "tesoreria":
                    return ContabilidadDatos.Consultar(@"SELECT co.Fecha,v.Folio,c.Nombre Cliente,co.Medio,co.Monto,co.IdAsiento Asiento
                        FROM cobrocliente co JOIN cuentascobrar cc USING(IdCuenta) JOIN venta v USING(IdVenta) JOIN cliente c USING(IdCliente) ORDER BY co.IdCobro DESC");
                case "iva":
                    return ContabilidadDatos.Consultar(@"SELECT p.Nombre Periodo,p.Estado,
                        COALESCE(SUM(IF(c.Codigo='2108',d.Haber-d.Debe,0)),0) Debito,
                        COALESCE(SUM(IF(c.Codigo='1109',d.Debe-d.Haber,0)),0) Credito,
                        GREATEST(COALESCE(MAX(i.Monto),0),0) PorPagar,GREATEST(-COALESCE(MAX(i.Monto),0),0) Remanente
                        FROM periodocontable p LEFT JOIN asientocontable a USING(IdPeriodo)
                        LEFT JOIN detalleasiento d USING(IdAsiento) LEFT JOIN cuentacontable c USING(IdCuentaContable)
                        LEFT JOIN declaracioniva i ON i.IdPeriodo=p.IdPeriodo WHERE p.IdPeriodo=@periodo GROUP BY p.IdPeriodo,p.Nombre,p.Estado",
                        new MySqlParameter("@periodo", Valor("Periodo")));
                case "inventario":
                    return ContabilidadDatos.InventarioValorizado(Valor("Buscar"));
                case "pagos":
                    return ContabilidadDatos.Consultar(@"
                        WITH Pendientes AS (
                            SELECT l.RazonSocial AS Laboratorio, cp.IdCuentaPagar AS Documento, cp.Estado,
                                DATE_ADD(r.FechaRecepcion,INTERVAL COALESCE(l.DiasPago,30) DAY) AS Vencimiento,
                                GREATEST(cp.Monto-COALESCE(p.Pagado,0)-COALESCE(dpc.Credito,0),0) AS Saldo
                            FROM cuentaporpagar cp JOIN recepcioncompra r ON r.IdRecepcion=cp.IdRecepcion
                            JOIN laboratorio l ON l.IdLaboratorio=cp.IdLaboratorio
                            LEFT JOIN (SELECT IdCuentaPagar,SUM(Monto) AS Pagado FROM pagoproveedor GROUP BY IdCuentaPagar) p ON p.IdCuentaPagar=cp.IdCuentaPagar
                            LEFT JOIN (SELECT IdRecepcion,SUM(MontoAplicado) AS Credito FROM devolucionproveedor WHERE Estado='Aceptado' GROUP BY IdRecepcion) dpc ON dpc.IdRecepcion=cp.IdRecepcion
                            WHERE l.RazonSocial LIKE @Buscar
                        )
                        SELECT Laboratorio, Documento, Estado, DATE_FORMAT(Vencimiento,'%d/%m/%Y') AS Vence, Saldo,
                            CASE WHEN Vencimiento IS NULL THEN N'Sin fecha'
                                 WHEN DATEDIFF(Vencimiento,CURDATE())<0 THEN N'Vencido'
                                 WHEN DATEDIFF(Vencimiento,CURDATE())<=30 THEN N'0 a 30 días'
                                 WHEN DATEDIFF(Vencimiento,CURDATE())<=60 THEN N'31 a 60 días'
                                 WHEN DATEDIFF(Vencimiento,CURDATE())<=90 THEN N'61 a 90 días'
                                 ELSE N'Más de 90 días' END AS Tramo
                        FROM Pendientes WHERE Saldo>0 AND (@Periodo IS NULL OR EXISTS(SELECT 1 FROM periodocontable pc WHERE pc.IdPeriodo=@Periodo AND Vencimiento BETWEEN pc.FechaInicio AND pc.FechaFin)) ORDER BY Vencimiento, Laboratorio", Buscar(), PeriodoFiltro());
                case "cobros":
                    return ContabilidadDatos.Consultar(@"
                        SELECT c.Nombre AS Cliente, cc.IdVenta AS Venta, cc.EstadoPago AS Estado,
                            DATE_FORMAT(cc.FechaVence,'%d/%m/%Y') AS Vence, cc.MontoPendiente AS Saldo,
                            CASE WHEN cc.FechaVence IS NULL THEN NULL
                                 WHEN DATEDIFF(CURDATE(),cc.FechaVence)<0 THEN 0
                                 ELSE DATEDIFF(CURDATE(),cc.FechaVence) END AS DíasVencidos
                        FROM cuentascobrar cc JOIN venta v ON v.IdVenta=cc.IdVenta
                        JOIN cliente c ON c.IdCliente=v.IdCliente
                        WHERE cc.MontoPendiente>0 AND c.Nombre LIKE @Buscar AND (@Periodo IS NULL OR EXISTS(SELECT 1 FROM periodocontable pc WHERE pc.IdPeriodo=@Periodo AND cc.FechaVence BETWEEN pc.FechaInicio AND pc.FechaFin)) ORDER BY cc.FechaVence,c.Nombre", Buscar(), PeriodoFiltro());
                case "perdidas":
                    int? periodoMerma = Valor("Periodo") == "" ? (int?)null : Entero("Periodo");
                    return ContabilidadDatos.Consultar(@"
                        SELECT DATE_FORMAT(m.Fecha,'%d/%m/%Y') AS Fecha,p.Nombre AS Producto,v.Sku AS SKU,
                            l.NumeroLote AS Lote,m.Motivo,m.Cantidad,m.CostoPerdida AS Pérdida
                        FROM merma m JOIN lote l ON l.IdLote=m.IdLote
                        JOIN varianteproducto v ON v.IdVariante=l.IdVariante
                        JOIN producto p ON p.IdProducto=v.IdProducto
                        WHERE (p.Nombre LIKE @Buscar OR v.Sku LIKE @Buscar OR m.Motivo LIKE @Buscar)
                          AND (@Periodo IS NULL OR EXISTS (SELECT 1 FROM periodocontable pc
                               WHERE pc.IdPeriodo=@Periodo AND m.Fecha BETWEEN pc.FechaInicio AND pc.FechaFin))
                        ORDER BY m.Fecha DESC,m.IdMerma DESC", Buscar(),
                        new MySqlParameter("@Periodo", MySqlDbType.Int32) { Value = (object)periodoMerma ?? DBNull.Value });
                default:
                    return ContabilidadDatos.Consultar(@"SELECT c.IdCuentaContable AS Id,c.Codigo AS Código,c.Nombre AS Cuenta,c.Tipo,c.Nivel,IF((SELECT COUNT(*) FROM cuentacontable x WHERE x.Codigo=c.Codigo)>1,'Código duplicado','') AS Revisión,p.Codigo AS CuentaSuperior,
                        CASE c.Imputable WHEN 1 THEN N'Sí' ELSE N'No' END AS Imputable
                        FROM cuentacontable c LEFT JOIN cuentacontable p ON p.IdCuentaContable=c.IdCuentaPadre ORDER BY c.Codigo");
            }
        }

        private MySqlParameter PeriodoFiltro()
        {
            return new MySqlParameter("@Periodo", MySqlDbType.Int32) { Value = Valor("Periodo") == "" ? (object)DBNull.Value : Entero("Periodo") };
        }

        private MySqlParameter Buscar()
        {
            return new MySqlParameter("@Buscar", "%" + Valor("Buscar") + "%");
        }

        private void Mostrar(string texto, bool exito)
        {
            Mensaje.Text = Server.HtmlEncode(texto);
            Mensaje.CssClass = exito ? "alert alert-success d-block" : "alert alert-danger d-block";
        }

        private void ErrorSql(MySqlException ex)
        {
            System.Diagnostics.Trace.TraceError(ex.ToString());
            if (ex.Number == 1062) Mostrar("El código de cuenta, reverso u operación ya está registrado.", false);
            else if (ex.Number == 1146 || ex.Number == 1054) Mostrar("Faltan tablas para esta consulta. Instala el esquema del ERP y la migración de Contabilidad.", false);
            else Mostrar("No se pudo consultar o guardar en MySQL. Verifica la conexión y la migración de Contabilidad.", false);
        }

        private void Exportar(bool pdf)
        {
            DataTable tabla = ObtenerRegistros();
            byte[] archivo = pdf ? ContabilidadExportacion.Pdf(Titulo.Text, tabla) : ContabilidadExportacion.Excel(tabla);
            Response.Clear();
            Response.ContentType = pdf ? "application/pdf" : ContabilidadExportacion.ExcelMimeType;
            Response.AddHeader("Content-Disposition", "attachment; filename=" + vista + (pdf ? ".pdf" : ".xlsx"));
            Response.BinaryWrite(archivo);
            Response.Flush();
            Response.SuppressContent = true;
            Context.ApplicationInstance.CompleteRequest();
        }

        private void ErrorInventario(Exception ex)
        {
            System.Diagnostics.Trace.TraceError(ex.ToString());
            Mostrar("No se pudo consultar Inventario. Revisa la conexión a la base compartida.", false);
        }
    }
}
