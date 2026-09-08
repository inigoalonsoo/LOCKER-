# Comandos de Investigación ACTUM

## 🔷 PASO PREVIO: Abrir PowerShell como Administrador

1. **Clic derecho** en el botón de Windows (esquina inferior izquierda) **del ordenador del locker** (dentro de TeamViewer)
2. Seleccionar **"Windows PowerShell (Administrador)"** o **"Terminal (Administrador)"**
3. Clic en **"Sí"** si pregunta permisos
4. Verificar que aparece una ventana azul/negra con `PS C:\Windows\system32>`

---

## 📋 Comandos a Ejecutar

### INSTRUCCIONES GENERALES:
- **Copiar:** Seleccionar el comando → `Ctrl + C`
- **Pegar en PowerShell:** Clic derecho en la ventana → automáticamente se pega (o `Ctrl + V`)
- **Ejecutar:** Pulsar `Enter`
- **Copiar resultados:** Seleccionar todo el texto → `Ctrl + C` → Enviarme

---

### COMANDO 1: Buscar carpetas ACTUM en Program Files
```powershell
Get-ChildItem -Path "C:\Program Files" -Filter "*ACTUM*" -Directory -ErrorAction SilentlyContinue | Select-Object FullName, LastWriteTime
```

---

### COMANDO 2: Buscar en Program Files (x86)
```powershell
Get-ChildItem -Path "C:\Program Files (x86)" -Filter "*ACTUM*" -Directory -ErrorAction SilentlyContinue | Select-Object FullName, LastWriteTime
```

---

### COMANDO 3: Buscar en ProgramData
```powershell
Get-ChildItem -Path "C:\ProgramData" -Filter "*ACTUM*" -Directory -ErrorAction SilentlyContinue | Select-Object FullName, LastWriteTime
```

---

### COMANDO 4: Buscar bases de datos ⚠️ (Puede tardar varios minutos)
```powershell
Get-ChildItem -Path "C:\" -Include "*.db","*.sqlite","*.mdb","*.accdb" -Recurse -ErrorAction SilentlyContinue | Where-Object { $_.FullName -like "*ACTUM*" -or $_.FullName -like "*locker*" } | Select-Object FullName, Length, LastWriteTime
```

---

### COMANDO 5: Buscar archivos de log ⚠️ (Puede tardar varios minutos)
```powershell
Get-ChildItem -Path "C:\" -Include "*.log","*.txt","*.csv" -Recurse -ErrorAction SilentlyContinue | Where-Object { $_.FullName -like "*ACTUM*" -or $_.FullName -like "*locker*" } | Sort-Object LastWriteTime -Descending | Select-Object -First 20 FullName, Length, LastWriteTime
```

---

### COMANDO 6: Buscar en datos locales del usuario
```powershell
Get-ChildItem -Path "$env:LOCALAPPDATA" -Filter "*ACTUM*" -Directory -ErrorAction SilentlyContinue | Select-Object FullName, LastWriteTime
```

---

### COMANDO 7: Buscar en datos roaming del usuario
```powershell
Get-ChildItem -Path "$env:APPDATA" -Filter "*ACTUM*" -Directory -ErrorAction SilentlyContinue | Select-Object FullName, LastWriteTime
```

---

### COMANDO 8: Ver procesos ACTUM en ejecución
```powershell
Get-Process | Where-Object { $_.ProcessName -like "*ACTUM*" -or $_.ProcessName -like "*locker*" } | Select-Object ProcessName, Id, Path
```

---

### COMANDO 9: Información de instalación
```powershell
Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* | Where-Object { $_.DisplayName -like "*ACTUM*" } | Select-Object DisplayName, DisplayVersion, InstallLocation
```

---

### COMANDO 10: Verificación 64-bits
```powershell
Get-ItemProperty HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* | Where-Object { $_.DisplayName -like "*ACTUM*" } | Select-Object DisplayName, DisplayVersion, InstallLocation
```

---

## ✅ QUÉ ENVIAR

1. ✅ Resultados de los 10 comandos (aunque algunos digan "Sin resultados")
2. ✅ Capturas de pantalla de la aplicación ACTUM (si está abierta)
3. ✅ Capturas de los menús de ACTUM (buscar opciones de Exportar/Historial/Logs)

---

## ⏱️ IMPORTANTE
- Los comandos 4 y 5 pueden tardar 5-10 minutos
- Si no sale nada, escribir "Sin resultados" para ese comando
- Copiar TODO lo que aparezca, incluso si parece mucha información
