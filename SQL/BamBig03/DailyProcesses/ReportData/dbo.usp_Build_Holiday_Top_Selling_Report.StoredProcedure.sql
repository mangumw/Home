USE [ReportData]
GO
/****** Object:  StoredProcedure [dbo].[usp_Build_Holiday_Top_Selling_Report]    Script Date: 8/19/2022 3:44:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[usp_Build_Holiday_Top_Selling_Report]
as
----
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
Truncate table ReportData.dbo.rpt_Holiday_Top_Selling_Report
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
--select @Perc_To_Total = Perc_To_Total from reference.dbo.Top_10_Sales_Curves
--                        where Year = @year and week = @week and ReportOrder = @ReportOrder
--select @Perc_Remaining = Perc_Remaining from reference.dbo.Top_10_Sales_Curves
--                        where Year = @year and week = @week and ReportOrder = @ReportOrder
--
select @sql = 'insert into Reportdata.dbo.rpt_Holiday_Top_Selling_Report '
select @sql = @sql + 'select top ' + cast(@numrows as char(2)) + ' '
select @sql = @sql + cast(@ReportOrder as char(3)) + ' as PrintOrder,'
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
select @sql = @sql + ' NULL as LY_SLSU, '
select @sql = @sql + ' NULL as Forecast_Thru, '
select @sql = @sql + ' 0 as Week_42, '
select @sql = @sql + ' 0 as Week_43, '
select @sql = @sql + ' 0 as Week_44, '
select @sql = @sql + ' 0 as Week_45, '
select @sql = @sql + ' 0 as Week_46, '
select @sql = @sql + ' 0 as Week_47, '
select @sql = @sql + ' 0 as Week_48, '
select @sql = @sql + ' 0 as Week_49 '
select @sql = @sql + ' from	dssdata.dbo.CARD t1'
select @sql = @sql + ' where t1.dept ' + @Dept_Op + ' ' + @Dept 
select @sql = @sql + ' and t1.SDept ' + @SDept_Op + ' ' + @SDept
select @sql = @sql + ' and t1.Class ' + @Class_Op + ' ' + @Class
if @Over_POS > 0
select @sql = @sql + ' and t1.Retail > ' + cast(@Over_POS as char(3)) + ' '
select @sql = @sql + ' order by Week1Dollars desc '
--
EXEC sp_executesql @sql
--
select @sql = 'insert into staging.dbo.tmp_Top10 '
select @sql = @sql + 'select top ' + cast(@numrows as char(3)) + ' '
select @sql = @sql + 'row_Number() over (order by t1.LYWeek1dollars desc) as LYRank, '
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
select @sql = 'update ReportData.dbo.rpt_Holiday_Top_Selling_Report '
select @sql = @sql + 'Set	LY_Title = Title, '
select @sql = @sql + 'LY_ISBN = ISBN, '
select @sql = @sql + 'NNTC = (Proj + (TY_SLSU * 3)) - (ReportData.dbo.rpt_Holiday_Top_Selling_Report.onHand + OnOrder), '
select @sql = @sql + 'LY_Author = Author, '
select @sql = @sql + 'LY_Dept_Num = Dept_Num, '
select @sql = @sql + 'LY_SDept_Num = SDept_Num, '
select @sql = @sql + 'LY_Class_Num = Class_Num, '
select @sql = @sql + 'LY_OnHand = Staging.dbo.tmp_Top10.OnHand, '
select @sql = @sql + 'LY_Class = Class, '
select @sql = @sql + 'LY_SLS$ = SLS$, '
select @sql = @sql + 'LY_SLSU = SLSU '
select @sql = @sql + 'from	Staging.dbo.tmp_Top10 '
select @sql = @sql + 'where Staging.dbo.tmp_top10.LYRank = Rank '
select @sql = @sql + 'and Section = ' + '''' + @Section + ''''
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
update	ReportData.dbo.rpt_Holiday_Top_Selling_Report
Set		Discount = 0
--
update	ReportData.dbo.rpt_Holiday_Top_Selling_Report
Set		Discount = reportdata.dbo.Discounts.Discount
from	reportdata.dbo.discounts
where	reportdata.dbo.Discounts.ISBN = ReportData.dbo.rpt_Holiday_Top_Selling_Report.TY_ISBN
----- new code to calculate the forecast for the week forward
declare @numweeks int

select @numweeks = (select week_multiplier from dbo.Holiday_Top_Sales_By_Category_Spread
where from_date = CONVERT(DateTime, CONVERT(Char, GETDATE(), 103), 103) and dept = 4)

select @numweeks

if @numweeks = 44
begin
update dbo.rpt_Holiday_Top_Selling_Report
   set Week_44 = TY_SLSU * (select multiplier from dbo.Holiday_Top_Sales_By_Category_Spread
 where rpt_Holiday_Top_Selling_Report.TY_Dept_Num = dbo.Holiday_Top_Sales_By_Category_Spread.dept 
   and dbo.Holiday_Top_Sales_By_Category_Spread.week_multiplier = 44)

update dbo.rpt_Holiday_Top_Selling_Report
   set Week_45 = Week_44 * (select multiplier from dbo.Holiday_Top_Sales_By_Category_Spread
 where rpt_Holiday_Top_Selling_Report.TY_Dept_Num = dbo.Holiday_Top_Sales_By_Category_Spread.dept 
   and dbo.Holiday_Top_Sales_By_Category_Spread.week_multiplier = 45)

update dbo.rpt_Holiday_Top_Selling_Report
   set Week_46 = Week_45 * (select multiplier from dbo.Holiday_Top_Sales_By_Category_Spread
 where rpt_Holiday_Top_Selling_Report.TY_Dept_Num = dbo.Holiday_Top_Sales_By_Category_Spread.dept 
   and dbo.Holiday_Top_Sales_By_Category_Spread.week_multiplier = 46)

update dbo.rpt_Holiday_Top_Selling_Report
   set Week_47 = Week_46 * (select multiplier from dbo.Holiday_Top_Sales_By_Category_Spread
 where rpt_Holiday_Top_Selling_Report.TY_Dept_Num = dbo.Holiday_Top_Sales_By_Category_Spread.dept 
   and dbo.Holiday_Top_Sales_By_Category_Spread.week_multiplier = 47)

update dbo.rpt_Holiday_Top_Selling_Report
   set Week_48 = Week_47 * (select multiplier from dbo.Holiday_Top_Sales_By_Category_Spread
 where rpt_Holiday_Top_Selling_Report.TY_Dept_Num = dbo.Holiday_Top_Sales_By_Category_Spread.dept 
   and dbo.Holiday_Top_Sales_By_Category_Spread.week_multiplier = 48)

   update dbo.rpt_Holiday_Top_Selling_Report
      set Forecast_Thru = (Week_44 + Week_45 + Week_46 + Week_47 + Week_48)
end


else if @numweeks = 45
begin

update dbo.rpt_Holiday_Top_Selling_Report
   set Week_45 = TY_SLSU * (select multiplier from dbo.Holiday_Top_Sales_By_Category_Spread
 where rpt_Holiday_Top_Selling_Report.TY_Dept_Num = dbo.Holiday_Top_Sales_By_Category_Spread.dept 
   and dbo.Holiday_Top_Sales_By_Category_Spread.week_multiplier = 45)

update dbo.rpt_Holiday_Top_Selling_Report
   set Week_46 = Week_45 * (select multiplier from dbo.Holiday_Top_Sales_By_Category_Spread
 where rpt_Holiday_Top_Selling_Report.TY_Dept_Num = dbo.Holiday_Top_Sales_By_Category_Spread.dept 
   and dbo.Holiday_Top_Sales_By_Category_Spread.week_multiplier = 46)

update dbo.rpt_Holiday_Top_Selling_Report
   set Week_47 = Week_46 * (select multiplier from dbo.Holiday_Top_Sales_By_Category_Spread
 where rpt_Holiday_Top_Selling_Report.TY_Dept_Num = dbo.Holiday_Top_Sales_By_Category_Spread.dept 
   and dbo.Holiday_Top_Sales_By_Category_Spread.week_multiplier = 47)

update dbo.rpt_Holiday_Top_Selling_Report
   set Week_48 = Week_47 * (select multiplier from dbo.Holiday_Top_Sales_By_Category_Spread
 where rpt_Holiday_Top_Selling_Report.TY_Dept_Num = dbo.Holiday_Top_Sales_By_Category_Spread.dept 
   and dbo.Holiday_Top_Sales_By_Category_Spread.week_multiplier = 48)

 update dbo.rpt_Holiday_Top_Selling_Report
      set Forecast_Thru = Week_45 + Week_46 + Week_47 + Week_48
end

else if @numweeks = 46
begin

update dbo.rpt_Holiday_Top_Selling_Report
   set Week_46 = TY_SLSU * (select multiplier from dbo.Holiday_Top_Sales_By_Category_Spread
 where rpt_Holiday_Top_Selling_Report.TY_Dept_Num = dbo.Holiday_Top_Sales_By_Category_Spread.dept 
   and dbo.Holiday_Top_Sales_By_Category_Spread.week_multiplier = 46)

update dbo.rpt_Holiday_Top_Selling_Report
   set Week_47 = Week_46 * (select multiplier from dbo.Holiday_Top_Sales_By_Category_Spread
 where rpt_Holiday_Top_Selling_Report.TY_Dept_Num = dbo.Holiday_Top_Sales_By_Category_Spread.dept 
   and dbo.Holiday_Top_Sales_By_Category_Spread.week_multiplier = 47)

update dbo.rpt_Holiday_Top_Selling_Report
   set Week_48 = Week_47 * (select multiplier from dbo.Holiday_Top_Sales_By_Category_Spread
 where rpt_Holiday_Top_Selling_Report.TY_Dept_Num = dbo.Holiday_Top_Sales_By_Category_Spread.dept 
   and dbo.Holiday_Top_Sales_By_Category_Spread.week_multiplier = 48)

 update dbo.rpt_Holiday_Top_Selling_Report
      set Forecast_Thru = Week_46 + Week_47 + Week_48
end

else if @numweeks = 47
begin

update dbo.rpt_Holiday_Top_Selling_Report
   set Week_47 = TY_SLSU * (select multiplier from dbo.Holiday_Top_Sales_By_Category_Spread
 where rpt_Holiday_Top_Selling_Report.TY_Dept_Num = dbo.Holiday_Top_Sales_By_Category_Spread.dept 
   and dbo.Holiday_Top_Sales_By_Category_Spread.week_multiplier = 47)

update dbo.rpt_Holiday_Top_Selling_Report
   set Week_48 = Week_47 * (select multiplier from dbo.Holiday_Top_Sales_By_Category_Spread
 where rpt_Holiday_Top_Selling_Report.TY_Dept_Num = dbo.Holiday_Top_Sales_By_Category_Spread.dept 
   and dbo.Holiday_Top_Sales_By_Category_Spread.week_multiplier = 48)

 update dbo.rpt_Holiday_Top_Selling_Report
      set Forecast_Thru = Week_47 + Week_48
end

else if @numweeks = 48
begin
update dbo.rpt_Holiday_Top_Selling_Report
   set Week_48 = TY_SLSU * (select multiplier from dbo.Holiday_Top_Sales_By_Category_Spread
 where rpt_Holiday_Top_Selling_Report.TY_Dept_Num = dbo.Holiday_Top_Sales_By_Category_Spread.dept 
   and dbo.Holiday_Top_Sales_By_Category_Spread.week_multiplier = 48)

 update dbo.rpt_Holiday_Top_Selling_Report
      set Forecast_Thru = Week_48
end
GO
