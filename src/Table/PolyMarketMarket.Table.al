table 50107 "PolyMarket Market"
{
    Caption = 'Mercado PolyMarket';
    TableType = Temporary;
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Entry No."; Integer) { Caption = 'N.º'; }
        field(2; Question; Text[500]) { Caption = 'Mercado / Pregunta'; }
        field(3; Category; Text[100]) { Caption = 'Categoría'; }
        field(4; "Yes Probability"; Decimal)
        {
            Caption = 'Sí %';
            DecimalPlaces = 1 : 1;
        }
        field(5; "No Probability"; Decimal)
        {
            Caption = 'No %';
            DecimalPlaces = 1 : 1;
        }
        field(6; Volume; Decimal)
        {
            Caption = 'Volumen ($)';
            DecimalPlaces = 0 : 0;
        }
        field(7; "End Date"; Date) { Caption = 'Cierre'; }
        field(8; Featured; Boolean) { Caption = 'Dest.'; }
        field(9; "Search Text"; Text[700]) { Caption = 'Texto búsqueda'; }
    }

    keys
    {
        key(PK; "Entry No.") { Clustered = true; }
    }
}
