# Sistema de Monitoreo del Locker ACTUM - GHI Furnaces

## 📋 Descripción del Proyecto

Sistema automatizado para monitorear en tiempo real los movimientos del locker ACTUM EPI en GHI Furnaces. Registra automáticamente todas las extracciones y devoluciones de herramientas/equipos, generando un dashboard HTML visual con la identidad corporativa de GHI.

## 🎯 Objetivos

1. **Automatizar el registro** de todos los movimientos del locker (extracciones y devoluciones)
2. **Dashboard en tiempo real** con actualización automática cada minuto
3. **Sincronización con OneDrive** para acceso desde cualquier ubicación
4. **Identidad corporativa GHI**: colores oficiales (rojo #C31E2E, negro, blanco) y logo
5. **Ejecución invisible** en segundo plano sin interrumpir el trabajo del usuario

## 🏗️ Arquitectura del Sistema

### Ubicaciones

- **Ordenador del Locker**: `GHI-TAQUILLAS` con SQL Server Express
- **Base de datos**: `Actum_GHI` en `GHI-TAQUILLAS\SQLEXPRESS`
- **Scripts de monitoreo**: `C:\ACTUM\` (en el ordenador del locker)
- **Dashboard y datos**: `C:\Users\User\OneDrive - GHI HORNOS INDUSTRIALES S.L\LockerACTUM\`
- **Scripts de desarrollo**: `c:\Antigravity\GHI\` (ordenador local)

### Archivos Principales

#### En el ordenador del locker (`C:\ACTUM\`)

1. **MonitoreoLockerTiempoReal.ps1**
   - Script principal que se ejecuta cada minuto
   - Consulta la base de datos ACTUM
   - Detecta cambios (nuevas aperturas de consignas)
   - Registra en CSV histórico
   - Llama a GenerarDashboard.ps1

2. **GenerarDashboard.ps1**
   - Genera el archivo HTML del dashboard
   - Lee el historial CSV
   - Crea tabla con últimos 50 movimientos
   - Aplica estilos corporativos GHI

3. **EjecutarMonitoreoOculto.vbs**
   - VBScript para ejecutar PowerShell de forma invisible
   - Llamado por la tarea programada

4. **ConfigurarTareaOcultaVBS.ps1**
   - Script de configuración para crear/actualizar la tarea programada

#### En OneDrive (accesible desde cualquier ordenador)

- **DashboardLocker.html**: Dashboard visual
- **HistorialCompleto.csv**: Base de datos de todos los movimientos
- **EstadoAnterior.json**: Estado previo para detectar cambios

### Tarea Programada

- **Nombre**: `MonitoreoLockerTiempoReal`
- **Frecuencia**: Cada 1 minuto
- **Ejecuta**: `wscript.exe "C:\ACTUM\EjecutarMonitoreoOculto.vbs"`
- **Usuario**: Usuario actual con sesión iniciada

## 📊 Estructura de Datos

### Base de datos ACTUM

**Tablas principales:**
- `Consigna`: Estado de cada consigna (locker individual)
- `Usuario`: Información de los usuarios
- `Caja`: Información de dispositivos/herramientas (con Descripción)
- `Eventos`: Historial de eventos del sistema

**Consulta SQL utilizada:**
```sql
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
```

### CSV Historial

**Formato**: Delimitador `;` con encoding UTF-8

**Columnas:**
- `FechaHoraApertura`: Timestamp del movimiento
- `Usuario`: Nombre del usuario
- `Apellidos`: Apellidos del usuario
- `Consigna`: Número de consigna
- `Descripcion`: Descripción del equipo/herramienta (ej: "Pinza.Amp1500v-Fluke393-59260351WS")
- `Accion`: "Extracción" o "Devolución"
- `EstadoPuerta`: "Abierta" o "Cerrada"

## 🎨 Dashboard

### Características

- **Diseño responsive** con la identidad GHI
- **Logo oficial** de GHI Furnaces
- **Colores corporativos**: Rojo #C31E2E, negro, blanco, gris
- **Tabla de últimos 50 movimientos** ordenada cronológicamente (más reciente arriba)
- **Búsqueda en tiempo real** por cualquier campo
- **Badges de color**: 
  - Rojo para "Extracción"
  - Verde para "Devolución"
- **Actualización automática**: Cada minuto
- **Encoding correcto**: UTF-8 con soporte para tildes y caracteres españoles

### Columnas del Dashboard

1. Fecha Apertura
2. Usuario
3. Apellidos
4. Consigna
5. Descripción
6. Acción

## ⚙️ Estado Actual (17/02/2026)

### ✅ Completado

- [x] Sistema de monitoreo automático cada minuto
- [x] Captura de datos desde ACTUM
- [x] Registro en CSV histórico
- [x] Dashboard con identidad GHI
- [x] Sincronización con OneDrive
- [x] Columna "Descripción" funcional (desde tabla Caja)
- [x] Orden cronológico descendente (más reciente primero)
- [x] Encoding correcto de caracteres españoles
- [x] Columnas actualizadas (eliminadas: Fecha Detección, DNI, Caja)
- [x] Acción con valores en español: "Extracción"/"Devolución"

### ⚠️ Problema Actual

**VENTANA DE POWERSHELL VISIBLE CADA MINUTO**

El sistema funciona correctamente pero cada minuto aparece brevemente una ventana de PowerShell que interrumpe el trabajo del usuario.

**Intentos realizados:**
1. ✅ VBScript con parámetro `0` (invisible)
2. ✅ `-WindowStyle Hidden` en PowerShell
3. ✅ Eliminación de todos los `Write-Host`
4. ✅ Dot-sourcing (`.`) en lugar de call operator (`&`)
5. ⏳ **Pendiente**: Configurar tarea con `-LogonType S4U`

**Próximo paso:**
Ejecutar en el locker:
```powershell
# SOLUCIÓN DEFINITIVA: LogonType S4U
Unregister-ScheduledTask -TaskName "MonitoreoLockerTiempoReal" -Confirm:$false

$action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-WindowStyle Hidden -NonInteractive -NoProfile -ExecutionPolicy Bypass -File `"C:\ACTUM\MonitoreoLockerTiempoReal.ps1`""

$trigger = New-ScheduledTaskTrigger -Once -At (Get-Date) -RepetitionInterval (New-TimeSpan -Minutes 1) -RepetitionDuration ([System.TimeSpan]::FromDays(3650))

$principal = New-ScheduledTaskPrincipal -UserId $env:USERNAME -LogonType S4U

$settings = New-ScheduledTaskSettingsSet -Hidden -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable -ExecutionTimeLimit (New-TimeSpan -Minutes 5)

Register-ScheduledTask -TaskName "MonitoreoLockerTiempoReal" -Action $action -Trigger $trigger -Principal $principal -Settings $settings
```

## 🔄 Flujo de Trabajo

1. **Cada minuto**: Tarea programada ejecuta `EjecutarMonitoreoOculto.vbs`
2. **VBScript**: Llama a `MonitoreoLockerTiempoReal.ps1` en modo invisible
3. **Monitoreo**: Consulta base de datos ACTUM
4. **Detección**: Compara con estado anterior (JSON)
5. **Registro**: Si hay cambios, añade al CSV histórico
6. **Dashboard**: Genera HTML con datos actualizados
7. **Sincronización**: OneDrive sincroniza automáticamente
8. **Estado**: Guarda estado actual para próxima ejecución

## 🛠️ Mantenimiento

### Actualizar scripts en el locker

Cuando modifiques archivos en `c:\Antigravity\GHI\`:
1. Conéctate al locker por TeamViewer
2. Copia el archivo actualizado
3. Pégalo en `C:\ACTUM\` usando notepad
4. Guarda (Ctrl+S)

### Regenerar dashboard manualmente

```powershell
cd C:\ACTUM
.\GenerarDashboard.ps1
```

### Verificar tarea programada

```powershell
Get-ScheduledTaskInfo -TaskName "MonitoreoLockerTiempoReal" | Select-Object LastRunTime, LastTaskResult, NextRunTime
```

### Actualizar descripciones del CSV

Si cambias descripciones en ACTUM EPI Visor:
```powershell
# Ejecutar script de actualización (crear si es necesario)
# Leer descripciones actuales de BD y actualizar CSV histórico
```

## 📝 Notas Importantes

- **No ejecutar desde ordenador remoto**: Los scripts están diseñados para ejecutarse solo en el ordenador del locker
- **OneDrive sincroniza**: No es necesario copiar manualmente el dashboard
- **Base de datos local**: ACTUM está solo en el servidor del locker
- **Encoding UTF-8**: Siempre usar UTF-8 para preservar tildes
- **Descripción desde Caja**: La tabla `Caja.Descripcion` es la fuente de info de equipos

## 🆘 Solución de Problemas

### El dashboard no se actualiza
1. Verificar tarea programada activa
2. Comprobar conexión a base de datos
3. Revisar logs de errores en PowerShell

### Caracteres raros en el dashboard
- Verificar encoding UTF-8 en todos los archivos
- Usar HTML entities cuando sea necesario

### OneDrive no sincroniza
- Verificar que OneDrive está activo
- Comprobar rutas correctas
- La ruta debe ser accesible por el usuario de la tarea

---

**Última actualización**: 17/02/2026
**Versión**: 1.0
**Contacto**: Equipo de desarrollo GHI
