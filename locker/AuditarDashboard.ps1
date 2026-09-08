# AuditarDashboard.ps1 - creado 2026-09-08
#
# Comprueba que lo que muestra DashboardLocker.html es VERDAD.
# SOLO LECTURA: no escribe, no borra, no modifica nada. Se puede lanzar cuando sea.
#
# Por que hace falta: la pestana "Estado Instrumentos" NO lee el estado de SQL.
# GenerarDashboard.ps1:174-181 lo deriva de la ULTIMA ACCION DEL CSV
# (Extraccion -> En uso, Devolucion -> Disponible). De SQL solo saca la descripcion
# del instrumento. Si el CSV esta mal, el dashboard MIENTE y nada lo delata.
# La unica prueba real es comparar contra Consigna.Estado, que es lo que dice el hardware.
#
# Uso en el locker:   cd C:\ACTUM ;  .\AuditarDashboard.ps1

$carpeta = "C:\Users\User\OneDrive - GHI HORNOS INDUSTRIALES S.L\LockerACTUM"
$csv     = "$carpeta\HistorialCompleto.csv"
$html    = "$carpeta\DashboardLocker.html"
$servidor = "GHI-TAQUILLAS\SQLEXPRESS"
$baseDatos = "Actum_GHI"

Write-Host ""
Write-Host "=== 1. INTEGRIDAD DEL CSV ===" -ForegroundColor Cyan

$bytes = [System.IO.File]::ReadAllBytes($csv)
$nulos = 0
foreach ($b in $bytes) { if ($b -eq 0) { $nulos++ } }

$lineas = [System.IO.File]::ReadAllLines($csv)
$uni = [System.Collections.Generic.HashSet[string]]::new()
foreach ($x in $lineas) { [void]$uni.Add($x) }
$ratio = [math]::Round($lineas.Count / [math]::Max($uni.Count,1), 2)

$txt = [System.IO.File]::ReadAllText($csv)
$mojibake = ([regex]::Matches($txt, [string][char]0xC3)).Count
$reemplazo = ([regex]::Matches($txt, [string][char]0xFFFD)).Count

Write-Host ("  Lineas: {0}   Unicas: {1}   Duplicadas exactas: {2}   Ratio: {3}" -f $lineas.Count, $uni.Count, ($lineas.Count - $uni.Count), $ratio)
Write-Host ("  Bytes NULL (senal de apagon durante escritura): {0}" -f $nulos)
Write-Host ("  Mojibake: {0}   Caracter de reemplazo: {1}" -f $mojibake, $reemplazo)

$mov = Import-Csv $csv -Delimiter ';' -Encoding UTF8
$fechas = New-Object System.Collections.Generic.List[datetime]
$malas = 0
foreach ($m in $mov) {
    try { $fechas.Add([DateTime]::ParseExact($m.FechaHoraApertura, 'MM/dd/yyyy HH:mm:ss', $null)) } catch { $malas++ }
}
$ord = $fechas | Sort-Object
Write-Host ("  Movimientos: {0}   Fechas ilegibles: {1}" -f $mov.Count, $malas)
Write-Host ("  Rango real: {0}  ->  {1}" -f $ord[0].ToString('dd/MM/yyyy HH:mm:ss'), $ord[-1].ToString('dd/MM/yyyy HH:mm:ss'))
Write-Host ("  Consigna 100 (sistema, se filtra): {0}" -f @($mov | Where-Object { $_.Consigna -eq '100' }).Count)
$acc = ($mov | Group-Object Accion | ForEach-Object { $_.Name + '=' + $_.Count }) -join '   '
Write-Host ("  Acciones: {0}" -f $acc)

# Veredicto de la parte 1
$ok1 = ($nulos -eq 0 -and $malas -eq 0 -and $ratio -lt 1.05)
if ($ok1) { Write-Host "  --> CSV SANO" -ForegroundColor Green }
else       { Write-Host "  --> CSV CON PROBLEMAS - revisar arriba" -ForegroundColor Red }

Write-Host ""
Write-Host "=== 2. EL HTML GENERADO ===" -ForegroundColor Cyan

$h = [System.IO.File]::ReadAllText($html)
$item = Get-Item $html
$noAscii = ([regex]::Matches($h, '[^\x00-\x7F]')).Count
$filas   = ([regex]::Matches($h, '<tr>')).Count
$enUso   = ([regex]::Matches($h, 'badge badge-en-uso')).Count
$dispo   = ([regex]::Matches($h, 'badge badge-disponible')).Count

