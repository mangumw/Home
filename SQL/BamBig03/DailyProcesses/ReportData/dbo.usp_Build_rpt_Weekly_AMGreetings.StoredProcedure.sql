USE [ReportData]
GO
/****** Object:  StoredProcedure [dbo].[usp_Build_rpt_Weekly_AMGreetings]    Script Date: 8/19/2022 3:44:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[usp_Build_rpt_Weekly_AMGreetings]
as
--
declare @tyd smalldatetime
declare @lyd smalldatetime
select @tyd = staging.dbo.fn_last_saturday(getdate())-7
select @lyd = staging.dbo.fn_last_saturday(dateadd(yy,-1,dateadd(dd,2,@tyd)))


--



select	t2.store_number,
		t1.sku_number,
		t1.title,
		t1.Dept,
		t1.SDept,
		t1.Class,
		t1.SClass,
		sum(t2.current_units) as SLSU,
		sum(t2.current_dollars) as SLSD
into	#tmp1
from	reference.dbo.item_master t1,
		dssdata.dbo.weekly_Sales t2
where	t1.Vendor_Number = 11575
and		t2.sku_number = t1.sku_number
and		t2.day_date = @tyd
group by t2.store_number,
		t1.sku_number,
		t1.title,
		t1.Dept,
		t1.SDept,
		t1.Class,
		t1.SClass
order by t2.store_number,t1.sku_number
--
select	t2.store_number,
		t1.sku_number,
		sum(t2.current_units) as LY_SLSU,
		sum(t2.current_dollars) as LY_SLSD
into	#tmp2
from	reference.dbo.item_master t1,
		dssdata.dbo.weekly_Sales t2
where	t1.Vendor_Number = 11575
and		t2.sku_number = t1.sku_number
and		t2.day_date = @lyd
group by t2.store_number,
		t1.sku_number
order by t2.store_number,t1.sku_number
--
drop table reportdata.dbo.rpt_Weekly_AMGreetings
--
select	t1.store_number,
		t1.sku_number,
		t1.title,
		t1.Dept,
		t1.SDept,
		t1.Class,
		t1.SClass,
		t1.SLSU,
		t1.SLSD,
		isnull(t2.ly_slsu,0) as LY_SLSU,
		isnull(t2.ly_slsd,0) as LY_SLSD
into	reportdata.dbo.rpt_weekly_amgreetings
from	#tmp1 t1 left join 
		#tmp2 t2
on		t2.sku_number = t1.sku_number
and		t2.store_number = t1.store_number











GO
