codeunit 50106 "SC Deduct Morosos"
{
    Subtype = Normal;
    TableNo = "Job Queue Entry";

    trigger OnRun()
    var
        Customer: Record Customer;
        CustLedgerEntry: Record "Cust. Ledger Entry";
        SocialCreditMgt: Codeunit "Social Credit Mgt";
        PointsBefore: Integer;
    begin
        if Customer.FindSet(true) then
            repeat
                CustLedgerEntry.SetRange("Customer No.", Customer."No.");
                CustLedgerEntry.SetRange("Document Type", CustLedgerEntry."Document Type"::Invoice);
                CustLedgerEntry.SetRange(Open, true);

                // Prioridad 1: factura vencida → SC = 0
                CustLedgerEntry.SetFilter("Due Date", '<%1', Today());
                if not CustLedgerEntry.IsEmpty() then begin
                    PointsBefore := Customer."Social Credit Points";
                    if PointsBefore > 0 then begin
                        Customer."Social Credit Points" := 0;
                        Customer."Social Credit Label" := SocialCreditMgt.GetLabel(0);
                        Customer.Modify();
                        SocialCreditMgt.LogChange(
                            Customer."No.",
                            CopyStr(Customer.Name, 1, 100),
                            PointsBefore,
                            0,
                            'Vencimiento de factura');
                    end;
                end else begin
                    // Prioridad 2: factura abierta no vencida → -50
                    CustLedgerEntry.SetRange("Due Date");
                    if not CustLedgerEntry.IsEmpty() then begin
                        PointsBefore := Customer."Social Credit Points";
                        Customer."Social Credit Points" -= 50;
                        Customer."Social Credit Label" := SocialCreditMgt.GetLabel(Customer."Social Credit Points");
                        Customer.Modify();
                        SocialCreditMgt.LogChange(
                            Customer."No.",
                            CopyStr(Customer.Name, 1, 100),
                            PointsBefore,
                            Customer."Social Credit Points",
                            'Por moroso cabrón');
                    end;
                end;
            until Customer.Next() = 0;
    end;
}
