table 50112 "EJ7 Cliente Local"
{
    Caption = 'Cliente Local';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "No. Cliente Local"; Code[20])
        {
            Caption = 'No. Cliente Local';
            NotBlank = true;
        }
        field(2; Nombre; Text[100])
        {
            Caption = 'Nombre';
        }
        field(3; "No. Cliente Generico"; Code[20])
        {
            Caption = 'No. Cliente Genérico';
            TableRelation = Customer;

            trigger OnValidate()
            begin
                if Rec."No. Cliente Generico" = '' then begin
                    Rec."Ultima Factura" := '';
                    exit;
                end;
                UpdateUltimaFactura();
            end;
        }
        field(4; "Nombre Cliente Generico"; Text[100])
        {
            Caption = 'Nombre Cliente Genérico';
            FieldClass = FlowField;
            CalcFormula = lookup(Customer.Name where("No." = field("No. Cliente Generico")));
            Editable = false;
        }
        field(5; "Ultima Factura"; Code[20])
        {
            Caption = 'Última Factura';
            Editable = false;
        }
    }

    keys
    {
        key(PK; "No. Cliente Local") { Clustered = true; }
    }

    local procedure UpdateUltimaFactura()
    var
        SalesInvHdr: Record "Sales Invoice Header";
    begin
        SalesInvHdr.SetRange("Sell-to Customer No.", Rec."No. Cliente Generico");
        if SalesInvHdr.FindLast() then
            Rec."Ultima Factura" := SalesInvHdr."No."
        else
            Rec."Ultima Factura" := '';
    end;
}
