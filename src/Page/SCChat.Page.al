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
            // ── Setup (primera vez) ──────────────────────────────────────────────
            group(SetupGroup)
            {
                Caption = 'Configurar API Key';
                Visible = not IsConfigured;

                field(ApiKeyInput; ApiKeyBuffer)
                {
                    ApplicationArea = All;
                    Caption = 'API Key';
                    ExtendedDatatype = Masked;
                    ToolTip = 'Pega tu clave de OpenRouter u OpenAI y pulsa Guardar.';
                }
            }

            // ── Chat ─────────────────────────────────────────────────────────────
            group(ChatGroup)
            {
                Caption = ' ';
                ShowCaption = false;
                Visible = IsConfigured;

                part(ChatLines; "SC Chat Lines")
                {
                    ApplicationArea = All;
                    Caption = ' ';
                }

                group(InputRow)
                {
                    Caption = ' ';
                    ShowCaption = false;

                    field(UserInput; UserInputText)
                    {
                        ApplicationArea = All;
                        Caption = ' ';
                        ShowCaption = false;
                        MultiLine = true;
                        ToolTip = 'Escribe tu mensaje aquí.';
                    }
                    // Botón de envío: campo con DrillDown que actúa como botón
                    field(SendBtn; SendBtnLbl)
                    {
                        ApplicationArea = All;
                        Caption = ' ';
                        ShowCaption = false;
                        Editable = false;
                        DrillDown = true;
                        Style = StrongAccent;

                        trigger OnDrillDown()
                        begin
                            SendUserMessage();
                        end;
                    }
                }

                field(StatusInfo; StatusText)
                {
                    ApplicationArea = All;
                    ShowCaption = false;
                    Editable = false;
                    StyleExpr = StatusStyle;
                    Visible = StatusText <> '';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(SaveApiKey)
            {
                ApplicationArea = All;
                Caption = 'Guardar';
                Image = Approve;
                Visible = not IsConfigured;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;

                trigger OnAction()
                begin
                    SaveSetup();
                end;
            }

            action(SendMsg)
            {
                ApplicationArea = All;
                Caption = 'Enviar';
                Image = SendTo;
                Visible = IsConfigured;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                ShortCutKey = 'Ctrl+Return';

                trigger OnAction()
                begin
                    SendUserMessage();
                end;
            }

            action(ClearChat)
            {
                ApplicationArea = All;
                Caption = 'Limpiar chat';
                Image = Delete;
                Visible = IsConfigured;
                Promoted = true;
                PromotedCategory = Process;

                trigger OnAction()
                begin
                    if Confirm('¿Limpiar todo el historial de esta conversación?', false) then begin
                        ChatMgt.ClearSession(SessionId);
                        CurrPage.ChatLines.Page.SetSessionId(SessionId);
                        StatusText := '';
                        CurrPage.Update(false);
                    end;
                end;
            }

            action(ChangeApiKey)
            {
                ApplicationArea = All;
                Caption = 'Cambiar API Key';
                Image = Edit;
                Visible = IsConfigured;
                Promoted = true;
                PromotedCategory = Process;

                trigger OnAction()
                begin
                    OpenApiKeySetup();
                end;
            }
        }
    }

    var
        ChatMgt: Codeunit "SC Chat Mgt";
        SessionId: Guid;
        IsConfigured: Boolean;
        UserInputText: Text;
        ApiKeyBuffer: Text;
        StatusText: Text;
        StatusStyle: Text;
        SendBtnLbl: Text;

    trigger OnInit()
    begin
        SessionId := CreateGuid();
        SendBtnLbl := '▶  Enviar';
    end;

    trigger OnOpenPage()
    begin
        IsConfigured := ChatMgt.IsConfigured();
        if IsConfigured then
            CurrPage.ChatLines.Page.SetSessionId(SessionId);
    end;

    local procedure SaveSetup()
    var
        Setup: Record "SC Chat Setup";
        IsNew: Boolean;
    begin
        if ApiKeyBuffer = '' then begin
            Message('Introduce una API Key antes de guardar.');
            exit;
        end;
        if StrLen(ApiKeyBuffer) < 20 then begin
            Message('La API Key parece demasiado corta.');
            exit;
        end;

        IsNew := not Setup.Get('');
        if IsNew then begin
            Setup.Init();
            Setup."Primary Key" := '';
            Setup."API Base URL" := 'https://openrouter.ai/api/v1';
            Setup."Max Tokens" := 1000;
            Setup."System Prompt" := 'Eres un asistente de Business Central. Ayuda con preguntas sobre ventas, clientes, facturas y operaciones empresariales.';
        end;
        Setup."OpenAI API Key" := CopyStr(ApiKeyBuffer, 1, 250);
        Setup."Model" := 'openai/gpt-4o-mini';

        if IsNew then
            Setup.Insert(false)
        else
            Setup.Modify(false);

        ApiKeyBuffer := '';
        IsConfigured := true;
        CurrPage.Update(false);
        Message('✅ Configuración guardada. ¡Ya puedes usar el chat!');
    end;

    local procedure SendUserMessage()
    var
        MsgToSend: Text;
        Response: Text;
    begin
        MsgToSend := UserInputText.Trim();
        if MsgToSend = '' then
            exit;

        CurrPage.ChatLines.Page.SetSessionId(SessionId);
        UserInputText := '';
        StatusText := '⏳ Enviando...';
        StatusStyle := 'Subordinate';
        CurrPage.Update(false);

        Response := ChatMgt.SendMessage(SessionId, MsgToSend);

        StatusText := '';
        CurrPage.ChatLines.Page.Reload();
        CurrPage.Update(false);
    end;

    local procedure OpenApiKeySetup()
    var
        SetupPage: Page "SC Chat Setup Page";
    begin
        SetupPage.RunModal();
        IsConfigured := ChatMgt.IsConfigured();
        CurrPage.Update(false);
    end;
}
