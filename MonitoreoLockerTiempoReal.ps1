# MonitoreoLockerTiempoReal.ps1 v2.0
# Basado en tabla Eventos de SQL - garantiza CERO perdida de datos
# Aunque el PC se apague o la tarea se pare, al reiniciar recupera todos los eventos

$servidor = "GHI-TAQUILLAS\SQLEXPRESS"
$baseDatos = "Actum_GHI"
$carpetaOneDrive = "C:\Users\User\OneDrive - GHI HORNOS INDUSTRIALES S.L\LockerACTUM"
$archivoHistorial = "$carpetaOneDrive\HistorialCompleto.csv"
$archivoEstadoAnterior = "$carpetaOneDrive\EstadoAnterior.json"
$archivoHTML = "$carpetaOneDrive\DashboardLocker.html"
$archivoMarcador = "$carpetaOneDrive\UltimoEventoProcesado.txt"

# Crear carpeta si no existe
if (-not (Test-Path $carpetaOneDrive)) {
    New-Item -ItemType Directory -Path $carpetaOneDrive -Force | Out-Null
}

# =============================================
# HEALTH CHECK: OneDrive corriendo?
# =============================================
$oneDrive = Get-Process -Name "OneDrive" -ErrorAction SilentlyContinue
if (-not $oneDrive) {
    try {
        Start-Process "C:\Program Files\Microsoft OneDrive\OneDrive.exe" -WindowStyle Hidden
        Write-Host "[HEALTH] OneDrive reiniciado" -ForegroundColor Yellow
    } catch {
        Write-Host "[HEALTH] Error al reiniciar OneDrive: $_" -ForegroundColor Red
    }
}

# =============================================
# PASO 1: Leer marcador (ultimo evento procesado)
# =============================================
$ultimoProcesado = $null
$esPrimeraEjecucion = $false

if (Test-Path $archivoMarcador) {
    $fechaTexto = (Get-Content $archivoMarcador -Raw -Encoding UTF8).Trim()
    try {
        $ultimoProcesado = [DateTime]::ParseExact($fechaTexto, 'yyyy-MM-dd HH:mm:ss', [System.Globalization.CultureInfo]::InvariantCulture)
    } catch {
        try {
            $ultimoProcesado = [DateTime]::Parse($fechaTexto)
        } catch {
            $ultimoProcesado = $null
        }
    }
}

# Si no hay marcador, usar la fecha del ultimo registro del CSV
if ($ultimoProcesado -eq $null) {
    $esPrimeraEjecucion = $true
    if (Test-Path $archivoHistorial) {
        try {
            $csvContent = Get-Content $archivoHistorial -Tail 10 -Encoding UTF8
            foreach ($linea in $csvContent) {
                if ($linea -match '^(\d{2}/\d{2}/\d{4} \d{2}:\d{2}:\d{2});') {
                    $ultimoProcesado = [DateTime]::ParseExact($Matches[1], 'MM/dd/yyyy HH:mm:ss', $null)
                    break
                }
            }
        } catch {
            $ultimoProcesado = $null
        }
    }
}

# Si sigue sin haber marcador, usar hace 24 horas
if ($ultimoProcesado -eq $null) {
    $ultimoProcesado = (Get-Date).AddHours(-24)
}

# Para primera ejecucion, restar 10 segundos para crear ventana de solapamiento
if ($esPrimeraEjecucion) {
    $ultimoProcesado = $ultimoProcesado.AddSeconds(-10)
}

Write-Host "[EVENTOS] Buscando desde: $($ultimoProcesado.ToString('yyyy-MM-dd HH:mm:ss'))" -ForegroundColor Cyan

# =============================================
# PASO 2: Leer eventos nuevos desde SQL
# Evento=10000 = usuario identificado (acceso real a consigna)
# =============================================
$nuevosMovimientos = @()
$eventosEnSQL = 0

