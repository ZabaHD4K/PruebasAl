# PruebasAL — Mega Extensión de Business Central

Repositorio de aprendizaje de desarrollo AL para **Microsoft Dynamics 365 Business Central**.
Este repo nace como un proyecto práctico y va creciendo con cada nueva funcionalidad aprendida, sirviendo como referencia real de cómo extender BC desde cero.

---

## ¿Qué es esto?

Una extensión de BC construida de forma incremental. Cada módulo añade algo nuevo al sistema, explorando distintas áreas del desarrollo AL: tablas, páginas, codeunits, eventos, reportes, API pages, job queues, etc.

El objetivo no es hacer algo perfecto — es **aprender haciendo**.

---

## Módulos actuales

### 🏅 Social Credit System

El primer módulo implementado. Añade un sistema de **puntos de crédito social** a los clientes de BC.

**Qué hace:**
- Añade el campo `Social Credit Points` (por defecto 1000) a cada cliente
- Muestra el estado del cliente con colores y emojis en toda la interfaz
- Aparece en: lista de clientes, ficha de cliente, lookups, dropdowns, mini tarjetas y documentos de venta
- Permite ajustar puntos manualmente con registro de motivo y auditoría completa

**Rangos:**
| Puntos | Icono | Rango |
|--------|-------|-------|
| ≥ 1500 | 🟢 | Ciudadano Ejemplar |
| ≥ 1000 | 🔵 | Ciudadano Normal |
| ≥ 500  | 🟡 | Bajo Supervisión |
| < 500  | 🔴 | Lista Negra |

---

### 🔍 Filtros y Ordenación en Lista de Clientes

Añadidos directamente sobre la lista de clientes para explorar la base de clientes por nivel de Social Credit de forma visual e interactiva.

**Ordenación:**
- Botón **↓ Mayor a menor** — ordena por puntos de mayor a menor
- Botón **↑ Menor a mayor** — ordena por puntos de menor a mayor
- Basado en un índice dedicado en la tabla (`SocialCreditKey`) para garantizar rendimiento

**Filtros por nivel (barra interactiva):**
- Barra de 4 botones visuales encima de la lista de clientes
- Cada botón representa un nivel: 🟢 🔵 🟡 🔴
- **Click** activa el filtro (el botón cambia de color y muestra ✔)
- **Click de nuevo** lo desactiva
- Se pueden **combinar varios niveles** a la vez — por ejemplo, ver solo rojos y azules simultáneamente
- La barra se puede mostrar/ocultar con el botón **"Filtrar por nivel"** en la barra de acciones

---

### 📊 Social Credit Report

Página de ranking que muestra todos los clientes ordenados por puntuación de Social Credit.

- Tabla temporal generada en tiempo real al abrir la página
- Ordenación ascendente y descendente desde la barra de acciones
- Cada fila incluye: Nº cliente, nombre, puntos, estado y rango
- Coloreado dinámico según el nivel de cada cliente
- Accesible desde la lista de clientes con el botón **"Social Credit Report"**

---

### ⚙️ Job Queue — Penalización por Morosos

Codeunit diseñado para ejecutarse cada noche mediante el **Job Queue** de BC.

**Comportamiento:**
- Recorre todos los clientes
- Si el cliente tiene alguna factura **abierta y vencida** (fecha de vencimiento anterior a hoy) → resta **50 puntos**
- El cambio queda registrado en el log con el motivo `"Por moroso cabrón"`
- Si no hay facturas vencidas, no se aplica ninguna penalización

**Configuración en BC:**
1. Buscar **Job Queue Entries** → New
2. `Object Type to Run` = Codeunit | `Object ID` = **50106**
3. Marcar todos los días, `Starting Time` = `00:00:00`
4. Estado → **Ready**

---

### 🔔 Notificaciones de Facturas Vencidas

Al abrir la lista de clientes, el sistema comprueba automáticamente si existen facturas abiertas con fecha de vencimiento anterior a hoy.

- Por cada factura vencida se muestra una **notificación** en pantalla con el número de factura, nombre del cliente y fecha de vencimiento
- Cada notificación incluye el botón **"Ver factura XXXX"** que abre directamente la página de esa factura contabilizada

---

### 🌐 API REST — Social Credit

Dos endpoints REST propios publicados bajo el publisher `arbentia`, grupo `socialcredit`, versión `v1.0`.

**Clientes:**
```
GET http://bc-dev:7048/BC/api/arbentia/socialcredit/v1.0/companies({id})/customers
```
Campos: `id`, `name`, `city`, `email`, `socialCreditPoints`, `socialCreditLabel`, `socialCreditRank`

**Facturas:**
```
GET http://bc-dev:7048/BC/api/arbentia/socialcredit/v1.0/companies({id})/invoices
```
Campos: `entryNo`, `customerNo`, `customerName`, `documentNo`, `postingDate`, `dueDate`, `open`, `amount`, `overdue`

