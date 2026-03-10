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

### Pasos de despliegue (estado 2026-02-26):
1. ✅ Copiar `GenerarDashboardAdmin.ps1` al locker como `C:\ACTUM\GenerarDashboardAdmin.ps1`
2. ✅ Copiar `EjecutarAdminOculto.vbs` al locker como `C:\ACTUM\EjecutarAdminOculto.vbs`
3. ✅ Ejecutar el script para generar el HTML inicial: `cd C:\ACTUM; .\GenerarDashboardAdmin.ps1`
4. ✅ Verificar que `DashboardAdmin.html` aparece en `C:\Users\User\OneDrive...\LockerACTUM\` — CONFIRMADO FUNCIONANDO
5. ⏳ **PENDIENTE**: Crear la tarea programada con el comando de arriba (cada 1 min)

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

**Estado final confirmado (2026-02-25 — PRODUCCION):**
| Componente | Estado | Notas |
|---|---|---|
| MonitoreoLockerTiempoReal | ✅ Interactive (User) via VBS | Oculto, cada 1 min |
| GenerarDashboardHTML | ✅ ACTIVA — Interactive (User) | Reactivada + cambiada de SYSTEM a User el 2026-03-03 |
| ActualizarExcel | ✅ SYSTEM | OK |
| Auto-login PC locker | ✅ Configurado | AutoAdminLogon=1, User, sin contrasena |
| Watchdog tarea | ✅ Configurado | Reinicia 3 veces si falla |
| Tildes/Codigos | ✅ CORRECTO | M-001, C-002... OK. Tildes OK |

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
