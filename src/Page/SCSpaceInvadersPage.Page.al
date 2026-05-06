page 50124 "SC Space Invaders"
{
    PageType = Card;
    Caption = 'Space Invaders';
    ApplicationArea = All;
    UsageCategory = Tasks;

    layout
    {
        area(Content)
        {
            usercontrol(SpaceInvadersCtrl; "SC Space Invaders Addin")
            {
                ApplicationArea = All;
            }
        }
    }
}
