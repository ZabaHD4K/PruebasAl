reportextension 50131 "EJ30 Sales Invoice Ext" extends "Standard Sales - Invoice"
{
    dataset
    {
        add("Sales Invoice Header")
        {
            column(TextoLegal; TextoLegalText)
            {
                Caption = 'Texto Legal', Comment = 'ESP="Texto Legal"';
            }
        }
        modify("Sales Invoice Header")
        {
            trigger OnAfterGetRecord()
            begin
                if not TextoLegalLoaded then begin
                    TextoLegalLoaded := true;
                    LoadTextoLegal();
                end;
            end;
        }
    }

    var
        TextoLegalText: Text;
        TextoLegalLoaded: Boolean;

    local procedure LoadTextoLegal()
    var
        CompInfo: Record "Company Information";
    begin
        if CompInfo.Get() then
            TextoLegalText := CompInfo.GetTextoLegal();
    end;
}
