page 50117 "SC Role Center"
{
    PageType = RoleCenter;
    Caption = 'Social Credit';
    ApplicationArea = All;

    layout
    {
        area(RoleCenter)
        {
            part(Headline; "SC Headline Part")
            {
                ApplicationArea = All;
            }
            part(Cues; "SC Cue Part")
            {
                ApplicationArea = All;
            }
        }
    }

    actions
    {
        area(Sections)
        {
            group(SCSection)
            {
                Caption = 'Social Credit';
                action(GoAjustarPuntos)
                {
                    ApplicationArea = All;
                    Caption = 'Ajustar Puntos';
                    RunObject = page "Social Credit Adjust";
                    ToolTip = 'Ajusta manualmente los puntos de Social Credit de un cliente.';
                }
                action(GoSlider)
                {
                    ApplicationArea = All;
                    Caption = 'Slider de Puntos';
                    RunObject = page "SC Slider";
                    ToolTip = 'Ajusta los puntos con el slider interactivo.';
                }
                action(GoHistorial)
                {
                    ApplicationArea = All;
                    Caption = 'Historial de Cambios';
                    RunObject = page "Social Credit History";
                    ToolTip = 'Consulta el log de todos los ajustes de puntos.';
                }
                action(GoInforme)
                {
                    ApplicationArea = All;
                    Caption = 'Informe de Puntuaciones';
                    RunObject = page "Social Credit Report";
                    ToolTip = 'Informe completo con gráficas exportable a PDF, Excel y CSV.';
                }
                action(GoChat)
                {
                    ApplicationArea = All;
                    Caption = 'Chat IA';
                    RunObject = page "SC Chat";
                    ToolTip = 'Chatbot con IA para consultas sobre Social Credit.';
                }
                action(GoHub)
                {
                    ApplicationArea = All;
                    Caption = 'Centro de Extension';
                    RunObject = page "Extension SC";
                    ToolTip = 'Hub central con todos los accesos de la extensión.';
                }
            }
            group(ClientsSection)
            {
                Caption = 'Clientes';
                action(GoCustomerList)
                {
                    ApplicationArea = All;
                    Caption = 'Lista de Clientes';
                    RunObject = page "Customer List";
                    ToolTip = 'Lista de clientes con columnas de Social Credit.';
                }
                action(GoCustomerCard)
                {
                    ApplicationArea = All;
                    Caption = 'Ficha de Cliente';
                    RunObject = page "Customer Card";
                    ToolTip = 'Ficha de cliente con FactBox de Social Credit.';
                }
            }
            group(SalesSection)
            {
                Caption = 'Ventas';
                action(GoSalesOrder)
                {
                    ApplicationArea = All;
                    Caption = 'Pedidos de Venta';
                    RunObject = page "Sales Order List";
                }
                action(GoSalesInvoice)
                {
                    ApplicationArea = All;
                    Caption = 'Facturas de Venta';
                    RunObject = page "Sales Invoice List";
                }
            }
        }
    }
}
