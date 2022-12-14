USE [ReportData]
GO
/****** Object:  StoredProcedure [dbo].[usp_Build_Top_10_Store]    Script Date: 8/19/2022 3:44:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[usp_Build_Top_10_Store]
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
declare @Store int
declare @Region int
declare @District int
declare @Perc_To_Total float
declare @Perc_Remaining float
declare @strTYSatDate varchar(12)
declare @strLYSatDate varchar(12)
--
declare @sql nvarchar(1000)
--
select @year = datepart(yy,getdate())
select @year = @year - 1
select @week = staging.dbo.fn_Calendar_Week(getdate())
select @strTYSatDate = staging.dbo.fn_Last_Saturday(Getdate())
select @strLYSatDate = staging.dbo.fn_Last_Saturday(DateAdd(yy,-1,Getdate()))
--
Truncate table ReportData.dbo.rpt_Top_10_Store
Truncate table Staging.dbo.tmp_Top10_Store
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
declare curstore cursor for select Region_Number, District_Number, Store_Number from reference.dbo.active_stores
open curstore
--
fetch next from curstore into @Region, @District, @Store
while @@Fetch_Status = 0
begin
--
set @sql = 'insert into Reportdata.dbo.rpt_Top_10_Store '
set @sql = @sql + 'select top ' + cast(@numrows as char(2)) + ' '
set @sql = @sql + cast(@ReportOrder as char(3)) + ' as PrintOrder,'
set @sql = @sql + '''' + @Section + '''' + ' as Section,'
set @sql = @sql + ltrim(str(@Region)) + ' as Region_Number,'
set @sql = @sql + ltrim(str(@District)) + ' as District_Number,'
set @sql = @sql + ltrim(str(@Store)) + ' as Store_Number,'
set @sql = @sql + ' row_Number() over (order by t2.Current_Dollars desc) as Rank, '
set @sql = @sql + ' t1.ISBN as TY_ISBN, '
set @sql = @sql + ' t1.title as TY_Title, '
set @sql = @sql + ' t1.Author as TY_Author, '
set @sql = @sql + ' t1.Dept_Name as TY_Dept, '
set @sql = @sql + ' t1.SDept_Name as TY_SDept, '
set @sql = @sql + ' t1.Class_Name as TY_Class, '
set @sql = @sql + ' t2.Current_Dollars as TY_SLS$, '
set @sql = @sql + ' t2.Current_Units as TY_SLSU, '
set @sql = @sql + ' t1.Total_OnHand as OnHand, '
set @sql = @sql + ' isnull(t1.Qty_OnOrder,0) as OnOrder, '
set @sql = @sql + ' NULL as LY_ISBN, '
set @sql = @sql + ' NULL as LY_Title, '
set @sql = @sql + ' NULL as LY_Author, '
set @sql = @sql + ' NULL as LY_Dept, '
set @sql = @sql + ' NULL as LY_SDept, '
set @sql = @sql + ' NULL as LY_Class, '
set @sql = @sql + ' NULL as LY_SLS$, '
set @sql = @sql + ' NULL as LY_SLSU '
set @sql = @sql + ' from	dssdata.dbo.CARD t1, dssdata.dbo.weekly_sales t2 '
set @sql = @sql + ' where	t1.dept ' + @Dept_Op + ' ' + @Dept 
set @sql = @sql + ' and		t1.SDept ' + @SDept_Op + ' ' + @SDept
set @sql = @sql + ' and		t1.Class ' + @Class_Op + ' ' + @Class
set @sql = @sql + ' and     t2.sku_number = t1.sku_number '
set @sql = @sql + ' and		t2.day_date = ' + '''' + @strTYSatDate + ''''
set @sql = @sql + ' and		t2.Store_Number = ' + ltrim(str(@Store))

if @Over_POS > 0
set @sql = @sql + ' and		t1.Retail > ' + cast(@Over_POS as char(3)) + ' '
set @sql = @sql + ' order by t2.Current_Dollars desc '
--
EXEC sp_executesql @sql
--
set @sql = 'insert into staging.dbo.tmp_Top10_Store '
set @sql = @sql + 'select top ' + cast(@numrows as char(3)) + ' '
set @sql = @sql + ltrim(str(@Store)) + ' as LYStore, '
set @sql = @sql + 'row_Number() over (order by t2.Current_Dollars desc) as LYRank, '
set @sql = @sql + 't1.ISBN as ISBN, '
set @sql = @sql + 't1.Title as Title, '
set @sql = @sql + 't1.Author, '
set @sql = @sql + 't1.Dept_Name, '
set @sql = @sql + 't1.SDept_Name, '
set @sql = @sql + 't1.Class_Name, '
set @sql = @sql + 't2.Current_Dollars as Sls$, '
set @sql = @sql + 't2.current_Units as SlsU '
set @sql = @sql + 'from	dssdata.dbo.CARD t1, dssdata.dbo.weekly_sales t2 '
set @sql = @sql + ' where	t1.dept ' + @Dept_Op + ' ' + @Dept 
set @sql = @sql + ' and		t1.SDept ' + @SDept_Op + ' ' + @SDept
set @sql = @sql + ' and		t1.Class ' + @Class_Op + ' ' + @Class
set @sql = @sql + ' and     t2.sku_number = t1.sku_number '
set @sql = @sql + ' and     t2.store_number = ' + ltrim(str(@Store))
set @sql = @sql + ' and     t2.day_date = ' + '''' + @strLYSatDate + ''''
if @Over_POS > 0
set @sql = @sql + ' and		t1.retail > ' + cast(@Over_POS as char(3)) + ' '
set @sql = @sql + ' order by t2.Current_Dollars desc'
--
EXEC sp_executesql @sql
--
set @sql = 'update ReportData.dbo.rpt_Top_10_Store '
set @sql = @sql + 'set	ReportData.dbo.rpt_Top_10_Store.LY_Title = Title, '
set @sql = @sql + 'ReportData.dbo.rpt_Top_10_Store.LY_ISBN = ISBN, '
set @sql = @sql + 'ReportData.dbo.rpt_Top_10_Store.LY_Author = Author, '
set @sql = @sql + 'ReportData.dbo.rpt_Top_10_Store.LY_Dept = Dept, '
set @sql = @sql + 'ReportData.dbo.rpt_Top_10_Store.LY_SDept = SDept, '
set @sql = @sql + 'ReportData.dbo.rpt_Top_10_Store.LY_Class = Class, '
set @sql = @sql + 'ReportData.dbo.rpt_Top_10_Store.LY_SLS$ = SLS$, '
set @sql = @sql + 'ReportData.dbo.rpt_Top_10_Store.LY_SLSU = SLSU '
set @sql = @sql + 'from	Staging.dbo.tmp_Top10_Store '
set @sql = @sql + 'where Staging.dbo.tmp_Top10_Store.LYRank = Rank '
set @sql = @sql + 'and Staging.dbo.tmp_Top10_Store.LYStore = Store_Number '
set @sql = @sql + 'and Section = ' + '''' + @Section + ''''
--
EXEC sp_executesql @sql
--
truncate table staging.dbo.tmp_Top10_Store
--
fetch next from curstore into @Region, @District, @Store
end
close curstore
deallocate curstore
--
fetch next from cur into @ReportOrder, @numrows, @Section, @Dept_Op, @Dept, @SDept_Op, @SDept, @Class_Op, @Class, @Over_POS
end 
--
close cur
deallocate cur

GO
