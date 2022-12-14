USE [ReportData]
GO
/****** Object:  StoredProcedure [dbo].[usp_rpt_Regional_By_District]    Script Date: 8/19/2022 3:44:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE Procedure [dbo].[usp_rpt_Regional_By_District]
as
declare @SD smalldatetime
declare @ED smalldatetime
declare @WD varchar(25)
declare @mon int
declare @Total_RegU	int
declare @Total_RegD money
declare @fy int
declare @Period int
--
select @fy = fiscal_year from reference.dbo.calendar_dim where day_date = staging.dbo.fn_dateonly(dateadd(mm,-1,getdate()))
select @period = fiscal_period from reference.dbo.calendar_dim where day_date = staging.dbo.fn_dateonly(dateadd(mm,-1,getdate()))
select @sd = min(day_date) from reference.dbo.calendar_dim where fiscal_year = @fy and fiscal_period = @period
select @ed = max(day_date) from reference.dbo.calendar_dim where fiscal_year = @fy and fiscal_period = @period
--
--
--select	@Grand_SLSU = sum(t1.current_units),
--		@Grand_SLSD = sum(t1.current_dollars) 
--from	reference.dbo.item_master t2,
--		dssdata.dbo.weekly_sales t1
--where	t1.day_date >= @SD and t1.day_date < @ED
--and		t1.sku_number = t2.sku_number
--
truncate table staging.dbo.tmp_District
insert into staging.dbo.tmp_district
select	t1.Store_Number,
		t1.Store_Name,
		t1.District_Number,
		t1.District_Name,
		sum(t2.current_Dollars) as Total_SLSD,
		sum(t2.Current_Units) as Total_SLSU
from	reference.dbo.Active_Stores t1,
		dssdata.dbo.weekly_sales t2,
		reference.dbo.item_master t3
where	t2.Store_Number = t1.Store_Number
and		t2.sku_number = t3.sku_number
and		t2.day_date >= @SD 
and		t2.day_date < @ED
group by t1.Store_Number,t1.Store_Name,t1.District_Number,t1.district_name

select	@SD as Start_Date,
		@ED as End_Date,
		t3.District_Number,
		t3.District_Name,
		t3.Store_Number,
		t3.Store_Name,
		t3.Total_SLSD,
		t3.Total_SLSU,
		sum(t1.current_units) as Region_SLSU,
		sum(t1.current_dollars) as Region_SLSD
from	reference.dbo.item_master t2,
		dssdata.dbo.weekly_sales t1,
		staging.dbo.tmp_district t3
where	t2.dept = 4
and		t2.sdept in (116, 130)
and		t2.class =504
and		t1.Store_Number = t3.Store_Number
and		t1.sku_number = t2.sku_number
and		t1.day_date >= @SD and t1.day_date < @ED
group by t3.District_number,t3.District_Name,t3.Store_Number,t3.Store_Name,t3.total_slsd,t3.total_slsu
order by (sum(t1.current_dollars)/@Total_RegD) * 100 desc



GO
