USE [ReportData]
GO
/****** Object:  StoredProcedure [dbo].[usp_rpt_DSR_Chain_Daily]    Script Date: 8/19/2022 3:44:28 PM ******/
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
declare @TY_Daily_Comp	money
declare @TY_Daily_All	money
declare @TY_WTD_Comp	money
declare @TY_WTD_All		money
declare @TY_PTD_Comp	money
declare @TY_PTD_All		money
declare @TY_QTD_Comp	money
declare @TY_QTD_All		money
declare @TY_YTD_Comp	money
declare @TY_YTD_All		money
--
declare @LY_Daily_Comp	money
declare @LY_Daily_All	money
declare @LY_WTD_Comp	money
declare @LY_WTD_All		money
declare @LY_PTD_Comp	money
declare @LY_PTD_All		money
declare @LY_QTD_Comp	money
declare @LY_QTD_All		money
declare @LY_YTD_Comp	money
declare @LY_YTD_All		money
--
declare @TY_Daily_Comp_Bud	Money
declare @TY_Daily_All_Bud	money
declare @TY_WTD_Comp_Bud	money
declare @TY_WTD_All_Bud		money
declare @TY_PTD_Comp_Bud	money
declare @TY_PTD_All_Bud		money
declare @TY_QTD_Comp_Bud	money
declare @TY_QTD_All_Bud		money
declare @TY_YTD_Comp_Bud	money
declare @TY_YTD_All_Bud		money
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
select	@TY_Daily_Comp = sum(Extended_Price)
from	dssdata.dbo.Dsr_Store_Daily t1,
		reference.dbo.Comp_Stores_History t2
where	t1.day_date = @TYYES
and		t2.start_date <= @TYYES
and		t2.End_Date >= @TYYES
and		t1.store_number = t2.store_number
--
-- Get Yesterday DSR All Stores
--
select	@TY_Daily_All = sum(Extended_Price)
from	dssdata.dbo.Dsr_Store_Daily t1
where	t1.day_date = @TYYES
--
-- Get Yesterday Comp Budget
select	@TY_Daily_Comp_Bud = Comp_Stores
from	reference.dbo.DSR_Daily_Budget
where	day_date = @TYYES
--
-- Get Yesterday All Stores Budget
select	@TY_Daily_All_Bud = All_Stores
from	reference.dbo.DSR_Daily_Budget
where	day_date = @TYYES
--
-- Get WTD DSR Comp Stores
--
select	@TY_WTD_Comp = sum(Extended_Price)
from	dssdata.dbo.Dsr_Store_Daily t1,
		reference.dbo.Comp_Stores_History t2
where	t1.day_date >= @TYWS
and		t2.start_date <= t1.day_date
and		t2.End_Date >= t1.day_date
and		t1.store_number = t2.store_number
--
-- Get WTD All Stores
--
select	@TY_WTD_All = sum(Extended_Price) 
from	dssdata.dbo.Dsr_Store_Daily t1
where	t1.day_date >= @TYWS
--
-- Get WTD Comp Budget
--
select	@TY_WTD_Comp_Bud = sum(Comp_Stores)
from	reference.dbo.DSR_Daily_Budget
where	day_date >= @TYWS
--
-- Get WTD All Stores Budget
--
select	@TY_WTD_All_Bud = sum(All_Stores)
from	reference.dbo.DSR_Daily_Budget
where	day_date >= @TYWS
--
-- Get PTD DSR Comp Stores
--
select	@TY_PTD_Comp = sum(Extended_Price)
from	dssdata.dbo.Dsr_Store_Daily t1,
		reference.dbo.Comp_Stores_History t2
