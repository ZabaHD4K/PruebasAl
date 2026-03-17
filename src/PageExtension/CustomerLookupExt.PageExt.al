pageextension 50102 "Customer Lookup Social Credit" extends "Customer Lookup"
{
    layout
    {
        modify(Name)
        {
            StyleExpr = SocialCreditStyle;
        }
        addafter(Name)
        {
            field(SocialCreditIcon; SocialCreditIcon)
            {
                ApplicationArea = All;
                Caption = '';
                Width = 1;
                Editable = false;
                StyleExpr = SocialCreditStyle;
            }
        }
    }

    var
        SocialCreditStyle: Text;
        SocialCreditIcon: Text[10];

    trigger OnAfterGetRecord()
    begin
        RefreshSocialCredit();
    end;

    local procedure RefreshSocialCredit()
    var
        SocialCreditMgt: Codeunit "Social Credit Mgt";
    begin
        SocialCreditStyle := SocialCreditMgt.GetStyle(Rec."Social Credit Points");
        SocialCreditIcon := CopyStr(SocialCreditMgt.GetLabel(Rec."Social Credit Points"), 1, 2);
    end;
}
