# GenerarDashboardAdmin.ps1
# Dashboard interno para administradores del sistema locker.
# Genera DashboardAdmin.html en la misma carpeta que DashboardLocker.html.
# NO modifica ni interfiere con GenerarDashboard.ps1 ni DashboardLocker.html.

$carpetaUser        = "C:\Users\User\OneDrive - GHI HORNOS INDUSTRIALES S.L\LockerACTUM"
$carpetaDesarrollo  = "c:\Users\ialopez\OneDrive - GHI HORNOS INDUSTRIALES S.L\Antigravity\GHI"
$carpetaACTUM       = "C:\ACTUM"

# =============================================
# AUTO-UPDATE: si hay version nueva en OneDrive, copiar a C:\ACTUM y relanzar
# =============================================
$scriptOneDrive = "$carpetaUser\GenerarDashboardAdmin.ps1"
$scriptLocal    = "$carpetaACTUM\GenerarDashboardAdmin.ps1"
if ((Test-Path $scriptOneDrive) -and (Test-Path $scriptLocal)) {
    $tsOneDrive = (Get-Item $scriptOneDrive).LastWriteTimeUtc
    $tsLocal    = (Get-Item $scriptLocal).LastWriteTimeUtc
    if ($tsOneDrive -gt $tsLocal.AddSeconds(10)) {
        Copy-Item $scriptOneDrive $scriptLocal -Force
        & $scriptLocal
        exit
    }
}

if (Test-Path $carpetaUser) {
    $carpetaOneDrive = $carpetaUser
} else {
    $carpetaOneDrive = $carpetaDesarrollo
}

$archivoHistorial = "$carpetaOneDrive\HistorialCompleto.csv"
$archivoHTML      = "$carpetaOneDrive\DashboardAdmin.html"

$hoy = Get-Date

# =============================================
# FUNCION: Convertir caracteres especiales a HTML entities
# Usa [char]0xXX para evitar problemas de encoding al copiar el script
# =============================================
function ConvertTo-HtmlEntities {
    param([string]$text)
    if ([string]::IsNullOrEmpty($text)) { return $text }
    $text = $text -replace [char]0xE1, '&aacute;'
    $text = $text -replace [char]0xE9, '&eacute;'
    $text = $text -replace [char]0xED, '&iacute;'
    $text = $text -replace [char]0xF3, '&oacute;'
    $text = $text -replace [char]0xFA, '&uacute;'
    $text = $text -replace [char]0xF1, '&ntilde;'
    $text = $text -replace [char]0xFC, '&uuml;'
    $text = $text -replace [char]0xC1, '&Aacute;'
    $text = $text -replace [char]0xC9, '&Eacute;'
    $text = $text -replace [char]0xCD, '&Iacute;'
    $text = $text -replace [char]0xD3, '&Oacute;'
    $text = $text -replace [char]0xDA, '&Uacute;'
    $text = $text -replace [char]0xD1, '&Ntilde;'
    $text = $text -replace [char]0xDC, '&Uuml;'
    return $text
}

# =============================================
# PASO 1: Leer instrumentos desde SQL (tabla Caja + JOIN Consigna)
# Clave: Consigna.CodigoCliente = numero de consigna del CSV
# =============================================
$mapaInstrumentos = @{}   # clave: CodigoConsigna -> {CodigoGHI, Descripcion, FechaCaducidad}

try {
    $connStr = "Server=GHI-TAQUILLAS\SQLEXPRESS;Database=Actum_GHI;Integrated Security=True;Connect Timeout=5"
    $conn = New-Object System.Data.SqlClient.SqlConnection $connStr
    $conn.Open()
    $cmd = $conn.CreateCommand()
    $cmd.CommandText = "SELECT C.CodigoCliente AS ConsignaCod, Cj.CodigoCliente AS CodigoGHI, Cj.Descripcion, Cj.FechaCaducidad FROM Consigna C JOIN Caja Cj ON C.Caja_Codigo = Cj.Codigo WHERE C.Activa = 1"
    $reader = $cmd.ExecuteReader()
    while ($reader.Read()) {
        $key = "$([int]$reader['ConsignaCod'])"
        $fechaCad = if ($reader['FechaCaducidad'] -ne [DBNull]::Value) { [DateTime]$reader['FechaCaducidad'] } else { $null }
        $mapaInstrumentos[$key] = @{
            CodigoGHI      = "$($reader['CodigoGHI'])"
            Descripcion    = ConvertTo-HtmlEntities "$($reader['Descripcion'])"
            FechaCaducidad = $fechaCad
        }
    }
    $reader.Close()
    $conn.Close()
    $fuenteDatos = "SQL Server"
} catch {
    # Fallback a EXPORT_Cajas.txt
    $fuenteDatos = "EXPORT_Cajas.txt (fallback)"
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
                    $mapaInstrumentos[$codigo] = @{
                        CodigoGHI      = $campos[1].Trim()
                        Descripcion    = ConvertTo-HtmlEntities $campos[2].Trim()
                        FechaCaducidad = $null
                    }
                }
            }
        }
    }
}

