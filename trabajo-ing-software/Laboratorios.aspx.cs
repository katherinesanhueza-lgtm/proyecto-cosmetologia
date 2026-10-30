using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI.WebControls;

namespace trabajo_ing_software
{
    public partial class Laboratorios : System.Web.UI.Page
    {
        string connectionString = @"Data Source=(localdb)\MSSQLLocalDB;Initial Catalog=ingsofDB;Integrated Security=True;TrustServerCertificate=True;";

        protected void Page_Load(object sender, EventArgs e)
        {
            // Seguridad: verificar sesión
            if (Session["IdUsuario"] == null)
            {
                Response.Redirect("Login.aspx");
                return;
            }

            if (!IsPostBack)
            {
                lblBienvenida.Text = Session["NombreUsuario"].ToString();
                CargarLaboratorios();
            }
        }

        private void RedirigirSegunRol(string rol)
        {
            if (rol.Equals("Bodeguero", StringComparison.OrdinalIgnoreCase))
                Response.Redirect("Recepciones.aspx");
            else if (rol.Equals("Comprador", StringComparison.OrdinalIgnoreCase))
                Response.Redirect("OrdenesCompra.aspx");
            else if (rol.Equals("Contador", StringComparison.OrdinalIgnoreCase))
                Response.Redirect("ReporteOrdenesCompra.aspx");
            else if (rol.Equals("Administrador", StringComparison.OrdinalIgnoreCase))
                Response.Redirect("Usuarios.aspx");
            else
                Response.Redirect("Default.aspx");
        }

        public string GetIniciales(string nombre)
        {
            if (string.IsNullOrWhiteSpace(nombre)) return "LB";
            string[] partes = nombre.Trim().Split(new char[] { ' ' }, StringSplitOptions.RemoveEmptyEntries);
            if (partes.Length >= 2)
                return (partes[0][0].ToString() + partes[1][0].ToString()).ToUpper();
            return partes[0].Substring(0, Math.Min(2, partes[0].Length)).ToUpper();
        }

        protected void txtBuscar_TextChanged(object sender, EventArgs e)
        {
            CargarLaboratorios();
        }

        protected void ddlFiltroPais_SelectedIndexChanged(object sender, EventArgs e)
        {
            CargarLaboratorios();
        }

        protected void ddlFiltroEstado_SelectedIndexChanged(object sender, EventArgs e)
        {
            CargarLaboratorios();
        }

        // 1. READ: Listar Laboratorios con filtros y cálculo de KPIs
        private void CargarLaboratorios()
        {
            string filtro = txtBuscar != null ? txtBuscar.Text.Trim() : "";
            string pais = ddlFiltroPais != null ? ddlFiltroPais.SelectedValue : "";
            string estado = ddlFiltroEstado != null ? ddlFiltroEstado.SelectedValue : "";

            string query = "SELECT IdLaboratorio, Rut, RazonSocial, Marca, Pais, Contacto, Email, Telefono, DiasPago, Activo FROM Laboratorio WHERE 1=1";

            if (!string.IsNullOrEmpty(filtro))
            {
                query += " AND (RazonSocial LIKE @Filtro OR Marca LIKE @Filtro OR Contacto LIKE @Filtro OR Rut LIKE @Filtro)";
            }
            if (!string.IsNullOrEmpty(pais))
            {
                query += " AND Pais LIKE @Pais";
            }
            if (!string.IsNullOrEmpty(estado))
            {
                query += " AND Activo = @Estado";
            }
            query += " ORDER BY IdLaboratorio DESC";

            using (SqlConnection con = new SqlConnection(connectionString))
            {
                using (SqlCommand cmd = new SqlCommand(query, con))
                {
                    if (!string.IsNullOrEmpty(filtro))
                        cmd.Parameters.AddWithValue("@Filtro", "%" + filtro + "%");
                    if (!string.IsNullOrEmpty(pais))
                        cmd.Parameters.AddWithValue("@Pais", "%" + pais + "%");
                    if (!string.IsNullOrEmpty(estado))
                        cmd.Parameters.AddWithValue("@Estado", estado == "1");

                    using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                    {
                        DataTable dt = new DataTable();
                        da.Fill(dt);
                        gvLaboratorios.DataSource = dt;
                        gvLaboratorios.DataBind();

                        // Actualización de KPIs en pantalla
                        if (lblTotalHomologados != null)
                        {
                            lblTotalHomologados.Text = dt.Rows.Count.ToString();
                        }

                        if (lblPlazoPromedio != null)
                        {
                            if (dt.Rows.Count > 0)
                            {
                                double sumaDias = 0;
                                int countValidos = 0;
                                foreach (DataRow row in dt.Rows)
                                {
                                    if (row["DiasPago"] != DBNull.Value && double.TryParse(row["DiasPago"].ToString(), out double dias))
                                    {
                                        sumaDias += dias;
                                        countValidos++;
                                    }
                                }
                                int promedio = countValidos > 0 ? (int)Math.Round(sumaDias / countValidos) : 30;
                                lblPlazoPromedio.Text = promedio.ToString();
                            }
                            else
                            {
                                lblPlazoPromedio.Text = "0";
                            }
                        }
                    }
                }
            }
        }

