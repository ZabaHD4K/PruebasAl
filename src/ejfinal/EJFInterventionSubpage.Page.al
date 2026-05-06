page 50134 "EJF Intervention Subpage"
{
    Caption = 'Intervention Lines', Comment = 'ESP="Líneas de Intervención"';
    PageType = ListPart;
    SourceTable = "EJF Intervention Line";
    AutoSplitKey = true;

    layout
    {
        area(Content)
        {
            repeater(Lines)
            {
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                }
                field(Quantity; Rec.Quantity)
                {
                    ApplicationArea = All;
                }
                field(Hours; Rec.Hours)
                {
                    ApplicationArea = All;
                }
                field("Unit Cost"; Rec."Unit Cost")
                {
                    ApplicationArea = All;
                }
                field(Amount; Rec.Amount)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field(Billable; Rec.Billable)
                {
                    ApplicationArea = All;
                }
            }
        }
    }
}
