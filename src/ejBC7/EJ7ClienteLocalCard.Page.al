page 50129 "EJ7 Cliente Local Card"
{
    PageType = Card;
    SourceTable = "EJ7 Cliente Local";
    Caption = 'Ficha Cliente Local';
    ApplicationArea = All;
    UsageCategory = None;

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';

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
                    ToolTip = 'Especifica el cliente de BC asociado. Al cambiarlo se actualiza la última factura.';

                    trigger OnValidate()
                    begin
                        CurrPage.Update(false);
                    end;
                }
                field("Nombre Cliente Generico"; Rec."Nombre Cliente Generico")
                {
                    ApplicationArea = All;
                    ToolTip = 'Nombre del cliente de BC asociado (calculado automáticamente).';
                }
                field("Ultima Factura"; Rec."Ultima Factura")
                {
                    ApplicationArea = All;
                    ToolTip = 'Última factura de venta registrada para el cliente de BC asociado.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(VerPedidos)
            {
                ApplicationArea = All;
                Caption = 'Ver Pedidos';
                Image = Order;
                ToolTip = 'Muestra los pedidos de venta del cliente genérico asociado.';

                trigger OnAction()
                var
                    SalesHdr: Record "Sales Header";
                begin
                    if Rec."No. Cliente Generico" = '' then begin
                        Message('No hay ningún cliente genérico asignado.');
                        exit;
                    end;
                    SalesHdr.SetRange("Document Type", SalesHdr."Document Type"::Order);
                    SalesHdr.SetRange("Sell-to Customer No.", Rec."No. Cliente Generico");
                    Page.Run(9305, SalesHdr);
                end;
            }
            action(Imprimir)
            {
                ApplicationArea = All;
                Caption = 'Imprimir';
                Image = Print;
                ToolTip = 'Genera el informe de clientes locales en PDF.';

                trigger OnAction()
                var
                    Rpt: Report "EJ7 Clientes Locales";
                begin
                    Rpt.Run();
                end;
            }
            action(CopiarCliente)
            {
                ApplicationArea = All;
                Caption = 'Copiar cliente';
                Image = Copy;
                ToolTip = 'Crea una copia de este cliente local añadiendo "-COPIA" al número y al nombre.';

                trigger OnAction()
                var
                    NuevoCliente: Record "EJ7 Cliente Local";
                    NuevoNo: Code[20];
                    NuevoNombre: Text[100];
                    AlreadyExistsErr: Label 'Ya existe un cliente local con el número "%1". Elimínalo antes de volver a copiar.';
                    CopiadoMsg: Label 'Cliente copiado correctamente con número "%1".';
                begin
                    NuevoNo := CopyStr(Rec."No. Cliente Local" + '-COPIA', 1, MaxStrLen(Rec."No. Cliente Local"));
                    NuevoNombre := CopyStr(Rec.Nombre + '-COPIA', 1, MaxStrLen(Rec.Nombre));

                    if NuevoCliente.Get(NuevoNo) then
                        Error(AlreadyExistsErr, NuevoNo);

                    NuevoCliente.Init();
                    NuevoCliente."No. Cliente Local" := NuevoNo;
                    NuevoCliente.Nombre := NuevoNombre;
                    NuevoCliente."No. Cliente Generico" := Rec."No. Cliente Generico";
                    NuevoCliente."Ultima Factura" := Rec."Ultima Factura";
                    NuevoCliente.Insert(true);

                    Message(CopiadoMsg, NuevoNo);
                end;
            }
        }
        area(Promoted)
        {
            actionref(VerPedidos_Ref; VerPedidos) { }
            actionref(CopiarCliente_Ref; CopiarCliente) { }
        }
    }
}
