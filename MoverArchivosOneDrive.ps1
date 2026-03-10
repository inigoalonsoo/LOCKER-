# Script para mover archivos a la carpeta correcta de OneDrive

$origenCarpeta = "C:\Users\User\OneDrive\LockerACTUM"
$destinoCarpeta = "C:\Users\User\OneDrive - GHI HORNOS INDUSTRIALES S.L\LockerACTUM"

Write-Host "=== Moviendo archivos a OneDrive sincronizado ===" -ForegroundColor Cyan

# Crear carpeta destino si no existe
if (-not (Test-Path $destinoCarpeta)) {
    New-Item -ItemType Directory -Path $destinoCarpeta -Force | Out-Null
    Write-Host "Carpeta creada: $destinoCarpeta" -ForegroundColor Green
} else {
    Write-Host "Carpeta ya existe: $destinoCarpeta" -ForegroundColor Yellow
}

# Verificar si existe carpeta origen
if (Test-Path $origenCarpeta) {
    # Copiar todos los archivos
    $archivos = Get-ChildItem $origenCarpeta -File
    
    foreach ($archivo in $archivos) {
        $destino = Join-Path $destinoCarpeta $archivo.Name
        Copy-Item -Path $archivo.FullName -Destination $destino -Force
        Write-Host "Copiado: $($archivo.Name)" -ForegroundColor Green
    }
    
    Write-Host "`nArchivos movidos exitosamente" -ForegroundColor Green
    Write-Host "Total archivos: $($archivos.Count)" -ForegroundColor Green
} else {
    Write-Host "No existe carpeta origen: $origenCarpeta" -ForegroundColor Yellow
}

# Mostrar archivos en destino
Write-Host "`n=== Archivos en OneDrive sincronizado ===" -ForegroundColor Cyan
Get-ChildItem $destinoCarpeta | Select-Object Name, LastWriteTime, Length | Format-Table -AutoSize
