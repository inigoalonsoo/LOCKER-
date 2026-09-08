---
kind: implementation
subject: conservar-correcciones-manuales-locker
date: 2026-09-08
verdict: validacion-local; pendiente-despliegue-y-prueba-real
supersedes: apartado-N-CLAUDE-proteccion-parcial
---

La protección está preparada en desarrollo. No está desplegada en GHI-TAQUILLAS.
Los resultados locales están en `tests/resultado.json`; el estado anterior fallaba los 5 casos
de `tests/baseline.json`. Los datos de prueba son sintéticos; no son los datos del locker.

## Qué conserva

- Altas, cambios de cualquier campo y borrados hechos en `HistorialCompleto.csv`.
- Correcciones guardadas en `CorreccionesManuales.csv`, que el inicializador ya no reemplaza.
- Borrados de movimientos nuevos que haya añadido el monitor después de activar la protección.

La clave de un movimiento es fecha/hora al segundo y consigna. Cambiarla equivale a borrar la anterior
y añadir la nueva. Dos filas con la misma clave bloquean la operación: no se elige una a ciegas.
CSV válido: delimitador `;`, UTF-8, fechas `MM/dd/yyyy HH:mm:ss`, las 7 columnas existentes;
`CorreccionesManuales.csv` admite además `Motivo`. Se admiten campos entrecomillados, tildes y punto y coma
dentro de un campo. Fechas, acciones, consignas o CSV inválidos detienen la escritura.

`ProteccionHistorial.json` recuerda las modificaciones y los borrados. Es un fichero de datos permanente:
no editarlo, borrarlo ni regenerarlo. La edición directa del historial prevalece sobre SQL y sobre
una corrección antigua de la misma clave. Para cambiar esa decisión, editar la fila del historial de nuevo.
Los cambios del CSV no cambian la asignación dentro de ACTUM ni el contenido de SQL.

## Entrega y primera activación

