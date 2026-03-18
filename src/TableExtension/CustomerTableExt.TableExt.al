tableextension 50100 "Customer Social Credit Ext" extends Customer
{
    fields
    {
        field(50100; "Social Credit Points"; Integer)
        {
            Caption = 'Social Credit Points';
            DataClassification = CustomerContent;
            InitValue = 1000;
            MinValue = 0;

            trigger OnValidate()
            begin
                UpdateSocialCreditLabel();
            end;
        }
        field(50101; "Social Credit Label"; Text[50])
        {
            Caption = 'Social Credit';
            DataClassification = CustomerContent;
            Editable = false;
        }
    }

    keys
    {
        key(SocialCreditKey; "Social Credit Points") { }
    }

    fieldgroups
    {
        addlast(Brick; "Social Credit Label") { }
        addlast(DropDown; "Social Credit Label") { }
    }

    trigger OnAfterInsert()
    begin
        UpdateSocialCreditLabel();
    end;

    trigger OnAfterModify()
    begin
        UpdateSocialCreditLabel();
    end;

    local procedure UpdateSocialCreditLabel()
    var
        SocialCreditMgt: Codeunit "Social Credit Mgt";
    begin
        "Social Credit Label" := SocialCreditMgt.GetLabel("Social Credit Points");
    end;
}