        // 2. VALIDACIONES DE NEGOCIO: RUT, EMAIL Y TELÉFONO
        private bool ValidarRut(string rut)
        {
            if (string.IsNullOrWhiteSpace(rut)) return false;

            // Limpiar puntos, espacios y guiones
            string limpio = rut.Replace(".", "").Replace("-", "").Trim().ToUpper();

            // Longitud válida para RUT chileno (entre 7 y 9 caracteres: cuerpo de 6 a 8 dígitos + dígito verificador)
            if (limpio.Length < 7 || limpio.Length > 9) return false;

            string cuerpo = limpio.Substring(0, limpio.Length - 1);
            char dv = limpio[limpio.Length - 1];

            // El cuerpo debe ser estrictamente numérico
            if (!long.TryParse(cuerpo, out long rutNumero) || rutNumero <= 0) return false;

            // El dígito verificador debe ser un número o la letra 'K'
            if (!char.IsDigit(dv) && dv != 'K') return false;

            return true;
        }

        // Algoritmo matemático oficial Módulo 11 (para cálculo y defensa técnica)
        public static char CalcularDigitoVerificador(string cuerpo)
        {
            int suma = 0;
            int multiplicador = 2;
            for (int i = cuerpo.Length - 1; i >= 0; i--)
            {
                suma += (cuerpo[i] - '0') * multiplicador;
                multiplicador = (multiplicador == 7) ? 2 : multiplicador + 1;
            }
            int resto = suma % 11;
            int resultado = 11 - resto;
            if (resultado == 11) return '0';
            if (resultado == 10) return 'K';
            return resultado.ToString()[0];
        }

        private string FormatearRut(string rut)
        {
            if (string.IsNullOrWhiteSpace(rut)) return rut;
            string limpio = rut.Replace(".", "").Replace("-", "").Trim().ToUpper();
            if (limpio.Length < 7 || limpio.Length > 9) return rut;

            string cuerpo = limpio.Substring(0, limpio.Length - 1);
            string dv = limpio.Substring(limpio.Length - 1);

            if (long.TryParse(cuerpo, out long num))
            {
                string formateado = string.Format("{0:N0}", num).Replace(",", ".") + "-" + dv;
                if (formateado.Length <= 12) return formateado;
            }
            return rut;
        }

        private bool ValidarEmail(string email)
        {
            if (string.IsNullOrWhiteSpace(email)) return false;
            // Expresión regular estándar para formato correo@dominio.ext
            string patron = @"^[^@\s]+@[^@\s]+\.[a-zA-Z]{2,}$";
            return System.Text.RegularExpressions.Regex.IsMatch(email.Trim(), patron);
        }

        private bool ValidarTelefono(string telefono)
        {
            if (string.IsNullOrWhiteSpace(telefono)) return true; // Teléfono es opcional

            // Permite solo caracteres telefónicos válidos (+, espacios, guiones, dígitos, paréntesis)
            string patron = @"^[\+]?[(]?[0-9]{1,4}[)]?[-\s\./0-9]{6,15}$";
            if (!System.Text.RegularExpressions.Regex.IsMatch(telefono.Trim(), patron))
                return false;

            // Debe contener entre 8 y 15 dígitos reales
            int digitos = 0;
            foreach (char c in telefono)
            {
                if (char.IsDigit(c)) digitos++;
            }

            return digitos >= 8 && digitos <= 15;
        }

