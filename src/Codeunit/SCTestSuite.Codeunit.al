/// <summary>
/// Tests unitarios de la extensión Social Credit.
/// Cubre: SocialCreditMgt (GetStyle/GetLabel/GetRank/AdjustCustomerPoints/LogChange),
///        SC Cue FlowFields y SC Deduct Morosos.
/// </summary>
codeunit 50149 "SC Test Suite"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        SocialCreditMgt: Codeunit "Social Credit Mgt";
        TestCustomerPrefix: Label 'SCTEST', Locked = true;

    // ════════════════════════════════════════════════════════════
    //  GET STYLE — límites exactos
    // ════════════════════════════════════════════════════════════

    [Test]
    procedure GetStyle_Boundary_1500_IsFavorable()
    begin
        AssertEqual('Favorable', SocialCreditMgt.GetStyle(1500), 'Exactamente 1500 debe ser Favorable');
        AssertEqual('Favorable', SocialCreditMgt.GetStyle(2000), '2000 debe ser Favorable');
    end;

    [Test]
    procedure GetStyle_Boundary_1499_IsStandardAccent()
    begin
        AssertEqual('StandardAccent', SocialCreditMgt.GetStyle(1499), 'Exactamente 1499 debe ser StandardAccent');
        AssertEqual('StandardAccent', SocialCreditMgt.GetStyle(1000), 'Exactamente 1000 debe ser StandardAccent');
    end;

    [Test]
    procedure GetStyle_Boundary_999_IsAttention()
    begin
        AssertEqual('Attention', SocialCreditMgt.GetStyle(999), 'Exactamente 999 debe ser Attention');
        AssertEqual('Attention', SocialCreditMgt.GetStyle(500), 'Exactamente 500 debe ser Attention');
    end;

    [Test]
    procedure GetStyle_Boundary_499_IsUnfavorable()
    begin
        AssertEqual('Unfavorable', SocialCreditMgt.GetStyle(499), 'Exactamente 499 debe ser Unfavorable');
        AssertEqual('Unfavorable', SocialCreditMgt.GetStyle(0), '0 debe ser Unfavorable');
    end;

    // ════════════════════════════════════════════════════════════
    //  GET RANK
    // ════════════════════════════════════════════════════════════

    [Test]
    procedure GetRank_AllFourRanks()
    begin
        AssertEqual('Ciudadano Ejemplar', SocialCreditMgt.GetRank(1500), '>=1500 = Ciudadano Ejemplar');
        AssertEqual('Ciudadano Normal',   SocialCreditMgt.GetRank(1000), '>=1000 = Ciudadano Normal');
        AssertEqual('Bajo Supervision',   SocialCreditMgt.GetRank(500),  '>=500 = Bajo Supervision');
        AssertEqual('Lista Negra',        SocialCreditMgt.GetRank(499),  '<500 = Lista Negra');
        AssertEqual('Lista Negra',        SocialCreditMgt.GetRank(0),    '0 = Lista Negra');
    end;

    // ════════════════════════════════════════════════════════════
    //  GET LABEL
    // ════════════════════════════════════════════════════════════

    [Test]
    procedure GetLabel_ContainsPointsValue()
    begin
        AssertTrue(SocialCreditMgt.GetLabel(1234).Contains('1234'), 'Label debe incluir el valor numérico');
        AssertTrue(SocialCreditMgt.GetLabel(0).Contains('0'), 'Label de 0 puntos debe incluir el cero');
    end;

    [Test]
    procedure GetLabel_CorrectEmojiPerRank()
    begin
        AssertTrue(SocialCreditMgt.GetLabel(1500).Contains('🟢'), '>=1500 debe tener emoji verde');
        AssertTrue(SocialCreditMgt.GetLabel(1000).Contains('🔵'), '>=1000 debe tener emoji azul');
        AssertTrue(SocialCreditMgt.GetLabel(500).Contains('🟡'),  '>=500 debe tener emoji amarillo');
        AssertTrue(SocialCreditMgt.GetLabel(0).Contains('🔴'),    '0 debe tener emoji rojo');
    end;

    // ════════════════════════════════════════════════════════════
    //  GET CUSTOMER LABEL / STYLE — casos borde
    // ════════════════════════════════════════════════════════════

    [Test]
    procedure GetCustomerLabel_EmptyNo_ReturnsEmpty()
    begin
        AssertEqual('', SocialCreditMgt.GetCustomerLabel(''), 'CustomerNo vacío debe devolver cadena vacía');
    end;

    [Test]
    procedure GetCustomerLabel_NonexistentNo_ReturnsEmpty()
    begin
        AssertEqual('', SocialCreditMgt.GetCustomerLabel('NO-EXISTE-999'), 'Cliente inexistente debe devolver cadena vacía');
    end;

    [Test]
    procedure GetCustomerStyle_EmptyNo_ReturnsEmpty()
    begin
        AssertEqual('', SocialCreditMgt.GetCustomerStyle(''), 'CustomerNo vacío debe devolver cadena vacía');
    end;

    // ════════════════════════════════════════════════════════════
    //  ADJUST CUSTOMER POINTS — lógica de negocio
    // ════════════════════════════════════════════════════════════

    [Test]
    procedure AdjustPoints_PositiveDelta_IncreasesPoints()
    var
        Customer: Record Customer;
    begin
        CreateTestCustomer(Customer, 1000);
        SocialCreditMgt.AdjustCustomerPoints(Customer."No.", 300, 'Test subida');
        Customer.Get(Customer."No.");
        AssertEqual(1300, Customer."Social Credit Points", 'Los puntos deben aumentar en 300');
        CleanupTestCustomer(Customer);
    end;

    [Test]
    procedure AdjustPoints_NegativeDelta_DecreasesPoints()
    var
        Customer: Record Customer;
    begin
        CreateTestCustomer(Customer, 1000);
        SocialCreditMgt.AdjustCustomerPoints(Customer."No.", -400, 'Test bajada');
        Customer.Get(Customer."No.");
        AssertEqual(600, Customer."Social Credit Points", 'Los puntos deben bajar en 400');
        CleanupTestCustomer(Customer);
    end;

    [Test]
    procedure AdjustPoints_WouldGoNegative_ClampsToZero()
    var
        Customer: Record Customer;
    begin
        CreateTestCustomer(Customer, 100);
        SocialCreditMgt.AdjustCustomerPoints(Customer."No.", -999, 'Delta mayor que los puntos actuales');
        Customer.Get(Customer."No.");
        AssertEqual(0, Customer."Social Credit Points", 'Los puntos nunca pueden ser negativos: deben quedar en 0');
        CleanupTestCustomer(Customer);
    end;

    [Test]
    procedure AdjustPoints_ZeroDelta_PointsUnchanged()
    var
        Customer: Record Customer;
    begin
        CreateTestCustomer(Customer, 1000);
        SocialCreditMgt.AdjustCustomerPoints(Customer."No.", 0, 'Delta cero');
        Customer.Get(Customer."No.");
        AssertEqual(1000, Customer."Social Credit Points", 'Con delta 0 los puntos no deben cambiar');
        CleanupTestCustomer(Customer);
    end;

    [Test]
    procedure AdjustPoints_UpdatesLabelAndEmoji()
    var
        Customer: Record Customer;
    begin
        // Empieza en Normal (🔵), sube a Ejemplar (🟢)
        CreateTestCustomer(Customer, 1000);
        SocialCreditMgt.AdjustCustomerPoints(Customer."No.", 600, 'Subida a Ejemplar');
        Customer.Get(Customer."No.");
        AssertEqual(1600, Customer."Social Credit Points", 'Puntos deben ser 1600');
        AssertTrue(Customer."Social Credit Label".Contains('🟢'), 'El label debe actualizarse al emoji verde (Ejemplar)');
        CleanupTestCustomer(Customer);
    end;

    [Test]
    procedure AdjustPoints_CreatesLogEntry()
    var
        Customer: Record Customer;
        LogEntry: Record "Social Credit Log Entry";
    begin
        CreateTestCustomer(Customer, 1000);
        SocialCreditMgt.AdjustCustomerPoints(Customer."No.", 200, 'Test log');

        LogEntry.SetRange("Customer No.", Customer."No.");
        AssertTrue(LogEntry.FindLast(), 'Debe crearse al menos una entrada en el log');
        AssertEqual(1000, LogEntry."Points Before", 'Puntos antes incorrectos en el log');
        AssertEqual(1200, LogEntry."Points After",  'Puntos después incorrectos en el log');
        AssertEqual(200,  LogEntry."Change",         'Cambio incorrecto en el log');
        AssertEqual('Test log', LogEntry."Reason",   'El motivo debe guardarse en el log');

        CleanupTestCustomer(Customer);
    end;

    // ════════════════════════════════════════════════════════════
    //  LOG CHANGE — campos del registro
    // ════════════════════════════════════════════════════════════

    [Test]
    procedure LogChange_AllFieldsSavedCorrectly()
    var
        LogEntry: Record "Social Credit Log Entry";
    begin
        SocialCreditMgt.LogChange('SCTEST-LOG', 'Cliente de prueba', 800, 950, 'Motivo de prueba');

        LogEntry.SetRange("Customer No.", 'SCTEST-LOG');
        AssertTrue(LogEntry.FindLast(), 'Debe existir la entrada de log');
        AssertEqual('SCTEST-LOG',      LogEntry."Customer No.",   'Customer No. incorrecto');
        AssertEqual('Cliente de prueba', LogEntry."Customer Name", 'Customer Name incorrecto');
        AssertEqual(800,               LogEntry."Points Before",  'Points Before incorrecto');
        AssertEqual(950,               LogEntry."Points After",   'Points After incorrecto');
        AssertEqual(150,               LogEntry."Change",         'Change debe ser After - Before');
        AssertEqual('Motivo de prueba', LogEntry."Reason",        'Reason incorrecto');
        AssertNotEqual(0DT,            LogEntry."Log DateTime",   'Log DateTime debe estar relleno');
        AssertNotEqual('',             LogEntry."User ID",        'User ID debe estar relleno');

        LogEntry.SetRange("Customer No.", 'SCTEST-LOG');
        LogEntry.DeleteAll();
    end;

    [Test]
    procedure LogChange_NegativeChange_SavedCorrectly()
    var
        LogEntry: Record "Social Credit Log Entry";
    begin
        SocialCreditMgt.LogChange('SCTEST-LOG', 'Test', 1000, 700, 'Bajada');

        LogEntry.SetRange("Customer No.", 'SCTEST-LOG');
        LogEntry.FindLast();
        AssertEqual(-300, LogEntry."Change", 'Change negativo debe guardarse correctamente');

        LogEntry.SetRange("Customer No.", 'SCTEST-LOG');
        LogEntry.DeleteAll();
    end;

    // ════════════════════════════════════════════════════════════
    //  SC CUE — FlowFields
    // ════════════════════════════════════════════════════════════

    [Test]
    procedure SCCue_FlowFields_MatchManualCount()
    var
        SCCue: Record "SC Cue";
        Customer: Record Customer;
        ManualEjemplar: Integer;
        ManualNormal: Integer;
        ManualSup: Integer;
        ManualNegra: Integer;
    begin
        if Customer.FindSet() then
            repeat
                case true of
                    Customer."Social Credit Points" >= 1500: ManualEjemplar += 1;
                    Customer."Social Credit Points" >= 1000: ManualNormal += 1;
                    Customer."Social Credit Points" >= 500:  ManualSup += 1;
                    else                                     ManualNegra += 1;
                end;
            until Customer.Next() = 0;

        if not SCCue.Get('') then begin
            SCCue.Init();
            SCCue."Primary Key" := '';
            SCCue.Insert(true);
        end;
        SCCue.CalcFields("Clientes Ejemplar", "Clientes Normal", "Clientes Supervision", "Clientes Lista Negra");

        AssertEqual(ManualEjemplar, SCCue."Clientes Ejemplar",    'FlowField Ejemplar no coincide');
        AssertEqual(ManualNormal,   SCCue."Clientes Normal",      'FlowField Normal no coincide');
        AssertEqual(ManualSup,      SCCue."Clientes Supervision", 'FlowField Supervision no coincide');
        AssertEqual(ManualNegra,    SCCue."Clientes Lista Negra", 'FlowField Lista Negra no coincide');
    end;

    [Test]
    procedure SCCue_AfterAdjust_FlowFieldUpdates()
    var
        SCCue: Record "SC Cue";
        Customer: Record Customer;
        NegraAntes: Integer;
        NegraDespues: Integer;
    begin
        CreateTestCustomer(Customer, 0);   // empieza en Lista Negra

        if not SCCue.Get('') then begin
            SCCue.Init(); SCCue."Primary Key" := ''; SCCue.Insert(true);
        end;
        SCCue.CalcFields("Clientes Lista Negra");
        NegraAntes := SCCue."Clientes Lista Negra";

        SocialCreditMgt.AdjustCustomerPoints(Customer."No.", 600, 'Test cue');  // sale de Lista Negra

        SCCue.CalcFields("Clientes Lista Negra");
        NegraDespues := SCCue."Clientes Lista Negra";

        AssertEqual(NegraAntes - 1, NegraDespues, 'Lista Negra debe decrementar al subir puntos');
        CleanupTestCustomer(Customer);
    end;

    // ════════════════════════════════════════════════════════════
    //  SC DEDUCT MOROSOS
    // ════════════════════════════════════════════════════════════

    [Test]
    procedure DeductMorosos_CustomerWithOverdueInvoice_DeductsPoints()
    var
        Customer: Record Customer;
        CustLedgerEntry: Record "Cust. Ledger Entry";
        JobQueueEntry: Record "Job Queue Entry";
        SCDeductMorosos: Codeunit "SC Deduct Morosos";
    begin
        CreateTestCustomer(Customer, 1000);
        CreateOverdueLedgerEntry(Customer."No.", CustLedgerEntry);

        SCDeductMorosos.Run(JobQueueEntry);

        Customer.Get(Customer."No.");
        AssertEqual(950, Customer."Social Credit Points", 'Cliente moroso debe perder 50 puntos');

        CleanupLedgerEntry(CustLedgerEntry);
        CleanupTestCustomer(Customer);
    end;

    [Test]
    procedure DeductMorosos_CustomerWithoutOverdueInvoice_KeepsPoints()
    var
        Customer: Record Customer;
        JobQueueEntry: Record "Job Queue Entry";
        SCDeductMorosos: Codeunit "SC Deduct Morosos";
    begin
        CreateTestCustomer(Customer, 1000);

        SCDeductMorosos.Run(JobQueueEntry);

        Customer.Get(Customer."No.");
        AssertEqual(1000, Customer."Social Credit Points", 'Sin facturas vencidas no se deben descontar puntos');
        CleanupTestCustomer(Customer);
    end;

    [Test]
    procedure DeductMorosos_PointsAtZero_StaysAtZero()
    var
        Customer: Record Customer;
        CustLedgerEntry: Record "Cust. Ledger Entry";
        JobQueueEntry: Record "Job Queue Entry";
        SCDeductMorosos: Codeunit "SC Deduct Morosos";
    begin
        CreateTestCustomer(Customer, 0);
        CreateOverdueLedgerEntry(Customer."No.", CustLedgerEntry);

        SCDeductMorosos.Run(JobQueueEntry);

        Customer.Get(Customer."No.");
        AssertEqual(0, Customer."Social Credit Points", 'Los puntos no pueden bajar de 0');
        CleanupLedgerEntry(CustLedgerEntry);
        CleanupTestCustomer(Customer);
    end;

    // ════════════════════════════════════════════════════════════
    //  ASSERT HELPERS — sin dependencia de librería externa
    // ════════════════════════════════════════════════════════════

    local procedure AssertEqual(Expected: Variant; Actual: Variant; Msg: Text)
    begin
        if Format(Expected) <> Format(Actual) then
            Error('FAIL: %1\Expected: [%2]\Actual:   [%3]', Msg, Expected, Actual);
    end;

    local procedure AssertTrue(Condition: Boolean; Msg: Text)
    begin
        if not Condition then
            Error('FAIL (expected TRUE): %1', Msg);
    end;

    local procedure AssertNotEqual(NotExpected: Variant; Actual: Variant; Msg: Text)
    begin
        if Format(NotExpected) = Format(Actual) then
            Error('FAIL (expected values to differ): %1\Both are: [%2]', Msg, Actual);
    end;

    // ════════════════════════════════════════════════════════════
    //  DATA HELPERS
    // ════════════════════════════════════════════════════════════

    local procedure CreateTestCustomer(var Customer: Record Customer; InitialPoints: Integer)
    var
        No: Code[20];
    begin
        No := CopyStr(TestCustomerPrefix + Format(Time(), 0, '<Hours24><Minutes><Seconds2>'), 1, 20);
        if Customer.Get(No) then
            CleanupTestCustomer(Customer);

        Customer.Init();
        Customer."No." := No;
        Customer.Name := 'Test SC Customer';
        Customer."Social Credit Points" := InitialPoints;
        Customer."Social Credit Label" := SocialCreditMgt.GetLabel(InitialPoints);
        Customer.Insert(true);
    end;

    local procedure CleanupTestCustomer(var Customer: Record Customer)
    var
        LogEntry: Record "Social Credit Log Entry";
    begin
        LogEntry.SetRange("Customer No.", Customer."No.");
        LogEntry.DeleteAll();
        if Customer.Delete(true) then;
    end;

    local procedure CreateOverdueLedgerEntry(CustomerNo: Code[20]; var CustLedgerEntry: Record "Cust. Ledger Entry")
    var
        EntryNo: Integer;
    begin
        CustLedgerEntry.SetLoadFields("Entry No.");
        if CustLedgerEntry.FindLast() then
            EntryNo := CustLedgerEntry."Entry No." + 1
        else
            EntryNo := 1;

        CustLedgerEntry.Init();
        CustLedgerEntry."Entry No."     := EntryNo;
        CustLedgerEntry."Customer No."  := CustomerNo;
        CustLedgerEntry."Document Type" := CustLedgerEntry."Document Type"::Invoice;
        CustLedgerEntry.Open            := true;
        CustLedgerEntry."Due Date"      := CalcDate('<-1D>', Today());
        CustLedgerEntry.Insert(true);
    end;

    local procedure CleanupLedgerEntry(var CustLedgerEntry: Record "Cust. Ledger Entry")
    begin
        if CustLedgerEntry.Delete(true) then;
    end;
}
