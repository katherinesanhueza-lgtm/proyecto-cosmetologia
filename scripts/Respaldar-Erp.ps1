[CmdletBinding()]
param(
    [Parameter(Mandatory)][string]$Destino,
    [Parameter(Mandatory)][string]$DirectorioMySql
)
$ErrorActionPreference = 'Stop'
$app = Join-Path (Split-Path $PSScriptRoot) 'trabajo-ing-software'
$source = ([xml](Get-Content -LiteralPath (Join-Path $app 'Web.config') -Raw)).configuration.connectionStrings.configSource
$entry = ([xml](Get-Content -LiteralPath (Join-Path $app $source) -Raw)).connectionStrings.add | Where-Object name -eq DefaultConnection
[void][Reflection.Assembly]::LoadFrom((Join-Path $app 'bin/MySql.Data.dll'))
$config = [MySql.Data.MySqlClient.MySqlConnectionStringBuilder]::new([string]$entry.connectionString)
$schema = $config.Database
if ($schema -notmatch '^[a-zA-Z0-9_]+$') { throw 'Nombre de base no válido.' }
$Destino = [IO.Path]::GetFullPath($Destino)
[void][IO.Directory]::CreateDirectory($Destino)
$nombre = '{0}_{1}_{2}.sql' -f $schema,(Get-Date -Format 'yyyyMMdd_HHmmss'),([guid]::NewGuid().ToString('N').Substring(0,8))
$archivo = Join-Path $Destino $nombre
$validacion = 'validar_respaldo_' + [guid]::NewGuid().ToString('N')
function EjecutarCliente($exe, [string[]]$argumentos, $entrada) {
    $proceso = New-Object Diagnostics.ProcessStartInfo
    $proceso.FileName = Join-Path $DirectorioMySql ($exe+'.exe')
    $proceso.UseShellExecute = $false
    $proceso.CreateNoWindow = $true
    $proceso.RedirectStandardInput = $true
    $opciones = @('--no-defaults','--protocol=tcp',('--host='+$config.Server),('--port='+$config.Port),('--user='+$config.UserID),'--default-character-set=utf8mb4') + $argumentos
    $proceso.Arguments = ($opciones | ForEach-Object { if ($_ -match '"') { throw 'Opción inválida.' }; '"'+$_+'"' }) -join ' '
    $proceso.EnvironmentVariables['MYSQL_PWD'] = $config.Password
    $cliente = [Diagnostics.Process]::Start($proceso)
    try {
        if ($entrada) {
            $bytes = [IO.File]::OpenRead($entrada)
            try { $bytes.CopyTo($cliente.StandardInput.BaseStream) } finally { $bytes.Dispose() }
        }
    } finally { $cliente.StandardInput.Close(); $cliente.WaitForExit() }
    if ($cliente.ExitCode -ne 0) { throw "Error al ejecutar $exe." }
}
EjecutarCliente mysqldump @('--single-transaction','--quick','--routines','--events','--triggers','--hex-blob',("--result-file="+$archivo+'.parcial'),$schema) $null
EjecutarCliente mysql @('--execute=CREATE DATABASE '+$validacion) $null
try {
    EjecutarCliente mysql @($validacion) ($archivo+'.parcial')
    [IO.File]::Move(($archivo+'.parcial'),$archivo)
    Write-Output $archivo
} finally { EjecutarCliente mysql @('--execute=DROP DATABASE '+$validacion) $null }
