
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Globalization;
using System.Linq;
using MySql.Data.MySqlClient;

namespace trabajo_ing_software
{
    public partial class Inventario : PaginaInventario
    {
        private string CadenaConexion
        {
            get
            {
                return ConfigurationManager
                    .ConnectionStrings["DefaultConnection"]
                    .ConnectionString;
            }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            bool esExistencias = string.Equals(Request.QueryString["vista"], "existencias", StringComparison.OrdinalIgnoreCase);

            pnlResumenInventario.Visible = !esExistencias;
            pnlExistenciasInventario.Visible = esExistencias;
            Page.Title = esExistencias ? "Existencias de Inventario" : "Resumen de Inventario";

            if (!esExistencias)
            {
                CargarResumenInventario();
                return;
            }

            if (!IsPostBack)
            {
                CargarBodegas();
                CargarInventario();
            }
        }

        private void CargarResumenInventario()
        {
            try
            {
                var cultura = new CultureInfo("es-CL");
                using (MySqlConnection conexion = new MySqlConnection(CadenaConexion))
                {
                    conexion.Open();
                    string sql = @"
                        SELECT
                            COALESCE((SELECT COUNT(*) FROM producto WHERE Activo = 1), 0) AS Productos,
                            COALESCE((SELECT SUM(StockActual) FROM inventario), 0) AS StockTotal,
                            COALESCE((SELECT COUNT(DISTINCT p.IdProducto)
                                      FROM producto p
                                      INNER JOIN varianteproducto v ON p.IdProducto = v.IdProducto
                                      INNER JOIN inventario i ON v.IdVariante = i.IdVariante
                                      INNER JOIN bodega b ON i.IdBodega = b.IdBodega
                                      WHERE p.Activo = 1 AND v.Activo = 1 AND b.Activo = 1
                                        AND i.StockActual <= COALESCE(p.StockMinimo, 0)), 0) AS Alertas,
                            COALESCE((SELECT COUNT(*) FROM lote WHERE CantidadDisponible > 0), 0) AS Lotes";
                    using (MySqlCommand cmd = new MySqlCommand(sql, conexion))
                    using (MySqlDataReader dr = cmd.ExecuteReader())
                    {
                        if (dr.Read())
                        {
                            litInvProductos.Text = Convert.ToInt32(dr["Productos"]).ToString("N0", cultura);
                            litInvStockTotal.Text = Convert.ToInt32(dr["StockTotal"]).ToString("N0", cultura);
                            litInvStockBajo.Text = Convert.ToInt32(dr["Alertas"]).ToString("N0", cultura);
                            litInvLotes.Text = Convert.ToInt32(dr["Lotes"]).ToString("N0", cultura);
                        }
                    }

                    // Gráfico de barras de existencias por producto
                    string sqlBarras = @"
                        SELECT p.Nombre AS Producto, COALESCE(SUM(i.StockActual), 0) AS TotalStock
                        FROM producto p
                        LEFT JOIN varianteproducto v ON v.IdProducto = p.IdProducto
                        LEFT JOIN inventario i ON i.IdVariante = v.IdVariante
                        WHERE p.Activo = 1
                        GROUP BY p.IdProducto, p.Nombre
                        ORDER BY TotalStock DESC, p.Nombre ASC
                        LIMIT 6";
                    DataTable dtBarras = new DataTable();
                    using (MySqlDataAdapter da = new MySqlDataAdapter(sqlBarras, conexion))
                    {
                        da.Fill(dtBarras);
                    }
                    int maxStock = dtBarras.Rows.Count == 0 ? 0 : dtBarras.AsEnumerable().Max(r => Convert.ToInt32(r["TotalStock"]));
                    var itemsGrafico = new List<object>();
                    for (int idx = 0; idx < 6; idx++)
                    {
                        if (idx < dtBarras.Rows.Count)
                        {
                            DataRow fila = dtBarras.Rows[idx];
                            int val = Convert.ToInt32(fila["TotalStock"]);
                            string nom = Convert.ToString(fila["Producto"]);
                            if (nom.Length > 11) nom = nom.Substring(0, 10) + ".";
                            itemsGrafico.Add(new
                            {
                                Etiqueta = nom,
                                Unidades = val.ToString("N0", cultura) + " u.",
                                Altura = maxStock > 0 ? Math.Round((double)val / maxStock * 100).ToString(CultureInfo.InvariantCulture) : "0"
                            });
                        }
                        else
                        {
                            itemsGrafico.Add(new { Etiqueta = "—", Unidades = "0 u.", Altura = "0" });
                        }
                    }
                    rptBarrasInventario.DataSource = itemsGrafico;
                    rptBarrasInventario.DataBind();
                    lblSinStockGrafico.Visible = maxStock <= 0;

                    // Tabla de 5 lotes vigentes ordenados por FEFO
                    string sqlLotes = @"
                        SELECT l.NumeroLote,
                               p.Nombre AS Producto,
                               IFNULL(DATE_FORMAT(l.FechaVencimiento, '%d-%m-%Y'), 'Sin fecha') AS Vencimiento,
                               COALESCE(l.CantidadDisponible, 0) AS Disponible
                        FROM lote l
                        INNER JOIN varianteproducto v ON v.IdVariante = l.IdVariante
                        INNER JOIN producto p ON p.IdProducto = v.IdProducto
                        WHERE COALESCE(l.CantidadDisponible, 0) > 0
                        ORDER BY l.FechaVencimiento ASC, l.IdLote DESC
                        LIMIT 5";
                    DataTable dtLotes = new DataTable();
                    using (MySqlDataAdapter daLotes = new MySqlDataAdapter(sqlLotes, conexion))
                    {
                        daLotes.Fill(dtLotes);
                    }
                    gvLotesRecientes.DataSource = dtLotes;
                    gvLotesRecientes.DataBind();
                    if (gvLotesRecientes.HeaderRow != null)
                        gvLotesRecientes.HeaderRow.TableSection = System.Web.UI.WebControls.TableRowSection.TableHeader;
                }
            }
            catch
            {
                litInvProductos.Text = "0";
                litInvStockTotal.Text = "0";
                litInvStockBajo.Text = "0";
                litInvLotes.Text = "0";
            }
        }

