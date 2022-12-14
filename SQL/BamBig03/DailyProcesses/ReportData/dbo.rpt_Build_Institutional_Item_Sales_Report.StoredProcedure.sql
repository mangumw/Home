USE [ReportData]
GO
/****** Object:  StoredProcedure [dbo].[rpt_Build_Institutional_Item_Sales_Report]    Script Date: 8/19/2022 3:44:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[rpt_Build_Institutional_Item_Sales_Report]
as
declare @TY smalldatetime
declare @LY smalldatetime
--
set @TY = staging.dbo.fn_Last_Saturday(getdate())
set @LY = staging.dbo.fn_Last_Saturday(dateadd(yy,-1,getdate()))
--
-- Get Last Year Totals
select  t1.Sku_Number,
		sum(t1.current_units) as LY_SLSU,
		sum(t1.current_dollars) as LY_SLSD
into	#LY
from	dssdata.dbo.Institutional_Weekly_Sales t1
where	day_date = @LY 
group by t1.sku_Number
order by t1.sku_Number
--
-- Get this years data
--
IF  EXISTS (SELECT * FROM ReportData.sys.objects WHERE object_id = OBJECT_ID(N'[ReportData].[dbo].[rpt_Institutional_Weekly_Item_Sales]') AND type in (N'U'))
DROP TABLE [ReportData].[dbo].[rpt_Institutional_Weekly_Item_Sales]
--
select  t1.day_date,
		t1.sku_number,
		t2.Title,
		t1.store_number,
		t4.store_Name,
		t1.Transaction_Date,
		t1.current_dollars,
		t1.current_units,
		t3.LY_SLSU,
		t3.LY_SLSD
into	reportdata.dbo.rpt_Institutional_Weekly_Item_Sales
from	dssdata.dbo.Institutional_Weekly_Sales t1,
		reference.dbo.item_master t2,
		#LY t3,
		reference.dbo.Active_Stores t4
where	t1.day_date = @TY
and		t2.sku_number = t1.sku_number
and		t3.sku_number = t1.sku_number
and		t4.store_number = t1.store_number
order by t1.sku_number

delete from reportdata.dbo.rpt_Institutional_Weekly_Item_Sales
where sku_number = 4 and current_dollars = 0









GO
