page 50128 "EJ7 Clientes Locales"
{
    PageType = List;
    SourceTable = "EJ7 Cliente Local";
    Caption = 'Clientes Locales';
    ApplicationArea = All;
    UsageCategory = Lists;
    CardPageId = "EJ7 Cliente Local Card";

    layout
    {
        area(Content)
        {
            repeater(Rows)
            {
                field("No. Cliente Local"; Rec."No. Cliente Local")
                {
                    ApplicationArea = All;
                    ToolTip = 'Especifica el código del cliente local.';
                }
                field(Nombre; Rec.Nombre)
                {
                    ApplicationArea = All;
                    ToolTip = 'Especifica el nombre del cliente local.';
                }
                field("No. Cliente Generico"; Rec."No. Cliente Generico")
                {
                    ApplicationArea = All;
                    ToolTip = 'Especifica el cliente de BC asociado.';
                }
                field("Nombre Cliente Generico"; Rec."Nombre Cliente Generico")
                {
                    ApplicationArea = All;
                    ToolTip = 'Nombre del cliente de BC asociado (calculado).';
                }
                field("Ultima Factura"; Rec."Ultima Factura")
                {
                    ApplicationArea = All;
                    ToolTip = 'Última factura de venta del cliente de BC asociado.';
                }
            }
        }
    }
}
