$ErrorActionPreference = 'Stop'
$repo = Split-Path $PSScriptRoot -Parent
$testRoot = Join-Path ([IO.Path]::GetTempPath()) ('locker-backup-tests-' + [guid]::NewGuid().ToString('N'))
[void][IO.Directory]::CreateDirectory($testRoot)
$results = @()
function Check($ok,$message) { if (-not $ok) { throw $message } }
foreach ($case in @('copies-and-verifies','refuses-existing-destination','refuses-destination-inside-source','requires-history-and-marker','preserves-binary-and-unicode-data')) {
    try {
        $base=Join-Path $testRoot $case
        $scripts=Join-Path $base 'scripts'; $data=Join-Path $base 'data'; $dest=Join-Path $base 'backup'
        [void][IO.Directory]::CreateDirectory($scripts); [void][IO.Directory]::CreateDirectory($data)
        [IO.File]::WriteAllText((Join-Path $scripts 'Monitor.ps1'),'# original')
        [IO.File]::WriteAllText((Join-Path $data 'HistorialCompleto.csv'),'header')
        [IO.File]::WriteAllText((Join-Path $data 'UltimoEventoProcesado.txt'),'2026-09-08 10:00:00')
        if (Test-Path (Join-Path $repo 'RespaldarLockerAntesCambios.ps1')) { . (Join-Path $repo 'RespaldarLockerAntesCambios.ps1') }
        if (-not (Get-Command Copy-LockerSnapshot -ErrorAction SilentlyContinue)) { throw 'No existe un respaldo completo con verificacion; BackupHistorial.ps1 solo copia el historial.' }
        if ($case -eq 'refuses-existing-destination') {
            [void][IO.Directory]::CreateDirectory($dest); [IO.File]::WriteAllText((Join-Path $dest 'keep'),'untouched')
            $failed=$false; try { Copy-LockerSnapshot $scripts $data $dest } catch { $failed=$true }
            Check ($failed -and [IO.File]::ReadAllText((Join-Path $dest 'keep')) -eq 'untouched') 'Existing backup overwritten'
        } elseif ($case -eq 'refuses-destination-inside-source') {
            $failed=$false; try { Copy-LockerSnapshot $scripts $data (Join-Path $data 'backup') } catch { $failed=$true }
            Check $failed 'Recursive self-copy accepted'
        } elseif ($case -eq 'requires-history-and-marker') {
            [IO.File]::Delete((Join-Path $data 'UltimoEventoProcesado.txt'))
            $failed=$false; try { Copy-LockerSnapshot $scripts $data $dest } catch { $failed=$true }
            Check $failed 'Missing marker accepted'
        } else {
            if ($case -eq 'preserves-binary-and-unicode-data') {
                [void][IO.Directory]::CreateDirectory((Join-Path $data 'nested'))
                [IO.File]::WriteAllBytes((Join-Path $data 'nested\binary.bin'),[byte[]](0,1,127,128,255))
                [IO.File]::WriteAllText((Join-Path $data 'nested\text.txt'),('Correcci'+[char]243+'n'))
            }
            $result=Copy-LockerSnapshot $scripts $data $dest
            $expected=if($case -eq 'copies-and-verifies'){3}else{5}
            Check ($result.Files -eq $expected -and $result.Verified -eq $expected) 'Incorrect verified count'
            $manifest=@(Get-Content (Join-Path $dest 'MANIFIESTO.csv') | ConvertFrom-Csv -Delimiter ';')
            foreach($entry in $manifest){Check ((Get-FileHash -LiteralPath $entry.Source).Hash -eq (Get-FileHash -LiteralPath (Join-Path $dest $entry.Relative)).Hash) 'Hash mismatch'}
        }
        $results += [pscustomobject]@{name=$case;pass=$true;error=''}
    } catch { $results += [pscustomobject]@{name=$case;pass=$false;error=$_.Exception.Message} }
}
foreach($case in @('tasks-restored-on-success','tasks-restored-on-copy-failure','original-disabled-task-stays-disabled','unreadable-process-blocks-backup','waits-for-cmd-wrapper')) {
    try {
        $base=Join-Path $testRoot $case;$scripts=Join-Path $base 'scripts';$data=Join-Path $base 'data';$dest=Join-Path $base 'backups'
        [void][IO.Directory]::CreateDirectory($scripts);[void][IO.Directory]::CreateDirectory($data)
        [IO.File]::WriteAllText((Join-Path $scripts 'Monitor.ps1'),'# original')
        [IO.File]::WriteAllText((Join-Path $data 'HistorialCompleto.csv'),'header')
        [IO.File]::WriteAllText((Join-Path $data 'UltimoEventoProcesado.txt'),'2026-09-08 10:00:00')
        $fakeTasks=@(
            [pscustomobject]@{TaskName='MonitoreoLockerTiempoReal';TaskPath='\';Settings=[pscustomobject]@{Enabled=$true};Actions=@()},
            [pscustomobject]@{TaskName='ReconstruirCSVSemanal';TaskPath='\';Settings=[pscustomobject]@{Enabled=$false};Actions=@()}
        )
        function Get-ScheduledTask($TaskName,$TaskPath){if($TaskName){$fakeTasks | Where-Object TaskName -eq $TaskName}else{$fakeTasks}}
        function Disable-ScheduledTask($TaskName,$TaskPath){($fakeTasks | Where-Object TaskName -eq $TaskName).Settings.Enabled=$false}
        function Enable-ScheduledTask($TaskName,$TaskPath){($fakeTasks | Where-Object TaskName -eq $TaskName).Settings.Enabled=$true}
        function Export-ScheduledTask($TaskName,$TaskPath){'<Task />'}
        $script:backupPolls=0;$script:backupSleeps=0
        function Start-Sleep($Seconds){$script:backupSleeps++}
        function Get-CimInstance($ClassName){
            $script:backupPolls++
            if($case -eq 'unreadable-process-blocks-backup'){[pscustomobject]@{ProcessId=999999;Name='powershell.exe';CommandLine=$null}}
            elseif($case -eq 'waits-for-cmd-wrapper' -and $script:backupPolls -eq 1){[pscustomobject]@{ProcessId=999999;Name='cmd.exe';CommandLine=('cmd.exe /c '+$scripts+'\wrapper.cmd')}}
            else {@()}
        }
        $realCopy=(Get-Command Copy-LockerSnapshot).ScriptBlock
        if($case -eq 'tasks-restored-on-copy-failure'){
            function Copy-LockerSnapshot {throw 'SIMULATED COPY FAILURE'}
        }
        $failed=$false
        try {Invoke-LockerBackup $scripts $data $dest | Out-Null} catch {$failed=$true}
        finally {Set-Item Function:Copy-LockerSnapshot $realCopy}
        Check ($fakeTasks[0].Settings.Enabled -and -not $fakeTasks[1].Settings.Enabled) 'Task states not restored'
        $report=Get-ChildItem $dest -Filter RESULTADO.json -Recurse | Select-Object -First 1
        $read=Get-Content -LiteralPath $report.FullName -Raw -Encoding UTF8 | ConvertFrom-Json
        Check $read.TasksRestored 'Task restoration not verified'
        if($case -in @('tasks-restored-on-copy-failure','unreadable-process-blocks-backup')){Check ($failed -and -not $read.PASS) 'Failure reported as PASS'}
        else {Check (-not $failed -and $read.PASS) 'Successful backup not verified'}
        if($case -eq 'waits-for-cmd-wrapper'){Check ($script:backupPolls -ge 3 -and $script:backupSleeps -ge 2) 'Did not wait for cmd wrapper and quiet period'}
        $results += [pscustomobject]@{name=$case;pass=$true;error=''}
    } catch {$results += [pscustomobject]@{name=$case;pass=$false;error=$_.Exception.Message}}
}
$results | ConvertTo-Json | Set-Content (Join-Path $PSScriptRoot 'respaldo-resultado.json') -Encoding UTF8
$results | Format-Table -AutoSize
if (@($results | Where-Object {-not $_.pass}).Count) { exit 1 }
