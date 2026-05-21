# CLAUDE.md — Sistema Locker Instrumentacion GHI

> **START HERE — Para el desarrollador que retoma este proyecto**
>
> Este repositorio contiene el sistema de monitoreo automatico del locker ACTUM EPI de GHI Hornos Industriales. Lee esta seccion antes de tocar nada.
>
> **Estado a 2026-05-21:** Sistema completamente funcional en produccion. 487+ movimientos registrados. 5 tareas programadas activas en GHI-TAQUILLAS.
>
> **Las tres cosas mas importantes:**
> 1. El unico script que se edita para cambiar el dashboard es `GenerarDashboard.ps1`. Los demas no hace falta tocarlos salvo que cambie la infraestructura.
> 2. No hay acceso directo por red al locker. El unico camino para desplegar es: copiar el script → enviarlo al PC del locker → pegarlo en Notepad via TeamViewer → guardar en `C:\ACTUM\`.
> 3. Nunca modificar manualmente `HistorialCompleto.csv`, `UltimoEventoProcesado.txt` ni `EstadoAnterior.json`.
>
> **Pendiente prioritario:** El usuario mostrado en "En uso por X" puede diferir del asignado en ACTUM cuando la asignacion se hace desde el software sin abrir el locker fisicamente. Solucion: leer `Consigna.Usuario_Codigo` directamente en `GenerarDashboard.ps1` para la pestana Estado.

---

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Project Is

Automated monitoring system for the ACTUM EPI locker at GHI Hornos Industriales. It polls a SQL Server database every minute, detects locker open/close events, appends them to a CSV history, and generates a live HTML dashboard synced via OneDrive.

## Two Environments

**Development** (machine `ialopez`):
- Working folder: `C:\Users\ialopez\OneDrive - GHI HORNOS INDUSTRIALES S.L\TRABAJOS REALIZADOS\LOCKER INSTRUMENTACION\`
- No SQL Server access — scripts cannot be run end-to-end locally
- Server documental folder structure (handover package):
  - `DESARROLLO LOCKER (lo necesario para poder desarrollar el sistema si hace falta)` — source code, scripts, CLAUDE.md
  - `GITHUB REPOSITORIO` — link/reference to https://github.com/inigoalonsoo/LOCKER-.git
  - `INFORMACION LOCKER (lo que hay que saber sobre el sistema)` — DOCUMENTACION_LOCKER.html
  - `MANTENIMIENTO LOCKER (el unico mantenimiento manual que necesita)` — maintenance doc
  - `DashboardLocker` / `DashboardAdmin` — Windows shortcuts (.url) to the live dashboards

**Production** (locker machine — `GHI-TAQUILLAS`):
- Scripts deployed to: `C:\ACTUM\`
- SQL Server: `GHI-TAQUILLAS\SQLEXPRESS`, database `Actum_GHI`
- Dashboard and data: `C:\Users\User\OneDrive - GHI HORNOS INDUSTRIALES S.L\LockerACTUM\`
- Access via TeamViewer only (through a colleague who connects remotely)
- Only one Windows user exists on the locker: `User` (not `fabricacion1`, not `User2`)

## Deployment Workflow (ALWAYS follow this)

1. **Claude generates/updates `GenerarDashboard.ps1`** here in development
2. **User copies the script content** (Ctrl+A → Ctrl+C in VS Code)
3. **User sends it to their colleague** who has TeamViewer open to the locker
4. **Colleague opens Notepad on the locker**, pastes the content, saves as `C:\ACTUM\GenerarDashboard.ps1` (encoding: UTF-8, type: All Files)
5. **Colleague runs in locker PowerShell:**
   ```powershell
   cd C:\ACTUM
   .\GenerarDashboard.ps1
   ```
6. **Dashboard updates automatically** — `DashboardLocker.html` is synced via OneDrive to `fabricacion1@ghifurnaces.com`

> ⚠️ There is NO direct network access to the locker from the dev machine. Do NOT try to copy files over the network or use remote PowerShell. The only path is Notepad via TeamViewer.

## Real-Time Data Protocol

Claude must always work with real locker data. If any data is needed:
- Ask for the specific PowerShell command to run on the locker
- The user runs it in the locker PowerShell and pastes the output back
- Claude updates the script based on the real output

**Key data files on the locker:**
- `C:\ACTUM\EXPORT_Cajas.txt` — maps Consigna numbers to instrument codes (L-010, C-002, etc.)
- `C:\ACTUM\EXPORT_Consignas.txt` — consigna details
- `C:\ACTUM\EXPORT_Usuarios.txt` — user list
- `C:\Users\User\OneDrive - GHI HORNOS INDUSTRIALES S.L\LockerACTUM\HistorialCompleto.csv` — full movement history (delimiter `;`, UTF-8)
- `C:\Users\User\OneDrive - GHI HORNOS INDUSTRIALES S.L\LockerACTUM\EstadoAnterior.json` — last known state

## Script Roles — Qué modificar y qué NO tocar

### ✅ EL ÚNICO SCRIPT QUE SE MODIFICA: `GenerarDashboard.ps1`

Para cambiar el dashboard (diseño, columnas, colores, datos mostrados) **solo se toca `GenerarDashboard.ps1`**. Los demás NO hace falta modificarlos nunca salvo que cambie la infraestructura del locker.

| Script | ¿Se modifica? | Qué hace |
|--------|--------------|----------|
| `GenerarDashboard.ps1` | ✅ **SÍ** | Lee CSV → Genera el HTML del dashboard |
| `MonitoreoLockerTiempoReal.ps1` | ✅ **SÍ** | v2.0: Lee tabla Eventos de SQL → actualiza CSV → llama a GenerarDashboard. **Recupera TODO aunque el PC se apague.** |
| `MoverArchivosOneDrive.ps1` | ❌ **NO** | Mueve archivos al OneDrive |
| `ExportarLocker.ps1` | ❌ **NO** | Exporta datos de SQL a los EXPORT_*.txt |
| `ConfigurarTareaOcultaVBS.ps1` | ❌ **NO** | Configura la tarea programada (ya está hecho, no volver a tocar) |
| `EjecutarMonitoreoOculto.vbs` | ❌ **NO** | Wrapper que lanza PowerShell sin ventana visible |

## Ficheros autogenerados — NO tocar manualmente

- **`HistorialCompleto.csv`** — Lo escribe `MonitoreoLockerTiempoReal.ps1` cada vez que detecta un movimiento en el locker. Es la fuente de datos del dashboard. **No modificar a mano.**
- **`UltimoEventoProcesado.txt`** — Marcador con el timestamp del último evento de la tabla Eventos procesado. Lo usa v2.0 para saber dónde continuar. **No modificar a mano.**
- **`EstadoAnterior.json`** — Lo usa `MonitoreoLockerTiempoReal.ps1` para comparar el estado actual con el anterior y detectar cambios (backward compatibility). **No modificar a mano.**
- **`DashboardLocker.html`** — Lo genera `GenerarDashboard.ps1` automáticamente. **No modificar a mano.**
- **`EXPORT_*.txt`** — Los genera `ExportarLocker.ps1` exportando desde SQL. Se ejecuta manualmente cuando hay que actualizar el mapa de códigos.

## Data Flow (v2.0 - Activo desde 2026-04-21)

```
SQL Server (Actum_GHI)
  └─ Tabla Eventos (Evento=10000 = usuario identificado)
       └─ MonitoreoLockerTiempoReal.ps1 v2.0 (every 1 min via Scheduled Task → VBS)
            ├─ Lee UltimoEventoProcesado.txt (marcador)
            ├─ Query: SELECT * FROM Eventos WHERE Evento=10000 AND FechaHora > @marcador
            ├─ State tracking: determina Extracción/Devolución por estado previo
            ├─ Appends to HistorialCompleto.csv (delimiter: ;, UTF-8)
            ├─ Actualiza UltimoEventoProcesado.txt
            ├─ Health check: OneDrive corriendo?
            └─ SIEMPRE llama a: . "C:\ACTUM\GenerarDashboard.ps1"
                 └─ Reads CSV + SQL (Caja) → builds DashboardLocker.html → OneDrive sync
```

**Ventaja v2.0:** CERO pérdida de datos. Aunque el PC se apague 24 horas, al volver a encender recupera TODOS los eventos de la tabla Eventos.

## State Mapping (ACTUM database values)

- `Consigna.Estado = 2` → "Libre" → logged as `Accion = "Devolución"`
- `Consigna.Estado = 4` → "Ocupada" → logged as `Accion = "Extracción"`
- `Consigna.EstadoPuerta = 2` → "Cerrada", else "Abierta"

## EXPORT_Cajas.txt Structure (key for Código column)

The file `C:\ACTUM\EXPORT_Cajas.txt` has TWO sections separated by a blank line:

**Section 1 — Instruments/Boxes:**
```
Codigo,CodigoCliente,Descripcion,...
1,M-001,Nivel Optico / LeicaNA730Plus / 2201660,...
2,C-002,Cámara Termográfica / TESTO 872 / 87262826812,...
11,L-010,Pinza amp. 1500A / FLUKE 393 / 59260351WS,...
```

**Section 2 — Consignas (lockers):**
```
Codigo,CodigoCliente,Bloque,Fila,Columna,Caja_Codigo,...
1,01,...,1,...   ← consigna "01" holds box Codigo=1 (M-001)
2,02,...,2,...   ← consigna "02" holds box Codigo=2 (C-002)
11,11,...,11,... ← consigna "11" holds box Codigo=11 (L-010)
```

**Lookup logic — CONFIRMED WORKING (2026-02-19):**
- Section 2 (consignas) is EMPTY in the real file — only section 1 has data
- The Consigna number in HistorialCompleto.csv maps DIRECTLY to Codigo in section 1
- IMPORTANT: CSV stores consignas with leading zeros (`"01"`, `"09"`) but EXPORT_Cajas has no zeros (`"1"`, `"9"`)
- Fix: `$consignaKey = "$([int]$mov.Consigna)"` strips the leading zero before lookup
- Consigna `"100"` is a system event — always filter it out with `Where-Object { $_.Consigna -ne '100' }`

## UTF-8 / Tildes Solution (CONFIRMED WORKING ✅)

**Problem:** PowerShell 5.1 reads `.ps1` files as ANSI/Windows-1252 by default, so Spanish characters (á, é, ó, ú, ñ, etc.) inside heredocs (`@"...`"@`) get corrupted when written to HTML.

**Solution applied and confirmed working:**
1. Use **HTML entities** for ALL accented characters inside heredocs:
   - `á` → `&aacute;`, `é` → `&eacute;`, `ó` → `&oacute;`, `ú` → `&uacute;`
   - `Á` → `&Aacute;`, `É` → `&Eacute;`, `Ó` → `&Oacute;`, `Ú` → `&Uacute;`
   - `ñ` → `&ntilde;`, `Nº` → `N&ordm;`
2. Save the `.ps1` with **UTF-8 WITH BOM** (`New-Object System.Text.UTF8Encoding $true`)
3. The `<meta charset="UTF-8">` tag ensures the browser renders entities correctly

> ⚠️ NEVER use raw Spanish characters inside `@"...`"@` heredocs in PowerShell scripts. Always use HTML entities.

## Tab Navigation (CONFIRMED WORKING ✅)

Los tabs usan **CSS puro con radio buttons** — sin JavaScript. Esto es necesario porque OneDrive web (SharePoint preview) bloquea JS.

```html
<input type="radio" class="tab-inputs" id="tab-estado" name="tabs" checked>
<input type="radio" class="tab-inputs" id="tab-historial" name="tabs">
<div class="tabs-nav">
    <label class="tab-label" for="tab-estado">Estado Instrumentos</label>
    <label class="tab-label" for="tab-historial">Historial Movimientos</label>
