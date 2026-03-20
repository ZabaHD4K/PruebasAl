table 50105 "SC Cue"
{
    Caption = 'Social Credit Cue';
    DataClassification = SystemMetadata;

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
        }
        field(2; "Clientes Ejemplar"; Integer)
        {
            Caption = 'Ciudadano Ejemplar';
            FieldClass = FlowField;
            CalcFormula = count(Customer where ("Social Credit Points" = filter(>= 1500)));
            Editable = false;
        }
        field(3; "Clientes Normal"; Integer)
        {
            Caption = 'Ciudadano Normal';
            FieldClass = FlowField;
            CalcFormula = count(Customer where ("Social Credit Points" = filter(1000 .. 1499)));
            Editable = false;
        }
        field(4; "Clientes Supervision"; Integer)
        {
            Caption = 'Bajo Supervision';
            FieldClass = FlowField;
            CalcFormula = count(Customer where ("Social Credit Points" = filter(500 .. 999)));
            Editable = false;
        }
        field(5; "Clientes Lista Negra"; Integer)
        {
            Caption = 'Lista Negra';
            FieldClass = FlowField;
            CalcFormula = count(Customer where ("Social Credit Points" = filter(0 .. 499)));
            Editable = false;
        }
    }

    keys
    {
        key(PK; "Primary Key") { Clustered = true; }
    }
}