        // CARGAR BODEGAS DESDE MYSQL
        private void CargarBodegas()
        {
            try
            {
                using (MySqlConnection conexion =
                    new MySqlConnection(CadenaConexion))
                {
                    string consulta = @"
                        SELECT IdBodega, Nombre
                        FROM bodega
                        WHERE Activo = 1
                        ORDER BY Nombre";

                    using (MySqlCommand comando =
                        new MySqlCommand(consulta, conexion))
                    {
                        conexion.Open();

                        ddlBodega.DataSource =
                            comando.ExecuteReader();

                        ddlBodega.DataTextField = "Nombre";
                        ddlBodega.DataValueField = "IdBodega";
                        ddlBodega.DataBind();

                        ddlBodega.Items.Insert(0,
                            new System.Web.UI.WebControls.ListItem(
                                "Todas las bodegas", ""));
                    }
                }
            }
            catch (Exception)
            {
                ddlBodega.Items.Clear();

                ddlBodega.Items.Add(
                    new System.Web.UI.WebControls.ListItem(
                        "Todas las bodegas", ""));

                lblMensaje.Text =
                    "No fue posible cargar las bodegas.";
            }
        }

        // CONSULTAR INVENTARIO CON FILTROS
        private void CargarInventario()
        {
            string consulta = @"
                SELECT
                    p.Nombre AS Producto,
                    v.Sku AS SKU,
                    COALESCE(v.Presentacion, 'Sin especificar')
                        AS Presentacion,
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
                  AND (
                      @Buscar = ''
                      OR p.Nombre LIKE @Patron
                      OR v.Sku LIKE @Patron
                  )
                  AND (
                      @Bodega = 0
                      OR b.IdBodega = @Bodega
                  )
                  AND (
                      @Estado = ''
                      OR (
                          @Estado = 'Sin stock'
                          AND COALESCE(i.StockActual, 0) <= 0
                      )
                      OR (
                          @Estado = 'Stock bajo'
                          AND i.StockActual > 0
                          AND p.StockMinimo IS NOT NULL
                          AND i.StockActual <= p.StockMinimo
                      )
                      OR (
                          @Estado = 'Disponible'
                          AND (
                              p.StockMinimo IS NULL
                              OR i.StockActual > p.StockMinimo
                          )
                          AND i.StockActual > 0
                      )
                  )
                ORDER BY p.Nombre, v.Sku, b.Nombre";

            try
            {
                string buscar = txtBuscar.Text.Trim();

                int idBodega = 0;

                if (!string.IsNullOrEmpty(
                    ddlBodega.SelectedValue))
                {
                    if (!int.TryParse(
                        ddlBodega.SelectedValue,
                        out idBodega))
                    {
                        lblMensaje.Text =
                            "La bodega seleccionada no es válida.";
                        return;
                    }
                }

                string estado = ddlEstado.SelectedValue;

                using (MySqlConnection conexion =
                    new MySqlConnection(CadenaConexion))
                {
                    using (MySqlCommand comando =
                        new MySqlCommand(consulta, conexion))
                    {
                        comando.Parameters.AddWithValue(
                            "@Buscar", buscar);

                        comando.Parameters.AddWithValue(
                            "@Patron", "%" + buscar + "%");

                        comando.Parameters.AddWithValue(
                            "@Bodega", idBodega);

                        comando.Parameters.AddWithValue(
                            "@Estado", estado);

                        using (MySqlDataAdapter adaptador =
                            new MySqlDataAdapter(comando))
                        {
                            DataTable tabla = new DataTable();

                            adaptador.Fill(tabla);

                            gvInventario.DataSource = tabla;
                            gvInventario.DataBind();

                            if (tabla.Rows.Count == 0)
                            {
                                lblMensaje.Text =
                                    "No se encontraron productos " +
                                    "con los filtros seleccionados.";
                            }
                            else
                            {
                                lblMensaje.Text =
                                    "Registros encontrados: " +
                                    tabla.Rows.Count;
                            }
                        }
                    }
                }
            }
            catch (Exception)
            {
                gvInventario.DataSource = null;
                gvInventario.DataBind();

                lblMensaje.Text =
                    "No fue posible consultar el inventario. " +
                    "Verifica la conexión con MySQL.";
            }
        }

        // BOTÓN BUSCAR
        protected void btnBuscar_Click(
            object sender, EventArgs e)
        {
            CargarInventario();
        }

        // BOTÓN LIMPIAR FILTROS
        protected void btnLimpiar_Click(
            object sender, EventArgs e)
        {
            txtBuscar.Text = "";

            ddlBodega.SelectedIndex = 0;
            ddlEstado.SelectedIndex = 0;

            CargarInventario();
        }
    }
}
