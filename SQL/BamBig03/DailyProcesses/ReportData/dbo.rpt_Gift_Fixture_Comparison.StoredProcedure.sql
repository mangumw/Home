USE [ReportData]
GO
/****** Object:  StoredProcedure [dbo].[rpt_Gift_Fixture_Comparison]    Script Date: 8/19/2022 3:44:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[rpt_Gift_Fixture_Comparison]
as
declare @tySD smalldatetime
declare @lyED smalldatetime
declare @lySD smalldatetime
set @tySD = dateadd(ww,-3,staging.dbo.fn_last_saturday(getdate()))
set @lyED = staging.dbo.fn_Last_Saturday(dateadd(yy,-1,getdate()))
set @lySD = dateadd(ww,-3,@lyED)
-- Get this years numbers
select	t1.Store_Number,
		t1.Has_Fixture,
		sum(t2.current_dollars) as TY_SLSD
into	#ty
from	staging.dbo.store_fixtures t1,
		dssdata.dbo.weekly_sales t2,
		reference.dbo.item_master t3
where	t2.store_number = t1.store_number
and		t2.day_date >= @tySD
and		t3.dept = 6
and		t2.sku_number = t3.sku_number
group by t1.store_number,t1.has_fixture
--
select	t1.Store_Number,
		t1.Has_Fixture,
		sum(t2.current_dollars) as ly_SLSD
into	#ly
from	staging.dbo.store_fixtures t1,
		dssdata.dbo.weekly_sales t2,
		reference.dbo.item_master t3
where	t2.store_number = t1.store_number
and		t2.day_date >= @lySD and t2.day_date <= @lyED
and		t3.dept = 6
and		t2.sku_number = t3.sku_number
group by t1.store_number,t1.has_fixture
--
select	t1.store_number,
		t3.Store_Name,
		t2.Has_Fixture,
		t1.ty_SLSD,
		t2.ly_slsd
from	#ty t1,
		#ly t2,
		reference.dbo.active_stores t3
where	t2.store_number = t1.store_number
and		t3.store_number = t1.store_number

GO
