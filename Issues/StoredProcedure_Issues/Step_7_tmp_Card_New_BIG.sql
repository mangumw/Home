truncate table Staging.dbo.tmp_CARD_New
--
--
insert into Staging.dbo.tmp_CARD_new
(
	   [ISBN]
      ,[SKU]
      ,[EAN]
      ,[DW_ISBN]
      ,[Title]
      ,[Status]
      ,[Pub_Code]
      ,[Publisher]
      ,[VIN]
      ,[Author]
      ,[Returnable]
      ,[Disposition]
      ,[Sr_Buyer]
      ,[Buyer]
      ,[Buyer_Number]
      ,[Dept]
      ,[Dept_Name]
      ,[SDept]
      ,[SDept_Name]
      ,[Class]
      ,[Class_Name]
      ,[SClass]
      ,[SClass_Name]
      ,[Module]
      ,[Sku_Type]
      ,[Subject]
      ,[Strength]
      ,[Bookscan_Rank]
      ,[Internet_Rank]
      ,[BAM_WOS]
      ,[AWBC_WOS]
      ,[Sell_Thru]
      ,[DWCost]
      ,[Retail]
      ,[Coordinate_Group]
      ,[Season]
      ,[IDate]
      ,[ExpReceiptDate]
      ,[Store_Min]
      ,[Min_Qty]
      ,[Max_Qty]
      ,[Expr1]
      ,[BAM_OnHand]
      ,[BAM_OnOrder]
      ,[Warehouse_OnHand]
      ,[ReturnCenter_OnHand]
      ,[Qty_OnOrder]
      ,[Qty_OnBackorder]
      ,[InTransit]
      ,[Total_OnHand]
      ,[NumStocked]
      ,[Week1Units]
      ,[Week1Dollars]
      ,[Week2Units]
      ,[Week2dollars]
      ,[week3units]
      ,[week3dollars]
      ,[dcweek1units]
      ,[dcweek1dollars]
      ,[dcweek2units]
      ,[dcweek2dollars]
      ,[dcweek3units]
      ,[dcweek3dollars]
      ,[lyweek1units]
      ,[lyweek1dollars]
      ,[lyweek2units]
      ,[lyweek2dollars]
      ,[lyweek3units]
      ,[lyweek3dollars]
      ,[lydcweek1units]
      ,[lydcweek1dollars]
      ,[lydcweek2units]
      ,[lydcweek2dollars]
      ,[lydcweek3units]
      ,[lydcweek3dollars]
      ,[TYYTDUnits]
      ,[TYYTDDollars]
      ,[LYYTDUnits]
      ,[LYYTDDollars]
      ,[DCTYYTDUnits]
      ,[DCTYYTDDollars]
      ,[DCLYYTDUnits]
      ,[DCLYYTDDollars]
      ,[Week13units]
      ,[week13dollars]
      ,[dcweek13units]
      ,[dcweek13dollars]
      ,[wtd_units]
      ,[wtd_dollars]
      ,[DCwtd_units]
      ,[DCwtd_dollars]
      ,[ltd_units]
      ,[ltd_dollars]
      ,[dcltd_units]
      ,[dcltd_dollars]
      ,[Warehouse_ID]
      ,[Expr2]
      ,[Expr3]
      ,[Load_Date]
      ,[Condition]
)
SELECT     t1.ISBN, t1.Sku_Number AS SKU, t1.EAN, t1.DW_ISBN, t1.Title, t1.Status, t1.Pub_Code, t1.Publisher, t1.VIN, t1.Author, t1.Returnable, t1.Disposition, t1.Sr_Buyer, 
                      t1.Buyer, t1.Buyer_Number, t1.Dept, t1.Dept_Name, t1.SDept, t1.SDept_Name, t1.Class, t1.Class_Name, t1.SClass, t1.SClass_Name, t1.Module, t1.Sku_Type, 
                      t1.Subject, t1.Strength, 0 AS Bookscan_Rank, 0 AS Internet_Rank, NULL AS BAM_WOS, NULL AS AWBC_WOS, CASE WHEN t3.Week1Units > 0 AND 
                      t4.BAM_OnHand > 0 AND t3.Week1Units > 0 THEN isnull(t3.Week1Units / nullif((t3.Week1Units + t4.BAM_OnHand),0),0) ELSE 0 END AS Sell_Thru, t1.DWCost, t1.Retail, 
                      t1.Coordinate_Group, t1.Season, t1.IDate, t1.ExpReceiptDate, t4.Store_Min, t1.Min_Qty, t1.Max_Qty, ISNULL(t8.IBCSQT, 0) AS Expr1, t4.BAM_OnHand, 
                      t4.BAM_OnOrder, t4.Warehouse_OnHand, t4.ReturnCenter_OnHand, t4.Qty_OnOrder, t4.Qty_OnBackorder, t4.InTransit, t4.Total_OnHand, NULL AS NumStocked, 
                      ISNULL(t3.WEEK1UNITS, 0) AS Week1Units, ISNULL(t3.WEEK1DOLLARS, 0) AS Week1Dollars, ISNULL(t3.WEEK2UNITS, 0) AS Week2Units, ISNULL(t3.WEEK2Dollars, 
                      0) AS Week2dollars, ISNULL(t3.WEEK3UNITS, 0) AS week3units, ISNULL(t3.WEEK3Dollars, 0) AS week3dollars, ISNULL(t3.DCWeek1Units, 0) AS dcweek1units, 
                      ISNULL(t3.DCWeek1Dollars, 0) AS dcweek1dollars, ISNULL(t3.DCWeek2Units, 0) AS dcweek2units, ISNULL(t3.DCWeek2Dollars, 0) AS dcweek2dollars, 
                      ISNULL(t3.DCWeek3Units, 0) AS dcweek3units, ISNULL(t3.DCWeek3Dollars, 0) AS dcweek3dollars, ISNULL(t3.LYWEEK1UNITS, 0) AS lyweek1units, 
                      ISNULL(t3.LYWEEK1Dollars, 0) AS lyweek1dollars, ISNULL(t3.LYWEEK2UNITS, 0) AS lyweek2units, ISNULL(t3.LYWEEK2Dollars, 0) AS lyweek2dollars, 
                      ISNULL(t3.LYWEEK3UNITS, 0) AS lyweek3units, ISNULL(t3.LYWEEK3Dollars, 0) AS lyweek3dollars, ISNULL(t3.LYDCWeek1Units, 0) AS lydcweek1units, 
                      ISNULL(t3.LYDCWeek1Dollars, 0) AS lydcweek1dollars, ISNULL(t3.LYDCWeek2Units, 0) AS lydcweek2units, ISNULL(t3.LYDCWeek2Dollars, 0) AS lydcweek2dollars, 
                      ISNULL(t3.LYDCWeek3Units, 0) AS lydcweek3units, ISNULL(t3.LYDCWeek3Dollars, 0) AS lydcweek3dollars, ISNULL(t3.TYYTDUNITS, 0) AS TYYTDUnits, 
                      ISNULL(t3.TYYTDDOLLARS, 0) AS TYYTDDollars, ISNULL(t3.LYYTDUNITS, 0) AS LYYTDUnits, ISNULL(t3.LYYTDDOLLARS, 0) AS LYYTDDollars, 
                      ISNULL(t3.DCTYYTDUNITS, 0) AS DCTYYTDUnits, ISNULL(t3.DCTYYTDDOLLARS, 0) AS DCTYYTDDollars, ISNULL(t3.DCLYYTDUNITS, 0) AS DCLYYTDUnits, 
                      ISNULL(t3.DCLYYTDDOLLARS, 0) AS DCLYYTDDollars, ISNULL(t3.Week13Units, 0) AS Week13units, ISNULL(t3.Week13Dollars, 0) AS week13dollars, 
                      ISNULL(t3.DCWeek13Units, 0) AS dcweek13units, ISNULL(t3.DCWeek13Dollars, 0) AS dcweek13dollars, ISNULL(t5.WTD_Units, 0) AS wtd_units, 
                      ISNULL(t5.WTD_Dollars, 0) AS wtd_dollars, ISNULL(t9.DCWTD_Units, 0) AS DCwtd_units, ISNULL(t9.DCWTD_Dollars, 0) AS DCwtd_dollars, ISNULL(t6.LTD_Units, 0) 
                      AS ltd_units, ISNULL(t6.LTD_Dollars, 0) AS ltd_dollars, ISNULL(t7.DCLTD_Units, 0) AS dcltd_units, ISNULL(t7.DCLTD_Dollars, 0) AS dcltd_dollars, t4.Warehouse_ID, 
                      '' AS Expr2, '' AS Expr3, GETDATE() AS Load_Date, t1.Condition
FROM	[Staging].[dbo].[wrk_Card_Descriptive] AS t1 LEFT OUTER JOIN
        [DssData].[dbo].Three_Week_Sales AS t3 ON t3.SKU_NUMBER = t1.Sku_Number LEFT OUTER JOIN
        [Staging].[dbo].wrk_Card_Inventory AS t4 ON t4.sku_number = t1.Sku_Number LEFT OUTER JOIN
        [Staging].[dbo].wrk_Card_WTD AS t5 ON t5.sku_number = t1.Sku_Number LEFT OUTER JOIN
        [Staging].[dbo].wrk_card_ltd AS t6 ON t6.sku_number = t1.Sku_Number LEFT OUTER JOIN
        [Staging].[dbo].wrk_Card_DCLTD AS t7 ON t7.sku_number = t1.Sku_Number LEFT OUTER JOIN
        [Reference].[dbo].ITWHM AS t8 ON t8.IBITNO = t1.Sku_Text LEFT OUTER JOIN
        [Staging].[dbo].wrk_Card_DCWTD AS t9 ON t9.sku_number = t1.Sku_Number