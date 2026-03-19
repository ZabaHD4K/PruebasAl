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
        if CustomerNo = '' then
            exit('');
        if not Customer.Get(CustomerNo) then
            exit('');
        exit(GetLabel(Customer."Social Credit Points"));
    end;

    procedure InitializeCustomers()
    var
        Customer: Record Customer;
        Errors: Integer;
    begin
        if not Customer.FindSet(true) then
            exit;
        repeat
            if not TryInitializeCustomer(Customer) then
                Errors += 1;
        until Customer.Next() = 0;

        if Errors > 0 then
            Message('Social Credit inicializado con %1 error(es). Revisa los clientes manualmente si es necesario.', Errors);
    end;

    [TryFunction]
    local procedure TryInitializeCustomer(var Customer: Record Customer)
    begin
        if Customer."Social Credit Points" = 0 then
            Customer."Social Credit Points" := 1000;
        Customer."Social Credit Label" := GetLabel(Customer."Social Credit Points");
        Customer.Modify();
    end;

    procedure GetCustomerStyle(CustomerNo: Code[20]): Text
    var
        Customer: Record Customer;
    begin
        if CustomerNo = '' then
            exit('');
        if not Customer.Get(CustomerNo) then
            exit('');
        exit(GetStyle(Customer."Social Credit Points"));
    end;

    procedure LogChange(CustomerNo: Code[20]; CustomerName: Text[100]; PointsBefore: Integer; PointsAfter: Integer; Reason: Text[250])
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
        LogEntry."Reason" := Reason;
        if not TryInsertLog(LogEntry) then;
        // Si el log falla, se ignora silenciosamente para no interrumpir el flujo principal
    end;

    [TryFunction]
    local procedure TryInsertLog(var LogEntry: Record "Social Credit Log Entry")
    begin
        LogEntry.Insert(true);
    end;
}
