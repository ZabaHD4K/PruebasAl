/// <summary>
/// Implementación por defecto de "ISC Rank Provider".
/// Contiene toda la lógica de umbrales, etiquetas y estilos del módulo base.
///
/// Para sustituirla sin modificar este archivo, suscríbete al evento:
///   SocialCreditMgt.OnGetRankProvider(var Provider, var IsHandled)
/// y asigna tu propia codeunit al parámetro Provider.
/// </summary>
codeunit 50116 "SC Default Rank Provider" implements "ISC Rank Provider"
{
    Access = Internal;

    /// <summary>
    /// Umbrales del sistema Social Credit base.
    /// Si añades un valor al enum "SC Rank" desde una extensión,
    /// sobrescribe el proveedor para incluir el nuevo umbral aquí.
    /// </summary>
    procedure GetRank(Points: Integer): Enum "SC Rank"
    begin
        case true of
            Points >= 1500:
                exit(Enum::"SC Rank"::Ejemplar);
            Points >= 1000:
                exit(Enum::"SC Rank"::Normal);
            Points >= 500:
                exit(Enum::"SC Rank"::Supervision);
            else
                exit(Enum::"SC Rank"::ListaNegra);
        end;
    end;

    /// <summary>
    /// Etiqueta compacta con emoji y puntos.
    /// El else cubre rangos añadidos por extensiones que no
    /// hayan sobrescrito el proveedor.
    /// </summary>
    procedure GetLabel(Rank: Enum "SC Rank"; Points: Integer): Text[50]
    begin
        case Rank of
            Enum::"SC Rank"::Ejemplar:
                exit(CopyStr('🟢 (' + Format(Points) + ')', 1, 50));
            Enum::"SC Rank"::Normal:
                exit(CopyStr('🔵 (' + Format(Points) + ')', 1, 50));
            Enum::"SC Rank"::Supervision:
                exit(CopyStr('🟡 (' + Format(Points) + ')', 1, 50));
            else
                exit(CopyStr('🔴 (' + Format(Points) + ')', 1, 50));
        end;
    end;

    /// <summary>
    /// StyleExpr de BC para campos, columnas y CueGroups.
    /// El else garantiza que rangos desconocidos no rompen la UI.
    /// </summary>
    procedure GetStyle(Rank: Enum "SC Rank"): Text
    begin
        case Rank of
            Enum::"SC Rank"::Ejemplar:
                exit('Favorable');
            Enum::"SC Rank"::Normal:
                exit('StandardAccent');
            Enum::"SC Rank"::Supervision:
                exit('Attention');
            else
                exit('Unfavorable');
        end;
    end;
}
