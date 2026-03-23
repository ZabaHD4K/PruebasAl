/// <summary>
/// Proveedor de lógica de rangos de Social Credit.
///
/// Este interface separa el QUÉS (qué rango tiene un cliente dado)
/// del CÓMO (cómo se muestran los rangos).
///
/// La implementación por defecto es "SC Default Rank Provider".
/// Cualquier extensión puede sustituirla suscribiéndose al evento
/// SocialCreditMgt.OnGetRankProvider y devolviendo su propia codeunit.
///
/// Ejemplo de extensión completa:
///   codeunit 70000 "My Rank Provider" implements "ISC Rank Provider"
///   {
///       procedure GetRank(Points: Integer): Enum "SC Rank"
///       begin
///           if Points >= 2000 then exit(Enum::"SC Rank"::Ejemplar);
///           ...
///       end;
///       procedure GetLabel(Rank: Enum "SC Rank"; Points: Integer): Text[50]
///       begin ... end;
///       procedure GetStyle(Rank: Enum "SC Rank"): Text
///       begin ... end;
///   }
/// </summary>
interface "ISC Rank Provider"
{
    /// <summary>
    /// Mapea una puntuación a su rango correspondiente.
    /// Toda la lógica de umbrales debe vivir aquí.
    /// </summary>
    procedure GetRank(Points: Integer): Enum "SC Rank";

    /// <summary>
    /// Devuelve la etiqueta corta que se almacena en Customer."Social Credit Label".
    /// Recibe el rango ya calculado y los puntos para componer el texto.
    /// Ejemplo: '🟢 (1750)'
    /// </summary>
    procedure GetLabel(Rank: Enum "SC Rank"; Points: Integer): Text[50];

    /// <summary>
    /// Devuelve el StyleExpr de BC para colorear campos y columnas.
    /// Valores válidos: Favorable | StandardAccent | Attention | Unfavorable
    /// </summary>
    procedure GetStyle(Rank: Enum "SC Rank"): Text;
}
