USE [ReportData]
GO
/****** Object:  StoredProcedure [dbo].[usp_Build_Top_10_Qtr_Report]    Script Date: 8/19/2022 3:44:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[usp_Build_Top_10_Qtr_Report]
as

declare @ReportOrder int
declare @numrows int
declare @Section varchar(30)
declare @Dept_Op varchar(5)
declare @Dept varchar(30)
declare @SDept_Op varchar(5)
declare @SDept varchar(30)
declare @Class_Op varchar(5)
declare @Class varchar(30)
declare @Over_POS Int
declare @year int
declare @week int
declare @Perc_To_Total float
declare @Perc_Remaining float
declare @sd varchar(10)
declare @ed varchar(10)
declare @lysd varchar(10)
declare @lyed varchar(10)
--
set @sd = '10-29-2006'
set @ed = '12-30-2006'
set @lysd = '10-30-2005'
set @lyed = '12-31-2005'
--
declare @sql nvarchar(1000)
--
select @year = datepart(yy,getdate())
select @year = @year - 1
select @week = staging.dbo.fn_Calendar_Week(getdate())
--
Truncate table ReportData.dbo.rpt_Top_10_Qtr_Report
Truncate table Staging.dbo.tmp_Top10
--
declare cur cursor for select ReportOrder, numrows, Section, Dept_Op, Dept, SDept_Op, SDept, Class_Op, Class, Over_POS
from reportdata.dbo.Top_10_Report_Config
order by ReportOrder
--
open cur
fetch next from cur into @ReportOrder, @numrows, @Section, @Dept_Op, @Dept, @SDept_Op, @SDept, @Class_Op, @Class, @Over_POS
--
while @@Fetch_Status = 0
begin
select @Perc_To_Total = Perc_To_Total from reference.dbo.Top_10_Sales_Curves
                        where Year = @year and week = @week and ReportOrder = @ReportOrder
select @Perc_Remaining = Perc_Remaining from reference.dbo.Top_10_Sales_Curves
                        where Year = @year and week = @week and ReportOrder = @ReportOrder
--
set @sql = 'insert into Reportdata.dbo.rpt_Top_10_Qtr_Report '
set @sql = @sql + 'select top ' + cast(@numrows as char(2)) + ' '
set @sql = @sql + '''' + @sd + '''' + ' as Start_Date, '
set @sql = @sql + '''' + @ed + '''' + ' as End_Date, '
set @sql = @sql + cast(@ReportOrder as char(3)) + ' as PrintOrder,'
set @sql = @sql + '''' + @Section + '''' + ' as Section,'
set @sql = @sql + ' row_Number() over (order by sum(t2.current_dollars) desc) as Rank, '
set @sql = @sql + ' t1.title as TY_Title, '
set @sql = @sql + ' t1.Author as TY_Author, '
set @sql = @sql + ' t1.Class_Name as TY_Class, '
set @sql = @sql + ' sum(t2.current_dollars) as TY_SLS$, '
set @sql = @sql + ' sum(t2.current_units) as TY_SLSU, '
set @sql = @sql + ' t1.Total_OnHand as OnHand, '
set @sql = @sql + ' isnull(t1.Qty_OnOrder,0) as OnOrder, '
set @sql = @sql + ' NULL as Proj, '
set @sql = @sql + ' NULL as NNTC, '
set @sql = @sql + ' NULL as LY_Title, '
set @sql = @sql + ' NULL as LY_Author, '
set @sql = @sql + ' NULL as LY_Class, '
set @sql = @sql + ' NULL as LY_SLS$, '
set @sql = @sql + ' NULL as LY_SLSU '
set @sql = @sql + ' from	dssdata.dbo.CARD t1, dssdata.dbo.weekly_sales t2 '
set @sql = @sql + ' where	t1.dept ' + @Dept_Op + ' ' + @Dept 
set @sql = @sql + ' and		t1.SDept ' + @SDept_Op + ' ' + @SDept
set @sql = @sql + ' and		t1.Class ' + @Class_Op + ' ' + @Class
if @Over_POS > 0
set @sql = @sql + ' and		t1.Retail > ' + cast(@Over_POS as char(3)) + ' '
set @sql = @sql + ' and     t2.sku_number = t1.sku_number '
set @sql = @sql + ' and     t2.day_date >= ' + '''' + @sd + '''' + ' and t2.day_date <= ' + '''' + @ed + ''''
set @sql = @sql + ' Group by t1.title,t1.author,t1.class_name,t1.total_Onhand,t1.Qty_OnOrder '
set @sql = @sql + ' order by sum(t2.current_dollars) desc '
--
EXEC sp_executesql @sql
--
--
set @sql = 'insert into staging.dbo.tmp_Top10 '
set @sql = @sql + 'select top ' + cast(@numrows as char(3)) + ' '
set @sql = @sql + 'row_Number() over (order by sum(t2.current_dollars) desc) as LYRank, '
set @sql = @sql + 't1.Title as Title, '
set @sql = @sql + 't1.Author, '
set @sql = @sql + 't1.Class_Name, '
set @sql = @sql + 'sum(t2.current_dollars) as Sls$, '
set @sql = @sql + 'sum(t2.current_units) as SlsU '
set @sql = @sql + 'from	dssdata.dbo.CARD t1, dssdata.dbo.weekly_sales t2 '
set @sql = @sql + ' where	t1.dept ' + @Dept_Op + ' ' + @Dept 
set @sql = @sql + ' and		t1.SDept ' + @SDept_Op + ' ' + @SDept
set @sql = @sql + ' and		t1.Class ' + @Class_Op + ' ' + @Class
if @Over_POS > 0
set @sql = @sql + ' and		t1.retail > ' + cast(@Over_POS as char(3)) + ' '
set @sql = @sql + ' and     t2.sku_number = t1.sku_number '
set @sql = @sql + ' and     t2.day_date >= ' + '''' + @lysd + '''' + ' and t2.day_date <= ' + '''' + @lyed + ''''
set @sql = @sql + ' Group by t1.title,t1.author,t1.class_name '
set @sql = @sql + ' order by sum(t2.current_dollars) desc '
--
EXEC sp_executesql @sql
--
set @sql = 'update ReportData.dbo.rpt_Top_10_Qtr_Report '
set @sql = @sql + 'set	LY_Title = Title, '
set @sql = @sql + 'LY_Author = Author, '
set @sql = @sql + 'LY_Class = Class, '
set @sql = @sql + 'LY_SLS$ = SLS$, '
set @sql = @sql + 'LY_SLSU = SLSU '
set @sql = @sql + 'from	Staging.dbo.tmp_Top10 '
set @sql = @sql + 'where Staging.dbo.tmp_top10.LYRank = Rank '
set @sql = @sql + 'and Section = ' + '''' + @Section + ''''
--
EXEC sp_executesql @sql
--
truncate table staging.dbo.tmp_Top10
--
fetch next from cur into @ReportOrder, @numrows, @Section, @Dept_Op, @Dept, @SDept_Op, @SDept, @Class_Op, @Class, @Over_POS
end 
--
close cur
deallocate cur









GO
