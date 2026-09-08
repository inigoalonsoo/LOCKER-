# Respaldo anterior a los cambios de Codex ? 08/09/2026

Punto de partida: commit bd8cf4d4124f5d75bdeaa7130d068ffcc1e86961, 08/09/2026 10:34:01 +02:00.
Al iniciar el trabajo de Codex, git status --short no mostraba cambios; HEAD sigue en ese commit.
El respaldo se ha creado despu?s de los cambios, recuperando la versi?n anterior conservada en Git.
No se ha restaurado ni cambiado ning?n script actual al crear este respaldo.

## Contenido

- ESTADO_ANTES_CODEX.zip: los 67 archivos versionados completos de aquel commit, en repositorio_antes/.
- ORIGINALES/: copia accesible de los 4 archivos que Codex modific?: CLAUDE.md,
  CrearCorreccionesManuales.ps1, MonitoreoLockerTiempoReal.ps1 y ReconstruirHistorial.ps1.
- MANIFIESTO.json: commit de origen, tama?os, SHA-256 y listado de archivos a?adidos posteriormente.
- CAMBIOS_CODEX.patch: diferencias de los archivos versionados, para poder revisar qu? cambi?.

El ZIP tambi?n contiene este documento, el manifiesto y el parche. Los originales est?n dentro de
repositorio_antes/ y tambi?n separados en ORIGINALES/ al lado del ZIP para facilitar su uso.
Los archivos se obtuvieron de los blobs originales de Git. Este equipo usa core.autocrlf=true:
los saltos de l?nea del archivo en disco anterior pod?an ser CRLF y los del respaldo son los can?nicos
conservados por Git. Se conserva el contenido del punto de partida, no una imagen completa del disco.

## Qu? hab?a antes

- El monitor era v2.4.
- ReconstruirHistorial.ps1 incorporaba CorreccionesManuales.csv, pero no proteg?a cambios directos
  ni borrados de HistorialCompleto.csv; ante correcciones inv?lidas pod?a continuar sin aplicarlas.
- CrearCorreccionesManuales.ps1 reescrib?a las 4 correcciones iniciales, guardando una copia previa.
- No exist?an ProteccionHistorial.ps1, ProteccionHistorial.json ni el nuevo mecanismo de transacci?n.
- CLAUDE.md conten?a el traspaso dejado por Claude, antes de las anotaciones de Codex.

## Para volver al c?digo anterior en desarrollo

1. Guardar primero otra copia del estado que haya en ese momento, especialmente si se han hecho m?s cambios.
2. Copiar los 4 archivos de ORIGINALES/ sobre los equivalentes de la ra?z del proyecto.
3. Los archivos nuevos de Codex est?n enumerados en MANIFIESTO.json. Pueden conservarse como evidencia
   o apartarse a otra carpeta; los scripts antiguos no utilizan ProteccionHistorial.ps1.
4. No hace falta borrar masivamente, ejecutar git reset --hard ni cambiar de commit.

Si se necesita otro archivo antiguo, est? dentro de repositorio_antes/ en el ZIP.
No extraer todo el ZIP encima del proyecto a ciegas: revisar qu? se quiere recuperar.

## L?mite importante: el ordenador del locker

Codex no ha desplegado sus cambios en GHI-TAQUILLAS. Este respaldo cubre el proyecto de desarrollo.
No contiene una copia actual de C:\ACTUM ni del historial, marcador o correcciones del locker.
Los ficheros de muestra del proyecto, si los hubiera, NO deben usarse para restaurar datos de producci?n.

Antes de cualquier despliegue futuro, guardar tambi?n los scripts existentes de C:\ACTUM y los datos
actuales de LockerACTUM en el propio locker. Si despu?s se quisiera volver atr?s en producci?n, pausar
el monitor y revisar conjuntamente la versi?n del c?digo y sus datos. No sobrescribir el historial con
una copia antigua que descarte movimientos registrados desde entonces.
