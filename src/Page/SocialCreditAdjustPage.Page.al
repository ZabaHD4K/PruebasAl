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
            group(AdjustGroup)
            {
                Caption = 'Ajuste';
                field(AdjustDirection; AdjustDirection)
                {
                    ApplicationArea = All;
                    Caption = 'Dirección';
                    ToolTip = 'Selecciona si quieres subir o bajar puntos.';
                }
                field(AdjustAmount; AdjustAmount)
                {
                    ApplicationArea = All;
                    Caption = 'Cantidad';
                    MinValue = 1;
                    ToolTip = 'Número de puntos a aplicar.';
                }
                field(Reason; Reason)
                {
                    ApplicationArea = All;
                    Caption = 'Motivo';
                    ToolTip = 'Indica el motivo del ajuste.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(AplicarAjuste)
            {
                ApplicationArea = All;
                Caption = 'Aplicar ajuste';
                Image = Apply;
                ToolTip = 'Aplica el ajuste de puntos al cliente seleccionado.';
                trigger OnAction()
                begin
                    case AdjustDirection of
                        AdjustDirection::Subir:
                            AdjustPoints(AdjustAmount);
                        AdjustDirection::Bajar:
                            AdjustPoints(-AdjustAmount);
                    end;
                end;
            }
        }
        area(Promoted)
        {
            actionref(AplicarAjusteRef; AplicarAjuste) { }
        }
    }

    var
        CustomerNo: Code[20];
        CustomerName: Text[100];
        CurrentPoints: Integer;
        CurrentLabel: Text[50];
        CurrentStyle: Text;
        AdjustDirection: Option Subir,Bajar;
        AdjustAmount: Integer;
        Reason: Text[250];

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
        if AdjustAmount <= 0 then begin
            Message('Introduce una cantidad mayor que cero.');
            exit;
        end;
        if Reason = '' then begin
            Message('Introduce un motivo antes de ajustar los puntos.');
            exit;
        end;
        Customer.Get(CustomerNo);
        PointsBefore := Customer."Social Credit Points";
        if (PointsBefore + Delta) < 0 then begin
            Message('No se puede aplicar el ajuste: el cliente tiene %1 puntos y restar %2 daría un resultado negativo.', PointsBefore, AdjustAmount);
            exit;
        end;
        SocialCreditMgt.AdjustCustomerPoints(CustomerNo, Delta, Reason);
        Reason := '';
        AdjustAmount := 0;
        LoadCustomer();
        CurrPage.Update(false);
    end;
}
