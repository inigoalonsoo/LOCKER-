# Run only on GHI-TAQUILLAS, as administrator. No deployment, deletion or SQL.
# Tasks are restored to their initial enabled/disabled state, even after failure.
function Get-LockerBackupFiles([string]$Scripts, [string]$Data) {
    foreach ($f in @(Get-ChildItem -LiteralPath $Scripts -File -Force -ErrorAction Stop)) {
        if ($f.Extension -in @('.ps1','.vbs','.bat','.cmd','.json','.txt','.config')) {
            [pscustomobject]@{Source=$f.FullName;Relative=('Scripts\'+$f.Name)}
        }
    }
    foreach ($f in @(Get-ChildItem -LiteralPath $Data -File -Recurse -Force -ErrorAction Stop)) {
        [pscustomobject]@{Source=$f.FullName;Relative=('Datos\'+$f.FullName.Substring($Data.TrimEnd('\').Length+1))}
    }
}
function Copy-LockerSnapshot([string]$Scripts,[string]$Data,[string]$Destination) {
    $ErrorActionPreference='Stop'
    $Scripts=[IO.Path]::GetFullPath($Scripts).TrimEnd('\')
    $Data=[IO.Path]::GetFullPath($Data).TrimEnd('\')
    $Destination=[IO.Path]::GetFullPath($Destination).TrimEnd('\')
    foreach($source in @($Scripts,$Data)) {
        if($Destination.Equals($source,[StringComparison]::OrdinalIgnoreCase) -or $Destination.StartsWith($source+'\',[StringComparison]::OrdinalIgnoreCase)) { throw 'Destino dentro del origen: se cancela.' }
    }
    if(Test-Path -LiteralPath $Destination) { throw 'El destino ya existe; no se sobrescribe.' }
    foreach($name in @('HistorialCompleto.csv','UltimoEventoProcesado.txt')) {
        if(-not [IO.File]::Exists((Join-Path $Data $name))) { throw "Falta $name en $Data" }
    }
    $files=@(Get-LockerBackupFiles $Scripts $Data)
    if(@($files | Where-Object {$_.Relative -like 'Scripts\*'}).Count -eq 0) { throw 'No se encontraron scripts.' }
    [void][IO.Directory]::CreateDirectory($Destination)
    $manifest=@()
    foreach($f in $files) {
        $target=Join-Path $Destination $f.Relative
        [void][IO.Directory]::CreateDirectory([IO.Path]::GetDirectoryName($target))
        $before=(Get-FileHash -LiteralPath $f.Source -Algorithm SHA256).Hash
        [IO.File]::Copy($f.Source,$target,$false)
        $manifest += [pscustomobject]@{Source=$f.Source;Relative=$f.Relative;Bytes=(Get-Item -LiteralPath $target).Length;SHA256=$before}
    }
    $after=@(Get-LockerBackupFiles $Scripts $Data | ForEach-Object Source | Sort-Object)
    $beforeNames=@($files | ForEach-Object Source | Sort-Object)
    if(($after -join "`n") -cne ($beforeNames -join "`n")) { throw 'Cambio la lista de archivos mientras se copiaba; respaldo no valido.' }
    foreach($entry in $manifest) {
        $sourceHash=(Get-FileHash -LiteralPath $entry.Source -Algorithm SHA256).Hash
        $copyHash=(Get-FileHash -LiteralPath (Join-Path $Destination $entry.Relative) -Algorithm SHA256).Hash
        if($sourceHash -cne $entry.SHA256 -or $copyHash -cne $entry.SHA256) { throw "Cambio o copia diferente: $($entry.Source)" }
    }
    $manifest | Export-Csv -LiteralPath (Join-Path $Destination 'MANIFIESTO.csv') -Delimiter ';' -NoTypeInformation -Encoding UTF8
    [pscustomobject]@{Files=$manifest.Count;Verified=$manifest.Count;Bytes=($manifest | Measure-Object Bytes -Sum).Sum;Path=$Destination}
}
function Invoke-LockerBackup([string]$Scripts,[string]$Data,[string]$BackupRoot) {
    $ErrorActionPreference='Stop'
    $tasks=@(Get-ScheduledTask | Where-Object {
        $actions=($_.Actions | ForEach-Object { $_.Execute+' '+$_.Arguments }) -join ' '
        $actions -match [regex]::Escape($Scripts.TrimEnd('\')+'\') -or $_.TaskName -in @('MonitoreoLockerTiempoReal','ReconstruirCSVSemanal','GenerarDashboardHTML','GenerarDashboardAdmin','ActualizarExcel')
    })
    if(@($tasks | Where-Object TaskName -eq 'MonitoreoLockerTiempoReal').Count -ne 1) { throw 'No se identifica una unica tarea MonitoreoLockerTiempoReal. No se ha pausado nada.' }
    foreach($required in @($Scripts,$Data,(Join-Path $Data 'HistorialCompleto.csv'),(Join-Path $Data 'UltimoEventoProcesado.txt'))) {
        if(-not(Test-Path -LiteralPath $required)){throw "No existe: $required"}
    }
    $run=Join-Path $BackupRoot ((Get-Date -Format 'yyyyMMdd_HHmmss')+'_'+[guid]::NewGuid().ToString('N').Substring(0,8))
    [void][IO.Directory]::CreateDirectory((Join-Path $run 'Tareas'))
    $states=@();$index=0
    foreach($task in $tasks) {
        $states += [pscustomobject]@{TaskName=$task.TaskName;TaskPath=$task.TaskPath;Enabled=[bool]$task.Settings.Enabled}
        Export-ScheduledTask -TaskName $task.TaskName -TaskPath $task.TaskPath | Set-Content -LiteralPath (Join-Path $run ('Tareas\'+$index+'.xml')) -Encoding Unicode
        $index++
    }
    $states | ConvertTo-Json | Set-Content -LiteralPath (Join-Path $run 'ESTADO_TAREAS_ANTES.json') -Encoding UTF8
    $failure=$null;$snapshot=$null;$restoreErrors=@()
    try {
        foreach($state in $states) {
            if($state.Enabled) { Disable-ScheduledTask -TaskName $state.TaskName -TaskPath $state.TaskPath | Out-Null }
        }
        foreach($state in $states) {
            if((Get-ScheduledTask -TaskName $state.TaskName -TaskPath $state.TaskPath).Settings.Enabled) { throw "Tarea no pausada: $($state.TaskName)" }
        }
        # VBS wrappers return before their child PowerShell process finishes.
        $names=@(Get-ChildItem -LiteralPath $Scripts -File | Where-Object {$_.Extension -in @('.ps1','.vbs','.bat','.cmd')} | ForEach-Object {[regex]::Escape($_.Name)})
        $pattern=([regex]::Escape($Scripts.TrimEnd('\')+'\'))
        if($names.Count){$pattern+='|'+($names -join '|')}
        $deadline=(Get-Date).AddSeconds(60);$quietPolls=0
        do {
            $hosts=@(Get-CimInstance Win32_Process | Where-Object {
                $_.ProcessId -ne $PID -and $_.Name -in @('powershell.exe','pwsh.exe','wscript.exe','cscript.exe','cmd.exe')
            })
            if(@($hosts | Where-Object {[string]::IsNullOrWhiteSpace($_.CommandLine)}).Count){throw 'Hay procesos de scripts con CommandLine ilegible; no se puede confirmar que terminaron.'}
            $running=@($hosts | Where-Object {$_.CommandLine -match $pattern})
            $runningTasks=@($states | Where-Object {(Get-ScheduledTask -TaskName $_.TaskName -TaskPath $_.TaskPath).State -eq 'Running'})
            if(-not $running.Count -and -not $runningTasks.Count){$quietPolls++}else{$quietPolls=0}
            if($quietPolls -ge 2){break}
            if((Get-Date) -ge $deadline){throw ('Procesos aun activos: '+(($running | ForEach-Object ProcessId) -join ', ')+'. No se han terminado a la fuerza.')}
            Start-Sleep -Seconds 2
        } while($true)
        $snapshot=Copy-LockerSnapshot $Scripts $Data (Join-Path $run 'Archivos')
    } catch { $failure=$_.Exception.Message }
    finally {
        foreach($state in $states) {
            try {
                $now=Get-ScheduledTask -TaskName $state.TaskName -TaskPath $state.TaskPath
                if([bool]$now.Settings.Enabled -ne $state.Enabled) {
                    if($state.Enabled){Enable-ScheduledTask -TaskName $state.TaskName -TaskPath $state.TaskPath | Out-Null}
                    else {Disable-ScheduledTask -TaskName $state.TaskName -TaskPath $state.TaskPath | Out-Null}
                }
                if([bool](Get-ScheduledTask -TaskName $state.TaskName -TaskPath $state.TaskPath).Settings.Enabled -ne $state.Enabled){throw 'Estado no restaurado'}
            } catch {$restoreErrors+=($state.TaskName+': '+$_.Exception.Message)}
        }
    }
    $result=[pscustomobject]@{Backup=$run;Files=if($snapshot){$snapshot.Files}else{0};Verified=if($snapshot){$snapshot.Verified}else{0};Bytes=if($snapshot){$snapshot.Bytes}else{0};Tasks=$states.Count;TasksRestored=($restoreErrors.Count -eq 0);Error=$failure;TaskErrors=$restoreErrors;PASS=($null -eq $failure -and $null -ne $snapshot -and $restoreErrors.Count -eq 0)}
    $result | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath (Join-Path $run 'RESULTADO.json') -Encoding UTF8
    $result | Format-List
    if(-not $result.PASS){throw "Respaldo NO confirmado. Revisar $run\RESULTADO.json y el estado de las tareas."}
    Write-Host 'RESPALDO_VERIFICADO=SI. Tareas devueltas a su estado anterior. No se ha desplegado ningun cambio.' -ForegroundColor Green
}
if ($MyInvocation.InvocationName -ne '.') {
    $ErrorActionPreference='Stop'
    if($env:COMPUTERNAME -ne 'GHI-TAQUILLAS'){throw 'Ejecutar solo en el PC GHI-TAQUILLAS.'}
    $identity=[Security.Principal.WindowsIdentity]::GetCurrent()
    $principal=New-Object Security.Principal.WindowsPrincipal($identity)
    if(-not $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)){throw 'Abrir PowerShell como administrador.'}
    Invoke-LockerBackup 'C:\ACTUM' 'C:\Users\User\OneDrive - GHI HORNOS INDUSTRIALES S.L\LockerACTUM' 'C:\RESPALDOS_LOCKER'
}
