USE [ReportData]
GO
/****** Object:  StoredProcedure [dbo].[usp_Build_Store_Dashboard]    Script Date: 8/19/2022 3:44:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Create procedure [dbo].[usp_Build_Store_Dashboard]
as
declare @ty_sd smalldatetime
declare @ly_sd smalldatetime
declare @ly_ed smalldatetime
--
select @ty_sd = dateadd(ww,-13,staging.dbo.fn_last_saturday(getdate()))
select @ly_sd = dateadd(ww,-13,staging.dbo.fn_last_saturday(dateadd(yy,-1,getdate())))
select @ly_ed = dateadd(yy,-1,staging.dbo.fn_dateonly(getdate()))
--
select  t2.fiscal_year_week,
		t1.store_number,
		sum(current_dollars) as TY_SLSD
into	#ty
from	dssdata.dbo.weekly_sales t1,
		reference.dbo.calendar_dim t2
where	t1.day_date >= @ty_sd
and		t2.day_date = t1.day_date
group by t2.fiscal_year_week,t1.store_number
order by t2.fiscal_year_week
--
select  t2.fiscal_year_week,
		t1.store_number,
		sum(current_dollars) as LY_SLSD
into	#ly
from	dssdata.dbo.weekly_sales t1,
		reference.dbo.calendar_dim t2
where	t1.day_date >= @ly_sd
and		t1.day_date <= @ly_ed
and		t2.day_date = t1.day_date
group by t2.fiscal_year_week,t1.store_number
order by t2.fiscal_year_week
--
truncate table ReportData.dbo.Store_13Week_Sales
insert into ReportData.dbo.Store_13Week_Sales
select	t1.fiscal_year_week,
		t1.store_number,
		t1.TY_SLSD,
		t2.LY_SLSD
from	#ty t1,
		#ly t2
where	t2.fiscal_year_week = t1.fiscal_year_week
and		t2.store_number = t1.store_number
GO