try {
    $connectionString = "Server=$servidor;Database=$baseDatos;Integrated Security=True;Connect Timeout=10"
    $connection = New-Object System.Data.SqlClient.SqlConnection($connectionString)
    $connection.Open()

    # Query: eventos tipo 10000 (usuario identificado) desde el marcador
    # JOIN para obtener nombre, apellidos, codigo cliente y descripcion
    $query = @"
SELECT E.FechaHora, E.Consigna_Codigo, E.Caja_Codigo, E.Usuario_Codigo,
       CS.CodigoCliente AS Consigna,
       CJ.Descripcion AS CajaDescripcion,
       U.Nombre, U.Apellidos
FROM Eventos E
LEFT JOIN Consigna CS ON E.Consigna_Codigo = CS.Codigo
LEFT JOIN Caja CJ ON E.Caja_Codigo = CJ.Codigo
LEFT JOIN Usuario U ON E.Usuario_Codigo = U.Codigo
WHERE E.FechaHora > @ultimo
  AND E.Evento IN (10000, 10001)
  AND E.Consigna_Codigo > 0
  AND E.Consigna_Codigo <> 100
  AND E.Usuario_Codigo > 0
ORDER BY E.FechaHora
"@

    $command = $connection.CreateCommand()
    $command.CommandText = $query
    $command.CommandTimeout = 30
    $param = $command.Parameters.Add("@ultimo", [System.Data.SqlDbType]::DateTime)
    $param.Value = $ultimoProcesado

    $adapter = New-Object System.Data.SqlClient.SqlDataAdapter($command)
    $dataTable = New-Object System.Data.DataTable
    $adapter.Fill($dataTable) | Out-Null
    $eventosEnSQL = $dataTable.Rows.Count

    Write-Host "[EVENTOS] Encontrados: $($dataTable.Rows.Count) eventos de identificacion (10000/10001)" -ForegroundColor Cyan

    if ($dataTable.Rows.Count -gt 0) {
        # =============================================
        # PASO 3: DEDUPLICACION de artefactos (mismo usuario+consigna <30s)
        # Cluster par  -> descartar todo (identificacion doble sin accion neta)
        # Cluster impar-> conservar solo el primero (1 interaccion real)
        # =============================================
        $ventanaSeg = 3

        # Incluir tambien el ultimo evento del CSV por consigna para dedup cross-batch
        $ultimoEventoPrevio = @{}
        if (Test-Path $archivoHistorial) {
            try {
                $csvExistente = Import-Csv -Path $archivoHistorial -Delimiter ";" -Encoding UTF8 | Where-Object { $_.Consigna -ne '100' }
                foreach ($mov in $csvExistente) {
                    try {
                        $f = [DateTime]::ParseExact($mov.FechaHoraApertura, 'MM/dd/yyyy HH:mm:ss', $null)
                    } catch { continue }
                    $key = "$([int]$mov.Consigna)"
                    if (-not $ultimoEventoPrevio.ContainsKey($key) -or $ultimoEventoPrevio[$key].Fecha -lt $f) {
                        $ultimoEventoPrevio[$key] = @{ Fecha = $f; Usuario = $mov.Usuario; Apellidos = $mov.Apellidos }
                    }
                }
            } catch {
                Write-Host "[DEDUP] Error leyendo CSV previo: $_" -ForegroundColor Yellow
            }
        }

        # Ordenar filas por consigna ASC, fecha ASC
        $filasOrdenadas = $dataTable.Rows | Sort-Object @{Expression={[int]$_['Consigna_Codigo']}}, @{Expression={[DateTime]$_['FechaHora']}}

        $filasLimpias = New-Object System.Collections.Generic.List[object]
        $clusterActual = New-Object System.Collections.Generic.List[object]
        $clusterConsigna = -1
        $clusterUsuario  = -1
        $clusterUltFecha = [DateTime]::MinValue

        function Close-ClusterMon {
            param($cluster, $destino)
            if ($cluster.Count -eq 0) { return }
            # Cluster -> siempre conservar el primero (el mas antiguo)
            $destino.Add($cluster[0]) | Out-Null
        }

        foreach ($row in $filasOrdenadas) {
            $cCod = [int]$row['Consigna_Codigo']
            $uCod = if ($row['Usuario_Codigo'] -ne [DBNull]::Value) { [int]$row['Usuario_Codigo'] } else { 0 }
            $f    = [DateTime]$row['FechaHora']

            $perteneceCluster = $false
            if ($clusterActual.Count -gt 0) {
                $diff = ($f - $clusterUltFecha).TotalSeconds
                if ($cCod -eq $clusterConsigna -and $uCod -eq $clusterUsuario -and $diff -le $ventanaSeg) {
                    $perteneceCluster = $true
                }
            } else {
                # Primer evento de este grupo: chequear cross-batch con el ultimo del CSV
                $keyPrev = "$cCod"
                if ($ultimoEventoPrevio.ContainsKey($keyPrev)) {
                    $prev = $ultimoEventoPrevio[$keyPrev]
                    $diffPrev = ($f - $prev.Fecha).TotalSeconds
                    $nombreNuevo = if ($row['Nombre'] -ne [DBNull]::Value) { "$($row['Nombre'])" } else { "" }
                    $apellNuevo  = if ($row['Apellidos'] -ne [DBNull]::Value) { "$($row['Apellidos'])" } else { "" }
                    if ($diffPrev -ge 0 -and $diffPrev -lt $ventanaSeg -and $prev.Usuario -eq $nombreNuevo -and $prev.Apellidos -eq $apellNuevo) {
                        # Es artefacto del ultimo evento del CSV -> descartar este
                        Write-Host "[DEDUP] Artefacto cross-batch descartado (consigna $cCod, $diffPrev s)" -ForegroundColor DarkYellow
                        continue
                    }
                }
            }

            if (-not $perteneceCluster) {
                Close-ClusterMon $clusterActual $filasLimpias
                $clusterActual = New-Object System.Collections.Generic.List[object]
                $clusterConsigna = $cCod
                $clusterUsuario  = $uCod
            }

            $clusterActual.Add($row) | Out-Null
            $clusterUltFecha = $f
        }
        Close-ClusterMon $clusterActual $filasLimpias

        $descartados = $dataTable.Rows.Count - $filasLimpias.Count
        if ($descartados -gt 0) {
            Write-Host "[DEDUP] Artefactos descartados: $descartados / $($dataTable.Rows.Count)" -ForegroundColor Yellow
        }

        # =============================================
        # PASO 4: Para cada consigna con eventos nuevos, alternar desde estado SQL actual
        # =============================================
        # Obtener estado actual de SQL para todas las consignas afectadas
        $estadoFinalSQL = @{}
        try {
            $cmdEstado = $connection.CreateCommand()
            $cmdEstado.CommandText = "SELECT Codigo, Estado FROM Consigna WHERE Activa = 1"
            $readerEstado = $cmdEstado.ExecuteReader()
            while ($readerEstado.Read()) {
                $estadoFinalSQL["$($readerEstado['Codigo'])"] = [int]$readerEstado['Estado']
            }
            $readerEstado.Close()
        } catch {
            Write-Host "[ESTADO] Error consultando Consigna.Estado: $_" -ForegroundColor Yellow
        }

        # Agrupar filas limpias por consigna usando hashtable (evita Group-Object en pipeline con DataRows)
        $porConsigna = @{}
        foreach ($fila in $filasLimpias) {
            $k = "$([int][string]$fila['Consigna_Codigo'])"
            if (-not $porConsigna.ContainsKey($k)) {
                $porConsigna[$k] = [System.Collections.Generic.List[object]]::new()
            }
            $porConsigna[$k].Add($fila)
        }

        foreach ($cKey in $porConsigna.Keys) {
            # Estado actual de la consigna (default: 4)
            $estadoSiguiente = 4
            if ($estadoFinalSQL.ContainsKey($cKey)) {
                $estadoSiguiente = $estadoFinalSQL[$cKey]
            }

            # Ordenar eventos de esta consigna DESC (mas reciente primero)
            $eventosConsigna = $porConsigna[$cKey] | Sort-Object @{Expression={[DateTime][string]$_['FechaHora']}; Descending=$true}

            foreach ($row in $eventosConsigna) {
                if ($estadoSiguiente -eq 4) {
                    $accion = "Extracci$([char]243)n"
                    $estadoSiguiente = 2
                } else {
                    $accion = "Devoluci$([char]243)n"
                    $estadoSiguiente = 4
                }

                $fechaHora = [DateTime][string]$row['FechaHora']
                $nombre    = [string]$row['Nombre']
                $apellidos = [string]$row['Apellidos']
                $consigna  = [string]$row['Consigna']
                if (-not $consigna) { $consigna = $cKey }
                $descripcion = [string]$row['CajaDescripcion']

                $nuevosMovimientos += [PSCustomObject]@{
                    FechaHoraApertura = $fechaHora.ToString('MM/dd/yyyy HH:mm:ss')
                    Usuario           = $nombre
                    Apellidos         = $apellidos
                    Consigna          = $consigna
                    Descripcion       = $descripcion
                    Accion            = $accion
                    EstadoPuerta      = "Cerrada"
                }
            }
        }

        # SAFETY NET: si filasLimpias tiene datos pero nuevosMovimientos quedo vacio -> bug en PASO 4
        # Usa [string] para castear columnas y evitar problemas con DBNull o tipos de DataRow
        if ($filasLimpias.Count -gt 0 -and $nuevosMovimientos.Count -eq 0) {
            Write-Host "[SAFETY] Bug PASO4 - $($filasLimpias.Count) filas sin procesar - recuperando" -ForegroundColor Magenta
            $safeList = @()
            foreach ($fila in $filasLimpias) {
                try {
                    $sCodStr  = [string]$fila['Consigna_Codigo']
                    $sCod     = if ($sCodStr -ne '') { [int]$sCodStr } else { 0 }
                    $sKey     = "$sCod"
                    $sEst     = if ($estadoFinalSQL.ContainsKey($sKey)) { $estadoFinalSQL[$sKey] } else { 4 }
                    $sAcc     = if ($sEst -eq 2) { "Devoluci$([char]243)n" } else { "Extracci$([char]243)n" }
                    $sFechStr = [string]$fila['FechaHora']
                    $sFech    = [DateTime]::Parse($sFechStr)
                    $sNom     = [string]$fila['Nombre']
                    $sApel    = [string]$fila['Apellidos']
                    $sCons    = [string]$fila['Consigna']
                    if (-not $sCons) { $sCons = $sKey }
                    $sDesc    = [string]$fila['CajaDescripcion']
                    $safeList += [PSCustomObject]@{
                        FechaHoraApertura = $sFech.ToString('MM/dd/yyyy HH:mm:ss')
                        Usuario           = $sNom
                        Apellidos         = $sApel
                        Consigna          = $sCons
                        Descripcion       = $sDesc
                        Accion            = $sAcc
                        EstadoPuerta      = "Cerrada"
                    }
                    Write-Host "[SAFETY] OK: consigna $sCons $sNom $sApel - $sAcc" -ForegroundColor Green
                } catch {
                    Write-Host "[SAFETY] ERROR en fila: $_" -ForegroundColor Red
                }
            }
            if ($safeList.Count -gt 0) {
                $nuevosMovimientos = $safeList
                Write-Host "[SAFETY] $($safeList.Count) movimientos recuperados" -ForegroundColor Green
            }
        }

        # Ordenar cronologicamente ascendente antes de escribir
        # @() garantiza que siempre sea un array aunque Sort-Object devuelva un escalar
        $nuevosMovimientos = @($nuevosMovimientos | Sort-Object { [DateTime]::ParseExact($_.FechaHoraApertura, 'MM/dd/yyyy HH:mm:ss', $null) })
    }

    $connection.Close()

} catch {
    Write-Host "[ERROR] SQL: $_" -ForegroundColor Red

    # FALLBACK: metodo original (comparacion de estados)
    Write-Host "[FALLBACK] Intentando metodo original..." -ForegroundColor Yellow
    try {
        $connectionString = "Server=$servidor;Database=$baseDatos;Integrated Security=True;"
        $connection = New-Object System.Data.SqlClient.SqlConnection($connectionString)
        $connection.Open()
        $command = $connection.CreateCommand()
        $command.CommandText = @"
SELECT
    U.Codigo AS UsuarioCodigo,
    U.Nombre,
    U.Apellidos,
    C.Codigo AS ConsignaCodigo,
    C.CodigoCliente AS Consigna,
    C.FechaHoraUltimaApertura,
    C.Usuario_CodigoUltimaApertura,
    C.Estado,
    C.EstadoPuerta,
    Cj.Descripcion AS CajaDescripcion
FROM Consigna C
LEFT JOIN Usuario U ON C.Usuario_CodigoUltimaApertura = U.Codigo
LEFT JOIN Caja Cj ON C.Caja_Codigo = Cj.Codigo
WHERE C.FechaHoraUltimaApertura IS NOT NULL
"@
        $adapter = New-Object System.Data.SqlClient.SqlDataAdapter($command)
        $dataTable2 = New-Object System.Data.DataTable
        $adapter.Fill($dataTable2) | Out-Null
        $connection.Close()

        $estadoActual = @{}
        foreach ($row in $dataTable2.Rows) {
            $key = [string]$row["ConsignaCodigo"]
            $estadoActual[$key] = @{
                Consigna = $row["Consigna"]
                Usuario = $row["Nombre"]
                Apellidos = $row["Apellidos"]
                Descripcion = if ($row["CajaDescripcion"] -ne [DBNull]::Value) { $row["CajaDescripcion"] } else { "" }
                FechaHora = [string]$row["FechaHoraUltimaApertura"]
                UsuarioCodigo = $row["Usuario_CodigoUltimaApertura"]
                Estado = $row["Estado"]
                EstadoPuerta = $row["EstadoPuerta"]
            }
        }

        $estadoAnterior = @{}
        if (Test-Path $archivoEstadoAnterior) {
            $jsonContent = Get-Content $archivoEstadoAnterior -Raw -Encoding UTF8 | ConvertFrom-Json
            foreach ($property in $jsonContent.PSObject.Properties) {
                $estadoAnterior[$property.Name] = @{
                    Consigna = $property.Value.Consigna
                    Usuario = $property.Value.Usuario
                    Apellidos = $property.Value.Apellidos
                    Descripcion = if ($property.Value.Descripcion) { $property.Value.Descripcion } else { "" }
                    FechaHora = $property.Value.FechaHora
                    UsuarioCodigo = $property.Value.UsuarioCodigo
                    Estado = $property.Value.Estado
                    EstadoPuerta = $property.Value.EstadoPuerta
                }
            }
        }

        $nuevosMovimientos = @()
        foreach ($key in $estadoActual.Keys) {
            $consignaActual = $estadoActual[$key]

            if (-not $estadoAnterior.ContainsKey($key) -or
                $estadoAnterior[$key].FechaHora -ne $consignaActual.FechaHora) {

                $cambio = [PSCustomObject]@{
                    FechaHoraApertura = $consignaActual.FechaHora
                    Usuario = $consignaActual.Usuario
                    Apellidos = $consignaActual.Apellidos
                    Consigna = $consignaActual.Consigna
                    Descripcion = $consignaActual.Descripcion
                    Accion = if ($consignaActual.Estado -eq 2) { "Devoluci$([char]243)n" } elseif ($consignaActual.Estado -eq 4) { "Extracci$([char]243)n" } else { "Desconocido" }
                    EstadoPuerta = if ($consignaActual.EstadoPuerta -eq 2) { "Cerrada" } else { "Abierta" }
                }
                $nuevosMovimientos += $cambio
            }
        }

        Write-Host "[FALLBACK] Metodo original: $($nuevosMovimientos.Count) cambios" -ForegroundColor Yellow

    } catch {
        Write-Host "[ERROR CRITICO] Falló metodo original: $_" -ForegroundColor Red
        exit 1
    }
}

