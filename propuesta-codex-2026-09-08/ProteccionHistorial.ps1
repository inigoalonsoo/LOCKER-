# Shared by reconstruction, initializer and monitor. Windows PowerShell 5.1; ASCII source.
# State stores manual upserts/deletions and the last materialized history.
# Do not edit or delete ProteccionHistorial.json: it remembers intentional deletions.
$script:LockerColumns = @('FechaHoraApertura','Usuario','Apellidos','Consigna','Descripcion','Accion','EstadoPuerta')

function Enter-LockerLock([string]$Folder) {
    $sha = [Security.Cryptography.SHA256]::Create()
    try { $id = [BitConverter]::ToString($sha.ComputeHash([Text.Encoding]::UTF8.GetBytes([IO.Path]::GetFullPath($Folder).TrimEnd('\').ToUpperInvariant()))).Replace('-','') }
    finally { $sha.Dispose() }
    $mutex = New-Object Threading.Mutex($false, ('Global\GHI-Locker-' + $id))
    $owned = $false
    try {
        try { $owned = $mutex.WaitOne(0) } catch [Threading.AbandonedMutexException] { $owned = $true }
        if (-not $owned) { throw 'Otro proceso esta usando el historial. Reintentar despues.' }
        return $mutex
    } catch { $mutex.Dispose(); throw }
}
function Exit-LockerLock($Mutex) { $Mutex.ReleaseMutex(); $Mutex.Dispose() }
function Assert-LockerNoPending([string]$Folder) {
    if (Test-Path -LiteralPath (Join-Path $Folder 'ReconstruccionPendiente.json')) {
        throw 'Transaccion interrumpida: ejecutar ReconstruirHistorial.ps1 -RecuperarTransaccion antes de continuar.'
    }
}
function Get-LockerHash([string]$Path) {
    if (-not [IO.File]::Exists($Path)) { return 'ABSENT' }
    return (Get-FileHash -LiteralPath $Path -Algorithm SHA256 -ErrorAction Stop).Hash
}
function ConvertTo-LockerRow($Row) {
    $record = [ordered]@{}
    foreach ($col in $script:LockerColumns) {
        if ($null -eq $Row.PSObject.Properties[$col]) { throw "Falta columna: $col" }
        $record[$col] = [string]$Row.$col
    }
    [void][datetime]::ParseExact($record.FechaHoraApertura,'MM/dd/yyyy HH:mm:ss',[cultureinfo]::InvariantCulture)
    if ($record.Consigna -notmatch '^\d+$' -or [int]$record.Consigna -le 0 -or [int]$record.Consigna -eq 100) { throw 'Consigna invalida' }
    if ($record.Accion -cnotin @('Extraccion','Devolucion',('Extracci'+[char]243+'n'),('Devoluci'+[char]243+'n'))) { throw 'Accion invalida' }
    if ($record.EstadoPuerta -cnotin @('Cerrada','Abierta')) { throw 'EstadoPuerta invalido' }
    return [pscustomobject]$record
}
function Get-LockerKey($Row) {
    $date = [datetime]::ParseExact($Row.FechaHoraApertura,'MM/dd/yyyy HH:mm:ss',[cultureinfo]::InvariantCulture)
    return ($date.ToString('yyyyMMddHHmmss') + '|' + [int]$Row.Consigna)
}
function Get-LockerMap($Rows) {
    $map = @{}
    foreach ($row in @($Rows)) {
        $r = ConvertTo-LockerRow $row
        $key = Get-LockerKey $r
        if ($map.ContainsKey($key)) { throw "Movimiento ambiguo/duplicado (fecha+consigna): $key" }
        $map[$key] = $r
    }
    return $map
}
function Test-LockerEqual($A, $B) {
    return (($A | Select-Object $script:LockerColumns | ConvertTo-Json -Compress) -ceq ($B | Select-Object $script:LockerColumns | ConvertTo-Json -Compress))
}
function Read-LockerCsv([string]$Path) {
    # Strict UTF8 and strict CSV field count; Import-Csv alone accepts truncated rows.
    Add-Type -AssemblyName Microsoft.VisualBasic
    $utf8 = New-Object Text.UTF8Encoding($false,$true)
    $text = [IO.File]::ReadAllText($Path,$utf8)
    if ($text.Contains([string][char]0)) { throw "Bytes NULL en $Path" }
    $reader = New-Object IO.StringReader($text.TrimStart([char]0xFEFF))
    $parser = New-Object Microsoft.VisualBasic.FileIO.TextFieldParser($reader)
    $parser.SetDelimiters(';'); $parser.HasFieldsEnclosedInQuotes = $true; $parser.TrimWhiteSpace = $false
    try {
        $headers = $parser.ReadFields()
        if ($null -eq $headers -or $headers.Count -notin @(7,8)) { throw "Cabecera invalida: $Path" }
        if (($headers[0..6] -join ';') -cne ($script:LockerColumns -join ';')) { throw "Columnas invalidas: $Path" }
        if ($headers.Count -eq 8 -and $headers[7] -cne 'Motivo') { throw "Columna extra invalida: $Path" }
        while (-not $parser.EndOfData) {
            $fields = $parser.ReadFields()
            if ($fields.Count -ne $headers.Count) { throw "Fila incompleta en $Path" }
            $row = [ordered]@{}
            for ($i=0; $i -lt 7; $i++) { $row[$headers[$i]] = $fields[$i] }
            ConvertTo-LockerRow ([pscustomobject]$row)
        }
    } finally { $parser.Dispose(); $reader.Dispose() }
}
function ConvertTo-LockerCsv($Rows) {
    $lines = @($Rows | Select-Object $script:LockerColumns | ConvertTo-Csv -NoTypeInformation -Delimiter ';')
    if ($lines.Count -eq 0) { $lines = @($script:LockerColumns -join ';') }
    return (($lines -join "`r`n") + "`r`n")
}
function Write-LockerAtomic([string]$Path, [string]$Text) {
    $temp = $Path + '.' + [guid]::NewGuid().ToString('N') + '.tmp'
    [IO.File]::WriteAllText($temp,$Text,(New-Object Text.UTF8Encoding($false)))
    if ([IO.File]::Exists($Path)) { [IO.File]::Replace($temp,$Path,[NullString]::Value) }
    else { [IO.File]::Move($temp,$Path) }
}
function Complete-LockerTransaction([string]$Folder) {
    $pending = Join-Path $Folder 'ReconstruccionPendiente.json'
    $journal = [IO.File]::ReadAllText($pending) | ConvertFrom-Json -ErrorAction Stop
    if ($journal.Version -ne 1 -or @($journal.Files).Count -notin @(2,3) -or [string]::IsNullOrWhiteSpace($journal.Backup)) { throw 'Transaccion incompleta o version invalida' }
    $backupRoot = [IO.Path]::GetFullPath((Join-Path $Folder 'BackupsCorrecciones')).TrimEnd('\') + '\'
    if (-not [IO.Path]::GetFullPath($journal.Backup).StartsWith($backupRoot,[StringComparison]::OrdinalIgnoreCase)) { throw 'Backup fuera de la carpeta de proteccion' }
    $names = @($journal.Files | ForEach-Object Name)
    if (@($names | Select-Object -Unique).Count -ne $names.Count -or $names -cnotcontains 'HistorialCompleto.csv' -or $names -cnotcontains 'UltimoEventoProcesado.txt') { throw 'Destinos de transaccion incompletos' }
    foreach ($entry in $journal.Files) {
        if ($entry.Name -cnotin @('HistorialCompleto.csv','ProteccionHistorial.json','UltimoEventoProcesado.txt')) { throw 'Destino de transaccion invalido' }
        $target = Join-Path $Folder $entry.Name
        $staged = Join-Path $journal.Backup ('NEW_' + $entry.Name)
        if ((Get-LockerHash $staged) -cne $entry.After) { throw 'Copia preparada corrupta; restaurar desde backup con revision humana' }
        if ((Get-LockerHash $target) -cnotin @($entry.Before,$entry.After)) { throw "$target cambio despues de la interrupcion. No se sobrescribe." }
    }
    foreach ($entry in $journal.Files) {
        Write-LockerAtomic (Join-Path $Folder $entry.Name) ([IO.File]::ReadAllText((Join-Path $journal.Backup ('NEW_' + $entry.Name))))
    }
    foreach ($entry in $journal.Files) {
        if ((Get-LockerHash (Join-Path $Folder $entry.Name)) -cne $entry.After) { throw 'Verificacion de transaccion fallida' }
    }
    [IO.File]::Delete($pending)
    Write-Host "[PROTECCION] Transaccion verificada. Backup: $($journal.Backup)"
}
function Invoke-LockerRebuild {
    param([string]$Folder, [object[]]$AutomaticRows, [switch]$AdoptCurrent, [switch]$Preview)
    $ErrorActionPreference = 'Stop'
    Assert-LockerNoPending $Folder
    $history = Join-Path $Folder 'HistorialCompleto.csv'
    $corrections = Join-Path $Folder 'CorreccionesManuales.csv'
    $statePath = Join-Path $Folder 'ProteccionHistorial.json'
    $marker = Join-Path $Folder 'UltimoEventoProcesado.txt'
    $inputs = @{}
    foreach ($path in @($history,$corrections,$statePath,$marker)) { $inputs[$path] = Get-LockerHash $path }
    $automatic = Get-LockerMap $AutomaticRows
    if ($automatic.Count -eq 0) { throw 'SQL sin movimientos: se cancela para no vaciar el historial.' }
    $current = Get-LockerMap @(Read-LockerCsv $history)
    $base = @{}; foreach ($key in $automatic.Keys) { $base[$key] = $automatic[$key] }
    $hasCorrections = [IO.File]::Exists($corrections)
    if ($hasCorrections) {
        $corr = Get-LockerMap @(Read-LockerCsv $corrections)
        foreach ($key in $corr.Keys) { $base[$key] = $corr[$key] }
    }
    $overrides = @{}; $deleted = @{}
    if ([IO.File]::Exists($statePath)) {
        if ($AdoptCurrent) { throw 'Proteccion ya inicializada. No volver a adoptar.' }
        $state = [IO.File]::ReadAllText($statePath) | ConvertFrom-Json
        if ($state.Version -ne 1 -or $null -eq $state.LastOutput -or $null -eq $state.Upserts -or $null -eq $state.Deleted) { throw 'Estado de proteccion invalido' }
        if ($state.HadCorrections -and -not $hasCorrections) { throw 'Falta CorreccionesManuales.csv; restaurarlo antes de reconstruir.' }
        $previous = Get-LockerMap @($state.LastOutput)
        $overrides = Get-LockerMap @($state.Upserts)
        foreach ($key in $state.Deleted) {
            if ($key -notmatch '^\d{14}\|\d+$') { throw 'Clave de borrado invalida' }
            $deleted[$key] = $true
        }
    } else {
        if (-not $AdoptCurrent) { throw 'Primera vez: revisar la previsualizacion con -AdoptarHistorialActual. Aplicar solo si el historial actual es el que desea conservar.' }
        $cutoff = [datetime]::ParseExact([IO.File]::ReadAllText($marker).Trim(),'yyyy-MM-dd HH:mm:ss',[cultureinfo]::InvariantCulture)
        $previous = @{}
        # Missing SQL events newer than the processed cursor are new, not manual deletions.
        foreach ($key in $base.Keys) {
            $date = [datetime]::ParseExact($base[$key].FechaHoraApertura,'MM/dd/yyyy HH:mm:ss',[cultureinfo]::InvariantCulture)
            if ($date -le $cutoff) { $previous[$key] = $base[$key] }
        }
    }
    foreach ($key in $previous.Keys) {
        if (-not $current.ContainsKey($key)) { $deleted[$key] = $true; $overrides.Remove($key) }
    }
    foreach ($key in $current.Keys) {
        if (-not $previous.ContainsKey($key) -or -not (Test-LockerEqual $current[$key] $previous[$key])) {
            $deleted.Remove($key)
            # Identical automatic appends need no permanent manual override.
            if ($base.ContainsKey($key) -and (Test-LockerEqual $current[$key] $base[$key])) { $overrides.Remove($key) }
            else { $overrides[$key] = $current[$key] }
        }
    }
    foreach ($key in $deleted.Keys) { $base.Remove($key) }
    foreach ($key in $overrides.Keys) { $base[$key] = $overrides[$key] }
    $output = @($base.Values | Sort-Object { Get-LockerKey $_ })
    $newMarker = ($automatic.Values | ForEach-Object { [datetime]::ParseExact($_.FechaHoraApertura,'MM/dd/yyyy HH:mm:ss',[cultureinfo]::InvariantCulture) } | Sort-Object | Select-Object -Last 1).ToString('yyyy-MM-dd HH:mm:ss')
    $details = @()
    foreach ($key in @($overrides.Keys | Sort-Object)) {
        $r = $overrides[$key]
        $details += [pscustomobject]@{Operacion='CONSERVAR';Clave=$key;Usuario=$r.Usuario;Accion=$r.Accion;Descripcion=$r.Descripcion}
    }
    foreach ($key in @($deleted.Keys | Sort-Object)) {
        $details += [pscustomobject]@{Operacion='BORRADO';Clave=$key;Usuario='';Accion='';Descripcion='No reaparecera desde SQL'}
    }
    $result = [pscustomobject]@{Before=$current.Count;After=$output.Count;Upserts=$overrides.Count;Deleted=$deleted.Count;Marker=$newMarker;Preview=[bool]$Preview;Details=$details}
    if ($Preview) { return $result }
    $newState = [ordered]@{Version=1;SqlMarker=$newMarker;HadCorrections=$hasCorrections;LastOutput=$output;Upserts=@($overrides.Values);Deleted=@($deleted.Keys)}
    $texts = [ordered]@{
        'ProteccionHistorial.json'=($newState | ConvertTo-Json -Depth 12)
        'HistorialCompleto.csv'=(ConvertTo-LockerCsv $output)
        'UltimoEventoProcesado.txt'=$newMarker
    }
    Write-LockerTransaction -Folder $Folder -Texts $texts -Inputs $inputs
    return $result
}
function Write-LockerTransaction {
    param([string]$Folder, $Texts, $Inputs)
    $backup = Join-Path $Folder ('BackupsCorrecciones\' + (Get-Date -Format 'yyyyMMdd_HHmmss') + '_' + [guid]::NewGuid().ToString('N'))
    [void][IO.Directory]::CreateDirectory($backup)
    foreach ($path in $inputs.Keys) {
        if ($inputs[$path] -ne 'ABSENT') { [IO.File]::Copy($path,(Join-Path $backup ([IO.Path]::GetFileName($path)))) }
    }
    $entries = @()
    foreach ($name in $texts.Keys) {
        $staged = Join-Path $backup ('NEW_' + $name)
        [IO.File]::WriteAllText($staged,$texts[$name],(New-Object Text.UTF8Encoding($false)))
        $entries += [pscustomobject]@{Name=$name;Before=$inputs[(Join-Path $Folder $name)];After=(Get-LockerHash $staged)}
    }
    # Detect input changes during preparation. Editors must be closed during commit.
    foreach ($path in $inputs.Keys) {
        if ((Get-LockerHash $path) -cne $inputs[$path]) { throw "$path cambio durante la reconstruccion. Reintentar." }
    }
    $journal = [ordered]@{Version=1;Backup=$backup;Files=$entries}
    Write-LockerAtomic (Join-Path $Folder 'ReconstruccionPendiente.json') ($journal | ConvertTo-Json -Depth 5)
    Complete-LockerTransaction $Folder
}
function Save-LockerAutomaticMovements {
    param([string]$Folder, [object[]]$Rows)
    $ErrorActionPreference = 'Stop'
    Assert-LockerNoPending $Folder
    if ($Rows.Count -eq 0) { return }
    $history = Join-Path $Folder 'HistorialCompleto.csv'
    $statePath = Join-Path $Folder 'ProteccionHistorial.json'
    $marker = Join-Path $Folder 'UltimoEventoProcesado.txt'
    $inputs = @{}
    foreach ($path in @($history,$statePath,$marker)) { $inputs[$path] = Get-LockerHash $path }
    $current = @()
    if ([IO.File]::Exists($history)) { $current = @(Read-LockerCsv $history) }
    $added = @(Get-LockerMap $Rows).Values
    $combined = @($current) + @($added)
    [void](Get-LockerMap $combined)
    $newMarker = ($Rows | ForEach-Object { [datetime]::ParseExact($_.FechaHoraApertura,'MM/dd/yyyy HH:mm:ss',[cultureinfo]::InvariantCulture) } | Sort-Object | Select-Object -Last 1).ToString('yyyy-MM-dd HH:mm:ss')
    $texts = [ordered]@{
        'HistorialCompleto.csv'=(ConvertTo-LockerCsv $combined)
        'UltimoEventoProcesado.txt'=$newMarker
    }
    if ([IO.File]::Exists($statePath)) {
        $state = [IO.File]::ReadAllText($statePath) | ConvertFrom-Json
        if ($state.Version -ne 1 -or $null -eq $state.LastOutput -or $null -eq $state.Upserts -or $null -eq $state.Deleted) { throw 'Estado de proteccion invalido' }
        $previous = Get-LockerMap @($state.LastOutput)
        # Record only automatic appends; never absorb an unrecorded manual edit into baseline.
        foreach ($row in $added) {
            $key = Get-LockerKey $row
            if ($previous.ContainsKey($key)) { throw "Evento ya registrado: $key. Revisar marcador." }
            $previous[$key] = $row
        }
        $state.LastOutput = @($previous.Values)
        $state.SqlMarker = $newMarker
        $texts['ProteccionHistorial.json'] = $state | ConvertTo-Json -Depth 12
    }
    Write-LockerTransaction -Folder $Folder -Texts $texts -Inputs $inputs
}
