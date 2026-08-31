section Section1;

shared dimension_customer_DataDestination = let
    Source = Lakehouse.Contents([CreateNavigationProperties = false, EnableFolding = false]),
    Navigation1 = Source{[workspaceId = "cb1694d4-24e2-49b6-ae61-91f0fcd1f0da"]}[Data],
    Navigation2 = Navigation1{[lakehouseId = "b42ce291-ce0a-40c8-83b4-0f423ac53d97"]}[Data],
    Navigation3 = Navigation2{[Id = "dimension_customer", ItemKind = "Table"]}[Data]
in
    Navigation3;

[DataDestinations = {[Definition = [Kind = "Reference", QueryName = "dimension_customer_DataDestination", IsNewTarget = true], Settings = [Kind = "Automatic", TypeSettings = [Kind = "Table"]]]}]
shared dimension_customer = let
    Source = Csv.Document(Web.Contents("https://raw.githubusercontent.com/microsoft/fabric-samples/main/docs-samples/data-engineering/dimension_customer.csv"), [Delimiter = ",", Columns = 11, Encoding = 65001, QuoteStyle = QuoteStyle.Csv]),
    PromoteHeaders = Table.PromoteHeaders(Source, [PromoteAllScalars = true]),
    Typed = Table.TransformColumnTypes(PromoteHeaders, {
        {"CustomerKey", Int64.Type},
        {"WWICustomerID", Int64.Type},
        {"LineageKey", Int64.Type},
        {"Customer", type nullable text},
        {"BillToCustomer", type nullable text},
        {"Category", type nullable text},
        {"BuyingGroup", type nullable text},
        {"PrimaryContact", type nullable text},
        {"PostalCode", type nullable text},
        {"ValidFrom", type nullable datetime},
        {"ValidTo", type nullable datetime}
    })
in
    Typed;