</div>
```

El CSS activa el tab seleccionado con `#tab-estado:checked ~ .tab-content.content-estado { display: block; }`.

> ⚠️ NUNCA usar JavaScript `onclick` para los tabs — OneDrive web lo bloquea. Siempre CSS puro.

> ⚠️ NUNCA usar `@import url('https://fonts.googleapis.com/...')` — OneDrive web bloquea CDN externos. Usar fuentes del sistema: `-apple-system, BlinkMacSystemFont, 'Segoe UI', Arial, sans-serif`

## Known Issues / Pending

**1. Date format mismatch (MEDIUM)**
`GenerarDashboard.ps1` parses dates with `'MM/dd/yyyy HH:mm:ss'` (US format). The locker machine may write dates in Spanish format (`dd/MM/yyyy`). A format mismatch silently corrupts `Sort-Object`. If instrument states look wrong, check the date format in the real CSV first.

**2. Consignas con cero inicial (✅ RESUELTO)**
El CSV almacena consignas como `"01"`, `"02"` etc. pero EXPORT_Cajas.txt usa `"1"`, `"2"` sin cero. Fix aplicado: `$consignaKey = "$([int]$mov.Consigna)"` convierte `"01"` → `"1"` antes del lookup.

**3. Tarea programada falla por SQL (MITIGADO)**
`MonitoreoLockerTiempoReal.ps1` a veces falla al conectar con SQL Server (error 2147946720) y no llega a llamar a `GenerarDashboard.ps1`. Solución: se creó una segunda tarea `GenerarDashboardHTML` que ejecuta **solo** `GenerarDashboard.ps1` cada minuto como respaldo.

## Useful Manual Commands (run on locker machine)

```powershell
# Regenerate dashboard from existing CSV
cd C:\ACTUM
.\GenerarDashboard.ps1

# Check first 5 lines of CSV to see real data format
Get-Content "C:\Users\User\OneDrive - GHI HORNOS INDUSTRIALES S.L\LockerACTUM\HistorialCompleto.csv" | Select-Object -First 5

# Check scheduled task status
Get-ScheduledTaskInfo -TaskName "MonitoreoLockerTiempoReal" | Select-Object LastRunTime, LastTaskResult, NextRunTime

# Verify script version in production
Get-Item "C:\ACTUM\GenerarDashboard.ps1" | Select-Object Length, LastWriteTime
Get-Content "C:\ACTUM\GenerarDashboard.ps1" | Select-Object -First 5

# Check HTML was generated correctly
Get-Item "C:\Users\User\OneDrive - GHI HORNOS INDUSTRIALES S.L\LockerACTUM\DashboardLocker.html" | Select-Object Length, LastWriteTime
```

## Corporate Identity

- Primary red: `#C31E2E`
- Logo: embedded SVG (inline in dashboard heredoc, no external file dependency)
- Font: **system fonts only** (`-apple-system, BlinkMacSystemFont, 'Segoe UI', Arial, sans-serif`) — NO Google Fonts CDN
- Design: dark glassmorphism, gradient badges (green=Disponible, red=En uso/Extracción)
- Stats grid: always 4 columns (`grid-template-columns: repeat(4, 1fr)`)
- Table headers: `white-space: nowrap` to prevent wrapping
- NO `setTimeout` auto-reload — el HTML lo actualiza la tarea programada cada minuto

## Estado Actual del Dashboard (confirmado 2026-02-24) ✅

Características CONFIRMADAS funcionando en producción:

| Característica | Estado | Detalle |
|---|---|---|
| Diseño dark glassmorphism | ✅ | Fondo negro/gris, tarjetas translucidas |
| Logo GHI SVG inline | ✅ | Sin dependencias externas |
| 4 stat cards en una fila | ✅ | `repeat(4, 1fr)` |
| Pestaña Estado Instrumentos | ✅ | CSS puro, radio buttons |
| Pestaña Historial Movimientos | ✅ | CSS puro, radio buttons |
| Tildes y caracteres españoles | ✅ | HTML entities en heredoc + normalización Accion |
| Columna Código (L-010, T-001...) | ✅ | Desde SQL tabla `Caja` (auto-actualizado) |
| Columna Instrumento / Modelo / Nº serie | ✅ | Desde `Caja.Descripcion` en SQL |
| Consignas con cero (01, 09...) | ✅ | Fix `[int]` para strip leading zero |
| Filtro consigna 100 (sistema) | ✅ | `Where-Object { $_.Consigna -ne '100' }` |
| Badges verde/rojo estado | ✅ | Disponible / En uso por [nombre] |
| "En uso por " sin nombre | ✅ | Muestra solo "En uso" si usuario vacío |
| Duplicados en historial | ✅ | Group-Object sin Accion (encoding distinto) |
| Tildes en Extracción/Devolución | ✅ | Normalizado a `Extracci&oacute;n` / `Devoluci&oacute;n` |
| Actualización automática | ✅ | Doble tarea: MonitoreoLocker + GenerarDashboardHTML |
| Auto-actualización desde ACTUM EPI Visor | ✅ | SQL directo cada minuto — sin EXPORT manual |
| Compatible OneDrive web | ✅ | Sin JS, sin CDN externos |
| Nº Consigna en una línea | ✅ | `white-space: nowrap` en `th` |

---

## MonitoreoLockerTiempoReal.ps1 v2.0 — Sistema basado en Eventos (2026-04-21)

**Cambio arquitectónico mayor:** El script ahora usa la tabla `Eventos` de SQL como fuente de datos, en lugar de comparar estados. Esto garantiza **CERO pérdida de datos**.

### Tabla Eventos (SQL)

| Campo | Descripción |
|---|---|
| `Codigo` | GUID único del evento |
| `FechaHora` | Timestamp exacto del evento |
| `Evento` | Tipo: 3=puerta cierra, 4=puerta abre, **10000=usuario identificado** |
| `Consigna_Codigo` | Número de consigna |
| `Caja_Codigo` | Número de caja/instrumento |
| `Usuario_Codigo` | Código del usuario (solo en Evento=10000) |
| `Tratado` | Flag de procesado (no lo usamos) |

**Total eventos:** 168.760 desde 26/10/2024 hasta la actualidad.

### Cómo funciona v2.0

1. **Lee `UltimoEventoProcesado.txt`** → timestamp del último evento procesado
2. **Query SQL:** `SELECT * FROM Eventos WHERE Evento=10000 AND FechaHora > @ultimo`
3. **State tracking:** Para cada evento, determina si es Extracción o Devolución según el estado previo de la consigna:
   - Estado Ocupada (4) → acceso → Libre (2) = **Extracción**
   - Estado Libre (2) → acceso → Ocupada (4) = **Devolución**
4. **Añade al CSV** con el mismo formato que v1.0
5. **Actualiza `UltimoEventoProcesado.txt`**

### Ventajas vs v1.0

| Característica | v1.0 (antiguo) | v2.0 (nuevo) |
|---|---|---|
| Fuente de datos | Comparar `FechaHoraUltimaApertura` | **Tabla Eventos** |
| Pérdida de datos | Sí (si alguien saca+devuelve durante parada) | **No** |
| Recuperación tras apagado | Solo estado final | **TODOS los eventos** |
| Health check OneDrive | No | **Sí** |
| Fallback si SQL falla | No | **Sí** (usa método v1.0) |

### Fichero de marcador

**`UltimoEventoProcesado.txt`** - Contiene el timestamp del último evento procesado (formato: `yyyy-MM-dd HH:mm:ss`)

- En primera ejecución: lee última línea del CSV, resta 10 segundos (ventana de solapamiento)
- En ejecuciones normales: solo procesa eventos nuevos desde el marcador
- Se actualiza después de cada ejecución

### Fallback automático

Si la tabla `Eventos` no está disponible o la query falla, el script **automáticamente usa el método v1.0** (comparación de estados) como fallback. Esto garantiza que el sistema nunca se pare completamente.

---

## DashboardAdmin.html — Panel Interno (creado 2026-02-26)

Dashboard paralelo al DashboardLocker.html, para uso exclusivo de los administradores del sistema.
**NO interfiere con el DashboardLocker.html ni con ningún script existente.**

### Archivos nuevos:
| Archivo | Ruta dev | Ruta locker |
|---|---|---|
| `GenerarDashboardAdmin.ps1` | `GHI/GenerarDashboardAdmin.ps1` | `C:\ACTUM\GenerarDashboardAdmin.ps1` |
| `EjecutarAdminOculto.vbs` | `GHI-Locker-Dashboard/tareas-programadas/EjecutarAdminOculto.vbs` | `C:\ACTUM\EjecutarAdminOculto.vbs` |
| `DashboardAdmin.html` | (generado automáticamente) | `C:\Users\User\OneDrive...\LockerACTUM\DashboardAdmin.html` |

### Estructura del dashboard:
- **Pestaña 1 — Registro de Uso**: Recuento de usos por instrumento desde CSV, ordenado de mayor a menor. Barras visuales de uso, ranking con medallas (oro/plata/bronce), fecha último uso.
- **Pestaña 2 — Calibración**: Todos los instrumentos con FechaCaducidad de SQL. Badge CADUCADO/URGENTE(<30d)/PRÓXIMO(<90d)/CALIBRADO/SIN FECHA. Barra de progreso de días restantes. Ordenado por urgencia.
- **Pestaña 3 — Usuarios**: Lista completa desde SQL tabla Usuario. Columnas: `CodigoCliente` (código visible tipo "0001"), `UID` (PIN de acceso al locker), `Nombre`, `Apellidos`, tipo de acceso (SAT/Estándar). Ordenado por CodigoCliente.

### Banner de alerta automático:
Si hay instrumentos caducados o urgentes, aparece un banner rojo en la parte superior indicándolo.

