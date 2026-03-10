# Script para generar Dashboard HTML del Locker
$carpetaUser = "C:\Users\User\OneDrive - GHI HORNOS INDUSTRIALES S.L\LockerACTUM"
$carpetaDesarrollo = "c:\Users\ialopez\OneDrive - GHI HORNOS INDUSTRIALES S.L\Antigravity\GHI"
$carpetaACTUM = "C:\ACTUM"

if (Test-Path $carpetaUser) {
    $carpetaOneDrive = $carpetaUser
} else {
    $carpetaOneDrive = $carpetaDesarrollo
}

$archivoHistorial = "$carpetaOneDrive\HistorialCompleto.csv"
$archivoHTML = "$carpetaOneDrive\DashboardLocker.html"

# Leer logo en base64 (embebido como data URI para compatibilidad OneDrive)
$logoBase64 = ''
$logoBase64Paths = @("$carpetaACTUM\logo_base64.txt", "$carpetaOneDrive\logo_base64.txt")
foreach ($p in $logoBase64Paths) {
    if (Test-Path $p) { $logoBase64 = (Get-Content $p -Raw).Trim(); break }
}

# =============================================
# PASO 1: Leer datos de instrumentos desde SQL (tabla Caja)
# Fallback: EXPORT_Cajas.txt si SQL no disponible
# Caja.Codigo = numero de consigna (clave de enlace)
# =============================================
$mapaCajas = @{} # clave: Codigo -> {CodigoCliente, Descripcion, FechaCaducidad}

try {
    $connStr = "Server=GHI-TAQUILLAS\SQLEXPRESS;Database=Actum_GHI;Integrated Security=True;Connect Timeout=5"
    $conn = New-Object System.Data.SqlClient.SqlConnection $connStr
    $conn.Open()
    $cmd = $conn.CreateCommand()
    $cmd.CommandText = "SELECT Codigo, CodigoCliente, Descripcion, FechaCaducidad FROM Caja"
    $reader = $cmd.ExecuteReader()
    while ($reader.Read()) {
        $codigo = "$([int]$reader['Codigo'])"
        $fechaCad = if ($reader['FechaCaducidad'] -ne [DBNull]::Value) { [DateTime]$reader['FechaCaducidad'] } else { $null }
        $mapaCajas[$codigo] = @{
            CodigoCliente  = "$($reader['CodigoCliente'])"
            Descripcion    = "$($reader['Descripcion'])"
            FechaCaducidad = $fechaCad
        }
    }
    $reader.Close()
    $conn.Close()
} catch {
    # Fallback a EXPORT_Cajas.txt si SQL no disponible
    $exportCajasPath = "$carpetaACTUM\EXPORT_Cajas.txt"
    if (Test-Path $exportCajasPath) {
        $lineas = Get-Content $exportCajasPath -Encoding UTF8
        $enSeccion1 = $false
        foreach ($linea in $lineas) {
            if ($linea -match '^Codigo,CodigoCliente,Descripcion') { $enSeccion1 = $true; continue }
            if ($linea -match '^Codigo,CodigoCliente,Bloque')      { $enSeccion1 = $false; continue }
            if ($linea -match '^-' -or [string]::IsNullOrWhiteSpace($linea)) { continue }
            if ($enSeccion1) {
                $campos = $linea -split ','
                if ($campos.Count -ge 3) {
                    $codigo = "$([int]$campos[0].Trim())"
                    $mapaCajas[$codigo] = @{
                        CodigoCliente  = $campos[1].Trim()
                        Descripcion    = $campos[2].Trim()
                        FechaCaducidad = $null
                    }
                }
            }
        }
    }
}

# =============================================
# PASO 2: Leer historial y calcular estado
# =============================================
$estadoInstrumentos = @()
$historial = @()
$hoy = Get-Date

if (Test-Path $archivoHistorial) {
    $historial = Import-Csv -Path $archivoHistorial -Delimiter ";" -Encoding UTF8
}

