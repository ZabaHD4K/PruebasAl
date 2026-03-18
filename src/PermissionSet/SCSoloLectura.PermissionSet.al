permissionset 50100 "SC - Solo Lectura"
{
    Assignable = true;
    Caption = 'Social Credit - Solo Lectura';

    Permissions =
        tabledata Customer = R,
        tabledata "Social Credit Log Entry" = R,
        page "Customer Social Credit FactBox" = X,
        page "Social Credit History" = X,
        page "SC Sel Cust Part" = X,
        codeunit "Social Credit Mgt" = X,
        codeunit "Social Credit Check Subscriber" = X;
}
