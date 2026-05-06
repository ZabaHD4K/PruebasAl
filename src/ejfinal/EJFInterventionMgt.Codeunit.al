codeunit 50117 "EJF Intervention Mgt"
{
    procedure InsertSuggestedLine(var Header: Record "EJF Intervention Header")
    var
        Line: Record "EJF Intervention Line";
        Customer: Record Customer;
        LastLineNo: Integer;
        Desc: Text[100];
    begin
        Header.TestField("No.");
        Header.TestField("Customer No.");
        if Header.Status <> "EJF Intervention Status"::Open then
            Error('Solo se pueden insertar líneas en documentos en estado Abierto.');

        Customer.Get(Header."Customer No.");

        Line.SetRange("Document No.", Header."No.");
        if Line.FindLast() then
            LastLineNo := Line."Line No."
        else
            LastLineNo := 0;

        if Customer."EJF Preferred Technician" <> '' then
            Desc := Customer."EJF Preferred Technician"
        else
            Desc := 'Visita técnica';

        Line.Init();
        Line."Document No." := Header."No.";
        Line."Line No." := LastLineNo + 10000;
        Line.Validate(Description, Desc);
        Line.Validate(Quantity, 1);
        Line.Validate(Hours, Customer."EJF Max Suggested Hours");
        Line.Validate("Unit Cost", 0);
        Line.Billable := true;
        Line.Insert(true);
    end;

    procedure ReleaseIntervention(var Header: Record "EJF Intervention Header")
    var
        Line: Record "EJF Intervention Line";
    begin
        Header.TestField("No.");
        Header.TestField(Description);
        Header.TestField("Customer No.");
        Header.TestField("Requested Date");
        if Header.Status <> "EJF Intervention Status"::Open then
            Error('Solo se pueden lanzar documentos en estado Abierto.');

        Line.SetRange("Document No.", Header."No.");
        if Line.IsEmpty() then
            Error('El documento debe tener al menos una línea para poder lanzarse.');

        Header.Status := "EJF Intervention Status"::Released;
        Header.Modify();
    end;

    procedure ReopenIntervention(var Header: Record "EJF Intervention Header")
    begin
        if Header.Status = "EJF Intervention Status"::Posted then
            Error('Un documento registrado no puede reabrirse.');
        Header.Status := "EJF Intervention Status"::Open;
        Header.Modify();
    end;

    procedure PostIntervention(var Header: Record "EJF Intervention Header")
    var
        Customer: Record Customer;
    begin
        if Header.Status <> "EJF Intervention Status"::Released then
            Error('Solo se pueden registrar documentos en estado Lanzado.');

        Header.CalcFields("Total Amount");

        Customer.Get(Header."Customer No.");
        Customer."EJF Last Intervention Date" := Today();
        Customer."EJF Accumulated Amount" += Header."Total Amount";
        Customer.Modify();

        Header.Status := "EJF Intervention Status"::Posted;
        Header.Modify();
    end;
}
