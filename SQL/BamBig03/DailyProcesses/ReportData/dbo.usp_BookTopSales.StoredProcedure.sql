USE [ReportData]
GO
/****** Object:  StoredProcedure [dbo].[usp_BookTopSales]    Script Date: 8/19/2022 3:44:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--
CREATE Procedure [dbo].[usp_BookTopSales]
  @SD varchar(25) =  NULL,
  @ED varchar(25) = NULL,
  @buyer_name varchar(50) = NULL
AS
declare @TD varchar(25)
declare @Department varchar(5)
declare @buyer varchar(3)
--
CREATE TABLE #rpt_top_sales1 (
	[Sr_Buyer] varchar(30) NULL,
	[Buyer] varchar(30) NULL,
	[department_Number] [int] NULL ,
	[SubDep_Number] [int] NULL ,
	[department_Name] varchar(50) NULL,
	[subdept_name] varchar(50) NULL,
	[sku_number] [int] NULL ,
	[Current_Dollars] [money] NULL ,
	[Current_Units] [decimal](18, 0) NULL 
) 
--
CREATE TABLE #rpt_top_sales2 (
	Sr_Buyer varchar(30) NULL,
	Buyer varchar(30) NULL,
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
INDEX [idx_rptsales1] ON #rpt_top_sales1 ([department_number], [SubDep_number], [sku_number])
--
CREATE 
INDEX [idx_rptsales2] ON #rpt_top_sales2 ([department], [SubDepartment], [Item_Name])
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
         	where day_date = staging.dbo.fn_DateOnly(GetDate())
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

--if @buyer_Name <> '<All>'
--  select @buyer = byrnum from reference.dbo.tblbyr where byrnam = @buyer_Name

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
if @buyer_name = '<All>'
insert into #rpt_top_sales1
select  t3.Sr_Buyer,
		t3.Buyer,
		t2.Dept,
        t2.SDept,
		t2.dept_name,
		t2.sdept_name,
		t1.sku_number,
		sum(t1.current_Dollars) as Current_Dollars,
		sum(Current_Units) as Current_Units
from  	dssdata.dbo.weekly_sales t1,
		reference.dbo.item_Master t2,
		dssdata.dbo.CARD t3
where	t1.day_date >= @StartDate and t1.day_date <= @EndDate
and		t2.sku_number = t1.sku_number
and		t2.Dept In (1,2,4,5,8)
and		t3.sku_number = t1.sku_number
group by t3.sr_buyer,t3.buyer,t2.Dept, t2.SDept, t2.dept_name,t2.sdept_name,t1.sku_number
else
insert into #rpt_top_sales1
select  t3.Sr_Buyer,
		t3.buyer,
		t2.Dept,
        t2.SDept,
		t2.dept_name,
		t2.sdept_name,
		t1.sku_number,
		sum(t1.current_Dollars) as Current_Dollars,
		sum(Current_Units) as Current_Units
from  	dssdata.dbo.weekly_sales t1,
		reference.dbo.item_Master t2,
		dssdata.dbo.CARD t3
where	t1.day_date >= @StartDate and t1.day_date <= @EndDate
and		t2.sku_number = t1.sku_number
and		t2.Dept In (1,2,4,5,8)
and		t3.sku_number = t1.sku_number
and		t3.sr_buyer = @buyer_name
group by t3.sr_buyer,t3.buyer,t2.Dept, t2.SDept, t2.dept_name,t2.sdept_name,t1.sku_number

--
-- select * from ##rpt_top_sales order by SubDep_Record_Number
---- Create Cursor to loop through the distinct sub_department rows in the temp table
--
declare  SubDept_Cursor cursor for 
select distinct (SubDep_Number),Department_Number from #rpt_top_sales1 order by department_Number,SubDep_Number
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
   insert into #rpt_top_sales2
    select top 10 
	  t1.sr_buyer,
	  t1.buyer,
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
    from #rpt_top_sales1 t1,
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
SELECT     TOP 100 PERCENT #rpt_top_sales2.Sr_Buyer,#rpt_top_sales2.Buyer,#rpt_top_sales2.Item_Name, #rpt_top_sales2.Department,  
                      #rpt_top_sales2.SubDepartment, #rpt_top_sales2.SubDepartment_Name, #rpt_top_sales2.Author, #rpt_top_sales2.ISBN, 
                      #rpt_top_sales2.Current_Week_Dollars, #rpt_top_sales2.SKU_Number, #rpt_top_sales2.Current_Units, reference.dbo.invcbl.On_Hand AS BAMOH, 
                      reference.dbo.itbal.OnHand AS WHOH, reference.dbo.itbal.OnBackOrder AS QBO, reference.dbo.itbal.OnPO AS QOO
FROM         #rpt_top_sales2 LEFT OUTER JOIN
                      reference.dbo.itbal ON #rpt_top_sales2.ISBN = reference.dbo.itbal.ISBN 
					  and reference.dbo.itbal.WarehouseID = '1' LEFT OUTER JOIN
                      reference.dbo.invcbl ON #rpt_top_sales2.SKU_Number = reference.dbo.invcbl.Sku_Number
GROUP BY #rpt_top_sales2.Item_Name, #rpt_top_sales2.Department, #rpt_top_sales2.SubDepartment, 
                      #rpt_top_sales2.SubDepartment_Name, #rpt_top_sales2.Author, #rpt_top_sales2.ISBN, #rpt_top_sales2.Current_Week_Dollars, 
                      #rpt_top_sales2.SKU_Number, #rpt_top_sales2.Current_Units, reference.dbo.invcbl.On_Hand, reference.dbo.itbal.OnHand, reference.dbo.itbal.OnBackOrder, 
                      reference.dbo.itbal.OnPO,#rpt_top_sales2.Sr_Buyer,#rpt_top_sales2.Buyer
ORDER BY #rpt_top_sales2.Department, #rpt_top_sales2.SubDepartment, #rpt_top_sales2.Current_Week_Dollars DESC











GO
