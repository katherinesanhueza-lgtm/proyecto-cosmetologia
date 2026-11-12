using System;
using System.Collections.Generic;
using System.Data;
using System.Globalization;
using System.Text;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using MySql.Data.MySqlClient;

namespace trabajo_ing_software
{
    public class Gestion : PaginaInventario
    {
        protected PlaceHolder Interfaz;
        readonly Dictionary<string,Control> campos=new Dictionary<string,Control>();
        Label mensaje; GridView tabla; string modulo; string consulta; object[] filtros;
        int Editar { get { int id; return int.TryParse(Request.QueryString["id"],out id)?id:0; } }
        protected override void OnInit(EventArgs e)
        {
            base.OnInit(e); if(Session["InventarioToken"]==null)Session["InventarioToken"]=Guid.NewGuid().ToString("N"); ViewStateUserKey=(string)Session["InventarioToken"];
            modulo=Request.QueryString["m"] ?? "productos";
            Interfaz.Controls.Add(new LiteralControl("<div class='dashboard'><div class='dashboard-header'><div><p class='dashboard-etiqueta'>CONTROL DE INVENTARIO</p><h1>"+HttpUtility.HtmlEncode(Titulo())+"</h1></div></div>"));
            mensaje=new Label{ID="mensaje",EnableViewState=false}; Interfaz.Controls.Add(mensaje);
            Interfaz.Controls.Add(new LiteralControl("<section class='card-dermocosmetica gestion-formulario'>"));
            try { Crear(); }
            catch(Exception ex){MostrarError(ex);}
            Interfaz.Controls.Add(new LiteralControl("</section><section class='card-dermocosmetica mt-4'><div class='table-responsive'>"));
            tabla=new GridView{ID="tabla",AutoGenerateColumns=true,CssClass="table table-hover",GridLines=GridLines.None,EmptyDataText="No hay registros para los filtros seleccionados."};
            if(modulo=="productos" || modulo=="variantes" || modulo=="lotes")
                tabla.Columns.Add(new HyperLinkField{Text="Editar",DataNavigateUrlFields=new[]{"Id"},DataNavigateUrlFormatString="Gestion.aspx?m="+modulo+"&id={0}"});
            Interfaz.Controls.Add(tabla); Interfaz.Controls.Add(new LiteralControl("</div></section></div>"));
        }
        string Titulo(){switch(modulo){case "productos":return "Productos y stock mínimo";case "variantes":return "Variantes y presentaciones";case "lotes":return "Lotes y vencimientos";case "movimientos":return "Entradas, salidas y ajustes";case "historial":return "Historial de movimientos";case "alertas":return "Alertas de inventario";default:return "Reportes de inventario";}}
        void Texto(string id,string titulo,int longitud=100,string tipo="")
        {
            var t=new TextBox{ID=id,MaxLength=longitud,CssClass="input-dermo"}; if(tipo!="")t.Attributes["type"]=tipo;
            Interfaz.Controls.Add(new Label{Text=titulo,AssociatedControlID=id}); Interfaz.Controls.Add(t); campos[id]=t;
        }
        void Lista(string id,string titulo,string sql,bool todos=false)
        {
            var d=new DropDownList{ID=id,CssClass="input-dermo"};
            Interfaz.Controls.Add(new Label{Text=titulo,AssociatedControlID=id});Interfaz.Controls.Add(d);campos[id]=d;
            d.DataSource=InventarioDatos.Tabla(sql);d.DataValueField="Id";d.DataTextField="Nombre";d.DataBind();
            if(todos)d.Items.Insert(0,new ListItem("Todos / sin especificar","0"));
        }
        void Opciones(string id,string titulo,params string[] opciones)
        {
            var d=new DropDownList{ID=id,CssClass="input-dermo"};foreach(var o in opciones)d.Items.Add(o);
            Interfaz.Controls.Add(new Label{Text=titulo,AssociatedControlID=id});Interfaz.Controls.Add(d);campos[id]=d;
        }
        void Boton(string texto,EventHandler accion){var b=new Button{Text=texto,CssClass="btn btn-primary m-2",CausesValidation=false};b.Click+=accion;Interfaz.Controls.Add(b);}
        string V(string id){var c=campos[id];return c is TextBox?((TextBox)c).Text.Trim():((DropDownList)c).SelectedValue;}
        int N(string id,int min=0){int n;if(!int.TryParse(V(id),out n)||n<min)throw new ArgumentException("Revisa el valor de "+id+" (mínimo "+min+").");return n;}
        object FK(string id){int n=N(id);return n==0?(object)null:n;}
        string Requerido(string id){string v=V(id);if(v=="")throw new ArgumentException("Completa el campo "+id+".");return v;}
        DateTime Fecha(string id){DateTime d;if(!DateTime.TryParseExact(V(id),"yyyy-MM-dd",CultureInfo.InvariantCulture,DateTimeStyles.None,out d))throw new ArgumentException("Revisa la fecha de "+id+".");return d;}
        void Crear()
        {
            if(modulo=="productos")
            {
                Texto("Nombre","Nombre del producto",150);Texto("Descripcion","Descripción",255);
                Lista("Categoria","Categoría","SELECT IdCategoria Id,Nombre FROM categoria WHERE Activo=1",true);
                Lista("Marca","Marca","SELECT IdMarca Id,Nombre FROM marca WHERE Activo=1",true);
                Texto("Minimo","Stock mínimo",10,"number");Opciones("Activo","Estado","Activo","Inactivo");
            }
            else if(modulo=="variantes")
            {
                Lista("Producto","Producto","SELECT IdProducto Id,CONCAT(Nombre,IF(Activo=1,'',' (inactivo)')) Nombre FROM producto");
                Texto("SKU","Código SKU único",50);Texto("Nombre","Nombre de variante",100);Texto("Atributos","Volumen / tamaño",200);Texto("Presentacion","Presentación",100);Texto("Color","Color",50);Opciones("Activo","Estado","Activo","Inactivo");
            }
            else if(modulo=="lotes")
            {
                Lista("Variante","Variante","SELECT v.IdVariante Id,CONCAT(p.Nombre,' · ',v.Sku) Nombre FROM varianteproducto v JOIN producto p ON p.IdProducto=v.IdProducto WHERE v.Activo=1 AND p.Activo=1");
                Lista("Bodega","Bodega","SELECT IdBodega Id,Nombre FROM bodega WHERE Activo=1");
                Texto("Numero","Número de lote",50);Texto("Ingreso","Fecha de ingreso",10,"date");Texto("Vencimiento","Fecha de vencimiento",10,"date");
                Opciones("Estado","Estado","Disponible","Cuarentena","Vencido","Agotado");
                Interfaz.Controls.Add(new LiteralControl("<p>Las cantidades se registran desde Movimientos para conservar la trazabilidad. Los lotes nuevos comienzan con cero unidades.</p>"));
            }
            else if(modulo=="movimientos")
            {
                Opciones("Tipo","Operación","Entrada","Salida","Ajuste positivo","Ajuste negativo");
                Lista("Lote","Lote / variante / bodega","SELECT l.IdLote Id,CONCAT(l.NumeroLote,' · ',v.Sku,' · ',COALESCE(b.Nombre,'Sin bodega'),' · saldo ',COALESCE(l.CantidadDisponible,0)) Nombre FROM lote l JOIN varianteproducto v ON v.IdVariante=l.IdVariante LEFT JOIN bodega b ON b.IdBodega=l.IdBodega ORDER BY l.IdLote DESC");
                Lista("Bodega","Bodega","SELECT IdBodega Id,Nombre FROM bodega WHERE Activo=1");
                Texto("Cantidad","Cantidad de unidades",10,"number");Texto("Motivo","Motivo / justificación",255);
                Lista("Compra","Detalle de recepción de compra","SELECT d.IdDetalleRec Id,CONCAT('Recepción #',d.IdRecepcion,' · detalle #',d.IdDetalleRec,' · ',v.Sku,' · ',d.Cantidad,' unidades') Nombre FROM detallerecepcion d JOIN varianteproducto v ON v.IdVariante=d.IdVariante WHERE NOT EXISTS(SELECT 1 FROM movimientoinventario m WHERE m.Origen='Entrada' AND m.IdDetalleOrigen=d.IdDetalleRec)",true);
                Lista("Venta","Detalle de venta","SELECT d.IdVentaDetalle Id,CONCAT('Venta #',d.IdVenta,' · detalle #',d.IdVentaDetalle,' · ',v.Sku,' · ',d.Cantidad,' unidades') Nombre FROM ventadetalle d JOIN varianteproducto v ON v.IdVariante=d.IdVariante WHERE NOT EXISTS(SELECT 1 FROM movimientoinventario m WHERE m.Origen='Salida' AND m.IdDetalleOrigen=d.IdVentaDetalle)",true);
                Interfaz.Controls.Add(new LiteralControl("<p>Entradas: selecciona una recepción de Compras. Salidas: selecciona un detalle de Ventas. Registra su cantidad completa. Para pérdidas, daños, vencimiento o diferencias usa un ajuste y explica el motivo.</p>"));
            }
            else
            {
                Texto("Buscar","Producto, SKU o número de lote",150);
                Lista("Bodega","Bodega","SELECT IdBodega Id,Nombre FROM bodega WHERE Activo=1",true);
                if(modulo=="historial") {Texto("Desde","Desde",10,"date");Texto("Hasta","Hasta",10,"date");Opciones("Tipo","Tipo","Todos","Entrada","Salida","Ajuste positivo","Ajuste negativo");}
                else Opciones("Estado","Estado","Todos","Disponible","Stock bajo","Sin stock","Próximo a vencer","Vencido");
                Boton("Consultar",(s,e)=>{});Boton("Exportar CSV",Exportar);return;
            }
            Boton(Editar>0?"Guardar cambios":"Registrar",Guardar);
            Interfaz.Controls.Add(new HyperLink{Text="Nuevo registro",NavigateUrl="Gestion.aspx?m="+modulo,CssClass="btn btn-outline-secondary m-2"});
            if(!IsPostBack && Editar>0) CargarEdicion();
        }
        void Asignar(string id,object valor){var c=campos[id];string v=Convert.ToString(valor);if(c is TextBox)((TextBox)c).Text=v;else{var d=(DropDownList)c;if(d.Items.FindByValue(v)!=null)d.SelectedValue=v;}}
        void CargarEdicion()
        {
            string sql=modulo=="productos"?"SELECT Nombre,Descripcion,COALESCE(IdCategoria,0) Categoria,COALESCE(IdMarca,0) Marca,StockMinimo Minimo,IF(Activo=1,'Activo','Inactivo') Activo FROM producto WHERE IdProducto=@p0":modulo=="variantes"?"SELECT IdProducto Producto,Sku SKU,NombreVariante Nombre,AtributoValor Atributos,Presentacion,Color,IF(Activo=1,'Activo','Inactivo') Activo FROM varianteproducto WHERE IdVariante=@p0":"SELECT IdVariante Variante,IdBodega Bodega,NumeroLote Numero,DATE_FORMAT(FechaIngreso,'%Y-%m-%d') Ingreso,DATE_FORMAT(FechaVencimiento,'%Y-%m-%d') Vencimiento,Estado FROM lote WHERE IdLote=@p0";
            var dt=InventarioDatos.Tabla(sql,Editar);if(dt.Rows.Count==0)throw new ArgumentException("Registro no encontrado.");foreach(DataColumn c in dt.Columns)Asignar(c.ColumnName,dt.Rows[0][c]);
        }
        void Guardar(object sender,EventArgs e)
        {
            try
            {
                if(modulo=="productos")
                    InventarioDatos.Ejecutar(Editar==0?"INSERT INTO producto(Nombre,Descripcion,IdCategoria,IdMarca,StockMinimo,Activo) VALUES(@p0,@p1,@p2,@p3,@p4,@p5)":"UPDATE producto SET Nombre=@p0,Descripcion=@p1,IdCategoria=@p2,IdMarca=@p3,StockMinimo=@p4,Activo=@p5 WHERE IdProducto=@p6",Requerido("Nombre"),V("Descripcion"),FK("Categoria"),FK("Marca"),N("Minimo"),V("Activo")=="Activo",Editar);
                else if(modulo=="variantes")
                {
                    if(Editar>0)
                    {
                        var original=InventarioDatos.Tabla("SELECT IdProducto FROM varianteproducto WHERE IdVariante=@p0",Editar);
                        if(original.Rows.Count!=1 || Convert.ToInt32(original.Rows[0][0])!=N("Producto",1))throw new ArgumentException("La variante debe conservar su producto original. Crea otra variante para un producto diferente.");
                    }
                    InventarioDatos.Ejecutar(Editar==0?"INSERT INTO varianteproducto(IdProducto,Sku,NombreVariante,AtributoValor,Presentacion,Color,Activo) VALUES(@p0,@p1,@p2,@p3,@p4,@p5,@p6)":"UPDATE varianteproducto SET Sku=@p1,NombreVariante=@p2,AtributoValor=@p3,Presentacion=@p4,Color=@p5,Activo=@p6 WHERE IdVariante=@p7 AND IdProducto=@p0",N("Producto",1),Requerido("SKU"),V("Nombre"),V("Atributos"),V("Presentacion"),V("Color"),V("Activo")=="Activo",Editar);
                }
                else if(modulo=="lotes")
                {
                    var ingreso=Fecha("Ingreso");var vence=Fecha("Vencimiento");if(vence<ingreso)throw new ArgumentException("El vencimiento debe ser posterior al ingreso.");
                    if(Editar==0)InventarioDatos.Ejecutar("INSERT INTO lote(IdVariante,IdBodega,NumeroLote,FechaIngreso,FechaVencimiento,CantidadInicial,CantidadDisponible,Estado) VALUES(@p0,@p1,@p2,@p3,@p4,0,0,@p5)",N("Variante",1),N("Bodega",1),Requerido("Numero"),ingreso,vence,V("Estado"));
                    else
                    {
                        var dt=InventarioDatos.Tabla("SELECT IdVariante,IdBodega,CantidadDisponible FROM lote WHERE IdLote=@p0",Editar);
                        if(dt.Rows.Count!=1 || Convert.ToInt32(dt.Rows[0][0])!=N("Variante") || Convert.ToInt32(dt.Rows[0][1])!=N("Bodega"))throw new ArgumentException("La variante y bodega de un lote existente no se pueden cambiar.");
                        if(V("Estado")=="Agotado" && Convert.ToInt32(dt.Rows[0][2])>0)throw new ArgumentException("Un lote con existencias no puede marcarse agotado; registra el ajuste correspondiente.");
                        InventarioDatos.Ejecutar("UPDATE lote SET NumeroLote=@p0,FechaIngreso=@p1,FechaVencimiento=@p2,Estado=@p3 WHERE IdLote=@p4",Requerido("Numero"),ingreso,vence,V("Estado"),Editar);
                    }
                }
                else if(modulo=="movimientos")
                {string tipo=V("Tipo");InventarioDatos.Mover(N("Lote",1),N("Bodega",1),UsuarioInventario,tipo,N("Cantidad",1),Requerido("Motivo"),tipo=="Entrada"?N("Compra",1):tipo=="Salida"?N("Venta",1):0);}
                mensaje.Text="Registro guardado correctamente.";mensaje.CssClass="alert alert-success d-block";
            }
            catch(Exception ex){MostrarError(ex);}
        }
        void MostrarError(Exception ex){System.Diagnostics.Trace.TraceError(ex.ToString());mensaje.Text=HttpUtility.HtmlEncode(ex is ArgumentException?ex.Message:ex is MySqlException && ((MySqlException)ex).Number==1062?"El SKU o la referencia ya existe.":"No se pudo completar la operación. Revisa los datos y la conexión a MySQL.");mensaje.CssClass="alert alert-danger d-block";}
        protected override void OnPreRender(EventArgs e)
        {try{PrepararConsulta();tabla.DataSource=InventarioDatos.Tabla(consulta,filtros??new object[0]);tabla.DataBind();}catch(Exception ex){MostrarError(ex);}base.OnPreRender(e);}
        void PrepararConsulta()
        {
            filtros=new object[0];
            if(modulo=="productos")consulta="SELECT p.IdProducto Id,p.Nombre,p.Descripcion,c.Nombre Categoria,m.Nombre Marca,p.StockMinimo,IF(p.Activo=1,'Activo','Inactivo') Estado FROM producto p LEFT JOIN categoria c ON c.IdCategoria=p.IdCategoria LEFT JOIN marca m ON m.IdMarca=p.IdMarca ORDER BY p.Nombre";
            else if(modulo=="variantes")consulta="SELECT v.IdVariante Id,p.Nombre Producto,v.Sku,v.NombreVariante,v.AtributoValor VolumenTamaño,v.Presentacion,v.Color,IF(v.Activo=1,'Activo','Inactivo') Estado FROM varianteproducto v JOIN producto p ON p.IdProducto=v.IdProducto ORDER BY p.Nombre,v.Sku";
            else if(modulo=="lotes")consulta="SELECT l.IdLote Id,v.Sku,l.NumeroLote,b.Nombre Bodega,l.FechaIngreso,l.FechaVencimiento,l.CantidadInicial,l.CantidadDisponible,l.Estado FROM lote l JOIN varianteproducto v ON v.IdVariante=l.IdVariante LEFT JOIN bodega b ON b.IdBodega=l.IdBodega ORDER BY l.FechaVencimiento";
            else if(modulo=="historial" || modulo=="movimientos")
            {
                consulta="SELECT m.IdMovimiento,m.FechaMovimiento,p.Nombre Producto,v.Sku,l.NumeroLote,b.Nombre Bodega,t.Nombre Tipo,m.Cantidad,m.StockAnterior,m.StockPosterior,m.Referencia,m.Observacion Motivo,m.IdUsuario Responsable FROM movimientoinventario m JOIN lote l ON l.IdLote=m.IdLote JOIN varianteproducto v ON v.IdVariante=l.IdVariante JOIN producto p ON p.IdProducto=v.IdProducto JOIN tipomovimiento t ON t.IdTipoMovimiento=m.IdTipoMovimiento LEFT JOIN bodega b ON b.IdBodega=m.IdBodega";
                if(modulo=="historial")
                {
                    DateTime? desde=V("Desde")==""?(DateTime?)null:Fecha("Desde");DateTime? hasta=V("Hasta")==""?(DateTime?)null:Fecha("Hasta");if(desde>hasta)throw new ArgumentException("El rango de fechas no es válido.");
                    consulta+=" WHERE (p.Nombre LIKE @p0 OR v.Sku LIKE @p0 OR l.NumeroLote LIKE @p0) AND (@p1=0 OR m.IdBodega=@p1) AND (@p2 IS NULL OR m.FechaMovimiento>=@p2) AND (@p3 IS NULL OR m.FechaMovimiento<DATE_ADD(@p3,INTERVAL 1 DAY)) AND (@p4='Todos' OR t.Nombre=@p4)";
                    filtros=new object[]{"%"+V("Buscar")+"%",N("Bodega"),desde,hasta,V("Tipo")};
                }
                consulta+=" ORDER BY m.IdMovimiento DESC";
            }
            else
            {
                // Incluye variantes activas sin fila de inventario y todas las bodegas activas.
                consulta=@"SELECT * FROM (SELECT p.Nombre Producto,v.Sku,b.Nombre Bodega,COALESCE(i.StockActual,0) StockActual,COALESCE(i.StockReservado,0) Reservado,COALESCE(i.StockActual,0)-COALESCE(i.StockReservado,0) Disponible,COALESCE(p.StockMinimo,0) StockMinimo,NULL NumeroLote,NULL FechaVencimiento,CASE WHEN COALESCE(i.StockActual,0)<=0 THEN 'Sin stock' WHEN i.StockActual<=COALESCE(p.StockMinimo,0) THEN 'Stock bajo' ELSE 'Disponible' END Estado,b.IdBodega FROM varianteproducto v JOIN producto p ON p.IdProducto=v.IdProducto CROSS JOIN bodega b LEFT JOIN inventario i ON i.IdVariante=v.IdVariante AND i.IdBodega=b.IdBodega WHERE p.Activo=1 AND v.Activo=1 AND b.Activo=1 UNION ALL SELECT p.Nombre,v.Sku,b.Nombre,l.CantidadDisponible,0,l.CantidadDisponible,p.StockMinimo,l.NumeroLote,l.FechaVencimiento,CASE WHEN l.FechaVencimiento<CURDATE() OR l.Estado='Vencido' THEN 'Vencido' ELSE 'Próximo a vencer' END,b.IdBodega FROM lote l JOIN varianteproducto v ON v.IdVariante=l.IdVariante JOIN producto p ON p.IdProducto=v.IdProducto JOIN bodega b ON b.IdBodega=l.IdBodega WHERE l.CantidadDisponible>0 AND (l.FechaVencimiento<=DATE_ADD(CURDATE(),INTERVAL 30 DAY) OR l.Estado='Vencido') AND p.Activo=1 AND v.Activo=1 AND b.Activo=1) r WHERE (Producto LIKE @p0 OR Sku LIKE @p0 OR NumeroLote LIKE @p0) AND (@p1=0 OR IdBodega=@p1) AND (@p2='Todos' OR Estado=@p2)";
                if(modulo=="alertas")consulta+=" AND Estado<>'Disponible'";
                consulta+=" ORDER BY Producto,Sku,Bodega";filtros=new object[]{"%"+V("Buscar")+"%",N("Bodega"),V("Estado")};
            }
        }
        void Exportar(object s,EventArgs e)
        {
            try
            {
                PrepararConsulta();var dt=InventarioDatos.Tabla(consulta,filtros);var csv=new StringBuilder();
                for(int row=-1;row<dt.Rows.Count;row++){var vals=new List<string>();for(int col=0;col<dt.Columns.Count;col++){string v=row<0?dt.Columns[col].ColumnName:Convert.ToString(dt.Rows[row][col]);if(v.TrimStart().StartsWith("=")||v.TrimStart().StartsWith("+")||v.TrimStart().StartsWith("-")||v.TrimStart().StartsWith("@"))v="'"+v;vals.Add("\""+v.Replace("\"","\"\"")+"\"");}csv.AppendLine(string.Join(";",vals));}
                byte[] data=Encoding.UTF8.GetBytes(csv.ToString());byte[] bom=Encoding.UTF8.GetPreamble();Response.Clear();Response.ContentType="text/csv; charset=utf-8";Response.AddHeader("Content-Disposition","attachment; filename="+modulo+".csv");Response.BinaryWrite(bom);Response.BinaryWrite(data);Response.Flush();Response.SuppressContent=true;Context.ApplicationInstance.CompleteRequest();
            }catch(Exception ex){MostrarError(ex);}
        }
    }
}
