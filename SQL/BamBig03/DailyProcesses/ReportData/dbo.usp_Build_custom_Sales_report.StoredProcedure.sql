USE [ReportData]
GO
/****** Object:  StoredProcedure [dbo].[usp_Build_custom_Sales_report]    Script Date: 8/19/2022 3:44:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE Procedure [dbo].[usp_Build_custom_Sales_report]
as
declare @YES		smalldatetime
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
select @YES = staging.dbo.fn_DateOnly(dateadd(dd,-1,getdate()))
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
truncate table staging.dbo.tmp_custom_Sales
--drop table #CMTD
--drop table #CWeek
--drop table #CQTD
--drop table #CYTD
--
-- Load Base Table
--
insert into staging.dbo.tmp_custom_Sales 
select	distinct
		@seldate as Day_Date,
		t1.Region_Number,
		t1.Region_Name,
		t1.District_Number,
		t1.District_Name,
		t1.Store_Number,
		t1.Store_Name,
		'DVD-BARGAIN ASSORTMENT',
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
from	reference.dbo.Active_Stores t1
--
-- Get Yesterday Sales
--
select	t2.Store_number,
		isnull(sum(t2.Item_Quantity),0) as Day_Units,
		isnull(sum(t2.Extended_price),0) as Day_Dollars
into	#CDay
from	dssdata.dbo.detail_transaction_history t2
where	t2.sku_number in (2439597,2463294,2476974)
and		t2.day_date = @YES
group by t2.store_number
--(2439597,2463294,2476974)
-- Get Week Sales
--
select	t2.Store_number,
		isnull(sum(t2.Item_Quantity),0) as Week_Units,
		isnull(sum(t2.Extended_Price),0) as Week_Dollars
into	#CWeek
from	dssdata.dbo.Detail_Transaction_History t2
where	t2.sku_number in (2439597,2463294,2476974)
and		t2.day_date > @seldate
group by t2.store_number
--
-- Get MTD Sales
--
select	t2.Store_number,
		sum(t2.Item_Quantity) as MTD_Units,
		sum(t2.Extended_Price) as MTD_Dollars
into	#CMTD
from	dssdata.dbo.detail_transaction_history t2
where	t2.day_date >= @MTD
and		t2.sku_number in (2439597,2463294,2476974)
group by t2.store_number
--
-- Get QTD Sales
--
select	t2.Store_number,
		sum(t2.item_Quantity) as QTD_Units,
		sum(t2.Extended_Price) as QTD_Dollars
into	#CQTD
from	dssdata.dbo.Detail_Transaction_History t2
where	t2.day_date >= @QTD
and		t2.sku_number in (2439597,2463294,2476974)
group by t2.store_number
--
-- Get YTD Sales
--
select	t2.Store_number,
		sum(t2.Item_Quantity) as YTD_Units,
		sum(t2.Extended_Price) as YTD_Dollars
into	#CYTD
from	dssdata.dbo.Detail_Transaction_History t2
where	t2.day_date >= @YTD
and		t2.sku_number in (2439597,2463294,2476974)
group by t2.store_number
--
-- Update Base Table with Sales Data
--
update staging.dbo.tmp_custom_Sales
set		YES_dollars = #CDay.Day_Dollars,
		YES_Units = #Cday.day_Units
from	#CDay
where	#CDay.Store_Number = staging.dbo.tmp_custom_Sales.Store_Number
--
update staging.dbo.tmp_custom_Sales
set		Week_dollars = #CWeek.Week_Dollars,
		Week_Units = #CWeek.Week_Units
from	#CWeek
where	#CWeek.Store_Number = staging.dbo.tmp_custom_Sales.Store_Number
--
update staging.dbo.tmp_custom_Sales
set		MTD_Units = #CMTD.MTD_Units,
		MTD_Dollars = #CMTD.MTD_Dollars
from	#CMTD
where	#CMTD.Store_Number = staging.dbo.tmp_custom_Sales.Store_number
--
update staging.dbo.tmp_custom_Sales
set		QTD_Units = #CQTD.QTD_Units,
		QTD_Dollars = #CQTD.QTD_Dollars
from	#CQTD
where	#CQTD.Store_Number = staging.dbo.tmp_custom_Sales.Store_number
--
update staging.dbo.tmp_custom_Sales
set		YTD_Units = #CYTD.YTD_Units,
		YTD_Dollars = #CYTD.YTD_Dollars
from	#CYTD
where	#CYTD.Store_Number = staging.dbo.tmp_custom_Sales.Store_number
--
--
TRUNCATE TABLE REPORTDATA.DBO.custom_SALES
Insert into ReportData.dbo.custom_Sales
select	t1.day_date,
		t1.Region,
		t1.District,
		t1.Store_Number,
		t1.Store_Name,
		'DVD-BARGAIN ASSORTMENT',
		'DVD-BARGAIN ASSORTMENT',
		t1.YES_Units,
		t1.YES_Dollars,
		t1.Week_Units,
		t1.Week_Dollars,
		t1.MTD_Units,
		t1.MTD_Dollars,
		t1.QTD_Units,
		t1.QTD_Dollars,
		t1.YTD_Units,
		t1.YTD_Dollars
from	Staging.dbo.tmp_custom_Sales t1
--		
--
--drop table #CWeek
--drop table #CQTD
--drop table #CMTD
--drop table #CYTD

GO
