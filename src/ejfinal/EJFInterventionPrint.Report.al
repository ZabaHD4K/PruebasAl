report 50133 "EJF Intervention Print"
{
    Caption = 'Intervention Print', Comment = 'ESP="Impresión de Intervención"';
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;
    DefaultRenderingLayout = EJFInterventionLayout;

    dataset
    {
        dataitem(Header; "EJF Intervention Header")
        {
            RequestFilterFields = "No.", "Customer No.", Status;

            column(CompanyName; CompanyNameVal) { }
            column(CompanyAddress; CompanyAddressVal) { }
            column(CompanyCity; CompanyCityVal) { }
            column(CompanyPhone; CompanyPhoneVal) { }
            column(ReportDateCol; ReportDate) { }
            column(HeaderNo; "No.") { }
            column(HeaderDescription; Description) { }
            column(CustomerNo; "Customer No.") { }
            column(CustomerName; "Customer Name") { }
            column(RequestedDate; "Requested Date") { }
            column(PlannedDate; "Planned Date") { }
            column(HeaderStatus; Format(Status)) { }
            column(HeaderCity; City) { }
            column(HeaderPhone; "Phone No.") { }
            column(TotalHours; "Total Hours") { }
            column(TotalAmount; "Total Amount") { }

            dataitem(Line; "EJF Intervention Line")
            {
                DataItemLink = "Document No." = field("No.");
                DataItemTableView = sorting("Document No.", "Line No.");

                column(LineDescription; Description) { }
                column(LineQuantity; Quantity) { }
                column(LineHours; Hours) { }
                column(LineUnitCost; "Unit Cost") { }
                column(LineAmount; Amount) { }
                column(LineBillable; Format(Billable)) { }
            }

            trigger OnPreDataItem()
            var
                CompanyInfo: Record "Company Information";
            begin
                ReportDate := Today();
                if CompanyInfo.Get() then begin
                    CompanyNameVal := CompanyInfo.Name;
                    CompanyAddressVal := CompanyInfo.Address;
                    CompanyCityVal := CompanyInfo.City;
                    CompanyPhoneVal := CompanyInfo."Phone No.";
                end;
            end;

            trigger OnAfterGetRecord()
            begin
                CalcFields("Total Hours", "Total Amount");
            end;
        }
    }

    rendering
    {
        layout(EJFInterventionLayout)
        {
            Type = RDLC;
            LayoutFile = 'src/ejfinal/EJFInterventionPrint.rdlc';
        }
    }

    var
        CompanyNameVal: Text[100];
        CompanyAddressVal: Text[100];
        CompanyCityVal: Text[30];
        CompanyPhoneVal: Text[30];
        ReportDate: Date;
}