Ambos endpoints son de **solo lectura** (`InsertAllowed`, `ModifyAllowed`, `DeleteAllowed` = false). El campo `overdue` se calcula en tiempo real.

---

### 📤 Exportación de Datos (CSV / XML / JSON / Excel)

Botón **"Exportar"** disponible en tres páginas de BC con 4 formatos de descarga:

| Formato | Extensión | Descripción |
|---------|-----------|-------------|
| CSV | `.csv` | Separado por comas, compatible con cualquier hoja de cálculo |
| XML | `.xml` | Estructura jerárquica estándar |
| JSON | `.json` | Formato ideal para integraciones y APIs |
| Excel | `.xlsx` | Archivo nativo de Excel con formato numérico |

**Páginas con exportación:**

- **Lista de Clientes** → No., Nombre, Ciudad, Teléfono, Email, Social Credit, Estado, Rango
- **Lista de Proveedores** → No., Nombre, Ciudad, Teléfono, Email, Saldo, Términos de pago
- **Lista de Artículos (Inventario)** → No., Descripción, Stock, Precio venta, Coste, Categoría, Unidad de medida

---

### 🔐 Permisos (Permission Sets)

Dos conjuntos de permisos incluidos en la extensión para controlar el acceso al módulo:

| Permission Set | Descripción |
|----------------|-------------|
| `SC - Solo Lectura` | Acceso de solo lectura: ve puntos, estado, historial, ranking y API. |
| `SC - Gestión` | Acceso completo: todo lo de Solo Lectura + ajuste de puntos, job queue, exportación y notificaciones. |

---

## Objetos AL

| Objeto | Tipo | ID | Descripción |
|--------|------|----|-------------|
| `CustomerTableExt` | TableExtension | — | Añade `Social Credit Points`, `Social Credit Label` e índice `SocialCreditKey` a Customer |
| `SocialCreditLogEntry` | Table | 50100 | Tabla de auditoría con todos los cambios de puntos |
| `SC Report Line` | Table (Temporary) | 50103 | Tabla temporal para las líneas del ranking de Social Credit |
| `SocialCreditMgt` | Codeunit | 50101 | Lógica central: estilos, etiquetas, rangos, log de cambios e inicialización |
| `SocialCreditCheckSubscriber` | Codeunit | 50102 | Suscriptor de eventos para validaciones automáticas |
| `InstallSocialCredit` | Codeunit | 50103 | Inicializa todos los clientes a 1000 puntos en la instalación |
| `UpgradeSocialCredit` | Codeunit | 50104 | Sincroniza datos al republicar la extensión |
| `SC Deduct Morosos` | Codeunit | 50106 | Job Queue nocturno: resta 50 pts a clientes con facturas vencidas |
| `SC Overdue Notifier` | Codeunit | 50107 | Muestra notificaciones al abrir la lista de clientes si hay facturas vencidas |
| `SC Export Mgt` | Codeunit | 50110 | Lógica de exportación en CSV, XML, JSON y Excel para clientes, proveedores e inventario |
| `CustomerSocialCreditFactBox` | Page (CardPart) | — | Panel lateral con estado, rango y puntos del cliente seleccionado |
| `SocialCreditAdjustPage` | Page | — | Panel para subir/bajar puntos con motivo |
| `SocialCreditHistory` | Page | — | Historial completo de cambios de un cliente |
| `Social Credit Report` | Page | 50105 | Ranking de todos los clientes ordenado por puntuación de Social Credit |
| `SC Customer API` | Page (API) | 50108 | Endpoint REST de solo lectura para clientes con Social Credit |
| `SC Invoice API` | Page (API) | 50109 | Endpoint REST de solo lectura para facturas de clientes |
| `CustomerListExt` | PageExtension | 50100 | Icono, estado, barra de filtros, ordenación, FactBox y exportación |
| `CustomerCardExt` | PageExtension | 50101 | Campos Social Credit en la ficha del cliente |
| `CustomerLookupExt` | PageExtension | 50102 | Icono de estado en el lookup de selección de clientes |
| `SalesOrderExt` | PageExtension | 50103 | Etiqueta de estado en pedidos de venta |
| `SalesInvoiceExt` | PageExtension | 50105 | Etiqueta de estado en facturas de venta |
| `SalesQuoteExt` | PageExtension | 50104 | Etiqueta de estado en presupuestos |
| `SalesCreditMemoExt` | PageExtension | 50106 | Etiqueta de estado en abonos de venta |
| `VendorListExt` | PageExtension | 50107 | Botón de exportación en la lista de proveedores |
| `ItemListExt` | PageExtension | 50108 | Botón de exportación en la lista de artículos |
| `SC - Solo Lectura` | PermissionSet | 50100 | Permisos de solo lectura para el módulo |
| `SC - Gestión` | PermissionSet | 50101 | Permisos completos de gestión |

