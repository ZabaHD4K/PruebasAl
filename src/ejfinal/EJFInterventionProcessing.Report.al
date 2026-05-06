report 50132 "EJF Intervention Processing"
{
    Caption = 'Intervention Processing', Comment = 'ESP="Procesamiento de Intervenciones"';
    ProcessingOnly = true;
    UsageCategory = Tasks;
    ApplicationArea = All;

    dataset
    {
        dataitem(InterventionHeader; "EJF Intervention Header")
        {
            RequestFilterFields = "No.", "Customer No.", "Requested Date";

            trigger OnPreDataItem()
            begin
                if OnlyOpen then
                    SetRange(Status, "EJF Intervention Status"::Open);
            end;

            trigger OnAfterGetRecord()
            var
                Line: Record "EJF Intervention Line";
            begin
                if InterventionHeader.Status <> "EJF Intervention Status"::Open then
                    CurrReport.Skip();

                if OnlyWithLines then begin
                    Line.SetRange("Document No.", InterventionHeader."No.");
                    if Line.IsEmpty() then
                        CurrReport.Skip();
                end;

                Mgt.InsertSuggestedLine(InterventionHeader);

                if LaunchDoc then
                    if InterventionHeader.Status = "EJF Intervention Status"::Open then
                        Mgt.ReleaseIntervention(InterventionHeader);

                ProcessedCount += 1;
            end;

            trigger OnPostDataItem()
            begin
                Message('Documentos procesados: %1', ProcessedCount);
            end;
        }
    }

    requestpage
    {
        layout
        {
            area(Content)
            {
                group(Options)
                {
                    Caption = 'Options', Comment = 'ESP="Opciones"';
                    field(OnlyOpen; OnlyOpen)
                    {
                        Caption = 'Only Open Documents', Comment = 'ESP="Solo documentos abiertos"';
                        ApplicationArea = All;
                    }
                    field(OnlyWithLines; OnlyWithLines)
                    {
                        Caption = 'Only If Has Lines', Comment = 'ESP="Solo si hay líneas"';
                        ApplicationArea = All;
                    }
                    field(LaunchDoc; LaunchDoc)
                    {
                        Caption = 'Release Document', Comment = 'ESP="Lanzar el documento"';
                        ApplicationArea = All;
                    }
                }
            }
        }
    }

    var
        Mgt: Codeunit "EJF Intervention Mgt";
        OnlyOpen: Boolean;
        OnlyWithLines: Boolean;
        LaunchDoc: Boolean;
        ProcessedCount: Integer;
}
