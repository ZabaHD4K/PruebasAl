table 50103 "SC Report Line"
{
    Caption = 'Social Credit Report Line';
    DataClassification = SystemMetadata;
    TableType = Temporary;

    fields
    {
        field(1; "Line No."; Integer)
        {
            Caption = 'Nº Línea';
        }
        field(2; "Customer No."; Code[20])
        {
            Caption = 'Nº Cliente';
        }
        field(3; "Customer Name"; Text[100])
        {
            Caption = 'Nombre';
        }
        field(4; "Social Credit Points"; Integer)
        {
            Caption = 'Puntos';
        }
        field(5; "Social Credit Label"; Text[50])
        {
            Caption = 'Social Credit';
        }
        field(6; "SC Rank"; Text[50])
        {
            Caption = 'Rango';
        }
        field(7; "SC Style"; Text[30])
        {
            Caption = 'Estilo';
        }
    }

    keys
    {
        key(PK; "Line No.") { Clustered = true; }
    }
}
