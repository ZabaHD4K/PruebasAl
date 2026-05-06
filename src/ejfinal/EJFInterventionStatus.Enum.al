enum 50104 "EJF Intervention Status"
{
    Extensible = true;
    AssignmentCompatibility = true;

    value(0; Open)
    {
        Caption = 'Open', Comment = 'ESP="Abierto"';
    }
    value(1; Released)
    {
        Caption = 'Released', Comment = 'ESP="Lanzado"';
    }
    value(2; Posted)
    {
        Caption = 'Posted', Comment = 'ESP="Registrado"';
    }
}
