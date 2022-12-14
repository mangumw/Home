USE [Staging]
GO
/****** Object:  StoredProcedure [dbo].[usp_Build_Store_Mag_Sales]    Script Date: 8/19/2022 3:41:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[usp_Build_Store_Mag_Sales]
as
----
declare @seldate smalldatetime
declare @numdays float
declare @DOW float
declare @DOM float
declare @DOQ float
declare @DOY float
declare @fq varchar(7)
declare @FY int
declare @FP int
declare @QS smalldatetime
declare @QE smalldatetime
declare @QDays float
declare @DIntoQ float
declare @endDate smalldatetime
declare @WTD		smalldatetime
declare @MTD		smalldatetime
declare @QTD		smalldatetime
declare @YTD		smalldatetime
declare @DateTmp	varchar(30)
declare @period		int
declare @Qtr		varchar(10)
declare @FW         int
declare @sql        Nvarchar(1000)
declare @YearDays	float
declare @EOY		smalldatetime
declare @yesterday smalldatetime
declare @strsql nvarchar(1000)
declare @loop int
declare @fw_Start int
declare @fw_End int
declare @Year_Perc float
--
select @seldate = staging.dbo.fn_dateonly(dateadd(dd,-1,getdate()))
select @DOW = day_of_week_number from reference.dbo.calendar_dim where day_date = staging.dbo.fn_DateOnly(@seldate)
select @FY = fiscal_year from reference.dbo.calendar_dim where day_date = staging.dbo.fn_DateOnly(@seldate)
select @FP = fiscal_period from reference.dbo.calendar_dim where day_date = staging.dbo.fn_DateOnly(@seldate)
select @numdays = max(day_of_month_number) from reference.dbo.calendar_dim where fiscal_year = @FY and fiscal_period = @FP
select @DOM = day_of_Period from reference.dbo.calendar_dim where day_date = staging.dbo.fn_DateOnly(@seldate)
select @DOY = day_of_fiscal_year from reference.dbo.calendar_dim where day_date = staging.dbo.fn_DateOnly(getdate())
select @Year_Perc = @DOY / 365
select @DOQ = day_of_month_number from reference.dbo.calendar_dim where day_date = staging.dbo.fn_DateOnly(@seldate)
select @FQ = fiscal_quarter from reference.dbo.calendar_dim where day_date = staging.dbo.fn_DateOnly(@seldate)
select @QS = min(day_date) from reference.dbo.calendar_dim where fiscal_quarter = @FQ
select @QE = max(day_date) from reference.dbo.calendar_dim where fiscal_quarter = @FQ
select @fw = fiscal_year_week from reference.dbo.calendar_dim where day_date = staging.dbo.fn_Last_Saturday(getdate())
select @period = fiscal_period from reference.dbo.calendar_dim where day_date = staging.dbo.fn_Last_Saturday(getdate())
--
select @seldate = staging.dbo.fn_dateonly(dateadd(dd,1,staging.dbo.fn_Last_Saturday(dateadd(dd,-1,getdate()))))
select @enddate = staging.dbo.fn_dateonly(dateadd(dd,6,@seldate))
select @yesterday = staging.dbo.fn_dateonly(Dateadd(dd,-1,getdate()))
--
-- Get Period To Date by Store
--
select @fw_Start = min(fiscal_year_week) from reference.dbo.calendar_dim where fiscal_period = @period and fiscal_year = @fy
select @fw_end = fiscal_year_week from reference.dbo.calendar_dim where day_date = staging.dbo.fn_DateOnly(getdate())
--
truncate table staging.dbo.MFM_PTD_Goals
--
select @strsql = 'insert into staging.dbo.MFM_PTD_Goals select store_number,Week_' + ltrim(str(@fw_start))
--
select @loop = @fw_start + 1
while @loop <= @fw_end
begin
	select @strsql = @strsql + '+Week_' + ltrim(str(@loop))
	select @loop = @loop + 1
end
select @strsql = @strsql + ' as PTD_Goal from reference.dbo.Mag_Sales_Goals'
EXEC sp_executesql @strsql
--
-- Get Quarter To Date Goals
--
select @fq = fiscal_quarter from reference.dbo.calendar_dim where day_date = staging.dbo.fn_Last_Saturday(Getdate())
select @fw_start = min(fiscal_year_week) from reference.dbo.calendar_dim where fiscal_quarter = @fq
--select @fw_end = max(fiscal_year_week) from reference.dbo.calendar_dim where day_date = staging.dbo.fn_Last_Saturday(getdate())
--
truncate table staging.dbo.MFM_QTD_Goals
--
select @strsql = 'insert into staging.dbo.MFM_QTD_Goals select store_number,Week_' + ltrim(str(@fw_start))
--
select @loop = @fw_start + 1
while @loop <= @fw_end
begin
	select @strsql = @strsql + '+Week_' + ltrim(str(@loop))
	select @loop = @loop + 1
end
select @strsql = @strsql + ' as QTD_Goal from reference.dbo.Mag_Sales_Goals'
EXEC sp_executesql @strsql
--
-- Get the YTD Goals by store
--
select @fw_start = 1
--
truncate table staging.dbo.MFM_YTD_Goals
--
select @strsql = 'insert into staging.dbo.MFM_YTD_Goals select store_number,Week_1'
--
select @loop = @fw_start + 1
while @loop <= @fw_end
begin
	select @strsql = @strsql + '+Week_' + ltrim(str(@loop))
	select @loop = @loop + 1
end
select @strsql = @strsql + ' as YTD_Goal from reference.dbo.Mag_Sales_Goals'
EXEC sp_executesql @strsql
--
-- Build Wrk_Store_Mag_Sales from Offers and SubOfferdata
--
truncate table staging.dbo.wrk_store_mag_sales
--
insert into staging.dbo.wrk_store_mag_sales
SELECT staging.dbo.fn_dateonly(tdate),store, count(store) 
FROM reference.dbo.MFM
WHERE staging.dbo.fn_dateonly(tdate) BETWEEN @seldate AND @enddate
GROUP BY staging.dbo.fn_dateonly(tdate),store
order by store
--
-- Get the Opportunities for the date range
--
select	t1.day_date,
		t2.store_number,
		count(t1.transaction_number) as Avail_Trans
into	#Opp
from	Reference.dbo.active_stores t2,
		dssdata.dbo.header_transaction t1,
		dssdata.dbo.tender_transaction t3
where	t1.day_date >= @seldate and t1.day_date <= @enddate
--and		t1.Customer_Number IS NOT NULL and cast(t1.Customer_Number as bigint) > 0
and		t3.tender_type in ('AE','AX','DC','DI','DT','MA','OT','VI')
and		t1.store_number = t2.store_number
and		t3.day_date = t1.day_date
and		t3.store_number = t1.store_number
and		t3.register_number = t1.register_number
and		t3.roll_over = t1.roll_over
and		t3.transaction_number = t1.transaction_number
group by t1.day_date,t2.store_number
order by t2.Store_Number,t1.day_date
--
-- Get the total sales for the date range
--
select	t1.day_date,
		t2.store_number,
		count(t1.transaction_number) as Tot_Trans
into	#Tot
from	Reference.dbo.active_stores t2,
		dssdata.dbo.header_transaction t1
where	t1.day_date >= @seldate and t1.day_date <= @enddate
--and		t1.Customer_Number IS NOT NULL and cast(t1.Customer_Number as bigint) > 0
and		t1.store_number = t2.store_number
group by t1.day_date,t2.store_number
order by t2.Store_Number,t1.day_date
--
delete from reference.dbo.store_mag_sales where day_date >= @seldate and day_date <= @enddate
--
-- Replace the Store_Mag_Sales for the date range from above collected data
--
insert into reference.dbo.store_mag_sales
select	t1.day_date,
		t1.Store_Number,
		isnull(t3.Mag_Sales,0) as Mag_Sales,
		isnull(t1.Avail_trans,0) as Avail_Trans,
		isnull(t2.Tot_Trans,0) as Tot_Trans
from	#Opp t1 left join #tot t2 
on		t2.day_date = t1.day_date
and		t2.store_number = t1.store_number
left join staging.dbo.wrk_store_mag_sales t3
on		t3.day_date = t1.day_date
and		t3.store_number = t1.store_number
--
-- The base data has been built, now build the report data
--
-- Truncate the work tables
--
truncate table staging.dbo.mag_daily
truncate table staging.dbo.mag_WTD
truncate table staging.dbo.mag_MTD
truncate table staging.dbo.mag_QTD
truncate table staging.dbo.mag_YTD
truncate table reportdata.dbo.rpt_mag_sales_report
--
-- Set up the date values
--
select @seldate = staging.dbo.fn_DateOnly(dateadd(dd,-1,getdate()))
select @FW = Fiscal_Year_Week from reference.dbo.calendar_dim where day_date = @seldate
select @FQ = right(fiscal_quarter,1) from reference.dbo.calendar_dim where day_date = @seldate
select @period = fiscal_period from reference.dbo.calendar_dim where day_date = @seldate
select @fy = fiscal_year from reference.dbo.calendar_dim where day_date = @seldate
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
select @sql = 'Insert into staging.dbo.wrk_MSG '
select @sql = @sql + 'select t1.Store_Number,t1.Region,t1.District,t1.Week_'
select @sql = @sql + cast(@FW as char(2)) + ',t1.P' + cast(@period as char(2)) + ','
select @sql = @sql + 't1.Q' + cast(@FQ as char(1)) + ',t1.Year_Goal,t2.PTD_Goal,t3.QTD_Goal,t4.YTD_Goal '
select @sql = @sql + ' from reference.dbo.mag_sales_Goals t1,staging.dbo.MFM_PTD_Goals t2,MFM_QTD_Goals t3,MFM_YTD_Goals t4'
select @sql = @sql + ' where t2.store_number = t1.store_number and t3.store_number = t1.store_number and t4.store_number = t1.store_number'
exec sp_executesql @sql

--
-- Get Daily Data
--
select	@yesterday as Day_Date,
		Store_Number,
		Mag_Sales,
		Opportunities,
		Total_Transactions
into	#tmp 
from	Reference.dbo.Store_mag_sales where day_date = @yesterday
--
INSERT INTO staging.dbo.mag_Daily
select	@seldate as Day_Date,
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
where	day_date >= @WTD and day_date <= @enddate
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
where	day_date >= @MTD and day_date <= @enddate
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
where	day_date >= @QTD and day_date <= @enddate
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
where	day_date >= @YTD and day_date <= @enddate
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
		t5.Region_Name,
		t5.District_Number,
		t5.District_Name,
		t1.store_number,
		t5.Store_Name,
		t1.Opportunities,
		isnull(t1.Mag_Sales,0) as Mag_Sales,
		isnull(t2.WTD_Opportunities,0) as WTD_Opportunities,
		isnull(t2.WTD_Mag_Sales,0) as WTD_Mag_Sales,
		isnull(t7.Week_Goal,0) as WTD_Goal,
		isnull(t3.MTD_Opportunities,0) as MTD_Opportunities,
		isnull(t3.MTD_Mag_Sales,0) as MTD_Mag_Sales,
		isnull(t7.PTD_Goal,0) as MTD_Goal,
		isnull(t6.QTD_Opportunities,0) as QTD_Opportunities,
		isnull(t6.QTD_Mag_Sales,0) as QTD_Mag_Sales,
		isnull(t7.QTD_Goal,0) as QTD_Goal,
		isnull(t4.YTD_Opportunities,0) as YTD_Opportunities,
		isnull(t4.YTD_Mag_Sales,0) as YTD_Mag_Sales,
		isnull(t7.YTD_Goal,0) as YTD_Goal,
		isnull(t7.Year_Goal,0) as Year_Goal,
		@Year_Perc as Year_Perc
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


drop table #opp
drop table #tot
drop table #tmp































GO
