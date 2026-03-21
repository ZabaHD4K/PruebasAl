controladdin "PM Addin"
{
    StartupScript = 'src/ControlAddin/js/pm.js';
    HorizontalStretch = true;
    VerticalStretch = false;
    MinimumHeight = 700;
    MaximumHeight = 700;

    /// <summary>Stores the API base URL in JS (no longer triggers a fetch).</summary>
    procedure SetApiBase(Url: Text);

    /// <summary>Sends markets JSON (fetched server-side) to JS for rendering.</summary>
    procedure LoadMarketsData(JsonText: Text);

    /// <summary>Sends tags JSON (fetched server-side) to JS for the filter selector.</summary>
    procedure LoadTagsData(JsonText: Text);

    /// <summary>Fired by the JS when it wants AL to re-fetch and push fresh data.</summary>
    event RequestRefresh();

    /// <summary>Fired by the JS when Microsoft.Dynamics.NAV.AddInReady() is called.</summary>
    event ControlAddInReady();
}
