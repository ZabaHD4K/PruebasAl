table 50110 "EJ2 Linea Tarea"
{
    Caption = 'Task Line', Comment = 'ESP="Línea Tarea"';
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
            TableRelation = "EJ2 Cabecera Tarea"."No. Tarea"
                            where("Tipo Tarea" = field("Tipo Tarea"));
        }
        field(3; "Linea Tarea"; Integer)
        {
            Caption = 'Line No.', Comment = 'ESP="Línea Tarea"';
        }
        field(4; Descripcion; Text[100])
        {
            Caption = 'Description', Comment = 'ESP="Descripción"';
        }
        field(5; Terminada; Boolean)
        {
            Caption = 'Done', Comment = 'ESP="Terminada"';
        }
        field(6; "Horas Dedicadas"; Decimal)
        {
            Caption = 'Hours Spent', Comment = 'ESP="Horas Dedicadas"';
            MinValue = 0;
        }
    }

    keys
    {
        key(PK; "Tipo Tarea", "No. Tarea", "Linea Tarea") { Clustered = true; }
    }

    trigger OnInsert()
    var
        CabTarea: Record "EJ2 Cabecera Tarea";
        ErrTerminadaLbl: Label 'Cannot add lines to a completed task.',
            Comment = 'ESP="No se pueden añadir líneas en una tarea Terminada."';
    begin
        if CabTarea.Get(Rec."Tipo Tarea", Rec."No. Tarea") then begin
            if CabTarea.Estado = "EJ2 Estado Tarea"::Terminada then
                Error(ErrTerminadaLbl);

            if CabTarea.Estado = "EJ2 Estado Tarea"::Notificada then begin
                CabTarea.Estado := "EJ2 Estado Tarea"::EnCurso;
                CabTarea.Modify(true);
            end;
        end;
    end;
}
