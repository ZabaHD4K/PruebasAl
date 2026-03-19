codeunit 50110 "SC Export Mgt"
{
    // ══════════════════════════════════════════
    //  CLIENTES
    // ══════════════════════════════════════════

    procedure ExportCustomersAsCSV()
    var
        Customer: Record Customer;
        Content: TextBuilder;
    begin
        Content.AppendLine('No.,Nombre,Ciudad,Telefono,Email,Social Credit,Estado,Rango');
        if Customer.FindSet() then
            repeat
                Content.AppendLine(StrSubstNo('%1,%2,%3,%4,%5,%6,%7,%8',
                    EscapeCSV(Customer."No."),
                    EscapeCSV(Customer.Name),
                    EscapeCSV(Customer.City),
                    EscapeCSV(Customer."Phone No."),
                    EscapeCSV(Customer."E-Mail"),
                    Format(Customer."Social Credit Points"),
                    EscapeCSV(Customer."Social Credit Label"),
                    EscapeCSV(SocialCreditMgt.GetRank(Customer."Social Credit Points"))));
            until Customer.Next() = 0;
        DownloadText(Content.ToText(), 'clientes.csv');
    end;

    procedure ExportCustomersAsXML()
    var
        Customer: Record Customer;
        XmlDoc: XmlDocument;
        Root: XmlElement;
        TempBlob: Codeunit "Temp Blob";
        OutStr: OutStream;
        InStr: InStream;
        FileName: Text;
    begin
        XmlDoc := XmlDocument.Create();
        Root := XmlElement.Create('Customers');
        if Customer.FindSet() then
            repeat
                Root.Add(BuildCustomerXmlElement(Customer));
            until Customer.Next() = 0;
        XmlDoc.Add(Root);
        TempBlob.CreateOutStream(OutStr);
        XmlDoc.WriteTo(OutStr);
        TempBlob.CreateInStream(InStr);
        FileName := 'clientes.xml';
        DownloadFromStream(InStr, '', '', 'XML Files (*.xml)|*.xml', FileName);
    end;

    procedure ExportCustomersAsJSON()
    var
        Customer: Record Customer;
        JsonArr: JsonArray;
        JsonObj: JsonObject;
        JsonTxt: Text;
    begin
        if Customer.FindSet() then
            repeat
                Clear(JsonObj);
                JsonObj.Add('no', Customer."No.");
                JsonObj.Add('name', Customer.Name);
                JsonObj.Add('city', Customer.City);
                JsonObj.Add('phone', Customer."Phone No.");
                JsonObj.Add('email', Customer."E-Mail");
                JsonObj.Add('socialCreditPoints', Customer."Social Credit Points");
                JsonObj.Add('socialCreditLabel', Customer."Social Credit Label");
                JsonObj.Add('rank', SocialCreditMgt.GetRank(Customer."Social Credit Points"));
                JsonArr.Add(JsonObj);
            until Customer.Next() = 0;
        JsonArr.WriteTo(JsonTxt);
        DownloadText(JsonTxt, 'clientes.json');
    end;

    procedure ExportCustomersAsExcel()
    var
        Customer: Record Customer;
        ExcelBuffer: Record "Excel Buffer" temporary;
    begin
        ExcelBuffer.DeleteAll();
        ExcelBuffer.NewRow();
        AddExcelHeader(ExcelBuffer, 'No.');
        AddExcelHeader(ExcelBuffer, 'Nombre');
        AddExcelHeader(ExcelBuffer, 'Ciudad');
        AddExcelHeader(ExcelBuffer, 'Telefono');
        AddExcelHeader(ExcelBuffer, 'Email');
        AddExcelHeader(ExcelBuffer, 'Social Credit');
        AddExcelHeader(ExcelBuffer, 'Estado');
        AddExcelHeader(ExcelBuffer, 'Rango');
        if Customer.FindSet() then
            repeat
                ExcelBuffer.NewRow();
                AddExcelCell(ExcelBuffer, Customer."No.");
                AddExcelCell(ExcelBuffer, Customer.Name);
                AddExcelCell(ExcelBuffer, Customer.City);
                AddExcelCell(ExcelBuffer, Customer."Phone No.");
                AddExcelCell(ExcelBuffer, Customer."E-Mail");
                ExcelBuffer.AddColumn(Customer."Social Credit Points", false, '', false, false, false, '#,##0', ExcelBuffer."Cell Type"::Number);
                AddExcelCell(ExcelBuffer, Customer."Social Credit Label");
                AddExcelCell(ExcelBuffer, SocialCreditMgt.GetRank(Customer."Social Credit Points"));
            until Customer.Next() = 0;
        ExcelBuffer.CreateNewBook('Clientes');
        ExcelBuffer.WriteSheet('Clientes', CompanyName(), UserId());
        ExcelBuffer.CloseBook();
        ExcelBuffer.OpenExcel();
    end;

    // ══════════════════════════════════════════
    //  PROVEEDORES
    // ══════════════════════════════════════════

    procedure ExportVendorsAsCSV()
    var
        Vendor: Record Vendor;
        Content: TextBuilder;
    begin
        Content.AppendLine('No.,Nombre,Ciudad,Telefono,Email,Saldo (DL),Terminos Pago');
        if Vendor.FindSet() then
            repeat
                Vendor.CalcFields("Balance (LCY)");
                Content.AppendLine(StrSubstNo('%1,%2,%3,%4,%5,%6,%7',
                    EscapeCSV(Vendor."No."),
                    EscapeCSV(Vendor.Name),
                    EscapeCSV(Vendor.City),
                    EscapeCSV(Vendor."Phone No."),
                    EscapeCSV(Vendor."E-Mail"),
                    Format(Vendor."Balance (LCY)"),
                    EscapeCSV(Vendor."Payment Terms Code")));
            until Vendor.Next() = 0;
        DownloadText(Content.ToText(), 'proveedores.csv');
    end;

    procedure ExportVendorsAsXML()
    var
        Vendor: Record Vendor;
        XmlDoc: XmlDocument;
        Root: XmlElement;
        TempBlob: Codeunit "Temp Blob";
        OutStr: OutStream;
        InStr: InStream;
        FileName: Text;
    begin
        XmlDoc := XmlDocument.Create();
        Root := XmlElement.Create('Vendors');
        if Vendor.FindSet() then
            repeat
                Vendor.CalcFields("Balance (LCY)");
                Root.Add(BuildVendorXmlElement(Vendor));
            until Vendor.Next() = 0;
        XmlDoc.Add(Root);
        TempBlob.CreateOutStream(OutStr);
        XmlDoc.WriteTo(OutStr);
        TempBlob.CreateInStream(InStr);
        FileName := 'proveedores.xml';
        DownloadFromStream(InStr, '', '', 'XML Files (*.xml)|*.xml', FileName);
    end;

    procedure ExportVendorsAsJSON()
    var
        Vendor: Record Vendor;
        JsonArr: JsonArray;
        JsonObj: JsonObject;
        JsonTxt: Text;
    begin
        if Vendor.FindSet() then
            repeat
                Vendor.CalcFields("Balance (LCY)");
                Clear(JsonObj);
                JsonObj.Add('no', Vendor."No.");
                JsonObj.Add('name', Vendor.Name);
                JsonObj.Add('city', Vendor.City);
                JsonObj.Add('phone', Vendor."Phone No.");
                JsonObj.Add('email', Vendor."E-Mail");
                JsonObj.Add('balance', Vendor."Balance (LCY)");
                JsonObj.Add('paymentTerms', Vendor."Payment Terms Code");
                JsonArr.Add(JsonObj);
            until Vendor.Next() = 0;
        JsonArr.WriteTo(JsonTxt);
        DownloadText(JsonTxt, 'proveedores.json');
    end;

    procedure ExportVendorsAsExcel()
    var
        Vendor: Record Vendor;
        ExcelBuffer: Record "Excel Buffer" temporary;
    begin
        ExcelBuffer.DeleteAll();
        ExcelBuffer.NewRow();
        AddExcelHeader(ExcelBuffer, 'No.');
        AddExcelHeader(ExcelBuffer, 'Nombre');
        AddExcelHeader(ExcelBuffer, 'Ciudad');
        AddExcelHeader(ExcelBuffer, 'Telefono');
        AddExcelHeader(ExcelBuffer, 'Email');
        AddExcelHeader(ExcelBuffer, 'Saldo (DL)');
        AddExcelHeader(ExcelBuffer, 'Terminos Pago');
        if Vendor.FindSet() then
            repeat
                Vendor.CalcFields("Balance (LCY)");
                ExcelBuffer.NewRow();
                AddExcelCell(ExcelBuffer, Vendor."No.");
                AddExcelCell(ExcelBuffer, Vendor.Name);
                AddExcelCell(ExcelBuffer, Vendor.City);
                AddExcelCell(ExcelBuffer, Vendor."Phone No.");
                AddExcelCell(ExcelBuffer, Vendor."E-Mail");
                ExcelBuffer.AddColumn(Vendor."Balance (LCY)", false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
                AddExcelCell(ExcelBuffer, Vendor."Payment Terms Code");
            until Vendor.Next() = 0;
        ExcelBuffer.CreateNewBook('Proveedores');
        ExcelBuffer.WriteSheet('Proveedores', CompanyName(), UserId());
        ExcelBuffer.CloseBook();
        ExcelBuffer.OpenExcel();
    end;

    // ══════════════════════════════════════════
    //  INVENTARIO
    // ══════════════════════════════════════════

    procedure ExportItemsAsCSV()
    var
        Item: Record Item;
        Content: TextBuilder;
    begin
        Content.AppendLine('No.,Descripcion,Stock,Precio Venta,Coste,Categoria,Unidad Medida');
        if Item.FindSet() then
            repeat
                Item.CalcFields(Inventory);
                Content.AppendLine(StrSubstNo('%1,%2,%3,%4,%5,%6,%7',
                    EscapeCSV(Item."No."),
                    EscapeCSV(Item.Description),
                    Format(Item.Inventory),
                    Format(Item."Unit Price"),
                    Format(Item."Unit Cost"),
                    EscapeCSV(Item."Item Category Code"),
                    EscapeCSV(Item."Base Unit of Measure")));
            until Item.Next() = 0;
        DownloadText(Content.ToText(), 'inventario.csv');
    end;

    procedure ExportItemsAsXML()
    var
        Item: Record Item;
        XmlDoc: XmlDocument;
        Root: XmlElement;
        TempBlob: Codeunit "Temp Blob";
        OutStr: OutStream;
        InStr: InStream;
        FileName: Text;
    begin
        XmlDoc := XmlDocument.Create();
        Root := XmlElement.Create('Items');
        if Item.FindSet() then
            repeat
                Item.CalcFields(Inventory);
                Root.Add(BuildItemXmlElement(Item));
            until Item.Next() = 0;
        XmlDoc.Add(Root);
        TempBlob.CreateOutStream(OutStr);
        XmlDoc.WriteTo(OutStr);
        TempBlob.CreateInStream(InStr);
        FileName := 'inventario.xml';
        DownloadFromStream(InStr, '', '', 'XML Files (*.xml)|*.xml', FileName);
    end;

    procedure ExportItemsAsJSON()
    var
        Item: Record Item;
        JsonArr: JsonArray;
        JsonObj: JsonObject;
        JsonTxt: Text;
    begin
        if Item.FindSet() then
            repeat
                Item.CalcFields(Inventory);
                Clear(JsonObj);
                JsonObj.Add('no', Item."No.");
                JsonObj.Add('description', Item.Description);
                JsonObj.Add('inventory', Item.Inventory);
                JsonObj.Add('unitPrice', Item."Unit Price");
                JsonObj.Add('unitCost', Item."Unit Cost");
                JsonObj.Add('category', Item."Item Category Code");
                JsonObj.Add('unitOfMeasure', Item."Base Unit of Measure");
                JsonArr.Add(JsonObj);
            until Item.Next() = 0;
        JsonArr.WriteTo(JsonTxt);
        DownloadText(JsonTxt, 'inventario.json');
    end;

    procedure ExportItemsAsExcel()
    var
        Item: Record Item;
        ExcelBuffer: Record "Excel Buffer" temporary;
    begin
        ExcelBuffer.DeleteAll();
        ExcelBuffer.NewRow();
        AddExcelHeader(ExcelBuffer, 'No.');
        AddExcelHeader(ExcelBuffer, 'Descripcion');
        AddExcelHeader(ExcelBuffer, 'Stock');
        AddExcelHeader(ExcelBuffer, 'Precio Venta');
        AddExcelHeader(ExcelBuffer, 'Coste');
        AddExcelHeader(ExcelBuffer, 'Categoria');
        AddExcelHeader(ExcelBuffer, 'Unidad Medida');
        if Item.FindSet() then
            repeat
                Item.CalcFields(Inventory);
                ExcelBuffer.NewRow();
                AddExcelCell(ExcelBuffer, Item."No.");
                AddExcelCell(ExcelBuffer, Item.Description);
                ExcelBuffer.AddColumn(Item.Inventory, false, '', false, false, false, '#,##0.##', ExcelBuffer."Cell Type"::Number);
                ExcelBuffer.AddColumn(Item."Unit Price", false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
                ExcelBuffer.AddColumn(Item."Unit Cost", false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
                AddExcelCell(ExcelBuffer, Item."Item Category Code");
                AddExcelCell(ExcelBuffer, Item."Base Unit of Measure");
            until Item.Next() = 0;
        ExcelBuffer.CreateNewBook('Inventario');
        ExcelBuffer.WriteSheet('Inventario', CompanyName(), UserId());
        ExcelBuffer.CloseBook();
        ExcelBuffer.OpenExcel();
    end;

    // ══════════════════════════════════════════
    //  HELPERS PRIVADOS
    // ══════════════════════════════════════════

    local procedure DownloadText(Content: Text; FileName: Text)
    var
        TempBlob: Codeunit "Temp Blob";
        OutStr: OutStream;
        InStr: InStream;
        FileNameOut: Text;
    begin
        TempBlob.CreateOutStream(OutStr, TextEncoding::UTF8);
        OutStr.WriteText(Content);
        TempBlob.CreateInStream(InStr);
        FileNameOut := FileName;
        DownloadFromStream(InStr, '', '', '', FileNameOut);
    end;

    local procedure EscapeCSV(Value: Text): Text
    begin
        if Value.Contains(',') or Value.Contains('"') or Value.Contains(#10) then
            exit('"' + Value.Replace('"', '""') + '"');
        exit(Value);
    end;

    local procedure XmlElem(Name: Text; Value: Text): XmlElement
    var
        Elem: XmlElement;
    begin
        Elem := XmlElement.Create(Name);
        Elem.Add(XmlText.Create(Value));
        exit(Elem);
    end;

    local procedure BuildCustomerXmlElement(Customer: Record Customer): XmlElement
    var
        Elem: XmlElement;
    begin
        Elem := XmlElement.Create('Customer');
        Elem.Add(XmlElem('No', Customer."No."));
        Elem.Add(XmlElem('Name', Customer.Name));
        Elem.Add(XmlElem('City', Customer.City));
        Elem.Add(XmlElem('Phone', Customer."Phone No."));
        Elem.Add(XmlElem('Email', Customer."E-Mail"));
        Elem.Add(XmlElem('SocialCreditPoints', Format(Customer."Social Credit Points")));
        Elem.Add(XmlElem('SocialCreditLabel', Customer."Social Credit Label"));
        Elem.Add(XmlElem('Rank', SocialCreditMgt.GetRank(Customer."Social Credit Points")));
        exit(Elem);
    end;

    local procedure BuildVendorXmlElement(Vendor: Record Vendor): XmlElement
    var
        Elem: XmlElement;
    begin
        Elem := XmlElement.Create('Vendor');
        Elem.Add(XmlElem('No', Vendor."No."));
        Elem.Add(XmlElem('Name', Vendor.Name));
        Elem.Add(XmlElem('City', Vendor.City));
        Elem.Add(XmlElem('Phone', Vendor."Phone No."));
        Elem.Add(XmlElem('Email', Vendor."E-Mail"));
        Elem.Add(XmlElem('Balance', Format(Vendor."Balance (LCY)")));
        Elem.Add(XmlElem('PaymentTerms', Vendor."Payment Terms Code"));
        exit(Elem);
    end;

    local procedure BuildItemXmlElement(Item: Record Item): XmlElement
    var
        Elem: XmlElement;
    begin
        Elem := XmlElement.Create('Item');
        Elem.Add(XmlElem('No', Item."No."));
        Elem.Add(XmlElem('Description', Item.Description));
        Elem.Add(XmlElem('Inventory', Format(Item.Inventory)));
        Elem.Add(XmlElem('UnitPrice', Format(Item."Unit Price")));
        Elem.Add(XmlElem('UnitCost', Format(Item."Unit Cost")));
        Elem.Add(XmlElem('Category', Item."Item Category Code"));
        Elem.Add(XmlElem('UnitOfMeasure', Item."Base Unit of Measure"));
        exit(Elem);
    end;

    local procedure AddExcelHeader(var ExcelBuffer: Record "Excel Buffer"; HeaderText: Text)
    begin
        ExcelBuffer.AddColumn(HeaderText, false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
    end;

    local procedure AddExcelCell(var ExcelBuffer: Record "Excel Buffer"; CellValue: Text)
    begin
        ExcelBuffer.AddColumn(CellValue, false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
    end;

    var
        SocialCreditMgt: Codeunit "Social Credit Mgt";
}
