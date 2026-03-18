codeunit 50100 "Install Social Credit"
{
    Subtype = Install;

    trigger OnInstallAppPerCompany()
    begin
        SetDefaultSocialCreditPoints();
    end;

    local procedure SetDefaultSocialCreditPoints()
    var
        SocialCreditMgt: Codeunit "Social Credit Mgt";
    begin
        SocialCreditMgt.InitializeCustomers();
    end;
}