# =============================================
# PASO 2: Leer usuarios desde SQL (tabla Usuario)
# =============================================
$listaUsuarios = @()

try {
    $connStr = "Server=GHI-TAQUILLAS\SQLEXPRESS;Database=Actum_GHI;Integrated Security=True;Connect Timeout=5"
    $conn2 = New-Object System.Data.SqlClient.SqlConnection $connStr
    $conn2.Open()
    $cmd2 = $conn2.CreateCommand()
    $cmd2.CommandText = "SELECT CodigoCliente, UID, Nombre, Apellidos, AccesoConsignasRestringidas, Consigna_Codigo FROM Usuario ORDER BY CodigoCliente"
    $reader2 = $cmd2.ExecuteReader()
    while ($reader2.Read()) {
        $esAdmin = if ($reader2['AccesoConsignasRestringidas'] -ne [DBNull]::Value) { [bool]$reader2['AccesoConsignasRestringidas'] } else { $false }
        $consCod = if ($reader2['Consigna_Codigo'] -ne [DBNull]::Value) { "$($reader2['Consigna_Codigo'])" } else { '' }
        $codigoUsr = if ($reader2['CodigoCliente'] -ne [DBNull]::Value) { "$($reader2['CodigoCliente'])" } else { '' }
        $pinUsr    = if ($reader2['UID']            -ne [DBNull]::Value) { "$($reader2['UID'])"            } else { '' }
        $listaUsuarios += [PSCustomObject]@{
            Codigo      = $codigoUsr
            Pin         = $pinUsr
            Nombre      = ConvertTo-HtmlEntities "$($reader2['Nombre'])"
            Apellidos   = ConvertTo-HtmlEntities "$($reader2['Apellidos'])"
            EsAdmin     = $esAdmin
            ConsignaCod = $consCod
        }
    }
    $reader2.Close()
    $conn2.Close()
} catch {
    # Sin acceso SQL: tabla usuarios queda vacia
}

# =============================================
# PASO 3: Leer historial CSV y calcular estadisticas de uso
# =============================================
$historial = @()
if (Test-Path $archivoHistorial) {
    $historial = Import-Csv -Path $archivoHistorial -Delimiter ";" -Encoding UTF8
}

# Filtrar consigna 100 (evento sistema)
$historialFiltrado = $historial | Where-Object { $_.Consigna -ne '100' }

# --- Registro de uso: contar usos por instrumento (cada fila del CSV es 1 uso) ---
$usosPorConsigna = $historialFiltrado | Group-Object Consigna | ForEach-Object {
    $consignaKey = "$([int]$_.Name)"
    $info = if ($mapaInstrumentos.ContainsKey($consignaKey)) { $mapaInstrumentos[$consignaKey] } else {
        # Intentar obtener descripcion del CSV
        $desc = ($_.Group | Select-Object -First 1).Descripcion
        @{ CodigoGHI = ''; Descripcion = ConvertTo-HtmlEntities $desc; FechaCaducidad = $null }
    }
    [PSCustomObject]@{
        NumConsigna  = $_.Name
        CodigoGHI    = $info.CodigoGHI
        Descripcion  = $info.Descripcion
        TotalUsos    = $_.Count
        UltimUso     = ($_.Group | ForEach-Object {
            try { [DateTime]::ParseExact($_.FechaHoraApertura, 'MM/dd/yyyy HH:mm:ss', $null) } catch { [DateTime]::MinValue }
        } | Sort-Object -Descending | Select-Object -First 1)
    }
} | Sort-Object TotalUsos -Descending

$maxUsos = if ($usosPorConsigna.Count -gt 0) { ($usosPorConsigna | Measure-Object TotalUsos -Maximum).Maximum } else { 1 }