### Tarea programada para el Admin Dashboard:
```powershell
# Ejecutar como admin en el locker para crear la tarea:
$accion = New-ScheduledTaskAction -Execute "wscript.exe" -Argument "`"C:\ACTUM\EjecutarAdminOculto.vbs`""
$trigger = New-ScheduledTaskTrigger -Once -At (Get-Date) -RepetitionInterval (New-TimeSpan -Minutes 1) -RepetitionDuration ([System.TimeSpan]::FromDays(3650))
$principal = New-ScheduledTaskPrincipal -UserId $env:USERNAME -LogonType Interactive -RunLevel Limited
$settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -Hidden -StartWhenAvailable -ExecutionTimeLimit (New-TimeSpan -Minutes 5)
Register-ScheduledTask -TaskName "GenerarDashboardAdmin" -Action $accion -Trigger $trigger -Principal $principal -Settings $settings
```
> Nota: se actualiza cada 1 min, igual que el DashboardLocker principal.

### Pasos de despliegue (estado 2026-03-10):
1. ✅ Copiar `GenerarDashboardAdmin.ps1` al locker como `C:\ACTUM\GenerarDashboardAdmin.ps1`
2. ✅ Copiar `EjecutarAdminOculto.vbs` al locker como `C:\ACTUM\EjecutarAdminOculto.vbs`
3. ✅ Ejecutar el script para generar el HTML inicial: `cd C:\ACTUM; .\GenerarDashboardAdmin.ps1`
4. ✅ Verificar que `DashboardAdmin.html` aparece en `C:\Users\User\OneDrive...\LockerACTUM\` — CONFIRMADO FUNCIONANDO
5. ✅ **COMPLETADO 2026-03-10**: Tarea programada `GenerarDashboardAdmin` creada — State: Ready, NextRunTime cada 1 min

### Columnas SQL confirmadas — Tabla `Usuario` (2026-02-26)

> ⚠️ IMPORTANTE: Los nombres reales difieren de lo esperado:

| Columna SQL real | Lo que muestra | Ejemplo |
|---|---|---|
| `CodigoCliente` | Código visible en ACTUM EPI Visor | `0001`, `0002` |
| `UID` | PIN de acceso al locker (lo que el usuario teclea) | `71102524`, `79002926` |
| `Nombre` | Nombre del usuario | `RAUL V.` |
| `Apellidos` | Apellidos | `VILLASANTE` |
| `AccesoConsignasRestringidas` | `True` = SAT (acceso total) | |
| `Codigo` | ID interno numérico (1, 2, 3...) — NO usar para mostrar | |

**NUNCA usar `Pin` — esa columna NO existe. El PIN es `UID`.**
**NUNCA usar `Codigo` para el código visible — usar `CodigoCliente`.**

## Resumen de Sesión — 2026-02-26 (tarde)

### Todo lo completado en esta sesión:

**1. DashboardAdmin.html — CREADO Y FUNCIONANDO EN PRODUCCIÓN ✅**
- Generado por `GenerarDashboardAdmin.ps1` en `C:\ACTUM\`
- HTML en `C:\Users\User\OneDrive...\LockerACTUM\DashboardAdmin.html`
- Pestaña 1 (Registro de Uso) ✅ funcionando
- Pestaña 2 (Calibración) ✅ funcionando
- Pestaña 3 (Usuarios) ✅ funcionando tras fix de columnas SQL

**2. Fix columnas SQL Usuarios (bug crítico resuelto)**
- `Pin` → renombrado a `UID` (nombre real en la tabla)
- `Codigo` → renombrado a `CodigoCliente` (para el código visible tipo "0001")
- Ordenado por `CodigoCliente` (igual que ACTUM EPI Visor)

**3. Intervalo tarea programada — cambiado a 1 minuto**
- Antes estaba configurado a 5 min → ahora 1 min (igual que DashboardLocker)

**4. VBS wrapper `EjecutarAdminOculto.vbs` — copiado al locker ✅**

### Estado final sistema completo (2026-02-26):
| Componente | Estado | Notas |
|---|---|---|
| `MonitoreoLockerTiempoReal` | ✅ Corriendo | Interactive (User), cada 1 min |
| `GenerarDashboard.ps1` + `DashboardLocker.html` | ✅ Producción | Sin tocar |
| `ActualizarExcel.ps1` | ✅ Corriendo | SYSTEM, cada 5 min |
| `GenerarDashboardAdmin.ps1` + `DashboardAdmin.html` | ✅ Funcionando | HTML generado OK |
| Tarea `GenerarDashboardAdmin` (auto-refresh) | ⏳ PENDIENTE | Crear en próxima sesión |

### Lo que queda por hacer (próxima sesión):
1. **Crear la tarea programada** `GenerarDashboardAdmin` en el locker (ejecutar como admin):
```powershell
$accion = New-ScheduledTaskAction -Execute "wscript.exe" -Argument "`"C:\ACTUM\EjecutarAdminOculto.vbs`""
$trigger = New-ScheduledTaskTrigger -Once -At (Get-Date) -RepetitionInterval (New-TimeSpan -Minutes 1) -RepetitionDuration ([System.TimeSpan]::FromDays(3650))
$principal = New-ScheduledTaskPrincipal -UserId $env:USERNAME -LogonType Interactive -RunLevel Limited
$settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -Hidden -StartWhenAvailable -ExecutionTimeLimit (New-TimeSpan -Minutes 5)
Register-ScheduledTask -TaskName "GenerarDashboardAdmin" -Action $accion -Trigger $trigger -Principal $principal -Settings $settings
```

---

## Tareas Pendientes / Posibles Mejoras Futuras

Lista de mejoras a implementar en próximas sesiones:

**DashboardLocker (público):**
- [ ] Ordenar la tabla por Estado (En uso primero, luego Disponible)
- [ ] Añadir buscador/filtro en la tabla de historial
- [ ] Mostrar fecha de último uso de cada instrumento en la tabla de estado
- [ ] Añadir columna "Días en uso" para instrumentos no devueltos

**DashboardAdmin (interno):**
- [ ] Añadir gráfico de uso por usuario (quién usa más el locker)
- [ ] Añadir línea de tendencia de movimientos por semana/mes
- [ ] Filtro de calibración por departamento (si se añade esa columna en SQL)

## Resumen de Sesión — 2026-02-24

### Todo lo completado en esta sesión:

**1. Fix tildes en Historial Movimientos**
- Problema: CSV tenía entradas con encoding roto → `"DevoluciÃ³n"` / `"ExtracciÃ³n"`
- Solución: normalizar siempre el valor de `Accion` a HTML entities en el render:
  ```powershell
  $accionTexto = if ($mov.Accion -like '*Extracci*') { 'Extracci&oacute;n' } elseif ($mov.Accion -like '*Devoluci*') { 'Devoluci&oacute;n' } else { $mov.Accion }
  ```

**2. Fix filas duplicadas en Historial**
- Problema: mismo evento aparecía dos veces con distinto encoding de `Accion` → `Group-Object` los trataba como diferentes
- Solución: quitar `Accion` del `Group-Object` key:
  ```powershell
  Group-Object FechaHoraApertura, Usuario, Consigna  # sin Accion
  ```

**3. Columna renombrada a "Instrumento / Modelo / Nº serie"**
- El campo `Caja.Descripcion` ya viene en ese formato desde SQL (`"Nivel Optico / LeicaNA730Plus / 2201660"`)

**4. Fix "En uso por " sin nombre**
- Si `Usuario` o `Apellidos` están vacíos, muestra `"En uso"` en vez de `"En uso por "`
- Fix aplicado en dos sitios: construcción del objeto y render HTML

**5. Integración SQL directa — GRAN MEJORA**
- `GenerarDashboard.ps1` ahora lee directamente de la tabla `Caja` de SQL Server:
  ```sql
  SELECT Codigo, CodigoCliente, Descripcion, FechaCaducidad FROM Caja
  ```
- `Caja.Codigo` = número de consigna (clave de enlace con el CSV de historial)
- Fallback automático a `EXPORT_Cajas.txt` si SQL no disponible
- `FechaCaducidad` se lee y almacena en los objetos (para uso futuro en HTML de calibración)

**6. Auto-actualización sin EXPORT manual**
- Cualquier cambio en ACTUM EPI Visor (nuevo instrumento, descripción, fecha caducidad...) se refleja en el dashboard en < 1 minuto
- Ya NO necesario hacer export desde ACTUM EPI Visor para actualizar el dashboard

### Estructura tabla SQL Caja (confirmada 2026-02-24):
| Columna SQL | Uso |
|---|---|
| `Codigo` | = Nº Consigna (clave de enlace) |
| `CodigoCliente` | Código GHI (M-001, L-010...) |
| `Descripcion` | "Instrumento / Modelo / Nº serie" (formato ya correcto) |
| `FechaCaducidad` | Fecha caducidad calibración (para futuro HTML) |
| `Foto` | Bytes PNG — ignorar |

### Estado final del sistema (2026-02-24):
| Script | En locker | Funciona | Fuente de datos |
|---|---|---|---|
| `MonitoreoLockerTiempoReal.ps1` | ✅ | ✅ Cada 1 min | SQL → CSV |
| `GenerarDashboard.ps1` | ✅ | ✅ Cada 1 min (VBS) | SQL (Caja) + CSV (Historial) |
| `ActualizarExcel.ps1` | ✅ | ✅ Cada 5 min (VBS) | CSV (Historial) + Excel |

## Resumen de Sesión — 2026-02-19

### Todo lo completado en esta sesión:

**1. Fix columna Código (L-010, T-001...)**
- Problema: `consignasMap` (sección 2 de EXPORT_Cajas.txt) estaba vacía en el locker
- Solución: el número de Consigna del CSV mapea DIRECTAMENTE al Codigo de sección 1
- `$mapaCodigos[$campos[0].Trim()] = $campos[1].Trim()` — directo, sin sección 2

**2. Fix consignas con cero inicial (01, 09...)**
- Problema: CSV guarda `"01"` pero EXPORT_Cajas.txt tiene `"1"` sin cero
- Solución: `$consignaKey = "$([int]$mov.Consigna)"` — convierte `"01"` → `"1"` antes del lookup

**3. Fix "Nº Consigna" en dos líneas**
- Añadido `white-space: nowrap` a todos los `th` de la tabla

**4. Tarea programada `GenerarDashboardHTML` (respaldo anti-fallos SQL)**
- Si `MonitoreoLockerTiempoReal` falla por SQL, el HTML igualmente se regenera cada minuto
- Usaba `-WindowStyle Hidden` que NO ocultaba la ventana → reconfigurada con VBS wrapper

**5. Ventana PowerShell visible cada minuto — RESUELTO**
- `GenerarDashboardHTML` rehecha con `EjecutarDashboardOculto.vbs` (parámetro `0` = 100% oculto)
- Patrón VBS documentado para todas las tareas futuras

**6. Excel de instrumentos — COMPLETADO**
- `ActualizarExcel.ps1` creado y desplegado en `C:\ACTUM\`
- ImportExcel v7.8.10 instalado en ruta no estándar (OneDrive\Documentos\WindowsPowerShell\Modules)
- Fix: `$excel.Save(); $excel.Dispose()` en vez de `Close-ExcelPackage -Save` (falla en v7.8.10)
- Tarea `ActualizarExcelLocker` creada via `EjecutarExcelOculto.vbs`, cada 5 minutos
- Actualiza: col A (UBICACIÓN) y col K (Estado CALIBRADO/CADUCADO)

### Estado final del sistema (2026-02-19 13:10):
| Script | En locker | Funciona |
|---|---|---|
| `MonitoreoLockerTiempoReal.ps1` | ✅ | ✅ Cada 1 min |
| `GenerarDashboard.ps1` | ✅ | ✅ Cada 1 min (VBS) |
| `ActualizarExcel.ps1` | ✅ | ✅ Cada 5 min (VBS) |
| `ExportarLocker.ps1` | ✅ | Manual (cuando cambia el ACTUM) |


## Tareas Programadas en el Locker (2026-02-19)

| Tarea | Qué ejecuta | Frecuencia | Propósito |
|---|---|---|---|
| `MonitoreoLockerTiempoReal` | `EjecutarMonitoreoOculto.vbs` → `MonitoreoLockerTiempoReal.ps1` | Cada 1 min | SQL → CSV → HTML |
| `GenerarDashboardHTML` | `EjecutarDashboardOculto.vbs` → `GenerarDashboard.ps1` | Cada 1 min | Respaldo: HTML siempre actualizado |
| `ActualizarExcelLocker` | `EjecutarExcelOculto.vbs` → `ActualizarExcel.ps1` | Cada 5 min | Actualiza UBICACIÓN y Estado en Excel |

## Cómo hacer tareas programadas 100% invisibles (SIN ventana PowerShell)

> ⚠️ CRÍTICO: Nunca crear tareas que llamen directamente a `powershell.exe` con `-File`. Aunque se use `-WindowStyle Hidden`, Windows a veces muestra la ventana igualmente. La solución correcta es SIEMPRE usar un wrapper VBS.

### Patrón correcto (3 pasos):

**Paso 1 — Crear el VBS wrapper** (hacer invisible la ejecución):
```powershell
Set-Content -Path "C:\ACTUM\EjecutarXXXOculto.vbs" -Value 'CreateObject("WScript.Shell").Run "powershell.exe -WindowStyle Hidden -NonInteractive -ExecutionPolicy Bypass -File ""C:\ACTUM\NombreScript.ps1""", 0, False'
```
El `0` en `.Run` es el parámetro clave — significa "ventana completamente oculta".

**Paso 2 — Crear la tarea apuntando al VBS** (no al .ps1 directamente):
```powershell
$accion = New-ScheduledTaskAction -Execute "wscript.exe" -Argument "`"C:\ACTUM\EjecutarXXXOculto.vbs`""
$trigger = New-ScheduledTaskTrigger -Once -At (Get-Date) -RepetitionInterval (New-TimeSpan -Minutes 1) -RepetitionDuration ([System.TimeSpan]::FromDays(3650))
$principal = New-ScheduledTaskPrincipal -UserId $env:USERNAME -LogonType Interactive -RunLevel Limited
$settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -Hidden -StartWhenAvailable -ExecutionTimeLimit (New-TimeSpan -Minutes 5)
Register-ScheduledTask -TaskName "NombreTarea" -Action $accion -Trigger $trigger -Principal $principal -Settings $settings
```

