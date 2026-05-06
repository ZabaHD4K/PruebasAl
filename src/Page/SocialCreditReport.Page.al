page 50105 "Social Credit Report"
{
    PageType = Card;
    Caption = 'Clientes — Social Credit';
    ApplicationArea = All;
    UsageCategory = Lists;

    layout
    {
        area(Content)
        {
            usercontrol(CustAddin; "SC Customer List Addin")
            {
                ApplicationArea = All;

                trigger OnReady()
                begin
                    LoadCustomers();
                end;

                trigger OnOpenCustomer(CustomerNo: Text)
                var
                    Customer: Record Customer;
                begin
                    if Customer.Get(CustomerNo) then
                        Page.Run(21, Customer);
                end;
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(PrintPdf)
            {
                ApplicationArea = All;
                Caption = 'Imprimir / PDF';
                Image = Print;
                ToolTip = 'Genera el informe en formato PDF.';
                trigger OnAction()
                var
                    SCReport: Report "SC Informe Social Credit";
                begin
                    SCReport.Run();
                end;
            }
            action(ExportExcel)
            {
                ApplicationArea = All;
                Caption = 'Exportar Excel';
                Image = ExportToExcel;
                trigger OnAction()
                begin
                    ExportToExcel();
                end;
            }
            action(ExportCsv)
            {
                ApplicationArea = All;
                Caption = 'Exportar CSV';
                Image = Export;
                trigger OnAction()
                begin
                    ExportToCsv();
                end;
            }
        }
        area(Promoted)
        {
            actionref(PrintPdf_Ref; PrintPdf) { }
            actionref(ExportExcel_Ref; ExportExcel) { }
            actionref(ExportCsv_Ref; ExportCsv) { }
        }
    }

    local procedure LoadCustomers()
    var
        Customer: Record Customer;
        JArray: JsonArray;
        JObj: JsonObject;
        Json: Text;
    begin
        CurrPage.CustAddin.SetStatus('⏳ Cargando clientes...');
        if Customer.FindSet() then
            repeat
                Clear(JObj);
                JObj.Add('no', Customer."No.");
                JObj.Add('name', Customer.Name);
                JObj.Add('points', Customer."Social Credit Points");
                JArray.Add(JObj);
            until Customer.Next() = 0;
        JArray.WriteTo(Json);
        CurrPage.CustAddin.LoadCustomers(Json);
        CurrPage.Update(false);
    end;

    local procedure ExportToExcel()
    var
        Customer: Record Customer;
        ExcelBuf: Record "Excel Buffer" temporary;
    begin
        ExcelBuf.DeleteAll();
        ExcelBuf.NewRow();
        ExcelBuf.AddColumn('No. Cliente', false, '', true, false, false, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddColumn('Nombre',      false, '', true, false, false, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddColumn('Puntos',      false, '', true, false, false, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddColumn('Estado',      false, '', true, false, false, '', ExcelBuf."Cell Type"::Text);
        Customer.SetLoadFields("No.", Name, "Social Credit Points", "Social Credit Label");
        Customer.SetCurrentKey("Social Credit Points");
        Customer.Ascending(false);
        if Customer.FindSet() then
            repeat
                ExcelBuf.NewRow();
                ExcelBuf.AddColumn(Customer."No.",                   false, '', false, false, false, '', ExcelBuf."Cell Type"::Text);
                ExcelBuf.AddColumn(Customer.Name,                    false, '', false, false, false, '', ExcelBuf."Cell Type"::Text);
                ExcelBuf.AddColumn(Customer."Social Credit Points",  false, '', false, false, false, '', ExcelBuf."Cell Type"::Number);
                ExcelBuf.AddColumn(Customer."Social Credit Label",   false, '', false, false, false, '', ExcelBuf."Cell Type"::Text);
            until Customer.Next() = 0;
        ExcelBuf.CreateNewBook('Social Credit');
        ExcelBuf.WriteAllToCurrentSheet(ExcelBuf);
        ExcelBuf.CloseBook();
        ExcelBuf.SetFriendlyFilename('Social_Credit_Report');
        ExcelBuf.OpenExcel();
    end;

    local procedure ExportToCsv()
    var
        Customer: Record Customer;
        TempBlob: Codeunit "Temp Blob";
        OutStr: OutStream;
        InStr: InStream;
        FileName: Text;
        CrLf: Text[2];
        Cr: Char;
        Lf: Char;
    begin
        Cr := 13;
        Lf := 10;
        CrLf := '' + Cr + Lf;
        TempBlob.CreateOutStream(OutStr, TextEncoding::UTF8);
        OutStr.WriteText('"No. Cliente";"Nombre";"Puntos";"Estado"' + CrLf);
        Customer.SetLoadFields("No.", Name, "Social Credit Points", "Social Credit Label");
        Customer.SetCurrentKey("Social Credit Points");
        Customer.Ascending(false);
        if Customer.FindSet() then
            repeat
                OutStr.WriteText(
                    '"' + Customer."No." + '";' +
                    '"' + Customer.Name.Replace('"', '""') + '";' +
                    '"' + Format(Customer."Social Credit Points") + '";' +
                    '"' + Customer."Social Credit Label" + '"' + CrLf);
            until Customer.Next() = 0;
        FileName := 'Social_Credit_Report.csv';
        TempBlob.CreateInStream(InStr);
        DownloadFromStream(InStr, 'Exportar CSV', '', 'Ficheros CSV (*.csv)|*.csv', FileName);
    end;
}