if ($historial.Count -gt 0) {
    $historialFiltrado = $historial | Where-Object { $_.Consigna -ne '100' }
    $ultimaAccionPorConsigna = $historialFiltrado |
        Sort-Object { [DateTime]::ParseExact($_.FechaHoraApertura, 'MM/dd/yyyy HH:mm:ss', $null) } -Descending |
        Group-Object Consigna |
        ForEach-Object { $_.Group | Select-Object -First 1 }

    foreach ($mov in $ultimaAccionPorConsigna) {
        $estado = if ($mov.Accion -like '*Extracci*') { 'En uso' } elseif ($mov.Accion -like '*Devoluci*') { 'Disponible' } else { 'Desconocido' }
        $nombreCompleto = ("$($mov.Usuario) $($mov.Apellidos)").Trim()
        $usuarioActual = if ($estado -eq 'En uso' -and $nombreCompleto -ne '') { $nombreCompleto } else { '' }

        $consignaKey = "$([int]$mov.Consigna)"
        $cajaInfo = if ($mapaCajas.ContainsKey($consignaKey)) { $mapaCajas[$consignaKey] } else { @{ CodigoCliente = ''; Descripcion = $mov.Descripcion; FechaCaducidad = $null } }

        $fechaCadTexto = ''
        $estadoCalibracion = ''
        if ($cajaInfo.FechaCaducidad -ne $null) {
            $fechaCadTexto = $cajaInfo.FechaCaducidad.ToString('dd/MM/yyyy')
            $estadoCalibracion = if ($cajaInfo.FechaCaducidad -lt $hoy) { 'CADUCADO' } else { 'CALIBRADO' }
        }

        $estadoInstrumentos += [PSCustomObject]@{
            NumConsigna       = $mov.Consigna
            Instrumento       = $cajaInfo.Descripcion
            CodigoCaja        = $cajaInfo.CodigoCliente
            Estado            = $estado
            UsuarioActual     = $usuarioActual
            FechaCaducidad    = $fechaCadTexto
            EstadoCalibracion = $estadoCalibracion
        }
    }
}

$totalMovimientos = ($historial | Where-Object { $_.Consigna -ne '100' }).Count
$totalInstrumentos = $estadoInstrumentos.Count
$instrumentosEnUso = ($estadoInstrumentos | Where-Object { $_.Estado -eq 'En uso' }).Count
$instrumentosDisponibles = ($estadoInstrumentos | Where-Object { $_.Estado -eq 'Disponible' }).Count
$instrumentosCaducados = ($estadoInstrumentos | Where-Object { $_.EstadoCalibracion -eq 'CADUCADO' }).Count
$ultimosMovimientos = $historial |
    Where-Object { $_.Consigna -ne '100' } |
    Sort-Object { [DateTime]::ParseExact($_.FechaHoraApertura, 'MM/dd/yyyy HH:mm:ss', $null) } -Descending |
    Group-Object FechaHoraApertura, Usuario, Consigna |
    ForEach-Object { $_.Group | Select-Object -First 1 }

