pageextension 50101 "Customer Card Social Credit" extends "Customer Card"
{
    layout
    {
        addafter(Name)
        {
            field("Social Credit Label"; Rec."Social Credit Label")
            {
                ApplicationArea = All;
                Caption = 'Social Credit';
                Editable = false;
                StyleExpr = SocialCreditStyle;
            }
            field("Social Credit Points"; Rec."Social Credit Points")
            {
                ApplicationArea = All;
                Caption = 'Puntos';
                StyleExpr = SocialCreditStyle;
            }
        }
        addlast(factboxes)
        {
            part(SocialCreditFactBox; "Customer Social Credit FactBox")
            {
                ApplicationArea = All;
                Caption = 'Social Credit';
                SubPageLink = "No." = field("No.");
            }
        }
    }

    var
        SocialCreditStyle: Text;

    trigger OnAfterGetRecord()
    begin
        RefreshSocialCredit();
    end;

    local procedure RefreshSocialCredit()
    var
        SocialCreditMgt: Codeunit "Social Credit Mgt";
    begin
        SocialCreditStyle := SocialCreditMgt.GetStyle(Rec."Social Credit Points");
    end;
}
