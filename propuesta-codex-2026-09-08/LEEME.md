# Propuesta de Codex — 2026-09-08 — NO DESPLEGADA (decisión tomada)

Esto es una propuesta **descartada para producción**, conservada por su valor de análisis.
**No copiar nada de esta carpeta a `C:\ACTUM`.**

## Qué proponía

Un sistema de protección de cambios manuales con estado persistente
(`ProteccionHistorial.json`), mutex entre procesos, transacciones con *journal*
(`ReconstruccionPendiente.json`), copias de seguridad automáticas y recuperación de
escrituras interrumpidas. Tocaba 4 scripts, incluido `MonitoreoLockerTiempoReal.ps1` (v2.5).

## Qué acertó, y se ha aprovechado

1. **Encontró un hueco real.** La protección anterior solo cubría `CorreccionesManuales.csv`.
   Si alguien editaba directamente `HistorialCompleto.csv`, se perdía igual.
   → **Resuelto** en `ReconstruirHistorial.ps1`, paso 2.6 (filas huérfanas).
2. **Mejora del inicializador:** `CrearCorreccionesManuales.ps1` no debe rehacer el fichero si
   ya existe, porque destruye lo añadido a mano después.
   → **Incorporado**, sin las dependencias.
3. **Respaldó antes de tocar nada** (`RESPALDO_ANTES_CODEX_2026-09-08`, 67/67 verificados) y
   **no desplegó nada** en el locker. Trabajo limpio y honesto sobre sus propios límites.

## Por qué NO se despliega

Medido leyendo el código, no su resumen:

| # | Problema | Dónde |
|---|---|---|
| 1 | **Crea una carpeta de backup en cada movimiento y nunca las borra.** ~5 MB/día dentro de la carpeta de OneDrive, sin rotación. Reproduce el problema del CSV inflado por otra vía | `Write-LockerTransaction:3` |
| 2 | **El estado JSON duplica el historial completo** (`LastOutput`) y se reescribe entero en cada movimiento (~150 KB) | `ProteccionHistorial.ps1:181` |
| 3 | **Fail-closed en el monitor:** si una escritura se corta, `Assert-LockerNoPending` aborta el monitor **cada minuto y en silencio** hasta que alguien ejecute `-RecuperarTransaccion`. Con 8 cortes de luz en 5 semanas, es el modo de fallo que costó 19 días en agosto | `MonitoreoLockerTiempoReal.ps1` v2.5 |
| 4 | **Mutex sin espera** (`WaitOne(0)`): dos ejecuciones solapadas y la segunda muere. El `ExecutionTimeLimit` está en 15 min porque las hay largas | `Enter-LockerLock` |
| 5 | **Un evento repetido bloquea el monitor** (`throw "Evento ya registrado"`) en vez de deduplicar. El marcador ya ha retrocedido varias veces en la historia del proyecto | `Save-LockerAutomaticMovements` |
| 6 | **`$ErrorActionPreference='Stop'` global** en un script construido a base de fallbacks tolerantes | `MonitoreoLockerTiempoReal.ps1` v2.5 |
| 7 | **Nada probado contra el CSV real ni contra SQL.** Las 23 pruebas son sintéticas, en carpetas temporales (lo reconoce él mismo) | `tests/` |

## El criterio de la decisión

El sistema pasaba de 5 scripts a 6, con estado persistente, transacciones, journal y mutex,
para proteger ediciones manuales en un sistema que registra ~10 movimientos al día, cuya
reconstrucción se lanza a mano y casi nunca, y que mantiene **una sola persona** por TeamViewer
con el Bloc de notas.

Dato que fija el tamaño real del problema: **la reconstrucción semanal llevaba desde el 20/05
sin funcionar y nadie lo notó**, porque no hacía falta.

La solución adoptada cubre lo mismo que se pedía —que las ediciones a mano no se pierdan— en
**unas 40 líneas dentro de un script que no corre solo**, sin estado nuevo, sin mutex y **sin
tocar `MonitoreoLockerTiempoReal.ps1`**, que es el único componente cuyo fallo no se puede
recuperar después.

## Qué hay aquí

- `ProteccionHistorial.ps1` — el motor propuesto (194 líneas)
- `tests/` — sus pruebas (23 de correcciones + 10 de respaldo)
- `DESPLIEGUE_CORRECCIONES.md` — su guía de despliegue
- `VerificarEntrega.ps1`, `SHA256.json`, `LOCKER_CORRECCIONES_2026-09-08.zip` — su paquete

Fuera de esta carpeta se conservan, por útiles:
- `RESPALDO_ANTES_CODEX_2026-09-08/` — respaldo verificado del estado previo
- `RespaldarLockerAntesCambios.ps1` — respalda scripts y datos del locker antes de un cambio
- `RESULTS.jsonl` — ledger de resultados
