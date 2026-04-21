page 50105 "Social Credit Report"
{
    PageType = List;
    Caption = 'Social Credit Report';
    ApplicationArea = All;
    SourceTable = "SC Report Line";
    SourceTableTemporary = true;
    Editable = false;
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(Lines)
            {
                field("Customer No."; Rec."Customer No.")
                {
                    ApplicationArea = All;
                    Caption = 'Nº Cliente';
                    StyleExpr = Rec."SC Style";
                }
                field("Customer Name"; Rec."Customer Name")
                {
                    ApplicationArea = All;
                    Caption = 'Nombre';
                    StyleExpr = Rec."SC Style";
                }
                field("Social Credit Points"; Rec."Social Credit Points")
                {
                    ApplicationArea = All;
                    Caption = 'Puntos';
                    StyleExpr = Rec."SC Style";
                }
                field("Social Credit Label"; Rec."Social Credit Label")
                {
                    ApplicationArea = All;
                    Caption = 'Social Credit';
                    StyleExpr = Rec."SC Style";
                }
                field("SC Rank"; Rec."SC Rank")
                {
                    ApplicationArea = All;
                    Caption = 'Rango';
                    StyleExpr = Rec."SC Style";
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(SortDesc)
            {
                ApplicationArea = All;
                Caption = '↓ Mayor a menor';
                Image = MoveDown;
                ToolTip = 'Ordena de mayor a menor puntuación de Social Credit.';
                trigger OnAction()
                begin
                    LoadData(false);
                end;
            }
            action(SortAsc)
            {
                ApplicationArea = All;
                Caption = '↑ Menor a mayor';
                Image = MoveUp;
                ToolTip = 'Ordena de menor a mayor puntuación de Social Credit.';
                trigger OnAction()
                begin
                    LoadData(true);
                end;
            }
            action(PrintPdf)
            {
                ApplicationArea = All;
                Caption = 'Imprimir / PDF';
                Image = Print;
                ToolTip = 'Genera el informe con gráficas en formato PDF listo para imprimir.';
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
                ToolTip = 'Exporta el listado de Social Credit a un fichero Excel (.xlsx).';
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
                ToolTip = 'Exporta el listado de Social Credit a un fichero CSV separado por punto y coma.';
                trigger OnAction()
                begin
                    ExportToCsv();
                end;
            }
        }

        area(Promoted)
        {
            actionref(SortDesc_Ref; SortDesc) { }
            actionref(SortAsc_Ref; SortAsc) { }
            actionref(PrintPdf_Ref; PrintPdf) { }
            actionref(ExportExcel_Ref; ExportExcel) { }
            actionref(ExportCsv_Ref; ExportCsv) { }
        }
    }

    trigger OnOpenPage()
    begin
        LoadData(false);
    end;

    local procedure LoadData(Ascending: Boolean)
    var
        Customer: Record Customer;
        SocialCreditMgt: Codeunit "Social Credit Mgt";
        LineNo: Integer;
    begin
        Rec.Reset();
        Rec.DeleteAll();

        LineNo := 1;
        Customer.SetLoadFields("No.", Name, "Social Credit Points", "Social Credit Label");
        Customer.SetCurrentKey("Social Credit Points");
        Customer.Ascending(Ascending);
        if Customer.FindSet() then
            repeat
                Rec.Init();
                Rec."Line No." := LineNo;
                Rec."Customer No." := Customer."No.";
                Rec."Customer Name" := CopyStr(Customer.Name, 1, 100);
                Rec."Social Credit Points" := Customer."Social Credit Points";
                Rec."Social Credit Label" := Customer."Social Credit Label";
                Rec."SC Rank" := SocialCreditMgt.GetRank(Customer."Social Credit Points");
                Rec."SC Style" := CopyStr(SocialCreditMgt.GetStyle(Customer."Social Credit Points"), 1, 30);
                Rec.Insert();
                LineNo += 1;
            until Customer.Next() = 0;

        if Rec.FindFirst() then;
        CurrPage.Update(false);
    end;

    local procedure ExportToExcel()
    var
        Customer: Record Customer;
        SocialCreditMgt: Codeunit "Social Credit Mgt";
        ExcelBuf: Record "Excel Buffer" temporary;
    begin
        ExcelBuf.DeleteAll();

        ExcelBuf.NewRow();
        ExcelBuf.AddColumn('No. Cliente', false, '', true, false, false, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddColumn('Nombre', false, '', true, false, false, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddColumn('Puntos', false, '', true, false, false, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddColumn('Rango', false, '', true, false, false, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddColumn('Estado', false, '', true, false, false, '', ExcelBuf."Cell Type"::Text);

        Customer.SetLoadFields("No.", Name, "Social Credit Points", "Social Credit Label");
        Customer.SetCurrentKey("Social Credit Points");
        Customer.Ascending(false);
        if Customer.FindSet() then
            repeat
                ExcelBuf.NewRow();
                ExcelBuf.AddColumn(Customer."No.", false, '', false, false, false, '', ExcelBuf."Cell Type"::Text);
                ExcelBuf.AddColumn(Customer.Name, false, '', false, false, false, '', ExcelBuf."Cell Type"::Text);
                ExcelBuf.AddColumn(Customer."Social Credit Points", false, '', false, false, false, '', ExcelBuf."Cell Type"::Number);
                ExcelBuf.AddColumn(SocialCreditMgt.GetRank(Customer."Social Credit Points"), false, '', false, false, false, '', ExcelBuf."Cell Type"::Text);
                ExcelBuf.AddColumn(Customer."Social Credit Label", false, '', false, false, false, '', ExcelBuf."Cell Type"::Text);
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
        SocialCreditMgt: Codeunit "Social Credit Mgt";
        TempBlob: Codeunit "Temp Blob";
        OutStr: OutStream;
        InStr: InStream;
        FileName: Text;
        CrLf: Text[2];
        Cr: Char;
        Lf: Char;
        Line: Text;
    begin
        Cr := 13;
        Lf := 10;
        CrLf := '' + Cr + Lf;

        TempBlob.CreateOutStream(OutStr, TextEncoding::UTF8);

        // Header
        OutStr.WriteText('"No. Cliente";"Nombre";"Puntos";"Rango";"Estado"' + CrLf);

        Customer.SetLoadFields("No.", Name, "Social Credit Points", "Social Credit Label");
        Customer.SetCurrentKey("Social Credit Points");
        Customer.Ascending(false);
        if Customer.FindSet() then
            repeat
                Line :=
                    '"' + Customer."No." + '";' +
                    '"' + Customer.Name.Replace('"', '""') + '";' +
                    '"' + Format(Customer."Social Credit Points") + '";' +
                    '"' + SocialCreditMgt.GetRank(Customer."Social Credit Points") + '";' +
                    '"' + Customer."Social Credit Label" + '"';
                OutStr.WriteText(Line + CrLf);
            until Customer.Next() = 0;

        FileName := 'Social_Credit_Report.csv';
        TempBlob.CreateInStream(InStr);
        DownloadFromStream(InStr, 'Exportar CSV', '', 'Ficheros CSV (*.csv)|*.csv', FileName);
    end;
}
