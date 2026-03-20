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

            trigger OnPreDataItem()
            var
                TempCust: Record Customer;
                SocialCreditMgt: Codeunit "Social Credit Mgt";
                RankText: Text[50];
            begin
                // Pre-compute totals per rank for the KPI boxes
                if TempCust.FindSet() then
                    repeat
                        TotalCustomers += 1;
                        RankText := SocialCreditMgt.GetRank(TempCust."Social Credit Points");
                        case RankText of
                            'Ciudadano Ejemplar': CntEjemplar += 1;
                            'Ciudadano Normal': CntNormal += 1;
                            'Bajo Supervision': CntSup += 1;
                            'Lista Negra': CntNegra += 1;
                        end;
                    until TempCust.Next() = 0;
            end;

            trigger OnAfterGetRecord()
            var
                SocialCreditMgt: Codeunit "Social Credit Mgt";
            begin
                SCRankText := SocialCreditMgt.GetRank("Social Credit Points");
                case SCRankText of
                    'Ciudadano Ejemplar': SCRankColor := '#16a34a';
                    'Ciudadano Normal': SCRankColor := '#2563eb';
                    'Bajo Supervision': SCRankColor := '#d97706';
                    else SCRankColor := '#dc2626';
                end;
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
