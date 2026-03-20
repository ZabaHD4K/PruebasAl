controladdin "SC Slider Addin"
{
    StartupScript = 'src/ControlAddin/js/slider.js';
    MinimumHeight = 180;
    MaximumHeight = 180;
    MinimumWidth = 300;
    HorizontalStretch = true;
    VerticalStretch = false;

    /// <summary>Llamado desde AL para fijar el valor del slider y actualizar la UI.</summary>
    procedure SetValue(NewValue: Integer);

    /// <summary>Llamado desde el slider JS cuando el usuario suelta el slider.</summary>
    event OnValueChanged(NewValue: Integer);
}
