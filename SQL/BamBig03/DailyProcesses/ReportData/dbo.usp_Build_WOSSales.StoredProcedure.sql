USE [ReportData]
GO
/****** Object:  StoredProcedure [dbo].[usp_Build_WOSSales]    Script Date: 8/19/2022 3:44:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[usp_Build_WOSSales]
as
--
Drop Table reportdata.dbo.WOSSALES
--
SELECT Reference.dbo.Item_Master.Dept, Reference.dbo.Item_Master.Dept_Name, Reference.dbo.Item_Master.SDept AS SD, 

Reference.dbo.Item_Master.SDept_Name, Reference.dbo.Item_Master.Class_Name, Reference.dbo.Item_Master.Class, 

Reference.dbo.Item_Master.BuyerName, SUM(DssData.dbo.Weekly_Sales.Current_Units) AS WK52U, 

SUM(DssData.dbo.Weekly_Sales.Current_Dollars) AS WK52D

INTO [#WOSSales]

FROM Reference.dbo.Item_Master INNER JOIN

DssData.dbo.Weekly_Sales ON Reference.dbo.Item_Master.Sku_Number = DssData.dbo.Weekly_Sales.Sku_Number

WHERE (DssData.dbo.Weekly_Sales.Day_Date >= GETDATE() - 357)

GROUP BY Reference.dbo.Item_Master.Class_Name, Reference.dbo.Item_Master.Class, Reference.dbo.Item_Master.SDept_Name, 

Reference.dbo.Item_Master.BuyerName, Reference.dbo.Item_Master.Dept, Reference.dbo.Item_Master.SDept, 

Reference.dbo.Item_Master.Dept_Name

SELECT Reference.dbo.INVCBL.Dept, Reference.dbo.INVCBL.SDept, Reference.dbo.INVCBL.Class, SUM(Reference.dbo.INVCBL.On_Hand) 

AS BAMOH, SUM(Reference.dbo.INVCBL.On_Hand * Reference.dbo.INVMST.POS_Price) AS BAMRTL

INTO #WOSInventory

FROM Reference.dbo.INVCBL INNER JOIN

Reference.dbo.INVMST ON Reference.dbo.INVCBL.Sku_Number = Reference.dbo.INVMST.Sku_Number

WHERE (NOT (Reference.dbo.INVMST.SKU_Type IN ('P', 'V')))

GROUP BY Reference.dbo.INVCBL.Dept, Reference.dbo.INVCBL.SDept, Reference.dbo.INVCBL.Class

 

SELECT #WOSSales.dept AS DP, #WOSSales.SD, #WOSSales.dept_name, #WOSSales.SDept_Name, #WOSSales.class, #WOSSales.class_name, 

Reference.dbo.Category_Master.BuyerName, #WOSSales.WK52U, #WOSSales.WK52D, #WOSInventory.BAMOH, 

#WOSInventory.BAMRTL
into reportdata.dbo.WOSSales

FROM #WOSSales INNER JOIN

#WOSInventory ON #WOSSaleS.DEPT = #WOSInventory.Dept AND #WOSSales.SD = #WOSInventory.SDept AND 

#WOSSales.class = #WOSInventory.Class INNER JOIN

Reference.dbo.Category_Master ON #WOSSaleS.DEPT = Reference.dbo.Category_Master.DEPT AND 

#WOSSaleS.SD = Reference.dbo.Category_Master.SubDept AND #WOSSales.class = Reference.dbo.Category_Master.Class

GROUP BY #WOSSaleS.DEPT, #WOSSales.SD, #WOSSaleS.SD, #WOSSales.class, #WOSSales.class_name, 

Reference.dbo.Category_Master.BuyerName, #WOSInventory.BAMOH, #WOSInventory.BAMRTL, #WOSSales.WK52U, #WOSSales.WK52D, #WOSSales.SDept_Name, #WOSSales.dept_name

 

GO