where	t1.day_date >= @TYPS
and		t2.start_date <= t1.day_date
and		t2.End_Date >= t1.day_date
and		t1.store_number = t2.store_number
--
-- Get PTD All Stores
--
select	@TY_PTD_All = sum(Extended_Price) 
from	dssdata.dbo.Dsr_Store_Daily t1
where	t1.day_date >= @TYPS
--
--
-- Get PTD Comp Budget
--
select	@TY_PTD_Comp_Bud = sum(Comp_Stores)
from	reference.dbo.DSR_Daily_Budget
where	day_date >= @TYPS
--
-- Get PTD All Stores Budget
--
select	@TY_PTD_All_Bud = sum(All_Stores)
from	reference.dbo.DSR_Daily_Budget
where	day_date >= @TYPS
--
-- Get QTD Comp Stores
--
select	@TY_QTD_Comp = sum(Extended_Price)
from	dssdata.dbo.Dsr_Store_Daily t1,
		reference.dbo.Comp_Stores_History t2
where	t1.day_date >= @TYQS
and		t2.start_date <= t1.day_date
and		t2.End_Date >= t1.day_date
and		t1.store_number = t2.store_number
--
-- Get QTD All Stores
--
select	@TY_QTD_All = sum(Extended_Price) 
from	dssdata.dbo.Dsr_Store_Daily t1
where	t1.day_date >= @TYQS
--
-- Get QTD Comp Budget
--
select	@TY_QTD_Comp_Bud = sum(Comp_Stores)
from	reference.dbo.DSR_Daily_Budget
where	day_date >= @TYQS
--
-- Get QTD All Stores Budget
--
select	@TY_QTD_All_Bud = sum(All_Stores)
from	reference.dbo.DSR_Daily_Budget
where	day_date >= @TYQS
--
-- Get YTD Comp Stores
--
select	@TY_YTD_Comp = sum(Extended_Price) 
from	dssdata.dbo.Dsr_Store_Daily t1,
		reference.dbo.Comp_Stores_History t2
where	t1.day_date >= @TYYS
and		t2.start_date <= t1.day_date
and		t2.End_Date >= t1.day_date
and		t1.store_number = t2.store_number
--
-- Get YTD All Stores
--
select	@TY_YTD_All = sum(Extended_Price) 
from	dssdata.dbo.Dsr_Store_Daily t1
where	t1.day_date >= @TYYS
--
-- Get YTD Comp Budget
--
select	@TY_YTD_Comp_Bud = sum(Comp_Stores)
from	reference.dbo.DSR_Daily_Budget
where	day_date >= @TYYS
--
-- Get YTD All Stores Budget
--
select	@TY_YTD_All_Bud = sum(All_Stores)
from	reference.dbo.DSR_Daily_Budget
where	day_date >= @TYYS
--
-- Get Last Year Data For Each Break
--
-- Get Yesterday DSR Comp
--
select	@LY_Daily_Comp = sum(Extended_Price)
from	dssdata.dbo.Dsr_Store_Daily t1,
		reference.dbo.Comp_Stores_History t2
where	t1.day_date = @LYYES
and		t1.day_date <= @LYYES
and		t2.start_date <= @LYYES
and		t2.End_Date >= @LYYES
and		t1.store_number = t2.store_number
--
-- Get Yesterday DSR All Stores
--
select	@LY_Daily_All = sum(Extended_Price)
from	dssdata.dbo.Dsr_Store_Daily t1
where	t1.day_date = @LYYES
--
-- Get WTD DSR Comp Stores
--
select	@LY_WTD_Comp = sum(Extended_Price)
from	dssdata.dbo.Dsr_Store_Daily t1,
		reference.dbo.Comp_Stores_History t2
where	t1.day_date >= @LYWS
and		t1.day_date <= @LYYES
and		t2.start_date <= t1.day_date
and		t2.End_Date >= t1.day_date
and		t1.store_number = t2.store_number
--
-- Get WTD All Stores
--
select	@LY_WTD_All = sum(Extended_Price) 
from	dssdata.dbo.Dsr_Store_Daily t1
where	t1.day_date >= @LYWS
and		t1.day_date <= @LYYES
--
-- Get PTD DSR Comp Stores
--
select	@LY_PTD_Comp = sum(Extended_Price)
from	dssdata.dbo.Dsr_Store_Daily t1,
		reference.dbo.Comp_Stores_History t2
