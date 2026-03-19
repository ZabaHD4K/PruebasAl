page 50105 "Social Credit Report"
{
    PageType = List;
    Caption = 'Social Credit Report';
    ApplicationArea = All;
    SourceTable = "SC Report Line";
    SourceTableTemporary = true;
    Editable = false;
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(Lines)
            {
                field("Customer No."; Rec."Customer No.")
                {
                    ApplicationArea = All;
                    Caption = 'Nº Cliente';
                    StyleExpr = Rec."SC Style";
                }
                field("Customer Name"; Rec."Customer Name")
                {
                    ApplicationArea = All;
                    Caption = 'Nombre';
                    StyleExpr = Rec."SC Style";
                }
                field("Social Credit Points"; Rec."Social Credit Points")
                {
                    ApplicationArea = All;
                    Caption = 'Puntos';
                    StyleExpr = Rec."SC Style";
                }
                field("Social Credit Label"; Rec."Social Credit Label")
                {
                    ApplicationArea = All;
                    Caption = 'Social Credit';
                    StyleExpr = Rec."SC Style";
                }
                field("SC Rank"; Rec."SC Rank")
                {
                    ApplicationArea = All;
                    Caption = 'Rango';
                    StyleExpr = Rec."SC Style";
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(SortDesc)
            {
                ApplicationArea = All;
                Caption = '↓ Mayor a menor';
                Image = MoveDown;
                ToolTip = 'Ordena de mayor a menor puntuación de Social Credit.';

                trigger OnAction()
                begin
                    LoadData(false);
                end;
            }
            action(SortAsc)
            {
                ApplicationArea = All;
                Caption = '↑ Menor a mayor';
                Image = MoveUp;
                ToolTip = 'Ordena de menor a mayor puntuación de Social Credit.';

                trigger OnAction()
                begin
                    LoadData(true);
                end;
            }
        }

        area(Promoted)
        {
            actionref(SortDesc_Ref; SortDesc) { }
            actionref(SortAsc_Ref; SortAsc) { }
        }
    }

    trigger OnOpenPage()
    begin
        LoadData(false);
    end;

    local procedure LoadData(Ascending: Boolean)
    var
        Customer: Record Customer;
        SocialCreditMgt: Codeunit "Social Credit Mgt";
        LineNo: Integer;
    begin
        Rec.Reset();
        Rec.DeleteAll();

        LineNo := 1;
        Customer.SetCurrentKey("Social Credit Points");
        Customer.Ascending(Ascending);
        if Customer.FindSet() then
            repeat
                Rec.Init();
                Rec."Line No." := LineNo;
                Rec."Customer No." := Customer."No.";
                Rec."Customer Name" := CopyStr(Customer.Name, 1, 100);
                Rec."Social Credit Points" := Customer."Social Credit Points";
                Rec."Social Credit Label" := Customer."Social Credit Label";
                Rec."SC Rank" := SocialCreditMgt.GetRank(Customer."Social Credit Points");
                Rec."SC Style" := CopyStr(SocialCreditMgt.GetStyle(Customer."Social Credit Points"), 1, 30);
                Rec.Insert();
                LineNo += 1;
            until Customer.Next() = 0;

        if Rec.FindFirst() then;
        CurrPage.Update(false);
    end;
}
