Set objShell = CreateObject("WScript.Shell")
objShell.Run "powershell.exe -ExecutionPolicy Bypass -File ""C:\ACTUM\MonitoreoLockerTiempoReal.ps1""", 0, False
Set objShell = Nothing