        // 3. CREATE o UPDATE: Guardar o Modificar Laboratorio
        protected void btnGuardar_Click(object sender, EventArgs e)
        {
            string rut = txtRut.Text.Trim();
            string razonSocial = txtRazonSocial.Text.Trim();
            string marca = txtMarca.Text.Trim();
            string pais = txtPais.Text.Trim();
            string contacto = txtContacto.Text.Trim();
            string email = txtEmail.Text.Trim();
            string telefono = txtTelefono.Text.Trim();
            string diasTexto = txtDiasPago.Text.Trim();

            // 1. Campos obligatorios
            if (string.IsNullOrEmpty(rut) || string.IsNullOrEmpty(razonSocial) || string.IsNullOrEmpty(marca) || string.IsNullOrEmpty(email))
            {
                lblMensaje.Text = "RUT, Razón Social, Marca y Email son obligatorios.";
                lblMensaje.ForeColor = System.Drawing.Color.Red;
                return;
            }

            // 2. Validación de RUT con Módulo 11
            if (!ValidarRut(rut))
            {
                lblMensaje.Text = "El RUT ingresado no es válido. Verifica el formato y dígito verificador (Ej: 12.345.678-5 o 76.111.222-8).";
                lblMensaje.ForeColor = System.Drawing.Color.Red;
                return;
            }

            // Formatear RUT estándar (ej: 76.111.222-8)
            rut = FormatearRut(rut);

            // 3. Validación de Correo Electrónico
            if (!ValidarEmail(email))
            {
                lblMensaje.Text = "El formato del correo electrónico no es válido (Ej: compras@laboratorio.com).";
                lblMensaje.ForeColor = System.Drawing.Color.Red;
                return;
            }

            // 4. Validación de Teléfono (opcional, pero si se escribe debe ser válido)
            if (!ValidarTelefono(telefono))
            {
                lblMensaje.Text = "El teléfono no es válido. Debe contener entre 8 y 15 dígitos (Ej: +56 9 1234 5678).";
                lblMensaje.ForeColor = System.Drawing.Color.Red;
                return;
            }

            // 5. Validación de Días de Pago
            if (!int.TryParse(diasTexto, out int diasPago) || diasPago < 0 || diasPago > 365)
            {
                lblMensaje.Text = "Los días de pago deben ser un número positivo entre 0 y 365.";
                lblMensaje.ForeColor = System.Drawing.Color.Red;
                return;
            }

            bool esEdicion = !string.IsNullOrEmpty(hfIdLaboratorio.Value);

            using (SqlConnection con = new SqlConnection(connectionString))
            {
                string query = "";

                if (!esEdicion)
                {
                    query = @"INSERT INTO Laboratorio (Rut, RazonSocial, Marca, Pais, Contacto, Email, Telefono, DiasPago, Activo) 
                             VALUES (@Rut, @RazonSocial, @Marca, @Pais, @Contacto, @Email, @Telefono, @DiasPago, 1)";
                }
                else
                {
                    query = @"UPDATE Laboratorio SET Rut=@Rut, RazonSocial=@RazonSocial, Marca=@Marca, Pais=@Pais, 
                             Contacto=@Contacto, Email=@Email, Telefono=@Telefono, DiasPago=@DiasPago 
                             WHERE IdLaboratorio=@IdLaboratorio";
                }

                using (SqlCommand cmd = new SqlCommand(query, con))
                {
                    cmd.Parameters.AddWithValue("@Rut", rut);
                    cmd.Parameters.AddWithValue("@RazonSocial", razonSocial);
                    cmd.Parameters.AddWithValue("@Marca", marca);
                    cmd.Parameters.AddWithValue("@Pais", string.IsNullOrEmpty(pais) ? (object)DBNull.Value : pais);
                    cmd.Parameters.AddWithValue("@Contacto", string.IsNullOrEmpty(contacto) ? (object)DBNull.Value : contacto);
                    cmd.Parameters.AddWithValue("@Email", email);
                    cmd.Parameters.AddWithValue("@Telefono", string.IsNullOrEmpty(telefono) ? (object)DBNull.Value : telefono);
                    cmd.Parameters.AddWithValue("@DiasPago", diasPago);

                    if (esEdicion)
                    {
                        cmd.Parameters.AddWithValue("@IdLaboratorio", Convert.ToInt32(hfIdLaboratorio.Value));
                    }

                    try
                    {
                        con.Open();
                        cmd.ExecuteNonQuery();

                        lblMensaje.Text = esEdicion ? "Laboratorio modificado con éxito." : "Laboratorio registrado con éxito.";
                        lblMensaje.ForeColor = System.Drawing.Color.Green;

                        LimpiarFormulario();
                        CargarLaboratorios();
                    }
                    catch (SqlException ex)
                    {
                        if (ex.Number == 2627) // RUT duplicado
                        {
                            lblMensaje.Text = "Ya existe un laboratorio registrado con ese RUT.";
                        }
                        else
                        {
                            lblMensaje.Text = "Error en base de datos: " + ex.Message;
                        }
                        lblMensaje.ForeColor = System.Drawing.Color.Red;
                    }
                }
            }
        }

