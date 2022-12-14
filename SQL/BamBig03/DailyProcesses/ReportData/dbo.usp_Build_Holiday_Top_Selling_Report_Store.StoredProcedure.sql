USE [ReportData]
GO
/****** Object:  StoredProcedure [dbo].[usp_Build_Holiday_Top_Selling_Report_Store]    Script Date: 8/19/2022 3:44:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[usp_Build_Holiday_Top_Selling_Report_Store]
as
----
declare @ReportOrder int
declare @Region_Number int
declare @District_Number int
declare @numrows int
declare @Section varchar(30)
declare @store_number int
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
declare @LS smalldatetime
declare @LYCard smalldatetime
--
declare @sql nvarchar(4000)
--
select @year = datepart(yy,getdate())
select @year = @year - 1
select @week = staging.dbo.fn_Calendar_Week(getdate())
select @LS = staging.dbo.fn_Last_Saturday(getdate())
select @lycard = dateadd(yy,-1,@LS)
--
Truncate table ReportData.dbo.rpt_Holiday_Top_Selling_Report_Store
Truncate table Staging.dbo.tmp_Top10
--
declare cur cursor for select ReportOrder, numrows, Section, Dept_Op, Dept, SDept_Op, SDept, Class_Op, Class, Over_POS
from Reference.dbo.Holiday_Top_Selling_Config
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
fetch next from curstore into @Region_Number, @District_Number, @Store_Number
while @@Fetch_Status = 0
begin
--
select @sql = 'insert into Reportdata.dbo.rpt_Holiday_Top_Selling_Report_Store '
select @sql = @sql + 'select top ' + cast(@numrows as char(2)) + ' '
select @sql = @sql + cast(@ReportOrder as char(3)) + ' as PrintOrder,'
select @sql = @sql + cast(@region_number as char(3)) + 'as Region_Number,'
select @sql = @sql + cast(@district_number as char(3)) + 'as District_Number,'
select @sql = @sql + cast(@store_number as char(3)) + 'as store_number,'
select @sql = @sql + '''' + @Section + '''' + ' as Section,'
select @sql = @sql + ' row_Number() over (order by t1.Week1dollars desc) as Rank, '
select @sql = @sql + ' t1.ISBN as TY_ISBN, '
select @sql = @sql + ' t1.title as TY_Title, '
select @sql = @sql + ' t1.Author as TY_Author, '
select @sql = @sql + ' t1.Dept as TY_Dept_Num, '
select @sql = @sql + ' t1.SDept as TY_SDept_Num, '
select @sql = @sql + ' t1.Class as TY_Class_Num, '
select @sql = @sql + ' t1.Store_Min as TY_Display_Min, '
select @sql = @sql + ' t1.Class_Name as TY_Class, '
select @sql = @sql + ' t1.Week1Dollars as TY_SLS$, '
select @sql = @sql + ' t1.Week1Units as TY_SLSU, '
select @sql = @sql + ' 0 as Discount, '
select @sql = @sql + ' t1.Total_OnHand as OnHand, '
select @sql = @sql + ' isnull(t1.Qty_OnOrder,0) as OnOrder, '
select @sql = @sql + ' 0 as Proj, '
--select @sql = @sql + ' (t1.Week1Units/' + cast(@Perc_To_Total as varchar(10)) + ')*' + cast(@Perc_Remaining as varchar(10)) + ' as Proj, '
select @sql = @sql + ' NULL as NNTC, '
select @sql = @sql + ' NULL as LY_ISBN, '
select @sql = @sql + ' NULL as LY_Title, '
select @sql = @sql + ' NULL as LY_Author, '
select @sql = @sql + ' NULL as LY_Dept_Num, '
select @sql = @sql + ' NULL as LY_SDept_Num, '
select @sql = @sql + ' NULL as LY_Class_Num, '
select @sql = @sql + ' NULL as LY_On_Hand, '
select @sql = @sql + ' NULL as LY_Class, '
select @sql = @sql + ' NULL as LY_SLS$, '
select @sql = @sql + ' NULL as LY_SLSU '
select @sql = @sql + ' from	dssdata.dbo.CARD t1'
select @sql = @sql + ' where  	t1.dept ' + @Dept_Op + ' ' + @Dept 
select @sql = @sql + ' and		t1.SDept ' + @SDept_Op + ' ' + @SDept
select @sql = @sql + ' and		t1.Class ' + @Class_Op + ' ' + @Class
if @Over_POS > 0
select @sql = @sql + ' and		t1.Retail > ' + cast(@Over_POS as char(3)) + ' '
select @sql = @sql + ' order by Week1Dollars desc '
--
select @sql
EXEC sp_executesql @sql
--
select @sql = 'insert into staging.dbo.tmp_Holiday_Top10_Store '
select @sql = @sql + 'select top ' + cast(@numrows as char(3)) + ' '
select @sql = @sql + 'row_Number() over (order by t1.LYWeek1dollars desc) as LYRank, '
select @sql = @sql + '''' + @region_number + '''' + 'as Region_Number,'
select @sql = @sql + '''' + @district_number + '''' + 'as District_Number,'
select @sql = @sql + '''' + @store_number + '''' + 'as store_number,'
select @sql = @sql + 't1.ISBN as ISBN, '
select @sql = @sql + 't1.Title as Title, '
select @sql = @sql + 't1.Author, '
select @sql = @sql + 't1.Dept, '
select @sql = @sql + 't1.SDept, '
select @sql = @sql + 't1.Class, '
select @sql = @sql + 't1.BAM_OnHand, '
select @sql = @sql + 't1.Class_Name, '
select @sql = @sql + 't1.LYWeek1Dollars as Sls$, '
select @sql = @sql + 't1.LYWeek1Units as SlsU '
select @sql = @sql + 'from	dssdata.dbo.CARD t1 '
select @sql = @sql + ' where	t1.dept ' + @Dept_Op + ' ' + @Dept 
select @sql = @sql + ' and		t1.SDept ' + @SDept_Op + ' ' + @SDept
select @sql = @sql + ' and		t1.Class ' + @Class_Op + ' ' + @Class
if @Over_POS > 0
select @sql = @sql + ' and		t1.retail > ' + cast(@Over_POS as char(3)) + ' '
select @sql = @sql + ' order by LYWeek1Dollars desc '
--
EXEC sp_executesql @sql
--
select @sql = 'update ReportData.dbo.rpt_Holiday_Top_Selling_Report_Store '
select @sql = @sql + 'Set	LY_Title = Title, '
select @sql = @sql + 'LY_ISBN = ISBN, '
select @sql = @sql + 'NNTC = (Proj + (TY_SLSU * 3)) - (ReportData.dbo.rpt_Holiday_Top_Selling_Report_Store.onHand + OnOrder), '
select @sql = @sql + 'LY_Author = Author, '
select @sql = @sql + 'LY_Dept_Num = Dept_Num, '
select @sql = @sql + 'LY_SDept_Num = SDept_Num, '
select @sql = @sql + 'LY_Class_Num = Class_Num, '
select @sql = @sql + 'LY_OnHand = Staging.dbo.tmp_Holiday_Top10_Store.OnHand, '
select @sql = @sql + 'LY_Class = Class, '
select @sql = @sql + 'LY_SLS$ = SLS$, '
select @sql = @sql + 'LY_SLSU = SLSU '
select @sql = @sql + 'from	Staging.dbo.tmp_Holiday_Top10_Store '
select @sql = @sql + 'where Staging.dbo.tmp_Holiday_top10_Store.LYRank = Rank '
select @sql = @sql + 'and Section = ' + '''' + @Section + ''''
select @sql = @sql + 'and Store_Number = ' + @store_Number
--
--
EXEC sp_executesql @sql
--
truncate table staging.dbo.tmp_Top10
--
fetch next from curstore into @Region_Number, @District_Number, @Store_Number
end
close curstore
deallocate curstore
--
fetch next from cur into @ReportOrder, @numrows, @Section, @Dept_Op, @Dept, @SDept_Op, @SDept, @Class_Op, @Class, @Over_POS
end 
--
close cur
deallocate cur
--
update	ReportData.dbo.rpt_Holiday_Top_Selling_Report
Set		Discount = 0
--
update	ReportData.dbo.rpt_Holiday_Top_Selling_Report
Set		Discount = reportdata.dbo.Discounts.Discount
from	reportdata.dbo.discounts
where	reportdata.dbo.Discounts.ISBN = ReportData.dbo.rpt_Holiday_Top_Selling_Report.TY_ISBN








GO
