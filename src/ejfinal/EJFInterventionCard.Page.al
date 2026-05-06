page 50133 "EJF Intervention Card"
{
    Caption = 'Intervention Card', Comment = 'ESP="Ficha de Intervención"';
    PageType = Card;
    SourceTable = "EJF Intervention Header";
    ApplicationArea = All;
    UsageCategory = Documents;

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                }
                field(Description; Rec.Description)
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
            }
            group(Customer)
            {
                Caption = 'Customer', Comment = 'ESP="Cliente"';
                field("Customer No."; Rec."Customer No.")
                {
                    ApplicationArea = All;
                }
                field("Customer Name"; Rec."Customer Name")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field(City; Rec.City)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Phone No."; Rec."Phone No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
            }
            group(Totals)
            {
                Caption = 'Totals', Comment = 'ESP="Totales"';
                field("Total Hours"; Rec."Total Hours")
                {
                    ApplicationArea = All;
                }
                field("Total Amount"; Rec."Total Amount")
                {
                    ApplicationArea = All;
                }
            }
            part(Lines; "EJF Intervention Subpage")
            {
                ApplicationArea = All;
                SubPageLink = "Document No." = field("No.");
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(InsertSuggestedLine)
            {
                Caption = 'Insert Suggested Line', Comment = 'ESP="Insertar Línea Sugerida"';
                ApplicationArea = All;
                Image = SuggestLines;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                var
                    Mgt: Codeunit "EJF Intervention Mgt";
                begin
                    Mgt.InsertSuggestedLine(Rec);
                    CurrPage.Lines.Page.Update(false);
                end;
            }
            action(Release)
            {
                Caption = 'Release', Comment = 'ESP="Lanzar"';
                ApplicationArea = All;
                Image = ReleaseDoc;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                var
                    Mgt: Codeunit "EJF Intervention Mgt";
                begin
                    Mgt.ReleaseIntervention(Rec);
                    CurrPage.Update(false);
                end;
            }
            action(Reopen)
            {
                Caption = 'Reopen', Comment = 'ESP="Reabrir"';
                ApplicationArea = All;
                Image = ReOpen;
                Promoted = true;
                PromotedCategory = Process;

                trigger OnAction()
                var
                    Mgt: Codeunit "EJF Intervention Mgt";
                begin
                    Mgt.ReopenIntervention(Rec);
                    CurrPage.Update(false);
                end;
            }
            action(Post)
            {
                Caption = 'Post', Comment = 'ESP="Registrar"';
                ApplicationArea = All;
                Image = Post;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                var
                    Mgt: Codeunit "EJF Intervention Mgt";
                begin
                    Mgt.PostIntervention(Rec);
                    CurrPage.Update(false);
                end;
            }
            action(Print)
            {
                Caption = 'Print', Comment = 'ESP="Imprimir"';
                ApplicationArea = All;
                Image = Print;
                Promoted = true;
                PromotedCategory = Process;

                trigger OnAction()
                var
                    PrintReport: Report "EJF Intervention Print";
                begin
                    PrintReport.SetTableView(Rec);
                    PrintReport.Run();
                end;
            }
        }
    }
}
