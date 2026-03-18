codeunit 50101 "Social Credit Mgt"
{
    procedure GetStyle(Points: Integer): Text
    begin
        case true of
            Points >= 1500:
                exit('Favorable');
            Points >= 1000:
                exit('StandardAccent');
            Points >= 500:
                exit('Attention');
            else
                exit('Unfavorable');
        end;
    end;

    procedure GetLabel(Points: Integer): Text[50]
    begin
        case true of
            Points >= 1500:
                exit('🟢 (' + Format(Points) + ')');
            Points >= 1000:
                exit('🔵 (' + Format(Points) + ')');
            Points >= 500:
                exit('🟡 (' + Format(Points) + ')');
            else
                exit('🔴 (' + Format(Points) + ')');
        end;
    end;

    procedure GetRank(Points: Integer): Text[50]
    begin
        case true of
            Points >= 1500:
                exit('Ciudadano Ejemplar');
            Points >= 1000:
                exit('Ciudadano Normal');
            Points >= 500:
                exit('Bajo Supervision');
            else
                exit('Lista Negra');
        end;
    end;

    procedure GetCustomerLabel(CustomerNo: Code[20]): Text[50]
    var
        Customer: Record Customer;
    begin
        if Customer.Get(CustomerNo) then
            exit(GetLabel(Customer."Social Credit Points"));
        exit('');
    end;

    procedure InitializeCustomers()
    var
        Customer: Record Customer;
    begin
        if Customer.FindSet(true) then
            repeat
                if Customer."Social Credit Points" = 0 then
                    Customer."Social Credit Points" := 1000;
                Customer."Social Credit Label" := GetLabel(Customer."Social Credit Points");
                Customer.Modify();
            until Customer.Next() = 0;
    end;

    procedure GetCustomerStyle(CustomerNo: Code[20]): Text
    var
        Customer: Record Customer;
    begin
        if Customer.Get(CustomerNo) then
            exit(GetStyle(Customer."Social Credit Points"));
        exit('');
    end;

    procedure LogChange(CustomerNo: Code[20]; CustomerName: Text[100]; PointsBefore: Integer; PointsAfter: Integer)
    var
        LogEntry: Record "Social Credit Log Entry";
    begin
        LogEntry.Init();
        LogEntry."Customer No." := CustomerNo;
        LogEntry."Customer Name" := CopyStr(CustomerName, 1, 100);
        LogEntry."Points Before" := PointsBefore;
        LogEntry."Points After" := PointsAfter;
        LogEntry."Change" := PointsAfter - PointsBefore;
        LogEntry."Log DateTime" := CurrentDateTime();
        LogEntry."User ID" := CopyStr(UserId(), 1, 50);
        LogEntry.Insert(true);
    end;
}
