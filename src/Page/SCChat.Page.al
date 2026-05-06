page 50111 "SC Chat"
{
    PageType = Card;
    Caption = 'Chat IA';
    UsageCategory = Lists;
    ApplicationArea = All;
    InsertAllowed = false;
    DeleteAllowed = false;
    ModifyAllowed = false;

    layout
    {
        area(Content)
        {
            usercontrol(ChatAddin; "SC Chat Addin")
            {
                ApplicationArea = All;

                trigger OnReady()
                begin
                    IsReady := true;
                    CurrPage.ChatAddin.SetConfigured(ChatMgt.IsConfigured());
                    if ChatMgt.IsConfigured() then
                        LoadExistingMessages();
                end;

                trigger OnSendMessage(UserText: Text)
                begin
                    SendUserMessage(UserText);
                end;

                trigger OnClearChat()
                begin
                    if Confirm('¿Limpiar todo el historial de esta conversación?', false) then begin
                        ChatMgt.ClearSession(SessionId);
                        CurrPage.ChatAddin.ClearMessages();
                    end;
                end;

                trigger OnSaveApiKey(ApiKey: Text)
                begin
                    SaveApiKey(ApiKey);
                end;
            }
        }
    }

    var
        ChatMgt: Codeunit "SC Chat Mgt";
        SessionId: Guid;
        IsReady: Boolean;

    trigger OnInit()
    begin
        SessionId := CreateGuid();
    end;

    local procedure LoadExistingMessages()
    var
        ChatLine: Record "SC Chat Line";
        RoleName: Text;
        TimeStr: Text;
    begin
        ChatLine.SetRange("Session ID", SessionId);
        ChatLine.SetFilter(Role, '<>%1', ChatLine.Role::System);
        ChatLine.SetCurrentKey("Entry No.");
        if ChatLine.FindSet() then
            repeat
                case ChatLine.Role of
                    ChatLine.Role::User:
                        RoleName := 'user';
                    ChatLine.Role::Assistant:
                        RoleName := 'assistant';
                    else
                        RoleName := 'assistant';
                end;
                TimeStr := Format(ChatLine."Message DateTime", 0, '<Hours24,2>:<Minutes,2>');
                CurrPage.ChatAddin.AddMessage(RoleName, ChatLine."Message Text", TimeStr);
            until ChatLine.Next() = 0;
    end;

    local procedure SendUserMessage(UserText: Text)
    var
        MsgToSend: Text;
        Response: Text;
        TimeStr: Text;
    begin
        MsgToSend := UserText.Trim();
        if MsgToSend = '' then
            exit;

        TimeStr := Format(CurrentDateTime, 0, '<Hours24,2>:<Minutes,2>');
        CurrPage.ChatAddin.AddMessage('user', MsgToSend, TimeStr);
        CurrPage.ChatAddin.SetStatus('⏳ Pensando...');
        CurrPage.Update(false);

        Response := ChatMgt.SendMessage(SessionId, MsgToSend);

        TimeStr := Format(CurrentDateTime, 0, '<Hours24,2>:<Minutes,2>');
        CurrPage.ChatAddin.AddMessage('assistant', Response, TimeStr);
        CurrPage.ChatAddin.SetStatus('');
        CurrPage.Update(false);
    end;

    local procedure SaveApiKey(ApiKey: Text)
    var
        Setup: Record "SC Chat Setup";
        IsNew: Boolean;
    begin
        IsNew := not Setup.Get('');
        if IsNew then begin
            Setup.Init();
            Setup."Primary Key"  := '';
            Setup."Model"        := 'openai/gpt-4o-mini';
            Setup."Max Tokens"   := 1000;
            Setup."API Base URL" := 'https://openrouter.ai/api/v1';
            Setup."System Prompt" := 'Eres un asistente de Business Central. Ayuda con preguntas sobre ventas, clientes, facturas y operaciones empresariales.';
        end;

        Setup."OpenAI API Key" := CopyStr(ApiKey, 1, 250);

        if IsNew then
            Setup.Insert(false)
        else
            Setup.Modify(false);

        CurrPage.ChatAddin.SetConfigured(true);
        CurrPage.Update(false);
    end;
}