# --- Calibracion: construir lista desde mapaInstrumentos ---
$listaCalib = $mapaInstrumentos.Keys | ForEach-Object {
    $k    = $_
    $info = $mapaInstrumentos[$k]
    $diasRestantes = $null
    $estadoCalib   = 'SIN FECHA'
    $pct           = 0
    $urgencia      = 0   # para ordenar: 0=caducado, 1=urgente(<30d), 2=proximo(<90d), 3=ok
    if ($info.FechaCaducidad -ne $null) {
        $diasRestantes = [int]($info.FechaCaducidad - $hoy).TotalDays
        if ($diasRestantes -lt 0) {
            $estadoCalib = 'CADUCADO'
            $pct = 0
            $urgencia = 0
        } elseif ($diasRestantes -le 30) {
            $estadoCalib = 'URGENTE'
            $pct = [int]($diasRestantes / 30 * 100)
            $urgencia = 1
        } elseif ($diasRestantes -le 90) {
            $estadoCalib = 'PROXIMO'
            $pct = [int]($diasRestantes / 90 * 100)
            $urgencia = 2
        } else {
            $estadoCalib = 'CALIBRADO'
            $pct = 100
            $urgencia = 3
        }
    } else { $urgencia = 4 }

    [PSCustomObject]@{
        NumConsigna    = $k
        CodigoGHI      = $info.CodigoGHI
        Descripcion    = $info.Descripcion
        FechaCaducidad = $info.FechaCaducidad
        DiasRestantes  = $diasRestantes
        EstadoCalib    = $estadoCalib
        PctBarra       = $pct
        Urgencia       = $urgencia
    }
} | Sort-Object Urgencia, DiasRestantes

# --- Stats globales ---
$totalMovimientos   = $historialFiltrado.Count
$totalInstrumentos  = $mapaInstrumentos.Count
$totalCaducados     = ($listaCalib | Where-Object { $_.EstadoCalib -eq 'CADUCADO' }).Count
$totalUrgentes      = ($listaCalib | Where-Object { $_.EstadoCalib -eq 'URGENTE' }).Count
$totalUsuarios      = $listaUsuarios.Count
$totalAdmins        = ($listaUsuarios | Where-Object { $_.EsAdmin }).Count

