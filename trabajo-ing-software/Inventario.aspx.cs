
using System;
using System.Configuration;
using System.Data;
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
            if (!IsPostBack)
            {
                CargarBodegas();
                CargarInventario();
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
