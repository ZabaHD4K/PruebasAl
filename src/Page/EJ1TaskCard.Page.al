page 50123 "EJ1 Task Card"
{
    PageType = Card;
    SourceTable = "EJ1 Task";
    Caption = 'Task Card', Comment = 'ESP="Ficha de tarea"';
    ApplicationArea = All;
    UsageCategory = Documents;

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';

                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                    Caption = 'No.', Comment = 'ESP="Nº"';
                    ToolTip = 'Specifies the unique identifier of the task.', Comment = 'ESP="Especifica el identificador único de la tarea."';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    Caption = 'Description', Comment = 'ESP="Descripción"';
                    ToolTip = 'Specifies a short description of the task.', Comment = 'ESP="Especifica una breve descripción de la tarea."';
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = All;
                    Caption = 'Status', Comment = 'ESP="Estado"';
                    ToolTip = 'Specifies the current progress status of the task.', Comment = 'ESP="Especifica el estado de progreso actual de la tarea."';
                    StyleExpr = StatusStyle;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(MarkCompleted)
            {
                ApplicationArea = All;
                Caption = 'Mark as Completed', Comment = 'ESP="Marcar como completada"';
                Image = Approve;
                ToolTip = 'Sets the task status to Completed.', Comment = 'ESP="Establece el estado de la tarea como Completada."';

                trigger OnAction()
                var
                    AlreadyCompletedMsg: Label 'This task is already marked as Completed.',
                        Comment = 'ESP="Esta tarea ya está marcada como Completada."';
                    MarkedCompletedMsg: Label 'Task "%1" has been marked as Completed.',
                        Comment = 'ESP="La tarea %1 ha sido marcada como Completada."';
                begin
                    if Rec.Status = Rec.Status::Completed then begin
                        Message(AlreadyCompletedMsg);
                        exit;
                    end;
                    Rec.Validate(Status, Rec.Status::Completed);
                    Rec.Modify(true);
                    Message(MarkedCompletedMsg, Rec."No.");
                end;
            }
        }
        area(Promoted)
        {
            actionref(MarkCompleted_Ref; MarkCompleted) { }
        }
    }

    var
        StatusStyle: Text;

    trigger OnAfterGetRecord()
    begin
        case Rec.Status of
            Rec.Status::Open:
                StatusStyle := 'StandardAccent';
            Rec.Status::InProgress:
                StatusStyle := 'Attention';
            Rec.Status::Completed:
                StatusStyle := 'Favorable';
        end;
    end;
}
