# Script para investigar toda la estructura de la base de datos ACTUM EPI Visor
# Este script explora todas las tablas mencionadas por el usuario

$servidor = "GHI-TAQUILLAS\SQLEXPRESS"
$baseDatos = "Actum_GHI"
$connectionString = "Server=$servidor;Database=$baseDatos;Integrated Security=True;"

function Ejecutar-Consulta {
    param(
        [string]$consulta,
        [string]$titulo
    )
    
    Write-Host "`n===========================================================" -ForegroundColor Cyan
    Write-Host "  $titulo" -ForegroundColor Yellow
    Write-Host "===========================================================" -ForegroundColor Cyan
    
    try {
        $connection = New-Object System.Data.SqlClient.SqlConnection($connectionString)
        $connection.Open()
        $command = $connection.CreateCommand()
        $command.CommandText = $consulta
        $adapter = New-Object System.Data.SqlClient.SqlDataAdapter($command)
        $dataTable = New-Object System.Data.DataTable
        $adapter.Fill($dataTable) | Out-Null
        $connection.Close()
        
        return $dataTable
    } catch {
        Write-Host "Error: $_" -ForegroundColor Red
        return $null
    }
}

# 1. EXPLORAR TABLA CONSIGNA (Estado de las consignas)
Write-Host "`n`n########## 1. TABLA CONSIGNA (ESTADO) ##########" -ForegroundColor Green
$consultaConsigna = "SELECT TOP 10 * FROM Consigna ORDER BY FechaHoraUltimaApertura DESC"
$dataConsigna = Ejecutar-Consulta -consulta $consultaConsigna -titulo "Primeras 10 filas de Consigna"
if ($dataConsigna) {
    Write-Host "`nColumnas disponibles:" -ForegroundColor Magenta
    $dataConsigna.Columns | Select-Object ColumnName, DataType | Format-Table -AutoSize
    Write-Host "`nDatos de ejemplo:" -ForegroundColor Magenta
    $dataConsigna | Format-Table -AutoSize
}

# 2. EXPLORAR TABLA USUARIO
Write-Host "`n`n########## 2. TABLA USUARIO ##########" -ForegroundColor Green
$consultaUsuario = "SELECT TOP 10 * FROM Usuario"
$dataUsuario = Ejecutar-Consulta -consulta $consultaUsuario -titulo "Primeras 10 filas de Usuario"
if ($dataUsuario) {
    Write-Host "`nColumnas disponibles:" -ForegroundColor Magenta
    $dataUsuario.Columns | Select-Object ColumnName, DataType | Format-Table -AutoSize
    Write-Host "`nDatos de ejemplo:" -ForegroundColor Magenta
    $dataUsuario | Format-Table -AutoSize
}

# 3. EXPLORAR TABLA CAJA (Dispositivos)
Write-Host "`n`n########## 3. TABLA CAJA (DISPOSITIVOS) ##########" -ForegroundColor Green
$consultaCaja = "SELECT TOP 10 * FROM Caja"
$dataCaja = Ejecutar-Consulta -consulta $consultaCaja -titulo "Primeras 10 filas de Caja"
if ($dataCaja) {
    Write-Host "`nColumnas disponibles:" -ForegroundColor Magenta
    $dataCaja.Columns | Select-Object ColumnName, DataType | Format-Table -AutoSize
    Write-Host "`nDatos de ejemplo (sin FOTO):" -ForegroundColor Magenta
    $dataCaja | Select-Object -Property * -ExcludeProperty Foto | Format-Table -AutoSize
}

# 4. EXPLORAR TABLA EVENTOS
Write-Host "`n`n########## 4. TABLA EVENTOS ##########" -ForegroundColor Green
$consultaEventos = "SELECT TOP 10 * FROM Eventos ORDER BY FechaHora DESC"
$dataEventos = Ejecutar-Consulta -consulta $consultaEventos -titulo "Últimos 10 eventos"
if ($dataEventos) {
    Write-Host "`nColumnas disponibles:" -ForegroundColor Magenta
    $dataEventos.Columns | Select-Object ColumnName, DataType | Format-Table -AutoSize
    Write-Host "`nDatos de ejemplo:" -ForegroundColor Magenta
    $dataEventos | Format-Table -AutoSize
}

