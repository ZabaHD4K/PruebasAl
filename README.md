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

**Rangos:**
| Puntos | Icono | Rango |
|--------|-------|-------|
| ≥ 1500 | 🟢 | Ciudadano Ejemplar |
| ≥ 1000 | 🔵 | Ciudadano Normal |
| ≥ 500  | 🟡 | Bajo Supervisión |
| < 500  | 🔴 | Lista Negra |

**Objetos AL creados:**
- `CustomerTableExt` — extiende la tabla Customer con los nuevos campos y fieldgroups (Brick + DropDown)
- `SocialCreditMgt` — codeunit de gestión con la lógica de estilos y etiquetas
- `CustomerListExt` — columna + icono + FactBox en la lista de clientes
- `CustomerCardExt` — campos en la sección General de la ficha
- `CustomerLookupExt` — icono en el lookup de selección de clientes
- `CustomerSocialCreditFactBox` — panel lateral siempre visible con estado y rango
- `SalesOrderExt`, `SalesInvoiceExt`, `SalesQuoteExt`, `SalesCrMemoExt` — etiqueta bajo el nombre del cliente en documentos de venta
- `InstallSocialCredit` — codeunit de instalación que inicializa todos los clientes a 1000 puntos
- `UpgradeSocialCredit` — codeunit de upgrade que sincroniza datos al republicar

---

## Entorno

- **BC Version:** Business Central 27.5 (ES Sandbox)
- **AL Language Extension:** VS Code
- **Docker:** contenedor local con BcContainerHelper
- **Publisher:** Arbentia
- **ID Range:** 50100 – 50149

---

## Estructura del proyecto

```
src/
├── Codeunit/
│   ├── InstallSocialCredit.Codeunit.al
│   ├── UpgradeSocialCredit.Codeunit.al
│   └── SocialCreditMgt.Codeunit.al
├── Page/
│   └── CustomerSocialCreditFactBox.Page.al
├── PageExtension/
│   ├── CustomerListExt.PageExt.al
│   ├── CustomerCardExt.PageExt.al
│   ├── CustomerLookupExt.PageExt.al
│   ├── SalesOrderExt.PageExt.al
│   ├── SalesInvoiceExt.PageExt.al
│   ├── SalesQuoteExt.PageExt.al
│   └── SalesCreditMemoExt.PageExt.al
└── TableExtension/
    └── CustomerTableExt.TableExt.al
```

---

## Próximos módulos (ideas)

- [ ] Historial de cambios de Social Credit con log de auditoría
- [ ] Acciones para sumar/restar puntos con motivo
- [ ] Alertas automáticas cuando un cliente baja de 500 puntos
- [ ] Reportes de ranking de clientes por Social Credit
- [ ] Integración con pedidos: penalización automática por pagos tardíos
- [ ] Y lo que se me vaya ocurriendo...

---

## Cómo usar

1. Clona el repo y ábrelo en VS Code con la extensión AL Language instalada
2. Levanta el contenedor BC con Docker (`scripts/setup-bc-container.ps1`)
3. `Ctrl+Shift+P` → **AL: Download Symbols**
4. `F5` para publicar y depurar
