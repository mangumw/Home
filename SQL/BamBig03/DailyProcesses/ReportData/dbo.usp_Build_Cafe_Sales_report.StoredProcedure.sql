USE [ReportData]
GO
/****** Object:  StoredProcedure [dbo].[usp_Build_Cafe_Sales_report]    Script Date: 8/19/2022 3:44:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE Procedure [dbo].[usp_Build_Cafe_Sales_report]
as

declare @WTD		smalldatetime
declare @MTD		smalldatetime
declare @QTD		smalldatetime
declare @YTD		smalldatetime
declare @DateTmp	varchar(30)
declare @FY			int
declare @seldate	smalldatetime
declare @period		int
declare @Qtr		varchar(10)
--
select @seldate = staging.dbo.fn_last_saturday(getdate())
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
select @FY = Fiscal_Year from reference.dbo.Calendar_Dim where day_date = staging.dbo.fn_DateOnly(dateadd(dd,-6,Getdate()))
select @Qtr = fiscal_quarter from reference.dbo.calendar_dim where day_date = @WTD 
select @QTD = min(day_date) from reference.dbo.calendar_dim where fiscal_quarter = @Qtr and fiscal_year = @FY
--
-- Select beginning of this year
--
select @YTD = min(day_date) from reference.dbo.Calendar_Dim where Fiscal_Year = @FY
--
-- End of Date Calcs
--
truncate table staging.dbo.tmp_Cafe_Sales
--drop table #CMTD
--drop table #CWeek
--drop table #CQTD
--drop table #CYTD


--
-- Load Base Table
--
insert into staging.dbo.tmp_Cafe_Sales 
select	distinct
		@seldate as Day_Date,
		t1.Region_Number,
		t1.Region_Name,
		t1.District_Number,
		t1.District_Name,
		t1.Store_Number,
		t1.Store_Name,
		t2.Lvl1Cat,
		0,
		0,
		0,
		0,
		0,
		0,
		0,
		0
from	reference.dbo.Active_Stores t1 cross join 
		reference.dbo.cafe_report_config t2
--
-- Get Week Sales
--
select	t2.Store_number,
		t1.lvl1cat,
		isnull(sum(t2.current_units),0) as Week_Units,
		isnull(sum(t2.Current_Dollars),0) as Week_Dollars
into	#CWeek
from	reference.dbo.cafe_report_config t1 left join 
		dssdata.dbo.Weekly_Sales t2
on		t2.sku_number = t1.sku
and		t2.day_date >= @seldate
group by t2.store_number,t1.lvl1cat
--
-- Get MTD Sales
--
select	t1.Store_number,
		t1.lvl1cat,
		sum(t2.current_units) as MTD_Units,
		sum(t2.Current_Dollars) as MTD_Dollars
into	#CMTD
from	staging.dbo.tmp_Cafe_Sales t1, 
		dssdata.dbo.Weekly_Sales t2,
		reference.dbo.cafe_report_config t3
where	t2.day_date >= @MTD
and		t3.lvl1cat = t1.lvl1cat
and		t2.sku_number = t3.sku
and		t2.Store_Number = t1.store_number
group by t1.store_number,t1.lvl1cat
--
-- Get QTD Sales
--
select	t1.Store_number,
		t1.lvl1cat,
		sum(t2.current_units) as QTD_Units,
		sum(t2.Current_Dollars) as QTD_Dollars
into	#CQTD
from	staging.dbo.tmp_Cafe_Sales t1,
		dssdata.dbo.Weekly_Sales t2,
		reference.dbo.cafe_report_config t3
where	t2.day_date >= @QTD
and		t3.lvl1cat = t1.lvl1cat
and		t2.sku_number = t3.sku
and		t2.Store_Number = t1.store_number
group by t1.store_number,t1.lvl1cat
--
-- Get YTD Sales
--
select	t2.Store_number,
		t1.lvl1cat,
		sum(t2.current_units) as YTD_Units,
		sum(t2.Current_Dollars) as YTD_Dollars
into	#CYTD
from	reference.dbo.cafe_report_config t1,
		dssdata.dbo.Weekly_Sales t2
where	t2.day_date >= @YTD
and		t2.sku_number = t1.sku
group by t2.store_number,t1.lvl1cat
--
-- Update Base Table with Sales Data
--
update staging.dbo.tmp_Cafe_Sales
set		Week_dollars = #CWeek.Week_Dollars,
		Week_Units = #CWeek.Week_Units
from	#CWeek
where	#CWeek.Store_Number = staging.dbo.tmp_Cafe_Sales.Store_Number
and		#CWeek.lvl1cat = staging.dbo.tmp_Cafe_Sales.lvl1cat
--
update staging.dbo.tmp_Cafe_Sales
set		MTD_Units = #CMTD.MTD_Units,
		MTD_Dollars = #CMTD.MTD_Dollars
from	#CMTD
where	#CMTD.Store_Number = staging.dbo.tmp_Cafe_Sales.Store_number
and		#CMTD.lvl1cat = staging.dbo.tmp_Cafe_Sales.lvl1cat
--
update staging.dbo.tmp_Cafe_Sales
set		QTD_Units = #CQTD.QTD_Units,
		QTD_Dollars = #CQTD.QTD_Dollars
from	#CQTD
where	#CQTD.Store_Number = staging.dbo.tmp_Cafe_Sales.Store_number
and		#CQTD.lvl1cat = staging.dbo.tmp_Cafe_Sales.lvl1cat
--
update staging.dbo.tmp_Cafe_Sales
set		YTD_Units = #CYTD.YTD_Units,
		YTD_Dollars = #CYTD.YTD_Dollars
from	#CYTD
where	#CYTD.Store_Number = staging.dbo.tmp_Cafe_Sales.Store_number
and		#CYTD.lvl1cat = staging.dbo.tmp_Cafe_Sales.lvl1cat
--
--
TRUNCATE TABLE REPORTDATA.DBO.CAFE_SALES
Insert into ReportData.dbo.Cafe_Sales
select	day_date,
		Region,
		District,
		Store_Number,
		Store_Name,
		Week_Units,
		Week_Dollars,
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
		MTD_Units,
		MTD_Dollars,
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
		QTD_Units,
		QTD_Dollars,
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
		YTD_Units,
		YTD_Dollars,
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
from	Staging.dbo.tmp_Cafe_Sales
where	lvl1cat = 'Coffee Of the Day'
--
update	reportdata.dbo.cafe_sales
set		W_HD_Units = Week_Units,
		W_HD_Dollars = Week_Dollars,
		M_HD_Units = MTD_Units,
		M_HD_Dollars = MTD_Dollars,
		Q_HD_Units = QTD_Units,
		Q_HD_Dollars = QTD_Dollars,
		Y_HD_Units = YTD_Units,
		Y_HD_Dollars = YTD_Dollars
from	staging.dbo.tmp_Cafe_Sales
where	lvl1cat = 'Hot Drinks'
and		reportdata.dbo.cafe_sales.Store_Number = staging.dbo.tmp_Cafe_Sales.Store_Number
--
update	reportdata.dbo.cafe_sales
set		W_CD_Units = Week_Units,
		W_CD_Dollars = Week_Dollars,
		M_CD_Units = MTD_Units,
		M_CD_Dollars = MTD_Dollars,
		Q_CD_Units = QTD_Units,
		Q_CD_Dollars = QTD_Dollars,
		Y_CD_Units = YTD_Units,
		Y_CD_Dollars = YTD_Dollars
from	staging.dbo.tmp_Cafe_Sales
where	lvl1cat = 'Cold Drinks'
and		reportdata.dbo.cafe_sales.Store_Number = staging.dbo.tmp_Cafe_Sales.Store_Number
--
update	reportdata.dbo.cafe_sales
set		W_BG_Units = Week_Units,
		W_BG_Dollars = Week_Dollars,
		M_BG_Units = MTD_Units,
		M_BG_Dollars = MTD_Dollars,
		Q_BG_Units = QTD_Units,
		Q_BG_Dollars = QTD_Dollars,
		Y_BG_Units = YTD_Units,
		Y_BG_Dollars = YTD_Dollars
from	staging.dbo.tmp_Cafe_Sales
where	lvl1cat = 'Fresh Goods'
and		reportdata.dbo.cafe_sales.Store_Number = staging.dbo.tmp_Cafe_Sales.Store_Number
--
update	reportdata.dbo.cafe_sales
set		W_MI_Units = Week_Units,
		W_MI_Dollars = Week_Dollars,
		M_MI_Units = MTD_Units,
		M_MI_Dollars = MTD_Dollars,
		Q_MI_Units = QTD_Units,
		Q_MI_Dollars = QTD_Dollars,
		Y_MI_Units = YTD_Units,
		Y_MI_Dollars = YTD_Dollars
from	staging.dbo.tmp_Cafe_Sales
where	lvl1cat = 'Miscellaneous'
and		reportdata.dbo.cafe_sales.Store_Number = staging.dbo.tmp_Cafe_Sales.Store_Number
--
update	reportdata.dbo.cafe_sales
set		W_WB_Units = Week_Units,
		W_WB_Dollars = Week_Dollars,
		M_WB_Units = MTD_Units,
		M_WB_Dollars = MTD_Dollars,
		Q_WB_Units = QTD_Units,
		Q_WB_Dollars = QTD_Dollars,
		Y_WB_Units = YTD_Units,
		Y_WB_Dollars = YTD_Dollars
from	staging.dbo.tmp_Cafe_Sales
where	lvl1cat = 'Whole Bean'
and		reportdata.dbo.cafe_sales.Store_Number = staging.dbo.tmp_Cafe_Sales.Store_Number

--		
--
--drop table #CWeek
--drop table #CQTD
--drop table #CMTD
--drop table #CYTD
GO
