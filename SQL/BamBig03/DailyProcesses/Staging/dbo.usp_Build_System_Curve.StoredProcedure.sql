USE [Staging]
GO
/****** Object:  StoredProcedure [dbo].[usp_Build_System_Curve]    Script Date: 8/19/2022 3:41:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[usp_Build_System_Curve]
as
--
declare @YTD_Total money
declare @tmp_year int
declare @Year int
declare @Week int
declare @Perc_To_Total float
declare @runPerc float
declare @sd varchar(12)
declare @ed varchar(12)
declare @upd_Perc float
--
declare @sql nvarchar(1000)
declare @Params nvarchar(1000)
--
set @runPerc = 0
--
truncate table Reference.dbo.Sales_Curves
--
select @Year = datepart(yy,getdate())
select @Year = @Year - 1
--
-- Get start and end dates for selects
--
select @sd = min(day_date) from reference.dbo.calendar_dim where Calendar_Year = @Year
select @ed = max(day_date) from reference.dbo.calendar_dim where Calendar_Year = @Year
--
-- First, get the total year sales for row
--
select @YTD_Total = sum(current_dollars)
					from dssdata.dbo.weekly_sales
					where day_date >= @sd and day_date <= @ed
if @YTD_Total IS NOT NULL
begin
--
-- Now, Insert the totals for each week
--
insert into reference.dbo.Sales_Curves
select  t3.calendar_year,
		t3.calendar_week,
		0 as Dept,
		0 as sdept,
		sum(t1.current_dollars)/@YTD_Total as Perc_To_Total,
		NULL as Perc_Remaining
from	dssdata.dbo.weekly_sales t1,
		reference.dbo.calendar_dim t3
where	t1.day_date >= @sd
and		t1.day_date <= @ed
and		t3.day_date = t1.day_date
group by t3.calendar_year,t3.calendar_week
 
-- End of Insert

END
--
-- Update Perc Remaining
--
select @upd_perc = 0
--
declare cur1 cursor for select year,week,perc_to_total from 
reference.dbo.Sales_Curves where dept = 0 order by year,week
open cur1
fetch next from cur1 into @year,@week,@Perc_To_Total
--
set @runPerc = 0
--
while @@Fetch_Status = 0
begin
--
set @runPerc = @runPerc + @Perc_To_Total
set @upd_perc = 1.0 - @runPerc
--
update reference.dbo.Sales_Curves
set Perc_Remaining = @upd_Perc
where year = @year and week = @week 
and Dept = 0
--
fetch next from cur1 into @year,@week,@Perc_To_Total
--
-- End Of Update
--
end
--
close cur1
deallocate cur1



GO
