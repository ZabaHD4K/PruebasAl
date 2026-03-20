# Social Credit Extension — Contexto del proyecto

## ¿Qué es esto?
Extensión de Business Central (AL) que implementa un sistema de **Social Credit** para clientes. Cada cliente tiene una puntuación (0–∞, mín. 0, inicial 1000) que refleja su fiabilidad. Los puntos suben o bajan manualmente o de forma automática.

## Rangos de puntuación
| Puntos      | Estado              | Emoji | Style BC         |
|-------------|---------------------|-------|------------------|
| >= 1500     | Ciudadano Ejemplar  | 🟢    | Favorable        |
| 1000–1499   | Ciudadano Normal    | 🔵    | StandardAccent   |
| 500–999     | Bajo Supervisión    | 🟡    | Attention        |
| < 500       | Lista Negra         | 🔴    | Unfavorable      |

## IDs de objetos usados
| Rango       | Tipo            |
|-------------|-----------------|
| 50100–50113 | Pages           |
| 50100–50101 | PageExtensions (empieza en 50100) |
| 50100–50101 | Tables / TableExtensions |
| 50101       | Codeunit principal (Social Credit Mgt) |
| 50106       | Codeunit SC Deduct Morosos |

**Próximo ID libre de página: 50118**
**Próximo ID libre de tabla: 50106**

## Arquitectura clave

### Codeunit principal: `Social Credit Mgt` (50101)
Procedimientos públicos — usar siempre estos en lugar de duplicar lógica:
- `AdjustCustomerPoints(CustomerNo, Delta, Reason)` — aplica delta, actualiza label, hace Modify y loguea. **Punto de entrada único para ajustar puntos.**
- `LogChange(CustomerNo, CustomerName, PointsBefore, PointsAfter, Reason)` — inserta en log.
- `GetStyle(Points)` / `GetLabel(Points)` / `GetRank(Points)` — helpers de presentación.
- `InitializeCustomers()` — pone 1000 puntos a clientes sin puntuación.

### Tabla de auditoría: `Social Credit Log Entry`
Registra cada cambio: cliente, puntos antes/después, delta, timestamp, usuario, motivo.

### Página hub: `Extension SC` (50113)
**REGLA CRÍTICA: cualquier página nueva de la extensión DEBE añadirse a esta página.**
Ver sección "Regla de registro" más abajo.

### Páginas propias de la extensión
| ID    | Nombre                        | Tipo           | Descripción                              |
|-------|-------------------------------|----------------|------------------------------------------|
| 50100 | Customer Social Credit FactBox| CardPart       | FactBox en ficha de cliente              |
| 50101 | Social Credit Adjust          | Card           | Ajuste manual de puntos                  |
| 50102 | Social Credit History         | List           | Historial de cambios (log)               |
| 50103 | SC Sel Cust Part              | ListPart       | Parte de selección de cliente            |
| 50105 | Social Credit Report          | List           | Informe general de puntuaciones          |
| 50108 | SC Customer API               | API            | API de clientes                          |
| 50109 | SC Invoice API                | API            | API de facturas                          |
| 50110 | SC Chat Lines                 | ListPart       | Líneas del chat IA                       |
| 50111 | SC Chat                       | Card           | Chatbot con IA                           |
| 50112 | SC Chat Setup Page            | NavigatePage   | Setup de API Key del chat               |
| 50113 | Extension SC                  | Card           | **Hub central de la extensión**          |
| 50114 | SC Slider                     | Card           | Ajuste de puntos con slider JavaScript   |
| 50115 | SC Cue Part                   | CardPart       | Cues con conteo de clientes por rango    |
| 50116 | SC Headline Part              | HeadlinePart   | Titular: peor cliente y media de puntos  |
| 50117 | SC Role Center                | RoleCenter     | Role Center principal del módulo SC      |

### PageExtensions sobre páginas estándar de BC
| ID    | Nombre                        | Extiende              | Qué añade                              |
|-------|-------------------------------|----------------------|----------------------------------------|
| 50100 | Customer List Social Credit   | Customer List        | Columna de puntos y estado             |
| 50101 | Customer Card Social Credit   | Customer Card        | FactBox SC y acción Ajustar            |
| 50102 | Customer Lookup Social Credit | Customer Lookup      | Columna de puntos en búsqueda          |
| 50103 | Sales Order Social Credit     | Sales Order          | Validación SC al seleccionar cliente   |
| 50104 | Sales Quote Social Credit     | Sales Quote          | Validación SC al seleccionar cliente   |
| 50105 | Sales Invoice Social Credit   | Sales Invoice        | Validación SC al seleccionar cliente   |
| 50106 | Sales Cr. Memo Social Credit  | Sales Credit Memo    | Validación SC al seleccionar cliente   |
| 50107 | Vendor List Export            | Vendor List          | Acción de exportación                  |
| 50108 | Item List Export              | Item List            | Acción de exportación                  |

## Convenciones del proyecto
- Prefijo de objetos: `SC` o `Social Credit`
- Motivo de ajuste automático por morosos: `'Por moroso cabrón'`
- Motivo de ajuste por slider JS: `'Ajustado via Slider JS'`
- `ApplicationArea = All` en todos los campos y acciones
- Nunca modificar `Social Credit Points` directamente en el Customer record fuera de `SocialCreditMgt.AdjustCustomerPoints` — siempre pasar por ese procedimiento para garantizar el log.

---

## REGLA: Registro obligatorio en Extension SC

> **Cada vez que se cree una nueva página navegable (Card, List, etc.) en esta extensión, hay que añadirla a la página `Extension SC` (50113):**
> 1. Añadir un `label` descriptivo en el `group` correspondiente del `layout`.
> 2. Añadir un `action` con `RunObject = page "NombreDeLaPagina"` en el `area(Processing)`.
> 3. Añadir el `actionref` correspondiente en el `area(Promoted)`.
>
> Las páginas de tipo `CardPart`, `ListPart`, `API` y `NavigatePage` no se añaden porque no son navegables directamente.
