Set objShell = CreateObject("WScript.Shell")
objShell.Run "powershell.exe -ExecutionPolicy Bypass -NoProfile -WindowStyle Hidden -File ""C:\ACTUM\MonitoreoLockerTiempoReal.ps1""", 0, False
