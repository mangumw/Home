USE [ReportData]
GO
/****** Object:  StoredProcedure [dbo].[usp_rpt_weekly_sales_chris]    Script Date: 8/19/2022 3:44:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[usp_rpt_weekly_sales_chris] 
	@Dept char(6)
AS
	SET NOCOUNT ON;
--
declare @strsql nvarchar(1000)

if @DEPT = '3'
begin
	select @strsql = 'select buyer,planner_name,Class,Class_Name,Sku_Number,'
    select @strsql = @strsql + 'ISBN,Title ,Author,pub_code,convert(varchar(10),idate,1) as idates'
	select @strsql = @strsql + ',convert(varchar(10),ExpReceiptDate,1) as expdates,Sku_Type ,Retail'
	select @strsql = @strsql + ',BAM_OnHand,Warehouse_OnHand ,Qty_OnOrder,intransit,TYYTDDollars,TYYTDUnits'
    select @strsql = @strsql + ',LYYTDUnits,Week13Dollars,Week13Units,FY14_WK13_Units,Week1Dollars'
	select @strsql = @strsql + ',Week1Units ,Week2Units ,Week3Units,Sell_Thru,Display_Min '
	select @strsql = @strsql + ',Active_Stores,WK8_No_Sales from ReportData.dbo.rpt_weekly_sales '
	select @strsql = @strsql + ' where Dept = ' + ltrim(str(cast(@Dept as int)))
	select @strsql = @strsql + ' and (sdept = 120 or sdept = 121 or sdept = 122 or sdept = 123 or sdept = 103) '
	select @strsql = @strsql + ' and class <> 999 '
    select @strsql = @strsql + ' and (BAM_OnHand>0 or Warehouse_OnHand > 0 or Qty_OnOrder > 0 or tyytddollars > 0) '
	select @strsql = @strsql + ' order by Week1Dollars'
end
else 
begin
    select @strsql = 'select buyer,planner_name,Class,Class_Name,Sku_Number,'
    select @strsql = @strsql + 'ISBN,Title ,Author,pub_code,convert(varchar(10),idate,120) as idates'
	select @strsql = @strsql + ',convert(varchar(10),ExpReceiptDate,120) as expdates,Sku_Type ,Retail'
	select @strsql = @strsql + ',BAM_OnHand,Warehouse_OnHand ,Qty_OnOrder,intransit,TYYTDDollars,TYYTDUnits'
    select @strsql = @strsql + ',LYYTDUnits,Week13Dollars,Week13Units,FY14_WK13_Units,Week1Dollars'
	select @strsql = @strsql + ',Week1Units ,Week2Units ,Week3Units,Sell_Thru,Display_Min '
	select @strsql = @strsql + ',Active_Stores,WK8_No_Sales from ReportData.dbo.rpt_weekly_sales '
	select @strsql = @strsql + ' where Dept = ' + ltrim(str(cast(@Dept as int)))
	select @strsql = @strsql + ' and class <> 999 '
    select @strsql = @strsql + ' and (BAM_OnHand>0 or Warehouse_OnHand > 0 or Qty_OnOrder > 0 or tyytddollars > 0) '
	select @strsql = @strsql + ' order by Week1Dollars'
end
--
 --select @strsql
--
EXEC sp_executesql @strsql
GO
