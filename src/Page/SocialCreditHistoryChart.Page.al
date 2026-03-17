page 50102 "Social Credit History"
{
    PageType = List;
    Caption = 'Historial de Social Credit';
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;
    SourceTable = "Social Credit Log Entry";
    SourceTableView = sorting("Log DateTime") order(descending);
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(Content)
        {
            repeater(LogList)
            {
                field("Log DateTime"; Rec."Log DateTime")
                {
                    ApplicationArea = All;
                    Caption = 'Fecha y Hora';
                }
                field("Customer No."; Rec."Customer No.")
                {
                    ApplicationArea = All;
                    Caption = 'Nº Cliente';
                }
                field("Customer Name"; Rec."Customer Name")
                {
                    ApplicationArea = All;
                    Caption = 'Cliente';
                }
                field("Points Before"; Rec."Points Before")
                {
                    ApplicationArea = All;
                    Caption = 'Puntos Antes';
                }
                field("Change"; Rec."Change")
                {
                    ApplicationArea = All;
                    Caption = 'Cambio';
                    StyleExpr = ChangeStyle;
                }
                field("Points After"; Rec."Points After")
                {
                    ApplicationArea = All;
                    Caption = 'Puntos Después';
                    StyleExpr = AfterStyle;
                }
                field("User ID"; Rec."User ID")
                {
                    ApplicationArea = All;
                    Caption = 'Usuario';
                }
            }
        }
    }

    var
        ChangeStyle: Text;
        AfterStyle: Text;

    trigger OnAfterGetRecord()
    var
        SocialCreditMgt: Codeunit "Social Credit Mgt";
    begin
        if Rec."Change" >= 0 then
            ChangeStyle := 'Favorable'
        else
            ChangeStyle := 'Unfavorable';
        AfterStyle := SocialCreditMgt.GetStyle(Rec."Points After");
    end;
}
