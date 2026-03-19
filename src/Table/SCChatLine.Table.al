table 50111 "SC Chat Line"
{
    Caption = 'SC Chat Line';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            DataClassification = SystemMetadata;
            AutoIncrement = true;
        }
        field(2; "Session ID"; Guid)
        {
            Caption = 'Session ID';
            DataClassification = SystemMetadata;
        }
        field(3; "Role"; Option)
        {
            Caption = 'Role';
            DataClassification = CustomerContent;
            OptionMembers = User,Assistant,System;
            OptionCaption = 'Usuario,Asistente,Sistema';
        }
        field(4; "Message"; Blob)
        {
            Caption = 'Message';
            DataClassification = CustomerContent;
        }
        field(5; "Message Text"; Text[2048])
        {
            Caption = 'Message Text';
            DataClassification = CustomerContent;
        }
        field(6; "Message DateTime"; DateTime)
        {
            Caption = 'Message DateTime';
            DataClassification = CustomerContent;
        }
        field(7; "User ID"; Code[50])
        {
            Caption = 'User ID';
            DataClassification = EndUserIdentifiableInformation;
        }
    }

    keys
    {
        key(PK; "Entry No.") { Clustered = true; }
        key(Session; "Session ID", "Message DateTime") { }
    }
}
