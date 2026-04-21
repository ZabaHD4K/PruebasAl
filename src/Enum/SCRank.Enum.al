/// <summary>
/// Rangos del sistema Social Credit.
/// Extensible: cualquier extensión puede añadir nuevos valores con enumextension.
///
/// El enum es ahora un tipo de datos puro — no despacha comportamiento.
/// Toda la lógica (umbrales, etiquetas, estilos) vive en "ISC Rank Provider"
/// y su implementación por defecto "SC Default Rank Provider".
///
/// El Caption de cada valor se usa como nombre legible del rango:
///   Format(Enum::"SC Rank"::Ejemplar) → 'Ciudadano Ejemplar'
///
/// Para añadir un rango nuevo desde una extensión:
///   enumextension 70000 "My SC Rank Ext" extends "SC Rank"
///   {
///       value(10; VIP)
///       {
///           Caption = 'Cliente VIP';
///       }
///   }
///   // Después sobrescribir el proveedor vía OnGetRankProvider para
///   // incluir el nuevo umbral y sus estilos/etiquetas.
/// </summary>
enum 50100 "SC Rank"
{
    Extensible = true;

    /// <summary>Lista Negra — menos de 500 puntos.</summary>
    value(0; ListaNegra)
    {
        Caption = 'Lista Negra';
    }

    /// <summary>Bajo Supervisión — de 500 a 999 puntos.</summary>
    value(1; Supervision)
    {
        Caption = 'Bajo Supervisión';
    }

    /// <summary>Ciudadano Normal — de 1 000 a 1 499 puntos.</summary>
    value(2; Normal)
    {
        Caption = 'Ciudadano Normal';
    }

    /// <summary>Ciudadano Ejemplar — 1 500 puntos o más.</summary>
    value(3; Ejemplar)
    {
        Caption = 'Ciudadano Ejemplar';
    }
}
