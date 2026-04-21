page 50116 "SC Headline Part"
{
    PageType = HeadlinePart;
    Caption = 'Titular Social Credit';
    ApplicationArea = All;
    RefreshOnActivate = true;

    layout
    {
        area(Content)
        {
            group(WorstCustomer)
            {
                field(HeadlineLabel; HeadlineLabelTxt)
                {
                    ApplicationArea = All;
                    Editable = false;
                    ShowCaption = false;
                }
                field(HeadlineValue; HeadlineValueTxt)
                {
                    ApplicationArea = All;
                    Editable = false;
                    ShowCaption = false;
                }
            }
            group(AvgGroup)
            {
                field(AvgLabel; AvgLabelTxt)
                {
                    ApplicationArea = All;
                    Editable = false;
                    ShowCaption = false;
                }
                field(AvgValue; AvgValueTxt)
                {
                    ApplicationArea = All;
                    Editable = false;
                    ShowCaption = false;
                }
            }
        }
    }

    var
        HeadlineLabelTxt: Text;
        HeadlineValueTxt: Text;
        AvgLabelTxt: Text;
        AvgValueTxt: Text;

    trigger OnOpenPage()
    begin
        LoadHeadlines();
    end;

    local procedure LoadHeadlines()
    var
        Customer: Record Customer;
        TotalPoints: BigInteger;
        CustomerCount: Integer;
    begin
        // Worst customer
        Customer.SetLoadFields(Name, "Social Credit Label", "Social Credit Points");
        Customer.SetCurrentKey("Social Credit Points");
        Customer.Ascending(true);
        if Customer.FindFirst() then begin
            HeadlineLabelTxt := 'Cliente con peor Social Credit ahora mismo';
            HeadlineValueTxt := Customer.Name + ' — ' +
                                Customer."Social Credit Label" + '  (' +
                                Format(Customer."Social Credit Points") + ' pts)';
        end else begin
            HeadlineLabelTxt := '';
            HeadlineValueTxt := 'No hay clientes registrados';
        end;

        // Average points
        Customer.SetLoadFields("Social Credit Points");
        if Customer.FindSet() then
            repeat
                TotalPoints += Customer."Social Credit Points";
                CustomerCount += 1;
            until Customer.Next() = 0;

        AvgLabelTxt := 'Puntuacion media de todos los clientes';
        if CustomerCount > 0 then
            AvgValueTxt := Format(Round(TotalPoints / CustomerCount, 1)) + ' pts — ' +
                           Format(CustomerCount) + ' clientes en total'
        else
            AvgValueTxt := '—';
    end;
}