# =============================================
# PASO 4: Generar HTML
# - Sin Google Fonts (CDN bloqueado en OneDrive web)
# - Tabs CSS puro sin JavaScript (compatible OneDrive web)
# - Encoding ASCII final (red de seguridad definitiva)
# =============================================
$html = @"
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>ADMIN LOCKER - GHI SMART FURNACES</title>
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
            --warning: #F59E0B;
            --danger: #EF4444;
            --info: #3B82F6;
            --glass-bg: rgba(255, 255, 255, 0.05);
            --glass-border: rgba(255, 255, 255, 0.1);
        }

        * { margin: 0; padding: 0; box-sizing: border-box; }

        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', 'Helvetica Neue', Arial, sans-serif;
            background: linear-gradient(135deg, var(--ghi-black) 0%, #111111 50%, #0D0D0D 100%);
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
            margin-bottom: 24px;
            padding: 22px 30px;
            background: linear-gradient(135deg, rgba(195,30,46,0.15) 0%, rgba(255,255,255,0.03) 100%);
            border: 1px solid rgba(195,30,46,0.3);
            border-radius: 16px;
            box-shadow: 0 4px 30px rgba(195,30,46,0.1);
        }

        .header-left { display: flex; align-items: center; gap: 20px; }

        .admin-badge {
            background: linear-gradient(135deg, var(--ghi-red-dark), var(--ghi-red));
            color: white;
            font-size: 0.7em;
            font-weight: 800;
            padding: 4px 10px;
            border-radius: 6px;
            letter-spacing: 1px;
            text-transform: uppercase;
        }

        .title-section h1 {
            font-size: 1.7em;
            font-weight: 800;
            color: var(--ghi-white);
            margin-bottom: 2px;
        }
        .title-section h1 span { color: var(--ghi-red); }
        .title-section p { color: var(--ghi-text-medium); font-size: 0.88em; }

        .header-right { display: flex; align-items: center; gap: 12px; }

        .live-indicator {
            display: flex;
            align-items: center;
            gap: 8px;
            padding: 8px 16px;
            background: rgba(16,185,129,0.1);
            border: 1px solid rgba(16,185,129,0.3);
            border-radius: 20px;
            color: var(--success);
            font-weight: 600;
            font-size: 0.9em;
        }

        .pulse-dot {
            width: 8px; height: 8px;
            background: var(--success);
            border-radius: 50%;
            animation: pulse 2s infinite;
        }

        @keyframes pulse {
            0%   { box-shadow: 0 0 0 0 rgba(16,185,129,0.7); }
            70%  { box-shadow: 0 0 0 6px rgba(16,185,129,0); }
            100% { box-shadow: 0 0 0 0 rgba(16,185,129,0); }
        }

        .timestamp { color: var(--ghi-text-medium); font-size: 0.82em; }

        /* ALERT BANNER - solo aparece si hay caducados/urgentes */
        .alert-banner {
            display: flex;
            align-items: center;
            gap: 14px;
            padding: 14px 24px;
            margin-bottom: 20px;
            background: rgba(239,68,68,0.12);
            border: 1px solid rgba(239,68,68,0.4);
            border-radius: 12px;
            color: #FCA5A5;
            font-weight: 600;
        }
        .alert-icon { font-size: 1.4em; }

        /* STATS GRID */
        .stats-grid {
            display: grid;
            grid-template-columns: repeat(6, 1fr);
            gap: 14px;
            margin-bottom: 24px;
        }

        .stat-card {
            background: var(--glass-bg);
            border: 1px solid var(--glass-border);
            padding: 20px;
            border-radius: 14px;
            box-shadow: 0 2px 16px rgba(0,0,0,0.2);
        }

        .stat-card.red   { border-color: rgba(195,30,46,0.4); background: rgba(195,30,46,0.08); }
        .stat-card.green { border-color: rgba(16,185,129,0.4); background: rgba(16,185,129,0.08); }
        .stat-card.amber { border-color: rgba(245,158,11,0.4); background: rgba(245,158,11,0.08); }
        .stat-card.blue  { border-color: rgba(59,130,246,0.4); background: rgba(59,130,246,0.08); }

        .stat-card h3 {
            color: var(--ghi-text-medium);
            font-size: 0.78em;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            margin-bottom: 10px;
        }

        .stat-card .number {
            font-size: 2.2em;
            font-weight: 900;
            line-height: 1;
            margin-bottom: 4px;
        }
        .stat-card.red   .number { color: var(--ghi-red); }
        .stat-card.green .number { color: var(--success); }
        .stat-card.amber .number { color: var(--warning); }
        .stat-card.blue  .number { color: var(--info); }
        .stat-card:not(.red):not(.green):not(.amber):not(.blue) .number { color: var(--ghi-red); }

        .stat-card .sublabel { color: var(--ghi-text-medium); font-size: 0.8em; }

        /* TABS - CSS puro sin JavaScript */
        .tab-inputs { display: none; }

        .tabs-nav {
            display: flex;
            gap: 8px;
            margin-bottom: 24px;
            background: rgba(255,255,255,0.03);
            border: 1px solid var(--glass-border);
            border-radius: 12px;
            padding: 8px;
        }

        .tab-label {
            flex: 1;
            padding: 13px 20px;
            background: transparent;
            color: var(--ghi-text-medium);
            font-size: 0.95em;
            font-weight: 600;
            cursor: pointer;
            border-radius: 8px;
            text-align: center;
            display: block;
            user-select: none;
            transition: background 0.2s;
        }

        .tab-label:hover { background: rgba(255,255,255,0.06); color: var(--ghi-text-light); }

        #tab-uso:checked      ~ .tabs-nav label[for="tab-uso"],
        #tab-calibracion:checked ~ .tabs-nav label[for="tab-calibracion"],
        #tab-usuarios:checked ~ .tabs-nav label[for="tab-usuarios"] {
            background: linear-gradient(135deg, var(--ghi-red-dark), var(--ghi-red));
            color: white;
            box-shadow: 0 4px 14px rgba(195,30,46,0.4);
        }

        .tab-content { display: none; }
        #tab-uso:checked      ~ .tab-content.content-uso      { display: block; }
        #tab-calibracion:checked ~ .tab-content.content-calibracion { display: block; }
        #tab-usuarios:checked ~ .tab-content.content-usuarios { display: block; }

        /* TABLE BASE */
        .table-container {
            background: var(--glass-bg);
            border: 1px solid var(--glass-border);
            padding: 28px;
            border-radius: 16px;
            box-shadow: 0 4px 24px rgba(0,0,0,0.2);
        }

        .table-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 20px;
        }

        .table-header h2 { font-size: 1.3em; font-weight: 700; }
        .table-header .subtitle { color: var(--ghi-text-medium); font-size: 0.85em; margin-top: 2px; }

        .table-wrapper { overflow-x: auto; border-radius: 10px; background: var(--ghi-grey-medium); }

        table { width: 100%; border-collapse: collapse; }

        thead {
            background: linear-gradient(135deg, var(--ghi-red-dark) 0%, var(--ghi-red) 100%);
            position: sticky; top: 0; z-index: 10;
        }

        th {
            padding: 14px 18px;
            text-align: left;
            font-weight: 700;
            font-size: 0.82em;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            color: white;
            border-bottom: 2px solid var(--ghi-red-light);
            white-space: nowrap;
        }

        tbody tr { border-bottom: 1px solid rgba(255,255,255,0.05); transition: background 0.15s; }
        tbody tr:nth-child(even) { background: rgba(255,255,255,0.02); }
        tbody tr:hover { background: rgba(195,30,46,0.08); }
        td { padding: 14px 18px; color: var(--ghi-text-light); font-size: 0.92em; }

        /* RANK column */
        .rank-num {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            width: 28px; height: 28px;
            border-radius: 50%;
            font-weight: 800;
            font-size: 0.85em;
        }
        .rank-1 { background: linear-gradient(135deg,#F59E0B,#D97706); color: #000; }
        .rank-2 { background: linear-gradient(135deg,#9CA3AF,#6B7280); color: #000; }
        .rank-3 { background: linear-gradient(135deg,#92400E,#78350F); color: #fff; }
        .rank-n { background: rgba(255,255,255,0.1); color: var(--ghi-text-medium); }

        /* USO BAR */
        .uso-bar-wrap {
            display: flex;
            align-items: center;
            gap: 10px;
        }
        .uso-bar-bg {
            flex: 1;
            height: 8px;
            background: rgba(255,255,255,0.1);
            border-radius: 4px;
            min-width: 60px;
        }
        .uso-bar-fill {
            height: 8px;
            border-radius: 4px;
            background: linear-gradient(90deg, var(--ghi-red-dark), var(--ghi-red-light));
        }
        .uso-count {
            font-weight: 700;
            color: var(--ghi-white);
            font-size: 0.95em;
            min-width: 28px;
            text-align: right;
        }
        .uso-fecha { color: var(--ghi-text-medium); font-size: 0.82em; }

        /* CALIB STATUS */
        .badge {
            display: inline-block;
            padding: 5px 11px;
            border-radius: 16px;
            font-size: 0.82em;
            font-weight: 700;
            white-space: nowrap;
        }

        .badge-caducado {
            background: linear-gradient(135deg,#EF4444,#DC2626);
            color: white;
            box-shadow: 0 3px 10px rgba(239,68,68,0.4);
        }

        .badge-urgente {
            background: linear-gradient(135deg,#F59E0B,#D97706);
            color: #000;
            box-shadow: 0 3px 10px rgba(245,158,11,0.4);
        }

        .badge-proximo {
            background: linear-gradient(135deg,#3B82F6,#2563EB);
            color: white;
            box-shadow: 0 3px 10px rgba(59,130,246,0.3);
        }

        .badge-calibrado {
            background: linear-gradient(135deg,#10B981,#059669);
            color: white;
            box-shadow: 0 3px 10px rgba(16,185,129,0.3);
        }

        .badge-sinfecha {
            background: rgba(255,255,255,0.1);
            color: var(--ghi-text-medium);
            border: 1px solid rgba(255,255,255,0.15);
        }

        .badge-admin {
            background: linear-gradient(135deg,#8B5CF6,#7C3AED);
            color: white;
            box-shadow: 0 3px 10px rgba(139,92,246,0.3);
            font-size: 0.75em;
            padding: 4px 10px;
        }

        .badge-user {
            background: rgba(255,255,255,0.08);
            color: var(--ghi-text-medium);
            border: 1px solid rgba(255,255,255,0.12);
            font-size: 0.75em;
            padding: 4px 10px;
        }

        /* CALIB PROGRESS BAR */
        .calib-bar-wrap { display: flex; align-items: center; gap: 8px; }
        .calib-bar-bg {
            flex: 1; height: 6px;
            background: rgba(255,255,255,0.08);
            border-radius: 3px;
            min-width: 50px;
        }
        .calib-bar-fill { height: 6px; border-radius: 3px; }
        .calib-bar-ok   { background: linear-gradient(90deg,#10B981,#059669); }
        .calib-bar-warn { background: linear-gradient(90deg,#3B82F6,#2563EB); }
        .calib-bar-urg  { background: linear-gradient(90deg,#F59E0B,#D97706); }
        .dias-texto { font-size: 0.82em; color: var(--ghi-text-medium); white-space: nowrap; }

        /* FOOTER */
        .footer {
            text-align: center;
            margin-top: 24px;
            padding: 14px;
            color: var(--ghi-text-medium);
            font-size: 0.85em;
            background: var(--glass-bg);
            border-radius: 8px;
            border: 1px solid var(--glass-border);
        }

        ::-webkit-scrollbar { width: 8px; height: 8px; }
        ::-webkit-scrollbar-track { background: var(--ghi-grey-medium); border-radius: 4px; }
        ::-webkit-scrollbar-thumb { background: var(--ghi-red); border-radius: 4px; }
        ::-webkit-scrollbar-thumb:hover { background: var(--ghi-red-light); }

        @media (max-width: 1100px) {
            .stats-grid { grid-template-columns: repeat(3, 1fr); }
        }
        @media (max-width: 768px) {
            body { padding: 10px; }
            .header { flex-direction: column; align-items: flex-start; gap: 12px; padding: 16px 18px; }
            .title-section h1 { font-size: 1.3em; }
            .stats-grid { grid-template-columns: repeat(2, 1fr); }
            .tabs-nav { flex-wrap: wrap; }
            .tab-label { padding: 10px 14px; font-size: 0.88em; }
        }
        @media (max-width: 480px) {
            .stats-grid { grid-template-columns: 1fr 1fr; gap: 10px; }
            td, th { padding: 10px 8px; }
            table { font-size: 0.82em; }
        }
    </style>
</head>
<body>
<div class="container">

    <!-- HEADER -->
    <div class="header">
        <div class="header-left">
            <div>
                <div style="display:flex;align-items:center;gap:10px;margin-bottom:4px;">
                    <h1 class="title-section" style="font-size:1.7em;font-weight:800;">
                        GHI <span style="color:var(--ghi-red);">ADMIN</span>
                    </h1>
                    <span class="admin-badge">PANEL INTERNO</span>
                </div>
                <p style="color:var(--ghi-text-medium);font-size:0.88em;">Locker ACTUM &mdash; Panel de administraci&oacute;n y control</p>
            </div>
        </div>
        <div class="header-right">
            <div class="live-indicator">
                <div class="pulse-dot"></div>
                <span>En vivo</span>
            </div>
            <div class="timestamp">$(Get-Date -Format 'dd/MM/yyyy HH:mm')</div>
        </div>
    </div>
"@

# BANNER DE ALERTA (solo si hay caducados o urgentes)
if ($totalCaducados -gt 0 -or $totalUrgentes -gt 0) {
    $alertMsg = ""
    if ($totalCaducados -gt 0) { $alertMsg += "$totalCaducados instrumento(s) con calibraci&oacute;n CADUCADA. " }
    if ($totalUrgentes  -gt 0) { $alertMsg += "$totalUrgentes instrumento(s) con calibraci&oacute;n urgente (&lt;30 d&iacute;as). " }
    $html += @"
    <div class="alert-banner">
        <span class="alert-icon">&#9888;</span>
        <span>ATENCI&Oacute;N: $alertMsg Revisar pesta&ntilde;a Calibraci&oacute;n.</span>
    </div>
"@
}

$html += @"
    <!-- STATS GLOBALES -->
    <div class="stats-grid">
        <div class="stat-card">
            <h3>Total Instrumentos</h3>
            <div class="number">$totalInstrumentos</div>
            <div class="sublabel">En el sistema</div>
        </div>
        <div class="stat-card">
            <h3>Total Movimientos</h3>
            <div class="number">$totalMovimientos</div>
            <div class="sublabel">Acumulado hist&oacute;rico</div>
        </div>
        <div class="stat-card red">
            <h3>Caducados</h3>
            <div class="number">$totalCaducados</div>
            <div class="sublabel">Calibraci&oacute;n vencida</div>
        </div>
        <div class="stat-card amber">
            <h3>Urgentes</h3>
            <div class="number">$totalUrgentes</div>
            <div class="sublabel">Caducan en &lt; 30 d&iacute;as</div>
        </div>
        <div class="stat-card blue">
            <h3>Usuarios</h3>
            <div class="number">$totalUsuarios</div>
            <div class="sublabel">En la base de datos</div>
        </div>
        <div class="stat-card green">
            <h3>&Uacute;ltima actualizaci&oacute;n</h3>
            <div class="number" style="font-size:1.8em;">$(Get-Date -Format 'HH:mm')</div>
            <div class="sublabel">Datos en tiempo real</div>
        </div>
    </div>

    <!-- TABS CSS PURO - sin JavaScript, compatible OneDrive web -->
    <input type="radio" class="tab-inputs" id="tab-uso"          name="tabs" checked>
    <input type="radio" class="tab-inputs" id="tab-calibracion"  name="tabs">
    <input type="radio" class="tab-inputs" id="tab-usuarios"     name="tabs">

    <div class="tabs-nav">
        <label class="tab-label" for="tab-uso">&#128202; Registro de Uso</label>
        <label class="tab-label" for="tab-calibracion">&#128197; Calibraci&oacute;n</label>
        <label class="tab-label" for="tab-usuarios">&#128100; Usuarios</label>
    </div>

    <!-- ================================================ -->
    <!-- TAB 1: REGISTRO DE USO                           -->
    <!-- ================================================ -->
    <div class="tab-content content-uso">
        <div class="table-container">
            <div class="table-header">
                <div>
                    <h2>&#128202; Registro de Uso de Instrumentos</h2>
                    <div class="subtitle">Ordenado de mayor a menor uso &mdash; $totalMovimientos movimientos totales</div>
                </div>
            </div>
            <div class="table-wrapper">
                <table>
                    <thead>
                        <tr>
                            <th>#</th>
                            <th>C&oacute;digo GHI</th>
                            <th>Instrumento / Modelo / N&ordm; serie</th>
                            <th>N&ordm; Consigna</th>
                            <th>Usos totales</th>
                            <th>&Uacute;ltimo uso</th>
                        </tr>
                    </thead>
                    <tbody>
"@

$rankIdx = 0
foreach ($item in $usosPorConsigna) {
    $rankIdx++
    $rankClass = switch ($rankIdx) { 1 { 'rank-1' } 2 { 'rank-2' } 3 { 'rank-3' } default { 'rank-n' } }
    $pctBarra  = [int](($item.TotalUsos / $maxUsos) * 100)
    $ultFecha  = if ($item.UltimUso -gt [DateTime]::MinValue) { $item.UltimUso.ToString('dd/MM/yyyy') } else { '-' }
    $codGHI    = if ($item.CodigoGHI) { $item.CodigoGHI } else { '-' }
    $html += @"
                        <tr>
                            <td><span class="rank-num $rankClass">$rankIdx</span></td>
                            <td><strong>$codGHI</strong></td>
                            <td>$($item.Descripcion)</td>
                            <td style="text-align:center;">$($item.NumConsigna)</td>
                            <td>
                                <div class="uso-bar-wrap">
                                    <div class="uso-bar-bg">
                                        <div class="uso-bar-fill" style="width:${pctBarra}%;"></div>
                                    </div>
                                    <span class="uso-count">$($item.TotalUsos)</span>
                                </div>
                            </td>
                            <td class="uso-fecha">$ultFecha</td>
                        </tr>
"@
}

if ($usosPorConsigna.Count -eq 0) {
    $html += @"
                        <tr><td colspan="6" style="text-align:center;padding:40px;color:var(--ghi-text-medium);">No hay datos de uso disponibles en el historial.</td></tr>
"@
}

$html += @"
                    </tbody>
                </table>
            </div>
        </div>
    </div>

    <!-- ================================================ -->
    <!-- TAB 2: CALIBRACION                               -->
    <!-- ================================================ -->
    <div class="tab-content content-calibracion">
        <div class="table-container">
            <div class="table-header">
                <div>
                    <h2>&#128197; Estado de Calibraci&oacute;n</h2>
                    <div class="subtitle">Ordenado por urgencia &mdash; $totalCaducados caducados &middot; $totalUrgentes urgentes</div>
                </div>
            </div>
            <div class="table-wrapper">
                <table>
                    <thead>
                        <tr>
                            <th>Estado</th>
                            <th>C&oacute;digo GHI</th>
                            <th>Instrumento / Modelo / N&ordm; serie</th>
                            <th>N&ordm; Consigna</th>
                            <th>Fecha caducidad</th>
                            <th>D&iacute;as restantes</th>
                        </tr>
                    </thead>
                    <tbody>
"@

foreach ($item in $listaCalib) {
    $badgeClass  = switch ($item.EstadoCalib) {
        'CADUCADO'  { 'badge-caducado' }
        'URGENTE'   { 'badge-urgente'  }
        'PROXIMO'   { 'badge-proximo'  }
        'CALIBRADO' { 'badge-calibrado' }
        default     { 'badge-sinfecha'  }
    }

    if ($item.FechaCaducidad -ne $null) {
        $fechaTexto = $item.FechaCaducidad.ToString('dd/MM/yyyy')
    } else {
        $fechaTexto = '&mdash;'
    }

    if ($item.DiasRestantes -ne $null) {
        if ($item.DiasRestantes -lt 0) {
            $diasTexto   = "Venci&oacute; hace $([Math]::Abs($item.DiasRestantes)) d&iacute;as"
            $barraClass  = 'calib-bar-fill calib-bar-urg'
            $barraWidth  = 100
        } elseif ($item.DiasRestantes -le 30) {
            $diasTexto   = "$($item.DiasRestantes) d&iacute;as"
            $barraClass  = 'calib-bar-fill calib-bar-urg'
            $barraWidth  = $item.PctBarra
        } elseif ($item.DiasRestantes -le 90) {
            $diasTexto   = "$($item.DiasRestantes) d&iacute;as"
            $barraClass  = 'calib-bar-fill calib-bar-warn'
            $barraWidth  = $item.PctBarra
        } else {
            $diasTexto   = "$($item.DiasRestantes) d&iacute;as"
            $barraClass  = 'calib-bar-fill calib-bar-ok'
            $barraWidth  = 100
        }
        $diasCell = @"
<div class="calib-bar-wrap">
                                    <div class="calib-bar-bg"><div class="$barraClass" style="width:${barraWidth}%;"></div></div>
                                    <span class="dias-texto">$diasTexto</span>
                                </div>
"@
    } else {
        $diasCell = '<span style="color:var(--ghi-text-medium);">&mdash;</span>'
    }

    $codGHI = if ($item.CodigoGHI) { $item.CodigoGHI } else { '-' }

    $html += @"
                        <tr>
                            <td><span class="badge $badgeClass">$($item.EstadoCalib)</span></td>
                            <td><strong>$codGHI</strong></td>
                            <td>$($item.Descripcion)</td>
                            <td style="text-align:center;">$($item.NumConsigna)</td>
                            <td>$fechaTexto</td>
                            <td>$diasCell</td>
                        </tr>
"@
}

if ($listaCalib.Count -eq 0) {
    $html += @"
                        <tr><td colspan="6" style="text-align:center;padding:40px;color:var(--ghi-text-medium);">No hay datos de calibraci&oacute;n disponibles.</td></tr>
"@
}

$html += @"
                    </tbody>
                </table>
            </div>
        </div>
    </div>

    <!-- ================================================ -->
    <!-- TAB 3: USUARIOS                                  -->
    <!-- ================================================ -->
    <div class="tab-content content-usuarios">
        <div class="table-container">
            <div class="table-header">
                <div>
                    <h2>&#128100; Usuarios del Sistema</h2>
                    <div class="subtitle">$totalUsuarios usuarios registrados &mdash; $totalAdmins con acceso SAT</div>
                </div>
            </div>
            <div class="table-wrapper">
                <table>
                    <thead>
                        <tr>
                            <th>C&oacute;digo</th>
                            <th>PIN</th>
                            <th>Nombre</th>
                            <th>Apellidos</th>
                            <th>Tipo de acceso</th>
                        </tr>
                    </thead>
                    <tbody>
"@

foreach ($usr in $listaUsuarios) {
    $tipoAcceso  = if ($usr.EsAdmin) { '<span class="badge badge-admin">SAT (Acceso total)</span>' } else { '<span class="badge badge-user">Est&aacute;ndar</span>' }
    $pinShow     = if ($usr.Pin -and $usr.Pin -ne '') { "<span style='font-family:monospace;font-size:1em;letter-spacing:2px;color:var(--ghi-white);'>$($usr.Pin)</span>" } else { '&mdash;' }
    $codShow     = if ($usr.Codigo -and $usr.Codigo -ne '') { "<strong style='font-family:monospace;'>$($usr.Codigo)</strong>" } else { '&mdash;' }
    $html += @"
                        <tr>
                            <td>$codShow</td>
                            <td>$pinShow</td>
                            <td>$($usr.Nombre)</td>
                            <td>$($usr.Apellidos)</td>
                            <td>$tipoAcceso</td>
                        </tr>
"@
}

if ($listaUsuarios.Count -eq 0) {
    $html += @"
                        <tr><td colspan="4" style="text-align:center;padding:40px;color:var(--ghi-text-medium);">Sin acceso a SQL Server &mdash; lista de usuarios no disponible.</td></tr>
"@
}

$html += @"
                    </tbody>
                </table>
            </div>
        </div>
    </div>

    <!-- FOOTER -->
    <div class="footer">
        Actualizado autom&aacute;ticamente cada minuto &nbsp;|&nbsp;
        Datos: $fuenteDatos &nbsp;|&nbsp;
        &Uacute;ltima actualizaci&oacute;n: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')
    </div>

</div>
</body>
</html>
"@

# =============================================
# ESCRITURA FINAL: ASCII puro (red de seguridad contra encoding)
# Cualquier caracter > 127 se convierte a entidad numerica &#NNN;
# El fichero resultante es ASCII puro = imposible corrupciones de encoding.
# =============================================
$htmlFinal = [System.Text.RegularExpressions.Regex]::Replace($html, '[^\x00-\x7F]', {
    param($match)
    return '&#' + [int][char]$match.Value + ';'
})
$ascii = New-Object System.Text.ASCIIEncoding
[System.IO.File]::WriteAllText($archivoHTML, $htmlFinal, $ascii)
Write-Host "Dashboard Admin generado: $archivoHTML" -ForegroundColor Green
