report 50100 "SC Informe Social Credit"
{
    Caption = 'Informe Social Credit';
    ApplicationArea = All;
    UsageCategory = ReportsAndAnalysis;
    DefaultLayout = RDLC;
    RDLCLayout = 'src/Report/SocialCreditLayout.rdlc';

    dataset
    {
        dataitem(Customer; Customer)
        {
            DataItemTableView = sorting("Social Credit Points") order(descending);

            column(CustNo; "No.") { }
            column(CustName; Name) { }
            column(SCPoints; "Social Credit Points") { }
            column(SCRank; SCRankText) { }
            column(RankColor; SCRankColor) { }
            column(TotalCount; TotalCustomers) { }
            column(CountEjemplar; CntEjemplar) { }
            column(CountNormal; CntNormal) { }
            column(CountSup; CntSup) { }
            column(CountNegra; CntNegra) { }

            trigger OnAfterGetRecord()
            var
                SocialCreditMgt: Codeunit "Social Credit Mgt";
            begin
                SCRankText := SocialCreditMgt.GetRank("Social Credit Points");
                case SCRankText of
                    'Ciudadano Ejemplar': begin SCRankColor := '#16a34a'; CntEjemplar += 1; end;
                    'Ciudadano Normal':   begin SCRankColor := '#2563eb'; CntNormal += 1; end;
                    'Bajo Supervision':  begin SCRankColor := '#d97706'; CntSup += 1; end;
                    else                 begin SCRankColor := '#dc2626'; CntNegra += 1; end;
                end;
                TotalCustomers += 1;
            end;
        }
    }

    var
        SCRankText: Text[50];
        SCRankColor: Text[20];
        TotalCustomers: Integer;
        CntEjemplar: Integer;
        CntNormal: Integer;
        CntSup: Integer;
        CntNegra: Integer;
}
