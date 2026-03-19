table 50104 "SC Chat Setup"
{
    Caption = 'SC Chat Setup';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
            DataClassification = SystemMetadata;
        }
        field(2; "OpenAI API Key"; Text[250])
        {
            Caption = 'OpenAI API Key';
            DataClassification = CustomerContent;
        }
        field(3; "Model"; Text[100])
        {
            Caption = 'Model';
            DataClassification = CustomerContent;
            InitValue = 'gpt-4o-mini';
        }
        field(4; "Max Tokens"; Integer)
        {
            Caption = 'Max Tokens';
            DataClassification = CustomerContent;
            InitValue = 1000;
            MinValue = 100;
            MaxValue = 4000;
        }
        field(5; "System Prompt"; Text[1000])
        {
            Caption = 'System Prompt';
            DataClassification = CustomerContent;
            InitValue = 'Eres un asistente de Business Central. Ayuda con preguntas sobre ventas, clientes, facturas y operaciones empresariales.';
        }
        field(6; "API Base URL"; Text[250])
        {
            Caption = 'API Base URL';
            DataClassification = CustomerContent;
            InitValue = 'https://openrouter.ai/api/v1';
        }
    }

    keys
    {
        key(PK; "Primary Key") { Clustered = true; }
    }

    procedure GetOrCreate(): Record "SC Chat Setup"
    var
        Setup: Record "SC Chat Setup";
    begin
        if not Setup.Get('') then begin
            Setup.Init();
            Setup."Primary Key" := '';
            Setup."Model" := 'openai/gpt-4o-mini';
            Setup."Max Tokens" := 1000;
            Setup."System Prompt" := 'Eres un asistente de Business Central. Ayuda con preguntas sobre ventas, clientes, facturas y operaciones empresariales.';
            Setup."API Base URL" := 'https://openrouter.ai/api/v1';
            Setup.Insert(false);
        end;
        exit(Setup);
    end;
}
