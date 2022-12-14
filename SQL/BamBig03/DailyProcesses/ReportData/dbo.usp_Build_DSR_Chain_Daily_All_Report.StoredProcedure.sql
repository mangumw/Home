USE [ReportData]
GO
/****** Object:  StoredProcedure [dbo].[usp_Build_DSR_Chain_Daily_All_Report]    Script Date: 8/19/2022 3:44:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[usp_Build_DSR_Chain_Daily_All_Report]
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
--declare @Active_Stores int
--declare @Polled_Stores int
----
--select	@Active_Stores = count(*)
--		from reference.dbo.Active_Stores
----
--select	t1.store_number,
--		count(t2.transaction_nbr) as Numtrans
--into	#Stores_Trans
--from	reference.dbo.active_stores t1 left join 
--		dssdata.dbo.detail_transaction_period t2
--on		t2.store_number = t1.store_number
--and		day_date = @TYYES
--group by t1.store_number
----
--select	@Polled_Stores = count(t1.Store_Number)
--from	#Stores_Trans t1,
--		Reference.dbo.Active_Stores t2
--where	t1.store_number = t2.store_number
--and		t1.numtrans > 0
----
--truncate table reportdata.dbo.reporting_stores
--insert into reportdata.dbo.reporting_stores
--select @Active_Stores - @Polled_Stores
--
-- Get Yesterday DSR Comp
--
select		t1.Dept,
			sum(t1.Extended_Price) as TYYES_Comp,
			sum(t1.Extended_Discount) as TYYES_Comp_Disc
into		#TYYES_Comp
from		Dssdata.dbo.DSR_Store_Daily t1 
join		Reference.dbo.Active_Stores t5
on			t1.Store_Number = t5.Store_Number
where		t1.day_date = @TYYES
group by	t1.Dept
order by	staging.dbo.fn_LeftPad(t1.Dept,2)
--
-- Get YES Comp Budget
--
select		t1.Dept,
			sum(t1.CompStore) as TYYES_Comp_Bud
into		#TYYES_Comp_Bud
from		staging.dbo.DSR_Budget_FY2010 t1
where 		t1.day_date = @TYYES 
group by	t1.Dept
order by	staging.dbo.fn_LeftPad(t1.Dept,2)
--
-- Get YES DSR All Stores
--
select		t1.Dept,
			sum(t1.Extended_Price) as TYYES_All,
			sum(t1.Extended_Discount) as TYYES_All_Disc
into		#TYYES_All
from		Dssdata.dbo.DSR_Store_Daily t1 
where		t1.day_date = @TYYES
group by	t1.Dept
order by	staging.dbo.fn_LeftPad(t1.Dept,2)
--
-- Get YES All Budget
--
select		t1.Dept,
			sum(t1.AllStore) as TYYES_All_Bud
into		#TYYES_All_Bud
from		staging.dbo.DSR_Budget_FY2010 t1
where 		t1.day_date >= @TYYES
and			t1.day_date < staging.dbo.fn_DateOnly(getdate())
group by	t1.Dept
order by	staging.dbo.fn_LeftPad(t1.Dept,2)
--
-- Get WTD DSR Comp Stores
--
select		t1.Dept,
			sum(t1.Extended_Price) as TYWTD_Comp,
			sum(t1.Extended_Discount) as TYWTD_Comp_Disc
into		#TYWTD_Comp
from		Dssdata.dbo.DSR_Store_Daily t1 
join		Reference.dbo.Active_Stores t5
on			t1.Store_Number = t5.Store_Number
where		t1.day_date >= @TYWS
group by	t1.Dept
order by	staging.dbo.fn_LeftPad(t1.Dept,2)
--
-- Get WTD Comp Budget
--
select		t1.Dept,
			sum(t1.CompStore) as TYWTD_Comp_Bud
into		#TYWTD_Comp_Bud
from		staging.dbo.DSR_Budget_FY2010 t1
where 		t1.day_date >= @TYWS 
and			t1.day_date < staging.dbo.fn_DateOnly(getdate())
group by	t1.Dept
order by	staging.dbo.fn_LeftPad(t1.Dept,2)
--
-- Get WTD DSR All Stores
--
select		t1.Dept,
			sum(t1.Extended_Price) as TYWTD_All,
			sum(t1.Extended_Discount) as TYWTD_All_Disc
into		#TYWTD_All
from		Dssdata.dbo.DSR_Store_Daily t1 
where		t1.day_date >= @TYWS
group by	t1.Dept
order by	staging.dbo.fn_LeftPad(t1.Dept,2)
--
-- Get WTD All Budget
--
select		t1.Dept,
			sum(t1.AllStore) as TYWTD_All_Bud
into		#TYWTD_All_Bud
from		staging.dbo.DSR_Budget_FY2010 t1
where 		t1.day_date >= @TYWS 
and			t1.day_date < staging.dbo.fn_DateOnly(getdate())
group by	t1.Dept
order by	staging.dbo.fn_LeftPad(t1.Dept,2)
--
-- Get PTD DSR Comp Stores
--
select		t1.Dept,
			sum(t1.Extended_Price) as TYPTD_Comp,
			sum(t1.Extended_Discount) as TYPTD_Comp_Disc
into		#TYPTD_Comp
from		Dssdata.dbo.DSR_Store_Daily t1 
join		Reference.dbo.Active_Stores t5
on			t1.Store_Number = t5.Store_Number
where		t1.day_date >= @TYPS
group by	t1.Dept
order by	staging.dbo.fn_LeftPad(t1.Dept,2)
--
-- Get PTD Comp Budget
--
select		t1.Dept,
			sum(t1.CompStore) as TYPTD_Comp_Bud
into		#TYPTD_Comp_Bud
from		staging.dbo.DSR_Budget_FY2010 t1
where 		t1.day_date >= @TYPS 
and			t1.day_date < staging.dbo.fn_DateOnly(getdate())
group by	t1.Dept
order by	staging.dbo.fn_LeftPad(t1.Dept,2)
--
-- Get PTD DSR All Stores
--
select		t1.Dept,
			sum(t1.Extended_Price) as TYPTD_All,
			sum(t1.Extended_Discount) as TYPTD_All_Disc
into		#TYPTD_All
from		Dssdata.dbo.DSR_Store_Daily t1 
where		t1.day_date >= @TYPS
group by	t1.Dept
order by	staging.dbo.fn_LeftPad(t1.Dept,2)
--
-- Get PTD All Budget
--
select		t1.Dept,
			sum(t1.AllStore) as TYPTD_All_Bud
into		#TYPTD_All_Bud
from		staging.dbo.DSR_Budget_FY2010 t1
where 		t1.day_date >= @TYPS 
and			t1.day_date < staging.dbo.fn_DateOnly(getdate())
group by	t1.Dept
order by	staging.dbo.fn_LeftPad(t1.Dept,2)
--
-- Get QTD DSR Comp Stores
--
select		t1.Dept,
			sum(t1.Extended_Price) as TYQTD_Comp,
			sum(t1.Extended_Discount) as TYQTD_Comp_Disc
into		#TYQTD_Comp
from		Dssdata.dbo.DSR_Store_Daily t1 
join		Reference.dbo.Active_Stores t5
on			t1.Store_Number = t5.Store_Number
where		t1.day_date >= @TYQS
group by	t1.Dept
order by	staging.dbo.fn_LeftPad(t1.Dept,2)
--
-- Get QTD Comp Budget
--
select		t1.Dept,
			sum(t1.CompStore) as TYQTD_Comp_Bud
into		#TYQTD_Comp_Bud
from		staging.dbo.DSR_Budget_FY2010 t1
where 		t1.day_date >= @TYQS 
and			t1.day_date < staging.dbo.fn_DateOnly(getdate())
group by	t1.Dept
order by	staging.dbo.fn_LeftPad(t1.Dept,2)
--
-- Get QTD DSR All Stores
--
select		t1.Dept,
			sum(t1.Extended_Price) as TYQTD_All,
			sum(t1.Extended_Discount) as TYQTD_All_Disc
into		#TYQTD_All
from		Dssdata.dbo.DSR_Store_Daily t1 
where		t1.day_date >= @TYQS
group by	t1.Dept
order by	staging.dbo.fn_LeftPad(t1.Dept,2)
--
-- Get QTD All Budget
--
select		t1.Dept,
			sum(t1.AllStore) as TYQTD_All_Bud
into		#TYQTD_All_Bud
from		staging.dbo.DSR_Budget_FY2010 t1
where 		t1.day_date >= @TYQS 
and			t1.day_date < staging.dbo.fn_DateOnly(getdate())
group by	t1.Dept
order by	staging.dbo.fn_LeftPad(t1.Dept,2)
--
-- Get YTD DSR Comp Stores
--
select		t1.Dept,
			sum(t1.Extended_Price) as TYYTD_Comp,
			sum(t1.Extended_Discount) as TYYTD_Comp_Disc
into		#TYYTD_Comp
from		Dssdata.dbo.DSR_Store_Daily t1 
join		Reference.dbo.Active_Stores t5
on			t1.Store_Number = t5.Store_Number
where		t1.day_date >= @TYYS
group by	t1.Dept
order by	staging.dbo.fn_LeftPad(t1.Dept,2)
--
-- Get PTD Comp Budget
--
select		t1.Dept,
			sum(t1.CompStore) as TYYTD_Comp_Bud
into		#TYYTD_Comp_Bud
from		staging.dbo.DSR_Budget_FY2010 t1
where 		t1.day_date >= @TYYS 
and			t1.day_date < staging.dbo.fn_DateOnly(getdate())
group by	t1.Dept
order by	staging.dbo.fn_LeftPad(t1.Dept,2)
--
-- Get YTD DSR All Stores
--
select		t1.Dept,
			sum(t1.Extended_Price) as TYYTD_All,
			sum(t1.Extended_Discount) as TYYTD_All_Disc
into		#TYYTD_All
from		Dssdata.dbo.DSR_Store_Daily t1 
where		t1.day_date >= @TYYS
group by	t1.Dept
order by	staging.dbo.fn_LeftPad(t1.Dept,2)
--
-- Get YTD All Budget
--
select		t1.Dept,
			sum(t1.AllStore) as TYYTD_All_Bud
into		#TYYTD_All_Bud
from		staging.dbo.DSR_Budget_FY2010 t1
where 		t1.day_date >= @TYYS 
and			t1.day_date < staging.dbo.fn_DateOnly(getdate())
group by	t1.Dept
order by	staging.dbo.fn_LeftPad(t1.Dept,2)
--
-- Get Last Year Data For Each Break
--
--
-- Get Yesterday DSR Comp
--
select		t1.Dept,
			t4.Description,
			sum(t1.Extended_Price) as LYYES_Comp,
			sum(t1.Extended_Discount) as LYYES_Comp_Disc
into		#LYYES_Comp
from		Dssdata.dbo.DSR_Store_Daily t1 
join		reference.dbo.DSR_Special_Dept t4
on			t4.Dept = t1.dept 
join		Reference.dbo.Active_Stores t5
on			t1.Store_Number = t5.Store_Number
where		t1.day_date = @LYYES
group by	t1.Dept,t4.Description
order by	staging.dbo.fn_LeftPad(t1.Dept,2)
--
-- Get Yesterday DSR All Stores
--
select		t1.Dept,
			t4.Description,
			sum(t1.Extended_Price) as LYYES_All,
			sum(t1.Extended_Discount) as LYYES_All_Disc
into		#LYYES_All
from		Dssdata.dbo.DSR_Store_Daily t1 
join		reference.dbo.DSR_Special_Dept t4
on			t4.Dept = t1.dept 
where		t1.day_date = @LYYES
group by	t1.Dept,t4.Description
order by	staging.dbo.fn_LeftPad(t1.Dept,2)
--
-- Get WTD DSR Comp
--
select		t1.Dept,
			t4.Description,
			sum(t1.Extended_Price) as LYWTD_Comp,
			sum(t1.Extended_Discount) as LYWTD_Comp_Disc
into		#LYWTD_Comp
from		Dssdata.dbo.DSR_Store_Daily t1 
join		reference.dbo.DSR_Special_Dept t4
on			t4.Dept = t1.dept 
join		Reference.dbo.Active_Stores t5
on			t1.Store_Number = t5.Store_Number
where		t1.day_date >= @LYWS
and			t1.day_date <= @LYYES
group by	t1.Dept,t4.Description
order by	staging.dbo.fn_LeftPad(t1.Dept,2)
--
-- Get WTD DSR All Stores
--
select		t1.Dept,
			t4.Description,
			sum(t1.Extended_Price) as LYWTD_All,
			sum(t1.Extended_Discount) as LYWTD_All_Disc
into		#LYWTD_All
from		Dssdata.dbo.DSR_Store_Daily t1 
join		reference.dbo.DSR_Special_Dept t4
on			t4.Dept = t1.dept 
where		t1.day_date >= @LYWS
and			t1.day_date <= @LYYES
group by	t1.Dept,t4.Description
order by	staging.dbo.fn_LeftPad(t1.Dept,2)
--
-- Get PTD DSR Comp
--
select		t1.Dept,
			t4.Description,
			sum(t1.Extended_Price) as LYPTD_Comp,
			sum(t1.Extended_Discount) as LYPTD_Comp_Disc
into		#LYPTD_Comp
from		Dssdata.dbo.DSR_Store_Daily t1 
join		reference.dbo.DSR_Special_Dept t4
on			t4.Dept = t1.dept 
join		Reference.dbo.Active_Stores t5
on			t1.Store_Number = t5.Store_Number
where		t1.day_date >= @LYPS
and			t1.day_date <= @LYYES
group by	t1.Dept,t4.Description
order by	staging.dbo.fn_LeftPad(t1.Dept,2)
--
-- Get PTD DSR All Stores
--
select		t1.Dept,
			t4.Description,
			sum(t1.Extended_Price) as LYPTD_All,
			sum(t1.Extended_Discount) as LYPTD_All_Disc
into		#LYPTD_All
from		Dssdata.dbo.DSR_Store_Daily t1 
join		reference.dbo.DSR_Special_Dept t4
on			t4.Dept = t1.dept 
where		t1.day_date >= @LYPS
and			t1.day_date <= @LYYES
group by	t1.Dept,t4.Description
order by	staging.dbo.fn_LeftPad(t1.Dept,2)
--
-- Get QTD DSR Comp
--
select		t1.Dept,
			t4.Description,
			sum(t1.Extended_Price) as LYQTD_Comp,
			sum(t1.Extended_Discount) as LYQTD_Comp_Disc
into		#LYQTD_Comp
from		Dssdata.dbo.DSR_Store_Daily t1 
join		reference.dbo.DSR_Special_Dept t4
on			t4.Dept = t1.dept 
join		Reference.dbo.Active_Stores t5
on			t1.Store_Number = t5.Store_Number
where		t1.day_date >= @LYQS
and			t1.day_date <= @LYYES
group by	t1.Dept,t4.Description
order by	staging.dbo.fn_LeftPad(t1.Dept,2)
--
-- Get QTD DSR All Stores
--
select		t1.Dept,
			t4.Description,
			sum(t1.Extended_Price) as LYQTD_All,
			sum(t1.Extended_Discount) as LYQTD_All_Disc
into		#LYQTD_All
from		Dssdata.dbo.DSR_Store_Daily t1 
join		reference.dbo.DSR_Special_Dept t4
on			t4.Dept = t1.dept 
where		t1.day_date >= @LYQS
and			t1.day_date <= @LYYES
group by	t1.Dept,t4.Description
order by	staging.dbo.fn_LeftPad(t1.Dept,2)
--
-- Get YTD DSR Comp
--
select		t1.Dept,
			t4.Description,
			sum(t1.Extended_Price) as LYYTD_Comp,
			sum(t1.Extended_Discount) as LYYTD_Comp_Disc
into		#LYYTD_Comp
from		Dssdata.dbo.DSR_Store_Daily t1 
join		reference.dbo.DSR_Special_Dept t4
on			t4.Dept = t1.dept 
join		Reference.dbo.Active_Stores t5
on			t1.Store_Number = t5.Store_Number
where		t1.day_date >= @LYYS
and			t1.day_date <= @LYYES
group by	t1.Dept,t4.Description
order by	staging.dbo.fn_LeftPad(t1.Dept,2)
--
-- Get YTD DSR All Stores
--
select		t1.Dept,
			t4.Description,
			sum(t1.Extended_Price) as LYYTD_All,
			sum(t1.Extended_Discount) as LYYTD_All_Disc
into		#LYYTD_All
from		Dssdata.dbo.DSR_Store_Daily t1 
join		reference.dbo.DSR_Special_Dept t4
on			t4.Dept = t1.dept 
where		t1.day_date >= @LYYS
and			t1.day_date <= @LYYES
group by	t1.Dept,t4.Description
order by	staging.dbo.fn_LeftPad(t1.Dept,2)
--
-- Construct Output Table
--
truncate table Reportdata.dbo.DSR_Chain_Report_All
insert into Reportdata.dbo.DSR_Chain_Report_All
select	staging.dbo.fn_DateOnly(dateadd(dd,-1,getdate())) as day_date,
		t0.Dept,
		t0.Description,
		isnull(t1.TYYES_Comp,0) as TYYES_Comp,
		isnull(t1.TYYES_Comp_Disc,0) as TYYES_Comp_Disc,
		isnull(t1a.TYYES_Comp_Bud,0) as TYYES_Comp_Bud,
		isnull(t2.TYYES_All,0) as TYYES_All,
		isnull(t2.TYYES_All_Disc,0) as TYYES_All_Disc,
		isnull(t2a.TYYES_All_Bud,0) as TYYES_All_Bud,
		isnull(t3.TYWTD_Comp,0) as TYWTD_Comp,
		isnull(t3.TYWTD_Comp_Disc,0) as TYWTD_Comp_Disc,
		isnull(t4.TYWTD_Comp_Bud,0) as TYWTD_Comp_Bud,
		isnull(t5.TYWTD_All,0) as TYWTD_All,
		isnull(t5.TYWTD_All_Disc,0) as TYWTD_All_Disc,
		isnull(t6.TYWTD_All_Bud,0) as TYWTD_All_Bud,
		isnull(t7.TYPTD_Comp,0) as TYPTD_Comp,
		isnull(t7.TYPTD_Comp_Disc,0) as TYPTD_Comp_Disc,
		isnull(t8.TYPTD_Comp_Bud,0) as TYPTD_Comp_Bud,
		isnull(t9.TYPTD_All,0) as TYPTD_All,
		isnull(t9.TYPTD_All_Disc,0) as TYPTD_All_Disc,
		isnull(t10.TYPTD_All_Bud,0) as TYPTD_All_Bud,
		isnull(t11.TYQTD_Comp,0) as TYQTD_Comp,
		isnull(t11.TYQTD_Comp_Disc,0) as TYQTD_Comp_Disc,
		isnull(t12.TYQTD_Comp_Bud,0) as TYQTD_Comp_Bud,
		isnull(t13.TYQTD_All,0) as TYQTD_All,
		isnull(t13.TYQTD_All_Disc,0) as TYQTD_All_Disc,
		isnull(t14.TYQTD_All_Bud,0) as TYQTD_All_Bud,
		isnull(t15.TYYTD_Comp,0) as TYYTD_Comp,
		isnull(t15.TYYTD_Comp_Disc,0) as TYYTD_Comp_Disc,
		isnull(t16.TYYTD_Comp_Bud,0) as TYYTD_Comp_Bud,
		isnull(t17.TYYTD_All,0) as TYYTD_All,
		isnull(t17.TYYTD_All_Disc,0) as TYYTD_All_Disc,
		isnull(t18.TYYTD_All_Bud,0) as TYYTD_All_Bud,
		isnull(t19.LYYES_Comp,0) as LYYES_Comp,
		isnull(t19.LYYES_Comp_Disc,0) as LYYES_Comp_Disc,
		isnull(t20.LYYES_All,0) as LYYES_All,
		isnull(t20.LYYES_All_Disc,0) as LYYES_All_Disc,
		isnull(t21.LYWTD_Comp,0) as LYWTD_Comp,
		isnull(t21.LYWTD_Comp_Disc,0) as LYWTD_Comp_Disc,
		isnull(t22.LYWTD_All,0) as LYWTD_All,
		isnull(t22.LYWTD_All_Disc,0) as LYWTD_All_Disc,
		isnull(t23.LYPTD_Comp,0) as LYPTD_Comp,
		isnull(t23.LYPTD_Comp_Disc,0) as LYPTD_Comp_Disc,
		isnull(t24.LYPTD_All,0) as LYPTD_All,
		isnull(t24.LYPTD_All_Disc,0) as LYPTD_All_Disc,
		isnull(t25.LYQTD_Comp,0) as LYQTD_Comp,
		isnull(t25.LYQTD_Comp_Disc,0) as LYQTD_Comp_Disc,
		isnull(t26.LYQTD_All,0) as LYQTD_All,
		isnull(t26.LYQTD_All_Disc,0) as LYQTD_All_Disc,
		isnull(t27.LYYTD_Comp,0) as LYYTD_Comp,
		isnull(t27.LYYTD_Comp_Disc,0) as LYYTD_Comp_Disc,
		isnull(t28.LYYTD_All,0) as LYYTD_All,
		isnull(t28.LYYTD_All_Disc,0) as LYYTD_All_Disc
from	reference.dbo.DSR_Special_Dept t0 
		left join #TYYES_Comp t1 on t1.dept = t0.dept
		left join #TYYES_Comp_Bud t1a on t1a.dept = t0.dept
		left join #TYYES_All t2 on t2.dept = t0.dept
		left join #TYYES_All_Bud t2a on t2a.dept = t0.dept
		left join #TYWTD_Comp t3 on t3.dept = t0.dept
		left join #TYWTD_Comp_Bud t4 on t4.dept = t0.dept
		left join #TYWTD_All t5 on t5.dept = t0.dept
		left join #TYWTD_All_Bud t6 on t6.dept = t0.dept
		left join #TYPTD_Comp t7 on t7.dept = t0.dept
		left join #TYPTD_Comp_Bud t8 on t8.dept = t0.dept
		left join #TYPTD_All t9 on t9.dept = t0.dept
		left join #TYPTD_All_Bud t10 on t10.dept = t0.dept
		left join #TYQTD_Comp t11 on t11.dept = t0.dept
		left join #TYQTD_Comp_Bud t12 on t12.dept = t0.dept
		left join #TYQTD_All t13 on t13.dept = t0.dept
		left join #TYQTD_All_Bud t14 on t14.dept = t0.dept
		left join #TYYTD_Comp t15 on t15.dept = t0.dept
		left join #TYYTD_Comp_Bud t16 on t16.dept = t0.dept
		left join #TYYTD_All t17 on t17.dept = t0.dept
		left join #TYYTD_All_Bud t18 on t18.dept = t0.dept
		left join #LYYES_Comp t19 on t19.dept = t0.dept
		left join #LYYES_All t20 on t20.dept = t0.dept
		left join #LYWTD_Comp t21 on t21.dept = t0.dept
		left join #LYWTD_All t22 on t22.dept = t0.dept
		left join #LYPTD_Comp t23 on t23.dept = t0.dept
		left join #LYPTD_All t24 on t24.dept = t0.dept
		left join #LYQTD_Comp t25 on t25.dept = t0.dept
		left join #LYQTD_All t26 on t26.dept = t0.dept
		left join #LYYTD_Comp t27 on t27.dept = t0.dept
		left join #LYYTD_All t28 on t28.dept = t0.dept
--
-- Build Summary Report
--
truncate table reportdata.dbo.DSR_Summary_Report_All
insert into	reportdata.dbo.DSR_Summary_Report_All
select	day_date,
		sum(TYYES_Comp) as TYYES_Comp,
		sum(LYYES_comp) as LYYES_Comp,
		sum(TYYES_Comp_Bud) as TYYES_Comp_Bud,
		sum(TYWTD_Comp) as TYWTD_Comp,
		sum(LYWTD_Comp) as LYWTD_Comp,
		sum(TYWTD_Comp_Bud) as TYWTD_Comp_Bud,
		sum(TYPTD_Comp) as TYPTD_Comp,
		sum(LYPTD_Comp) as LYPTD_Comp,
		sum(TYPTD_Comp_Bud) as TYPTD_Comp_Bud,
		sum(TYYTD_Comp) as TYYTD_Comp,
		sum(LYYTD_Comp) as LYYTD_Comp,
		sum(TYYTD_Comp_Bud) as TYYTD_Comp_Bud
from	reportdata.dbo.DSR_Chain_Report_All
where	day_date = staging.dbo.fn_DateOnly(dateadd(dd,-1,Getdate()))
group by day_date


GO
