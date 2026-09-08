# Script de Monitoreo en Tiempo Real del Locker ACTUM
# Detecta cambios cada minuto y construye historial completo

# Configuración
$servidor = "GHI-TAQUILLAS\SQLEXPRESS"
$baseDatos = "Actum_GHI"
$carpetaOneDrive = "C:\Users\User\OneDrive - GHI HORNOS INDUSTRIALES S.L\LockerACTUM"
$archivoHistorial = "$carpetaOneDrive\HistorialCompleto.csv"
$archivoEstadoAnterior = "$carpetaOneDrive\EstadoAnterior.json"
$archivoHTML = "$carpetaOneDrive\DashboardLocker.html"

# Crear carpeta si no existe
if (-not (Test-Path $carpetaOneDrive)) {
    New-Item -ItemType Directory -Path $carpetaOneDrive -Force | Out-Null
}

# Consulta SQL para obtener estado actual
$consultaSQL = @"
SELECT 
    U.Codigo AS UsuarioCodigo, 
    U.Nombre, 
    U.Apellidos, 
    C.Codigo AS ConsignaCodigo, 
    C.CodigoCliente AS Consigna, 
    C.FechaHoraUltimaApertura, 
    C.Usuario_CodigoUltimaApertura, 
    C.Estado, 
    C.EstadoPuerta,
    Cj.Descripcion AS CajaDescripcion
FROM Consigna C 
LEFT JOIN Usuario U ON C.Usuario_CodigoUltimaApertura = U.Codigo
LEFT JOIN Caja Cj ON C.Caja_Codigo = Cj.Codigo
WHERE C.FechaHoraUltimaApertura IS NOT NULL
"@

# Obtener estado actual de la base de datos
try {
    $connectionString = "Server=$servidor;Database=$baseDatos;Integrated Security=True;"
    $connection = New-Object System.Data.SqlClient.SqlConnection($connectionString)
    $connection.Open()
    $command = $connection.CreateCommand()
    $command.CommandText = $consultaSQL
    $adapter = New-Object System.Data.SqlClient.SqlDataAdapter($command)
    $dataTable = New-Object System.Data.DataTable
    $adapter.Fill($dataTable) | Out-Null
    $connection.Close()
    
    $estadoActual = @{}
    foreach ($row in $dataTable.Rows) {
        $key = [string]$row["ConsignaCodigo"]
        $estadoActual[$key] = @{
            Consigna = $row["Consigna"]
            Usuario = $row["Nombre"]
            Apellidos = $row["Apellidos"]
            Descripcion = if ($row["CajaDescripcion"] -ne [DBNull]::Value) { $row["CajaDescripcion"] } else { "" }
            FechaHora = [string]$row["FechaHoraUltimaApertura"]
            UsuarioCodigo = $row["Usuario_CodigoUltimaApertura"]
            Estado = $row["Estado"]
            EstadoPuerta = $row["EstadoPuerta"]
        }
    }
} catch {
    Write-Host "Error al consultar base de datos: $_" -ForegroundColor Red
    exit 1
}

# Cargar estado anterior si existe
$estadoAnterior = @{}
if (Test-Path $archivoEstadoAnterior) {
    $jsonContent = Get-Content $archivoEstadoAnterior -Raw | ConvertFrom-Json
    foreach ($property in $jsonContent.PSObject.Properties) {
        $estadoAnterior[$property.Name] = @{
            Consigna = $property.Value.Consigna
            Usuario = $property.Value.Usuario
            Apellidos = $property.Value.Apellidos
            Descripcion = if ($property.Value.Descripcion) { $property.Value.Descripcion } else { "" }
            FechaHora = $property.Value.FechaHora
            UsuarioCodigo = $property.Value.UsuarioCodigo
            Estado = $property.Value.Estado
            EstadoPuerta = $property.Value.EstadoPuerta
        }
    }
}

# Detectar cambios
$cambiosDetectados = @()
$fechaHoraActual = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

foreach ($key in $estadoActual.Keys) {
    $consignaActual = $estadoActual[$key]
    
    # Si es nueva o cambió la fecha de última apertura
    if (-not $estadoAnterior.ContainsKey($key) -or 
        $estadoAnterior[$key].FechaHora -ne $consignaActual.FechaHora) {
        
        $cambio = [PSCustomObject]@{
            FechaHoraApertura = $consignaActual.FechaHora
            Usuario = $consignaActual.Usuario
            Apellidos = $consignaActual.Apellidos
            Consigna = $consignaActual.Consigna
            Descripcion = $consignaActual.Descripcion
            Accion = if ($consignaActual.Estado -eq 2) { "Devoluci$([char]243)n" } elseif ($consignaActual.Estado -eq 4) { "Extracci$([char]243)n" } else { "Desconocido" }
            EstadoPuerta = if ($consignaActual.EstadoPuerta -eq 2) { "Cerrada" } else { "Abierta" }
        }
        $cambiosDetectados += $cambio
    }
}

# Si hay cambios, agregar al historial
if ($cambiosDetectados.Count -gt 0) {
    Write-Host "Cambios detectados: $($cambiosDetectados.Count)" -ForegroundColor Green
    
    # Agregar al archivo de historial CSV
    $existeHistorial = Test-Path $archivoHistorial
    foreach ($cambio in $cambiosDetectados) {
        $linea = "$($cambio.FechaHoraApertura);$($cambio.Usuario);$($cambio.Apellidos);$($cambio.Consigna);$($cambio.Descripcion);$($cambio.Accion);$($cambio.EstadoPuerta)"
        
        $utf8NoBOM = New-Object System.Text.UTF8Encoding $false
        if (-not $existeHistorial) {
            [System.IO.File]::WriteAllText($archivoHistorial, "FechaHoraApertura;Usuario;Apellidos;Consigna;Descripcion;Accion;EstadoPuerta`r`n", $utf8NoBOM)
            $existeHistorial = $true
        }

        [System.IO.File]::AppendAllText($archivoHistorial, $linea + "`r`n", $utf8NoBOM)
    }
    
    Write-Host "Historial actualizado: $archivoHistorial" -ForegroundColor Green
} else {
    Write-Host "No se detectaron cambios" -ForegroundColor Yellow
}

# Guardar estado actual para la próxima ejecución
$estadoActual | ConvertTo-Json -Depth 10 | Out-File -FilePath $archivoEstadoAnterior -Encoding UTF8

# Generar dashboard HTML (ejecutar en el mismo proceso, sin ventana nueva)
. "C:\ACTUM\GenerarDashboard.ps1"

Write-Host "Monitoreo completado a las $(Get-Date -Format 'HH:mm:ss')" -ForegroundColor Cyan
