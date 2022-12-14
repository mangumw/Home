USE [ReportData]
GO
/****** Object:  StoredProcedure [dbo].[usp_Key_4_OOS]    Script Date: 8/19/2022 3:44:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE Procedure [dbo].[usp_Key_4_OOS]
  @SD varchar(25) =  NULL,
  @ED varchar(25) = NULL
AS
declare @TD varchar(25)
declare @Department varchar(5)
--
--if exists (select * from reportdata.dbo.sysobjects where Name = 'rpt_Top_Sales1') 
--drop table #top_sales1
--
CREATE TABLE #top_sales1 (
	[department_Number] [int] NULL ,
	[SubDep_Number] [int] NULL ,
	[department_Name] varchar(50) NULL,
	[subdept_name] varchar(50) NULL,
	[sku_number] [int] NULL ,
	[Current_Dollars] [money] NULL ,
	[Current_Units] [decimal](18, 0) NULL 
) 
--
--if exists (select * from reportdata.dbo.sysobjects where Name = 'rpt_Top_Sales2')
--drop table #top_sales2
--
CREATE TABLE #top_sales2 (
	Item_Name varchar(75) NULL ,
	Department int NULL,
	Department_Name varchar(50) NULL,
	SubDepartment int NULL,
	SubDepartment_Name varchar(50) NULL,
	Author varchar(50) NULL,
	ISBN varchar(30) NULL,
	SKU_Number varchar(20) NULL,
	Current_Week_Dollars money NULL,
	Current_Units int NULL
) 
--
CREATE 
INDEX [idx_rptsales1] ON #top_sales1 ([department_number], [SubDep_number], [sku_number])
--
CREATE 
INDEX [idx_rptsales2] ON #top_sales2 ([department], [SubDepartment], [Item_Name])
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
         	where day_date = Staging.dbo.fn_DateOnly(GetDate())
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
--
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
	@dept_number int,
 	@SubDept decimal(3,0),
 	@SubDepartment_Name varchar(50),
	@Department_Name varchar(50),
 	@BuyerName varchar(50),
	@subdeptno int,
	@strsql nvarchar(4000),
	@loopcnt int
--
-- Get the Department_Record_Number for the Department Entered
--
--select @dept_number = Department_Record_Number,@Department_Name = department_Name 
--                             from reference.dbo.Department_Dim 
--                             where Department in (1,2,4,6,8,59,69)
--select @dept_number as Dept_Rec_No
--
-- First, Get all Sales for selected department into a temp table by SubDept
--
insert into #top_sales1
select  t2.Dept,
        t2.SDept,
		t2.dept_name,
		t2.sdept_name,
		t1.sku_number,
		sum(t1.current_Dollars) as Current_Dollars,
		sum(Current_Units) as Current_Units
from  	dssdata.dbo.weekly_sales t1,
		reference.dbo.item_Master t2
where	t1.day_date >= @StartDate and t1.day_date <= @EndDate
and		t2.sku_number = t1.sku_number
and		t2.Dept In (3,5,6,10,11,12,14,58,69)
group by t2.Dept, t2.SDept, t2.dept_name,t2.sdept_name,t1.sku_number
--
-- select * from #reportdata.dbo.rpt_top_sales order by SubDep_Record_Number
---- Create Cursor to loop through the distinct sub_department rows in the temp table
--
declare  SubDept_Cursor cursor for 
select distinct (SubDep_Number),Department_Number from #top_sales1 order by department_Number,SubDep_Number
--
open SubDept_Cursor
--
fetch next from subdept_cursor
into @subdeptno,@dept_number
-- Start loop
select @loopcnt = 0
--
  while @@fetch_status = 0
  begin

-- Get SubDepartment Record Number and Name

--  select @SubDept = SubDepartment, @SubDepartment_Name = SubDepartment_Name 
--                    from reference.dbo.SubDepartment_Dim 
--                    where subdep_record_number = @subdeptno
--  select @Department = Department, @Department_Name = Department_Name 
--                    from reference.dbo.Department_Dim 
--                    where Department_record_number = @dept_number

-- Select final rows from temp table combined with Item_Dim
 
-- select @subdeptno,@dept_number
   insert into #top_sales2
    select top 10 
      t2.Title,
      t1.Department_number as Department,
      t1.Department_Name as Department_Name,
      t1.SubDep_number as SubDepartment,
      t1.SubDept_Name as SubDepartment_Name,
      t2.author,
      t2.ISBN,
      t1.SKU_Number,
      t1.Current_Dollars,
      t1.Current_Units
    from #top_sales1 t1,
  	 reference.dbo.Item_Master t2
    where t2.sku_number = t1.sku_number 
	and		t1.department_number = @dept_number
	and		t1.subdep_number = @subdeptno
    order by t1.Department_Number,t1.SubDep_Number,t1.Current_Dollars desc

-- Grab Next Row

fetch next from subdept_cursor
into @subdeptno,@dept_number

end

close subdept_cursor
deallocate subdept_cursor
--
SELECT     TOP 100 PERCENT #top_sales2.Item_Name, #top_sales2.Department,  
                      #top_sales2.SubDepartment, #top_sales2.SubDepartment_Name, #top_sales2.Author, #top_sales2.ISBN, 
                      #top_sales2.Current_Week_Dollars, #top_sales2.SKU_Number, #top_sales2.Current_Units, reference.dbo.invcbl.On_Hand AS BAMOH, 
                      reference.dbo.itbal.OnHand AS WHOH, reference.dbo.itbal.OnBackOrder AS QBO, reference.dbo.itbal.OnPO AS QOO
FROM         #top_sales2 LEFT OUTER JOIN
                      reference.dbo.itbal ON #top_sales2.ISBN = reference.dbo.itbal.ISBN LEFT OUTER JOIN
                      reference.dbo.invcbl ON #top_sales2.SKU_Number = reference.dbo.invcbl.Sku_Number
GROUP BY #top_sales2.Item_Name, #top_sales2.Department, #top_sales2.SubDepartment, 
                      #top_sales2.SubDepartment_Name, #top_sales2.Author, #top_sales2.ISBN, #top_sales2.Current_Week_Dollars, 
                      #top_sales2.SKU_Number, #top_sales2.Current_Units, reference.dbo.invcbl.On_Hand, reference.dbo.itbal.OnHand, reference.dbo.itbal.OnBackOrder, 
                      reference.dbo.itbal.OnPO
ORDER BY #top_sales2.Department, #top_sales2.SubDepartment, #top_sales2.Current_Week_Dollars DESC











GO
