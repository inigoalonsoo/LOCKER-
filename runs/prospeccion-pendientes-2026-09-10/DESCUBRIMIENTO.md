---
kind: finding
subject: pendientes-operativos-locker
date: 2026-09-10
verdict: "6 leads, cobertura 6/6 · 4 tareas futuras · 0 intermedios · 0 desbloqueadas · 0 listas-para-OK · 0 siguen-bloq nuevas · 2 anotaciones · 0 descartados"
supersedes: null
---

# Prospeccion · pendientes operativos del locker

**Frontera** — IN: flujo SQL -> CSV/marcador -> dashboards/OneDrive, documentacion vigente y datos
sincronizados. OUT: calibraciones, alerta externa, SAI/cuadro y cualquier cambio en produccion.
**Mecanismos:** M2 on-hold, M4 declarado-real, M5 river-trace. No aplicados: M1, porque el codigo no
usa un backlog SATD consistente; M3, porque las tres tareas inmediatas ya tienen prerrequisito conocido;
M6, porque no hubo un cambio nuevo que analizar; M7, reservado para cuando se construya un gate nuevo.

## 0 · Inventario previo

| Fuente | Que habia | Conteo |
|---|---|---:|
| `CLAUDE.md:31-41` | 3 tareas fisicas + 1 mejora software + 1 deuda de infraestructura | 5 |
| `RESULTS.jsonl` | resultados antes de esta prospeccion | 8 |
| Bus | no existe `AGENT_BUS.jsonl` en este repo | 0 |
| Gates visibles | banner Admin con 4 comprobaciones + auditor manual | 5 |

## 1 · Leads y materialidad

| id | mecanismo | anclaje | materia | severidad | destino |
|---|---|---|---|---|---|
| L1 | M5 | `locker/MonitoreoLockerTiempoReal.ps1:407-440,620-629` | `EstadoAnterior.json`: 11 B y `{}` frente a 32 consignas | rompe solo si falla Eventos | T1 futura |
| L2 | M5/M4 | `locker/GenerarDashboard.ps1:6-21`; `GenerarDashboardAdmin.ps1:10-22` | 2 auto-updates copian y ejecutan sin hash/sintaxis/ASCII/backup | degrada | T2 futura |
| L3 | M5/M4 | `locker/AuditarDashboard.ps1`; `MonitoreoLockerTiempoReal.ps1:633-638` | 1 auditor de 32 consignas, 0 llamadas desde el monitor | degrada | T3 futura |
| L4 | M5 | `GenerarDashboard.ps1:692-704`; `GenerarDashboardAdmin.ps1:1270-1281` | 2 HTML, 249959 B y 127134 B, escritos directamente | degrada | T4 futura |
| L5 | M2/M4 | `CLAUDE.md:984-997`; CSV vivo `:532-534` | 3 de 4 instrumentos antiguos ya devueltos | pulido | A1 |
| L6 | M4 | `README.md:143-164` | 1 bloque conserva el problema antiguo de ventana/tarea | pulido | A2 |

## 2 · Re-verificacion propia

- **L1 confirmado:** el PASO 6 itera `$estadoPorConsigna.Keys`, variable no definida en el flujo actual,
  y el sujeto sincronizado contiene solo `{}`. El fallback lee ese fichero como baseline vacio.
- **L2 confirmado:** ambos scripts comparan timestamps, hacen `Copy-Item -Force`, ejecutan el destino y
  salen; no hay comprobacion intermedia.
- **L3 confirmado:** el flujo automatico llama a `GenerarDashboard.ps1`, no a `AuditarDashboard.ps1`.
- **L4 confirmado:** ambos finales usan `WriteAllText` directamente sobre el HTML publicado.
- **L5 confirmado:** CSV vivo contiene devoluciones del 09/09 para M-017, L-005 y T-008; L-004 sigue
  extraido desde el 14/05.

## 3 · Destinos propuestos

### Tareas futuras

- **T1 · Probar y reparar el fallback sin Eventos.** BASELINE: estado persistido `0/32`; DONE: prueba
  hermetica fuerza fallo de Eventos y produce 0 movimientos falsos conservando 32 estados. No tocar el
  monitor sin cumplir su regla dura.
- **T2 · Retirar o poner gate al auto-update.** BASELINE: 2/2 vias sin validacion; DONE: 0 copias ejecutables
  sin staging, sintaxis, ASCII, hash/backup y swap, o auto-update eliminado por decision de Inigo.
- **T3 · Decidir si el auditor entra en rutina.** BASELINE: 0 callers automaticos; DONE: decision documentada;
  si entra, debe informar divergencias sin bloquear captura.
- **T4 · Escritura atomica de dashboards.** BASELINE: 2/2 escrituras directas; DONE: 2/2 generan temporal,
  validan contenido minimo y reemplazan el destino.

### Anotaciones

- **A1:** corregir el bloque historico de cuatro instrumentos: 3 ya devueltos; solo L-004 sigue abierto.
- **A2:** marcar como historico el bloque obsoleto de tareas/ventana en README.

## 4 · Pendientes ya conocidos y re-medidos

- `L-004`: sigue extraido desde 14/05/2026; falta pegatina y devolucion identificada en consigna 9.
- `E-002`: ultima devolucion 16/12/2025; requiere abrir consigna 31 y leer la serie fisica.
- `D-001`: ultima extraccion 01/04/2026; la serie ya esta puesta y solo falta localizarlo.
- `Consigna.Usuario_Codigo`: desbloqueada, pero opcional; afecta potencialmente a 32 instrumentos.
- OneDrive + `fabricacion1`: sincronizacion fresca hoy, deuda a largo plazo por caducidad cada 42-50 dias.

## 5 · Verdict

Seis leads nuevos, seis con destino. Ninguno autoriza un cambio en produccion. Punto ciego residual: no se
forzo un fallo real de SQL ni un corte electrico. Los tres mecanismos coincidieron en que las tres acciones
inmediatas siguen siendo fisicas; los cuatro hallazgos de software deben tratarse como futuro hasta que
Inigo elija uno.
