page 50113 "Extension SC"
{
    PageType = Card;
    Caption = 'Social Credit - Centro de extensión';
    ApplicationArea = All;
    UsageCategory = Administration;

    layout
    {
        area(Content)
        {
            usercontrol(HubAddin; "SC Hub Addin")
            {
                ApplicationArea = All;

                trigger OnReady()
                begin
                end;

                trigger OnNavigate(Target: Text)
                begin
                    case Target of
                        'adjust':       Page.Run(50101);
                        'history':      Page.Run(50102);
                        'report':       Page.Run(50105);
                        'customers':    Page.Run(50105);
                        'chat':         Page.Run(50111);
                        'slider':       Page.Run(50114);
                        'polymarket':   Page.Run(50118);
                        'importexport': Page.Run(50119);
                        'snake':        Page.Run(50120);
                        'pysnake':      Page.Run(50122);
                        'ej1task':      Page.Run(50123);
                        'spaceinvaders': Page.Run(50124);
                        'ej2lista':     Page.Run(50127);
                        'ej7lista':     Page.Run(50128);
                        'customerlist': Page.Run(22);
                        'customercard': Page.Run(21);
                        'salesorder':   Page.Run(9305);
                        'salesquote':   Page.Run(9300);
                        'salesinvoice': Page.Run(9301);
                        'salescrmemo':  Page.Run(9302);
                        'vendors':      Page.Run(27);
                        'items':        Page.Run(31);
                    end;
                end;
            }
        }
    }
}
