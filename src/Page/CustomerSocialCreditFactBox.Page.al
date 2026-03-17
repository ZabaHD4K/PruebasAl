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
        SocialCreditRank: Text[30];

    trigger OnAfterGetRecord()
    begin
        RefreshSocialCredit();
    end;

    local procedure RefreshSocialCredit()
    var
        SocialCreditMgt: Codeunit "Social Credit Mgt";
    begin
        SocialCreditStyle := SocialCreditMgt.GetStyle(Rec."Social Credit Points");
        case true of
            Rec."Social Credit Points" >= 1500:
                SocialCreditRank := 'Ciudadano Ejemplar';
            Rec."Social Credit Points" >= 1000:
                SocialCreditRank := 'Ciudadano Normal';
            Rec."Social Credit Points" >= 500:
                SocialCreditRank := 'Bajo Supervision';
            else
                SocialCreditRank := 'Lista Negra';
        end;
    end;
}
