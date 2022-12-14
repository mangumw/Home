USE [Staging]
GO
/****** Object:  StoredProcedure [dbo].[usp_build_Key5_Capacity]    Script Date: 8/19/2022 3:41:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE Procedure [dbo].[usp_build_Key5_Capacity] AS

truncate table staging.dbo.lesliekey5

insert into staging.dbo.lesliekey5

SELECT     Reference.dbo.INVBAL.Store_Number AS Expr1, SUM(Reference.dbo.INVBAL.On_Hand) AS units, 

                      SUM(Reference.dbo.Item_Master.POS_Price * Reference.dbo.INVBAL.On_Hand) AS dollars

FROM         Reference.dbo.Item_Master INNER JOIN

                      Reference.dbo.INVBAL ON Reference.dbo.Item_Master.SKU_Number = Reference.dbo.INVBAL.sku_number

WHERE     (Reference.dbo.Item_Master.Dept = 5)

GROUP BY Reference.dbo.INVBAL.Store_Number

 

truncate table staging.dbo.lesliekey5a

insert into staging.dbo.lesliekey5a

 

SELECT     Reference.dbo.Key_5_capacity.store_number, Reference.dbo.Key_5_capacity.STORE_NAME, Reference.dbo.Key_5_capacity.Capacity, 

                      Reference.dbo.Key_5_capacity.Dollars, Staging.dbo.lesliekey5.Expr3 AS OH_units, Staging.dbo.lesliekey5.Expr2 AS OH_dollars

FROM         Reference.dbo.Key_5_capacity INNER JOIN

                      Staging.dbo.lesliekey5 ON Reference.dbo.Key_5_capacity.store_number = Staging.dbo.lesliekey5.Expr1

 

truncate table staging.dbo.lesliekey5b

insert into staging.dbo.lesliekey5b

 

SELECT     DssData.dbo.Weekly_Sales.Store_Number, SUM(DssData.dbo.Weekly_Sales.Current_Dollars) AS YTD_sls

FROM         DssData.dbo.Weekly_Sales INNER JOIN

                      Reference.dbo.Item_Master ON DssData.dbo.Weekly_Sales.Sku_Number = Reference.dbo.Item_Master.SKU_Number

WHERE     (DssData.dbo.Weekly_Sales.Day_Date > CONVERT(DATETIME, '2012-01-28 00:00:00', 102)) AND (Reference.dbo.Item_Master.Dept = 5)

GROUP BY DssData.dbo.Weekly_Sales.Store_Number

 

SELECT     Staging.dbo.lesliekey5a.store_number, Staging.dbo.lesliekey5a.STORE_NAME, Staging.dbo.lesliekey5a.Capacity, Staging.dbo.lesliekey5a.Dollars, 

                      Staging.dbo.lesliekey5a.OH_units, Staging.dbo.lesliekey5a.OH_dollars, Staging.dbo.lesliekey5b.YTD_sls

FROM         Staging.dbo.lesliekey5a INNER JOIN

                      Staging.dbo.lesliekey5b ON Staging.dbo.lesliekey5a.store_number = Staging.dbo.lesliekey5b.Store_Number

 
GO
