page 50101 "Social Credit Adjust"
{
    PageType = Card;
    Caption = 'Ajustar Social Credit';
    ApplicationArea = All;
    UsageCategory = None;

    layout
    {
        area(Content)
        {
            group(CustomerGroup)
            {
                Caption = 'Cliente';
                field(CustomerNo; CustomerNo)
                {
                    ApplicationArea = All;
                    Caption = 'Nº Cliente';
                    TableRelation = Customer."No.";
                    trigger OnValidate()
                    begin
                        LoadCustomer();
                    end;
                }
                field(CustomerName; CustomerName)
                {
                    ApplicationArea = All;
                    Caption = 'Nombre';
                    Editable = false;
                }
            }
            group(PointsGroup)
            {
                Caption = 'Social Credit';
                field(CurrentPoints; CurrentPoints)
                {
                    ApplicationArea = All;
                    Caption = 'Puntos';
                    Editable = false;
                    StyleExpr = CurrentStyle;
                }
                field(CurrentLabel; CurrentLabel)
                {
                    ApplicationArea = All;
                    Caption = 'Estado';
                    Editable = false;
                    StyleExpr = CurrentStyle;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(SubirPuntos)
            {
                ApplicationArea = All;
                Caption = 'Subir +100';
                Image = Add;
                ToolTip = 'Añade 100 puntos de Social Credit al cliente seleccionado.';
                trigger OnAction()
                begin
                    AdjustPoints(100);
                end;
            }
            action(BajarPuntos)
            {
                ApplicationArea = All;
                Caption = 'Bajar -100';
                Image = Minus;
                ToolTip = 'Resta 100 puntos de Social Credit al cliente seleccionado.';
                trigger OnAction()
                begin
                    AdjustPoints(-100);
                end;
            }
        }
        area(Promoted)
        {
            actionref(SubirPuntosRef; SubirPuntos) { }
            actionref(BajarPuntosRef; BajarPuntos) { }
        }
    }

    var
        CustomerNo: Code[20];
        CustomerName: Text[100];
        CurrentPoints: Integer;
        CurrentLabel: Text[30];
        CurrentStyle: Text;

    trigger OnOpenPage()
    begin
        if CustomerNo <> '' then
            LoadCustomer();
    end;

    procedure SetCustomer(NewCustomerNo: Code[20])
    begin
        CustomerNo := NewCustomerNo;
    end;

    local procedure LoadCustomer()
    var
        Customer: Record Customer;
        SocialCreditMgt: Codeunit "Social Credit Mgt";
    begin
        if CustomerNo = '' then begin
            CustomerName := '';
            CurrentPoints := 0;
            CurrentLabel := '';
            CurrentStyle := '';
            exit;
        end;
        Customer.Get(CustomerNo);
        CustomerName := Customer.Name;
        CurrentPoints := Customer."Social Credit Points";
        CurrentLabel := Customer."Social Credit Label";
        CurrentStyle := SocialCreditMgt.GetStyle(CurrentPoints);
    end;

    local procedure AdjustPoints(Delta: Integer)
    var
        Customer: Record Customer;
        SocialCreditMgt: Codeunit "Social Credit Mgt";
        PointsBefore: Integer;
    begin
        if CustomerNo = '' then begin
            Message('Selecciona un cliente primero.');
            exit;
        end;
        Customer.Get(CustomerNo);
        PointsBefore := Customer."Social Credit Points";
        Customer."Social Credit Points" := Customer."Social Credit Points" + Delta;
        if Customer."Social Credit Points" < 0 then
            Customer."Social Credit Points" := 0;
        Customer."Social Credit Label" := SocialCreditMgt.GetLabel(Customer."Social Credit Points");
        Customer.Modify(true);
        SocialCreditMgt.LogChange(CustomerNo, CustomerName, PointsBefore, Customer."Social Credit Points");
        CurrentPoints := Customer."Social Credit Points";
        CurrentLabel := Customer."Social Credit Label";
        CurrentStyle := SocialCreditMgt.GetStyle(CurrentPoints);
        CurrPage.Update(false);
    end;
}
