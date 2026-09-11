# CLAUDE.md — Sistema Locker Instrumentacion GHI

## 📍 TRASPASO A CLAUDE CODE — 10/09/2026, despues de Codex

> **ESTE ES EL ESTADO MAS RECIENTE.** Sustituye cualquier pendiente antiguo que lo contradiga.

### Confirmado hoy

- **Timeout de extraccion: CERRADO.** Tras reiniciar `ACTUM_EPI_Gestion.exe`, la pantalla aguanta los
  **120 segundos** configurados. Los valores efectivos quedan `20 | 120 | 120`.
- **Prueba real nueva:** el `A-003` (TESTO 340, serie `61186226`) fue extraido correctamente por
  **Javier Julian de Lamo** el 10/09 a las **09:30:21**. Debe conservarlo porque lo necesita; **NO devolverlo
  ahora** y no retirar su acceso SAT hasta que lo devuelva, si ese acceso se le dio solo para esto.
- **Consigna 22: CERRADA** — el instrumento volvio. **Pero OJO al mecanismo, que no fue el que se
  anoto:** el TESTO 340 `63862113` **NO lo devolvio Sergio identificandose**. Lo devolvio **Inigo el 09/09 a
  las 11:52:50 identificandose por error con el codigo de JAVIER JULIAN DE LAMO (usuario 38)**. La fila del
  CSV dice SERGIO V. VEGA **porque es una correccion manual**, no porque Sergio se identificara.
  - **Evidencia:** `CorreccionesManuales.csv`, ultima fila, con su motivo escrito:
    *"Al devolver el analizador, Inigo se identifico con el codigo de JAVIER JULIAN DE LAMO (38) en vez del
    de SERGIO V. VEGA (14). El evento de SQL dice Javier y no se puede cambiar."*
  - **La conclusion se mantiene:** el instrumento esta de vuelta y no hay que preguntar a nadie. Pero
    **la tabla `Eventos` de SQL dice JAVIER**, y quien reconstruya el historial vera Javier salvo que el
    paso 2.5 reaplique la correccion — que lo hace, porque **sustituye** desde el 09/09.
  - **Por que importa la distincion:** si se da por hecho que "Sergio se identifico", alguien puede pensar
    que SQL y el CSV coinciden. **No coinciden**, y esa es exactamente la razon de que exista
    `CorreccionesManuales.csv`.
- **`D-001`:** la serie `EA 10.00047` **ya esta puesta en ACTUM**. Sigue pendiente encontrar fisicamente
  el atornillador.
- Estado medido del CSV al revisar la extraccion: **537 lineas totales, 536 movimientos, 536/536 unicos,
  0 bytes NULL**; marcador `2026-09-10 09:30:21.667`.

### Decisiones de Inigo — dejar para un posible futuro

- **Alerta externa de sistema caido:** no hacer ahora. El banner de salud del DashboardAdmin sirve de
  momento. Futuro posible: vigilancia externa cada 10 min con aviso tras 20 min sin actualizar.
- **SAI + diagnostico del cuadro electrico:** no hacer ahora. Si se retoma, primero fotografiar regleta,
  fuentes y etiquetas, sumar los W reales y dejar 20 % de margen. El SAI mitiga cortes; revisar el cuadro
  busca la causa. Antecedente: **8 apagones en 5 semanas**.
- **Calibraciones:** dejar en espera de la respuesta de Applus para los **7 equipos**. No avanzar ahora.
  > ⚠️ **MATIZ (Claude Code, 10/09): esa espera solo aplica al lote de Applus.** Los otros **4 lotes no
  > dependen de Applus para nada**: Neurylan (7+2), Leica (1), Klotz (1) y CS (1). Y **dos de los cinco
  > caducados estan justo ahi**: `M-006` (**220 dias**, se pregunta a Neurylan) y `A-005` (**162 dias**,
  > Klotz). Las auditorias son en noviembre y el calendario corre. Decidir si se mandan o si se paran
  > tambien — pero que sea decision, no efecto secundario.

### Siguiente trabajo real, sin resucitar pendientes cerrados

1. `L-004` (Megger MIT320, `102465739`): poner pegatina y meterlo en la consigna 9 identificandose. La
   ultima operacion encontrada en el CSV sigue siendo una extraccion del 14/05/2026.
2. `E-002`, consigna 31: abrir con llave, leer el numero de serie fisico y registrarlo en ACTUM. El numero
   no consta ni en ACTUM ni en el Excel.
3. Encontrar fisicamente el atornillador `D-001`; la serie ya no es pendiente.
4. Cuando se quiera volver a software: valorar leer `Consigna.Usuario_Codigo` para la pestana Estado. La
   dependencia sobre la consigna 22 ya esta resuelta.
5. A largo plazo siguen abiertos quitar la dependencia de OneDrive + `fabricacion1` (Graph con certificado
   o IIS local). No mezclarlo con los trabajos rapidos anteriores.

> **IMPORTANTE PARA CLAUDE CODE — no mezclar listas:** Inigo quiere continuar primero con los pendientes
> originales anteriores. El orden inmediato es **L-004 -> E-002 -> localizar D-001**. Calibraciones espera
> respuesta de Applus; alerta externa y SAI/cuadro estan aplazados. Los cuatro puntos de software de la
> seccion siguiente son hallazgos NUEVOS de una prospeccion de Codex, archivados para un posible futuro;
> **NO eran lo que se venia haciendo y NO son el siguiente trabajo salvo que Inigo los elija expresamente.**

### Hallazgos para futuro — prospeccion Codex 10/09

No son tareas para ejecutar automaticamente; estan medidos y ordenados en
`runs/prospeccion-pendientes-2026-09-10/DESCUBRIMIENTO.md`:

1. El fallback usado si falla la tabla `Eventos` persiste `EstadoAnterior.json` vacio: **0/32 estados**.
2. Los **2 auto-updates** de dashboards copian y ejecutan por timestamp sin gate de sintaxis/hash/backup.
3. `AuditarDashboard.ps1` comprueba las **32 consignas**, pero tiene **0 llamadas** desde el monitor.
4. Los **2 HTML** se escriben directamente, no mediante temporal + reemplazo atomico.

Tambien se re-midio el bloque antiguo de cuatro instrumentos enviados a calibrar: `T-008`, `L-005` y
`M-017` ya fueron devueltos el 09/09 (CSV lineas 534, 533 y 532); **solo `L-004` sigue abierto**.

> **Regla de continuidad:** antes de citar como pendiente la ubicacion de un instrumento, buscar su numero
> de serie en el `HistorialCompleto.csv` sincronizado y leer la ultima fila. El error de no hacerlo hizo
> reaparecer falsamente el pendiente ya cerrado de la consigna 22.

## 🔧 EL UNICO MANTENIMIENTO QUE REQUIERE ESTE PROYECTO

> **Dictado por Inigo el 09/09/2026.** Todo lo demas del sistema es automatico. Esto es lo unico que
> **una persona tiene que hacer a mano**, y si no se hace, el sistema no avisa: sigue funcionando y
> mostrando datos viejos como si fueran buenos.

### 1. Re-autenticar OneDrive cuando caduca la contrasena — cada ~42 dias

La contrasena de **`fabricacion1@ghifurnaces.com`** (la cuenta de OneDrive del locker) caduca cada ~42-50
dias por politica de IT, **que no se puede cambiar**.

Cuando caduca: los scripts siguen funcionando, el HTML se genera cada minuto en el disco del locker, y
**nadie ve nada nuevo en la web**. No aparece error en ningun log — no es un error, es una ausencia.

**Como se arregla:** ver el procedimiento paso a paso en **CAMBIO DE CONTRASENA DE `fabricacion1`**,
mas abajo. Resumen: icono de OneDrive -> iniciar sesion con la nueva contrasena -> **salir de OneDrive y
volver a abrirlo desde el menu de inicio** (este ultimo paso NO sobra) -> apuntar 42 dias y poner
recordatorio.

**Como se detecta:** comparar la hora de *"Ultima actualizacion"* del dashboard **en la web** con la del
fichero en el locker. Si el local esta fresco y el de la web viejo, es esto.

> ⚠️ **NO CONFUNDIR CON LA OTRA CONTRASENA.** La de la cuenta Windows **`User`** del locker **ya no
> caduca** (se le quito la caducidad el 08/09 con `Set-LocalUser -PasswordNeverExpires`). Esa era la que
> rompia el arranque automatico. La que sigue caducando es **la de `fabricacion1`**, que es de GHI y su
> politica la fija IT.

### 2. Cuando vuelve un instrumento calibrado — TRES pasos, y ninguno es automatico

Que la empresa de calibracion lo calibre **no actualiza nada**. Al recibirlo hay que hacer, ademas de
devolverlo a su consigna:

| # | Que | Donde | Si no se hace |
|---|---|---|---|
| **a** | Poner la **nueva fecha de caducidad** | **ACTUM EPI Visor** | El `DashboardAdmin` lo seguira contando con la caducidad vieja: aparecera CADUCADO o URGENTE estando recien calibrado |
| **b** | Apuntar la fecha tambien en el **Excel** | `00.Intrumentos_Locker (1).xlsx` | Queda descuadrado con ACTUM. *(Excel antiguo, pero Inigo lo sigue manteniendo a proposito)* |
| **c** | Subir el **certificado de calibracion** | **servidor documental de la empresa** | No queda trazabilidad documental de la calibracion |

> **El paso (a) es el que mas se olvida y el que mas ruido genera despues**: dentro de dos meses parece
> que "el dashboard falla", cuando lo que falta es el dato. El sistema no puede saber que un instrumento
> se ha calibrado — solo lee lo que hay en ACTUM.

> **Devolverlo fisicamente a la consigna SI es automatico:** al identificarse y cerrar la puerta, el
> movimiento se registra solo y el instrumento vuelve a *Disponible*. Eso no hay que tocarlo a mano.

### Resumen para quien herede esto

**Dos cosas, nada mas:** re-autenticar OneDrive cada ~42 dias, y los tres pasos de arriba cada vez que
vuelve un instrumento de calibrar. **Todo lo demas el sistema lo hace solo.**

---

## 📐 CALIBRACIONES — proceso, empresas y contactos

> **Dictado por Inigo el 09/09/2026.** Conocimiento operativo que no esta en ningun sistema.

### Estrategia — por que AHORA, en septiembre

**Las auditorias suelen ser en NOVIEMBRE.** De ahi todo lo demas:

- **Pedir en septiembre la fecha de calibracion**, para enviarlos y que los calibren directamente. Asi los
  instrumentos pasan **el mayor tiempo posible aqui** y no fuera esperando hueco.
- **Dejar siempre uno de cada tipo en la empresa** (un PCE, un Testo, un nivel optico...) para que no este
  todo calibrandose a la vez y produccion se quede sin nada. O preguntar antes que va a hacer falta.
- Esto encaja con la avalancha detectada: **16 instrumentos caducan entre el 21/10 y el 01/12**. Agrupar
  por lotes y por empresa en vez de mandarlos de uno en uno segun van cayendo.

### A que empresa va cada instrumento

**Cada instrumento se manda a la empresa que consta en el Excel** — la que lo calibro o lo suministro antes.

**Excel de referencia (empresas de calibracion):**
```
\\srvdocumental\Ghihornos\Fabricacion\FABRICACION\Departamental\02 - INSTRUMENTACION\Locker instrumentacion\INSTRUMENTOS LOCKER.xlsx
```

> ⚠️ **OJO, son DOS Excel distintos y es facil confundirlos:**
> - **`INSTRUMENTOS LOCKER.xlsx`** (servidor documental, ruta de arriba) -> **las empresas de calibracion**
> - **`00.Intrumentos_Locker (1).xlsx`** (OneDrive del locker) -> el que actualiza `ActualizarExcel.ps1`
>   cada 5 minutos con UBICACION y CALIBRADO/CADUCADO

**Si hay problemas con la empresa asignada: la alternativa es NEURYLAN**, que son los mas cercanos y
"igual pueden hacer mas de todo".

### El proceso

1. **Pedir presupuesto** — Inigo tiene un correo de ejemplo **fijado en Outlook** con el formato.
2. **Hacer el pedido.**

### Contactos

| Empresa | Contacto |
|---|---|
| **Neurylan** *(alternativa general, los mas cercanos)* | `administracion@neurylan.com` |
| **Applus** | `izaskun.conde@applus.com` · **de los certificados:** `comercial.ac6m@applus.com` (FLUKE) y `calibraciones.applusleganes@applus.com` (Applus Metrology, Leganes, tel. **910 901 590**) |
| **CS Instruments** | `carlos.garcia@csinstruments.es` |
| **LEICA** | `trinidad.vilallba@leica-geosystems.com` |
| **RS** *(RS Iberia — Alcobendas, Madrid)* | `raquel.delgado@rsgroup.com` · tel. **+34 915 129 772**. Buzones generales: ofertas `ofertas@RS.rsgroup.com` · pedidos `pedidos@RS.rsgroup.com` · soporte tecnico `soporte.tecnico@RS.rsgroup.com` · atencion al cliente `atencion.cliente@RS.rsgroup.com` · centralita **91 512 96 99** (1 clientes / 2 soporte / 3 financiero) |

> Si esas personas no contestan, buscar el correo general de la empresa en Google.

### PENDIENTE — dos instrumentos posiblemente AVERIADOS

Hablado con la empresa de calibracion, **sin cerrar**. La idea: **llevarlos, que los revisen**, y si estan
averiados, que valoren **si los pueden arreglar y calibrar** o no.

| Instrumento | Nº serie | En ACTUM |
|---|---|---|
| **Atornillador Dinamometrico LDA-40 EA** | `10.00047` | **SI** — es `D-001`, **CADUCADO desde el 09/06/2026** |
| **Indicador de temperatura Phoenix TM PTM1010** | `1774+KD-9083/4/5/6` | ⚠️ **NO APARECE** en los 32 instrumentos de ACTUM |

> ⚠️ **El Phoenix TM no esta en ACTUM.** Revisada la lista completa de los 32 instrumentos del locker
> (09/09): no hay ningun Phoenix TM ni ese numero de serie. **Si no esta dado de alta, no sale en ningun
> dashboard y su calibracion no se controla ahi.** Comprobar y decidir si debe darse de alta:
> ```powershell
> sqlcmd -S "GHI-TAQUILLAS\SQLEXPRESS" -d Actum_GHI -E -W -s"|" -Q "SET NOCOUNT ON; SELECT CodigoCliente, Descripcion FROM Caja WHERE Descripcion LIKE '%PTM%' OR Descripcion LIKE '%Phoenix%' OR Descripcion LIKE '%1774%'"
> ```

### 📋 PLAN DE PEDIDOS — cruzado el 09/09/2026 (ACTUM + Excel del servidor)

> **Como se hizo:** se cruzo `Caja.FechaCaducidad` de **ACTUM** (la fuente de verdad de las fechas) con la
> columna **EMPRESA** del Excel del servidor documental (la fuente de a quien se manda cada uno).
> **32/32 instrumentos cuadran entre las dos fuentes: cero huecos.**

**21 instrumentos hay que pedirlos AHORA** (5 caducados + 16 que caducan en 90 dias).

#### El hallazgo que cambia la estrategia

Tu regla es *"dejar siempre uno de cada tipo en la empresa"*. Medido: **solo 4 modelos tienen mas de una
unidad.** De los 21 a pedir, **14 son unidad UNICA** — si se van, no hay repuesto de eso, punto.

**Donde SI se puede escalonar:**

| Modelo | Unidades | Como |
|---|---|---|
| **TESTO 872** (camara termografica) | 3 — `C-002` 29/10 · `S-001` 04/11 · `S-002` 04/11 | mandar **2, quedarse 1**, y el tercero cuando vuelva el primero |
| **TESTO 340** (analizador de gases) | 3 — `T-100-1` 04/11 · `A-004` 11/11 · `A-003` 12/01/27 | mandar los **dos que caducan**; `A-003` se queda de reserva *(ojo: `A-003` esta EN PARADERO DESCONOCIDO, ver consigna 5)* |
| **LEICA NA 730 PLUS** (nivel optico) | 2 — `M-005` **caducado** · `M-001` 01/12 | mandar **`M-005` ya**; `M-001` espera a que vuelva |
| **PCE T-1200** | 3 — todos fuera del horizonte (105d+) | **nada que hacer ahora** |

**Los 14 de unidad unica** (`T-017` `M-006` `A-005` `D-001` `L-006` `L-010` `T-007` `S-006` `T-100-4`
`L-002` `T-004` `T-005-1` `M-020` `L-001`): aqui no hay escalonado posible. Es donde toca **preguntar antes
que va a hacer falta**, que es la otra mitad de tu regla.

#### LOS LOTES, por empresa

**NEURYLAN es el lote grande: 7 seguros, y hasta 10 si se le dan los 3 dudosos.** De 21, la mitad. Es la
mejor posicion para negociar precio, y ademas son los mas cercanos.

| Empresa | N | Instrumentos (dias a caducar) |
|---|---|---|
| **NEURYLAN** | **7** | `T-004` 55 · `S-001` 56 · `T-100-1` 56 · `S-002` 56 · `M-020` 57 · `T-005-1` 57 · `A-004` 63 |
| **APPLUS** | 4 | `L-006` 42 · `L-010` 42 · `T-007` 43 · `L-001` 65 — *las tres pinzas FLUKE y la pistola* |
| **RS CALIBRATION** | 3 | `T-017` **CADUCADO 286 d** · `T-100-4` 51 · `L-002` 51 |
| **LEICA** | 2 | `M-005` **CADUCADO 132 d** · `M-001` 83 |
| **CS Instruments** | 1 | `S-006` 45 |
| **NEURYLAN (Testo)** | 1 | `C-002` 50 — *mismo proveedor, la etiqueta del Excel lo separa sin motivo* |
| **KLOTZ** | 1 | `A-005` **CADUCADO 162 d** |
| **⚠️ `Bosch / Neurylan?`** | 1 | `M-006` **CADUCADO 220 d** |
| **⚠️ `GEDORE / Neurylan?`** | 1 | `D-001` **CADUCADO 92 d** — *es uno de los dos posiblemente averiados* |

#### ✅ LAS DUDAS DEL EXCEL — resueltas por Inigo el 09/09

| Codigo | Ponia | Respuesta |
|---|---|---|
| `C-002` | `NEURYLAN (Testo)` | **Es el mismo Neurylan.** Va en el lote grande |
| `D-002` | caduca 30/05/2030 | **No caduca**: es un boroscopio. El 2030 esta puesto a proposito, no es un error |
| `E-002` | sin empresa | Es un **indicador de dial x2 + base** (Insize/Mitutoyo), consigna 31. **No se sabe si caduca** |
| `M-017` | `Neurylan?` | Sonometro PEAK TECH. **Ya calibrado** hasta 06/2027, sin prisa |
| `M-006` · `D-001` | `Bosch / Neurylan?` · `GEDORE / Neurylan?` | **Se preguntan a Neurylan en el mismo correo**, en bloque aparte |

> **PRECEDENTE QUE CIERRA LAS DOS ULTIMAS:** en su correo anterior Inigo pregunto *"¿por otro lado, seria
> tambien posible calibrar un Sonometro PEAK TECH 8005?"* y **volvio calibrado**. Esa empresa **si acepta
> marcas fuera de su linea**, asi que el Bosch y el GEDORE tienen todas las papeletas. *(Queda confirmar a
> que empresa se mando aquel correo.)*

#### El orden que propongo

1. **RS CALIBRATION y LEICA primero.** Tienen los caducados mas antiguos (`T-017` 286 dias, `M-005`
   132 dias) y son lotes pequenos: se resuelven rapido y quitan lo mas sangrante.
2. **NEURYLAN despues, como lote unico** — resolviendo antes las 3 dudas para que vayan 10 y no 7.
3. **APPLUS**, los 4 juntos. Las tres pinzas FLUKE son de funciones distintas (4-20 mA, 1500 V, 1000 A):
   **no son intercambiables entre si**, asi que aqui no hay escalonado posible aunque parezcan lo mismo.
4. **KLOTZ y CS**, sueltos, cuando toque.

> **Nota sobre `D-002`:** caduca el **30/05/2030** (1.359 dias). Es el unico con un intervalo asi de largo.
> Comprobar que no sea un error de tecleo en ACTUM.

### 📧 PLANTILLA ESTANDAR — solicitud de calibracion

> **Cementada el 09/09/2026**, mezclando la version de Inigo con la de Aitor Ulibarri. Se usa igual para
> todas las empresas: solo cambia la lista de equipos.

**Asunto:** `Solicitud de presupuesto - calibracion de N equipos - GHI Smart Furnaces`

```
Buenos dias,

Soy Inigo de GHI Smart Furnaces. Os contacto para solicitar presupuesto y plazo para la
calibracion de los siguientes instrumentos. Necesitamos certificado de calibracion emitido
bajo un sistema de gestion de calidad conforme a ISO 9001.

1. <Instrumento> <MARCA MODELO>, con el numero de serie <SERIE>
2. ...

[bloque opcional, solo si hay equipos de marca ajena]
¿Por otro lado, seria tambien posible calibrar un <equipo> con el numero de serie <serie>?

Os agradeceria que en la oferta indicaseis:
- Precio por equipo.
- Plazo desde que los recibis hasta que los devolveis.

Os comento nuestra situacion de fechas: necesitamos tenerlos operativos antes de noviembre,
por auditoria. Si algun plazo no encajase, decidmelo y organizamos los envios por lotes.

Gracias, un saludo.

Inigo Alonso
Instrumentacion - GHI Smart Furnaces
ialopez@ghifurnaces.com
```

**Por que ese orden — cada bloque esta donde esta por un motivo:**

| | Que | Por que ahi |
|---|---|---|
| 1 | Quien eres y que pides, en una frase | Quien lo abre sabe en 3 segundos si le toca a el |
| 2 | **ISO 9001** | Va **antes** de la lista: condiciona el precio. Al final, presupuestan sin ello y hay que repetir |
| 3 | Los equipos, **numerados** | *Descripcion · marca y modelo · n.º de serie*. Numerados porque con 8 equipos poder decir "el 5" ahorra un correo |
| 4 | El bloque **"¿por otro lado...?"** | Idea de Inigo. Separa lo seguro de lo dudoso, para que un "no" a eso no bloquee el resto |
| 5 | Que quieres en la oferta, **en lista** | En lista y no en prosa: contestan punto por punto y no se olvida ninguno |
| 6 | Tu fecha limite | Al final, para que suene a informacion y no a presion. Pero **tiene que estar**: si no, tu tienes prisa y ellos no lo saben |
| 7 | Firma con tu correo | Para que respondan a ti y no al buzon general |

> ⚠️ **DECISION DE INIGO (09/09): la oferta solo pide PRECIO y PLAZO.** Se propusieron dos puntos mas y
> **los descarto**, con motivo:
> - **Transporte** — *"siempre lo enviamos nosotros"*. No es una pregunta, es un dato que ya se sabe.
> - **Fuera de tolerancia** — se propuso porque es lo que puede hacer que la factura final no se parezca a
>   la oferta. Inigo prefiere no incluirlo. **Queda registrado para que ningun agente lo vuelva a anadir
>   "por ayudar": la plantilla es la de arriba, con dos puntos.**

### 🔄 EN QUE ORDEN PASAN LAS COSAS

| # | Paso | Quien | Que |
|---|---|---|---|
| 1 | **Pides presupuesto** | tu | La plantilla de arriba |
| 2 | **Llega la oferta** | ellos | Comprobar que dan **precio por equipo** y **plazo**. Si falta alguno, preguntar **antes** de seguir |
| 3 | **Haces el pedido** | tu | Confirmas y acordais fecha de envio. Hasta aqui el instrumento no se ha movido |
| 4 | **Envias** | tu | **Sacarlo del locker IDENTIFICANDOSE**, no con llave. Si sale con llave, sale sin rastro |
| 5 | **Vuelve** | ellos | Equipo + certificado |
| 6 | **Cierras el circulo** | tu | **(a)** fecha nueva en **ACTUM EPI Visor** · **(b)** en el **Excel** · **(c)** **certificado** al servidor |

> **El 6a es el que mas se olvida.** Dos meses despues parece que el dashboard falla, y lo que falta es el
> dato. El sistema no puede saber que algo se ha calibrado: solo lee lo que hay en ACTUM.

> ⚠️ **EL EXCEL NO TIENE AUTOGUARDADO** (dicho por Inigo, 09/09). Si lo editas y no guardas a mano, se
> pierde y no avisa nadie.

### 🔎 QUIEN VENDE Y QUIEN CALIBRA SON COSAS DISTINTAS — 10/09/2026

> **Esta seccion se reescribio el mismo dia.** La primera version decia *"los certificados mandan, el Excel
> miente"*. **Era falso**, y lo destapo la carpeta de pedidos. Se conserva el error porque explica el matiz.

**Como empezo:** RS pidio dar de alta a GHI como cliente nuevo para poder ofertar. Inigo miro los
certificados anteriores del Martindale y del RS PRO `22120786` y **los firmaba APPLUS**, no RS. Conclusion
aparente: el Excel se equivoca.

**Lo que habia en realidad**, leido en
`...\Locker instrumentacion\CALIBRACIONES INFORMACION (pedidos)\RS AMIDATA\2507486.pdf`:

```
Pedido 2507486 - 16/10/2025 - AMIDATA, S.A.
Parque Emp. Urbis Center, Av. Europa 19 E-3 - 28224 Pozuelo de Alarcon

  Calibracion: MARTINDALE PC15250 .........  76,86 EUR
  Calibracion: RS PRO 135 Thermometer ..... 239,00 EUR
                                    Total   315,86 EUR + IVA (382,19)
  Oferta RS de referencia: A1009058218
```

**AMIDATA es RS** (su filial espanola). Se le compra a RS, **y RS subcontrata la calibracion a Applus
Metrology**. Por eso el pedido es de RS y el certificado lo firma Applus. **Los dos documentos dicen la
verdad, pero responden a preguntas distintas:**

| Fuente | Responde a |
|---|---|
| Columna **EMPRESA** del Excel | **a quien se le COMPRA** |
| **Certificado** | **quien CALIBRA fisicamente** — puede ser un subcontratista |

> **REGLA:** antes de concluir que una fuente se equivoca, buscar si las dos pueden ser ciertas a la vez.
> Aqui se dio por falso el Excel con solo media evidencia. **La carpeta de pedidos es la que cierra la
> pregunta de "a quien se le compra"**, y no se habia mirado.

#### Lo que si quedo confirmado leyendo los 32 certificados

| Instrumento | Laboratorio que firma |
|---|---|
| `L-001` `L-006` `L-010` `T-007` (FLUKE) | **Applus** — `comercial.ac6m@applus.com` · certs. `OT00281928` `OT00275926/27/29` |
| `L-002` `T-100-4` | **Applus Metrology, Leganes** — `calibraciones.applusleganes@applus.com`, tel. **910 901 590** · certs. `25E020693` `25LC124636` |
| `M-001` | **Leica** |
| La mayoria de los TESTO | certificados emitidos por **Testo** (`info@testotis.es`), pedidos via **Neurylan** |

> **Trampa del nombre de fichero:** los certificados de `L-002` y `T-100-4` se llaman `..._RS-GHI.pdf`.
> Ese "RS" es la **marca del instrumento** (RS PRO), no el laboratorio. Hubo que abrir el PDF.

#### Certificados que faltan — pendientes de localizar, NO ausentes

Carpetas vacias: `T-017` · `M-005` · `M-006` · `A-005` · `D-001` · `D-002` · `E-002` · `E-003`.
Los cinco primeros son **los cinco caducados**.

> Se anoto que *"o no se calibraron o no se subio el certificado"*. **Inigo lo matiza (10/09): lo mas probable
> es que no los encontrase**, y para esos vale la empresa del Excel, que es donde se lo habran hecho la
> ultima vez. **Queda como "pendiente de localizar", no como "sin calibrar".** Conviene cerrarlo antes de
> noviembre: en auditoria, un instrumento sin certificado no esta respaldado aunque ACTUM tenga fecha.

#### DECISION (Inigo, 10/09): ir DIRECTO a Applus con los 7

*"Para que ellos subcontraten a Applus, para eso les escribimos nosotros directamente."*

**Sostenido por la evidencia:** Applus **ya calibro ese RS PRO 135 exacto** (cert. `25LC124636`), asi que la
capacidad esta demostrada, no supuesta. Se ahorra el margen del intermediario (RS cobro 239,00 EUR por el
RS PRO y 76,86 EUR por el Martindale), se evita el alta que pedia RS, y queda **un solo proveedor para los 7**.

> **Riesgo unico anotado:** si un RS PRO 135 sale **fuera de tolerancia**, un laboratorio externo lo calibra
> y lo reporta, pero **ajustarlo o repararlo** depende de que tenga acceso a la marca. Por la via de RS eso lo
> cubria el fabricante. Es lo unico que aportaba el intermediario.

**Precios de referencia para negociar** (pedido 2507486, oct-2025): Martindale **76,86 EUR** ·
RS PRO 135 **239,00 EUR**.

### ✏️ EL EXCEL LO ACTUALIZA INIGO A MANO — NINGUN AGENTE ESCRIBE EN EL

> **Regla de Inigo, 10/09/2026:** *"del Excel no edites tu nada, voy a esperar a que respondan y ya pondre
> yo a mano"*. **Aplica a Claude Code, Codex, GLM y a cualquier script.** El
> `INSTRUMENTOS LOCKER.xlsx` del servidor documental **se lee, no se escribe.**

Motivos de sobra: lo tiene abierto a menudo (aparece su fichero de bloqueo `~$`), **no tiene autoguardado**,
y es un documento compartido del departamento. Un agente escribiendo ahi puede pisar trabajo de una persona.

#### Cambios que le tocara hacer a Inigo — columna **M** (`EMPRESA`)

**Decididos, se pueden poner ya:**

| Celda | Codigo | Dice | Debe decir | Por que |
|---|---|---|---|---|
| **M32** | `T-017` | `RS CALIBRATION` | **`APPLUS`** | se va directo al laboratorio |
| **M17** | `T-100-4` | `RS CALIBRATION` | **`APPLUS`** | idem |
| **M20** | `L-002` | `RS CALIBRATION` | **`APPLUS`** | idem |
| **M5** | `C-002` | `NEURYLAN (Testo)` | **`NEURYLAN`** | es el mismo Neurylan |

**En espera, NO tocar hasta que contesten:**

| Celda | Codigo | Dice | A que espera |
|---|---|---|---|
| M7 | `M-006` | `Bosch / Neurylan?` | a que Neurylan diga si acepta el Bosch |
| M16 | `A-005` | `KLOTZ` | a que Neurylan diga si acepta el Klotz |
| M35 | `D-001` | `GEDORE / Neurylan?` | idem, y ademas **el instrumento esta perdido** |
| M30 | `M-017` | `Neurylan?` | **a que Inigo confirme** a que empresa mando el correo de los cuatro instrumentos. El certificado lo firma **Testo** y Neurylan es su distribuidor, pero no esta confirmado |

**Ya correctas:** `M11`, `M13`, `M14` (pinzas FLUKE) y `M31` (pistola FLUKE) — todas `APPLUS`.

### 📦 LOTE APPLUS — tambien en DOS TANDAS (decision de Inigo, 10/09)

*"Vamos a hacer tambien 2 tandas en Applus, que se va a quedar vacio esto si no."* Con 6 equipos en Neurylan
y 6 en Applus a la vez serian **12 de 32 fuera del locker**.

**1.ª tanda — 4 equipos, los mas urgentes:**

| Codigo | Instrumento | Caduca |
|---|---|---|
| `T-017` | Calibrador de procesos RS PRO 135 | **vencido hace 286 dias** |
| `L-006` | Pinza amperimetrica 4-20 mA FLUKE 771 | 21/10 |
| `L-010` | Pinza amperimetrica 1500 V FLUKE 393 | 21/10 |
| `T-007` | Pistola de temperatura infrarroja FLUKE 561 | 22/10 |

**2.ª tanda — 3 equipos, con mas margen:**

| Codigo | Instrumento | Caduca | Nota |
|---|---|---|---|
| `T-100-4` | Calibrador de procesos RS PRO 135 | 30/10 | **gemelo del `T-017`**: espera a que vuelva |
| `L-002` | Comprobador de fases MARTINDALE PC15250 | 30/10 | |
| `L-001` | Pinza amperimetrica 1000 A FLUKE 376 FC | 13/11 | |

Asi queda siempre **una pinza y un calibrador** dentro, y salen primero el vencido y los tres de octubre.

> **NO hace falta reescribir a Applus:** la oferta pedida cubre los 7. Las tandas se le comunican **al hacer
> el pedido**, cuando ya se conozca su plazo.

> ⏰ **RECORDATORIO ACTIVO, pedido por Inigo (10/09):** *"en cuanto me respondan se lo digo, acuerdate me
> dices que se lo diga"*. **Cuando llegue la oferta de Applus O la de Neurylan, lo PRIMERO es recordarle a
> Inigo que les comunique el envio en DOS TANDAS**, con la lista de que sale en cada una. Si no se dice al
> hacer el pedido, saldran los 7 (u 8) de golpe y el locker se queda vacio.

### 📍 `A-0031` — TESTO 340 que NO es del locker (confirmado por Inigo, 10/09)

*"Igual me llega un analizador de gases TESTO para calibrar, no esta registrado en el locker, aunque tiene
pegatina A-0031."* Y al preguntar por el formato raro del codigo:
**"Es A-0031, si si, aunque sea raro."**

> **CORRECCION:** se sospecho que `A-0031` (cuatro digitos) fuese el `A-003` mal leido, porque todos los del
> locker llevan tres. **No lo es: el codigo es correcto tal cual.** Es un instrumento distinto de los tres
> TESTO 340 conocidos (`A-003` `61186226` · `A-004` `62370623` · `T-100-1` `63862113`).

**Matiz clave de Inigo:** *"igual me mandan calibrarlo, eso no quiere decir que lo registre en el locker,
puede ir al cuarto de instrumentacion que no tiene locker"*.

**Calibrar un instrumento NO implica darlo de alta en ACTUM.** Hay instrumentos que viven en el **cuarto de
instrumentacion**, fuera del alcance de este sistema.

#### ⚠️ AGUJERO CONOCIDO: el cuarto de instrumentacion no lo vigila nada

Los instrumentos de ese cuarto **no estan ni en ACTUM ni en el Excel del locker** — el Excel tiene
exactamente las **32 filas** de las 32 consignas, ni una mas. Consecuencia medida:

| Control | ¿Cubre el cuarto? |
|---|---|
| Dashboard y pestana Calibracion | **no** |
| Banner de salud | **no** |
| Excel `INSTRUMENTOS LOCKER.xlsx` | **no** |
| Campana de calibraciones de septiembre | **no** |

**Si un instrumento de ahi caduca, no salta en ningun sitio.** Ya hay al menos dos casos conocidos:
el **Phoenix TM PTM1010** (`1774+KD-9083/4/5/6`) y, si acaba alli, este `A-0031`.

> **No se propone meterlos en el locker** — eso es otra decision, y Inigo ya dijo el 09/09 que el Phoenix
> queda fuera del alcance del proyecto a proposito. **Lo que si conviene es saber si existe alguna lista de
> ese cuarto**, porque hoy su calibracion depende solo de que alguien se acuerde. Pregunta abierta a Inigo.

### ✅ COLUMNA `CALIBRAR EN` — creada por Inigo el 10/09, revisada

Inigo la creo el mismo dia. **Los tres cambios decididos estan hechos:** `T-100-4`, `L-002` y `T-017`
pasan a **APPLUS** en `CALIBRAR EN`. Los interrogantes se dejaron igual en ambas columnas, que es lo
correcto mientras se espera respuesta.

**Las dos filas que no cuadraban al revisarlas:**

| Fila | Codigo | Que es | Que puso | Lectura |
|---|---|---|---|---|
| 33 | **`E-003`** | Medidor LCR **RS Pro** LCR1701, consigna 30, caduca 16/02/2027 (160 d) | `RS CALIBRATION` → **`(APPLUS)`** | **paréntesis bien puesto**: es marca RS Pro como el `T-017` y el `T-100-4`, asi que **por patron** iria a Applus, pero **no hay certificado suyo** en el servidor: no esta probado. Caduca en 160 dias — **decidir cuando Applus conteste** sobre los otros tres |
| 34 | **`E-002`** | Indicador de dial x2 + base, consigna 31 | vacio / vacio | correcto: sigue sin saberse |

> **Ojo, hay CUATRO instrumentos con `RS CALIBRATION`, no tres.** El cuarto es el `E-003`, que no entro en
> la campana porque caduca a 160 dias. Si Applus acepta los tres actuales, este va detras.

#### ✅ TERMINADO EL 10/09 — 31 de 32, y queda bien

Inigo eligio el camino **A** (rellenar la marca de verdad) y lo completo el mismo dia. **La columna `M`
(`EMPRESA`) ya es la MARCA y la `N` (`CALIBRAR EN`) el proveedor.** Estado medido:

| Columna | Contenido | Estado |
|---|---|---|
| **M · EMPRESA** | marca del fabricante: TESTO, FLUKE, LEICA, PCE, RS PRO, MARTINDALE, MEGGER, EXTECH, PEAK TECH, BOSCH, KLOTZ, GEDORE, DRAGER, CS | **31/32** |
| **N · CALIBRAR EN** | a quien se le compra: NEURYLAN, APPLUS, LEICA, CS | completa |

**Unica casilla vacia: `M34` (`E-002`).** La marca **si se sabe** — esta en la propia columna MODELO:
**`Insize/Mitutoyo`**. El `CALIBRAR EN` de esa fila **debe seguir vacio**: no se sabe donde se calibra ni si
caduca.

**Dos decisiones de Inigo mejores que lo propuesto:**
- **`E-003` → `(RS CALIBRATION / APPLUS)`** en vez de `(APPLUS)` a secas. **Conserva de donde venia y adonde
  iria**, asi que dentro de un ano se entiende el cambio sin preguntar.
- **Mantuvo los interrogantes** en vez de simplificarlos a `¿NEURYLAN?`. Mas conservador y no se pierde nada.

#### 🧩 EL ULTIMO INTERROGANTE SE CIERRA CON EL PROPIO EXCEL

`M-017` es el unico con `Neurylan?` en `CALIBRAR EN`. **Pero mirando las filas vecinas se resuelve:**

| Codigo | Marca | CALIBRAR EN |
|---|---|---|
| `L-004` | MEGGER | NEURYLAN |
| `T-008` | TESTO | NEURYLAN |
| `L-005` | FLUKE | NEURYLAN |
| **`M-017`** | **PEAK TECH** | **`Neurylan?`** |

**Esos cuatro son exactamente los del correo que Inigo enseno el 10/09** —el que preguntaba *"¿por otro lado,
seria tambien posible calibrar un Sonometro PEAK TECH 8005?"*— y **volvieron juntos**.

> **Si los otros tres son Neurylan, el cuarto tambien: era el mismo mensaje.** Y si no hay certeza sobre los
> tres, entonces el interrogante deberia estar en los cuatro, no en uno solo. **Coherencia, no dato nuevo.**

### 💡 IDEA DE INIGO (10/09) — partir la columna EMPRESA del Excel en dos

*"Se podria hacer una columna nueva: la de empresa que sea de que empresa es, y otra que se llame
CALIBRAR EN."* **Para un futuro, cuando el lo vea.** Ataca justo la confusion que costo tiempo el 10/09.

En realidad son **TRES** cosas distintas, aunque solo dos necesitan columna:

| | Que es | De donde sale | Columna? |
|---|---|---|---|
| **MARCA** | quien fabrico el instrumento | el propio equipo | **si** — columna nueva |
| **CALIBRAR EN** | **a quien se le COMPRA** la calibracion | el pedido | **si** — la actual `EMPRESA` renombrada |
| *(quien la hace)* | quien firma el certificado | el certificado PDF | **no** — se consulta cuando haga falta |

> **La tercera puede NO coincidir con la segunda, y es normal, no un error.** Caso real: se le compraba a
> **RS/Amidata** y calibraba **Applus Metrology**. Por no tener esto separado, el 10/09 se dio por falso el
> Excel cuando estaba bien.

**Ejemplo de como quedaria:** `A-005` -> MARCA: **Klotz** · CALIBRAR EN: **Neurylan** *(si lo aceptan)*.
Hoy esa casilla pone `KLOTZ` a secas y no se sabe cual de las dos cosas significa — y resulta que era la
marca, porque **no consta ningun pedido ni certificado de Klotz**.

### ✅ EL ATORNILLADOR `D-001` NO ESTABA PERDIDO: ESTA EN REPARACION (11/09)

**Inigo pregunto y le contestaron: se mando a arreglar.** *"No se si a Prada o... **Naroa sabe, preguntar**.
Cuando llegue ya me enterare."*

> **Eso explica por que el rastro se cortaba.** El historial terminaba en `AITOR U. ULIBARRI`, que lo extrajo
> el **01/04/2026 13:25:33** y no consta devolucion. No lo perdio nadie: **salio del circuito para repararlo**
> y por eso nunca volvio al locker. La busqueda se cierra; queda una pregunta concreta.

**PENDIENTE: preguntar a NAROA a que empresa se mando.**

#### ⚠️ CONSECUENCIA DIRECTA: hay que corregir el correo de Neurylan

En la consulta enviada el 10/09 iba este equipo como tercera pregunta de marca ajena:

> *"Atornillador dinamometrico GEDORE LDA-40 EA, con el numero de serie 10.00047. Este puede estar averiado:
> agradeceria que lo revisaseis y me dijeseis si es reparable y calibrable."*

**Ya esta en reparacion en otro sitio, asi que al contestar Neurylan hay que retirarlo.** Las consultas de
marca ajena pasan de **3 a 2**:

| Codigo | Equipo | Estado |
|---|---|---|
| `M-006` | Nivel optico BOSCH GOL 20 D, `801000535` | **sigue en pie** — 220 dias caducado |
| `A-005` | Analizador de particulas KLOTZ ABAKUS, `AMF-20707` | **sigue en pie** — 162 dias caducado |
| ~~`D-001`~~ | ~~Atornillador GEDORE LDA-40 EA~~ | ❌ **RETIRAR: ya esta en reparacion** |

### 📥 `L-006` RECUPERADO — y cierra el movimiento mas antiguo abierto (10/09)

Aparecio la **pinza amperimetrica FLUKE 771** (`L-006`, consigna 8) e Inigo la guardo. Verificado en el CSV:

```
09/10/2026 15:21:35;IKER L.;LASSO;08;Pinza amp. 4-20mA / FLUKE 771 / 66460003WS;Devolucion;Cerrada
```

> **Detalle que merece la pena:** esa pinza la extrajo Lasso el **`16/07/2026 13:20:21`** — exactamente
> **la ultima identificacion que hubo antes del incidente**, la fecha citada en todo este documento. Era el
> movimiento mas antiguo que seguia abierto en el sistema. **Ya esta cerrado.**

**Guardada a nombre de LASSO**, identificandose como el, igual que se hizo con Javier y el `A-003`: asi el
registro dice que devuelve quien lo tenia, y **no hace falta correccion manual**.

**Efecto en la campana:** el `L-006` esta **fisicamente dentro** y confirmado, asi que puede salir en la
**1.ª tanda de Applus** sin depender de nadie.

> **Otro movimiento del 10/09 visto al revisar el CSV:** `JAVIER JULIAN DE LAMO` extrajo tambien el
> **sonometro PEAK TECH 8005** (`M-017`, consigna 27) a las **14:51:35**. Sin urgencia — caduca 02/06/2027.

### ✏️ EL EXCEL LO ACTUALIZA INIGO A MANO — NINGUN AGENTE ESCRIBE EN EL

> **Regla de Inigo, 10/09/2026:** *"del Excel no edites tu nada, voy a esperar a que respondan y ya pondre
> yo a mano"*. **Aplica a Claude Code, Codex, GLM y a cualquier script.** El
> `INSTRUMENTOS LOCKER.xlsx` del servidor documental **se lee, no se escribe.**

Motivos de sobra: lo tiene abierto a menudo (aparece su fichero de bloqueo `~$`), **no tiene autoguardado**,
y es un documento compartido del departamento. Un agente escribiendo ahi puede pisar trabajo de una persona.

#### Cambios que le tocara hacer a Inigo — columna **M** (`EMPRESA`)

**Decididos, se pueden poner ya:**

| Celda | Codigo | Dice | Debe decir | Por que |
|---|---|---|---|---|
| **M32** | `T-017` | `RS CALIBRATION` | **`APPLUS`** | se va directo al laboratorio |
| **M17** | `T-100-4` | `RS CALIBRATION` | **`APPLUS`** | idem |
| **M20** | `L-002` | `RS CALIBRATION` | **`APPLUS`** | idem |
| **M5** | `C-002` | `NEURYLAN (Testo)` | **`NEURYLAN`** | es el mismo Neurylan |

**En espera, NO tocar hasta que contesten:**

| Celda | Codigo | Dice | A que espera |
|---|---|---|---|
| M7 | `M-006` | `Bosch / Neurylan?` | a que Neurylan diga si acepta el Bosch |
| M16 | `A-005` | `KLOTZ` | a que Neurylan diga si acepta el Klotz |
| M35 | `D-001` | `GEDORE / Neurylan?` | idem, y ademas **el instrumento esta perdido** |
| M30 | `M-017` | `Neurylan?` | **a que Inigo confirme** a que empresa mando el correo de los cuatro instrumentos. El certificado lo firma **Testo** y Neurylan es su distribuidor, pero no esta confirmado |

**Ya correctas:** `M11`, `M13`, `M14` (pinzas FLUKE) y `M31` (pistola FLUKE) — todas `APPLUS`.

### 📦 LOTE APPLUS — tambien en DOS TANDAS (decision de Inigo, 10/09)

*"Vamos a hacer tambien 2 tandas en Applus, que se va a quedar vacio esto si no."* Con 6 equipos en Neurylan
y 6 en Applus a la vez serian **12 de 32 fuera del locker**.

**1.ª tanda — 4 equipos, los mas urgentes:**

| Codigo | Instrumento | Caduca |
|---|---|---|
| `T-017` | Calibrador de procesos RS PRO 135 | **vencido hace 286 dias** |
| `L-006` | Pinza amperimetrica 4-20 mA FLUKE 771 | 21/10 |
| `L-010` | Pinza amperimetrica 1500 V FLUKE 393 | 21/10 |
| `T-007` | Pistola de temperatura infrarroja FLUKE 561 | 22/10 |

**2.ª tanda — 3 equipos, con mas margen:**

| Codigo | Instrumento | Caduca | Nota |
|---|---|---|---|
| `T-100-4` | Calibrador de procesos RS PRO 135 | 30/10 | **gemelo del `T-017`**: espera a que vuelva |
| `L-002` | Comprobador de fases MARTINDALE PC15250 | 30/10 | |
| `L-001` | Pinza amperimetrica 1000 A FLUKE 376 FC | 13/11 | |

Asi queda siempre **una pinza y un calibrador** dentro, y salen primero el vencido y los tres de octubre.

> **NO hace falta reescribir a Applus:** la oferta pedida cubre los 7. Las tandas se le comunican **al hacer
> el pedido**, cuando ya se conozca su plazo.

> ⏰ **RECORDATORIO ACTIVO, pedido por Inigo (10/09):** *"en cuanto me respondan se lo digo, acuerdate me
> dices que se lo diga"*. **Cuando llegue la oferta de Applus O la de Neurylan, lo PRIMERO es recordarle a
> Inigo que les comunique el envio en DOS TANDAS**, con la lista de que sale en cada una. Si no se dice al
> hacer el pedido, saldran los 7 (u 8) de golpe y el locker se queda vacio.

### 📍 `A-0031` — TESTO 340 que NO es del locker (confirmado por Inigo, 10/09)

*"Igual me llega un analizador de gases TESTO para calibrar, no esta registrado en el locker, aunque tiene
pegatina A-0031."* Y al preguntar por el formato raro del codigo:
**"Es A-0031, si si, aunque sea raro."**

> **CORRECCION:** se sospecho que `A-0031` (cuatro digitos) fuese el `A-003` mal leido, porque todos los del
> locker llevan tres. **No lo es: el codigo es correcto tal cual.** Es un instrumento distinto de los tres
> TESTO 340 conocidos (`A-003` `61186226` · `A-004` `62370623` · `T-100-1` `63862113`).

**Matiz clave de Inigo:** *"igual me mandan calibrarlo, eso no quiere decir que lo registre en el locker,
puede ir al cuarto de instrumentacion que no tiene locker"*.

**Calibrar un instrumento NO implica darlo de alta en ACTUM.** Hay instrumentos que viven en el **cuarto de
instrumentacion**, fuera del alcance de este sistema.

#### ⚠️ AGUJERO CONOCIDO: el cuarto de instrumentacion no lo vigila nada

Los instrumentos de ese cuarto **no estan ni en ACTUM ni en el Excel del locker** — el Excel tiene
exactamente las **32 filas** de las 32 consignas, ni una mas. Consecuencia medida:

| Control | ¿Cubre el cuarto? |
|---|---|
| Dashboard y pestana Calibracion | **no** |
| Banner de salud | **no** |
| Excel `INSTRUMENTOS LOCKER.xlsx` | **no** |
| Campana de calibraciones de septiembre | **no** |

**Si un instrumento de ahi caduca, no salta en ningun sitio.** Ya hay al menos dos casos conocidos:
el **Phoenix TM PTM1010** (`1774+KD-9083/4/5/6`) y, si acaba alli, este `A-0031`.

> **No se propone meterlos en el locker** — eso es otra decision, y Inigo ya dijo el 09/09 que el Phoenix
> queda fuera del alcance del proyecto a proposito. **Lo que si conviene es saber si existe alguna lista de
> ese cuarto**, porque hoy su calibracion depende solo de que alguien se acuerde. Pregunta abierta a Inigo.

### ✅ COLUMNA `CALIBRAR EN` — creada por Inigo el 10/09, revisada

Inigo la creo el mismo dia. **Los tres cambios decididos estan hechos:** `T-100-4`, `L-002` y `T-017`
pasan a **APPLUS** en `CALIBRAR EN`. Los interrogantes se dejaron igual en ambas columnas, que es lo
correcto mientras se espera respuesta.

**Las dos filas que no cuadraban al revisarlas:**

| Fila | Codigo | Que es | Que puso | Lectura |
|---|---|---|---|---|
| 33 | **`E-003`** | Medidor LCR **RS Pro** LCR1701, consigna 30, caduca 16/02/2027 (160 d) | `RS CALIBRATION` → **`(APPLUS)`** | **paréntesis bien puesto**: es marca RS Pro como el `T-017` y el `T-100-4`, asi que **por patron** iria a Applus, pero **no hay certificado suyo** en el servidor: no esta probado. Caduca en 160 dias — **decidir cuando Applus conteste** sobre los otros tres |
| 34 | **`E-002`** | Indicador de dial x2 + base, consigna 31 | vacio / vacio | correcto: sigue sin saberse |

> **Ojo, hay CUATRO instrumentos con `RS CALIBRATION`, no tres.** El cuarto es el `E-003`, que no entro en
> la campana porque caduca a 160 dias. Si Applus acepta los tres actuales, este va detras.

#### ✅ TERMINADO EL 10/09 — 31 de 32, y queda bien

Inigo eligio el camino **A** (rellenar la marca de verdad) y lo completo el mismo dia. **La columna `M`
(`EMPRESA`) ya es la MARCA y la `N` (`CALIBRAR EN`) el proveedor.** Estado medido:

| Columna | Contenido | Estado |
|---|---|---|
| **M · EMPRESA** | marca del fabricante: TESTO, FLUKE, LEICA, PCE, RS PRO, MARTINDALE, MEGGER, EXTECH, PEAK TECH, BOSCH, KLOTZ, GEDORE, DRAGER, CS | **31/32** |
| **N · CALIBRAR EN** | a quien se le compra: NEURYLAN, APPLUS, LEICA, CS | completa |

**Unica casilla vacia: `M34` (`E-002`).** La marca **si se sabe** — esta en la propia columna MODELO:
**`Insize/Mitutoyo`**. El `CALIBRAR EN` de esa fila **debe seguir vacio**: no se sabe donde se calibra ni si
caduca.

**Dos decisiones de Inigo mejores que lo propuesto:**
- **`E-003` → `(RS CALIBRATION / APPLUS)`** en vez de `(APPLUS)` a secas. **Conserva de donde venia y adonde
  iria**, asi que dentro de un ano se entiende el cambio sin preguntar.
- **Mantuvo los interrogantes** en vez de simplificarlos a `¿NEURYLAN?`. Mas conservador y no se pierde nada.

#### 🧩 EL ULTIMO INTERROGANTE SE CIERRA CON EL PROPIO EXCEL

`M-017` es el unico con `Neurylan?` en `CALIBRAR EN`. **Pero mirando las filas vecinas se resuelve:**

| Codigo | Marca | CALIBRAR EN |
|---|---|---|
| `L-004` | MEGGER | NEURYLAN |
| `T-008` | TESTO | NEURYLAN |
| `L-005` | FLUKE | NEURYLAN |
| **`M-017`** | **PEAK TECH** | **`Neurylan?`** |

**Esos cuatro son exactamente los del correo que Inigo enseno el 10/09** —el que preguntaba *"¿por otro lado,
seria tambien posible calibrar un Sonometro PEAK TECH 8005?"*— y **volvieron juntos**.

> **Si los otros tres son Neurylan, el cuarto tambien: era el mismo mensaje.** Y si no hay certeza sobre los
> tres, entonces el interrogante deberia estar en los cuatro, no en uno solo. **Coherencia, no dato nuevo.**

### 💡 IDEA DE INIGO (10/09) — partir la columna EMPRESA del Excel en dos

*"Se podria hacer una columna nueva: la de empresa que sea de que empresa es, y otra que se llame
CALIBRAR EN."* **Para un futuro, cuando el lo vea.** Ataca justo la confusion que costo tiempo el 10/09.

En realidad son **TRES** cosas distintas, aunque solo dos necesitan columna:

| | Que es | De donde sale | Columna? |
|---|---|---|---|
| **MARCA** | quien fabrico el instrumento | el propio equipo | **si** — columna nueva |
| **CALIBRAR EN** | **a quien se le COMPRA** la calibracion | el pedido | **si** — la actual `EMPRESA` renombrada |
| *(quien la hace)* | quien firma el certificado | el certificado PDF | **no** — se consulta cuando haga falta |

> **La tercera puede NO coincidir con la segunda, y es normal, no un error.** Caso real: se le compraba a
> **RS/Amidata** y calibraba **Applus Metrology**. Por no tener esto separado, el 10/09 se dio por falso el
> Excel cuando estaba bien.

**Ejemplo de como quedaria:** `A-005` -> MARCA: **Klotz** · CALIBRAR EN: **Neurylan** *(si lo aceptan)*.
Hoy esa casilla pone `KLOTZ` a secas y no se sabe cual de las dos cosas significa — y resulta que era la
marca, porque **no consta ningun pedido ni certificado de Klotz**.

### 🔍 BUSCAR EL ATORNILLADOR `D-001` — el rastro, medido el 10/09

**Ultimo movimiento registrado, y ahi se acaba:**

```
01/04/2026 13:24:35  ASIER A. ALABORT      Devolucion
01/04/2026 13:25:33  AITOR U. ULIBARRI     Extraccion   <- fin del rastro
```

**`AITOR U. ULIBARRI` lo saco el 1 de abril y no consta devolucion.** Mas de cinco meses.

**Dos fuentes independientes coinciden**, asi que no es suposicion:
- El `HistorialCompleto.csv` (lineas 469-470).
- El evento **`1002`** capturado el 08/09 al abrir consignas: la **32 asignada al usuario 59 = AITOR**.

**Anomalia del mismo dia:** Asier A. Alabort lo **devolvio** a las 13:24:35 **sin que conste que lo sacara
nunca**. Circulo de mano en mano sin pasar por el locker — lo que encaja con que acabase en el sitio de
Inigo sin registro.

**Orden para buscarlo:** (1) **Aitor Ulibarri**, ultimo registrado · (2) **Asier Alabort**, lo tuvo justo
antes y sabe a quien se lo paso · (3) el propio sitio de Inigo, donde el recuerda haberlo dejado para
mandarlo a arreglar.

> ⚠️ **CORRECCION:** se anoto que el `D-001` era *"el unico de los 32 sin numero de serie en ACTUM"*.
> **Es FALSO.** Las filas del historial de **noviembre de 2025** ya lo llevan:
> `Atornillador Dinametrico / LDA-40 / EA 10.00047`. El dato se leyo de una tabla con el texto **truncado**
> y se dio por ausente lo que solo estaba cortado. **Mismo patron que los `<tr>` y el `<script>`: fallaba el
> instrumento de medida, no el sujeto.** Antes de declarar que un campo esta vacio, leerlo sin truncar.

### 📦 LOTE NEURYLAN — pedido el 10/09/2026

**8 equipos a presupuestar + 3 consultas de marca ajena.** Se pide precio de los ocho pero **se envian en
DOS TANDAS**, para no quedarse sin ningun instrumento operativo de un tipo.

| # | Codigo | Instrumento | Serie | Caduca | Tanda |
|---|---|---|---|---|---|
| 1 | `C-002` | Camara termografica TESTO 872 | 62826812 | 29/10 | **1.ª** |
| 2 | `S-001` | Camara termografica TESTO 872 | 62813457 | 04/11 | **1.ª** |
| 3 | `S-002` | Camara termografica TESTO 872 | 62826952 | 04/11 | 2.ª — **se queda de reserva** |
| 4 | `T-100-1` | Analizador de gases TESTO 340 | 63862113 | 04/11 | **1.ª** |
| 5 | `A-004` | Analizador de gases TESTO 340 | 62370623 | 11/11 | 2.ª — **se queda de reserva** |
| 6 | `T-005-1` | Termometro con sonda TESTO 925 | 34768073 | 05/11 | **1.ª** (unidad unica) |
| 7 | `M-020` | Medidor presion diferencial TESTO 512 | BA150023 | 05/11 | **1.ª** (unidad unica) |
| 8 | `T-004` | Calibrador multifuncion EXTECH PRC30 | 15549 | 03/11 | **1.ª** (unidad unica) |

**Consultas de marca ajena, en bloque aparte del correo:**

| Codigo | Equipo | Nota |
|---|---|---|
| `M-006` | Nivel optico BOSCH GOL 20 D, `801000535` | **220 dias caducado** |
| `A-005` | Analizador de particulas KLOTZ ABAKUS, `AMF-20707` | **162 dias caducado** — ver abajo |
| `D-001` | Atornillador GEDORE LDA-40 EA, `10.00047` | **92 dias**, posiblemente averiado, y **hoy perdido** |

#### Por que el KLOTZ va aqui y no a Klotz

Buscado el 10/09 en todo el servidor documental: **no hay certificado del `A-005`, no hay carpeta de pedidos
de KLOTZ, y no hay ningun fichero con ese nombre.** Las carpetas de pedidos son solo APPLUS, CS, LEICA,
NEURYLAN y RS AMIDATA.

> **No consta que el `A-005` lo haya calibrado nunca nadie.** El "KLOTZ" del Excel parece ser **el fabricante**,
> no la empresa a la que se mando. Por eso se pregunta a Neurylan, que ya acepto un PEAK TECH fuera de su
> linea. Si dicen que no, entonces se busca a Klotz directamente.

#### El ajuste que obligo a rehacer el lote

El plan original mandaba 7 equipos con `S-002` retenida. **Al mirar los datos del 10/09 aparecio un problema:**
con el `A-003` extraido por Javier de Lamo, mandar los **dos** analizadores TESTO 340 dejaba el locker
**sin ningun analizador de gases disponible**. De ahi las dos tandas y que `A-004` se quede.

> **Desbloqueo:** el `T-100-1` es el de la consigna 22, que volvio el 09/09. **Antes no se podia mandar
> porque no aparecia; ahora si.**

### 📊 ESTADO DE LA CAMPANA — se actualiza segun vayan contestando

> **Este es el cuaderno de la campana.** Inigo ira diciendo que manda y que le responden; se apunta aqui,
> en el mismo turno, con la fecha. Sin esto, dentro de tres semanas nadie sabe por donde iba.

| Lote | Equipos | Presupuesto pedido | Oferta recibida | Pedido | Enviado | Vuelto y cerrado |
|---|---|---|---|---|---|---|
| ~~**1 · RS / Amidata**~~ | ~~3~~ | **DESCARTADO 10/09** — se va **directo a Applus**, que es quien calibra de verdad. Los 3 equipos pasan al lote 5 | | | | |
| **2 · Leica** | 1 | — | — | — | — | — |
| ~~**3 · Klotz**~~ | ~~1~~ | **FUSIONADO 10/09** con Neurylan: no consta contacto ni pedido ni certificado de Klotz | | | | |
| **4 · Neurylan** | **8 + 3** | **10/09/2026 · ENVIADO** | — | — | — | — |
| **5 · Applus** | **7** *(4 FLUKE + los 3 que iban via RS)* | **10/09/2026** | — | — | — | — |
| **6 · CS Instruments** | 1 | — | — | — | — | — |

**Historial del lote 5 (Applus, antes 1+5):** el 10/09 se pide presupuesto de **los 7 juntos** a
`izaskun.Conde@applus.com` *(con C mayuscula — corregido por Inigo)*, con copia a `comercial.ac6m@applus.com`
y `calibraciones.applusleganes@applus.com` por si son laboratorios distintos. **En el correo van las referencias de sus propios certificados anteriores**
(`OT00275926/27/29`, `OT00281928`, `25E020693`, `25LC124636`): es lo que mas acelera una oferta, porque no
tienen que buscar nada.

**Historial del lote 1 (RS — CERRADO):** enviado a Raquel Delgado el **09/09**. Respondio **autorespuesta de
vacaciones hasta el 13/09** con la lista de buzones generales. Reenviado el mismo **09/09** a `ofertas@RS.rsgroup.com` con
copia a Raquel, para no perder 4 dias y que ella lo tenga al volver.
> ⚠️ Ese buzon es de *"solicitud de ofertas de **material**"* y esto es un **servicio** de calibracion:
> puede que redirijan otra vez. Siguiente parada: `soporte.tecnico@RS.rsgroup.com` o el telefono
> **91 512 96 99 opcion 2**, que suele resolver en un minuto a que buzon va.

**Cierre de RS (10/09):** Natalia Murata (Customer Service BBDD, `Data.RSIberia@rs.rsgroup.com`) pidio
alta como cliente nuevo —direccion fiscal, tarjeta NIF, persona de contacto— pese a existir el pedido
`2507486` de octubre de 2025. Se responde declinando el alta con cortesia, sin dar detalles del cambio de via.

**Retenido tambien `T-100-4`:** es el mismo modelo que el `T-017` (RS PRO 135). Se manda primero el `T-017`,
vencido hace 286 dias, y el otro cuando vuelva. **Los 4 FLUKE NO se pueden escalonar**: miden magnitudes
distintas (4-20 mA, 1500 V, 1000 A, infrarrojos) y no hay reserva posible.

**Retenidos a proposito, para no quedarse sin repuesto:** `M-001` (2º nivel optico LEICA) y `S-002`
(3ª camara TESTO 872). Se mandan **cuando vuelva** el primero de su pareja.

**Al cerrar cada lote, los 3 pasos del apartado de mantenimiento:** fecha en ACTUM · fecha en el Excel ·
certificado al servidor documental.

### 📌 PENDIENTES FISICOS DE INIGO (09/09/2026)

| | Que | Detalle |
|---|---|---|
| 1 | **Buscar el atornillador `D-001`** | Lo dejo cerca de su sitio para mandarlo a arreglar y **no esta**. La consigna 32 lo da *En uso*, asi que abrirla con llave probablemente este vacia |
| ~~2~~ | ~~**Serie del `D-001` en ACTUM**~~ | ❌ **NO ERA PENDIENTE.** La serie `EA 10.00047` **ya estaba** en la descripcion desde 2025; se leyo truncada. Ver la correccion en la seccion de busqueda del `D-001` |
| 3 | **Pegatina `L-004` + meterlo en la consigna 9** | Megger MIT320 `102465739`, vuelto calibrado hasta 26/05/2027. **Meterlo identificandose** para que la devolucion quede registrada a su nombre |
| 4 | **Bajar a la consigna 31, abrirla con llave** | `E-002` = **INDICADOR DE DIAL x2 + BASE** (Insize/Mitutoyo). **El numero de serie no esta en ninguna parte** —ni Excel ni ACTUM—, hay que leerlo del instrumento y ponerlo en el nombre desde el Visor. **Aqui el viaje SI hace falta** |
| ~~5~~ | ~~**Localizar el TESTO 340 de la consigna 22**~~ | **RESUELTO 09/09:** lo tenia Sergio Vega y lo devolvio identificandose a las **11:52:50**. CSV: una sola devolucion, serie `63862113`. |
| 6 | **Buscar el correo de Klotz** | No consta. Mirar el certificado anterior; si no, preguntarselo a Neurylan |

> **Correccion del mismo dia:** se dijo primero que el viaje a por el numero de serie era a la consigna 32 y
> que se podia ahorrar. **Era la 31, y ahi el viaje si hace falta.** Son dos instrumentos distintos: el 32 es
> el atornillador (serie conocida, instrumento perdido) y el 31 el indicador de dial (instrumento en su
> sitio, serie desconocida).

### El objetivo de fondo

> **La idea de todo este dashboard es QUITAR el Excel en el futuro.** De momento Inigo lo sigue
> actualizando a mano a proposito, hasta que el sistema cubra todo lo que hoy cubre el Excel.

---

## 🔑 CAMBIO DE CONTRASENA DE `fabricacion1` — el procedimiento exacto

> **Dictado por Inigo el 09/09/2026.** Cada ~42 dias. Es el mantenimiento nº 1 del proyecto.

1. **Salir de la pantalla de devolucion/extraccion** del locker: pulsar **SALIR** y meter el codigo de
   usuario *(el de Inigo es `040905`; cada persona usa el suyo)*.
2. Ya en Windows: **icono de OneDrive** (abajo a la derecha) -> **iniciar sesion** con la **nueva
   contrasena** de `fabricacion1@ghifurnaces.com`.
3. **Y ahora lo que no es evidente y hay que hacer igualmente:** volver a pulsar el icono de abajo a la
   derecha -> **salir de OneDrive**. Despues, en el buscador de aplicaciones (abajo a la izquierda),
   buscar **OneDrive**, abrirlo desde ahi y **volver a iniciar sesion**. Con eso arranca de nuevo.
4. **Apuntar 42 dias desde ese dia** y poner un recordatorio para cambiarla **un poco ANTES de que
   caduque**, y que el locker no llegue a pararse.

> **Por que el paso 3 no sobra:** OneDrive puede quedarse en *"Buscando cambios..."* despues de
> re-autenticar y no subir nada, con el icono girando como si trabajara. Cerrarlo y reabrirlo desde el
> menu de inicio es lo que lo desbloquea. Ya paso el 14/05 y el 10/06.

---

## ⚡ LA BIOS `POWER ON` — CONFIGURADA, **NO PROBADA** (medido el 10/09)

**Pregunta de Inigo que destapo el hueco:** *"reiniciamos y se encendia, esa era la prueba. Pero si lo
apago, ¿se va a encender tambien?"*

**No.** Y la distincion importa:

| Gesto | ¿Se enciende solo? | Por que |
|---|---|---|
| **Reiniciar** | si | el equipo nunca pierde la alimentacion |
| **Apagar Windows** y dejar la corriente puesta | **NO, se queda apagado para siempre** | nada dispara el arranque |
| **Apagon** (se va y vuelve la luz) | **deberia** — es para lo que sirve el ajuste | **SIN PROBAR** |

> `Restore AC Power Loss = Power On` **no es "enciendete solo": es "enciendete cuando VUELVA la corriente"**.
> Reacciona a la transicion sin-luz -> con-luz. Si la luz no se va, no se dispara nunca.

**Lo que se probo el 08/09 fue un REINICIO**, es decir la cadena de software: Windows entra solo -> OneDrive
-> tareas -> ACTUM. **El eslabon de la placa no se ha probado.**

#### Comprobado en el log el 10/09: no ha habido ningun apagon desde el cambio

`Get-WinEvent` con `Id=6008,6005,41`: **ni un `6008` ni un `41` desde el 08/09 14:32.** El ultimo apagon
sucio sigue siendo el del **07/09 19:15**, anterior al cambio de BIOS. Por eso no hay prueba todavia.

**Se investigo un arranque sospechoso** del 09/09 a las 17:30 sin `6008` previo, por si hubiera sido un corte
con el equipo ya apagado —lo cual habria servido de prueba—. **No lo era:**

```
09/09 17:30:01  1074  svchost.exe en nombre de NT AUTHORITY\SYSTEM
                      motivo: Sistema operativo: service pack (planeado)
```

Era **Windows Update**.

#### ✅ PERO ESE REINICIO REGALO UNA PRUEBA MEJOR

**El 09/09 a las 17:30 el equipo se reinicio SOLO, sin nadie delante**, y a la manana siguiente **registro
perfectamente la extraccion de Javier de Lamo a las 09:30:21**.

> Eso demuestra que, **sin supervision**: Windows entro solo, OneDrive arranco, las tareas volvieron a correr
> **y ACTUM se abrio solo** — porque si no, esa extraccion no estaria en el CSV. El reinicio del 08/09 lo hizo
> Inigo estando delante; **este ocurrio a solas y salio bien.** Toda la cadena de software queda probada
> desatendida. Lo unico pendiente es el eslabon que no depende de Windows.

#### Como cerrarlo cuando se quiera

**Decision de Inigo (10/09): esperar a que pase de verdad**, sin provocarlo. Cuando ocurra, se lee del log:
un `6008` seguido de un `6005` pocos minutos despues y sin que nadie bajara = **probado**.

*(Alternativa sin riesgo alguno, por si algun dia se quiere cerrar antes: apagar Windows limpiamente, quitar
la corriente de la regleta, esperar 10 s y devolverla sin tocar el boton. Como el apagado es limpio, no hay
nada escribiendose y **no se puede danar el CSV**. Si arranca viniendo de estar apagado, con mas razon
arrancara tras un apagon estando encendido: es el mismo disparador.)*

> **Apunte menor:** **Windows Update reinicia el equipo por su cuenta** — paso el 09/09 a las 17:30. No es
> grave, porque el sistema se recupera solo y esta medido, pero podria caer justo mientras alguien saca un
> instrumento. Si algun dia molesta, se le fijan horas de actividad.

## ⏱️ LOS TRES TIMEOUTS DE ACTUM — medidos el 10/09/2026

**Sintoma de Inigo:** *"el tiempo que hay para extraer es muy pequeno, como 15 segundos"*.

**Causa:** hay **TRES** temporizadores, no uno, y en junio se cambio el que no era para este sintoma.
Leidos de la tabla `Parametros` de SQL:

| Campo | Valor a 10/09 | Que controla |
|---|---|---|
| `SegundosTimeoutMensajes` | 10 → **20** | cuanto se ve un mensaje en pantalla |
| `SegundosTimeoutFormularios` | 20 → **120** | ← **el que cortaba la extraccion.** Tiempo en la pantalla de seleccion |
| `SegundosTimeoutPuertaAbierta` | 60 → **120** | cuanto puede quedarse la puerta abierta |

**Cambiado y VERIFICADO el 10/09**: la consulta sobre `Parametros` devuelve `20 | 120 | 120`. El cambio esta
en la base de datos, no solo en la ventana. Falta la prueba real cronometrando una extraccion.

> La pantalla de PARAMETROS (v25.02) tiene ademas pestanas de **Ubicaciones, Electronicas, Consignas y
> Estaciones**, y una tabla de usuarios propia del programa con **`Admin` / contrasena `1234` en texto
> plano** (permisos de Visor y Parametros). Es diseno del fabricante, como la contrasena de `sa` en
> `Par.txt`. Anotado por si algun dia hay auditoria de IT.

> **Esto corrige lo anotado el 04/06.** Aquel dia se subio *"Segundos Timeout Puerta"* de 20 a 60 y se dio el
> problema por resuelto. **El cambio se hizo bien y sigue puesto (60)** — pero el que molesta al extraer es
> **`SegundosTimeoutFormularios`**, que se quedo en 20. Dos parametros parecidos, sintomas distintos.

**Como se cambia:** `C:\ACTUM\ACTUM_EPI\Parametros\` → **doble clic en `ACTUM_EPI_Parametros.exe`**.

> ⚠️ **NO abrir `ACTUM_EPI_Parametros.exe.config` con el Bloc de notas** — es el fichero de configuracion,
> no la aplicacion, y no tiene campos que tocar. Ademas apunta a `ACTUM-JOSEP\SQLEXPRESS` (el PC del
> fabricante): **esta obsoleto, el programa lee `Par.txt`**. Inigo abrio ese por error el 10/09.

**Verificacion tras el cambio** — no fiarse de que la ventana se cierre sin error:
```powershell
sqlcmd -S "GHI-TAQUILLAS\SQLEXPRESS" -d Actum_GHI -E -W -s"|" -Q "SET NOCOUNT ON; SELECT SegundosTimeoutMensajes, SegundosTimeoutFormularios, SegundosTimeoutPuertaAbierta FROM Parametros"
```
Y despues **cerrar y reabrir `ACTUM_EPI_Gestion.exe`**, que es quien atiende el panel y lee los parametros
al arrancar.

> **`Par.txt` contiene la contrasena de `sa` en claro** (`C:\ACTUM\ACTUM_EPI\*\Par.txt`). Es del fabricante,
> no nuestro, pero conviene saberlo si algun dia hay auditoria de IT.

## ❓ ¿EL BANNER DE SALUD DETECTA QUE ONEDRIVE DEJE DE SUBIR? — NO

**Pregunta de Inigo (10/09):** *"igual si deja de sincronizar por la contrasena lo avisa en el banner"*.

**No puede.** El chequeo corre **dentro del locker** y mira el CSV y el marcador, que son ficheros locales.
Si la sesion de `fabricacion1` caduca, el locker **sigue generandolo todo bien** y el banner sale **verde**:
lo que se queda vieja es la copia de la **web**, y eso desde dentro no se ve. Es la misma razon por la que
el vigilante tiene que correr FUERA.

**Pero hay una comprobacion de 5 segundos que ya existe y no costo nada montar:** la carpeta del locker
**esta sincronizada en el PC de Inigo**, en
`C:\Users\ialopez\OneDrive - GHI HORNOS INDUSTRIALES S.L\Archivos de Fabricacion1 - GHI Smart Furnaces - LockerACTUM\`.
Basta mirar la fecha de `DashboardLocker.html` en el explorador: si esta fresca, OneDrive sube.

> **Medido el 10/09 a las 12:48:** `DashboardLocker.html` marcaba **12:48**. Sincronizacion viva, en tiempo real.
> **Esa carpeta es ademas la base natural del vigilante externo** cuando se quiera hacer (pendiente aplazado):
> un equipo que NO es el locker viendo si ese fichero se queda parado.

**Plan de Inigo (10/09), y funciona:** cuando toque el cambio, **apuntar el dia**, poner recordatorio en el
movil a los ~42 dias o algo antes, y **cambiarla un dia antes de que caduque** para que el locker no llegue
a pararse nunca. De momento se gestiona asi.

> **A medio plazo Inigo quiere quitarse el problema de raiz**: pedir que no caduque, o publicar el dashboard
> por otra via. **Medido el 10/09: la via del IIS local esta descartada** (redes separadas, ver el pendiente
> de OneDrive). **La que queda es Graph con certificado**, que no caduca nunca.

## 🔑 ACCESO SAT — es a TODO, no a una consigna

**El 10/09 Inigo dio acceso a consignas restringidas a JAVIER JULIAN DE LAMO** desde el ACTUM EPI Visor, para
que pudiera sacar el `A-003` (analizador de gases TESTO 340 n.º 61186226, consigna 5).

> ⚠️ **`Usuario.AccesoConsignasRestringidas = True` NO es acceso a una consigna concreta: es acceso a TODAS
> las restringidas**, y es permanente hasta que se retire. Si se concedio solo para un instrumento,
> **plantearse retirarlo cuando lo devuelva**. Si se deja, que sea decision consciente: pasa al grupo de los
> que pueden abrir todo (IKER L. LASSO, AITOR U. ULIBARRI, JOSE G. G. GONZALEZ, INIGO A. ALONSO).

**Estado del `A-003` tras esto:** extraido **a nombre de Julian**, que se identifico el. Con eso queda
registrado correctamente en `Eventos` y **no hace falta correccion manual**.

> **Falsa alarma del mismo dia:** se reporto que la consigna 5 no dejaba ni extraer ni devolver, y se
> preparo un diagnostico completo (estado de la consigna, eventos, rele, tabla `Errores`). **No hacia falta:
> la opcion si estaba, Inigo no la habia visto.** Queda el metodo apuntado por si vuelve a pasar de verdad.

## 🛑 REGLA DURA — `MonitoreoLockerTiempoReal.ps1` NO SE TOCA A LA LIGERA

> **Cementada el 2026-09-08 tras la propuesta de Codex.** Aplica a CUALQUIER agente
> (Claude Code, Codex, GLM…) y a cualquier persona.

`MonitoreoLockerTiempoReal.ps1` es **el unico componente cuyo fallo no se puede recuperar
despues**. Todo lo demas es regenerable: el CSV se reconstruye desde `Eventos`, el HTML se
regenera desde el CSV, el Excel desde el CSV. Pero **lo que el monitor no captura no queda
registrado en ninguna parte**.

Condiciones para modificarlo, TODAS obligatorias:

1. **Probado contra los datos REALES** del locker (el CSV de produccion y SQL), no contra
   ficheros sinteticos en carpetas temporales.
2. **Sin dependencias nuevas.** Nada de dot-source de otros scripts: si falta uno, el monitor
   muere. Hoy es autonomo y debe seguir siendolo.
3. **FAIL-OPEN, nunca fail-closed.** Ante cualquier duda debe **seguir registrando**. Un
   monitor que se bloquea a si mismo por precaucion es peor que uno que registra de mas: lo
   segundo se limpia despues, lo primero pierde datos para siempre. **Y falla en silencio**,
   porque la tarea corre oculta.
4. **Sin estado persistente nuevo** que pueda corromperse y bloquearlo.
5. **Sin escrituras que crezcan sin limite** dentro de `LockerACTUM`: esa carpeta la sincroniza
   OneDrive y ya la desbordamos una vez.
6. **Verificado despues del despliegue** releyendo el fichero (lineas, no-ASCII, sintaxis) y
   comprobando que el CSV sigue creciendo con normalidad.

> **Corolario:** una mejora que solo afecta a la reconstruccion se implementa **en
> `ReconstruirHistorial.ps1`**, que se lanza a mano y casi nunca. Nunca en el monitor.

## Trabajo con varios agentes (Claude Code · Codex · GLM)

Alternar agentes esta bien y ahorra cuota. Reglas para que no se pisen:

> **REFUERZO 10/09/2026 — pendientes de instrumentos:** antes de citar como vivo un pendiente sobre
> ubicacion, extraccion o devolucion, buscar primero el numero de serie en el `HistorialCompleto.csv`
> sincronizado y leer su ultima fila. Caso que lo motiva: se volvio a preguntar por el TESTO 340
> `63862113` aunque el CSV ya contenia su devolucion por Sergio Vega a las **11:52:50 del 09/09**.

1. **`CLAUDE.md` es el unico traspaso.** Quien haga un cambio o reciba un dato del locker lo
   registra aqui en el mismo turno, con evidencia y siguiente paso. No marcar como ejecutado lo
   que solo esta propuesto.
2. **Git es la memoria real.** Commit por cada cambio logico y push cuando el usuario lo
   autorice, para que todo movimiento quede visible en
   `github.com/inigoalonsoo/LOCKER-`.
3. **Ningun agente despliega en el locker por su cuenta.** El despliegue lo hace siempre la
   persona, por Notepad/TeamViewer, con la verificacion de lineas + no-ASCII + sintaxis.
4. **Claude Code lleva las riendas; Codex y GLM aportan.** Decision de Inigo (08/09). No es jerarquia
   por gusto: es que **una sola cabeza debe responder de lo que entra en produccion**, y quien conoce el
   historial de averias de este sistema decide que se despliega. Codex y GLM pueden analizar, proponer,
   escribir pruebas y encontrar huecos —lo hicieron bien el 08/09— pero **lo que toca `C:\ACTUM` pasa
   antes por revision**. En la practica: proponer, no desplegar.
5. **Todos los agentes siguen el mismo estilo de trabajo**, que es lo que ha hecho utiles estas sesiones:
   - **Medir, no narrar.** `rc=0` y un `Write-Host` no son evidencia: hay que releer el sujeto (el fichero,
     la tarea, la fila) y citar el numero. El 08/09 se cazaron asi dos falsos exitos.
   - **Cambio minimo suficiente.** Antes de anadir maquinaria, preguntarse cuantas veces al ano corre eso
     que se quiere proteger. Aqui: ~10 movimientos/dia y una reconstruccion manual al ano.
   - **Fail-open en lo que corre solo.** Ver la regla dura de arriba.
   - **Decir lo que NO se ha comprobado.** Un "23/23 pruebas" sintetico no prueba que funcione con los
     datos reales, y hay que escribirlo.
   - **Corregirse en voz alta.** Si un diagnostico anterior era falso, se marca como corregido en este
     documento, no se tapa.
6. **Al terminar una sesion, sea el agente que sea: subir a GitHub y actualizar `CLAUDE.md`.** Los dos,
   en el mismo turno. El commit deja el **que** y el **por que** de cada cambio; `CLAUDE.md` deja el estado
   y el siguiente paso. Sin eso, el siguiente agente —o el mismo dentro de una semana— trabaja a ciegas y
   se repite trabajo ya hecho.
7. **Una propuesta descartada no se borra: se archiva** con el porque, para no volver a
   discutirla desde cero. Ver `propuesta-codex-2026-09-08/LEEME.md`.

### Episodio 2026-09-08 — propuesta de Codex, evaluada y descartada

Codex propuso un sistema de proteccion con estado persistente, mutex, transacciones con journal
y copias automaticas, tocando 4 scripts incluido el monitor (v2.5).

**Lo que acerto y se ha aprovechado:**
- Detecto un **hueco real**: la proteccion anterior solo cubria `CorreccionesManuales.csv`; una
  edicion directa de `HistorialCompleto.csv` se perdia igual. → Resuelto en el **paso 2.6** de
  `ReconstruirHistorial.ps1` (filas huerfanas).
- `CrearCorreccionesManuales.ps1` no debe rehacer el fichero si ya existe. → **Incorporado.**
- Respaldo verificado previo (67/67) y **cero cambios en produccion**.

**Por que se descarto** (medido leyendo su codigo): backups sin rotacion en **cada movimiento**
dentro de OneDrive · estado JSON que duplica el historial completo y se reescribe entero cada vez ·
**fail-closed** que deja el monitor abortando en silencio tras un corte de luz · mutex sin espera
que mata ejecuciones solapadas · un evento repetido lanza excepcion en vez de deduplicar ·
`$ErrorActionPreference='Stop'` global · y **nada probado contra datos reales**.

Detalle completo y tabla de fallos: `propuesta-codex-2026-09-08/LEEME.md`.

---

## ❓ ¿ESTA REPARADO EL SISTEMA? — respuesta honesta a 2026-09-08

**Resumen en una linea: el SOFTWARE esta reparado y verificado; el SISTEMA todavia NO esta a salvo,
porque la causa de las caidas sigue intacta y lo reparado no se ha probado con un movimiento real.**

### ✅ NIVEL 1 — Reparado Y verificado sobre el sujeto

| Que | Evidencia medida |
|---|---|
| Bucle de reprocesado (bug raiz `Sort-Object` alfabetico) | CSV **sin escribirse desde el 07/09 14:47**, mas de 22 h, mientras el dashboard se regenera cada minuto |
| Integridad del historial | 529/529 lineas unicas · 0 bytes NULL · 0 mojibake · 0 fechas ilegibles · 264 extracciones / 264 devoluciones |
| El dashboard dice la verdad | **32/32 consignas** coinciden con `Consigna.Estado` de SQL |
| La web recibe | *Ultima actualizacion: 2026-09-08 10:24:08* en SharePoint |
| Watchdog mentiroso | eliminado; HTML byte-identico despues (246.461) |
| `ReconstruirCSVSemanal` que borraba las correcciones | `Disabled` — y descubierto que **nunca funciono desde mayo** |
| Suspension / hibernacion / inicio rapido | `powercfg /a`: los tres en "no disponibles" |
| Hardware | SSD `Healthy` · `NoErrorsFound` · 0 WHEA · 7,9 GB RAM · 144 GB libres |
| Orden (4 frentes) | raiz del locker 46->14 · repo 64->5 · GitHub 89 renombrados · datos 7->6 |

### ✅ NIVEL 2 — **CERRADO el 08/09 por la tarde.** Ya probado en la practica (ver apartado P)

~~Esto funciona en teoria pero nadie lo ha visto funcionar:~~ **los tres puntos quedaron probados en
el viaje al locker del 08/09 tarde.** Se conserva la lista para saber que se probo exactamente:

1. **La captura de un movimiento NUEVO.** *Este es el hueco grande.* La ultima identificacion real es del
   **`2026-07-16 13:20:21`**: todo lo verificado se hizo con datos historicos. **Que la v2.4 capture bien
   una extraccion y una devolucion reales NO esta probado desde antes del incidente.**
2. **El arranque automatico de `ACTUM_EPI_Gestion.exe`.** El acceso directo esta creado y verificado
   leyendo el `.lnk`, pero **el PC no se ha reiniciado desde entonces**. No se ha visto abrirse solo.
3. **Los pasos 2.5 y 2.6 de `ReconstruirHistorial.ps1`.** Desplegados y con sintaxis correcta, pero
   **nunca ejecutados sobre datos reales** — a proposito, porque el CSV esta sano y no se toca lo que
   funciona.

### ❌ NIVEL 3 — SIN REPARAR. Lo que puede volver a tumbar el sistema

1. **LOS CORTES DE CORRIENTE siguen ocurriendo.** *(Ya no dejan el PC muerto — ver punto 2 — pero la causa sigue.)* Ocho apagones sucios en cinco semanas, y el ultimo fue el
   **07/09 a las 19:15**, despues de terminar la reparacion. La BIOS sigue sin configurar, no hay SAI y el
   cuadro electrico sigue cayendose. **Es la causa raiz y sigue exactamente igual que el primer dia.**
2. ~~El PC no vuelve solo tras un corte.~~ **RESUELTO el 08/09.** BIOS en `Power On` + auto-login
   arreglado + arranque automatico de ACTUM, y **verificado con un reinicio real**: Windows entra solo,
   OneDrive arranca, las tareas corren y ACTUM se abre. Ver apartado P.
3. **No hay deteccion de fallo.** Aparcada por decision de Inigo. Si el sistema se cae, **nadie se entera
   hasta que alguien mira**. Es lo que dejo el PC 19 dias muerto en agosto, y ahora ademas **no hay
   respaldo humano**: Imanolia lo lleva sola.
4. ~~**Consigna 22:** averiguar si el TESTO 340 lo tenia Sergio o Iker.~~ **RESUELTO 09/09:** lo tenia
   Sergio Vega y lo devolvio identificandose a las **11:52:50** (CSV, serie `63862113`).
5. **La dependencia de OneDrive + `fabricacion1`.** Sigue siendo el unico tramo que se rompe solo, cada
   ~50 dias, sin dar error en ningun log. Hoy funciona; volvera a caducar.

### La lectura, en corto

Todo lo que rompio el sistema **por software** esta arreglado, medido y documentado. Pero el sistema se
cayo por una cadena: **corte de corriente -> marcador corrupto -> bucle de reprocesado -> CSV destruido**.
Se ha roto la cadena por el eslabon del software, que era el que amplificaba el dano. **El primer eslabon
sigue ahi.**

Y hay una diferencia importante entre los dos tipos de dano:
- Lo que rompio el bucle **era recuperable**: el historial se reconstruyo entero desde `Eventos`.
- Lo que se pierde si el motor no corre **no se recupera de ningun sitio**. Por eso el arranque automatico
  y la BIOS importan mas que cualquier mejora de codigo pendiente.

---

# 📍 TRASPASO — 2026-09-10, fin de sesion de Claude Code → CONTINUA CODEX

> **LEE ESTO PRIMERO.** Es el estado real a 10/09. Lo de abajo (bloque del 08/09) sigue siendo valido como
> contexto, pero **esto es lo ultimo**.

## El sistema, en una linea

**Software reparado, probado y vuelve solo tras un corte.** Riesgos abiertos: la **corriente** (sin SAI) y
que **nadie se entera si se cae** — el banner de salud solo habla si alguien genera el HTML y abre el Admin.

## Hecho estos dos dias (todo verificado sobre el sujeto)

| | Que | Evidencia medida |
|---|---|---|
| **v2.6** | Causa raiz de los duplicados: el marcador perdia los milisegundos | reproceso parado · `[EVENTOS] Encontrados: 0` |
| **v2.7** | Guarda anti-duplicado antes de escribir en el CSV | 638 lineas · 0 errores |
| paso 2.5 | `CorreccionesManuales.csv` ahora **SUSTITUYE**, no solo anade | 343 lineas · **5 correcciones protegidas** |
| — | `<script>` del banner rojo de SharePoint eliminado | 705 lineas · el banner desaparecio |
| **salud** | Chequeo en `GenerarDashboardAdmin.ps1`, se ve **siempre** | 1.281 lineas · HTML `verde=1 rojo=0` |
| timeouts | Eran **TRES**, no uno. En junio se cambio el que no era | `Parametros` = **20 \| 120 \| 120** |
| calibr. | Campana montada: **21 instrumentos, 5 lotes** | cruce ACTUM + Excel, 32/32 |

**CSV a 10/09: 536/536 lineas, ratio 1,00, 535 movimientos, 0 bytes NULL.**

## ⚡ LO QUE HAY QUE HACER AHORA, por orden

### A · Cerrar lo del timeout (2 minutos, es lo unico a medio hacer)
1. **Reiniciar `ACTUM_EPI_Gestion.exe`** — sin esto el panel sigue con los valores viejos.
2. **Cronometrar una extraccion real.** Debe dar ~120 s. Si sigue cortando a los 20, manda otro sitio.
3. **DEJAR `ACTUM_EPI_Gestion.exe` ABIERTO.** Mientras este cerrado el locker **no registra nada**, y eso
   no se recupera de ningun sitio.

### B · Calibraciones — esperando a Applus
**Lote enviado el 10/09** a `izaskun.Conde@applus.com`: **7 equipos** (4 FLUKE + Martindale + 2 RS PRO 135).
Cuando llegue la oferta, **comprobar tres cosas**:
- **Precio POR EQUIPO**, no un total — si no, no se puede comparar con lo que cobro RS: Martindale
  **76,86 EUR** y RS PRO 135 **239,00 EUR** (pedido 2507486, oct-2025).
- **Plazo**: tienen que estar operativos **antes de noviembre** (auditoria).
- Si el desglose dice **"calibracion y ajuste"** o solo "calibracion" — responde solo a si cubren un equipo
  fuera de tolerancia, que es lo unico que aportaba el intermediario.

**Quedan 4 lotes sin pedir:** Neurylan (7+2) · Leica (1) · Klotz (1, **falta el correo**) · CS (1).
Los correos estan escritos y listos en la seccion de calibraciones. **RS descartado el 10/09.**

### C · Pendientes fisicos de Inigo
1. **Consigna 31** — abrir con llave, leer el n.º de serie del `E-002` (indicador de dial x2 + base) y
   ponerlo en ACTUM. **No consta en ninguna parte: el viaje SI hace falta.**
2. **`L-004`** — pegatina y meterlo en la consigna 9 **identificandose**.
3. **Atornillador `D-001`** — perdido. Su serie (`EA 10.00047`) si esta en el Excel: se puede poner en
   ACTUM sin bajar.
4. ~~**TESTO 340 de la consigna 22** (`63862113`) — preguntar a Sergio Vega e Iker Lasso.~~
   **RESUELTO 09/09:** devuelto por Sergio Vega a las **11:52:50**, una sola fila en el CSV.
5. **Correo de Klotz** — no consta.
6. **Retirar el acceso SAT a Julian de Lamo** cuando devuelva el `A-003`, si se le dio solo para eso.

### D · Lo grande, sin tocar
1. **SAI + cuadro electrico** — la unica causa raiz viva. 8 apagones en 5 semanas.
   **APLAZADO por Inigo el 10/09/2026.** Antes de comprar: fotografiar regleta, fuentes y etiquetas;
   sumar los W de PC, pantalla, electronica del locker y red que realmente necesiten respaldo, y dejar
   un 20 % de margen. El SAI mitiga los cortes; revisar el cuadro es lo que busca la causa.
2. **Alerta de sistema caido de verdad** — el vigilante debe correr **FUERA** del locker.
   **APLAZADA por Inigo el 10/09/2026:** el banner de salud actual sirve de momento. Posible futuro:
   vigilancia externa con Power Automate, comprobacion cada 10 min y aviso si el dashboard supera 20 min
   sin actualizar. No implementar ahora.
3. **Quitarse OneDrive + `fabricacion1`** — se rompe solo cada ~42 dias.
   **IIS LOCAL DESCARTADO POR MEDICION (10/09):** desde el PC de Inigo (`192.168.216.101`) el locker
   (`172.16.5.40`) **no responde — 100 % de paquetes perdidos**. Son redes separadas sin ruta, igual que el
   locker tampoco alcanza el servidor documental. Un IIS ahi serviria una web que **nadie de oficina podria
   abrir**. *(Matiz: el ping podria estar bloqueado por firewall aunque pasara HTTP; confirmarlo es una
   pregunta a IT, no un experimento.)*
   **Queda una sola via real: Microsoft Graph con certificado.** No depende de la red —el locker tiene
   internet— y **el certificado no caduca nunca**, asi que termina con los 42 dias para siempre. Es una
   peticion a IT de ~10 min: registrar una app en el Entra ID que GHI ya tiene. Sin coste.
4. **Leer `Consigna.Usuario_Codigo`** para la pestana Estado.

## ⚠️ LO QUE CODEX NO DEBE HACER

1. **NO tocar `MonitoreoLockerTiempoReal.ps1`** sin pasar las 6 condiciones de la REGLA DURA (arriba del todo).
2. **NO desplegar en el locker.** Lo hace la persona, por Notepad/TeamViewer, con la verificacion de
   lineas + no-ASCII + sintaxis.
3. **NO dar por bueno un cambio sin releer el sujeto.** Esta semana se cazaron asi: un watchdog que mentia,
   un `<script>` que se contaba a si mismo, un `powercfg` que no se aplico y un test que dio falso positivo
   porque comparaba con `$null`.
4. **NO concluir que una fuente miente sin comprobar si las dos pueden ser ciertas.** El 10/09 se dio por
   falso el Excel de calibraciones y **estaba bien**: el Excel dice a quien se COMPRA y el certificado quien
   CALIBRA. Eran dos preguntas distintas.
5. **NO anadir puntos a la plantilla de correo.** Inigo la dejo en dos: **precio y plazo**. Esta razonado
   arriba.

---

# ⚡ ESTADO ACTUAL Y SIGUIENTE PASO — actualizado 2026-09-08 (fin de sesion)

> **BLOQUE DE TRASPASO.** Si retomas el proyecto en otra sesion, otra terminal u otro modelo (Codex, etc.),
> lee SOLO esto para saber donde estamos y que hacer. El detalle esta en las secciones
> `AUDITORIA COMPLETA DE C:\ACTUM` (apartados A-O) y `Resumen de Sesion — 2026-09-08`, al final.

## Contexto minimo

Sistema de monitoreo del locker ACTUM de GHI. PC del locker: **GHI-TAQUILLAS** (IP 172.16.5.40), usuario
Windows **`User`**, acceso por **TeamViewer**. **Imanolia lo lleva sola: no hay respaldo ni segunda persona.**

Cadena completa:

```
[Consignas] --RS485--> [Electronica Kerong 172.16.5.41:23] <--TCP--> [ACTUM_EPI_Gestion.exe]
                                                                              |
                                                    escribe cada apertura     v
                              [SQL Express GHI-TAQUILLAS\SQLEXPRESS · BD Actum_GHI · tabla Eventos]
                                                                              |
   [Task Scheduler] -> [.vbs ventana oculta] -> [.ps1 en C:\ACTUM\] ----------+
                                                                              v
              [C:\Users\User\OneDrive - GHI HORNOS INDUSTRIALES S.L\LockerACTUM\]
                                                                              |
                    <- NO hay API ni subida: es una CARPETA LOCAL que el      v
                       cliente OneDrive (sesion fabricacion1@ghifurnaces.com) sincroniza
                                                          [SharePoint -> el enlace de la gente]
```

**El eslabon debil es ese ultimo tramo:** si la contrasena de `fabricacion1` caduca (~cada 50 dias), los
scripts siguen funcionando y **nadie ve nada nuevo en la web**, sin error en ningun log.
**Verificado el 08/09 a las 10:24: la web SI recibe. No hay que re-autenticar nada.**

## Situacion al cierre del 08/09/2026

- **Estado al cierre del 08/09: el sistema esta reparado, probado y vuelve solo tras un corte.**
  Queda como riesgo unico la corriente (sin SAI) y la falta de deteccion de fallo.
- **El locker esta FUERA DE SERVICIO a proposito.** `ACTUM_EPI_Gestion.exe` **cerrado** por decision de
  Inigo mientras se arregla todo. **Se reabrira al terminar** (y ahora ya tiene arranque automatico).
- **Ultima identificacion de usuario real: `2026-07-16 13:20:21`.** Nadie usa el locker desde julio.
- **Sistema sano y verificado:** CSV con 528 movimientos, 529/529 lineas unicas, 0 bytes NULL,
  0 mojibake, rango completo 26/10/2024 -> 16/07/2026, y **el dashboard coincide con el hardware en 32/32
  consignas**.
- **8 cortes de corriente en 5 semanas.** Causa dicha por Inigo: **el cuadro electrico del locker se cae**.
  El PC **no vuelve solo** (12 h muerto el 07-08/09; 6 dias en agosto). **Esto es lo unico grave sin
  resolver.**
- **Repo sincronizado con GitHub:** `github.com/inigoalonsoo/LOCKER-`, rama `master`, ultimo commit
  `bd8cf4d`. Verificado 1:1 (`rev-list --left-right --count` = `0 0`, working tree limpio).

### Hecho y verificado el 08/09 (todo medido sobre el sujeto, no narrado)

| Accion | Verificacion |
|---|---|
| `ReconstruirCSVSemanal` desactivada (borraba las correcciones manuales cada lunes) | `State = Disabled` |
| Descubierto que esa tarea **nunca funciono** desde el 20/05 (su `.vbs` esta roto) | apartado B |
| `GenerarDashboardHTML` devuelta a `Disabled` (se encendio sin querer) | `State = Disabled` |
| Suspension, hibernacion e inicio rapido desactivados | `powercfg /a` |
| Watchdog mentiroso eliminado de `GenerarDashboard.ps1` | 706 lineas · 0 errores · HTML byte-identico |
| Copia de conflicto de OneDrive borrada (10,4 MB) | listado vacio |
| Hardware descartado | SSD `Healthy` · `NoErrorsFound` · 0 WHEA · 7,9 GB RAM · 144 GB libres |
| Dashboard auditado | **32/32 consignas coinciden con SQL** |
| OneDrive sincroniza | web con *Ultima actualizacion: 2026-09-08 10:24:08* |
| Correcciones manuales a prueba de reconstrucciones | 4 guardadas en `CorreccionesManuales.csv` |
| Arranque automatico de `ACTUM_EPI_Gestion.exe` | `.lnk` creado en `Startup` y verificado leyendolo |
| Rafagas de `Usuario=0` explicadas | es la electronica al conectar — apartado O |
| Los 4 `.vbs` activos respaldados en el repo | los 4 `IDENTICO` |
| Todo commiteado y subido a GitHub | 4 commits · divergencia `0 0` |
| Ediciones directas del CSV protegidas (paso 2.6, filas huerfanas) | 308 lineas · 0 errores · sin tocar el monitor |
| Propuesta de Codex evaluada y descartada; monitor revertido a v2.4 | `IDENTICO` byte a byte al desplegado en el locker |
| **Desplegados en el locker** `ReconstruirHistorial.ps1` (paso 2.6) y `CrearCorreccionesManuales.ps1` | **308 y 88 lineas**, 0 no-ASCII, 0 errores de sintaxis |
| El inicializador ya NO destruye lo anadido a mano | responde *"Ya existe: 4 correcciones. NO se toca ni un byte"* |

---

## Sesion 2026-09-09 — v2.5: escritura atomica del marcador

**Chequeo matinal:** noche tranquila (0 cortes), 19 h de uptime, tareas `Ready`, OneDrive corriendo desde
el 08/09 14:33 y dashboard regenerandose. **El CSV no se habia escrito desde las 13:45:06 del 08/09** — el
bucle sigue muerto.

**Pero aparecio UNA linea duplicada** (532 lineas / 531 unicas). Diagnostico completo:

- La repetida era `07/16/2026 13:20:21;IKER L.;LASSO;08;...;Extraccion` — **antigua, no de la prueba**.
- Posiciones **527 y 530** de 532: la copia se escribio **en la misma pasada** que los dos movimientos de
  la prueba funcional (lineas 531-532), no en un arranque posterior.
- La prueba en si salio impecable: CSV con 2 lineas y SQL con 2 eventos (`10000` a 13:43:35 y `10001` a
  13:44:43, usuario 62). **El dedup funciono.**

**CAUSA RAIZ, leida en el codigo (`MonitoreoLockerTiempoReal.ps1:71-101`):** `WriteAllText` **no es
atomico**. El reinicio del 08/09 a las 13:33 (para cambiar la BIOS) corto la escritura del marcador; en la
pasada siguiente no se pudo leer, el script activo `$esPrimeraEjecucion`, tomo el maximo del CSV
(`07/16 13:20:21`) y **le resto 10 segundos** de ventana de solapamiento -> la query
`FechaHora > 13:20:11` devolvio el evento de 13:20:21 y lo reescribio.

> **Es EL MISMO mecanismo que destruyo el CSV en agosto.** Entonces, con el bug del `Sort-Object`
> alfabetico encima, produjo 103.495 filas con 187 reales. Ahora, con la v2.4 ya puesta, el mismo escenario
> produjo **UNA linea**. El fix del 07/09 contuvo el desastre; la v2.5 elimina la causa.

**Por que el dedup no la pillo:** compara el evento nuevo contra la **ultima** linea del CSV, y esa era una
correccion manual de SERGIO VEGA de abril. Como el CSV no esta en orden cronologico estricto (las
correcciones se anaden al final), la comparacion no encontro pareja. **No se toca**: arreglarlo exigiria
maquinaria en el script que corre cada minuto, para un sintoma que el dashboard ya colapsa al renderizar.

**Limpieza aplicada:** 1 linea quitada -> **531 / 531, ratio 1,00**, dashboard con **530 movimientos**.
Copia previa en `HistorialCompleto.csv.ANTES_DEDUP_20260909.bak`.

### v2.5 — el cambio

Un unico punto (`:479`): el marcador se escribe a un **temporal** y se **renombra** con `File.Replace`.
En NTFS el renombrado es atomico: ante un corte solo caben dos resultados, **el marcador viejo entero o el
nuevo entero, nunca uno a medias**.

```powershell
[System.IO.File]::WriteAllText($tmpMarcador, $textoMarcador, $utf8NoBOM)
[System.IO.File]::Replace($tmpMarcador, $archivoMarcador, [NullString]::Value)
```

> **`[NullString]::Value`, no `$null`.** El overload con `$null` no resuelve en PowerShell 5.1. Se probo
> ejecutandolo de verdad antes de escribirlo: deja el contenido nuevo y borra el temporal.

Lleva `catch` que escribe directo si el renombrado fallara — **fail-open**: peor garantia que la atomica,
pero muy preferible a dejar el marcador sin avanzar, que reprocesaria el mismo evento cada minuto.

**Paso por la regla dura del monitor:** probado con datos reales · sin dependencias nuevas · **mejora** el
fail-open (hoy un corte deja el marcador ilegible; con esto no puede) · sin estado persistente nuevo · sin
escrituras que crezcan · verificado tras desplegar.

**Desplegado y verificado el 09/09:** `sintaxis=0 no-ASCII=0 lineas=551`, bloque en la linea 483,
`LastTaskResult 0`, marcador intacto en `2026-09-08 13:44:43` y **ningun `.tmp` suelto**.
**Y el dashboard regenerado a las 8:31:07**, ya con la v2.5 desplegada: eso prueba que el script corre
**entero**, hasta la llamada final a `GenerarDashboard.ps1`. Un `LastTaskResult 0` por si solo no lo
probaria — el `.vbs` lanza PowerShell y termina, asi que daria 0 aunque el script petara al arrancar.
v2.4 guardada en `C:\ACTUM\_ARCHIVOackups_scripts\MonitoreoLockerTiempoReal_v2.4_ANTES_ATOMICO_20260909.ps1`
(24.206 bytes) y en `historico/scripts-antiguos/` del repo.

> ⚠️ **PENDIENTE DE EJERCITARSE.** El marcador **solo se escribe cuando hay un movimiento nuevo**, asi que
> con ACTUM cerrado el codigo nuevo no llega a ejecutarse. Esta desplegado y sano, pero **la escritura
> atomica no estara probada hasta el proximo movimiento real en el locker**. No darlo por verificado antes.

---

### Banner rojo de SharePoint — RESUELTO 09/09/2026

**Confirmado antes de tocar nada**, no supuesto. El aviso *"No se cargo parte del contenido"* citaba
literalmente **nuestros dos errores y ninguno mas**:

```
Uncaught SecurityError: Failed to execute 'replaceState' ... '#historial'  (about:srcdoc:3760:95)
Uncaught SecurityError: Failed to execute 'replaceState' ... '#estado'     (about:srcdoc:3759:95)
```

Lineas 3759 y 3760 = los dos `addEventListener` del bloque `<script>`, uno por pestana. Todo lo demas de
la consola (manifest, permissions policy, CSP, iconos duplicados, service workers) es ruido de Microsoft.

**Causa:** SharePoint incrusta el HTML en un iframe `about:srcdoc` con origin `null`, donde el navegador
prohibe `replaceState` con URL.

**Se ELIMINA, no se arregla.** Ese JavaScript existia para recuperar la pestana activa tras una recarga
(v2.1 UX, 21/04) y **el auto-refresh se quito el 11/06**: sin recargas no hay nada que recuperar. Ademas
nunca llego a funcionar en SharePoint. En su lugar queda un comentario HTML explicando por que no debe
volver a anadirse JavaScript ahi.

> **Prueba de que los tabs no dependian de el:** en la captura del 09/09, con el script lanzando
> excepciones, **los tabs se veian y funcionaban**. Son CSS puro (radio buttons + `:checked`).

**Verificado tras desplegar:** `sintaxis=0 no-ASCII=0 lineas=705` · en el HTML `</script>` = **0**,
`history.replaceState` = **0**, `addEventListener` = **0** · y **el banner desaparecio** al recargar con
`Ctrl+F5`, con los tabs cambiando normalmente.

> **DOS PREDICCIONES MIAS QUE FALLARON, por si sirven de aviso:**
> 1. Dije que en el HTML debia haber `<script>` = 0 y salio **1**. No quedaba codigo: **mi propio
>    comentario menciona la palabra `<script>`**, y el contador se contaba a si mismo. El predicado bueno
>    busca las llamadas reales (`</script>`, `history.replaceState`, `addEventListener`), no las palabras.
> 2. Dije que el backup pesaria 28.688 bytes y peso **29.394**. Diferencia: 706 bytes, **uno por linea**:
>    el locker usa CRLF y el repo LF. Es lo ya anotado sobre no comparar tamanos ni hashes entre los dos
>    sitios — se me escapo al dar la cifra.

---

### Auditoria del DashboardAdmin — 09/09/2026 · CORRECTO EN LAS TRES PESTANAS

Nunca se habia verificado (al `DashboardLocker` si, el 08/09). Como Inigo lo usa para controlar las
calibraciones, convenia comprobar que no se estaba fiando de datos equivocados.

**Calibraciones — clavadas contra SQL:**

| | Admin (badges) | menos el CSS | SQL | |
|---|---|---|---|---|
| CADUCADO | 6 | **5** | **5** | ✅ |
| URGENTE | 1 | **0** | **0** | ✅ |
| PROXIMO | 17 | **16** | **16** | ✅ |
| CALIBRADO | 12 | **11** | **11** | ✅ |

> El CSS define cada clase de badge en la hoja de estilo, asi que el contador suma **1 de mas por
> categoria**. Mismo efecto que ya se anoto el 07/09 con `badge-en-uso` del Locker.

Los **5 caducados aparecen por su codigo** (`T-017`, `M-006`, `A-005`, `M-005`, `D-001`), no solo en el
contador: un contador puede acertar el numero y equivocarse de instrumento.

**Usuarios:** los **88** de SQL estan todos. **No filtra por `Activo`** (`SELECT ... FROM Usuario ORDER BY
CodigoCliente`, linea 122).

**Se regenera cada minuto** (comprobado: 08:57:29).

### Estado de las calibraciones a 09/09/2026

**5 CADUCADOS:**

| Codigo | Instrumento | Caduco | Lleva |
|---|---|---|---|
| **T-017** | Cal.pro. y gen.senal / RSPRO135 / 23200551 | 27/11/2025 | **286 dias** |
| M-006 | Nivel Optico / BOSCH GOL 20 D / 801000535 | 01/02/2026 | 220 dias |
| A-005 | Analizador particulas / KLOTZ / AMF20707 | 31/03/2026 | 162 dias |
| M-005 | Nivel Optico / LeicaNA730Plus / 5718201 | 30/04/2026 | 132 dias |
| D-001 | Atornillador Dinamometrico / LDA-40 | 09/06/2026 | 92 dias |

> **El `M-005` es el instrumento que se saco en la prueba funcional del 08/09** (consigna 03), y estaba
> caducado desde abril. El sistema lo permitio sin avisar. **No es un fallo**: ACTUM controla accesos, no
> calibraciones. Pero es un caso real de coger un instrumento caducado sin enterarse — si algun dia
> interesa, el dashboard podria avisarlo.

**AVALANCHA A LA VISTA: 16 instrumentos caducan entre el 21/10 y el 01/12/2026.** Medio locker en seis
semanas (las dos pinzas FLUKE, tres camaras termicas TESTO, dos analizadores de gases, el medidor laser...).
Si se mandan de uno en uno segun caen, seran seis semanas sin la mitad del material: **conviene agruparlos
y negociarlos por lotes con el laboratorio.**

**Cero instrumentos sin fecha de caducidad:** los 32 estan controlados. No hay ninguno en el limbo.

> **Inigo pidio ayuda con las calibraciones ("ya te dire").** Pendiente de que concrete que necesita.

**PENDIENTE DE LOCALIZAR — instrumentos de las consignas 9, 19, 26 y 27 (apuntado por Inigo, 09/09):**
Se mandaron a calibrar; la empresa confirma que **estan calibrados y enviados de vuelta a GHI**, pero
Inigo se fue justo entonces y **hay que localizarlos fisicamente**.

| Consigna | Codigo | Instrumento | Caduca |
|---|---|---|---|
| 09 | **L-004** | Megger Insulation tester / MIT320 / 102465739 | 26/05/2027 |
| 19 | **T-008** | Cam.Term / TESTO 885 / 5630885 | 03/06/2027 |
| 26 | **L-005** | Comp.Aisl / FLUKE 1507 / 43160491WS | 26/05/2027 |
| 27 | **M-017** | Son. / PEAK TECH 8005 / 230723323 | 02/06/2027 |

> ✅ **Las fechas de ACTUM YA estan actualizadas** (las cuatro en 2027): Inigo hizo el paso (a) del
> mantenimiento antes de irse. **Solo queda localizarlos y meterlos en su consigna** — la devolucion se
> registra sola al identificarse.

> **Dato que encaja:** las cuatro figuran en el dashboard **"En uso por IÑIGO A. ALONSO"**. El sistema
> tiene bien registrado que las saco el — que es lo que paso al mandarlas a calibrar. No hay discrepancia.

> ⚠️ **OJO AL SEGUNDO PASO, QUE ES EL QUE SE OLVIDA.** Que la empresa las calibre **NO actualiza ACTUM**.
> Al recuperarlas hay que hacer DOS cosas: meterlas fisicamente en su consigna **y actualizar la
> FechaCaducidad en el ACTUM EPI Visor**. Sin lo segundo, el DashboardAdmin las seguira contando con la
> caducidad vieja aunque esten recien calibradas.

Consulta lista para ver que instrumentos son y que fecha tiene ACTUM registrada:
```powershell
sqlcmd -S "GHI-TAQUILLAS\SQLEXPRESS" -d Actum_GHI -E -W -s"|" -Q "SET NOCOUNT ON; SELECT C.CodigoCliente AS Consigna, Cj.CodigoCliente AS Codigo, Cj.Descripcion, CONVERT(varchar(10), Cj.FechaCaducidad, 103) AS Caduca, DATEDIFF(day, GETDATE(), Cj.FechaCaducidad) AS Dias, ISNULL(U.Nombre,'') + ' ' + ISNULL(U.Apellidos,'') AS QuienLaTiene FROM Consigna C LEFT JOIN Caja Cj ON C.Caja_Codigo = Cj.Codigo LEFT JOIN Usuario U ON C.Usuario_Codigo = U.Codigo WHERE C.CodigoCliente IN ('09','19','26','27','9') ORDER BY C.CodigoCliente"
```

### ⚠️ REGLA NUEVA — contar en HTML con regex: el instrumento suele ser el problema

**Dos falsos positivos el mismo dia, los dos por el contador, no por el sujeto:**

1. **`<script>` = 1 tras eliminarlo.** No quedaba codigo: **el comentario explicativo menciona la palabra**
   y el contador se contaba a si mismo. Predicado bueno: buscar las **llamadas reales**
   (`</script>`, `history.replaceState`, `addEventListener`), no las palabras.
2. **Parecian faltar 32 usuarios en el Admin.** El patron `<tr>` no captura `<tr style="...">`, y la tabla
   de Registro de Uso genera sus filas asi (`GenerarDashboardAdmin.ps1:913`). Contando bien:
   88 usuarios + 32 calibracion + 3 cabeceras = **123**, exacto.

> **Antes de dar por buena una anomalia medida con regex sobre HTML, comprobar que el patron captura todas
> las variantes de la etiqueta.** Usar `<tr` en vez de `<tr>`, y verificar contra el codigo que genera el
> HTML. Cuesta un minuto y evita perseguir un fantasma.

---

### v2.6 — CAUSA RAIZ DE LOS DUPLICADOS, ENCONTRADA Y CERRADA (09/09/2026)

**Los duplicados del CSV no eran mala suerte: eran dos fallos encadenados.**

#### Fallo 1 — el marcador perdia los milisegundos

La tabla `Eventos` guarda `FechaHora` **con milisegundos**; el marcador se escribia **truncado al segundo**.
Como la query es `FechaHora > @ultimo`:

```
evento real : 11:52:50.813
marcador    : 11:52:50.000   ->  11:52:50.813 > 11:52:50.000  =  SIEMPRE VERDADERO
```

**El evento volvia a entrar en CADA pasada, indefinidamente.** Medido en vivo: el de la consigna 22
llevaba **una hora** reprocesandose cada minuto, visible en el log como
`[DEDUP] Artefacto cross-batch descartado (consigna 22, 0.813 s)`.

#### Fallo 2 — el dedup solo protege a la primera fila del lote (LATENTE, no se toca)

En PASO 3, el chequeo contra el CSV esta en el `else` de `if ($clusterActual.Count -gt 0)`, asi que
**solo se aplica mientras no haya ningun cluster abierto**. En cuanto una fila abre cluster, las siguientes
ya no se comparan con el CSV.

Asi se duplico la consigna 26 el 09/09: llego el evento **nuevo** de la 19, ordenado antes (19 < 26), abrio
cluster; el de la **26** —reprocesado por el fallo 1— entro detras **sin pasar por el chequeo**.

> **Se deja como esta**: sin reprocesos no llega a manifestarse. Arreglarlo seria maquinaria extra en el
> script que corre cada minuto. **Cambio minimo suficiente.**

#### El arreglo

El marcador se escribe con **milisegundos**, y la fecha se toma **del evento SQL original** (`$filasLimpias`),
no del CSV, donde ya viene truncada. Sigue avanzando **solo sobre lo escrito**, como manda la regla del 02/06.
La lectura acepta los dos formatos, para que el marcador viejo siga valiendo.

**Verificado en produccion:**
```
[MARCADOR] Actualizado a 2026-09-09 11:52:50.813 (escritura atomica)
...siguiente pasada...
[EVENTOS] Encontrados: 0 eventos de identificacion     <- el reproceso PARO
```

#### 🔬 EL BUG SE MANIFESTO EN VIVO — y enseno algo que nadie habia previsto

Al editar a mano la linea de la consigna 22 (cambiar JAVIER JULIAN DE LAMO por SERGIO V. VEGA), el
monitor **volvio a escribir la original siete veces**, una por minuto.

**Por que:** el dedup identifica los eventos comparando **nombre y apellidos** con la ultima linea del CSV.
Al cambiar el nombre a mano, dejo de reconocerlo como ya escrito, y como el evento seguia entrando
(fallo 1), lo reescribia en cada pasada.

> ⚠️ **REGLA: no editar a mano una linea del CSV correspondiente a un evento RECIENTE mientras el evento
> pueda seguir entrando.** Con la v2.6 ya no puede — el marcador lo deja atras — pero el patron es
> importante: **editar un nombre rompe el reconocimiento del dedup.**

Limpieza posterior: 7 lineas de Javier + 1 duplicado de la consigna 26. **CSV final: 536 / 536, ratio 1,00,
535 movimientos.**

#### 🧪 DOS COSAS QUE SOLO SE VIERON POR PROBAR ANTES DE DESPLEGAR

1. **`ParseExact` con array de formatos NO se resuelve en PowerShell 5.1 sin cast `[string[]]`.** Fallaba
   con **ambas** cadenas. De haberlo desplegado, el marcador habria dejado de leerse en cada pasada y el
   script caeria al fallback siempre — peor que el problema original.
2. **La primera prueba dio un FALSO POSITIVO**: tras la excepcion las variables quedaban en `$null`, y
   comparar una fecha con `$null` devuelve `True`. El test decia que todo iba bien.

> **Probar el mecanismo con datos de verdad antes de tocar produccion no es ceremonia: aqui evito
> desplegar algo peor que el bug.**

---

### Consigna 22 — mapa de correcciones (importante si algun dia se reconstruye)

| Cuando | Que | Donde vive | Sobrevive a reconstruir? |
|---|---|---|---|
| 16/04 12:44:30 | IKER devuelve | `CorreccionesManuales.csv` | ✅ paso 2.5 |
| 16/04 12:45:00 | **SERGIO extrae** | `CorreccionesManuales.csv` | ✅ paso 2.5 |
| 09/09 11:52:50 | SERGIO devuelve | **`CorreccionesManuales.csv`** | ✅ **paso 2.5 la SUSTITUYE** (desde el 09/09) |

**Que paso realmente el 09/09:** al devolver el analizador, Inigo se identifico **con el codigo de Javier
Julian de Lamo (usuario 38)** por error, en vez del de Sergio Vega (usuario 14). El evento de SQL dice
Javier y **eso no se puede cambiar**: es lo que ocurrio.

> ✅ **RESUELTO el 09/09.** Antes esa linea se habia editado a mano en el CSV y una reconstruccion la
> habria revertido a Javier. Ahora vive en `CorreccionesManuales.csv` y el paso 2.5 **sustituye** la que
> genera SQL, asi que sobrevive a cualquier reconstruccion. **Las 5 correcciones estan protegidas.**

**Los movimientos de Javier de 2025 (consignas 12, 13, 19, 24) son reales y NO se tocan.**

---

### `EstadoAnterior.json` vacio — EVALUADO Y DESCARTADO (09/09/2026)

`$estadoPorConsigna` solo aparece en las lineas 621-623, justo donde se escribe el fichero, y **nunca se
define**: por eso queda en `{}`. Ese fichero lo lee **solo el fallback v1.0**, el metodo antiguo que salta
si la tabla `Eventos` fallara.

**Por que NO se arregla:** ese fallback **tambien necesita SQL** (lee la tabla `Consigna`), asi que solo
serviria en un escenario rarisimo — que `Eventos` falle pero el resto de la base funcione. Y no se ha
activado ni una vez desde abril. Tocar el script que corre cada minuto para mejorar una red de emergencia
que nunca se usa, y que en su escenario probablemente tampoco podria trabajar, **no pasa el filtro del
cambio minimo suficiente**.

> ⚠️ **SENAL DE ALARMA:** si algun dia aparece `[FALLBACK]` en el log, hay que mirarlo. Significaria que
> estamos en ese escenario raro **y con la red degradada** (estado previo vacio), asi que el fallback
> podria no detectar bien los cambios.

### ✅ HECHO 09/09 — el paso 2.5 SUSTITUYE, no solo anade

**Peticion de Inigo (09/09):** *"quiero que siempre que cambie algo de esta forma por haberme equivocado o
lo que sea, se arregle con lo de CorreccionesManuales"*.

Hoy el paso 2.5 **anade** las lineas de `CorreccionesManuales.csv`. Si en vez de eso **sustituyera** cuando
ya existe un movimiento con la misma clave (fecha + consigna + accion), se podria corregir **cualquier**
movimiento —incluidos los que SQL genera— y sobreviviria a toda reconstruccion.

Cerraria el circulo de los tres tipos de correccion:

| Tipo | Estado |
|---|---|
| **Anadir** un movimiento que no existe en SQL | ✅ paso 2.5 |
| **Editar** un movimiento que SI existe en SQL | ✅ **paso 2.5 con sustitucion (09/09)** |
| **Escribir** directamente en el CSV | ✅ paso 2.6 (filas huerfanas) |

**La clave de sustitucion es fecha + consigna + accion. NO incluye el usuario**, precisamente para poder
corregirlo. Desplegado y verificado el 09/09: 343 lineas, 0 errores. **5 correcciones protegidas.**

### v2.7 — GUARDA ANTI-DUPLICADO, la ultima red (09/09/2026)

Justo antes de escribir en el CSV, el monitor comprueba que la linea **no exista ya**. Una linea identica
a otra **siempre** es un error: no se puede hacer dos veces la misma accion, sobre la misma consigna, en el
mismo segundo.

**Por que hace falta aunque la v2.6 quitara la causa:** el dedup del PASO 3 solo compara con el CSV la
primera fila del lote. Si un evento ya escrito volviera a entrar por otra via —marcador corrupto, fallback
v1.0, una reconstruccion— y llegara detras de uno nuevo, se colaria. **Esto lo hace imposible.**

**FAIL-OPEN:** si el CSV no se puede leer, escribe igual. Duplicar es molesto; **perder un movimiento no se
recupera de ningun sitio**.

Si alguna vez aparece `[GUARDA] Duplicado exacto BLOQUEADO`, el CSV esta a salvo **pero hay que mirar por
que llego hasta ahi**: significa que algo anterior fallo.

Probada con ficheros reales antes de desplegar. Verificada en produccion: **638 lineas, 0 errores**.

> Va en `ReconstruirHistorial.ps1`, que se lanza a mano y casi nunca. **NO toca el monitor.**
> Al implementarlo, mover ahi la correccion de Sergio del 09/09 y quitarla del CSV editado a mano.

---

# 🟢 SIGUIENTE PASO — 2026-09-09

> **El reinicio con cambio de BIOS ya se hizo el 08/09 por la tarde y salio bien.** El detalle esta en el
> apartado **P**. Lo que sigue esta ordenado por valor.

### 1. Lo unico que puede volver a tumbar el sistema: LA CORRIENTE

Los cortes van a seguir (8 en 5 semanas, el ultimo el 07/09 a las 19:15). **Ya no dejan el locker muerto**
—vuelve solo—, pero atacar la causa sigue mereciendo la pena:

- **SAI** de 650-800 VA (60-100 EUR). Absorbe los cortes breves, que son la mayoria, y permite apagado
  ordenado en los largos. Acaba tambien con los apagones sucios que metieron bytes NULL en el CSV.
- **Avisar a mantenimiento del cuadro electrico.** Si se cae solo, el locker es solo el sintoma que se ha
  notado; habra mas cosas colgando de ahi.

### 2. Dos preguntas para personas, no para el ordenador

- **Consigna 22:** ¿quien tiene el *Analizador de Gases TESTO 340 nº **63862113***, SERGIO V. VEGA o
  IKER L. LASSO? La taquilla esta vacia, asi que alguien lo tiene. SQL dice Iker; el dashboard, Sergio
  (correccion manual del 10/06). **Quien conteste, decide cual es la verdad.**
- **Consigna 5:** ¿donde esta el *Analizador de Gases TESTO 340 nº **61186226*** (`A-003`)? El sistema lo
  da dentro desde que **DANIEL M. MARTINEZ lo devolvio el 30/04/2026** y la taquilla esta vacia.
  Preguntar a Daniel o mirar si esta en calibracion.

> ⚠️ **Son dos TESTO 340 DISTINTOS.** No confundirlos: el **63862113** es el de la 22 y esta fuera
> legitimamente; el **61186226** es el de la 5 y esta desaparecido.

### 3. Mejoras opcionales, por valor

| | Que | Nota |
|---|---|---|
| a | **Alerta de sistema caido** | Aparcada por decision de Inigo, pero **cubierta a medias el 09/09** con el banner de salud del **DashboardAdmin** (ver abajo). Lo que el banner NO cubre: que el PC este muerto, ni avisa a nadie por si solo (hay que abrir el Admin). Para eso el vigilante tiene que correr FUERA del locker. |
| ~~b~~ | ~~**Leer `Consigna.Usuario_Codigo` para la pestana Estado**~~ | ❌ **DESCARTADO 10/09 por Inigo.** Ya no estaba bloqueado, pero **es mala idea**: pondria a **SQL** a mandar en la columna Estado, y SQL es justo quien se equivoca en los casos corregidos a mano. Las 5 filas de `CorreccionesManuales.csv` existen porque SQL dice IKER donde debe decir SERGIO. Darle el mando **resucitaria el dato erroneo**. |
| ~~c~~ | ~~Quitar el `<script>`~~ | ✅ **HECHO 09/09.** Confirmado en consola, eliminado y verificado: el banner desaparecio. |
| ~~d~~ | ~~`EstadoAnterior.json` vacio~~ | ✅ **EVALUADO Y DESCARTADO 09/09.** Ver abajo. |
| ~~e~~ | ~~Quitar `MicrosoftEdgeAutoLaunch`~~ | ✅ **HECHO 09/09.** Ya no se abre Edge al arrancar. El arranque queda con `ACTUM_EPI_Gestion`, `OneDrive`, `Microsoft Edge Update` (actualizador silencioso, no abre ventanas), `Microsoft.Lists` y `SecurityHealth`. |
| **f** | **CALIBRACIONES** — tarea **recurrente**, no de un dia | La pestana Calibracion del `DashboardAdmin.html` ya clasifica por **CADUCADO / URGENTE (<30d) / PROXIMO (<90d)** leyendo `Caja.FechaCaducidad` de SQL: **sirve directamente como lista de trabajo**. Los pendientes estan apuntados en el cuaderno GHI y en recordatorios del movil. Ir mandando poco a poco. |
| g | **De raiz: quitarse OneDrive + `fabricacion1`** | Sigue siendo el unico tramo que se rompe solo cada ~50 dias sin dar error. Alternativas del 20/05: **Graph con certificado** o **IIS local**. |
| h | **Usar el AUTO-UPDATE** de `GenerarDashboard.ps1:6-21` | Canal de despliegue sin TeamViewer que nadie aprovecha. |

### 3.bis · BANNER DE SALUD EN EL **DASHBOARD ADMIN** — hecho el 09/09

**El problema que resuelve:** este sistema **falla en silencio**. La tarea corre oculta, y cuando algo va
mal nadie se entera hasta que alguien mira con atencion. El 09/09 estuvo escribiendo lineas duplicadas
**cada minuto** y solo se cazo porque estabamos delante; en agosto un bucle de reprocesado destruyo el CSV
y **paso 19 dias** sin que nadie lo supiera.

**Que se ha hecho:** `GenerarDashboardAdmin.ps1` se autodiagnostica antes de construir el HTML y **siempre
muestra el resultado** arriba del todo, encima del de calibraciones:

- **Verde** (`.salud-ok`) si todo esta bien, con **los numeros medidos**:
  *536 lineas / 536 unicas · 0 bytes NULL · 2 movimientos en 24 h · marcador 09/09/2026 11:52:50*
- **Rojo** (`.aviso-salud`) con la lista de lo que falla, y los numeros medidos igualmente.

> **Por que se muestra siempre y por que numeros en vez de un tick verde** — peticion de Inigo (09/09):
> *"quiero que aparezca algun banner o algo aunque haya 0 errores, pero que se vea"*. Tiene razon de fondo:
> **un detector que solo habla cuando falla no deja distinguir "todo bien" de "el chequeo no esta
> corriendo"**. Es exactamente lo que nadie noto del watchdog viejo, que llevaba meses callado sin hacer
> nada. Y se pintan los **numeros**, no un tick: un tick verde puede mentir; `536 / 536` es una medida.

**Las cuatro comprobaciones** (las cuatro firmas de averia que este proyecto ya ha sufrido):

| | Que mira | De donde viene |
|---|---|---|
| 1 | **Lineas duplicadas exactas** en el CSV | el bucle del 07/09 (ratio ~600:1) y los duplicados del 09/09 |
| 2 | **Bytes NULL** en el CSV | escritura cortada por apagon — se encontraron 4 el 07/09 |
| 3 | **Mas de 60 movimientos en 24 h** (lo normal son ~10) | firma del reprocesado en marcha |
| 4 | **Marcador ilegible o en el FUTURO** | si apunta al futuro, `FechaHora > @ultimo` no devuelve nada nunca |

#### ⚠️ POR QUE EN EL ADMIN Y NO EN EL DASHBOARD PUBLICO — decision de Inigo, 09/09

Se implemento primero en `GenerarDashboard.ps1` y se **revirtio**. Pregunta de Inigo: *"¿Pero lo va a ver
todo el mundo?"*. **Si**: `DashboardLocker.html` es el que se reparte por el enlace de SharePoint a toda la
gente de GHI. Un aviso rojo que dice *"bytes NULL en el historial"* no le dice nada a quien solo quiere ver
si su instrumento esta libre, y **siembra dudas sobre unos datos que casi siempre estan bien**.

El aviso es tecnico y **quien puede actuar sobre el es quien abre el panel de administracion**. Ahi va.

> **Contrapartida honesta: solo avisa cuando alguien abra el Admin.** Es peor cobertura que el publico —
> nadie recibe nada, hay que ir a mirar. Se acepta a cambio de no meter ruido a 88 usuarios.

> **Matiz medido, para no venderlo mejor de lo que es:** `DashboardAdmin.html` y `DashboardLocker.html`
> **viven en la misma carpeta** `LockerACTUM` de OneDrive. Lo que los separa hoy es **que enlace se ha
> repartido**, no un permiso distinto. "Interno" lo es en la practica, no por configuracion.
> **No se ha comprobado que tengan permisos diferentes en SharePoint.**

**Por que NO va en el monitor:** la regla dura. `MonitoreoLockerTiempoReal.ps1` es el unico componente cuyo
fallo no se recupera despues. Los dos dashboards son regenerables: si esto se rompiera, se pierde un HTML
que se rehace al minuto siguiente.

**Lo que este banner NO puede hacer** — y conviene tenerlo claro: **si el PC esta muerto, no hay nadie
generando el HTML**, asi que no avisa de nada. Cubre "el sistema esta haciendo algo raro", no "el sistema
no esta". Para lo segundo sigue haciendo falta un vigilante externo (pendiente 3.a).

**Probado antes de desplegar, con casos conocidos positivo y negativo** (regla: un detector recien escrito
es un sujeto mas, no un instrumento fiable). Ejecutado **dos veces**: sobre la version del dashboard publico
y otra vez sobre el bloque ya movido al Admin, con **resultado identico**:

| Caso | Esperado | Medido |
|---|---|---|
| A · CSV sano (muestra real de febrero) | 0 avisos | **0** |
| B · 1 linea duplicada + 1 byte NULL | 2 avisos | **2**, los dos correctos |
| C · 80 movimientos en 24 h + marcador a +2 dias | 2 avisos | **2**, los dos correctos |
| D · marcador con texto basura | 1 aviso | **1** |

**Discrimina: calla con datos sanos y habla con cada una de las cuatro averias.** Reprobado una tercera vez
tras anadir la tira verde: los mismos 4 casos, mismo resultado, y **los datos medidos aparecen en los cuatro**
(tambien en el sano, que es lo que se queria).

**DESPLEGADO Y VERIFICADO EN EL LOCKER el 09/09.** Dos despliegues el mismo dia:

| Version | Verificacion del `.ps1` | Verificacion del HTML generado |
|---|---|---|
| solo-rojo | `sintaxis=0 no-ASCII=0 lineas=1243` | `banner_salud=0` · `banner_calibracion=1` · 126.267 bytes |
| **con tira verde (la actual)** | `sintaxis=0 no-ASCII=0 lineas=1281` | **`verde=1` · `rojo=0` · `calibracion=1`** |

**Predicado cumplido al digito** en las dos: el de salud callado (o en verde) porque el CSV esta sano, y el
de calibraciones encendido porque hay 5 caducados.

**La linea que salio en produccion, leida del HTML:**
```
Sistema comprobado - sin anomalias.
536 lineas / 536 unicas  ·  0 bytes NULL  ·  5 movimiento(s) en 24 h  ·  marcador 09/09/2026 11:52:50
```

> **Tres cosas que esa linea confirma de paso, sin haberlas buscado:**
> 1. **536/536, ratio 1,00** — el bucle sigue muerto y la limpieza de esta manana aguanta.
> 2. **El marcador de la v2.6 se lee bien.** Es el que se escribio con milisegundos (`11:52:50.813`); que
>    aparezca aqui prueba **en produccion** que el `ParseExact` con array de formatos y su cast `[string[]]`
>    funciona — hasta ahora solo estaba probado en banco.
> 3. **5 movimientos en 24 h**, la actividad de hoy. Lejos del umbral de 60.

**Verificacion de los dos ficheros:**

| Fichero | Lineas | no-ASCII | Sintaxis | Here-strings |
|---|---|---|---|---|
| `GenerarDashboardAdmin.ps1` (con el aviso) | **1.281** | 0 | 0 errores | 17/17 |
| `GenerarDashboard.ps1` (revertido, sin tocar) | **705** | 0 | 0 errores | 5/5 |

> **`GenerarDashboard.ps1` vuelve a ser exactamente el que ya esta en el locker:** no hay que redesplegarlo.
> **Solo se despliega `GenerarDashboardAdmin.ps1`.**
> Version previa en `historico/scripts-antiguos/GenerarDashboardAdmin_ANTES_SALUD_20260909.ps1`.

### 4. Recordatorio operativo

**Dejar `ACTUM_EPI_Gestion.exe` ABIERTO.** Mientras este cerrado el locker **no registra nada**, y eso no
se recupera despues. Inigo lo cierra a proposito para trabajar por TeamViewer: acordarse de reabrirlo
al terminar cada sesion.

## DESPUES DEL REINICIO — resto de pendientes, por orden

### Fisicos (hay que bajar al locker)

1. **PRUEBA FUNCIONAL REAL.** Es el unico hueco de verificacion que queda: **el sistema reparado no se ha
   probado con un movimiento nuevo desde el 16/07**. Con ACTUM abierto: identificarse, **sacar** un
   instrumento, cerrar, **anotar hora exacta + consigna + instrumento**; esperar **mas de 30 segundos**
   (hay un dedup de 3 s, no confundir con duplicado); **devolverlo** y anotar la hora.
   > **Predicado de exito:** por cada accion fisica aparece **1 SOLO movimiento** en el CSV (no 2 — ojo a
   > los pares de eventos 10000+10001), con el **usuario correcto**, la **accion correcta**, el **marcador
   > avanzado a hoy** en formato `yyyy-MM-dd HH:mm:ss`, y reflejado en el dashboard en **< 1 min**.
   > Verificar las tres cosas: CSV, marcador y dashboard.
2. **CONSIGNA 22.** El dashboard dice **SERGIO V. VEGA** y SQL dice **IKER L. LASSO**. Abrirla y ver si el
   analizador de gases **TESTO 340** esta dentro. Es lo unico que resuelve el desacuerdo. De paso,
   comprobar 2-3 consignas mas marcadas *En uso*.
3. **SAI + cuadro electrico.** La causa de verdad. Un SAI de 650-800 VA (60-100 EUR) absorbe los cortes
   breves y permite apagado ordenado en los largos. Y avisar a mantenimiento del cuadro: si se cae solo,
   el locker es solo el sintoma que se ha notado.

### De software (se pueden hacer en remoto)

4. **EL GRAN ORDEN — los TRES frentes, y se hacen A LA VEZ** (asi lo quiere Inigo, 08/09).
   Dejado expresamente **para el final**: es lo unico que mueve ficheros de sitio.

   **4.a — `C:\ACTUM` en el locker. ✅ HECHO Y VERIFICADO el 08/09 13:14.**

   | | Antes | Despues |
   |---|---|---|
   | Ficheros en la raiz | 46 | **14** |
   | Carpetas | 8 | **3** (`ACTUM_EPI`, `BACKUP_20260907`, `_ARCHIVO`) |
   | Archivado a `_ARCHIVO\` | — | **35 elementos** (29 ficheros + 6 carpetas), **sin borrar** |
   | Borrado | — | 3 inutiles: fichero vacio, `.lnk` suelto y el leftover `UltimoEventoProcesado.txt` |

   **Verificacion tras aplicar:** los 13 activos en su sitio · `ACTUM_EPI` intacto ·
   `.\GenerarDashboard.ps1` -> *SQL OK, 32 instrumentos, 528 movimientos* y HTML de
   **246.461 bytes, byte-identico** al de antes de limpiar. La limpieza no altero nada.

   > Se aplico **antes** que 4.b/4.c/4.d, aprovechando que el locker estaba parado (ACTUM cerrado).
   > No habia dependencia tecnica entre los cuatro frentes: lo de "a la vez" era coherencia, no necesidad.

   Herramienta usada:
   Herramienta ya escrita y validada: **`LimpiarACTUM.ps1`** (162 lineas, ASCII puro, 0 errores).
   - **SIMULA por defecto**: `.\LimpiarACTUM.ps1` muestra el plan sin tocar nada.
   - Solo con `.\LimpiarACTUM.ps1 -Aplicar` actua.
   - Aparta a `C:\ACTUM\_ARCHIVO\` unos 98 MB (backups, instaladores, exports de febrero, pruebas,
     consultas sueltas) **sin borrar**, salvo 3 ficheros inutiles.
   - **NO mueve ningun script activo** (sus rutas estan cableadas en 4 `.vbs` y 5 tareas) y respeta una
     lista de intocables donde estan **`EXPORT_Cajas.txt`** (fallback que leen 3 scripts) y
     **`logo_base64.txt`** (`GenerarDashboard.ps1:52`).
   - Tras aplicarlo: `.\GenerarDashboard.ps1` para confirmar que el sistema sigue vivo.
   - **Simulacion ejecutada en el locker el 08/09** (`sintaxis=0 no-ASCII=0 lineas=162`):
     raiz con **46 ficheros y 8 carpetas** -> se archivarian **35 elementos** y se borrarian **3**.
     `EXPORT_Cajas.txt` correctamente avisado como intocable; los 13 activos y `ACTUM_EPI`, verificados
     en su sitio. Quedaria una raiz de ~11 ficheros y 3 carpetas (`ACTUM_EPI`, `BACKUP_20260907`, `_ARCHIVO`).
   - **Defecto corregido tras esa simulacion (v de 166 lineas):** los patrones `*_BACKUP_*.ps1` y
     `*_backup_*.ps1` son el mismo en Windows, que no distingue mayusculas, y tres ficheros salian
     **listados y contados dos veces** (38 en vez de 35). Anadido un `HashSet` de ya-planificados.
     Redesplegada y **reverificada en el locker el 08/09**: `sintaxis=0 no-ASCII=0 lineas=166` y
     **`se archivarian 35 elementos y se borrarian 3`**, sin nombres repetidos. Los 13 activos y
     `ACTUM_EPI` verificados en su sitio. **Lista para `-Aplicar` cuando toque el gran orden.**

   **4.b / 4.c — ESTA CARPETA Y GITHUB. HECHO Y VERIFICADO el 08/09.**
   La raiz paso de **64 ficheros sueltos a 5**. Estructura resultante:

   ```
   LOCKER INSTRUMENTACION/
   |-- locker/         13  ESPEJO EXACTO de lo que debe haber en C:\ACTUM
   |-- herramientas/    1  se lanza a mano y no vive en el locker (RespaldarLockerAntesCambios)
   |-- docs/           14  documentacion, guias, .docx y accesos directos
   |-- historico/      66  scripts antiguos, notas de sesiones, respaldos, propuesta-codex
   |-- muestras/        2  datos de ejemplo, RENOMBRADOS a *_MUESTRA_2026-02
   `-- CLAUDE.md · README.md · .gitignore · .gitattributes · RESULTS.jsonl
   ```

   **Verificado:** `locker/` coincide **exactamente** con los ficheros activos del locker real
   (los 13; `EXPORT_Cajas.txt` no esta en el repo por ser un dato generado). Comprobar si el locker
   esta al dia es ahora una comparacion mecanica, no un ejercicio de memoria.

   **4.c GitHub:** el commit registro **89 renombrados (`R`) y solo 2 anadidos**, asi que el historial
   de cada fichero sigue a su nueva ubicacion en vez de aparecer como borrado + nuevo.

   **`.gitattributes` anadido** (era el pendiente 9): sin el, Git avisaba en cada commit de LF/CRLF y
   podia marcar como modificados ficheros que nadie habia tocado. Los `.ps1`/`.vbs` quedan CRLF en
   disco y LF en el repositorio; los binarios, intactos.

   *(Historico de la propuesta previa a la ejecucion:)* Hoy la raiz mezcla codigo activo,
   documentacion, backups, muestras antiguas, capturas, `.docx`, `.url` y scripts de un solo uso.

   > **OJO A LA DIFERENCIA ENTRE LOS DOS SITIOS.** En el locker la limpieza solo APARTA LO MUERTO: los
   > 13 ficheros activos **se quedan planos en la raiz** porque sus rutas estan cableadas en 4 `.vbs` y
   > 5 tareas. Aqui NO hay esa atadura —este repo se edita, no se ejecuta— asi que **si se puede
   > reorganizar de verdad**. No esperar que las dos carpetas queden identicas: lo que se comparte es
   > el CRITERIO (activo / herramienta / historico), no la forma.

   Estructura propuesta, pensada para que se vea de un golpe que se despliega y que no:

   ```
   LOCKER INSTRUMENTACION/
   |-- locker/          <- lo que va TAL CUAL a C:\ACTUM: los 5 .ps1 activos + los 4 .vbs
   |-- herramientas/    <- se lanzan a mano: AuditarDashboard · LimpiarACTUM ·
   |                       RespaldarLockerAntesCambios · CrearCorreccionesManuales · ReconstruirHistorial
   |-- docs/            <- documentacion, guias, los .html de documentacion, .docx
   |-- historico/       <- backups de scripts, versiones antiguas, propuesta-codex-2026-09-08,
   |                       RESPALDO_ANTES_CODEX, conversaciones y notas de sesiones viejas
   |-- muestras/        <- datos de ejemplo antiguos, renombrados a *_MUESTRA_2026-02 (pendiente 8)
   `-- CLAUDE.md · README.md · .gitignore · .gitattributes   <- solo esto en la raiz
   ```

   > La carpeta `locker/` es la que mas valor tiene: **su contenido es exactamente lo que debe estar en
   > `C:\ACTUM`**, asi que comparar ambas se convierte en un `diff` y deja de depender de la memoria.
   > **Cuidado:** mover un `.ps1` aqui **NO afecta al locker** (alli las rutas son absolutas
   > `C:\ACTUM\*.ps1`), pero **si invalida las rutas citadas en esta documentacion**. Actualizar
   > las referencias de `CLAUDE.md` en el mismo movimiento.

   **4.c — GITHUB.** Al ser el mismo repo, se ordena solo con 4.b: el commit debe hacerse con
   `git mv` para que el historial siga cada fichero a su nueva ubicacion y no aparezcan como
   borrados + nuevos. Anadir tambien el `.gitattributes` que falta (pendiente 9) en esa misma tanda.

   **4.d — LA CARPETA DE DATOS `LockerACTUM` (OneDrive del locker).** `LimpiarACTUM.ps1` NO la toca:
   solo actua sobre `C:\ACTUM`. Inventario medido el 08/09 13:07:

   | Fichero | Tamano | Que es |
   |---|---|---|
   | `HistorialCompleto.csv` | 52,3 KB | **el historial vivo** (sin escribirse desde el 07/09 14:47) |
   | `DashboardLocker.html` | 240,7 KB | se regenera cada minuto |
   | `DashboardAdmin.html` | 122,5 KB | idem |
   | `CorreccionesManuales.csv` | 1,2 KB | las 4 correcciones manuales |
   | `UltimoEventoProcesado.txt` | 19 B | el marcador |
   | `EstadoAnterior.json` | **0 B** | vacio: `$estadoPorConsigna` sin definir (pendiente menor) |
   | `HistorialCompleto_BACKUP_20260421.csv` | 50,1 KB | **backup de abril, se puede archivar** |

   Regla para esta carpeta: **solo deben vivir aqui los ficheros que el sistema usa o publica.**
   Todo lo que sea copia o historico se saca, porque **cada byte de aqui lo sincroniza OneDrive**.

   > **Por que los tres juntos:** para que la estructura del locker y la del repo se parezcan y no
   > haya que traducir mentalmente entre las dos cada vez que se despliega algo.
5. **Alerta de sistema caido** — aparcada por decision de Inigo ("estoy atento cada 2 por 3"), no
   descartada. **El vigilante debe correr FUERA del locker**: uno que corra dentro no puede avisar de que
   el PC esta muerto, que es justo lo que paso 12 h y 6 dias.
6. **Leer `Consigna.Usuario_Codigo` para la pestana Estado** (pendiente desde el 20/05). Mas importante de
   lo que parecia: hoy **toda** la columna Estado se deriva del CSV en vez de la fuente de verdad
   (apartado L).
7. **Quitar el `<script>`** de `GenerarDashboard.ps1:672-684` (banner rojo de SharePoint por
   `replaceState`). Confirmar antes que el error que ve Inigo es ese y no otro.
8. **Renombrar las trampas de datos del repo:** `HistorialCompleto.csv` (18 movimientos, de febrero) y
   `DashboardLocker.html` (18/02) -> sufijo `_MUESTRA_2026-02`. **Ahora ademas estan publicados en GitHub.**
9. **Anadir un `.gitattributes`** — no existe, de ahi los avisos `LF sera reemplazado por CRLF`. No rompe
   nada, pero puede provocar falsos "modificados".
10. **Calibraciones** (tarea recurrente): la pestana Calibracion del `DashboardAdmin.html` ya clasifica por
    CADUCADO / URGENTE (<30d) / PROXIMO (<90d) leyendo `Caja.FechaCaducidad`. Sirve de lista de trabajo.
11. **De raiz: quitarse la dependencia de OneDrive + `fabricacion1`.** Alternativas estudiadas el 20/05 y
    aun validas: **Microsoft Graph con App Registration + certificado** (no caduca nunca, sin coste, GHI ya
    tiene Entra ID) o **IIS local** en `http://172.16.5.40` (pendiente verificar si las oficinas alcanzan
    esa subred).
12. *(Ordenar el repo y GitHub: movido al pendiente **4.b / 4.c**, para hacerlo junto con `C:\ACTUM`.)*
13. **Usar el AUTO-UPDATE que ya existe** en `GenerarDashboard.ps1:6-21`: si aparece una version mas nueva
    del script en la carpeta de OneDrive, el locker se la copia y se relanza solo. **Canal de despliegue
    sin TeamViewer que nadie usa.**

---

## Herramientas disponibles (en el repo y en `C:\ACTUM`)

| Script | Que hace | Estado |
|---|---|---|
| `AuditarDashboard.ps1` | Comprueba que el dashboard dice la verdad (CSV + HTML + comparacion con SQL). **Solo lectura** | desplegado |
| `CrearCorreccionesManuales.ps1` | Crea/rehace `CorreccionesManuales.csv` con copia de seguridad y verificacion | desplegado |
| `LimpiarACTUM.ps1` | Ordena `C:\ACTUM`. **Simula por defecto** | **solo en el repo** |
| `ReconstruirHistorial.ps1` | Rescate: rehace el CSV desde `Eventos`. **Paso 2.5** reaplica `CorreccionesManuales.csv` y **paso 2.6** conserva las filas escritas a mano directamente en el CSV | **desplegado 08/09, NO ejecutado** |
| `RespaldarLockerAntesCambios.ps1` | Copia scripts y datos del locker antes de un cambio, con verificacion SHA-256 y restauracion del estado de las tareas. De Codex, conservado | **solo en el repo** |

## Como desplegar un script al locker

1. Abrir el `.ps1` en **`locker/`** (esa carpeta es el espejo de `C:\ACTUM`), `Ctrl+A`, `Ctrl+C`.
2. En el locker: Bloc de notas -> pegar -> guardar en `C:\ACTUM\` con **Tipo: Todos los archivos** y
   **Codificacion: UTF-8**. (Si no se elige *Todos los archivos*, se guarda como `.ps1.txt`.)
3. **Verificar SIEMPRE** (esto detecta un pegado truncado, que ya paso en marzo: 688 lineas llegaron 454):

```powershell
$f = "C:\ACTUM\NOMBRE.ps1"
$err = $null
[void][System.Management.Automation.Language.Parser]::ParseFile($f, [ref]$null, [ref]$err)
$t = [System.IO.File]::ReadAllText($f)
"sintaxis=$($err.Count)  no-ASCII=$(([regex]::Matches($t,'[^\x00-\x7F]')).Count)  lineas=$(([System.IO.File]::ReadAllLines($f)).Count)"
```

Debe dar **`sintaxis=0  no-ASCII=0`** y el numero de lineas esperado.

## Reglas que mas duelen si se olvidan

1. **`Sort-Object` sobre fechas `MM/dd/yyyy` ordena ALFABETICAMENTE.** Parsear siempre primero
   (`Sort-Object { [DateTime]::ParseExact($_.Campo,'MM/dd/yyyy HH:mm:ss',$null) }`). Ha causado dos
   incidentes graves (30/04 y 07/09).
2. **Nunca declarar exito sin releer el estado del sujeto.** `rc=0` y un `Write-Host` no son evidencia.
   Caso del 08/09: `powercfg /hibernate off` "se aplico" y `powercfg /a` demostro que no.
3. **`Enable-`/`Disable-ScheduledTask` exigen ADMINISTRADOR.** En ventana normal fallan en silencio. Y
   `Disable-` no corta una ejecucion en marcha: hace falta `Stop-ScheduledTask` ademas.
4. **Literales de fecha en SQL: SIEMPRE `'YYYYMMDD'`.** El servidor esta en espanol y `'2026-07-16'` se lee
   como ano-dia-mes.
5. **Un Event ID sin `ProviderName` no significa nada.** `11` y `153` son de disco en `disk`/`storahci` y
   otra cosa distinta en `Kernel-General`/`Kernel-Boot`.
6. **Ratio filas/unicas del CSV** es el detector barato del bucle: sano ~1,00; el 07/09 era ~600.
7. **`Get-Content` sin `-Encoding UTF8`** muestra `ExtracciÃ³n` aunque el fichero este perfecto: PowerShell
   5.1 lee como ANSI. No confundirlo con corrupcion real.
8. **NUNCA tildes literales dentro de un `.ps1`.** Usar `[char]0xF3` para `o` acentuada, etc. Todos los
   scripts activos son **ASCII puro**, y por eso el despliegue por copia-pega es viable.
9. **No usar here-strings al pegar por chat/TeamViewer**: la indentacion los rompe. Usar arrays con
   `-join`. Ese fallo dejo `EjecutarReconstruccionOculto.vbs` roto **desde el 20/05 sin que nadie lo
   notara**.
10. **NO mover los scripts activos de `C:\ACTUM`**: sus rutas estan cableadas en 4 `.vbs` y 5 tareas.

---

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Project Is

Automated monitoring system for the ACTUM EPI locker at GHI Hornos Industriales. It polls a SQL Server database every minute, detects locker open/close events, appends them to a CSV history, and generates a live HTML dashboard synced via OneDrive.

## Two Environments

**Development** (machine `ialopez`):
- Working folder: `C:\Users\ialopez\OneDrive - GHI HORNOS INDUSTRIALES S.L\TRABAJOS REALIZADOS\LOCKER INSTRUMENTACION\`
- No SQL Server access — scripts cannot be run end-to-end locally
- Server documental folder structure (handover package):
  - `DESARROLLO LOCKER (lo necesario para poder desarrollar el sistema si hace falta)` — source code, scripts, CLAUDE.md
  - `GITHUB REPOSITORIO` — link/reference to https://github.com/inigoalonsoo/LOCKER-.git
  - `INFORMACION LOCKER (lo que hay que saber sobre el sistema)` — DOCUMENTACION_LOCKER.html
  - `MANTENIMIENTO LOCKER (el unico mantenimiento manual que necesita)` — maintenance doc
  - `DashboardLocker` / `DashboardAdmin` — Windows shortcuts (.url) to the live dashboards

**Production** (locker machine — `GHI-TAQUILLAS`):
- Scripts deployed to: `C:\ACTUM\`
- SQL Server: `GHI-TAQUILLAS\SQLEXPRESS`, database `Actum_GHI`
- Dashboard and data: `C:\Users\User\OneDrive - GHI HORNOS INDUSTRIALES S.L\LockerACTUM\`
- Access via TeamViewer only (through a colleague who connects remotely)
- Only one Windows user exists on the locker: `User` (not `fabricacion1`, not `User2`)

## Deployment Workflow (ALWAYS follow this)

1. **Claude generates/updates `GenerarDashboard.ps1`** here in development
2. **User copies the script content** (Ctrl+A → Ctrl+C in VS Code)
3. **User sends it to their colleague** who has TeamViewer open to the locker
4. **Colleague opens Notepad on the locker**, pastes the content, saves as `C:\ACTUM\GenerarDashboard.ps1` (encoding: UTF-8, type: All Files)
5. **Colleague runs in locker PowerShell:**
   ```powershell
   cd C:\ACTUM
   .\GenerarDashboard.ps1
   ```
6. **Dashboard updates automatically** — `DashboardLocker.html` is synced via OneDrive to `fabricacion1@ghifurnaces.com`

> ⚠️ There is NO direct network access to the locker from the dev machine. Do NOT try to copy files over the network or use remote PowerShell. The only path is Notepad via TeamViewer.

## Real-Time Data Protocol

Claude must always work with real locker data. If any data is needed:
- Ask for the specific PowerShell command to run on the locker
- The user runs it in the locker PowerShell and pastes the output back
- Claude updates the script based on the real output

**Key data files on the locker:**
- `C:\ACTUM\EXPORT_Cajas.txt` — maps Consigna numbers to instrument codes (L-010, C-002, etc.)
- `C:\ACTUM\EXPORT_Consignas.txt` — consigna details
- `C:\ACTUM\EXPORT_Usuarios.txt` — user list
- `C:\Users\User\OneDrive - GHI HORNOS INDUSTRIALES S.L\LockerACTUM\HistorialCompleto.csv` — full movement history (delimiter `;`, UTF-8)
- `C:\Users\User\OneDrive - GHI HORNOS INDUSTRIALES S.L\LockerACTUM\EstadoAnterior.json` — last known state

## Script Roles — Qué modificar y qué NO tocar

### ✅ EL ÚNICO SCRIPT QUE SE MODIFICA: `GenerarDashboard.ps1`

Para cambiar el dashboard (diseño, columnas, colores, datos mostrados) **solo se toca `GenerarDashboard.ps1`**. Los demás NO hace falta modificarlos nunca salvo que cambie la infraestructura del locker.

| Script | ¿Se modifica? | Qué hace |
|--------|--------------|----------|
| `GenerarDashboard.ps1` | ✅ **SÍ** | Lee CSV → Genera el HTML del dashboard |
| `MonitoreoLockerTiempoReal.ps1` | ✅ **SÍ** | v2.0: Lee tabla Eventos de SQL → actualiza CSV → llama a GenerarDashboard. **Recupera TODO aunque el PC se apague.** |
| `MoverArchivosOneDrive.ps1` | ❌ **NO** | Mueve archivos al OneDrive |
| `ExportarLocker.ps1` | ❌ **NO** | Exporta datos de SQL a los EXPORT_*.txt |
| `ConfigurarTareaOcultaVBS.ps1` | ❌ **NO** | Configura la tarea programada (ya está hecho, no volver a tocar) |
| `EjecutarMonitoreoOculto.vbs` | ❌ **NO** | Wrapper que lanza PowerShell sin ventana visible |

## Ficheros autogenerados — NO tocar manualmente

- **`HistorialCompleto.csv`** — Lo escribe `MonitoreoLockerTiempoReal.ps1` cada vez que detecta un movimiento en el locker. Es la fuente de datos del dashboard. **No modificar a mano.**
- **`UltimoEventoProcesado.txt`** — Marcador con el timestamp del último evento de la tabla Eventos procesado. Lo usa v2.0 para saber dónde continuar. **No modificar a mano.**
- **`EstadoAnterior.json`** — Lo usa `MonitoreoLockerTiempoReal.ps1` para comparar el estado actual con el anterior y detectar cambios (backward compatibility). **No modificar a mano.**
- **`DashboardLocker.html`** — Lo genera `GenerarDashboard.ps1` automáticamente. **No modificar a mano.**
- **`EXPORT_*.txt`** — Los genera `ExportarLocker.ps1` exportando desde SQL. Se ejecuta manualmente cuando hay que actualizar el mapa de códigos.

## Data Flow (v2.0 - Activo desde 2026-04-21)

```
SQL Server (Actum_GHI)
  └─ Tabla Eventos (Evento=10000 = usuario identificado)
       └─ MonitoreoLockerTiempoReal.ps1 v2.0 (every 1 min via Scheduled Task → VBS)
            ├─ Lee UltimoEventoProcesado.txt (marcador)
            ├─ Query: SELECT * FROM Eventos WHERE Evento=10000 AND FechaHora > @marcador
            ├─ State tracking: determina Extracción/Devolución por estado previo
            ├─ Appends to HistorialCompleto.csv (delimiter: ;, UTF-8)
            ├─ Actualiza UltimoEventoProcesado.txt
            ├─ Health check: OneDrive corriendo?
            └─ SIEMPRE llama a: . "C:\ACTUM\GenerarDashboard.ps1"
                 └─ Reads CSV + SQL (Caja) → builds DashboardLocker.html → OneDrive sync
```

**Ventaja v2.0:** CERO pérdida de datos. Aunque el PC se apague 24 horas, al volver a encender recupera TODOS los eventos de la tabla Eventos.

## State Mapping (ACTUM database values)

- `Consigna.Estado = 2` → "Libre" → logged as `Accion = "Devolución"`
- `Consigna.Estado = 4` → "Ocupada" → logged as `Accion = "Extracción"`
- `Consigna.EstadoPuerta = 2` → "Cerrada", else "Abierta"

## EXPORT_Cajas.txt Structure (key for Código column)

The file `C:\ACTUM\EXPORT_Cajas.txt` has TWO sections separated by a blank line:

**Section 1 — Instruments/Boxes:**
```
Codigo,CodigoCliente,Descripcion,...
1,M-001,Nivel Optico / LeicaNA730Plus / 2201660,...
2,C-002,Cámara Termográfica / TESTO 872 / 87262826812,...
11,L-010,Pinza amp. 1500A / FLUKE 393 / 59260351WS,...
```

**Section 2 — Consignas (lockers):**
```
Codigo,CodigoCliente,Bloque,Fila,Columna,Caja_Codigo,...
1,01,...,1,...   ← consigna "01" holds box Codigo=1 (M-001)
2,02,...,2,...   ← consigna "02" holds box Codigo=2 (C-002)
11,11,...,11,... ← consigna "11" holds box Codigo=11 (L-010)
```

**Lookup logic — CONFIRMED WORKING (2026-02-19):**
- Section 2 (consignas) is EMPTY in the real file — only section 1 has data
- The Consigna number in HistorialCompleto.csv maps DIRECTLY to Codigo in section 1
- IMPORTANT: CSV stores consignas with leading zeros (`"01"`, `"09"`) but EXPORT_Cajas has no zeros (`"1"`, `"9"`)
- Fix: `$consignaKey = "$([int]$mov.Consigna)"` strips the leading zero before lookup
- Consigna `"100"` is a system event — always filter it out with `Where-Object { $_.Consigna -ne '100' }`

## UTF-8 / Tildes Solution (CONFIRMED WORKING ✅)

**Problem:** PowerShell 5.1 reads `.ps1` files as ANSI/Windows-1252 by default, so Spanish characters (á, é, ó, ú, ñ, etc.) inside heredocs (`@"...`"@`) get corrupted when written to HTML.

**Solution applied and confirmed working:**
1. Use **HTML entities** for ALL accented characters inside heredocs:
   - `á` → `&aacute;`, `é` → `&eacute;`, `ó` → `&oacute;`, `ú` → `&uacute;`
   - `Á` → `&Aacute;`, `É` → `&Eacute;`, `Ó` → `&Oacute;`, `Ú` → `&Uacute;`
   - `ñ` → `&ntilde;`, `Nº` → `N&ordm;`
2. Save the `.ps1` with **UTF-8 WITH BOM** (`New-Object System.Text.UTF8Encoding $true`)
3. The `<meta charset="UTF-8">` tag ensures the browser renders entities correctly

> ⚠️ NEVER use raw Spanish characters inside `@"...`"@` heredocs in PowerShell scripts. Always use HTML entities.

## Tab Navigation (CONFIRMED WORKING ✅)

Los tabs usan **CSS puro con radio buttons** — sin JavaScript. Esto es necesario porque OneDrive web (SharePoint preview) bloquea JS.

```html
<input type="radio" class="tab-inputs" id="tab-estado" name="tabs" checked>
<input type="radio" class="tab-inputs" id="tab-historial" name="tabs">
<div class="tabs-nav">
    <label class="tab-label" for="tab-estado">Estado Instrumentos</label>
    <label class="tab-label" for="tab-historial">Historial Movimientos</label>
</div>
```

El CSS activa el tab seleccionado con `#tab-estado:checked ~ .tab-content.content-estado { display: block; }`.

> ⚠️ NUNCA usar JavaScript `onclick` para los tabs — OneDrive web lo bloquea. Siempre CSS puro.

> ⚠️ NUNCA usar `@import url('https://fonts.googleapis.com/...')` — OneDrive web bloquea CDN externos. Usar fuentes del sistema: `-apple-system, BlinkMacSystemFont, 'Segoe UI', Arial, sans-serif`

## Known Issues / Pending

**1. Date format mismatch (MEDIUM)**
`GenerarDashboard.ps1` parses dates with `'MM/dd/yyyy HH:mm:ss'` (US format). The locker machine may write dates in Spanish format (`dd/MM/yyyy`). A format mismatch silently corrupts `Sort-Object`. If instrument states look wrong, check the date format in the real CSV first.

**2. Consignas con cero inicial (✅ RESUELTO)**
El CSV almacena consignas como `"01"`, `"02"` etc. pero EXPORT_Cajas.txt usa `"1"`, `"2"` sin cero. Fix aplicado: `$consignaKey = "$([int]$mov.Consigna)"` convierte `"01"` → `"1"` antes del lookup.

**3. Tarea programada falla por SQL (MITIGADO)**
`MonitoreoLockerTiempoReal.ps1` a veces falla al conectar con SQL Server (error 2147946720) y no llega a llamar a `GenerarDashboard.ps1`. Solución: se creó una segunda tarea `GenerarDashboardHTML` que ejecuta **solo** `GenerarDashboard.ps1` cada minuto como respaldo.

## Useful Manual Commands (run on locker machine)

```powershell
# Regenerate dashboard from existing CSV
cd C:\ACTUM
.\GenerarDashboard.ps1

# Check first 5 lines of CSV to see real data format
Get-Content "C:\Users\User\OneDrive - GHI HORNOS INDUSTRIALES S.L\LockerACTUM\HistorialCompleto.csv" | Select-Object -First 5

# Check scheduled task status
Get-ScheduledTaskInfo -TaskName "MonitoreoLockerTiempoReal" | Select-Object LastRunTime, LastTaskResult, NextRunTime

# Verify script version in production
Get-Item "C:\ACTUM\GenerarDashboard.ps1" | Select-Object Length, LastWriteTime
Get-Content "C:\ACTUM\GenerarDashboard.ps1" | Select-Object -First 5

# Check HTML was generated correctly
Get-Item "C:\Users\User\OneDrive - GHI HORNOS INDUSTRIALES S.L\LockerACTUM\DashboardLocker.html" | Select-Object Length, LastWriteTime
```

## Corporate Identity

- Primary red: `#C31E2E`
- Logo: embedded SVG (inline in dashboard heredoc, no external file dependency)
- Font: **system fonts only** (`-apple-system, BlinkMacSystemFont, 'Segoe UI', Arial, sans-serif`) — NO Google Fonts CDN
- Design: dark glassmorphism, gradient badges (green=Disponible, red=En uso/Extracción)
- Stats grid: always 4 columns (`grid-template-columns: repeat(4, 1fr)`)
- Table headers: `white-space: nowrap` to prevent wrapping
- NO `setTimeout` auto-reload — el HTML lo actualiza la tarea programada cada minuto

## Estado Actual del Dashboard (confirmado 2026-02-24) ✅

Características CONFIRMADAS funcionando en producción:

| Característica | Estado | Detalle |
|---|---|---|
| Diseño dark glassmorphism | ✅ | Fondo negro/gris, tarjetas translucidas |
| Logo GHI SVG inline | ✅ | Sin dependencias externas |
| 4 stat cards en una fila | ✅ | `repeat(4, 1fr)` |
| Pestaña Estado Instrumentos | ✅ | CSS puro, radio buttons |
| Pestaña Historial Movimientos | ✅ | CSS puro, radio buttons |
| Tildes y caracteres españoles | ✅ | HTML entities en heredoc + normalización Accion |
| Columna Código (L-010, T-001...) | ✅ | Desde SQL tabla `Caja` (auto-actualizado) |
| Columna Instrumento / Modelo / Nº serie | ✅ | Desde `Caja.Descripcion` en SQL |
| Consignas con cero (01, 09...) | ✅ | Fix `[int]` para strip leading zero |
| Filtro consigna 100 (sistema) | ✅ | `Where-Object { $_.Consigna -ne '100' }` |
| Badges verde/rojo estado | ✅ | Disponible / En uso por [nombre] |
| "En uso por " sin nombre | ✅ | Muestra solo "En uso" si usuario vacío |
| Duplicados en historial | ✅ | Group-Object sin Accion (encoding distinto) |
| Tildes en Extracción/Devolución | ✅ | Normalizado a `Extracci&oacute;n` / `Devoluci&oacute;n` |
| Actualización automática | ✅ | Doble tarea: MonitoreoLocker + GenerarDashboardHTML |
| Auto-actualización desde ACTUM EPI Visor | ✅ | SQL directo cada minuto — sin EXPORT manual |
| Compatible OneDrive web | ✅ | Sin JS, sin CDN externos |
| Nº Consigna en una línea | ✅ | `white-space: nowrap` en `th` |

---

## MonitoreoLockerTiempoReal.ps1 v2.0 — Sistema basado en Eventos (2026-04-21)

**Cambio arquitectónico mayor:** El script ahora usa la tabla `Eventos` de SQL como fuente de datos, en lugar de comparar estados. Esto garantiza **CERO pérdida de datos**.

### Tabla Eventos (SQL)

| Campo | Descripción |
|---|---|
| `Codigo` | GUID único del evento |
| `FechaHora` | Timestamp exacto del evento |
| `Evento` | Tipo: 3=puerta cierra, 4=puerta abre, **10000=usuario identificado** |
| `Consigna_Codigo` | Número de consigna |
| `Caja_Codigo` | Número de caja/instrumento |
| `Usuario_Codigo` | Código del usuario (solo en Evento=10000) |
| `Tratado` | Flag de procesado (no lo usamos) |

**Total eventos:** 168.760 desde 26/10/2024 hasta la actualidad.

### Cómo funciona v2.0

1. **Lee `UltimoEventoProcesado.txt`** → timestamp del último evento procesado
2. **Query SQL:** `SELECT * FROM Eventos WHERE Evento=10000 AND FechaHora > @ultimo`
3. **State tracking:** Para cada evento, determina si es Extracción o Devolución según el estado previo de la consigna:
   - Estado Ocupada (4) → acceso → Libre (2) = **Extracción**
   - Estado Libre (2) → acceso → Ocupada (4) = **Devolución**
4. **Añade al CSV** con el mismo formato que v1.0
5. **Actualiza `UltimoEventoProcesado.txt`**

### Ventajas vs v1.0

| Característica | v1.0 (antiguo) | v2.0 (nuevo) |
|---|---|---|
| Fuente de datos | Comparar `FechaHoraUltimaApertura` | **Tabla Eventos** |
| Pérdida de datos | Sí (si alguien saca+devuelve durante parada) | **No** |
| Recuperación tras apagado | Solo estado final | **TODOS los eventos** |
| Health check OneDrive | No | **Sí** |
| Fallback si SQL falla | No | **Sí** (usa método v1.0) |

### Fichero de marcador

**`UltimoEventoProcesado.txt`** - Contiene el timestamp del último evento procesado (formato: `yyyy-MM-dd HH:mm:ss`)

- En primera ejecución: lee última línea del CSV, resta 10 segundos (ventana de solapamiento)
- En ejecuciones normales: solo procesa eventos nuevos desde el marcador
- Se actualiza después de cada ejecución

### Fallback automático

Si la tabla `Eventos` no está disponible o la query falla, el script **automáticamente usa el método v1.0** (comparación de estados) como fallback. Esto garantiza que el sistema nunca se pare completamente.

---

## DashboardAdmin.html — Panel Interno (creado 2026-02-26)

Dashboard paralelo al DashboardLocker.html, para uso exclusivo de los administradores del sistema.
**NO interfiere con el DashboardLocker.html ni con ningún script existente.**

### Archivos nuevos:
| Archivo | Ruta dev | Ruta locker |
|---|---|---|
| `GenerarDashboardAdmin.ps1` | `GHI/GenerarDashboardAdmin.ps1` | `C:\ACTUM\GenerarDashboardAdmin.ps1` |
| `EjecutarAdminOculto.vbs` | `GHI-Locker-Dashboard/tareas-programadas/EjecutarAdminOculto.vbs` | `C:\ACTUM\EjecutarAdminOculto.vbs` |
| `DashboardAdmin.html` | (generado automáticamente) | `C:\Users\User\OneDrive...\LockerACTUM\DashboardAdmin.html` |

### Estructura del dashboard:
- **Pestaña 1 — Registro de Uso**: Recuento de usos por instrumento desde CSV, ordenado de mayor a menor. Barras visuales de uso, ranking con medallas (oro/plata/bronce), fecha último uso.
- **Pestaña 2 — Calibración**: Todos los instrumentos con FechaCaducidad de SQL. Badge CADUCADO/URGENTE(<30d)/PRÓXIMO(<90d)/CALIBRADO/SIN FECHA. Barra de progreso de días restantes. Ordenado por urgencia.
- **Pestaña 3 — Usuarios**: Lista completa desde SQL tabla Usuario. Columnas: `CodigoCliente` (código visible tipo "0001"), `UID` (PIN de acceso al locker), `Nombre`, `Apellidos`, tipo de acceso (SAT/Estándar). Ordenado por CodigoCliente.

### Banner de alerta automático:
Si hay instrumentos caducados o urgentes, aparece un banner rojo en la parte superior indicándolo.

### Tarea programada para el Admin Dashboard:
```powershell
# Ejecutar como admin en el locker para crear la tarea:
$accion = New-ScheduledTaskAction -Execute "wscript.exe" -Argument "`"C:\ACTUM\EjecutarAdminOculto.vbs`""
$trigger = New-ScheduledTaskTrigger -Once -At (Get-Date) -RepetitionInterval (New-TimeSpan -Minutes 1) -RepetitionDuration ([System.TimeSpan]::FromDays(3650))
$principal = New-ScheduledTaskPrincipal -UserId $env:USERNAME -LogonType Interactive -RunLevel Limited
$settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -Hidden -StartWhenAvailable -ExecutionTimeLimit (New-TimeSpan -Minutes 5)
Register-ScheduledTask -TaskName "GenerarDashboardAdmin" -Action $accion -Trigger $trigger -Principal $principal -Settings $settings
```
> Nota: se actualiza cada 1 min, igual que el DashboardLocker principal.

### Pasos de despliegue (estado 2026-03-10):
1. ✅ Copiar `GenerarDashboardAdmin.ps1` al locker como `C:\ACTUM\GenerarDashboardAdmin.ps1`
2. ✅ Copiar `EjecutarAdminOculto.vbs` al locker como `C:\ACTUM\EjecutarAdminOculto.vbs`
3. ✅ Ejecutar el script para generar el HTML inicial: `cd C:\ACTUM; .\GenerarDashboardAdmin.ps1`
4. ✅ Verificar que `DashboardAdmin.html` aparece en `C:\Users\User\OneDrive...\LockerACTUM\` — CONFIRMADO FUNCIONANDO
5. ✅ **COMPLETADO 2026-03-10**: Tarea programada `GenerarDashboardAdmin` creada — State: Ready, NextRunTime cada 1 min

### Columnas SQL confirmadas — Tabla `Usuario` (2026-02-26)

> ⚠️ IMPORTANTE: Los nombres reales difieren de lo esperado:

| Columna SQL real | Lo que muestra | Ejemplo |
|---|---|---|
| `CodigoCliente` | Código visible en ACTUM EPI Visor | `0001`, `0002` |
| `UID` | PIN de acceso al locker (lo que el usuario teclea) | `71102524`, `79002926` |
| `Nombre` | Nombre del usuario | `RAUL V.` |
| `Apellidos` | Apellidos | `VILLASANTE` |
| `AccesoConsignasRestringidas` | `True` = SAT (acceso total) | |
| `Codigo` | ID interno numérico (1, 2, 3...) — NO usar para mostrar | |

**NUNCA usar `Pin` — esa columna NO existe. El PIN es `UID`.**
**NUNCA usar `Codigo` para el código visible — usar `CodigoCliente`.**

## Resumen de Sesión — 2026-02-26 (tarde)

### Todo lo completado en esta sesión:

**1. DashboardAdmin.html — CREADO Y FUNCIONANDO EN PRODUCCIÓN ✅**
- Generado por `GenerarDashboardAdmin.ps1` en `C:\ACTUM\`
- HTML en `C:\Users\User\OneDrive...\LockerACTUM\DashboardAdmin.html`
- Pestaña 1 (Registro de Uso) ✅ funcionando
- Pestaña 2 (Calibración) ✅ funcionando
- Pestaña 3 (Usuarios) ✅ funcionando tras fix de columnas SQL

**2. Fix columnas SQL Usuarios (bug crítico resuelto)**
- `Pin` → renombrado a `UID` (nombre real en la tabla)
- `Codigo` → renombrado a `CodigoCliente` (para el código visible tipo "0001")
- Ordenado por `CodigoCliente` (igual que ACTUM EPI Visor)

**3. Intervalo tarea programada — cambiado a 1 minuto**
- Antes estaba configurado a 5 min → ahora 1 min (igual que DashboardLocker)

**4. VBS wrapper `EjecutarAdminOculto.vbs` — copiado al locker ✅**

### Estado final sistema completo (2026-02-26):
| Componente | Estado | Notas |
|---|---|---|
| `MonitoreoLockerTiempoReal` | ✅ Corriendo | Interactive (User), cada 1 min |
| `GenerarDashboard.ps1` + `DashboardLocker.html` | ✅ Producción | Sin tocar |
| `ActualizarExcel.ps1` | ✅ Corriendo | SYSTEM, cada 5 min |
| `GenerarDashboardAdmin.ps1` + `DashboardAdmin.html` | ✅ Funcionando | HTML generado OK |
| Tarea `GenerarDashboardAdmin` (auto-refresh) | ⏳ PENDIENTE | Crear en próxima sesión |

### Lo que queda por hacer (próxima sesión):
1. **Crear la tarea programada** `GenerarDashboardAdmin` en el locker (ejecutar como admin):
```powershell
$accion = New-ScheduledTaskAction -Execute "wscript.exe" -Argument "`"C:\ACTUM\EjecutarAdminOculto.vbs`""
$trigger = New-ScheduledTaskTrigger -Once -At (Get-Date) -RepetitionInterval (New-TimeSpan -Minutes 1) -RepetitionDuration ([System.TimeSpan]::FromDays(3650))
$principal = New-ScheduledTaskPrincipal -UserId $env:USERNAME -LogonType Interactive -RunLevel Limited
$settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -Hidden -StartWhenAvailable -ExecutionTimeLimit (New-TimeSpan -Minutes 5)
Register-ScheduledTask -TaskName "GenerarDashboardAdmin" -Action $accion -Trigger $trigger -Principal $principal -Settings $settings
```

---

## Tareas Pendientes / Posibles Mejoras Futuras

Lista de mejoras a implementar en próximas sesiones:

**DashboardLocker (público):**
- [ ] Ordenar la tabla por Estado (En uso primero, luego Disponible)
- [ ] Añadir buscador/filtro en la tabla de historial
- [ ] Mostrar fecha de último uso de cada instrumento en la tabla de estado
- [ ] Añadir columna "Días en uso" para instrumentos no devueltos

**DashboardAdmin (interno):**
- [ ] Añadir gráfico de uso por usuario (quién usa más el locker)
- [ ] Añadir línea de tendencia de movimientos por semana/mes
- [ ] Filtro de calibración por departamento (si se añade esa columna en SQL)

## Resumen de Sesión — 2026-02-24

### Todo lo completado en esta sesión:

**1. Fix tildes en Historial Movimientos**
- Problema: CSV tenía entradas con encoding roto → `"DevoluciÃ³n"` / `"ExtracciÃ³n"`
- Solución: normalizar siempre el valor de `Accion` a HTML entities en el render:
  ```powershell
  $accionTexto = if ($mov.Accion -like '*Extracci*') { 'Extracci&oacute;n' } elseif ($mov.Accion -like '*Devoluci*') { 'Devoluci&oacute;n' } else { $mov.Accion }
  ```

**2. Fix filas duplicadas en Historial**
- Problema: mismo evento aparecía dos veces con distinto encoding de `Accion` → `Group-Object` los trataba como diferentes
- Solución: quitar `Accion` del `Group-Object` key:
  ```powershell
  Group-Object FechaHoraApertura, Usuario, Consigna  # sin Accion
  ```

**3. Columna renombrada a "Instrumento / Modelo / Nº serie"**
- El campo `Caja.Descripcion` ya viene en ese formato desde SQL (`"Nivel Optico / LeicaNA730Plus / 2201660"`)

**4. Fix "En uso por " sin nombre**
- Si `Usuario` o `Apellidos` están vacíos, muestra `"En uso"` en vez de `"En uso por "`
- Fix aplicado en dos sitios: construcción del objeto y render HTML

**5. Integración SQL directa — GRAN MEJORA**
- `GenerarDashboard.ps1` ahora lee directamente de la tabla `Caja` de SQL Server:
  ```sql
  SELECT Codigo, CodigoCliente, Descripcion, FechaCaducidad FROM Caja
  ```
- `Caja.Codigo` = número de consigna (clave de enlace con el CSV de historial)
- Fallback automático a `EXPORT_Cajas.txt` si SQL no disponible
- `FechaCaducidad` se lee y almacena en los objetos (para uso futuro en HTML de calibración)

**6. Auto-actualización sin EXPORT manual**
- Cualquier cambio en ACTUM EPI Visor (nuevo instrumento, descripción, fecha caducidad...) se refleja en el dashboard en < 1 minuto
- Ya NO necesario hacer export desde ACTUM EPI Visor para actualizar el dashboard

### Estructura tabla SQL Caja (confirmada 2026-02-24):
| Columna SQL | Uso |
|---|---|
| `Codigo` | = Nº Consigna (clave de enlace) |
| `CodigoCliente` | Código GHI (M-001, L-010...) |
| `Descripcion` | "Instrumento / Modelo / Nº serie" (formato ya correcto) |
| `FechaCaducidad` | Fecha caducidad calibración (para futuro HTML) |
| `Foto` | Bytes PNG — ignorar |

### Estado final del sistema (2026-02-24):
| Script | En locker | Funciona | Fuente de datos |
|---|---|---|---|
| `MonitoreoLockerTiempoReal.ps1` | ✅ | ✅ Cada 1 min | SQL → CSV |
| `GenerarDashboard.ps1` | ✅ | ✅ Cada 1 min (VBS) | SQL (Caja) + CSV (Historial) |
| `ActualizarExcel.ps1` | ✅ | ✅ Cada 5 min (VBS) | CSV (Historial) + Excel |

## Resumen de Sesión — 2026-02-19

### Todo lo completado en esta sesión:

**1. Fix columna Código (L-010, T-001...)**
- Problema: `consignasMap` (sección 2 de EXPORT_Cajas.txt) estaba vacía en el locker
- Solución: el número de Consigna del CSV mapea DIRECTAMENTE al Codigo de sección 1
- `$mapaCodigos[$campos[0].Trim()] = $campos[1].Trim()` — directo, sin sección 2

**2. Fix consignas con cero inicial (01, 09...)**
- Problema: CSV guarda `"01"` pero EXPORT_Cajas.txt tiene `"1"` sin cero
- Solución: `$consignaKey = "$([int]$mov.Consigna)"` — convierte `"01"` → `"1"` antes del lookup

**3. Fix "Nº Consigna" en dos líneas**
- Añadido `white-space: nowrap` a todos los `th` de la tabla

**4. Tarea programada `GenerarDashboardHTML` (respaldo anti-fallos SQL)**
- Si `MonitoreoLockerTiempoReal` falla por SQL, el HTML igualmente se regenera cada minuto
- Usaba `-WindowStyle Hidden` que NO ocultaba la ventana → reconfigurada con VBS wrapper

**5. Ventana PowerShell visible cada minuto — RESUELTO**
- `GenerarDashboardHTML` rehecha con `EjecutarDashboardOculto.vbs` (parámetro `0` = 100% oculto)
- Patrón VBS documentado para todas las tareas futuras

**6. Excel de instrumentos — COMPLETADO**
- `ActualizarExcel.ps1` creado y desplegado en `C:\ACTUM\`
- ImportExcel v7.8.10 instalado en ruta no estándar (OneDrive\Documentos\WindowsPowerShell\Modules)
- Fix: `$excel.Save(); $excel.Dispose()` en vez de `Close-ExcelPackage -Save` (falla en v7.8.10)
- Tarea `ActualizarExcelLocker` creada via `EjecutarExcelOculto.vbs`, cada 5 minutos
- Actualiza: col A (UBICACIÓN) y col K (Estado CALIBRADO/CADUCADO)

### Estado final del sistema (2026-02-19 13:10):
| Script | En locker | Funciona |
|---|---|---|
| `MonitoreoLockerTiempoReal.ps1` | ✅ | ✅ Cada 1 min |
| `GenerarDashboard.ps1` | ✅ | ✅ Cada 1 min (VBS) |
| `ActualizarExcel.ps1` | ✅ | ✅ Cada 5 min (VBS) |
| `ExportarLocker.ps1` | ✅ | Manual (cuando cambia el ACTUM) |


## Tareas Programadas en el Locker (2026-02-19)

| Tarea | Qué ejecuta | Frecuencia | Propósito |
|---|---|---|---|
| `MonitoreoLockerTiempoReal` | `EjecutarMonitoreoOculto.vbs` → `MonitoreoLockerTiempoReal.ps1` | Cada 1 min | SQL → CSV → HTML |
| `GenerarDashboardHTML` | `EjecutarDashboardOculto.vbs` → `GenerarDashboard.ps1` | Cada 1 min | Respaldo: HTML siempre actualizado |
| `ActualizarExcelLocker` | `EjecutarExcelOculto.vbs` → `ActualizarExcel.ps1` | Cada 5 min | Actualiza UBICACIÓN y Estado en Excel |

## Cómo hacer tareas programadas 100% invisibles (SIN ventana PowerShell)

> ⚠️ CRÍTICO: Nunca crear tareas que llamen directamente a `powershell.exe` con `-File`. Aunque se use `-WindowStyle Hidden`, Windows a veces muestra la ventana igualmente. La solución correcta es SIEMPRE usar un wrapper VBS.

### Patrón correcto (3 pasos):

**Paso 1 — Crear el VBS wrapper** (hacer invisible la ejecución):
```powershell
Set-Content -Path "C:\ACTUM\EjecutarXXXOculto.vbs" -Value 'CreateObject("WScript.Shell").Run "powershell.exe -WindowStyle Hidden -NonInteractive -ExecutionPolicy Bypass -File ""C:\ACTUM\NombreScript.ps1""", 0, False'
```
El `0` en `.Run` es el parámetro clave — significa "ventana completamente oculta".

**Paso 2 — Crear la tarea apuntando al VBS** (no al .ps1 directamente):
```powershell
$accion = New-ScheduledTaskAction -Execute "wscript.exe" -Argument "`"C:\ACTUM\EjecutarXXXOculto.vbs`""
$trigger = New-ScheduledTaskTrigger -Once -At (Get-Date) -RepetitionInterval (New-TimeSpan -Minutes 1) -RepetitionDuration ([System.TimeSpan]::FromDays(3650))
$principal = New-ScheduledTaskPrincipal -UserId $env:USERNAME -LogonType Interactive -RunLevel Limited
$settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -Hidden -StartWhenAvailable -ExecutionTimeLimit (New-TimeSpan -Minutes 5)
Register-ScheduledTask -TaskName "NombreTarea" -Action $accion -Trigger $trigger -Principal $principal -Settings $settings
```

**Paso 3 — Verificar:**
```powershell
Get-ScheduledTask -TaskName "NombreTarea" | Select-Object TaskName, State
```

### Archivos VBS en C:\ACTUM (confirmados funcionando):
| Archivo VBS | Script que lanza |
|---|---|
| `EjecutarMonitoreoOculto.vbs` | `MonitoreoLockerTiempoReal.ps1` |
| `EjecutarDashboardOculto.vbs` | `GenerarDashboard.ps1` |
| `EjecutarExcelOculto.vbs` | `ActualizarExcel.ps1` |

## Excel de Instrumentos — ✅ RESUELTO (2026-02-19)

**Archivo:** `00.Intrumentos_Locker (1).xlsx`
- En locker (User): `C:\Users\User\OneDrive - GHI HORNOS INDUSTRIALES S.L\00.Intrumentos_Locker (1).xlsx`
- En dev (ialopez): `c:\Users\ialopez\OneDrive - GHI HORNOS INDUSTRIALES S.L\LOCKER INSTRUMENTACIÓN\00.Intrumentos_Locker (1).xlsx`

**Script:** `C:\ACTUM\ActualizarExcel.ps1` — actualiza cada 5 min via tarea `ActualizarExcelLocker`

**Qué actualiza automáticamente:**
- Columna **A (UBICACIÓN)**: `Disponible` o `En uso por [nombre]` según estado del locker
- Columna **K (Estado)**: `CALIBRADO` o `CADUCADO` comparando Fecha caducidad (col I) con hoy

**Detalles técnicos importantes:**
- ImportExcel v7.8.10 instalado en ruta NO estándar: `C:\Users\User\OneDrive...\Documentos\WindowsPowerShell\Modules\ImportExcel\7.8.10\`
- El script lo busca en rutas alternativas automáticamente si `Import-Module ImportExcel` falla
- NO usar `Close-ExcelPackage -Save` — en v7.8.10 falla. Usar `$excel.Save(); $excel.Dispose()`
- Datos empiezan en **fila 3**. CONSIGNA formato: `"Consigna - 1"` → extraer número con regex

**Estructura del Excel (confirmada):**
| Col | Contenido |
|-----|-----------|
| A | UBICACIÓN (auto-actualizada) |
| B | CONSIGNA (formato: "Consigna - 1") |
| C | DEPARTAMENTO |
| D | CODIGO GHI (M-001, L-010...) |
| E | DESCRIPCIÓN |
| F | NUMERO DE SERIE |
| G | MODELO |
| H | Fecha calibración |
| I | Fecha caducidad |
| J | EMP (Error máximo permitido) |
| K | Estado (auto-actualizado: CALIBRADO/CADUCADO) |
| L | EMPRESA |

**Archivo:** `00.Intrumentos_Locker (1).xlsx`
- En dev (ialopez): `c:\Users\ialopez\OneDrive - GHI HORNOS INDUSTRIALES S.L\LOCKER INSTRUMENTACIÓN\00.Intrumentos_Locker (1).xlsx`
- En locker (User): `C:\Users\User\OneDrive - GHI HORNOS INDUSTRIALES S.L\00.Intrumentos_Locker (1).xlsx`

**Script creado:** `ActualizarExcel.ps1` en `C:\ACTUM\` (ya pasado al locker)

**Qué hace el script (listo, solo falta el módulo):**
- Columna **A (UBICACIÓN)**: actualiza a `Disponible` o `En uso por [nombre]` según el estado del locker
- Columna **K (Estado)**: actualiza a `CALIBRADO` o `CADUCADO` comparando Fecha caducidad (col I) con hoy

**Estructura del Excel (confirmada):**
| Col | Contenido |
|-----|-----------|
| A | UBICACIÓN (LOCKER, PRODUCCION, SAT, En uso por...) |
| B | CONSIGNA (formato: "Consigna - 1", "Consigna - 2"...) |
| C | DEPARTAMENTO |
| D | CODIGO GHI (M-001, L-010, T-001...) |
| E | DESCRIPCIÓN |
| F | NUMERO DE SERIE |
| G | MODELO |
| H | Fecha calibración |
| I | Fecha caducidad |
| J | EMP (Error máximo permitido) |
| K | Estado (CALIBRADO / CADUCADO) |
| L | EMPRESA |

**Datos empiezan en fila 3** (filas 1-2 son título/cabecera).
**CONSIGNA col B** usa formato "Consigna - N" → extraer número con regex `Consigna\s*-\s*(\d+)`.

**Problema bloqueante:** El locker no puede instalar el módulo `ImportExcel` de PowerShell Gallery.
- Se intentó: `[Net.ServicePointManager]::SecurityProtocol = Tls12` + NuGet + `Install-Module ImportExcel -Scope CurrentUser -Force`
- NuGet se instaló (v2.8.5.208) pero `ImportExcel` no se descargó
- **Posible solución futura:** Descargar el módulo en dev (ialopez) y copiarlo manualmente al locker vía OneDrive:
  ```powershell
  # En ialopez: guardar el módulo en una carpeta
  Save-Module -Name ImportExcel -Path "C:\Users\ialopez\OneDrive - GHI HORNOS INDUSTRIALES S.L\LOCKER INSTRUMENTACIÓN\ImportExcel_module"
  # En locker: importar desde esa ruta
  Import-Module "C:\Users\User\OneDrive - GHI HORNOS INDUSTRIALES S.L\LOCKER INSTRUMENTACION\ImportExcel_module\ImportExcel\*\ImportExcel.psd1"
  ```

---

## Evaluación de Sostenibilidad del Sistema (2026-02-24) ✅

### Componentes 100% sólidos y permanentes:

| Componente | Por qué es permanente |
|---|---|
| **Tildes** (Extracción/Devolución) | Fix a nivel de código — siempre escribe HTML entities, ignora encoding del CSV |
| **Auto-actualización de instrumentos** | Lectura SQL directa cada minuto — sin EXPORT manual ni pasos intermedios |
| **Compatibilidad OneDrive web** | HTML puro con CSS, sin JS, sin CDN externos — no puede romperse |
| **Deduplicación historial** | Group-Object por fecha+usuario+consigna (sin Accion) — robusto ante cualquier encoding |
| **Tabla Eventos como fuente** | **v2.0**: Recupera TODOS los eventos aunque el PC se apague horas |
| **Health check OneDrive** | **v2.0**: Auto-restart si el proceso se cae |

### Las dependencias del sistema (post v2.0):

| Riesgo | Probabilidad | Impacto si falla | ¿Cubierto? |
|---|---|---|---|
| **SQL Server apagado** (GHI-TAQUILLAS\SQLEXPRESS) | Baja | No se registran eventos nuevos | ⚠️ No hay solución técnica |
| **PC locker se apaga / cierra sesión** | Media | **v2.0**: Recupera TODO al volver | ✅ **RESUELTO** |
| **OneDrive sin conexión** | Baja | HTML se actualiza en local pero no en web | ⚠️ Requiere intervención manual |
| **Expiración contraseña Windows** | Media (cada 50 días) | OneDrive pierde sesión | ⚠️ Requiere login manual (IT) |

### v2.0: Sistema tolerante a fallos

**Antes (v1.0):** Si el PC se apagaba y alguien sacó+devolvió un instrumento, esos movimientos se perdían (solo se veía el estado final).

**Ahora (v2.0):** La tabla `Eventos` registra CADA apertura/cierre con timestamp. Aunque el PC esté apagado 3 días, al volver se recuperan los 3 días completos de eventos.

### ⚠️ PUNTO MÁS DÉBIL: Tareas programadas como Interactive

Las tareas están configuradas con `LogonType Interactive`, lo que significa que **solo corren si hay una sesión de usuario activa** en el PC del locker. Si el PC reinicia o cierra sesión sin que nadie entre, las actualizaciones se detienen.

**Solución definitiva (requiere admin, una sola vez):**
```powershell
# Ejecutar como ADMINISTRADOR en el locker:
$principal = New-ScheduledTaskPrincipal -UserId "SYSTEM" -LogonType ServiceAccount -RunLevel Highest
Set-ScheduledTask -TaskName "GenerarDashboardHTML"       -Principal $principal
Set-ScheduledTask -TaskName "MonitoreoLockerTiempoReal"  -Principal $principal
Set-ScheduledTask -TaskName "ActualizarExcelLocker"      -Principal $principal
```
Con esto las tareas corren 24/7 como servicio del sistema, sin necesitar sesión activa.

### Escalabilidad a largo plazo:

- **CSV creciente:** ~10 mov/día × 365 = ~3.650 entradas/año. El script agrupa y filtra eficientemente. Sin problemas durante al menos 10 años.
- **Mantenimiento necesario:** Prácticamente cero en condiciones normales.
- **Cambios que SÍ requieren intervención futura:**
  - Cambio de nombre/IP del servidor SQL → actualizar `$connStr` en `GenerarDashboard.ps1` y `MonitoreoLockerTiempoReal.ps1`
  - Cambio de ruta de OneDrive en el locker → actualizar `$carpetaUser` al inicio de cada script

---

## Estructura SQL confirmada (2026-02-24) — Para referencia futura

### Tabla `Caja` — Instrumentos del locker
| Columna | Descripción |
|---|---|
| `Codigo` | = Nº Consigna (clave de enlace con historial CSV) |
| `CodigoCliente` | Código GHI (M-001, L-010...) |
| `Descripcion` | "Instrumento / Modelo / Nº serie" (ya formateado correctamente) |
| `FechaCaducidad` | Fecha caducidad calibración (para futuro HTML de calibración) |
| `Foto` | PNG en bytes — ignorar |

### Tabla `Consigna` — Configuración de cada hueco del locker
| Columna | Descripción |
|---|---|
| `Codigo` | Número de consigna |
| `Caja_Codigo` | Instrumento asignado (FK a Caja) |
| `Restringida` | `True` = solo SAT; `False` = accesible a todos |
| `Activa` | Si la consigna está operativa |
| `Usuario_Codigo` | Usuario que tiene el instrumento ahora |

### Tabla `Usuario` — Usuarios del sistema
| Columna | Descripción |
|---|---|
| `AccesoConsignasRestringidas` | `True` = SAT (puede abrir todas); `False` = solo consignas no restringidas |
| `Consigna_Codigo` | Consigna habitualmente asignada al usuario |
| `Nombre`, `Apellidos` | Identificación del usuario |

---

## Resumen Final del Proyecto (estado a 2026-04-21)

El sistema de monitoreo del locker ACTUM está **completamente operativo y automatizado**:

1. **`MonitoreoLockerTiempoReal.ps1` v2.0** (cada 1 min) → Lee tabla Eventos → Escribe CSV → Genera HTML
2. **`GenerarDashboard.ps1`** (cada 1 min, tarea de respaldo) → Lee SQL (Caja) + CSV → Genera HTML
3. **`ActualizarExcel.ps1`** (cada 5 min) → Lee CSV → Actualiza Excel de instrumentos

**Sin intervención manual necesaria para:**
- ✅ Nuevas extracciones/devoluciones → aparecen en < 1 min
- ✅ Cambios de instrumento en ACTUM EPI Visor → aparecen en < 1 min
- ✅ Instrumentos nuevos o eliminados → aparecen en < 1 min
- ✅ Tildes y caracteres especiales → siempre correctos
- ✅ Estado del Excel de instrumentos → actualizado cada 5 min
- ✅ **Recuperación tras apagado** → TODOS los eventos se recuperan al volver (v2.0)

**Estado final confirmado (2026-04-21 — PRODUCCION):**
| Componente | Estado | Notas |
|---|---|---|
| MonitoreoLockerTiempoReal | ✅ v2.0 Interactive (User) via VBS | Oculto, cada 1 min, basado en tabla Eventos |
| GenerarDashboardHTML | ✅ ACTIVA — Interactive (User) | Oculto, cada 1 min |
| GenerarDashboardAdmin | ✅ Interactive (User) via VBS | Oculto, cada 1 min |
| ActualizarExcel | ✅ SYSTEM | OK |
| Auto-login PC locker | ✅ Configurado | AutoAdminLogon=1, User, sin contrasena |
| Watchdog tarea | ✅ Configurado | Reinicia 3 veces si falla |
| Tildes/Codigos | ✅ CORRECTO | M-001, C-002... OK. Tildes OK |
| **Tabla Eventos** | ✅ **Activa** | 168.760 eventos desde oct 2024 |
| **UltimoEventoProcesado.txt** | ✅ **Activo** | Marcador para tracking |

---

## Resumen de Sesión — 2026-04-21 (v2.0 Eventos + v2.1 Dedup + Refresh UX)

### Cambio arquitectónico mayor implementado ✅

**1. MonitoreoLockerTiempoReal.ps1 v2.0**
- **Sistema basado en tabla Eventos** en lugar de comparación de estados
- Query: `SELECT * FROM Eventos WHERE Evento IN (10000, 10001) AND FechaHora > @ultimo`
- **CERO pérdida de datos:** recupera TODO aunque el PC se apague horas
- **State tracking:** alternancia desde estado actual de SQL (fuente de verdad)
- **Health check OneDrive:** auto-restart si el proceso se cae
- **Fallback automático:** si Eventos falla, usa método v1.0

**2. Archivo de marcador**
- `UltimoEventoProcesado.txt` → timestamp del último evento procesado
- En primera ejecución: lee CSV, resta 10 segundos (solapamiento)
- Se actualiza tras cada ejecución

**3. Backup de versión anterior**
- `MonitoreoLockerTiempoReal_v1_BACKUP.ps1` guardado por si hay problemas

**Primer despliegue exitoso:**
- 39 eventos recuperados en primera ejecución
- Dashboard funciona correctamente

### v2.1 — Deduplicación por clusters (tarde 2026-04-21)

**Problema detectado tras el primer despliegue v2.0:**
- El CSV tenía pares Extracción+Devolución del mismo usuario a 5-15s (artefactos)
- Faltaban consignas que estaban en uso según SQL (solo 8 aparecían en vez de 12)
- Causa raíz: ACTUM emite **dos tipos de eventos por interacción**: tipo `10000` y tipo `10001`

**Descubrimiento clave — Tipos de Evento en SQL:**

| Evento | Total | Significado |
|---|---|---|
| 1 | 12.329 | ? |
| 2 | 11.716 | ? |
| 3 | 140.131 | Puerta cierra |
| 4 | 2.317 | Puerta abre |
| 1002 | 1.451 | ? |
| 3001-3004 | ~385 | ? |
| 3601-3602 | ~48 | ? |
| 4001 | 15 | ? |
| **10000** | **270** | **Identificación usuario (tipo A)** |
| **10001** | **261** | **Identificación usuario (tipo B)** |

**Ambos eventos 10000 y 10001 son identificaciones válidas.** ACTUM emite 1 de cada para la misma acción física (usuario se identifica, abre, cierra). Antes solo leíamos 10000 → perdíamos ~50% de eventos, en especial los de usuarios SAT.

**Solución implementada:**
1. Query actualizada a `Evento IN (10000, 10001)`
2. Deduplicación por clusters:
   - Cluster = eventos consecutivos con mismo Consigna + mismo Usuario + `<= 60s` de separación
   - Regla: cluster → conservar solo 1 evento (el más antiguo)
   - Alternancia desde estado actual de SQL asigna la acción correcta (Extracción/Devolución)

**4. ReconstruirHistorial.ps1 (nuevo script, ejecutar UNA VEZ)**
- Lee TODA la tabla Eventos (10000+10001) desde oct 2024
- Aplica dedup por clusters
- Procesa por consigna desde el estado actual de SQL hacia atrás (alternancia reversed)
- Reescribe `HistorialCompleto.csv` desde cero con 473 movimientos limpios
- Actualiza `UltimoEventoProcesado.txt`
- Útil también en el futuro si se detectan anomalías

**Resultado final del despliegue v2.1 (2026-04-21):**
| Métrica | Antes | Ahora |
|---|---|---|
| Eventos CSV | ~270 (solo 10000) | **473** (10000+10001, deduplicado) |
| Consignas en uso detectadas | 8 | **12** (coincide con SQL) |
| Artefactos duplicados | Abundantes | 58 eliminados automáticamente |
| Pérdida de datos | Si PC apagado | **Cero** |
| Usuarios SAT registrados | No | **Sí** (eventos 10001) |

### v2.1 UX — Dashboard Refresh + Tab persistente

**Mejoras en GenerarDashboard.ps1:**

**1. Refresh sincronizado al `:00`**
- Antes: refresh a 60s desde carga (ej: 11:32:13, 11:33:13...)
- Ahora: refresh al segundo 00 exacto (ej: 11:33:00, 11:34:00...)
- Implementación: script JS inline calcula `(60 - segundos_actuales) * 1000 - ms` y programa `location.reload()`
- Fallback: meta refresh `content="75"` (por si JS bloqueado en OneDrive web)

**2. Pestaña persistente al refresh**
- Antes: cualquier refresh volvía a "Estado Instrumentos" (default)
- Ahora: persiste via hash URL (`#estado` / `#historial`)
- Al cambiar tab → `history.replaceState` actualiza el hash
- Al cargar → lee hash y marca el radio correspondiente

**3. JS ubicado antes de `</body>`** — el script es inline, sin dependencias externas, sin onclick handlers (compatible con OneDrive web)

### Estructura SQL confirmada en esta sesión (2026-04-21)

**Tabla `Eventos`:**
| Campo | Tipo | Descripción |
|---|---|---|
| `Codigo` | uniqueidentifier | GUID |
| `FechaHora` | datetime | Timestamp evento |
| `Evento` | bigint | Tipo (ver tabla arriba) |
| `ElectronicaCU_Codigo` | bigint | |
| `ElectronicaCU_Rele` | bigint | |
| `Consigna_Codigo` | bigint | FK a Consigna |
| `Caja_Codigo` | bigint | FK a Caja |
| `Herramienta_Codigo` | bigint | |
| `Usuario_Codigo` | bigint | FK a Usuario (solo en 10000/10001) |
| `Tratado` | bit | No se usa |

**Tabla `Usuario` — usuarios SAT identificados (`AccesoConsignasRestringidas = True`):**
- 8 IKER L. LASSO · 59 AITOR U. ULIBARRI · 60 JOSE G. G. GONZALEZ GONZALEZ · 62 IÑIGO A. ALONSO · otros

### Reglas permanentes aprendidas

1. **Filtro SQL correcto para identificaciones:** `Evento IN (10000, 10001)`, NO solo `10000`
2. **Dedup por clusters** siempre que se procesen eventos nuevos (umbral `<= 60s`, mismo usuario + misma consigna)
3. **Cluster → conservar 1 evento** (el más antiguo) + alternancia desde SQL
4. **Estado actual SQL = fuente de verdad** para Disponible/En uso
5. **El CSV histórico se puede reconstruir en cualquier momento** con `ReconstruirHistorial.ps1` — útil si se detectan anomalías

### Tema pendiente (sesión futura)

- **Contraseña Windows User del locker** — IT estudia si permitir `PasswordNeverExpires` para que OneDrive no pierda sesión cada 50 días. Prueba inicial con `wmic useraccount` se revirtió (espera decisión IT).

---

## Resumen de Sesion — 2026-03-03

### Problemas encontrados y resueltos:

**1. Dashboard sin actualizar 11 horas**
- Causa raiz: **OneDrive.exe no estaba corriendo** en el locker. Nadie lo habia iniciado tras un reinicio.
- Fix: `Start-Process "C:\Program Files\Microsoft OneDrive\OneDrive.exe"`
- Fix permanente: clave de registro `HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run` con valor `"C:\Program Files\Microsoft OneDrive\OneDrive.exe"`

**2. Tarea GenerarDashboardHTML desactivada (de antes)**
- Fue desactivada manualmente el 24/02/2026
- Fix: `Enable-ScheduledTask -TaskName "GenerarDashboardHTML"` (requiere admin)
- Ahora tiene watchdog: GenerarDashboard.ps1 la reactiva automaticamente si la detecta Disabled

**3. SQL devolvía 0 instrumentos**
- Causa: `JOIN Consigna+Caja WHERE Activa=1` devolvía 0 filas
- Fix: fallback automatico a `SELECT FROM Caja` si el JOIN da 0 resultados

**4. Tildes rotas (caracteres ◆) — CRITICO**
- Causa raiz: `GenerarDashboardHTML` corria como **SYSTEM** (no como User)
- Con SYSTEM, `Integrated Security=True` falla en SQL Express → usa EXPORT_Cajas.txt como fallback
- **EXPORT_Cajas.txt tiene encoding roto** (caracteres como `C□mara Termogr□fica`)
- Fix: cambiar el principal de la tarea a User (Interactive):
  ```powershell
  Set-ScheduledTask -TaskName "GenerarDashboardHTML" -Principal (New-ScheduledTaskPrincipal -UserId "User" -LogonType Interactive -RunLevel Limited)
  ```
- ⚠️ REGLA PERMANENTE: `GenerarDashboardHTML` SIEMPRE debe correr como `User` (Interactive), NUNCA como SYSTEM

**5. Transferencia de scripts via TeamViewer/Notepad — PROBLEMA GRAVE**
- El heredoc `@"..."@` se rompe al pegar scripts largos via clipboard/TeamViewer
- Sintoma: "454 lines" en vez de 688, error "Falta la cadena en el terminador"
- Solucion correcta: enviar el archivo .ps1 directamente (Teams/email), NO copiar-pegar

### Estado del sistema (2026-03-03 09:52):
| Componente | Estado |
|---|---|
| MonitoreoLockerTiempoReal | ✅ User/Interactive, cada 1 min |
| GenerarDashboardHTML | ✅ User/Interactive (cambiado de SYSTEM), cada 1 min |
| ActualizarExcelLocker | ✅ SYSTEM, cada 5 min |
| OneDrive | ✅ Corriendo + auto-arranque configurado en registro |
| Dashboard HTML | ✅ Actualizandose cada minuto, tildes correctas |
| Meta-refresh navegador | ✅ Cada 60 segundos (`<meta http-equiv="refresh" content="60">`) |
| Watchdog tarea | ✅ En GenerarDashboard.ps1 — reactiva GenerarDashboardHTML si Disabled |

### ⚠️ REGLAS CRITICAS para evitar recurrencia:
1. **GenerarDashboardHTML SIEMPRE como User** — NUNCA como SYSTEM (SQL falla)
2. **OneDrive DEBE estar corriendo** — si el PC reinicia y OneDrive no arranca, nada se sincroniza
3. **EXPORT_Cajas.txt tiene encoding roto** — NO es un fallback fiable; mantener SQL funcionando
4. **No pegar scripts largos por Notepad/TeamViewer** — enviar el .ps1 como archivo



**Comportamiento ante reinicio del locker:**
1. PC arranca → entra automáticamente como `User` (auto-login)
2. Al iniciar sesión → Task Scheduler arranca `MonitoreoLockerTiempoReal`
3. Cada 1 minuto → CSV actualizado + HTML generado (oculto, sin ventana)
4. Dashboard disponible en OneDrive en < 1 minuto

**Sistema presentado y aceptado por GHI el 2026-02-25. En producción.**

---

## 🚨 GUÍA RÁPIDA DE ERRORES COMUNES

### Error 1: No sincroniza a OneDrive (la hora no cambia)

**Síntoma:** El HTML local se genera bien pero desde tu PC/web no se actualiza.

**Diagnóstico:**
```powershell
# En el locker:
Get-Item "C:\Users\User\OneDrive...\LockerACTUM\DashboardLocker.html" | Select-Object LastWriteTime
```
Si la hora es reciente → el problema es OneDrive.

**Solución:**
1. Reiniciar OneDrive:
```powershell
Stop-Process -Name OneDrive -Force
Stop-Process -Name "OneDrive.Sync.Service" -Force
Start-Sleep -Seconds 5
Start-Process "C:\Program Files\Microsoft OneDrive\OneDrive.exe"
```
2. Si sigue sin funcionar, la sesión ha expirado → iniciar sesión manualmente en OneDrive desde el navegador.

---

### Error 2: Tarea programada no se ejecuta

**Síntoma:** El HTML no se genera, la hora no cambia.

**Diagnóstico:**
```powershell
Get-ScheduledTaskInfo -TaskName "MonitoreoLockerTiempoReal" | Select-Object LastRunTime, LastTaskResult
```
- LastTaskResult = 0 → OK
- LastTaskResult = otro número → error

**Solución:**
```powershell
# Ver tarea
Get-ScheduledTask -TaskName "MonitoreoLockerTiempoReal" | Select-Object State
# Si está Disabled:
Enable-ScheduledTask -TaskName "MonitoreoLockerTiempoReal"
```

---

### Error 3: Cambio de contraseña del PC

**Síntoma:** OneDrive deja de sincronizar después de cambiar la contraseña del locker.

**Solución:**
1. Iniciar sesión en el locker con la nueva contraseña
2. Arrancar OneDrive si no está corriendo
3. Verificar sincronización

---

###Error 4: HTML con tildes rotos (caracteres raros)

**Síntoma:** En lugar de "Cámara" aparece "C□mara".

**Solución:**
```powershell
# Ejecutar el parche:
powershell -ExecutionPolicy Bypass -File "C:\ACTUM\PatchFuncionTildes.ps1"
```

---

### Checklist rápido de verificación:
```powershell
# 1. Estado tareas
Get-ScheduledTask | Where-Object {$_.TaskName -like "*Locker*" -or $_.TaskName -like "*Dashboard*"} | Select-Object TaskName, State

# 2. Última ejecución
Get-ScheduledTaskInfo -TaskName "MonitoreoLockerTiempoReal" | Select-Object LastRunTime, LastTaskResult

# 3. HTML actualizado
Get-Item "C:\Users\User\OneDrive...\LockerACTUM\DashboardLocker.html" | Select-Object LastWriteTime

# 4. OneDrive corriendo
Get-Process OneDrive -ErrorAction SilentlyContinue
```

**Arquitectura de tareas definitiva (NO cambiar a SYSTEM):**
- `MonitoreoLockerTiempoReal` → **Interactive (User)** — necesita SQL (Integrated Security) y escritura a `C:\Users\User\OneDrive...`
- `GenerarDashboardHTML` → **DISABLED** — redundante, MonitoreoLockerTiempoReal ya genera HTML
- `ActualizarExcel` → puede ser SYSTEM si no usa OneDrive user path

**Fix SQL aplicado (JOIN Consigna+Caja):**
```sql
-- ANTES (bug): clave = Caja.Codigo (no coincidia con Consigna.CodigoCliente del CSV)
SELECT Codigo, CodigoCliente, Descripcion, FechaCaducidad FROM Caja

-- DESPUES (correcto): clave = Consigna.CodigoCliente (mismo que CSV)
SELECT C.CodigoCliente AS ConsignaCod, Cj.CodigoCliente AS CodigoGHI, Cj.Descripcion, Cj.FechaCaducidad
FROM Consigna C JOIN Caja Cj ON C.Caja_Codigo = Cj.Codigo WHERE C.Activa = 1
```

---

## 🚨 REGLA PERMANENTE: Encoding en scripts PowerShell (2026-02-24)

### El problema que ocurrió:
Se escribieron caracteres literales (á, é, ó, ñ...) dentro del código fuente `.ps1`.
Cuando el script se copia al locker (Windows con CP1252 por defecto), esos caracteres UTF-8 se corrompen → el script falla con errores de sintaxis como `Token '&' inesperado`.

### La regla que SIEMPRE hay que seguir:
> **NUNCA usar caracteres especiales (tildes, ñ, etc.) literales en el código fuente PowerShell.**
> Usar SIEMPRE `[char]0xXX` en su lugar.

| Carácter | Usar en PS código |
|---|---|
| á | `[char]0xE1` |
| é | `[char]0xE9` |
| í | `[char]0xED` |
| ó | `[char]0xF3` |
| ú | `[char]0xFA` |
| ñ | `[char]0xF1` |
| ü | `[char]0xFC` |
| Á | `[char]0xC1` |
| É | `[char]0xC9` |
| Í | `[char]0xCD` |
| Ó | `[char]0xD3` |
| Ú | `[char]0xDA` |
| Ñ | `[char]0xD1` |
| Ü | `[char]0xDC` |

### Ejemplo correcto:
```powershell
# MAL: usa literal -> se rompe al copiar
$text = $text -replace 'á', '&aacute;'

# BIEN: usa codigo hex -> funciona en cualquier sistema
$text = $text -replace [char]0xE1, '&aacute;'
```

### Si vuelve a ocurrir el error en el locker:
Usar el script de parche `PatchFuncionTildes.ps1` (en carpeta GHI):
```powershell
# Pegar contenido en PowerShell del locker (via TeamViewer si hace falta)
# O ejecutar desde C:\ACTUM si se ha copiado ahi
powershell -ExecutionPolicy Bypass -File "C:\ACTUM\PatchFuncionTildes.ps1"
```
El parche detecta y reemplaza la función automáticamente, verifica sintaxis y ejecuta el dashboard.

### Dónde se aplica la función actualmente:
- `GenerarDashboard.ps1` → función `ConvertTo-HtmlEntities` al inicio del script
- Se aplica a `Caja.Descripcion` al construir `$estadoInstrumentos`
- Si se añaden nuevos campos de texto desde SQL, aplicar también: `ConvertTo-HtmlEntities $campo`

---

## 🛡️ SOLUCIÓN DEFINITIVA DE ENCODING (2026-02-24) — LA ÚLTIMA LÍNEA DE DEFENSA

### El problema raíz descubierto:
Dos fuentes diferentes generaban dos filas del mismo instrumento con encoding diferente:
- `C&aacute;mara` → ConvertTo-HtmlEntities funcionó correctamente
- `C&#225;mara` → el char Unicode 'á' escapó a ConvertTo-HtmlEntities y lo capturó la red de seguridad

Ambos son idénticos en HTML (`&aacute;` = `&#225;` = 'á'). El navegador los muestra igual.

### La solución: conversión ASCII final antes de escribir el HTML

Al final de `GenerarDashboard.ps1`, en lugar de escribir UTF-8, se convierte el HTML a ASCII puro:

```powershell
# Antes (roto):
$utf8WithBOM = New-Object System.Text.UTF8Encoding $true
[System.IO.File]::WriteAllText($archivoHTML, $html, $utf8WithBOM)

# Ahora (infalible):
$htmlFinal = [System.Text.RegularExpressions.Regex]::Replace($html, '[^\x00-\x7F]', {
    param($match)
    return '&#' + [int][char]$match.Value + ';'
})
$ascii = New-Object System.Text.ASCIIEncoding
[System.IO.File]::WriteAllText($archivoHTML, $htmlFinal, $ascii)
```

### Por qué es infalible:
- Convierte **cualquier carácter > ASCII** (> 127) a entidad numérica `&#NNN;`
- No depende de ConvertTo-HtmlEntities ni del encoding del sistema
- No depende de si SQL conecta o usa fallback CSV
- No depende del account (SYSTEM o interactivo) que ejecuta la tarea
- El fichero resultante es **ASCII puro** — imposible corrupciones de encoding

### Si hay que volver a parchearlo en el locker (TeamViewer):
```powershell
$archivo = "C:\ACTUM\GenerarDashboard.ps1"
$contenido = Get-Content $archivo -Raw -Encoding UTF8
$viejo = '$utf8WithBOM = New-Object System.Text.UTF8Encoding $true
[System.IO.File]::WriteAllText($archivoHTML, $html, $utf8WithBOM)'
$nuevo = @'
$htmlFinal = [System.Text.RegularExpressions.Regex]::Replace($html, '[^\x00-\x7F]', {
    param($match)
    return '&#' + [int][char]$match.Value + ';'
})
$ascii = New-Object System.Text.ASCIIEncoding
[System.IO.File]::WriteAllText($archivoHTML, $htmlFinal, $ascii)
'@
$utf8NoBOM = New-Object System.Text.UTF8Encoding $false
[System.IO.File]::WriteAllText($archivo, $contenido.Replace($viejo, $nuevo), $utf8NoBOM)
Write-Host "Parche aplicado" -ForegroundColor Green
& "C:\ACTUM\GenerarDashboard.ps1"
```

### Verificación tras el parche:
```powershell
# Debe mostrar &aacute; o &#225; — NUNCA bytes rotos
Select-String "mara" "C:\Users\User\OneDrive - GHI HORNOS INDUSTRIALES S.L\LockerACTUM\DashboardLocker.html" |
    Select-Object -First 3 -ExpandProperty Line
```

---

## Resumen de Sesion — 2026-03-25

### Problema: Dashboard sin actualizar desde el 24/03 a las 8h

**Sintoma:** El HTML se generaba correctamente en el locker cada minuto (LastWriteTime actualizado), pero el dashboard no se actualizaba en OneDrive web.

**Causa raiz REAL (confirmada):** La cuenta de OneDrive (`fabricacion1@ghifurnaces.com`) cambio de contrasena. El cliente OneDrive del locker perdio la sesion y dejo de sincronizar archivos al cloud — aunque el proceso OneDrive.exe seguia corriendo, estaba desautenticado.

**Señales que apuntan a este problema:**
- El HTML se actualiza localmente (LastWriteTime reciente en el locker)
- Pero el archivo en OneDrive web muestra version antigua
- OneDrive.exe corre pero con PID desde hace dias (no reciente)
- El icono de OneDrive en la bandeja muestra error de cuenta

**Fix:** Abrir OneDrive en el locker → iniciar sesion con la nueva contrasena → sync se reanuda en segundos.

**Lo que NO era el problema:**
- Tareas programadas: OK
- SQL Server: conexion OK (32 instrumentos)
- Generacion del HTML: OK
- Auto-login: correcto

### Acciones realizadas:

**1. ActualizarExcelLocker estaba Disabled**
- Fix: `Enable-ScheduledTask -TaskName "ActualizarExcelLocker"`

**2. Regeneracion manual del dashboard**
- `cd C:\ACTUM; .\GenerarDashboard.ps1`
- Resultado: SQL OK, 32 instrumentos, 210 movimientos, HTML generado

**3. Fix preventivo — Tareas robustas ante reinicios**
Aplicado `-StartWhenAvailable` y reintentos a las 3 tareas criticas:
```powershell
$settings = New-ScheduledTaskSettingsSet `
    -AllowStartIfOnBatteries `
    -DontStopIfGoingOnBatteries `
    -Hidden `
    -StartWhenAvailable `
    -ExecutionTimeLimit (New-TimeSpan -Minutes 5) `
    -RestartCount 3 `
    -RestartInterval (New-TimeSpan -Minutes 1)

Set-ScheduledTask -TaskName "MonitoreoLockerTiempoReal" -Settings $settings
Set-ScheduledTask -TaskName "GenerarDashboardHTML" -Settings $settings
Set-ScheduledTask -TaskName "GenerarDashboardAdmin" -Settings $settings
```

**Por que es el fix correcto:** `-StartWhenAvailable` hace que si el PC se reinicia y la tarea "pierde" su ventana horaria, Windows la lanza automaticamente en cuanto el sistema esta listo. Sin esto, la tarea queda en `Ready` pero nunca se dispara hasta el proximo ciclo programado (que puede no llegar si el trigger perdio su referencia).

### Estado del sistema (2026-03-25 08:00):
| Componente | Estado | Notas |
|---|---|---|
| MonitoreoLockerTiempoReal | ✅ Ready | StartWhenAvailable + 3 reintentos |
| GenerarDashboardHTML | ✅ Ready | StartWhenAvailable + 3 reintentos |
| GenerarDashboardAdmin | ✅ Ready | StartWhenAvailable + 3 reintentos |
| ActualizarExcelLocker | ✅ Ready | Reactivada |
| OneDrive | ✅ Corriendo | Desde 21/03 |
| SQL | ✅ OK | 32 instrumentos |
| Dashboard HTML | ✅ Actualizandose cada minuto | Confirmado 7:56:10 |

### Diagnostico rapido (para futuras incidencias):
```powershell
# 1. Estado de tareas
Get-ScheduledTask -TaskName "MonitoreoLockerTiempoReal","GenerarDashboardHTML","ActualizarExcelLocker","GenerarDashboardAdmin" | Select-Object TaskName, State

# 2. Ultima ejecucion y resultado
Get-ScheduledTaskInfo -TaskName "MonitoreoLockerTiempoReal" | Select-Object LastRunTime, LastTaskResult, NextRunTime
Get-ScheduledTaskInfo -TaskName "GenerarDashboardHTML" | Select-Object LastRunTime, LastTaskResult, NextRunTime

# 3. OneDrive corriendo?
Get-Process -Name "OneDrive" -ErrorAction SilentlyContinue | Select-Object Name, StartTime

# 4. Cuando se actualizo el HTML por ultima vez?
Get-Item "C:\Users\User\OneDrive - GHI HORNOS INDUSTRIALES S.L\LockerACTUM\DashboardLocker.html" | Select-Object LastWriteTime

# 5. Fix rapido si todo esta parado:
Enable-ScheduledTask -TaskName "ActualizarExcelLocker"
cd C:\ACTUM; .\GenerarDashboard.ps1

# 6. CRITICO: Verificar si OneDrive esta sincronizando
# Si el HTML se actualiza localmente pero NO en OneDrive web:
# → Probable cambio de contrasena de la cuenta OneDrive
# → Solucion: abrir OneDrive en el locker e iniciar sesion de nuevo
# → O restart del PC (arranca OneDrive limpio y pide credenciales)
```

## ⚠️ CAUSA FRECUENTE DE FALLO: Cambio de contraseña OneDrive

Si el dashboard deja de actualizarse en OneDrive web pero el archivo local SÍ está actualizado (LastWriteTime reciente):

**Diagnóstico confirmado:** archivos en OneDrive web muestran fecha antigua ("el martes a las 2:00") mientras el HTML local se genera cada minuto.

**Fix — dos pasos:**
1. Click en el icono OneDrive (bandeja sistema) → si pide credenciales, introducirlas
2. **Si el icono muestra "azul girando" pero sigue sin sincronizar:** ir a **OneDrive → Configuración (engranaje) → pestaña Cuenta → re-introducir credenciales** explicitamente ahí
3. En 1-2 minutos el sync se reanuda

> ⚠️ El icono "azul girando" NO garantiza que la cuenta corporativa esté autenticada. OneDrive puede girar por otros motivos mientras la cuenta `fabricacion1@ghifurnaces.com` está desconectada. Verificar siempre en la pestaña Cuenta de Configuración.

> ⚠️ Cada vez que se cambie la contraseña de `fabricacion1@ghifurnaces.com` (o la cuenta OneDrive del locker), hay que volver a autenticar OneDrive en el PC del locker.

### ⚠️ Estado "Buscando cambios..." atascado tras re-autenticacion

**Sintoma:** Tras introducir la nueva contrasena en OneDrive, el icono queda en "Buscando cambios..." durante mas de 10 minutos y no sube nada al cloud. El explorador de archivos muestra los archivos actualizados localmente pero OneDrive web sigue mostrando la version antigua.

**Causa:** OneDrive se queda colgado en el proceso de reconexion tras el cambio de credenciales.

**Fix — SIN necesidad de PowerShell ni IA:**
1. Conectarse al locker (TeamViewer o en persona)
2. Click derecho en el icono de OneDrive en la bandeja del sistema (esquina inferior derecha)
3. **Cerrar OneDrive**
4. Buscar "OneDrive" en el menu inicio y ejecutarlo
5. Esperar 2 minutos → el dashboard web se actualiza solo

### Contrasena de `fabricacion1` — quien se encarga

> **ACTUALIZADO 2026-09-08: no hay respaldo. Imanolia lo hace sola.**
> El companero que cubria el locker durante el verano de 2026 ya no esta. No hay segunda persona con
> TeamViewer ni punto de contacto alternativo. Toda intervencion en el locker la hace ella directamente.
> **Consecuencia operativa:** si nadie mira, nadie se entera — es el mismo agujero que dejo el PC 19 dias
> muerto en agosto. Refuerza el argumento de la alerta de sistema caido (pendiente 8).

- Contrasena cambiada el **10/06/2026**, con OneDrive re-autenticado ese mismo dia (tokens frescos)
- Caducidades siguientes: ~22/07/2026 y ~26/08/2026 — **la de agosto no consta re-autenticada**
- **Accion cuando caduca:** entrar al locker, meter la contrasena nueva en OneDrive
  (icono → Configuracion → pestana **Cuenta**), y cerrar/reabrir OneDrive si se queda en "Buscando cambios..."
- **Comportamiento de tokens OAuth:** cambiar la contrasena NO rompe OneDrive inmediatamente — el cliente
  sigue funcionando hasta que el refresh token caduca (dias/semanas). Por eso conviene re-autenticar cuanto
  antes tras el cambio, para tener tokens frescos.

---

## Resumen de Sesion — 2026-04-30 (Bug marcador formato fecha)

### Problema: Sin movimientos registrados desde el 17/04/2026

**Sintoma:** El CSV terminaba el 17/04/2026 07:48:14 (ALVARO T. TREPIANA). La tarea corria cada minuto (LastTaskResult=0) pero no registraba nada. `UltimoEventoProcesado.txt` no existia en `C:\ACTUM\` (buscamos en la ruta incorrecta).

**Causa raiz — Bug de formato en `MonitoreoLockerTiempoReal.ps1`:**
- Cuando el script procesaba movimientos nuevos, guardaba el marcador en formato `MM/dd/yyyy HH:mm:ss` (formato del CSV, ej: `04/17/2026 07:48:14`)
- En la siguiente ejecucion, intentaba leerlo como `yyyy-MM-dd HH:mm:ss` → fallo de parseo
- Caia al fallback: leia el CSV, calculaba el marcador desde la ultima linea (07:48:04), buscaba en SQL → el dedup cross-batch eliminaba ese evento (ya estaba en el CSV) → 0 movimientos nuevos
- Sobreescribia el marcador con `(Get-Date)` → desde ese momento el marcador era "ahora"
- En adelante: siempre buscaba desde "ahora", nunca encontraba eventos pasados

**Nota:** El marcador real esta en `C:\Users\User\OneDrive...\LockerACTUM\UltimoEventoProcesado.txt`, NO en `C:\ACTUM\`. Error de diagnostico inicial al buscar en la ruta equivocada.

**Fix aplicado en `MonitoreoLockerTiempoReal.ps1` (linea 385-387):**
```powershell
# ANTES (bug): guardaba en formato MM/dd/yyyy HH:mm:ss
$ultimoTimestamp = ($nuevosMovimientos | Sort-Object FechaHoraApertura | Select-Object -Last 1).FechaHoraApertura
[System.IO.File]::WriteAllText($archivoMarcador, $ultimoTimestamp, $utf8NoBOM)

# DESPUES (correcto): siempre formato yyyy-MM-dd HH:mm:ss
$ultimaFechaObj = [DateTime]::ParseExact(
    ($nuevosMovimientos | Sort-Object FechaHoraApertura | Select-Object -Last 1).FechaHoraApertura,
    'MM/dd/yyyy HH:mm:ss', $null)
[System.IO.File]::WriteAllText($archivoMarcador, $ultimaFechaObj.ToString('yyyy-MM-dd HH:mm:ss'), $utf8NoBOM)
```

**Recuperacion de eventos perdidos:**
- Se ejecuto `ReconstruirHistorial.ps1` con la tarea pausada (`Disable-ScheduledTask`)
- Resultado: 537 eventos SQL → 58 artefactos eliminados → 479 movimientos limpios (antes 473)
- Marcador actualizado a `2026-04-30 09:45:23` en formato correcto
- 12 consignas "En uso" recuperadas correctamente

**Fix cosmético adicional en `GenerarDashboard.ps1`:**
- El historial solo mostraba `Usuario` (ej: "ALVARO T.") sin apellidos
- Fix: `$(("$($movimiento.Usuario) $($movimiento.Apellidos)").Trim())` → ahora muestra nombre completo (ej: "ALVARO T. TREPIANA")

### Regla permanente aprendida:
> **El marcador `UltimoEventoProcesado.txt` SIEMPRE debe estar en formato `yyyy-MM-dd HH:mm:ss`.**
> Esta en `C:\Users\User\OneDrive...\LockerACTUM\`, NO en `C:\ACTUM\`.
> Si el sistema deja de registrar movimientos y la tarea corre sin errores (LastTaskResult=0), comprobar el contenido y formato de ese archivo primero.

---

## Resumen de Sesion — 2026-05-14 (OneDrive sin sesion, sin perdida de datos)

### Problema: Dashboard sin actualizar desde ~06/05/2026

**Sintoma:** El dashboard no se actualizaba en OneDrive web. El HTML local SI se generaba (LastWriteTime 14/05/2026 09:02:16).

**Causa raiz:** La cuenta OneDrive (`fabricacion1@ghifurnaces.com`) cambio de contrasena (~6 mayo). El proceso OneDrive.exe seguia corriendo (desde 09/05/2026 19:10:18) pero sin sesion autenticada → no sincronizaba nada.

**Fix (paso 1):** Click en el icono de OneDrive en la bandeja del sistema → introducir nueva contraseña si aparece aviso.

**Fix (paso 2 — si el paso 1 no basta):** OneDrive puede seguir sin sincronizar aunque el proceso corra y el icono muestre "azul girando". En ese caso hay que ir a **OneDrive → Configuración (engranaje) → pestaña Cuenta → re-introducir credenciales** explicitamente. Esto fue necesario en la segunda incidencia del 14/05.

**Verificacion de datos:**
- CSV terminaba en 05/06/2026 11:25:52 (ANGEL F. FERNANDEZ, consigna 13)
- SQL: 0 eventos desde el 6/05 → nadie uso el locker en esos 8 dias
- Marcador `UltimoEventoProcesado.txt`: `2026-05-14 09:11:06` (formato correcto)
- **Sin perdida de datos** — las tareas programadas funcionaron correctamente durante toda la interrupcion

**Lo que NO era el problema:**
- Tareas programadas: OK (LastTaskResult=0, HTML generado cada minuto)
- SQL Server: OK (0 eventos nuevos, pero conexion activa)
- Marcador: formato correcto

### Nota diagnostica — Sort-Object con fechas MM/dd/yyyy

`Sort-Object FechaHoraApertura` sobre el CSV ordena **alfabeticamente**, no cronologicamente. "12/..." (diciembre) aparece despues de "05/..." (mayo), lo que puede confundir el diagnostico.

**Para ver los ultimos movimientos reales usar:**
```powershell
# Opcion 1: tail del CSV (escrito en orden cronologico)
Get-Content "C:\Users\User\OneDrive - GHI HORNOS INDUSTRIALES S.L\LockerACTUM\HistorialCompleto.csv" | Select-Object -Last 20

# Opcion 2: filtrar por ano
Import-Csv "...\HistorialCompleto.csv" -Delimiter ";" |
    Where-Object { $_.FechaHoraApertura -like "*2026*" } |
    Select-Object -Last 15 | Format-Table -AutoSize
```

### Estado del sistema (2026-05-14):
| Componente | Estado | Notas |
|---|---|---|
| MonitoreoLockerTiempoReal | ✅ Corriendo | Sin interrupcion durante el fallo de OneDrive |
| OneDrive | ✅ Autenticado | Re-autenticado manualmente 14/05 |
| CSV HistorialCompleto | ✅ Completo | Sin perdida de datos (locker no usado 06-14/05) |
| Marcador UltimoEventoProcesado | ✅ Correcto | `2026-05-14 09:11:06` formato yyyy-MM-dd |

---

## Resumen de Sesion — 2026-05-20 (Investigacion alternativas a OneDrive)

### Contexto

IT confirma que la politica de cambio de contrasena de `fabricacion1@ghifurnaces.com` cada ~50 dias **no se puede modificar**. Se investigo si existe alguna alternativa al cliente OneDrive para sincronizar el dashboard.

### Analisis de red del locker (GHI-TAQUILLAS)

| Parametro | Valor |
|---|---|
| IP | 172.16.5.40 |
| Mascara | 255.255.255.0 |
| Gateway | 172.16.5.1 |
| DNS | 8.8.8.8 / 8.8.4.4 (Google — NO corporativo) |
| Acceso internet | ✅ SI (ping 8.8.8.8 OK, 7ms) |
| Acceso servidor documental | ❌ NO |

**Por que no llega al servidor documental:**
- `\\srvdocumental\Ghihornos` → IP real: `192.168.210.250`
- El locker esta en subred `172.16.5.x`, el servidor en `192.168.210.x` — subredes distintas sin routing entre ellas
- El DNS del locker es Google (8.8.8.8), no el DNS corporativo → no resuelve nombres `.ghihornos.local`

### Alternativas investigadas

**1. Carpeta de red compartida (`\\srvdocumental\Ghihornos`)** — ❌ DESCARTADA
- No accesible desde el locker (subredes distintas)

**2. Azure Blob Storage** — ⏳ PENDIENTE (futura)
- Viable tecnicamente: locker tiene internet, script usa `Invoke-RestMethod` (sin modulos extra)
- SAS token con expiracion en 2030 — sin dependencia de contrasenas de usuario
- URL permanente y publica
- **Descartada por ahora:** GHI no tiene suscripcion Azure disponible
- **Retomar cuando tengan Azure**

**3. Microsoft Graph API con App Registration** — ⏳ PENDIENTE (futura)
- Parte de M365 que GHI ya tiene (Azure AD / Microsoft Entra ID) — sin coste adicional
- IT registra la app una vez (10 min). Autenticacion por certificado: **no caduca nunca**
- Script sube HTML a SharePoint/OneDrive con ese certificado en vez de con fabricacion1
- URL para usuarios queda exactamente igual
- **Pendiente de evaluar con IT**

**4. Servidor web en el propio locker (IIS)** — ⏳ PENDIENTE (futura)
- Script deja HTML en `C:\inetpub\wwwroot\`, gente accede por `http://172.16.5.40/DashboardLocker.html`
- Cero sincronizacion, cero cuentas que caduquen
- **Bloqueante:** no se sabe si los PCs de oficina (192.168.x.x) pueden llegar a 172.16.5.40
- **Pendiente de verificar conectividad**

### Decision

Se mantiene el sistema actual con OneDrive + fabricacion1. Cuando la contrasena caduca → re-autenticar manualmente en el locker (icono OneDrive → Configuracion → Cuenta).

Las alternativas 2, 3 y 4 quedan documentadas para retomar en el futuro.

---

## Limitacion conocida: Asignaciones administrativas en ACTUM

**Descubierto 2026-05-20** al verificar consigna 30.

`Consigna.Usuario_Codigo` en SQL puede no coincidir con el ultimo movimiento fisico registrado en la tabla `Eventos`. Esto ocurre cuando alguien asigna un usuario a una consigna directamente desde el software ACTUM EPI Visor (sin que el usuario abra el locker fisicamente). Ese tipo de asignacion NO genera entrada en `Eventos`.

**Consecuencia:** El dashboard puede mostrar un usuario diferente al que ACTUM tiene asignado.
**Impacto:** Solo afecta a quien se muestra como "En uso por X". El instrumento si aparece como EN USO. No es un bug, es una limitacion estructural.
**Solucion futura:** Leer `Consigna.Usuario_Codigo` directamente en `GenerarDashboard.ps1` para la pestana Estado, en vez de derivarlo del CSV.

---

---

## Resumen de Sesion — 2026-05-20 (Bug marcador + Reconstruccion semanal automatica)

### Problema: Movimiento no registrado en dashboard

**Sintoma:** Un movimiento real (JOSE G. G. GONZALEZ devolvio consigna 03 a las 12:42:29) aparecia en la tabla SQL `Eventos` pero no en el CSV ni en el dashboard.

**Causa raiz — Bug del marcador en `MonitoreoLockerTiempoReal.ps1`:**
```powershell
# ANTES (bug): cuando no habia eventos, se actualizaba a Get-Date
} else {
    [System.IO.File]::WriteAllText($archivoMarcador, (Get-Date).ToString('yyyy-MM-dd HH:mm:ss'), $utf8NoBOM)
}
```
El marcador avanzaba cada minuto aunque no hubiera actividad. Cuando llego el evento a las 12:42:29, el marcador ya habia pasado esa hora → el evento quedo "en el pasado" y nunca fue procesado.

**Fix aplicado en `MonitoreoLockerTiempoReal.ps1`:**
- Si no hay eventos en SQL (`$eventosEnSQL = 0`): NO actualizar el marcador — se mantiene en el ultimo evento real
- Si SQL encontro eventos pero el dedup los elimino todos (`$eventosEnSQL > 0` pero `$nuevosMovimientos = 0`): avanzar marcador al ultimo evento SQL para no reprocesarlos siempre

**Bug secundario sin diagnosticar (1a ocurrencia):**
Durante la recuperacion (marcador reseteado a 12:42:00), el script encontro 1 evento pero produjo 0 movimientos — sin mensaje de error ni de dedup. Causa exacta desconocida. Ocurrio en 2 de 487 eventos totales (0.4%). No critico pero real.

> **✅ RESUELTO 2026-06-02:** Se añadio un SAFETY NET en `MonitoreoLockerTiempoReal.ps1` (ver sesion 2026-06-02).

**Recuperacion de datos:**
1. Evento manual añadido al CSV via PowerShell
2. `ReconstruirHistorial.ps1` ejecutado → 487 movimientos limpios (2 mas que antes)
3. Marcador actualizado a `2026-05-20 12:42:29` (formato correcto)

### Tarea programada semanal: `ReconstruirCSVSemanal`

Creada como seguro definitivo contra cualquier evento perdido:
- **Cuando:** Cada lunes a las 05:00 AM
- **Que hace:** Para MonitoreoLocker (75s) → ReconstruirHistorial → GenerarDashboard → reactiva MonitoreoLocker
- **Archivos:**
  - `C:\ACTUM\ReconstruirSemanal.ps1` — script principal
  - `C:\ACTUM\EjecutarReconstruccionOculto.vbs` — wrapper invisible

**Resultado:** Cualquier movimiento perdido durante la semana queda recuperado automaticamente el lunes. Sin intervencion manual.

### Estado de tareas programadas (2026-05-20):
| Tarea | Frecuencia | Estado |
|---|---|---|
| `MonitoreoLockerTiempoReal` | Cada 1 min | ✅ Ready |
| `GenerarDashboardHTML` | Cada 1 min | ✅ Ready |
| `GenerarDashboardAdmin` | Cada 1 min | ✅ Ready |
| `ActualizarExcelLocker` | Cada 5 min | ✅ Ready |
| `ReconstruirCSVSemanal` | **Lunes 05:00** | ✅ Ready (NextRun: 25/05/2026) |

### Regla permanente: here-strings en PowerShell via TeamViewer/chat

Al pegar comandos con here-string (`@'...'@`) desde el chat, la indentacion hace que `'@` no quede en columna 0 → PowerShell entra en modo de continuacion y el bloque no se ejecuta nunca.

**Solucion:** Usar arrays en lugar de here-strings para crear contenido de archivos:
```powershell
# MAL: here-string (se rompe al pegar con indentacion)
$content = @'
linea1
linea2
'@

# BIEN: array join (funciona siempre)
$lines = 'linea1', 'linea2'
$content = $lines -join "`r`n"
```

---

## Resumen de Sesion — 2026-05-21 (Dedup 60s → 10s + Fix manual consigna 13)

### Problema: Extraccion no registrada en consigna 13

**Sintoma:** Consigna 13 (Analizador particulas / KLOTZ / AMF20707) mostraba "Disponible" en el dashboard pero el instrumento estaba fisicamente extraido por ANGEL F. FERNANDEZ.

**Secuencia real confirmada:**

| Hora | Accion | En CSV |
|---|---|---|
| 10:54:12 | ANGEL F. FERNANDEZ Extraccion | OK |
| 11:19:54 | ANGEL F. FERNANDEZ Devolucion | OK |
| 11:20:10 | ANGEL F. FERNANDEZ Extraccion | NO — perdida |

**Diagnostico:**
- SQL `Eventos`: ultimo evento consigna 13 = `05/21/2026 11:20:10`, Evento=10000, Usuario=26 (ANGEL F.)
- Gap entre ultimo CSV (11:19:54) y evento SQL (11:20:10) = **16 segundos**
- Con `$ventanaSeg = 60`: 16 < 60 → el dedup cross-batch descartaba el evento como duplicado

**Causa raiz — ventana dedup demasiado amplia:**
El dedup cross-batch agrupa como "artefacto" cualquier evento del mismo usuario + consigna dentro de `$ventanaSeg` segundos del ultimo evento en CSV. Un gap de 16 segundos era suficiente para descartarlo con ventana de 60s.

**Fix aplicado — `MonitoreoLockerTiempoReal.ps1` linea 130:**
```powershell
# ANTES:
$ventanaSeg = 60

# AHORA:
$ventanaSeg = 10
```

Con 10 segundos: los duplicados reales de ACTUM (pares 10000+10001, tipicamente < 2s) siguen eliminandose. Acciones reales con > 10s de separacion ya no se descartan. Fisicamente imposible abrir, sacar/devolver y cerrar un locker en menos de 10 segundos.

**Bug secundario confirmado (2a ocurrencia — igual que 2026-05-20):**
Con marcador reseteado a 11:20:09 y ventanaSeg=10, el evento de 11:20:10 paso el filtro dedup (sin mensaje [DEDUP]) pero `$nuevosMovimientos` quedo = 0 sin explicacion ni mensaje de error. Misma conducta que el bug documentado el 20/05. Causa exacta desconocida. Ocurrencia estimada < 1% de eventos.

> **✅ RESUELTO 2026-06-02:** Se añadio un SAFETY NET en `MonitoreoLockerTiempoReal.ps1` (ver sesion 2026-06-02).

**Fix manual del CSV (ejecutado en el locker):**
```powershell
$utf8NoBOM = New-Object System.Text.UTF8Encoding $false
$linea = "05/21/2026 11:20:10;ANGEL F.;FERNANDEZ;13;Analizador part$([char]237)culas / KLOTZ / AMF20707;Extracci$([char]243)n;Cerrada"
[System.IO.File]::AppendAllText("C:\Users\User\OneDrive - GHI HORNOS INDUSTRIALES S.L\LockerACTUM\HistorialCompleto.csv", "$linea`r`n", $utf8NoBOM)
[System.IO.File]::WriteAllText("C:\Users\User\OneDrive - GHI HORNOS INDUSTRIALES S.L\LockerACTUM\UltimoEventoProcesado.txt", "2026-05-21 11:20:10", $utf8NoBOM)
```

**Resultado:** Dashboard regenerado con 494 movimientos. Consigna 13 muestra "En uso por ANGEL F. FERNANDEZ".

**Nota:** El `ReconstruirCSVSemanal` del lunes 25/05/2026 a las 05:00 recuperara automaticamente cualquier evento perdido esta semana.

---

## Resumen de Sesion — 2026-06-04 tarde (Bug raiz resuelto: Group-Object → hashtable)

### Bug raiz de todos los eventos perdidos — RESUELTO DEFINITIVAMENTE

**Causa raiz confirmada:** `Group-Object { "$($_['Consigna_Codigo'])" }` en PASO 4 fallaba silenciosamente cuando los elementos eran `DataRow` almacenados en `List[object]`. PowerShell no puede resolver el indexer de DataRow a traves del pipeline cuando el tipo declarado es `object`. Resultado: `$porConsigna` quedaba vacio, el foreach no ejecutaba, `$nuevosMovimientos` = 0 sin ningun error visible.

El SAFETY NET no lo capturaba porque `$nuevosMovimientos` quedaba en un estado ambiguo (no exactamente 0 ni >0 en algunos casos).

**Fix aplicado en `MonitoreoLockerTiempoReal.ps1` (PASO 4):**
```powershell
# ANTES (bug):
$porConsigna = $filasLimpias | Group-Object { "$($_['Consigna_Codigo'])" }

# AHORA (correcto):
$porConsigna = @{}
foreach ($fila in $filasLimpias) {
    $k = "$([int][string]$fila['Consigna_Codigo'])"
    if (-not $porConsigna.ContainsKey($k)) { $porConsigna[$k] = [System.Collections.Generic.List[object]]::new() }
    $porConsigna[$k].Add($fila)
}
```

Mismo patron `[string]$fila['Columna']` que ya funcionaba en el SAFETY NET.

**Fix adicional:** `@()` en Sort-Object final para garantizar siempre un array:
```powershell
$nuevosMovimientos = @($nuevosMovimientos | Sort-Object { ... })
```

**Verificacion:** Devolicion consigna 28 (AITOR U. ULIBARRI, 08:17:04) registrada automaticamente tras el deploy. 516 movimientos.

### Estado del sistema (2026-06-04 tarde):
| Componente | Estado | Notas |
|---|---|---|
| MonitoreoLockerTiempoReal | ✅ v2.3 | Bug raiz PASO 4 resuelto, hashtable en lugar de Group-Object |
| CSV HistorialCompleto | ✅ 516 movimientos | |
| Tareas programadas | ✅ 5 activas (Ready) | |

---

## Resumen de Sesion — 2026-06-10 (Correccion manual usuario consignas 18 y 22)

### Problema: Consignas 18 y 22 mostraban "En uso por IKER L. LASSO" en vez de SERGIO V. VEGA

**Causa:** El ultimo movimiento registrado en el CSV para ambas consignas era una Extraccion de IKER L. LASSO (16/04/2026). En realidad quien las tenia era SERGIO V. VEGA (asignacion no registrada en Eventos SQL).

**Verificacion previa:**
- SERGIO V. VEGA confirmado en tabla Usuario: `Codigo=14, CodigoCliente=0014, Nombre=SERGIO V., Apellidos=VEGA`
- Ultimas entradas CSV consigna 18: Extraccion IKER L. LASSO 04/16/2026 11:52:41
- Ultimas entradas CSV consigna 22: Extraccion IKER L. LASSO 04/16/2026 12:44:02

**Fix aplicado — 4 lineas manuales anadidas al CSV:**
```powershell
$utf8NoBOM = New-Object System.Text.UTF8Encoding $false
$csv = "C:\Users\User\OneDrive - GHI HORNOS INDUSTRIALES S.L\LockerACTUM\HistorialCompleto.csv"
$lineas = @(
    "04/16/2026 11:53:00;IKER L.;LASSO;18;MedidorLaserpuntoderocio / DP510 / 45174428;Devoluci$([char]0xF3)n;Cerrada",
    "04/16/2026 11:53:30;SERGIO V.;VEGA;18;MedidorLaserpuntoderocio / DP510 / 45174428;Extracci$([char]0xF3)n;Cerrada",
    "04/16/2026 12:44:30;IKER L.;LASSO;22;An.gases / TESTO 340 / 63862113;Devoluci$([char]0xF3)n;Cerrada",
    "04/16/2026 12:45:00;SERGIO V.;VEGA;22;An.gases / TESTO 340 / 63862113;Extracci$([char]0xF3)n;Cerrada"
)
foreach ($linea in $lineas) { [System.IO.File]::AppendAllText($csv, "$linea`r`n", $utf8NoBOM) }
cd C:\ACTUM; .\GenerarDashboard.ps1
```

**Resultado:** 526 movimientos. Dashboard muestra "En uso por SERGIO V. VEGA" en consignas 18 y 22.

### Patron para correccion manual de usuario en una consigna

Cuando el dashboard muestra un usuario incorrecto (asignacion administrativa en ACTUM sin apertura fisica):
1. Verificar el nombre exacto en SQL: `SELECT Nombre, Apellidos FROM Usuario WHERE Nombre LIKE '%X%'`
2. Ver ultima entrada del CSV para esa consigna: `Import-Csv ... | Where-Object { $_.Consigna -eq 'N' } | Select-Object -Last 3`
3. Anadir Devolucion del usuario incorrecto + Extraccion del usuario correcto con timestamps justo despues
4. Ejecutar `.\GenerarDashboard.ps1`

### Estado del sistema (2026-06-10):
| Componente | Estado | Notas |
|---|---|---|
| MonitoreoLockerTiempoReal | ✅ v2.3 | Sin cambios |
| CSV HistorialCompleto | ✅ 526 movimientos | +4 correcciones manuales consignas 18 y 22 |
| Tareas programadas | ✅ 5 activas (Ready) | Sin cambios |

---

## Resumen de Sesion — 2026-06-11 (Quitar auto-refresh dashboard)

### Problema: el dashboard volvía al tab "Estado Instrumentos" cada minuto

**Causa:** `GenerarDashboard.ps1` incluía dos mecanismos de auto-refresh:
- `<meta http-equiv="refresh" content="75">` — recarga completa cada 75s (fallback)
- `setTimeout(function(){ location.reload(); }, ms)` — JS que recargaba al :00 exacto

OneDrive web bloquea JS → solo actuaba el meta refresh → recarga completa → tab siempre volvía al default (Estado Instrumentos). El usuario perdía el tab donde estaba cada minuto.

**Fix aplicado en `GenerarDashboard.ps1`:**
- Eliminado el `<meta http-equiv="refresh">` 
- Eliminado el `setTimeout location.reload()` del bloque JS
- Conservado el JS de persistencia de tab via hash URL (inofensivo)

### Fix adicional: formato de fecha dd/MM/yyyy (europeo)

Las fechas en el historial mostraban formato americano `MM/dd/yyyy` (ej: `06/10/2026`) en vez del europeo `dd/MM/yyyy` (ej: `10/06/2026`).

**Causa:** el CSV almacena fechas en formato `MM/dd/yyyy HH:mm:ss` (formato del locker) y se mostraban directamente sin convertir.

**Fix en linea 654 de `GenerarDashboard.ps1`** — solo afecta a la presentacion, el CSV no cambia:
```powershell
# ANTES:
$($movimiento.FechaHoraApertura)

# AHORA:
$(try { [DateTime]::ParseExact($movimiento.FechaHoraApertura,'MM/dd/yyyy HH:mm:ss',$null).ToString('dd/MM/yyyy HH:mm:ss') } catch { $movimiento.FechaHoraApertura })
```
El `catch` garantiza que si alguna fecha tiene formato inesperado, se muestra tal cual sin romper nada.

**Por que no rompe nada:** el dashboard se actualiza porque la tarea programada reescribe el archivo HTML cada minuto. El navegador no necesita auto-recargarse — cuando el usuario abre el dashboard ya ve la version mas reciente. Si quiere actualizar pulsa F5.

**Verificacion:**
```powershell
Select-String -Pattern "refresh|reload" "C:\ACTUM\GenerarDashboard.ps1"
# Solo debe aparecer el comentario: "sin auto-reload" — ningun codigo funcional
```

### Estado del sistema (2026-06-11 — ESTADO FINAL ANTES DE VACACIONES):
| Componente | Estado | Notas |
|---|---|---|
| MonitoreoLockerTiempoReal | ✅ v2.3 | Bug raiz resuelto, sin cambios |
| GenerarDashboard | ✅ Sin auto-refresh, fechas dd/MM/yyyy | Tabs quietos, formato europeo |
| CSV HistorialCompleto | ✅ 528 movimientos | |
| Tareas programadas | ✅ 5 activas (Ready) | |
| OneDrive | ✅ Autenticado | Tokens frescos desde 10/06/2026 |
| Proxima accion manual | ⏳ | Re-autenticar OneDrive al caducar la contrasena (lo hace Imanolia) |

### Inventario de archivos en el locker (2026-06-04)

**C:\ACTUM — archivos activos:**
| Archivo | Fecha | Rol |
|---|---|---|
| `MonitoreoLockerTiempoReal.ps1` | 04/06/2026 | ✅ Script principal (v2.3) |
| `GenerarDashboard.ps1` | 21/04/2026 | ✅ Genera DashboardLocker.html |
| `GenerarDashboardAdmin.ps1` | 10/03/2026 | ✅ Genera DashboardAdmin.html |
| `ReconstruirHistorial.ps1` | 21/04/2026 | ✅ Reconstruccion manual/semanal |
| `ReconstruirSemanal.ps1` | 20/05/2026 | ✅ Wrapper reconstruccion semanal |
| `ActualizarExcel.ps1` | 19/02/2026 | ✅ Actualiza Excel instrumentos |
| `EjecutarMonitoreoOculto.vbs` | 12/02/2026 | ✅ Wrapper VBS MonitoreoLocker |
| `EjecutarDashboardOculto.vbs` | 19/02/2026 | ✅ Wrapper VBS Dashboard |
| `EjecutarAdminOculto.vbs` | 26/02/2026 | ✅ Wrapper VBS DashboardAdmin |
| `EjecutarExcelOculto.vbs` | 19/02/2026 | ✅ Wrapper VBS Excel |
| `EjecutarReconstruccionOculto.vbs` | 20/05/2026 | ✅ Wrapper VBS Reconstruccion |

**Archivos inofensivos — NO tocar:**
- `UltimoEventoProcesado.txt` en C:\ACTUM — leftover de abril, el real esta en OneDrive
- `Monitoreo Locker Tiempo Real` (tarea Disabled con espacios) — tarea duplicada obsoleta
- `EXPORT_*.txt` — desactualizados (feb 2026), fallback SQL
- Backups .ps1 — historicos

---

## Resumen de Sesion — 2026-06-04 (Timeout ACTUM + tiempo tareas + fixes movimientos perdidos)

### Cambios aplicados

**1. Timeout puerta ACTUM: 20s → 60s**
- Configurado en ACTUM EPI Visor → Parámetros → "Segundos Timeout Puerta"
- Causa raiz de operaciones incompletas: el locker cortaba la sesion antes de que el usuario terminara
- Con 60s hay margen suficiente para abrir, sacar/devolver y cerrar

**2. ExecutionTimeLimit tareas: 5 min → 15 min**
- Afectaba a: `MonitoreoLockerTiempoReal`, `GenerarDashboardAdmin`, `ActualizarExcelLocker`
- Comando usado (como admin):
  ```powershell
  $ts = New-TimeSpan -Minutes 1
  $te = New-TimeSpan -Minutes 15
  $s = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -Hidden -StartWhenAvailable -ExecutionTimeLimit $te -RestartCount 3 -RestartInterval $ts
  Set-ScheduledTask -TaskName "MonitoreoLockerTiempoReal" -Settings $s
  Set-ScheduledTask -TaskName "GenerarDashboardAdmin" -Settings $s
  Set-ScheduledTask -TaskName "ActualizarExcelLocker" -Settings $s
  ```
- Verificacion: `(Get-ScheduledTask -TaskName "MonitoreoLockerTiempoReal").Settings.ExecutionTimeLimit` → `PT15M`

**3. Fix movimientos manuales (consignas 25 y 30)**
- Consigna 30 JAVIER L. LOZA Devolucion 06/02/2026 14:00:10
- Consigna 25 INIGO A. ALONSO Devolucion 06/03/2026 10:01:52
- 506 movimientos totales en CSV

### Estado del sistema (2026-06-04):
| Componente | Estado | Notas |
|---|---|---|
| MonitoreoLockerTiempoReal | ✅ v2.2 | ventanaSeg=3, marcador conservador, SAFETY NET mejorado |
| Timeout puerta ACTUM | ✅ 60s | Subido desde 20s en ACTUM EPI Visor |
| ExecutionTimeLimit tareas | ✅ PT15M | Subido desde PT5M |
| CSV HistorialCompleto | ✅ 506 movimientos | |

---

## Resumen de Sesion — 2026-06-02 tarde (4a ocurrencia + fix definitivo ventanaSeg + marcador)

### Problema: Devolucion de consigna 30 no registrada

**Sintoma:** JAVIER L. LOZA devolvio consigna 30 (Medidor LCR / RS Pro LCR1701 / ESCFJ000970) a las 14:00:10. No aparecia en CSV ni en dashboard. Marcador = `2026-06-02 14:00:10` exactamente.

**Causa raiz — marcador == timestamp del evento:**
La query usa `FechaHora > @ultimo` (estrictamente mayor). El marcador estaba en `14:00:10` que es IGUAL al evento → la query devuelve 0 filas. Evento excluido permanentemente.

El marcador llego a `14:00:10` porque en la ejecucion anterior: SQL encontro el evento (`$eventosEnSQL=1`), pero `$nuevosMovimientos.Count=0` (PASO 4 bug o dedup). El bloque else avanzaba el marcador al ultimo evento SQL deduplicado → exactamente `14:00:10`.

**Fix manual:**
```powershell
$utf8NoBOM = New-Object System.Text.UTF8Encoding $false
$linea = "06/02/2026 14:00:10;JAVIER L.;LOZA;30;Medidor LCR / RS Pro LCR1701 / ESCFJ000970;Devoluci$([char]0xF3)n;Cerrada"
[System.IO.File]::AppendAllText("C:\Users\User\OneDrive - GHI HORNOS INDUSTRIALES S.L\LockerACTUM\HistorialCompleto.csv", "$linea`r`n", $utf8NoBOM)
cd C:\ACTUM; .\GenerarDashboard.ps1
```
Resultado: 498 movimientos.

### Fixes definitivos aplicados a MonitoreoLockerTiempoReal.ps1

**1. `$ventanaSeg = 10` → `$ventanaSeg = 3`**
- Con 10s el dedup cross-batch eliminaba eventos reales (gap de 16s ya ocurrio en may-21)
- ACTUM emite pares 10000+10001 en <2s de separacion → 3s es suficiente y seguro

**2. SAFETY NET reescrito (linea 269)**
- Problema: usaba `$fila['x'] -ne [DBNull]::Value` que puede fallar con DataRows boxeados como `object`
- Fix: usa `[string]$fila['x']` — en PowerShell el cast de DBNull a string da `""` directamente
- Usa lista separada `$safeList` en vez de `$nuevosMovimientos +=` para evitar problemas de scope
- Asigna `$nuevosMovimientos = $safeList` al final si hay resultados

**3. Else branch marcador — ya NO avanza (linea 434)**
- Antes: si `$eventosEnSQL > 0` pero `$nuevosMovimientos = 0`, avanzaba marcador al ultimo evento SQL
- Ahora: marcador NUNCA se actualiza cuando no hay movimientos nuevos
- Efecto: los artefactos se re-procesan cada minuto (siempre deduplicados) pero ningun evento real puede quedar excluido permanentemente
- Un evento solo queda excluido de la query cuando se ha escrito correctamente al CSV

**Verificacion en locker:**
```
MonitoreoLockerTiempoReal.ps1:130:        $ventanaSeg = 3
MonitoreoLockerTiempoReal.ps1:434:    # Marcador NO se actualiza cuando no hay movimientos nuevos.
```

### Regla permanente aprendida

> **El marcador NUNCA debe avanzar al timestamp de un evento que no se haya escrito al CSV.**
> Avanzar el marcador cuando `$eventosEnSQL > 0` pero `$nuevosMovimientos = 0` era el origen de todos los eventos perdidos: el marcador quedaba en T_evento, y `FechaHora > T_evento` lo excluia en adelante.

---

## Resumen de Sesion — 2026-06-02 (Bug secundario 3a ocurrencia + SAFETY NET)

### Problema: Devolucion de consigna 29 no registrada

**Sintoma:** IKER L. LASSO devolvio consigna 29 (Cal.pro. y gen.sen. / RSPRO135 / 23200551) a las 11:36:54 pero no aparecia en el dashboard. El instrumento seguia mostrando "En uso".

**Diagnostico:**
- SQL `Eventos`: evento `06/02/2026 11:36:54`, Evento=10001, Consigna=29, Usuario=8 — presente en SQL
- CSV: ultimo movimiento era `06/02/2026 11:30:08` (consigna 28) — el de consigna 29 no estaba
- Marcador `UltimoEventoProcesado.txt`: `2026-06-02 11:36:54` — habia avanzado exactamente al timestamp del evento perdido
- Estado SQL consigna 29: Estado=2 (Libre) — confirmaba que era una Devolucion

**Causa raiz — bug secundario (3a ocurrencia):**
El script encontro el evento en SQL (`$eventosEnSQL=1`), paso el dedup, pero `$nuevosMovimientos` quedo = 0 sin error ni mensaje. El bloque "todos deduplicados" (lineas 396-402) avanzo el marcador al timestamp del evento, ocultandolo permanentemente.

**Mecanismo exacto del bug:**
- Cuando `$filasLimpias` tiene datos pero PASO 4 (Group-Object/DataRow pipeline) produce 0 movimientos, el script cae al else branch con `$eventosEnSQL > 0`
- Ese branch esta disenado para eventos genuinamente deduplicados (artefactos 10000+10001)
- Pero cuando es el bug, el marcador avanza igual y el evento queda perdido para siempre

**Fix manual aplicado:**
```powershell
$utf8NoBOM = New-Object System.Text.UTF8Encoding $false
$linea = "06/02/2026 11:36:54;IKER L.;LASSO;29;Cal.pro. y gen.se$([char]0xF1). / RSPRO135 / 23200551;Devoluci$([char]0xF3)n;Cerrada"
[System.IO.File]::AppendAllText("C:\Users\User\OneDrive - GHI HORNOS INDUSTRIALES S.L\LockerACTUM\HistorialCompleto.csv", "$linea`r`n", $utf8NoBOM)
cd C:\ACTUM; .\GenerarDashboard.ps1
```
Resultado: 497 movimientos, consigna 29 muestra Disponible.

### Fix definitivo: SAFETY NET en MonitoreoLockerTiempoReal.ps1

**Bloque anadido entre PASO 4 y PASO 5** (despues del sort de $nuevosMovimientos):

```powershell
# SAFETY NET: si filasLimpias tiene datos pero nuevosMovimientos quedo vacio -> bug secundario
if ($filasLimpias.Count -gt 0 -and $nuevosMovimientos.Count -eq 0) {
    Write-Host "[SAFETY] Bug secundario detectado ($($filasLimpias.Count) filas perdidas) - procesando directamente" -ForegroundColor Magenta
    foreach ($fila in $filasLimpias) {
        # Determina accion desde estado SQL actual (Estado=2 -> Devolucion, Estado=4 -> Extraccion)
        # Es correcto para el caso tipico (1 evento perdido)
        ...
    }
}
```

**Como funciona:**
- Detecta exactamente el patron del bug: `$filasLimpias.Count > 0` AND `$nuevosMovimientos.Count = 0`
- Procesa los eventos directamente desde los datos crudos de SQL, determinando la accion por el estado actual de la consigna
- Para el caso tipico (1 evento perdido), Estado=2 → Devolucion y Estado=4 → Extraccion es siempre correcto

**Verificacion del deploy:**
```powershell
Select-String "SAFETY NET" "C:\ACTUM\MonitoreoLockerTiempoReal.ps1"
# Debe devolver: MonitoreoLockerTiempoReal.ps1:269: # SAFETY NET: ...
```

### Estado del sistema (2026-06-02 tarde):
| Componente | Estado | Notas |
|---|---|---|
| MonitoreoLockerTiempoReal | ✅ v2.2 | ventanaSeg=3, marcador conservador, SAFETY NET mejorado |
| ReconstruirCSVSemanal | ✅ Lunes 05:00 | Seguro adicional semanal |
| CSV HistorialCompleto | ✅ 498 movimientos | Completo tras fix manual consigna 30 |
| Marcador | ✅ `2026-06-02 14:00:10` | Formato correcto |

---

## Resumen de Sesion — 2026-09-07 (INCIDENTE bucle de reprocesado — RESUELTO)

> **Estado al cierre: SISTEMA REPARADO Y VERIFICADO EN PRODUCCION.** 528 movimientos, 5 tareas corriendo, cero movimientos perdidos. Quedan pendientes de PREVENCION (ver al final) — se retoman el 2026-09-08.

### Sintoma reportado

Dashboard congelado desde la noche del 12-13/08/2026. Toda la carpeta `LockerACTUM` de OneDrive parada. El 15/07 se habia verificado funcionando y se cambio la contrasena sin problema.

### VEREDICTO: NO SE PERDIO NINGUN MOVIMIENTO

**La ultima identificacion de usuario en toda la base de datos es `2026-07-16 13:20:21` (IKER L. LASSO, consigna 08).** Entre el 17/07 y el 07/09 hay **cero** identificaciones: agosto, vacaciones. No se perdieron — no los hubo.

Que el CSV se parase en el 16/07 **no era un truncamiento**: es la fecha correcta y coincide exactamente con SQL.

| Tipo de evento | N desde 01/07 | Ultimo |
|---|---|---|
| **10000** (identificacion) | 5 | **2026-07-16 13:20:21** |
| **10001** (identificacion) | 4 | **2026-07-14 13:07:06** |
| 3 (puerta cierra) | 382 | 2026-09-03 12:37:20 |
| 4 (puerta abre) | 25 | 2026-09-03 12:37:19 |

Tabla `Eventos`: **170.797 registros**, del 26/10/2024 al 03/09/2026. Histórico completo e intacto.

### Lo que si estaba destruido: el CSV

| Medida | 11/06 (sano) | 07/09 (al parar) | 07/09 (reparado) |
|---|---|---|---|
| Bytes | ~51 KB | **10.473.947** | **53.562** |
| Filas de datos | 528 | **103.494** | **528** |
| Lineas UNICAS (byte-exacto) | 528 | **187** | **528** |
| Histórico | completo | desde jun-2025, con huecos | **completo desde 26/10/2024** |
| Tildes | correctas | `IÃ‘IGO`, `DevoluciÃ³n` | **correctas** |

### CAUSA RAIZ — `MonitoreoLockerTiempoReal.ps1:436`

```powershell
# BUG: Sort-Object sin parsear -> orden ALFABETICO sobre MM/dd/yyyy
$ultimaFechaObj = [DateTime]::ParseExact(
    ($nuevosMovimientos | Sort-Object FechaHoraApertura | Select-Object -Last 1).FechaHoraApertura,
    'MM/dd/yyyy HH:mm:ss', $null)
```

Sobre `MM/dd/yyyy` el maximo **alfabetico** siempre es `12/...` -> **diciembre**. El marcador quedaba atrapado ahi.

**Confirmacion empirica en vivo:** el marcador se midio dos veces con 2h de diferencia y se vio reptar **dentro de diciembre de 2025**:
```
11:02  ->  2025-12-16 15:09:44
13:22  ->  2025-12-21 13:52:52
```
Prediccion falsable derivada: sin arreglarlo se habria estancado en un `12/31/xxxx` para siempre.

**La linea 317 del MISMO script ya lo hacia bien.** Se corrigio el sort para escribir el CSV y se dejo el roto para el marcador. Es la trampa que este documento avisaba el 2026-05-14 y que nunca se aplico a esa linea.

### Cadena completa (apagon = disparador, linea 436 = amplificador)

1. **Corte de corriente** durante el `WriteAllText` del marcador -> fichero vacio o partido
2. **Lineas 51-64** (fallback): leia `-Tail 10` del CSV y cogia **la primera linea que casaba, no la mas reciente** -> fecha antigua arbitraria
3. La query devuelve meses de eventos. **Linea 152** los procesa **agrupados por consigna, no cronologicamente** -> se appendean desordenados -> **la cola del CSV deja de ser cronologica**
4. **Linea 436** recalcula el marcador con sort alfabetico -> aterriza en diciembre 2025
5. **Bucle:** cada minuto reprocesa ~9 meses. Como la tarea muere a los 15 min de `ExecutionTimeLimit`, **nunca llega a las consignas del final** -> el historial se congela mientras el fichero engorda
6. SQL saturado -> `GenerarDashboard.ps1` empieza a fallar -> dashboard a **0/0/0** y HTML a 15 KB

**Prueba fisica de los apagones DENTRO del CSV:** 4 lineas compuestas integramente por **bytes NULL (`0x00`)**. Firma clasica de escritura interrumpida por corte de corriente.

### Cortes de corriente — 7 apagados sucios en 5 semanas

| Fecha | Evento |
|---|---|
| 03/08 11:23 y 11:59 | 6008 x2 el mismo dia |
| 04/08 05:51 | 6008 |
| 11/08 13:14 | **42 + 107** — el PC se SUSPENDIO y desperto |
| 11/08 13:16 | 6008 |
| **~12-13/08** | Se cae sucio y **nadie lo enciende -> ~19 dias muerto** |
| 31/08 11:40 | 6005 (alguien lo enciende; aqui se registra el 6008 del 12-13/08) |
| 31/08 12:07 | 1074 + 6006 + 6005 (reinicio ordenado) |
| 07/09 09:33 | 41 + 6008 + 6005 (encendido manual) |
| **07/09 13:15** | **41 + 6008 — septimo apagon, EN MEDIO del diagnostico** |

Lo que se vivio como "se apago el monitor y lo encendi" fue el PC cayendose de golpe. **No hubo evento 42 ese dia: no se durmio, es corriente.**

**El fallo caro no fue el apagon — fueron los 19 dias sin que nadie se enterase.**

### Ráfagas de eventos con Usuario=0: NO son fallos

Los picos (15/07: 180 · 03/08: 74 · 04/08: 36 · 11/08: 113 · 03/09: 38) son **aperturas manuales con llave y boton**, que abren y cierran todas las consignas a la vez. Por eso salen con `Usuario_Codigo = 0` y todas en el mismo segundo. **No son movimientos de usuario ni indican averia.** (Confirmado por Inigo, 2026-09-07.)

### SQL Server esta en ESPANOL — literales de fecha

`SELECT @@LANGUAGE` devuelve `Español` -> `DATEFORMAT dmy`. Con 4 digitos delante SQL asume ano primero y **el resto lo lee dia-mes**:

| Literal | Se interpreta como | Efecto |
|---|---|---|
| `'2026-07-01'` | ano 2026, dia 07, mes 01 = **7 de enero** | filtra mal en silencio |
| `'2026-07-16 23:59:59'` | mes **16** | error "valor fuera de intervalo" |

> **REGLA: usar SIEMPRE `'YYYYMMDD'` (`'20260701'`), neutral al idioma.** Para mostrar, `CONVERT(varchar, FechaHora, 120)`.

### EL WATCHDOG MIENTE — `GenerarDashboard.ps1:24-35`

```powershell
$tareaHTML = Get-ScheduledTask -TaskName "GenerarDashboardHTML" -ErrorAction SilentlyContinue
if ($tareaHTML -and $tareaHTML.State -eq "Disabled") {
    Enable-ScheduledTask -TaskName "GenerarDashboardHTML" -ErrorAction SilentlyContinue
    Write-Host "WATCHDOG: GenerarDashboardHTML estaba Disabled - reactivada automaticamente"
}
```

**Nunca ha funcionado.** Dos problemas encadenados:

1. **`Enable-ScheduledTask` exige Administrador**, y el proyecto obliga a que este script corra como `User` (regla del 03/03: como SYSTEM falla el SQL con Integrated Security). El `Enable` no puede funcionar en la configuracion correcta.
2. **`-ErrorAction SilentlyContinue` se come el "Acceso denegado"** y el `Write-Host` canta victoria sin comprobar. El 07/09 imprimio "reactivada automaticamente" y la tarea siguio en `Disabled` (verificado con `Get-ScheduledTask` justo despues).

> **Esto resuelve la contradiccion del documento:** una seccion decia "el watchdog la reactiva" y otra "GenerarDashboardHTML debe estar DISABLED por redundante". En la practica el watchdog no reactivaba nada.

**Antipatron que ha causado los problemas de este proyecto: declarar exito sin medir el resultado.** Fix pendiente: releer el estado tras el intento y reportar lo que realmente paso.

### Error JavaScript en OneDrive web (cosmetico)

```
Uncaught SecurityError: Failed to execute 'replaceState' on 'History' ...
origin 'null' and URL 'about:srcdoc'. (about:srcdoc:1473:95 / 1474:95)
```

Origen: `GenerarDashboard.ps1:680-681` (persistencia de pestana via hash URL, v2.1 UX del 21/04). SharePoint incrusta el HTML en un iframe `about:srcdoc` con origin `null`, donde `replaceState` con URL esta prohibido. Las lineas 680-681 del `.ps1` caen en las **1473-1474 del HTML generado**.

**No rompe los tabs** (radio buttons CSS puro), solo genera el banner rojo *"No se cargo parte del contenido"*.

> Este documento declaro ese JS "inofensivo" el 2026-06-11. **No lo es.** Fix: borrar el bloque `<script>` de las lineas 672-684.

### Tamano del DashboardLocker.html: no hay cifra "sana" fija

`GenerarDashboard.ps1` **no limita filas** (lineas 207-211): renderiza todos los movimientos tras agrupar por fecha+usuario+consigna. El tamano es **proporcional a los movimientos**:

| | Filas renderizadas | HTML |
|---|---|---|
| CSV corrupto | 103.494 filas -> **187 grupos** | 88.692 bytes |
| Reparado | 528 movimientos -> **528 grupos** | **246.461 bytes** |

`528/187 = 2,82` y `246.461/88.692 = 2,78`. El HTML era pequeno porque el `Group-Object` colapsaba las duplicadas.

> **No usar "~87 KB" como referencia de salud: esa medida se tomo en plena averia.** La referencia correcta es `<tr>` ~= movimientos + instrumentos + 2 cabeceras.

### Contadores de verificacion del HTML

- `<tr>` = **562** = 528 historial + 32 instrumentos + 2 cabeceras
- `badge-en-uso` en crudo = **17**, porque el CSS define la clase 2 veces (lineas 427 y 515). Para contar badges reales usar el patron **`badge badge-en-uso`** -> **15**

### Copia de conflicto de OneDrive

`HistorialCompleto-GHI-TAQUILLAS.csv` (10.404.324 bytes) junto al original. Copia que OneDrive crea cuando el mismo fichero cambia en dos sitios. Analizada: **las mismas 187 lineas unicas**, no aporta nada. **PENDIENTE de borrar.**

### REPARACION EJECUTADA Y VERIFICADA

| # | Accion | Verificacion medida |
|---|---|---|
| 1 | Causa raiz localizada **leyendo el codigo** | Linea 436, no inferida |
| 2 | **5 tareas desactivadas** | Las 5 en `Disabled` + `Stop-ScheduledTask` |
| 3 | **CSV congelado** | `103.495` = `103.495` en dos lecturas a 90 s |
| 4 | **Copia forense** en `C:\ACTUM\BACKUP_20260907\` | `103.495` = `103.495` filas origen vs copia |
| 5 | **Parche de 1 linea del bug raiz** (Plan B) | `PARCHE APLICADO` · 0 errores · lineas 317 y 436 parseando |
| 6 | **Auditoria de todo el repo** | 17 `Sort-Object` sobre fechas: **solo la 436 estaba rota** |
| 7 | **v2.4 desplegada por copia-pega** | **SHA256 identico** `112CE8A0…` · 517 lineas · 24.206 bytes · 0 errores · here-strings 2/2 |
| 8 | **Reconstruccion de PRUEBA** (fichero aparte) | 588 eventos -> 62 artefactos -> **526 movimientos** · unicos **526/526 = 1:1** · CSV real intacto en 10.473.947 bytes |
| 9 | **Sustitucion** | 53.381 bytes · marcador `2026-07-16 13:20:21` |
| 10 | **Consigna 22 -> SERGIO V. VEGA** reaplicada | **528** movimientos · 53.562 bytes |
| 11 | **Dashboards regenerados** | Locker 246.461 · Admin 125.404 · `En uso por SERGIO V. VEGA` · contador **528** (era 100.771) |
| 12 | **5 tareas reactivadas** | Las 5 en `Ready` |
| 13 | **PRUEBA DE FUEGO** | Tarea corriendo cada minuto durante 13 min (`LastRunTime 15:00:00`, `LastTaskResult 0`) y el CSV **sin escribirse desde las 14:47:06**. El bucle esta muerto. |

**v2.4 en produccion y en el repo, identicas:**
```
Lineas : 517      Bytes : 24.206
SHA256 : 112CE8A009E773E6888D66001FCA704089C558C41700CCC32AA9F3A497BF46A9
ASCII puro (0 caracteres no-ASCII) · here-strings 2 aperturas / 2 cierres
```

Backups de rollback en el locker: `MonitoreoLockerTiempoReal_ANTES_20260907.ps1` (v2.3 original) y `_POSTB_20260907.ps1` (v2.3 + parche B, 21.565 bytes).

### PENDIENTE — se retoma el 2026-09-08, por orden de valor

**El coste real del incidente no fue el apagon: fueron los 19 dias sin que nadie se enterase. Eso sigue sin resolver.**

- [ ] **1. ALERTA DE SISTEMA CAIDO** ← lo mas importante. Aviso automatico si el dashboard lleva >3 h sin actualizarse. Sin esto, el proximo fallo vuelve a pasar semanas desapercibido.
- [ ] **2. BIOS: `Restore on AC Power Loss -> Power On`.** 7 apagones en 5 semanas y cuando cae no vuelve solo. Requiere reiniciar el PC para entrar en la BIOS. Revisar tambien la suspension (evento 42 del 11/08 prueba que estaba activa).
- [ ] **3. Higiene rapida:**
  - Borrar `HistorialCompleto-GHI-TAQUILLAS.csv` (copia de conflicto, 10 MB inutiles)
  - Watchdog de `GenerarDashboard.ps1:24-35`: que verifique y diga la verdad
  - Borrar el `<script>` de `GenerarDashboard.ps1:672-684` (banner rojo de SharePoint)
- [ ] **4. Contrasena de `fabricacion1`** (caducaba ~26/08)
- [ ] **5. Menor:** `$estadoPorConsigna` sin definir (lineas 486-488, `EstadoAnterior.json` queda en `{}`) · revisar `$ventanaSeg = 3` (duplicados con la MISMA accion a 9-10 s en el historial antiguo) · `GHI-Locker-Dashboard/scripts/` tiene copias antiguas que difieren de la raiz

### TAREAS DE SEGUIMIENTO DEL LOCKER (apuntadas por Inigo, 2026-09-07)

Lista para retomar el tema del locker con calma — no solo el software:

- [ ] **A. PRUEBA FUNCIONAL de extraccion y devolucion.** Bajar al locker, identificarse, sacar un instrumento y devolverlo, y comprobar que el sistema lo detecta bien y en el orden correcto.
  > **Este es el hueco real de la verificacion.** Todo lo comprobado el 07/09 se hizo con datos **historicos**, porque desde el `2026-07-16 13:20:21` no hubo ningun movimiento nuevo. Que el sistema **capture correctamente un movimiento nuevo** no esta probado desde antes del incidente.
  >
  > **Predicado de exito:** por cada accion fisica aparece **1 solo movimiento** en el CSV (no 2 — ojo al dedup de `$ventanaSeg = 3` y a los pares de eventos 10000+10001), con el **usuario correcto**, la **accion correcta** (Extraccion / Devolucion segun corresponda), el **marcador avanza a la fecha de hoy** en formato `yyyy-MM-dd HH:mm:ss`, y el dashboard lo refleja en menos de 1 minuto. Verificar las tres cosas: CSV, marcador y dashboard.

- [ ] **B. AUDITORIA FISICA de las consignas.** Bajar al locker con el dashboard delante y comprobar una por una: que lo que el dashboard dice que hay en cada consigna **esta realmente ahi**, y que las marcadas como **Disponible estan vacias**. Aqui se cierra de verdad el asunto de la **consigna 22** (SERGIO VEGA vs lo que dice SQL) y cualquier otra asignacion administrativa desfasada. Referencia: las 15 consignas que el sistema da como "En uso" a 2026-09-07 son `01 02 08 09 11 13 15 19 20 21 22 24 26 27 32`.

- [ ] **C. CALIBRACIONES — ir mandando poco a poco.** Los pendientes estan apuntados en el **cuaderno GHI** y en **recordatorios del movil**. La pestana Calibracion del `DashboardAdmin.html` ya clasifica por CADUCADO / URGENTE (<30d) / PROXIMO (<90d) leyendo `Caja.FechaCaducidad` de SQL, asi que sirve directamente como lista de trabajo. **Tarea recurrente, no de un dia.**

- [ ] **D. EL ERROR QUE SALE AL ABRIR EL DASHBOARD — identificarlo de verdad.** Muy probablemente sea el banner rojo de SharePoint por `replaceState` (documentado en esta misma seccion), que se arregla borrando el `<script>` de `GenerarDashboard.ps1:672-684`. **Pero hay que confirmarlo, no darlo por hecho:** capturar el mensaje exacto cuando aparezca (`F12` -> Consola, o "Mostrar detalles" en el propio banner) por si fuera otro distinto.

### DECISION PENDIENTE — `ReconstruirCSVSemanal` borrara la correccion de la consigna 22

**El lunes 14/09 a las 05:00** esa tarea reconstruye el CSV desde SQL y **la consigna 22 volvera a salir a nombre de IKER L. LASSO**, porque las lineas de SERGIO VEGA se escriben a mano y **no existen en la tabla `Eventos`**.

Tres opciones sobre la mesa (sin decidir a 2026-09-07):
1. **Dejarlo** y reaplicar la correccion cuando pase
2. **Desactivar** la reconstruccion semanal — ya no hace falta como red de seguridad, el bug raiz esta arreglado
3. **Arreglarlo en origen:** asignar la consigna 22 a SERGIO en el ACTUM EPI Visor **y** implementar la mejora pendiente de leer `Consigna.Usuario_Codigo` para la pestana Estado. La unica que aguanta sola, pero mas trabajo

Decision de Inigo (2026-09-07): **la consigna 22 se deja a nombre de SERGIO V. VEGA**, y despues verificara fisicamente que consignas tiene quien.

Comando para reaplicar:
```powershell
$utf8NoBOM = New-Object System.Text.UTF8Encoding $false
$csv = "C:\Users\User\OneDrive - GHI HORNOS INDUSTRIALES S.L\LockerACTUM\HistorialCompleto.csv"
$lineas = @(
    "04/16/2026 12:44:30;IKER L.;LASSO;22;An.gases / TESTO 340 / 63862113;Devoluci$([char]0xF3)n;Cerrada",
    "04/16/2026 12:45:00;SERGIO V.;VEGA;22;An.gases / TESTO 340 / 63862113;Extracci$([char]0xF3)n;Cerrada"
)
foreach ($l in $lineas) { [System.IO.File]::AppendAllText($csv, "$l`r`n", $utf8NoBOM) }
cd C:\ACTUM; .\GenerarDashboard.ps1
```
> Anadir lineas antiguas al final deja el CSV desordenado. **Antes del fix eso era lo que disparaba el bucle**; con v2.4 el marcador se calcula por el **maximo real** de todo el fichero, asi que ya es seguro.

### Reglas permanentes aprendidas

> **1. `Sort-Object` sobre fechas en texto `MM/dd/yyyy` ordena ALFABETICAMENTE.** Todo orden cronologico debe parsear primero: `Sort-Object { [DateTime]::ParseExact($_.Campo,'MM/dd/yyyy HH:mm:ss',$null) }`. Ha causado DOS incidentes graves (30/04 y 07/09). Auditado el repo entero el 07/09: los 17 usos restantes son correctos.

> **2. Un marcador jamas debe derivarse de la "ultima linea" de un fichero que no esta garantizado en orden cronologico.** Si hay que derivarlo, coger el **maximo parseado**, nunca la posicion.

> **3. Ratio filas/unicas es el detector barato de este fallo.** Sano ~= 1:1; el 07/09 era **~600:1**. Deberia ser un chequeo automatico. Medir con `LC_ALL=C sort -u` o `HashSet`: `sort -u` a secas usa collation de la localizacion y **falsea el conteo** en ficheros con encoding mixto (dio 166 donde habia 187).

> **4. Las dos pestanas del dashboard tienen fuentes distintas y fallan por separado.** Estado lee SQL (fiable aunque el CSV este destruido); Historial lee el CSV. Que el dashboard "se vea bien" NO prueba que el sistema este sano — **hay que mirar el contador de movimientos**. El 07/09 a las 10:57 se veia perfecto y a las 11:21 estaba a ceros.

> **5. El sistema no tiene deteccion de fallo.** Estuvo 19 dias muerto sin que nadie lo supiera. Cualquier arreglo que no incluya una alerta deja el mismo agujero abierto.

> **6. PowerShell: `$array += ...` dentro de un bucle sobre decenas de miles de filas es O(n^2)** y cuelga la consola. Usar `[System.Collections.Generic.List[T]]::new()` + `.Add()`.

> **7. Literales de fecha en SQL: SIEMPRE `'YYYYMMDD'`.** El servidor esta en espanol y `'2026-07-16'` se lee como ano-dia-mes.

> **8. `Enable-` y `Disable-ScheduledTask` exigen PowerShell como ADMINISTRADOR.** En ventana normal fallan con `Acceso denegado` (HRESULT 0x80070005). Y **`Disable-ScheduledTask` NO corta la ejecucion en marcha**: hace falta `Stop-ScheduledTask` ademas, o la instancia viva sigue hasta 15 min.

> **9. Bytes NULL (`0x00`) en un fichero de datos = escritura interrumpida por corte de corriente.** Buscarlos confirma que hubo apagon durante una escritura.

> **10. Nunca declarar exito sin releer el estado del sujeto.** El watchdog lleva meses imprimiendo "reactivada automaticamente" sin reactivar nada. Todo `Enable`/`Set`/`Copy` debe seguirse de un `Get` que lo confirme.

> **11. Desplegar por copia-pega SI es viable, con dos condiciones:** que el `.ps1` sea **ASCII puro** (ninguna codificacion puede romperlo) y **verificar SHA256 + numero de lineas + contador de here-strings (aperturas/cierres)**. Asi se desplego la v2.4 con hash identico. El fallo del 2026-03-03 (688 lineas llegaron como 454) se habria detectado al instante.

---

## Resumen de Sesion — 2026-09-08 (Prevencion: que no se caiga)

> Foco elegido por Inigo: **aparcar la alerta de caida** ("yo estoy atento cada 2 por 3") y dedicar la sesion
> a que el sistema NO se caiga. La alerta queda pendiente, sin fecha.

### 1. `ReconstruirCSVSemanal` DESACTIVADA (decision cerrada)

Se desactiva por peticion expresa: **reescribia el CSV entero desde SQL cada lunes 05:00 y borraba las
correcciones manuales** (SERGIO V. VEGA en consignas 18 y 22, y las de 13/25/29/30). Esas lineas se escriben
a mano precisamente porque **no existen en la tabla `Eventos`** — cualquier reconstruccion se las lleva por
definicion, no por fallo.

Ya no cumplia funcion: se creo el 2026-05-20 como red contra el bug de eventos perdidos, cerrado el
**04/06** (v2.3, hashtable en PASO 4) y el **07/09** (v2.4, `Sort-Object` alfabetico en `:436`).

```powershell
Disable-ScheduledTask -TaskName "ReconstruirCSVSemanal"   # requiere ADMIN
Get-ScheduledTask -TaskName "ReconstruirCSVSemanal" | Select-Object TaskName, State
```
**Verificado sobre el sujeto: `State = Disabled`.**

`ReconstruirHistorial.ps1` sigue en `C:\ACTUM\` y se lanza **a mano** cuando haga falta. Es una herramienta
de rescate, no algo que se dispare solo sobre datos buenos.

> Esto **cierra la DECISION PENDIENTE** del 07/09 sobre la consigna 22: se eligio la opcion 2 (desactivar).

### 2. Estado del sistema tras la reparacion — SANO (ver correccion en el punto 5)

| Comprobacion | Valor medido 08/09 | Lectura |
|---|---|---|
| Consigna 22 | `04/16/2026 12:45:00 SERGIO V. VEGA Extraccion` | intacta, NO hubo que reaplicar |
| Consigna 18 | `07/06/2026 08:51:08 SERGIO V. VEGA Devolucion` | devuelta de verdad el 6 de julio |
| Ratio filas/unicas | **529 / 529 = 1,00** | sano (el 07/09 era ~600:1) |
| Bytes CSV | **53.562** | **byte-identico al cierre del 07/09** |
| Marcador | `2026-07-16 13:20:21` | formato correcto, NO diciembre |

**El CSV byte-identico es la evidencia de que el bucle esta muerto.** OJO: son ~7 h de funcionamiento real,
no 24 h de calendario — el PC estuvo apagado 12 h esa noche (ver punto 5).

`ReconstruirCSVSemanal` **no corrio el 08/09**: su `LastRunTime` era `07/09/2026 5:00:00` con
`LastTaskResult 267014` (`0x41306` = *tarea finalizada por el usuario*), que son los `Stop-ScheduledTask`
de la propia reparacion. Nunca llego a reescribir nada.

> Nota de metodo: en esta sesion se dio por hecho que el 08/09 era lunes y que la reconstruccion ya habria
> corrido. **Era martes.** El dato del `LastRunTime` lo desmintio. Comprobar el dia real antes de razonar
> sobre tareas semanales.

### 3. Suspension e hibernacion DESACTIVADAS (ataca el evento 42 del 11/08)

```powershell
powercfg /change standby-timeout-ac 0
powercfg /change hibernate-timeout-ac 0
powercfg /change disk-timeout-ac 0
powercfg /hibernate off
```
**Verificado:** `Indice de configuracion de corriente alterna actual: 0x00000000` en `STANDBYIDLE` y en
`HIBERNATEIDLE`. El PC enchufado ya no se duerme solo.

`/hibernate off` desactiva ademas el *inicio rapido* de Windows -> todos los arranques son limpios.
Reversible con `/hibernate on`.

Los indices de corriente continua seguian en `0x384` (15 min) y `0x2a30` (3 h): irrelevante en un sobremesa
sin bateria, pero se igualan a 0 por si algun dia le ponen un SAI que Windows vea como bateria.

### 4. Hibernacion e inicio rapido DESACTIVADOS (verificado)

`powercfg /hibernate off` **no se habia aplicado** en el primer intento: los timeouts quedaron a 0 pero
`powercfg /a` seguia listando *Hibernar*, *Suspension hibrida* e *Inicio rapido* como **disponibles**.
Se relanzo y se reverifico:

```
No disponibles: Hibernar ("No se habilito la hibernacion") · Suspension hibrida · Inicio rapido
Disponible:     Modo de espera (S3)  <- con timeout a 0, no se activa solo
```
> Caso de libro de la regla 10: `hibernate-timeout 0` y `/hibernate off` son cosas DISTINTAS.
> Solo `powercfg /a` lo demuestra.

### 5. DIAGNOSTICO DEL PC — el disco esta sano, lo que falla es la CORRIENTE

Medido el 08/09 sobre el locker:

| Sujeto | Valor medido | Veredicto |
|---|---|---|
| Disco | KINGSTON SA400S37240G SSD · `Healthy`/`OK` · Wear 0 · 43 C · 14.447 h | **sano** |
| Espacio C: | 144,3 GB libres / 78,7 usados | **sobrado** |
| WHEA (CPU/RAM/bus) | **0 eventos en 60 dias** | **sin fallo de hardware registrado** |
| Errores disco log 30d | 4x`11` · 14x`98` · 6x`153` | **FALSA ALARMA — no son de disco (ver abajo)** |

**OCTAVO APAGON — 07/09 19:15:42**, despues de cerrar la sesion de reparacion:
```
08/09 7:59:07  6008  El cierre anterior a las 19:15:42 del 07/09/2026 resulto inesperado
```
**12 horas muerto** hasta que alguien lo encendio a mano a las 7:59.

Historial completo de caidas (log de 30 dias):

| Cierre sucio | Volvio a arrancar | Tiempo muerto |
|---|---|---|
| 11/08 13:11:24 | 11/08 13:15:55 | 4 min |
| **25/08 12:37:39** | **31/08 11:40:14** | **6 DIAS** |
| 07/09 9:27:35 | 07/09 9:33:00 | 6 min |
| 07/09 12:53:05 | 07/09 13:15:34 | 22 min |
| **07/09 19:15:42** | **08/09 7:59:00** | **12 HORAS** |

Sin patron horario. El 11/08 ademas hubo `42`+`107` (se durmio y se reanudo) — ya corregido en el punto 3-4.

**Los IDs `11` y `153` NO son de disco.** Se filtro por numero de evento sin mirar el `ProviderName`, y esos
numeros significan cosas distintas segun quien los emita:

| ID | Proveedor real | Que es | Veredicto |
|---|---|---|---|
| `11` | `Kernel-General` | Transaccion TxR del registro sobre `HarddiskVolumeShadowCopy`, resultado `0xC00000A2` (*medio protegido contra escritura*) — lo esperado sobre una instantanea, que es de solo lectura | **ruido benigno** |
| `153` | `Kernel-Boot` | "La seguridad basada en virtualizacion es disabled". Sus horas (`7:59:00`, `13:15:32`, `9:32:58`, `12:07:41`, `11:40:13`) **son exactamente los arranques** | **informativo de boot** |

> **REGLA: un Event ID sin `ProviderName` no significa nada.** `11` y `153` son de disco en `disk`/`storahci`
> y son otra cosa completamente distinta en `Kernel-General`/`Kernel-Boot`. Filtrar por numero suelto produce
> falsos positivos. Filtrar SIEMPRE por `ProviderName` + `Id`.

**Cuadro final: SSD `Healthy`, cero WHEA, cero errores de E/S reales, 144 GB libres.**

> **VEREDICTO: el PC no esta enfermo, lo estan apagando.** El dano no lo hace el corte (2 segundos), lo hace
> que **cada corte lo deja muerto hasta que alguien pasa por alli**. Por eso la BIOS
> (`Restore on AC Power Loss -> Power On`) es la accion de mayor valor de toda la lista pendiente: convierte
> 12 horas de silencio en un minuto. Un SAI atacaria la causa en vez del sintoma.

> **CORRECCION de metodo (punto 2 de esta sesion):** se afirmo que el CSV byte-identico probaba 24 h sin bucle.
> **Falso: el PC estuvo apagado 12 de esas horas.** La evidencia real son ~7 h de funcionamiento
> (07/09 14:47->19:15 y 08/09 7:59->ahora). Sigue siendo buena senal, pero la mitad de fuerte.
> Comprobar SIEMPRE el uptime antes de convertir tiempo-de-calendario en tiempo-de-observacion.

### 6. WATCHDOG ELIMINADO de `GenerarDashboard.ps1` (desplegado y verificado)

Se **elimina**, no se arregla. Tenia DOS defectos, y el segundo es el que decide:

1. **Nunca funciono.** `Enable-ScheduledTask` exige Administrador y el script debe correr como `User`
   (como SYSTEM falla el SQL, regla del 03/03). El `-ErrorAction SilentlyContinue` se tragaba el
   "Acceso denegado" y el `Write-Host` cantaba victoria igual.
2. **Su objetivo era INCORRECTO.** Intentaba reactivar `GenerarDashboardHTML`, que por arquitectura debe
   estar `Disabled` (redundante: `MonitoreoLockerTiempoReal` ya genera el HTML). Si funcionase, cada minuto
   desharia esa decision y dejaria DOS procesos escribiendo los mismos ficheros de OneDrive a la vez
   — origen probable de la copia de conflicto `HistorialCompleto-GHI-TAQUILLAS.csv`.

> **No sustituir por una version "honesta": no queremos que esa tarea se reactive.**

**Demostracion empirica del bug, del mismo dia:** el bloque original, pegado en una ventana de
**Administrador**, SI reactivo la tarea (`GenerarDashboardHTML -> Ready`). Mismo codigo, dos resultados
segun la cuenta — y el mismo mensaje de exito en ambos. Se volvio a dejar en `Disabled`.

Parche quirurgico (busca el bloque por contenido, con guarda que aborta sin tocar nada si no encaja),
backup previo en `C:\ACTUM\GenerarDashboard_ANTES_20260908.ps1`.

| Verificacion | Esperado | Medido en el locker |
|---|---|---|
| Bloque detectado | lineas 23-35 | **23-35, guarda `True`** |
| Codigo `Enable-ScheduledTask` restante | vacio | **vacio** |
| Errores de sintaxis | 0 | **0** |
| Lineas | 706 | **706** (identico al repo) |
| No-ASCII | 0 | **0** |
| Dashboard regenerado | 528 mov · ~246 KB | **528 mov · 32 instr · 246.461 bytes** |

> **El HTML salio con 246.461 bytes, byte-identico al de la reparacion del 07/09.** Salida sin cambios =
> el parche quito el watchdog sin alterar el dashboard. Ese es el predicado fuerte, mejor que "no dio error".

> **Nota:** NO se puede comparar SHA256 entre repo y locker — el repo usa LF y el locker CRLF. La
> verificacion va por propiedades (lineas · no-ASCII · sintaxis · salida byte-identica), no por huella.

> **Correccion:** se predijo `707` lineas y salieron `706`. El error era del calculo (se sumaba la linea
> vacia final); `ReadAllLines` sobre el repo da **706**. El fichero estaba bien.

### PENDIENTE tras esta sesion (reordenado por el diagnostico del punto 5)

- [ ] **1. BIOS: `Restore on AC Power Loss -> Power On`** <- AHORA ES LO PRIMERO. Es lo unico que convierte
      12 horas de silencio en un minuto. 8 apagones en 5 semanas y el PC nunca vuelve solo.
- [ ] **2. Corriente: averiguar la causa.** Como esta enchufado (regleta con interruptor? linea compartida con
      maquinaria? otros equipos que caigan a la vez?). **Un SAI ataca la causa en vez del sintoma** y con este
      historial se paga solo.
- [x] **3. Errores de disco `11`/`153` — DESCARTADO 08/09.** Falsa alarma: son `Kernel-General` (TxR sobre
      shadow copy) y `Kernel-Boot` (VBS disabled en cada arranque), no incidencias de disco. Queda solo
      confirmar el `Repair-Volume -DriveLetter C -Scan` (debe dar `NoErrorsFound`).
- [x] **4. Watchdog — ELIMINADO y verificado el 08/09** (ver punto 6).
- [ ] **5. Borrar el `<script>`** de `GenerarDashboard.ps1:672-684` (banner rojo de SharePoint por `replaceState`).
- [ ] **6. Borrar** `HistorialCompleto-GHI-TAQUILLAS.csv` (copia de conflicto, ~10 MB inutiles).
- [ ] **7. Contrasena de `fabricacion1`** (caducaba ~26/08).
- [ ] **8. Alerta de sistema caido** — aparcada por decision de Inigo, no descartada. El octavo apagon (12 h
      muertas sin que nadie se enterase) es exactamente el argumento a favor de retomarla.
- [ ] **9. Commitear v2.4 + CLAUDE.md** (ambos siguen sin commitear en el repo de desarrollo).
- [ ] **10. Tareas fisicas A-D** del 07/09. La **A** (prueba funcional real de extraccion y devolucion) sigue
      siendo el hueco de verificacion: el marcador sigue clavado en `2026-07-16 13:20:21` porque **nadie ha usado
      el locker desde entonces**, asi que el sistema reparado NO esta probado con un movimiento nuevo.

---

## AUDITORIA COMPLETA DE `C:\ACTUM` — 2026-09-08

> Sujeto: copia integra de `C:\ACTUM` del locker descargada el 08/09 a las 09:05, mas la carpeta
> `LockerACTUM` de OneDrive (descargada el 07/09 14:08, es decir **en plena averia**: su CSV son los
> 10.473.947 bytes de antes de reparar). **118 ficheros · 98 MB.**

### A. LA CADENA COMPLETA, DE LA PUERTA AL NAVEGADOR

```
[Consignas fisicas] --RS485--> [Electronica Kerong  BU 172.16.5.41:23]
        |                                   ^
        |                                   | TCP (telnet/23)
        v                                   |
[ACTUM_EPI_Gestion.exe]  <-- software del FABRICANTE, corriendo siempre
        |   escribe cada apertura/identificacion
        v
[SQL Server Express  GHI-TAQUILLAS\SQLEXPRESS  ·  BD Actum_GHI  ·  tabla Eventos]
        |
        |   <-- AQUI EMPIEZA LO NUESTRO
        v
[Task Scheduler] --> [.vbs (ventana oculta)] --> [.ps1]
        |
        v
[C:\Users\User\OneDrive - GHI HORNOS INDUSTRIALES S.L\LockerACTUM\]
   HistorialCompleto.csv · UltimoEventoProcesado.txt · DashboardLocker.html · DashboardAdmin.html
        |
        |   <-- NO hay API, NO hay subida, NO hay codigo de red.
        |       Es una CARPETA LOCAL NORMAL que el cliente OneDrive de Windows sincroniza,
        |       porque en el usuario `User` hay iniciada la sesion de fabricacion1@ghifurnaces.com
        v
[SharePoint / OneDrive de fabricacion1] --> el enlace que abre la gente en el navegador
```

> **Como se "conecta a OneDrive": no se conecta.** Los scripts escriben ficheros en una carpeta del disco
> como quien guarda en Documentos. Lo unico que la hace especial es que **OneDrive.exe la esta vigilando**
> con la cuenta `fabricacion1` autenticada. Si esa sesion caduca, los scripts siguen funcionando
> perfectamente y **nadie ve nada nuevo en la web**. Esa es la causa mas frecuente de averia del sistema
> (25/03, 06/05, 14/05) y por eso no aparece en ningun log: no es un error, es una ausencia.

**Los 3 programas del fabricante** (`C:\ACTUM\ACTUM_EPI\`):

| Programa | Para que sirve |
|---|---|
| `ACTUM_EPI_Gestion.exe` | El motor. Habla con la electronica Kerong y escribe en SQL. **Si se para, no se registra nada.** |
| `ACTUM_EPI_Visor.exe` | Consulta de estado (el "ACTUM EPI Visor" que se abre para mirar consignas) |
| `ACTUM_EPI_Parametros.exe` | Configuracion (aqui se cambio el timeout de puerta el 04/06) |

**Las 5 tareas programadas** (todas: Task Scheduler -> `wscript.exe` -> `.vbs` -> `powershell.exe -File`):

| Tarea | Cada | Script | Estado |
|---|---|---|---|
| `MonitoreoLockerTiempoReal` | 1 min | `MonitoreoLockerTiempoReal.ps1` v2.4 | activa · **es la unica imprescindible** |
| `GenerarDashboardAdmin` | 1 min | `GenerarDashboardAdmin.ps1` | activa |
| `ActualizarExcelLocker` | 5 min | `ActualizarExcel.ps1` | activa |
| `GenerarDashboardHTML` | 1 min | `GenerarDashboard.ps1` | Disabled (redundante) |
| `ReconstruirCSVSemanal` | lunes 05:00 | `ReconstruirSemanal.ps1` | Disabled el 08/09 |

`GenerarDashboard.ps1` **no necesita tarea propia**: `MonitoreoLockerTiempoReal.ps1` lo invoca con dot-sourcing
al final de cada pasada.

### B. HALLAZGO — `ReconstruirCSVSemanal` NUNCA FUNCIONO (desde el 20/05/2026)

`EjecutarReconstruccionOculto.vbs` (164 bytes) esta **partido en dos lineas**, con un `LF` suelto en mitad de
la cadena literal y la segunda linea indentada con dos espacios:

```
CreateObject("WScript.Shell").Run "powershell.exe ... -File
  ""C:\ACTUM\ReconstruirSemanal.ps1""", 0, False
```

En VBScript eso es **constante de cadena sin terminar**. Los otros cuatro `.vbs` son de UNA linea y con
`CRLF`; este es el unico con `LF` — firma de un pegado roto, exactamente el fallo que este documento
advierte sobre here-strings indentados.

**Triangulacion independiente:** si hubiera corrido alguna vez, el lunes siguiente al 10/06 habria borrado
las lineas manuales de SERGIO V. VEGA. Siguen ahi tres meses despues. **Nunca se ejecuto.**

**Y estaba roto por partida doble:** `ReconstruirSemanal.ps1` usa `Disable-ScheduledTask` /
`Enable-ScheduledTask`, que **exigen Administrador**, y la tarea corre como `User`. Aunque el VBS fuese
correcto, habria fallado igual.

> Consecuencia: la "red de seguridad semanal" documentada el 20/05 **nunca existio**. El sistema lleva
> desde junio funcionando sin ella — y sin perder nada, porque el bug raiz se cerro el 04/06.
> Su `LastTaskResult 267014` encaja: `wscript` abria un cuadro de error invisible y la tarea se quedaba
> colgada hasta el `ExecutionTimeLimit`.

### C. HALLAZGO — LOS LOGS DE ACTUM EXISTEN Y NADIE LOS MIRA

`C:\ACTUM\ACTUM_EPI\Gestion\` guarda dos series de logs del fabricante. **Son diagnostico gratis.**

**`Desconexiones_AAAAMMDD.txt`** — perdida de comunicacion con la electronica Kerong:

| Dia | Ciclos desconexion/conexion |
|---|---|
| 15/07 · 19/07 · 04/08 · 03/09 | 1 |
| 03/08 | 3 |
| **11/08** | **7 en 35 minutos** (14:22 a 14:57) |

**`Error_AAAAMMDD.txt`** — solo se crean los dias con errores. Volumen medido:

| Dia | Errores | Dia | Errores |
|---|---|---|---|
| 09/07/25 · 10/09/25 · 12/11/25 | 35-40 | 15/07/26 | 32 |
| 12/08/25 | 111 | 19/07/26 | 190 |
| 10/03 · 15/04 · 13/05 | 34-56 | **03/08/26** | **1.604** |
| | | **11/08/26** | **872** |

Un dia normal son 30-50 errores. El **03/08 (1.604)** y el **11/08 (872)** se salen de la escala, y son los
**unicos dos dias con `System.OutOfMemoryException`** en todo el historial.

Errores dominantes esos dias:
- `System.OutOfMemoryException` en `classeKerong`
- `Memoria de sistema insuficiente en el grupo de recursos de servidor internal` — **SQL Express sin RAM**
- `No hay ningun proceso en el otro extremo de la canalizacion` — **SQL Server se cayo**
- `ExecuteNonQuery requiere una Connection abierta` (688 veces el 03/08)
- `Error generico en GDI+` — agotamiento de handles

> **[RESUELTO el 08/09 - ver apartado O: es la ELECTRONICA al conectar, confirmado con firma identica]**
> ~~Hipotesis a verificar:~~ las rafagas de eventos con `Usuario_Codigo = 0`
> (03/08: 74 · 11/08: 113) se atribuyeron el 07/09 a **aperturas manuales con llave y boton**. Los logs
> ofrecen una explicacion alternativa: cuando la electronica Kerong **reconecta**, ACTUM re-lee el estado de
> todas las consignas y emite eventos de puerta en bloque. El 11/08 hubo 7 reconexiones y 113 eventos.
> **No se descarta ninguna de las dos** — hace falta comprobar si las horas de los eventos `Usuario=0`
> coinciden con las horas de `CONEXION` del log. Es una consulta de 2 minutos.

> **Pendiente de medir: cuanta RAM tiene el PC.** SQL Server Express tiene un tope propio de ~1 GB de buffer;
> si el equipo va justo de memoria, los `OutOfMemory` tienen explicacion estructural y volveran.

### D. LO QUE SOBRA — 98 MB, 118 FICHEROS, TODO EN EL MISMO CAJON

`C:\ACTUM` mezcla en la raiz: codigo en produccion, backups, datos de prueba, exports muertos, salidas de
consultas fallidas, instaladores y binarios del fabricante. Inventario de lo prescindible:

| Que | Tamano | Por que sobra |
|---|---|---|
| `Backup\*.bak` (2 ficheros de 2025) | **41 MB** | Backups SQL previos a una actualizacion de **febrero 2025** |
| `Instalador\` | **20 MB** | Instaladores `.msi`, ZNetCom, TestKerong. Utiles UNA vez |
| `Act2502\` `Act250212\` `Act250219\` | **10 MB** | Tres copias fechadas de los `.exe` del fabricante |
| `BACKUP_20260907\` | 11 MB | Copia forense de la averia. **Conservar hasta cerrar el incidente** |
| 4 backups de `MonitoreoLockerTiempoReal*.ps1` | 58 KB | `_v1_BACKUP`, `_BACKUP_20260421`, `_ANTES_20260907`, `_POSTB_20260907` |
| 3 backups de `GenerarDashboard*.ps1` | 70 KB | `_backup_20260218`, `_BACKUP_20260421`, `_ANTES_20260908` |
| `PRUEBA_HistorialCompleto.csv` + `PRUEBA_UltimoEventoProcesado.txt` | 53 KB | Restos del ensayo de reconstruccion del 07/09 |
| `ReconstruirHistorial_PRUEBA.ps1` | 9 KB | Idem |
| `UltimoEventoProcesado.txt` (en `C:\ACTUM`) | 24 B | **Leftover del 17/04 con BOM.** El real vive en OneDrive. **Trampa de diagnostico** — ya hizo perder tiempo el 30/04 |
| `Nuevo documento de texto.txt` | 0 B | Vacio |
| `tablas.txt` + `lista_tablas.txt` | 564 B | La misma lista, dos veces |
| `relaciones.txt` · `estructura_movimientos.txt` | 298 B | Salidas de consultas que devolvieron **0 filas** |
| `ejemplo_movimientos.txt` | 126 B | Un **mensaje de error de SQL** guardado como fichero |
| `EXPORT_*.txt` (8 ficheros) | 80 KB | De **febrero 2026** y con **encoding roto** (`C?mara Termogr?fica`) |
| `MoverArchivosOneDrive.ps1` | 1,5 KB | Migracion puntual de OneDrive personal a corporativo. **Ya hecha** |
| `ExportarLocker.ps1` | 2,3 KB | Escribe a `C:\Users\<user>\OneDrive\ReportesLocker` — ruta **personal que no existe**. Genera CSV pese a decir Excel |
| `Documentos - Acceso directo.lnk` | 1 KB | Acceso directo suelto |

### E. RIESGOS DETECTADOS (mas alla del desorden)

1. **Credenciales en texto plano.** `ACTUM_EPI\*\Par.txt` contiene servidor, base de datos, usuario **`sa`**
   y su contrasena en claro. Ademas los `.exe.config` llevan `User ID=sa;Password=actact` apuntando a
   **`ACTUM-JOSEP\SQLEXPRESS`** — el PC del fabricante. Esos `.config` estan obsoletos (el programa lee
   `Par.txt`), pero la credencial sigue ahi escrita. **No es accion nuestra: es del fabricante.** Anotado
   por si algun dia hay auditoria de IT.
2. **`GenerarDashboard.ps1` tiene un AUTO-UPDATE** (lineas 6-21): si aparece un `GenerarDashboard.ps1` mas
   nuevo en la carpeta de OneDrive, **lo copia a `C:\ACTUM` y lo ejecuta**. Dos caras:
   - **A favor:** es un canal de despliegue SIN TeamViewer que existe y **no se esta usando** (hoy no hay
     ningun `.ps1` en `LockerACTUM`). Subiendo el fichero por SharePoint, el locker se actualiza solo.
   - **En contra:** ejecuta lo que aparezca ahi. Si OneDrive sincroniza el fichero a medias, se ejecuta un
     script truncado. Y cualquiera con acceso a esa carpeta ejecuta codigo en el locker.
3. **El leftover `UltimoEventoProcesado.txt` de `C:\ACTUM`** no lo lee nadie hoy, pero esta a un cambio de
   ruta de convertirse en un marcador de abril. Borrarlo.
4. **El repo de desarrollo NO es espejo del locker.** Medido: `MonitoreoLockerTiempoReal.ps1` y
   `GenerarDashboard.ps1` son **identicos** (confirma que el parche del watchdog se desplego bien), pero
   `ActualizarExcel.ps1`, `ExportarLocker.ps1`, `MoverArchivosOneDrive.ps1` y `ConfigurarTareaOcultaVBS.ps1`
   **difieren**, y `GenerarDashboardAdmin.ps1` difiere solo en espacios finales.

### F. LO QUE ESTA BIEN DISENADO (no tocar)

- **La fuente de verdad es la tabla `Eventos` de SQL**, no un estado derivado. Permite reconstruir el
  historico entero desde octubre de 2024. Es la decision de arquitectura mas acertada del proyecto.
- **HTML estatico, sin JS funcional y sin CDN externos.** Es lo que lo hace visible en SharePoint web.
- **Todos los `.ps1` son ASCII puro** (medido: 0 caracteres no-ASCII en los cinco activos). Por eso el
  despliegue por copia-pega es viable.
- **El patron `.vbs` + `Run(..., 0, False)`** para ocultar la ventana funciona y esta bien documentado.
- **Un solo script imprescindible** (`MonitoreoLockerTiempoReal.ps1`) que invoca al resto por dot-sourcing.

### G. PROPUESTA — ORDEN SIN MOVER NADA QUE ESTE VIVO

> **Regla que manda aqui:** las rutas `C:\ACTUM\*.ps1` estan **cableadas en 5 ficheros `.vbs` y en 5 tareas
> programadas**. Mover un script activo obliga a reconfigurar todo eso, con riesgo real de dejar el sistema
> parado. **Los scripts activos NO se mueven.** Solo se aparta lo muerto.

```
C:\ACTUM\
├── ACTUM_EPI\                 <- del fabricante. NO TOCAR
├── MonitoreoLockerTiempoReal.ps1
├── GenerarDashboard.ps1            los 5 activos se quedan
├── GenerarDashboardAdmin.ps1       EXACTAMENTE donde estan
├── ActualizarExcel.ps1
├── ReconstruirHistorial.ps1        (rescate manual)
├── Ejecutar*.vbs  (los 4 buenos)
├── BACKUP_20260907\           <- conservar hasta cerrar el incidente
└── _ARCHIVO\                  <- NUEVA. Todo lo demas, sin borrar nada
    ├── backups_scripts\       (7 .ps1 historicos)
    ├── pruebas\               (PRUEBA_*, ReconstruirHistorial_PRUEBA.ps1)
    ├── exports_2026-02\       (EXPORT_*.txt, encoding roto)
    ├── obsoleto\              (MoverArchivosOneDrive.ps1, ExportarLocker.ps1,
    │                           ReconstruirSemanal.ps1 + su .vbs roto)
    ├── consultas_sueltas\     (tablas, lista_tablas, relaciones, estructura_*, ejemplo_*)
    └── instaladores\          (Instalador\, Act2502\, Act250212\, Act250219\, Backup\, Consignas\)
```

**Mover, no borrar** — salvo tres excepciones que si conviene eliminar:
`Nuevo documento de texto.txt` (0 bytes) · `UltimoEventoProcesado.txt` de `C:\ACTUM` (trampa de
diagnostico) · `Documentos - Acceso directo.lnk`.

**Ganancia medida:** la raiz pasa de **118 ficheros / 98 MB** a **~12 ficheros / ~17 MB** (contando
`ACTUM_EPI`), sin tocar una sola ruta de las que el sistema usa.

### H. VEREDICTO DE DISENO

**La arquitectura es correcta; lo que esta mal es la HIGIENE y la FRAGILIDAD DEL ULTIMO TRAMO.**

Lo que de verdad merece cambiarse de raiz, por orden:

1. **La dependencia de OneDrive + `fabricacion1`.** Es el unico tramo de toda la cadena que se rompe solo,
   cada ~50 dias, sin dar error. Todo lo demas (SQL, tareas, scripts) es robusto. Alternativas ya estudiadas
   el 20/05 y aun validas: **Microsoft Graph con App Registration y certificado** (no caduca nunca, sin
   coste, GHI ya tiene Entra ID) o **IIS local** sirviendo el HTML en `http://172.16.5.40` (cero cuentas,
   pendiente de verificar si las oficinas alcanzan esa subred).
2. **La falta de deteccion de fallo.** Sin respaldo humano, un fallo silencioso dura semanas. Ya paso.
3. **La higiene de `C:\ACTUM`** (apartado G).
4. **Usar el auto-update** que ya existe, para no depender de tener a alguien delante del PC.

### I. EL REPO DE DESARROLLO vs EL LOCKER — comparado el 08/09

Sujetos: `C:\ACTUM` del locker (descarga del 08/09 09:05) contra
`...\MIS PROYECTOS\LOCKER INSTRUMENTACION\`.

**Los 5 scripts activos estan alineados:**

| Fichero | Veredicto |
|---|---|
| `MonitoreoLockerTiempoReal.ps1` | **IDENTICO** byte a byte (v2.4) |
| `GenerarDashboard.ps1` | **IDENTICO** byte a byte (ya sin watchdog) |
| `ReconstruirHistorial.ps1` | **IDENTICO** |
| `GenerarDashboardAdmin.ps1` | equivalente — difiere solo en espacios finales de linea |
| `ActualizarExcel.ps1` | equivalente — solo espacios |

> Que los dos primeros salgan identicos es **verificacion independiente de los dos despliegues** de estos
> dias (v2.4 el 07/09 y watchdog el 08/09): no es que el parche dijera que fue bien, es que el fichero de
> produccion y el del repo son el mismo.

**Corregido el 08/09 — los `.vbs` no estaban respaldados:**
`EjecutarDashboardOculto.vbs`, `EjecutarAdminOculto.vbs` y `EjecutarExcelOculto.vbs` existian **solo en el
locker**; y `EjecutarMonitoreoOculto.vbs` del repo estaba **anticuado** (le faltaban `-NoProfile` y
`-WindowStyle Hidden`, que si tiene el de produccion). Copiados los 4 desde el locker: **verificado
IDENTICO** en los cuatro.

**`EjecutarReconstruccionOculto.vbs` NO se ha llevado al repo a proposito** — esta roto (apartado B) y su
tarea desactivada. Que no vuelva por la puerta de atras.

**Diferencia real que queda (sin importancia):** `ExportarLocker.ps1` difiere en 60 lineas entre ambos.
Es el script obsoleto que escribe a una ruta de OneDrive personal inexistente; va a `_ARCHIVO`.

### J. TRAMPAS DE DATOS EN EL REPO (no son produccion, pero lo parecen)

| Fichero en el repo | Que es realmente |
|---|---|
| `HistorialCompleto.csv` | **18 movimientos**, de 07/11/2025 a **17/02/2026**. Foto de hace 7 meses |
| `DashboardLocker.html` | Generado el **18/02/2026** |
| `Downloads\LockerACTUM\` (la descarga del 07/09 14:08) | CSV de **10.473.947 bytes** = la foto **EN PLENA AVERIA**, NO el estado actual |

Ninguno se usa. El sistema real vive en `C:\Users\User\OneDrive - GHI HORNOS INDUSTRIALES S.L\LockerACTUM\`
**del locker**. Pero se llaman igual que los de produccion: quien abra la carpeta dentro de unos meses puede
tomarlos por buenos. **Renombrar con sufijo `_MUESTRA_2026-02` o mover a una subcarpeta.**

### K. HALLAZGO — `ACTUM_EPI_Gestion.exe` NO ARRANCA SOLO

Medido el 08/09: `Get-CimInstance Win32_StartupCommand` filtrado por ACTUM devuelve **vacio**, y la carpeta
`Startup` del usuario tampoco lo tiene. **El motor del locker no se levanta con el PC.**

Contexto: el 08/09 el proceso no estaba corriendo y el ultimo evento en SQL era del **03/09 12:37:30** —
pero eso era **intencionado**: Inigo lo tenia cerrado a proposito mientras el sistema estaba averiado, y lo
reabrira cuando este todo arreglado. **No era una averia desatendida.**

> **Pero el riesgo estructural es real y sigue abierto:** con `ACTUM_EPI_Gestion.exe` abierto en uso normal,
> un corte de luz lo cierra, y **al volver el PC nadie lo reabre**. De poco sirve que la BIOS encienda el
> equipo si el programa que registra los movimientos se queda sin abrir. Y a diferencia del CSV,
> **lo que no se graba no se recupera**: no esta en ninguna parte.
>
> Cuando se reabra la aplicacion, dejarlo con arranque automatico (acceso directo en la carpeta `Startup`
> del usuario `User`, o clave `Run` del registro).

`Error_20260903.txt` guarda como murio la ultima vez, por si se repite:
```
14:05:10  Sin conexion / Modulo: modulGestio / Funcion: Main / Error: Error generico en GDI+
```
`Funcion: Main` = el hilo principal. Ahi se cerro el programa.

### L. CORRECCION IMPORTANTE — la pestana Estado NO lee el estado de SQL

La **regla 4** del incidente del 07/09 decia: *"Estado lee SQL (fiable aunque el CSV este destruido)"*.
**Es FALSO.** Leido en `GenerarDashboard.ps1:174-181`:

```powershell
$estado = if ($mov.Accion -like '*Extracci*') { 'En uso' } elseif ($mov.Accion -like '*Devoluci*') { 'Disponible' }
```

El estado y el usuario salen de **la ultima accion del CSV**, no de `Consigna.Estado`. De SQL solo se toma
la descripcion y el codigo del instrumento (`mapaCajas`). **Si el CSV esta mal, la pestana Estado miente.**

Consecuencias practicas:
- Un instrumento **sin ningun movimiento en el CSV no aparece** en el dashboard.
- El unico modo de saber si el dashboard dice la verdad es **compararlo contra `Consigna.Estado` de SQL**.
- Es tambien la razon de fondo de la limitacion conocida de las asignaciones administrativas.

> **La mejora pendiente desde el 20/05 (leer `Consigna.Usuario_Codigo` para la pestana Estado) es mas
> importante de lo que parecia:** no es un detalle de quien figura como usuario, es que **toda la columna
> Estado se deriva de un fichero de texto en vez de la fuente de verdad.**

### M. AUDITORIA DEL DASHBOARD — 08/09/2026 · EL DASHBOARD DICE LA VERDAD

Ejecutado `AuditarDashboard.ps1` (creado ese dia, solo lectura, tambien en el repo).

**1. CSV — SANO**

| Medida | Valor | Predicado |
|---|---|---|
| Lineas / unicas | **529 / 529** | ratio **1,00** (el 07/09 era ~600) |
| Duplicadas exactas | **0** | |
| Bytes NULL | **0** | ninguna escritura cortada por apagon |
| Mojibake / caracter de reemplazo | **0 / 0** | encoding intacto |
| Movimientos | **528** | fechas ilegibles: **0** |
| Rango real | **26/10/2024 17:50:27 -> 16/07/2026 13:20:21** | historico completo |
| Consigna 100 (sistema) | **0** | |
| Acciones | **Extraccion=264 · Devolucion=264** | alternancia coherente de punta a punta |

**2. HTML — CORRECTO**

- **562 `<tr>` = 528 movimientos + 32 instrumentos + 2 cabeceras.** Cuadra al digito.
- **15 En uso + 17 Disponible = 32.**
- **No-ASCII: 0** — la red de seguridad de encoding funciona.
- 246.461 bytes, regenerado a las 09:42:09 (las tareas corren).

**3. DASHBOARD vs `Consigna.Estado` de SQL — 32/32 COINCIDEN, 0 DISCREPAN**

> **Veredicto: lo que muestra el dashboard es verdad.** No queda ningun rastro del bucle de reprocesado
> ni de los datos corruptos.

**DOS MATICES sobre el alcance de esa verificacion (el "OK" no cubre todo):**

1. **La consigna 22 sale `OK` pero NO es un OK completo.** El script compara **solo el estado**, no el
   usuario. Ahi: SQL dice **IKER L. LASSO** y el dashboard dice **SERGIO V. VEGA**. Coinciden en *En uso*,
   difieren en quien. Es la correccion manual del 10/06, que no existe en la tabla `Eventos`.
   **Sigue pendiente de confirmacion fisica (tarea B).**
2. **En las consignas `Disponible`, `UsuarioSQL` sale vacio y `UsuarioDash` muestra un nombre. NO es un
   fallo:** el dashboard solo pinta el usuario cuando el instrumento esta *En uso*
   (`GenerarDashboard.ps1:182`); ese nombre del CSV es simplemente quien lo devolvio el ultimo, y en el HTML
   no se ve.

**Herramienta reutilizable:** `AuditarDashboard.ps1` (127 lineas · 6.259 bytes · ASCII puro · 0 errores de
sintaxis). Lanzar cuando se sospeche de los datos: `cd C:\ACTUM ; .\AuditarDashboard.ps1`.

### N. CORRECCIONES MANUALES QUE SOBREVIVEN — 2026-09-08

**Peticion de Inigo:** *"quiero que si cambio algo a mano por cualquier razon, se quede guardado,
que si lo he hecho es por algo"*.

**El problema de fondo:** las correcciones a mano y los datos automaticos vivian **en el mismo fichero**,
y ese fichero es regenerable. Una asignacion hecha desde el ACTUM EPI Visor **sin abrir el locker
fisicamente no genera evento en SQL**, asi que al reconstruir desde `Eventos` esas lineas desaparecian.
Era disciplina, no diseno: dependia de que nadie lanzase una reconstruccion.

**La solucion — separar las dos cosas:**

| Fichero | Que es | Se regenera? |
|---|---|---|
| `HistorialCompleto.csv` | Lo que dice la tabla `Eventos` | **SI** — desechable |
| `CorreccionesManuales.csv` | Lo que decide la persona | **NO** — se conserva y se reaplica |

**Implementado:** `ReconstruirHistorial.ps1` tiene un **PASO 2.5** que, antes de escribir el CSV, lee
`CorreccionesManuales.csv` y anade sus lineas al conjunto de movimientos. Como el orden final se hace por
fecha parseada, quedan en su sitio cronologico. Si el fichero no existe, se comporta como antes; si esta
mal formado, avisa en rojo y continua sin aplicarlo (nunca rompe la reconstruccion). Las fechas ilegibles
se omiten una a una con aviso.

**Formato** (`;` como delimitador, en `C:\Users\User\OneDrive - GHI...\LockerACTUM\`):
```
FechaHoraApertura;Usuario;Apellidos;Consigna;Descripcion;Accion;EstadoPuerta;Motivo
```
La columna **`Motivo` no se copia al historial**: solo documenta por que se hizo la correccion, para que
dentro de un ano se sepa. Fecha en `MM/dd/yyyy HH:mm:ss`, igual que el historial.

> **Para cambiar de usuario una consigna hacen falta DOS lineas:** la `Devolucion` del usuario equivocado
> y, unos segundos despues, la `Extraccion` del correcto. El estado se deriva de la ultima accion.

**Scripts nuevos en el repo** (los tres ASCII puro, 0 errores de sintaxis, validados con el parser):

| Script | Que hace |
|---|---|
| `CrearCorreccionesManuales.ps1` | Crea/rehace `CorreccionesManuales.csv`. Hace copia de seguridad si ya existia y **verifica leyendo el fichero escrito**, no la intencion |
| `AuditarDashboard.ps1` | Comprueba que el dashboard dice la verdad (CSV + HTML + comparacion con `Consigna.Estado`). Solo lectura |
| `ReconstruirHistorial.ps1` | Modificado: paso 2.5 |

**Contenido inicial:** las 4 lineas de SERGIO V. VEGA (consignas 18 y 22) del 10/06/2026, con su motivo.
Las correcciones de las consignas 13, 25, 29 y 30 **NO van aqui**: aquellas si existen en `Eventos` (eran
eventos reales que los bugs no capturaron), asi que una reconstruccion las recupera sola.

**DESPLEGADO Y VERIFICADO el 08/09** (246 y 76 lineas, 0 no-ASCII, 0 errores; 4 correcciones guardadas). Se copiaron `ReconstruirHistorial.ps1` y `CrearCorreccionesManuales.ps1`
a `C:\ACTUM\` y ejecutar una vez `CrearCorreccionesManuales.ps1`.

> **Ojo con las tildes:** nunca escribir `Devolucion`/`Extraccion` con tilde literal en un `.ps1`.
> `CrearCorreccionesManuales.ps1` las construye con `[char]0xF3`, como manda la regla del proyecto.

### O. RESUELTO — las rafagas de `Usuario = 0` son la ELECTRONICA, no aperturas con llave

**Confirmado el 08/09 con un caso provocado y de causa conocida.** Al abrir `ACTUM_EPI_Gestion.exe` a las
09:30 para una comprobacion, SQL registro esto:

| Momento | Causa | Eventos generados |
|---|---|---|
| **08/09 09:30:23** | **Se abre la app ACTUM (provocado por nosotros)** | `1` x**3** + `3` x**33** |
| 11/08 14:53 | Reconexion Kerong (tras la de las 14:52) | `1` x**3** + `3` x**33** |
| 07/09 13:17 | Arranque del PC tras el apagon de las 12:53 | `1` x**3** + `3` x**32** |

**Firma identica.** Cuando la electronica conecta, ACTUM re-lee el estado de todas las consignas y emite
un bloque de eventos `3` (puerta cerrada) con `Usuario_Codigo = 0`, precedido de 3 eventos `1`.

> **Esto CORRIGE lo anotado el 07/09**, donde estas rafagas se atribuyeron a *"aperturas manuales con llave
> y boton"*. La evidencia que lo descarta: **no hay ningun bloque equivalente de eventos `4` (puerta abre)**.
> Una apertura fisica con llave generaria ~32 aperturas antes de los 32 cierres. No las hay, ni el 11/08 ni
> el 07/09 ni el 08/09.

**No ensucian el historial.** Verificado el 08/09: tras el barrido de las 09:30, las ultimas lineas del CSV
seguian siendo de julio y abril. `MonitoreoLockerTiempoReal.ps1` solo procesa `Evento IN (10000, 10001)`
—identificaciones de usuario— e ignora los eventos de puerta. **No hay que hacer nada con ellas.**

> **Trampa de lectura documentada el mismo dia:** `Get-Content` sin `-Encoding UTF8` muestra
> `ExtracciÃ³n` / `DevoluciÃ³n` en PowerShell 5.1, porque lee como ANSI y un `o` acentuado en UTF-8 son dos
> bytes. **El fichero esta bien** — `AuditarDashboard.ps1`, que lee con `ReadAllText`, dio **mojibake 0**.
> Para inspeccionar el CSV a mano: `Get-Content ... -Encoding UTF8`.

> **Y que las correcciones manuales queden al final del fichero, fuera de orden cronologico, es normal.**
> Antes de la v2.4 eso disparaba el bucle (el marcador se tomaba de la ultima linea); ahora el marcador se
> calcula por el **maximo parseado** de todo el fichero, y el dashboard ordena por fecha al renderizar.

## Traspaso Codex — 2026-09-08 — protección de correcciones (LOCAL)

La descripción del apartado N es histórica: ya no se omiten correcciones inválidas ni se continúa sobrescribiendo.
El historial actual se compara con la última salida registrada; se conservan altas, cambios y borrados como
operaciones permanentes en `ProteccionHistorial.json`. `CorreccionesManuales.csv` sigue soportado y el
inicializador existente conserva sus bytes si ya existe. Las ediciones directas del historial prevalecen sobre
SQL y sobre las correcciones antiguas de la misma clave (fecha al segundo + número de consigna).

El monitor registra sus altas en la referencia de comparación, sin absorber cambios manuales pendientes.
Historial, marcador SQL y estado se guardan juntos mediante un diario recuperable, backups y reemplazos de
archivo. Una interrupción bloquea monitor/reconstrucción hasta `-RecuperarTransaccion`; una edición posterior
al fallo bloquea también la recuperación, para no sobrescribirla. El bloqueo compartido coordina scripts,
no editores humanos: pausar el monitor al editar; cerrar el editor antes de reanudar.

El marcador se calcula solo desde movimientos automáticos. Si se pierde, el monitor protegido usa el
marcador automático guardado en el estado, nunca una fecha manual del historial.
La primera adopción trata ausencias anteriores al marcador como borrados intencionales: revisar la
previsualización porque no puede distinguir un borrado previo de un fallo histórico de captura.

Validación local y revisión independiente: ver `RESULTS.jsonl`, `tests/resultado.json` y
`DESPLIEGUE_CORRECCIONES.md`. No se ha ejecutado SQL ni desplegado ni hecho commit/push.
Pendiente: copia por TeamViewer, verificación de archivos, previsualización sobre datos reales,
adopción revisada y comprobación de monitor con un movimiento real.

REFUERZO 2026-09-08 — protección de historial — las pruebas deben incluir un movimiento añadido por el
monitor y borrado por la persona antes de reconstruir. Caso medido: la primera versión local resucitaba
ese movimiento porque la referencia solo se guardaba al reconstruir; `tests/intermediate.json` registra el
fallo y `tests/Correcciones.Tests.ps1` contiene su regresión. No confundir mutex entre scripts con bloqueo de Excel.

### P. EL VIAJE AL LOCKER — 08/09/2026 tarde. **NIVEL 2 CERRADO**

Todo lo que estaba "reparado pero sin probar" queda **probado**.

#### P.1 · BIOS configurada ✅

`Restore AC Power Loss` estaba en **`Advanced` -> `Miscellaneous Configuration`** (BIOS AMI Aptio
2.17.1247). Puesta en **`Power On`**.
> Anotado para la proxima: NO esta en `Chipset` ni en `ACPI Settings`, que fue donde se busco primero.

#### P.2 · LA PRUEBA FUNCIONAL — **PASADA** ⭐

Extraccion y devolucion reales, consigna 03, usuario IÑIGO A. ALONSO (codigo 62):

```
09/08/2026 13:43:35;IÑIGO A.;ALONSO;03;Nivel Optico / LeicaNA730Plus / 5718201;Extraccion;Cerrada
09/08/2026 13:44:43;IÑIGO A.;ALONSO;03;Nivel Optico / LeicaNA730Plus / 5718201;Devolucion;Cerrada
```

| Predicado declarado antes | Resultado |
|---|---|
| **1 solo movimiento por accion fisica** | ✅ exactamente 2 lineas, ni una mas |
| Usuario correcto | ✅ |
| Accion correcta (Extraccion / Devolucion) | ✅ |
| Marcador avanzado a hoy, formato `yyyy-MM-dd HH:mm:ss` | ✅ `2026-09-08 13:44:43` |
| Reflejado en el dashboard | ✅ 247.309 bytes (530 movimientos) |

**La secuencia completa en SQL**, que ademas aclara la semantica de los eventos:
```
13:43:25  evento 4      puerta ABRE      consigna 3
13:43:35  evento 10000  IDENTIFICACION   consigna 3, usuario 62   <- extraccion
13:43:39  evento 3      puerta CIERRA    consigna 3
13:44:33  evento 4      puerta ABRE      consigna 3
13:44:43  evento 10001  IDENTIFICACION   consigna 3, usuario 62   <- devolucion
13:44:44  evento 3      puerta CIERRA    consigna 3
```
> **Confirma que `10000` y `10001` son ambos identificaciones validas, una por accion.** El filtro
> `Evento IN (10000, 10001)` de la v2.1 era correcto. Y el dedup de `$ventanaSeg = 3` no estorbo: las dos
> acciones distaban 68 s.

Tercera confirmacion de la firma de arranque: a las **13:42:29**, `1`x3 + `3`x33 (apartado O).

#### P.3 · HALLAZGO — el evento `1002` valida el dashboard desde otra fuente

Al revisar las consignas se generaron eventos **`1002`**, que **llevan el `Usuario_Codigo` asignado a cada
consigna**. Cruzados con el dashboard:

| Consigna | `1002` | Dashboard | |
|---|---|---|---|
| 19 · 26 · 27 | 62 | IÑIGO A. ALONSO | ✅ |
| 8 · 21 | 8 | IKER L. LASSO | ✅ |
| 2 · 15 | 51 | ALVARO T. TREPIANA | ✅ |
| 32 | 59 | AITOR U. ULIBARRI | ✅ |
| 13 | 26 | ANGEL F. FERNANDEZ | ✅ |
| 11 | 10 | IKER C. CAMIN | ✅ |
| 1 | 45 | ALVARO S. SAEZ | ✅ |
| 20 | 13 | ASIER R. RIAÑO | ✅ |
| 24 | 27 | FELIPE C. CAÑARTE | ✅ |
| **22** | **8 (IKER)** | **SERGIO V. VEGA** | ⚠️ la unica |

**Verificacion independiente y gratuita del dashboard entero.** Util para el futuro: si se quiere auditar
sin bajar al locker, basta abrir consignas y leer los `1002`.

#### P.4 · Auditoria fisica

- ~~**Consigna 22: VACIA** y pendiente de saber si lo tenia Sergio o Iker.~~ **RESUELTO 09/09:** lo tenia
  Sergio Vega y lo devolvio identificandose a las **11:52:50**; una sola fila para el nº **63862113**.
- **Resto de consignas revisadas: todo correcto.**
- **⚠️ CONSIGNA 5 — el instrumento NO esta.** El sistema la da *Disponible* (SQL `Estado=2`, instrumento
  `A-003`, sin usuario) y **fisicamente esta vacia**.
  - `A-003` = *Analizador de Gases / TESTO 340 / **61186226*** — **OJO, no confundir con el de la
    consigna 22, que es el nº 63862113. Son dos TESTO 340 distintos.**
  - Ultimo movimiento registrado: **30/04/2026 15:56:55, devolucion de DANIEL M. MARTINEZ**.
  - Alguien lo saco **sin identificarse** (con llave, o en una apertura manual), o se llevo a calibrar sin
    registrarlo. **No es un fallo del software:** es la limitacion de las acciones que no generan evento.
  - **Pendiente: preguntar a Daniel M. Martinez / mirar si esta en calibracion.**

#### P.5 · AUTO-LOGIN ARREGLADO — era un fallo grave escondido

Al reiniciar, Windows **pidio contrasena**. El registro tenia `AutoAdminLogon=1` correctamente, pero:

```
Ultimo cambio de contrasena:  03/08/2026 12:00:43
La contrasena expira:         14/09/2026 12:00:43   <- en 6 dias
```

**La contrasena de `User` se cambio el 3 de agosto y nadie actualizo la copia del arranque automatico.**

> **Por que era grave:** con la BIOS ya en `Power On`, tras un corte el PC se enciende **y se queda en la
> pantalla de contrasena**. Sin sesion iniciada no arrancan ni ACTUM ni las tareas. **La BIOS sola no
> servia de nada.** Se habria descubierto en el proximo apagon, es decir, tarde.

**Arreglado en dos pasos:**

1. **Quitada la caducidad.** `User` es una cuenta **LOCAL** del equipo (grupo local *Administradores*,
   grupo global *Ninguno*), asi que **no depende de la politica de IT** — al contrario que
   `fabricacion1@ghifurnaces.com`.
   ```powershell
   Set-LocalUser -Name "User" -PasswordNeverExpires $true
   ```
   **Verificado:** `net user User` -> *"La contrasena expira: **Nunca**"*.
2. **Regrabada la contrasena del arranque automatico** con `netplwiz`.
   > La casilla *"Los usuarios deben escribir su nombre y contrasena"* **no aparecia** (Windows la esconde
   > con Windows Hello). Se hace visible con:
   > ```powershell
   > Set-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\PasswordLess\Device" -Name DevicePasswordLessBuildVersion -Value 0
   > ```
   > Y si la casilla ya sale desmarcada, Windows no detecta cambio: hay que **marcarla -> Aplicar ->
   > desmarcarla -> Aceptar** para que pida la contrasena.

#### P.6 · REINICIO DE VERIFICACION — la cadena completa ✅

| Eslabon | Resultado |
|---|---|
| Windows entra **solo**, sin contrasena | ✅ arranque 14:32:35 |
| OneDrive arranca solo | ✅ 14:33:11 |
| Las 3 tareas | ✅ `Ready` |
| Dashboard regenerandose | ✅ 247.309 bytes a las 14:36:07 |
| ACTUM se abre solo | ✅ (Inigo lo vio; luego lo cerro para trabajar por TeamViewer) |

> **Con esto, tras un corte de corriente el locker vuelve solo: BIOS enciende -> Windows entra ->
> ACTUM arranca -> las tareas registran.** Es lo que convertia un apagon de 2 segundos en 12 horas
> (o 6 dias) de silencio.

**Efecto secundario menor — investigado y descartado como problema.** Al arrancar se abrio tambien el
explorador de archivos. Medido:

- `Startup` del usuario: **solo `ACTUM_EPI_Gestion.lnk`**, el nuestro. Limpio.
- `RestartApps` **no existe** en el registro: no era esa la causa.
- Causa probable: la opcion del propio Explorador *"Restaurar las ventanas de carpetas abiertas al iniciar
  sesion"* (`HKCU:\...\Explorer\Advanced\PersistBrowsers`). Inofensiva.

**De paso, inventario del arranque automatico:** `ACTUM_EPI_Gestion` · `OneDrive` · `SecurityHealth` ·
`Microsoft.Lists` · `Microsoft Edge Update` · **`MicrosoftEdgeAutoLaunch`** (este abre Edge en cada
inicio: ruido innecesario en un PC dedicado, se puede quitar).

---
