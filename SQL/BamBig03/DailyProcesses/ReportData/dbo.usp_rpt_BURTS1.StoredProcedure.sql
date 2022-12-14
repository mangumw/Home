USE [ReportData]
GO
/****** Object:  StoredProcedure [dbo].[usp_rpt_BURTS1]    Script Date: 8/19/2022 3:44:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[usp_rpt_BURTS1] AS

SELECT reference.dbo.Store_Dim.store_number, Sum(dssdata.dbo.weekly_sales.current_dollars) AS BCWD, dssdata.dbo.weekly_sales.day_date AS SatDate, dssdata.dbo.weekly_sales.sku_number
INTO #burts_sls
FROM dssdata.dbo.weekly_sales INNER JOIN reference.dbo.Store_Dim ON dssdata.dbo.weekly_sales.store_number = reference.dbo.Store_Dim.store_number
GROUP BY reference.dbo.Store_Dim.store_number, dssdata.dbo.weekly_sales.day_date, dssdata.dbo.weekly_sales.sku_number
HAVING (((dssdata.dbo.weekly_sales.day_date)>=getDate()-7) AND ((dssdata.dbo.weekly_sales.sku_number)=1746786))

SELECT Sum(dssdata.dbo.weekly_sales.current_dollars) AS DeptCWD, reference.dbo.Store_Dim.store_number, dssdata.dbo.weekly_sales.day_date AS SatDate
INTO #Dept_sls
FROM (dssdata.dbo.weekly_sales INNER JOIN reference.dbo.Item_Dim ON dssdata.dbo.weekly_sales.sku_number = reference.dbo.Item_Dim.sku_number) INNER JOIN reference.dbo.Store_Dim ON dssdata.dbo.weekly_sales.store_number = reference.dbo.Store_Dim.store_number
GROUP BY reference.dbo.Store_Dim.store_number, dssdata.dbo.weekly_sales.day_date, reference.dbo.Item_Dim.department
HAVING (((dssdata.dbo.weekly_sales.day_date)>=getDate()-7) AND ((reference.dbo.Item_Dim.department)=6))

SELECT reference.dbo.Store_Dim.store_number, reference.dbo.Store_Dim.store_name, IsNull([#burts_sls].[BCWD],0) AS ItemSls, #Dept_sls.DeptCWD AS Dept,  IsNull([BCWD]/[DeptCWD],0) AS[%OfStore]
FROM (#Dept_sls INNER JOIN reference.dbo.Store_Dim ON #Dept_sls.store_number = reference.dbo.Store_Dim.store_number) LEFT JOIN #burts_sls ON #Dept_sls.store_number = #burts_sls.store_number


GO
