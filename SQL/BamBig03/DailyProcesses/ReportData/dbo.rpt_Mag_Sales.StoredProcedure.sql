USE [ReportData]
GO
/****** Object:  StoredProcedure [dbo].[rpt_Mag_Sales]    Script Date: 8/19/2022 3:44:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[rpt_Mag_Sales]
as
--
declare @WTD		smalldatetime
declare @MTD		smalldatetime
declare @QTD		smalldatetime
declare @YTD		smalldatetime
declare @DateTmp	varchar(30)
declare @FY			int
declare @seldate	smalldatetime
declare @period		int
declare @Qtr		varchar(10)
declare @FW         int
declare @FQ         int
declare @sql        Nvarchar(1000)
declare @YearDays	float
declare @YTD_Perc	float
declare @EOY		smalldatetime

--
-- Build Work Tables
--
truncate table staging.dbo.mag_daily
truncate table staging.dbo.mag_WTD
truncate table staging.dbo.mag_MTD
truncate table staging.dbo.mag_QTD
truncate table staging.dbo.mag_YTD
truncate table reportdata.dbo.rpt_mag_sales_report
--
select @seldate = staging.dbo.fn_DateOnly(dateadd(dd,-1,getdate()))
select @FW = Fiscal_Year_Week from reference.dbo.calendar_dim where day_date = @seldate
select @FQ = right(fiscal_quarter,1) from reference.dbo.calendar_dim where day_date = @seldate
select @period = fiscal_period from reference.dbo.calendar_dim where day_date = @seldate
select @fy = fiscal_year from reference.dbo.calendar_dim where day_date = @seldate
--
-- calc ytd %
--
select @EOY = max(day_date) from reference.dbo.calendar_dim where fiscal_year = @fy
select @yearDays = datediff(dd,getdate(),@EOY)
select @YTD_Perc = 1.0 - (@YearDays / 365.0)
--
-- Calc Beginning of this week
--
select @WTD = staging.dbo.fn_Last_Saturday(@seldate)
select @WTD = dateadd(dd,1,@WTD)
--
-- Calc Beginning of this Period
--
select @MTD = day_date from reference.dbo.calendar_dim 
			where day_of_period = 1 and fiscal_period = @period and fiscal_year = @fy
--
-- Calc Beginning of this quarter
--
select @FY = Fiscal_Year from reference.dbo.Calendar_Dim where day_date = staging.dbo.fn_DateOnly(Getdate())
select @Qtr = fiscal_quarter from reference.dbo.calendar_dim where day_date = @WTD 
select @QTD = min(day_date) from reference.dbo.calendar_dim where fiscal_quarter = @Qtr and fiscal_year = @FY
--
-- Select beginning of this year
--
select @YTD = min(day_date) from reference.dbo.Calendar_Dim where Fiscal_Year = @FY
--
-- End of Date Calcs
-- Get Goal Data
--
truncate table staging.dbo.wrk_MSG
select @sql = 'insert into staging.dbo.wrk_MSG '
select @sql = @sql + 'select Store_Number,Region,District,Week_'
select @sql = @sql + cast(@FW as char(2)) + ',P' + cast(@period as char(2)) + ','
select @sql = @sql + 'Q' + cast(@FQ as char(1)) + ',Year_Goal from reference.dbo.mag_sales_Goals '
exec sp_executesql @sql
--
-- Get Daily Data
--
select @seldate
select	@seldate as Day_Date,
		Store_Number,
		Mag_Sales,
		Opportunities,
		Total_Transactions
into	#tmp 
from	Reference.dbo.Store_mag_sales where day_date = @Seldate
--
INSERT INTO staging.dbo.mag_Daily
select	@Seldate as Day_Date,
		t2.store_number,
		isnull(t1.Opportunities,0) as Opportunities,
		isnull(t1.Mag_Sales,0) as Mag_Sales
from	#tmp t1 right join reference.dbo.active_stores t2
on	t1.store_number = t2.store_number
order by Store_Number,day_date

--
-- get Week To Date
--
INSERT INTO staging.dbo.mag_WTD
select	store_number,
		sum(Opportunities) as WTD_Opportunities,
		sum(mag_sales) as WTD_Mag_Sales
from	Reference.dbo.store_mag_sales
where	day_date >= @WTD
group by store_number 
order by Store_Number
--
-- get Month To Date
--
INSERT INTO staging.dbo.mag_MTD
select	store_number,
		sum(Opportunities) as MTD_Opportunities,
		sum(mag_sales) as MTD_Mag_Sales
from	Reference.dbo.store_mag_sales
where	day_date >= @MTD
group by store_number 
order by Store_Number
--
-- get Quarter To Date
--
INSERT INTO staging.dbo.mag_QTD
select	store_number,
		sum(Opportunities) as QTD_Opportunities,
		sum(mag_sales) as QTD_Mag_Sales
from	Reference.dbo.store_mag_sales
where	day_date >= @QTD
group by store_number 
order by Store_Number
--
-- Get YTD
--
INSERT INTO staging.dbo.mag_YTD
select	store_number,
		sum(Opportunities) as YTD_Opportunities,
		sum(mag_sales) as YTD_Mag_Sales
from	Reference.dbo.store_mag_sales
where	day_date >= @YTD
group by store_number 
order by Store_Number
--
-- Combine Previous Record Sets
--
truncate table ReportData.dbo.rpt_Mag_Sales_Report
--

insert into ReportData.dbo.rpt_Mag_Sales_Report
select	t1.day_date,
		t5.Region_Number,
		t5.District_Number,
		t1.store_number,
		t1.Opportunities,
		isnull(t1.Mag_Sales,0) as Mag_Sales,
		isnull(t2.WTD_Opportunities,0) as WTD_Opportunities,
		isnull(t2.WTD_Mag_Sales,0) as WTD_Mag_Sales,
		isnull(t7.Week_Goal,0) as WTD_Goal,
		isnull(t3.MTD_Opportunities,0) as MTD_Opportunities,
		isnull(t3.MTD_Mag_Sales,0) as MTD_Mag_Sales,
		isnull(t7.Period_Goal,0) as MTD_Goal,
		isnull(t6.QTD_Opportunities,0) as QTD_Opportunities,
		isnull(t6.QTD_Mag_Sales,0) as QTD_Mag_Sales,
		isnull(t7.Quarter_Goal,0) as QTD_Goal,
		isnull(t4.YTD_Opportunities,0) as YTD_Opportunities,
		isnull(t4.YTD_Mag_Sales,0) as YTD_Mag_Sales,
		isnull(t7.Year_Goal,0) as YTD_Goal
from	reference.dbo.active_stores t5 left join 
		staging.dbo.mag_Daily t1 
		on t1.store_number = t5.store_number
		left join staging.dbo.mag_WTD t2
		on t2.store_number = t1.store_number
		left join staging.dbo.mag_MTD t3
		on t3.store_number = t1.store_number
		left join staging.dbo.mag_QTD t6
		on t6.store_number = t1.store_number
		left join staging.dbo.mag_YTD T4
		on t4.store_number = t1.store_number
		left join staging.dbo.wrk_MSG t7
		on t7.store_number = t1.store_number
where	t1.day_date is not null
order by t5.region_number,t5.district_number,t1.store_number

--
-- End Of Processing
--





























GO