where	t1.day_date >= @LYPS
and		t1.day_date <= @LYYES
and		t2.start_date <= t1.day_date
and		t2.End_Date >= t1.day_date
and		t1.store_number = t2.store_number
--
-- Get PTD All Stores
--
select	@LY_PTD_All = sum(Extended_Price) 
from	dssdata.dbo.Dsr_Store_Daily t1
where	t1.day_date >= @LYPS
and		t1.day_date <= @LYYES
--
-- Get QTD Comp Stores
--
select	@LY_QTD_Comp = sum(Extended_Price)
from	dssdata.dbo.Dsr_Store_Daily t1,
		reference.dbo.Comp_Stores_History t2
where	t1.day_date >= @LYQS
and		t1.day_date <= @LYYES
and		t2.start_date <= t1.day_date
and		t2.End_Date >= t1.day_date
and		t1.store_number = t2.store_number
--
-- Get QTD All Stores
--
select	@LY_QTD_All = sum(Extended_Price) 
from	dssdata.dbo.Dsr_Store_Daily t1
where	t1.day_date >= @LYQS
and		t1.day_date <= @LYYES
--
-- Get YTD Comp Stores
--
select	@LY_YTD_Comp = sum(Extended_Price) 
from	dssdata.dbo.Dsr_Store_Daily t1,
		reference.dbo.Comp_Stores_History t2
where	t1.day_date >= @LYYS
and		t1.day_date <= @LYYES
and		t2.start_date <= t1.day_date
and		t2.End_Date >= t1.day_date
and		t1.store_number = t2.store_number
--
-- Get YTD All Stores
--
select	@LY_YTD_All = sum(Extended_Price) 
from	dssdata.dbo.Dsr_Store_Daily t1
where	t1.day_date >= @LYYS
and		t1.day_date <= @LYYES
--
-- Display Collected Data
--
select	@TY_Daily_Comp as TY_Daily_Comp,
		@TY_Daily_All as TY_Daily_All,
		@TY_Daily_Comp_Bud as TY_Daily_Comp_Bud,
		@TY_Daily_All_Bud as TY_Daily_All_Bud,
		@LY_Daily_Comp as LY_Daily_Comp,
		@LY_Daily_All as LY_Daily_All,
		@TY_WTD_Comp as TY_WTD_Comp,
		@TY_WTD_All as TY_WTD_All,
		@TY_WTD_Comp_Bud as TY_WTD_Comp_Bud,
		@TY_WTD_All_Bud as TY_WTD_All_Bud,
		@LY_WTD_Comp as LY_WTD_Comp,
		@LY_WTD_All as LY_WTD_All,
		@TY_PTD_Comp as TY_PTD_Comp,
		@TY_PTD_All as TY_PTD_All,
		@TY_PTD_Comp_Bud as TY_PTD_Comp_Bud,
		@TY_PTD_All_Bud as TY_PTD_All_Bud,
		@LY_PTD_Comp as LY_PTD_Comp,
		@LY_PTD_All as LY_PTD_All,
		@TY_QTD_Comp as TY_QTD_Comp,
		@TY_QTD_All as TY_QTD_All,
		@TY_QTD_Comp_Bud as TY_QTD_Comp_Bud,
		@TY_QTD_All_Bud as TY_QTD_All_Bud,
		@LY_QTD_Comp as LY_QTD_Comp,
		@LY_QTD_All as LY_QTD_All,
		@TY_YTD_Comp as TY_YTD_Comp,
		@TY_YTD_All as TY_YTD_All,
		@TY_YTD_Comp_Bud as TY_YTD_Comp_Bud,
		@TY_YTD_All_Bud as TY_YTD_All_Bud,
		@LY_YTD_Comp as LY_YTD_Comp,
		@LY_YTD_All as LY_YTD_Comp


GO
