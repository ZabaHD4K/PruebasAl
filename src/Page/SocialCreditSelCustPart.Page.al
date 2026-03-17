page 50103 "SC Sel Cust Part"
{
    PageType = ListPart;
    Caption = 'Clientes en la gráfica';
    ApplicationArea = All;
    SourceTable = Customer;
    SourceTableTemporary = true;
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(CustomerList)
            {
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                    Caption = 'Nº';
                }
                field(Name; Rec.Name)
                {
                    ApplicationArea = All;
                    Caption = 'Nombre';
                }
                field("Social Credit Points"; Rec."Social Credit Points")
                {
                    ApplicationArea = All;
                    Caption = 'Puntos SC';
                }
            }
        }
    }

    procedure SetCustomers(var TempCust: Record Customer temporary)
    begin
        Rec.Reset();
        Rec.DeleteAll();
        if TempCust.FindSet() then
            repeat
                Rec := TempCust;
                Rec.Insert();
            until TempCust.Next() = 0;
        CurrPage.Update(false);
    end;

    procedure GetCurrentNo(): Code[20]
    begin
        exit(Rec."No.");
    end;
}
