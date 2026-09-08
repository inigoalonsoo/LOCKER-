# Resultados Comandos 11-17 - Exploración ACTUM

**Fecha:** 11 de febrero de 2026, 11:22

---

## 🎉 DESCUBRIMIENTO CRÍTICO: ACTUM USA SQL SERVER

### 🔑 Información de Conexión Encontrada en Par.txt

```
Servidor: GHI-TAQUILLAS\SQLEXPRESS
Base de datos: Actum_GHI
Usuario: sa
Contraseña: 101103118101103118
```

**Esto cambia TODO:** Los datos del locker NO están en archivos de texto, están en una **base de datos SQL Server**.

---

## 📊 Resultados Detallados

### COMANDO 11: Lista completa de archivos

Total de archivos encontrados: **33 archivos**

#### Archivos más relevantes:

| Archivo | Tamaño | Última modificación | Comentario |
|---------|--------|---------------------|------------|
| **Par.txt** (Gestion) | 61 bytes | **11/02/2026 9:31:50** | ✅ Contiene credenciales SQL |
| **Par.txt** (Parametros) | 61 bytes | **11/02/2026 8:42:28** | ✅ Contiene credenciales SQL |
| Par.txt (Visor) | 70 bytes | 10/02/2026 14:26:48 | Parámetros del visor |

#### Aplicaciones ejecutables:

| Aplicación | Tamaño | Fecha | Propósito |
|------------|--------|-------|-----------|
| **ACTUM_EPI_Gestion.exe** | 2.4 MB | 27/02/2025 | Aplicación principal de gestión |
| ACTUM_EPI_Parametros.exe | 2.1 MB | 05/02/2025 | Configuración |
| ACTUM_EPI_Visor.exe | 1.0 MB | 05/02/2025 | Visualización de datos |

#### Archivos de log:

- Desconexiones_YYYYMMDD.txt (varios)
- Error_YYYYMMDD.txt (varios)

---

### COMANDO 12: Estructura de carpetas

```
C:\ACTUM\ACTUM_EPI\
├── Gestion       ← Aplicación principal
├── Parametros    ← Configuración
└── Visor         ← Visor de datos
```

---

### COMANDO 13: Contenido de Par.txt ⭐⭐⭐

```
GHI-TAQUILLAS\SQLEXPRESS
Actum_GHI
sa
101103118101103118
```

**Interpretación:**
- Línea 1: Servidor SQL Server (nombre del equipo + instancia)
- Línea 2: Nombre de la base de datos
- Línea 3: Usuario (sa = System Administrator)
- Línea 4: Contraseña

---

### COMANDO 14: Archivo de errores

Los errores muestran:
- Problemas de conexión a SQL Server
- "Error relacionado con la red o específico de la instancia"
- "El servidor está en modo de usuario único"

**Conclusión:** La aplicación ACTUM depende completamente de SQL Server para funcionar.

---

### COMANDO 15: Archivos modificados HOY

Solo 2 archivos activos hoy:
1. `C:\ACTUM\ACTUM_EPI\Gestion\Par.txt` (9:31:50)
2. `C:\ACTUM\ACTUM_EPI\Parametros\Par.txt` (8:42:28)

**Esto indica que la aplicación se ejecutó hoy.**

---

### COMANDO 16: Búsqueda de archivos con "usuario", "log", etc.

Solo encontró archivos de logo (LogoACTUM.jpg, LogoACTUMTransparent.png)

**Conclusión:** NO hay archivos de texto con registros de usuarios/movimientos. Todo está en SQL.

---

### COMANDO 17: Archivos grandes o CSV

**NO se encontraron archivos CSV.**

Solo archivos .exe (ejecutables) mayores de 50KB.

**Conclusión definitiva:** ACTUM NO exporta a CSV automáticamente. Los datos están exclusivamente en SQL Server.

---

## 🎯 Análisis Final

### ✅ Lo que sabemos ahora:

1. **Los datos del locker están en SQL Server**, no en archivos
2. **Base de datos:** `Actum_GHI` en servidor `GHI-TAQUILLAS\SQLEXPRESS`
3. **Credenciales de acceso:** Usuario `sa` con contraseña conocida
4. **Aplicaciones:**
   - Gestión: Para administrar el sistema
   - Parámetros: Para configurar
   - Visor: Para ver datos

### ❌ Lo que NO encontramos:

- ❌ Archivos CSV con exportaciones automáticas
- ❌ Archivos de texto con registros de movimientos
- ❌ Logs que contengan información de usuario/movimientos

---

## 🚀 Próximo Paso CRÍTICO

Necesitamos **conectarnos a la base de datos SQL Server** y explorar:
1. ¿Qué tablas hay en la base de datos `Actum_GHI`?
2. ¿Qué columnas tienen esas tablas?
3. ¿Cuál tabla contiene los movimientos del locker?
4. ¿Qué formato tienen los datos?

**Herramienta necesaria:** Comandos SQL en PowerShell para consultar la base de datos.
