pageextension 50103 "Sales Order Social Credit" extends "Sales Order"
{
    layout
    {
        addafter("Sell-to Customer Name")
        {
            field(SellToSocialCredit; SellToSocialCredit)
            {
                ApplicationArea = All;
                Caption = 'Social Credit';
                Editable = false;
                StyleExpr = SellToSocialCreditStyle;
            }
        }
    }

    var
        SellToSocialCredit: Text[50];
        SellToSocialCreditStyle: Text;

    trigger OnAfterGetCurrRecord()
    begin
        RefreshSocialCredit();
    end;

    local procedure RefreshSocialCredit()
    var
        SocialCreditMgt: Codeunit "Social Credit Mgt";
    begin
        SellToSocialCredit := SocialCreditMgt.GetCustomerLabel(Rec."Sell-to Customer No.");
        SellToSocialCreditStyle := SocialCreditMgt.GetCustomerStyle(Rec."Sell-to Customer No.");
    end;
}
