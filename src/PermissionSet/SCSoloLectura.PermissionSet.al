permissionset 50100 "SC - Solo Lectura"
{
    Assignable = true;
    Caption = 'Social Credit - Solo Lectura';

    Permissions =
        tabledata Customer = R,
        tabledata "Social Credit Log Entry" = R,
        tabledata "SC Report Line" = RIMD,
        page "Customer Social Credit FactBox" = X,
        page "Social Credit History" = X,
        page "SC Sel Cust Part" = X,
        page "Social Credit Report" = X,
        page "SC Customer API" = X,
        page "SC Invoice API" = X,
        codeunit "Social Credit Mgt" = X,
        codeunit "Social Credit Check Subscriber" = X,
        codeunit "SC Overdue Notifier" = X;
}
