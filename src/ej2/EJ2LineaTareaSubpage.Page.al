page 50125 "EJ2 Linea Tarea Subpage"
{
    PageType = ListPart;
    SourceTable = "EJ2 Linea Tarea";
    Caption = 'Task Lines', Comment = 'ESP="Líneas de Tarea"';
    ApplicationArea = All;
    AutoSplitKey = true;

    layout
    {
        area(Content)
        {
            repeater(Lines)
            {
                // Campos clave de cabecera: ocultos por defecto, el usuario puede mostrarlos
                field("Tipo Tarea"; Rec."Tipo Tarea")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the task type inherited from the header.',
                              Comment = 'ESP="Especifica el tipo de tarea heredado de la cabecera."';
                }
                field("No. Tarea"; Rec."No. Tarea")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the task number inherited from the header.',
                              Comment = 'ESP="Especifica el número de tarea heredado de la cabecera."';
                }
                field("Linea Tarea"; Rec."Linea Tarea")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the auto-generated line number (increments by 10,000).',
                              Comment = 'ESP="Especifica el número de línea autogenerado (incrementos de 10.000)."';
                }
                field(Descripcion; Rec.Descripcion)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies a description of the work done in this line.',
                              Comment = 'ESP="Especifica una descripción del trabajo realizado en esta línea."';
                }
                field("Horas Dedicadas"; Rec."Horas Dedicadas")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the hours spent on this line.',
                              Comment = 'ESP="Especifica las horas dedicadas a esta línea."';
                }
                field(Terminada; Rec.Terminada)
                {
                    ApplicationArea = All;
                    ToolTip = 'Indicates whether this line has been completed.',
                              Comment = 'ESP="Indica si esta línea ha sido completada."';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(TerminarTarea)
            {
                ApplicationArea = All;
                Caption = 'Complete Task', Comment = 'ESP="Terminar Tarea"';
                Image = Approve;
                ToolTip = 'Marks the task as completed when all lines are done and the task is in progress.',
                          Comment = 'ESP="Marca la tarea como Terminada cuando todas las líneas están completadas y la tarea está En curso."';

                trigger OnAction()
                var
                    CabTarea: Record "EJ2 Cabecera Tarea";
                    LinPendiente: Record "EJ2 Linea Tarea";
                    ErrNotInProgressLbl: Label 'Cannot complete a task that is not in progress.',
                        Comment = 'ESP="No se puede dar por Terminada una tarea que no está en curso."';
                    ErrLinesNotDoneLbl: Label 'Cannot complete the task because not all lines are finished.',
                        Comment = 'ESP="No se puede dar por terminada la tarea porque no están terminadas todas sus líneas."';
                    MsgAlreadyDoneLbl: Label 'The task is already completed.',
                        Comment = 'ESP="La tarea ya está actualmente terminada."';
                begin
                    if not CabTarea.Get(CabTareaGlobal."Tipo Tarea", CabTareaGlobal."No. Tarea") then
                        exit;

                    case CabTarea.Estado of
                        "EJ2 Estado Tarea"::Terminada:
                            Message(MsgAlreadyDoneLbl);
                        "EJ2 Estado Tarea"::Notificada:
                            Error(ErrNotInProgressLbl);
                        "EJ2 Estado Tarea"::EnCurso:
                            begin
                                LinPendiente.SetRange("Tipo Tarea", CabTarea."Tipo Tarea");
                                LinPendiente.SetRange("No. Tarea", CabTarea."No. Tarea");
                                LinPendiente.SetRange(Terminada, false);
                                if not LinPendiente.IsEmpty() then
                                    Error(ErrLinesNotDoneLbl);

                                CabTarea.Estado := "EJ2 Estado Tarea"::Terminada;
                                CabTarea.Modify(true);
                                CurrPage.Update(false);
                            end;
                    end;
                end;
            }
        }
    }

    var
        CabTareaGlobal: Record "EJ2 Cabecera Tarea";

    // Llamado desde la página de ficha para pasar la cabecera actual
    procedure SetCabTarea(CabTarea: Record "EJ2 Cabecera Tarea")
    begin
        CabTareaGlobal := CabTarea;
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    var
        LinTarea: Record "EJ2 Linea Tarea";
    begin
        // Heredar la clave de cabecera
        Rec."Tipo Tarea" := CabTareaGlobal."Tipo Tarea";
        Rec."No. Tarea"  := CabTareaGlobal."No. Tarea";

        // Autoincrementar Linea Tarea de 10.000 en 10.000
        LinTarea.SetRange("Tipo Tarea", Rec."Tipo Tarea");
        LinTarea.SetRange("No. Tarea", Rec."No. Tarea");
        if LinTarea.FindLast() then
            Rec."Linea Tarea" := LinTarea."Linea Tarea" + 10000
        else
            Rec."Linea Tarea" := 10000;
    end;
}
