# PATCH: Reemplaza la funcion ConvertTo-HtmlEntities con version sin caracteres especiales
# Ejecutar en C:\ACTUM como administrador
# ---------------------------------------------------

$archivo = "C:\ACTUM\GenerarDashboard.ps1"
$contenido = Get-Content $archivo -Raw -Encoding UTF8

$funcionVieja = @'
function ConvertTo-HtmlEntities {
'@

# Buscar inicio y fin de la funcion
$inicio = $contenido.IndexOf("function ConvertTo-HtmlEntities {")
$fin    = $contenido.IndexOf("`n}", $inicio) + 2

if ($inicio -lt 0) {
    Write-Host "No se encontro la funcion - buscando alternativa..."
    # Si no existe, insertar antes de PASO 1
    $inicio = $contenido.IndexOf("# PASO 1:")
    $fin    = $inicio
}

$funcionNueva = @"
function ConvertTo-HtmlEntities {
    param([string]`$text)
    if ([string]::IsNullOrEmpty(`$text)) { return `$text }
    `$text = `$text -replace [char]0xE1, '&aacute;'
    `$text = `$text -replace [char]0xE9, '&eacute;'
    `$text = `$text -replace [char]0xED, '&iacute;'
    `$text = `$text -replace [char]0xF3, '&oacute;'
    `$text = `$text -replace [char]0xFA, '&uacute;'
    `$text = `$text -replace [char]0xF1, '&ntilde;'
    `$text = `$text -replace [char]0xFC, '&uuml;'
    `$text = `$text -replace [char]0xC1, '&Aacute;'
    `$text = `$text -replace [char]0xC9, '&Eacute;'
    `$text = `$text -replace [char]0xCD, '&Iacute;'
    `$text = `$text -replace [char]0xD3, '&Oacute;'
    `$text = `$text -replace [char]0xDA, '&Uacute;'
    `$text = `$text -replace [char]0xD1, '&Ntilde;'
    `$text = `$text -replace [char]0xDC, '&Uuml;'
    return `$text
}

"@

$nuevo = $contenido.Substring(0, $inicio) + $funcionNueva + $contenido.Substring($fin)
$utf8NoBOM = New-Object System.Text.UTF8Encoding $false
[System.IO.File]::WriteAllText($archivo, $nuevo, $utf8NoBOM)

Write-Host "Patch aplicado OK. Verificando sintaxis..." -ForegroundColor Green
& powershell.exe -NoProfile -NonInteractive -Command "Get-Command '$archivo' -ErrorAction SilentlyContinue; `$null = [System.Management.Automation.Language.Parser]::ParseFile('$archivo', [ref]`$null, [ref]`$null); Write-Host 'Sintaxis OK'" 2>&1
Write-Host "Ejecutando dashboard..." -ForegroundColor Cyan
& "C:\ACTUM\GenerarDashboard.ps1"
