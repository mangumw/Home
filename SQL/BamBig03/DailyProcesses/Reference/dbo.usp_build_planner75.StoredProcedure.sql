USE [Reference]
GO
/****** Object:  StoredProcedure [dbo].[usp_build_planner75]    Script Date: 8/19/2022 3:46:15 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE Procedure [dbo].[usp_build_planner75]

As


TRUNCATE TABLE staging.dbo.plan1
INSERT INTO staging.dbo.plan1
SELECT     Staging.dbo.planner75.SKU, Staging.dbo.planner75.Planner, Item_Master.SKU_Number, DssData.dbo.Weekly_Sales.Day_Date, 
                      Item_Master.SKU_Type, Item_Master.Title, Item_Master.Author, DssData.dbo.CARD.DWCost, Item_Master.POS_Price, 
                      DssData.dbo.CARD.Warehouse_OnHand, DssData.dbo.CARD.Qty_OnOrder, SUM(DssData.dbo.Weekly_Sales.Current_Units) AS TY_WK_UNITS, 
                      SUM(DssData.dbo.Weekly_Sales.Current_Dollars) AS TY_WK_Dollar, SUM(DssData.dbo.CARD.TYYTDUnits) AS TY_YTD_UNITS, 
                      SUM(DssData.dbo.CARD.TYYTDDollars) AS TY_YTD_Dollars, SUM(DssData.dbo.CARD.LYYTDUnits) AS LY_YTD_UNITS, 
                      SUM(DssData.dbo.CARD.LYYTDDollars) AS LY_YTD_DOLLARS
FROM         Staging.dbo.planner75 INNER JOIN
                      DssData.dbo.CARD ON Staging.dbo.planner75.[SKU ] = DssData.dbo.CARD.Sku_Number INNER JOIN
                      Item_Master ON Staging.dbo.planner75.[SKU ] = Item_Master.SKU_Number INNER JOIN
                      DssData.dbo.Weekly_Sales ON Staging.dbo.planner75.[SKU ] = DssData.dbo.Weekly_Sales.Sku_Number
WHERE     (DssData.dbo.Weekly_Sales.Day_Date = Staging.dbo.fn_Last_Saturday(GETDATE()))
GROUP BY Staging.dbo.planner75.SKU, Staging.dbo.planner75.Planner, DssData.dbo.Weekly_Sales.Day_Date, Item_Master.SKU_Type, Item_Master.Title, 
                      Item_Master.Author, Item_Master.POS_Price, Item_Master.SKU_Number, DssData.dbo.CARD.Warehouse_OnHand, DssData.dbo.CARD.Qty_OnOrder, 
                      DssData.dbo.CARD.DWCost
----
TRUNCATE TABLE staging.dbo.plan2

INSERT INTO staging.dbo.plan2

SELECT     staging.dbo.planner75.Sku, Staging.dbo.planner75.Planner, Item_Master.SKU_Number, SUM(DssData.dbo.Weekly_Sales.Current_Units) 
                      AS LY_WK_Units, SUM(DssData.dbo.Weekly_Sales.Current_Dollars) AS LY_WK_Dollar
FROM         Staging.dbo.planner75 INNER JOIN
                      Item_Master ON staging.dbo.planner75.Sku = Item_Master.SKU_Number INNER JOIN
                      DssData.dbo.Weekly_Sales ON staging.dbo.planner75.Sku = DssData.dbo.Weekly_Sales.Sku_Number
WHERE     (DssData.dbo.Weekly_Sales.Day_Date = Staging.dbo.fn_Last_Saturday(DATEADD(yy, - 1, GETDATE())))
GROUP BY staging.dbo.planner75.Sku, Staging.dbo.planner75.Planner, Item_Master.SKU_Number
ORDER BY Staging.dbo.planner75.Planner, LY_WK_Dollar DESC
----

declare @Fiscal_Quarter varchar(8)

declare @TYQS smalldatetime 
select @fiscal_Quarter = Fiscal_Quarter from reference.dbo.Calendar_Dim where day_date = staging.dbo.fn_DateOnly(getdate())

select @TYQS = min(day_date) from reference.dbo.Calendar_Dim where fiscal_quarter = @fiscal_quarter

TRUNCATE TABLE staging.dbo.plan3

INSERT INTO staging.dbo.plan3
SELECT     staging.dbo.planner75.Sku, Staging.dbo.planner75.Planner, Item_Master.SKU_Number, SUM(DssData.dbo.Weekly_Sales.Current_Dollars) 
                      AS TY_QTD_Dollar, SUM(DssData.dbo.Weekly_Sales.Current_Units) AS TY_QTD_Units
FROM         Staging.dbo.planner75 INNER JOIN
                      Item_Master ON staging.dbo.planner75.Sku = Item_Master.SKU_Number INNER JOIN
                      DssData.dbo.Weekly_Sales ON staging.dbo.planner75.Sku = DssData.dbo.Weekly_Sales.Sku_Number
WHERE     (DssData.dbo.Weekly_Sales.Day_Date >= @TYQS)
GROUP BY staging.dbo.planner75.Sku, Staging.dbo.planner75.Planner, Item_Master.SKU_Number
ORDER BY Staging.dbo.planner75.Planner, TY_QTD_Dollar DESC

declare @Fiscal_Quarter2 varchar(8)

declare @TYQS2 smalldatetime

select @fiscal_Quarter2 = staging.dbo.fn_LastQuarter(dateadd(yy,-1,getdate()))

select @TYQS2 = min(day_date) from reference.dbo.Calendar_Dim where fiscal_quarter = @fiscal_quarter2
TRUNCATE TABLE staging.dbo.plan5
INSERT INTO staging.dbo.plan5
SELECT     staging.dbo.planner75.Sku, Staging.dbo.planner75.Planner, Item_Master.SKU_Number, SUM(DssData.dbo.Weekly_Sales.Current_Dollars) 
                      AS LY_QTD_Dollar, SUM(DssData.dbo.Weekly_Sales.Current_Units) AS LY_QTD_Units
FROM         Staging.dbo.planner75 INNER JOIN
                      Item_Master ON staging.dbo.planner75.Sku = Item_Master.SKU_Number INNER JOIN
                      DssData.dbo.Weekly_Sales ON staging.dbo.planner75.Sku = DssData.dbo.Weekly_Sales.Sku_Number
WHERE     (DssData.dbo.Weekly_Sales.Day_Date >= @TYQS2) AND (DssData.dbo.Weekly_Sales.Day_Date <= DATEADD(yy, - 1, GETDATE()))
GROUP BY staging.dbo.planner75.Sku, Staging.dbo.planner75.Planner, Item_Master.SKU_Number

ORDER BY staging.dbo.planner75.Planner, LY_QTD_Dollar DESC

----

declare @ZZZ smalldatetime

select @ZZZ = dateadd(dd,1,staging.dbo.fn_Last_Saturday(dateadd(yy,-1,getdate())))

TRUNCATE TABLE staging.dbo.inv_ly_plan
INSERT INTO staging.dbo.inv_ly_plan
SELECT     DssData.dbo.CARD_History.sku_number, DssData.dbo.CARD_History.Retail, DssData.dbo.CARD_History.Total_OnHand AS LY_ON_HAND, 
                      DssData.dbo.CARD_History.Total_OnHand * DssData.dbo.CARD_History.Retail AS LY_OH_DOLLAR
FROM         DssData.dbo.CARD_History INNER JOIN
                      Staging.dbo.planner75 ON DssData.dbo.CARD_History.sku_number = staging.dbo.planner75.Sku
WHERE     (DssData.dbo.CARD_History.day_date = @ZZZ)

---
SELECT     sku_number, LY_ON_HAND
FROM         Staging.dbo.inv_ly_plan
GROUP BY sku_number, LY_ON_HAND

----
truncate table Staging.dbo.inv_ty_plan

insert into Staging.dbo.inv_ty_plan

SELECT     DssData.dbo.CARD.Sku_Number, SUM(DssData.dbo.CARD.Total_OnHand) AS OH_TY_U, 
                      SUM(DssData.dbo.CARD.Total_OnHand * DssData.dbo.CARD.Retail) AS OH_TY_D
FROM         DssData.dbo.CARD INNER JOIN
                      Staging.dbo.planner75 ON DssData.dbo.CARD.Sku_Number = Staging.dbo.planner75.Sku
GROUP BY DssData.dbo.CARD.Sku_Number


TRUNCATE TABLE staging.dbo.plan75
INSERT INTO staging.dbo.plan75
SELECT     Staging.dbo.plan1.SKU, Staging.dbo.plan1.Planner, Staging.dbo.plan1.SKU_Type, Staging.dbo.plan1.Title, Staging.dbo.plan1.Author, 
                      Staging.dbo.plan1.DWCost, Staging.dbo.plan1.POS_Price, Staging.dbo.plan1.Warehouse_OnHand, Staging.dbo.plan1.Qty_OnOrder, 
                      Staging.dbo.plan1.TY_WK_UNITS, Staging.dbo.plan1.TY_WK_Dollar, Staging.dbo.plan2.LY_WK_Dollar, Staging.dbo.plan3.TY_QTD_Dollar, 
                      Staging.dbo.plan3.TY_QTD_Units, Staging.dbo.plan5.LY_QTD_Dollar, Staging.dbo.plan5.LY_QTD_Units, Staging.dbo.inv_ty_plan.OH_TY_U, 
                      Staging.dbo.inv_ty_plan.OH_TY_D, Staging.dbo.plan2.LY_WK_Units, Staging.dbo.inv_ly_plan.LY_ON_HAND, 
                      Staging.dbo.inv_ly_plan.LY_OH_DOLLAR, Staging.dbo.plan1.TY_YTD_UNITS, Staging.dbo.plan1.TY_YTD_Dollars, Staging.dbo.plan1.LY_YTD_UNITS, 
                      Staging.dbo.plan1.LY_YTD_DOLLARS
FROM         Staging.dbo.plan1 LEFT OUTER JOIN
                      Staging.dbo.plan2 ON Staging.dbo.plan1.[SKU ] = Staging.dbo.plan2.Sku LEFT OUTER JOIN
                      Staging.dbo.inv_ly_plan ON Staging.dbo.plan1.[SKU ] = Staging.dbo.inv_ly_plan.sku_number LEFT OUTER JOIN
                      Staging.dbo.plan3 ON Staging.dbo.plan1.[SKU ] = Staging.dbo.plan3.Sku LEFT OUTER JOIN
                      Staging.dbo.plan5 ON Staging.dbo.plan1.[SKU ] = Staging.dbo.plan5.Sku LEFT OUTER JOIN
                      Staging.dbo.inv_ty_plan ON Staging.dbo.plan1.[SKU ] = Staging.dbo.inv_ty_plan.Sku_Number



select * FROM staging.dbo.plan75

GO
