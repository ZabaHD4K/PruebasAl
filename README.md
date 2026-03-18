# PruebasAL — Mega Extensión de Business Central

Repositorio de aprendizaje de desarrollo AL para **Microsoft Dynamics 365 Business Central**.
Este repo nace como un proyecto práctico y va creciendo con cada nueva funcionalidad aprendida, sirviendo como referencia real de cómo extender BC desde cero.

---

## ¿Qué es esto?

Una extensión de BC construida de forma incremental. Cada módulo añade algo nuevo al sistema, explorando distintas áreas del desarrollo AL: tablas, páginas, codeunits, eventos, reportes, etc.

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

### 🔐 Permisos (Permission Sets)

Dos conjuntos de permisos incluidos en la extensión para controlar el acceso al módulo:

| Permission Set | Descripción |
|----------------|-------------|
| `SC - Solo Lectura` | Acceso de solo lectura: ve puntos, estado e historial. Incluye permiso de lectura sobre la tabla Customer. |
| `SC - Gestión` | Acceso completo: todo lo de Solo Lectura + puede ajustar puntos y modificar registros. Hereda `SC - Solo Lectura` vía `IncludedPermissionSets`. |

---

## Objetos AL

| Objeto | Tipo | Descripción |
|--------|------|-------------|
| `CustomerTableExt` | TableExtension | Añade `Social Credit Points`, `Social Credit Label` e índice `SocialCreditKey` a Customer |
| `SocialCreditMgt` | Codeunit | Lógica central: estilos, etiquetas, rangos, log de cambios e inicialización |
| `SocialCreditCheckSubscriber` | Codeunit | Suscriptor de eventos para validaciones automáticas |
| `InstallSocialCredit` | Codeunit | Inicializa todos los clientes a 1000 puntos en la instalación |
| `UpgradeSocialCredit` | Codeunit | Sincroniza datos al republicar la extensión |
| `CustomerListExt` | PageExtension | Columna de icono, campos de estado, barra de filtros interactiva, ordenación y FactBox |
| `CustomerCardExt` | PageExtension | Campos Social Credit en la ficha del cliente |
| `CustomerLookupExt` | PageExtension | Icono de estado en el lookup de selección de clientes |
| `SalesOrderExt` | PageExtension | Etiqueta de estado bajo el nombre del cliente en pedidos de venta |
| `SalesInvoiceExt` | PageExtension | Etiqueta de estado en facturas de venta |
| `SalesQuoteExt` | PageExtension | Etiqueta de estado en presupuestos |
| `SalesCreditMemoExt` | PageExtension | Etiqueta de estado en abonos de venta |
| `CustomerSocialCreditFactBox` | Page (CardPart) | Panel lateral con estado, rango y puntos del cliente seleccionado |
| `SocialCreditAdjustPage` | Page | Panel para subir/bajar puntos con motivo |
| `SocialCreditHistory` | Page | Historial completo de cambios de un cliente |
| `SocialCreditLogEntry` | Table | Tabla de auditoría con todos los cambios de puntos |
| `SC - Solo Lectura` | PermissionSet | Permisos de solo lectura para el módulo |
| `SC - Gestión` | PermissionSet | Permisos completos de gestión |

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
│   └── SocialCreditCheckSubscriber.Codeunit.al
├── Page/
│   ├── CustomerSocialCreditFactBox.Page.al
│   ├── SocialCreditAdjustPage.Page.al
│   ├── SocialCreditHistoryChart.Page.al
│   └── SocialCreditSelCustPart.Page.al
├── PageExtension/
│   ├── CustomerListExt.PageExt.al       ← filtros, ordenación, barra interactiva
│   ├── CustomerCardExt.PageExt.al
│   ├── CustomerLookupExt.PageExt.al
│   ├── SalesOrderExt.PageExt.al
│   ├── SalesInvoiceExt.PageExt.al
│   ├── SalesQuoteExt.PageExt.al
│   └── SalesCreditMemoExt.PageExt.al
├── PermissionSet/
│   ├── SCSoloLectura.PermissionSet.al
│   └── SCGestion.PermissionSet.al
└── TableExtension/
    └── CustomerTableExt.TableExt.al     ← índice SocialCreditKey
```

---

## Próximos módulos (ideas)

- [x] Historial de cambios de Social Credit con log de auditoría
- [x] Acciones para sumar/restar puntos con motivo
- [x] Filtros y ordenación por nivel en la lista de clientes
- [ ] Alertas automáticas cuando un cliente baja de 500 puntos
- [ ] Reportes de ranking de clientes por Social Credit
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
