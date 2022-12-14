USE [Staging]
GO
/****** Object:  StoredProcedure [dbo].[usp_Build_Period_Sales]    Script Date: 8/19/2022 3:41:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO










CREATE PROCEDURE [dbo].[usp_Build_Period_Sales]
as

-----------------------------------------------------------------------------------
-- This SQL calculates the Period To Date values for Sales Units and Dollars     --
-- The date processing is rather complicated but breaks down to this:            --
--   for each week that has elapsed in the period, the sales data is returned.   --
--   For weeks end dates that have not passed, NULL is returned.                 --
--   If it is in the first week of a period, then the entire last period         --
--   is returned.                                                                --
-----------------------------------------------------------------------------------

declare @wk1dt smalldatetime      	-- Declare Week Date Variables
declare @wk2dt smalldatetime
declare @wk3dt smalldatetime
declare @wk4dt smalldatetime
declare @wk5dt smalldatetime

declare @wk1ly smalldatetime      	-- Declare Last Year Date Variables
declare @wk2ly smalldatetime
declare @wk3ly smalldatetime
declare @wk4ly smalldatetime
declare @wk5ly smalldatetime

declare @TFYStart smalldatetime		-- Declare Fiscal Year Start Dates
declare @LFYStart smalldatetime

declare @fiscal_period int		-- Declare Current Fiscal Period 
declare @fiscal_year int		-- Declare Current Fiscal Year
declare @day_of_week int                -- Declare Day Of Week
declare @DIP int			-- Declare Date In Period
declare @WIP int 			-- Declare Weeks In Period
declare @End_Date smalldatetime         -- Declare End_Of_Select date
declare @LY_End_Date smalldatetime      -- Declare Last Year End Of Select Date

------------------------------------------ End Of Declarations --------------------------------------------

------------------------------------------ Clean Out Work Tables ------------------------------------------

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[work_Period_Sales_TYWeek]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table work_Period_Sales_TYWeek

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[work_Period_Sales_LYWeek]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table work_Period_Sales_LYWeek

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[work_TYYTDSales]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table work_TYYTDSales

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[work_LYYTDSales]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table work_LYYTDSales

------------------------------------------ Create All Required Date Values --------------------------------

					-- Get Fiscal Period and Year - This Year
select @fiscal_period = fiscal_period from Reference.dbo.Calendar_Dim where day_date = dbo.fn_DateOnly(GETDATE())
select @DIP = day_of_period from Reference.dbo.Calendar_Dim where day_date = dbo.fn_DateOnly(GETDATE())

select @fiscal_year = fiscal_year from Reference.dbo.Calendar_Dim where day_date = dbo.fn_DateOnly(GETDATE())

select @day_of_week = day_of_week_number from Reference.dbo.Calendar_Dim where day_date = dbo.fn_DateOnly(GETDATE())

select @End_Date  = dbo.fn_dateonly(dateadd(dd,(@day_of_week*-1),getdate()))
					-- Get End Of Select Date - Last Year
select @day_of_week = day_of_week_number from Reference.dbo.Calendar_Dim where day_date = dbo.fn_DateOnly(dateadd(yy,-1,GETDATE()))
select @ly_End_Date  = day_date from reference.dbo.calendar_dim
                       where fiscal_year = @fiscal_year - 1 and 
                       day_of_fiscal_year = (select max(day_of_fiscal_year) from 
                                             reference.dbo.calendar_dim where fiscal_year = @fiscal_year - 1)
					-- Get Day In Period
if @DIP < 7 select @fiscal_period = @fiscal_period - 1
if @fiscal_period = 0
begin
 select @fiscal_period = 12
 select @fiscal_year = @fiscal_year - 1
end
					-- Determine number of periods in this month
select @WIP = count(day_date) from Reference.dbo.Calendar_dim
              where  day_of_week_number = 7
              and fiscal_period = @fiscal_period
              and fiscal_year = @fiscal_year
              and day_date <= dbo.fn_DateOnly(GetDate())

					-- Get first week end date
select @wk1dt = dateadd(dd,6,day_date) from Reference.dbo.Calendar_Dim where fiscal_period = @fiscal_period and fiscal_year = @fiscal_year and day_of_period = 1


if @WIP >= 2 select @wk2dt = dateadd(dd,7,@wk1dt) else select @wk2dt = NULL
if @WIP >= 3 select @wk3dt = dateadd(dd,7,@wk2dt) else select @wk3dt = NULL
if @WIP >= 4 select @wk4dt = dateadd(dd,7,@wk3dt) else select @wk4dt = NULL
if @WIP = 5  select @wk5dt = dateadd(dd,7,@wk4dt) else select @wk5dt = NULL

					-- Get First Week End Date - Last Year
select @wk1ly = dateadd(dd,6,day_date) from Reference.dbo.Calendar_Dim where fiscal_period = @fiscal_period and fiscal_year = @fiscal_year - 1 and day_of_period = 1

					-- Calculate Subsequent Week End Dates - Last Year
if @WIP >= 2 select @wk2ly = dateadd(dd,7,@wk1ly) else select @wk2ly = NULL
if @WIP >= 3 select @wk3ly = dateadd(dd,7,@wk2ly) else select @wk3ly = NULL
if @WIP >= 4 select @wk4ly = dateadd(dd,7,@wk3ly) else select @wk4ly = NULL
if @wip = 5 select @wk5ly = dateadd(dd,7,@wk4ly) else select @wk5ly = NULL

					-- Get This Fiscal Year Start
select @TFYStart = day_date from Reference.dbo.Calendar_Dim 
where  fiscal_year = @fiscal_year
and    day_of_fiscal_year = 1
					-- Get Last Fiscal Year Start
select @LFYStart = day_date from Reference.dbo.Calendar_Dim 
where  fiscal_year = @fiscal_year - 1
and    day_of_fiscal_year = 1

------------------------------------------ End Of Date Value Create ---------------------------------------

------------------------------------------ Construct Data Summaries ---------------------------------------
 
					-- Get Current Year Period Sums

select t1.sku_number,
  (select sum(current_units) from DssData.dbo.Weekly_Sales 
   where day_date = @wk1dt and sku_number = t1.sku_number) as Week1Units,
  (select sum(current_dollars) from DssData.dbo.Weekly_Sales 
   where day_date = @wk1dt and sku_number = t1.sku_number) as Week1Dollars,
  CASE @wk2dt
    when NULL then NULL
    else (select sum(current_units) from DssData.dbo.Weekly_Sales 
          where day_date = @wk2dt and Sku_Number = t1.Sku_Number)
  END as Week2Units,
  CASE @wk2dt
    When NULL then NULL
    Else (select sum(current_dollars) from DssData.dbo.Weekly_Sales 
          where day_date = @wk2dt and Sku_Number = t1.Sku_Number)
  END as Week2Dollars,
  CASE @wk3dt
    When NULL then NULL
    Else (select sum(current_units) from DssData.dbo.Weekly_Sales 
          where day_date = @wk3dt and Sku_Number = t1.Sku_Number)
  END as Week3Units,
  CASE @wk3dt
    When NULL then NULL
    Else (select sum(current_dollars) from DssData.dbo.Weekly_Sales 
          where day_date = @wk3dt and Sku_Number = t1.Sku_Number)
  END as Week3Dollars,
  CASE @wk4dt
    When NULL then NULL
    else (select sum(current_units) from DssData.dbo.Weekly_Sales 
          where day_date = @wk4dt and Sku_Number = t1.Sku_Number)
  END as Week4Units,
  CASE @wk4dt
    When NULL then NULL
    Else (select sum(current_dollars) from DssData.dbo.Weekly_Sales
          where day_date = @wk4dt and Sku_Number = t1.Sku_Number)
  END as Week4Dollars,
  Case @wk5dt
    when NULL then NULL
    else (select sum(current_Units) from DssData.dbo.Weekly_Sales
          where day_date = @wk5dt and Sku_Number = t1.Sku_Number)
  End as Week5Units,
  Case @wk5dt
    when NULL then NULL
    else (select sum(current_dollars) from DssData.dbo.Weekly_Sales
          where day_date = @wk5dt and Sku_Number = t1.Sku_Number)
  End as Week5Dollars
INTO Staging.dbo.work_Period_Sales_TYWeek
from DssData.dbo.Weekly_Sales t1
where day_date >= @WK1DT AND day_date <= @End_Date
group by t1.Sku_Number

					-- Get Last Year Period Sums
select t1.Sku_Number,
       (select sum(current_Units) from DssData.dbo.Weekly_Sales
        where day_date = @wk1ly and Sku_Number = t1.Sku_Number) as lyWeek1Units,
       (select sum(current_dollars) from DssData.dbo.Weekly_Sales
        where day_date = @wk1ly and Sku_Number = t1.Sku_Number) as lyWeek1Dollars,
       CASE @wk2ly
         When NULL then NULL
         Else (select sum(current_Units) from DssData.dbo.Weekly_Sales
               where day_date = @wk2ly and Sku_Number = t1.Sku_Number)
       END as lyWeek2Units,
       CASE @wk2ly
         When NULL then NULL
         Else (select sum(current_dollars) from DssData.dbo.Weekly_Sales
               where day_date = @wk2ly and Sku_Number = t1.Sku_Number)
       END as lyWeek2Dollars,
       CASE @wk3ly
         When NULL then NULL
         Else (select sum(current_Units) from DssData.dbo.Weekly_Sales
               where day_date = @wk3ly and Sku_Number = t1.Sku_Number)
       END as lyWeek3Units,
       CASE @wk3ly
         When NULL then NULL
         Else (select sum(current_dollars) from DssData.dbo.Weekly_Sales
               where day_date = @wk3ly and Sku_Number = t1.Sku_Number)
       END as lyWeek3Dollars,
       CASE @wk4ly
         When NULL then NULL
         Else (select sum(current_Units) from DssData.dbo.Weekly_Sales
               where day_date = @wk4ly and Sku_Number = t1.Sku_Number) 
       END as lyWeek4Units,
       CASE @wk4ly
         When NULL then NULL
         Else (select sum(current_dollars) from DssData.dbo.Weekly_Sales
               where day_date = @wk4ly and Sku_Number = t1.Sku_Number) 
       END as lyWeek4Dollars,
       Case @wk5ly
         When NULL then NULL
         Else (select sum(current_Units) from DssData.dbo.Weekly_Sales
               where day_date = @wk5ly and Sku_Number = t1.Sku_Number)
       End as lyWeek5Units,
       Case @wk5ly
         When NULL then NULL 
         Else (select sum(current_dollars) from DssData.dbo.Weekly_Sales
               where day_date = @wk5ly and Sku_Number = t1.Sku_Number)
       End as lyWeek5Dollars
INTO Staging.dbo.work_Period_Sales_LYWeek
from DssData.dbo.Weekly_Sales t1
where day_date >= @WK1ly AND day_date <= @ly_End_Date
group by t1.Sku_Number
					-- Get Current Year YTD

SELECT t1.Sku_Number, Sum(current_dollars) AS TYYTDollars,sum(current_units) as TYYTDUnits
INTO Staging.dbo.Work_TYYTDSales
FROM DssData.dbo.Weekly_Sales t1
WHERE t1.day_date >= @TFYStart
GROUP BY Sku_Number
					-- Get Last Year YTD

SELECT     Sku_Number,SUM(current_dollars) AS LYYTDollars, SUM(current_units) AS LYYTDUnits
INTO       Staging.dbo.Work_LYYTDSales 
FROM         DssData.dbo.Weekly_Sales
WHERE    day_date >= @LFYStart and day_date <= dateadd(yy,-1,dbo.fn_DateOnly(getdate()))
Group By Sku_Number

					-- Drop Existing Period_Sales table 

-- if exists (select * from DSSData.dbo.sysobjects where id = object_id(N'[dbo].[Period_Sales]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table DSSData.dbo.Period_Sales

					-- Join Work Tables into Period_Sales table

select t5.sku_number as Sku_Number,
	  t5.ISBN as ISBN,
      isnull(t1.Week1Units,0) as Week1Units,
      isnull(t1.Week1Dollars,0)as Week1Dollars,
      isnull(t1.Week2Units,0) as Week2Units,
      isnull(t1.Week2Dollars,0) as Week2Dollars,
      isnull(t1.Week3Units,0) as Week3Units,
      isnull(t1.Week3Dollars,0)as Week3Dollars,
      isnull(t1.Week4Units,0) as Week4Units,
      isnull(t1.Week4Dollars,0) as Week4Dollars,
      isnull(t1.Week5Units,0) as Week5Units,
      isnull(t1.Week5Dollars,0) as Week5Dollars,
      isnull(t2.lyWeek1Units,0) as lyWeek1Units,
      isnull(t2.lyWeek1Dollars,0)as lyWeek1Dollars,
      isnull(t2.lyWeek2Units,0) as lyWeek2Units,
      isnull(t2.lyWeek2Dollars,0) as lyWeek2Dollars,
      isnull(t2.lyWeek3Units,0) as lyWeek3Units,
      isnull(t2.lyWeek3Dollars,0) as lyWeek3Dollars,
      isnull(t2.lyWeek4Units,0) as lyWeek4Units,
      isnull(t2.lyWeek4Dollars,0) as lyWeek4Dollars,
      isnull(t2.lyWeek5Units,0) as lyWeek5Units,
      isnull(t2.lyWeek5Dollars,0) as lyWeek5Dollars,
      isnull(t3.TYYTDUnits,0) as TYYTDUnits,
      isnull(t3.TYYTDollars,0) as TYYTDollars,
      isnull(t4.LYYTDUnits,0) as LYYTDUnits,
      isnull(t4.LYYTDollars,0) as LYYTDollars,
	  getdate() as Load_Date
into DSSData.dbo.Period_Sales
FROM (((Reference.dbo.Item_Master t5
        LEFT JOIN Work_LYYTDSales t4 ON t5.Sku_Number = t4.Sku_Number) 
        LEFT JOIN work_Period_Sales_LYWeek t2 ON t5.Sku_Number = t2.Sku_Number) 
        LEFT JOIN work_Period_Sales_TYWeek t1 ON t5.Sku_Number = t1.Sku_Number) 
        LEFT JOIN Work_TYYTDSales t3 ON t5.Sku_Number = t3.Sku_Number;














GO
