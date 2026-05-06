page 50132 "EJF Intervention List"
{
    Caption = 'Intervention List', Comment = 'ESP="Lista de Intervenciones"';
    PageType = List;
    SourceTable = "EJF Intervention Header";
    CardPageId = "EJF Intervention Card";
    Editable = false;
    ApplicationArea = All;
    UsageCategory = Lists;

    layout
    {
        area(Content)
        {
            repeater(Headers)
            {
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                }
                field("Customer No."; Rec."Customer No.")
                {
                    ApplicationArea = All;
                }
                field("Customer Name"; Rec."Customer Name")
                {
                    ApplicationArea = All;
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = All;
                }
                field("Requested Date"; Rec."Requested Date")
                {
                    ApplicationArea = All;
                }
                field("Planned Date"; Rec."Planned Date")
                {
                    ApplicationArea = All;
                }
                field("Total Hours"; Rec."Total Hours")
                {
                    ApplicationArea = All;
                }
                field("Total Amount"; Rec."Total Amount")
                {
                    ApplicationArea = All;
                }
            }
        }
    }
}
