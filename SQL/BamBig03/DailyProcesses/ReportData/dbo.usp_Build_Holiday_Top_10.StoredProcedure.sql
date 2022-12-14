USE [ReportData]
GO
/****** Object:  StoredProcedure [dbo].[usp_Build_Holiday_Top_10]    Script Date: 8/19/2022 3:44:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[usp_Build_Holiday_Top_10]
as
--
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
declare @Year_Build float
declare @Week_Build float
declare @sd smalldatetime
declare @ed smalldatetime
declare @type varchar(10)
declare @CWeek int
declare @build float
declare @BookMult float
declare @NonBookMult float
declare @Mult float
--
declare @sql nvarchar(1500)
--
select @year = datepart(yy,getdate())
select @sd = min(day_date) from reference.dbo.calendar_Dim where calendar_year = @year
select @ed = Max(day_date) from reference.dbo.calendar_Dim where calendar_year = @year
select @ed = staging.dbo.fn_Last_Saturday(@ed)
select @year = @year - 1
select @week = fiscal_year_week from reference.dbo.calendar_dim where day_date = staging.dbo.fn_Last_Saturday(Getdate())
select @CWeek = Calendar_Week from reference.dbo.calendar_dim where day_date = staging.dbo.fn_Last_Saturday(getdate())
--
--select @BookMult = Mult from reference.dbo.Holiday_Top_10_Config where Week = @Week and Type = 'Book'
--select @NonBookMult = Mult from reference.dbo.Holiday_Top_10_Config where Week = @Week and Type = 'NonBook'
--
Truncate table ReportData.dbo.rpt_Holiday_Top_10_Report
Truncate table Staging.dbo.tmp_Holiday_Top10
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
--
--if @Dept = '1' or @Dept = '2' or @Dept = '4' or @Dept = '5' or @Dept = '8' or @Dept = '(1,4)'
--	set @mult = @BookMult
--else 
--	set @mult = @NonBookMult
--
set @sql = 'insert into Reportdata.dbo.rpt_Holiday_Top_10_Report '
set @sql = @sql + 'select top ' + cast(@numrows as char(2)) + ' '
set @sql = @sql + cast(@ReportOrder as char(3)) + ' as PrintOrder,'
set @sql = @sql + '''' + @Section + '''' + ' as Section,'
set @sql = @sql + ' row_Number() over (order by t1.Week1dollars desc) as Rank, '
set @sql = @sql + ' t1.ISBN as TY_ISBN, '
set @sql = @sql + ' t1.title as TY_Title, '
set @sql = @sql + ' t1.Author as TY_Author, '
set @sql = @sql + ' t1.Class_Name as TY_Class, '
set @sql = @sql + ' t1.Week1Dollars as TY_SLS$, '
set @sql = @sql + ' t1.Week1Units as TY_SLSU, '
set @sql = @sql + ' NULL as YTD_SLSU, '
set @sql = @sql + ' t1.BAM_OnHand, '
set @sql = @sql + ' t1.InTransit, '
set @sql = @sql + ' t1.Store_Min, '
set @sql = @sql + ' t1.Warehouse_OnHand, '
set @sql = @sql + ' t1.Qty_OnOrder, '
--set @sql = @sql + ' (t1.Week1Units * ' + cast(@Mult as varchar(5)) + ') as Year_Proj, '
--set @sql = @sql + ' ((t1.Week1Units * ' + cast(@Mult as varchar(5)) + ')+t1.Store_Min) - (t1.BAM_OnHand + t1.InTransit+t1.Warehouse_OnHand+t1.Qty_OnOrder) as NNTC, '
set @sql = @sql + ' 0 as Year_Proj, '
set @sql = @sql + ' 0 as NNTC, '
set @sql = @sql + ' NULL as LY_ISBN, '
set @sql = @sql + ' NULL as LY_Title, '
set @sql = @sql + ' NULL as LY_Author, '
set @sql = @sql + ' NULL as LY_Class, '
set @sql = @sql + ' NULL as LY_SLS$, '
set @sql = @sql + ' NULL as LY_SLSU '
set @sql = @sql + ' from	dssdata.dbo.CARD t1,Dssdata.dbo.weekly_sales t2 '
set @sql = @sql + ' where	t1.dept ' + @Dept_Op + ' ' + @Dept 
set @sql = @sql + ' and		t1.SDept ' + @SDept_Op + ' ' + @SDept
set @sql = @sql + ' and		t1.Class ' + @Class_Op + ' ' + @Class
set @Sql = @sql + ' and t2.sku_number = t1.sku_number '
set @Sql = @sql + ' and t2.day_date >= ' + '''' + cast(@sd as varchar(12)) + '''' + ' and t2.day_date <= ' + '''' + cast(@ed as varchar(12)) + ''''
if @Over_POS > 0
set @sql = @sql + ' and		t1.Retail > ' + cast(@Over_POS as char(3)) + ' '
--
set @sql = @sql + ' Group By t1.ISBN,t1.Title,t1.Author,t1.Class_Name,t1.Week1Dollars,t1.Week1Units, '
set @sql = @sql + ' t1.BAM_OnHand,t1.InTransit,t1.Store_Min,t1.Warehouse_OnHand,t1.Qty_OnOrder'
--
set @sql = @sql + ' order by Week1Dollars desc '
--
EXEC sp_executesql @sql
--
set @sql = 'insert into staging.dbo.tmp_Holiday_Top10 '
set @sql = @sql + 'select top ' + cast(@numrows as char(3)) + ' '
set @sql = @sql + 'row_Number() over (order by t1.LYWeek1dollars desc) as LYRank, '
set @sql = @sql + 't1.ISBN as ISBN, '
set @sql = @sql + 't1.Title as Title, '
set @sql = @sql + 't1.Author, '
set @sql = @sql + 't1.Class_Name, '
set @sql = @sql + 't1.LYWeek1Dollars as Sls$, '
set @sql = @sql + 't1.LYWeek1Units as SlsU '
set @sql = @sql + 'from	dssdata.dbo.CARD t1 '
set @sql = @sql + ' where	t1.dept ' + @Dept_Op + ' ' + @Dept 
set @sql = @sql + ' and		t1.SDept ' + @SDept_Op + ' ' + @SDept
set @sql = @sql + ' and		t1.Class ' + @Class_Op + ' ' + @Class
if @Over_POS > 0
set @sql = @sql + ' and		t1.retail > ' + cast(@Over_POS as char(3)) + ' '
set @sql = @sql + ' order by LYWeek1Dollars desc '
--
EXEC sp_executesql @sql
--
set @sql = 'update Reportdata.dbo.rpt_Holiday_Top_10_Report '
set @sql = @sql + 'set	LY_ISBN = ISBN, '
set @sql = @sql + 'LY_Title = Title, '
set @sql = @sql + 'LY_Author = Author, '
set @sql = @sql + 'LY_Class = Class, '
set @sql = @sql + 'LY_SLS$ = SLS$, '
set @sql = @sql + 'LY_SLSU = SLSU '
set @sql = @sql + 'from	Staging.dbo.tmp_Holiday_Top10 '
set @sql = @sql + 'where Staging.dbo.tmp_Holiday_top10.LYRank = Rank '
set @sql = @sql + 'and Section = ' + '''' + @Section + ''''
--
EXEC sp_executesql @sql
--
truncate table staging.dbo.tmp_Holiday_Top10

fetch next from cur into @ReportOrder, @numrows, @Section, @Dept_Op, @Dept, @SDept_Op, @SDept, @Class_Op, @Class, @Over_POS
end 

close cur
deallocate cur







GO
