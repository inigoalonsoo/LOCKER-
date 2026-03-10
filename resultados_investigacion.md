# Resultados de la Investigación ACTUM

**Fecha:** 11 de febrero de 2026, 11:08
**Método:** Ejecución de 10 comandos PowerShell en el ordenador del locker

---

## 🎯 HALLAZGO PRINCIPAL

✅ **ACTUM está instalado en:** `C:\ACTUM\ACTUM_EPI\`

---

## 📊 Resultados Detallados

### Comando 1-3: Búsqueda de carpetas ACTUM
**Resultado:** Sin resultados en Program Files, Program Files (x86) y ProgramData
- ACTUM NO está instalado en las ubicaciones estándar de programas
- Está en una ubicación personalizada: `C:\ACTUM\`

### Comando 4: Búsqueda de bases de datos
**Resultado:** ❌ NO se encontraron bases de datos (.db, .sqlite, .mdb, .accdb)
- El sistema NO usa bases de datos tradicionales
- Probablemente usa archivos de texto para almacenar datos

### Comando 5: Búsqueda de archivos de log ✅ ¡MUY IMPORTANTE!
**Resultado:** Se encontraron 12 archivos en `C:\ACTUM\ACTUM_EPI\`

#### Archivos encontrados (ordenados por fecha):

| Archivo | Tamaño | Última Modificación | Ubicación |
|---------|--------|---------------------|-----------|
| `Par.txt` | 61 bytes | **11/02/2026 9:31:50** | `C:\ACTUM\ACTUM_EPI\Gestion\` |
| `Par.txt` | 61 bytes | **11/02/2026 8:42:28** | `C:\ACTUM\ACTUM_EPI\Parametros\` |
| `Par.txt` | 70 bytes | 10/02/2026 14:26:48 | `C:\ACTUM\ACTUM_EPI\Visor\` |
| `Desconexiones_20251112.txt` | 49 bytes | 12/11/2025 16:33:52 | `C:\ACTUM\ACTUM_EPI\Gestion\` |
| `Error_20251112.txt` | 10,722 bytes | 12/11/2025 16:32:49 | `C:\ACTUM\ACTUM_EPI\Gestion\` |
| `Desconexiones_20250910.txt` | 49 bytes | 10/09/2025 8:23:17 | `C:\ACTUM\ACTUM_EPI\Gestion\` |
| `Error_20250910.txt` | 11,467 bytes | 10/09/2025 8:22:16 | `C:\ACTUM\ACTUM_EPI\Gestion\` |
| `Desconexiones_20250812.txt` | 49 bytes | 12/08/2025 22:56:23 | `C:\ACTUM\ACTUM_EPI\Gestion\` |
| `Error_20250812.txt` | 25,847 bytes | 12/08/2025 22:55:22 | `C:\ACTUM\ACTUM_EPI\Gestion\` |
| `Desconexiones_20250709.txt` | 49 bytes | 09/07/2025 3:56:31 | `C:\ACTUM\ACTUM_EPI\Gestion\` |
| `Error_20250709.txt` | 13,699 bytes | 09/07/2025 3:55:29 | `C:\ACTUM\ACTUM_EPI\Gestion\` |
| `Act.txt` | 21 bytes | 26/10/2024 13:23:42 | `C:\ACTUM\ACTUM_EPI\Parametros\` |

### Comando 6-7: Datos de usuario
**Resultado:** Sin resultados en AppData (Local y Roaming)

### Comando 8: Procesos en ejecución
**Resultado:** ❌ NO hay procesos ACTUM ejecutándose actualmente
- La aplicación no está abierta en este momento
- O se ejecuta bajo otro nombre de proceso

### Comando 9-10: Información de instalación
**Resultado:** Sin resultados en el registro de Windows
- ACTUM no está registrado como aplicación instalada
- Instalación personalizada/manual

---

## 🔍 Análisis y Conclusiones

### Estructura de carpetas identificada:
```
C:\ACTUM\
└── ACTUM_EPI\
    ├── Gestion\        ← CARPETA MÁS IMPORTANTE (logs de errores y desconexiones)
    ├── Parametros\     ← Archivos de configuración
    └── Visor\          ← Posible interfaz de visualización
```

### Observaciones importantes:

1. **Sistema basado en archivos de texto:** No usa bases de datos, usa archivos `.txt`

2. **Archivos activos HOY:** 
   - `Gestion\Par.txt` actualizado hoy a las 9:31
   - `Parametros\Par.txt` actualizado hoy a las 8:42
   - **Esto confirma que el sistema está activo y funcionando**

3. **Archivos con fechas en el nombre:**
   - `Desconexiones_YYYYMMDD.txt` - Registro de desconexiones por fecha
   - `Error_YYYYMMDD.txt` - Registro de errores por fecha
   - Patrón: Un archivo por cada día con actividad

4. **Carpeta "Gestion":** Parece ser la carpeta principal donde se guardan los registros de actividad

---

## 📋 Próximos Pasos Necesarios

### URGENTE - Explorar contenido de archivos:

Necesitamos ver el **contenido** de estos archivos para entender el formato de datos:

#### Comandos a ejecutar en PowerShell:

```powershell
# 1. Listar TODO el contenido de la carpeta Gestion
Get-ChildItem -Path "C:\ACTUM\ACTUM_EPI\Gestion" -Recurse | Select-Object FullName, Length, LastWriteTime

# 2. Ver contenido del archivo Par.txt más reciente
Get-Content "C:\ACTUM\ACTUM_EPI\Gestion\Par.txt"

# 3. Ver las primeras 50 líneas de un archivo de Error
Get-Content "C:\ACTUM\ACTUM_EPI\Gestion\Error_20251112.txt" -First 50

# 4. Listar TODOS los archivos de la carpeta ACTUM_EPI
Get-ChildItem -Path "C:\ACTUM\ACTUM_EPI" -Recurse -File | Select-Object FullName, Length, LastWriteTime | Sort-Object LastWriteTime -Descending
```

### Información que buscamos:
- ¿Qué contienen los archivos `Par.txt`?
- ¿Hay archivos con registros de movimientos del locker?
- ¿Qué formato tienen los datos? (CSV, texto plano, XML, etc.)
- ¿Hay más archivos además de los que encontramos?

---

## ✅ Estado de Completitud

- ✅ Localizada instalación de ACTUM
- ✅ Identificadas carpetas principales
- ✅ Encontrados archivos de logs
- ⏳ Pendiente: Ver contenido de archivos
- ⏳ Pendiente: Identificar archivo con movimientos del locker
- ⏳ Pendiente: Entender formato de datos
