codeunit 50103 "Social Credit Check Subscriber"
{
    // Suscriptor que intercepta la validación del cliente en cualquier documento.
    // Si el cliente tiene Social Credit en rojo (<500 puntos), pide confirmación.
    // Si el usuario cancela, se lanza un Error para revertir la selección.

    // ── Ventas (Pedido, Factura, Abono, Oferta, Pedido abierto) ──────────────
    [EventSubscriber(ObjectType::Table, Database::"Sales Header", 'OnAfterValidateEvent', 'Sell-to Customer No.', false, false)]
    local procedure CheckSCOnSalesHeader(var Rec: Record "Sales Header"; var xRec: Record "Sales Header")
    begin
        CheckCustomerSocialCredit(Rec."Sell-to Customer No.");
    end;

    // ── Servicio (Pedido, Factura, Oferta de servicio) ────────────────────────
    [EventSubscriber(ObjectType::Table, Database::"Service Header", 'OnAfterValidateEvent', 'Customer No.', false, false)]
    local procedure CheckSCOnServiceHeader(var Rec: Record "Service Header"; var xRec: Record "Service Header")
    begin
        CheckCustomerSocialCredit(Rec."Customer No.");
    end;

    // ── Recordatorios ─────────────────────────────────────────────────────────
    [EventSubscriber(ObjectType::Table, Database::"Reminder Header", 'OnAfterValidateEvent', 'Customer No.', false, false)]
    local procedure CheckSCOnReminderHeader(var Rec: Record "Reminder Header"; var xRec: Record "Reminder Header")
    begin
        CheckCustomerSocialCredit(Rec."Customer No.");
    end;

    // ── Intereses por mora ────────────────────────────────────────────────────
    [EventSubscriber(ObjectType::Table, Database::"Finance Charge Memo Header", 'OnAfterValidateEvent', 'Customer No.', false, false)]
    local procedure CheckSCOnFinChargeMemoHeader(var Rec: Record "Finance Charge Memo Header"; var xRec: Record "Finance Charge Memo Header")
    begin
        CheckCustomerSocialCredit(Rec."Customer No.");
    end;

    // ── Lógica común ──────────────────────────────────────────────────────────
    local procedure CheckCustomerSocialCredit(CustomerNo: Code[20])
    var
        Customer: Record Customer;
        ConfirmMsg: Label '⚠️ El cliente "%1" tiene un Social Credit muy bajo (%2 puntos).\¿Desea continuar de todas formas?', Comment = '%1=Nombre cliente, %2=Puntos';
    begin
        if CustomerNo = '' then
            exit;
        if not Customer.Get(CustomerNo) then
            exit;
        if Customer."Social Credit Points" >= 500 then
            exit;

        if not Confirm(ConfirmMsg, false, Customer.Name, Customer."Social Credit Points") then
            Error('Selección cancelada: el cliente "%1" tiene Social Credit en nivel rojo (%2 puntos).', Customer.Name, Customer."Social Credit Points");
    end;
}
