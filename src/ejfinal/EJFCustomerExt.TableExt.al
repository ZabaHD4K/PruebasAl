tableextension 50102 "EJF Customer Ext" extends Customer
{
    fields
    {
        field(50104; "EJF Preferred Technician"; Text[100])
        {
            Caption = 'Preferred Technician', Comment = 'ESP="Técnico Preferente"';
            DataClassification = CustomerContent;
        }
        field(50105; "EJF Max Suggested Hours"; Decimal)
        {
            Caption = 'Max Suggested Hours', Comment = 'ESP="Horas Máximas Sugeridas"';
            DataClassification = CustomerContent;
        }
        field(50106; "EJF Last Intervention Date"; Date)
        {
            Caption = 'Last Intervention Date', Comment = 'ESP="Fecha Última Intervención"';
            DataClassification = CustomerContent;
        }
        field(50107; "EJF Accumulated Amount"; Decimal)
        {
            Caption = 'Accumulated Intervention Amount', Comment = 'ESP="Importe Acumulado Intervenciones"';
            DataClassification = CustomerContent;
        }
    }
}
