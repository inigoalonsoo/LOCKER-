# Script para reconfigurar la tarea programada usando VBScript (método más confiable)

$nombreTarea = "MonitoreoLockerTiempoReal"

# Eliminar tarea existente si existe
if (Get-ScheduledTask -TaskName $nombreTarea -ErrorAction SilentlyContinue) {
    Write-Host "Eliminando tarea existente..." -ForegroundColor Yellow
    Unregister-ScheduledTask -TaskName $nombreTarea -Confirm:$false
}

# Crear nueva acción usando el VBScript (ejecuta sin ventanas)
$accion = New-ScheduledTaskAction -Execute "wscript.exe" -Argument "`"C:\ACTUM\EjecutarMonitoreoOculto.vbs`""

# Crear trigger cada minuto
$trigger = New-ScheduledTaskTrigger -Once -At (Get-Date) -RepetitionInterval (New-TimeSpan -Minutes 1) -RepetitionDuration ([System.TimeSpan]::FromDays(3650))

# Crear principal (ejecutar como usuario actual)
$principal = New-ScheduledTaskPrincipal -UserId $env:USERNAME -LogonType Interactive -RunLevel Limited

# Configuración: ejecutar aunque el usuario no esté logueado, oculta
$settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -Hidden -StartWhenAvailable -ExecutionTimeLimit (New-TimeSpan -Minutes 5)

# Registrar tarea
Register-ScheduledTask -TaskName $nombreTarea -Action $accion -Trigger $trigger -Principal $principal -Settings $settings -Description "Monitoreo automático del locker ACTUM usando VBScript (100% invisible)"

Write-Host "`n✅ Tarea programada reconfigurada con VBScript" -ForegroundColor Green
Write-Host "Ahora la ejecución será 100% invisible (sin ventanas)" -ForegroundColor Cyan

# Mostrar configuración
Get-ScheduledTask -TaskName $nombreTarea | Format-List TaskName, State, Description

# Iniciar tarea inmediatamente para probar
Write-Host "`nIniciando tarea para verificar que funciona invisible..." -ForegroundColor Yellow
Start-ScheduledTask -TaskName $nombreTarea

Start-Sleep -Seconds 5

# Verificar última ejecución
$info = Get-ScheduledTaskInfo -TaskName $nombreTarea
Write-Host "`nÚltima ejecución: $($info.LastRunTime)" -ForegroundColor Cyan
Write-Host "Resultado: $($info.LastTaskResult) (0 = Éxito)" -ForegroundColor Cyan
Write-Host "`n✅ ¡Listo! El monitoreo ahora es 100% invisible usando VBScript" -ForegroundColor Green