# 5. EXPLORAR TABLA ERRORES
Write-Host "`n`n########## 5. TABLA ERRORES ##########" -ForegroundColor Green
$consultaErrores = "SELECT TOP 10 * FROM Errores ORDER BY FechaHora DESC"
$dataErrores = Ejecutar-Consulta -consulta $consultaErrores -titulo "Últimos 10 errores"
if ($dataErrores) {
    Write-Host "`nColumnas disponibles:" -ForegroundColor Magenta
    $dataErrores.Columns | Select-Object ColumnName, DataType | Format-Table -AutoSize
    Write-Host "`nDatos de ejemplo:" -ForegroundColor Magenta
    $dataErrores | Format-Table -AutoSize
}

# 6. EXPLORAR TABLA PARAMETROS
Write-Host "`n`n########## 6. TABLA PARAMETROS ##########" -ForegroundColor Green
$consultaParametros = "SELECT * FROM Parametros"
$dataParametros = Ejecutar-Consulta -consulta $consultaParametros -titulo "Todos los parámetros"
if ($dataParametros) {
    Write-Host "`nColumnas disponibles:" -ForegroundColor Magenta
    $dataParametros.Columns | Select-Object ColumnName, DataType | Format-Table -AutoSize
    Write-Host "`nDatos de ejemplo:" -ForegroundColor Magenta
    $dataParametros | Format-Table -AutoSize
}

# 7. EXPLORAR OTRAS TABLAS RELACIONADAS
Write-Host "`n`n########## 7. OTRAS TABLAS ##########" -ForegroundColor Green

# CajaTipo
$consultaCajaTipo = "SELECT * FROM CajaTipo"
$dataCajaTipo = Ejecutar-Consulta -consulta $consultaCajaTipo -titulo "Todos los tipos de caja"
if ($dataCajaTipo) {
    Write-Host "`nColumnas CajaTipo:" -ForegroundColor Magenta
    $dataCajaTipo.Columns | Select-Object ColumnName, DataType | Format-Table -AutoSize
    Write-Host "`nDatos:" -ForegroundColor Magenta
    $dataCajaTipo | Format-Table -AutoSize
}

# Herramienta
$consultaHerramienta = "SELECT TOP 10 * FROM Herramienta"
$dataHerramienta = Ejecutar-Consulta -consulta $consultaHerramienta -titulo "Primeras 10 herramientas"
if ($dataHerramienta) {
    Write-Host "`nColumnas Herramienta:" -ForegroundColor Magenta
    $dataHerramienta.Columns | Select-Object ColumnName, DataType | Format-Table -AutoSize
    Write-Host "`nDatos (sin FOTO):" -ForegroundColor Magenta
    $dataHerramienta | Select-Object -Property * -ExcludeProperty Foto | Format-Table -AutoSize
}

# Caja_Herramienta (relación)
$consultaCajaHerramienta = "SELECT * FROM Caja_Herramienta"
$dataCajaHerramienta = Ejecutar-Consulta -consulta $consultaCajaHerramienta -titulo "Relación Caja-Herramienta"
if ($dataCajaHerramienta) {
    Write-Host "`nColumnas Caja_Herramienta:" -ForegroundColor Magenta
    $dataCajaHerramienta.Columns | Select-Object ColumnName, DataType | Format-Table -AutoSize
    Write-Host "`nDatos:" -ForegroundColor Magenta
    $dataCajaHerramienta | Format-Table -AutoSize
}

Write-Host "`n`n===========================================================" -ForegroundColor Green
Write-Host "  INVESTIGACIÓN COMPLETA FINALIZADA" -ForegroundColor Yellow
Write-Host "===========================================================" -ForegroundColor Green
