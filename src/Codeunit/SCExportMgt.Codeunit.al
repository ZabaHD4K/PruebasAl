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
        Customer.SetLoadFields("No.", Name, City, "Phone No.", "E-Mail", "Social Credit Points", "Social Credit Label");
        if not Customer.FindSet() then begin
            Message('No hay clientes para exportar.');
            exit;
        end;
        Content.AppendLine('No.,Nombre,Ciudad,Telefono,Email,Social Credit,Estado,Rango');
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
        if not TryDownloadText(Content.ToText(), 'clientes.csv') then
            Message('No se pudo descargar el archivo CSV. Inténtalo de nuevo.');
    end;

    procedure ExportCustomersAsXML()
    var
        Customer: Record Customer;
        Root: XmlElement;
    begin
        Customer.SetLoadFields("No.", Name, City, "Phone No.", "E-Mail", "Social Credit Points", "Social Credit Label");
        if not Customer.FindSet() then begin
            Message('No hay clientes para exportar.');
            exit;
        end;
        Root := XmlElement.Create('Customers');
        repeat
            Root.Add(BuildCustomerXmlElement(Customer));
        until Customer.Next() = 0;
        if not TryDownloadXML(Root, 'clientes.xml') then
            Message('No se pudo generar o descargar el archivo XML. Inténtalo de nuevo.');
    end;

    procedure ExportCustomersAsJSON()
    var
        Customer: Record Customer;
        JsonArr: JsonArray;
        JsonObj: JsonObject;
        JsonTxt: Text;
    begin
        Customer.SetLoadFields("No.", Name, City, "Phone No.", "E-Mail", "Social Credit Points", "Social Credit Label");
        if not Customer.FindSet() then begin
            Message('No hay clientes para exportar.');
            exit;
        end;
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
        if not JsonArr.WriteTo(JsonTxt) then begin
            Message('No se pudo serializar los datos a JSON.');
            exit;
        end;
        if not TryDownloadText(JsonTxt, 'clientes.json') then
            Message('No se pudo descargar el archivo JSON. Inténtalo de nuevo.');
    end;

    procedure ExportCustomersAsExcel()
    var
        Customer: Record Customer;
        ExcelBuffer: Record "Excel Buffer" temporary;
    begin
        Customer.SetLoadFields("No.", Name, City, "Phone No.", "E-Mail", "Social Credit Points", "Social Credit Label");
        if not Customer.FindSet() then begin
            Message('No hay clientes para exportar.');
            exit;
        end;
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
        if not TryOpenExcel(ExcelBuffer, 'Clientes') then
            Message('No se pudo generar el archivo Excel. Inténtalo de nuevo.');
    end;

    // ══════════════════════════════════════════
    //  PROVEEDORES
    // ══════════════════════════════════════════

    procedure ExportVendorsAsCSV()
    var
        Vendor: Record Vendor;
        Content: TextBuilder;
    begin
        Vendor.SetLoadFields("No.", Name, City, "Phone No.", "E-Mail", "Payment Terms Code");
        if not Vendor.FindSet() then begin
            Message('No hay proveedores para exportar.');
            exit;
        end;
        Content.AppendLine('No.,Nombre,Ciudad,Telefono,Email,Saldo (DL),Terminos Pago');
        repeat
            if not TryCalcVendorBalance(Vendor) then;
            Content.AppendLine(StrSubstNo('%1,%2,%3,%4,%5,%6,%7',
                EscapeCSV(Vendor."No."),
                EscapeCSV(Vendor.Name),
                EscapeCSV(Vendor.City),
                EscapeCSV(Vendor."Phone No."),
                EscapeCSV(Vendor."E-Mail"),
                Format(Vendor."Balance (LCY)"),
                EscapeCSV(Vendor."Payment Terms Code")));
        until Vendor.Next() = 0;
        if not TryDownloadText(Content.ToText(), 'proveedores.csv') then
            Message('No se pudo descargar el archivo CSV. Inténtalo de nuevo.');
    end;

    procedure ExportVendorsAsXML()
    var
        Vendor: Record Vendor;
        Root: XmlElement;
    begin
        Vendor.SetLoadFields("No.", Name, City, "Phone No.", "E-Mail", "Payment Terms Code");
        if not Vendor.FindSet() then begin
            Message('No hay proveedores para exportar.');
            exit;
        end;
        Root := XmlElement.Create('Vendors');
        repeat
            if not TryCalcVendorBalance(Vendor) then;
            Root.Add(BuildVendorXmlElement(Vendor));
        until Vendor.Next() = 0;
        if not TryDownloadXML(Root, 'proveedores.xml') then
            Message('No se pudo generar o descargar el archivo XML. Inténtalo de nuevo.');
    end;

    procedure ExportVendorsAsJSON()
    var
        Vendor: Record Vendor;
        JsonArr: JsonArray;
        JsonObj: JsonObject;
        JsonTxt: Text;
    begin
        Vendor.SetLoadFields("No.", Name, City, "Phone No.", "E-Mail", "Payment Terms Code");
        if not Vendor.FindSet() then begin
            Message('No hay proveedores para exportar.');
            exit;
        end;
        repeat
            if not TryCalcVendorBalance(Vendor) then;
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
        if not JsonArr.WriteTo(JsonTxt) then begin
            Message('No se pudo serializar los datos a JSON.');
            exit;
        end;
        if not TryDownloadText(JsonTxt, 'proveedores.json') then
            Message('No se pudo descargar el archivo JSON. Inténtalo de nuevo.');
    end;

    procedure ExportVendorsAsExcel()
    var
        Vendor: Record Vendor;
        ExcelBuffer: Record "Excel Buffer" temporary;
    begin
        Vendor.SetLoadFields("No.", Name, City, "Phone No.", "E-Mail", "Payment Terms Code");
        if not Vendor.FindSet() then begin
            Message('No hay proveedores para exportar.');
            exit;
        end;
        ExcelBuffer.DeleteAll();
        ExcelBuffer.NewRow();
        AddExcelHeader(ExcelBuffer, 'No.');
        AddExcelHeader(ExcelBuffer, 'Nombre');
        AddExcelHeader(ExcelBuffer, 'Ciudad');
        AddExcelHeader(ExcelBuffer, 'Telefono');
        AddExcelHeader(ExcelBuffer, 'Email');
        AddExcelHeader(ExcelBuffer, 'Saldo (DL)');
        AddExcelHeader(ExcelBuffer, 'Terminos Pago');
        repeat
            if not TryCalcVendorBalance(Vendor) then;
            ExcelBuffer.NewRow();
            AddExcelCell(ExcelBuffer, Vendor."No.");
            AddExcelCell(ExcelBuffer, Vendor.Name);
            AddExcelCell(ExcelBuffer, Vendor.City);
            AddExcelCell(ExcelBuffer, Vendor."Phone No.");
            AddExcelCell(ExcelBuffer, Vendor."E-Mail");
            ExcelBuffer.AddColumn(Vendor."Balance (LCY)", false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
            AddExcelCell(ExcelBuffer, Vendor."Payment Terms Code");
        until Vendor.Next() = 0;
        if not TryOpenExcel(ExcelBuffer, 'Proveedores') then
            Message('No se pudo generar el archivo Excel. Inténtalo de nuevo.');
    end;

    // ══════════════════════════════════════════
    //  INVENTARIO
    // ══════════════════════════════════════════

    procedure ExportItemsAsCSV()
    var
        Item: Record Item;
        Content: TextBuilder;
    begin
        Item.SetLoadFields("No.", Description, "Unit Price", "Unit Cost", "Item Category Code", "Base Unit of Measure");
        if not Item.FindSet() then begin
            Message('No hay artículos para exportar.');
            exit;
        end;
        Content.AppendLine('No.,Descripcion,Stock,Precio Venta,Coste,Categoria,Unidad Medida');
        repeat
            if not TryCalcItemInventory(Item) then;
            Content.AppendLine(StrSubstNo('%1,%2,%3,%4,%5,%6,%7',
                EscapeCSV(Item."No."),
                EscapeCSV(Item.Description),
                Format(Item.Inventory),
                Format(Item."Unit Price"),
                Format(Item."Unit Cost"),
                EscapeCSV(Item."Item Category Code"),
                EscapeCSV(Item."Base Unit of Measure")));
        until Item.Next() = 0;
        if not TryDownloadText(Content.ToText(), 'inventario.csv') then
            Message('No se pudo descargar el archivo CSV. Inténtalo de nuevo.');
    end;

    procedure ExportItemsAsXML()
    var
        Item: Record Item;
        Root: XmlElement;
    begin
        Item.SetLoadFields("No.", Description, "Unit Price", "Unit Cost", "Item Category Code", "Base Unit of Measure");
        if not Item.FindSet() then begin
            Message('No hay artículos para exportar.');
            exit;
        end;
        Root := XmlElement.Create('Items');
        repeat
            if not TryCalcItemInventory(Item) then;
            Root.Add(BuildItemXmlElement(Item));
        until Item.Next() = 0;
        if not TryDownloadXML(Root, 'inventario.xml') then
            Message('No se pudo generar o descargar el archivo XML. Inténtalo de nuevo.');
    end;

    procedure ExportItemsAsJSON()
    var
        Item: Record Item;
        JsonArr: JsonArray;
        JsonObj: JsonObject;
        JsonTxt: Text;
    begin
        Item.SetLoadFields("No.", Description, "Unit Price", "Unit Cost", "Item Category Code", "Base Unit of Measure");
        if not Item.FindSet() then begin
            Message('No hay artículos para exportar.');
            exit;
        end;
        repeat
            if not TryCalcItemInventory(Item) then;
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
        if not JsonArr.WriteTo(JsonTxt) then begin
            Message('No se pudo serializar los datos a JSON.');
            exit;
        end;
        if not TryDownloadText(JsonTxt, 'inventario.json') then
            Message('No se pudo descargar el archivo JSON. Inténtalo de nuevo.');
    end;

    procedure ExportItemsAsExcel()
    var
        Item: Record Item;
        ExcelBuffer: Record "Excel Buffer" temporary;
    begin
        Item.SetLoadFields("No.", Description, "Unit Price", "Unit Cost", "Item Category Code", "Base Unit of Measure");
        if not Item.FindSet() then begin
            Message('No hay artículos para exportar.');
            exit;
        end;
        ExcelBuffer.DeleteAll();
        ExcelBuffer.NewRow();
        AddExcelHeader(ExcelBuffer, 'No.');
        AddExcelHeader(ExcelBuffer, 'Descripcion');
        AddExcelHeader(ExcelBuffer, 'Stock');
        AddExcelHeader(ExcelBuffer, 'Precio Venta');
        AddExcelHeader(ExcelBuffer, 'Coste');
        AddExcelHeader(ExcelBuffer, 'Categoria');
        AddExcelHeader(ExcelBuffer, 'Unidad Medida');
        repeat
            if not TryCalcItemInventory(Item) then;
            ExcelBuffer.NewRow();
            AddExcelCell(ExcelBuffer, Item."No.");
            AddExcelCell(ExcelBuffer, Item.Description);
            ExcelBuffer.AddColumn(Item.Inventory, false, '', false, false, false, '#,##0.##', ExcelBuffer."Cell Type"::Number);
            ExcelBuffer.AddColumn(Item."Unit Price", false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
            ExcelBuffer.AddColumn(Item."Unit Cost", false, '', false, false, false, '#,##0.00', ExcelBuffer."Cell Type"::Number);
            AddExcelCell(ExcelBuffer, Item."Item Category Code");
            AddExcelCell(ExcelBuffer, Item."Base Unit of Measure");
        until Item.Next() = 0;
        if not TryOpenExcel(ExcelBuffer, 'Inventario') then
            Message('No se pudo generar el archivo Excel. Inténtalo de nuevo.');
    end;

    // ══════════════════════════════════════════
    //  TRY FUNCTIONS — operaciones con riesgo
    // ══════════════════════════════════════════

    [TryFunction]
    local procedure TryDownloadText(Content: Text; FileName: Text)
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

    [TryFunction]
    local procedure TryDownloadXML(Root: XmlElement; FileName: Text)
    var
        XmlDoc: XmlDocument;
        TempBlob: Codeunit "Temp Blob";
        OutStr: OutStream;
        InStr: InStream;
        FileNameOut: Text;
    begin
        XmlDoc := XmlDocument.Create();
        XmlDoc.Add(Root);
        TempBlob.CreateOutStream(OutStr);
        XmlDoc.WriteTo(OutStr);
        TempBlob.CreateInStream(InStr);
        FileNameOut := FileName;
        DownloadFromStream(InStr, '', '', 'XML Files (*.xml)|*.xml', FileNameOut);
    end;

    [TryFunction]
    local procedure TryOpenExcel(var ExcelBuffer: Record "Excel Buffer"; SheetName: Text)
    begin
        ExcelBuffer.CreateNewBook(SheetName);
        ExcelBuffer.WriteSheet(SheetName, CompanyName(), UserId());
        ExcelBuffer.CloseBook();
        ExcelBuffer.OpenExcel();
    end;

    [TryFunction]
    local procedure TryCalcVendorBalance(var Vendor: Record Vendor)
    begin
        Vendor.CalcFields("Balance (LCY)");
    end;

    [TryFunction]
    local procedure TryCalcItemInventory(var Item: Record Item)
    begin
        Item.CalcFields(Inventory);
    end;

    // ══════════════════════════════════════════
    //  HELPERS PRIVADOS
    // ══════════════════════════════════════════

    local procedure EscapeCSV(Value: Text): Text
    begin
        if Value.Contains(',') or Value.Contains('"') then
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

    // ══════════════════════════════════════════
    //  IMPORTAR CLIENTES
    // ══════════════════════════════════════════

    procedure ImportCustomersFromCSV()
    var
        InStr: InStream;
        FileName: Text;
        Line: Text;
        Fields: array[10] of Text;
        FieldCount: Integer;
        IsHeader: Boolean;
        Imported: Integer;
        Errors: Integer;
        Points: Integer;
        Cr: Char;
        Lf: Char;
    begin
        Cr := 13;
        Lf := 10;
        if not UploadIntoStream('Importar clientes (CSV)', '', 'CSV Files (*.csv)|*.csv', FileName, InStr) then
            exit;

        IsHeader := true;
        Imported := 0;
        Errors := 0;

        while not InStr.EOS() do begin
            InStr.ReadText(Line);
            Line := DelChr(Line, '>', Cr);
            Line := DelChr(Line, '>', Lf);
            if Line = '' then
                continue;
            if IsHeader then begin
                IsHeader := false;
                continue;
            end;

            ParseCsvLine(Line, Fields, FieldCount);
            if FieldCount < 2 then begin
                Errors += 1;
                continue;
            end;

            Points := -1;
            if (FieldCount >= 6) and (Fields[6] <> '') then
                if not Evaluate(Points, Fields[6]) then
                    Points := -1;

            if ProcessImportedCustomer(
                CopyStr(Fields[1], 1, 20),
                CopyStr(Fields[2], 1, 100),
                CopyStr(Fields[3], 1, 30),
                CopyStr(Fields[4], 1, 30),
                CopyStr(Fields[5], 1, 80),
                Points)
            then
                Imported += 1
            else
                Errors += 1;
        end;

        Message('%1 clientes importados correctamente. %2 filas omitidas.', Imported, Errors);
    end;

    procedure ImportCustomersFromXML()
    var
        InStr: InStream;
        FileName: Text;
        ContentBuf: TextBuilder;
        Line: Text;
        XmlDoc: XmlDocument;
        RootElem: XmlElement;
        CustomerNodes: XmlNodeList;
        CustomerNode: XmlNode;
        CustElem: XmlElement;
        TempNode: XmlNode;
        Imported: Integer;
        Errors: Integer;
        No: Code[20];
        Name: Text[100];
        City: Text[30];
        Phone: Text[30];
        Email: Text[80];
        Points: Integer;
        PointsText: Text;
    begin
        if not UploadIntoStream('Importar clientes (XML)', '', 'XML Files (*.xml)|*.xml', FileName, InStr) then
            exit;

        while not InStr.EOS() do begin
            InStr.ReadText(Line);
            ContentBuf.Append(Line);
        end;

        if not XmlDocument.ReadFrom(ContentBuf.ToText(), XmlDoc) then begin
            Message('El archivo XML no tiene un formato válido.');
            exit;
        end;

        XmlDoc.GetRoot(RootElem);
        if not RootElem.SelectNodes('Customer', CustomerNodes) then begin
            Message('No se encontraron elementos <Customer> en el XML.');
            exit;
        end;

        Imported := 0;
        Errors := 0;

        foreach CustomerNode in CustomerNodes do begin
            CustElem := CustomerNode.AsXmlElement();
            No := '';
            Name := '';
            City := '';
            Phone := '';
            Email := '';
            Points := -1;

            if CustElem.SelectSingleNode('No', TempNode) then
                No := CopyStr(TempNode.AsXmlElement().InnerText(), 1, 20);
            if CustElem.SelectSingleNode('Name', TempNode) then
                Name := CopyStr(TempNode.AsXmlElement().InnerText(), 1, 100);
            if CustElem.SelectSingleNode('City', TempNode) then
                City := CopyStr(TempNode.AsXmlElement().InnerText(), 1, 30);
            if CustElem.SelectSingleNode('Phone', TempNode) then
                Phone := CopyStr(TempNode.AsXmlElement().InnerText(), 1, 30);
            if CustElem.SelectSingleNode('Email', TempNode) then
                Email := CopyStr(TempNode.AsXmlElement().InnerText(), 1, 80);
            if CustElem.SelectSingleNode('SocialCreditPoints', TempNode) then begin
                PointsText := TempNode.AsXmlElement().InnerText();
                if PointsText <> '' then
                    if not Evaluate(Points, PointsText) then
                        Points := -1;
            end;

            if ProcessImportedCustomer(No, Name, City, Phone, Email, Points) then
                Imported += 1
            else
                Errors += 1;
        end;

        Message('%1 clientes importados correctamente. %2 filas omitidas.', Imported, Errors);
    end;

    procedure ImportCustomersFromJSON()
    var
        InStr: InStream;
        FileName: Text;
        ContentBuf: TextBuilder;
        Line: Text;
        JArr: JsonArray;
        JToken: JsonToken;
        JObj: JsonObject;
        JVal: JsonToken;
        Imported: Integer;
        Errors: Integer;
        No: Code[20];
        Name: Text[100];
        City: Text[30];
        Phone: Text[30];
        Email: Text[80];
        Points: Integer;
    begin
        if not UploadIntoStream('Importar clientes (JSON)', '', 'JSON Files (*.json)|*.json', FileName, InStr) then
            exit;

        while not InStr.EOS() do begin
            InStr.ReadText(Line);
            ContentBuf.Append(Line);
        end;

        if not JArr.ReadFrom(ContentBuf.ToText()) then begin
            Message('El archivo JSON no tiene un formato válido (se espera un array [ ]).');
            exit;
        end;

        Imported := 0;
        Errors := 0;

        foreach JToken in JArr do begin
            JObj := JToken.AsObject();
            No := '';
            Name := '';
            City := '';
            Phone := '';
            Email := '';
            Points := -1;

            if JObj.Get('no', JVal) then
                No := CopyStr(JVal.AsValue().AsText(), 1, 20);
            if JObj.Get('name', JVal) then
                Name := CopyStr(JVal.AsValue().AsText(), 1, 100);
            if JObj.Get('city', JVal) then
                City := CopyStr(JVal.AsValue().AsText(), 1, 30);
            if JObj.Get('phone', JVal) then
                Phone := CopyStr(JVal.AsValue().AsText(), 1, 30);
            if JObj.Get('email', JVal) then
                Email := CopyStr(JVal.AsValue().AsText(), 1, 80);
            if JObj.Get('socialCreditPoints', JVal) then
                Points := JVal.AsValue().AsInteger();

            if ProcessImportedCustomer(No, Name, City, Phone, Email, Points) then
                Imported += 1
            else
                Errors += 1;
        end;

        Message('%1 clientes importados correctamente. %2 filas omitidas.', Imported, Errors);
    end;

    procedure ImportCustomersFromXLS()
    var
        ExcelBuffer: Record "Excel Buffer" temporary;
        InStr: InStream;
        FileName: Text;
        MaxRow: Integer;
        Row: Integer;
        Col: Integer;
        NoCol: Integer;
        NameCol: Integer;
        CityCol: Integer;
        PhoneCol: Integer;
        EmailCol: Integer;
        PointsCol: Integer;
        Header: Text;
        Imported: Integer;
        Errors: Integer;
        No: Code[20];
        Name: Text[100];
        City: Text[30];
        Phone: Text[30];
        Email: Text[80];
        Points: Integer;
    begin
        if not UploadIntoStream('Importar clientes (Excel)', '', 'Excel Files (*.xlsx)|*.xlsx', FileName, InStr) then
            exit;

        ExcelBuffer.DeleteAll();
        ExcelBuffer.OpenBookStream(InStr, 'Clientes');
        ExcelBuffer.ReadSheet();

        // Detectar columnas por cabecera (flexible ante reordenaciones)
        NoCol := 1; NameCol := 2; CityCol := 3;
        PhoneCol := 4; EmailCol := 5; PointsCol := 6;

        for Col := 1 to 10 do
            if ExcelBuffer.Get(1, Col) then begin
                Header := ExcelBuffer."Cell Value as Text";
                case Header of
                    'No.':           NoCol := Col;
                    'Nombre':        NameCol := Col;
                    'Ciudad':        CityCol := Col;
                    'Telefono':      PhoneCol := Col;
                    'Email':         EmailCol := Col;
                    'Social Credit': PointsCol := Col;
                end;
            end;

        MaxRow := 0;
        if ExcelBuffer.FindLast() then
            MaxRow := ExcelBuffer."Row No.";

        Imported := 0;
        Errors := 0;

        for Row := 2 to MaxRow do begin
            No := '';
            Name := '';
            City := '';
            Phone := '';
            Email := '';
            Points := -1;

            if ExcelBuffer.Get(Row, NoCol) then
                No := CopyStr(ExcelBuffer."Cell Value as Text", 1, 20);
            if ExcelBuffer.Get(Row, NameCol) then
                Name := CopyStr(ExcelBuffer."Cell Value as Text", 1, 100);
            if ExcelBuffer.Get(Row, CityCol) then
                City := CopyStr(ExcelBuffer."Cell Value as Text", 1, 30);
            if ExcelBuffer.Get(Row, PhoneCol) then
                Phone := CopyStr(ExcelBuffer."Cell Value as Text", 1, 30);
            if ExcelBuffer.Get(Row, EmailCol) then
                Email := CopyStr(ExcelBuffer."Cell Value as Text", 1, 80);
            if ExcelBuffer.Get(Row, PointsCol) then
                if not Evaluate(Points, ExcelBuffer."Cell Value as Text") then
                    Points := -1;

            if ProcessImportedCustomer(No, Name, City, Phone, Email, Points) then
                Imported += 1
            else
                Errors += 1;
        end;

        Message('%1 clientes importados correctamente. %2 filas omitidas.', Imported, Errors);
    end;

    // ══════════════════════════════════════════
    //  HELPERS PRIVADOS — IMPORTACIÓN
    // ══════════════════════════════════════════

    /// <summary>
    /// Crea o actualiza un cliente importado.
    /// Si SocialCreditPts es -1 (campo ausente en el archivo) inicializa a 1000.
    /// Si SocialCreditPts es 0 se respeta (cliente en Lista Negra).
    /// </summary>
    local procedure ProcessImportedCustomer(No: Code[20]; Name: Text[100]; City: Text[30]; Phone: Text[30]; Email: Text[80]; SocialCreditPts: Integer): Boolean
    var
        Customer: Record Customer;
        IsNew: Boolean;
        OriginalPoints: Integer;
        TargetPoints: Integer;
        Delta: Integer;
    begin
        if No = '' then
            exit(false);

        TargetPoints := SocialCreditPts;
        if TargetPoints < 0 then
            TargetPoints := 1000;

        Customer.SetLoadFields("No.", Name, City, "Phone No.", "E-Mail", "Social Credit Points");
        IsNew := not Customer.Get(No);
        if IsNew then begin
            Customer.Init();
            Customer."No." := No;
        end else
            OriginalPoints := Customer."Social Credit Points";

        if Name <> '' then
            Customer.Name := Name;
        if City <> '' then
            Customer.City := City;
        if Phone <> '' then
            Customer."Phone No." := Phone;
        if Email <> '' then
            Customer."E-Mail" := Email;

        if IsNew then begin
            Customer.Insert(true);
            SocialCreditMgt.AdjustCustomerPoints(Customer."No.", TargetPoints, 'Importación');
        end else begin
            Customer.Modify(true);
            Delta := TargetPoints - OriginalPoints;
            if Delta <> 0 then
                SocialCreditMgt.AdjustCustomerPoints(Customer."No.", Delta, 'Importación');
        end;

        exit(true);
    end;

    local procedure ParseCsvLine(Line: Text; var Fields: array[10] of Text; var Count: Integer)
    var
        Pos: Integer;
        LineLen: Integer;
        InQuote: Boolean;
        FieldBuf: TextBuilder;
        Ch: Text[1];
    begin
        Count := 0;
        InQuote := false;
        LineLen := StrLen(Line);
        Pos := 1;

        while Pos <= LineLen do begin
            Ch := CopyStr(Line, Pos, 1);
            case true of
                InQuote and (Ch = '"') and (Pos < LineLen) and (CopyStr(Line, Pos + 1, 1) = '"'):
                    begin
                        FieldBuf.Append('"');
                        Pos += 1;
                    end;
                InQuote and (Ch = '"'):
                    InQuote := false;
                not InQuote and (Ch = '"'):
                    InQuote := true;
                not InQuote and (Ch = ','):
                    begin
                        Count += 1;
                        if Count <= ArrayLen(Fields) then
                            Fields[Count] := FieldBuf.ToText();
                        Clear(FieldBuf);
                    end;
                else
                    FieldBuf.Append(Ch);
            end;
            Pos += 1;
        end;

        Count += 1;
        if Count <= ArrayLen(Fields) then
            Fields[Count] := FieldBuf.ToText();
    end;

    var
        SocialCreditMgt: Codeunit "Social Credit Mgt";
}
