param([string]$ScriptFolder = $PSScriptRoot)
$ErrorActionPreference = 'Stop'
$manifest = Get-Content -LiteralPath (Join-Path $PSScriptRoot 'SHA256.json') -Raw -Encoding UTF8 | ConvertFrom-Json
$results = @()
foreach ($entry in $manifest) {
    $path = Join-Path $ScriptFolder $entry.File
    $text = [IO.File]::ReadAllText($path).Replace("`r`n","`n")
    $sha = [Security.Cryptography.SHA256]::Create()
    try { $hash = [BitConverter]::ToString($sha.ComputeHash([Text.Encoding]::UTF8.GetBytes($text))).Replace('-','').ToLowerInvariant() }
    finally { $sha.Dispose() }
    $tokens=$null; $errors=$null
    [void][Management.Automation.Language.Parser]::ParseFile($path,[ref]$tokens,[ref]$errors)
    $nonAscii = @($text.ToCharArray() | Where-Object { [int]$_ -gt 127 }).Count
    $results += [pscustomobject]@{File=$entry.File;SHA256=$hash;Match=($hash -ceq $entry.SHA256Normalized);SyntaxErrors=@($errors).Count;NonASCII=$nonAscii}
}
$results | Format-Table -AutoSize
if (@($results | Where-Object { -not $_.Match -or $_.SyntaxErrors -or $_.NonASCII }).Count) { throw 'Entrega diferente o invalida; no ejecutar los scripts.' }
Write-Host "Verificados $($results.Count)/$($manifest.Count) scripts. Sin ejecutar SQL ni modificar datos."
