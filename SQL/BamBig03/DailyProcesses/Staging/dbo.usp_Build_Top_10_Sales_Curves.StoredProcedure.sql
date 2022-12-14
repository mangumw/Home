USE [Staging]
GO
/****** Object:  StoredProcedure [dbo].[usp_Build_Top_10_Sales_Curves]    Script Date: 8/19/2022 3:41:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[usp_Build_Top_10_Sales_Curves]
as
--
declare @ReportOrder int
declare @oReportOrder int
declare @numrows int
declare @Dept_Op varchar(5)
declare @Dept varchar(30)
declare @SDept_Op varchar(5)
declare @SDept varchar(30)
declare @Class_Op varchar(5)
declare @Class varchar(30)
declare @Over_POS Int
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
declare @Section varchar(30)
declare @oSection varchar(30)
declare @upd_Perc float
--
declare @sql nvarchar(1000)
declare @Params nvarchar(1000)
--
set @runPerc = 0
--
Truncate table Reference.dbo.Top_10_Sales_Curves		-- Clear out results table
--
select @Year = datepart(yy,getdate())
select @Year = @Year - 1
--
-- Get start and end dates for selects
--
select @sd = min(day_date) from reference.dbo.calendar_dim where Calendar_Year = @Year
select @ed = max(day_date) from reference.dbo.calendar_dim where Calendar_Year = @Year
--
-- Setup cursor to grab contents of report config table
--
declare cur cursor for select ReportOrder, numrows, Section, Dept_Op, Dept, SDept_Op, SDept, Class_Op, Class, Over_POS
from reportdata.dbo.Top_10_Report_Config
order by ReportOrder
--
-- get first row
--
open cur
fetch next from cur into @ReportOrder, @numrows, @Section, @Dept_Op, @Dept, @SDept_Op, @SDept, @Class_Op, @Class, @Over_POS
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
set @sql = @sql + ' where	t2.dept ' + @Dept_Op + ' ' + @Dept 
set @sql = @sql + ' and		t2.SDept ' + @SDept_Op + ' ' + @SDept
set @sql = @sql + ' and		t2.Class ' + @Class_Op + ' ' + @Class
if @Over_POS > 0
set @sql = @sql + ' and		t2.POS_Price > ' + cast(@Over_POS as char(3)) + ' '
set @sql = @sql + ' and		t1.sku_number = t2.sku_number ' 
set @sql = @sql + ' and		t1.day_date >= ' + '''' + @sd + '''' + ' and t1.day_date <= ' + '''' + @ed + ''''
set @Params = N'@InProc_YTD_Total money OUTPUT'
--
-- execute the statement
--
EXEC sp_executesql @sql,@Params,@InProc_YTD_Total=@YTD_Total OUTPUT
--
set @sql = 'insert into reference.dbo.Top_10_Sales_Curves '
set @sql = @sql + 'select t3.calendar_year, '
set @sql = @sql + 't3.calendar_week, '
set @sql = @sql + str(@ReportOrder)  + ' as Reportorder, '
set @sql = @sql + '''' + @section + '''' + ' as Section, ' 
set @sql = @sql + 'sum(t1.current_dollars)/' + str(@YTD_Total) + ' as Perc_To_Total, '
set @sql = @sql + 'NULL as Perc_Remaining '
set @sql = @sql + 'from	dssdata.dbo.weekly_sales t1, '
set @sql = @sql + 'reference.dbo.item_master t2, '
set @sql = @sql + 'reference.dbo.calendar_dim t3 '
set @sql = @sql + ' where	t2.dept ' + @Dept_Op + ' ' + @Dept 
set @sql = @sql + ' and		t2.SDept ' + @SDept_Op + ' ' + @SDept
set @sql = @sql + ' and		t2.Class ' + @Class_Op + ' ' + @Class
if @Over_POS > 0
set @sql = @sql + ' and		t2.POS_Price > ' + cast(@Over_POS as char(3)) + ' '
set @sql = @sql + ' and		t1.sku_number = t2.sku_number ' 
set @sql = @sql + ' and		t1.day_date >= ' + '''' + @sd + '''' + ' and t1.day_date <= ' + '''' + @ed + ''''
set @sql = @sql + ' and		t3.day_date = t1.day_date '
set @sql = @sql + ' group by t3.calendar_year,t3.calendar_week'
--
EXEC sp_executesql @sql
--
fetch next from cur into @ReportOrder, @numrows, @Section, @Dept_Op, @Dept, @SDept_Op, @SDept, @Class_Op, @Class, @Over_POS
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
declare cur1 cursor for select year,week,Reportorder,perc_to_total from 
reference.dbo.Top_10_Sales_Curves order by ReportOrder,year,week
open cur1
fetch next from cur1 into @year,@week,@ReportOrder,@Perc_To_Total
--
while @@Fetch_Status = 0
begin
if @year <> @oyear or @ReportOrder <> @oReportOrder
  set @runPerc = 0
--
set @runPerc = @runPerc + @Perc_To_Total
set @upd_perc = 1.0 - @runPerc
--
update reference.dbo.Top_10_Sales_Curves
set Perc_Remaining = @upd_Perc
where year = @year and week = @week 
and ReportOrder = @ReportOrder
--
set @oyear = @year
set @oweek = @week
set @oReportOrder = @Reportorder
--
fetch next from cur1 into @year,@week,@ReportOrder,@Perc_To_Total
--
-- End Of Update
--
end
--
close cur1
deallocate cur1


GO
