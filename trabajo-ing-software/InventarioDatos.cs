using System;
using System.Configuration;
using System.Data;
using MySql.Data.MySqlClient;

namespace trabajo_ing_software
{
    public static class InventarioDatos
    {
        public static MySqlConnection Abrir()
        {
            var c = new MySqlConnection(ConfigurationManager.ConnectionStrings["DefaultConnection"].ConnectionString);
            c.Open(); return c;
        }
        public static MySqlCommand Comando(MySqlConnection c, MySqlTransaction t, string sql, params object[] args)
        {
            var cmd = new MySqlCommand(sql, c, t);
            for (int i = 0; i < args.Length; i++) cmd.Parameters.AddWithValue("@p" + i, args[i] ?? DBNull.Value);
            return cmd;
        }
        public static DataTable Tabla(string sql, params object[] args)
        {
            using (var c = Abrir()) using (var cmd = Comando(c, null, sql, args)) using (var a = new MySqlDataAdapter(cmd))
            { var dt = new DataTable(); a.Fill(dt); return dt; }
        }
        public static void Ejecutar(string sql, params object[] args)
        { using (var c = Abrir()) using (var cmd = Comando(c, null, sql, args)) cmd.ExecuteNonQuery(); }
        public static void Mover(int lote, int bodega, int usuario, string tipo, int cantidad, string motivo, int documento)
        {
            if (cantidad <= 0 || string.IsNullOrWhiteSpace(motivo) || motivo.Length > 255) throw new ArgumentException("Indica una cantidad positiva y una justificación de hasta 255 caracteres.");
            if (tipo != "Entrada" && tipo != "Salida" && tipo != "Ajuste positivo" && tipo != "Ajuste negativo") throw new ArgumentException("Tipo de movimiento inválido.");
            using (var c = Abrir()) using (var t = c.BeginTransaction())
            {
                try
                {
                    int variante; int disponible; string estado; DateTime? vencimiento;
                    using (var cmd = Comando(c,t,"SELECT IdVariante,COALESCE(CantidadDisponible,0),Estado,FechaVencimiento FROM lote WHERE IdLote=@p0 AND IdBodega=@p1 FOR UPDATE",lote,bodega))
                    using (var r = cmd.ExecuteReader())
                    {
                        if (!r.Read()) throw new ArgumentException("El lote no pertenece a la bodega seleccionada.");
                        variante=r.GetInt32(0); disponible=r.GetInt32(1); estado=r.GetString(2); vencimiento=r.IsDBNull(3)?(DateTime?)null:r.GetDateTime(3);
                    }
                    // La variante serializa todas las operaciones sobre sus existencias.
                    using(var cmd=Comando(c,t,"SELECT v.IdVariante FROM varianteproducto v JOIN producto p ON p.IdProducto=v.IdProducto WHERE v.IdVariante=@p0 AND v.Activo=1 AND p.Activo=1 FOR UPDATE",variante))
                        if(cmd.ExecuteScalar()==null) throw new ArgumentException("Producto o variante inactivos.");
                    using(var cmd=Comando(c,t,"SELECT IdBodega FROM bodega WHERE IdBodega=@p0 AND Activo=1 FOR UPDATE",bodega))
                        if(cmd.ExecuteScalar()==null) throw new ArgumentException("Bodega inactiva.");
                    bool suma=tipo=="Entrada" || tipo=="Ajuste positivo";
                    if(tipo=="Entrada" || tipo=="Salida")
                    {
                        if(tipo=="Entrada")
                        {
                            using(var cmd=Comando(c,t,"SELECT COUNT(*) FROM detallerecepcion d JOIN recepcioncompra r ON r.IdRecepcion=d.IdRecepcion JOIN ordencompra o ON o.IdOC=r.IdOC JOIN lote l ON l.IdLote=@p1 WHERE d.IdDetalleRec=@p0 AND COALESCE(o.Estado,'')<>'Anulada' AND (d.NumeroLote IS NULL OR d.NumeroLote='' OR d.NumeroLote=l.NumeroLote) AND (d.FechaVencimiento IS NULL OR d.FechaVencimiento=l.FechaVencimiento)",documento,lote))
                                if(Convert.ToInt32(cmd.ExecuteScalar())!=1)throw new ArgumentException("La recepción debe corresponder al número y vencimiento del lote y a una compra vigente.");
                        }
                        string sql=tipo=="Entrada" ? "SELECT IdVariante,Cantidad FROM detallerecepcion WHERE IdDetalleRec=@p0 FOR UPDATE" : "SELECT IdVariante,Cantidad FROM ventadetalle WHERE IdVentaDetalle=@p0 FOR UPDATE";
                        using(var cmd=Comando(c,t,sql,documento)) using(var r=cmd.ExecuteReader())
                        { if(!r.Read() || r.GetInt32(0)!=variante || r.GetInt32(1)!=cantidad) throw new ArgumentException("Selecciona un detalle de compra/venta de la misma variante y registra su cantidad completa."); }
                        using(var cmd=Comando(c,t,"SELECT COUNT(*) FROM movimientoinventario WHERE Origen=@p0 AND IdDetalleOrigen=@p1",tipo,documento))
                            if(Convert.ToInt32(cmd.ExecuteScalar())>0) throw new ArgumentException("Este detalle ya fue registrado en inventario.");
                    }
                    if(tipo=="Salida" && (estado!="Disponible" || (vencimiento.HasValue && vencimiento.Value.Date<DateTime.Today))) throw new ArgumentException("No se puede vender un lote vencido, agotado o en cuarentena.");
                    if(suma && (estado=="Cuarentena" || estado=="Vencido" || (vencimiento.HasValue && vencimiento.Value.Date<DateTime.Today))) throw new ArgumentException("No se puede ingresar stock disponible a un lote vencido o en cuarentena.");
                    int anterior=0,reservado=0; int inventario=0;
                    using(var cmd=Comando(c,t,"SELECT IdInventario,COALESCE(StockActual,0),COALESCE(StockReservado,0) FROM inventario WHERE IdVariante=@p0 AND IdBodega=@p1 FOR UPDATE",variante,bodega)) using(var r=cmd.ExecuteReader())
                    { if(r.Read()){inventario=r.GetInt32(0); anterior=r.GetInt32(1); reservado=r.GetInt32(2); if(r.Read())throw new ArgumentException("Existen registros duplicados de inventario; corrígelos antes de operar.");} }
                    if(!suma && (cantidad>disponible || cantidad>anterior-reservado)) throw new ArgumentException("Stock insuficiente: revisa las unidades del lote y las reservas de la bodega.");
                    int posterior=checked(anterior+(suma?cantidad:-cantidad)); int saldo=checked(disponible+(suma?cantidad:-cantidad));
                    using(var cmd=Comando(c,t,inventario==0?"INSERT INTO inventario(IdVariante,IdBodega,StockActual,StockReservado,FechaActualizada) VALUES(@p0,@p1,@p2,0,NOW())":"UPDATE inventario SET StockActual=@p2,FechaActualizada=NOW() WHERE IdVariante=@p0 AND IdBodega=@p1",variante,bodega,posterior))cmd.ExecuteNonQuery();
                    using(var cmd=Comando(c,t,"UPDATE lote SET CantidadDisponible=@p0,CantidadInicial=COALESCE(CantidadInicial,0)+@p1,Estado=CASE WHEN @p0=0 THEN 'Agotado' WHEN Estado='Agotado' THEN 'Disponible' ELSE Estado END WHERE IdLote=@p2",saldo,suma?cantidad:0,lote))cmd.ExecuteNonQuery();
                    using(var cmd=Comando(c,t,"UPDATE varianteproducto SET StockTotal=(SELECT COALESCE(SUM(StockActual),0) FROM inventario WHERE IdVariante=@p0) WHERE IdVariante=@p0",variante))cmd.ExecuteNonQuery();
                    int idTipo;
                    using(var cmd=Comando(c,t,"SELECT IdTipoMovimiento FROM tipomovimiento WHERE Nombre=@p0 LIMIT 1",tipo))
                    { var id=cmd.ExecuteScalar(); if(id==null)throw new ArgumentException("Falta configurar el tipo de movimiento."); idTipo=Convert.ToInt32(id); }
                    using(var cmd=Comando(c,t,"INSERT INTO movimientoinventario(IdLote,IdBodega,IdTipoMovimiento,IdUsuario,Cantidad,StockAnterior,StockPosterior,Referencia,Observacion,Origen,IdDetalleOrigen) VALUES(@p0,@p1,@p2,@p3,@p4,@p5,@p6,@p7,@p8,@p9,@p10)",lote,bodega,idTipo,usuario,cantidad,anterior,posterior,documento>0?tipo+" #"+documento:"Ajuste manual",motivo,documento>0?tipo:null,documento>0?(object)documento:null))cmd.ExecuteNonQuery();
                    t.Commit();
                }
                catch { t.Rollback(); throw; }
            }
        }
    }
}
