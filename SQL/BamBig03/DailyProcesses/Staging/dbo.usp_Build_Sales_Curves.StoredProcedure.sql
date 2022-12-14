USE [Staging]
GO
/****** Object:  StoredProcedure [dbo].[usp_Build_Sales_Curves]    Script Date: 8/19/2022 3:41:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Create procedure [dbo].[usp_Build_Sales_Curves]
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
--
declare @sql nvarchar(1000)
declare @Params nvarchar(1000)
--
set @runPerc = 0
--
Truncate table Reference.dbo.Sales_Curves		-- Clear out results table
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
declare cur cursor for select distinct Dept,SubDept
from reference.dbo.category_master
order by Dept,SubDept
--
-- get first row
--
open cur
fetch next from cur into @Dept, @SDept
--
-- setup loop to go through entire table
--
while @@Fetch_Status = 0
begin
--
-- First, get the total year sales for row
--
set @sql = 'select @InProc_YTD_Total = sum(t1.current_dollars) '
set @sql = @sql + 'from	dssdata.dbo.weekly_sales t1, '
set @sql = @sql + 'reference.dbo.item_master t2 '
set @sql = @sql + ' where	t2.dept = @oDept '
set @sql = @sql + ' and		t2.SDept = @oSDept '
set @sql = @sql + ' and		t1.sku_number = t2.sku_number ' 
set @sql = @sql + ' and		t1.day_date >= @osd and t1.day_date <= @oed '
set @Params = N'@oDept int,@oSDept int,@osd smalldatetime,@oed smalldatetime,@InProc_YTD_Total money OUTPUT'
--
-- execute the statement
--
EXEC sp_executesql @sql,@Params,@oDept=@Dept,@oSDept=@SDept,@osd=@sd,@oed=@ed,@InProc_YTD_Total=@YTD_Total OUTPUT
--
if @YTD_Total IS NOT NULL
begin
--
-- Now, get the totals for each week
--
set @sql = 'insert into reference.dbo.Sales_Curves '
set @sql = @sql + 'select t3.calendar_year, '
set @sql = @sql + 't3.calendar_week, '
set @sql = @sql + '@oDept, '
set @sql = @sql + '@oSDept, '
set @sql = @sql + 'sum(t1.current_dollars)/' + str(@YTD_Total) + ' as Perc_To_Total, '
set @sql = @sql + 'NULL as Perc_Remaining '
set @sql = @sql + 'from	dssdata.dbo.weekly_sales t1, '
set @sql = @sql + 'reference.dbo.item_master t2, '
set @sql = @sql + 'reference.dbo.calendar_dim t3 '
set @sql = @sql + ' where	t2.dept = @oDept '
set @sql = @sql + ' and		t2.SDept = @oSDept '
set @sql = @sql + ' and		t1.sku_number = t2.sku_number ' 
set @sql = @sql + ' and		t1.day_date >= @osd and t1.day_date <= @oed '
set @sql = @sql + ' and		t3.day_date = t1.day_date '
set @sql = @sql + ' group by t3.calendar_year,t3.calendar_week'
set @Params = N'@oDept int,@oSDept int,@osd smalldatetime,@oed smalldatetime'
--
EXEC sp_executesql @sql,@Params,@oDept=@Dept,@oSDept=@SDept,@osd=@sd,@oed=@ed
End
--
fetch next from cur into @Dept,@SDept
-- 
-- End of Insert
--
END
Close cur
deallocate cur
----
---- Update Perc Remaining
----
select @upd_perc = 0
--
declare cur1 cursor for select year,week,Dept,SDept,perc_to_total from 
reference.dbo.Sales_Curves order by year,week,Dept,SDept
open cur1
fetch next from cur1 into @year,@week,@Dept,@SDept,@Perc_To_Total
--
while @@Fetch_Status = 0
begin
if @year <> @oyear or @Dept <> @oDept or @SDept <> @oSDept
  set @runPerc = 0
--
set @runPerc = @runPerc + @Perc_To_Total
set @upd_perc = 1.0 - @runPerc
--
update reference.dbo.Sales_Curves
set Perc_Remaining = @upd_Perc
where year = @year and week = @week 
and Dept = @Dept and SDept = @SDept
--
set @oyear = @year
set @oweek = @week
set @oDept = @Dept
set @oSDept = @SDept
--
fetch next from cur1 into @year,@week,@Dept,@SDept,@Perc_To_Total
--
-- End Of Update
--
end
--
close cur1
deallocate cur1



GO
