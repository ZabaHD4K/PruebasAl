codeunit 50102 "Upgrade Social Credit"
{
    Subtype = Upgrade;

    trigger OnUpgradePerCompany()
    begin
        PopulateSocialCredit();
    end;

    local procedure PopulateSocialCredit()
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
