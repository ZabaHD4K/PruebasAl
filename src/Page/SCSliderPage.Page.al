page 50114 "SC Slider"
{
    PageType = Card;
    Caption = 'Ajuste de puntos con Slider';
    ApplicationArea = All;
    UsageCategory = Administration;

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
            group(SliderGroup)
            {
                Caption = 'Social Credit';
                Visible = CustomerNo <> '';
                usercontrol(SliderAddin; "SC Slider Addin")
                {
                    ApplicationArea = All;
                    trigger OnValueChanged(NewValue: Integer)
                    begin
                        ApplySliderValue(NewValue);
                    end;
                }
            }
        }
    }

    var
        CustomerNo: Code[20];
        CustomerName: Text[100];
        CurrentPoints: Integer;

    local procedure LoadCustomer()
    var
        Customer: Record Customer;
    begin
        if CustomerNo = '' then begin
            CustomerName := '';
            CurrentPoints := 0;
            exit;
        end;
        Customer.SetLoadFields(Name, "Social Credit Points");
        Customer.Get(CustomerNo);
        CustomerName := Customer.Name;
        CurrentPoints := Customer."Social Credit Points";
        CurrPage.SliderAddin.SetValue(CurrentPoints);
    end;

    local procedure ApplySliderValue(NewValue: Integer)
    var
        Customer: Record Customer;
        SocialCreditMgt: Codeunit "Social Credit Mgt";
        Delta: Integer;
    begin
        if CustomerNo = '' then
            exit;

        Customer.SetLoadFields("Social Credit Points");
        Customer.Get(CustomerNo);
        Delta := NewValue - Customer."Social Credit Points";

        if Delta = 0 then
            exit;

        SocialCreditMgt.AdjustCustomerPoints(CustomerNo, Delta, 'Ajustado via Slider JS');
        CurrentPoints := NewValue;
    end;
}