**Paso 3 — Verificar:**
```powershell
Get-ScheduledTask -TaskName "NombreTarea" | Select-Object TaskName, State
```

### Archivos VBS en C:\ACTUM (confirmados funcionando):
| Archivo VBS | Script que lanza |
|---|---|
| `EjecutarMonitoreoOculto.vbs` | `MonitoreoLockerTiempoReal.ps1` |
| `EjecutarDashboardOculto.vbs` | `GenerarDashboard.ps1` |
| `EjecutarExcelOculto.vbs` | `ActualizarExcel.ps1` |

## Excel de Instrumentos — ✅ RESUELTO (2026-02-19)

**Archivo:** `00.Intrumentos_Locker (1).xlsx`
- En locker (User): `C:\Users\User\OneDrive - GHI HORNOS INDUSTRIALES S.L\00.Intrumentos_Locker (1).xlsx`
- En dev (ialopez): `c:\Users\ialopez\OneDrive - GHI HORNOS INDUSTRIALES S.L\LOCKER INSTRUMENTACIÓN\00.Intrumentos_Locker (1).xlsx`

**Script:** `C:\ACTUM\ActualizarExcel.ps1` — actualiza cada 5 min via tarea `ActualizarExcelLocker`

**Qué actualiza automáticamente:**
- Columna **A (UBICACIÓN)**: `Disponible` o `En uso por [nombre]` según estado del locker
- Columna **K (Estado)**: `CALIBRADO` o `CADUCADO` comparando Fecha caducidad (col I) con hoy

**Detalles técnicos importantes:**
- ImportExcel v7.8.10 instalado en ruta NO estándar: `C:\Users\User\OneDrive...\Documentos\WindowsPowerShell\Modules\ImportExcel\7.8.10\`
- El script lo busca en rutas alternativas automáticamente si `Import-Module ImportExcel` falla
- NO usar `Close-ExcelPackage -Save` — en v7.8.10 falla. Usar `$excel.Save(); $excel.Dispose()`
- Datos empiezan en **fila 3**. CONSIGNA formato: `"Consigna - 1"` → extraer número con regex

**Estructura del Excel (confirmada):**
| Col | Contenido |
|-----|-----------|
| A | UBICACIÓN (auto-actualizada) |
| B | CONSIGNA (formato: "Consigna - 1") |
| C | DEPARTAMENTO |
| D | CODIGO GHI (M-001, L-010...) |
| E | DESCRIPCIÓN |
| F | NUMERO DE SERIE |
| G | MODELO |
| H | Fecha calibración |
| I | Fecha caducidad |
| J | EMP (Error máximo permitido) |
| K | Estado (auto-actualizado: CALIBRADO/CADUCADO) |
| L | EMPRESA |

**Archivo:** `00.Intrumentos_Locker (1).xlsx`
- En dev (ialopez): `c:\Users\ialopez\OneDrive - GHI HORNOS INDUSTRIALES S.L\LOCKER INSTRUMENTACIÓN\00.Intrumentos_Locker (1).xlsx`
- En locker (User): `C:\Users\User\OneDrive - GHI HORNOS INDUSTRIALES S.L\00.Intrumentos_Locker (1).xlsx`

**Script creado:** `ActualizarExcel.ps1` en `C:\ACTUM\` (ya pasado al locker)

**Qué hace el script (listo, solo falta el módulo):**
- Columna **A (UBICACIÓN)**: actualiza a `Disponible` o `En uso por [nombre]` según el estado del locker
- Columna **K (Estado)**: actualiza a `CALIBRADO` o `CADUCADO` comparando Fecha caducidad (col I) con hoy

**Estructura del Excel (confirmada):**
| Col | Contenido |
|-----|-----------|
| A | UBICACIÓN (LOCKER, PRODUCCION, SAT, En uso por...) |
| B | CONSIGNA (formato: "Consigna - 1", "Consigna - 2"...) |
| C | DEPARTAMENTO |
| D | CODIGO GHI (M-001, L-010, T-001...) |
| E | DESCRIPCIÓN |
| F | NUMERO DE SERIE |
| G | MODELO |
| H | Fecha calibración |
| I | Fecha caducidad |
| J | EMP (Error máximo permitido) |
| K | Estado (CALIBRADO / CADUCADO) |
| L | EMPRESA |

**Datos empiezan en fila 3** (filas 1-2 son título/cabecera).
**CONSIGNA col B** usa formato "Consigna - N" → extraer número con regex `Consigna\s*-\s*(\d+)`.

**Problema bloqueante:** El locker no puede instalar el módulo `ImportExcel` de PowerShell Gallery.
- Se intentó: `[Net.ServicePointManager]::SecurityProtocol = Tls12` + NuGet + `Install-Module ImportExcel -Scope CurrentUser -Force`
- NuGet se instaló (v2.8.5.208) pero `ImportExcel` no se descargó
- **Posible solución futura:** Descargar el módulo en dev (ialopez) y copiarlo manualmente al locker vía OneDrive:
  ```powershell
  # En ialopez: guardar el módulo en una carpeta
  Save-Module -Name ImportExcel -Path "C:\Users\ialopez\OneDrive - GHI HORNOS INDUSTRIALES S.L\LOCKER INSTRUMENTACIÓN\ImportExcel_module"
  # En locker: importar desde esa ruta
  Import-Module "C:\Users\User\OneDrive - GHI HORNOS INDUSTRIALES S.L\LOCKER INSTRUMENTACION\ImportExcel_module\ImportExcel\*\ImportExcel.psd1"
  ```

---

## Evaluación de Sostenibilidad del Sistema (2026-02-24) ✅

### Componentes 100% sólidos y permanentes:

| Componente | Por qué es permanente |
|---|---|
| **Tildes** (Extracción/Devolución) | Fix a nivel de código — siempre escribe HTML entities, ignora encoding del CSV |
| **Auto-actualización de instrumentos** | Lectura SQL directa cada minuto — sin EXPORT manual ni pasos intermedios |
| **Compatibilidad OneDrive web** | HTML puro con CSS, sin JS, sin CDN externos — no puede romperse |
| **Deduplicación historial** | Group-Object por fecha+usuario+consigna (sin Accion) — robusto ante cualquier encoding |
| **Tabla Eventos como fuente** | **v2.0**: Recupera TODOS los eventos aunque el PC se apague horas |
| **Health check OneDrive** | **v2.0**: Auto-restart si el proceso se cae |

### Las dependencias del sistema (post v2.0):

| Riesgo | Probabilidad | Impacto si falla | ¿Cubierto? |
|---|---|---|---|
| **SQL Server apagado** (GHI-TAQUILLAS\SQLEXPRESS) | Baja | No se registran eventos nuevos | ⚠️ No hay solución técnica |
| **PC locker se apaga / cierra sesión** | Media | **v2.0**: Recupera TODO al volver | ✅ **RESUELTO** |
| **OneDrive sin conexión** | Baja | HTML se actualiza en local pero no en web | ⚠️ Requiere intervención manual |
| **Expiración contraseña Windows** | Media (cada 50 días) | OneDrive pierde sesión | ⚠️ Requiere login manual (IT) |

### v2.0: Sistema tolerante a fallos

**Antes (v1.0):** Si el PC se apagaba y alguien sacó+devolvió un instrumento, esos movimientos se perdían (solo se veía el estado final).

**Ahora (v2.0):** La tabla `Eventos` registra CADA apertura/cierre con timestamp. Aunque el PC esté apagado 3 días, al volver se recuperan los 3 días completos de eventos.

### ⚠️ PUNTO MÁS DÉBIL: Tareas programadas como Interactive

Las tareas están configuradas con `LogonType Interactive`, lo que significa que **solo corren si hay una sesión de usuario activa** en el PC del locker. Si el PC reinicia o cierra sesión sin que nadie entre, las actualizaciones se detienen.

**Solución definitiva (requiere admin, una sola vez):**
```powershell
# Ejecutar como ADMINISTRADOR en el locker:
$principal = New-ScheduledTaskPrincipal -UserId "SYSTEM" -LogonType ServiceAccount -RunLevel Highest
Set-ScheduledTask -TaskName "GenerarDashboardHTML"       -Principal $principal
Set-ScheduledTask -TaskName "MonitoreoLockerTiempoReal"  -Principal $principal
Set-ScheduledTask -TaskName "ActualizarExcelLocker"      -Principal $principal
```
Con esto las tareas corren 24/7 como servicio del sistema, sin necesitar sesión activa.

### Escalabilidad a largo plazo:

- **CSV creciente:** ~10 mov/día × 365 = ~3.650 entradas/año. El script agrupa y filtra eficientemente. Sin problemas durante al menos 10 años.
- **Mantenimiento necesario:** Prácticamente cero en condiciones normales.
- **Cambios que SÍ requieren intervención futura:**
  - Cambio de nombre/IP del servidor SQL → actualizar `$connStr` en `GenerarDashboard.ps1` y `MonitoreoLockerTiempoReal.ps1`
  - Cambio de ruta de OneDrive en el locker → actualizar `$carpetaUser` al inicio de cada script

---

## Estructura SQL confirmada (2026-02-24) — Para referencia futura

### Tabla `Caja` — Instrumentos del locker
| Columna | Descripción |
|---|---|
| `Codigo` | = Nº Consigna (clave de enlace con historial CSV) |
| `CodigoCliente` | Código GHI (M-001, L-010...) |
| `Descripcion` | "Instrumento / Modelo / Nº serie" (ya formateado correctamente) |
| `FechaCaducidad` | Fecha caducidad calibración (para futuro HTML de calibración) |
| `Foto` | PNG en bytes — ignorar |

### Tabla `Consigna` — Configuración de cada hueco del locker
| Columna | Descripción |
|---|---|
| `Codigo` | Número de consigna |
| `Caja_Codigo` | Instrumento asignado (FK a Caja) |
| `Restringida` | `True` = solo SAT; `False` = accesible a todos |
| `Activa` | Si la consigna está operativa |
| `Usuario_Codigo` | Usuario que tiene el instrumento ahora |

### Tabla `Usuario` — Usuarios del sistema
| Columna | Descripción |
|---|---|
| `AccesoConsignasRestringidas` | `True` = SAT (puede abrir todas); `False` = solo consignas no restringidas |
| `Consigna_Codigo` | Consigna habitualmente asignada al usuario |
| `Nombre`, `Apellidos` | Identificación del usuario |

---

## Resumen Final del Proyecto (estado a 2026-04-21)

El sistema de monitoreo del locker ACTUM está **completamente operativo y automatizado**:

1. **`MonitoreoLockerTiempoReal.ps1` v2.0** (cada 1 min) → Lee tabla Eventos → Escribe CSV → Genera HTML
2. **`GenerarDashboard.ps1`** (cada 1 min, tarea de respaldo) → Lee SQL (Caja) + CSV → Genera HTML
3. **`ActualizarExcel.ps1`** (cada 5 min) → Lee CSV → Actualiza Excel de instrumentos

**Sin intervención manual necesaria para:**
- ✅ Nuevas extracciones/devoluciones → aparecen en < 1 min
- ✅ Cambios de instrumento en ACTUM EPI Visor → aparecen en < 1 min
- ✅ Instrumentos nuevos o eliminados → aparecen en < 1 min
- ✅ Tildes y caracteres especiales → siempre correctos
- ✅ Estado del Excel de instrumentos → actualizado cada 5 min
- ✅ **Recuperación tras apagado** → TODOS los eventos se recuperan al volver (v2.0)

**Estado final confirmado (2026-04-21 — PRODUCCION):**
| Componente | Estado | Notas |
|---|---|---|
| MonitoreoLockerTiempoReal | ✅ v2.0 Interactive (User) via VBS | Oculto, cada 1 min, basado en tabla Eventos |
| GenerarDashboardHTML | ✅ ACTIVA — Interactive (User) | Oculto, cada 1 min |
| GenerarDashboardAdmin | ✅ Interactive (User) via VBS | Oculto, cada 1 min |
| ActualizarExcel | ✅ SYSTEM | OK |
| Auto-login PC locker | ✅ Configurado | AutoAdminLogon=1, User, sin contrasena |
| Watchdog tarea | ✅ Configurado | Reinicia 3 veces si falla |
| Tildes/Codigos | ✅ CORRECTO | M-001, C-002... OK. Tildes OK |
| **Tabla Eventos** | ✅ **Activa** | 168.760 eventos desde oct 2024 |
| **UltimoEventoProcesado.txt** | ✅ **Activo** | Marcador para tracking |

---

## Resumen de Sesión — 2026-04-21 (v2.0 Eventos + v2.1 Dedup + Refresh UX)

### Cambio arquitectónico mayor implementado ✅

**1. MonitoreoLockerTiempoReal.ps1 v2.0**
- **Sistema basado en tabla Eventos** en lugar de comparación de estados
- Query: `SELECT * FROM Eventos WHERE Evento IN (10000, 10001) AND FechaHora > @ultimo`
- **CERO pérdida de datos:** recupera TODO aunque el PC se apague horas
- **State tracking:** alternancia desde estado actual de SQL (fuente de verdad)
- **Health check OneDrive:** auto-restart si el proceso se cae
- **Fallback automático:** si Eventos falla, usa método v1.0

**2. Archivo de marcador**
- `UltimoEventoProcesado.txt` → timestamp del último evento procesado
- En primera ejecución: lee CSV, resta 10 segundos (solapamiento)
- Se actualiza tras cada ejecución

**3. Backup de versión anterior**
- `MonitoreoLockerTiempoReal_v1_BACKUP.ps1` guardado por si hay problemas

**Primer despliegue exitoso:**
- 39 eventos recuperados en primera ejecución
- Dashboard funciona correctamente

### v2.1 — Deduplicación por clusters (tarde 2026-04-21)

**Problema detectado tras el primer despliegue v2.0:**
- El CSV tenía pares Extracción+Devolución del mismo usuario a 5-15s (artefactos)
- Faltaban consignas que estaban en uso según SQL (solo 8 aparecían en vez de 12)
- Causa raíz: ACTUM emite **dos tipos de eventos por interacción**: tipo `10000` y tipo `10001`

**Descubrimiento clave — Tipos de Evento en SQL:**

| Evento | Total | Significado |
|---|---|---|
| 1 | 12.329 | ? |
| 2 | 11.716 | ? |
| 3 | 140.131 | Puerta cierra |
| 4 | 2.317 | Puerta abre |
| 1002 | 1.451 | ? |
| 3001-3004 | ~385 | ? |
| 3601-3602 | ~48 | ? |
| 4001 | 15 | ? |
| **10000** | **270** | **Identificación usuario (tipo A)** |
| **10001** | **261** | **Identificación usuario (tipo B)** |

**Ambos eventos 10000 y 10001 son identificaciones válidas.** ACTUM emite 1 de cada para la misma acción física (usuario se identifica, abre, cierra). Antes solo leíamos 10000 → perdíamos ~50% de eventos, en especial los de usuarios SAT.

**Solución implementada:**
1. Query actualizada a `Evento IN (10000, 10001)`
2. Deduplicación por clusters:
   - Cluster = eventos consecutivos con mismo Consigna + mismo Usuario + `<= 60s` de separación
   - Regla: cluster → conservar solo 1 evento (el más antiguo)
   - Alternancia desde estado actual de SQL asigna la acción correcta (Extracción/Devolución)

**4. ReconstruirHistorial.ps1 (nuevo script, ejecutar UNA VEZ)**
- Lee TODA la tabla Eventos (10000+10001) desde oct 2024
- Aplica dedup por clusters
- Procesa por consigna desde el estado actual de SQL hacia atrás (alternancia reversed)
- Reescribe `HistorialCompleto.csv` desde cero con 473 movimientos limpios
- Actualiza `UltimoEventoProcesado.txt`
- Útil también en el futuro si se detectan anomalías

**Resultado final del despliegue v2.1 (2026-04-21):**
| Métrica | Antes | Ahora |
|---|---|---|
| Eventos CSV | ~270 (solo 10000) | **473** (10000+10001, deduplicado) |
| Consignas en uso detectadas | 8 | **12** (coincide con SQL) |
| Artefactos duplicados | Abundantes | 58 eliminados automáticamente |
| Pérdida de datos | Si PC apagado | **Cero** |
| Usuarios SAT registrados | No | **Sí** (eventos 10001) |

### v2.1 UX — Dashboard Refresh + Tab persistente

**Mejoras en GenerarDashboard.ps1:**

**1. Refresh sincronizado al `:00`**
- Antes: refresh a 60s desde carga (ej: 11:32:13, 11:33:13...)
- Ahora: refresh al segundo 00 exacto (ej: 11:33:00, 11:34:00...)
- Implementación: script JS inline calcula `(60 - segundos_actuales) * 1000 - ms` y programa `location.reload()`
- Fallback: meta refresh `content="75"` (por si JS bloqueado en OneDrive web)

**2. Pestaña persistente al refresh**
- Antes: cualquier refresh volvía a "Estado Instrumentos" (default)
- Ahora: persiste via hash URL (`#estado` / `#historial`)
- Al cambiar tab → `history.replaceState` actualiza el hash
- Al cargar → lee hash y marca el radio correspondiente

