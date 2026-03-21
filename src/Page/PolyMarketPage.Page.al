page 50118 "PolyMarket"
{
    PageType = List;
    Caption = 'PolyMarket Live';
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "PolyMarket Market";
    SourceTableTemporary = true;
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
                    LoadData();
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

    trigger OnOpenPage()
    begin
        LoadData();
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

    var
        SearchText: Text[250];
        QuestionStyle: Text;
        YesStyle: Text;
        NoStyle: Text;

    local procedure ApplySearch()
    begin
        if SearchText = '' then
            Rec.SetRange("Search Text")
        else
            Rec.SetFilter("Search Text", '@*' + SearchText + '*');
        CurrPage.Update(false);
    end;

    local procedure LoadData()
    var
        Setup: Record "PolyMarket Setup";
        Client: HttpClient;
        Response: HttpResponseMessage;
        Json: Text;
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
        Setup := Setup.GetOrCreate();

        Rec.Reset();
        Rec.DeleteAll();

        if not Client.Get(Setup."API Base URL" + '/markets?limit=48&closed=false&order=volume&ascending=false', Response) then
            exit;
        if not Response.IsSuccessStatusCode then
            exit;

        Response.Content.ReadAs(Json);
        if not JArray.ReadFrom(Json) then
            exit;

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

        // Re-aplicar búsqueda si había texto
        if SearchText <> '' then
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