---

## Entorno

- **BC Version:** Business Central 27.5 (ES Sandbox)
- **AL Language Extension:** VS Code
- **Docker:** contenedor local `bc-dev` con BcContainerHelper
- **Publisher:** Arbentia
- **ID Range:** 50100 – 50149

---

## Estructura del proyecto

```
src/
├── Codeunit/
│   ├── InstallSocialCredit.Codeunit.al
│   ├── UpgradeSocialCredit.Codeunit.al
│   ├── SocialCreditMgt.Codeunit.al
│   ├── SocialCreditCheckSubscriber.Codeunit.al
│   ├── SCDeductMorosos.Codeunit.al          ← job queue penalización morosos
│   ├── SCOverdueNotifier.Codeunit.al        ← notificaciones facturas vencidas
│   └── SCExportMgt.Codeunit.al              ← exportación CSV/XML/JSON/Excel
├── Page/
│   ├── CustomerSocialCreditFactBox.Page.al
│   ├── SocialCreditAdjustPage.Page.al
│   ├── SocialCreditHistoryChart.Page.al
│   ├── SocialCreditSelCustPart.Page.al
│   ├── SocialCreditReport.Page.al           ← ranking de clientes
│   ├── SCCustomerAPI.Page.al                ← API REST clientes
│   └── SCInvoiceAPI.Page.al                 ← API REST facturas
├── PageExtension/
│   ├── CustomerListExt.PageExt.al           ← filtros, ordenación, exportación
│   ├── CustomerCardExt.PageExt.al
│   ├── CustomerLookupExt.PageExt.al
│   ├── SalesOrderExt.PageExt.al
│   ├── SalesInvoiceExt.PageExt.al
│   ├── SalesQuoteExt.PageExt.al
│   ├── SalesCreditMemoExt.PageExt.al
│   ├── VendorListExt.PageExt.al             ← exportación proveedores
│   └── ItemListExt.PageExt.al               ← exportación inventario
├── PermissionSet/
│   ├── SCSoloLectura.PermissionSet.al
│   └── SCGestion.PermissionSet.al
├── Table/
│   └── SocialCreditReportLine.Table.al      ← tabla temporal para el ranking
└── TableExtension/
    └── CustomerTableExt.TableExt.al         ← índice SocialCreditKey
```

---

## Próximos módulos (ideas)

- [x] Historial de cambios de Social Credit con log de auditoría
- [x] Acciones para sumar/restar puntos con motivo
- [x] Filtros y ordenación por nivel en la lista de clientes
- [x] Reportes de ranking de clientes por Social Credit
- [x] Job Queue nocturno: penalización automática por facturas vencidas
- [x] Notificaciones de facturas vencidas al abrir la lista de clientes
- [x] API REST de solo lectura para clientes y facturas
- [x] Exportación en CSV, XML, JSON y Excel para clientes, proveedores e inventario
- [ ] Alertas automáticas cuando un cliente baja de 500 puntos
- [ ] Integración con pedidos: penalización automática por pagos tardíos
- [ ] Y lo que se me vaya ocurriendo...

---

## Cómo usar en tu entorno

### Requisitos previos
- [Visual Studio Code](https://code.visualstudio.com/)
- Extensión [AL Language](https://marketplace.visualstudio.com/items?itemName=ms-dynamics-smb.al) instalada en VS Code
- [Docker Desktop](https://www.docker.com/products/docker-desktop/) en modo **Windows Containers**
- PowerShell con el módulo `BcContainerHelper`:
  ```powershell
  Install-Module BcContainerHelper -Force
  ```

### Pasos

**1. Clona el repo**
```bash
git clone https://github.com/ZabaHD4K/PruebasAl.git
cd PruebasAl
```

**2. Crea un contenedor BC local**

Abre PowerShell como Administrador y ejecuta:
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
> La primera vez tarda ~15-20 min descargando la imagen. Solo hay que hacerlo una vez.

**3. Abre el proyecto en VS Code**
```bash
code .
```

**4. Descarga los símbolos**

`Ctrl+Shift+P` → **AL: Download Symbols** → introduce usuario `admin` y la contraseña que elegiste.

**5. Publica y prueba**

`F5` — BC se abrirá en el navegador con la extensión activa.

> Si los clientes no muestran puntos de Social Credit, ve a la lista de clientes y pulsa **Ajustar Social Credit** → los datos se inicializarán automáticamente.

### Notas
- El `launch.json` ya apunta a `http://bc-dev` — si usas otro nombre de contenedor, cámbialo ahí
- BC version usada: **27.5 ES Sandbox**
- ID range de la extensión: **50100 – 50149**
