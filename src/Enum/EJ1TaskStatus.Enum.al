enum 50101 "EJ1 Task Status"
{
    Extensible = true;

    value(0; Open)
    {
        Caption = 'Open', Comment = 'ESP="Abierta"';
    }
    value(1; InProgress)
    {
        Caption = 'In Progress', Comment = 'ESP="En progreso"';
    }
    value(2; Completed)
    {
        Caption = 'Completed', Comment = 'ESP="Completada"';
    }
}
