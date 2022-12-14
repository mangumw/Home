USE [Reference]
GO
/****** Object:  StoredProcedure [dbo].[usp_top10_quarterly]    Script Date: 8/19/2022 3:46:15 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- saved to databases,system databases,master,progammability,stored procedures

CREATE Procedure [dbo].[usp_top10_quarterly]
As

declare @period int
declare @dayofperiod int

select @period = fiscal_period 
from reference.dbo.calendar_dim where
day_date = staging.dbo.fn_DateOnly(getdate())

select @dayofperiod = day_of_period 
from reference.dbo.calendar_dim where
day_date = staging.dbo.fn_DateOnly(getdate())

-- only run if this is the first day of a quarter
If (@period = 1 or @period = 4 or @period = 7 or @period = 10) and @dayofperiod = 1
Begin

declare @from_dt smalldatetime
declare @to_dt smalldatetime
declare @quarter char
declare @year int

select @quarter = right(fiscal_quarter,1) from reference.dbo.calendar_dim 
where day_date = staging.dbo.fn_DateOnly(getdate()-1)

select @year = fiscal_year from reference.dbo.calendar_dim 
where day_date = staging.dbo.fn_DateOnly(getdate()-1)

select @from_dt = min(day_date) 
from reference.dbo.Calendar_Dim
where fiscal_quarter = (select fiscal_quarter from reference.dbo.calendar_dim 
where day_date = staging.dbo.fn_DateOnly(getdate()-1))


select @to_dt = max(day_date) 
from reference.dbo.Calendar_Dim
where fiscal_quarter = (select fiscal_quarter from reference.dbo.calendar_dim 
where day_date = staging.dbo.fn_DateOnly(getdate()-1))

----------Prop Top 10
insert into reference.dbo.quarterly_prop_10
SELECT top 10
Reference.dbo.Item_Master.Dept AS Dept, 
Reference.dbo.Item_Master.SDept_Name, 
Reference.dbo.Item_Master.ISBN, 
Reference.dbo.Item_Master.SKU_Number, 
Reference.dbo.Item_Master.Title, 
Reference.dbo.Item_Master.Author, 
Reference.dbo.Item_Master.PubCode, 
--Prop_Top_500_Sales = '$' + convert(varchar,SUM(DssData.dbo.Weekly_Sales.Current_Dollars),1),
SUM(DssData.dbo.Weekly_Sales.Current_dollars) AS Prop_Top_10_sales,
SUM(DssData.dbo.Weekly_Sales.Current_Units) AS Prop_Top_10_Units,
row_number() over (order by SUM(DssData.dbo.Weekly_Sales.Current_dollars) DESC) as row,
@quarter as Prop_fiscal_quarter,
@year as Prop_fiscal_year
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
ORDER BY Prop_Top_10_Sales DESC

---gift top 10
insert into reference.dbo.quarterly_gift_10
SELECT top 10    
Reference.dbo.Item_Master.Dept AS Dept, 
Reference.dbo.Item_Master.SDept_Name, 
Reference.dbo.Item_Master.ISBN, 
Reference.dbo.Item_Master.SKU_Number, 
reference.dbo.Item_Master.Title, 
Reference.dbo.Item_Master.Author, 
Reference.dbo.Item_Master.PubCode, 
SUM(DssData.dbo.Weekly_Sales.Current_Dollars) AS Gift_Top_10_Sales,
SUM(DssData.dbo.Weekly_Sales.Current_Units) AS Gift_Top_10_Units, 
row_number() over (order by SUM(DssData.dbo.Weekly_Sales.Current_dollars) DESC) as row,
@quarter as Gift_fiscal_quarter,
@year as Gift_fiscal_year
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
ORDER BY Gift_Top_10_Sales DESC


---gift top x
insert into reference.dbo.quarterly_import_10
SELECT top 10    
Reference.dbo.Item_Master.Dept AS Dept, 
Reference.dbo.Item_Master.SDept_Name, 
Reference.dbo.Item_Master.ISBN, 
Reference.dbo.Item_Master.SKU_Number, 
Reference.dbo.Item_Master.Title, 
Reference.dbo.Item_Master.Author, 
Reference.dbo.Item_Master.PubCode, 
SUM(DssData.dbo.Weekly_Sales.Current_Dollars) AS Import_Top_10_Sales,
SUM(DssData.dbo.Weekly_Sales.Current_Units) AS Import_Top_10_Units,
row_number() over (order by SUM(DssData.dbo.Weekly_Sales.Current_dollars) DESC) as row,
@quarter as Import_fiscal_quarter,
@year as Import_fiscal_year 
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
ORDER BY import_Top_10_Sales DESC

End
GO
