table 50114 "EJF Intervention Line"
{
    Caption = 'Intervention Line', Comment = 'ESP="Línea de Intervención"';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Document No."; Code[20])
        {
            Caption = 'Document No.', Comment = 'ESP="Nº Documento"';
            DataClassification = CustomerContent;
            TableRelation = "EJF Intervention Header";
        }
        field(2; "Line No."; Integer)
        {
            Caption = 'Line No.', Comment = 'ESP="Nº Línea"';
            DataClassification = CustomerContent;
        }
        field(3; Description; Text[100])
        {
            Caption = 'Description', Comment = 'ESP="Descripción"';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if Description = '' then
                    Error('La descripción de la línea no puede estar vacía.');
            end;
        }
        field(4; Quantity; Decimal)
        {
            Caption = 'Quantity', Comment = 'ESP="Cantidad"';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if Quantity <= 0 then
                    Error('La cantidad debe ser mayor que cero.');
                CalculateAmount();
            end;
        }
        field(5; Hours; Decimal)
        {
            Caption = 'Hours', Comment = 'ESP="Horas"';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if Hours < 0 then
                    Error('Las horas no pueden ser negativas.');
            end;
        }
        field(6; "Unit Cost"; Decimal)
        {
            Caption = 'Unit Cost', Comment = 'ESP="Coste Unitario"';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if "Unit Cost" < 0 then
                    Error('El coste unitario no puede ser negativo.');
                CalculateAmount();
            end;
        }
        field(7; Amount; Decimal)
        {
            Caption = 'Amount', Comment = 'ESP="Importe"';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(8; Billable; Boolean)
        {
            Caption = 'Billable', Comment = 'ESP="Facturable"';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; "Document No.", "Line No.")
        {
            Clustered = true;
        }
    }

    trigger OnInsert()
    begin
        CheckHeaderStatus();
    end;

    trigger OnModify()
    begin
        CheckHeaderStatus();
    end;

    trigger OnDelete()
    begin
        CheckHeaderStatus();
    end;

    local procedure CalculateAmount()
    begin
        Amount := Quantity * "Unit Cost";
    end;

    local procedure CheckHeaderStatus()
    var
        Header: Record "EJF Intervention Header";
    begin
        if "Document No." = '' then
            exit;
        if Header.Get("Document No.") then
            if Header.Status <> "EJF Intervention Status"::Open then
                Error('No se pueden modificar líneas de un documento que no está en estado Abierto.');
    end;
}
