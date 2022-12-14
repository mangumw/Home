USE [ReportData]
GO
/****** Object:  StoredProcedure [dbo].[usp_Build_rpt_Institutional_Sales_Region]    Script Date: 8/19/2022 3:44:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[usp_Build_rpt_Institutional_Sales_Region]
as

declare @Fiscal_Year int
declare @Fiscal_Quarter varchar(7)
--
declare @LS smalldatetime
declare @TYWE smalldatetime
declare @TYWS smalldatetime
declare @LYW smalldatetime
declare @TYQS smalldatetime
declare @TYQE smalldatetime
declare @LYQS smalldatetime
declare @LYQE smalldatetime
declare @TYMS smalldatetime
declare @TYME smalldatetime
declare @LYMS smalldatetime
declare @LYME smalldatetime
declare @TYYS smalldatetime
declare @TYYE smalldatetime
declare @LYYS smalldatetime
declare @LYYE smalldatetime
declare @fiscal_period int
--
select @LS = staging.dbo.fn_Last_Saturday(getdate())
--
select @fiscal_year = Fiscal_Year from reference.dbo.Calendar_Dim where day_date = @LS
select @fiscal_quarter = fiscal_quarter from reference.dbo.calendar_dim where day_date = @LS
select @TYQS = min(day_date) from reference.dbo.calendar_dim where fiscal_quarter = @fiscal_quarter
select @TYQE = max(day_date) from reference.dbo.calendar_dim where fiscal_quarter = @fiscal_quarter
select @fiscal_quarter = cast(@fiscal_year - 1 as char(4)) + right(@fiscal_quarter,3)
select @LYQS = min(day_date) from reference.dbo.calendar_dim where fiscal_quarter = @fiscal_quarter
select @LYQE = max(day_date) from reference.dbo.calendar_dim where fiscal_quarter = @fiscal_quarter
--
set @TYWE = @LS
set @TYWS = dateadd(dd,-6,@TYWE)
set @LYW = staging.dbo.fn_Last_Saturday(dateadd(yy,-1,@TYWE))
select @fiscal_period = fiscal_period from reference.dbo.calendar_dim where day_date = @LS
select @TYMS = day_date from reference.dbo.calendar_dim where fiscal_period = @fiscal_period and day_of_period = 1 and fiscal_year = @fiscal_year
set @TYME = dateadd(dd,-1,dateadd(mm,1,@TYMS))
set @LYMS = dateadd(dd,1,dateadd(yy,-1,@TYMS))
set @LYME = dateadd(dd,1,dateadd(dd,-1,dateadd(mm,1,@LYMS)))
--
Select @TYYS = day_date from reference.dbo.Calendar_Dim where Fiscal_Year = @fiscal_Year and day_of_fiscal_year = 1
select @LYYS = day_date from reference.dbo.Calendar_Dim where Fiscal_Year = @fiscal_Year - 1 and day_of_fiscal_year = 1
select @TYYE = staging.dbo.fn_DateOnly(GetDate())
select @LYYE = dateadd(yy,-1,@TYYE)
--
-- Get Last Year Week Totals
--
select  t1.Store_Number,
		sum(t1.current_units) as LYW_SLSU,
		sum(t1.current_dollars) as LYW_SLSD
into	#LYW
from	dssdata.dbo.Institutional_Weekly_Sales t1
where	t1.day_date = @LYW 
group by t1.Store_Number
order by t1.Store_Number
--
select  t1.Store_Number,
		sum(t1.item_quantity) as LYW_SLSTU,
		sum(t1.extended_price) as LYW_SLSTD
into	#LYWT
from	dssdata.dbo.detail_transaction_history t1
where	t1.day_date = @LYW 
group by t1.Store_Number
order by t1.Store_Number
--
-- Get Last Year Month Totals
--
select  t1.Store_Number,
		sum(t1.current_units) as LYM_SLSU,
		sum(t1.current_dollars) as LYM_SLSD
into	#LYM
from	dssdata.dbo.Institutional_Weekly_Sales t1
where	t1.day_date >= @LYMS and t1.day_date <= @LYME 
group by t1.Store_Number
order by t1.Store_Number
--
select  t1.Store_Number,
		sum(t1.item_quantity) as LYM_SLSTU,
		sum(t1.extended_price) as LYM_SLSTD
into	#LYMT
from	dssdata.dbo.detail_transaction_history t1
where	t1.day_date >= @LYMS and t1.day_date <= @LYME 
group by t1.Store_Number
order by t1.Store_Number
--
-- Get Last Year Quarter Totals
--
select  t1.Store_Number,
		sum(t1.current_units) as LYQ_SLSU,
		sum(t1.current_dollars) as LYQ_SLSD
into	#LYQ
from	dssdata.dbo.Institutional_Weekly_Sales t1
where	t1.day_date >= @LYQS and t1.day_date <= @LYQE 
group by t1.Store_Number
order by t1.Store_Number
--
select  t1.Store_Number,
		sum(t1.item_quantity) as LYQ_SLSTU,
		sum(t1.extended_price) as LYQ_SLSTD
into	#LYQT
from	dssdata.dbo.detail_transaction_history t1
where	t1.day_date >= @LYQS and t1.day_date <= @LYQE 
group by t1.Store_Number
order by t1.Store_Number
--
-- Get Last Year YTD Totals
--
select  t1.Store_Number,
		sum(t1.current_units) as LYY_SLSU,
		sum(t1.current_dollars) as LYY_SLSD
into	#LYY
from	dssdata.dbo.Institutional_Weekly_Sales t1
where	t1.day_date >= @LYYS and t1.day_date <= @LYYE 
group by t1.Store_Number
order by t1.Store_Number
--
select  t1.Store_Number,
		sum(t1.item_quantity) as LYY_SLSTU,
		sum(t1.extended_price) as LYY_SLSTD
into	#LYYT
from	dssdata.dbo.detail_transaction_history t1
where	t1.day_date >= @LYYS and t1.day_date <= @LYYE 
group by t1.Store_Number
order by t1.Store_Number
--
select  t1.Store_Number,
		sum(t1.current_units) as TYW_SLSU,
		sum(t1.current_dollars) as TYW_SLSD
into	#TYW
from	dssdata.dbo.Institutional_Weekly_Sales t1
where	t1.day_date = @TYWE
group by t1.Store_Number
order by t1.Store_Number
--
select  t1.Store_Number,
		sum(t1.Item_Quantity) as TYW_SLSTU,
		sum(t1.Extended_Price) as TYW_SLSTD
into	#TYWT
from	dssdata.dbo.detail_transaction_period t1
where	t1.day_date >= @TYWS and day_date <= @TYWE
group by t1.Store_Number
order by t1.Store_Number
--
-- Get This Year Month Totals
--
select  t1.Store_Number,
		sum(t1.current_units) as TYM_SLSU,
		sum(t1.current_dollars) as TYM_SLSD
into	#TYM
from	dssdata.dbo.Institutional_Weekly_Sales t1
where	t1.day_date >= @TYMS and t1.day_date <= @TYME 
group by t1.Store_Number
order by t1.Store_Number
--
select  t1.Store_Number,
		sum(t1.item_quantity) as TYM_SLSTU,
		sum(t1.extended_price) as TYM_SLSTD
into	#TYMT
from	dssdata.dbo.detail_transaction_history t1
where	t1.day_date >= @TYMS and t1.day_date <= @TYME 
group by t1.Store_Number
order by t1.Store_Number
--
-- Get This Year Quarter Totals
--
select  t1.Store_Number,
		sum(t1.current_units) as TYQ_SLSU,
		sum(t1.current_dollars) as TYQ_SLSD
into	#TYQ
from	dssdata.dbo.Institutional_Weekly_Sales t1
where	t1.day_date >= @TYQS and t1.day_date <= @TYQE
group by t1.Store_Number
order by t1.Store_Number
--
select  t1.Store_Number,
		sum(t1.item_quantity) as TYQ_SLSTU,
		sum(t1.extended_price) as TYQ_SLSTD
into	#TYQT
from	dssdata.dbo.detail_transaction_history t1
where	t1.day_date >= @TYQS and t1.day_date <= @TYQE
group by t1.Store_Number
order by t1.Store_Number
--
-- Get This Year YTD Totals
--
select  t1.Store_Number,
		sum(t1.current_units) as TYY_SLSU,
		sum(t1.current_dollars) as TYY_SLSD
into	#TYY
from	dssdata.dbo.Institutional_Weekly_Sales t1
where	t1.day_date >= @TYYS and t1.day_date <= @TYYE 
group by t1.Store_Number
order by t1.Store_Number
--
select  t1.Store_Number,
		sum(t1.item_quantity) as TYY_SLSTU,
		sum(t1.extended_price) as TYY_SLSTD
into	#TYYT
from	dssdata.dbo.detail_transaction_history t1
where	t1.day_date >= @TYYS and t1.day_date <= @TYYE 
group by t1.Store_Number
order by t1.Store_Number
--
-- Get this years data
--
IF  EXISTS (SELECT * FROM ReportData.sys.objects WHERE object_id = OBJECT_ID(N'[ReportData].[dbo].[rpt_Institutional_Sales_Region]') AND type in (N'U'))
DROP TABLE [ReportData].[dbo].[rpt_Institutional_Sales_Region]
--
select  t9.Region_Number,
		t9.region_name,
		t9.District_Number,
		t9.district_name,
		t9.store_number,
		t9.store_Name,
		isnull(t1.TYW_SLSD,0) as TYW_SLSD,
		isnull(t1.TYW_SLSU,0) as TYW_SLSU,
		isnull(t11.TYW_SLSTD,0) as TYW_SLSTD,
		isnull(t11.TYW_SLSTU,0) as TYW_SLSTU,
		isnull(t2.LYW_SLSD,0) as LYW_SLSD,
		isnull(t2.LYW_SLSU,0) as LYW_SLSU,
		isnull(t12.LYW_SLSTD,0) as LYW_SLSTD,
		isnull(t12.LYW_SLSTU,0) as LYW_SLSTU,
		isnull(t3.TYM_SLSD,0) as TYM_SLSD,
		isnull(t3.TYM_SLSU,0) as TYM_SLSU,
		isnull(t13.TYM_SLSTD,0) as TYM_SLSTD,
		isnull(t13.TYM_SLSTU,0) as TYM_SLSTU,
		isnull(t4.LYM_SLSD,0) as LYM_SLSD,
		isnull(t4.LYM_SLSU,0) as LYM_SLSU,
		isnull(t14.LYM_SLSTD,0) as LYM_SLSTD,
		isnull(t14.LYM_SLSTU,0) as LYM_SLSTU,
		isnull(t7.TYQ_SLSD,0) as TYQ_SLSD,
		isnull(t7.TYQ_SLSU,0) as TYQ_SLSU,
		isnull(t15.TYQ_SLSTD,0) as TYQ_SLSTD,
		isnull(t15.TYQ_SLSTU,0) as TYQ_SLSTU,
		isnull(t8.LYQ_SLSD,0) as LYQ_SLSD,
		isnull(t8.LYQ_SLSU,0) as LYQ_SLSU,
		isnull(t16.LYQ_SLSTD,0) as LYQ_SLSTD,
		isnull(t16.LYQ_SLSTU,0) as LYQ_SLSTU,
		isnull(t5.TYY_SLSD,0) as TYY_SLSD,
		isnull(t5.TYY_SLSU,0) as TYY_SLSU,
		isnull(t17.TYY_SLSTD,0) as TYY_SLSTD,
		isnull(t17.TYY_SLSTU,0) as TYY_SLSTU,
		isnull(t6.LYY_SLSD,0) as LYY_SLSD,
		isnull(t6.LYY_SLSU,0) as LYY_SLSU,
		isnull(t18.LYY_SLSTD,0) as LYY_SLSTD,
		isnull(t18.LYY_SLSTU,0) as LYY_SLSTU
into	reportdata.dbo.rpt_Institutional_Sales_Region
from	reference.dbo.active_stores t9 left join #TYW t1 on t1.store_number = t9.store_number
		left join #LYW t2 on t2.store_number = t9.store_number
		left join #TYM t3 on t3.store_number = t9.store_number
		left join #LYM t4 on t4.store_number = t9.store_number
		left join #TYY t5 on t5.store_number = t9.store_number
		left join #LYY t6 on t6.store_number = t9.store_number
		left join #TYQ t7 on t7.store_number = t9.store_number
		left join #LYQ t8 on t8.store_number = t9.store_number
--
		left join #TYWt t11 on t11.store_number = t9.store_number
		left join #LYWT t12 on t12.store_number = t9.store_number
		left join #TYMT t13 on t13.store_number = t9.store_number
		left join #LYMT t14 on t14.store_number = t9.store_number
		left join #TYQT t15 on t15.store_number = t9.store_number
		left join #LYQT t16 on t16.store_number = t9.store_number
		left join #TYYT t17 on t17.store_number = t9.store_number
		left join #LYYT t18 on t18.store_number = t9.store_number

















GO
