page 50109 "SC Invoice API"
{
    PageType = API;
    APIPublisher = 'arbentia';
    APIGroup = 'socialcredit';
    APIVersion = 'v1.0';
    EntityName = 'invoice';
    EntitySetName = 'invoices';
    SourceTable = "Cust. Ledger Entry";
    SourceTableView = where("Document Type" = const(Invoice));
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = false;
    ODataKeyFields = "Entry No.";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(entryNo; Rec."Entry No.")
                {
                    Caption = 'entryNo';
                }
                field(customerNo; Rec."Customer No.")
                {
                    Caption = 'customerNo';
                }
                field(customerName; Rec."Customer Name")
                {
                    Caption = 'customerName';
                }
                field(documentNo; Rec."Document No.")
                {
                    Caption = 'documentNo';
                }
                field(postingDate; Rec."Posting Date")
                {
                    Caption = 'postingDate';
                }
                field(dueDate; Rec."Due Date")
                {
                    Caption = 'dueDate';
                }
                field(open; Rec.Open)
                {
                    Caption = 'open';
                }
                field(amount; Rec."Sales (LCY)")
                {
                    Caption = 'amount';
                }
                field(overdue; Overdue)
                {
                    Caption = 'overdue';
                }
            }
        }
    }

    var
        Overdue: Boolean;

    trigger OnAfterGetRecord()
    begin
        Overdue := Rec.Open and (Rec."Due Date" < Today());
    end;
}
