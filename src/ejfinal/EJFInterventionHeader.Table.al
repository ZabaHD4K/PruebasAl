table 50113 "EJF Intervention Header"
{
    Caption = 'Intervention Header', Comment = 'ESP="Cabecera de Intervención"';
    DataClassification = CustomerContent;
    LookupPageId = "EJF Intervention List";
    DrillDownPageId = "EJF Intervention List";

    fields
    {
        field(1; "No."; Code[20])
        {
            Caption = 'No.', Comment = 'ESP="Nº"';
            DataClassification = CustomerContent;
        }
        field(2; Description; Text[100])
        {
            Caption = 'Description', Comment = 'ESP="Descripción"';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if Description = '' then
                    Error('La descripción no puede estar vacía.');
            end;
        }
        field(3; "Customer No."; Code[20])
        {
            Caption = 'Customer No.', Comment = 'ESP="Nº Cliente"';
            DataClassification = CustomerContent;
            TableRelation = Customer;

            trigger OnValidate()
            var
                Customer: Record Customer;
            begin
                if "Customer No." = '' then begin
                    "Customer Name" := '';
                    City := '';
                    "Phone No." := '';
                    exit;
                end;
                Customer.Get("Customer No.");
                "Customer Name" := Customer.Name;
                City := Customer.City;
                "Phone No." := Customer."Phone No.";
            end;
        }
        field(4; "Customer Name"; Text[100])
        {
            Caption = 'Customer Name', Comment = 'ESP="Nombre Cliente"';
            DataClassification = CustomerContent;
        }
        field(5; "Requested Date"; Date)
        {
            Caption = 'Requested Date', Comment = 'ESP="Fecha Solicitud"';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if "Requested Date" = 0D then
                    Error('La fecha de solicitud debe tener valor.');
                ValidatePlannedDate();
            end;
        }
        field(6; "Planned Date"; Date)
        {
            Caption = 'Planned Date', Comment = 'ESP="Fecha Planificada"';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                ValidatePlannedDate();
            end;
        }
        field(7; Status; Enum "EJF Intervention Status")
        {
            Caption = 'Status', Comment = 'ESP="Estado"';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(8; "Total Hours"; Decimal)
        {
            Caption = 'Total Hours', Comment = 'ESP="Total Horas"';
            FieldClass = FlowField;
            CalcFormula = sum("EJF Intervention Line".Hours where("Document No." = field("No.")));
            Editable = false;
        }
        field(9; "Total Amount"; Decimal)
        {
            Caption = 'Total Amount', Comment = 'ESP="Importe Total"';
            FieldClass = FlowField;
            CalcFormula = sum("EJF Intervention Line".Amount where("Document No." = field("No.")));
            Editable = false;
        }
        field(10; City; Text[30])
        {
            Caption = 'City', Comment = 'ESP="Ciudad"';
            DataClassification = CustomerContent;
        }
        field(11; "Phone No."; Text[30])
        {
            Caption = 'Phone No.', Comment = 'ESP="Teléfono"';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; "No.")
        {
            Clustered = true;
        }
        key(Customer; "Customer No.") { }
    }

    trigger OnInsert()
    begin
        Status := "EJF Intervention Status"::Open;
    end;

    local procedure ValidatePlannedDate()
    begin
        if ("Planned Date" <> 0D) and ("Requested Date" <> 0D) then
            if "Planned Date" < "Requested Date" then
                Error('La fecha planificada no puede ser anterior a la fecha de solicitud.');
    end;
}
