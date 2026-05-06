pageextension 50109 "EJ30 Company Info PageExt" extends "Company Information"
{
    layout
    {
        addlast(content)
        {
            group(GrpTextoLegal)
            {
                Caption = 'Texto Legal', Comment = 'ESP="Texto Legal"';

                field(TextoLegalField; TextoLegalVar)
                {
                    ApplicationArea = All;
                    Caption = 'Texto Legal', Comment = 'ESP="Texto Legal"';
                    MultiLine = true;
                    ToolTip = 'Specifies the legal text that will appear at the end of sales invoices.',
                              Comment = 'ESP="Especifica el texto legal que aparecerá al final de las facturas de venta."';

                    trigger OnValidate()
                    begin
                        Rec.SetTextoLegal(TextoLegalVar);
                        Rec.Modify(true);
                    end;
                }
            }
        }
    }

    var
        TextoLegalVar: Text;

    trigger OnAfterGetRecord()
    begin
        TextoLegalVar := Rec.GetTextoLegal();
    end;
}
