USE [ReportData]
GO
/****** Object:  StoredProcedure [dbo].[usp_Build_DotCom_Top_Selling_Report]    Script Date: 8/19/2022 3:44:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[usp_Build_DotCom_Top_Selling_Report]
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
declare @LS smalldatetime
--
declare @sql nvarchar(1000)
--
select @year = datepart(yy,getdate())
select @year = @year - 1
select @week = staging.dbo.fn_Calendar_Week(getdate())
select @LS = staging.dbo.fn_Last_Saturday(getdate())
--
Truncate table ReportData.dbo.rpt_DotCom_Top_Selling_Report
Truncate table Staging.dbo.tmp_Top10
--
declare cur cursor for select ReportOrder, numrows, Section, Dept_Op, Dept, SDept_Op, SDept, Class_Op, Class, Over_POS
from Reference.dbo.DotCom_Top_Selling_Config
order by ReportOrder
--
open cur
fetch next from cur into @ReportOrder, @numrows, @Section, @Dept_Op, @Dept, @SDept_Op, @SDept, @Class_Op, @Class, @Over_POS
--
while @@Fetch_Status = 0
begin
--select @Perc_To_Total = Perc_To_Total from reference.dbo.Top_10_Sales_Curves
--                        where Year = @year and week = @week and ReportOrder = @ReportOrder
--select @Perc_Remaining = Perc_Remaining from reference.dbo.Top_10_Sales_Curves
--                        where Year = @year and week = @week and ReportOrder = @ReportOrder
--
set @sql = 'insert into Reportdata.dbo.rpt_DotCom_Top_Selling_Report '
set @sql = @sql + 'select top ' + cast(@numrows as char(2)) + ' '
set @sql = @sql + cast(@ReportOrder as char(3)) + ' as PrintOrder,'
set @sql = @sql + '''' + @Section + '''' + ' as Section,'
set @sql = @sql + ' row_Number() over (order by t1.DCWeek1dollars desc) as Rank, '
set @sql = @sql + ' t1.ISBN as TY_ISBN, '
set @sql = @sql + ' t1.title as TY_Title, '
set @sql = @sql + ' t1.Author as TY_Author, '
set @sql = @sql + ' t1.Dept as TY_Dept_Num, '
set @sql = @sql + ' t1.SDept as TY_SDept_Num, '
set @sql = @sql + ' t1.Class as TY_Class_Num, '
set @sql = @sql + ' t1.Store_Min as TY_Display_Min, '
set @sql = @sql + ' t1.Class_Name as TY_Class, '
set @sql = @sql + ' t1.DCWeek1Dollars as TY_SLS$, '
set @sql = @sql + ' t1.DCWeek1Units as TY_SLSU, '
set @sql = @sql + ' 0 as Discount, '
set @sql = @sql + ' t1.Warehouse_OnHand as OnHand, '
set @sql = @sql + ' isnull(t1.Qty_OnOrder,0) as OnOrder, '
set @sql = @sql + ' 0 as Proj, '
--set @sql = @sql + ' (t1.Week1Units/' + cast(@Perc_To_Total as varchar(10)) + ')*' + cast(@Perc_Remaining as varchar(10)) + ' as Proj, '
set @sql = @sql + ' NULL as NNTC, '
set @sql = @sql + ' NULL as LY_ISBN, '
set @sql = @sql + ' NULL as LY_Title, '
set @sql = @sql + ' NULL as LY_Author, '
set @sql = @sql + ' NULL as LY_Dept_Num, '
set @sql = @sql + ' NULL as LY_SDept_Num, '
set @sql = @sql + ' NULL as LY_Class_Num, '
set @sql = @sql + ' NULL as LY_Display_Min, '
set @sql = @sql + ' NULL as LY_Class, '
set @sql = @sql + ' NULL as LY_SLS$, '
set @sql = @sql + ' NULL as LY_SLSU '
set @sql = @sql + ' from	dssdata.dbo.CARD t1 '
set @sql = @sql + ' where  	t1.dept ' + @Dept_Op + ' ' + @Dept 
set @sql = @sql + ' and		t1.SDept ' + @SDept_Op + ' ' + @SDept
set @sql = @sql + ' and		t1.Class ' + @Class_Op + ' ' + @Class
if @Over_POS > 0
set @sql = @sql + ' and		t1.Retail > ' + cast(@Over_POS as char(3)) + ' '
set @sql = @sql + ' order by DCWeek1Dollars desc '
--
EXEC sp_executesql @sql
--
--
set @sql = 'insert into staging.dbo.tmp_Top10 '
set @sql = @sql + 'select top ' + cast(@numrows as char(3)) + ' '
set @sql = @sql + 'row_Number() over (order by t1.LYDCWeek1dollars desc) as LYRank, '
set @sql = @sql + 't1.ISBN as ISBN, '
set @sql = @sql + 't1.Title as Title, '
set @sql = @sql + 't1.Author, '
set @sql = @sql + 't1.Dept, '
set @sql = @sql + 't1.SDept, '
set @sql = @sql + 't1.Class, '
set @sql = @sql + 't1.BAM_OnHand, '
set @sql = @sql + 't1.Class_Name, '
set @sql = @sql + 't1.LYDCWeek1Dollars as Sls$, '
set @sql = @sql + 't1.LYDCWeek1Units as SlsU '
set @sql = @sql + 'from	dssdata.dbo.CARD t1 '
set @sql = @sql + ' where	t1.dept ' + @Dept_Op + ' ' + @Dept 
set @sql = @sql + ' and		t1.SDept ' + @SDept_Op + ' ' + @SDept
set @sql = @sql + ' and		t1.Class ' + @Class_Op + ' ' + @Class
if @Over_POS > 0
set @sql = @sql + ' and		t1.retail > ' + cast(@Over_POS as char(3)) + ' '
set @sql = @sql + ' order by LYDCWeek1Dollars desc '
--
EXEC sp_executesql @sql
--
set @sql = 'update ReportData.dbo.rpt_DotCom_Top_Selling_Report '
set @sql = @sql + 'set	LY_Title = Title, '
set @sql = @sql + 'LY_ISBN = ISBN, '
set @sql = @sql + 'NNTC = (Proj + (TY_SLSU * 3)) - (Staging.dbo.tmp_Top10.onHand + OnOrder), '
set @sql = @sql + 'LY_Author = Author, '
set @sql = @sql + 'LY_Dept_Num = Dept_Num, '
set @sql = @sql + 'LY_SDept_Num = SDept_Num, '
set @sql = @sql + 'LY_Class_Num = Class_Num, '
set @sql = @sql + 'LY_OnHand = Staging.dbo.tmp_Top10.OnHand, '
set @sql = @sql + 'LY_Class = Class, '
set @sql = @sql + 'LY_SLS$ = SLS$, '
set @sql = @sql + 'LY_SLSU = SLSU '
set @sql = @sql + 'from	Staging.dbo.tmp_Top10 '
set @sql = @sql + 'where Staging.dbo.tmp_top10.LYRank = Rank '
set @sql = @sql + 'and Section = ' + '''' + @Section + ''''
--
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
--
update	ReportData.dbo.rpt_DotCom_Top_Selling_Report
set		Discount = 0
--
update	ReportData.dbo.rpt_DotCom_Top_Selling_Report
set		Discount = reportdata.dbo.Discounts.Discount
from	reportdata.dbo.discounts
where	reportdata.dbo.Discounts.ISBN = ReportData.dbo.rpt_Dotcom_Top_Selling_Report.TY_ISBN
GO
