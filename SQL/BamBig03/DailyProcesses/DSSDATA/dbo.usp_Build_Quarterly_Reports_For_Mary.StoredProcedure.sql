USE [Dssdata]
GO
/****** Object:  StoredProcedure [dbo].[usp_Build_Quarterly_Reports_For_Mary]    Script Date: 8/19/2022 3:48:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[usp_Build_Quarterly_Reports_For_Mary]
as


declare @from_dt smalldatetime
declare @to_dt smalldatetime

select @from_dt = min(day_date) 
from reference.dbo.Calendar_Dim
where fiscal_quarter = '2012-Q2'

select @to_dt = max(day_date) 
from reference.dbo.Calendar_Dim
where fiscal_quarter = '2012-Q2'
/*
----------Prop Rollup
SELECT
Prop_Sales = '$'+convert(varchar,SUM(DssData.dbo.Weekly_Sales.Current_Dollars),1), 
Prop_Units = convert(varchar,SUM(DssData.dbo.Weekly_Sales.Current_Units),1)
FROM
DssData.dbo.Weekly_Sales INNER JOIN
Reference.dbo.Item_Master ON DssData.dbo.Weekly_Sales.Sku_Number = Reference.dbo.Item_Master.SKU_Number
WHERE
(DssData.dbo.Weekly_Sales.Day_Date 
BETWEEN CONVERT(DATETIME,@from_dt,102) AND CONVERT(DATETIME,@to_dt,102)) AND 
(Reference.dbo.Item_Master.Coordinate_Group IN ('PROP', 'PROMO', 'PROPS', 'PROPA'))
ORDER BY Prop_Sales DESC

----------Gift Rollup
SELECT     
Reference.dbo.Item_Master.Dept AS Dept,
Gift_Sales = '$' + convert(varchar,SUM(DssData.dbo.Weekly_Sales.Current_Dollars),1), 
SUM(DssData.dbo.Weekly_Sales.Current_Units) AS Gift_Units 
FROM         
DssData.dbo.Weekly_Sales INNER JOIN
Reference.dbo.Item_Master ON DssData.dbo.Weekly_Sales.Sku_Number = Reference.dbo.Item_Master.SKU_Number
WHERE     
(DssData.dbo.Weekly_Sales.Day_Date 
BETWEEN CONVERT(DATETIME,@from_dt,102) AND CONVERT(DATETIME,@to_dt,102))  
GROUP BY 
Reference.dbo.Item_Master.Dept
HAVING      
(Reference.dbo.Item_Master.Dept = 6)
ORDER BY Gift_Sales DESC

----------Import Rollup
SELECT     
Import_Sales = '$' + convert(varchar,SUM(DssData.dbo.Weekly_Sales.Current_Dollars),1), 
SUM(DssData.dbo.Weekly_Sales.Current_Units) AS Import_Units
FROM         
DssData.dbo.Weekly_Sales INNER JOIN
Reference.dbo.Item_Master ON DssData.dbo.Weekly_Sales.Sku_Number = Reference.dbo.Item_Master.SKU_Number
WHERE     
(DssData.dbo.Weekly_Sales.Day_Date 
BETWEEN CONVERT(DATETIME,@from_dt,102) AND CONVERT(DATETIME,@to_dt,102)) AND 
(Reference.dbo.Item_Master.PubCode IN ('AFE', 'BSM', 'DRR', 'IAR', 'IFH', 'MDD')) AND (Reference.dbo.Item_Master.Dept = 6)
ORDER BY Import_Sales DESC
*/
----------Prop Top 500
SELECT top 10
Reference.dbo.Item_Master.Dept AS Dept, 
Reference.dbo.Item_Master.SDept_Name, 
Reference.dbo.Item_Master.ISBN, 
Reference.dbo.Item_Master.SKU_Number, 
Reference.dbo.Item_Master.Title, 
Reference.dbo.Item_Master.Author, 
Reference.dbo.Item_Master.PubCode, 
--Prop_Top_500_Sales = '$' + convert(varchar,SUM(DssData.dbo.Weekly_Sales.Current_Dollars),1),
SUM(DssData.dbo.Weekly_Sales.Current_dollars) AS Prop_Top_500_sales,
SUM(DssData.dbo.Weekly_Sales.Current_Units) AS Prop_Top_500_Units
FROM         
DssData.dbo.Weekly_Sales INNER JOIN
Reference.dbo.Item_Master ON DssData.dbo.Weekly_Sales.Sku_Number = Reference.dbo.Item_Master.SKU_Number
WHERE
(DssData.dbo.Weekly_Sales.Day_Date 
BETWEEN CONVERT(DATETIME,@from_dt,102) AND CONVERT(DATETIME,@to_dt,102)) AND 
(Reference.dbo.Item_Master.Coordinate_Group IN ('PROP', 'PROMO', 'PROPS', 'PROPA'))
GROUP BY 
Reference.dbo.Item_Master.ISBN, 
Reference.dbo.Item_Master.Title, 
Reference.dbo.Item_Master.Author, 
Reference.dbo.Item_Master.SDept_Name, 
Reference.dbo.Item_Master.Dept, 
Reference.dbo.Item_Master.SKU_Number, 
Reference.dbo.Item_Master.PubCode
HAVING 
(SUM(DssData.dbo.Weekly_Sales.Current_Dollars) > 500)
ORDER BY Prop_Top_500_Sales DESC

