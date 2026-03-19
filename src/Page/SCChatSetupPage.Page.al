page 50112 "SC Chat Setup Page"
{
    PageType = NavigatePage;
    Caption = 'API Key del Chat IA';
    SourceTable = "SC Chat Setup";
    UsageCategory = None;
    ApplicationArea = All;
    InsertAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(Content)
        {
            group(KeyGroup)
            {
                Caption = ' ';
                ShowCaption = false;

                field(ApiKey; Rec."OpenAI API Key")
                {
                    ApplicationArea = All;
                    Caption = 'API Key';
                    ExtendedDatatype = Masked;
                    ToolTip = 'Tu clave de API de OpenRouter u OpenAI.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(Guardar)
            {
                ApplicationArea = All;
                Caption = 'Guardar';
                Image = Approve;
                InFooterBar = true;

                trigger OnAction()
                var
                    Existing: Record "SC Chat Setup";
                begin
                    if StrLen(Rec."OpenAI API Key") < 20 then begin
                        Message('La API Key parece demasiado corta.');
                        exit;
                    end;
                    if Existing.Get(Rec."Primary Key") then
                        Rec.Modify(false)
                    else
                        Rec.Insert(false);
                    CurrPage.Close();
                end;
            }
        }
    }

    trigger OnOpenPage()
    var
        Setup: Record "SC Chat Setup";
    begin
        if not Setup.Get('') then begin
            Setup.Init();
            Setup."Primary Key" := '';
            Setup."Model" := 'openai/gpt-4o-mini';
            Setup."Max Tokens" := 1000;
            Setup."API Base URL" := 'https://openrouter.ai/api/v1';
            Setup."System Prompt" := 'Eres un asistente de Business Central.';
        end;
        Rec := Setup;
    end;
}
