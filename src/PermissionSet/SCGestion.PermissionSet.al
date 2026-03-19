permissionset 50101 "SC - Gestion"
{
    Assignable = true;
    Caption = 'Social Credit - Gestión';
    IncludedPermissionSets = "SC - Solo Lectura";

    Permissions =
        tabledata "Social Credit Log Entry" = RIMD,
        page "Social Credit Adjust" = X,
        codeunit "Install Social Credit" = X,
        codeunit "Upgrade Social Credit" = X,
        codeunit "SC Deduct Morosos" = X,
        codeunit "SC Overdue Notifier" = X,
        codeunit "SC Export Mgt" = X;
}
