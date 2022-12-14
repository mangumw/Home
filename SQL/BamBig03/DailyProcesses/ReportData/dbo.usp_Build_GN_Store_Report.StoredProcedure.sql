USE [ReportData]
GO
/****** Object:  StoredProcedure [dbo].[usp_Build_GN_Store_Report]    Script Date: 8/19/2022 3:44:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[usp_Build_GN_Store_Report]
as
declare @TYWk1 smalldatetime
declare @TYWk2 smalldatetime
declare @TYWk3 smalldatetime
declare @LYWk1 smalldatetime
declare @LYWk2 smalldatetime
declare @LYWk3 smalldatetime
--
select @TYWk1 = staging.dbo.fn_Last_Saturday(getdate())
select @TYWk2 = dateadd(ww,-1,@TYWk1)
select @TYWk3 = dateadd(ww,-2,@TYWk1)
--
select @LYWk1 = staging.dbo.fn_last_saturday(dateadd(yy,-1,getdate()))
select @LYWk2 = dateadd(ww,-1,@LYWk1)
select @LYWk3 = dateadd(ww,-2,@LYWk1)
--
select	t1.store_number,
		sum(t1.current_dollars) as TYWk1Dollars
into	#TYWk1
from	dssdata.dbo.weekly_sales t1,
		reference.dbo.item_master t2
where	day_date = @TYWk1
and		t2.dept = 4 and t2.sdept = 131
and		t1.sku_number = t2.sku_number
group by store_number
--
select	store_number,
		sum(current_dollars) as TYWk2Dollars
into	#TYWk2
from	dssdata.dbo.weekly_sales t1,
		reference.dbo.item_master t2
where day_date = @TYWk2
and		t2.dept = 4 and t2.sdept = 131
and		t1.sku_number = t2.sku_number
group by store_number
--
select	store_number,
		sum(current_dollars) as TYWk3Dollars
into	#TYWk3
from	dssdata.dbo.weekly_sales t1,
		reference.dbo.item_master t2
where day_date = @TYWk3
and		t2.dept = 4 and t2.sdept = 131
and		t1.sku_number = t2.sku_number
group by store_number
--
select	store_number,
		sum(current_dollars) as LYWk1Dollars
into	#LYWk1
from	dssdata.dbo.weekly_sales t1,
		reference.dbo.item_master t2
where day_date = @LYWk1
and		t2.dept = 4 and t2.sdept = 131
and		t1.sku_number = t2.sku_number
group by store_number
--
select	store_number,
		sum(current_dollars) as LYWk2Dollars
into	#LYWk2
from	dssdata.dbo.weekly_sales t1,
		reference.dbo.item_master t2
where day_date = @LYWk2
and		t2.dept = 4 and t2.sdept = 131
and		t1.sku_number = t2.sku_number
group by store_number
--
select	store_number,
		sum(current_dollars) as LYWk3Dollars
into	#LYWk3
from	dssdata.dbo.weekly_sales t1,
		reference.dbo.item_master t2
where day_date = @LYWk3
and		t2.dept = 4 and t2.sdept = 131
and		t1.sku_number = t2.sku_number
group by store_number
--
drop table reportdata.dbo.rpt_GN_Store
--
select	t1.store_number,
		t2.store_name,
		t1.TYWk1Dollars,
		t3.LYWk1Dollars,
		t4.TYWk2Dollars,
		t5.LYWk2Dollars,
		t6.TYWk3Dollars,
		t7.LYWk3Dollars
into	ReportData.dbo.rpt_GN_Store
from	#TYWk1 t1,
		reference.dbo.comp_stores t2,
		#LYWk1 t3,
		#TYWk2 t4,
		#LYWk2 t5,
		#TYWk3 t6,
		#LYWk3 t7
where	t2.store_number = t1.store_number
and		t3.store_number = t1.store_number
and		t4.store_number = t1.store_number
and		t5.store_number = t1.store_number
and		t6.store_number = t1.store_number
and		t7.store_number = t1.store_number
order by t1.store_number
--
drop table #TYWk1
drop table #TYWk2
drop table #TYWk3
drop table #LYWk1
drop table #LYWk2
drop table #LYWk3


GO
