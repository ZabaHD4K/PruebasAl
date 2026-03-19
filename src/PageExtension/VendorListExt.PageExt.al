pageextension 50107 "Vendor List Export" extends "Vendor List"
{
    actions
    {
        addlast(processing)
        {
            group(ExportVendorGroup)
            {
                Caption = 'Exportar';
                Image = Export;

                action(VendorExportCSV)
                {
                    ApplicationArea = All;
                    Caption = 'Exportar CSV';
                    Image = ExportToExcel;
                    ToolTip = 'Descarga la lista de proveedores en formato CSV.';

                    trigger OnAction()
                    var
                        ExportMgt: Codeunit "SC Export Mgt";
                    begin
                        ExportMgt.ExportVendorsAsCSV();
                    end;
                }
                action(VendorExportXML)
                {
                    ApplicationArea = All;
                    Caption = 'Exportar XML';
                    Image = XMLFile;
                    ToolTip = 'Descarga la lista de proveedores en formato XML.';

                    trigger OnAction()
                    var
                        ExportMgt: Codeunit "SC Export Mgt";
                    begin
                        ExportMgt.ExportVendorsAsXML();
                    end;
                }
                action(VendorExportJSON)
                {
                    ApplicationArea = All;
                    Caption = 'Exportar JSON';
                    Image = Web;
                    ToolTip = 'Descarga la lista de proveedores en formato JSON.';

                    trigger OnAction()
                    var
                        ExportMgt: Codeunit "SC Export Mgt";
                    begin
                        ExportMgt.ExportVendorsAsJSON();
                    end;
                }
                action(VendorExportExcel)
                {
                    ApplicationArea = All;
                    Caption = 'Exportar Excel';
                    Image = Excel;
                    ToolTip = 'Descarga la lista de proveedores en formato Excel (.xlsx).';

                    trigger OnAction()
                    var
                        ExportMgt: Codeunit "SC Export Mgt";
                    begin
                        ExportMgt.ExportVendorsAsExcel();
                    end;
                }
            }
        }
    }
}
