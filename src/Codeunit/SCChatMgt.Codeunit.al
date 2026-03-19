codeunit 50104 "SC Chat Mgt"
{
    procedure IsConfigured(): Boolean
    var
        Setup: Record "SC Chat Setup";
    begin
        if not Setup.Get('') then
            exit(false);
        exit(Setup."OpenAI API Key" <> '');
    end;

    procedure SendMessage(SessionId: Guid; UserMessage: Text): Text
    var
        Setup: Record "SC Chat Setup";
        ChatLine: Record "SC Chat Line";
        Response: Text;
    begin
        Setup := Setup.GetOrCreate();
        if Setup."OpenAI API Key" = '' then
            exit('⚠️ API Key no configurada. Haz clic en "Configurar API" para añadir tu clave de OpenAI.');

        // Save user message
        SaveChatLine(SessionId, ChatLine.Role::User, UserMessage);

        // Call API
        if not CallLLMApi(Setup, SessionId, UserMessage, Response) then begin
            SaveChatLine(SessionId, ChatLine.Role::Assistant, Response);
            exit(Response);
        end;

        // Save assistant response
        SaveChatLine(SessionId, ChatLine.Role::Assistant, Response);
        exit(Response);
    end;

    // Returns true and sets Response on success.
    // Returns false and sets Response to the error message on failure.
    // NOTE: HttpClient cannot be used inside [TryFunction], so errors are returned via the Response parameter.
    local procedure CallLLMApi(Setup: Record "SC Chat Setup"; SessionId: Guid; UserMessage: Text; var Response: Text): Boolean
    var
        Client: HttpClient;
        RequestMsg: HttpRequestMessage;
        ResponseMsg: HttpResponseMessage;
        Headers: HttpHeaders;
        Content: HttpContent;
        ContentHeaders: HttpHeaders;
        RequestBody: Text;
        ResponseBody: Text;
        JResponse: JsonObject;
        JChoices: JsonArray;
        JChoice: JsonToken;
        JMessage: JsonToken;
        JContent: JsonToken;
        JError: JsonToken;
        JErrorObj: JsonObject;
        JErrorMsg: JsonToken;
        MessagesJson: Text;
        ApiUrl: Text;
    begin
        MessagesJson := BuildMessagesJson(Setup, SessionId, UserMessage);
        RequestBody := '{"model":"' + Setup."Model" + '","messages":' + MessagesJson + ',"max_tokens":' + Format(Setup."Max Tokens") + '}';

        Content.WriteFrom(RequestBody);
        Content.GetHeaders(ContentHeaders);
        ContentHeaders.Remove('Content-Type');
        ContentHeaders.Add('Content-Type', 'application/json');

        ApiUrl := Setup."API Base URL";
        if ApiUrl = '' then
            ApiUrl := 'https://openrouter.ai/api/v1';
        ApiUrl += '/chat/completions';

        RequestMsg.Method := 'POST';
        RequestMsg.SetRequestUri(ApiUrl);
        RequestMsg.GetHeaders(Headers);
        Headers.Add('Authorization', 'Bearer ' + Setup."OpenAI API Key");
        Headers.Add('X-Title', 'Business Central Chat');
        RequestMsg.Content := Content;

        if not Client.Send(RequestMsg, ResponseMsg) then begin
            Response := '❌ No se pudo conectar con el servidor. Verifica tu conexión y la URL de la API.';
            exit(false);
        end;

        ResponseMsg.Content.ReadAs(ResponseBody);

        if not ResponseMsg.IsSuccessStatusCode() then begin
            if JResponse.ReadFrom(ResponseBody) then
                if JResponse.Get('error', JError) then begin
                    JErrorObj := JError.AsObject();
                    if JErrorObj.Get('message', JErrorMsg) then begin
                        Response := '❌ Error de la API: ' + JErrorMsg.AsValue().AsText();
                        exit(false);
                    end;
                end;
            Response := '❌ Error HTTP ' + Format(ResponseMsg.HttpStatusCode()) + '. Verifica tu API Key y el modelo configurado.';
            exit(false);
        end;

        if not JResponse.ReadFrom(ResponseBody) then begin
            Response := '❌ Respuesta inválida del servidor.';
            exit(false);
        end;

        if not JResponse.Get('choices', JChoice) then begin
            Response := '❌ Formato de respuesta inesperado (sin choices).';
            exit(false);
        end;

        JChoices := JChoice.AsArray();
        if JChoices.Count() = 0 then begin
            Response := '❌ El servidor no devolvió ninguna respuesta.';
            exit(false);
        end;

        JChoices.Get(0, JChoice);
        JChoice.AsObject().Get('message', JMessage);
        JMessage.AsObject().Get('content', JContent);
        Response := JContent.AsValue().AsText();
        exit(true);
    end;

    local procedure BuildMessagesJson(Setup: Record "SC Chat Setup"; SessionId: Guid; UserMessage: Text): Text
    var
        ChatLine: Record "SC Chat Line";
        Msgs: Text;
        RoleName: Text;
        MsgText: Text;
        Escaped: Text;
    begin
        // System message
        Escaped := EscapeJson(Setup."System Prompt");
        Msgs := '[{"role":"system","content":"' + Escaped + '"}';

        // History from this session (last 10 exchanges to stay within token limits)
        ChatLine.SetRange("Session ID", SessionId);
        ChatLine.SetFilter("Role", '<>%1', ChatLine.Role::System);
        if ChatLine.FindSet() then
            repeat
                case ChatLine.Role of
                    ChatLine.Role::User:
                        RoleName := 'user';
                    ChatLine.Role::Assistant:
                        RoleName := 'assistant';
                    else
                        RoleName := 'user';
                end;
                MsgText := ChatLine."Message Text";
                Escaped := EscapeJson(MsgText);
                Msgs += ',{"role":"' + RoleName + '","content":"' + Escaped + '"}';
            until ChatLine.Next() = 0;

        // Current user message
        Escaped := EscapeJson(UserMessage);
        Msgs += ',{"role":"user","content":"' + Escaped + '"}]';
        exit(Msgs);
    end;

    local procedure EscapeJson(Input: Text): Text
    begin
        Input := Input.Replace('\', '\\');
        Input := Input.Replace('"', '\"');
        Input := Input.Replace('/', '\/');
        exit(Input);
    end;

    procedure SaveChatLine(SessionId: Guid; Role: Option; MessageText: Text)
    var
        ChatLine: Record "SC Chat Line";
    begin
        ChatLine.Init();
        ChatLine."Session ID" := SessionId;
        ChatLine.Role := Role;
        ChatLine."Message Text" := CopyStr(MessageText, 1, 2048);
        ChatLine."Message DateTime" := CurrentDateTime();
        ChatLine."User ID" := CopyStr(UserId(), 1, 50);
        ChatLine.Insert(false);
    end;

    procedure ClearSession(SessionId: Guid)
    var
        ChatLine: Record "SC Chat Line";
    begin
        ChatLine.SetRange("Session ID", SessionId);
        if not ChatLine.IsEmpty() then
            ChatLine.DeleteAll();
    end;
}
