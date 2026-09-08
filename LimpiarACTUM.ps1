# LimpiarACTUM.ps1 - creado 2026-09-08
#
# Ordena C:\ACTUM apartando lo muerto a C:\ACTUM\_ARCHIVO\, SIN BORRAR (salvo 3 excepciones)
# y SIN MOVER NI UN SOLO FICHERO ACTIVO.
#
# POR QUE NO SE MUEVEN LOS SCRIPTS ACTIVOS
# ----------------------------------------
# Sus rutas estan cableadas en 4 ficheros .vbs y en 5 tareas programadas. Moverlos obliga a
# reconfigurar todo eso y es la forma mas facil de dejar el locker parado. Se quedan donde estan.
#
# DEPENDENCIAS MEDIDAS (08/09) - por eso estos DOS ficheros NO se mueven:
#   EXPORT_Cajas.txt  -> lo leen GenerarDashboard.ps1, GenerarDashboardAdmin.ps1 y ActualizarExcel.ps1
#                        como fallback si SQL no responde (GenerarDashboard.ps1:135)
#   logo_base64.txt   -> lo lee GenerarDashboard.ps1:52
# Los demas EXPORT_*.txt no los referencia ningun script activo.
#
# USO
# ---
#   .\LimpiarACTUM.ps1            <- SIMULA. No toca nada. Muestra que haria.
#   .\LimpiarACTUM.ps1 -Aplicar   <- lo hace de verdad.

param([switch]$Aplicar)

$raiz    = "C:\ACTUM"
$archivo = "$raiz\_ARCHIVO"

# --- Lo que NO se toca bajo ningun concepto -------------------------------
$intocables = @(
    "MonitoreoLockerTiempoReal.ps1",
    "GenerarDashboard.ps1",
    "GenerarDashboardAdmin.ps1",
    "ActualizarExcel.ps1",
    "ReconstruirHistorial.ps1",
    "CrearCorreccionesManuales.ps1",
    "AuditarDashboard.ps1",
    "LimpiarACTUM.ps1",
    "EjecutarMonitoreoOculto.vbs",
    "EjecutarDashboardOculto.vbs",
    "EjecutarAdminOculto.vbs",
    "EjecutarExcelOculto.vbs",
    "EXPORT_Cajas.txt",
    "logo_base64.txt"
)

# --- Que va a cada sitio --------------------------------------------------
$plan = @(
    @{ Destino = "backups_scripts";  Patrones = @("*_BACKUP_*.ps1","*_ANTES_*.ps1","*_POSTB_*.ps1","*_v1_BACKUP.ps1","*_backup_*.ps1") },
    @{ Destino = "pruebas";          Patrones = @("PRUEBA_*","ReconstruirHistorial_PRUEBA.ps1") },
    @{ Destino = "exports_2026-02";  Patrones = @("EXPORT_*.txt") },
    @{ Destino = "obsoleto";         Patrones = @("MoverArchivosOneDrive.ps1","ExportarLocker.ps1","ReconstruirSemanal.ps1","EjecutarReconstruccionOculto.vbs","ConfigurarTareaOcultaVBS.ps1") },
    @{ Destino = "consultas_sueltas";Patrones = @("tablas.txt","lista_tablas.txt","relaciones.txt","estructura_movimientos.txt","ejemplo_movimientos.txt","todas_columnas.txt") }
)

$carpetasAArchivar = @("Instalador","Act2502","Act250212","Act250219","Backup","Consignas")

# --- Lo unico que se borra ------------------------------------------------
$aBorrar = @(
    "Nuevo documento de texto.txt",          # vacio, 0 bytes
    "UltimoEventoProcesado.txt",             # leftover del 17/04. El real vive en OneDrive. Trampa de diagnostico
    "Documentos - Acceso directo.lnk"        # acceso directo suelto
)

# ==========================================================================
if (-not $Aplicar) {
    Write-Host ""
    Write-Host "*** MODO SIMULACION - no se toca nada ***" -ForegroundColor Yellow
    Write-Host "*** Para hacerlo de verdad:  .\LimpiarACTUM.ps1 -Aplicar ***" -ForegroundColor Yellow
}
Write-Host ""

$antes = @(Get-ChildItem $raiz -File).Count
$antesDir = @(Get-ChildItem $raiz -Directory).Count
Write-Host "Estado inicial de C:\ACTUM: $antes ficheros y $antesDir carpetas en la raiz" -ForegroundColor Cyan
Write-Host ""

