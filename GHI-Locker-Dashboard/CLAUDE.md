# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Project Is

Automated monitoring system for the ACTUM EPI locker at GHI Hornos Industriales. It polls a SQL Server database every minute, detects locker open/close events, appends them to a CSV history, and generates a live HTML dashboard synced via OneDrive.

## Two Environments

**Development** (this machine — `ialopez`):
- Scripts live here: `c:\Users\ialopez\OneDrive - GHI HORNOS INDUSTRIALES S.L\Antigravity\GHI\`
- No SQL Server access — scripts cannot be run end-to-end locally

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
| `GenerarDashboard.ps1` | ✅ **SÍ — el único** | Lee CSV → Genera el HTML del dashboard |
| `MonitoreoLockerTiempoReal.ps1` | ❌ **NO** | Detecta cambios en el locker → actualiza CSV → llama a GenerarDashboard |
| `MoverArchivosOneDrive.ps1` | ❌ **NO** | Mueve archivos al OneDrive |
| `ExportarLocker.ps1` | ❌ **NO** | Exporta datos de SQL a los EXPORT_*.txt |
| `ConfigurarTareaOcultaVBS.ps1` | ❌ **NO** | Configura la tarea programada (ya está hecho, no volver a tocar) |
| `EjecutarMonitoreoOculto.vbs` | ❌ **NO** | Wrapper que lanza PowerShell sin ventana visible |

## Ficheros autogenerados — NO tocar manualmente

- **`HistorialCompleto.csv`** — Lo escribe `MonitoreoLockerTiempoReal.ps1` cada vez que detecta un movimiento en el locker. Es la fuente de datos del dashboard. **No modificar a mano.**
- **`EstadoAnterior.json`** — Lo usa `MonitoreoLockerTiempoReal.ps1` para comparar el estado actual con el anterior y detectar cambios. **No modificar a mano.**
- **`DashboardLocker.html`** — Lo genera `GenerarDashboard.ps1` automáticamente. **No modificar a mano.**
- **`EXPORT_*.txt`** — Los genera `ExportarLocker.ps1` exportando desde SQL. Se ejecuta manualmente cuando hay que actualizar el mapa de códigos.

## Data Flow

```
SQL Server (Actum_GHI)
  └─ Consigna JOIN Usuario JOIN Caja
       └─ MonitoreoLockerTiempoReal.ps1  (every 1 min via Scheduled Task → VBS)
            ├─ Compares FechaHoraUltimaApertura vs EstadoAnterior.json
            ├─ On change → appends to HistorialCompleto.csv (delimiter: ;, UTF-8)
            ├─ Saves new EstadoAnterior.json
            └─ SIEMPRE llama a: . "C:\ACTUM\GenerarDashboard.ps1"
                 └─ Reads CSV + EXPORT_Cajas.txt → builds DashboardLocker.html → OneDrive sync
```

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

## Tareas Pendientes / Posibles Mejoras Futuras

Lista de mejoras a implementar en próximas sesiones:

- [ ] Ordenar la tabla por Estado (En uso primero, luego Disponible)
- [ ] Añadir buscador/filtro en la tabla de historial
- [ ] Mostrar fecha de último uso de cada instrumento en la tabla de estado
- [ ] Añadir columna "Días en uso" para instrumentos no devueltos
- [ ] HTML separado para calibración (FechaCaducidad + CALIBRADO/CADUCADO badge) — datos ya disponibles en SQL

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
| **Fallback a EXPORT_Cajas.txt** | Si SQL cae, el script usa automáticamente el fichero local |

### Las 3 dependencias reales del sistema:

| Riesgo | Probabilidad | Impacto si falla | ¿Cubierto? |
|---|---|---|---|
| **SQL Server apagado** (GHI-TAQUILLAS\SQLEXPRESS) | Baja | Usa EXPORT_Cajas.txt automáticamente | ✅ Sí (fallback) |
| **PC locker se apaga / cierra sesión** | Media | Las tareas programadas dejan de ejecutarse | ✅ RESUELTO 2026-02-24 (SYSTEM) |
| **OneDrive sin conexión** | Baja | HTML se actualiza en local pero no en web | ❌ Depende de infraestructura |

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

## Resumen Final del Proyecto (estado a 2026-02-24)

El sistema de monitoreo del locker ACTUM está **completamente operativo y automatizado**:

1. **`MonitoreoLockerTiempoReal.ps1`** (cada 1 min) → Lee SQL → Escribe CSV → Genera HTML
2. **`GenerarDashboard.ps1`** (cada 1 min, tarea de respaldo) → Lee SQL (Caja) + CSV → Genera HTML
3. **`ActualizarExcel.ps1`** (cada 5 min) → Lee CSV → Actualiza Excel de instrumentos

**Sin intervención manual necesaria para:**
- ✅ Nuevas extracciones/devoluciones → aparecen en < 1 min
- ✅ Cambios de instrumento en ACTUM EPI Visor → aparecen en < 1 min
- ✅ Instrumentos nuevos o eliminados → aparecen en < 1 min
- ✅ Tildes y caracteres especiales → siempre correctos
- ✅ Estado del Excel de instrumentos → actualizado cada 5 min

**Única acción recomendada pendiente:**
Reconfigurar tareas como SYSTEM account (ver sección "Punto más débil") para garantizar funcionamiento 24/7 incluso si el PC del locker reinicia.
