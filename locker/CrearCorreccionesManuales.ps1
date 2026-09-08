# CrearCorreccionesManuales.ps1 - creado 2026-09-08
#
# Crea solo si no existe el fichero CorreccionesManuales.csv con las correcciones hechas a mano
# que NO existen en la tabla Eventos de SQL.
#
# POR QUE EXISTE ESTE FICHERO
# ---------------------------
# Una asignacion hecha desde el ACTUM EPI Visor SIN abrir el locker fisicamente no genera
# ningun evento en SQL. Para que el dashboard refleje la realidad hay que escribir esas
# lineas a mano en el historial. Pero ReconstruirHistorial.ps1 tira el CSV y lo rehace
# desde Eventos, asi que esas lineas se perdian en cada reconstruccion.
#
# Desde el 08/09/2026 viven aqui, separadas:
#   CorreccionesManuales.csv  -> lo que decide la persona. NO se regenera. Se conserva.
#   HistorialCompleto.csv     -> lo que dice SQL. Regenerable, desechable.
#
# ReconstruirHistorial.ps1 las reaplica SIEMPRE (paso 2.5).
#
# COMO ANADIR UNA CORRECCION NUEVA
# --------------------------------
# Editar directamente C:\Users\User\OneDrive...\LockerACTUM\CorreccionesManuales.csv.
# Formato:  FechaHoraApertura;Usuario;Apellidos;Consigna;Descripcion;Accion;EstadoPuerta;Motivo
#   - La fecha va en MM/dd/yyyy HH:mm:ss (formato americano, igual que el historial)
#   - La columna Motivo NO se copia al historial: solo documenta por que se hizo
#   - Para cambiar de usuario una consigna hacen falta DOS lineas: la Devolucion del
#     usuario equivocado y, unos segundos despues, la Extraccion del correcto
#   - NUNCA escribir tildes literales aqui: usar [char]0xF3 como se hace abajo
#
# Uso:  cd C:\ACTUM ; .\CrearCorreccionesManuales.ps1

$carpeta = "C:\Users\User\OneDrive - GHI HORNOS INDUSTRIALES S.L\LockerACTUM"
$destino = "$carpeta\CorreccionesManuales.csv"

# Si el fichero YA EXISTE no se toca: es la fuente de verdad de lo que decide la persona.
# (mejora aportada por la revision de Codex del 08/09: antes se rehacia y perdia lo anadido a mano)
if (Test-Path -LiteralPath $destino) {
    $existentes = @(Import-Csv -Path $destino -Delimiter ";" -Encoding UTF8)
    $malas = 0
    foreach ($c in $existentes) {
        try { [void][DateTime]::ParseExact($c.FechaHoraApertura, 'MM/dd/yyyy HH:mm:ss', $null) } catch { $malas++ }
    }
    Write-Host ""
    Write-Host "Ya existe: $($existentes.Count) correcciones. NO se toca ni un byte." -ForegroundColor Yellow
    $existentes | Select-Object FechaHoraApertura, Usuario, Apellidos, Consigna, Accion | Format-Table -AutoSize
    if ($malas -eq 0) { Write-Host "Todas las fechas son legibles - OK" -ForegroundColor Green }
    else              { Write-Host "$malas fechas ILEGIBLES - corregir a mano en el fichero" -ForegroundColor Red }
    Write-Host ""
    Write-Host "Para anadir una correccion: editar el CSV directamente (ver cabecera de este script)." -ForegroundColor Cyan
    Write-Host ""
    exit
}

$dev = "Devoluci" + [char]0xF3 + "n"
$ext = "Extracci" + [char]0xF3 + "n"

$motivo18 = "2026-06-10 Asignacion administrativa: la consigna 18 la tenia SERGIO V. VEGA, no IKER L. LASSO. Hecha desde ACTUM EPI Visor sin abrir el locker, no existe en Eventos."
$motivo22 = "2026-06-10 Asignacion administrativa: la consigna 22 la tenia SERGIO V. VEGA, no IKER L. LASSO. Hecha desde ACTUM EPI Visor sin abrir el locker, no existe en Eventos. PENDIENTE de confirmacion fisica."

$lineas = @(
    "FechaHoraApertura;Usuario;Apellidos;Consigna;Descripcion;Accion;EstadoPuerta;Motivo",
    "04/16/2026 11:53:00;IKER L.;LASSO;18;MedidorLaserpuntoderocio / DP510 / 45174428;$dev;Cerrada;$motivo18",
    "04/16/2026 11:53:30;SERGIO V.;VEGA;18;MedidorLaserpuntoderocio / DP510 / 45174428;$ext;Cerrada;$motivo18",
    "04/16/2026 12:44:30;IKER L.;LASSO;22;An.gases / TESTO 340 / 63862113;$dev;Cerrada;$motivo22",
    "04/16/2026 12:45:00;SERGIO V.;VEGA;22;An.gases / TESTO 340 / 63862113;$ext;Cerrada;$motivo22"
)

$utf8NoBOM = New-Object System.Text.UTF8Encoding $false
[System.IO.File]::WriteAllText($destino, ($lineas -join "`r`n") + "`r`n", $utf8NoBOM)

Write-Host ""
Write-Host "Escrito: $destino" -ForegroundColor Green

# Verificacion sobre el fichero, no sobre la intencion
$comprobar = Import-Csv -Path $destino -Delimiter ";" -Encoding UTF8
Write-Host "Correcciones guardadas: $($comprobar.Count)" -ForegroundColor Green
$comprobar | Select-Object FechaHoraApertura, Usuario, Apellidos, Consigna, Accion | Format-Table -AutoSize

$malas = 0
foreach ($c in $comprobar) {
    try { [void][DateTime]::ParseExact($c.FechaHoraApertura, 'MM/dd/yyyy HH:mm:ss', $null) } catch { $malas++ }
}
if ($malas -eq 0) { Write-Host "Todas las fechas son legibles - OK" -ForegroundColor Green }
else              { Write-Host "$malas fechas ILEGIBLES - corregir antes de reconstruir" -ForegroundColor Red }

Write-Host ""
Write-Host "A partir de ahora ReconstruirHistorial.ps1 las reaplica en cada reconstruccion." -ForegroundColor Cyan
Write-Host "Este fichero NO se regenera solo: es la fuente de verdad de lo que se corrige a mano." -ForegroundColor Cyan
Write-Host ""
