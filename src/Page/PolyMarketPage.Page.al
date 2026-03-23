page 50118 "PolyMarket"
{
    PageType = List;
    Caption = 'PolyMarket Live';
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "PolyMarket Market";
    InsertAllowed = false;
    DeleteAllowed = false;
    ModifyAllowed = false;

    layout
    {
        area(Content)
        {
            group(SearchBar)
            {
                ShowCaption = false;
                field(SearchInput; SearchText)
                {
                    ApplicationArea = All;
                    Caption = 'Buscar';
                    ToolTip = 'Filtra los mercados por nombre o categoría.';
                    trigger OnValidate()
                    begin
                        ApplySearch();
                    end;
                }
            }

            // Indicador de estado: visible mientras carga o si hubo error
            group(StatusGroup)
            {
                ShowCaption = false;
                Visible = StatusText <> '';
                field(StatusField; StatusText)
                {
                    ApplicationArea = All;
                    ShowCaption = false;
                    Editable = false;
                    StyleExpr = StatusStyle;
                    ToolTip = 'Estado de la carga de datos desde la API de PolyMarket.';
                }
            }

            repeater(Markets)
            {
                field(Featured; Rec.Featured)
                {
                    ApplicationArea = All;
                    ToolTip = 'Mercado destacado en PolyMarket.';
                }
                field(Question; Rec.Question)
                {
                    ApplicationArea = All;
                    ToolTip = 'Pregunta o título del mercado de predicción.';
                    StyleExpr = QuestionStyle;
                }
                field(Category; Rec.Category)
                {
                    ApplicationArea = All;
                    ToolTip = 'Categoría del mercado.';
                }
                field("Yes Probability"; Rec."Yes Probability")
                {
                    ApplicationArea = All;
                    ToolTip = 'Probabilidad implícita de que ocurra el evento (Sí).';
                    StyleExpr = YesStyle;
                }
                field("No Probability"; Rec."No Probability")
                {
                    ApplicationArea = All;
                    ToolTip = 'Probabilidad implícita de que NO ocurra el evento (No).';
                    StyleExpr = NoStyle;
                }
                field(Volume; Rec.Volume)
                {
                    ApplicationArea = All;
                    ToolTip = 'Volumen total apostado en dólares.';
                }
                field("End Date"; Rec."End Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Fecha de cierre del mercado.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(Reload)
            {
                Caption = 'Recargar ahora';
                ApplicationArea = All;
                Image = Refresh;
                ToolTip = 'Recarga los mercados desde la API de PolyMarket.';
                trigger OnAction()
                begin
                    EnqueueLoad();
                end;
            }
            action(ClearSearch)
            {
                Caption = 'Limpiar búsqueda';
                ApplicationArea = All;
                Image = ClearFilter;
                ToolTip = 'Elimina el filtro de búsqueda y muestra todos los mercados.';
                trigger OnAction()
                begin
                    SearchText := '';
                    ApplySearch();
                end;
            }
        }
        area(Promoted)
        {
            actionref(ReloadRef; Reload) { }
            actionref(ClearRef; ClearSearch) { }
        }
    }

    // ── Ciclo de vida de la página ───────────────────────────────────────────────

    trigger OnOpenPage()
    begin
        EnqueueLoad();
    end;

    trigger OnAfterGetRecord()
    begin
        if Rec.Featured then
            QuestionStyle := 'Strong'
        else
            QuestionStyle := '';

        if Rec."Yes Probability" >= 65 then
            YesStyle := 'Favorable'
        else if Rec."Yes Probability" >= 35 then
            YesStyle := 'Attention'
        else
            YesStyle := 'Unfavorable';

        if Rec."No Probability" >= 65 then
            NoStyle := 'Unfavorable'
        else if Rec."No Probability" >= 35 then
            NoStyle := 'Attention'
        else
            NoStyle := 'Favorable';
    end;

    // ── Background Task ──────────────────────────────────────────────────────────

    trigger OnPageBackgroundTaskCompleted(TaskId: Integer; Results: Dictionary of [Text, Text])
    var
        Json: Text;
    begin
        if TaskId <> BackgroundTaskId then
            exit;

        StatusText := '';
        StatusStyle := '';

        if not Results.Get('Json', Json) then begin
            StatusText := '⚠️ La API no devolvió datos. Pulsa Recargar para intentarlo de nuevo.';
            StatusStyle := 'Attention';
            CurrPage.Update(false);
            exit;
        end;

        ParseAndLoadData(Json);
    end;

    trigger OnPageBackgroundTaskError(TaskId: Integer; ErrorCode: Text; ErrorText: Text; ErrorCallStack: Text; var IsHandled: Boolean)
    begin
        if TaskId <> BackgroundTaskId then
            exit;

        StatusText := '❌ Error al contactar con PolyMarket. Pulsa Recargar para intentarlo de nuevo.';
        StatusStyle := 'Unfavorable';
        IsHandled := true;
        CurrPage.Update(false);
    end;

    // ── Variables ────────────────────────────────────────────────────────────────

    var
        SearchText: Text[250];
        QuestionStyle: Text;
        YesStyle: Text;
        NoStyle: Text;
        BackgroundTaskId: Integer;
        StatusText: Text;
        StatusStyle: Text;

    // ── Procedimientos locales ───────────────────────────────────────────────────

    /// <summary>
    /// Cancela la tarea anterior (si la hay), muestra indicador de carga
    /// y encola la llamada HTTP en segundo plano.
    /// La UI queda libre inmediatamente; los datos llegan en OnPageBackgroundTaskCompleted.
    /// </summary>
    local procedure EnqueueLoad()
    var
        Setup: Record "PolyMarket Setup";
        Params: Dictionary of [Text, Text];
    begin
        // Cancelar tarea previa si aún está corriendo
        if BackgroundTaskId <> 0 then
            CurrPage.CancelBackgroundTask(BackgroundTaskId);

        StatusText := '⏳ Cargando mercados desde PolyMarket...';
        StatusStyle := 'StandardAccent';
        CurrPage.Update(false);

        Setup := Setup.GetOrCreate();
        Params.Add('ApiUrl', Setup."API Base URL");

        CurrPage.EnqueueBackgroundTask(
            BackgroundTaskId,
            Codeunit::"SC PolyMarket BG Task",
            Params,
            30000,
            PageBackgroundTaskErrorLevel::Warning);
    end;

    /// <summary>
    /// Parsea el JSON recibido del background task y rellena la tabla temporal.
    /// Se ejecuta en el hilo principal (puede escribir en Rec).
    /// </summary>
    local procedure ParseAndLoadData(Json: Text)
    var
        JArray: JsonArray;
        JToken: JsonToken;
        JObj: JsonObject;
        EntryNo: Integer;
        i: Integer;
        PriceVal: Decimal;
        DateStr: Text;
        PricesJson: Text;
        QuestionText: Text;
        CategoryText: Text;
    begin
        if not JArray.ReadFrom(Json) then begin
            StatusText := '⚠️ El JSON recibido no tiene el formato esperado.';
            StatusStyle := 'Attention';
            CurrPage.Update(false);
            exit;
        end;

        Rec.Reset();
        Rec.DeleteAll();

        EntryNo := 0;
        for i := 0 to JArray.Count - 1 do begin
            JArray.Get(i, JToken);
            JObj := JToken.AsObject();

            EntryNo += 1;
            Rec.Init();
            Rec."Entry No." := EntryNo;

            QuestionText := '';
            CategoryText := '';

            if JObj.Get('question', JToken) then begin
                QuestionText := JToken.AsValue().AsText();
                Rec.Question := CopyStr(QuestionText, 1, MaxStrLen(Rec.Question));
            end;

            if JObj.Get('category', JToken) then begin
                CategoryText := JToken.AsValue().AsText();
                Rec.Category := CopyStr(CategoryText, 1, MaxStrLen(Rec.Category));
            end;

            Rec."Search Text" := CopyStr(QuestionText + ' ' + CategoryText, 1, MaxStrLen(Rec."Search Text"));

            if JObj.Get('outcomePrices', JToken) then begin
                PricesJson := JToken.AsValue().AsText();
                Rec."Yes Probability" := Round(GetPriceByIndex(PricesJson, 0) * 100, 0.1);
                Rec."No Probability" := Round(GetPriceByIndex(PricesJson, 1) * 100, 0.1);
            end;

            if JObj.Get('volume', JToken) then
                if Evaluate(PriceVal, JToken.AsValue().AsText()) then
                    Rec.Volume := Round(PriceVal, 1);

            if JObj.Get('endDate', JToken) then begin
                DateStr := JToken.AsValue().AsText();
                Rec."End Date" := ParseIsoDate(DateStr);
            end;

            if JObj.Get('featured', JToken) then
                Rec.Featured := JToken.AsValue().AsBoolean();

            Rec.Insert();
        end;

        if SearchText <> '' then
            Rec.SetFilter("Search Text", '@*' + SearchText + '*');

        CurrPage.Update(false);
    end;

    local procedure ApplySearch()
    begin
        if SearchText = '' then
            Rec.SetRange("Search Text")
        else
            Rec.SetFilter("Search Text", '@*' + SearchText + '*');
        CurrPage.Update(false);
    end;

    local procedure GetPriceByIndex(PricesJson: Text; Idx: Integer): Decimal
    var
        JArr: JsonArray;
        JToken: JsonToken;
        Price: Decimal;
    begin
        if not JArr.ReadFrom(PricesJson) then
            exit(0);
        if JArr.Count <= Idx then
            exit(0);
        JArr.Get(Idx, JToken);
        if Evaluate(Price, JToken.AsValue().AsText()) then
            exit(Price);
        exit(0);
    end;

    local procedure ParseIsoDate(IsoStr: Text): Date
    var
        Y: Integer;
        M: Integer;
        D: Integer;
    begin
        if StrLen(IsoStr) < 10 then
            exit(0D);
        if not Evaluate(Y, CopyStr(IsoStr, 1, 4)) then exit(0D);
        if not Evaluate(M, CopyStr(IsoStr, 6, 2)) then exit(0D);
        if not Evaluate(D, CopyStr(IsoStr, 9, 2)) then exit(0D);
        exit(DMY2Date(D, M, Y));
    end;
}
