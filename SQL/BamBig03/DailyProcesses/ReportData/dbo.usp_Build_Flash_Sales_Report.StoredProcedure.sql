USE [ReportData]
GO
/****** Object:  StoredProcedure [dbo].[usp_Build_Flash_Sales_Report]    Script Date: 8/19/2022 3:44:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[usp_Build_Flash_Sales_Report]
as
--
declare @fiscal_year int
declare @fiscal_period int
declare @TY_Start smalldatetime
declare @TY_End smalldatetime
declare @LY_Start smalldatetime
declare @LY_End smalldatetime
declare @Store_Number int
declare @Old_Store int
declare @TY_SLSD money
declare @LY_SLSD money
declare @TY_Cumm money
declare @LY_Cumm money
declare @Day_Date smalldatetime
declare @Week int
declare @Day_Week int
declare @TY_MTD money
declare @LY_MTD money
--
select @fiscal_year = fiscal_year from reference.dbo.calendar_dim where day_date = staging.dbo.fn_DateOnly(getdate())
select @fiscal_period = fiscal_period from reference.dbo.calendar_dim where day_date = staging.dbo.fn_DateOnly(getdate())
select @TY_Start = min(day_date) from reference.dbo.calendar_dim where fiscal_year = @fiscal_year and fiscal_period = @fiscal_period
select @TY_End = Max(day_date) from reference.dbo.calendar_dim where fiscal_year = @fiscal_year and fiscal_period = @fiscal_period
select @fiscal_year = @fiscal_year - 1
select @LY_Start = min(day_date) from reference.dbo.calendar_dim where fiscal_year = @fiscal_year and fiscal_period = @fiscal_period
select @LY_End = Max(day_date) from reference.dbo.calendar_dim where fiscal_year = @fiscal_year and fiscal_period = @fiscal_period
--
truncate table ReportData.dbo.Flash_Sales_Report
--
insert into ReportData.dbo.Flash_Sales_Report
select	t1.day_date,
		t1.fiscal_period_week,
		t1.day_of_week_number,
		t2.store_number,
		0,
		0,
		0,
		0,
		0,
		0
from	reference.dbo.calendar_dim t1,
		reference.dbo.active_stores t2
where	t1.day_date >= @TY_Start
and		t1.day_date <= @TY_End
--
select	t1.day_date,
		t1.fiscal_period_week,
		t1.day_of_week_number,
		t2.store_number,
		sum(t2.extended_price) as TY_SLSD
into	#TY
from	reference.dbo.calendar_dim t1,
		dssdata.dbo.detail_transaction_history t2
where	t1.day_date >= @TY_Start
and		t2.day_date = t1.day_date
and		t2.transaction_code <> 'ED'
group by t1.day_date,t1.fiscal_period_week,t1.day_of_week_number,t2.Store_Number
--
update	ReportData.dbo.Flash_Sales_Report
set		ReportData.dbo.Flash_Sales_Report.TY_SLSD = #TY.TY_SLSD
from	#TY
where	ReportData.dbo.Flash_Sales_Report.day_date = #TY.day_date
and		ReportData.dbo.Flash_Sales_Report.Store_Number = #TY.Store_Number
--
select	day_date,
		Store_Number,
		sum(Unit_Retail) as Retail
into	#MCC_TY
from	dssdata.dbo.Club_Card_Activity
where	day_date >= @TY_Start
group by day_date,store_number
--
Update	ReportData.dbo.Flash_Sales_Report
set		TY_SLSD = TY_SLSD + #MCC_TY.Retail
from	#MCC_TY
where	ReportData.dbo.Flash_Sales_Report.Day_Date = #MCC_TY.Day_Date
and		ReportData.dbo.Flash_Sales_Report.Store_Number = #MCC_TY.Store_Number
--
select	t1.day_date,
		t1.fiscal_period_week,
		t1.day_of_week_number,
		t2.store_number,
		isnull(sum(t2.extended_price),0) as LY_SLSD
into	#FSR_LY
from	reference.dbo.calendar_dim t1,
		dssdata.dbo.detail_transaction_History t2
where	t1.day_date >= @LY_Start
and		t1.day_date <= @LY_End
and		t2.day_date = t1.day_date
and		t2.transaction_code <> 'ED'
group by t1.day_date,t1.fiscal_period_week,t1.day_of_week_number,t2.Store_Number
--
update	reportdata.dbo.Flash_Sales_Report
set		reportdata.dbo.Flash_Sales_Report.LY_SLSD = #FSR_LY.LY_SLSD
from	#FSR_LY
where	reportdata.dbo.Flash_Sales_Report.Fiscal_Period_Week = #FSR_LY.Fiscal_Period_Week
and		reportdata.dbo.Flash_Sales_Report.Day_Of_Week_Number = #FSR_LY.Day_Of_Week_Number
and		reportdata.dbo.Flash_Sales_Report.Store_Number = #FSR_LY.Store_Number
--
select	t1.day_date,
		t1.fiscal_period_week,
		t1.day_of_week_number,
		t2.store_number,
		isnull(sum(t2.Unit_Retail),0) as LY_SLSD
into	#MCC_LY
from	reference.dbo.calendar_dim t1,
		dssdata.dbo.Club_Card_Activity t2
where	t1.day_date >= @LY_Start
and		t1.day_date <= @LY_End
and		t2.day_date = t1.day_date
group by t1.day_date,t1.fiscal_period_week,t1.day_of_week_number,t2.Store_Number
--
update	reportdata.dbo.Flash_Sales_Report
set		reportdata.dbo.Flash_Sales_Report.LY_SLSD = reportdata.dbo.Flash_Sales_Report.LY_SLSD + #MCC_LY.LY_SLSD
from	#MCC_LY
where	reportdata.dbo.Flash_Sales_Report.Fiscal_Period_Week = #MCC_LY.Fiscal_Period_Week
and		reportdata.dbo.Flash_Sales_Report.Day_Of_Week_Number = #MCC_LY.Day_Of_Week_Number
and		reportdata.dbo.Flash_Sales_Report.Store_Number = #MCC_LY.Store_Number



--select	day_date,
--		Store_Number,
--		sum(Unit_Retail) as Retail
--into	#MCC_LY
--from	dssdata.dbo.Club_Card_Activity
--where	day_date >= @LY_Start
--and		day_date <= @LY_End
--group by day_date,store_number
----
--Update	ReportData.dbo.Flash_Sales_Report
--set		LY_SLSD = LY_SLSD + #MCC_LY.Retail
--from	#MCC_LY
--where	ReportData.dbo.Flash_Sales_Report.Day_Date = dateadd(yy,1,#MCC_LY.Day_Date)
--and		ReportData.dbo.Flash_Sales_Report.Store_Number = #MCC_LY.Store_Number
--
select	day_date,
		store_number,
		TY_SLSD,
		LY_SLSD
into	#FSR_Upd
from	reportdata.dbo.Flash_Sales_Report
order by day_date,store_number
--
select @Old_Store = 0
--
declare cur cursor for select day_date,fiscal_period_week,day_of_week_number,store_number,TY_SLSD,LY_SLSD
                       from reportdata.dbo.Flash_Sales_Report
                       order by Store_number,day_date
open cur
fetch next from cur into @day_date,@Week,@Day_Week,@Store_Number,@TY_SLSD,@LY_SLSD
--
while @@Fetch_Status = 0
begin
	if @Old_Store <> @Store_Number
	begin
		if @Week = 1 and @Day_Week = 1
		begin
			select	@TY_Cumm = @TY_SLSD
			select	@LY_CUMM = @LY_SLSD
--
			update	reportdata.dbo.flash_sales_report
			set		TY_Cumm = @TY_Cumm,
					LY_Cumm = @LY_Cumm
			where	Day_Date = @Day_Date
			and		Store_Number = @Store_Number
		End
		Else
		Begin
			update	reportdata.dbo.flash_sales_report
			set		TY_Cumm = @TY_Cumm,
					LY_Cumm = @LY_Cumm
			where	Day_Date = @Day_Date
			and		Store_Number = @Store_Number
--
			select @TY_Cumm = 0
			select @LY_Cumm = 0
		End
		select @Old_Store = @Store_Number
	End
	Else
	Begin
--
		select	@TY_Cumm = @TY_Cumm + @TY_SLSD
		select	@LY_Cumm = @LY_Cumm + @LY_SLSD
--
		update	reportdata.dbo.flash_sales_report
		set		TY_Cumm = @TY_Cumm,
				LY_Cumm = @LY_Cumm
		where	Day_Date = @Day_Date
		and		Store_Number = @Store_Number
	End
--
	fetch next from cur into @day_date,@Week,@Day_Week,@Store_Number,@TY_SLSD,@LY_SLSD
End
--
close cur
deallocate cur
--
select Store_Number,sum(TY_SLSD) as TY_MTD
into #TY_MTD
from reportdata.dbo.flash_sales_report
group by store_number
--
update reportdata.dbo.flash_sales_report
set reportdata.dbo.flash_sales_report.TY_MTD = #TY_MTD.TY_MTD
from #TY_MTD
where reportdata.dbo.flash_sales_report.Store_number = #TY_MTD.Store_Number
--
select Store_Number,sum(LY_SLSD) as LY_MTD
into #LY_MTD
from reportdata.dbo.flash_sales_report
where TY_SLSD > 0
group by store_number
--
update reportdata.dbo.flash_sales_report
set reportdata.dbo.flash_sales_report.LY_MTD = #LY_MTD.LY_MTD
from #LY_MTD
where reportdata.dbo.flash_sales_report.Store_number = #LY_MTD.Store_Number



GO
