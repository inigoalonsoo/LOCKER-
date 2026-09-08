# Script para reconfigurar la tarea programada para que se ejecute OCULTA

$nombreTarea = "MonitoreoLockerTiempoReal"

# Eliminar tarea existente si existe
if (Get-ScheduledTask -TaskName $nombreTarea -ErrorAction SilentlyContinue) {
    Write-Host "Eliminando tarea existente..." -ForegroundColor Yellow
    Unregister-ScheduledTask -TaskName $nombreTarea -Confirm:$false
}

# Crear nueva acción con WindowStyle Hidden
$accion = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-WindowStyle Hidden -ExecutionPolicy Bypass -File `"C:\ACTUM\MonitoreoLockerTiempoReal.ps1`""

# Crear trigger cada minuto
$trigger = New-ScheduledTaskTrigger -Once -At (Get-Date) -RepetitionInterval (New-TimeSpan -Minutes 1) -RepetitionDuration ([System.TimeSpan]::FromDays(3650))

# Crear principal (ejecutar como usuario actual)
$principal = New-ScheduledTaskPrincipal -UserId $env:USERNAME -LogonType Interactive -RunLevel Limited

# Configuración: ejecutar aunque el usuario no esté logueado, oculta
$settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -Hidden -StartWhenAvailable -ExecutionTimeLimit (New-TimeSpan -Minutes 5)

# Registrar tarea
Register-ScheduledTask -TaskName $nombreTarea -Action $accion -Trigger $trigger -Principal $principal -Settings $settings -Description "Monitoreo automático del locker ACTUM en segundo plano (oculto)"

Write-Host "`n✅ Tarea programada reconfigurada para ejecución OCULTA" -ForegroundColor Green
Write-Host "La ventana de PowerShell ya no será visible durante las actualizaciones automáticas" -ForegroundColor Cyan

# Mostrar configuración
Get-ScheduledTask -TaskName $nombreTarea | Format-List TaskName, State, Description

# Iniciar tarea inmediatamente para probar
Write-Host "`nIniciando tarea para verificar que funciona en segundo plano..." -ForegroundColor Yellow
Start-ScheduledTask -TaskName $nombreTarea

Start-Sleep -Seconds 5

# Verificar última ejecución
$info = Get-ScheduledTaskInfo -TaskName $nombreTarea
Write-Host "`nÚltima ejecución: $($info.LastRunTime)" -ForegroundColor Cyan
Write-Host "Resultado: $($info.LastTaskResult) (0 = Éxito)" -ForegroundColor Cyan
Write-Host "`n✅ ¡Listo! El monitoreo ahora se ejecuta completamente en segundo plano" -ForegroundColor Green
