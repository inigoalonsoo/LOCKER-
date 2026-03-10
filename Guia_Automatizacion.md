# Guía de Configuración de la Automatización

## 📋 Archivos Creados

1. **ExportarLocker.ps1** - Script que exporta los datos del locker a Excel/CSV
2. Esta guía - Instrucciones para configurar la ejecución automática

---

## 🚀 PASO 1: Probar el Script Manualmente

Antes de automatizar, vamos a probar que el script funciona.

### En el ordenador del locker (por TeamViewer):

1. **Abrir PowerShell como Administrador**
   - Clic derecho en botón Windows → "Windows PowerShell (Administrador)"

2. **Navegar a la carpeta donde está el script**
   ```powershell
   cd C:\ACTUM
   ```

3. **Permitir ejecución de scripts** (solo la primera vez)
   ```powershell
   Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
   ```

4. **Ejecutar el script**
   ```powershell
   .\ExportarLocker.ps1
   ```

5. **Verificar resultados**
   - El script creará la carpeta `C:\Users\[TuUsuario]\OneDrive\ReportesLocker\`
   - Dentro habrá un archivo `ReporteLocker_YYYY-MM-DD.csv`
   - Abrirlo con Excel para verificar los datos

---

## 🔄 PASO 2: Configurar Ejecución Automática

Una vez verificado que funciona, configuramos la tarea programada.

### Opción A: Con Interfaz Gráfica (Más Fácil)

1. **Abrir el Programador de Tareas**
   - Presionar `Windows + R`
   - Escribir: `taskschd.msc`
   - Pulsar Enter

2. **Crear Tarea Básica**
   - En el panel derecho, clic en "Crear tarea básica..."
   - Nombre: `Exportar Locker ACTUM Diario`
   - Descripción: `Exporta datos del locker a Excel automáticamente`
   - Clic en "Siguiente"

3. **Configurar Desencadenador (Cuándo se ejecuta)**
   - Seleccionar: "Diariamente"
   - Clic "Siguiente"
   - Hora: `08:00:00` (o la hora que prefieras)
   - Repetir cada: `1` días
   - Clic "Siguiente"

4. **Configurar Acción**
   - Seleccionar: "Iniciar un programa"
   - Clic "Siguiente"
   - Programa/script: `powershell.exe`
   - Agregar argumentos: `-ExecutionPolicy Bypass -File "C:\ACTUM\ExportarLocker.ps1"`
   - Clic "Siguiente"

5. **Finalizar**
   - Marcar "Abrir el cuadro de diálogo Propiedades"
   - Clic "Finalizar"

6. **Configuración Adicional en Propiedades**
   - Pestaña "General":
     - Marcar "Ejecutar con los privilegios más altos"
     - Marcar "Ejecutar tanto si el usuario inició sesión como si no"
   - Pestaña "Configuración":
     - Marcar "Ejecutar la tarea lo antes posible después de un inicio programado perdido"
   - Clic "Aceptar"

---

### Opción B: Con PowerShell (Automático)

Ejecutar este script en PowerShell como Administrador:

```powershell
# Configuración de la tarea programada
$accion = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-ExecutionPolicy Bypass -File `"C:\ACTUM\ExportarLocker.ps1`""
$desencadenador = New-ScheduledTaskTrigger -Daily -At 8:00AM
$principal = New-ScheduledTaskPrincipal -UserId "SYSTEM" -LogonType ServiceAccount -RunLevel Highest
$configuracion = New-ScheduledTaskSettingsSet -StartWhenAvailable -RunOnlyIfNetworkAvailable -DontStopIfGoingOnBatteries

Register-ScheduledTask -TaskName "Exportar Locker ACTUM Diario" -Action $accion -Trigger $desencadenador -Principal $principal -Settings $configuracion -Description "Exporta datos del locker a Excel automáticamente"

Write-Host "✓ Tarea programada creada exitosamente" -ForegroundColor Green
```

---

## 🧪 PASO 3: Probar la Tarea Programada

1. **Abrir el Programador de Tareas** (`taskschd.msc`)
2. **Buscar la tarea:** "Exportar Locker ACTUM Diario"
3. **Clic derecho → "Ejecutar"**
4. **Verificar** que se crea el archivo en OneDrive

---

## 📂 PASO 4: Ubicación de los Archivos

Los reportes se guardarán en:
```
C:\Users\[Usuario]\OneDrive\ReportesLocker\
├── ReporteLocker_2026-02-11.csv
├── ReporteLocker_2026-02-12.csv
├── ReporteLocker_2026-02-13.csv
├── ...
└── Log_Exportaciones.txt
```

**OneDrive los sincronizará automáticamente a la nube** para acceso desde cualquier dispositivo.

---

## ✅ Verificación Final

1. ✅ Script ejecutado manualmente con éxito
2. ✅ Archivo CSV generado correctamente
3. ✅ Datos visibles en Excel
4. ✅ Tarea programada configurada
5. ✅ Tarea programada probada manualmente
6. ✅ Archivos visibles en OneDrive

---

## 🔧 Solución de Problemas

### El script da error de SQL
- Verificar que SQL Server esté iniciado
- Verificar credenciales en Par.txt

### No se crea el archivo
- Verificar permisos de escritura en OneDrive
- Verificar que la carpeta OneDrive existe

### La tarea programada no se ejecuta
- Verificar que esté marcado "Ejecutar con privilegios más altos"
- Verificar que la ruta del script sea correcta
- Ver el historial de la tarea en el Programador de Tareas

### El archivo no aparece en OneDrive web
- Esperar unos minutos para la sincronización
- Verificar que OneDrive esté activo (icono en la barra de tareas)

---

## 📞 Modificar la Hora de Ejecución

Si quieres cambiar la hora:
1. Abrir Programador de Tareas
2. Buscar "Exportar Locker ACTUM Diario"
3. Clic derecho → Propiedades
4. Pestaña "Desencadenadores"
5. Editar y cambiar la hora
6. Aceptar

---

## 📊 Formato del Excel

El archivo CSV se puede abrir con Excel y contiene:
- Nombre Usuario
- Apellidos
- Documento (DNI)
- Consigna
- Caja
- Fecha Ultima Apertura
- Estado (Libre/Ocupada)
- Estado Puerta
- Usuario Activo