**3. JS ubicado antes de `</body>`** — el script es inline, sin dependencias externas, sin onclick handlers (compatible con OneDrive web)

### Estructura SQL confirmada en esta sesión (2026-04-21)

**Tabla `Eventos`:**
| Campo | Tipo | Descripción |
|---|---|---|
| `Codigo` | uniqueidentifier | GUID |
| `FechaHora` | datetime | Timestamp evento |
| `Evento` | bigint | Tipo (ver tabla arriba) |
| `ElectronicaCU_Codigo` | bigint | |
| `ElectronicaCU_Rele` | bigint | |
| `Consigna_Codigo` | bigint | FK a Consigna |
| `Caja_Codigo` | bigint | FK a Caja |
| `Herramienta_Codigo` | bigint | |
| `Usuario_Codigo` | bigint | FK a Usuario (solo en 10000/10001) |
| `Tratado` | bit | No se usa |

**Tabla `Usuario` — usuarios SAT identificados (`AccesoConsignasRestringidas = True`):**
- 8 IKER L. LASSO · 59 AITOR U. ULIBARRI · 60 JOSE G. G. GONZALEZ GONZALEZ · 62 IÑIGO A. ALONSO · otros

### Reglas permanentes aprendidas

1. **Filtro SQL correcto para identificaciones:** `Evento IN (10000, 10001)`, NO solo `10000`
2. **Dedup por clusters** siempre que se procesen eventos nuevos (umbral `<= 60s`, mismo usuario + misma consigna)
3. **Cluster → conservar 1 evento** (el más antiguo) + alternancia desde SQL
4. **Estado actual SQL = fuente de verdad** para Disponible/En uso
5. **El CSV histórico se puede reconstruir en cualquier momento** con `ReconstruirHistorial.ps1` — útil si se detectan anomalías

### Tema pendiente (sesión futura)

- **Contraseña Windows User del locker** — IT estudia si permitir `PasswordNeverExpires` para que OneDrive no pierda sesión cada 50 días. Prueba inicial con `wmic useraccount` se revirtió (espera decisión IT).

---

## Resumen de Sesion — 2026-03-03

### Problemas encontrados y resueltos:

**1. Dashboard sin actualizar 11 horas**
- Causa raiz: **OneDrive.exe no estaba corriendo** en el locker. Nadie lo habia iniciado tras un reinicio.
- Fix: `Start-Process "C:\Program Files\Microsoft OneDrive\OneDrive.exe"`
- Fix permanente: clave de registro `HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run` con valor `"C:\Program Files\Microsoft OneDrive\OneDrive.exe"`

**2. Tarea GenerarDashboardHTML desactivada (de antes)**
- Fue desactivada manualmente el 24/02/2026
- Fix: `Enable-ScheduledTask -TaskName "GenerarDashboardHTML"` (requiere admin)
- Ahora tiene watchdog: GenerarDashboard.ps1 la reactiva automaticamente si la detecta Disabled

**3. SQL devolvía 0 instrumentos**
- Causa: `JOIN Consigna+Caja WHERE Activa=1` devolvía 0 filas
- Fix: fallback automatico a `SELECT FROM Caja` si el JOIN da 0 resultados

**4. Tildes rotas (caracteres ◆) — CRITICO**
- Causa raiz: `GenerarDashboardHTML` corria como **SYSTEM** (no como User)
- Con SYSTEM, `Integrated Security=True` falla en SQL Express → usa EXPORT_Cajas.txt como fallback
- **EXPORT_Cajas.txt tiene encoding roto** (caracteres como `C□mara Termogr□fica`)
- Fix: cambiar el principal de la tarea a User (Interactive):
  ```powershell
  Set-ScheduledTask -TaskName "GenerarDashboardHTML" -Principal (New-ScheduledTaskPrincipal -UserId "User" -LogonType Interactive -RunLevel Limited)
  ```
- ⚠️ REGLA PERMANENTE: `GenerarDashboardHTML` SIEMPRE debe correr como `User` (Interactive), NUNCA como SYSTEM

**5. Transferencia de scripts via TeamViewer/Notepad — PROBLEMA GRAVE**
- El heredoc `@"..."@` se rompe al pegar scripts largos via clipboard/TeamViewer
- Sintoma: "454 lines" en vez de 688, error "Falta la cadena en el terminador"
- Solucion correcta: enviar el archivo .ps1 directamente (Teams/email), NO copiar-pegar

### Estado del sistema (2026-03-03 09:52):
| Componente | Estado |
|---|---|
| MonitoreoLockerTiempoReal | ✅ User/Interactive, cada 1 min |
| GenerarDashboardHTML | ✅ User/Interactive (cambiado de SYSTEM), cada 1 min |
| ActualizarExcelLocker | ✅ SYSTEM, cada 5 min |
| OneDrive | ✅ Corriendo + auto-arranque configurado en registro |
| Dashboard HTML | ✅ Actualizandose cada minuto, tildes correctas |
| Meta-refresh navegador | ✅ Cada 60 segundos (`<meta http-equiv="refresh" content="60">`) |
| Watchdog tarea | ✅ En GenerarDashboard.ps1 — reactiva GenerarDashboardHTML si Disabled |