Se necesitan JUNTOS estos 4 ficheros en `C:\ACTUM\`:

1. `ProteccionHistorial.ps1` (nuevo soporte común).
2. `ReconstruirHistorial.ps1`.
3. `CrearCorreccionesManuales.ps1`.
4. `MonitoreoLockerTiempoReal.ps1` (v2.5).

No cambiar los VBS, las rutas de las tareas ni los generadores de dashboard.
Mantener `ReconstruirCSVSemanal` desactivada.

En el locker, PowerShell **como administrador**, pausar únicamente el monitor antes de copiar.
El wrapper VBS termina antes que PowerShell: el estado de la tarea por sí solo no prueba que el script haya acabado.

```powershell
Disable-ScheduledTask -TaskName 'MonitoreoLockerTiempoReal'
Get-CimInstance Win32_Process | Where-Object {
    $_.Name -eq 'powershell.exe' -and $_.CommandLine -match '(?i)-File\s+"?C:\\ACTUM\\MonitoreoLockerTiempoReal\.ps1'
} | Select-Object ProcessId, CommandLine
```

Esperar a que ese listado quede vacío. Si sigue apareciendo, no copiar todavía ni matar el proceso a ciegas.
Conservar copia de los 3 scripts antiguos en una carpeta fechada. Copiar los 4 nuevos por el flujo habitual
de TeamViewer/Notepad; el soporte común primero y el monitor al final. El ZIP contiene también
`VerificarEntrega.ps1` y `SHA256.json`: si se transfieren, ejecutar `VerificarEntrega.ps1 -ScriptFolder C:\ACTUM`
desde la carpeta del paquete. La verificación compara contenido normalizando solo CRLF/LF y BOM, y comprueba
sintaxis y ASCII. Así una diferencia de saltos de línea al pegar no produce un falso fallo de contenido.

Primero, ejecutar SOLO la previsualización:

```powershell
cd C:\ACTUM
.\ReconstruirHistorial.ps1 -AdoptarHistorialActual
```

No escribe datos. Muestra filas actuales/propuestas, correcciones conservadas, claves de borrado y marcador.
**Compartir esa salida antes de aplicar**, para contrastarla con los datos reales. En la primera adopción,
las filas ausentes anteriores al marcador se consideran borradas intencionadamente. El sistema no puede
saber si una ausencia antigua era una decisión humana o un fallo histórico. No adoptar un historial averiado.
Los movimientos de SQL posteriores al marcador se consideran nuevos y se recuperan.

Cuando se haya revisado la salida, la escritura se hace con:

```powershell
.\ReconstruirHistorial.ps1 -AdoptarHistorialActual -Aplicar
```

No hace falta ejecutar `CrearCorreccionesManuales.ps1` si el CSV de correcciones ya existe.
Si se ejecuta, valida y conserva sus bytes; solo crea las 4 correcciones iniciales cuando no existe.

Verificar después:

```powershell
.\ReconstruirHistorial.ps1
.\GenerarDashboard.ps1
.\AuditarDashboard.ps1
```

La segunda previsualización debe mantener las correcciones y borrados revisados. `AuditarDashboard.ps1`
compara estado con SQL: una discrepancia intencional puede ser precisamente la corrección manual.
La auditoría antigua no valida el usuario; comprobar también el nombre en el dashboard para las consignas corregidas.
Reanudar el monitor solo con esa lectura revisada:

```powershell
Enable-ScheduledTask -TaskName 'MonitoreoLockerTiempoReal'
```

Queda la prueba real de extraer/devolver un instrumento: 1 movimiento por acción, usuario correcto,
marcador avanzado y dashboard actualizado. Esa prueba no se ha realizado desde desarrollo.

## Ediciones siguientes

Pausar el monitor y esperar a que termine antes de abrir el CSV. Editar, guardar en UTF-8 con `;` y cerrar
el editor antes de reanudar. No editar desde dos equipos ni mientras se ejecuta una reconstrucción.
El bloqueo compartido coordina nuestros scripts; no bloquea Excel ni una sincronización externa de OneDrive.

No hay que copiar cada cambio a otro fichero: la siguiente reconstrucción reconoce las diferencias.
Los movimientos posteriores del monitor conservan esos cambios pendientes. Para comprobarlos inmediatamente,
ejecutar `ReconstruirHistorial.ps1` sin parámetros (solo previsualiza); para materializar, añadir `-Aplicar`.
No volver a pasar `-AdoptarHistorialActual` una vez creado el estado de protección.

## Si se corta la escritura

Cada operación que escribe datos guarda una copia previa en `LockerACTUM\BackupsCorrecciones\<fecha-id>\`.
También deja allí los archivos nuevos preparados. No se borran automáticamente esos backups.
Se crea `ReconstruccionPendiente.json` antes de reemplazar archivos; el monitor se detiene si lo encuentra.

```powershell
cd C:\ACTUM
.\ReconstruirHistorial.ps1 -RecuperarTransaccion
```

Esta recuperación completa la operación preparada, verifica sus hashes y retira el aviso pendiente.
No necesita SQL. Si alguien ha editado un archivo después del corte, se niega a sobrescribirlo:
conservar los archivos y revisar junto con las copias de `BackupsCorrecciones`, sin borrar el aviso a mano.
Una pérdida/corrupción del estado de protección requiere restaurar su copia; no reinicializar para sortear el error.

## Alcance de la comprobación local

Las pruebas ejecutan el código real de lectura, combinación y escritura sobre carpetas temporales. Incluyen
dos reconstrucciones consecutivas, altas del monitor, borrados, cambios de fecha, datos inválidos, CSV entrecomillado,
previsualización sin escrituras, tres cortes entre archivos, recuperación y exclusión entre dos procesos.
La prueba del comando completo sustituye únicamente la consulta SQL por una tabla sintética.
El algoritmo histórico que infiere acciones/deduplica eventos no se ha rediseñado aquí.
El despliegue, SQL real, permisos de la cuenta User y sincronización de OneDrive quedan pendientes de comprobar en el locker.
