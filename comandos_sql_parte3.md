# Comandos SQL - PARTE 3: Explorar Base de Datos

## 🎯 DESCUBRIMIENTO CRÍTICO

¡Los datos del locker están en una **base de datos SQL Server**, no en archivos de texto!

**Información de conexión:**
- Servidor: `GHI-TAQUILLAS\SQLEXPRESS`
- Base de datos: `Actum_GHI`
- Usuario: `sa`
- Contraseña: `101103118101103118`

---

## 📋 Comandos SQL a Ejecutar en PowerShell

### COMANDO 18: Listar todas las tablas de la base de datos

```powershell
sqlcmd -S "GHI-TAQUILLAS\SQLEXPRESS" -d "Actum_GHI" -U "sa" -P "101103118101103118" -Q "SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE = 'BASE TABLE' ORDER BY TABLE_NAME"
```

**Qué hace:** Muestra la lista de todas las tablas en la base de datos Actum_GHI

---

### COMANDO 19: Ver estructura de la tabla que parezca más relevante

Una vez veamos la lista de tablas del COMANDO 18, ejecutaremos este comando reemplazando `[NOMBRE_TABLA]` por la tabla que parezca contener movimientos:

```powershell
sqlcmd -S "GHI-TAQUILLAS\SQLEXPRESS" -d "Actum_GHI" -U "sa" -P "101103118101103118" -Q "SELECT COLUMN_NAME, DATA_TYPE FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = '[NOMBRE_TABLA]'"
```

---

### COMANDO 20: Ver los últimos 20 registros de una tabla

```powershell
sqlcmd -S "GHI-TAQUILLAS\SQLEXPRESS" -d "Actum_GHI" -U "sa" -P "101103118101103118" -Q "SELECT TOP 20 * FROM [NOMBRE_TABLA] ORDER BY [COLUMNA_FECHA] DESC"
```

---

## ⚠️ IMPORTANTE

**PRIMERO ejecutad el COMANDO 18** para ver qué tablas hay. Una vez veamos los nombres de las tablas, os diré exactamente qué comandos ejecutar a continuación.

Buscamos tablas con nombres como:
- Movimientos
- Registros
- Historial
- Acciones
- Eventos
- Transacciones
- Usuarios
- Extracciones
- O cualquier nombre que sugiera actividad del locker

---

## 🔧 Comandos Alternativos (si SQLCMD no está disponible)

Si `sqlcmd` no funciona, usaremos PowerShell puro:

### ALTERNATIVA AL COMANDO 18:

```powershell
$server = "GHI-TAQUILLAS\SQLEXPRESS"
$database = "Actum_GHI"
$user = "sa"
$password = "101103118101103118"
$connectionString = "Server=$server;Database=$database;User Id=$user;Password=$password;"
$connection = New-Object System.Data.SqlClient.SqlConnection($connectionString)
$connection.Open()
$command = $connection.CreateCommand()
$command.CommandText = "SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE = 'BASE TABLE' ORDER BY TABLE_NAME"
$reader = $command.ExecuteReader()
while ($reader.Read()) {
    $reader.GetValue(0)
}
$connection.Close()
```

---

## 📝 Instrucciones

1. **Ejecutad primero el COMANDO 18** (o la alternativa si sqlcmd no está disponible)
2. **Copiadme la lista completa de tablas** que aparezca
3. **Esperaos** - os diré exactamente qué tabla consultar a continuación

**NO ejecutéis los comandos 19 y 20 todavía**, primero necesito ver la lista de tablas.

---

## ✅ Objetivo

Una vez sepamos qué tablas hay y veamos sus datos, podremos:
1. ✅ Identificar exactamente dónde están los movimientos del locker
2. ✅ Ver qué información se registra (usuario, fecha, hora, artículo, etc.)
3. ✅ Diseñar la consulta SQL perfecta para extraer los datos
4. ✅ Crear el script que genere el Excel automáticamente
