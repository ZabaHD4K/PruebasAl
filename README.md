# Social Credit Management — Extensión BC

Repositorio de aprendizaje de desarrollo AL para **Microsoft Dynamics 365 Business Central**.

Construido de forma incremental: cada ejercicio añade un módulo nuevo explorando una área distinta del desarrollo AL — tablas, páginas, codeunits, events, reports, APIs, control add-ins, job queues, test suites, xmlports, traducciones, etc.

> El objetivo no es hacer algo perfecto — es **aprender haciendo**.

---

## Índice

- [¿Qué es Social Credit?](#qué-es-social-credit)
- [Módulos implementados](#módulos-implementados)
- [Objetos AL](#objetos-al)
- [Estructura del proyecto](#estructura-del-proyecto)
- [Entorno y requisitos](#entorno-y-requisitos)
- [Cómo publicar la extensión](#cómo-publicar-la-extensión)

---

## ¿Qué es Social Credit?

Un sistema de **puntuación de fiabilidad de clientes** integrado en BC. Cada cliente tiene una puntuación (0–∞, valor inicial 1 000 puntos) que refleja su comportamiento comercial. La puntuación sube o baja manualmente o de forma automática.

### Rangos

| Puntos | Estado | Color BC |
|--------|--------|----------|
| ≥ 1 500 | 🟢 Ciudadano Ejemplar | `Favorable` |
| 1 000 – 1 499 | 🔵 Ciudadano Normal | `StandardAccent` |
| 500 – 999 | 🟡 Bajo Supervisión | `Attention` |
| < 500 | 🔴 Lista Negra | `Unfavorable` |

---

## Módulos implementados

### Ej. 1 — Social Credit básico

El núcleo del sistema.

- Campo `Social Credit Points` (Integer, min. 0, init. 1 000) y `Social Credit Label` (Text) añadidos a la tabla **Customer** vía TableExtension.
- **Codeunit `Social Credit Mgt`**: punto de entrada único para ajustar puntos (`AdjustCustomerPoints`), obtener estilos/etiquetas/rangos e inicializar clientes.
- **FactBox** en la ficha de cliente con puntos, estado y rango con coloración dinámica.
- **PageExtension** sobre Customer List: columna de puntos y estado coloreado.
- **PageExtension** sobre Customer Lookup: estado visible en la búsqueda de clientes.
- Codeunits de **Install** y **Upgrade** que inicializan los clientes a 1 000 puntos al publicar.

---

### Ej. 2 — Filtros y ordenación en la lista de clientes

Exploración interactiva de la base de clientes por nivel de Social Credit.

- Botones **↑ / ↓** para ordenar por puntos (soportados por el índice `SocialCreditKey`).
- Barra de 4 filtros visuales (🟢 🔵 🟡 🔴) combinables entre sí.
- Activar/desactivar cada nivel con un click — el botón muestra ✔ cuando está activo.
- Botón de acción **"Filtrar por nivel"** para mostrar/ocultar la barra.

---

### Ej. 3 — Social Credit Report

Ranking de todos los clientes ordenado por puntuación.

- Tabla temporal generada en tiempo real al abrir la página.
- Coloreado dinámico por rango en cada fila.
- Acciones de ordenación ascendente y descendente desde la barra.
- Exportable a PDF, Excel y CSV desde las opciones nativas de BC.

---

### Ej. 4 — Log de auditoría

Registro inmutable de cada cambio de puntuación.

- Tabla `Social Credit Log Entry` con: cliente, nombre, puntos antes/después, delta, fecha y hora, usuario y motivo.
- Todo cambio pasa obligatoriamente por `SocialCreditMgt.AdjustCustomerPoints` → el log nunca queda vacío.
- Página **Social Credit History** con historial completo y filtros.
- Acción **"Historial"** accesible desde la ficha de cliente y el Role Center.

---

### Ej. 5 — Job Queue: penalización por morosos

Codeunit para ejecutar cada noche vía el Job Queue de BC.

- Recorre todos los clientes y comprueba si tienen facturas abiertas y vencidas.
- Si las hay → resta **50 puntos** con motivo `"Por moroso cabrón"` y lo registra en el log.
- Configuración: `Object Type = Codeunit`, `Object ID = 50106`, todos los días a las `00:00`.

---

### Ej. 6 — Notificaciones de facturas vencidas

Al abrir la lista de clientes, el sistema escanea facturas abiertas con fecha de vencimiento pasada.

- Por cada factura vencida aparece una notificación en pantalla con número, cliente y fecha.
- Botón **"Ver factura XXXX"** en cada notificación que abre directamente la factura contabilizada.

---

### Ej. 7 — Validación SC en documentos de venta

PageExtensions sobre los 4 documentos de venta principales.

- Al seleccionar un cliente, se evalúa su rango de Social Credit.
- **Lista Negra** (< 500 pts): advertencia de bloqueo con opción de continuar o cancelar.
- **Bajo Supervisión** (500–999 pts): aviso informativo, sin bloqueo.
- Se aplica en: Pedidos, Facturas, Ofertas y Abonos de venta.

---

### Ej. 8 — API REST

Dos endpoints REST propios bajo el publisher `arbentia`, grupo `socialcredit`, versión `v1.0`.

**Clientes (`/customers`):**
```
GET .../api/arbentia/socialcredit/v1.0/companies({id})/customers
```
Campos: `id`, `name`, `city`, `email`, `socialCreditPoints`, `socialCreditLabel`, `socialCreditRank`

**Facturas (`/invoices`):**
```
GET .../api/arbentia/socialcredit/v1.0/companies({id})/invoices
```
Campos: `entryNo`, `customerNo`, `customerName`, `documentNo`, `postingDate`, `dueDate`, `open`, `amount`, `overdue`

Ambos de solo lectura. El campo `overdue` se calcula en tiempo real comparando `dueDate` con la fecha actual.

---

### Ej. 9 — Exportación de datos

Botón **"Exportar"** con 4 formatos disponible en tres páginas estándar de BC.

| Formato | Extensión | Notas |
|---------|-----------|-------|
| CSV | `.csv` | Separado por comas; compatible con Excel y Google Sheets |
| XML | `.xml` | Estructura jerárquica; estándar para integración con ERP |
| JSON | `.json` | Array de objetos; ideal para APIs y aplicaciones web |
| Excel | `.xlsx` | Nativo de Excel con formato numérico aplicado |

**Páginas con exportación:**
- **Lista de clientes** → No., Nombre, Ciudad, Teléfono, Email, Social Credit, Estado, Rango
- **Lista de proveedores** → No., Nombre, Ciudad, Teléfono, Email, Saldo (DL), Términos de pago
- **Lista de artículos** → No., Descripción, Stock, Precio venta, Coste, Categoría, Unidad de medida

---

### Ej. 10 — Permission Sets

Dos conjuntos de permisos para controlar el acceso al módulo.

| Permission Set | Caption | Acceso |
|----------------|---------|--------|
| `SC - Solo Lectura` | Social Credit - Read Only | Ver puntos, historial, ranking, API, chatbot |
| `SC - Gestión` | Social Credit - Management | Todo lo anterior + ajuste de puntos, job queue, exportación, notificaciones |

`SC - Gestión` incluye `SC - Solo Lectura` vía `IncludedPermissionSets`.

---

### Ej. 11 — Chatbot con IA

Chatbot integrado directamente en BC que responde preguntas sobre Social Credit en lenguaje natural.

- Usa la API de **OpenRouter** (o cualquier proveedor OpenAI-compatible).
- API Key almacenada en la tabla `SC Chat Setup` (cifrada con `ExtendedDatatype = Masked`).
- Interfaz tipo chat en tiempo real: el usuario escribe y el asistente responde.
- Historial de conversación en la tabla `SC Chat Line`.
- Accesible desde el Role Center y desde el hub de extensión.

---

### Ej. 12 — Slider JavaScript (Control Add-in)

Ajuste de puntos de Social Credit con un slider interactivo construido en JavaScript puro.

- Control Add-in con slider HTML/CSS/JS embebido en una página BC (Card).
- El valor del slider se sincroniza en tiempo real con BC vía `invokeExtensibilityMethod`.
- Al mover el slider → llama a `AdjustCustomerPoints` → puntos actualizados instantáneamente en la BD.
- Motivo de ajuste registrado en el log: `"Ajustado via Slider JS"`.

---

### Ej. 13 — Role Center completo

Dashboard dedicado al gestor del módulo Social Credit.

**Componentes:**

| Objeto | Tipo | Descripción |
|--------|------|-------------|
| `SC Role Center` | RoleCenter | Página principal del rol |
| `SC Cue Part` | CardPart | 4 KPIs con recuento de clientes por rango (FlowFields) |
| `SC Headline Part` | HeadlinePart | Titular con el peor cliente y media de puntos de todos |
| `SC Profile` | Profile | Perfil "Gestor Social Credit" asignado al Role Center |

El Role Center incluye accesos directos a todas las páginas del módulo organizados en secciones: Social Credit, Clientes y Ventas.

---

### Ej. 14 — PolyMarket Live

Mercados de predicción en tiempo real integrados directamente en BC.

- Carga los 48 mercados con mayor volumen desde la API pública de PolyMarket al abrir la página.
- Lista nativa BC con columnas: mercado destacado, pregunta, categoría, probabilidad Sí/No, volumen y fecha de cierre.
- **Coloración dinámica**: probabilidad ≥ 65 % → verde; 35–64 % → amarillo; < 35 % → rojo.
- **Búsqueda en tiempo real** sobre el campo combinado pregunta + categoría.
- Botón **"Recargar ahora"** para refrescar datos bajo demanda.
- Implementado como página BC List nativa (sin ControlAddin) con `HttpClient` server-side y tabla temporal `PolyMarket Market`.

---

### Ej. 15 — Importación / Exportación bidireccional

Sistema completo de importación y exportación de clientes con Social Credit automático.

**Exportación** (4 formatos, todos los clientes):
CSV · XML · JSON · Excel — incluyendo puntos, estado y rango SC.

**Importación** (4 formatos):
- Si el archivo **incluye** la columna de Social Credit → se aplica el valor del archivo.
- Si el archivo **no incluye** Social Credit → se asignan **1 000 puntos por defecto**.
- Si el cliente ya existe → se actualizan sus datos y se ajustan los puntos vía delta.
- **Garantía de auditoría**: todo ajuste de SC pasa por `AdjustCustomerPoints` → queda en el log.

**XMLport nativo** (`SC Customer Xmlport`, bidireccional):
- `Direction = Both` — BC pregunta la dirección al ejecutar.
- Triggers `OnBeforeInsertRecord` / `OnAfterInsertRecord` para nuevos clientes.
- Triggers `OnBeforeModifyRecord` / `OnAfterModifyRecord` para existentes (calcula delta y llama `AdjustCustomerPoints`).

Formatos soportados para importación manual:

| Formato | Cabeceras / Estructura |
|---------|----------------------|
| CSV | `No.,Nombre,Ciudad,Telefono,Email,Social Credit` |
| XML | `<Customers><Customer><No>…</No><Name>…</Name>…</Customer></Customers>` |
| JSON | `[{"no":"…","name":"…","city":"…","socialCreditPoints":1000}]` |
| Excel | Hoja llamada `"Clientes"`, cabeceras en fila 1 (orden flexible) |

---

### Ej. 16 — Test Suite (AL Test Codeunit)

Suite de tests automatizados para validar el comportamiento del módulo.

- **Codeunit 50149 `SC Test Suite`** con subtipo `Test`.
- Usa `LibraryERM` para crear facturas reales (no inserciones directas en Cust. Ledger Entry).
- Claves de cliente generadas con `CreateGuid()` para evitar colisiones entre tests.
- Limpieza de datos en `OnAfterEach` con reversión de transacciones contables.

Tests incluidos:
- `TestAdjustPoints` — verifica que los puntos suben/bajan correctamente.
- `TestMinimumPoints` — verifica que los puntos nunca bajan de 0.
- `TestLogEntry` — verifica que cada ajuste deja entrada en el log.
- `TestDeductMorosos` — verifica la penalización automática por facturas vencidas.

---

### Ej. 17 — Manifiesto AppSource (`app.json`)

`app.json` configurado como si la extensión fuera a publicarse en AppSource.

- `privacyStatement`, `EULA`, `help`, `url` → URLs de Arbentia.
- `logo`, `screenshots` → rutas en `res/`.
- Dependencias declaradas: **System Application** + **Base Application** (BC 27.0).
- `resourceExposurePolicy`: descarga de fuentes desactivada.
- `contextSensitiveHelpUrl` configurada.
- `supportedLocales`: `["es-ES", "en-US"]`.
- Feature `TranslationFile` activada para que el compilador genere el `.g.xlf`.

---

### Ej. 18 — Archivo de traducción (XLIFF)

Archivo de traducción al inglés para todo el módulo.

- **Formato**: XLIFF 1.2 (estándar de BC).
- **Ruta**: `Translations/SocialCreditManagement.en-US.xlf`.
- `source-language="es-ES"` (captions del código AL) → `target-language="en-US"`.

Cobertura del archivo:

| Objeto | Elementos traducidos |
|--------|---------------------|
| `Table 50102` Social Credit Log Entry | Caption de tabla + 9 campos (Entry No., Customer No., Name, Points Before/After, Change, DateTime, User ID, Reason) |
| `TableExtension 50100` | Campos Social Credit Points y Social Credit Label |
| `PermissionSet 50100` SC - Solo Lectura | Caption → "Read Only" |
| `PermissionSet 50101` SC - Gestión | Caption → "Management" |
| `Profile SC_ROLE_CENTER` | Caption + ProfileDescription |
| `Page 50117` SC Role Center | Caption + todos los grupos, acciones y ToolTips |
| `Page 50115` SC Cue Part | Caption + 4 cues con ToolTips |
| `Page 50116` SC Headline Part | Caption |
| `Page 50100` FactBox | Caption + 3 campos |
| `Page 50101` Social Credit Adjust | Caption + grupos, campos, acciones y ToolTips |
| `Page 50113` Extension SC (hub) | Caption + grupos + todas las acciones |
| `Page 50119` SC Import Export | Caption + grupos + 9 acciones |
| `XmlPort 50100` SC Customer Xmlport | Caption |
| `Page 50118` PolyMarket Live | Caption + búsqueda + 2 acciones |

---

## Objetos AL

### Tablas

| ID | Nombre | Tipo | Descripción |
|----|--------|------|-------------|
| — (ext) | `Customer Social Credit Ext` | TableExtension | Añade `Social Credit Points`, `Social Credit Label` e índice `SocialCreditKey` a Customer |
| 50102 | `Social Credit Log Entry` | Table | Auditoría de todos los cambios de puntos (Entry No., Customer, Points Before/After, Change, DateTime, User ID, Reason) |
| 50103 | `SC Report Line` | Table (Temporary) | Líneas del ranking de Social Credit generadas en tiempo real |
| 50104 | `SC Chat Setup` | Table | Almacena la API Key del chatbot (enmascarada) |
| 50105 | `SC Cue` | Table | Tabla de Cues con FlowFields que cuentan clientes por rango |
| 50106 | `SC Chat Line` | Table | Historial de mensajes del chatbot (rol + contenido) |
| 50107 | `PolyMarket Market` | Table (Temporary) | Datos en memoria de los mercados de predicción cargados desde la API |
| 50108 | `PolyMarket Setup` | Table | URL base de la API de PolyMarket |

### Codeunits

| ID | Nombre | Descripción |
|----|--------|-------------|
| 50101 | `Social Credit Mgt` | Lógica central: `AdjustCustomerPoints`, `GetStyle/Label/Rank`, log, inicialización |
| 50102 | `Social Credit Check Subscriber` | Suscriptor de eventos para validaciones SC en documentos de venta |
| 50103 | `Install Social Credit` | Inicializa todos los clientes a 1 000 puntos en la instalación |
| 50104 | `Upgrade Social Credit` | Sincroniza etiquetas al republicar la extensión |
| 50106 | `SC Deduct Morosos` | Job Queue nocturno: resta 50 pts a clientes con facturas vencidas |
| 50107 | `SC Overdue Notifier` | Notificaciones de facturas vencidas al abrir la lista de clientes |
| 50108 | `SC Chat Mgt` | Lógica del chatbot: llamada a la API de IA, gestión del historial |
| 50110 | `SC Export Mgt` | Exportación e importación de clientes/proveedores/artículos en CSV, XML, JSON y Excel |
| 50149 | `SC Test Suite` | Test codeunit con casos de prueba para el módulo SC |

### Páginas propias

| ID | Nombre | Tipo | Descripción |
|----|--------|------|-------------|
| 50100 | `Customer Social Credit FactBox` | CardPart | FactBox con puntos, estado y rango en la ficha de cliente |
| 50101 | `Social Credit Adjust` | Card | Ajuste manual de puntos con motivo |
| 50102 | `Social Credit History` | List | Historial del log de cambios de Social Credit |
| 50103 | `SC Sel Cust Part` | ListPart | Parte de selección de cliente para el ajuste |
| 50105 | `Social Credit Report` | List | Ranking de todos los clientes por puntuación |
| 50108 | `SC Customer API` | API | Endpoint REST de solo lectura para clientes |
| 50109 | `SC Invoice API` | API | Endpoint REST de solo lectura para facturas |
| 50110 | `SC Chat Lines` | ListPart | Burbuja de mensajes del chatbot |
| 50111 | `SC Chat` | Card | Chatbot con IA para consultas sobre Social Credit |
| 50112 | `SC Chat Setup Page` | NavigatePage | Configuración de la API Key del chatbot |
| 50113 | `Extension SC` | Card | Hub central de la extensión con todos los accesos |
| 50114 | `SC Slider` | Card | Ajuste de puntos con slider JavaScript interactivo |
| 50115 | `SC Cue Part` | CardPart | 4 KPIs por rango de clientes (FlowFields) |
| 50116 | `SC Headline Part` | HeadlinePart | Peor cliente y media de puntos de todos los clientes |
| 50117 | `SC Role Center` | RoleCenter | Dashboard principal del módulo SC |
| 50118 | `PolyMarket` | List | Mercados de predicción en tiempo real desde la API de PolyMarket |
| 50119 | `SC Import Export` | Card | Importación y exportación de clientes en CSV, XML, JSON y Excel |

### PageExtensions sobre páginas estándar de BC

| ID | Nombre | Extiende | Añade |
|----|--------|----------|-------|
| 50100 | `Customer List Social Credit` | Customer List | Columna de puntos y estado SC |
| 50101 | `Customer Card Social Credit` | Customer Card | FactBox SC y acción de ajuste |
| 50102 | `Customer Lookup Social Credit` | Customer Lookup | Columna de estado en búsqueda |
| 50103 | `Sales Order Social Credit` | Sales Order | Validación SC al seleccionar cliente |
| 50104 | `Sales Quote Social Credit` | Sales Quote | Validación SC al seleccionar cliente |
| 50105 | `Sales Invoice Social Credit` | Sales Invoice | Validación SC al seleccionar cliente |
| 50106 | `Sales Cr. Memo Social Credit` | Sales Credit Memo | Validación SC al seleccionar cliente |
| 50107 | `Vendor List Export` | Vendor List | Acción de exportación |
| 50108 | `Item List Export` | Item List | Acción de exportación |

### Otros objetos

| ID | Nombre | Tipo | Descripción |
|----|--------|------|-------------|
| 50100 | `SC - Solo Lectura` | PermissionSet | Acceso de solo lectura al módulo |
| 50101 | `SC - Gestión` | PermissionSet | Acceso completo de gestión |
| 50100 | `SC Customer Xmlport` | XmlPort | Exportación/importación bidireccional de clientes en XML con log SC garantizado |
| — | `SC_ROLE_CENTER` | Profile | Perfil "Gestor Social Credit" asignado al Role Center SC |

---

## Estructura del proyecto

```
AL/
├── app.json                              ← Manifiesto AppSource (BC 27, es-ES + en-US)
├── Translations/
│   └── SocialCreditManagement.en-US.xlf ← Traducción completa al inglés (XLIFF 1.2)
├── src/
│   ├── Codeunit/
│   │   ├── SocialCreditMgt.Codeunit.al           ← Lógica central (AdjustCustomerPoints)
│   │   ├── SocialCreditCheckSubscriber.Codeunit.al
│   │   ├── InstallSocialCredit.Codeunit.al
│   │   ├── UpgradeSocialCredit.Codeunit.al
│   │   ├── SCDeductMorosos.Codeunit.al            ← Job Queue morosos
│   │   ├── SCOverdueNotifier.Codeunit.al
│   │   ├── SCChatMgt.Codeunit.al                  ← Chatbot IA
│   │   ├── SCExportMgt.Codeunit.al                ← Export + Import CSV/XML/JSON/Excel
│   │   └── SCTestSuite.Codeunit.al                ← Test suite
│   ├── ControlAddin/
│   │   ├── SCSliderAddin.ControlAddin.al          ← Slider JavaScript
│   │   ├── PMAddin.ControlAddin.al
│   │   └── js/
│   │       └── pm.js
│   ├── Page/
│   │   ├── CustomerSocialCreditFactBox.Page.al
│   │   ├── SocialCreditAdjustPage.Page.al
│   │   ├── SocialCreditHistoryChart.Page.al
│   │   ├── SocialCreditSelCustPart.Page.al
│   │   ├── SocialCreditReport.Page.al
│   │   ├── SCCustomerAPI.Page.al
│   │   ├── SCInvoiceAPI.Page.al
│   │   ├── SCChatLines.Page.al
│   │   ├── SCChat.Page.al
│   │   ├── SCChatSetupPage.Page.al
│   │   ├── ExtensionSC.Page.al                    ← Hub central (50113)
│   │   ├── SCSliderPage.Page.al
│   │   ├── SCCuePart.Page.al
│   │   ├── SCHeadlinePart.Page.al
│   │   ├── SCRoleCenter.Page.al
│   │   ├── PolyMarketPage.Page.al
│   │   └── SCImportExport.Page.al
│   ├── PageExtension/
│   │   ├── CustomerListExt.PageExt.al
│   │   ├── CustomerCardExt.PageExt.al
│   │   ├── CustomerLookupExt.PageExt.al
│   │   ├── SalesOrderExt.PageExt.al
│   │   ├── SalesQuoteExt.PageExt.al
│   │   ├── SalesInvoiceExt.PageExt.al
│   │   ├── SalesCreditMemoExt.PageExt.al
│   │   ├── VendorListExt.PageExt.al
│   │   └── ItemListExt.PageExt.al
│   ├── PermissionSet/
│   │   ├── SCSoloLectura.PermissionSet.al
│   │   └── SCGestion.PermissionSet.al
│   ├── Profile/
│   │   └── SCProfile.Profile.al
│   ├── Report/
│   │   └── SocialCreditReport.Report.al           ← RDLC report
│   ├── Table/
│   │   ├── SocialCreditLogEntry.Table.al           ← Log de auditoría
│   │   ├── SocialCreditReportLine.Table.al
│   │   ├── SCChatSetup.Table.al
│   │   ├── SCChatLine.Table.al
│   │   ├── SCCue.Table.al
│   │   ├── PolyMarketSetup.Table.al
│   │   └── PolyMarketMarket.Table.al
│   ├── TableExtension/
│   │   └── CustomerTableExt.TableExt.al
│   └── Xmlport/
│       └── SCCustomerXmlport.Xmlport.al            ← Bidireccional, log garantizado
└── res/
    ├── logo.png
    └── screenshots/
        ├── 01-role-center.png
        ├── 02-customer-list.png
        ├── 03-adjust-points.png
        ├── 04-history.png
        └── 05-sales-order-warning.png
```

---

## Entorno y requisitos

| | |
|---|---|
| **BC Version** | Business Central 27.5 (ES Sandbox) |
| **Runtime** | AL 13.0 |
| **Target** | Cloud (SaaS) |
| **Publisher** | Arbentia |
| **ID Range** | 50100 – 50149 |
| **Idiomas** | es-ES (base), en-US (traducción XLIFF) |
| **Features** | `NoImplicitWith`, `TranslationFile` |

---

## Cómo publicar la extensión

### Requisitos previos

- [Visual Studio Code](https://code.visualstudio.com/) con la extensión [AL Language](https://marketplace.visualstudio.com/items?itemName=ms-dynamics-smb.al)
- [Docker Desktop](https://www.docker.com/products/docker-desktop/) en modo **Windows Containers**
- PowerShell con `BcContainerHelper`:
  ```powershell
  Install-Module BcContainerHelper -Force
  ```

### 1. Clonar el repositorio

```bash
git clone https://github.com/ZabaHD4K/PruebasAl.git
cd PruebasAl
```

### 2. Crear un contenedor BC local

```powershell
Import-Module BcContainerHelper

$credential = Get-Credential -UserName "admin" -Message "Elige una contraseña para BC"

New-BcContainer `
    -accept_eula `
    -containerName "bc-dev" `
    -artifactUrl (Get-BCArtifactUrl -type Sandbox -country "es" -select Latest) `
    -credential $credential `
    -auth NavUserPassword `
    -updateHosts `
    -includeAL `
    -memoryLimit 8G
```

> La primera vez tarda ~15–20 min descargando la imagen. Solo hay que hacerlo una vez.

### 3. Descargar símbolos y publicar

```
Ctrl+Shift+P → AL: Download Symbols
```

Introduce usuario `admin` y la contraseña elegida, luego:

```
F5  →  BC se abre en el navegador con la extensión activa
```

> Si los clientes no muestran puntos de Social Credit, abre la lista de clientes y pulsa **Extension SC → Ajustar puntos** para inicializarlos.

### 4. Configurar el chatbot (opcional)

Abre la página **Chat IA**, pega tu API Key de [OpenRouter](https://openrouter.ai) y pulsa **Guardar**. La clave queda almacenada de forma segura en `SC Chat Setup`.

### 5. Configurar el Job Queue (opcional)

Para activar la penalización nocturna por morosos:

1. Busca **Job Queue Entries** → New
2. `Object Type to Run` = Codeunit, `Object ID` = **50106**
3. Marca todos los días, `Starting Time` = `00:00:00`
4. Estado → **Ready**

---

## Checklist de ejercicios

- [x] Ej. 1 — Social Credit básico (tabla ext, codeunit, FactBox, Customer List/Card)
- [x] Ej. 2 — Filtros y ordenación en la lista de clientes
- [x] Ej. 3 — Social Credit Report (ranking temporal)
- [x] Ej. 4 — Log de auditoría (Social Credit Log Entry)
- [x] Ej. 5 — Job Queue: penalización automática por morosos
- [x] Ej. 6 — Notificaciones de facturas vencidas
- [x] Ej. 7 — Validación SC en documentos de venta (pedido, factura, oferta, abono)
- [x] Ej. 8 — API REST (clientes + facturas, solo lectura)
- [x] Ej. 9 — Exportación CSV / XML / JSON / Excel
- [x] Ej. 10 — Permission Sets (Solo Lectura + Gestión)
- [x] Ej. 11 — Chatbot con IA (OpenRouter / OpenAI)
- [x] Ej. 12 — Slider JavaScript (Control Add-in)
- [x] Ej. 13 — Role Center, Cues, Headlines y Profile
- [x] Ej. 14 — PolyMarket Live (API externa, tabla temporal, lista nativa BC)
- [x] Ej. 15 — Importación bidireccional CSV / XML / JSON / Excel + XMLport nativo
- [x] Ej. 16 — Test Suite (AL Test Codeunit con LibraryERM)
- [x] Ej. 17 — Manifiesto AppSource completo (`app.json`)
- [x] Ej. 18 — Archivo de traducción XLIFF 1.2 (en-US)
