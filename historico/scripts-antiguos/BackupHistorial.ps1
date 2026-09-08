# BackupHistorial.ps1
# Backup diario automatico del HistorialCompleto.csv con rotacion de 30 dias.
# Se ejecuta via tarea programada a las 3:00 AM (dormida del locker).
# Los backups se guardan dentro de OneDrive -> se sincronizan a la nube.

$carpetaUser     = "C:\Users\User\OneDrive - GHI HORNOS INDUSTRIALES S.L\LockerACTUM"
$archivoOrigen   = "$carpetaUser\HistorialCompleto.csv"
$carpetaBackups  = "$carpetaUser\Backups_Historial"
$diasRetencion   = 30

Write-Host "[BACKUP] Iniciando backup diario del historial..." -ForegroundColor Cyan

# Crear carpeta de backups si no existe
if (-not (Test-Path $carpetaBackups)) {
    New-Item -ItemType Directory -Path $carpetaBackups -Force | Out-Null
    Write-Host "[BACKUP] Carpeta creada: $carpetaBackups" -ForegroundColor Yellow
}

# Verificar que el CSV existe
if (-not (Test-Path $archivoOrigen)) {
    Write-Host "[BACKUP] ERROR: no se encuentra $archivoOrigen" -ForegroundColor Red
    exit 1
}

# Copiar con fecha en el nombre
$fecha           = Get-Date -Format 'yyyyMMdd'
$archivoDestino  = "$carpetaBackups\HistorialCompleto_$fecha.csv"

try {
    Copy-Item -Path $archivoOrigen -Destination $archivoDestino -Force
    $tam = (Get-Item $archivoDestino).Length
    Write-Host "[BACKUP] Creado: HistorialCompleto_$fecha.csv ($tam bytes)" -ForegroundColor Green
} catch {
    Write-Host "[BACKUP] ERROR al copiar: $_" -ForegroundColor Red
    exit 1
}

# ROTACION: eliminar backups mas antiguos de $diasRetencion dias
$limite   = (Get-Date).AddDays(-$diasRetencion)
$antiguos = Get-ChildItem -Path $carpetaBackups -Filter "HistorialCompleto_*.csv" |
            Where-Object { $_.LastWriteTime -lt $limite }

$eliminados = 0
foreach ($f in $antiguos) {
    try {
        Remove-Item $f.FullName -Force
        $eliminados++
    } catch {
        Write-Host "[BACKUP] No se pudo eliminar $($f.Name): $_" -ForegroundColor Yellow
    }
}

if ($eliminados -gt 0) {
    Write-Host "[BACKUP] Rotacion: $eliminados archivos > $diasRetencion dias eliminados" -ForegroundColor Cyan
}

$totalBackups = (Get-ChildItem -Path $carpetaBackups -Filter "HistorialCompleto_*.csv").Count
Write-Host "[BACKUP] Total backups actuales en la carpeta: $totalBackups" -ForegroundColor Cyan
Write-Host "[BACKUP] Completado a las $(Get-Date -Format 'HH:mm:ss')" -ForegroundColor Green
