# Automatización del Sistema de Locker ACTUM

## Objetivo
Automatizar el registro de movimientos del locker (extracción, devolución, hora, persona, estado) para que los datos se sincronicen automáticamente con OneDrive sin necesidad de acceso físico al locker.

## Tareas

### Fase 1: Investigación del Sistema ACTUM ✅
- [x] Conectar al ordenador del locker vía TeamViewer
- [x] Abrir PowerShell como administrador
- [x] Ejecutar comandos de búsqueda de instalación ACTUM
- [x] Ejecutar comandos de búsqueda de bases de datos
- [x] Ejecutar comandos de búsqueda de archivos de log
- [x] Explorar estructura de base de datos SQL Server
- [x] Identificar tablas y columnas relevantes
- [x] Analizar resultados y determinar ubicación de datos

### Fase 2: Diseño de Solución ✅
- [x] Diseñar arquitectura de sincronización automática
- [x] Definir formato del Excel final
- [x] Planificar frecuencia de actualización (diaria)
- [x] Crear consulta SQL para extraer datos
- [x] Validar consulta con usuario

### Fase 3: Implementación ✅
- [x] Crear script de extracción de datos de ACTUM
- [x] Crear script de detección de cambios en tiempo real
- [x] Crear sistema de historial acumulativo
- [x] Crear generador de dashboard HTML
- [x] Configurar sincronización con OneDrive

### Fase 4: Automatización 🔄
- [/] Copiar scripts al ordenador del locker
- [ ] Configurar tarea programada cada 1 minuto
- [ ] Realizar pruebas de ejecución automática
- [ ] Documentar el sistema para mantenimiento futuro

### Fase 5: Validación ⏳
- [ ] Verificar detección de cambios en tiempo real
- [ ] Confirmar acceso desde OneDrive web
- [ ] Validar dashboard HTML
- [ ] Capacitar al equipo en el uso del sistema
