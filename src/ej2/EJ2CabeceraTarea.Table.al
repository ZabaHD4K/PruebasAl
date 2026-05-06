table 50109 "EJ2 Cabecera Tarea"
{
    Caption = 'Task Header', Comment = 'ESP="Cabecera Tarea"';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Tipo Tarea"; Enum "EJ2 Tipo Tarea")
        {
            Caption = 'Task Type', Comment = 'ESP="Tipo Tarea"';
        }
        field(2; "No. Tarea"; Code[20])
        {
            Caption = 'Task No.', Comment = 'ESP="No. Tarea"';
            NotBlank = true;
        }
        field(3; Descripcion; Text[50])
        {
            Caption = 'Description', Comment = 'ESP="Descripción"';
        }
        field(4; Estado; Enum "EJ2 Estado Tarea")
        {
            Caption = 'Status', Comment = 'ESP="Estado"';
        }
        field(5; "Horas Dedicadas"; Decimal)
        {
            Caption = 'Hours Spent', Comment = 'ESP="Horas Dedicadas"';
            FieldClass = FlowField;
            CalcFormula = sum("EJ2 Linea Tarea"."Horas Dedicadas"
                              where("Tipo Tarea" = field("Tipo Tarea"),
                                    "No. Tarea"  = field("No. Tarea")));
            Editable = false;
        }
        field(6; "Usuario Creacion"; Text[250])
        {
            Caption = 'Created By', Comment = 'ESP="Usuario Creación"';
            DataClassification = EndUserIdentifiableInformation;
            Editable = false;
        }
    }

    keys
    {
        key(PK; "Tipo Tarea", "No. Tarea") { Clustered = true; }
    }

    trigger OnInsert()
    begin
        if Rec."Usuario Creacion" = '' then
            Rec."Usuario Creacion" := UserId();
    end;

    trigger OnDelete()
    var
        LinTarea: Record "EJ2 Linea Tarea";
    begin
        LinTarea.SetRange("Tipo Tarea", Rec."Tipo Tarea");
        LinTarea.SetRange("No. Tarea", Rec."No. Tarea");
        LinTarea.DeleteAll(true);
    end;
}
