USE [ReportData]
GO
/****** Object:  StoredProcedure [dbo].[usp_Build_rpt_Institutional_Store_Sales]    Script Date: 8/19/2022 3:44:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[usp_Build_rpt_Institutional_Store_Sales]
as
declare @Fiscal_Year int
--
declare @TYW smalldatetime
declare @LYW smalldatetime
declare @TYMS smalldatetime
declare @TYME smalldatetime
declare @LYMS smalldatetime
declare @LYME smalldatetime
declare @TYYS smalldatetime
declare @TYYE smalldatetime
declare @LYYS smalldatetime
declare @LYYE smalldatetime
--
select @fiscal_year = Fiscal_Year from reference.dbo.Calendar_Dim where day_date = staging.dbo.fn_DateOnly(Getdate())
--
set @TYW = staging.dbo.fn_Last_Saturday(getdate())
set @LYW = staging.dbo.fn_Last_Saturday(dateadd(yy,-1,getdate()))
set @TYMS = str(datepart(mm,getdate())) + '/01/' + str(datepart(yy,getdate()))
set @TYME = dateadd(dd,-1,dateadd(mm,1,@TYMS))
set @LYMS = dateadd(yy,-1,@TYMS)
set @LYME = dateadd(dd,-1,dateadd(mm,1,@LYMS))
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
where	day_date = @LYW 
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
where	day_date >= @LYMS and day_date <= @LYME 
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
where	day_date >= @LYYS and day_date <= @LYYE 
group by t1.Store_Number
order by t1.Store_Number
--
--
-- Get This Year Week Totals
--
select  t1.Store_Number,
		sum(t1.current_units) as TYW_SLSU,
		sum(t1.current_dollars) as TYW_SLSD
into	#TYW
from	dssdata.dbo.Institutional_Weekly_Sales t1
where	day_date = @TYW 
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
where	day_date >= @TYMS and day_date <= @TYME 
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
where	day_date >= @TYMS and day_date <= @TYME 
group by t1.Store_Number
order by t1.Store_Number

--
-- Get this years data
--
IF  EXISTS (SELECT * FROM ReportData.sys.objects WHERE object_id = OBJECT_ID(N'[ReportData].[dbo].[rpt_Institutional_Store_Sales]') AND type in (N'U'))
DROP TABLE [ReportData].[dbo].[rpt_Institutional_Store_Sales]
--
select  t9.store_number,
		t7.store_Name,
		isnull(t1.TYW_SLSD,0) as TYW_SLSD,
		isnull(t1.TYW_SLSU,0) as TYW_SLSU,
		isnull(t2.LYW_SLSD,0) as LYW_SLSD,
		isnull(t2.LYW_SLSU,0) as LYW_SLSU,
		isnull(t3.TYM_SLSD,0) as TYM_SLSD,
		isnull(t3.TYM_SLSU,0) as TYM_SLSU,
		isnull(t4.LYM_SLSD,0) as LYM_SLSD,
		isnull(t4.LYM_SLSU,0) as LYM_SLSU,
		isnull(t5.TYY_SLSD,0) as TYY_SLSD,
		isnull(t5.TYY_SLSU,0) as TYY_SLSU,
		isnull(t6.LYY_SLSD,0) as LYY_SLSD,
		isnull(t6.LYY_SLSU,0) as LYY_SLSU
into	reportdata.dbo.rpt_Institutional_Store_Sales
from	reference.dbo.active_stores t9 left join #TYW t1 on t1.store_number = t9.store_number
		left join #LYW t2 on t2.store_number = t9.store_number
		left join #TYM t3 on t3.store_number = t9.store_number
		left join #LYM t4 on t4.store_number = t9.store_number
		left join #TYY t5 on t5.store_number = t9.store_number
		left join #LYY t6 on t6.store_number = t9.store_number
		left join reference.dbo.store_dim t7 on t7.store_number = t9.store_number

GO
