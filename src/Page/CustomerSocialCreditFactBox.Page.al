page 50100 "Customer Social Credit FactBox"
{
    PageType = CardPart;
    SourceTable = Customer;
    Caption = 'Social Credit';
    RefreshOnActivate = true;

    layout
    {
        area(content)
        {
            field("Social Credit Label"; Rec."Social Credit Label")
            {
                ApplicationArea = All;
                Caption = 'Estado';
                Editable = false;
                StyleExpr = SocialCreditStyle;
            }
            field("Social Credit Points"; Rec."Social Credit Points")
            {
                ApplicationArea = All;
                Caption = 'Puntos';
                StyleExpr = SocialCreditStyle;
            }
            field(SocialCreditRank; SocialCreditRank)
            {
                ApplicationArea = All;
                Caption = 'Rango';
                Editable = false;
                StyleExpr = SocialCreditStyle;
            }
        }
    }

    var
        SocialCreditStyle: Text;
        SocialCreditRank: Text[50];

    trigger OnAfterGetRecord()
    begin
        RefreshSocialCredit();
    end;

    local procedure RefreshSocialCredit()
    var
        SocialCreditMgt: Codeunit "Social Credit Mgt";
    begin
        SocialCreditStyle := SocialCreditMgt.GetStyle(Rec."Social Credit Points");
        SocialCreditRank := SocialCreditMgt.GetRank(Rec."Social Credit Points");
    end;
}
