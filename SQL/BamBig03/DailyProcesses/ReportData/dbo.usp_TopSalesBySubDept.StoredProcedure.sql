USE [ReportData]
GO
/****** Object:  StoredProcedure [dbo].[usp_TopSalesBySubDept]    Script Date: 8/19/2022 3:44:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE Procedure [dbo].[usp_TopSalesBySubDept]
  @Department varchar(6) = NULL,
  @SD varchar(25) =  NULL,
  @ED varchar(25) = NULL
AS

--declare @department varchar(6)
--declare @SD varchar(25)
--declare @ED varchar(25)
--
--set @department = '01'
--set @SD = '08-19-2006'
--set @ED = '08-19-2006'
--
-------------------------------------------------------------------------------
-- Top 10 sales by SubDepartment by date Range
--------------------------------------------------------------------------------
declare @TD varchar(25)
declare @buyer varchar(3)
--
CREATE TABLE #rpt_Top_Sales1 (
	[department_Number] int NULL ,
	[SubDep_Number] int NULL ,
	[Sku_Number] int NULL ,
	[Sr_Buyer] varchar(30) NULL,
	[Buyer] varchar(30) NULL,
	[Current_Dollars] money NULL ,
	[Current_Units] decimal(18, 0) NULL 
) 
--
CREATE TABLE #rpt_Top_Sales2 (
	Sr_Buyer varchar(30) NULL,
	Buyer varchar(30) NULL,
	Item_Name varchar(75) NULL ,
	Department varchar(5) NULL,
	Department_Name varchar(50) NULL,
	SubDepartment varchar(5) NULL,
	SubDepartment_Name varchar(50) NULL,
	Author varchar(50) NULL,
	ISBN varchar(30) NULL,
	SKU_Number varchar(20) NULL,
	Current_Week_Dollars money NULL,
	Current_Units int NULL
) 
--
CREATE 
INDEX [idx_rptsales1] ON #rpt_Top_Sales1 ([department_Number], [SubDep_Number], [sku_number])
--
CREATE 
INDEX [idx_rptsales2] ON #rpt_Top_Sales2 ([department], [SubDepartment], [Item_Name])
--
-- Check to see if the user supplied start and end dates. If not, get them for last period
declare @fiscalPeriod int,
	@fiscalyear int,
	@StartDate SmallDateTime,
	@EndDate SmallDateTime
--
if @SD is null
begin
  	select @fiscalPeriod = fiscal_period,@fiscalyear = fiscal_year 
         	from reference.dbo.Calendar_Dim
         	where day_date = dbo.fn_DateOnly(GetDate())
  	if @fiscalperiod = 1
  	begin
    		select @fiscalPeriod = 12
    		select @FiscalYear = @FiscalYear - 1
  	End
  	else
    		select @FiscalPeriod = @FiscalPeriod - 1
	select @StartDate = day_date 
         	from reference.dbo.Calendar_Dim
         	where day_of_period = 1 
         	and fiscal_period = @fiscalperiod and fiscal_year = @fiscalyear

  	select @EndDate = max(day_date) 
         	from reference.dbo.Calendar_Dim
         	where fiscal_period = @fiscalperiod and fiscal_year = @fiscalyear

end
else
begin
              if convert(smalldatetime,@SD)  > convert(smalldatetime, @ED)					-- If user specified start date after end date, swap the dates.
              begin
                select @TD = @SD
	  select @SD = @ED
	  select @ED = @TD
              end
	select @StartDate = @SD
  	select @EndDate = @ED
end
--
-- End of user supplied variables
--
declare	@Deptname varchar(50),
	@Dept_Record_Number int,
 	@SubDept decimal(3,0),
 	@SubDepartment_Name varchar(50),
	@Department_Name varchar(50),
 	@BuyerName varchar(50),
	@SubDeptRecNo int,
	@strsql nvarchar(4000),
	@loopcnt int
--
---- Get the Department_Record_Number for the Department Entered
--
select @dept_Record_Number = Department_Record_Number,@Department_Name = department_Name 
                             from reference.dbo.Department_Dim 
                             where Department = staging.dbo.fn_NoLeadZero(@Department)
--
insert into #rpt_Top_Sales1 
select  t2.dept, 
		t2.Sdept, 
		t1.sku_number, 
		t2.Sr_Buyer,
		t2.Buyer,
		sum(t1.current_Dollars) as Current_Week_Dollars, 
		sum(t1.Current_Units) as Current_Units 
from  	dssdata.dbo.weekly_sales t1, 
		dssdata.dbo.CARD t2 
where	t2.sku_number = t1.sku_number 
		and t2.Dept = cast(@Department as int) 
		and day_date >= @SD and day_date <= @ED
group by t2.Dept, t2.sdept, t1.sku_number, t2.sr_buyer, t2.buyer
--
-- Create Cursor to loop through the distinct sub_department rows in the temp table
--
declare  SubDept_Cursor cursor for 
select distinct (SubDep_Number) from #rpt_Top_Sales1

open SubDept_Cursor

fetch next from subdept_cursor
into @SubDeptRecNo
-- Start loop
select @loopcnt = 0
  while @@fetch_status = 0
  begin
-- Get SubDepartment Record Number and Name
  select @SubDept = SubDepartment, @SubDepartment_Name = SubDepartment_Name 
                    from reference.dbo.SubDepartment_Dim 
                    where subdepartment = @SubDeptRecNo 
					and department_record_number = @dept_record_number
-- Select final rows from temp table combined with Item_Dim
    insert into #rpt_Top_Sales2
    select top 10 
	  t1.sr_buyer,
	  t1.buyer,	
      t2.Title,
      t2.Dept,
      @Department_Name as Department_Name,
      t2.sdept,
      @SubDepartment_Name as SubDepartment_Name,
      t2.author,
      t2.ISBN,
      t2.SKU_Number,
      t1.Current_Dollars,
      t1.Current_Units
    from #rpt_Top_Sales1 t1,
  	 reference.dbo.Item_Master t2
    where t2.Dept = cast(@Department as int)
    And t2.sdept = @SubDept
    And   t2.sku_number = t1.sku_number 
    order by t2.Dept,t2.SDept,t1.Current_Dollars desc
--
-- Grab Next Row
--
fetch next from subdept_cursor
into @SubDeptRecNo
--
end
--
close subdept_cursor
deallocate subdept_cursor
--
select * from #rpt_Top_Sales2
order by SubDepartment, Current_Week_Dollars desc









GO
