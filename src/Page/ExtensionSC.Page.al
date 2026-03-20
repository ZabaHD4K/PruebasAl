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
            group(SocialCreditPages)
            {
                Caption = 'Páginas de Social Credit';
                label(LblAdjust)
                {
                    ApplicationArea = All;
                    Caption = 'Ajustar puntos de Social Credit a un cliente.';
                }
                label(LblHistory)
                {
                    ApplicationArea = All;
                    Caption = 'Historial de cambios de puntos por cliente.';
                }
                label(LblReport)
                {
                    ApplicationArea = All;
                    Caption = 'Informe general de puntuaciones de clientes.';
                }
                label(LblChat)
                {
                    ApplicationArea = All;
                    Caption = 'Chatbot con IA para consultas de Social Credit.';
                }
                label(LblSlider)
                {
                    ApplicationArea = All;
                    Caption = 'Ajuste interactivo de puntos mediante un slider JavaScript dinámico.';
                }
            }
            group(ModifiedPages)
            {
                Caption = 'Páginas de BC modificadas por la extensión';
                label(LblCustomerList)
                {
                    ApplicationArea = All;
                    Caption = 'Lista de clientes — columna de puntos y estado SC añadidos.';
                }
                label(LblCustomerCard)
                {
                    ApplicationArea = All;
                    Caption = 'Ficha de cliente — FactBox y acciones SC añadidas.';
                }
                label(LblSalesOrder)
                {
                    ApplicationArea = All;
                    Caption = 'Pedido de venta — validación SC al seleccionar cliente.';
                }
                label(LblSalesQuote)
                {
                    ApplicationArea = All;
                    Caption = 'Oferta de venta — validación SC al seleccionar cliente.';
                }
                label(LblSalesInvoice)
                {
                    ApplicationArea = All;
                    Caption = 'Factura de venta — validación SC al seleccionar cliente.';
                }
                label(LblSalesCrMemo)
                {
                    ApplicationArea = All;
                    Caption = 'Abono de venta — validación SC al seleccionar cliente.';
                }
                label(LblVendorList)
                {
                    ApplicationArea = All;
                    Caption = 'Lista de proveedores — acción de exportación añadida.';
                }
                label(LblItemList)
                {
                    ApplicationArea = All;
                    Caption = 'Lista de productos — acción de exportación añadida.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            group(SCActions)
            {
                Caption = 'Social Credit';
                Image = SocialNetwork;
                action(AjustarPuntos)
                {
                    ApplicationArea = All;
                    Caption = 'Ajustar puntos';
                    Image = Adjust;
                    ToolTip = 'Abre la página para ajustar manualmente los puntos de Social Credit de un cliente.';
                    RunObject = page "Social Credit Adjust";
                }
                action(Historial)
                {
                    ApplicationArea = All;
                    Caption = 'Historial de cambios';
                    Image = History;
                    ToolTip = 'Abre el historial de todos los cambios de puntos de Social Credit.';
                    RunObject = page "Social Credit History";
                }
                action(Informe)
                {
                    ApplicationArea = All;
                    Caption = 'Informe de puntuaciones';
                    Image = Report;
                    ToolTip = 'Abre el informe general de puntuaciones de Social Credit.';
                    RunObject = page "Social Credit Report";
                }
                action(Chat)
                {
                    ApplicationArea = All;
                    Caption = 'Chat IA';
                    Image = Comment;
                    ToolTip = 'Abre el chatbot con IA para consultas de Social Credit.';
                    RunObject = page "SC Chat";
                }
                action(Slider)
                {
                    ApplicationArea = All;
                    Caption = 'Slider de puntos';
                    Image = Slider;
                    ToolTip = 'Ajusta los puntos de Social Credit de un cliente con un slider interactivo. Se guarda automáticamente al mover.';
                    RunObject = page "SC Slider";
                }
            }
            group(BCModifiedActions)
            {
                Caption = 'Páginas de BC modificadas';
                Image = Setup;
                action(Clientes)
                {
                    ApplicationArea = All;
                    Caption = 'Lista de clientes';
                    Image = Customer;
                    ToolTip = 'Abre la lista de clientes con las columnas de Social Credit.';
                    RunObject = page "Customer List";
                }
                action(FichaCliente)
                {
                    ApplicationArea = All;
                    Caption = 'Ficha de cliente';
                    Image = Customer;
                    ToolTip = 'Abre la ficha de cliente con el FactBox de Social Credit.';
                    RunObject = page "Customer Card";
                }
                action(PedidoVenta)
                {
                    ApplicationArea = All;
                    Caption = 'Pedidos de venta';
                    Image = Order;
                    ToolTip = 'Abre los pedidos de venta con validación de Social Credit.';
                    RunObject = page "Sales Order List";
                }
                action(OfertaVenta)
                {
                    ApplicationArea = All;
                    Caption = 'Ofertas de venta';
                    Image = Quote;
                    ToolTip = 'Abre las ofertas de venta con validación de Social Credit.';
                    RunObject = page "Sales Quotes";
                }
                action(FacturaVenta)
                {
                    ApplicationArea = All;
                    Caption = 'Facturas de venta';
                    Image = Invoice;
                    ToolTip = 'Abre las facturas de venta con validación de Social Credit.';
                    RunObject = page "Sales Invoice List";
                }
                action(AbonoVenta)
                {
                    ApplicationArea = All;
                    Caption = 'Abonos de venta';
                    Image = CreditMemo;
                    ToolTip = 'Abre los abonos de venta con validación de Social Credit.';
                    RunObject = page "Sales Credit Memos";
                }
                action(Proveedores)
                {
                    ApplicationArea = All;
                    Caption = 'Lista de proveedores';
                    Image = Vendor;
                    ToolTip = 'Abre la lista de proveedores con la acción de exportación.';
                    RunObject = page "Vendor List";
                }
                action(Productos)
                {
                    ApplicationArea = All;
                    Caption = 'Lista de productos';
                    Image = Item;
                    ToolTip = 'Abre la lista de productos con la acción de exportación.';
                    RunObject = page "Item List";
                }
            }
        }
        area(Promoted)
        {
            group(PromotedSC)
            {
                Caption = 'Social Credit';
                actionref(AjustarPuntosRef; AjustarPuntos) { }
                actionref(HistorialRef; Historial) { }
                actionref(InformeRef; Informe) { }
                actionref(ChatRef; Chat) { }
                actionref(SliderRef; Slider) { }
            }
            group(PromotedBC)
            {
                Caption = 'BC Modificadas';
                actionref(ClientesRef; Clientes) { }
                actionref(FichaClienteRef; FichaCliente) { }
                actionref(PedidoVentaRef; PedidoVenta) { }
                actionref(OfertaVentaRef; OfertaVenta) { }
                actionref(FacturaVentaRef; FacturaVenta) { }
                actionref(AbonoVentaRef; AbonoVenta) { }
                actionref(ProveedoresRef; Proveedores) { }
                actionref(ProductosRef; Productos) { }
            }
        }
    }
}
