USE [Reference]
GO
/****** Object:  StoredProcedure [dbo].[usp_top50_prop]    Script Date: 8/19/2022 3:46:15 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- saved to databases,system databases,master,progammability,stored procedures

CREATE Procedure [dbo].[usp_top50_prop]
As


truncate table staging.dbo.prop1
insert into staging.dbo.prop1

SELECT     TOP (50) DssData.dbo.CARD.Sku_Number, DssData.dbo.CARD.Title, 
                      DssData.dbo.CARD.Author, DssData.dbo.CARD.Qty_OnOrder, DssData.dbo.CARD.Total_OnHand, SUM(DssData.dbo.Weekly_Sales.Current_Units) 
                      AS units, SUM(DssData.dbo.Weekly_Sales.Current_Dollars) AS dollars
FROM         DssData.dbo.CARD INNER JOIN
                      DssData.dbo.Weekly_Sales ON DssData.dbo.CARD.Sku_Number = DssData.dbo.Weekly_Sales.Sku_Number
WHERE     (DssData.dbo.CARD.Coordinate_Group IN ('PROMO', 'PROPS', 'PROP', 'PROPA')) AND 
                      (DssData.dbo.Weekly_Sales.Day_Date = Staging.dbo.fn_Last_Saturday(GETDATE()))
GROUP BY DssData.dbo.CARD.ISBN, DssData.dbo.CARD.Sku_Number, DssData.dbo.CARD.Title, DssData.dbo.CARD.Author, DssData.dbo.CARD.Qty_OnOrder, 
                      DssData.dbo.CARD.Total_OnHand
ORDER BY dollars DESC

truncate table staging.dbo.prop2
insert into staging.dbo.prop2

SELECT     TOP (50) DssData.dbo.CARD.Sku_Number, DssData.dbo.CARD.Title, 
                      DssData.dbo.CARD.Author, DssData.dbo.CARD.Qty_OnOrder, DssData.dbo.CARD.Total_OnHand, SUM(DssData.dbo.Weekly_Sales.Current_Units) 
                      AS units, SUM(DssData.dbo.Weekly_Sales.Current_Dollars) AS dollars
FROM         DssData.dbo.CARD INNER JOIN
                      DssData.dbo.Weekly_Sales ON DssData.dbo.CARD.Sku_Number = DssData.dbo.Weekly_Sales.Sku_Number
WHERE     (DssData.dbo.CARD.Coordinate_Group IN ('PROMO', 'PROPS', 'PROP', 'PROPA')) AND 
                      (DssData.dbo.Weekly_Sales.Day_Date = staging.dbo.fn_Last_Saturday(Dateadd(yy,-1,getdate())))
GROUP BY DssData.dbo.CARD.ISBN, DssData.dbo.CARD.Sku_Number, DssData.dbo.CARD.Title, DssData.dbo.CARD.Author, DssData.dbo.CARD.Qty_OnOrder, 
                      DssData.dbo.CARD.Total_OnHand
ORDER BY dollars DESC

select      t1.sku_number,

            t1.title,

            t1.author,

            t1.Qty_OnOrder,

            t1.total_onHand,

            t1.units,

            t1.Dollars,

            t2.sku_number as LY_Sku_Number,

            t2.title as LY_Title,

            t2.author as LY_Author,

            t2.Qty_OnOrder as LY_Qty_OnOrder,

            t2.total_onHand as LY_Total_On_Hand,

            t2.units as LY_Units,

            t2.Dollars as LY_Dollars

from  staging.dbo.prop1 t1,

            staging.dbo.prop2 t2    

where t2.num = t1.num   
GO