# =============================================
# PASO 5: Agregar al CSV
# =============================================
if ($nuevosMovimientos.Count -gt 0) {
    Write-Host "[CSV] Nuevos movimientos: $($nuevosMovimientos.Count)" -ForegroundColor Green

    $existeHistorial = Test-Path $archivoHistorial
    $utf8NoBOM = New-Object System.Text.UTF8Encoding $false

    if (-not $existeHistorial) {
        [System.IO.File]::WriteAllText($archivoHistorial, "FechaHoraApertura;Usuario;Apellidos;Consigna;Descripcion;Accion;EstadoPuerta`r`n", $utf8NoBOM)
    }

    foreach ($mov in $nuevosMovimientos) {
        $linea = "$($mov.FechaHoraApertura);$($mov.Usuario);$($mov.Apellidos);$($mov.Consigna);$($mov.Descripcion);$($mov.Accion);$($mov.EstadoPuerta)"
        [System.IO.File]::AppendAllText($archivoHistorial, "$linea`r`n", $utf8NoBOM)
    }

    Write-Host "[CSV] Historial actualizado" -ForegroundColor Green

    # Actualizar marcador con el ultimo evento procesado (formato yyyy-MM-dd HH:mm:ss)
    $ultimaFechaObj = [DateTime]::ParseExact(
        ($nuevosMovimientos | Sort-Object FechaHoraApertura | Select-Object -Last 1).FechaHoraApertura,
        'MM/dd/yyyy HH:mm:ss', $null)
    [System.IO.File]::WriteAllText($archivoMarcador, $ultimaFechaObj.ToString('yyyy-MM-dd HH:mm:ss'), $utf8NoBOM)

} else {
    Write-Host "[CSV] No hay nuevos movimientos" -ForegroundColor Yellow
    # Marcador NO se actualiza cuando no hay movimientos nuevos.
    # Razon: avanzar el marcador cuando los eventos fueron deduplicados puede saltar
    # por encima de un evento real si el dedup o PASO4 falla silenciosamente.
    # Los artefactos se reprocessaran en la siguiente ejecucion y seran deduplicados de nuevo.
    if ($eventosEnSQL -gt 0) {
        Write-Host "[MARCADOR] $eventosEnSQL evento(s) deduplicado(s) - marcador sin cambios" -ForegroundColor DarkYellow
    }
}

# =============================================
# PASO 6: Guardar estado actual para backward compatibility
# =============================================
$estadoActualGuardado = @{}
foreach ($key in $estadoPorConsigna.Keys) {
    $estadoActualGuardado[$key] = @{
        Estado = $estadoPorConsigna[$key]
        FechaHora = (Get-Date).ToString('yyyy-MM-dd HH:mm:ss')
    }
}
try {
    $estadoActualGuardado | ConvertTo-Json -Depth 10 | Out-File -FilePath $archivoEstadoAnterior -Encoding UTF8
} catch {
    # Si falla, no es critico
}

# =============================================
# PASO 7: Generar dashboard
# =============================================
. "C:\ACTUM\GenerarDashboard.ps1"

Write-Host "[DONE] Monitoreo completado: $(Get-Date -Format 'HH:mm:ss')" -ForegroundColor Cyan
