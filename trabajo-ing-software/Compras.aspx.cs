using System;
using System.Data;
using System.Globalization;
using System.Linq;
using System.Web.UI;
using MySql.Data.MySqlClient;

namespace trabajo_ing_software
{
    public partial class Compras : Page
    {
        private static readonly CultureInfo Cultura = CultureInfo.GetCultureInfo("es-CL");

        protected override void OnLoad(EventArgs e)
        {
            base.OnLoad(e);
            if (Session["IdUsuario"] == null)
            {
                Acceso.Visible = true;
                return;
            }

            string rol = Convert.ToString(Session["RolUsuario"]).Trim().ToUpperInvariant();
            if (rol != "ADMINISTRADOR" && rol != "COMPRADOR" && rol != "BODEGUERO" && rol != "CONTADOR")
            {
                Mensaje.Text = "Tu perfil no tiene acceso al resumen de Compras.";
                Mensaje.Visible = true;
                return;
            }

            try
            {
                DateTime hoy = DateTime.Today;
                DateTime mes = new DateTime(hoy.Year, hoy.Month, 1);
                var indicadores = VentaInventario.Consultar(@"SELECT
                    (SELECT COALESCE(SUM(Total),0) FROM ordencompra
                        WHERE Fecha>=@p0 AND Fecha<@p1 AND Estado IN ('Emitida','Parcial','Recibida')) AS Importe,
                    (SELECT COUNT(*) FROM ordencompra WHERE Estado IN ('Emitida','Parcial')) AS Pendientes,
                    (SELECT COUNT(*) FROM recepcioncompra WHERE FechaRecepcion>=@p0 AND FechaRecepcion<@p1) AS Recepciones,
                    (SELECT COUNT(*) FROM laboratorio WHERE Activo=1) AS Proveedores",
                    mes, mes.AddMonths(1)).Rows[0];

                Importe.Text = Moneda(Convert.ToDecimal(indicadores["Importe"]));
                Pendientes.Text = Convert.ToInt32(indicadores["Pendientes"]).ToString("N0", Cultura);
                RecepcionesMes.Text = Convert.ToInt32(indicadores["Recepciones"]).ToString("N0", Cultura);
                Proveedores.Text = Convert.ToInt32(indicadores["Proveedores"]).ToString("N0", Cultura);
                CargarGrafico(mes);

                var ordenes = VentaInventario.Consultar(@"SELECT o.NumeroOC,l.RazonSocial AS Proveedor,o.Estado,
                    COALESCE(o.Total,0) AS Total FROM ordencompra o
                    JOIN laboratorio l ON l.IdLaboratorio=o.IdLaboratorio
                    ORDER BY o.Fecha DESC,o.IdOC DESC LIMIT 5");
                ordenes.Columns.Add("Importe", typeof(string));
                foreach (DataRow orden in ordenes.Rows)
                    orden["Importe"] = Moneda(Convert.ToDecimal(orden["Total"]));
                Ordenes.DataSource = ordenes;
                Ordenes.DataBind();
                if (Ordenes.HeaderRow != null) Ordenes.HeaderRow.TableSection = System.Web.UI.WebControls.TableRowSection.TableHeader;
                Panel.Visible = true;
            }
            catch (MySqlException ex)
            {
                System.Diagnostics.Trace.TraceError(ex.ToString());
                Mensaje.Text = "No se pudo cargar el resumen de Compras. Intenta actualizar la página.";
                Mensaje.Visible = true;
            }
        }

        private void CargarGrafico(DateTime mes)
        {
            DateTime primero = mes.AddMonths(-5);
            var datos = VentaInventario.Consultar(@"SELECT EXTRACT(YEAR_MONTH FROM Fecha) AS Mes,
                COALESCE(SUM(Total),0) AS Total FROM ordencompra
                WHERE Fecha>=@p0 AND Fecha<@p1 AND Estado IN ('Emitida','Parcial','Recibida')
                GROUP BY EXTRACT(YEAR_MONTH FROM Fecha)", primero, mes.AddMonths(1));
            var totales = datos.AsEnumerable().ToDictionary(
                fila => Convert.ToInt32(fila["Mes"]), fila => Convert.ToDecimal(fila["Total"]));
            decimal maximo = totales.Count == 0 ? 0 : totales.Values.Max();
            Meses.DataSource = Enumerable.Range(0, 6).Select(indice =>
            {
                DateTime fecha = primero.AddMonths(indice);
                totales.TryGetValue(fecha.Year * 100 + fecha.Month, out decimal valor);
                return new
                {
                    Mes = fecha.ToString("MMM", Cultura),
                    Importe = Moneda(valor),
                    Altura = maximo > 0 ? Math.Round(valor / maximo * 100).ToString(CultureInfo.InvariantCulture) : "0"
                };
            }).ToList();
            Meses.DataBind();
            SinCompras.Visible = maximo <= 0;
        }

        private static string Moneda(decimal importe)
        {
            return importe.ToString("C0", Cultura);
        }
    }
}
