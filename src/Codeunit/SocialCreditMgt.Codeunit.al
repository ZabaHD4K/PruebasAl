codeunit 50101 "Social Credit Mgt"
{
    /// <summary>
    /// Devuelve el valor del enum "SC Rank" para los puntos dados.
    /// Delega en el proveedor activo — por defecto "SC Default Rank Provider",
    /// sustituible por extensiones vía OnGetRankProvider.
    /// </summary>
    procedure GetSCRank(Points: Integer): Enum "SC Rank"
    begin
        exit(GetRankProvider().GetRank(Points));
    end;

    procedure GetStyle(Points: Integer): Text
    var
        Provider: Interface "ISC Rank Provider";
    begin
        Provider := GetRankProvider();
        exit(Provider.GetStyle(Provider.GetRank(Points)));
    end;

    procedure GetLabel(Points: Integer): Text[50]
    var
        Provider: Interface "ISC Rank Provider";
    begin
        Provider := GetRankProvider();
        exit(Provider.GetLabel(Provider.GetRank(Points), Points));
    end;

    /// <summary>
    /// Devuelve el nombre legible del rango.
    /// Usa Format(enum) para obtener el Caption del valor — de este modo
    /// cualquier enumextension con su propio Caption queda automáticamente soportado.
    /// </summary>
    procedure GetRank(Points: Integer): Text[50]
    begin
        exit(CopyStr(Format(GetRankProvider().GetRank(Points)), 1, 50));
    end;

    /// <summary>
    /// Punto de extensión: permite a otras extensiones sustituir el proveedor
    /// de rangos completo sin modificar este codeunit.
    ///
    /// Uso:
    ///   [EventSubscriber(ObjectType::Codeunit, Codeunit::"Social Credit Mgt",
    ///                    'OnGetRankProvider', '', false, false)]
    ///   local procedure MyProviderSubscriber(
    ///       var Provider: Interface "ISC Rank Provider"; var IsHandled: Boolean)
    ///   var
    ///       MyProvider: Codeunit "My Rank Provider";
    ///   begin
    ///       Provider := MyProvider;
    ///       IsHandled := true;
    ///   end;
    /// </summary>
    [IntegrationEvent(false, false)]
    procedure OnGetRankProvider(var Provider: Interface "ISC Rank Provider"; var IsHandled: Boolean)
    begin
    end;

    local procedure GetRankProvider(): Interface "ISC Rank Provider"
    var
        DefaultProvider: Codeunit "SC Default Rank Provider";
        Provider: Interface "ISC Rank Provider";
        IsHandled: Boolean;
    begin
        Provider := DefaultProvider;
        OnGetRankProvider(Provider, IsHandled);
        exit(Provider);
    end;

    procedure GetCustomerLabel(CustomerNo: Code[20]): Text[50]
    var
        Customer: Record Customer;
    begin
        if CustomerNo = '' then
            exit('');
        Customer.SetLoadFields("Social Credit Points");
        if not Customer.Get(CustomerNo) then
            exit('');
        exit(GetLabel(Customer."Social Credit Points"));
    end;

    procedure InitializeCustomers()
    var
        Customer: Record Customer;
    begin
        Customer.SetLoadFields("No.", "Social Credit Points", "Social Credit Label");
        if not Customer.FindSet(true) then
            exit;
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
        if CustomerNo = '' then
            exit('');
        Customer.SetLoadFields("Social Credit Points");
        if not Customer.Get(CustomerNo) then
            exit('');
        exit(GetStyle(Customer."Social Credit Points"));
    end;

    procedure AdjustCustomerPoints(CustomerNo: Code[20]; Delta: Integer; Reason: Text[250])
    var
        Customer: Record Customer;
        PointsBefore: Integer;
    begin
        Customer.SetLoadFields("No.", Name, "Social Credit Points", "Social Credit Label");
        Customer.Get(CustomerNo);
        PointsBefore := Customer."Social Credit Points";
        if PointsBefore + Delta < 0 then
            Customer."Social Credit Points" := 0
        else
            Customer."Social Credit Points" := PointsBefore + Delta;
        Customer."Social Credit Label" := GetLabel(Customer."Social Credit Points");
        Customer.Modify(true);
        LogChange(CustomerNo, CopyStr(Customer.Name, 1, 100), PointsBefore, Customer."Social Credit Points", Reason);
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
        LogEntry.Insert(true);
    end;
}
