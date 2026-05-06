page 50126 "EJ2 Tarea Card"
{
    PageType = Card;
    SourceTable = "EJ2 Cabecera Tarea";
    Caption = 'Task Card', Comment = 'ESP="Ficha de Tarea"';
    ApplicationArea = All;
    UsageCategory = Documents;

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';

                field("Tipo Tarea"; Rec."Tipo Tarea")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the type of the task: Incident or Inquiry.',
                              Comment = 'ESP="Especifica el tipo de tarea: Incidencia o Consulta."';
                }
                field("No. Tarea"; Rec."No. Tarea")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the unique identifier of the task.',
                              Comment = 'ESP="Especifica el identificador único de la tarea."';
                }
                field(Descripcion; Rec.Descripcion)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies a short description of the task.',
                              Comment = 'ESP="Especifica una breve descripción de la tarea."';
                }
                field(Estado; Rec.Estado)
                {
                    ApplicationArea = All;
                    Editable = false;
                    StyleExpr = EstadoStyle;
                    ToolTip = 'Specifies the current status of the task: Notified, In Progress or Completed.',
                              Comment = 'ESP="Especifica el estado actual de la tarea: Notificada, En curso o Terminada."';
                }
                field("Horas Dedicadas"; Rec."Horas Dedicadas")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the total hours spent on this task, calculated from all its lines.',
                              Comment = 'ESP="Especifica el total de horas dedicadas a esta tarea, calculado de todas sus líneas."';
                }
                field("Usuario Creacion"; Rec."Usuario Creacion")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the user who created this task.',
                              Comment = 'ESP="Especifica el usuario que creó esta tarea."';
                }
            }
            part(LineasPart; "EJ2 Linea Tarea Subpage")
            {
                ApplicationArea = All;
                SubPageLink = "Tipo Tarea" = field("Tipo Tarea"),
                              "No. Tarea"  = field("No. Tarea");
                Caption = 'Lines', Comment = 'ESP="Líneas"';
            }
        }
    }

    var
        EstadoStyle: Text;

    trigger OnAfterGetRecord()
    begin
        // Pasar la cabecera a la subpage para que pueda acceder a ella
        CurrPage.LineasPart.Page.SetCabTarea(Rec);

        // Estilo visual del campo Estado
        case Rec.Estado of
            "EJ2 Estado Tarea"::Notificada:
                EstadoStyle := 'StandardAccent';
            "EJ2 Estado Tarea"::EnCurso:
                EstadoStyle := 'Attention';
            "EJ2 Estado Tarea"::Terminada:
                EstadoStyle := 'Favorable';
        end;
    end;
}