### ⚠️ REGLAS CRITICAS para evitar recurrencia:
1. **GenerarDashboardHTML SIEMPRE como User** — NUNCA como SYSTEM (SQL falla)
2. **OneDrive DEBE estar corriendo** — si el PC reinicia y OneDrive no arranca, nada se sincroniza
3. **EXPORT_Cajas.txt tiene encoding roto** — NO es un fallback fiable; mantener SQL funcionando
4. **No pegar scripts largos por Notepad/TeamViewer** — enviar el .ps1 como archivo



**Comportamiento ante reinicio del locker:**
1. PC arranca → entra automáticamente como `User` (auto-login)
2. Al iniciar sesión → Task Scheduler arranca `MonitoreoLockerTiempoReal`
3. Cada 1 minuto → CSV actualizado + HTML generado (oculto, sin ventana)
4. Dashboard disponible en OneDrive en < 1 minuto

**Sistema presentado y aceptado por GHI el 2026-02-25. En producción.**

---

## 🚨 GUÍA RÁPIDA DE ERRORES COMUNES

### Error 1: No sincroniza a OneDrive (la hora no cambia)

**Síntoma:** El HTML local se genera bien pero desde tu PC/web no se actualiza.

**Diagnóstico:**
```powershell
# En el locker:
Get-Item "C:\Users\User\OneDrive...\LockerACTUM\DashboardLocker.html" | Select-Object LastWriteTime
```
Si la hora es reciente → el problema es OneDrive.

**Solución:**
1. Reiniciar OneDrive:
```powershell
Stop-Process -Name OneDrive -Force
Stop-Process -Name "OneDrive.Sync.Service" -Force
Start-Sleep -Seconds 5
Start-Process "C:\Program Files\Microsoft OneDrive\OneDrive.exe"
```
2. Si sigue sin funcionar, la sesión ha expirado → iniciar sesión manualmente en OneDrive desde el navegador.

---

### Error 2: Tarea programada no se ejecuta

**Síntoma:** El HTML no se genera, la hora no cambia.

**Diagnóstico:**
```powershell
Get-ScheduledTaskInfo -TaskName "MonitoreoLockerTiempoReal" | Select-Object LastRunTime, LastTaskResult
```
- LastTaskResult = 0 → OK
- LastTaskResult = otro número → error

**Solución:**
```powershell
# Ver tarea
Get-ScheduledTask -TaskName "MonitoreoLockerTiempoReal" | Select-Object State
# Si está Disabled:
Enable-ScheduledTask -TaskName "MonitoreoLockerTiempoReal"
```

---

### Error 3: Cambio de contraseña del PC

**Síntoma:** OneDrive deja de sincronizar después de cambiar la contraseña del locker.

**Solución:**
1. Iniciar sesión en el locker con la nueva contraseña
2. Arrancar OneDrive si no está corriendo
3. Verificar sincronización

---

###Error 4: HTML con tildes rotos (caracteres raros)

**Síntoma:** En lugar de "Cámara" aparece "C□mara".

**Solución:**
```powershell
# Ejecutar el parche:
powershell -ExecutionPolicy Bypass -File "C:\ACTUM\PatchFuncionTildes.ps1"
```

---

### Checklist rápido de verificación:
```powershell
# 1. Estado tareas
Get-ScheduledTask | Where-Object {$_.TaskName -like "*Locker*" -or $_.TaskName -like "*Dashboard*"} | Select-Object TaskName, State

# 2. Última ejecución
Get-ScheduledTaskInfo -TaskName "MonitoreoLockerTiempoReal" | Select-Object LastRunTime, LastTaskResult

# 3. HTML actualizado
Get-Item "C:\Users\User\OneDrive...\LockerACTUM\DashboardLocker.html" | Select-Object LastWriteTime

# 4. OneDrive corriendo
Get-Process OneDrive -ErrorAction SilentlyContinue
```

**Arquitectura de tareas definitiva (NO cambiar a SYSTEM):**
- `MonitoreoLockerTiempoReal` → **Interactive (User)** — necesita SQL (Integrated Security) y escritura a `C:\Users\User\OneDrive...`
- `GenerarDashboardHTML` → **DISABLED** — redundante, MonitoreoLockerTiempoReal ya genera HTML
- `ActualizarExcel` → puede ser SYSTEM si no usa OneDrive user path

**Fix SQL aplicado (JOIN Consigna+Caja):**
```sql
-- ANTES (bug): clave = Caja.Codigo (no coincidia con Consigna.CodigoCliente del CSV)
SELECT Codigo, CodigoCliente, Descripcion, FechaCaducidad FROM Caja

-- DESPUES (correcto): clave = Consigna.CodigoCliente (mismo que CSV)
SELECT C.CodigoCliente AS ConsignaCod, Cj.CodigoCliente AS CodigoGHI, Cj.Descripcion, Cj.FechaCaducidad
FROM Consigna C JOIN Caja Cj ON C.Caja_Codigo = Cj.Codigo WHERE C.Activa = 1
```

---

## 🚨 REGLA PERMANENTE: Encoding en scripts PowerShell (2026-02-24)

### El problema que ocurrió:
Se escribieron caracteres literales (á, é, ó, ñ...) dentro del código fuente `.ps1`.
Cuando el script se copia al locker (Windows con CP1252 por defecto), esos caracteres UTF-8 se corrompen → el script falla con errores de sintaxis como `Token '&' inesperado`.

### La regla que SIEMPRE hay que seguir:
> **NUNCA usar caracteres especiales (tildes, ñ, etc.) literales en el código fuente PowerShell.**
> Usar SIEMPRE `[char]0xXX` en su lugar.

| Carácter | Usar en PS código |
|---|---|
| á | `[char]0xE1` |
| é | `[char]0xE9` |
| í | `[char]0xED` |
| ó | `[char]0xF3` |
| ú | `[char]0xFA` |
| ñ | `[char]0xF1` |
| ü | `[char]0xFC` |
| Á | `[char]0xC1` |
| É | `[char]0xC9` |
| Í | `[char]0xCD` |
| Ó | `[char]0xD3` |
| Ú | `[char]0xDA` |
| Ñ | `[char]0xD1` |
| Ü | `[char]0xDC` |

### Ejemplo correcto:
```powershell
# MAL: usa literal -> se rompe al copiar
$text = $text -replace 'á', '&aacute;'

# BIEN: usa codigo hex -> funciona en cualquier sistema
$text = $text -replace [char]0xE1, '&aacute;'
```

### Si vuelve a ocurrir el error en el locker:
Usar el script de parche `PatchFuncionTildes.ps1` (en carpeta GHI):
```powershell
# Pegar contenido en PowerShell del locker (via TeamViewer si hace falta)
# O ejecutar desde C:\ACTUM si se ha copiado ahi
powershell -ExecutionPolicy Bypass -File "C:\ACTUM\PatchFuncionTildes.ps1"
```
El parche detecta y reemplaza la función automáticamente, verifica sintaxis y ejecuta el dashboard.

### Dónde se aplica la función actualmente:
- `GenerarDashboard.ps1` → función `ConvertTo-HtmlEntities` al inicio del script
- Se aplica a `Caja.Descripcion` al construir `$estadoInstrumentos`
- Si se añaden nuevos campos de texto desde SQL, aplicar también: `ConvertTo-HtmlEntities $campo`

---

## 🛡️ SOLUCIÓN DEFINITIVA DE ENCODING (2026-02-24) — LA ÚLTIMA LÍNEA DE DEFENSA

### El problema raíz descubierto:
Dos fuentes diferentes generaban dos filas del mismo instrumento con encoding diferente:
- `C&aacute;mara` → ConvertTo-HtmlEntities funcionó correctamente
- `C&#225;mara` → el char Unicode 'á' escapó a ConvertTo-HtmlEntities y lo capturó la red de seguridad

Ambos son idénticos en HTML (`&aacute;` = `&#225;` = 'á'). El navegador los muestra igual.

### La solución: conversión ASCII final antes de escribir el HTML

Al final de `GenerarDashboard.ps1`, en lugar de escribir UTF-8, se convierte el HTML a ASCII puro:

```powershell
# Antes (roto):
$utf8WithBOM = New-Object System.Text.UTF8Encoding $true
[System.IO.File]::WriteAllText($archivoHTML, $html, $utf8WithBOM)

# Ahora (infalible):
$htmlFinal = [System.Text.RegularExpressions.Regex]::Replace($html, '[^\x00-\x7F]', {
    param($match)
    return '&#' + [int][char]$match.Value + ';'
})
$ascii = New-Object System.Text.ASCIIEncoding
[System.IO.File]::WriteAllText($archivoHTML, $htmlFinal, $ascii)
```

### Por qué es infalible:
- Convierte **cualquier carácter > ASCII** (> 127) a entidad numérica `&#NNN;`
- No depende de ConvertTo-HtmlEntities ni del encoding del sistema
- No depende de si SQL conecta o usa fallback CSV
- No depende del account (SYSTEM o interactivo) que ejecuta la tarea
- El fichero resultante es **ASCII puro** — imposible corrupciones de encoding

### Si hay que volver a parchearlo en el locker (TeamViewer):
```powershell
$archivo = "C:\ACTUM\GenerarDashboard.ps1"
$contenido = Get-Content $archivo -Raw -Encoding UTF8
$viejo = '$utf8WithBOM = New-Object System.Text.UTF8Encoding $true
[System.IO.File]::WriteAllText($archivoHTML, $html, $utf8WithBOM)'
$nuevo = @'
$htmlFinal = [System.Text.RegularExpressions.Regex]::Replace($html, '[^\x00-\x7F]', {
    param($match)
    return '&#' + [int][char]$match.Value + ';'
})
$ascii = New-Object System.Text.ASCIIEncoding
[System.IO.File]::WriteAllText($archivoHTML, $htmlFinal, $ascii)
'@
$utf8NoBOM = New-Object System.Text.UTF8Encoding $false
[System.IO.File]::WriteAllText($archivo, $contenido.Replace($viejo, $nuevo), $utf8NoBOM)
Write-Host "Parche aplicado" -ForegroundColor Green
& "C:\ACTUM\GenerarDashboard.ps1"
```

### Verificación tras el parche:
```powershell
# Debe mostrar &aacute; o &#225; — NUNCA bytes rotos
Select-String "mara" "C:\Users\User\OneDrive - GHI HORNOS INDUSTRIALES S.L\LockerACTUM\DashboardLocker.html" |
    Select-Object -First 3 -ExpandProperty Line
```

---

## Resumen de Sesion — 2026-03-25

### Problema: Dashboard sin actualizar desde el 24/03 a las 8h

**Sintoma:** El HTML se generaba correctamente en el locker cada minuto (LastWriteTime actualizado), pero el dashboard no se actualizaba en OneDrive web.

**Causa raiz REAL (confirmada):** La cuenta de OneDrive (`fabricacion1@ghifurnaces.com`) cambio de contrasena. El cliente OneDrive del locker perdio la sesion y dejo de sincronizar archivos al cloud — aunque el proceso OneDrive.exe seguia corriendo, estaba desautenticado.

**Señales que apuntan a este problema:**
- El HTML se actualiza localmente (LastWriteTime reciente en el locker)
- Pero el archivo en OneDrive web muestra version antigua
- OneDrive.exe corre pero con PID desde hace dias (no reciente)
- El icono de OneDrive en la bandeja muestra error de cuenta

**Fix:** Abrir OneDrive en el locker → iniciar sesion con la nueva contrasena → sync se reanuda en segundos.

**Lo que NO era el problema:**
- Tareas programadas: OK
- SQL Server: conexion OK (32 instrumentos)
- Generacion del HTML: OK
- Auto-login: correcto

### Acciones realizadas:

