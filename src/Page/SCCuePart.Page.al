page 50115 "SC Cue Part"
{
    PageType = CardPart;
    Caption = 'Social Credit';
    SourceTable = "SC Cue";
    RefreshOnActivate = true;
    InsertAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(Content)
        {
            cuegroup(SCCues)
            {
                Caption = 'Clientes por rango';
                field("Clientes Ejemplar"; Rec."Clientes Ejemplar")
                {
                    ApplicationArea = All;
                    Caption = 'Ciudadano Ejemplar';
                    Style = Favorable;
                    DrillDownPageId = "Social Credit Report";
                    ToolTip = 'Clientes con 1500 o más puntos de Social Credit.';
                }
                field("Clientes Normal"; Rec."Clientes Normal")
                {
                    ApplicationArea = All;
                    Caption = 'Ciudadano Normal';
                    Style = StandardAccent;
                    DrillDownPageId = "Social Credit Report";
                    ToolTip = 'Clientes con entre 1000 y 1499 puntos de Social Credit.';
                }
                field("Clientes Supervision"; Rec."Clientes Supervision")
                {
                    ApplicationArea = All;
                    Caption = 'Bajo Supervision';
                    Style = Attention;
                    DrillDownPageId = "Social Credit Report";
                    ToolTip = 'Clientes con entre 500 y 999 puntos de Social Credit.';
                }
                field("Clientes Lista Negra"; Rec."Clientes Lista Negra")
                {
                    ApplicationArea = All;
                    Caption = 'Lista Negra';
                    Style = Unfavorable;
                    DrillDownPageId = "Social Credit Report";
                    ToolTip = 'Clientes con menos de 500 puntos de Social Credit.';
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        if not Rec.Get('') then begin
            Rec.Init();
            Rec."Primary Key" := '';
            Rec.Insert(true);
        end;
        Rec.CalcFields(
            "Clientes Ejemplar",
            "Clientes Normal",
            "Clientes Supervision",
            "Clientes Lista Negra");
    end;
}
