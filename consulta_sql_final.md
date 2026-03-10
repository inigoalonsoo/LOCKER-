# Consulta SQL Final para Excel

## 🎯 Consulta Principal

Esta consulta obtiene toda la información disponible del locker:

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

## 📋 Comando Para Probar

Ejecutad esto en PowerShell para ver los resultados:

```powershell
sqlcmd -S "GHI-TAQUILLAS\SQLEXPRESS" -d "Actum_GHI" -E -Q "SELECT U.Nombre AS 'Nombre', U.Apellidos, U.DI AS 'DNI', C.CodigoCliente AS 'Consigna', C.Caja_Codigo AS 'Caja', C.FechaHoraUltimaApertura AS 'Fecha', CASE C.Estado WHEN 2 THEN 'Libre' WHEN 4 THEN 'Ocupada' ELSE 'Desconocido' END AS 'Estado' FROM Consigna C LEFT JOIN Usuario U ON C.Usuario_CodigoUltimaApertura = U.Codigo WHERE C.FechaHoraUltimaApertura IS NOT NULL ORDER BY C.FechaHoraUltimaApertura DESC"
```

---

## 💾 Exportar a Excel Directamente

Para exportar directamente a Excel:

```powershell
sqlcmd -S "GHI-TAQUILLAS\SQLEXPRESS" -d "Actum_GHI" -E -Q "SELECT U.Nombre AS 'Nombre', U.Apellidos, U.DI AS 'DNI', C.CodigoCliente AS 'Consigna', C.Caja_Codigo AS 'Caja', C.FechaHoraUltimaApertura AS 'Fecha', CASE C.Estado WHEN 2 THEN 'Libre' WHEN 4 THEN 'Ocupada' ELSE 'Desconocido' END AS 'Estado' FROM Consigna C LEFT JOIN Usuario U ON C.Usuario_CodigoUltimaApertura = U.Codigo WHERE C.FechaHoraUltimaApertura IS NOT NULL ORDER BY C.FechaHoraUltimaApertura DESC" -o "C:\ACTUM\ReporteLocker.csv" -s";" -W
```

Este comando guarda los resultados en un archivo CSV que se puede abrir en Excel.

---

## 📊 Columnas del Excel Resultante

1. **Nombre** - Nombre del usuario
2. **Apellidos** - Apellidos completos
3. **DNI** - Documento de identidad
4. **Consigna** - Número de consigna (01, 02, 03...)
5. **Caja** - ID de la caja
6. **Fecha** - Fecha y hora de la última apertura
7. **Estado** - Libre u Ocupada

---

## ⚠️ Limitación Importante

**El sistema solo guarda la ÚLTIMA apertura** de cada consigna, no un historial completo.

Para crear un historial, necesitamos ejecutar esta consulta periódicamente (ej: cada día) y acumular los resultados.
