page 50120 "Snake"
{
    PageType = Card;
    Caption = 'Snake';
    ApplicationArea = All;
    UsageCategory = Tasks;

    layout
    {
        area(Content)
        {
            usercontrol(SnakeCtrl; "Snake Addin")
            {
                ApplicationArea = All;
            }
        }
    }
}
