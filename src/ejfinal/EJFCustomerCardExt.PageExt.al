pageextension 50110 "EJF Customer Card Ext" extends "Customer Card"
{
    layout
    {
        addlast(content)
        {
            group(EJFInterventions)
            {
                Caption = 'Interventions', Comment = 'ESP="Intervenciones"';
                field("EJF Preferred Technician"; Rec."EJF Preferred Technician")
                {
                    ApplicationArea = All;
                }
                field("EJF Max Suggested Hours"; Rec."EJF Max Suggested Hours")
                {
                    ApplicationArea = All;
                }
                field("EJF Last Intervention Date"; Rec."EJF Last Intervention Date")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("EJF Accumulated Amount"; Rec."EJF Accumulated Amount")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
            }
        }
    }

    actions
    {
        addlast(processing)
        {
            action(ViewInterventions)
            {
                Caption = 'Interventions', Comment = 'ESP="Intervenciones"';
                ApplicationArea = All;
                Image = ServiceLedger;
                RunObject = page "EJF Intervention List";
                RunPageLink = "Customer No." = field("No.");
                RunPageMode = View;
                Promoted = true;
                PromotedCategory = Process;
            }
        }
    }
}
