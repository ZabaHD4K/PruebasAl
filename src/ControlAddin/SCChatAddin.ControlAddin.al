controladdin "SC Chat Addin"
{
    StartupScript = 'src/ControlAddin/js/chat.js';
    HorizontalStretch = true;
    VerticalStretch = true;
    MinimumHeight = 600;
    RequestedHeight = 700;

    event OnReady();
    event OnSendMessage(UserText: Text);
    event OnClearChat();
    event OnSaveApiKey(ApiKey: Text);

    procedure AddMessage(Role: Text; MessageText: Text; TimeStr: Text);
    procedure SetStatus(StatusText: Text);
    procedure ClearMessages();
    procedure SetConfigured(IsConfigured: Boolean);
    procedure ShowSetup();
}
