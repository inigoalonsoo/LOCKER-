# Script para copiar el logo a la carpeta de OneDrive del locker

$origenLogo = "c:\Antigravity\GHI\OIP (9).webp"
$destinoLogo = "C:\Users\User\OneDrive - GHI HORNOS INDUSTRIALES S.L\LockerACTUM\logo_ghi.webp"

Write-Host "Copiando logo de GHI Furnaces..." -ForegroundColor Cyan

if (Test-Path $origenLogo) {
    Copy-Item $origenLogo -Destination $destinoLogo -Force
    Write-Host "✓ Logo copiado exitosamente a: $destinoLogo" -ForegroundColor Green
} else {
    Write-Host "✗ No se encontró el logo en: $origenLogo" -ForegroundColor Red
}

Write-Host "`nAhora copia el script actualizado del dashboard:" -ForegroundColor Yellow
Write-Host "Copy-Item 'c:\Antigravity\GHI\GenerarDashboard.ps1' -Destination 'C:\ACTUM\GenerarDashboard.ps1' -Force" -ForegroundColor White
