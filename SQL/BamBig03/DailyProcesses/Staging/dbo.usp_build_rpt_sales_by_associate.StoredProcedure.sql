USE [Staging]
GO
/****** Object:  StoredProcedure [dbo].[usp_build_rpt_sales_by_associate]    Script Date: 8/19/2022 3:41:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[usp_build_rpt_sales_by_associate]
as
--
declare @WTD		smalldatetime
declare @MTD		smalldatetime
declare @YTD		smalldatetime
declare @DateTmp	varchar(30)
declare @FY			int
declare @seldate	smalldatetime
--
-- Build Work Tables
--
truncate table staging.dbo.Dash_daily
truncate table staging.dbo.Dash_WTD
truncate table staging.dbo.Dash_MTD
truncate table staging.dbo.Dash_YTD
--
-- Calc Yesterday's Date
--
select @seldate = staging.dbo.fn_dateonly(dateadd(dd,-1,getdate()))
--
-- Calc Beginning of this week
--
select @WTD = staging.dbo.fn_Last_Saturday(getdate())
select @WTD = dateadd(dd,1,@WTD)
--
-- Calc Beginning of this Month
--
select @MTD = ltrim(str(datepart(mm,getdate()))) + '/' + '01' + '/' + ltrim(str(datepart(yy,getdate())))
--
-- Select beginning of this year
--
select @FY = Fiscal_Year from reference.dbo.Calendar_Dim where day_date = staging.dbo.fn_DateOnly(Getdate())
select @YTD = min(day_date) from reference.dbo.Calendar_Dim where Fiscal_Year = @FY
--
select  t1.day_date,
		t1.store_number,
		t1.cashier_number,
		sum(t1.transaction_amount) as Total_Sales
into	#daily_Total
from	dssdata.dbo.header_transaction t1
where	t1.day_date = @seldate
group by t1.day_date,t1.store_number,t1.cashier_number
--
select  t1.day_date,
		t1.store_number,
		t1.cashier_number,
		sum(t2.Extended_Price) as DC_Sales
into	#daily_DC
from	dssdata.dbo.header_transaction t1,
		dssdata.dbo.detail_transaction_period t2
where	t1.day_date = @seldate
and		t2.day_date = t1.day_date
and		t2.store_number = t1.store_number
and		t2.transaction_code = 'MC'
and		t2.transaction_nbr = t1.transaction_number
and		t2.register_nbr = t1.register_number
group by t1.day_date,t1.store_number,t1.cashier_number
--
insert into staging.dbo.dash_daily
select	t1.day_date,
		t1.store_number,
		t1.cashier_nbr,
		t1.total_sales,
		t2.dc_sales
from	#daily_total t1,
		#daily_DC t2
where	t2.day_date = t1.day_date
and		t2.store_number = t1.store_number
and		t2.cashier_nbr = t1.cashier_nbr
order by t1.total_sales desc
--
drop table #daily_total
drop table #daily_dc
--
select  t1.day_date,
		t1.store_number,
		t1.cashier_number,
		sum(t1.Transaction_amount) as WTD_Total
into	#WTD_Total
from	dssdata.dbo.header_transaction t1
where	t1.day_date >= @WTD
group by t1.day_date,t1.store_number,t1.cashier_number
--
select  t1.day_date,
		t1.store_number,
		t1.cashier_number,
		sum(t2.Extended_Price) as WTD_DC
into	#WTD_DC
from	dssdata.dbo.header_transaction t1,
		dssdata.dbo.detail_transaction_period t2
where	t1.day_date >= @WTD
and		t2.day_date = t1.day_date
and		t2.store_number = t1.store_number
and		t2.transaction_code = 'MC'
and		t2.transaction_nbr = t1.transaction_number
and		t2.register_nbr = t1.register_number
group by t1.day_date,t1.store_number,t1.cashier_number
--
insert into staging.dbo.Dash_WTD
select	t1.store_number,
		t1.cashier_number,
		t1.WTD_total,
		t2.WTD_DC
from	#WTD_total t1,
		#WTD_DC t2
where	t2.day_date = t1.day_date
and		t2.store_number = t1.store_number
and		t2.cashier_nbr = t1.cashier_number
order by t1.wtd_total desc
--
drop table #WTD_Total
drop table #WTD_DC
--
select  t1.store_number,
		t1.cashier_number,
		sum(t1.Transaction_amount) as Total_Sales
into	#MTD_Total
from	dssdata.dbo.header_transaction t1
where	t1.day_date >= @MTD
group by t1.store_number,t1.cashier_number
--
select  t1.store_number,
		t1.cashier_number,
		sum(t2.Extended_Price) as DC_Sales
into	#MTD_DC
from	dssdata.dbo.header_transaction t1,
		dssdata.dbo.detail_transaction_period t2
where	t1.day_date >= @MTD
and		t2.day_date = t1.day_date
and		t2.store_number = t1.store_number
and		t2.transaction_code = 'MC'
and		t2.transaction_nbr = t1.transaction_number
and		t2.register_nbr = t1.register_number
group by t1.store_number,t1.cashier_number
--
insert into staging.dbo.Dash_MTD
select	t1.store_number,
		t1.cashier_number,
		t1.total_sales,
		t2.dc_sales
from	#MTD_total t1,
		#MTD_DC t2
where	t2.store_number = t1.store_number
and		t2.cashier_nbr = t1.cashier_number
order by t1.total_sales desc
--
drop table #MTD_Total
drop table #MTD_DC
--
select  t1.store_number,
		t1.cashier_number,
		sum(t1.Transaction_amount) as Total_Sales
into	#YTD_Total
from	dssdata.dbo.header_transaction t1
where	t1.day_date >= @YTD
group by t1.store_number,t1.cashier_number
--
select  t1.store_number,
		t1.cashier_number,
		sum(t2.Extended_Price) as DC_Sales
into	#YTD_DC
from	dssdata.dbo.header_transaction t1,
		dssdata.dbo.detail_transaction_period t2
where	t1.day_date >= @YTD
and		t2.day_date = t1.day_date
and		t2.store_number = t1.store_number
and		t2.transaction_code = 'MC'
and		t2.transaction_nbr = t1.transaction_number
and		t2.register_nbr = t1.register_number
group by t1.store_number,t1.cashier_number
--
insert into staging.dbo.Dash_YTD
select	t1.store_number,
		t1.cashier_number,
		t1.total_sales,
		t2.dc_sales
from	#YTD_total t1,
		#YTD_DC t2
where	t2.store_number = t1.store_number
and		t2.cashier_nbr = t1.cashier_number
order by t1.total_sales desc
--
drop table #YTD_Total
drop table #YTD_DC
--
truncate table reportdata.dbo.rpt_sales_by_associate
--
insert into reportdata.dbo.rpt_sales_by_associate
select	t1.day_date,
		t5.region_number,
		t5.district_number,
		t1.store_number,
		t1.cashier_nbr,
		t1.total_sales,
		t1.dc_sales,
		t2.WTD_Sales,
		t2.WTD_DC_Sales,
		t3.MTD_Sales,
		t3.MTD_DC_Sales,
		t4.YTD_Sales,
		t4.YTD_DC_Sales
from	staging.dbo.dash_daily t1,
		staging.dbo.dash_WTD t2,
		staging.dbo.dash_MTD t3,
		staging.dbo.dash_YTD t4,
		reference.dbo.active_stores t5
where	t2.store_number = t1.store_number
and		t2.cashier_nbr = t1.cashier_nbr
and		t3.store_number = t1.store_number
and		t3.cashier_nbr = t1.cashier_nbr
and		t4.store_number = t1.store_number
and		t4.cashier_nbr = t1.cashier_nbr
and		t5.store_number = t1.store_number

GO
