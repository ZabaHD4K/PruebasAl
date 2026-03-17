pageextension 50100 "Customer List Social Credit" extends "Customer List"
{
    layout
    {
        modify(Name)
        {
            StyleExpr = SocialCreditStyle;
        }
        addafter(Name)
        {
            field(SocialCreditIcon; SocialCreditIcon)
            {
                ApplicationArea = All;
                Caption = '';
                Width = 1;
                Editable = false;
                Visible = true;
                StyleExpr = SocialCreditStyle;
            }
        }
        addbefore("Balance (LCY)")
        {
            field("Social Credit Label"; Rec."Social Credit Label")
            {
                ApplicationArea = All;
                Caption = 'Estado';
                Editable = false;
                StyleExpr = SocialCreditStyle;
            }
            field("Social Credit Points"; Rec."Social Credit Points")
            {
                ApplicationArea = All;
                Caption = 'Social Credit';
                StyleExpr = SocialCreditStyle;
            }
        }
        addlast(factboxes)
        {
            part(SocialCreditFactBox; "Customer Social Credit FactBox")
            {
                ApplicationArea = All;
                Caption = 'Social Credit';
                SubPageLink = "No." = field("No.");
                Visible = true;
            }
        }
    }

    actions
    {
        addlast(processing)
        {
            action(RefreshSocialCredit)
            {
                ApplicationArea = All;
                Caption = 'Ajustar Social Credit';
                Image = Edit;
                ToolTip = 'Abre el panel para subir o bajar puntos de Social Credit de un cliente.';

                trigger OnAction()
                var
                    AdjustPage: Page "Social Credit Adjust";
                begin
                    AdjustPage.SetCustomer(Rec."No.");
                    AdjustPage.RunModal();
                    CurrPage.Update(false);
                end;
            }
        }
    }

    var
        SocialCreditStyle: Text;
        SocialCreditIcon: Text[10];

    trigger OnAfterGetRecord()
    begin
        RefreshSocialCredit();
    end;

    local procedure RefreshSocialCredit()
    var
        SocialCreditMgt: Codeunit "Social Credit Mgt";
    begin
        SocialCreditStyle := SocialCreditMgt.GetStyle(Rec."Social Credit Points");
        SocialCreditIcon := CopyStr(SocialCreditMgt.GetLabel(Rec."Social Credit Points"), 1, 2);
    end;
}