---gift top x
SELECT top 10    
Reference.dbo.Item_Master.Dept AS Dept, 
Reference.dbo.Item_Master.SDept_Name, 
Reference.dbo.Item_Master.ISBN, 
Reference.dbo.Item_Master.SKU_Number, 
reference.dbo.Item_Master.Title, 
Reference.dbo.Item_Master.Author, 
Reference.dbo.Item_Master.PubCode, 
SUM(DssData.dbo.Weekly_Sales.Current_Dollars) AS Gift_Top_500_Sales,
SUM(DssData.dbo.Weekly_Sales.Current_Units) AS Gift_Top_500_Units 
FROM         
DssData.dbo.Weekly_Sales INNER JOIN
Reference.dbo.Item_Master ON DssData.dbo.Weekly_Sales.Sku_Number = Reference.dbo.Item_Master.SKU_Number
WHERE     
(DssData.dbo.Weekly_Sales.Day_Date 
BETWEEN CONVERT(DATETIME,@from_dt,102) AND CONVERT(DATETIME,@to_dt,102))  
GROUP BY 
Reference.dbo.Item_Master.ISBN, 
Reference.dbo.Item_Master.Title, 
Reference.dbo.Item_Master.Author, 
Reference.dbo.Item_Master.SDept_Name, 
Reference.dbo.Item_Master.Dept, 
Reference.dbo.Item_Master.SKU_Number, 
Reference.dbo.Item_Master.PubCode
HAVING      
(SUM(DssData.dbo.Weekly_Sales.Current_Dollars) > 500) AND (Reference.dbo.Item_Master.Dept = 6)
ORDER BY Gift_Top_500_Sales DESC


---gift top x
SELECT top 10    
Reference.dbo.Item_Master.Dept AS Dept, 
Reference.dbo.Item_Master.SDept_Name, 
Reference.dbo.Item_Master.ISBN, 
Reference.dbo.Item_Master.SKU_Number, 
Reference.dbo.Item_Master.Title, 
Reference.dbo.Item_Master.Author, 
Reference.dbo.Item_Master.PubCode, 
SUM(DssData.dbo.Weekly_Sales.Current_Dollars) AS Gift_Top_500_Sales,
SUM(DssData.dbo.Weekly_Sales.Current_Units) AS Import_Top_500_Units 
FROM         
DssData.dbo.Weekly_Sales INNER JOIN
Reference.dbo.Item_Master ON DssData.dbo.Weekly_Sales.Sku_Number = Reference.dbo.Item_Master.SKU_Number
WHERE     
(DssData.dbo.Weekly_Sales.Day_Date 
BETWEEN CONVERT(DATETIME,@from_dt,102) AND CONVERT(DATETIME,@to_dt,102))  
GROUP BY 
Reference.dbo.Item_Master.ISBN, 
Reference.dbo.Item_Master.Title, 
Reference.dbo.Item_Master.Author, 
Reference.dbo.Item_Master.SDept_Name, 
Reference.dbo.Item_Master.Dept, 
Reference.dbo.Item_Master.SKU_Number, 
Reference.dbo.Item_Master.PubCode
HAVING      
(SUM(DssData.dbo.Weekly_Sales.Current_Dollars) > 500) AND (Reference.dbo.Item_Master.Dept = 6) AND 
(Reference.dbo.Item_Master.PubCode IN ('AFE', 'BSM', 'DRR', 'IAR', 'IFH', 'MDD'))
ORDER BY Gift_Top_500_Sales DESC


GO
