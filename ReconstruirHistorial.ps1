# ReconstruirHistorial.ps1
# Reconstruye HistorialCompleto.csv desde la tabla Eventos de SQL
# Usa el estado actual de Consigna.Estado como fuente de verdad.
#
# Algoritmo: para cada consigna, tomar su estado actual y recorrer sus eventos
# del mas reciente al mas antiguo asignando acciones alternadas (Extraccion/Devolucion).
# Esto garantiza que el ULTIMO movimiento de cada consigna coincida con la realidad de SQL.

$servidor = "GHI-TAQUILLAS\SQLEXPRESS"
$baseDatos = "Actum_GHI"
$carpetaOneDrive = "C:\Users\User\OneDrive - GHI HORNOS INDUSTRIALES S.L\LockerACTUM"
$archivoHistorial = "$carpetaOneDrive\HistorialCompleto.csv"
$archivoMarcador  = "$carpetaOneDrive\UltimoEventoProcesado.txt"

Write-Host "[RECONSTRUCCION] Iniciando..." -ForegroundColor Cyan

# ----------------------------------------------------------------------
# 1. Consultar todos los eventos tipo 10000 + estado actual de su consigna
# ----------------------------------------------------------------------
$connectionString = "Server=$servidor;Database=$baseDatos;Integrated Security=True;Connect Timeout=30"
$connection = New-Object System.Data.SqlClient.SqlConnection($connectionString)
$connection.Open()

$query = @"
SELECT E.FechaHora, E.Consigna_Codigo, E.Caja_Codigo, E.Usuario_Codigo,
       CS.CodigoCliente AS Consigna,
       CS.Estado AS EstadoActual,
       CJ.Descripcion AS CajaDescripcion,
       U.Nombre, U.Apellidos
FROM Eventos E
INNER JOIN Consigna CS ON E.Consigna_Codigo = CS.Codigo
LEFT JOIN Caja CJ ON E.Caja_Codigo = CJ.Codigo
LEFT JOIN Usuario U ON E.Usuario_Codigo = U.Codigo
WHERE E.Evento IN (10000, 10001)
  AND E.Consigna_Codigo > 0
  AND E.Consigna_Codigo <> 100
  AND CS.Activa = 1
ORDER BY E.Consigna_Codigo ASC, E.FechaHora DESC
"@

$command = $connection.CreateCommand()
$command.CommandText = $query
$command.CommandTimeout = 120

$adapter = New-Object System.Data.SqlClient.SqlDataAdapter($command)
$dt = New-Object System.Data.DataTable
$adapter.Fill($dt) | Out-Null
$connection.Close()

Write-Host "[RECONSTRUCCION] Eventos de identificacion (10000/10001) encontrados: $($dt.Rows.Count)" -ForegroundColor Cyan

# ----------------------------------------------------------------------
# 2. DEDUPLICACION por clusters
#    Un "cluster" = eventos consecutivos misma consigna+usuario separados < 30s.
#    Cluster par  -> artefacto (identificacion doble), eliminar todos.
#    Cluster impar-> conservar solo el primero (1 interaccion real).
# ----------------------------------------------------------------------
$ventanaSegundos = 60

# Primero reordenar a fecha ascendente dentro de cada consigna para agrupar correctamente
$filasOrdenadas = $dt.Rows | Sort-Object @{Expression={[int]$_['Consigna_Codigo']}}, @{Expression={[DateTime]$_['FechaHora']}}

$filasLimpias = New-Object System.Collections.Generic.List[object]
$clusterActual = New-Object System.Collections.Generic.List[object]
$clusterConsigna = -1
$clusterUsuario  = -1
$clusterUltFecha = [DateTime]::MinValue

function Close-Cluster {
    param($cluster, $destino)
    if ($cluster.Count -eq 0) { return }
    # Cluster de 1 -> conservar unico evento
    # Cluster de 2+ -> conservar solo el primero (el mas antiguo) como representante
    $destino.Add($cluster[0]) | Out-Null
}

foreach ($row in $filasOrdenadas) {
    $consigna = [int]$row['Consigna_Codigo']
    $usuario  = if ($row['Usuario_Codigo'] -ne [DBNull]::Value) { [int]$row['Usuario_Codigo'] } else { 0 }
    $fecha    = [DateTime]$row['FechaHora']

    $perteneceCluster = $false
    if ($clusterActual.Count -gt 0) {
        $diff = ($fecha - $clusterUltFecha).TotalSeconds
        if ($consigna -eq $clusterConsigna -and $usuario -eq $clusterUsuario -and $diff -le $ventanaSegundos) {
            $perteneceCluster = $true
        }
    }

    if (-not $perteneceCluster) {
        Close-Cluster $clusterActual $filasLimpias
        $clusterActual = New-Object System.Collections.Generic.List[object]
        $clusterConsigna = $consigna
        $clusterUsuario  = $usuario
    }

    $clusterActual.Add($row) | Out-Null
    $clusterUltFecha = $fecha
}
Close-Cluster $clusterActual $filasLimpias

$descartados = $dt.Rows.Count - $filasLimpias.Count
Write-Host "[DEDUP] Artefactos descartados: $descartados" -ForegroundColor Yellow
Write-Host "[DEDUP] Eventos limpios: $($filasLimpias.Count)" -ForegroundColor Cyan

