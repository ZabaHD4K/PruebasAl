table 50108 "EJ1 Task"
{
    Caption = 'Task', Comment = 'ESP="Tarea"';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "No."; Code[20])
        {
            Caption = 'No.', Comment = 'ESP="Nº"';
            NotBlank = true;
        }
        field(2; Description; Text[100])
        {
            Caption = 'Description', Comment = 'ESP="Descripción"';
            DataClassification = CustomerContent;
        }
        field(3; Status; Enum "EJ1 Task Status")
        {
            Caption = 'Status', Comment = 'ESP="Estado"';
        }
    }

    keys
    {
        key(PK; "No.") { Clustered = true; }
    }
}
