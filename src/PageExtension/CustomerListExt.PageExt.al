pageextension 50100 "Customer List Social Credit" extends "Customer List"
{
    layout
    {
        addfirst(content)
        {
            group(SCFilterBar)
            {
                ShowCaption = false;
                Visible = SCFilterBarVisible;

                field(BtnVerde; BtnVerdeLabel)
                {
                    ApplicationArea = All;
                    Caption = ' ';
                    ShowCaption = false;
                    Editable = false;
                    StyleExpr = EstiloVerde;
                    Width = 1;
                    ToolTip = 'Ciudadano Ejemplar (≥ 1500 pts). Haz clic para activar/desactivar el filtro.';

                    trigger OnDrillDown()
                    begin
                        FiltroVerde := not FiltroVerde;
                        RefreshFilterBar();
                        ApplySCFilter();
                    end;
                }
                field(BtnAzul; BtnAzulLabel)
                {
                    ApplicationArea = All;
                    Caption = ' ';
                    ShowCaption = false;
                    Editable = false;
                    StyleExpr = EstiloAzul;
                    Width = 1;
                    ToolTip = 'Ciudadano Normal (1000–1499 pts). Haz clic para activar/desactivar el filtro.';

                    trigger OnDrillDown()
                    begin
                        FiltroAzul := not FiltroAzul;
                        RefreshFilterBar();
                        ApplySCFilter();
                    end;
                }
                field(BtnAmarillo; BtnAmarilloLabel)
                {
                    ApplicationArea = All;
                    Caption = ' ';
                    ShowCaption = false;
                    Editable = false;
                    StyleExpr = EstiloAmarillo;
                    Width = 1;
                    ToolTip = 'Bajo Supervisión (500–999 pts). Haz clic para activar/desactivar el filtro.';

                    trigger OnDrillDown()
                    begin
                        FiltroAmarillo := not FiltroAmarillo;
                        RefreshFilterBar();
                        ApplySCFilter();
                    end;
                }
                field(BtnRojo; BtnRojoLabel)
                {
                    ApplicationArea = All;
                    Caption = ' ';
                    ShowCaption = false;
                    Editable = false;
                    StyleExpr = EstiloRojo;
                    Width = 1;
                    ToolTip = 'Lista Negra (< 500 pts). Haz clic para activar/desactivar el filtro.';

                    trigger OnDrillDown()
                    begin
                        FiltroRojo := not FiltroRojo;
                        RefreshFilterBar();
                        ApplySCFilter();
                    end;
                }
            }
        }

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
        addlast(Promoted)
        {
            actionref(SortSCDesc_Ref; SortSCDesc) { }
            actionref(SortSCAsc_Ref; SortSCAsc) { }
            actionref(ToggleFilterBar_Ref; ToggleFilterBar) { }
            actionref(OpenSCReport_Ref; OpenSCReport) { }
        }

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

            group(SocialCreditSortGroup)
            {
                Caption = 'Ordenar por Social Credit';

                action(SortSCDesc)
                {
                    ApplicationArea = All;
                    Caption = '↓ Mayor a menor';
                    Image = MoveDown;
                    ToolTip = 'Ordena los clientes de mayor a menor puntuación de Social Credit.';

                    trigger OnAction()
                    begin
                        Rec.SetCurrentKey("Social Credit Points");
                        Rec.Ascending(false);
                        CurrPage.Update(false);
                    end;
                }
                action(SortSCAsc)
                {
                    ApplicationArea = All;
                    Caption = '↑ Menor a mayor';
                    Image = MoveUp;
                    ToolTip = 'Ordena los clientes de menor a mayor puntuación de Social Credit.';

                    trigger OnAction()
                    begin
                        Rec.SetCurrentKey("Social Credit Points");
                        Rec.Ascending(true);
                        CurrPage.Update(false);
                    end;
                }
            }

            action(ToggleFilterBar)
            {
                ApplicationArea = All;
                Caption = 'Filtrar por nivel';
                Image = FilterLines;
                ToolTip = 'Muestra u oculta la barra de filtros por nivel de Social Credit.';

                trigger OnAction()
                begin
                    SCFilterBarVisible := not SCFilterBarVisible;
                    CurrPage.Update(false);
                end;
            }
            action(OpenSCReport)
            {
                ApplicationArea = All;
                Caption = 'Social Credit Report';
                Image = Report;
                ToolTip = 'Abre el ranking de clientes ordenado por puntuación de Social Credit.';

                trigger OnAction()
                begin
                    Page.Run(Page::"Social Credit Report");
                end;
            }

            group(ExportGroup)
            {
                Caption = 'Exportar';
                Image = Export;

                action(ExportCSV)
                {
                    ApplicationArea = All;
                    Caption = 'Exportar CSV';
                    Image = ExportToExcel;
                    ToolTip = 'Descarga la lista de clientes en formato CSV.';

                    trigger OnAction()
                    var
                        ExportMgt: Codeunit "SC Export Mgt";
                    begin
                        ExportMgt.ExportCustomersAsCSV();
                    end;
                }
                action(ExportXML)
                {
                    ApplicationArea = All;
                    Caption = 'Exportar XML';
                    Image = XMLFile;
                    ToolTip = 'Descarga la lista de clientes en formato XML.';

                    trigger OnAction()
                    var
                        ExportMgt: Codeunit "SC Export Mgt";
                    begin
                        ExportMgt.ExportCustomersAsXML();
                    end;
                }
                action(ExportJSON)
                {
                    ApplicationArea = All;
                    Caption = 'Exportar JSON';
                    Image = Web;
                    ToolTip = 'Descarga la lista de clientes en formato JSON.';

                    trigger OnAction()
                    var
                        ExportMgt: Codeunit "SC Export Mgt";
                    begin
                        ExportMgt.ExportCustomersAsJSON();
                    end;
                }
                action(ExportExcel)
                {
                    ApplicationArea = All;
                    Caption = 'Exportar Excel';
                    Image = Excel;
                    ToolTip = 'Descarga la lista de clientes en formato Excel (.xlsx).';

                    trigger OnAction()
                    var
                        ExportMgt: Codeunit "SC Export Mgt";
                    begin
                        ExportMgt.ExportCustomersAsExcel();
                    end;
                }
            }
        }
    }

    var
        SocialCreditStyle: Text;
        SocialCreditIcon: Text[10];
        SCFilterBarVisible: Boolean;
        FiltroVerde: Boolean;
        FiltroAzul: Boolean;
        FiltroAmarillo: Boolean;
        FiltroRojo: Boolean;
        BtnVerdeLabel: Text[30];
        BtnAzulLabel: Text[30];
        BtnAmarilloLabel: Text[30];
        BtnRojoLabel: Text[30];
        EstiloVerde: Text;
        EstiloAzul: Text;
        EstiloAmarillo: Text;
        EstiloRojo: Text;

    trigger OnOpenPage()
    begin
        SCFilterBarVisible := true;
        RefreshFilterBar();
    end;

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

    local procedure RefreshFilterBar()
    begin
        if FiltroVerde then begin
            BtnVerdeLabel := '🟢 ✔ Ejemplar';
            EstiloVerde := 'Favorable';
        end else begin
            BtnVerdeLabel := '🟢 Ejemplar';
            EstiloVerde := 'Standard';
        end;

        if FiltroAzul then begin
            BtnAzulLabel := '🔵 ✔ Normal';
            EstiloAzul := 'StandardAccent';
        end else begin
            BtnAzulLabel := '🔵 Normal';
            EstiloAzul := 'Standard';
        end;

        if FiltroAmarillo then begin
            BtnAmarilloLabel := '🟡 ✔ Supervisión';
            EstiloAmarillo := 'Attention';
        end else begin
            BtnAmarilloLabel := '🟡 Supervisión';
            EstiloAmarillo := 'Standard';
        end;

        if FiltroRojo then begin
            BtnRojoLabel := '🔴 ✔ Negra';
            EstiloRojo := 'Unfavorable';
        end else begin
            BtnRojoLabel := '🔴 Negra';
            EstiloRojo := 'Standard';
        end;
    end;

    local procedure ApplySCFilter()
    var
        Filter: Text;
    begin
        if FiltroVerde then
            Filter += '|1500..';
        if FiltroAzul then
            Filter += '|1000..1499';
        if FiltroAmarillo then
            Filter += '|500..999';
        if FiltroRojo then
            Filter += '|..499';

        Filter := Filter.TrimStart('|');

        if Filter = '' then
            Rec.SetRange("Social Credit Points")
        else
            Rec.SetFilter("Social Credit Points", Filter);

        CurrPage.Update(false);
    end;
}
