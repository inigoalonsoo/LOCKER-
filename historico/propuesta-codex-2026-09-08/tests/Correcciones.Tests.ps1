param([string]$OutputPath = (Join-Path $PSScriptRoot 'resultado.json'))
$ErrorActionPreference = 'Stop'
$repo = Split-Path $PSScriptRoot -Parent
$root = Join-Path ([IO.Path]::GetTempPath()) ('locker-test-' + [guid]::NewGuid().ToString('N'))
[void][IO.Directory]::CreateDirectory($root)
$results = New-Object 'System.Collections.Generic.List[object]'
$cols = 'FechaHoraApertura','Usuario','Apellidos','Consigna','Descripcion','Accion','EstadoPuerta'
function Row($date, $user, $locker) {
    [pscustomobject]@{FechaHoraApertura=$date;Usuario=$user;Apellidos='TEST';Consigna="$locker";Descripcion='Instrumento';Accion=('Extracci'+[char]243+'n');EstadoPuerta='Cerrada'}
}
function Save($path, $rows) { @($rows) | Select-Object $cols | Export-Csv -LiteralPath $path -Delimiter ';' -NoTypeInformation -Encoding UTF8 }
function Check($condition, $message) { if (-not $condition) { throw $message } }
function Case($name, [scriptblock]$body) {
    try { & $body; $results.Add([pscustomobject]@{name=$name;pass=$true;error=''}) }
    catch { $results.Add([pscustomobject]@{name=$name;pass=$false;error=$_.Exception.Message}) }
}
if (Test-Path (Join-Path $repo 'ProteccionHistorial.ps1')) { . (Join-Path $repo 'ProteccionHistorial.ps1') }
function Rebuild($folder, $rows, [switch]$adopt) {
    if (Get-Command Invoke-LockerRebuild -ErrorAction SilentlyContinue) {
        Invoke-LockerRebuild -Folder $folder -AutomaticRows @($rows) -AdoptCurrent:$adopt | Out-Null
    } else {
        # Baseline: execute the real legacy write/merge section, bypassing SQL only.
        $source = [IO.File]::ReadAllText((Join-Path $repo 'ReconstruirHistorial.ps1'))
        $suffix = $source.Substring($source.IndexOf('$archivoCorrecciones ='))
        $carpetaOneDrive = $folder
        $archivoHistorial = Join-Path $folder 'HistorialCompleto.csv'
        $archivoMarcador = Join-Path $folder 'UltimoEventoProcesado.txt'
        $movimientos = @($rows | ForEach-Object { $_ | Select-Object *,@{n='FechaRaw';e={[datetime]::ParseExact($_.FechaHoraApertura,'MM/dd/yyyy HH:mm:ss',[cultureinfo]::InvariantCulture)}} })
        & ([scriptblock]::Create($suffix)) | Out-Null
    }
}
function Fixture($name) {
    $folder = Join-Path $root $name
    [void][IO.Directory]::CreateDirectory($folder)
    Save (Join-Path $folder 'HistorialCompleto.csv') $sql
    [IO.File]::WriteAllText((Join-Path $folder 'UltimoEventoProcesado.txt'),'2026-09-08 10:00:00')
    return $folder
}
$sql = @( (Row '09/08/2026 09:00:00' 'AUTO1' 1), (Row '09/08/2026 10:00:00' 'AUTO2' 2) )
Case 'direct edit survives two rebuilds' {
    $f=Fixture 'edit'; $h=Join-Path $f 'HistorialCompleto.csv'
    $r=@(Import-Csv $h -Delimiter ';' -Encoding UTF8); $r[0].Usuario='MANUAL'; Save $h $r
    Rebuild $f $sql -adopt; Rebuild $f $sql
    Check ((Import-Csv $h -Delimiter ';' -Encoding UTF8)[0].Usuario -ceq 'MANUAL') 'Manual user was overwritten'
}
Case 'deletion survives two rebuilds' {
    $f=Fixture 'delete'; $h=Join-Path $f 'HistorialCompleto.csv'
    Save $h @($sql[1]); Rebuild $f $sql -adopt; Rebuild $f $sql
    Check (@(Import-Csv $h -Delimiter ';').Count -eq 1) 'Deleted movement reappeared'
}
Case 'manual addition survives without advancing SQL marker' {
    $f=Fixture 'add'; $h=Join-Path $f 'HistorialCompleto.csv'
    Save $h @($sql + (Row '10/01/2026 12:00:00' 'MANUAL' 3))
    Rebuild $f $sql -adopt; Rebuild $f $sql
    Check (@(Import-Csv $h -Delimiter ';').Count -eq 3) 'Manual addition lost'
    Check ((Get-Content (Join-Path $f 'UltimoEventoProcesado.txt') -Raw) -eq '2026-09-08 10:00:00') 'Manual date advanced SQL cursor'
}
Case 'invalid correction stops without overwriting history or marker' {
    $f=Fixture 'bad'; $h=Join-Path $f 'HistorialCompleto.csv'; $m=Join-Path $f 'UltimoEventoProcesado.txt'
    $before=(Get-FileHash $h).Hash; $mark=(Get-FileHash $m).Hash
    Save (Join-Path $f 'CorreccionesManuales.csv') @((Row 'bad-date' 'MANUAL' 3))
    $failed=$false; try { Rebuild $f $sql -adopt } catch { $failed=$true }
    Check $failed 'Malformed corrections did not stop rebuild'
    Check (((Get-FileHash $h).Hash -eq $before) -and ((Get-FileHash $m).Hash -eq $mark)) 'Input files changed on error'
}
Case 'initializer preserves existing corrections byte for byte' {
    $f=Fixture 'seed'; $c=Join-Path $f 'CorreccionesManuales.csv'
    Save $c @((Row '09/08/2026 11:00:00' 'CUSTOM' 3)); $before=(Get-FileHash $c).Hash
    $script=[IO.File]::ReadAllText((Join-Path $repo 'CrearCorreccionesManuales.ps1'))
    $script=$script.Replace('C:\Users\User\OneDrive - GHI HORNOS INDUSTRIALES S.L\LockerACTUM',$f)
    # ScriptBlock retains no PSScriptRoot; invoke a copy next to helper in test workspace.
    $copy=Join-Path $f 'CrearCorreccionesManuales.ps1'; [IO.File]::WriteAllText($copy,$script)
    if (Test-Path (Join-Path $repo 'ProteccionHistorial.ps1')) { Copy-Item (Join-Path $repo 'ProteccionHistorial.ps1') $f }
    & $copy | Out-Null
    Check ((Get-FileHash $c).Hash -eq $before) 'Initializer replaced existing corrections'
}
Case 'delete automatic append after adoption remains deleted' {
    $f=Fixture 'append-delete'; $h=Join-Path $f 'HistorialCompleto.csv'
    Rebuild $f $sql -adopt
    $new=Row '09/08/2026 11:00:00' 'AUTO3' 3
    if (Get-Command Save-LockerAutomaticMovements -ErrorAction SilentlyContinue) {
        Save-LockerAutomaticMovements -Folder $f -Rows @($new)
    } else {
        Save $h @($sql + $new)
        [IO.File]::WriteAllText((Join-Path $f 'UltimoEventoProcesado.txt'),'2026-09-08 11:00:00')
    }
    Save $h $sql
    Rebuild $f @($sql + $new); Rebuild $f @($sql + $new)
    Check (@(Import-Csv $h -Delimiter ';').Count -eq 2) 'Deleted automatic append resurrected'
}
Case 'later edit and change of date survive' {
    $f=Fixture 'later-edit'; $h=Join-Path $f 'HistorialCompleto.csv'; Rebuild $f $sql -adopt
    $r=@(Import-Csv $h -Delimiter ';' -Encoding UTF8); $r[0].FechaHoraApertura='09/08/2026 09:01:00'; $r[0].Usuario='changed'; Save $h $r
    Rebuild $f $sql; Rebuild $f $sql
    $r=@(Import-Csv $h -Delimiter ';'); Check ($r.Count -eq 2 -and $r[0].Usuario -ceq 'changed') 'Date/user edit lost'
}
Case 'new SQL event after cursor is recovered' {
    $f=Fixture 'sql-new'; $h=Join-Path $f 'HistorialCompleto.csv'
    $more=@($sql + (Row '09/08/2026 11:00:00' 'AUTO3' 3))
    Rebuild $f $more -adopt; Rebuild $f $more
    Check (@(Import-Csv $h -Delimiter ';').Count -eq 3) 'New SQL event treated as deletion'
}
Case 'preview creates no files and changes no bytes' {
    $f=Fixture 'preview'; $before=@(Get-ChildItem $f | Get-FileHash | ForEach-Object Hash) -join ','
    Invoke-LockerRebuild -Folder $f -AutomaticRows $sql -AdoptCurrent -Preview | Out-Null
    $after=@(Get-ChildItem $f | Get-FileHash | ForEach-Object Hash) -join ','
    Check ($before -ceq $after) 'Preview mutated files'
}
Case 'CSV quotes semicolons accents and multiline survive round trip' {
    $f=Fixture 'quoted'; $h=Join-Path $f 'HistorialCompleto.csv'
    $r=@(Import-Csv $h -Delimiter ';' -Encoding UTF8); $r[0].Descripcion="Medidor; `"especial`"`r`nL"+[char]225+'ser'; Save $h $r
    Rebuild $f $sql -adopt; Rebuild $f $sql
    Check ((Import-Csv $h -Delimiter ';' -Encoding UTF8)[0].Descripcion -ceq $r[0].Descripcion) 'CSV field text changed'
}
Case 'duplicate event identity blocks rewrite' {
    $f=Fixture 'duplicate'; $h=Join-Path $f 'HistorialCompleto.csv'; Save $h @($sql + $sql[0]); $hash=Get-LockerHash $h
    $failed=$false; try { Rebuild $f $sql -adopt } catch { $failed=$true }
    Check ($failed -and (Get-LockerHash $h) -ceq $hash) 'Ambiguous duplicate accepted or history changed'
}
Case 'missing correction file after adoption blocks rewrite' {
    $f=Fixture 'missing-corr'; $h=Join-Path $f 'HistorialCompleto.csv'; $c=Join-Path $f 'CorreccionesManuales.csv'
    Save $c @($sql[0]); Rebuild $f $sql -adopt; [IO.File]::Delete($c); $hash=Get-LockerHash $h
    $failed=$false; try { Rebuild $f $sql } catch { $failed=$true }
    Check ($failed -and (Get-LockerHash $h) -ceq $hash) 'Missing corrections ignored'
}
Case 'header-only history preserves intentional delete all' {
    $f=Fixture 'delete-all'; $h=Join-Path $f 'HistorialCompleto.csv'; Rebuild $f $sql -adopt
    [IO.File]::WriteAllText($h,($cols -join ';')+"`r`n")
    Rebuild $f $sql; Rebuild $f $sql
    Check (@(Read-LockerCsv $h).Count -eq 0) 'Deleted rows resurrected'
}
Case 'empty SQL and corrupt protection state fail closed' {
    $f=Fixture 'bad-state'; $h=Join-Path $f 'HistorialCompleto.csv'; Rebuild $f $sql -adopt; $hash=Get-LockerHash $h
    $emptyFailed=$false; try { Rebuild $f @() } catch { $emptyFailed=$true }
    [IO.File]::WriteAllText((Join-Path $f 'ProteccionHistorial.json'),'{bad')
    $stateFailed=$false; try { Rebuild $f $sql } catch { $stateFailed=$true }
    Check ($emptyFailed -and $stateFailed -and (Get-LockerHash $h) -ceq $hash) 'Invalid source/state mutated history'
}
foreach ($stage in @('ProteccionHistorial.json','HistorialCompleto.csv','UltimoEventoProcesado.txt')) {
    Case "interruption after $stage recovers without loss" {
        $f=Fixture ('crash-'+$stage); $h=Join-Path $f 'HistorialCompleto.csv'
        $r=@(Import-Csv $h -Delimiter ';' -Encoding UTF8); $r[0].Usuario='MANUAL'; Save $h $r
        $realWrite = (Get-Command Write-LockerAtomic).ScriptBlock
        function Write-LockerAtomic([string]$Path,[string]$Text) {
            & $realWrite $Path $Text
            if ([IO.Path]::GetFileName($Path) -ceq $stage) { throw 'SIMULATED INTERRUPTION' }
        }
        $failed=$false
        try { Rebuild $f $sql -adopt } catch { $failed=$_.Exception.Message -like '*SIMULATED INTERRUPTION*' }
        finally { Set-Item Function:Write-LockerAtomic $realWrite }
        Check $failed 'Fault injection did not reach commit'
        $blocked=$false; try { Assert-LockerNoPending $f } catch { $blocked=$true }
        Check $blocked 'Monitor not blocked during interrupted transaction'
        Complete-LockerTransaction $f
        Rebuild $f $sql
        Check ((Import-Csv $h -Delimiter ';')[0].Usuario -ceq 'MANUAL') 'Recovery lost manual edit'
        Check (-not (Test-Path (Join-Path $f 'ReconstruccionPendiente.json'))) 'Pending journal not cleared'
    }
}
Case 'recovery refuses a new human edit after interruption' {
    $f=Fixture 'crash-edit'; $h=Join-Path $f 'HistorialCompleto.csv'
    $realWrite = (Get-Command Write-LockerAtomic).ScriptBlock
    function Write-LockerAtomic([string]$Path,[string]$Text) {
        & $realWrite $Path $Text
        if ([IO.Path]::GetFileName($Path) -ceq 'ProteccionHistorial.json') { throw 'SIMULATED INTERRUPTION' }
    }
    try { Rebuild $f $sql -adopt } catch { } finally { Set-Item Function:Write-LockerAtomic $realWrite }
    $r=@(Import-Csv $h -Delimiter ';'); $r[0].Usuario='NEW-HUMAN'; Save $h $r; $hash=Get-LockerHash $h
    $failed=$false; try { Complete-LockerTransaction $f } catch { $failed=$true }
    Check ($failed -and (Get-LockerHash $h) -ceq $hash) 'Recovery overwrote newer human edit'
}
Case 'mutex excludes a second PowerShell process' {
    $f=Fixture 'mutex'; $lock=Enter-LockerLock $f
    try {
        $job=Start-Job -ScriptBlock {
            param($helper,$folder)
            . $helper
            try { $m=Enter-LockerLock $folder; Exit-LockerLock $m; 'UNEXPECTED-ACCESS' } catch { 'BLOCKED' }
        } -ArgumentList (Join-Path $repo 'ProteccionHistorial.ps1'),$f
        $answer=@(Receive-Job $job -Wait); Remove-Job $job
        Check ($answer -contains 'BLOCKED' -and $answer -notcontains 'UNEXPECTED-ACCESS') 'Concurrent writer obtained lock'
    } finally { Exit-LockerLock $lock }
}
Case 'real reconstruction entry point defaults to preview then applies' {
    $f=Fixture 'entrypoint'; $h=Join-Path $f 'HistorialCompleto.csv'; $hash=Get-LockerHash $h
    $source=[IO.File]::ReadAllText((Join-Path $repo 'ReconstruirHistorial.ps1'))
    $source=$source.Replace('C:\Users\User\OneDrive - GHI HORNOS INDUSTRIALES S.L\LockerACTUM',$f)
    $a=$source.IndexOf('$connectionString ='); $b=$source.IndexOf('$connection.Close()')+'$connection.Close()'.Length
    $fake=@(
        '$dt = New-Object System.Data.DataTable',
        'foreach ($c in @("FechaHora","Consigna_Codigo","Caja_Codigo","Usuario_Codigo","Consigna","EstadoActual","CajaDescripcion","Nombre","Apellidos")) { [void]$dt.Columns.Add($c) }',
        '[void]$dt.Rows.Add("09/08/2026 09:00:00",1,1,1,1,4,"Instrumento","AUTO1","TEST")',
        '[void]$dt.Rows.Add("09/08/2026 10:00:00",2,2,2,2,4,"Instrumento","AUTO2","TEST")'
    ) -join "`r`n"
    $source=$source.Substring(0,$a)+$fake+$source.Substring($b)
    $copy=Join-Path $f 'ReconstruirHistorial.ps1'; [IO.File]::WriteAllText($copy,$source)
    Copy-Item (Join-Path $repo 'ProteccionHistorial.ps1') $f
    & $copy -AdoptarHistorialActual | Out-Null
    Check ((Get-LockerHash $h) -ceq $hash -and -not (Test-Path (Join-Path $f 'ProteccionHistorial.json'))) 'Default command wrote data'
    & $copy -AdoptarHistorialActual -Aplicar | Out-Null
    & $copy -Aplicar | Out-Null
    Check (@(Read-LockerCsv $h).Count -eq 2) 'Reconstruction entrypoint wrong output'
}
Case 'automatic append does not absorb pending manual edits' {
    $f=Fixture 'pending-edit'; $h=Join-Path $f 'HistorialCompleto.csv'; Rebuild $f $sql -adopt
    $r=@(Import-Csv $h -Delimiter ';'); $r[0].Usuario='MANUAL'; Save $h $r
    $new=Row '09/08/2026 11:00:00' 'AUTO3' 3
    Save-LockerAutomaticMovements -Folder $f -Rows @($new)
    Rebuild $f @($sql + $new); Rebuild $f @($sql + $new)
    Check ((Import-Csv $h -Delimiter ';')[0].Usuario -ceq 'MANUAL') 'Monitor absorbed manual edit into automatic baseline'
}
Case 'incomplete transaction journal is rejected and retained' {
    $f=Fixture 'bad-journal'; $j=Join-Path $f 'ReconstruccionPendiente.json'
    [IO.File]::WriteAllText($j,'{"Version":1,"Files":[]}')
    $failed=$false; try { Complete-LockerTransaction $f } catch { $failed=$true }
    Check ($failed -and (Test-Path $j)) 'Incomplete journal silently discarded'
}
Case 'monitor cannot infer cursor from manual future date after marker loss' {
    $f=Fixture 'lost-marker'; $h=Join-Path $f 'HistorialCompleto.csv'
    Save $h @($sql + (Row '10/01/2026 12:00:00' 'MANUAL' 3)); Rebuild $f $sql -adopt
    [IO.File]::Delete((Join-Path $f 'UltimoEventoProcesado.txt'))
    $source=[IO.File]::ReadAllText((Join-Path $repo 'MonitoreoLockerTiempoReal.ps1'))
    $a=$source.IndexOf('$ultimoProcesado = $null'); $b=$source.IndexOf('Write-Host "[EVENTOS] Buscando desde:')
    $carpetaOneDrive=$f; $archivoHistorial=$h; $archivoMarcador=Join-Path $f 'UltimoEventoProcesado.txt'
    # Dot source actual cursor block so resulting cursor remains observable.
    . ([scriptblock]::Create($source.Substring($a,$b-$a)))
    Check ($ultimoProcesado -eq [datetime]'2026-09-08T10:00:00') 'Cursor not recovered from trusted automatic state'
}
$results | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath $OutputPath -Encoding UTF8
$results | Format-Table -AutoSize
Write-Host "Evidence: $root"
if (@($results | Where-Object { -not $_.pass }).Count) { exit 1 }
