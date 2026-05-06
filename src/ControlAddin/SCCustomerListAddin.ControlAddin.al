controladdin "SC Customer List Addin"
{
    StartupScript = 'src/ControlAddin/js/customers.js';
    HorizontalStretch = true;
    VerticalStretch = true;
    MinimumHeight = 600;
    RequestedHeight = 700;

    event OnReady();
    event OnOpenCustomer(CustomerNo: Text);

    procedure LoadCustomers(Json: Text);
    procedure SetStatus(StatusText: Text);
}
