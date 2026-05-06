report 50130 "EJ7 Clientes Locales"
{
    Caption = 'Clientes Locales';
    ApplicationArea = All;
    UsageCategory = ReportsAndAnalysis;
    DefaultLayout = RDLC;
    RDLCLayout = 'src/ejBC7/EJ7ClienteLocalReport.rdlc';

    dataset
    {
        dataitem(ClienteLocal; "EJ7 Cliente Local")
        {
            column(No_Cliente_Local; "No. Cliente Local") { }
            column(Nombre; Nombre) { }
            column(No_Cliente_Generico; "No. Cliente Generico") { }
            column(Nombre_Cliente_Generico; "Nombre Cliente Generico") { }
            column(Ultima_Factura; "Ultima Factura") { }
        }
    }

    requestpage
    {
        layout
        {
        }
        actions
        {
        }
    }
}
