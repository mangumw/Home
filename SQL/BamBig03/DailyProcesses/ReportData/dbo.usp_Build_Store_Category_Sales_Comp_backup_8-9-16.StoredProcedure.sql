USE [ReportData]
GO
/****** Object:  StoredProcedure [dbo].[usp_Build_Store_Category_Sales_Comp_backup_8-9-16]    Script Date: 8/19/2022 3:44:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[usp_Build_Store_Category_Sales_Comp_backup_8-9-16]
as
--
--drop table #StoreDept
--drop table #StoreCat
--drop table #ChainCat
--
declare @tytoday smalldatetime
declare @lytoday smalldatetime
--
declare @DOFY_TY int
declare @DOFY_LY int
declare @Fiscal_Diff int
--
declare @Fiscal_Year_Week int
--
declare @Fiscal_Qtr_TY varchar(10)
declare @Fiscal_Qtr_LY varchar(10)
--
declare @LY_End_Date smalldatetime
declare @TY_End_Date smalldatetime
declare @WTY_Start_Date smalldatetime
declare @WLY_Start_Date smalldatetime
declare @PTY_Start_Date smalldatetime
declare @PLY_Start_Date smalldatetime
--
declare @QTY_Start_Date smalldatetime
declare @QLY_Start_Date smalldatetime
--
declare @YTY_Start_Date smalldatetime
declare @YLY_Start_Date smalldatetime

declare @FY int
declare @fiscal_period int
--
select @tytoday = staging.dbo.fn_DateOnly(staging.dbo.fn_Last_Saturday(getdate()))
select @lytoday = staging.dbo.fn_dateonly(staging.dbo.fn_Last_Saturday(dateadd(yy,-1,getdate())))
--
select @DOFY_TY = day_of_fiscal_year from reference.dbo.calendar_dim where day_date = @tytoday
select @DOFY_LY = day_of_fiscal_year from reference.dbo.calendar_dim where day_date = @lytoday
select @Fiscal_Diff = @DOFY_TY - @DOFY_LY
--
select @fiscal_qtr_ty = fiscal_quarter from reference.dbo.calendar_dim where day_date = @tytoday
select @fiscal_qtr_ly = fiscal_quarter from reference.dbo.calendar_dim where day_date = @lytoday
--
select @FY = Fiscal_Year from reference.dbo.calendar_dim where day_date = @tytoday
select @fiscal_year_week = fiscal_year_week from reference.dbo.calendar_dim where day_date = @tytoday
select @TY_End_Date = staging.dbo.fn_DateOnly(staging.dbo.fn_Last_Saturday(Getdate())) --max(day_date) from reference.dbo.calendar_dim where fiscal_year_week = @fiscal_year_week - 1 and fiscal_year = @fy
select @WTY_Start_Date = min(day_date) from reference.dbo.calendar_dim where fiscal_year_week = @fiscal_year_week and fiscal_year = @fy
select @WLY_Start_Date = min(day_date) from reference.dbo.calendar_dim where fiscal_year_week = @fiscal_year_week and fiscal_year = @fy-1
--
select @fiscal_period = fiscal_period from reference.dbo.calendar_dim where day_date = @tytoday
--
select @PTY_Start_Date = min(day_date) from reference.dbo.calendar_dim where fiscal_year = @fy and fiscal_period = @fiscal_period

select @PLY_Start_Date = min(day_date) from reference.dbo.calendar_dim where fiscal_year = @fy-1 and fiscal_period = @fiscal_period
select @LY_End_Date = @WLY_Start_Date + 6
--select @LY_End_Date = staging.dbo.fn_DateOnly(dateadd(dd,2,dateadd(yy,-1,@TY_End_Date)))
--
select @QTY_Start_Date = min(day_date) from reference.dbo.calendar_dim where fiscal_quarter = @fiscal_qtr_ty
select @QLY_Start_Date = min(day_date) from reference.dbo.calendar_dim where fiscal_quarter = @fiscal_qtr_ly
--
select @YTY_Start_Date = min(day_date) from reference.dbo.calendar_dim where fiscal_year = @fy
select @YLY_Start_Date = min(day_date) from reference.dbo.calendar_dim where fiscal_year = @fy - 1
select @WTY_Start_Date,@PTY_Start_DAte,@QTY_Start_Date,@TY_End_Date
select @WlY_Start_Date,@PlY_Start_DAte,@QlY_Start_Date,@lY_End_Date




--
-- Truncate all work tables
--
truncate table Staging.dbo.StoreCat_WTD_TY
truncate table Staging.dbo.StoreCat_WTD_LY
truncate table Staging.dbo.StoreCat_PTD_TY
truncate table Staging.dbo.StoreCat_PTD_LY
truncate table Staging.dbo.StoreCat_QTD_TY
truncate table Staging.dbo.StoreCat_QTD_LY
truncate table Staging.dbo.StoreCat_YTD_TY
truncate table Staging.dbo.StoreCat_YTD_LY
--
truncate table Staging.dbo.ChainCat_WTD_TY
truncate table Staging.dbo.ChainCat_WTD_LY
truncate table Staging.dbo.ChainCat_PTD_TY
truncate table Staging.dbo.ChainCat_PTD_LY
truncate table Staging.dbo.ChainCat_QTD_TY
truncate table Staging.dbo.ChainCat_QTD_LY
truncate table Staging.dbo.ChainCat_YTD_TY
truncate table Staging.dbo.ChainCat_YTD_LY
--
-- Create base output table
--
select distinct
		Dept,
		Dept_Name,
		SDept,
		SDept_Name,
		Class,
		Class_Name
into	#depts
from	reference.dbo.item_master
where	Dept > 0 and Dept <> 87
and		Class_Name IS NOT NULL
--
select	Distinct
		t1.Store_Number,
		t1.Store_Name,
		t2.Dept,
		t2.Dept_Name,
		t2.SDept,
		t2.SDept_Name,
		t2.Class,
		t2.Class_Name
into	#StoreDept
from	reference.dbo.Comp_Stores t1,
		#depts t2
order by t1.Store_number,t2.Dept,t2.SDept,t2.Class
--
truncate table reportdata.dbo.rpt_Store_category_sales_Comp
--
insert into reportdata.dbo.rpt_Store_category_sales_comp
select	store_number,
		Store_Name,
		dept,
		dept_name,
		sdept,
		sdept_name,
		class,
		class_name,
		0,
		0,
		0,
		0,
		0,
		0,
		0,
		0,
		0,
		0,
		0,
		0,
		0,
		0,
		0,
		0
from	#StoreDept
--
-- Get This Week Store Category Sales
--
insert into	Staging.dbo.StoreCat_WTD_TY
select	t1.Store_Number,
		t2.Dept,
		t2.SDept,
		t2.Class,
		sum(t1.Current_Dollars) as WTD_TY_SLSD
from	dssdata.dbo.Weekly_Sales t1,
		reference.dbo.item_Master t2
where	t1.day_date >= @WTY_Start_Date
and		t1.day_date <= @TY_End_Date
and		t2.sku_number = t1.sku_number
group by t1.Store_Number,t2.Dept,t2.SDept,t2.Class
--select 'TY_StoreCat',@@RowCount
--
-- Get Last Year Week Store Category Sales
--
insert into	Staging.dbo.StoreCat_WTD_LY
select	t1.Store_Number as Store_Number,
		t2.Dept as Dept,
		t2.SDept as SDept,
		t2.Class as Class,
		sum(t1.Current_Dollars) as WTD_LY_SLSD
from	dssdata.dbo.Weekly_Sales t1,
		reference.dbo.item_Master t2
where	t1.day_date >= @WLY_Start_Date
and		t1.day_date <= @LY_End_Date
and		t2.sku_number = t1.sku_number
group by t1.Store_Number,t2.Dept,t2.SDept,t2.Class
--
-- Get Period To Date Store Category Sales
--
insert into	Staging.dbo.StoreCat_PTD_TY
select	t1.Store_Number,
		t2.Dept,
		t2.SDept,
		t2.Class,
		sum(t1.current_dollars) as PTD_TY_SLSD
from	dssdata.dbo.weekly_sales t1,
		reference.dbo.item_Master t2
where	t1.day_date >= @PTY_Start_Date
and		t1.day_date <= @TY_End_Date
and		t2.sku_number = t1.sku_number
group by t1.Store_Number,t2.Dept,t2.SDept,t2.Class
--
-- Get Last Year PTD Store Category Sales
--
insert into	Staging.dbo.StoreCat_PTD_LY
select	t1.Store_Number as Store_Number,
		t2.Dept as Dept,
		t2.SDept as SDept,
		t2.Class as Class,
		sum(t1.current_dollars) as PTD_LY_SLSD
from	dssdata.dbo.weekly_sales t1,
		reference.dbo.item_Master t2
where	t1.day_date >= @PLY_Start_Date
and		t1.day_date <= @LY_End_Date
and		t2.sku_number = t1.sku_number
group by t1.Store_Number,t2.Dept,t2.SDept,t2.Class
--
-- Get QTD Store Category Sales
--
insert into	Staging.dbo.StoreCat_QTD_TY
select	t1.Store_Number,
		t2.Dept,
		t2.SDept,
		t2.Class,
		sum(t1.Current_Dollars) as QTD_TY_SLSD
from	dssdata.dbo.Weekly_Sales t1,
		reference.dbo.item_Master t2
where	t1.day_date >= @QTY_Start_Date
and		t1.day_date <= @TY_End_Date
and		t2.sku_number = t1.sku_number
group by t1.Store_Number,t2.Dept,t2.SDept,t2.Class
--
-- Get Last Year QTD Store Category Sales
--
insert into	Staging.dbo.StoreCat_QTD_LY
select	t1.Store_Number as Store_Number,
		t2.Dept as Dept,
		t2.SDept as SDept,
		t2.Class as Class,
		sum(t1.Current_Dollars) as QTD_LY_SLSD
from	dssdata.dbo.Weekly_Sales t1,
		reference.dbo.item_Master t2
where	t1.day_date >= @QLY_Start_Date
and		t1.day_date <= @LY_End_Date
and		t2.sku_number = t1.sku_number
group by t1.Store_Number,t2.Dept,t2.SDept,t2.Class
--
-- Get YTD Store Category Sales
--
insert into	Staging.dbo.StoreCat_YTD_TY
select	t1.Store_Number as Store_Number,
		t2.Dept as Dept,
		t2.SDept as SDept,
		t2.Class as Class,
		sum(t1.Current_Dollars) as YTD_TY_SLSD
from	dssdata.dbo.Weekly_Sales t1,
		reference.dbo.item_Master t2
where	t1.day_date >= @YTY_Start_Date
and		t1.day_date <= @TY_End_Date
and		t2.sku_number = t1.sku_number
group by t1.Store_Number,t2.Dept,t2.SDept,t2.Class
--
-- Get LY YTD Store Category Sales
--
insert into	Staging.dbo.StoreCat_YTD_LY
select	t1.Store_Number as Store_Number,
		t2.Dept as Dept,
		t2.SDept as SDept,
		t2.Class as Class,
		sum(t1.Current_Dollars) as YTD_LY_SLSD
from	dssdata.dbo.Weekly_Sales t1,
		reference.dbo.item_Master t2
where	t1.day_date >= @YLY_Start_Date
and		t1.day_date <= @LY_End_Date
and		t2.sku_number = t1.sku_number
group by t1.Store_Number,t2.Dept,t2.SDept,t2.Class
--
-- Get This week Chain Cat Sales
--
insert into	Staging.dbo.ChainCat_WTD_TY
select	t2.Dept,
		t2.SDept,
		t2.Class,
		sum(t1.Current_Dollars) as WTD_TY_Chain
from	dssdata.dbo.Weekly_Sales t1,
		Reference.dbo.Item_Master t2,
		reference.dbo.comp_stores t3
where	t1.day_date >= @WTY_Start_Date
and		t1.day_date <= @TY_End_Date
and		t2.Sku_Number = t1.Sku_Number
--and		t3.start_date <= @QTY_Start_Date
--and		t3.end_date >= @QTY_Start_Date
and		t1.store_number = t3.store_number
group by t2.Dept,t2.SDept,t2.Class
--
-- Get LY WTD Chain Cat Sales
--
insert into	Staging.dbo.ChainCat_WTD_LY
select	t2.Dept,
		t2.SDept,
		t2.Class,
		sum(t1.Current_Dollars) as WTD_LY_Chain
from	dssdata.dbo.Weekly_Sales t1,
		Reference.dbo.Item_Master t2,
		reference.dbo.comp_stores t3
where	t1.day_date >= @WLY_Start_Date
and		t1.day_date <= @LY_End_Date
and		t2.sku_number = t1.sku_number
--and		t3.start_date <= @QTY_Start_Date
--and		t3.end_date >= @QTY_Start_Date
and		t1.store_number = t3.store_number
group by t2.Dept,t2.SDept,t2.Class
--
-- Get PTD Chain Cat Sales
--
insert into	Staging.dbo.ChainCat_PTD_TY
select	t2.Dept,
		t2.SDept,
		t2.Class,
		sum(t1.Current_Dollars) as PTD_TY_Chain
from	dssdata.dbo.Weekly_Sales t1,
		Reference.dbo.Item_Master t2,
		reference.dbo.comp_stores t3
where	t1.day_date >= @PTY_Start_Date
and		t1.day_date <= @TY_End_Date
and		t2.Sku_Number = t1.Sku_Number
--and		t3.start_date <= @QTY_Start_Date
--and		t3.end_date >= @QTY_Start_Date
and		t1.store_number = t3.store_number
group by t2.Dept,t2.SDept,t2.Class
--
-- Get LY PTD Chain Cat Sales
--
insert into	Staging.dbo.ChainCat_PTD_LY
select	t2.Dept,
		t2.SDept,
		t2.Class,
		sum(t1.Current_Dollars) as PTD_LY_Chain
from	dssdata.dbo.Weekly_Sales t1,
		Reference.dbo.Item_Master t2,
		reference.dbo.comp_stores t3
where	t1.day_date >= @PLY_Start_Date
and		t1.day_date <= @LY_End_Date
and		t2.sku_number = t1.sku_number
--and		t3.start_date <= @QTY_Start_Date
--and		t3.end_date >= @QTY_Start_Date
and		t1.store_number = t3.store_number
group by t2.Dept,t2.SDept,t2.Class
--
--
-- Get QTD Chain Cat Sales
--
insert into	Staging.dbo.ChainCat_QTD_TY
select	t2.Dept,
		t2.SDept,
		t2.Class,
		sum(t1.Current_Dollars) as QTD_TY_Chain
from	dssdata.dbo.Weekly_Sales t1,
		Reference.dbo.Item_Master t2,
		reference.dbo.comp_stores t3
where	t1.day_date >= @QTY_Start_Date
and		t1.day_date <= @TY_End_Date
and		t2.Sku_Number = t1.Sku_Number
--and		t3.start_date <= @QTY_Start_Date
--and		t3.end_date >= @QTY_Start_Date
and		t1.store_number = t3.store_number
group by t2.Dept,t2.SDept,t2.Class
--
-- Get LY QTD Chain Cat Sales
--
insert into	Staging.dbo.ChainCat_QTD_LY
select	t2.Dept,
		t2.SDept,
		t2.Class,
		sum(t1.current_dollars) as QTD_LY_Chain
from	dssdata.dbo.Weekly_Sales t1,
		Reference.dbo.Item_Master t2,
		reference.dbo.comp_stores t3
where	t1.day_date >= @QLY_Start_Date
and		t1.day_date <= @LY_End_Date
and		t2.sku_number = t1.sku_number
--and		t3.start_date <= @QTY_Start_Date
--and		t3.end_date >= @QTY_Start_Date
and		t1.store_number = t3.store_number
group by t2.Dept,t2.SDept,t2.Class
--
-- Get YTD Chain Cat Sales
--
insert into	Staging.dbo.ChainCat_YTD_TY
select	t2.Dept,
		t2.SDept,
		t2.Class,
		sum(t1.Current_Dollars) as YTD_TY_Chain
from	dssdata.dbo.Weekly_Sales t1,
		Reference.dbo.Item_Master t2,
		reference.dbo.comp_stores t3
where	t1.day_date >= @YTY_Start_Date
and		t1.day_date <= @TY_End_Date
and		t2.Sku_Number = t1.Sku_Number
--and		t3.start_date <= @QTY_Start_Date
--and		t3.end_date >= @QTY_Start_Date
and		t1.store_number = t3.store_number
group by t2.Dept,t2.SDept,t2.Class
--
-- Get YTD Chain Cat Sales LY
--
insert into	Staging.dbo.ChainCat_YTD_LY
select	t2.Dept,
		t2.SDept,
		t2.Class,
		sum(t1.Current_Dollars) as YTD_LY_Chain
from	dssdata.dbo.Weekly_Sales t1,
		Reference.dbo.Item_Master t2,
		reference.dbo.comp_stores t3
where	t1.day_date >= @YLY_Start_Date
and		t1.day_date <= @LY_End_Date
and		t2.Sku_Number = t1.Sku_Number
--and		t3.start_date <= @QTY_Start_Date
--and		t3.end_date >= @QTY_Start_Date
and		t1.store_number = t3.store_number
group by t2.Dept,t2.SDept,t2.Class
--
-- Combine tmp tables to Interim tables
--
select	t1.Store_Number,
		t1.Dept,
		t1.Dept_Name,
		t1.SDept,
		t1.SDept_Name,
		t1.Class,
		t1.Class_Name,
		t2.WTD_TY_SLSD,
		t3.WTD_LY_SLSD,
		t4.PTD_TY_SLSD,
		t5.PTD_LY_SLSD,
		t6.QTD_TY_SLSD,
		t7.QTD_LY_SLSD,
		t8.YTD_TY_SLSD,
		t9.YTD_LY_SLSD
into	#StoreCat
from	reportdata.dbo.rpt_Store_Category_Sales_Comp t1 
left join staging.dbo.StoreCat_WTD_TY t2
on		t2.Store_Number = t1.Store_Number
and		t2.Dept = t1.Dept
and		t2.SDept = t1.SDept
and		t2.Class = t1.Class
left join staging.dbo.StoreCat_WTD_LY t3
on		t3.Store_Number = t1.Store_Number
and		t3.Dept = t1.Dept
and		t3.SDept = t1.SDept
and		t3.Class = t1.Class
left join staging.dbo.StoreCat_PTD_TY t4
on		t4.Store_Number = t1.Store_Number
and		t4.Dept = t1.Dept
and		t4.SDept = t1.SDept
and		t4.Class = t1.Class
left join staging.dbo.StoreCat_PTD_LY t5
on		t5.Store_Number = t1.Store_Number
and		t5.Dept = t1.Dept
and		t5.SDept = t1.SDept
and		t5.Class = t1.Class
left join staging.dbo.StoreCat_QTD_TY t6
on		t6.Store_Number = t1.Store_Number
and		t6.Dept = t1.Dept
and		t6.SDept = t1.SDept
and		t6.Class = t1.Class
left join staging.dbo.StoreCat_QTD_LY t7
on		t7.Store_Number = t1.Store_Number
and		t7.Dept = t1.Dept
and		t7.SDept = t1.SDept
and		t7.Class = t1.Class
left join staging.dbo.StoreCat_YTD_TY t8
on		t8.Store_Number = t1.Store_Number
and		t8.Dept = t1.Dept
and		t8.SDept = t1.SDept
and		t8.Class = t1.Class
left join staging.dbo.StoreCat_YTD_LY t9
on		t9.Store_Number = t1.Store_Number
and		t9.Dept = t1.Dept
and		t9.SDept = t1.SDept
and		t9.Class = t1.Class
--
select	t1.Dept,
		t1.Dept_Name,
		t1.SDept,
		t1.SDept_Name,
		t1.Class,
		t1.Class_Name,
		t2.WTD_TY_Chain,
		t3.WTD_LY_Chain,
		t4.PTD_TY_Chain,
		t5.PTD_LY_Chain,
		t6.QTD_TY_Chain,
		t7.QTD_LY_Chain,
		t8.YTD_TY_Chain,
		t9.YTD_LY_Chain
into	#ChainCat
from	#Depts t1 
left join staging.dbo.ChainCat_WTD_TY t2
on		t2.Dept = t1.Dept
and		t2.SDept = t1.SDept
and		t2.Class = t1.Class
left join staging.dbo.ChainCat_WTD_LY t3
on		t3.Dept = t1.Dept
and		t3.SDept = t1.SDept
and		t3.Class = t1.Class
left join staging.dbo.ChainCat_PTD_TY t4
on		t4.Dept = t1.Dept
and		t4.SDept = t1.SDept
and		t4.Class = t1.Class
left join staging.dbo.ChainCat_PTD_LY t5
on		t5.Dept = t1.Dept
and		t5.SDept = t1.SDept
and		t5.Class = t1.Class
left join staging.dbo.ChainCat_QTD_TY t6
on		t6.Dept = t1.Dept
and		t6.SDept = t1.SDept
and		t6.Class = t1.Class
left join staging.dbo.ChainCat_QTD_LY t7
on		t7.Dept = t1.Dept
and		t7.SDept = t1.SDept
and		t7.Class = t1.Class
left join staging.dbo.ChainCat_YTD_TY t8
on		t8.Dept = t1.Dept
and		t8.SDept = t1.SDept
and		t8.Class = t1.Class
left join staging.dbo.ChainCat_YTD_LY t9
on		t9.Dept = t1.Dept
and		t9.SDept = t1.SDept
and		t9.Class = t1.Class
--
-- Combine interim tables into final report table
----
--truncate table reportdata.dbo.rpt_store_category_sales_Comp
--insert into reportdata.dbo.rpt_store_category_sales_Comp
--select	t1.store_number,
--		t3.Store_Name,
--		t1.Dept,
--		t1.Dept_Name,
--		t1.SDept,
--		t1.SDept_Name,
--		t1.Class,
--		t1.Class_Name,
--		isnull(t1.WTD_TY_SLSD,0),
--		isnull(t1.WTD_LY_SLSD,0),
--		isnull(t1.PTD_TY_SLSD,0),
--		isnull(t1.PTD_LY_SLSD,0),
--		isnull(t1.QTD_TY_SLSD,0),
--		isnull(t1.QTD_LY_SLSD,0),
--		isnull(t1.YTD_TY_SLSD,0),
--		isnull(t1.YTD_LY_SLSD,0),
--		isnull(t2.WTD_TY_Chain,0),
--		isnull(t2.WTD_LY_Chain,0),
--		isnull(t2.PTD_TY_Chain,0),
--		isnull(t2.PTD_LY_Chain,0),
--		isnull(t2.QTD_TY_Chain,0),
--		isnull(t2.QTD_LY_Chain,0),
--		isnull(t2.YTD_TY_Chain,0),
--		isnull(t2.YTD_LY_Chain,0)
--from	#StoreCat t1,
--		#ChainCat t2,
--		reference.dbo.Comp_stores t3
--where	t2.Dept = t1.Dept
--and		t2.SDept = t1.SDept
--and		t2.Class = t1.Class
--and		t3.store_number = t1.store_number
--
--
		
update	reportdata.dbo.rpt_store_category_sales_Comp
set		wtd_ty_Store = #storecat.WTD_TY_SLSD,
		wtd_ly_Store = #storecat.WTD_LY_SLSD,
		Ptd_ty_Store = #storecat.PTD_TY_SLSD,
		Ptd_Ly_Store = #storecat.PTD_LY_SLSD,
		Qtd_ty_Store = #storecat.QTD_TY_SLSD,
		Qtd_Ly_Store = #storecat.QTD_LY_SLSD,
		Ytd_ty_Store = #storecat.YTD_TY_SLSD,
		Ytd_Ly_Store = #storecat.YTD_LY_SLSD
from	#StoreCat
where	reportdata.dbo.rpt_store_category_sales_Comp.store_number = #storecat.store_number
and		reportdata.dbo.rpt_store_category_sales_Comp.dept = #storecat.dept
and		reportdata.dbo.rpt_store_category_sales_Comp.sdept = #storecat.sdept
and		reportdata.dbo.rpt_store_category_sales_Comp.class = #storecat.class
--
update	reportdata.dbo.rpt_store_category_sales_Comp
set		wtd_ty_chain = #chaincat.WTD_TY_chain,
		wtd_ly_chain = #chaincat.WTD_LY_chain,
		Ptd_ty_chain = #chaincat.PTD_TY_chain,
		Ptd_Ly_chain = #chaincat.PTD_LY_chain,
		Qtd_ty_chain = #chaincat.QTD_TY_chain,
		Qtd_Ly_chain = #chaincat.QTD_LY_chain,
		Ytd_ty_chain = #chaincat.YTD_TY_chain,
		Ytd_Ly_chain = #chaincat.YTD_LY_chain
from	#chainCat
where	reportdata.dbo.rpt_store_category_sales_Comp.dept = #chaincat.dept
and		reportdata.dbo.rpt_store_category_sales_Comp.sdept = #chaincat.sdept
and		reportdata.dbo.rpt_store_category_sales_Comp.class = #chaincat.class





GO
