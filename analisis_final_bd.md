# Análisis Final de la Base de Datos ACTUM

**Fecha:** 11 de febrero de 2026, 11:46

---

## 🎯 Estructura del Sistema Descubierta

### 📊 Tablas Principales y su Función:

#### 1. **Consigna** (Cajas/Compartimentos del Locker)
- **Codigo**: ID de la consigna
- **CodigoCliente**: Nombre/número de la consigna (01, 02, 03...)
- **Caja_Codigo**: ID de la caja asociada
- **Usuario_Codigo**: Usuario actual asignado (puede ser 0 si está libre)
- **FechaHoraUltimaApertura**: ⭐ Última vez que se abrió
- **Usuario_CodigoUltimaApertura**: ⭐ Último usuario que la abrió
- **Estado**: 2 (libre), 4 (ocupada)
- **EstadoPuerta**: 2 (cerrada)
- **EstadoOcupacion**: 2 (vacía/ocupada)

#### 2. **Usuario**
- **Codigo**: ID del usuario
- **Nombre**: Nombre del usuario (RAUL V., PABLO O., etc.)
- **Apellidos**: Apellidos completos
- **DI**: Documento de identidad
- **Activo**: Si está activo o no
- Otros campos de permisos y notificaciones

#### 3. **Eventos**
- **Codigo**: GUID único del evento
- **FechaHora**: Fecha y hora del evento
- **Evento**: Tipo de evento (2, 3)
- **Consigna_Codigo**: Consigna afectada
- **Caja_Codigo**: Caja afectada
- **Herramienta_Codigo**: Herramienta (mismo que Caja)
- **Usuario_Codigo**: Siempre 0 ⚠️

#### 4. **Acciones**
- **FechaHora**: Fecha y hora de la acción
- **CodigoAccion**: Tipo de acción (1, 4, 5)
- **Usuario_Codigo**: Siempre 0 ⚠️
- **Consigna_Codigo**: Consigna afectada

#### 5. **Herramienta**
- ❌ **TABLA VACÍA** - No se usan registros de herramientas

---

## 🔍 Observaciones Críticas

### ✅ Datos Disponibles:
1. **Fecha de última apertura** de cada consigna
2. **Usuario que abrió** cada consigna (Usuario_CodigoUltimaApertura)
3. **Estado actual** de cada consigna
4. **Información completa** de usuarios

### ⚠️ Limitaciones del Sistema:
1. **NO hay historial completo**: Solo se guarda la ÚLTIMA apertura de cada consigna
2. **NO hay registro de devoluciones específicas**: Solo la última apertura
3. **NO hay herramientas registradas**: La tabla Herramienta está vacía
4. **Eventos y Acciones NO tienen usuario directo**: Usuario_Codigo = 0

### 🎯 Datos Recientes (Últimos días):
- **2026-02-10**: Consignas 19, 11 (usuarios 87, 59)
- **2026-02-09**: Consignas 20, 1 (usuarios 59, 45)
- **2026-02-04**: Consignas 5, 16, 25 (usuario 59)
- **2026-01-30 a 2026-01-15**: Varios usuarios y consignas

---

## 📋 Lo que PODEMOS Obtener

### ✅ Información Disponible para Excel:

| Campo | Origen | Descripción |
|-------|--------|-------------|
| **Nombre Usuario** | Usuario.Nombre | Nombre del usuario |
| **Apellidos** | Usuario.Apellidos | Apellidos completos |
| **Documento** | Usuario.DI | DNI/documento |
| **Consigna** | Consigna.CodigoCliente | Número de consigna (01, 02...) |
| **Caja** | Consigna.Caja_Codigo | Número de caja |
| **Fecha Última Apertura** | Consigna.FechaHoraUltimaApertura | Cuándo se abrió |
| **Estado** | Consigna.Estado | 2=Libre, 4=Ocupada |
| **Estado Puerta** | Consigna.EstadoPuerta | Estado de la puerta |
| **Usuario Activo** | Usuario.Activo | Si el usuario sigue activo |

### ❌ Información NO Disponible:

- ❌ Historial completo de aperturas (solo la última)
- ❌ Fecha de devolución
- ❌ Múltiples movimientos por consigna
- ❌ Herramientas específicas

---

## 🚀 Consulta SQL Propuesta

### Consulta para obtener todos los datos disponibles:

```sql
SELECT 
    U.Nombre AS 'Nombre Usuario',
    U.Apellidos,
    U.DI AS 'Documento',
    C.CodigoCliente AS 'Consigna',
    C.Caja_Codigo AS 'Caja',
    C.FechaHoraUltimaApertura AS 'Fecha Última Apertura',
    CASE C.Estado
        WHEN 2 THEN 'Libre'
        WHEN 4 THEN 'Ocupada'
        ELSE 'Desconocido'
    END AS 'Estado',
    CASE C.EstadoPuerta
        WHEN 2 THEN 'Cerrada'
        ELSE 'Otro'
    END AS 'Estado Puerta',
    CASE U.Activo
        WHEN 1 THEN 'Sí'
        WHEN 0 THEN 'No'
        ELSE 'Desconocido'
    END AS 'Usuario Activo'
FROM 
    Consigna C
    LEFT JOIN Usuario U ON C.Usuario_CodigoUltimaApertura = U.Codigo
WHERE 
    C.FechaHoraUltimaApertura IS NOT NULL
ORDER BY 
    C.FechaHoraUltimaApertura DESC
```

---

## 💡 Recomendación

**El sistema ACTUM solo registra el ESTADO ACTUAL**, no un historial completo. 

### Opciones:

1. **Opción A - Snapshot Diario:**
   - Ejecutar la consulta SQL automáticamente cada día
   - Guardar el estado actual en un Excel acumulativo
   - Así crear nuestro propio historial

2. **Opción B - Monitoreo de Eventos:**
   - Analizar la tabla Eventos más a fondo
   - Puede tener más información histórica

3. **Opción C - Estado Actual:**
   - Simplemente obtener el estado actual de todas las consignas
   - Quién tiene qué en este momento

**¿Cuál queréis?** Probablemente la Opción A es la mejor para crear un historial a futuro.