# =============================================
# PASO 3: Generar HTML
# - Sin Google Fonts (CDN bloqueado en OneDrive web)
# - Tabs CSS puro sin JavaScript (compatible OneDrive web)
# =============================================
$html = @"
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>LOCKER INSTRUMENTACI&Oacute;N - GHI SMART FURNACES</title>
    <style>
        :root {
            --ghi-red: #C31E2E;
            --ghi-red-dark: #9B1825;
            --ghi-red-light: #E63946;
            --ghi-black: #0A0A0A;
            --ghi-white: #FFFFFF;
            --ghi-grey: #1A1A1A;
            --ghi-grey-medium: #2D2D2D;
            --ghi-grey-light: #404040;
            --ghi-text-light: #E0E0E0;
            --ghi-text-medium: #B0B0B0;
            --success: #10B981;
            --glass-bg: rgba(255, 255, 255, 0.05);
            --glass-border: rgba(255, 255, 255, 0.1);
        }

        * { margin: 0; padding: 0; box-sizing: border-box; }

        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', 'Helvetica Neue', Arial, sans-serif;
            background: linear-gradient(135deg, var(--ghi-black) 0%, var(--ghi-grey) 100%);
            color: var(--ghi-white);
            min-height: 100vh;
            padding: 20px;
        }

        .container { max-width: 1400px; margin: 0 auto; }

        /* HEADER */
        .header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 30px;
            padding: 25px 35px;
            background: var(--glass-bg);
            border: 1px solid var(--glass-border);
            border-radius: 16px;
            box-shadow: 0 4px 24px rgba(0, 0, 0, 0.2);
        }

        .logo-section { display: flex; align-items: center; gap: 24px; }

        .title-section h1 {
            font-size: 1.8em;
            font-weight: 800;
            color: var(--ghi-red);
            margin-bottom: 4px;
        }

        .title-section p { color: var(--ghi-text-medium); font-size: 0.95em; font-weight: 500; }

        .live-indicator {
            display: flex;
            align-items: center;
            gap: 10px;
            padding: 10px 18px;
            background: var(--glass-bg);
            border: 1px solid var(--glass-border);
            border-radius: 25px;
            color: var(--success);
            font-weight: 600;
        }

        .pulse-dot {
            width: 10px;
            height: 10px;
            background: var(--success);
            border-radius: 50%;
        }

        /* TABS - CSS puro sin JavaScript, compatible con OneDrive web */
        .tab-inputs { display: none; }

        .tabs-nav {
            display: flex;
            gap: 10px;
            margin-bottom: 30px;
            background: var(--glass-bg);
            border: 1px solid var(--glass-border);
            border-radius: 12px;
            padding: 8px;
        }

        .tab-label {
            flex: 1;
            padding: 14px 24px;
            background: transparent;
            color: var(--ghi-text-light);
            font-size: 1em;
            font-weight: 600;
            cursor: pointer;
            border-radius: 8px;
            text-align: center;
            display: block;
            user-select: none;
        }

        .tab-label:hover { background: var(--ghi-grey-light); }

        #tab-estado:checked ~ .tabs-nav label[for="tab-estado"],
        #tab-historial:checked ~ .tabs-nav label[for="tab-historial"] {
            background: var(--ghi-red);
            color: white;
            box-shadow: 0 4px 12px rgba(195, 30, 46, 0.4);
        }

        .tab-content { display: none; }
        #tab-estado:checked ~ .tab-content.content-estado { display: block; }
        #tab-historial:checked ~ .tab-content.content-historial { display: block; }

        /* STATS */
        .stats {
            display: grid;
            grid-template-columns: repeat(4, 1fr);
            gap: 20px;
            margin-bottom: 30px;
        }

        .stat-card {
            background: var(--glass-bg);
            border: 1px solid var(--glass-border);
            padding: 25px;
            border-radius: 16px;
            box-shadow: 0 4px 24px rgba(0, 0, 0, 0.2);
        }

        .stat-card h3 {
            color: var(--ghi-text-medium);
            font-size: 0.9em;
            font-weight: 600;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            margin-bottom: 12px;
        }

        .stat-card .number {
            font-size: 2.5em;
            font-weight: 800;
            color: var(--ghi-red);
            line-height: 1;
            margin-bottom: 8px;
        }

        .stat-card .label { color: var(--ghi-text-light); font-size: 0.85em; font-weight: 500; }

        /* TABLE */
        .table-container {
            background: var(--glass-bg);
            border: 1px solid var(--glass-border);
            padding: 35px;
            border-radius: 16px;
            box-shadow: 0 4px 24px rgba(0, 0, 0, 0.2);
            overflow: hidden;
        }

        .table-header { margin-bottom: 25px; }

        .table-header h2 {
            color: var(--ghi-white);
            font-weight: 700;
            font-size: 1.5em;
        }

        .table-wrapper { overflow-x: auto; border-radius: 12px; background: var(--ghi-grey-medium); }

        table { width: 100%; border-collapse: collapse; }

        thead {
            background: linear-gradient(135deg, var(--ghi-red-dark) 0%, var(--ghi-red) 100%);
            position: sticky;
            top: 0;
            z-index: 10;
        }

        th {
            padding: 16px 20px;
            text-align: left;
            font-weight: 700;
            font-size: 0.85em;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            color: white;
            border-bottom: 2px solid var(--ghi-red-light);
            white-space: nowrap;
        }

        tbody tr { border-bottom: 1px solid var(--glass-border); }
        tbody tr:nth-child(even) { background: rgba(255,255,255,0.02); }
        td { padding: 16px 20px; color: var(--ghi-text-light); font-size: 0.95em; }

        /* BADGES */
        .badge { display: inline-block; padding: 6px 12px; border-radius: 20px; font-size: 0.85em; font-weight: 600; }

        .badge-disponible {
            background: linear-gradient(135deg, #10B981 0%, #059669 100%);
            color: white;
            box-shadow: 0 4px 12px rgba(16, 185, 129, 0.3);
        }

        .badge-en-uso {
            background: linear-gradient(135deg, #EF4444 0%, #DC2626 100%);
            color: white;
            box-shadow: 0 4px 12px rgba(239, 68, 68, 0.3);
        }

        .badge-ocupada {
            display: inline-block;
            color: white;
            background: linear-gradient(135deg, #EF4444 0%, #DC2626 100%);
            padding: 8px 14px;
            border-radius: 20px;
            font-size: 0.8em;
            font-weight: 700;
            box-shadow: 0 4px 12px rgba(239, 68, 68, 0.3);
        }

        .badge-libre {
            display: inline-block;
            color: white;
            background: linear-gradient(135deg, #10B981 0%, #059669 100%);
            padding: 8px 14px;
            border-radius: 20px;
            font-size: 0.8em;
            font-weight: 700;
            box-shadow: 0 4px 12px rgba(16, 185, 129, 0.3);
        }

        .actualizado {
            text-align: center;
            margin-top: 30px;
            padding: 15px;
            color: var(--ghi-text-medium);
            font-size: 0.9em;
            background: var(--glass-bg);
            border-radius: 8px;
            border: 1px solid var(--glass-border);
        }

        ::-webkit-scrollbar { width: 10px; height: 10px; }
        ::-webkit-scrollbar-track { background: var(--ghi-grey-medium); border-radius: 5px; }
        ::-webkit-scrollbar-thumb { background: var(--ghi-red); border-radius: 5px; }
        ::-webkit-scrollbar-thumb:hover { background: var(--ghi-red-light); }

        /* =============================================
           RESPONSIVE - TABLET (<=768px)
           ============================================= */
        @media (max-width: 768px) {
            body { padding: 10px; }

            .header {
                flex-direction: column;
                align-items: flex-start;
                gap: 14px;
                padding: 18px 20px;
            }
            .title-section h1 { font-size: 1.3em; }
            .title-section p  { font-size: 0.85em; }

            .stats { grid-template-columns: repeat(2, 1fr); }

            .tabs-nav { flex-wrap: wrap; gap: 8px; }
            .tab-label { padding: 10px 16px; font-size: 0.9em; }

            table { font-size: 0.85em; }
        }

        /* =============================================
           RESPONSIVE - MOVIL (<=480px)
           ============================================= */
        @media (max-width: 480px) {
            body { padding: 8px; }

            .header { padding: 14px 14px; gap: 10px; }
            .title-section h1 { font-size: 1.1em; }
            .title-section p  { font-size: 0.8em; }

            .stats { grid-template-columns: 1fr; }

            .stat-card { padding: 18px; }
            .stat-card .number { font-size: 2.2em; }

            .tabs-nav { flex-direction: column; gap: 6px; }
            .tab-label { text-align: center; padding: 10px; font-size: 0.85em; }

            table { font-size: 0.8em; }
            td, th { padding: 8px 6px; }

            .badge, .badge-disponible, .badge-en-uso, .badge-ocupada, .badge-libre {
                font-size: 0.75em !important;
                padding: 5px 10px;
            }

            .live-indicator { font-size: 0.85em; padding: 8px 14px; }
            .actualizado { font-size: 0.8em; }
        }
    </style>
</head>
<body>
    <div class="container">

        <!-- HEADER -->
        <div class="header">
            <div class="logo-section">
                <div class="title-section">
                    <h1>GHI SMART FURNACES</h1>
                    <p>LOCKER INSTRUMENTACI&Oacute;N</p>
                </div>
            </div>
            <div class="live-indicator">
                <div class="pulse-dot"></div>
                <span>En vivo</span>
            </div>
        </div>

        <!-- TABS CSS PURO - funciona en OneDrive web sin JavaScript -->
        <input type="radio" class="tab-inputs" id="tab-estado" name="tabs" checked>
        <input type="radio" class="tab-inputs" id="tab-historial" name="tabs">

        <div class="tabs-nav">
            <label class="tab-label" for="tab-estado">Estado Instrumentos</label>
            <label class="tab-label" for="tab-historial">Historial Movimientos</label>
        </div>

        <!-- TAB 1: ESTADO -->
        <div class="tab-content content-estado">
            <div class="stats">
                <div class="stat-card">
                    <h3>Total Instrumentos</h3>
                    <div class="number">$totalInstrumentos</div>
                    <div class="label">Registrados en el sistema</div>
                </div>
                <div class="stat-card">
                    <h3>Disponibles</h3>
                    <div class="number">$instrumentosDisponibles</div>
                    <div class="label">Listos para usar</div>
                </div>
                <div class="stat-card">
                    <h3>En Uso</h3>
                    <div class="number">$instrumentosEnUso</div>
                    <div class="label">Actualmente asignados</div>
                </div>
                <div class="stat-card">
                    <h3>&Uacute;ltima Actualizaci&oacute;n</h3>
                    <div class="number" style="font-size: 2em;">$(Get-Date -Format 'HH:mm')</div>
                    <div class="label">Hora actual</div>
                </div>
            </div>
            <div class="table-container">
                <div class="table-header">
                    <h2>Estado Actual de Instrumentos</h2>
                </div>
                <div class="table-wrapper">
                    <table>
                        <thead>
                            <tr>
                                <th>Instrumento / Modelo / N&ordm; serie</th>
                                <th>N&ordm; Consigna</th>
                                <th>C&oacute;digo</th>
                                <th>Estado</th>
                            </tr>
                        </thead>
                        <tbody>
"@

foreach ($instrumento in $estadoInstrumentos) {
    if ($instrumento.Estado -eq 'En uso') {
        $estadoTexto = if ($instrumento.UsuarioActual.Trim() -ne '') { "En uso por $($instrumento.UsuarioActual)" } else { "En uso" }
    } else {
        $estadoTexto = "Disponible"
    }
    $badgeEstado = if ($instrumento.Estado -eq 'En uso') { 'badge-en-uso' } else { 'badge-disponible' }
    $html += @"
                            <tr>
                                <td>$($instrumento.Instrumento)</td>
                                <td>$($instrumento.NumConsigna)</td>
                                <td>$($instrumento.CodigoCaja)</td>
                                <td><span class="badge $badgeEstado">$estadoTexto</span></td>
                            </tr>
"@
}

$html += @"
                        </tbody>
                    </table>
                </div>
            </div>
        </div>

        <!-- TAB 2: HISTORIAL -->
        <div class="tab-content content-historial">
            <div class="stats">
                <div class="stat-card">
                    <h3>Total Movimientos</h3>
                    <div class="number">$totalMovimientos</div>
                    <div class="label">Registros totales</div>
                </div>
                <div class="stat-card">
                    <h3>&Uacute;ltima Actualizaci&oacute;n</h3>
                    <div class="number" style="font-size: 2em;">$(Get-Date -Format 'HH:mm')</div>
                    <div class="label">Hora actual</div>
                </div>
            </div>
            <div class="table-container">
                <div class="table-header">
                    <h2>Todos los Movimientos</h2>
                </div>
                <div class="table-wrapper">
                    <table id="tablaMovimientos">
                        <thead>
                            <tr>
                                <th>Fecha Apertura</th>
                                <th>Usuario</th>
                                <th>Consigna</th>
                                <th>Descripci&oacute;n</th>
                                <th>Acci&oacute;n</th>
                            </tr>
                        </thead>
                        <tbody>
"@

foreach ($movimiento in $ultimosMovimientos) {
    $badgeClass = if ($movimiento.Accion -like '*Extracci*') { 'badge-ocupada' } elseif ($movimiento.Accion -like '*Devoluci*') { 'badge-libre' } else { 'badge-libre' }
    # Normalizar Accion: independientemente del encoding del CSV, usar siempre HTML entities correctas
    $accionTexto = if ($movimiento.Accion -like '*Extracci*') { 'Extracci&oacute;n' } elseif ($movimiento.Accion -like '*Devoluci*') { 'Devoluci&oacute;n' } else { $movimiento.Accion }
    $html += @"
                            <tr>
                                <td>$($movimiento.FechaHoraApertura)</td>
                                <td>$($movimiento.Usuario)</td>
                                <td>$($movimiento.Consigna)</td>
                                <td>$($movimiento.Descripcion)</td>
                                <td><span class="badge $badgeClass">$accionTexto</span></td>
                            </tr>
"@
}

$html += @"
                        </tbody>
                    </table>
                </div>
            </div>
        </div>

        <p class="actualizado">Actualizado autom&aacute;ticamente cada minuto | &Uacute;ltima actualizaci&oacute;n: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')</p>
    </div>
</body>
</html>
"@

$utf8WithBOM = New-Object System.Text.UTF8Encoding $true
[System.IO.File]::WriteAllText($archivoHTML, $html, $utf8WithBOM)
Write-Host "Dashboard HTML generado: $archivoHTML" -ForegroundColor Green
Write-Host "Codigos cargados desde EXPORT_Cajas.txt: $($mapaCodigos.Count)" -ForegroundColor Cyan
