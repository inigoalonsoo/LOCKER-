# Configuración del Sistema de Monitoreo en Tiempo Real

## 📋 Archivos Creados

1. **MonitoreoLockerTiempoReal.ps1** - Script principal que detecta cambios cada minuto
2. **GenerarDashboard.ps1** - Genera el dashboard HTML visual
3. Esta guía de configuración

---

## 🚀 PASO 1: Copiar Scripts al Ordenador del Locker

Los archivos están en `c:\Antigravity\GHI\` en tu ordenador.

Necesitas copiarlos a `C:\ACTUM\` en el ordenador del locker:

### Archivos a copiar:
- `MonitoreoLockerTiempoReal.ps1`
- `GenerarDashboard.ps1`

**Método:** Igual que antes (copiar/pegar por Bloc de Notas o transferencia TeamViewer)

---

## 🧪 PASO 2: Probar Manualmente

En PowerShell como Administrador del ordenador del locker:

```powershell
cd C:\ACTUM
.\MonitoreoLockerTiempoReal.ps1
```

**Debería crear:**
- Carpeta: `C:\Users\User\OneDrive\LockerACTUM\`
- Archivo: `HistorialCompleto.csv`
- Archivo: `DashboardLocker.html`
- Archivo: `EstadoAnterior.json` (uso interno)

---

## 🔄 PASO 3: Actualizar Tarea Programada a 1 Minuto

### Primero, eliminar la tarea anterior (diaria):

```powershell
Unregister-ScheduledTask -TaskName "Exportar Locker ACTUM Diario" -Confirm:$false
```

### Crear la nueva tarea (cada 1 minuto):

```powershell
$accion = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-ExecutionPolicy Bypass -File `"C:\ACTUM\MonitoreoLockerTiempoReal.ps1`""
$desencadenador = New-ScheduledTaskTrigger -Once -At (Get-Date) -RepetitionInterval (New-TimeSpan -Minutes 1) -RepetitionDuration ([TimeSpan]::MaxValue)
$principal = New-ScheduledTaskPrincipal -UserId "SYSTEM" -LogonType ServiceAccount -RunLevel Highest
$configuracion = New-ScheduledTaskSettingsSet -StartWhenAvailable -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -ExecutionTimeLimit (New-TimeSpan -Minutes 1)

Register-ScheduledTask -TaskName "Monitoreo Locker Tiempo Real" -Action $accion -Trigger $desencadenador -Principal $principal -Settings $configuracion -Description "Monitorea el locker cada minuto y actualiza historial"

Write-Host "Tarea programada creada - Se ejecuta cada 1 minuto" -ForegroundColor Green
```

---

## 📊 PASO 4: Verificar que Funciona

### Probar ejecución manual de la tarea:

```powershell
Start-ScheduledTask -TaskName "Monitoreo Locker Tiempo Real"
```

### Ver el historial generado:

```powershell
Get-Content "C:\Users\User\OneDrive\LockerACTUM\HistorialCompleto.csv"
```

---

## 🌐 PASO 5: Acceder al Dashboard

### En el ordenador del locker:
- Abrir el archivo: `C:\Users\User\OneDrive\LockerACTUM\DashboardLocker.html`
- Con cualquier navegador (Chrome, Edge, Firefox)

### Desde cualquier ordenador de la empresa:
1. Ir a: `https://onedrive.live.com`
2. Entrar con: `fabricacion1@ghifurnaces.com`
3. Carpeta: `LockerACTUM`
4. Abrir: `DashboardLocker.html`

---

## ✅ Cómo Funciona el Sistema

### Cada 1 minuto (automático):

1. **Consulta la base de datos ACTUM**
2. **Compara** con el estado del minuto anterior
3. **Si detecta cambios:**
   - Guarda el movimiento en `HistorialCompleto.csv`
   - Actualiza el dashboard `DashboardLocker.html`
4. **OneDrive sincroniza** automáticamente a la nube
5. **Toda la empresa** puede ver los datos actualizados

---

## 📁 Archivos Generados

| Archivo | Descripción | Para qué sirve |
|---------|-------------|----------------|
| `HistorialCompleto.csv` | Historial acumulativo | Abrir con Excel, análisis de datos |
| `DashboardLocker.html` | Dashboard visual | Ver en navegador, pantalla grande |
| `EstadoAnterior.json` | Estado anterior (interno) | No tocar, uso del sistema |

---

## 🔧 Solución de Problemas

### No se detectan cambios
- Verificar que ACTUM esté funcionando
- Verificar que SQL Server esté iniciado

### El HTML no se actualiza
- Verificar que se ejecute `GenerarDashboard.ps1`
- Revisar errores en PowerShell

### No aparece en OneDrive web
- Esperar 1-2 minutos para sincronización
- Verificar que OneDrive esté activo (icono en bandeja)

---

## 📧 OneDrive Configurado

- **Cuenta:** fabricacion1@ghifurnaces.com
- **Ruta local:** C:\Users\User\OneDrive\LockerACTUM\
- **Acceso web:** https://onedrive.live.com (con la cuenta de fabricación)
