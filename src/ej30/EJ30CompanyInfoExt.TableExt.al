tableextension 50101 "EJ30 Company Info Ext" extends "Company Information"
{
    fields
    {
        field(50100; "Texto Legal"; Blob)
        {
            Caption = 'Texto Legal', Comment = 'ESP="Texto Legal"';
            DataClassification = CustomerContent;
        }
    }

    procedure GetTextoLegal(): Text
    var
        InStr: InStream;
        TextContent: Text;
    begin
        CalcFields("Texto Legal");
        if "Texto Legal".HasValue() then begin
            "Texto Legal".CreateInStream(InStr, TextEncoding::UTF8);
            InStr.ReadText(TextContent);
        end;
        exit(TextContent);
    end;

    procedure SetTextoLegal(NewText: Text)
    var
        OutStr: OutStream;
    begin
        "Texto Legal".CreateOutStream(OutStr, TextEncoding::UTF8);
        OutStr.WriteText(NewText);
    end;
}
