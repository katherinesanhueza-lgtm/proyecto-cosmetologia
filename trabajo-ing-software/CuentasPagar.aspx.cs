using System;
using System.Configuration;
using System.Data;
using System.Globalization;
using System.Web.UI;
using System.Web.UI.WebControls;
using MySql.Data.MySqlClient;

namespace trabajo_ing_software
{
    public partial class CuentasPagar : Page
    {
        private readonly string connectionString = ConfigurationManager.ConnectionStrings["DefaultConnection"] != null
            ? ConfigurationManager.ConnectionStrings["DefaultConnection"].ConnectionString
            : "Server=localhost;Port=3306;Database=ERP_Dermocosmetica;Uid=root;Pwd=;";

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["IdUsuario"] == null)
            {
                Response.Redirect("Login.aspx");
                return;
            }

            string rol = Convert.ToString(Session["RolUsuario"]).Trim();
            if (!rol.Equals("Administrador", StringComparison.OrdinalIgnoreCase) &&
                !rol.Equals("Administrador General", StringComparison.OrdinalIgnoreCase) &&
                !rol.Equals("Contador", StringComparison.OrdinalIgnoreCase))
            {
                ConfiguracionGlobal.RedirigirSegunRol(Response, rol);
                return;
            }

            if (!IsPostBack)
            {
                lblBienvenida.Text = Convert.ToString(Session["NombreUsuario"]);
                txtFechaPago.Text = DateTime.Today.ToString("yyyy-MM-dd");
                CargarLaboratoriosFiltro();
                CargarPeriodosAbiertos();
                CargarCuentasPendientesCombo();
                CargarListadoCuentas();
                CargarHistorialPagos();
                CalcularKPIs();
            }
        }

        private void CargarLaboratoriosFiltro()
        {
            ddlFiltroLab.Items.Clear();
            ddlFiltroLab.Items.Add(new ListItem("Todos los Laboratorios", ""));

            using (MySqlConnection con = new MySqlConnection(connectionString))
            using (MySqlCommand cmd = new MySqlCommand("SELECT IdLaboratorio, RazonSocial FROM Laboratorio ORDER BY RazonSocial", con))
            {
                con.Open();
                using (MySqlDataReader dr = cmd.ExecuteReader())
                {
                    while (dr.Read())
                    {
                        ddlFiltroLab.Items.Add(new ListItem(dr["RazonSocial"].ToString(), dr["IdLaboratorio"].ToString()));
                    }
                }
            }
        }

        private void CargarPeriodosAbiertos()
        {
            ddlPeriodo.Items.Clear();

            using (MySqlConnection con = new MySqlConnection(connectionString))
            using (MySqlCommand cmd = new MySqlCommand("SELECT IdPeriodo, Nombre FROM periodocontable WHERE Estado = 'Abierto' ORDER BY FechaInicio DESC", con))
            {
                con.Open();
                using (MySqlDataReader dr = cmd.ExecuteReader())
                {
                    while (dr.Read())
                    {
                        ddlPeriodo.Items.Add(new ListItem(dr["Nombre"].ToString(), dr["IdPeriodo"].ToString()));
                    }
                }
            }

            if (ddlPeriodo.Items.Count == 0)
            {
                ddlPeriodo.Items.Add(new ListItem("-- Sin períodos abiertos --", ""));
            }
        }

        private void CargarCuentasPendientesCombo()
        {
            ddlCuentaPago.Items.Clear();
            ddlCuentaPago.Items.Add(new ListItem("-- Seleccionar Cuenta por Pagar --", ""));

            string sql = @"SELECT cp.IdCuentaPagar, l.RazonSocial, oc.NumeroOC,
                                  (cp.Monto - IFNULL(p.Pagado, 0)) AS Saldo
                           FROM cuentaporpagar cp
                           INNER JOIN recepcioncompra r ON r.IdRecepcion = cp.IdRecepcion
                           INNER JOIN ordencompra oc ON oc.IdOC = r.IdOC
                           INNER JOIN laboratorio l ON l.IdLaboratorio = cp.IdLaboratorio
                           LEFT JOIN (SELECT IdCuentaPagar, SUM(Monto) AS Pagado FROM pagoproveedor GROUP BY IdCuentaPagar) p
                                  ON p.IdCuentaPagar = cp.IdCuentaPagar
                           WHERE (cp.Monto - IFNULL(p.Pagado, 0)) > 0
                           ORDER BY DATE_ADD(r.FechaRecepcion, INTERVAL IFNULL(l.DiasPago, 30) DAY) ASC";

            using (MySqlConnection con = new MySqlConnection(connectionString))
            using (MySqlCommand cmd = new MySqlCommand(sql, con))
            {
                con.Open();
                using (MySqlDataReader dr = cmd.ExecuteReader())
                {
                    while (dr.Read())
                    {
                        string texto = string.Format("CXP-{0:D4} | {1} | {2} (Saldo: {3:C0})",
                            Convert.ToInt32(dr["IdCuentaPagar"]),
                            dr["RazonSocial"],
                            dr["NumeroOC"],
                            Convert.ToDecimal(dr["Saldo"]));
                        ddlCuentaPago.Items.Add(new ListItem(texto, dr["IdCuentaPagar"].ToString()));
                    }
                }
            }

            ActualizarMontoSegunCuenta();
        }

        private void ActualizarMontoSegunCuenta()
        {
            int idCxp;
            if (!int.TryParse(ddlCuentaPago.SelectedValue, out idCxp))
            {
                lblDetalleCuentaSel.Text = "";
                txtMontoPago.Text = "";
                txtMontoPago.Enabled = rblTipoPago.SelectedValue != "Total";
                return;
            }

            string sql = @"SELECT cp.Monto, IFNULL(p.Pagado, 0) AS Pagado,
                                  DATE_ADD(r.FechaRecepcion, INTERVAL IFNULL(l.DiasPago, 30) DAY) AS Vencimiento,
                                  oc.NumeroOC, l.RazonSocial
                           FROM cuentaporpagar cp
                           INNER JOIN recepcioncompra r ON r.IdRecepcion = cp.IdRecepcion
                           INNER JOIN ordencompra oc ON oc.IdOC = r.IdOC
                           INNER JOIN laboratorio l ON l.IdLaboratorio = cp.IdLaboratorio
                           LEFT JOIN (SELECT IdCuentaPagar, SUM(Monto) AS Pagado FROM pagoproveedor GROUP BY IdCuentaPagar) p
                                  ON p.IdCuentaPagar = cp.IdCuentaPagar
                           WHERE cp.IdCuentaPagar = @Id";

            using (MySqlConnection con = new MySqlConnection(connectionString))
            using (MySqlCommand cmd = new MySqlCommand(sql, con))
            {
                cmd.Parameters.AddWithValue("@Id", idCxp);
                con.Open();
                using (MySqlDataReader dr = cmd.ExecuteReader())
                {
                    if (dr.Read())
                    {
                        decimal total = Convert.ToDecimal(dr["Monto"]);
                        decimal pagado = Convert.ToDecimal(dr["Pagado"]);
                        decimal saldo = Math.Max(0m, total - pagado);
                        DateTime vence = Convert.ToDateTime(dr["Vencimiento"]);

                        lblDetalleCuentaSel.Text = string.Format("{0} · {1} · Vence {2:dd/MM/yyyy} · Total: {3:C0} · Pagado: {4:C0} · Saldo: {5:C0}",
                            dr["RazonSocial"], dr["NumeroOC"], vence, total, pagado, saldo);

                        if (rblTipoPago.SelectedValue == "Total")
                        {
                            txtMontoPago.Text = Math.Round(saldo, 0).ToString("0", CultureInfo.InvariantCulture);
                            txtMontoPago.Enabled = false;
                        }
                        else
                        {
                            txtMontoPago.Enabled = true;
                            if (string.IsNullOrWhiteSpace(txtMontoPago.Text))
                            {
                                txtMontoPago.Text = Math.Round(saldo / 2m, 0).ToString("0", CultureInfo.InvariantCulture);
                            }
                        }

                        if (string.IsNullOrWhiteSpace(txtGlosaPago.Text))
                        {
                            txtGlosaPago.Text = string.Format("Pago {0} CXP-{1:D4} ({2}) - {3}",
                                rblTipoPago.SelectedValue.ToLowerInvariant(), idCxp, dr["NumeroOC"], dr["RazonSocial"]);
                        }
                    }
                }
            }
        }

        protected void ddlCuentaPago_SelectedIndexChanged(object sender, EventArgs e)
        {
            txtGlosaPago.Text = "";
            txtMontoPago.Text = "";
            ActualizarMontoSegunCuenta();
        }

        protected void rblTipoPago_SelectedIndexChanged(object sender, EventArgs e)
        {
            txtGlosaPago.Text = "";
            ActualizarMontoSegunCuenta();
        }

        private void CargarListadoCuentas()
        {
            string busq = (txtBuscar.Text ?? "").Trim();
            string idLab = ddlFiltroLab.SelectedValue;
            string estado = ddlFiltroEstado.SelectedValue;

            string sql = @"SELECT t.* FROM (
                               SELECT cp.IdCuentaPagar, cp.IdRecepcion, oc.NumeroOC,
                                      l.IdLaboratorio, l.RazonSocial AS Laboratorio, l.Rut, IFNULL(l.DiasPago, 30) AS DiasPago,
                                      r.FechaRecepcion,
                                      DATE_ADD(r.FechaRecepcion, INTERVAL IFNULL(l.DiasPago, 30) DAY) AS FechaVencimiento,
                                      DATEDIFF(DATE_ADD(r.FechaRecepcion, INTERVAL IFNULL(l.DiasPago, 30) DAY), CURDATE()) AS DiasRestantes,
                                      cp.Monto AS MontoTotal,
                                      IFNULL(p.Pagado, 0) AS MontoPagado,
                                      GREATEST(cp.Monto - IFNULL(p.Pagado, 0), 0) AS SaldoPendiente,
                                      CASE
                                          WHEN (cp.Monto - IFNULL(p.Pagado, 0)) <= 0 THEN 'Pagada'
                                          WHEN DATEDIFF(DATE_ADD(r.FechaRecepcion, INTERVAL IFNULL(l.DiasPago, 30) DAY), CURDATE()) < 0 THEN 'Vencida'
                                          WHEN IFNULL(p.Pagado, 0) > 0 THEN 'Parcial'
                                          ELSE 'Pendiente'
                                      END AS EstadoEfectivo
                               FROM cuentaporpagar cp
                               INNER JOIN recepcioncompra r ON r.IdRecepcion = cp.IdRecepcion
                               INNER JOIN ordencompra oc ON oc.IdOC = r.IdOC
                               INNER JOIN laboratorio l ON l.IdLaboratorio = cp.IdLaboratorio
                               LEFT JOIN (SELECT IdCuentaPagar, SUM(Monto) AS Pagado FROM pagoproveedor GROUP BY IdCuentaPagar) p
                                      ON p.IdCuentaPagar = cp.IdCuentaPagar
                           ) t
                           WHERE 1=1";

            if (!string.IsNullOrEmpty(busq))
            {
                sql += @" AND (t.Laboratorio LIKE @Busq OR t.Rut LIKE @Busq OR t.NumeroOC LIKE @Busq
                              OR CONCAT('CXP-', LPAD(t.IdCuentaPagar, 4, '0')) LIKE @Busq
                              OR CONCAT('REC-', LPAD(t.IdRecepcion, 4, '0')) LIKE @Busq)";
            }

            if (!string.IsNullOrEmpty(idLab))
                sql += " AND t.IdLaboratorio = @IdLab";

            if (estado == "PENDIENTES")
                sql += " AND t.SaldoPendiente > 0";
            else if (estado == "VENCIDAS")
                sql += " AND t.SaldoPendiente > 0 AND t.DiasRestantes < 0";
            else if (estado == "Pagada")
                sql += " AND t.SaldoPendiente <= 0";

            sql += " ORDER BY CASE WHEN t.SaldoPendiente > 0 THEN 0 ELSE 1 END, t.FechaVencimiento ASC, t.IdCuentaPagar DESC";

            using (MySqlConnection con = new MySqlConnection(connectionString))
            using (MySqlCommand cmd = new MySqlCommand(sql, con))
            {
                if (!string.IsNullOrEmpty(busq))
                    cmd.Parameters.AddWithValue("@Busq", "%" + busq + "%");
                if (!string.IsNullOrEmpty(idLab))
                    cmd.Parameters.AddWithValue("@IdLab", idLab);

                using (MySqlDataAdapter da = new MySqlDataAdapter(cmd))
                {
                    DataTable dt = new DataTable();
                    da.Fill(dt);
                    gvCuentasPagar.DataSource = dt;
                    gvCuentasPagar.DataBind();
                }
            }
        }

        private void CargarHistorialPagos()
        {
            string sql = @"SELECT pp.IdPagoProveedor, pp.Fecha, l.RazonSocial AS Laboratorio,
                                  pp.IdCuentaPagar, oc.NumeroOC, pp.IdAsiento, pp.Monto, u.Nombre AS Usuario
                           FROM pagoproveedor pp
                           INNER JOIN cuentaporpagar cp ON cp.IdCuentaPagar = pp.IdCuentaPagar
                           INNER JOIN recepcioncompra r ON r.IdRecepcion = cp.IdRecepcion
                           INNER JOIN ordencompra oc ON oc.IdOC = r.IdOC
                           INNER JOIN laboratorio l ON l.IdLaboratorio = cp.IdLaboratorio
                           INNER JOIN usuario u ON u.IdUsuario = pp.IdUsuario
                           ORDER BY pp.Fecha DESC, pp.IdPagoProveedor DESC";

            using (MySqlConnection con = new MySqlConnection(connectionString))
            using (MySqlDataAdapter da = new MySqlDataAdapter(sql, con))
            {
                DataTable dt = new DataTable();
                da.Fill(dt);
                gvPagos.DataSource = dt;
                gvPagos.DataBind();
            }
        }

        private void CalcularKPIs()
        {
            string sql = @"SELECT
                               IFNULL(SUM(CASE WHEN Saldo > 0 THEN Saldo ELSE 0 END), 0) AS DeudaTotal,
                               SUM(CASE WHEN Saldo > 0 THEN 1 ELSE 0 END) AS CantPendientes,
                               IFNULL(SUM(CASE WHEN Saldo > 0 AND DiasRestantes < 0 THEN Saldo ELSE 0 END), 0) AS DeudaVencida,
                               IFNULL(SUM(CASE WHEN Saldo > 0 AND DiasRestantes BETWEEN 0 AND 30 THEN Saldo ELSE 0 END), 0) AS PorVencer30
                           FROM (
                               SELECT (cp.Monto - IFNULL(p.Pagado, 0)) AS Saldo,
                                      DATEDIFF(DATE_ADD(r.FechaRecepcion, INTERVAL IFNULL(l.DiasPago, 30) DAY), CURDATE()) AS DiasRestantes
                               FROM cuentaporpagar cp
                               INNER JOIN recepcioncompra r ON r.IdRecepcion = cp.IdRecepcion
                               INNER JOIN laboratorio l ON l.IdLaboratorio = cp.IdLaboratorio
                               LEFT JOIN (SELECT IdCuentaPagar, SUM(Monto) AS Pagado FROM pagoproveedor GROUP BY IdCuentaPagar) p
                                      ON p.IdCuentaPagar = cp.IdCuentaPagar
                           ) q";

            using (MySqlConnection con = new MySqlConnection(connectionString))
            {
                con.Open();
                using (MySqlCommand cmd = new MySqlCommand(sql, con))
                using (MySqlDataReader dr = cmd.ExecuteReader())
                {
                    if (dr.Read())
                    {
                        lblKpiDeudaTotal.Text = string.Format("{0:C0}", dr["DeudaTotal"]);
                        lblKpiCantPendientes.Text = dr["CantPendientes"] != DBNull.Value ? dr["CantPendientes"].ToString() : "0";
                        lblKpiVencida.Text = string.Format("{0:C0}", dr["DeudaVencida"]);
                        lblKpiPorVencer30.Text = string.Format("{0:C0}", dr["PorVencer30"]);
                    }
                }

                string sqlMes = @"SELECT IFNULL(SUM(Monto), 0)
                                  FROM pagoproveedor
                                  WHERE YEAR(Fecha) = YEAR(CURDATE()) AND MONTH(Fecha) = MONTH(CURDATE())";
                using (MySqlCommand cmdMes = new MySqlCommand(sqlMes, con))
                {
                    decimal pagadoMes = Convert.ToDecimal(cmdMes.ExecuteScalar());
                    lblKpiPagadoMes.Text = string.Format("{0:C0}", pagadoMes);
                }
            }
        }

        protected void btnTogglePago_Click(object sender, EventArgs e)
        {
            pnlFormPago.Visible = !pnlFormPago.Visible;
            lblMensaje.Visible = false;
            if (pnlFormPago.Visible)
            {
                CargarCuentasPendientesCombo();
            }
        }

        protected void btnCancelarPago_Click(object sender, EventArgs e)
        {
            pnlFormPago.Visible = false;
        }

        protected void btnRegistrarPago_Click(object sender, EventArgs e)
        {
            int idCuenta, idPeriodo;
            decimal montoPago;
            DateTime fechaPago;

            if (!int.TryParse(ddlCuentaPago.SelectedValue, out idCuenta))
            {
                MostrarMensaje("Selecciona una cuenta por pagar pendiente.", false);
                return;
            }

            if (!int.TryParse(ddlPeriodo.SelectedValue, out idPeriodo))
            {
                MostrarMensaje("Debe existir un período contable abierto para contabilizar el pago.", false);
                return;
            }

            string montoRaw = (txtMontoPago.Text ?? "").Trim().Replace(",", ".");
            if (!decimal.TryParse(montoRaw, NumberStyles.Any, CultureInfo.InvariantCulture, out montoPago) || montoPago <= 0)
            {
                MostrarMensaje("Ingresa un monto de pago válido mayor a 0.", false);
                return;
            }

            if (!DateTime.TryParse(txtFechaPago.Text, out fechaPago))
            {
                fechaPago = DateTime.Today;
            }

            int idUsuario = Convert.ToInt32(Session["IdUsuario"]);
            string medioPago = ddlMedioPago.SelectedValue;
            string glosaRaw = (txtGlosaPago.Text ?? "").Trim();
            string glosa = string.IsNullOrEmpty(glosaRaw)
                ? string.Format("[{0}] Pago a proveedor CXP-{1:D4}", medioPago, idCuenta)
                : (glosaRaw.StartsWith("[") ? glosaRaw : string.Format("[{0}] {1}", medioPago, glosaRaw));
            if (glosa.Length > 255) glosa = glosa.Substring(0, 255);

            int nuevoIdPago = 0;

            using (MySqlConnection con = new MySqlConnection(connectionString))
            {
                con.Open();
                using (MySqlTransaction trans = con.BeginTransaction())
                {
                    try
                    {
                        decimal montoCuenta = 0m;
                        decimal pagadoPrevio = 0m;

                        using (MySqlCommand cmdLock = new MySqlCommand(@"
                            SELECT cp.Monto, IFNULL((SELECT SUM(Monto) FROM pagoproveedor WHERE IdCuentaPagar = cp.IdCuentaPagar), 0) AS Pagado
                            FROM cuentaporpagar cp
                            WHERE cp.IdCuentaPagar = @Id FOR UPDATE", con, trans))
                        {
                            cmdLock.Parameters.AddWithValue("@Id", idCuenta);
                            using (MySqlDataReader dr = cmdLock.ExecuteReader())
                            {
                                if (!dr.Read())
                                    throw new InvalidOperationException("La cuenta por pagar seleccionada ya no existe.");
                                montoCuenta = Convert.ToDecimal(dr["Monto"]);
                                pagadoPrevio = Convert.ToDecimal(dr["Pagado"]);
                            }
                        }

                        decimal saldoPendiente = montoCuenta - pagadoPrevio;
                        if (saldoPendiente <= 0)
                            throw new InvalidOperationException("Esta cuenta ya se encuentra completamente saldada.");

                        if (montoPago > saldoPendiente)
                            throw new InvalidOperationException(string.Format("El monto ({0:C0}) excede el saldo pendiente ({1:C0}).", montoPago, saldoPendiente));

                        // Validar que la fecha pertenezca al período abierto
                        using (MySqlCommand cmdPer = new MySqlCommand(@"SELECT IdPeriodo FROM periodocontable
                                WHERE IdPeriodo = @IdPer AND Estado = 'Abierto' AND @Fecha BETWEEN FechaInicio AND FechaFin FOR UPDATE", con, trans))
                        {
                            cmdPer.Parameters.AddWithValue("@IdPer", idPeriodo);
                            cmdPer.Parameters.AddWithValue("@Fecha", fechaPago.Date);
                            if (cmdPer.ExecuteScalar() == null)
                                throw new InvalidOperationException("La fecha de pago debe corresponder a un período contable abierto.");
                        }

                        // Obtener cuentas contables imputables (Debe: Proveedores Pasivo, Haber: Caja/Bancos Activo)
                        int idCuentaPasivo = ObtenerCuentaContable(con, trans, "2101", "Pasivo");
                        int idCuentaBanco = ObtenerCuentaContable(con, trans, "1101", "Activo");

                        // 1. Insertar Asiento Contable
                        int idAsiento;
                        using (MySqlCommand cmdAs = new MySqlCommand(@"INSERT INTO asientocontable (IdPeriodo, Fecha, Glosa, IdUsuario)
                                VALUES (@IdPer, @Fecha, @Glosa, @IdUsu); SELECT LAST_INSERT_ID();", con, trans))
                        {
                            cmdAs.Parameters.AddWithValue("@IdPer", idPeriodo);
                            cmdAs.Parameters.AddWithValue("@Fecha", fechaPago.Date);
                            cmdAs.Parameters.AddWithValue("@Glosa", glosa);
                            cmdAs.Parameters.AddWithValue("@IdUsu", idUsuario);
                            idAsiento = Convert.ToInt32(cmdAs.ExecuteScalar());
                        }

                        // 2. Detalle Asiento (Partida doble: Debe Pasivo Proveedores / Haber Caja-Bancos)
                        using (MySqlCommand cmdDet = new MySqlCommand(@"
                            INSERT INTO detalleasiento (IdAsiento, IdCuentaContable, Debe, Haber) VALUES (@Asiento, @Pasivo, @Monto, 0);
                            INSERT INTO detalleasiento (IdAsiento, IdCuentaContable, Debe, Haber) VALUES (@Asiento, @Banco, 0, @Monto);", con, trans))
                        {
                            cmdDet.Parameters.AddWithValue("@Asiento", idAsiento);
                            cmdDet.Parameters.AddWithValue("@Pasivo", idCuentaPasivo);
                            cmdDet.Parameters.AddWithValue("@Banco", idCuentaBanco);
                            cmdDet.Parameters.AddWithValue("@Monto", montoPago);
                            cmdDet.ExecuteNonQuery();
                        }

                        // 3. Insertar PagoProveedor
                        using (MySqlCommand cmdPago = new MySqlCommand(@"INSERT INTO pagoproveedor (IdCuentaPagar, IdAsiento, Monto, Fecha, IdUsuario)
                                VALUES (@IdCxp, @IdAsiento, @Monto, @Fecha, @IdUsu); SELECT LAST_INSERT_ID();", con, trans))
                        {
                            cmdPago.Parameters.AddWithValue("@IdCxp", idCuenta);
                            cmdPago.Parameters.AddWithValue("@IdAsiento", idAsiento);
                            cmdPago.Parameters.AddWithValue("@Monto", montoPago);
                            cmdPago.Parameters.AddWithValue("@Fecha", fechaPago.Date);
                            cmdPago.Parameters.AddWithValue("@IdUsu", idUsuario);
                            nuevoIdPago = Convert.ToInt32(cmdPago.ExecuteScalar());
                        }

                        // Vincular Origen único en asientocontable
                        using (MySqlCommand cmdOrig = new MySqlCommand("UPDATE asientocontable SET Origen = 'PagoProv', IdOrigen = @IdPago WHERE IdAsiento = @IdAsiento", con, trans))
                        {
                            cmdOrig.Parameters.AddWithValue("@IdPago", nuevoIdPago);
                            cmdOrig.Parameters.AddWithValue("@IdAsiento", idAsiento);
                            cmdOrig.ExecuteNonQuery();
                        }

                        // 4. Actualizar estado de CuentaPorPagar (Pagada / Parcial)
                        string nuevoEstado = (pagadoPrevio + montoPago >= montoCuenta) ? "Pagada" : "Parcial";
                        using (MySqlCommand cmdUpd = new MySqlCommand("UPDATE cuentaporpagar SET Estado = @Estado WHERE IdCuentaPagar = @Id", con, trans))
                        {
                            cmdUpd.Parameters.AddWithValue("@Estado", nuevoEstado);
                            cmdUpd.Parameters.AddWithValue("@Id", idCuenta);
                            cmdUpd.ExecuteNonQuery();
                        }

                        trans.Commit();

                        MostrarMensaje(string.Format("Pago PAG-{0:D4} por {1:C0} registrado y contabilizado (Asiento #{2}). Cuenta marcada como {3}.",
                            nuevoIdPago, montoPago, idAsiento, nuevoEstado), true);
                    }
                    catch (Exception ex)
                    {
                        trans.Rollback();
                        MostrarMensaje("Error al registrar pago: " + ex.Message, false);
                        return;
                    }
                }
            }

            txtGlosaPago.Text = "";
            txtMontoPago.Text = "";
            pnlFormPago.Visible = false;
            CargarCuentasPendientesCombo();
            CargarListadoCuentas();
            CargarHistorialPagos();
            CalcularKPIs();

            if (nuevoIdPago > 0)
            {
                AbrirComprobantePago(nuevoIdPago);
            }
        }

        private int ObtenerCuentaContable(MySqlConnection con, MySqlTransaction trans, string codigoPreferido, string tipoFallback)
        {
            using (MySqlCommand cmd = new MySqlCommand(@"SELECT IdCuentaContable FROM cuentacontable
                    WHERE Imputable = 1 AND (Codigo = @Cod OR Tipo = @Tipo)
                    ORDER BY CASE WHEN Codigo = @Cod THEN 0 ELSE 1 END, Codigo ASC LIMIT 1", con, trans))
            {
                cmd.Parameters.AddWithValue("@Cod", codigoPreferido);
                cmd.Parameters.AddWithValue("@Tipo", tipoFallback);
                object res = cmd.ExecuteScalar();
                if (res == null)
                    throw new InvalidOperationException(string.Format("Falta configurar una cuenta contable imputable de tipo {0} (código {1}).", tipoFallback, codigoPreferido));
                return Convert.ToInt32(res);
            }
        }

        protected void gvCuentasPagar_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            if (e.CommandName == "PrepararPago")
            {
                pnlFormPago.Visible = true;
                CargarCuentasPendientesCombo();
                string idCxp = Convert.ToString(e.CommandArgument);
                if (ddlCuentaPago.Items.FindByValue(idCxp) != null)
                {
                    ddlCuentaPago.SelectedValue = idCxp;
                }
                txtGlosaPago.Text = "";
                txtMontoPago.Text = "";
                ActualizarMontoSegunCuenta();
            }
        }

        protected void gvPagos_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            if (e.CommandName == "VerComprobante")
            {
                int idPago;
                if (int.TryParse(Convert.ToString(e.CommandArgument), out idPago))
                {
                    AbrirComprobantePago(idPago);
                }
            }
        }

        private void AbrirComprobantePago(int idPago)
        {
            string sql = @"SELECT pp.IdPagoProveedor, pp.Fecha, pp.Monto, pp.IdAsiento,
                                  IFNULL(a.Glosa, 'Pago a proveedor') AS Glosa,
                                  cp.IdCuentaPagar, cp.Monto AS TotalCuenta, cp.IdRecepcion,
                                  oc.NumeroOC, l.RazonSocial AS Laboratorio, l.Rut, u.Nombre AS Usuario,
                                  IFNULL((SELECT SUM(Monto) FROM pagoproveedor p2 WHERE p2.IdCuentaPagar = cp.IdCuentaPagar AND p2.IdPagoProveedor <= pp.IdPagoProveedor), 0) AS PagadoAcumulado
                           FROM pagoproveedor pp
                           INNER JOIN cuentaporpagar cp ON cp.IdCuentaPagar = pp.IdCuentaPagar
                           INNER JOIN recepcioncompra r ON r.IdRecepcion = cp.IdRecepcion
                           INNER JOIN ordencompra oc ON oc.IdOC = r.IdOC
                           INNER JOIN laboratorio l ON l.IdLaboratorio = cp.IdLaboratorio
                           INNER JOIN asientocontable a ON a.IdAsiento = pp.IdAsiento
                           INNER JOIN usuario u ON u.IdUsuario = pp.IdUsuario
                           WHERE pp.IdPagoProveedor = @IdPago";

            using (MySqlConnection con = new MySqlConnection(connectionString))
            using (MySqlCommand cmd = new MySqlCommand(sql, con))
            {
                cmd.Parameters.AddWithValue("@IdPago", idPago);
                con.Open();
                using (MySqlDataReader dr = cmd.ExecuteReader())
                {
                    if (dr.Read())
                    {
                        decimal montoPago = Convert.ToDecimal(dr["Monto"]);
                        decimal totalCuenta = Convert.ToDecimal(dr["TotalCuenta"]);
                        decimal pagadoAcum = Convert.ToDecimal(dr["PagadoAcumulado"]);
                        decimal saldoRem = Math.Max(0m, totalCuenta - pagadoAcum);

                        lblRecFolio.Text = string.Format("PAG-{0:D4}", idPago);
                        lblRecFecha.Text = Convert.ToDateTime(dr["Fecha"]).ToString("dd/MM/yyyy");
                        lblRecAsiento.Text = "#" + dr["IdAsiento"].ToString();
                        lblRecProveedor.Text = dr["Laboratorio"].ToString();
                        lblRecRut.Text = dr["Rut"].ToString();
                        lblRecReferencia.Text = string.Format("CXP-{0:D4} · REC-{1:D4} · {2}",
                            Convert.ToInt32(dr["IdCuentaPagar"]), Convert.ToInt32(dr["IdRecepcion"]), dr["NumeroOC"]);
                        lblRecModalidad.Text = saldoRem <= 0m ? "Cancelación Total" : "Abono Parcial";
                        lblRecMonto.Text = string.Format("{0:C0}", montoPago);
                        lblRecTotalOriginal.Text = string.Format("{0:C0}", totalCuenta);
                        lblRecSaldoRemanente.Text = string.Format("{0:C0}", saldoRem);
                        lblRecGlosa.Text = dr["Glosa"].ToString();
                        lblRecUsuario.Text = dr["Usuario"].ToString();

                        // Inyección obligatoria del nombre oficial desde ConfiguracionGlobal.NombreContador
                        lblFirmaContador.Text = ConfiguracionGlobal.NombreContador;
                    }
                }
            }

            pnlModalRecibo.Visible = true;
        }

        protected void btnCerrarRecibo_Click(object sender, EventArgs e)
        {
            pnlModalRecibo.Visible = false;
        }

        protected void Filtro_Changed(object sender, EventArgs e)
        {
            CargarListadoCuentas();
        }

        protected void btnLimpiar_Click(object sender, EventArgs e)
        {
            txtBuscar.Text = "";
            ddlFiltroLab.SelectedIndex = 0;
            ddlFiltroEstado.SelectedIndex = 0;
            CargarListadoCuentas();
        }

        protected string FormatDiasRestantes(object diasObj, object saldoObj)
        {
            decimal saldo = Convert.ToDecimal(saldoObj);
            if (saldo <= 0) return "Saldada";

            int dias = Convert.ToInt32(diasObj);
            if (dias < 0) return string.Format("Vencida hace {0} d.", Math.Abs(dias));
            if (dias == 0) return "Vence hoy";
            return string.Format("Vence en {0} d.", dias);
        }

        protected string GetClaseEstado(object estadoObj)
        {
            string estado = Convert.ToString(estadoObj).ToLowerInvariant();
            if (estado.Contains("pagad")) return "badge-cxp-pagada";
            if (estado.Contains("parcial")) return "badge-cxp-parcial";
            if (estado.Contains("vencid")) return "badge-cxp-vencida";
            return "badge-cxp-pendiente";
        }

        private void MostrarMensaje(string msg, bool exito)
        {
            lblMensaje.Text = msg;
            lblMensaje.Visible = true;
            lblMensaje.Style["background-color"] = exito ? "#E8F8F0" : "#FDEDEC";
            lblMensaje.Style["color"] = exito ? "#1E8449" : "#922B21";
            lblMensaje.Style["border"] = exito ? "1px solid #A9DFBF" : "1px solid #F5B7B1";
        }

        protected void btnLogout_Click(object sender, EventArgs e)
        {
            Session.Clear();
            Session.Abandon();
            Response.Redirect("Login.aspx");
        }
    }
}