**1. ActualizarExcelLocker estaba Disabled**
- Fix: `Enable-ScheduledTask -TaskName "ActualizarExcelLocker"`

**2. Regeneracion manual del dashboard**
- `cd C:\ACTUM; .\GenerarDashboard.ps1`
- Resultado: SQL OK, 32 instrumentos, 210 movimientos, HTML generado

**3. Fix preventivo — Tareas robustas ante reinicios**
Aplicado `-StartWhenAvailable` y reintentos a las 3 tareas criticas:
```powershell
$settings = New-ScheduledTaskSettingsSet `
    -AllowStartIfOnBatteries `
    -DontStopIfGoingOnBatteries `
    -Hidden `
    -StartWhenAvailable `
    -ExecutionTimeLimit (New-TimeSpan -Minutes 5) `
    -RestartCount 3 `
    -RestartInterval (New-TimeSpan -Minutes 1)

Set-ScheduledTask -TaskName "MonitoreoLockerTiempoReal" -Settings $settings
Set-ScheduledTask -TaskName "GenerarDashboardHTML" -Settings $settings
Set-ScheduledTask -TaskName "GenerarDashboardAdmin" -Settings $settings
```

**Por que es el fix correcto:** `-StartWhenAvailable` hace que si el PC se reinicia y la tarea "pierde" su ventana horaria, Windows la lanza automaticamente en cuanto el sistema esta listo. Sin esto, la tarea queda en `Ready` pero nunca se dispara hasta el proximo ciclo programado (que puede no llegar si el trigger perdio su referencia).

### Estado del sistema (2026-03-25 08:00):
| Componente | Estado | Notas |
|---|---|---|
| MonitoreoLockerTiempoReal | ✅ Ready | StartWhenAvailable + 3 reintentos |
| GenerarDashboardHTML | ✅ Ready | StartWhenAvailable + 3 reintentos |
| GenerarDashboardAdmin | ✅ Ready | StartWhenAvailable + 3 reintentos |
| ActualizarExcelLocker | ✅ Ready | Reactivada |
| OneDrive | ✅ Corriendo | Desde 21/03 |
| SQL | ✅ OK | 32 instrumentos |
| Dashboard HTML | ✅ Actualizandose cada minuto | Confirmado 7:56:10 |

### Diagnostico rapido (para futuras incidencias):
```powershell
# 1. Estado de tareas
Get-ScheduledTask -TaskName "MonitoreoLockerTiempoReal","GenerarDashboardHTML","ActualizarExcelLocker","GenerarDashboardAdmin" | Select-Object TaskName, State

# 2. Ultima ejecucion y resultado
Get-ScheduledTaskInfo -TaskName "MonitoreoLockerTiempoReal" | Select-Object LastRunTime, LastTaskResult, NextRunTime
Get-ScheduledTaskInfo -TaskName "GenerarDashboardHTML" | Select-Object LastRunTime, LastTaskResult, NextRunTime

# 3. OneDrive corriendo?
Get-Process -Name "OneDrive" -ErrorAction SilentlyContinue | Select-Object Name, StartTime

# 4. Cuando se actualizo el HTML por ultima vez?
Get-Item "C:\Users\User\OneDrive - GHI HORNOS INDUSTRIALES S.L\LockerACTUM\DashboardLocker.html" | Select-Object LastWriteTime

# 5. Fix rapido si todo esta parado:
Enable-ScheduledTask -TaskName "ActualizarExcelLocker"
cd C:\ACTUM; .\GenerarDashboard.ps1

# 6. CRITICO: Verificar si OneDrive esta sincronizando
# Si el HTML se actualiza localmente pero NO en OneDrive web:
# → Probable cambio de contrasena de la cuenta OneDrive
# → Solucion: abrir OneDrive en el locker e iniciar sesion de nuevo
# → O restart del PC (arranca OneDrive limpio y pide credenciales)
```

## ⚠️ CAUSA FRECUENTE DE FALLO: Cambio de contraseña OneDrive

Si el dashboard deja de actualizarse en OneDrive web pero el archivo local SÍ está actualizado (LastWriteTime reciente):

**Diagnóstico confirmado:** archivos en OneDrive web muestran fecha antigua ("el martes a las 2:00") mientras el HTML local se genera cada minuto.

**Fix — dos pasos:**
1. Click en el icono OneDrive (bandeja sistema) → si pide credenciales, introducirlas
2. **Si el icono muestra "azul girando" pero sigue sin sincronizar:** ir a **OneDrive → Configuración (engranaje) → pestaña Cuenta → re-introducir credenciales** explicitamente ahí
3. En 1-2 minutos el sync se reanuda

> ⚠️ El icono "azul girando" NO garantiza que la cuenta corporativa esté autenticada. OneDrive puede girar por otros motivos mientras la cuenta `fabricacion1@ghifurnaces.com` está desconectada. Verificar siempre en la pestaña Cuenta de Configuración.

> ⚠️ Cada vez que se cambie la contraseña de `fabricacion1@ghifurnaces.com` (o la cuenta OneDrive del locker), hay que volver a autenticar OneDrive en el PC del locker.

---

## Resumen de Sesion — 2026-04-30 (Bug marcador formato fecha)

### Problema: Sin movimientos registrados desde el 17/04/2026

**Sintoma:** El CSV terminaba el 17/04/2026 07:48:14 (ALVARO T. TREPIANA). La tarea corria cada minuto (LastTaskResult=0) pero no registraba nada. `UltimoEventoProcesado.txt` no existia en `C:\ACTUM\` (buscamos en la ruta incorrecta).

**Causa raiz — Bug de formato en `MonitoreoLockerTiempoReal.ps1`:**
- Cuando el script procesaba movimientos nuevos, guardaba el marcador en formato `MM/dd/yyyy HH:mm:ss` (formato del CSV, ej: `04/17/2026 07:48:14`)
- En la siguiente ejecucion, intentaba leerlo como `yyyy-MM-dd HH:mm:ss` → fallo de parseo
- Caia al fallback: leia el CSV, calculaba el marcador desde la ultima linea (07:48:04), buscaba en SQL → el dedup cross-batch eliminaba ese evento (ya estaba en el CSV) → 0 movimientos nuevos
- Sobreescribia el marcador con `(Get-Date)` → desde ese momento el marcador era "ahora"
- En adelante: siempre buscaba desde "ahora", nunca encontraba eventos pasados

**Nota:** El marcador real esta en `C:\Users\User\OneDrive...\LockerACTUM\UltimoEventoProcesado.txt`, NO en `C:\ACTUM\`. Error de diagnostico inicial al buscar en la ruta equivocada.

**Fix aplicado en `MonitoreoLockerTiempoReal.ps1` (linea 385-387):**
```powershell
# ANTES (bug): guardaba en formato MM/dd/yyyy HH:mm:ss
$ultimoTimestamp = ($nuevosMovimientos | Sort-Object FechaHoraApertura | Select-Object -Last 1).FechaHoraApertura
[System.IO.File]::WriteAllText($archivoMarcador, $ultimoTimestamp, $utf8NoBOM)

# DESPUES (correcto): siempre formato yyyy-MM-dd HH:mm:ss
$ultimaFechaObj = [DateTime]::ParseExact(
    ($nuevosMovimientos | Sort-Object FechaHoraApertura | Select-Object -Last 1).FechaHoraApertura,
    'MM/dd/yyyy HH:mm:ss', $null)
[System.IO.File]::WriteAllText($archivoMarcador, $ultimaFechaObj.ToString('yyyy-MM-dd HH:mm:ss'), $utf8NoBOM)
```

**Recuperacion de eventos perdidos:**
- Se ejecuto `ReconstruirHistorial.ps1` con la tarea pausada (`Disable-ScheduledTask`)
- Resultado: 537 eventos SQL → 58 artefactos eliminados → 479 movimientos limpios (antes 473)
- Marcador actualizado a `2026-04-30 09:45:23` en formato correcto
- 12 consignas "En uso" recuperadas correctamente

**Fix cosmético adicional en `GenerarDashboard.ps1`:**
- El historial solo mostraba `Usuario` (ej: "ALVARO T.") sin apellidos
- Fix: `$(("$($movimiento.Usuario) $($movimiento.Apellidos)").Trim())` → ahora muestra nombre completo (ej: "ALVARO T. TREPIANA")

### Regla permanente aprendida:
> **El marcador `UltimoEventoProcesado.txt` SIEMPRE debe estar en formato `yyyy-MM-dd HH:mm:ss`.**
> Esta en `C:\Users\User\OneDrive...\LockerACTUM\`, NO en `C:\ACTUM\`.
> Si el sistema deja de registrar movimientos y la tarea corre sin errores (LastTaskResult=0), comprobar el contenido y formato de ese archivo primero.

---

## Resumen de Sesion — 2026-05-14 (OneDrive sin sesion, sin perdida de datos)

### Problema: Dashboard sin actualizar desde ~06/05/2026

**Sintoma:** El dashboard no se actualizaba en OneDrive web. El HTML local SI se generaba (LastWriteTime 14/05/2026 09:02:16).

**Causa raiz:** La cuenta OneDrive (`fabricacion1@ghifurnaces.com`) cambio de contrasena (~6 mayo). El proceso OneDrive.exe seguia corriendo (desde 09/05/2026 19:10:18) pero sin sesion autenticada → no sincronizaba nada.

**Fix (paso 1):** Click en el icono de OneDrive en la bandeja del sistema → introducir nueva contraseña si aparece aviso.

**Fix (paso 2 — si el paso 1 no basta):** OneDrive puede seguir sin sincronizar aunque el proceso corra y el icono muestre "azul girando". En ese caso hay que ir a **OneDrive → Configuración (engranaje) → pestaña Cuenta → re-introducir credenciales** explicitamente. Esto fue necesario en la segunda incidencia del 14/05.

**Verificacion de datos:**
- CSV terminaba en 05/06/2026 11:25:52 (ANGEL F. FERNANDEZ, consigna 13)
- SQL: 0 eventos desde el 6/05 → nadie uso el locker en esos 8 dias
- Marcador `UltimoEventoProcesado.txt`: `2026-05-14 09:11:06` (formato correcto)
- **Sin perdida de datos** — las tareas programadas funcionaron correctamente durante toda la interrupcion

**Lo que NO era el problema:**
- Tareas programadas: OK (LastTaskResult=0, HTML generado cada minuto)
- SQL Server: OK (0 eventos nuevos, pero conexion activa)
- Marcador: formato correcto

### Nota diagnostica — Sort-Object con fechas MM/dd/yyyy

`Sort-Object FechaHoraApertura` sobre el CSV ordena **alfabeticamente**, no cronologicamente. "12/..." (diciembre) aparece despues de "05/..." (mayo), lo que puede confundir el diagnostico.

**Para ver los ultimos movimientos reales usar:**
```powershell
# Opcion 1: tail del CSV (escrito en orden cronologico)
Get-Content "C:\Users\User\OneDrive - GHI HORNOS INDUSTRIALES S.L\LockerACTUM\HistorialCompleto.csv" | Select-Object -Last 20

# Opcion 2: filtrar por ano
Import-Csv "...\HistorialCompleto.csv" -Delimiter ";" |
    Where-Object { $_.FechaHoraApertura -like "*2026*" } |
    Select-Object -Last 15 | Format-Table -AutoSize
