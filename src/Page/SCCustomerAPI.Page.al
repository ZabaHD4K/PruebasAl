page 50108 "SC Customer API"
{
    PageType = API;
    APIPublisher = 'arbentia';
    APIGroup = 'socialcredit';
    APIVersion = 'v1.0';
    EntityName = 'customer';
    EntitySetName = 'customers';
    SourceTable = Customer;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = false;
    ODataKeyFields = "No.";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(id; Rec."No.")
                {
                    Caption = 'id';
                }
                field(name; Rec.Name)
                {
                    Caption = 'name';
                }
                field(city; Rec.City)
                {
                    Caption = 'city';
                }
                field(email; Rec."E-Mail")
                {
                    Caption = 'email';
                }
                field(socialCreditPoints; Rec."Social Credit Points")
                {
                    Caption = 'socialCreditPoints';
                }
                field(socialCreditLabel; Rec."Social Credit Label")
                {
                    Caption = 'socialCreditLabel';
                }
                field(socialCreditRank; SocialCreditRank)
                {
                    Caption = 'socialCreditRank';
                }
            }
        }
    }

    var
        SocialCreditRank: Text[50];

    trigger OnAfterGetRecord()
    var
        SocialCreditMgt: Codeunit "Social Credit Mgt";
    begin
        SocialCreditRank := SocialCreditMgt.GetRank(Rec."Social Credit Points");
    end;
}