# ----------------------------------------------------------------------
# 3. Procesar por consigna (fecha DESC dentro de cada consigna)
#    Partir del estado actual y alternar hacia atras.
# ----------------------------------------------------------------------
# Reordenar: consigna ASC, fecha DESC
$filasProcesar = $filasLimpias | Sort-Object @{Expression={[int]$_['Consigna_Codigo']}}, @{Expression={[DateTime]$_['FechaHora']}; Descending=$true}

$movimientos = New-Object System.Collections.Generic.List[PSObject]
$consignaActualKey = $null
$estadoSiguiente = 0

foreach ($row in $filasProcesar) {
    $consignaCod = "$($row['Consigna_Codigo'])"

    if ($consignaCod -ne $consignaActualKey) {
        # Nueva consigna -> iniciar con estado actual de SQL
        $consignaActualKey = $consignaCod
        $estadoSiguiente = [int]$row['EstadoActual']
    }

    # La accion del evento actual es la que produjo el estado "estadoSiguiente"
    if ($estadoSiguiente -eq 4) {
        $accion = "Extracci$([char]243)n"
        $estadoSiguiente = 2  # Antes de este evento, el estado era Libre
    } else {
        $accion = "Devoluci$([char]243)n"
        $estadoSiguiente = 4  # Antes de este evento, el estado era Ocupada
    }

    $fechaHora   = [DateTime]$row['FechaHora']
    $nombre      = if ($row['Nombre']    -ne [DBNull]::Value) { "$($row['Nombre'])" }    else { "" }
    $apellidos   = if ($row['Apellidos'] -ne [DBNull]::Value) { "$($row['Apellidos'])" } else { "" }
    $consCliente = if ($row['Consigna']  -ne [DBNull]::Value) { "$($row['Consigna'])" }  else { $consignaCod }
    $descripcion = if ($row['CajaDescripcion'] -ne [DBNull]::Value) { "$($row['CajaDescripcion'])" } else { "" }

    $movimientos.Add([PSCustomObject]@{
        FechaRaw          = $fechaHora
        FechaHoraApertura = $fechaHora.ToString('MM/dd/yyyy HH:mm:ss')
        Usuario           = $nombre
        Apellidos         = $apellidos
        Consigna          = $consCliente
        Descripcion       = $descripcion
        Accion            = $accion
        EstadoPuerta      = "Cerrada"
    }) | Out-Null
}

Write-Host "[RECONSTRUCCION] Movimientos procesados: $($movimientos.Count)" -ForegroundColor Cyan

# ----------------------------------------------------------------------
# 3. Ordenar todo por fecha ascendente y escribir el CSV
# ----------------------------------------------------------------------
$movimientosOrdenados = $movimientos | Sort-Object FechaRaw

$utf8NoBOM = New-Object System.Text.UTF8Encoding $false
$sb = New-Object System.Text.StringBuilder
[void]$sb.AppendLine("FechaHoraApertura;Usuario;Apellidos;Consigna;Descripcion;Accion;EstadoPuerta")
foreach ($mov in $movimientosOrdenados) {
    [void]$sb.AppendLine("$($mov.FechaHoraApertura);$($mov.Usuario);$($mov.Apellidos);$($mov.Consigna);$($mov.Descripcion);$($mov.Accion);$($mov.EstadoPuerta)")
}
[System.IO.File]::WriteAllText($archivoHistorial, $sb.ToString(), $utf8NoBOM)

Write-Host "[RECONSTRUCCION] CSV escrito: $archivoHistorial" -ForegroundColor Green

# ----------------------------------------------------------------------
# 4. Actualizar marcador con la fecha del ultimo evento procesado
# ----------------------------------------------------------------------
if ($movimientosOrdenados.Count -gt 0) {
    $ultimo = ($movimientosOrdenados | Select-Object -Last 1).FechaRaw
    [System.IO.File]::WriteAllText($archivoMarcador, $ultimo.ToString('yyyy-MM-dd HH:mm:ss'), $utf8NoBOM)
    Write-Host "[RECONSTRUCCION] Marcador: $($ultimo.ToString('yyyy-MM-dd HH:mm:ss'))" -ForegroundColor Green
}

# ----------------------------------------------------------------------
# 5. Resumen: cuantas consignas quedan marcadas como "En uso" tras reconstruccion
# ----------------------------------------------------------------------
$ultimoPorConsigna = $movimientosOrdenados |
    Group-Object Consigna |
    ForEach-Object { $_.Group | Sort-Object FechaRaw -Descending | Select-Object -First 1 }

$enUso = $ultimoPorConsigna | Where-Object { $_.Accion -like '*Extracci*' } | Sort-Object { [int]$_.Consigna }

Write-Host ""
Write-Host "[RESUMEN] Consignas 'En uso' segun CSV reconstruido:" -ForegroundColor Yellow
$enUso | Select-Object Consigna, Usuario, Apellidos, Descripcion | Format-Table -AutoSize

Write-Host "[DONE] Reconstruccion completada" -ForegroundColor Cyan
Write-Host "Siguiente paso: ejecutar 'C:\ACTUM\GenerarDashboard.ps1' para regenerar el HTML" -ForegroundColor Yellow
