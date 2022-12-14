USE [ReportData]
GO
/****** Object:  StoredProcedure [dbo].[usp_Debug_Example]    Script Date: 8/19/2022 3:44:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[usp_Debug_Example]
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
declare @DOW int
--
-- Get Yesterday, Week, Period, Quarter and Year Dates
--
select @TYYES = Dateadd(dd,-1,staging.dbo.fn_DateOnly(Getdate()))
select @DOW = day_of_week_number from reference.dbo.calendar_dim where day_date = @TYYES
select @LYYES = staging.dbo.fn_Last_Saturday(Dateadd(yy,-1,Getdate()))
select @LYYES = dateadd(dd,@DOW,@LYYES)
--
select @fiscal_year = Fiscal_Year from reference.dbo.Calendar_Dim where day_date = @TYYES
select @fiscal_Period = Fiscal_Period from reference.dbo.Calendar_Dim where day_date = @TYYES
select @fiscal_Quarter = Fiscal_Quarter from reference.dbo.Calendar_Dim where day_date = @TYYES
--
select @TYWS = dateadd(dd,1,staging.dbo.fn_Last_Saturday(@TYYES))
select @LYWS = dateadd(dd,1,staging.dbo.fn_Last_Saturday(dateadd(yy,-1,Getdate())))
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
-- Get Stores
--
declare @Comp_Stores int
declare @Polled_Stores int
--
select	@Comp_Stores = count(*)
		from reference.dbo.comp_stores
--
select	t1.store_number,
		count(t2.transaction_nbr) as Numtrans
into	#Stores_Trans
from	reference.dbo.active_stores t1 left join 
		dssdata.dbo.detail_transaction_period t2
on		t2.store_number = t1.store_number
and		day_date = @TYYES
group by t1.store_number
--
select	@Polled_Stores = count(t1.Store_Number)
from	#Stores_Trans t1,
		Reference.dbo.comp_stores t2
where	t1.store_number = t2.store_number
and		t1.numtrans > 0
--
truncate table reportdata.dbo.reporting_stores
insert into reportdata.dbo.reporting_stores
select @Comp_Stores - @Polled_Stores
--
-- Get Yesterday DSR Comp
--
truncate table Staging.dbo.TYYES_Comp
insert into Staging.dbo.TYYES_Comp
select		t1.Dept,
			sum(t1.Extended_Price) as TYYES_Comp,
			sum(t1.Extended_Discount) as TYYES_Comp_Disc
from		Dssdata.dbo.DSR_Store_Daily t1 
join		Reference.dbo.comp_stores t5
on			t1.Store_Number = t5.Store_Number
where		t1.day_date = @TYYES
group by	t1.Dept
order by	staging.dbo.fn_LeftPad(t1.Dept,2)
--
-- Get YES Comp Budget
--
truncate table Staging.dbo.TYYES_Comp_Bud
insert into Staging.dbo.TYYES_Comp_Bud
select		t1.Dept,
			sum(t1.CompStore) as TYYES_Comp_Bud
from		staging.dbo.DSR_Budget_FY2010 t1
where 		t1.day_date = @TYYES 
group by	t1.Dept
order by	staging.dbo.fn_LeftPad(t1.Dept,2)
GO
