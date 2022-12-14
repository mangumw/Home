USE [Staging]
GO
/****** Object:  StoredProcedure [dbo].[usp_Build_Dept_Sales_Curves]    Script Date: 8/19/2022 3:41:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[usp_Build_Dept_Sales_Curves]
as
--
declare @Dept int 
declare @SDept int
declare @YTD_Total money
declare @tmp_year int
declare @Year int
declare @Week int
declare @Perc_To_Total float
declare @runPerc float
declare @sd varchar(12)
declare @ed varchar(12)
declare @oyear int
declare @oweek int
declare @oDept int 
declare @oSDept int
declare @upd_Perc float
declare @Year_Total money
declare @Prev_Week_Total money
declare @Week_Total money
--
declare @sql nvarchar(1000)
declare @Params nvarchar(1000)
--
set @runPerc = 0
--
Truncate table Reference.dbo.Dept_Sales_Curves		-- Clear out results table
--
select @Year = datepart(yy,getdate())
select @Year = @Year - 1
--
-- Get start and end dates for selects
--
select @sd = min(day_date) from reference.dbo.calendar_dim where Calendar_Year = @Year
select @ed = max(day_date) from reference.dbo.calendar_dim where Calendar_Year = @Year
--
-- Setup cursor to grab contents of Category_Master
--
declare cur cursor for select distinct Dept
from reference.dbo.category_master
order by Dept
--
-- get first row
--
open cur
fetch next from cur into @Dept
--
-- setup loop to go through entire table
--
while @@Fetch_Status = 0
begin
--
-- First, get the total year sales for row
--
select	@Year_Total = sum(t1.current_dollars) 
from	dssdata.dbo.weekly_sales t1, 
		reference.dbo.item_master t2 
where	t2.dept = @Dept
and		t1.sku_number = t2.sku_number 
and		t1.day_date >= @sd and t1.day_date <= @ed 
--
--if @Year_Total IS NOT NULL
--begin
--
-- Now, get the totals for each week
--
insert into reference.dbo.Dept_Sales_Curves 
select		t3.calendar_year, 
			t3.calendar_week, 
			t2.Dept, 
			0 as Previous_Week_Total,
			sum(t1.current_dollars) as Week_Total,
			NULL as YTD_Total,
			@Year_Total as Year_Total,
			0 as Week_Build,
			0 as Year_Build
from		dssdata.dbo.weekly_sales t1, 
			reference.dbo.item_master t2, 
			reference.dbo.calendar_dim t3 
where		t2.dept = @Dept
and			t1.sku_number = t2.sku_number 
and			t1.day_date >= @sd and t1.day_date <= @ed
and			t1.day_date = t3.day_date 
group by	t3.calendar_year,t3.calendar_week,t2.Dept
--
fetch next from cur into @Dept
End
-- 
-- End of Insert
--
Close cur
deallocate cur
----
---- Update Perc Remaining
----
select @upd_perc = 0
select @Prev_Week_Total = 0
select @YTD_Total = 0
--
declare cur1 cursor for select year,week,Dept,Week_Total from 
reference.dbo.Dept_Sales_Curves order by year,Dept,week
open cur1
fetch next from cur1 into @year,@week,@Dept,@Week_Total
--
while @@Fetch_Status = 0
begin
  if @year <> @oyear or @Dept <> @oDept 
  begin
    set @runPerc = 0
    select @YTD_Total = 0
    select @Prev_Week_Total = 0
  end
--
  select @YTD_Total = @YTD_Total + @Week_Total
--
  update reference.dbo.Dept_Sales_Curves
  set		YTD_Total = @YTD_Total,
     		Previous_Week_total = @Prev_Week_total
  where		year = @year 
  and		week = @week 
  and		Dept = @Dept 
--
  set @oyear = @year
  set @oweek = @week
  set @oDept = @Dept
  set @Prev_Week_Total = @Week_total
--
  fetch next from cur1 into @year,@week,@Dept,@Week_Total
--
-- End Of Update
--
End
--
close cur1
deallocate cur1
--
-- Update table with Week Build and Year Build
--
update	Reference.dbo.Dept_Sales_Curves
set		Week_Build = Week_Total / Previous_Week_Total,
		Year_Build = Year_Total / YTD_Total
where	Week > 1 and Previous_Week_total <> 0
--
-- Curve Building Complete
--
																																																



GO
