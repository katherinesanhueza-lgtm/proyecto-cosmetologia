$ErrorActionPreference = 'Stop'
$base = 'http://localhost:8085'
function Enviar($ruta, $valores, $boton='Registrar') {
    $pagina = Invoke-WebRequest ($base+$ruta) -SessionVariable sesion -UseBasicParsing
    $datos = @{}
    foreach ($input in [regex]::Matches($pagina.Content, '<input\b[^>]*>')) {
        $name = [regex]::Match($input.Value, 'name="([^"]+)"').Groups[1].Value
        $value = [regex]::Match($input.Value, 'value="([^"]*)"').Groups[1].Value
        $type = [regex]::Match($input.Value, 'type="([^"]*)"').Groups[1].Value
        if ($name -and ($type -ne 'submit' -or $value -eq $boton)) { $datos[$name]=[Net.WebUtility]::HtmlDecode($value) }
    }
    foreach ($select in [regex]::Matches($pagina.Content, '<select\b[^>]*name="([^"]+)"[^>]*>(.*?)</select>', 'Singleline')) {
        $opciones=[regex]::Matches($select.Groups[2].Value,'<option[^>]*value="([^"]*)"[^>]*>')
        if($opciones.Count -gt 0){$datos[$select.Groups[1].Value]=$opciones[0].Groups[1].Value}
    }
    foreach($key in $valores.Keys){$datos['ctl00$MainContent$'+$key]=[string]$valores[$key]}
    $r=Invoke-WebRequest ($base+$ruta) -WebSession $sesion -Method Post -Body $datos -UseBasicParsing
    return [Net.WebUtility]::HtmlDecode($r.Content)
}
function Exigir($condicion,$mensaje){if(!$condicion){throw $mensaje};Write-Output ('OK: '+$mensaje)}
$marca='PRUEBA-'+[guid]::NewGuid().ToString('N').Substring(0,10)
$resultado=Enviar '/Gestion?m=productos' @{Nombre=$marca;Descripcion='Prueba temporal';Categoria=0;Marca=0;Minimo=2;Activo='Activo'}
Exigir ($resultado.Contains('Registro guardado correctamente')) 'Registro de producto mediante formulario Web Forms'
$cfg=[xml](Get-Content "$PSScriptRoot/Cosmetologia/Web.config")
if($cfg.configuration.connectionStrings.configSource){
    $cfg=[xml](Get-Content (Join-Path "$PSScriptRoot/Cosmetologia" $cfg.configuration.connectionStrings.configSource))
    $cadena=$cfg.connectionStrings.add.connectionString
} else { $cadena=$cfg.configuration.connectionStrings.add.connectionString }
$pares=@{};$cadena.Split(';')|ForEach-Object{if($_ -match '^([^=]+)=(.*)$'){$pares[$matches[1]]=$matches[2]}}
$env:MYSQL_PWD=$pares['Pwd'];$mysql='C:\Program Files\MySQL\MySQL Server 8.0\bin\mysql.exe'
function Sql($sql){$r=& $mysql -N -B --default-character-set=utf8mb4 -h localhost -u $pares['Uid'] -D $pares['Database'] -e $sql;if($LASTEXITCODE -ne 0){throw 'Error SQL en verificación'};return $r}
try {
    $producto=Sql "SELECT IdProducto FROM producto WHERE Nombre='$marca'"
    $r=Enviar '/Gestion?m=variantes' @{Producto=$producto;SKU=$marca;Nombre='Variante prueba';Atributos='50 ml';Presentacion='Frasco';Color='Natural';Activo='Activo'}
    Exigir ($r.Contains('Registro guardado correctamente')) 'Registro de variante'
    $variante=Sql "SELECT IdVariante FROM varianteproducto WHERE Sku='$marca'"
    $bodega=Sql 'SELECT MIN(IdBodega) FROM bodega WHERE Activo=1'
    $usuario=Sql 'SELECT MIN(IdUsuario) FROM usuario'
    $r=Enviar '/Gestion?m=lotes' @{Variante=$variante;Bodega=$bodega;Numero=$marca;Ingreso=(Get-Date -Format yyyy-MM-dd);Vencimiento=((Get-Date).AddDays(10).ToString('yyyy-MM-dd'));Estado='Disponible'}
    Exigir ($r.Contains('Registro guardado correctamente')) 'Registro de lote por bodega'
    $lote=Sql "SELECT IdLote FROM lote WHERE NumeroLote='$marca'"
    $mov=@{Tipo='Ajuste positivo';Lote=$lote;Bodega=$bodega;Usuario=$usuario;Cantidad=5;Motivo='Prueba temporal de diferencia de inventario';Compra=0;Venta=0}
    $r=Enviar '/Gestion?m=movimientos' $mov
    Exigir ($r.Contains('Registro guardado correctamente')) 'Ajuste incrementa existencias y genera movimiento'
    Exigir ((Sql "SELECT StockActual FROM inventario WHERE IdVariante=$variante AND IdBodega=$bodega") -eq '5') 'Saldo de bodega igual a cinco unidades'
    $mov.Tipo='Ajuste negativo';$mov.Cantidad=6;$r=Enviar '/Gestion?m=movimientos' $mov
    Exigir ($r.Contains('Stock insuficiente')) 'Operación sin stock rechazada'
    Exigir ((Sql "SELECT CantidadDisponible FROM lote WHERE IdLote=$lote") -eq '5') 'Rechazo conserva el saldo del lote'
    $mov.Cantidad=2;$r=Enviar '/Gestion?m=movimientos' $mov
    Exigir ($r.Contains('Registro guardado correctamente')) 'Ajuste negativo válido'
    Exigir ((Sql "SELECT StockTotal FROM varianteproducto WHERE IdVariante=$variante") -eq '3') 'Stock total sincronizado'
    $r=Enviar '/Gestion?m=historial' @{Buscar=$marca;Bodega=0;Desde='';Hasta='';Tipo='Todos'} 'Consultar'
    Exigir ($r.Contains('Ajuste negativo') -and $r.Contains($marca)) 'Historial filtrado contiene los movimientos'
    $r=Enviar '/Gestion?m=alertas' @{Buscar=$marca;Bodega=0;Estado='Próximo a vencer'} 'Consultar'
    Exigir ($r.Contains($marca)) 'Alerta de vencimiento dentro de treinta días'
    $rut=$marca.Substring($marca.Length-10)
    $proveedor=Sql "INSERT INTO laboratorio(Rut,RazonSocial) VALUES('$rut','$marca'); SELECT LAST_INSERT_ID();"
    $orden=Sql "INSERT INTO ordencompra(NumeroOC,IdLaboratorio,Fecha,Estado,IdUsuario) VALUES('$marca',$proveedor,CURDATE(),'Recibida',$usuario); SELECT LAST_INSERT_ID();"
    $detalleOC=Sql "INSERT INTO detalleordencompra(IdOC,IdVariante,CantidadPedida,CantidadRecibida,CostoUnitario) VALUES($orden,$variante,4,4,1); SELECT LAST_INSERT_ID();"
    $recepcion=Sql "INSERT INTO recepcioncompra(IdOC,FechaRecepcion,IdUsuario) VALUES($orden,CURDATE(),$usuario); SELECT LAST_INSERT_ID();"
    $compra=Sql "INSERT INTO detallerecepcion(IdRecepcion,IdDetalleOC,IdVariante,NumeroLote,FechaVencimiento,Cantidad,CostoUnitario) VALUES($recepcion,$detalleOC,$variante,'$marca',DATE_ADD(CURDATE(),INTERVAL 10 DAY),4,1); SELECT LAST_INSERT_ID();"
    $mov.Tipo='Entrada';$mov.Cantidad=4;$mov.Compra=$compra
    $r=Enviar '/Gestion?m=movimientos' $mov
    Exigir ($r.Contains('Registro guardado correctamente')) 'Entrada vinculada a recepción de compra'
    Exigir ((Sql "SELECT StockActual FROM inventario WHERE IdVariante=$variante AND IdBodega=$bodega") -eq '7') 'Entrada aumenta automáticamente el stock'
    $pendientes=Invoke-WebRequest ($base+'/Gestion?m=movimientos') -UseBasicParsing
    Exigir (!$pendientes.Content.Contains('detalle #'+$compra+' · '+$marca)) 'Recepción procesada se retira de documentos pendientes'
    $cliente=Sql "INSERT INTO cliente(Rut,Nombre) VALUES('$marca','$marca'); SELECT LAST_INSERT_ID();"
    $venta=Sql "INSERT INTO venta(TipoDocumento,Fecha,IdCliente,IdUsuario) VALUES('Prueba',CURDATE(),$cliente,$usuario); SELECT LAST_INSERT_ID();"
    $detalleVenta=Sql "INSERT INTO ventadetalle(IdVenta,IdVariante,Cantidad,PrecioUnitario,Subtotal) VALUES($venta,$variante,2,1,2); SELECT LAST_INSERT_ID();"
    $mov.Tipo='Salida';$mov.Cantidad=2;$mov.Venta=$detalleVenta;$mov.Compra=0
    $r=Enviar '/Gestion?m=movimientos' $mov
    Exigir ($r.Contains('Registro guardado correctamente')) 'Salida vinculada a venta'
    Exigir ((Sql "SELECT CantidadDisponible FROM lote WHERE IdLote=$lote") -eq '5') 'Salida descuenta automáticamente el lote'
    $detalleExceso=Sql "INSERT INTO ventadetalle(IdVenta,IdVariante,Cantidad,PrecioUnitario,Subtotal) VALUES($venta,$variante,8,1,8); SELECT LAST_INSERT_ID();"
    $mov.Cantidad=8;$mov.Venta=$detalleExceso;$r=Enviar '/Gestion?m=movimientos' $mov
    Exigir ($r.Contains('Stock insuficiente')) 'Salida por venta con stock insuficiente rechazada'
    Exigir ((Sql "SELECT COUNT(*) FROM movimientoinventario WHERE Origen='Salida' AND IdDetalleOrigen=$detalleExceso") -eq '0') 'Salida rechazada no genera movimiento parcial'
    $r=Enviar ('/Gestion?m=productos&id='+$producto) @{Nombre=$marca;Descripcion='Editado';Categoria=0;Marca=0;Minimo=10;Activo='Inactivo'} 'Guardar cambios'
    Exigir ($r.Contains('Registro guardado correctamente')) 'Edición y desactivación de producto'
    Exigir ((Sql "SELECT CONCAT(StockMinimo,':',Activo) FROM producto WHERE IdProducto=$producto") -eq '10:0') 'Stock mínimo y estado guardados'
    $r=Enviar '/Gestion?m=historial' @{Buscar=$marca;Bodega=0;Desde='';Hasta='';Tipo='Todos'} 'Exportar CSV'
    Exigir ($r.Contains('FechaMovimiento') -and !$r.Contains('<html')) 'Exportación CSV sin HTML añadido'
} finally {
    if($venta){Sql "DELETE FROM ventadetalle WHERE IdVenta=$venta; DELETE FROM venta WHERE IdVenta=$venta;" | Out-Null}
    if($cliente){Sql "DELETE FROM cliente WHERE IdCliente=$cliente" | Out-Null}
    if($recepcion){Sql "DELETE FROM detallerecepcion WHERE IdRecepcion=$recepcion; DELETE FROM recepcioncompra WHERE IdRecepcion=$recepcion;" | Out-Null}
    if($orden){Sql "DELETE FROM detalleordencompra WHERE IdOC=$orden; DELETE FROM ordencompra WHERE IdOC=$orden;" | Out-Null}
    if($proveedor){Sql "DELETE FROM laboratorio WHERE IdLaboratorio=$proveedor" | Out-Null}
    if($producto){Sql "DELETE m FROM movimientoinventario m JOIN lote l ON l.IdLote=m.IdLote JOIN varianteproducto v ON v.IdVariante=l.IdVariante WHERE v.IdProducto=$producto; DELETE i FROM inventario i JOIN varianteproducto v ON v.IdVariante=i.IdVariante WHERE v.IdProducto=$producto; DELETE l FROM lote l JOIN varianteproducto v ON v.IdVariante=l.IdVariante WHERE v.IdProducto=$producto; DELETE FROM varianteproducto WHERE IdProducto=$producto; DELETE FROM producto WHERE IdProducto=$producto;" | Out-Null}
    Remove-Item Env:MYSQL_PWD
}
