Select cast(pub_code as nvarchar(255)) as Pub_Group
, cast (ISBN as NVARCHAR(255)) as ISBN
, cast (Sku_Number as NVARCHAR(255)) as Sku_Number
,cast(Title as NVARCHAR(255)) as Title
, cast(Author as NVARCHAR(255)) AS Author
, CAST(Sku_Type AS nvarchar(255)) AS Sku_Type
, IDate
, Retail
,Week1Units+DCWeek1Units as Week1Units
,Week2Units+DCWeek2Units as Week2Units
,TYYTDUnits + DCTYYTDUnits as YTD_Units
,BAM_OnHand
,Warehouse_OnHand,Qty_OnOrder from DssData.dbo.CARD