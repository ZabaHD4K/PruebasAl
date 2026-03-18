codeunit 50102 "Upgrade Social Credit"
{
    Subtype = Upgrade;

    trigger OnUpgradePerCompany()
    begin
        PopulateSocialCredit();
    end;

    local procedure PopulateSocialCredit()
    var
        SocialCreditMgt: Codeunit "Social Credit Mgt";
    begin
        SocialCreditMgt.InitializeCustomers();
    end;
}
