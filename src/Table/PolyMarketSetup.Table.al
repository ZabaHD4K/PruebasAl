table 50106 "PolyMarket Setup"
{
    Caption = 'PolyMarket Setup';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
            DataClassification = SystemMetadata;
        }
        field(2; "API Base URL"; Text[250])
        {
            Caption = 'API Base URL';
            DataClassification = CustomerContent;
            InitValue = 'https://gamma-api.polymarket.com';
        }
    }

    keys
    {
        key(PK; "Primary Key") { Clustered = true; }
    }

    procedure GetOrCreate(): Record "PolyMarket Setup"
    var
        Setup: Record "PolyMarket Setup";
    begin
        if not Setup.Get('') then begin
            Setup.Init();
            Setup."Primary Key" := '';
            Setup."API Base URL" := 'https://gamma-api.polymarket.com';
            Setup.Insert(false);
        end;
        exit(Setup);
    end;
}