Write-Host ("  Bytes: {0}   Generado: {1}" -f $item.Length, $item.LastWriteTime)
Write-Host ("  Filas <tr>: {0}   En uso: {1}   Disponible: {2}" -f $filas, $enUso, $dispo)
Write-Host ("  No-ASCII (debe ser 0): {0}" -f $noAscii)
if ($noAscii -eq 0) { Write-Host "  --> ENCODING CORRECTO" -ForegroundColor Green }
else                { Write-Host "  --> HAY CARACTERES SIN CONVERTIR" -ForegroundColor Red }

Write-Host ""
Write-Host "=== 3. LO QUE DICE EL DASHBOARD vs LO QUE DICE EL HARDWARE (SQL) ===" -ForegroundColor Cyan

# Estado segun el CSV, replicando exactamente la logica de GenerarDashboard.ps1
$porConsigna = @{}
foreach ($m in $mov) {
    if ($m.Consigna -eq '100') { continue }
    try { $f = [DateTime]::ParseExact($m.FechaHoraApertura, 'MM/dd/yyyy HH:mm:ss', $null) } catch { continue }
    $k = "$([int]$m.Consigna)"
    if (-not $porConsigna.ContainsKey($k) -or $f -gt $porConsigna[$k].F) {
        $est = if ($m.Accion -like '*Extracci*') { 'En uso' } elseif ($m.Accion -like '*Devoluci*') { 'Disponible' } else { 'Desconocido' }
        $porConsigna[$k] = [PSCustomObject]@{
            F = $f
            Estado = $est
            Usuario = ("$($m.Usuario) $($m.Apellidos)").Trim()
        }
    }
}

$q = "SET NOCOUNT ON; SELECT C.CodigoCliente, C.Estado, ISNULL(U.Nombre,'') + ' ' + ISNULL(U.Apellidos,'') FROM Consigna C LEFT JOIN Usuario U ON C.Usuario_Codigo = U.Codigo WHERE C.Activa = 1"
$filasSql = sqlcmd -S $servidor -d $baseDatos -E -W -s"|" -h-1 -Q $q

$res = @()
foreach ($f in $filasSql) {
    $p = $f -split '\|'
    if ($p.Count -lt 3) { continue }
    try { $k = "$([int]($p[0].Trim()))" } catch { continue }
    $eSql = switch ($p[1].Trim()) { '4' { 'En uso' } '2' { 'Disponible' } default { "Estado=$($p[1].Trim())" } }
    $eDash = if ($porConsigna.ContainsKey($k)) { $porConsigna[$k].Estado } else { 'NO APARECE' }
    $uDash = if ($porConsigna.ContainsKey($k)) { $porConsigna[$k].Usuario } else { '' }
    $res += [PSCustomObject]@{
        Consigna    = [int]$k
        SQL         = $eSql
        Dashboard   = $eDash
        UsuarioSQL  = $p[2].Trim()
        UsuarioDash = $uDash
        Veredicto   = if ($eSql -eq $eDash) { 'OK' } else { '*** DISCREPA ***' }
    }
}

$res | Sort-Object Consigna | Format-Table -AutoSize

$nOk = @($res | Where-Object { $_.Veredicto -eq 'OK' }).Count
$nNo = @($res | Where-Object { $_.Veredicto -ne 'OK' }).Count
Write-Host ("RESUMEN: {0} coinciden / {1} discrepan / {2} consignas activas" -f $nOk, $nNo, $res.Count)
if ($nNo -eq 0) { Write-Host "--> EL DASHBOARD DICE LA VERDAD" -ForegroundColor Green }
else            { Write-Host "--> HAY CONSIGNAS DONDE EL DASHBOARD NO COINCIDE CON EL HARDWARE" -ForegroundColor Yellow }

Write-Host ""
Write-Host "Nota: una discrepancia NO siempre es un bug. Si alguien asigno una consigna desde el" -ForegroundColor DarkGray
Write-Host "ACTUM EPI Visor sin abrir el locker fisicamente, eso NO genera evento y el CSV no se entera." -ForegroundColor DarkGray
Write-Host "Es la limitacion conocida de las asignaciones administrativas." -ForegroundColor DarkGray
Write-Host ""
