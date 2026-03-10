# Script para actualizar automaticamente el Excel de instrumentos
# Columnas que se actualizan:
#   - UBICACION (col A): "Disponible" o "En uso por [nombre]"
#   - Estado (col K): "CALIBRADO" o "CADUCADO" segun Fecha caducidad (col I)
#
# Se ejecuta cada 5 minutos via tarea programada (ActualizarExcelLocker)

# =============================================
# PASO 1: Rutas
# =============================================
$carpetaUser  = "C:\Users\User\OneDrive - GHI HORNOS INDUSTRIALES S.L\LockerACTUM"
$carpetaDesarrollo = "c:\Users\ialopez\OneDrive - GHI HORNOS INDUSTRIALES S.L\Antigravity\GHI"
$carpetaACTUM = "C:\ACTUM"

if (Test-Path $carpetaUser) {
    $carpetaOneDrive = $carpetaUser
    $archivoExcel = "C:\Users\User\OneDrive - GHI HORNOS INDUSTRIALES S.L\00.Intrumentos_Locker (1).xlsx"
} else {
    $carpetaOneDrive = $carpetaDesarrollo
    $archivoExcel = "c:\Users\ialopez\OneDrive - GHI HORNOS INDUSTRIALES S.L\LOCKER INSTRUMENTACION\00.Intrumentos_Locker (1).xlsx"
}

$archivoHistorial = "$carpetaOneDrive\HistorialCompleto.csv"

# =============================================
# PASO 2: Construir mapa Consigna -> CodigoCaja
# =============================================
$mapaCodigos = @{}
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
            if ($campos.Count -ge 2) {
                $mapaCodigos[$campos[0].Trim()] = $campos[1].Trim()
            }
        }
    }
}

# =============================================
# PASO 3: Leer historial y calcular estado actual
# =============================================
$estadoInstrumentos = @()
$historial = @()

if (Test-Path $archivoHistorial) {
    $historial = Import-Csv -Path $archivoHistorial -Delimiter ";" -Encoding UTF8
}

if ($historial.Count -gt 0) {
    $historialFiltrado = $historial | Where-Object { $_.Consigna -ne '100' }
    $ultimaAccionPorConsigna = $historialFiltrado |
        Sort-Object { try { [DateTime]::ParseExact($_.FechaHoraApertura, 'MM/dd/yyyy HH:mm:ss', $null) } catch { [DateTime]::MinValue } } -Descending |
        Group-Object Consigna |
        ForEach-Object { $_.Group | Select-Object -First 1 }

    foreach ($mov in $ultimaAccionPorConsigna) {
        $estado = if ($mov.Accion -like '*Extracci*') { 'En uso' } elseif ($mov.Accion -like '*Devoluci*') { 'Disponible' } else { 'Desconocido' }
        $usuarioActual = if ($estado -eq 'En uso') { "$($mov.Usuario) $($mov.Apellidos)" } else { '' }
        $consignaKey = "$([int]$mov.Consigna)"
        $estadoInstrumentos += [PSCustomObject]@{
            NumConsigna   = $mov.Consigna
            Estado        = $estado
            UsuarioActual = $usuarioActual
        }
    }
}

# =============================================
# PASO 4: Cargar modulo ImportExcel
# (puede estar en ruta no estandar si se instalo con -Scope CurrentUser)
# =============================================
if (-not (Test-Path $archivoExcel)) {
    Write-Host "Excel no encontrado: $archivoExcel" -ForegroundColor Red
    exit
}

$moduleLoaded = $false
try {
    Import-Module ImportExcel -ErrorAction Stop
    $moduleLoaded = $true
} catch {
    $rutasAlternativas = @(
        "C:\Users\User\OneDrive - GHI HORNOS INDUSTRIALES S.L\Documentos\WindowsPowerShell\Modules\ImportExcel\*\ImportExcel.psd1",
        "$env:USERPROFILE\Documents\WindowsPowerShell\Modules\ImportExcel\*\ImportExcel.psd1",
        "$env:USERPROFILE\OneDrive*\Documentos\WindowsPowerShell\Modules\ImportExcel\*\ImportExcel.psd1"
    )
    foreach ($ruta in $rutasAlternativas) {
        $psd1 = Get-Item $ruta -ErrorAction SilentlyContinue | Select-Object -First 1
        if ($psd1) {
            try {
                Import-Module $psd1.FullName -ErrorAction Stop
                $moduleLoaded = $true
                Write-Host "ImportExcel cargado desde: $($psd1.FullName)" -ForegroundColor Cyan
                break
            } catch {}
        }
    }
}

if (-not $moduleLoaded) {
    Write-Host "Modulo ImportExcel no encontrado. Ejecuta: Install-Module ImportExcel -Scope CurrentUser -Force" -ForegroundColor Red
    exit
}

# =============================================
# PASO 5: Actualizar Excel
# =============================================
try {
    $excel = Open-ExcelPackage -Path $archivoExcel
    $ws    = $excel.Workbook.Worksheets[1]
    $hoy   = Get-Date

    $filaInicio = 3   # Datos empiezan en fila 3 (1-2 son titulo/cabecera)
    $filaFin    = $ws.Dimension.End.Row
    $actualizados = 0

    for ($fila = $filaInicio; $fila -le $filaFin; $fila++) {

        # --- COLUMNA K (col 11): Estado segun Fecha caducidad (col I = 9) ---
        $celdaFechaCad = $ws.Cells[$fila, 9]
        if ($celdaFechaCad.Value -ne $null) {
            $fechaCad = $null
            if ($celdaFechaCad.Value -is [DateTime]) {
                $fechaCad = $celdaFechaCad.Value
            } elseif ($celdaFechaCad.Text -match '\d{2}/\d{2}/\d{4}') {
                try { $fechaCad = [DateTime]::Parse($celdaFechaCad.Text) } catch {}
            }
            if ($fechaCad -ne $null) {
                $nuevoEstado = if ($fechaCad -lt $hoy) { "CADUCADO" } else { "CALIBRADO" }
                if ($ws.Cells[$fila, 11].Text -ne $nuevoEstado) {
                    $ws.Cells[$fila, 11].Value = $nuevoEstado
                    $actualizados++
                }
            }
        }

        # --- COLUMNA A (col 1): UBICACION segun estado del locker ---
        $consignaTexto = $ws.Cells[$fila, 2].Text  # col B = CONSIGNA ("Consigna - 1")
        if ($consignaTexto -match 'Consigna\s*-\s*(\d+)') {
            $numConsigna  = "$([int]$matches[1])"
            $instrumento  = $estadoInstrumentos | Where-Object { "$([int]$_.NumConsigna)" -eq $numConsigna }
            if ($instrumento) {
                $nuevaUbicacion = if ($instrumento.Estado -eq 'En uso') {
                    "En uso por $($instrumento.UsuarioActual)"
                } else {
                    "Disponible"
                }
                if ($ws.Cells[$fila, 1].Text -ne $nuevaUbicacion) {
                    $ws.Cells[$fila, 1].Value = $nuevaUbicacion
                    $actualizados++
                }
            }
        }
    }

    $excel.Save()
    $excel.Dispose()
    Write-Host "Excel actualizado: $actualizados celdas modificadas" -ForegroundColor Green

} catch {
    Write-Host "Error al actualizar Excel: $_" -ForegroundColor Red
}
