codeunit 50100 "Install Social Credit"
{
    Subtype = Install;

    trigger OnInstallAppPerCompany()
    begin
        SetDefaultSocialCreditPoints();
    end;

    local procedure SetDefaultSocialCreditPoints()
    var
        Customer: Record Customer;
        SocialCreditMgt: Codeunit "Social Credit Mgt";
    begin
        if Customer.FindSet(true) then
            repeat
                if Customer."Social Credit Points" = 0 then
                    Customer."Social Credit Points" := 1000;
                Customer."Social Credit Label" := SocialCreditMgt.GetLabel(Customer."Social Credit Points");
                Customer.Modify();
            until Customer.Next() = 0;
    end;
}
