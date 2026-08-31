[StagingDefinition = [Kind = "FastCopy"]]
section Section1;
[DataDestinations = {[Definition = [Kind = "Reference", QueryName = "dimension_customer csv_DataDestination", IsNewTarget = true], Settings = [Kind = "Automatic", TypeSettings = [Kind = "Table"]]]}]
shared #"dimension_customer csv" = let
  Source = Lakehouse.Contents(null),
  Navigation = Source{[workspaceId = "cb1694d4-24e2-49b6-ae61-91f0fcd1f0da"]}[Data],
  #"Navigation 1" = Navigation{[lakehouseId = "b42ce291-ce0a-40c8-83b4-0f423ac53d97"]}[Data],
  #"Navigation 2" = #"Navigation 1"{[Id = "Files", ItemKind = "Folder"]}[Data],
  #"Navigation 3" = #"Navigation 2"{[Name = "dimension_customer.csv"]}[Content],
  #"Imported CSV" = Csv.Document(#"Navigation 3", [Delimiter = ",", Columns = 11, Encoding = 65001, QuoteStyle = QuoteStyle.None])
in
  #"Imported CSV";
shared #"dimension_customer csv_DataDestination" = let
  Pattern = Lakehouse.Contents([CreateNavigationProperties = false, EnableFolding = false, HierarchicalNavigation = true, EnableVorder = true, OutputMetadataRefresh = true]),
  Navigation_1 = Pattern{[workspaceId = "cb1694d4-24e2-49b6-ae61-91f0fcd1f0da"]}[Data],
  Navigation_2 = Navigation_1{[lakehouseId = "b42ce291-ce0a-40c8-83b4-0f423ac53d97"]}[Data],
  Navigation_3 = Navigation_2{[Id = "dbo", ItemKind = "Schema"]}[Data],
  TableNavigation = Navigation_3{[Id = "dim_customer", ItemKind = "Table"]}?[Data]?
in
  TableNavigation;
