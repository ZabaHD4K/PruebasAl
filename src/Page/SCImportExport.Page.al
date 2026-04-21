page 50119 "SC Import Export"
{
    PageType = Card;
    Caption = 'Importar / Exportar Clientes';
    ApplicationArea = All;
    UsageCategory = Administration;
    InsertAllowed = false;
    DeleteAllowed = false;
    ModifyAllowed = false;

    layout
    {
        area(Content)
        {
            group(ExportGroup)
            {
                Caption = 'Exportar clientes';
                label(LblExport)
                {
                    ApplicationArea = All;
                    Caption = 'Descarga todos los clientes (con Social Credit) en el formato elegido.';
                }
                label(LblExportCSV)
                {
                    ApplicationArea = All;
                    Caption = '· CSV — compatible con Excel, Google Sheets y cualquier editor de texto.';
                }
                label(LblExportXML)
                {
                    ApplicationArea = All;
                    Caption = '· XML — estándar para intercambio con otros sistemas ERP.';
                }
                label(LblExportJSON)
                {
                    ApplicationArea = All;
                    Caption = '· JSON — ideal para integraciones con APIs y aplicaciones web.';
                }
                label(LblExportXLS)
                {
                    ApplicationArea = All;
                    Caption = '· Excel (XLS) — abre directamente en Microsoft Excel.';
                }
            }
            group(ImportGroup)
            {
                Caption = 'Importar clientes';
                label(LblImport)
                {
                    ApplicationArea = All;
                    Caption = 'Carga clientes desde un archivo. Si el archivo no incluye puntuación de Social Credit, se asignarán 1.000 puntos por defecto.';
                }
                label(LblImportFormat)
                {
                    ApplicationArea = All;
                    Caption = 'Formatos soportados: CSV, XML, JSON y Excel. Si el cliente ya existe en BC se actualizarán sus datos.';
                }
                label(LblImportCSVHint)
                {
                    ApplicationArea = All;
                    Caption = 'Cabeceras CSV esperadas: No.,Nombre,Ciudad,Telefono,Email,Social Credit';
                }
                label(LblImportXMLHint)
                {
                    ApplicationArea = All;
                    Caption = 'Estructura XML esperada: <Customers><Customer><No>…</No><Name>…</Name>…</Customer></Customers>';
                }
                label(LblImportJSONHint)
                {
                    ApplicationArea = All;
                    Caption = 'Estructura JSON esperada: [{"no":"…","name":"…","city":"…","socialCreditPoints":1000}]';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            group(ExportActions)
            {
                Caption = 'Exportar';
                Image = Export;
                action(ExportCSV)
                {
                    ApplicationArea = All;
                    Caption = 'Exportar CSV';
                    Image = ExportFile;
                    ToolTip = 'Descarga todos los clientes en formato CSV (separado por comas).';
                    trigger OnAction()
                    var
                        SCExportMgt: Codeunit "SC Export Mgt";
                    begin
                        SCExportMgt.ExportCustomersAsCSV();
                    end;
                }
                action(ExportXML)
                {
                    ApplicationArea = All;
                    Caption = 'Exportar XML';
                    Image = ExportFile;
                    ToolTip = 'Descarga todos los clientes en formato XML estructurado.';
                    trigger OnAction()
                    var
                        SCExportMgt: Codeunit "SC Export Mgt";
                    begin
                        SCExportMgt.ExportCustomersAsXML();
                    end;
                }
                action(ExportJSON)
                {
                    ApplicationArea = All;
                    Caption = 'Exportar JSON';
                    Image = ExportFile;
                    ToolTip = 'Descarga todos los clientes en formato JSON.';
                    trigger OnAction()
                    var
                        SCExportMgt: Codeunit "SC Export Mgt";
                    begin
                        SCExportMgt.ExportCustomersAsJSON();
                    end;
                }
                action(ExportXLS)
                {
                    ApplicationArea = All;
                    Caption = 'Exportar Excel';
                    Image = ExportFile;
                    ToolTip = 'Abre todos los clientes directamente en Microsoft Excel.';
                    trigger OnAction()
                    var
                        SCExportMgt: Codeunit "SC Export Mgt";
                    begin
                        SCExportMgt.ExportCustomersAsExcel();
                    end;
                }
            }
            group(XmlportActions)
            {
                Caption = 'XMLport nativo';
                Image = XMLFile;
                action(RunXmlport)
                {
                    ApplicationArea = All;
                    Caption = 'Importar / Exportar XML (XMLport)';
                    Image = XMLFile;
                    ToolTip = 'Ejecuta el XMLport nativo de BC para importar o exportar clientes en XML con Social Credit. Pregunta la dirección al abrirse.';
                    RunObject = xmlport "SC Customer Xmlport";
                }
            }
            group(ImportActions)
            {
                Caption = 'Importar';
                Image = Import;
                action(ImportCSV)
                {
                    ApplicationArea = All;
                    Caption = 'Importar CSV';
                    Image = ImportFile;
                    ToolTip = 'Carga clientes desde un archivo CSV. Cabeceras: No.,Nombre,Ciudad,Telefono,Email,Social Credit';
                    trigger OnAction()
                    var
                        SCExportMgt: Codeunit "SC Export Mgt";
                    begin
                        SCExportMgt.ImportCustomersFromCSV();
                    end;
                }
                action(ImportXML)
                {
                    ApplicationArea = All;
                    Caption = 'Importar XML';
                    Image = ImportFile;
                    ToolTip = 'Carga clientes desde un archivo XML con estructura <Customers><Customer>…</Customer></Customers>.';
                    trigger OnAction()
                    var
                        SCExportMgt: Codeunit "SC Export Mgt";
                    begin
                        SCExportMgt.ImportCustomersFromXML();
                    end;
                }
                action(ImportJSON)
                {
                    ApplicationArea = All;
                    Caption = 'Importar JSON';
                    Image = ImportFile;
                    ToolTip = 'Carga clientes desde un archivo JSON con estructura de array [{"no":"…","name":"…",…}].';
                    trigger OnAction()
                    var
                        SCExportMgt: Codeunit "SC Export Mgt";
                    begin
                        SCExportMgt.ImportCustomersFromJSON();
                    end;
                }
                action(ImportXLS)
                {
                    ApplicationArea = All;
                    Caption = 'Importar Excel';
                    Image = ImportFile;
                    ToolTip = 'Carga clientes desde un archivo Excel (.xlsx). La hoja debe llamarse "Clientes".';
                    trigger OnAction()
                    var
                        SCExportMgt: Codeunit "SC Export Mgt";
                    begin
                        SCExportMgt.ImportCustomersFromXLS();
                    end;
                }
            }
        }
        area(Promoted)
        {
            group(PromotedXmlport)
            {
                Caption = 'XMLport';
                actionref(RunXmlportRef; RunXmlport) { }
            }
            group(PromotedExport)
            {
                Caption = 'Exportar';
                actionref(ExportCSVRef; ExportCSV) { }
                actionref(ExportXMLRef; ExportXML) { }
                actionref(ExportJSONRef; ExportJSON) { }
                actionref(ExportXLSRef; ExportXLS) { }
            }
            group(PromotedImport)
            {
                Caption = 'Importar';
                actionref(ImportCSVRef; ImportCSV) { }
                actionref(ImportXMLRef; ImportXML) { }
                actionref(ImportJSONRef; ImportJSON) { }
                actionref(ImportXLSRef; ImportXLS) { }
            }
        }
    }
}
