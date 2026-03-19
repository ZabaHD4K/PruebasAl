pageextension 50108 "Item List Export" extends "Item List"
{
    actions
    {
        addlast(processing)
        {
            group(ExportItemGroup)
            {
                Caption = 'Exportar';
                Image = Export;

                action(ItemExportCSV)
                {
                    ApplicationArea = All;
                    Caption = 'Exportar CSV';
                    Image = ExportToExcel;
                    ToolTip = 'Descarga el inventario en formato CSV.';

                    trigger OnAction()
                    var
                        ExportMgt: Codeunit "SC Export Mgt";
                    begin
                        ExportMgt.ExportItemsAsCSV();
                    end;
                }
                action(ItemExportXML)
                {
                    ApplicationArea = All;
                    Caption = 'Exportar XML';
                    Image = XMLFile;
                    ToolTip = 'Descarga el inventario en formato XML.';

                    trigger OnAction()
                    var
                        ExportMgt: Codeunit "SC Export Mgt";
                    begin
                        ExportMgt.ExportItemsAsXML();
                    end;
                }
                action(ItemExportJSON)
                {
                    ApplicationArea = All;
                    Caption = 'Exportar JSON';
                    Image = Web;
                    ToolTip = 'Descarga el inventario en formato JSON.';

                    trigger OnAction()
                    var
                        ExportMgt: Codeunit "SC Export Mgt";
                    begin
                        ExportMgt.ExportItemsAsJSON();
                    end;
                }
                action(ItemExportExcel)
                {
                    ApplicationArea = All;
                    Caption = 'Exportar Excel';
                    Image = Excel;
                    ToolTip = 'Descarga el inventario en formato Excel (.xlsx).';

                    trigger OnAction()
                    var
                        ExportMgt: Codeunit "SC Export Mgt";
                    begin
                        ExportMgt.ExportItemsAsExcel();
                    end;
                }
            }
        }
    }
}