$nMovidos = 0
$nBorrados = 0
$conflictos = @()
# Windows no distingue mayusculas: '*_BACKUP_*.ps1' y '*_backup_*.ps1' casan lo mismo.
# Sin esto un fichero se lista (y se cuenta) dos veces.
$yaPlanificados = New-Object 'System.Collections.Generic.HashSet[string]' ([StringComparer]::OrdinalIgnoreCase)

foreach ($grupo in $plan) {
    $destino = "$archivo\$($grupo.Destino)"
    foreach ($patron in $grupo.Patrones) {
        foreach ($f in @(Get-ChildItem $raiz -File -Filter $patron -ErrorAction SilentlyContinue)) {
            if ($intocables -contains $f.Name) {
                $conflictos += $f.Name
                continue
            }
            if (-not $yaPlanificados.Add($f.Name)) { continue }
            Write-Host ("  {0,-45} -> _ARCHIVO\{1}" -f $f.Name, $grupo.Destino)
            if ($Aplicar) {
                if (-not (Test-Path $destino)) { New-Item -ItemType Directory -Path $destino -Force | Out-Null }
                Move-Item $f.FullName (Join-Path $destino $f.Name) -Force
            }
            $nMovidos++
        }
    }
}

foreach ($d in $carpetasAArchivar) {
    $ruta = "$raiz\$d"
    if (Test-Path $ruta) {
        $mb = [math]::Round((Get-ChildItem $ruta -Recurse -File | Measure-Object Length -Sum).Sum / 1MB, 1)
        Write-Host ("  [carpeta] {0,-35} -> _ARCHIVO\instaladores  ({1} MB)" -f $d, $mb)
        if ($Aplicar) {
            $destino = "$archivo\instaladores"
            if (-not (Test-Path $destino)) { New-Item -ItemType Directory -Path $destino -Force | Out-Null }
            Move-Item $ruta (Join-Path $destino $d) -Force
        }
        $nMovidos++
    }
}

Write-Host ""
foreach ($b in $aBorrar) {
    $ruta = Join-Path $raiz $b
    if (Test-Path $ruta) {
        Write-Host ("  BORRAR  {0}" -f $b) -ForegroundColor Red
        if ($Aplicar) { Remove-Item $ruta -Force }
        $nBorrados++
    }
}

if ($conflictos.Count -gt 0) {
    Write-Host ""
    Write-Host "AVISO: estos ficheros encajaban en un patron pero son INTOCABLES y NO se han movido:" -ForegroundColor Yellow
    $conflictos | Sort-Object -Unique | ForEach-Object { Write-Host "  $_" -ForegroundColor Yellow }
}

# ==========================================================================
Write-Host ""
Write-Host "=== VERIFICACION: siguen ahi los ficheros que el sistema USA? ===" -ForegroundColor Cyan
$faltan = @()
foreach ($n in $intocables) {
    if ($n -eq "LimpiarACTUM.ps1") { continue }
    if (-not (Test-Path (Join-Path $raiz $n))) { $faltan += $n }
}
if ($faltan.Count -eq 0) {
    Write-Host "  Los $($intocables.Count - 1) ficheros activos siguen en su sitio - OK" -ForegroundColor Green
} else {
    Write-Host "  FALTAN: $($faltan -join ', ')" -ForegroundColor Red
    Write-Host "  RECUPERARLOS DE _ARCHIVO INMEDIATAMENTE" -ForegroundColor Red
}

if (Test-Path "$raiz\ACTUM_EPI\Gestion\ACTUM_EPI_Gestion.exe") {
    Write-Host "  ACTUM_EPI (software del fabricante) intacto - OK" -ForegroundColor Green
} else {
    Write-Host "  ACTUM_EPI NO ESTA - PROBLEMA GRAVE" -ForegroundColor Red
}

$despues = @(Get-ChildItem $raiz -File).Count
$despuesDir = @(Get-ChildItem $raiz -Directory).Count
Write-Host ""
if ($Aplicar) {
    Write-Host "HECHO: $nMovidos elementos archivados, $nBorrados borrados" -ForegroundColor Green
    Write-Host "Raiz de C:\ACTUM: $antes -> $despues ficheros, $antesDir -> $despuesDir carpetas" -ForegroundColor Green
    Write-Host ""
    Write-Host "Nada se ha perdido: todo esta en C:\ACTUM\_ARCHIVO\" -ForegroundColor Cyan
    Write-Host "SIGUIENTE PASO: comprobar que el sistema sigue vivo ->  .\GenerarDashboard.ps1" -ForegroundColor Yellow
} else {
    Write-Host "SIMULACION: se archivarian $nMovidos elementos y se borrarian $nBorrados" -ForegroundColor Yellow
    Write-Host "Para hacerlo:  .\LimpiarACTUM.ps1 -Aplicar" -ForegroundColor Yellow
}
Write-Host ""
