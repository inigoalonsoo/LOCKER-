# Script de Exportación Automática del Locker ACTUM
# Este script extrae los datos del locker y los guarda en un archivo Excel

# Configuración
$servidor = "GHI-TAQUILLAS\SQLEXPRESS"
$baseDatos = "Actum_GHI"
$carpetaDestino = "C:\Users\$env:USERNAME\OneDrive\ReportesLocker"
$fechaHoy = Get-Date -Format "yyyy-MM-dd"
$archivoExcel = "$carpetaDestino\ReporteLocker_$fechaHoy.csv"

# Crear carpeta si no existe
if (-not (Test-Path $carpetaDestino)) {
    New-Item -ItemType Directory -Path $carpetaDestino -Force | Out-Null
    Write-Host "Carpeta creada: $carpetaDestino"
}

# Consulta SQL
$consulta = @"
SELECT 
    U.Nombre AS 'Nombre Usuario',
    U.Apellidos,
    U.DI AS 'Documento',
    C.CodigoCliente AS 'Consigna',
    C.Caja_Codigo AS 'Caja',
    C.FechaHoraUltimaApertura AS 'Fecha Ultima Apertura',
    CASE C.Estado
        WHEN 2 THEN 'Libre'
        WHEN 4 THEN 'Ocupada'
        ELSE 'Desconocido'
    END AS 'Estado',
    CASE C.EstadoPuerta
        WHEN 2 THEN 'Cerrada'
        ELSE 'Abierta'
    END AS 'Estado Puerta',
    CASE U.Activo
        WHEN 1 THEN 'Si'
        WHEN 0 THEN 'No'
        ELSE 'Desconocido'
    END AS 'Usuario Activo'
FROM 
    Consigna C
    LEFT JOIN Usuario U ON C.Usuario_CodigoUltimaApertura = U.Codigo
WHERE 
    C.FechaHoraUltimaApertura IS NOT NULL
ORDER BY 
    C.FechaHoraUltimaApertura DESC
"@

# Ejecutar consulta y exportar
Write-Host "Ejecutando consulta SQL..."
try {
    # Usar sqlcmd con autenticación de Windows y exportar a CSV
    sqlcmd -S $servidor -d $baseDatos -E -Q $consulta -o $archivoExcel -s";" -W -h-1
    
    if (Test-Path $archivoExcel) {
        Write-Host "✓ Reporte generado exitosamente: $archivoExcel" -ForegroundColor Green
        Write-Host "✓ Fecha: $fechaHoy" -ForegroundColor Green
        
        # Mostrar tamaño del archivo
        $tamano = (Get-Item $archivoExcel).Length
        Write-Host "✓ Tamaño: $tamano bytes" -ForegroundColor Green
    } else {
        Write-Host "✗ Error: No se pudo crear el archivo" -ForegroundColor Red
        exit 1
    }
} catch {
    Write-Host "✗ Error al ejecutar la consulta: $_" -ForegroundColor Red
    exit 1
}

# Log de ejecución
$archivoLog = "$carpetaDestino\Log_Exportaciones.txt"
$mensajeLog = "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - Exportación exitosa: $archivoExcel"
Add-Content -Path $archivoLog -Value $mensajeLog

Write-Host "`n=== EXPORTACIÓN COMPLETADA ===" -ForegroundColor Cyan
Write-Host "Archivo guardado en: $archivoExcel" -ForegroundColor Cyan
