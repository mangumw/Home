USE [ReportData]
GO
/****** Object:  StoredProcedure [dbo].[usp_daily_flash_stores_cafe]    Script Date: 8/19/2022 3:44:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[usp_daily_flash_stores_cafe] as 

--drop table #CTY
--drop table #AMCC_TY
--drop table #AFSR_LY
--drop table #AMCC_LY
--drop table #AFSR_Upd
--drop table #ATY_MTD
--drop table #ALY_MTD
--drop table #ATY1
--drop table #AFSR1_LY
--drop table #AFSR1_Upd
--drop table #ATY_MTD1
--drop table #ALY_MTD1

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
declare @TY_SLSD_CAFE money
declare @LY_SLSD_CAFE money
declare @TY_Cumm money
declare @LY_Cumm money
declare @TY_Cumm_CAFE money
declare @LY_Cumm_CAFE money
declare @Day_Date smalldatetime
declare @Week int
declare @Day_Week int
declare @TY_MTD money
declare @LY_MTD money
declare @TY_MTD_CAFE money
declare @LY_MTD_CAFE money
--
select @fiscal_year = fiscal_year from reference.dbo.calendar_dim where day_date = staging.dbo.fn_DateOnly(getdate())
select @fiscal_period = fiscal_period from reference.dbo.calendar_dim where day_date = staging.dbo.fn_DateOnly(getdate())
select @TY_Start = min(day_date) from reference.dbo.calendar_dim where fiscal_year = @fiscal_year and fiscal_period = @fiscal_period
select @TY_End = Max(day_date) from reference.dbo.calendar_dim where fiscal_year = @fiscal_year and fiscal_period = @fiscal_period
select @fiscal_year = @fiscal_year - 1
select @LY_Start = min(day_date) from reference.dbo.calendar_dim where fiscal_year = @fiscal_year and fiscal_period = @fiscal_period
select @LY_End = Max(day_date) from reference.dbo.calendar_dim where fiscal_year = @fiscal_year and fiscal_period = @fiscal_period
--
truncate table reportdata.dbo.flash_sales_report_cafe
--
insert into reportdata.dbo.flash_sales_report_cafe
select	t1.day_date,
		t1.fiscal_period_week,
		t1.day_of_week_number,
		t2.store_number,
0,0,0,0,0,0,
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
SELECT     t1.day_date, t1.fiscal_period_week, t1.day_of_week_number, t2.Store_Number, SUM(t2.Extended_Price) AS TY_SLSD
INTO            #CTY
FROM         Reference.dbo.Calendar_Dim AS t1 INNER JOIN
                      DssData.dbo.Detail_Transaction_History AS t2 ON t1.day_date = t2.Day_Date INNER JOIN
                      Reference.dbo.Item_Master AS t3 ON t2.Sku_Number = t3.SKU_Number
WHERE     (t1.day_date >= @TY_Start) AND (t2.Transaction_Code <> 'ED') AND (NOT (t3.Dept IN (13, 14, 69, 16)))
GROUP BY t1.day_date, t1.fiscal_period_week, t1.day_of_week_number, t2.Store_Number
-- COMPLETE ABOVE --------------------------
update	reportdata.dbo.flash_sales_report_cafe
set		reportdata.dbo.flash_sales_report_cafe.TY_SLSD = #CTY.TY_SLSD
from	#CTY
where	reportdata.dbo.flash_sales_report_cafe.day_date = #CTY.day_date
and		reportdata.dbo.flash_sales_report_cafe.Store_Number = #CTY.Store_Number
-- COMPLETE ABOVE ---------------------------
select	day_date,
		Store_Number,
		sum(Unit_Retail) as Retail
into	#AMCC_TY
from	dssdata.dbo.Club_Card_Activity
where	day_date >= @TY_Start
group by day_date,store_number
--
Update	reportdata.dbo.flash_sales_report_cafe
set		TY_SLSD = TY_SLSD + #AMCC_TY.Retail
from	#AMCC_TY
where	reportdata.dbo.flash_sales_report_cafe.Day_Date = #AMCC_TY.Day_Date
and		reportdata.dbo.flash_sales_report_cafe.Store_Number = #AMCC_TY.Store_Number
-- COMPLETE ABOVE -------------------------------
SELECT     t1.day_date, t1.fiscal_period_week, t1.day_of_week_number, t2.Store_Number, ISNULL(SUM(t2.Extended_Price), 0) AS LY_SLSD
INTO            #AFSR_LY
FROM         Reference.dbo.Calendar_Dim AS t1 INNER JOIN
                      DssData.dbo.Detail_Transaction_History AS t2 ON t1.day_date = t2.Day_Date INNER JOIN
                      Reference.dbo.Item_Master AS t3 ON t2.Sku_Number = t3.SKU_Number
WHERE     (t1.day_date >= @LY_Start) AND (t1.day_date <= @LY_End) AND (t2.Transaction_Code <> 'ED') AND (NOT (t3.Dept IN (13, 14, 69, 16)))
GROUP BY t1.day_date, t1.fiscal_period_week, t1.day_of_week_number, t2.Store_Number
--
update	reportdata.dbo.flash_sales_report_cafe
set		reportdata.dbo.flash_sales_report_cafe.LY_SLSD = #AFSR_LY.LY_SLSD
from	#AFSR_LY
where	reportdata.dbo.flash_sales_report_cafe.Fiscal_Period_Week = #AFSR_LY.Fiscal_Period_Week
and		reportdata.dbo.flash_sales_report_cafe.Day_Of_Week_Number = #AFSR_LY.Day_Of_Week_Number
and		reportdata.dbo.flash_sales_report_cafe.Store_Number = #AFSR_LY.Store_Number
-----------------NEW------------------------------
select	t1.day_date,
		t1.fiscal_period_week,
		t1.day_of_week_number,
		t2.store_number,
		isnull(sum(t2.Unit_Retail),0) as LY_SLSD
into	#AMCC_LY
from	reference.dbo.calendar_dim t1,
		dssdata.dbo.Club_Card_Activity t2
where	t1.day_date >= @LY_Start
and		t1.day_date <= @LY_End
and		t2.day_date = t1.day_date
group by t1.day_date,t1.fiscal_period_week,t1.day_of_week_number,t2.Store_Number
-- OLD COMMENT OUT------------------------------------------------------------
--select	day_date,
--		Store_Number,
--		sum(Unit_Retail) as Retail
--into	#AMCC_LY
--from	dssdata.dbo.Club_Card_Activity
--where	day_date >= @LY_Start
--and		day_date <= @LY_End
--group by day_date,store_number
----------------NEW-----------------------------------------------------------
update	reportdata.dbo.Flash_Sales_Report_cafe
set		reportdata.dbo.Flash_Sales_Report_cafe.LY_SLSD = reportdata.dbo.Flash_Sales_Report_cafe.LY_SLSD + #AMCC_LY.LY_SLSD
from	#AMCC_LY
where	reportdata.dbo.Flash_Sales_Report_cafe.Fiscal_Period_Week = #AMCC_LY.Fiscal_Period_Week
and		reportdata.dbo.Flash_Sales_Report_cafe.Day_Of_Week_Number = #AMCC_LY.Day_Of_Week_Number
and		reportdata.dbo.Flash_Sales_Report_cafe.Store_Number = #AMCC_LY.Store_Number
--------------OLD COMMENT OUT --------------------------------------------------------------

--
--Update	reportdata.dbo.flash_sales_report_cafe
--set		LY_SLSD = LY_SLSD + #AMCC_LY.Retail
--from	#AMCC_LY
--where	reportdata.dbo.flash_sales_report_cafe.Day_Date = dateadd(yy,1,#AMCC_LY.Day_Date)
--and		reportdata.dbo.flash_sales_report_cafe.Store_Number = #AMCC_LY.Store_Number
-- COMPLETE ABOVE--------------------------------------------------------------------------------
select	day_date,
		store_number,
		TY_SLSD,
		LY_SLSD
into	#AFSR_Upd
from	reportdata.dbo.flash_sales_report_cafe
order by day_date,store_number
--
select @Old_Store = 0
--
declare cur cursor for select day_date,fiscal_period_week,day_of_week_number,store_number,TY_SLSD,LY_SLSD
                       from reportdata.dbo.flash_sales_report_cafe
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
			select	@LY_Cumm = @LY_SLSD
--
			update	reportdata.dbo.flash_sales_report_cafe
			set		TY_Cumm = @TY_Cumm,
					LY_Cumm = @LY_Cumm
			where	Day_Date = @Day_Date
			and		Store_Number = @Store_Number
		End
		Else
		Begin
			update	reportdata.dbo.flash_sales_report_cafe
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
		update	reportdata.dbo.flash_sales_report_cafe
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
------------------------------complete above----------------------------------------
select Store_Number,sum(TY_SLSD) as TY_MTD
into #ATY_MTD
from reportdata.dbo.flash_sales_report_cafe
group by store_number
--
update reportdata.dbo.flash_sales_report_cafe
set reportdata.dbo.flash_sales_report_cafe.TY_MTD = #ATY_MTD.TY_MTD
from #ATY_MTD
where reportdata.dbo.flash_sales_report_cafe.Store_number = #ATY_MTD.Store_Number
--
select Store_Number,sum(LY_SLSD) as LY_MTD
into #ALY_MTD
from reportdata.dbo.flash_sales_report_cafe
where TY_SLSD > 0
group by store_number
--
update reportdata.dbo.flash_sales_report_cafe
set reportdata.dbo.flash_sales_report_cafe.LY_MTD = #ALY_MTD.LY_MTD
from #ALY_MTD
where reportdata.dbo.flash_sales_report_cafe.Store_number = #ALY_MTD.Store_Number
-----------------------cafe update TY -----------------------------------------------
SELECT     t1.day_date, t1.fiscal_period_week, t1.day_of_week_number, t2.Store_Number, SUM(t2.Extended_Price) AS TY_SLSD_CAFE
INTO            #ATY1
FROM         Reference.dbo.Calendar_Dim AS t1 INNER JOIN
                      DssData.dbo.Detail_Transaction_History AS t2 ON t1.day_date = t2.Day_Date INNER JOIN
                      Reference.dbo.Item_Master AS t3 ON t2.Sku_Number = t3.SKU_Number
WHERE     (t1.day_date >= @TY_Start) AND (t3.Dept IN (13, 14, 69, 16))
GROUP BY t1.day_date, t1.fiscal_period_week, t1.day_of_week_number, t2.Store_Number
--
update	reportdata.dbo.flash_sales_report_cafe
set		reportdata.dbo.flash_sales_report_cafe.TY_SLSD_CAFE = #ATY1.TY_SLSD_CAFE
from	#ATY1
where	reportdata.dbo.flash_sales_report_cafe.day_date = #ATY1.day_date
and		reportdata.dbo.flash_sales_report_cafe.Store_Number = #ATY1.Store_Number
-------------------------cafe update LY -----------------------------------------------
SELECT     t1.day_date, t1.fiscal_period_week, t1.day_of_week_number, t2.Store_Number, ISNULL(SUM(t2.Extended_Price), 0) AS LY_SLSD_CAFE
INTO            #AFSR1_LY
FROM         Reference.dbo.Calendar_Dim AS t1 INNER JOIN
                      DssData.dbo.Detail_Transaction_History AS t2 ON t1.day_date = t2.Day_Date INNER JOIN
                      Reference.dbo.Item_Master AS t3 ON t2.Sku_Number = t3.SKU_Number
WHERE     (t1.day_date >= @LY_Start) AND (t1.day_date <= @LY_End) and (t3.Dept IN (13, 14, 69, 16))
GROUP BY t1.day_date, t1.fiscal_period_week, t1.day_of_week_number, t2.Store_Number
--
update	reportdata.dbo.flash_sales_report_cafe
set		reportdata.dbo.flash_sales_report_cafe.LY_SLSD_CAFE = #AFSR1_LY.LY_SLSD_CAFE
from	#AFSR1_LY
where	reportdata.dbo.flash_sales_report_cafe.Fiscal_Period_Week = #AFSR1_LY.Fiscal_Period_Week
and		reportdata.dbo.flash_sales_report_cafe.Day_Of_Week_Number = #AFSR1_LY.Day_Of_Week_Number
and		reportdata.dbo.flash_sales_report_cafe.Store_Number = #AFSR1_LY.Store_Number
--------------------------cafe cumulative TY-------------------------------------------------

--select * from #ATY1
--select * from reportdata.dbo.flash_sales_report_cafe

select	day_date,
		store_number,
		TY_SLSD_CAFE,
		LY_SLSD_CAFE
into	#AFSR1_Upd
from	reportdata.dbo.flash_sales_report_cafe
order by day_date,store_number
--
select @Old_Store = 0
--
declare cur cursor for select day_date,fiscal_period_week,day_of_week_number,store_number,TY_SLSD_CAFE,LY_SLSD_CAFE
                       from reportdata.dbo.flash_sales_report_cafe
                       order by Store_number,day_date
open cur
fetch next from cur into @day_date,@Week,@Day_Week,@Store_Number,@TY_SLSD_CAFE,@LY_SLSD_CAFE
--
while @@Fetch_Status = 0
begin
	if @Old_Store <> @Store_Number
	begin
		if @Week = 1 and @Day_Week = 1
		begin
			select	@TY_Cumm_CAFE = @TY_SLSD_CAFE
			select	@LY_Cumm_CAFE = @LY_SLSD_CAFE
--
			update	reportdata.dbo.flash_sales_report_cafe
			set		TY_Cumm_CAFE = @TY_Cumm_CAFE,
					LY_Cumm_CAFE = @LY_Cumm_CAFE
			where	Day_Date = @Day_Date
			and		Store_Number = @Store_Number
		End
		Else
		Begin
			update	reportdata.dbo.flash_sales_report_cafe
			set		TY_Cumm_CAFE = @TY_Cumm_CAFE,
					LY_Cumm_CAFE = @LY_Cumm_CAFE
			where	Day_Date = @Day_Date
			and		Store_Number = @Store_Number
--
			select @TY_Cumm_CAFE = 0
			select @LY_Cumm_CAFE = 0
		End
		select @Old_Store = @Store_Number
	End
	Else
	Begin
--
		select	@TY_Cumm_CAFE = @TY_Cumm_CAFE + @TY_SLSD_CAFE
		select	@LY_Cumm_CAFE = @LY_Cumm_CAFE + @LY_SLSD_CAFE
--
		update	reportdata.dbo.flash_sales_report_cafe
		set		TY_Cumm_CAFE = @TY_Cumm_CAFE,
				LY_Cumm_CAFE = @LY_Cumm_CAFE
		where	Day_Date = @Day_Date
		and		Store_Number = @Store_Number
	End
--
	fetch next from cur into @day_date,@Week,@Day_Week,@Store_Number,@TY_SLSD_CAFE,@LY_SLSD_CAFE
End
--
close cur
deallocate cur

-------------------------------MTD CAFET---------------------------------------------------
select Store_Number,sum(TY_SLSD_CAFE) as TY_MTD_CAFE
into #ATY_MTD1
from reportdata.dbo.flash_sales_report_cafe
group by store_number
--
update reportdata.dbo.flash_sales_report_cafe
set reportdata.dbo.flash_sales_report_cafe.TY_MTD_CAFE = #ATY_MTD1.TY_MTD_CAFE
from #ATY_MTD1
where reportdata.dbo.flash_sales_report_cafe.Store_number = #ATY_MTD1.Store_Number
--
select Store_Number,sum(LY_SLSD_CAFE) as LY_MTD_CAFE
into #ALY_MTD1
from reportdata.dbo.flash_sales_report_cafe
where TY_SLSD_CAFE > 0
group by store_number
--
update reportdata.dbo.flash_sales_report_cafe
set reportdata.dbo.flash_sales_report_cafe.LY_MTD_CAFE = #ALY_MTD1.LY_MTD_CAFE
from #ALY_MTD1
where reportdata.dbo.flash_sales_report_cafe.Store_number = #ALY_MTD1.Store_Number












GO
