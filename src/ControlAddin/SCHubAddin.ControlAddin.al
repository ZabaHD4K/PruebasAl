controladdin "SC Hub Addin"
{
    StartupScript = 'src/ControlAddin/js/hub.js';
    HorizontalStretch = true;
    VerticalStretch = true;
    MinimumHeight = 600;
    RequestedHeight = 700;

    event OnReady();
    event OnNavigate(Target: Text);
}
