# Comandos de Exploración - PARTE 2

## 🎯 Objetivo
Ahora que sabemos que ACTUM está en `C:\ACTUM\ACTUM_EPI\`, necesitamos explorar el **contenido** de los archivos para entender el formato de datos y encontrar dónde se guardan los movimientos del locker.

---

## 📋 Comandos a Ejecutar

### COMANDO 11: Listar TODOS los archivos en la carpeta ACTUM
```powershell
Get-ChildItem -Path "C:\ACTUM\ACTUM_EPI" -Recurse -File | Select-Object FullName, Length, LastWriteTime | Sort-Object LastWriteTime -Descending
```

**Qué hace:** Muestra TODOS los archivos dentro de ACTUM_EPI ordenados por fecha (el más reciente primero)

---

### COMANDO 12: Ver estructura de carpetas
```powershell
Get-ChildItem -Path "C:\ACTUM\ACTUM_EPI" -Recurse -Directory | Select-Object FullName
```

**Qué hace:** Muestra todas las subcarpetas dentro de ACTUM_EPI

---

### COMANDO 13: Ver contenido del archivo Par.txt de Gestion
```powershell
Get-Content "C:\ACTUM\ACTUM_EPI\Gestion\Par.txt"
```

**Qué hace:** Muestra el contenido completo del archivo de parámetros de Gestion

---

### COMANDO 14: Ver primeras 100 líneas de un archivo de Error
```powershell
Get-Content "C:\ACTUM\ACTUM_EPI\Gestion\Error_20251112.txt" -First 100
```

**Qué hace:** Muestra las primeras 100 líneas del archivo de errores más reciente

---

### COMANDO 15: Buscar archivos modificados HOY
```powershell
Get-ChildItem -Path "C:\ACTUM\ACTUM_EPI" -Recurse -File | Where-Object { $_.LastWriteTime -gt (Get-Date).Date } | Select-Object FullName, Length, LastWriteTime | Sort-Object LastWriteTime -Descending
```

**Qué hace:** Muestra solo los archivos que se han modificado HOY (los que están activos)

---

### COMANDO 16: Buscar archivos con "usuario" o "user" en el nombre
```powershell
Get-ChildItem -Path "C:\ACTUM\ACTUM_EPI" -Recurse -File | Where-Object { $_.Name -like "*usuario*" -or $_.Name -like "*user*" -or $_.Name -like "*log*" -or $_.Name -like "*registro*" } | Select-Object FullName, Length, LastWriteTime
```

**Qué hace:** Busca archivos que puedan contener registros de usuarios o movimientos

---

### COMANDO 17: Buscar archivos CSV o archivos grandes (posibles registros)
```powershell
Get-ChildItem -Path "C:\ACTUM\ACTUM_EPI" -Recurse -File | Where-Object { $_.Extension -eq ".csv" -or $_.Length -gt 50000 } | Select-Object FullName, Length, LastWriteTime | Sort-Object Length -Descending
```

**Qué hace:** Busca archivos CSV o archivos grandes (más de 50KB) que puedan contener muchos registros

---

## 📸 Tareas Visuales

### Tarea 1: Explorar con el Explorador de Archivos
1. Abrir el Explorador de Archivos en el ordenador del locker
2. Navegar a `C:\ACTUM\ACTUM_EPI`
3. Hacer **capturas de pantalla** de:
   - La estructura de carpetas
   - El contenido de la carpeta `Gestion`
   - Cualquier archivo que parezca importante

### Tarea 2: Buscar la aplicación ACTUM
1. ¿Hay un ejecutable de ACTUM? (archivo `.exe`)
2. Si lo hay, ¿está en `C:\ACTUM\ACTUM_EPI`?
3. Intentar abrirlo y hacer capturas de pantalla de la interfaz

---

## ✅ Información a Enviarme

1. **Resultados de los comandos 11-17**
2. **Capturas de pantalla** de la carpeta ACTUM
3. **Responder:** ¿Veis algún archivo con extensión `.csv`, `.xlsx`, o con "movimientos", "historial", "registros" en el nombre?

---

## 🎯 Lo que Buscamos

Necesitamos encontrar el archivo que contenga:
- Fecha/hora de cada movimiento
- Nombre del usuario
- Artículo que sacó/devolvió
- Acción (extracción o devolución)

Es probable que sea:
- Un archivo CSV
- Un archivo de texto estructurado
- Un archivo de log con formato específico
- O varios archivos (uno por día, como los de Error y Desconexiones)
