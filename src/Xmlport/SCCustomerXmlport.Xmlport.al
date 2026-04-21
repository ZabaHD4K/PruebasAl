xmlport 50100 "SC Customer Xmlport"
{
    Caption = 'Clientes Social Credit';
    Direction = Both;
    Format = Xml;

    schema
    {
        textelement(Customers)
        {
            tableelement(Customer; Customer)
            {
                XmlName = 'Customer';

                fieldelement(No; Customer."No.")
                {
                    XmlName = 'No';
                }
                fieldelement(Name; Customer.Name)
                {
                    XmlName = 'Name';
                }
                fieldelement(City; Customer.City)
                {
                    XmlName = 'City';
                }
                fieldelement(Phone; Customer."Phone No.")
                {
                    XmlName = 'Phone';
                }
                fieldelement(Email; Customer."E-Mail")
                {
                    XmlName = 'Email';
                }
                fieldelement(SocialCreditPoints; Customer."Social Credit Points")
                {
                    XmlName = 'SocialCreditPoints';
                }

                trigger OnBeforeInsertRecord()
                begin
                    // Capturar los puntos del XML antes de insertar con 0
                    ImportedPoints := Customer."Social Credit Points";
                    Customer."Social Credit Points" := 0;
                    Customer."Social Credit Label" := SocialCreditMgt.GetLabel(0);
                end;

                trigger OnAfterInsertRecord()
                begin
                    // Aplicar puntos vía AdjustCustomerPoints para garantizar el log de auditoría
                    if ImportedPoints < 0 then
                        ImportedPoints := 1000;
                    if ImportedPoints <> 0 then
                        SocialCreditMgt.AdjustCustomerPoints(Customer."No.", ImportedPoints, 'Importación XML');
                end;

                trigger OnBeforeModifyRecord()
                var
                    DbCustomer: Record Customer;
                begin
                    // Guardar los puntos del XML y restaurar el valor actual de BD
                    // para que Modify no bypasee AdjustCustomerPoints
                    ImportedPoints := Customer."Social Credit Points";
                    DbCustomer.SetLoadFields("Social Credit Points", "Social Credit Label");
                    if DbCustomer.Get(Customer."No.") then begin
                        OriginalPoints := DbCustomer."Social Credit Points";
                        Customer."Social Credit Points" := OriginalPoints;
                        Customer."Social Credit Label" := DbCustomer."Social Credit Label";
                    end else
                        OriginalPoints := 0;
                end;

                trigger OnAfterModifyRecord()
                var
                    Delta: Integer;
                begin
                    if ImportedPoints < 0 then
                        ImportedPoints := 1000;
                    Delta := ImportedPoints - OriginalPoints;
                    if Delta <> 0 then
                        SocialCreditMgt.AdjustCustomerPoints(Customer."No.", Delta, 'Importación XML');
                end;
            }
        }
    }

    var
        SocialCreditMgt: Codeunit "Social Credit Mgt";
        ImportedPoints: Integer;
        OriginalPoints: Integer;
}
