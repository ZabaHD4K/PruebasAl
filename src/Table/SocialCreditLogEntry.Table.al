table 50102 "Social Credit Log Entry"
{
    Caption = 'Social Credit Log';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            AutoIncrement = true;
            Caption = 'Nº Entrada';
        }
        field(2; "Customer No."; Code[20])
        {
            Caption = 'Nº Cliente';
            TableRelation = Customer."No.";
        }
        field(3; "Customer Name"; Text[100])
        {
            Caption = 'Nombre';
        }
        field(4; "Points Before"; Integer)
        {
            Caption = 'Puntos Antes';
        }
        field(5; "Points After"; Integer)
        {
            Caption = 'Puntos Después';
        }
        field(6; "Change"; Integer)
        {
            Caption = 'Cambio';
        }
        field(7; "Log DateTime"; DateTime)
        {
            Caption = 'Fecha y Hora';
        }
        field(8; "User ID"; Code[50])
        {
            Caption = 'Usuario';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(9; "Reason"; Text[250])
        {
            Caption = 'Motivo';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; "Entry No.") { Clustered = true; }
        key(CustomerDate; "Customer No.", "Log DateTime") { }
        key(DateOnly; "Log DateTime") { }
    }
}
