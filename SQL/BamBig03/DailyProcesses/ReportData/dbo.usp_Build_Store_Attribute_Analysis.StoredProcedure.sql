USE [ReportData]
GO
/****** Object:  StoredProcedure [dbo].[usp_Build_Store_Attribute_Analysis]    Script Date: 8/19/2022 3:44:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[usp_Build_Store_Attribute_Analysis]
as
--
-- Date Calc Variables
--
declare @TY_Start smalldatetime
declare @LY_Start smalldatetime
declare @CP int
declare @FY int
declare @FW int
--
-- Cursor Variables
--
declare @Fiscal_Period int
declare @Store_Number int
declare @TY money
declare @LY money
declare @TYYTD money
declare @LYYTD money
--
-- Sql Variable
--
declare @sql varchar(500)
--
select @FW = fiscal_Year_Week from reference.dbo.calendar_dim where day_date = staging.dbo.fn_DateOnly(getdate())
select @CP = fiscal_period from reference.dbo.calendar_dim where day_date = staging.dbo.fn_DateOnly(getdate())
select @FY = Fiscal_Year from reference.dbo.calendar_dim where day_date = staging.dbo.fn_DateOnly(getdate())
select @TY_Start = min(day_date) from reference.dbo.calendar_dim where fiscal_year = @fy
select @LY_Start = min(day_date) from reference.dbo.calendar_dim where fiscal_year = @fy - 1
--
-- Populate Output Table
--
truncate table reportdata.dbo.Store_Attribute_Sales
insert into reportdata.dbo.Store_Attribute_Sales
select	@FW,t1.Store_Number,t1.Store_Name,t2.State,t2.Open_DTE,t2.Mall_Stripe,t2.Sq_Ft_Grade,t2.Volume_Grade,t2.seasonal,t2.market,
		t2.demographic,@CP,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		from	Reference.dbo.Comp_Stores t1,
		Reference.dbo.Store_Demographics t2
where	t2.Store_Number = t1.Store_Number
--
select	t1.Fiscal_Period,
		t2.Store_Number,
		sum(t2.Current_Dollars) as TY_SLSD
into	#TY_Sales
from	reference.dbo.calendar_dim t1,
		dssdata.dbo.weekly_sales t2
where	t2.day_date >= @TY_Start
and		t1.day_date = t2.day_date
and		t2.Store_Number > 55
group by t1.fiscal_period,t2.store_number
order by t2.Store_number,t1.Fiscal_Period
--
select	t1.Fiscal_Period,
		t2.Store_Number,
		sum(t2.Current_Dollars) as LY_SLSD
into	#LY_Sales
from	reference.dbo.calendar_dim t1,
		dssdata.dbo.weekly_sales t2
where	t2.day_date >= @LY_Start
and		t2.day_date < dateadd(yy,-1,getdate())
and		t1.day_date = t2.day_date
and		t2.Store_Number > 55
group by t1.fiscal_period,t2.store_number
order by t2.Store_number,t1.Fiscal_Period
--
select	t2.Store_Number,
		sum(t2.Current_Dollars) as TY_YTD
into	#TY_YTD
from	reference.dbo.calendar_dim t1,
		dssdata.dbo.weekly_sales t2
where	t2.day_date >= @TY_Start
and		t1.day_date = t2.day_date
and		t2.Store_Number > 55
group by t2.store_number
order by t2.Store_number
--
select	t2.Store_Number,
		sum(t2.Current_Dollars) as LY_YTD
into	#LY_YTD
from	reference.dbo.calendar_dim t1,
		dssdata.dbo.weekly_sales t2
where	t2.day_date >= @LY_Start
and		t2.day_date <= staging.dbo.fn_DateOnly(dateadd(yy,-1,getdate()))
and		t1.day_date = t2.day_date
and		t2.Store_Number > 55
group by t2.store_number
order by t2.Store_number
--
-- Loop through Sales and update output table
--
declare cur cursor for 
select	t1.Fiscal_Period,
		t1.Store_Number,
		t1.TY_SLSD,
		t2.LY_SLSD,
		t3.TY_YTD,
		t4.LY_YTD
from	#TY_Sales t1,
		#LY_Sales t2,
		#TY_YTD t3,
		#LY_YTD t4
where	t2.Fiscal_Period = t1.Fiscal_Period
and		t2.Store_Number = t1.Store_Number
and		t3.store_number = t1.store_number
and		t4.store_number = t1.store_number

Open Cur
--
fetch next from cur into @Fiscal_Period,@Store_Number,@TY,@LY,@TYYTD,@LYYTD
--
while @@Fetch_Status = 0
begin
--
	select @Sql = 'Update reportdata.dbo.Store_Attribute_Sales set TY_P' + ltrim(str(@Fiscal_Period)) + ' = ' + str(@TY) + ' ,LY_P' + ltrim(str(@Fiscal_Period)) + ' = ' + str(@LY) + ' where Store_Number = ' + Str(@Store_Number)
--	select @Sql	
exec (@Sql)
	Update reportdata.dbo.Store_Attribute_Sales set TY_YTD = @TYYTD,LY_YTD = @LYYTD where store_number = @Store_Number 
    Update reportdata.dbo.Store_Attribute_Sales set Perc_YTD = isnull((@TYYTD - @LYYTD) / nullif(@LYYTD,0),0) where store_number = @Store_Number and @LYYTD <> 0 
--
fetch next from cur into @Fiscal_Period,@Store_Number,@TY,@LY,@TYYTD,@LYYTD
-- sp_find 'Store_Attribute_Sales'
end
--
close cur
deallocate cur
--
-- Update Percs
--
update reportdata.dbo.Store_Attribute_Sales
set		Perc_P1 = Staging.dbo.fn_Safe_Divide((TY_P1 - LY_P1),LY_P1),
		Perc_P2 = Staging.dbo.fn_Safe_Divide((TY_P2 - LY_P2),LY_P2),
		Perc_P3 = Staging.dbo.fn_Safe_Divide((TY_P3 - LY_P3),LY_P3),
		Perc_P4 = Staging.dbo.fn_Safe_Divide((TY_P4 - LY_P4),LY_P4),
		Perc_P5 = Staging.dbo.fn_Safe_Divide((TY_P5 - LY_P5),LY_P5),
		Perc_P6 = Staging.dbo.fn_Safe_Divide((TY_P6 - LY_P6),LY_P6),
		Perc_P7 = Staging.dbo.fn_Safe_Divide((TY_P7 - LY_P7),LY_P7),
		Perc_P8 = Staging.dbo.fn_Safe_Divide((TY_P8 - LY_P8),LY_P8),
		Perc_P9 = Staging.dbo.fn_Safe_Divide((TY_P9 - LY_P9),LY_P9),
		Perc_P10 = Staging.dbo.fn_Safe_Divide((TY_P10 - LY_P10),LY_P10),
		Perc_P11 = Staging.dbo.fn_Safe_Divide((TY_P11 - LY_P11),LY_P11),
		Perc_P12 = Staging.dbo.fn_Safe_Divide((TY_P12 - LY_P12),LY_P12)
--
-- Clean up temp tables select * from store_attribute_sales
--
drop table #TY_Sales
drop table #LY_Sales
drop table #TY_YTD
drop table #LY_YTD
--
-- End Of Proc
--



GO
