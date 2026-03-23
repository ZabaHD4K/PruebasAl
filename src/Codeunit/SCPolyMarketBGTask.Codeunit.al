/// <summary>
/// Codeunit de tarea en segundo plano para PolyMarket Live.
/// Se ejecuta en una sesión separada (sin UI, sin escritura a BD).
/// Recibe la URL base vía parámetros, hace la llamada HTTP y devuelve el JSON crudo.
/// El resultado lo procesa OnPageBackgroundTaskCompleted en PolyMarketPage.
/// </summary>
codeunit 50115 "SC PolyMarket BG Task"
{
    trigger OnRun()
    var
        Params: Dictionary of [Text, Text];
        Results: Dictionary of [Text, Text];
        Client: HttpClient;
        Response: HttpResponseMessage;
        ApiUrl: Text;
        Json: Text;
    begin
        Params := Page.GetBackgroundParameters();

        if not Params.Get('ApiUrl', ApiUrl) then
            exit;
        if ApiUrl = '' then
            exit;

        if not Client.Get(ApiUrl + '/markets?limit=48&closed=false&order=volume&ascending=false', Response) then
            exit;
        if not Response.IsSuccessStatusCode then
            exit;

        Response.Content.ReadAs(Json);
        Results.Add('Json', Json);
        Page.SetBackgroundTaskResult(Results);
    end;
}
