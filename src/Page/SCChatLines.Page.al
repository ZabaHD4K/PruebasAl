page 50110 "SC Chat Lines"
{
    PageType = ListPart;
    Caption = 'Chat';
    SourceTable = "SC Chat Line";
    SourceTableView = sorting("Entry No.") order(Descending);
    InsertAllowed = false;
    DeleteAllowed = false;
    ModifyAllowed = false;
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(Lines)
            {
                field(MessageFull; GetDisplayText())
                {
                    ApplicationArea = All;
                    ShowCaption = false;
                    MultiLine = true;
                    StyleExpr = MsgStyle;
                    Width = 100;
                }
                field(TimeFld; Format(Rec."Message DateTime", 0, '<Hours24,2>:<Minutes,2>'))
                {
                    ApplicationArea = All;
                    Caption = ' ';
                    Editable = false;
                    Width = 4;
                    StyleExpr = TimeStyle;
                }
            }
        }
    }

    var
        MsgStyle: Text;
        TimeStyle: Text;
        FilterSessionId: Guid;

    trigger OnAfterGetRecord()
    begin
        case Rec.Role of
            Rec.Role::User:
                begin
                    MsgStyle := 'StandardAccent';
                    TimeStyle := 'Subordinate';
                end;
            Rec.Role::Assistant:
                begin
                    MsgStyle := 'Favorable';
                    TimeStyle := 'Subordinate';
                end;
            else begin
                MsgStyle := 'Subordinate';
                TimeStyle := 'Subordinate';
            end;
        end;
    end;

    procedure SetSessionId(SessionId: Guid)
    begin
        FilterSessionId := SessionId;
        Rec.SetRange("Session ID", SessionId);
        if Rec.FindFirst() then;
        CurrPage.Update(false);
    end;

    procedure Reload()
    begin
        Rec.SetRange("Session ID", FilterSessionId);
        if Rec.FindFirst() then;
        CurrPage.Update(false);
    end;

    local procedure GetDisplayText(): Text
    begin
        case Rec.Role of
            Rec.Role::User:
                exit('👤  ' + Rec."Message Text");
            Rec.Role::Assistant:
                exit('🤖  ' + Rec."Message Text");
            else
                exit(Rec."Message Text");
        end;
    end;
}