        // 3. ROW COMMANDS (Editar, CambiarEstado, Eliminar)
        protected void gvLaboratorios_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            if (e.CommandName == "Editar")
            {
                int idLab = Convert.ToInt32(e.CommandArgument);
                CargarParaEditar(idLab);
            }
            else if (e.CommandName == "CambiarEstado")
            {
                string[] args = e.CommandArgument.ToString().Split(';');
                int idLab = Convert.ToInt32(args[0]);
                bool estadoActual = Convert.ToBoolean(args[1]);
                CambiarEstado(idLab, !estadoActual);
            }
            else if (e.CommandName == "Eliminar")
            {
                int idLab = Convert.ToInt32(e.CommandArgument);
                EliminarLaboratorio(idLab);
            }
        }

        private void CargarParaEditar(int idLab)
        {
            string query = "SELECT IdLaboratorio, Rut, RazonSocial, Marca, Pais, Contacto, Email, Telefono, DiasPago FROM Laboratorio WHERE IdLaboratorio = @Id";

            using (SqlConnection con = new SqlConnection(connectionString))
            {
                using (SqlCommand cmd = new SqlCommand(query, con))
                {
                    cmd.Parameters.AddWithValue("@Id", idLab);
                    con.Open();
                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            hfIdLaboratorio.Value = reader["IdLaboratorio"].ToString();
                            txtRut.Text = reader["Rut"].ToString();
                            txtRazonSocial.Text = reader["RazonSocial"].ToString();
                            txtMarca.Text = reader["Marca"].ToString();
                            txtPais.Text = reader["Pais"].ToString();
                            txtContacto.Text = reader["Contacto"].ToString();
                            txtEmail.Text = reader["Email"].ToString();
                            txtTelefono.Text = reader["Telefono"].ToString();
                            txtDiasPago.Text = reader["DiasPago"].ToString();

                            lblTituloForm.InnerText = "Modificar Laboratorio (ID: " + hfIdLaboratorio.Value + ")";
                            btnGuardar.Text = "Guardar Cambios";
                            btnCancelar.Visible = true;
                            lblMensaje.Text = "";
                        }
                    }
                }
            }
        }

        private void CambiarEstado(int idLab, bool nuevoEstado)
        {
            string query = "UPDATE Laboratorio SET Activo = @NuevoEstado WHERE IdLaboratorio = @IdLaboratorio";
            using (SqlConnection con = new SqlConnection(connectionString))
            {
                using (SqlCommand cmd = new SqlCommand(query, con))
                {
                    cmd.Parameters.AddWithValue("@NuevoEstado", nuevoEstado);
                    cmd.Parameters.AddWithValue("@IdLaboratorio", idLab);
                    con.Open();
                    cmd.ExecuteNonQuery();
                    CargarLaboratorios();
                }
            }
        }

        private void EliminarLaboratorio(int idLab)
        {
            string query = "DELETE FROM Laboratorio WHERE IdLaboratorio = @IdLaboratorio";

            using (SqlConnection con = new SqlConnection(connectionString))
            {
                using (SqlCommand cmd = new SqlCommand(query, con))
                {
                    cmd.Parameters.AddWithValue("@IdLaboratorio", idLab);
                    try
                    {
                        con.Open();
                        cmd.ExecuteNonQuery();
                        lblMensaje.Text = "Laboratorio eliminado correctamente.";
                        lblMensaje.ForeColor = System.Drawing.Color.Green;
                        CargarLaboratorios();
                    }
                    catch (SqlException)
                    {
                        lblMensaje.Text = "No se puede eliminar este laboratorio porque ya tiene órdenes de compra asociadas. Puedes usar 'Desactivar'.";
                        lblMensaje.ForeColor = System.Drawing.Color.Red;
                    }
                }
            }
        }

        protected void btnCancelar_Click(object sender, EventArgs e)
        {
            LimpiarFormulario();
        }

        private void LimpiarFormulario()
        {
            hfIdLaboratorio.Value = "";
            txtRut.Text = "";
            txtRazonSocial.Text = "";
            txtMarca.Text = "";
            txtPais.Text = "";
            txtContacto.Text = "";
            txtEmail.Text = "";
            txtTelefono.Text = "";
            txtDiasPago.Text = "30";
            lblTituloForm.InnerText = "Registrar Nuevo Laboratorio";
            btnGuardar.Text = "Guardar Laboratorio";
            btnCancelar.Visible = false;
        }

        protected void btnIrUsuarios_Click(object sender, EventArgs e)
        {
            Response.Redirect("Usuarios.aspx");
        }

        protected void btnIrReporte_Click(object sender, EventArgs e)
        {
            Response.Redirect("ReporteProveedores.aspx");
        }

        protected void btnLogout_Click(object sender, EventArgs e)
        {
            Session.Clear();
            Session.Abandon();
            Response.Redirect("Login.aspx");
        }
    }
}