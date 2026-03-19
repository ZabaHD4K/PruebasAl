codeunit 50107 "SC Overdue Notifier"
{
    [EventSubscriber(ObjectType::Page, Page::"Customer List", OnOpenPageEvent, '', false, false)]
    local procedure OnCustomerListOpen(var Rec: Record Customer)
    begin
        // El subscriber nunca debe hacer petar la apertura de la página
        if not TrySendOverdueNotifications() then;
    end;

    [TryFunction]
    local procedure TrySendOverdueNotifications()
    var
        CustLedgEntry: Record "Cust. Ledger Entry";
        Notif: Notification;
    begin
        CustLedgEntry.SetRange("Document Type", CustLedgEntry."Document Type"::Invoice);
        CustLedgEntry.SetRange(Open, true);
        CustLedgEntry.SetFilter("Due Date", '<%1', Today());
        if not CustLedgEntry.FindSet() then
            exit;

        repeat
            Notif.Id := CreateGuid();
            Notif.Message := StrSubstNo(
                '⚠️ Factura %1 de %2 lleva vencida desde el %3 y no ha sido pagada.',
                CustLedgEntry."Document No.",
                CustLedgEntry."Customer Name",
                Format(CustLedgEntry."Due Date", 0, '<Day,2>/<Month,2>/<Year4>'));
            Notif.Scope := NotificationScope::LocalScope;
            Notif.SetData('DocNo', CustLedgEntry."Document No.");
            Notif.AddAction(
                StrSubstNo('Ver factura %1', CustLedgEntry."Document No."),
                Codeunit::"SC Overdue Notifier",
                'OpenInvoice');
            Notif.Send();
        until CustLedgEntry.Next() = 0;
    end;

    procedure OpenInvoice(Notif: Notification)
    var
        SalesInvHeader: Record "Sales Invoice Header";
        DocNo: Code[20];
        NotFoundMsg: Label 'No se encontró la factura contabilizada "%1".\Es posible que sea una factura sin contabilizar o que haya sido eliminada.';
    begin
        DocNo := CopyStr(Notif.GetData('DocNo'), 1, 20);
        if DocNo = '' then begin
            Message('No se pudo identificar el número de factura.');
            exit;
        end;
        if not SalesInvHeader.Get(DocNo) then begin
            Message(NotFoundMsg, DocNo);
            exit;
        end;
        if not TryOpenInvoicePage(SalesInvHeader) then
            Message('No se pudo abrir la factura "%1". Inténtalo de nuevo.', DocNo);
    end;

    [TryFunction]
    local procedure TryOpenInvoicePage(var SalesInvHeader: Record "Sales Invoice Header")
    begin
        Page.Run(Page::"Posted Sales Invoice", SalesInvHeader);
    end;
}
