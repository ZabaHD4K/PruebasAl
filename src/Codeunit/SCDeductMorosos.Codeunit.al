codeunit 50106 "SC Deduct Morosos"
{
    Subtype = Normal;
    TableNo = "Job Queue Entry";

    trigger OnRun()
    var
        Customer: Record Customer;
        Processed: Integer;
        Errors: Integer;
    begin
        if not Customer.FindSet(true) then
            exit;

        repeat
            if TryProcessCustomer(Customer) then
                Processed += 1
            else
                Errors += 1;
        until Customer.Next() = 0;

        // Si hubo errores parciales, se marca el job queue como fallido con detalle
        // Los clientes procesados correctamente ya tienen sus cambios guardados
        if Errors > 0 then
            Error('SC Deduct Morosos completado con errores: %1 cliente(s) procesados correctamente, %2 cliente(s) fallaron.',
                Processed, Errors);
    end;

    [TryFunction]
    local procedure TryProcessCustomer(var Customer: Record Customer)
    var
        CustLedgerEntry: Record "Cust. Ledger Entry";
        SocialCreditMgt: Codeunit "Social Credit Mgt";
        PointsBefore: Integer;
    begin
        CustLedgerEntry.SetRange("Customer No.", Customer."No.");
        CustLedgerEntry.SetRange("Document Type", CustLedgerEntry."Document Type"::Invoice);
        CustLedgerEntry.SetRange(Open, true);
        CustLedgerEntry.SetFilter("Due Date", '<%1', Today());
        if CustLedgerEntry.IsEmpty() then
            exit;

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
}