```

### Estado del sistema (2026-05-14):
| Componente | Estado | Notas |
|---|---|---|
| MonitoreoLockerTiempoReal | ✅ Corriendo | Sin interrupcion durante el fallo de OneDrive |
| OneDrive | ✅ Autenticado | Re-autenticado manualmente 14/05 |
| CSV HistorialCompleto | ✅ Completo | Sin perdida de datos (locker no usado 06-14/05) |
| Marcador UltimoEventoProcesado | ✅ Correcto | `2026-05-14 09:11:06` formato yyyy-MM-dd |

---

## Resumen de Sesion — 2026-05-20 (Investigacion alternativas a OneDrive)

### Contexto

IT confirma que la politica de cambio de contrasena de `fabricacion1@ghifurnaces.com` cada ~50 dias **no se puede modificar**. Se investigo si existe alguna alternativa al cliente OneDrive para sincronizar el dashboard.

### Analisis de red del locker (GHI-TAQUILLAS)

| Parametro | Valor |
|---|---|
| IP | 172.16.5.40 |
| Mascara | 255.255.255.0 |
| Gateway | 172.16.5.1 |
| DNS | 8.8.8.8 / 8.8.4.4 (Google — NO corporativo) |
| Acceso internet | ✅ SI (ping 8.8.8.8 OK, 7ms) |
| Acceso servidor documental | ❌ NO |

**Por que no llega al servidor documental:**
- `\\srvdocumental\Ghihornos` → IP real: `192.168.210.250`
- El locker esta en subred `172.16.5.x`, el servidor en `192.168.210.x` — subredes distintas sin routing entre ellas
- El DNS del locker es Google (8.8.8.8), no el DNS corporativo → no resuelve nombres `.ghihornos.local`

### Alternativas investigadas

**1. Carpeta de red compartida (`\\srvdocumental\Ghihornos`)** — ❌ DESCARTADA
- No accesible desde el locker (subredes distintas)

**2. Azure Blob Storage** — ⏳ PENDIENTE (futura)
- Viable tecnicamente: locker tiene internet, script usa `Invoke-RestMethod` (sin modulos extra)
- SAS token con expiracion en 2030 — sin dependencia de contrasenas de usuario
- URL permanente y publica
- **Descartada por ahora:** GHI no tiene suscripcion Azure disponible
- **Retomar cuando tengan Azure**

**3. Microsoft Graph API con App Registration** — ⏳ PENDIENTE (futura)
- Parte de M365 que GHI ya tiene (Azure AD / Microsoft Entra ID) — sin coste adicional
- IT registra la app una vez (10 min). Autenticacion por certificado: **no caduca nunca**
- Script sube HTML a SharePoint/OneDrive con ese certificado en vez de con fabricacion1
- URL para usuarios queda exactamente igual
- **Pendiente de evaluar con IT**

**4. Servidor web en el propio locker (IIS)** — ⏳ PENDIENTE (futura)
- Script deja HTML en `C:\inetpub\wwwroot\`, gente accede por `http://172.16.5.40/DashboardLocker.html`
- Cero sincronizacion, cero cuentas que caduquen
- **Bloqueante:** no se sabe si los PCs de oficina (192.168.x.x) pueden llegar a 172.16.5.40
- **Pendiente de verificar conectividad**

### Decision

Se mantiene el sistema actual con OneDrive + fabricacion1. Cuando la contrasena caduca → re-autenticar manualmente en el locker (icono OneDrive → Configuracion → Cuenta).

Las alternativas 2, 3 y 4 quedan documentadas para retomar en el futuro.

---

## Limitacion conocida: Asignaciones administrativas en ACTUM

**Descubierto 2026-05-20** al verificar consigna 30.

`Consigna.Usuario_Codigo` en SQL puede no coincidir con el ultimo movimiento fisico registrado en la tabla `Eventos`. Esto ocurre cuando alguien asigna un usuario a una consigna directamente desde el software ACTUM EPI Visor (sin que el usuario abra el locker fisicamente). Ese tipo de asignacion NO genera entrada en `Eventos`.

**Consecuencia:** El dashboard puede mostrar un usuario diferente al que ACTUM tiene asignado.
**Impacto:** Solo afecta a quien se muestra como "En uso por X". El instrumento si aparece como EN USO. No es un bug, es una limitacion estructural.
**Solucion futura:** Leer `Consigna.Usuario_Codigo` directamente en `GenerarDashboard.ps1` para la pestana Estado, en vez de derivarlo del CSV.

---

---

## Resumen de Sesion — 2026-05-20 (Bug marcador + Reconstruccion semanal automatica)

### Problema: Movimiento no registrado en dashboard

**Sintoma:** Un movimiento real (JOSE G. G. GONZALEZ devolvio consigna 03 a las 12:42:29) aparecia en la tabla SQL `Eventos` pero no en el CSV ni en el dashboard.

**Causa raiz — Bug del marcador en `MonitoreoLockerTiempoReal.ps1`:**
```powershell
# ANTES (bug): cuando no habia eventos, se actualizaba a Get-Date
} else {
    [System.IO.File]::WriteAllText($archivoMarcador, (Get-Date).ToString('yyyy-MM-dd HH:mm:ss'), $utf8NoBOM)
}
```
El marcador avanzaba cada minuto aunque no hubiera actividad. Cuando llego el evento a las 12:42:29, el marcador ya habia pasado esa hora → el evento quedo "en el pasado" y nunca fue procesado.

**Fix aplicado en `MonitoreoLockerTiempoReal.ps1`:**
- Si no hay eventos en SQL (`$eventosEnSQL = 0`): NO actualizar el marcador — se mantiene en el ultimo evento real
- Si SQL encontro eventos pero el dedup los elimino todos (`$eventosEnSQL > 0` pero `$nuevosMovimientos = 0`): avanzar marcador al ultimo evento SQL para no reprocesarlos siempre

**Bug secundario sin diagnosticar:**
Durante la recuperacion (marcador reseteado a 12:42:00), el script encontro 1 evento pero produjo 0 movimientos — sin mensaje de error ni de dedup. Causa exacta desconocida. Ocurrio en 2 de 487 eventos totales (0.4%). No critico pero real.

**Recuperacion de datos:**
1. Evento manual añadido al CSV via PowerShell
2. `ReconstruirHistorial.ps1` ejecutado → 487 movimientos limpios (2 mas que antes)
3. Marcador actualizado a `2026-05-20 12:42:29` (formato correcto)

### Tarea programada semanal: `ReconstruirCSVSemanal`

Creada como seguro definitivo contra cualquier evento perdido:
- **Cuando:** Cada lunes a las 05:00 AM
- **Que hace:** Para MonitoreoLocker (75s) → ReconstruirHistorial → GenerarDashboard → reactiva MonitoreoLocker
- **Archivos:**
  - `C:\ACTUM\ReconstruirSemanal.ps1` — script principal
  - `C:\ACTUM\EjecutarReconstruccionOculto.vbs` — wrapper invisible

**Resultado:** Cualquier movimiento perdido durante la semana queda recuperado automaticamente el lunes. Sin intervencion manual.

### Estado de tareas programadas (2026-05-20):
| Tarea | Frecuencia | Estado |
|---|---|---|
| `MonitoreoLockerTiempoReal` | Cada 1 min | ✅ Ready |
| `GenerarDashboardHTML` | Cada 1 min | ✅ Ready |
| `GenerarDashboardAdmin` | Cada 1 min | ✅ Ready |
| `ActualizarExcelLocker` | Cada 5 min | ✅ Ready |
| `ReconstruirCSVSemanal` | **Lunes 05:00** | ✅ Ready (NextRun: 25/05/2026) |

### Regla permanente: here-strings en PowerShell via TeamViewer/chat

Al pegar comandos con here-string (`@'...'@`) desde el chat, la indentacion hace que `'@` no quede en columna 0 → PowerShell entra en modo de continuacion y el bloque no se ejecuta nunca.

**Solucion:** Usar arrays en lugar de here-strings para crear contenido de archivos:
```powershell
# MAL: here-string (se rompe al pegar con indentacion)
$content = @'
linea1
linea2
'@

# BIEN: array join (funciona siempre)
$lines = 'linea1', 'linea2'
$content = $lines -join "`r`n"
```

---

## Resumen de Sesion — 2026-05-21 (Dedup 60s → 10s + Fix manual consigna 13)

### Problema: Extraccion no registrada en consigna 13

**Sintoma:** Consigna 13 (Analizador particulas / KLOTZ / AMF20707) mostraba "Disponible" en el dashboard pero el instrumento estaba fisicamente extraido por ANGEL F. FERNANDEZ.

**Secuencia real confirmada:**

| Hora | Accion | En CSV |
|---|---|---|
| 10:54:12 | ANGEL F. FERNANDEZ Extraccion | OK |
| 11:19:54 | ANGEL F. FERNANDEZ Devolucion | OK |
| 11:20:10 | ANGEL F. FERNANDEZ Extraccion | NO — perdida |

**Diagnostico:**
- SQL `Eventos`: ultimo evento consigna 13 = `05/21/2026 11:20:10`, Evento=10000, Usuario=26 (ANGEL F.)
- Gap entre ultimo CSV (11:19:54) y evento SQL (11:20:10) = **16 segundos**
- Con `$ventanaSeg = 60`: 16 < 60 → el dedup cross-batch descartaba el evento como duplicado

**Causa raiz — ventana dedup demasiado amplia:**
El dedup cross-batch agrupa como "artefacto" cualquier evento del mismo usuario + consigna dentro de `$ventanaSeg` segundos del ultimo evento en CSV. Un gap de 16 segundos era suficiente para descartarlo con ventana de 60s.

**Fix aplicado — `MonitoreoLockerTiempoReal.ps1` linea 130:**
```powershell
# ANTES:
$ventanaSeg = 60

# AHORA:
$ventanaSeg = 10
```

Con 10 segundos: los duplicados reales de ACTUM (pares 10000+10001, tipicamente < 2s) siguen eliminandose. Acciones reales con > 10s de separacion ya no se descartan. Fisicamente imposible abrir, sacar/devolver y cerrar un locker en menos de 10 segundos.

**Bug secundario confirmado (2a ocurrencia — igual que 2026-05-20):**
Con marcador reseteado a 11:20:09 y ventanaSeg=10, el evento de 11:20:10 paso el filtro dedup (sin mensaje [DEDUP]) pero `$nuevosMovimientos` quedo = 0 sin explicacion ni mensaje de error. Misma conducta que el bug documentado el 20/05. Causa exacta desconocida. Ocurrencia estimada < 1% de eventos.

**Para investigar en el futuro:** anadir esta linea justo antes de `if ($nuevosMovimientos.Count -gt 0)` (~linea 370):
```powershell
Write-Host "DEBUG: filasLimpias=$($filasLimpias.Count) nuevosMov=$($nuevosMovimientos.Count)" -ForegroundColor Magenta
```

**Fix manual del CSV (ejecutado en el locker):**
```powershell
$utf8NoBOM = New-Object System.Text.UTF8Encoding $false
$linea = "05/21/2026 11:20:10;ANGEL F.;FERNANDEZ;13;Analizador part$([char]237)culas / KLOTZ / AMF20707;Extracci$([char]243)n;Cerrada"
[System.IO.File]::AppendAllText("C:\Users\User\OneDrive - GHI HORNOS INDUSTRIALES S.L\LockerACTUM\HistorialCompleto.csv", "$linea`r`n", $utf8NoBOM)
[System.IO.File]::WriteAllText("C:\Users\User\OneDrive - GHI HORNOS INDUSTRIALES S.L\LockerACTUM\UltimoEventoProcesado.txt", "2026-05-21 11:20:10", $utf8NoBOM)
```

**Resultado:** Dashboard regenerado con 494 movimientos. Consigna 13 muestra "En uso por ANGEL F. FERNANDEZ".

**Nota:** El `ReconstruirCSVSemanal` del lunes 25/05/2026 a las 05:00 recuperara automaticamente cualquier evento perdido esta semana.
