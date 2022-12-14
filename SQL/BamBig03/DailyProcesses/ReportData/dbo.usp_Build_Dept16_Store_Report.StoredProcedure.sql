USE [ReportData]
GO
/****** Object:  StoredProcedure [dbo].[usp_Build_Dept16_Store_Report]    Script Date: 8/19/2022 3:44:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[usp_Build_Dept16_Store_Report]
as
declare @WK1 as smalldatetime
declare @wk2 as smalldatetime
declare @wk3 as smalldatetime
declare @WK1ly as smalldatetime
declare @wk2ly as smalldatetime
declare @wk3ly as smalldatetime
declare @TY as smalldatetime
declare @LY as smalldatetime
declare @fiscal_year int
--
select @fiscal_year = fiscal_year from reference.dbo.calendar_dim 
where day_date = staging.dbo.fn_dateonly(getdate())
--
select @TY = day_date from reference.dbo.calendar_dim 
where fiscal_year = @fiscal_year and day_of_fiscal_year = 1
--
select @LY = day_date from reference.dbo.calendar_dim 
where fiscal_year = @fiscal_year - 1 and day_of_fiscal_year = 1
--
select @wk1 = staging.dbo.fn_last_saturday(getdate())
select @wk2 = dateadd(ww,-1,@wk1)
select @wk3 = dateadd(ww,-1,@wk2)
select @wk1ly = staging.dbo.fn_last_saturday(dateadd(yy,-1,getdate()))
select @wk2ly = dateadd(ww,-1,@wk1ly)
select @wk3ly = dateadd(ww,-1,@wk2ly)
--
drop table staging.dbo.dept16_wk1
drop table staging.dbo.dept16_wk2
drop table staging.dbo.dept16_wk3
drop table staging.dbo.dept16_wk1ly
drop table staging.dbo.dept16_wk2ly
drop table staging.dbo.dept16_wk3ly
drop table staging.dbo.dept16_TY
drop table staging.dbo.dept16_LY
drop table reportdata.dbo.Dept16_store
--
select	t3.Store_Number,
		rtrim(t1.SDept_Name) + ' (' + ltrim(str(t1.SDept)) + ')' as SDept,
		rtrim(t1.Class_Name) + ' (' + ltrim(str(t1.Class)) + ')' as Class,
		rtrim(t1.SClass_Name) + ' (' + ltrim(str(t1.SClass)) + ')' as SClass,
		sum(t2.Week1Dollars) as Week1Dollars
into	Staging.dbo.dept16_wk1
from	reference.dbo.item_master t1,
		dssdata.dbo.three_week_sales t2,
		dssdata.dbo.weekly_sales t3
where	t1.Dept = 16
and		t2.sku_number = t1.sku_number
and		t3.sku_number = t1.sku_number
and		t3.day_date = @wk1
group by t3.Store_Number,t1.Dept_Name,t1.SDept,t1.SDept_Name,t1.Class,t1.Class_Name,t1.SClass,t1.SClass_Name
order by t3.store_number,t1.SDept,t1.Class,t1.sclass
--
select	t3.Store_Number,
		rtrim(t1.SDept_Name) + ' (' + ltrim(str(t1.SDept)) + ')' as SDept,
		rtrim(t1.Class_Name) + ' (' + ltrim(str(t1.Class)) + ')' as Class,
		rtrim(t1.SClass_Name) + ' (' + ltrim(str(t1.SClass)) + ')' as SClass,
		sum(t2.Week1Dollars) as Week2Dollars
into	Staging.dbo.dept16_wk2
from	reference.dbo.item_master t1,
		dssdata.dbo.three_week_sales t2,
		dssdata.dbo.weekly_sales t3
where	t1.Dept = 16
and		t2.sku_number = t1.sku_number
and		t3.sku_number = t1.sku_number
and		t3.day_date = @wk2
group by t3.Store_Number,t1.Dept_Name,t1.SDept,t1.SDept_Name,t1.Class,t1.Class_Name,t1.SClass,t1.SClass_Name
order by t3.store_number,t1.SDept,t1.Class,t1.sclass
--
select	t3.Store_Number,
		rtrim(t1.SDept_Name) + ' (' + ltrim(str(t1.SDept)) + ')' as SDept,
		rtrim(t1.Class_Name) + ' (' + ltrim(str(t1.Class)) + ')' as Class,
		rtrim(t1.SClass_Name) + ' (' + ltrim(str(t1.SClass)) + ')' as SClass,
		sum(t2.Week1Dollars) as Week3Dollars
into	staging.dbo.dept16_wk3
from	reference.dbo.item_master t1,
		dssdata.dbo.three_week_sales t2,
		dssdata.dbo.weekly_sales t3
where	t1.Dept = 16
and		t2.sku_number = t1.sku_number
and		t3.sku_number = t1.sku_number
and		t3.day_date = @wk3
group by t3.Store_Number,t1.Dept_Name,t1.SDept,t1.SDept_Name,t1.Class,t1.Class_Name,t1.SClass,t1.SClass_Name
order by t3.store_number,t1.SDept,t1.Class,t1.sclass
--
select	t3.Store_Number,
		rtrim(t1.SDept_Name) + ' (' + ltrim(str(t1.SDept)) + ')' as SDept,
		rtrim(t1.Class_Name) + ' (' + ltrim(str(t1.Class)) + ')' as Class,
		rtrim(t1.SClass_Name) + ' (' + ltrim(str(t1.SClass)) + ')' as SClass,
		sum(t2.Week1Dollars) as lyWeek1Dollars
into	Staging.dbo.dept16_wk1ly
from	reference.dbo.item_master t1,
		dssdata.dbo.three_week_sales t2,
		dssdata.dbo.weekly_sales t3
where	t1.Dept = 16
and		t2.sku_number = t1.sku_number
and		t3.sku_number = t1.sku_number
and		t3.day_date = @wk1ly
group by t3.Store_Number,t1.Dept_Name,t1.SDept,t1.SDept_Name,t1.Class,t1.Class_Name,t1.SClass,t1.SClass_Name
order by t3.store_number,t1.SDept,t1.Class,t1.sclass
--
select	t3.Store_Number,
		rtrim(t1.SDept_Name) + ' (' + ltrim(str(t1.SDept)) + ')' as SDept,
		rtrim(t1.Class_Name) + ' (' + ltrim(str(t1.Class)) + ')' as Class,
		rtrim(t1.SClass_Name) + ' (' + ltrim(str(t1.SClass)) + ')' as SClass,
		sum(t2.Week1Dollars) as lyWeek2Dollars
into	Staging.dbo.dept16_wk2ly
from	reference.dbo.item_master t1,
		dssdata.dbo.three_week_sales t2,
		dssdata.dbo.weekly_sales t3
where	t1.Dept = 16
and		t2.sku_number = t1.sku_number
and		t3.sku_number = t1.sku_number
and		t3.day_date = @wk2ly
group by t3.Store_Number,t1.Dept_Name,t1.SDept,t1.SDept_Name,t1.Class,t1.Class_Name,t1.SClass,t1.SClass_Name
order by t3.store_number,t1.SDept,t1.Class,t1.sclass
--
select	t3.Store_Number,
		rtrim(t1.SDept_Name) + ' (' + ltrim(str(t1.SDept)) + ')' as SDept,
		rtrim(t1.Class_Name) + ' (' + ltrim(str(t1.Class)) + ')' as Class,
		rtrim(t1.SClass_Name) + ' (' + ltrim(str(t1.SClass)) + ')' as SClass,
		sum(t2.Week1Dollars) as lyWeek3Dollars
into	staging.dbo.dept16_wk3ly
from	reference.dbo.item_master t1,
		dssdata.dbo.three_week_sales t2,
		dssdata.dbo.weekly_sales t3
where	t1.Dept = 16
and		t2.sku_number = t1.sku_number
and		t3.sku_number = t1.sku_number
and		t3.day_date = @wk3ly
group by t3.Store_Number,t1.Dept_Name,t1.SDept,t1.SDept_Name,t1.Class,t1.Class_Name,t1.SClass,t1.SClass_Name
order by t3.store_number,t1.SDept,t1.Class,t1.sclass
--
-- Get TY YTD numbers
--
select	t3.Store_Number,
		rtrim(t1.SDept_Name) + ' (' + ltrim(str(t1.SDept)) + ')' as SDept,
		rtrim(t1.Class_Name) + ' (' + ltrim(str(t1.Class)) + ')' as Class,
		rtrim(t1.SClass_Name) + ' (' + ltrim(str(t1.SClass)) + ')' as SClass,
		sum(t2.Week1Dollars) as TYDollars
into	Staging.dbo.dept16_TY
from	reference.dbo.item_master t1,
		dssdata.dbo.three_week_sales t2,
		dssdata.dbo.weekly_sales t3
where	t1.Dept = 16
and		t2.sku_number = t1.sku_number
and		t3.sku_number = t1.sku_number
and		t3.day_date >= @TY
group by t3.Store_Number,t1.Dept_Name,t1.SDept,t1.SDept_Name,t1.Class,t1.Class_Name,t1.SClass,t1.SClass_Name
order by t3.store_number,t1.SDept,t1.Class,t1.sclass
--
-- Get LY Numbers
--
select	t3.Store_Number,
		rtrim(t1.SDept_Name) + ' (' + ltrim(str(t1.SDept)) + ')' as SDept,
		rtrim(t1.Class_Name) + ' (' + ltrim(str(t1.Class)) + ')' as Class,
		rtrim(t1.SClass_Name) + ' (' + ltrim(str(t1.SClass)) + ')' as SClass,
		sum(t2.Week1Dollars) as LYDollars
into	Staging.dbo.dept16_LY
from	reference.dbo.item_master t1,
		dssdata.dbo.three_week_sales t2,
		dssdata.dbo.weekly_sales t3
where	t1.Dept = 16
and		t2.sku_number = t1.sku_number
and		t3.sku_number = t1.sku_number
and		t3.day_date >= @LY 
and		t3.day_date <= dateadd(yy,-1,getdate())
group by t3.Store_Number,t1.Dept_Name,t1.SDept,t1.SDept_Name,t1.Class,t1.Class_Name,t1.SClass,t1.SClass_Name
order by t3.store_number,t1.SDept,t1.Class,t1.sclass

select	t1.store_number,
		t1.SDept,
		t1.Class,
		t1.SClass,
		t1.Week1Dollars,
		t4.lyweek1dollars,
		t2.Week2Dollars,
		t5.lyweek2dollars,
		t3.Week3Dollars,
		t6.lyweek3dollars,
		t7.TYDollars,
		t8.LYDollars
into	reportdata.dbo.Dept16_Store
from	staging.dbo.dept16_wk1 t1,
		staging.dbo.dept16_wk2 t2,
		staging.dbo.dept16_wk3 t3,
		staging.dbo.dept16_wk1ly t4,
		staging.dbo.dept16_wk2ly t5,
		staging.dbo.dept16_wk3ly t6,
		staging.dbo.Dept16_TY t7,
		staging.dbo.Dept16_ly t8
where	t2.store_number = t1.store_number
and		t3.store_number = t1.store_number
and		t4.store_number = t1.store_number
and		t5.store_number = t1.store_number
and		t6.store_number = t1.store_number
and		t7.store_number = t1.store_number
and		t8.store_number = t1.store_number
and		t2.sdept = t1.sdept
and		t3.sdept = t1.sdept
and		t4.sdept = t1.sdept
and		t5.sdept = t1.sdept
and		t6.sdept = t1.sdept
and		t7.sdept = t1.sdept
and		t8.sdept = t1.sdept
and		t2.class = t1.class
and		t3.class = t1.class
and		t4.class = t1.class
and		t5.class = t1.class
and		t6.class = t1.class
and		t7.class = t1.class
and		t8.class = t1.class
and		t2.sclass = t1.sclass
and		t3.sclass = t1.sclass
and		t4.sclass = t1.sclass
and		t5.sclass = t1.sclass
and		t6.sclass = t1.sclass
and		t7.sclass = t1.sclass
and		t8.sclass = t1.sclass
GO
