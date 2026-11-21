
using System;
using System.Configuration;
using System.Data;
using System.Text;
using MySql.Data.MySqlClient;

namespace trabajo_ing_software
{
    public partial class ReporteInventario : PaginaInventario
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                CargarReporte();
            }
        }

        private DataTable ObtenerDatos()
        {
            string cadena = ConfigurationManager
                .ConnectionStrings["DefaultConnection"]
                .ConnectionString;

            string sql = @"
                SELECT
                    p.Nombre AS Producto,
                    v.Sku AS SKU,
                    b.Nombre AS Bodega,
                    COALESCE(i.StockActual, 0)
                        AS StockActual,
                    COALESCE(p.StockMinimo, 0)
                        AS StockMinimo,
                    CASE
                        WHEN COALESCE(i.StockActual, 0) <= 0
                            THEN 'Sin stock'
                        WHEN p.StockMinimo IS NOT NULL
                             AND i.StockActual <= p.StockMinimo
                            THEN 'Stock bajo'
                        ELSE 'Disponible'
                    END AS EstadoStock
                FROM inventario i
                INNER JOIN varianteproducto v
                    ON i.IdVariante = v.IdVariante
                INNER JOIN producto p
                    ON v.IdProducto = p.IdProducto
                INNER JOIN bodega b
                    ON i.IdBodega = b.IdBodega
                WHERE p.Activo = 1
                  AND v.Activo = 1
                  AND b.Activo = 1
                ORDER BY p.Nombre, v.Sku, b.Nombre";

            DataTable tabla = new DataTable();

            using (MySqlConnection conexion =
                new MySqlConnection(cadena))
            using (MySqlCommand comando =
                new MySqlCommand(sql, conexion))
            using (MySqlDataAdapter adaptador =
                new MySqlDataAdapter(comando))
            {
                adaptador.Fill(tabla);
            }

            return tabla;
        }

        private void CargarReporte()
        {
            try
            {
                DataTable tabla = ObtenerDatos();

                gvReporte.DataSource = tabla;
                gvReporte.DataBind();

                int disponibles = 0;
                int bajos = 0;
                int sinStock = 0;

                foreach (DataRow fila in tabla.Rows)
                {
                    string estado =
                        fila["EstadoStock"].ToString();

                    if (estado == "Disponible")
                        disponibles++;
                    else if (estado == "Stock bajo")
                        bajos++;
                    else if (estado == "Sin stock")
                        sinStock++;
                }

                lblTotal.Text = tabla.Rows.Count.ToString();
                lblDisponibles.Text = disponibles.ToString();
                lblStockBajo.Text = bajos.ToString();
                lblSinStock.Text = sinStock.ToString();

                lblMensaje.Text =
                    "Registros encontrados: " +
                    tabla.Rows.Count;
            }
            catch (Exception)
            {
                gvReporte.DataSource = null;
                gvReporte.DataBind();

                lblTotal.Text = "0";
                lblDisponibles.Text = "0";
                lblStockBajo.Text = "0";
                lblSinStock.Text = "0";

                lblMensaje.Text =
                    "No fue posible generar el reporte. " +
                    "Verifica la conexión con MySQL.";

                btnExportar.Enabled = false;
            }
        }

        // EXPORTACIÓN CSV
        protected void btnExportar_Click(
            object sender, EventArgs e)
        {
            try
            {
                DataTable tabla = ObtenerDatos();

                StringBuilder csv = new StringBuilder();

                csv.AppendLine(
                    "Producto;SKU;Bodega;Stock actual;" +
                    "Stock mínimo;Estado");

                foreach (DataRow fila in tabla.Rows)
                {
                    string[] columnas = {
                        fila["Producto"].ToString(),
                        fila["SKU"].ToString(),
                        fila["Bodega"].ToString(),
                        fila["StockActual"].ToString(),
                        fila["StockMinimo"].ToString(),
                        fila["EstadoStock"].ToString()
                    };

                    for (int i = 0; i < columnas.Length; i++)
                    {
                        string valor = columnas[i] ?? "";

                        // Evita fórmulas al abrir CSV
                        // en aplicaciones de hojas de cálculo.
                        if (valor.StartsWith("=") ||
                            valor.StartsWith("+") ||
                            valor.StartsWith("-") ||
                            valor.StartsWith("@"))
                        {
                            valor = "'" + valor;
                        }

                        columnas[i] = "\"" +
                            valor.Replace("\"", "\"\"") + "\"";
                    }

                    csv.AppendLine(
                        string.Join(";", columnas));
                }

                byte[] archivo = new UTF8Encoding(true)
                    .GetBytes(csv.ToString());

                Response.Clear();
                Response.ContentType =
                    "text/csv; charset=utf-8";

                Response.AddHeader(
                    "Content-Disposition",
                    "attachment; filename=ReporteInventario.csv");

                Response.BinaryWrite(archivo);
                Response.Flush();
                Response.SuppressContent = true;

                Context.ApplicationInstance
                    .CompleteRequest();
            }
            catch (Exception)
            {
                lblMensaje.Text =
                    "No fue posible exportar el reporte.";
            }
        }
    }
}
