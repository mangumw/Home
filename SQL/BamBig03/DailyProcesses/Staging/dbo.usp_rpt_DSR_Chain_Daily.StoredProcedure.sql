USE [Staging]
GO
/****** Object:  StoredProcedure [dbo].[usp_rpt_DSR_Chain_Daily]    Script Date: 8/19/2022 3:41:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[usp_rpt_DSR_Chain_Daily]
as
--
declare @Fiscal_Year int
declare @Fiscal_Period int
declare @Fiscal_Quarter varchar(8)
--
declare @TYYES smalldatetime
declare @LYYES smalldatetime
declare @TYWS smalldatetime
declare @LYWS smalldatetime
declare @TYPS smalldatetime
declare @LYPS smalldatetime
declare @TYQS smalldatetime
declare @LYQS smalldatetime
declare @TYYS smalldatetime
declare @LYYS smalldatetime
--
-- Get Yesterday, Week, Period, Quarter and Year Dates
--
select @TYYES = Dateadd(dd,-1,staging.dbo.fn_DateOnly(Getdate()))
select @LYYES = Dateadd(yy,-1,@TYYES)
--
select @fiscal_year = Fiscal_Year from reference.dbo.Calendar_Dim where day_date = @TYYES
select @fiscal_Period = Fiscal_Period from reference.dbo.Calendar_Dim where day_date = @TYYES
select @fiscal_Quarter = Fiscal_Quarter from reference.dbo.Calendar_Dim where day_date = @TYYES
--
select @TYWS = dateadd(dd,1,staging.dbo.fn_Last_Saturday(@TYYES))
select @LYWS = dateadd(dd,1,staging.dbo.fn_Last_Saturday(dateadd(yy,-1,@TYYES)))
--
select @TYPS = min(day_date) from reference.dbo.Calendar_Dim where fiscal_year = @fiscal_Year and fiscal_period = @Fiscal_period
select @LYPS = min(day_date) from reference.dbo.Calendar_Dim where fiscal_year = @fiscal_Year - 1 and fiscal_period = @Fiscal_period
--
select @TYQS = min(day_date) from reference.dbo.Calendar_Dim where fiscal_quarter = @fiscal_quarter
select @fiscal_Quarter = Fiscal_Quarter from reference.dbo.Calendar_Dim where day_date = dateadd(yy,-1,@TYYES)
select @LYQS = min(day_date) from reference.dbo.Calendar_Dim where fiscal_quarter = @fiscal_quarter
--
Select @TYYS = day_date from reference.dbo.Calendar_Dim where Fiscal_Year = @fiscal_Year and day_of_fiscal_year = 1
select @LYYS = day_date from reference.dbo.Calendar_Dim where Fiscal_Year = @fiscal_Year - 1 and day_of_fiscal_year = 1
--
-- End of Date Setup
--
-- Get Yesterday DSR Comp
--
select	t1.Dept,
		sum(Extended_Price) as TYYES_Comp
into	#TYYES_Comp
from	dssdata.dbo.Dsr_Store_Daily t1,
		reference.dbo.Comp_Stores_History t2
where	t1.day_date = @TYYES
and		t2.start_date <= @TYYES
and		t2.End_Date >= @TYYES
and		t1.store_number = t2.store_number
group by dept
--
-- Get Yesterday DSR All Stores
--
select	Dept,
		sum(Extended_Price) as TYYES_All
into	#TYYES_All
from	dssdata.dbo.Dsr_Store_Daily t1
where	t1.day_date = @TYYES
group by dept
--
-- Get Yesterday Comp Budget
--select	@TY_Daily_Comp_Bud = Comp_Stores
--from	reference.dbo.DSR_Daily_Budget
--where	day_date = @TYYES
----
---- Get Yesterday All Stores Budget
--select	@TY_Daily_All_Bud = All_Stores
--from	reference.dbo.DSR_Daily_Budget
--where	day_date = @TYYES
--
-- Get WTD DSR Comp Stores
--
select	Dept,
		sum(Extended_Price) as TYWTD_Comp
into	#TYWTD_Comp
from	dssdata.dbo.Dsr_Store_Daily t1,
		reference.dbo.Comp_Stores_History t2
where	t1.day_date >= @TYWS
and		t2.start_date <= t1.day_date
and		t2.End_Date >= t1.day_date
and		t1.store_number = t2.store_number
group by dept
--
-- Get WTD All Stores
--
select	Dept,
		sum(Extended_Price) as TYWTD_All
into	#TYWTD_All
from	dssdata.dbo.Dsr_Store_Daily t1
where	t1.day_date >= @TYWS
group by dept
--
-- Get WTD Comp Budget
--
--select	@TY_WTD_Comp_Bud = sum(Comp_Stores)
--from	reference.dbo.DSR_Daily_Budget
--where	day_date >= @TYWS
----
---- Get WTD All Stores Budget
----
--select	@TY_WTD_All_Bud = sum(All_Stores)
--from	reference.dbo.DSR_Daily_Budget
--where	day_date >= @TYWS
--
-- Get PTD DSR Comp Stores
--
select	Dept,
		sum(Extended_Price) as TYPTD_Comp
into	#TYPTD_Comp
from	dssdata.dbo.Dsr_Store_Daily t1,
		reference.dbo.Comp_Stores_History t2
where	t1.day_date >= @TYPS
and		t2.start_date <= t1.day_date
and		t2.End_Date >= t1.day_date
and		t1.store_number = t2.store_number
group by dept
--
-- Get PTD All Stores
--
select	Dept,
		sum(Extended_Price) as TYPTD_All
into	#TYPTD_All
from	dssdata.dbo.Dsr_Store_Daily t1
where	t1.day_date >= @TYPS
group by dept
--
--
-- Get PTD Comp Budget
--
--select @TY_PTD_Comp_Bud = sum(Comp_Stores)
--from	reference.dbo.DSR_Daily_Budget
--where	day_date >= @TYPS
----
---- Get PTD All Stores Budget
----
--select	@TY_PTD_All_Bud = sum(All_Stores)
--from	reference.dbo.DSR_Daily_Budget
--where	day_date >= @TYPS
--
-- Get QTD Comp Stores
--
select	Dept,
		sum(Extended_Price) as TYQTD_Comp
into	#TYQTD_Comp
from	dssdata.dbo.Dsr_Store_Daily t1,
		reference.dbo.Comp_Stores_History t2
where	t1.day_date >= @TYQS
and		t2.start_date <= t1.day_date
and		t2.End_Date >= t1.day_date
and		t1.store_number = t2.store_number
group by dept
--
-- Get QTD All Stores
--
select	Dept,
		sum(Extended_Price) as TYQTD_All
into	#TYQTD_All
from	dssdata.dbo.Dsr_Store_Daily t1
where	t1.day_date >= @TYQS
group by dept
--
-- Get QTD Comp Budget
--
--select	@TY_QTD_Comp_Bud = sum(Comp_Stores)
--from	reference.dbo.DSR_Daily_Budget
--where	day_date >= @TYQS
----
---- Get QTD All Stores Budget
----
--select	@TY_QTD_All_Bud = sum(All_Stores)
--from	reference.dbo.DSR_Daily_Budget
--where	day_date >= @TYQS
--
-- Get YTD Comp Stores
--
select	Dept,
		sum(Extended_Price) as TYYTD_Comp
into	#TYYTD_Comp
from	dssdata.dbo.Dsr_Store_Daily t1,
		reference.dbo.Comp_Stores_History t2
where	t1.day_date >= @TYYS
and		t2.start_date <= t1.day_date
and		t2.End_Date >= t1.day_date
and		t1.store_number = t2.store_number
group by dept
--
-- Get YTD All Stores
--
select	Dept,
		sum(Extended_Price) as TYYTD_All
into	#TYYTD_All
from	dssdata.dbo.Dsr_Store_Daily t1
where	t1.day_date >= @TYYS
group by dept
--
-- Get YTD Comp Budget
--
--select	@TY_YTD_Comp_Bud = sum(Comp_Stores)
--from	reference.dbo.DSR_Daily_Budget
--where	day_date >= @TYYS
----
---- Get YTD All Stores Budget
----
--select	@TY_YTD_All_Bud = sum(All_Stores)
--from	reference.dbo.DSR_Daily_Budget
--where	day_date >= @TYYS
--
-- Get Last Year Data For Each Break
--
-- Get Yesterday DSR Comp
--
select	Dept,
		sum(Extended_Price) as LYYES_Comp
into	#LYYES_Comp
from	dssdata.dbo.Dsr_Store_Daily t1,
		reference.dbo.Comp_Stores_History t2
where	t1.day_date = @LYYES
and		t1.day_date <= @LYYES
and		t2.start_date <= @LYYES
and		t2.End_Date >= @LYYES
and		t1.store_number = t2.store_number
group by dept
--
-- Get Yesterday DSR All Stores
--
select	Dept,
		sum(Extended_Price) as LYYES_All
into	#LYYES_All
from	dssdata.dbo.Dsr_Store_Daily t1
where	t1.day_date = @LYYES
group by dept
--
-- Get WTD DSR Comp Stores
--
select	Dept,
		sum(Extended_Price) as LYWTD_Comp
into	#LYWTD_Comp
from	dssdata.dbo.Dsr_Store_Daily t1,
		reference.dbo.Comp_Stores_History t2
where	t1.day_date >= @LYWS
and		t1.day_date <= @LYYES
and		t2.start_date <= t1.day_date
and		t2.End_Date >= t1.day_date
and		t1.store_number = t2.store_number
group by dept
--
-- Get WTD All Stores
--
select	Dept,
		sum(Extended_Price) as LYWTD_All
into	#LYWTD_All
from	dssdata.dbo.Dsr_Store_Daily t1
where	t1.day_date >= @LYWS
and		t1.day_date <= @LYYES
group by dept
--
-- Get PTD DSR Comp Stores
--
select	Dept,
		sum(Extended_Price) as LYPTD_Comp
into	#LYPTD_Comp
from	dssdata.dbo.Dsr_Store_Daily t1,
		reference.dbo.Comp_Stores_History t2
where	t1.day_date >= @LYPS
and		t1.day_date <= @LYYES
and		t2.start_date <= t1.day_date
and		t2.End_Date >= t1.day_date
and		t1.store_number = t2.store_number
group by dept
--
-- Get PTD All Stores
--
select	Dept,
		sum(Extended_Price) as LYPTD_All
into	#LYPTD_All
from	dssdata.dbo.Dsr_Store_Daily t1
where	t1.day_date >= @LYPS
and		t1.day_date <= @LYYES
group by dept
--
-- Get QTD Comp Stores
--
select	Dept,
		sum(Extended_Price) as LYQTD_Comp_All
into	#LYQTD_Comp_All
from	dssdata.dbo.Dsr_Store_Daily t1,
		reference.dbo.Comp_Stores_History t2
where	t1.day_date >= @LYQS
and		t1.day_date <= @LYYES
and		t2.start_date <= t1.day_date
and		t2.End_Date >= t1.day_date
and		t1.store_number = t2.store_number
group by dept
--
-- Get QTD All Stores
--
select	Dept,
		sum(Extended_Price) as LYQTD_All
into	#LYQTDF_All
from	dssdata.dbo.Dsr_Store_Daily t1
where	t1.day_date >= @LYQS
and		t1.day_date <= @LYYES
group by dept
--
-- Get YTD Comp Stores
--
select	Dept,
		sum(Extended_Price) as LYYTD_Comp
into	#LYYTD_Comp
from	dssdata.dbo.Dsr_Store_Daily t1,
		reference.dbo.Comp_Stores_History t2
where	t1.day_date >= @LYYS
and		t1.day_date <= @LYYES
and		t2.start_date <= t1.day_date
and		t2.End_Date >= t1.day_date
and		t1.store_number = t2.store_number
group by dept
--
-- Get YTD All Stores
--
select	Dept,
		sum(Extended_Price) as LYYTD_All
into	#LYYTD_All
from	dssdata.dbo.Dsr_Store_Daily t1
where	t1.day_date >= @LYYS
and		t1.day_date <= @LYYES
group by dept
--
-- Get list of Depts
--
select	Distinct t1.Dept,
		t2.dept_name
into	#Depts
from	dssdata.dbo.DSR_Store_Daily t1,
		reference.dbo.invdpt t2
where	t2.dept = t1.dept
--
-- Construct Output Table
--
select	t0.Dept,
		t0.Dept_Name,
		t1.TYYES_Comp,
		t2.TYYES_All,
		t3.TYWTD_Comp,
		t4.TYWTD_All,
		t5.TYPTD_Comp,
		t6.TYPTD_All,
		t7.TYQTD_Comp,
		t8.TYQTD_All,
		t9.TYYTD_Comp,
		t10.TYYTD_All,
		t11.LYYES_Comp,
		t12.LYYES_All,
		t13.LYWTD_Comp,
		t14.LYWTD_All,
		t15.LYPTD_Comp,
		t16.LYPTD_All,
		t17.LYQTD_Comp,
		t18.LYQTD_All,
		t19.LYYTD_Comp,
		t20.LYYTD_All
from	#Depts t0 left join
		#TYYES_Comp t1 on t1.dept = t0.dept
		left join #TYYES_All t2 on t2.dept = t0.dept
		left join #TYWTD_Comp t3 on t3.dept = t0.dept
		left join #TYWTD_All t4 on t4.dept = t0.dept
		left join #TYPTD_Comp t5 on t5.dept = t0.dept
		left join #TYPTD_All t6 on t6.dept = t0.dept
		left join #TYQTD_Comp t7 on t7.dept = t0.dept
		left join #TYQTD_All t8 on t8.dept = t0.dept
		left join #TYYTD_Comp t9 on t9.dept = t0.dept
		left join #TYYTD_All t10 on t10.dept = t0.dept
		left join #LYYES_Comp t11 on t11.dept = t0.dept
		left join #LYYES_All t12 on t12.dept = t0.dept
		left join #LYWTD_Comp t13 on t13.dept = t0.dept
		left join #LYWTD_All t14 on t14.dept = t0.dept
		left join #LYPTD_Comp t15 on t15.dept = t0.dept
		left join #LYPTD_All t16 on t16.dept = t0.dept
		left join #LYQTD_Comp t17 on t17.dept = t0.dept
		left join #LYQTD_All t18 on t18.dept = t0.dept
		left join #LYYTD_Comp t19 on t19.dept = t0.dept
		left join #LYYTD_All t20 on t20.dept = t0.dept
GO
