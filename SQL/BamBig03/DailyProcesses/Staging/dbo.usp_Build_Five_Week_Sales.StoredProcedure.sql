USE [Staging]
GO
/****** Object:  StoredProcedure [dbo].[usp_Build_Five_Week_Sales]    Script Date: 8/19/2022 3:41:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO









CREATE Procedure [dbo].[usp_Build_Five_Week_Sales]
as
begin

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


declare @Wk13 smalldatetime			-- for 13 week sales


declare @TFYStart smalldatetime
declare @LFYStart smalldatetime

declare @fiscal_year int			-- Declare Current Fiscal Year
declare @day_of_week int           	-- Declare Day Of Week
declare @DIP int					-- Declare Date In Period

------------------------------------------ End Of Declarations --------------------------------------------
------------------------------------------ Create All Required Date Values --------------------------------

Set Transaction Isolation Level Read Uncommitted

select @fiscal_year = fiscal_year from reference.dbo.calendar_dim where day_date = staging.dbo.fn_dateonly(getdate())

					-- Get Fiscal Period and Year - This Year

select @wk1dt  = Staging.dbo.fn_Last_Saturday(Getdate())
select @wk2dt = dateadd(ww,-1,@wk1dt)
select @wk3dt = dateadd(ww,-1,@wk2dt)
select @wk4dt = dateadd(ww,-1,@wk3dt)
select @wk5dt = dateadd(ww,-1,@wk4dt)

					-- Get End Of Select Date - Last Year
select @wk1ly  = Staging.dbo.fn_Last_Saturday(dateadd(yy,-1,getdate()))
select @wk2ly = dateadd(ww,-1,@wk1ly)
select @wk3ly = dateadd(ww,-1,@wk2ly)
select @wk4ly = dateadd(ww,-1,@wk3ly)
select @wk5ly = dateadd(ww,-1,@wk4ly)

select @TFYStart = dateadd(dd,6,day_date) from Reference.dbo.Calendar_Dim 
where  fiscal_year = @fiscal_year
and    day_of_fiscal_year = 1
					-- Get Last Fiscal Year Start
select @LFYStart = dateadd(dd,6,day_date) from Reference.dbo.Calendar_Dim 
where  fiscal_year = @fiscal_year - 1
and    day_of_fiscal_year = 1

select @wk13 = dateadd(ww,-13,@wk1dt)

truncate table dssdata.dbo.Five_Week_Sales

truncate table staging.dbo.work_Five_Week_Sales

------------------------------------------ Construct Data Summaries ---------------------------------------
					-- Get Current Year Period Sums
insert into Staging.dbo.work_Five_Week_Sales
 SELECT T1.SKU_NUMBER,
  (SELECT isnull(SUM(CURRENT_UNITS),0) FROM DssData.dbo.Weekly_Sales with (NoLock)
   WHERE SKU_Number = T1.SKU_Number and day_date = @wk1dt) AS WEEK1UNITS,
  (SELECT isnull(SUM(current_dollars),0) FROM DssData.dbo.Weekly_Sales with (NoLock) 
   WHERE Sku_Number = T1.Sku_Number and day_date = @wk1dt) AS WEEK1DOLLARS,
  (SELECT isnull(SUM(CURRENT_UNITS),0) FROM DssData.dbo.Weekly_Sales with (NoLock)
   WHERE DAY_DATE = @WK2DT AND Sku_Number = T1.Sku_Number)AS WEEK2UNITS,
  (SELECT isnull(SUM(current_dollars),0) FROM DssData.dbo.Weekly_Sales with (NoLock)
   WHERE DAY_DATE = @WK2DT AND Sku_Number = T1.Sku_Number)AS WEEK2Dollars,
  (SELECT isnull(SUM(CURRENT_UNITS),0) FROM DssData.dbo.Weekly_Sales with (NoLock)
   WHERE DAY_DATE = @WK3DT AND Sku_Number = T1.Sku_Number)AS WEEK3UNITS,
  (SELECT isnull(SUM(current_dollars),0) FROM DssData.dbo.Weekly_Sales with (NoLock)
   WHERE DAY_DATE = @WK3DT AND Sku_Number = T1.Sku_Number)AS WEEK3Dollars,
  (SELECT isnull(SUM(CURRENT_UNITS),0) FROM DssData.dbo.Weekly_Sales with (NoLock)
   WHERE DAY_DATE = @WK4DT AND Sku_Number = T1.Sku_Number)AS WEEK4UNITS,
  (SELECT isnull(SUM(current_dollars),0) FROM DssData.dbo.Weekly_Sales with (NoLock)
   WHERE DAY_DATE = @WK4DT AND Sku_Number = T1.Sku_Number)AS WEEK4Dollars,
  (SELECT isnull(SUM(CURRENT_UNITS),0) FROM DssData.dbo.Weekly_Sales with (NoLock)
   WHERE DAY_DATE = @WK5DT AND Sku_Number = T1.Sku_Number)AS WEEK5UNITS,
  (SELECT isnull(SUM(current_dollars),0) FROM DssData.dbo.Weekly_Sales with (NoLock)
   WHERE DAY_DATE = @WK5DT AND Sku_Number = T1.Sku_Number)AS WEEK5Dollars,
  (SELECT isnull(SUM(CURRENT_UNITS),0) FROM DssData.dbo.Weekly_Sales with (NoLock)
   WHERE DAY_DATE = @WK1ly AND Sku_Number = T1.Sku_Number)AS LYWEEK1UNITS,
  (SELECT isnull(SUM(current_dollars),0) FROM DssData.dbo.Weekly_Sales with (NoLock)
   WHERE DAY_DATE = @WK1LY AND Sku_Number = T1.Sku_Number)AS LYWEEK1Dollars,
  (SELECT isnull(SUM(CURRENT_UNITS),0) FROM DssData.dbo.Weekly_Sales with (NoLock)
   WHERE DAY_DATE = @WK2ly AND Sku_Number = T1.Sku_Number)AS LYWEEK2UNITS,
  (SELECT isnull(SUM(current_dollars),0) FROM DssData.dbo.Weekly_Sales with (NoLock)
   WHERE DAY_DATE = @WK2LY AND Sku_Number = T1.Sku_Number)AS LYWEEK2Dollars,
  (SELECT isnull(SUM(CURRENT_UNITS),0) FROM DssData.dbo.Weekly_Sales with (NoLock)
   WHERE DAY_DATE = @WK3ly AND Sku_Number = T1.Sku_Number)AS LYWEEK3UNITS,
  (SELECT isnull(SUM(current_dollars),0) FROM DssData.dbo.Weekly_Sales with (NoLock)
   WHERE DAY_DATE = @WK3LY AND Sku_Number = T1.Sku_Number)AS LYWEEK3Dollars,
  (SELECT isnull(SUM(CURRENT_UNITS),0) FROM DssData.dbo.Weekly_Sales with (NoLock)
   WHERE DAY_DATE = @WK4ly AND Sku_Number = T1.Sku_Number)AS LYWEEK4UNITS,
  (SELECT isnull(SUM(current_dollars),0) FROM DssData.dbo.Weekly_Sales with (NoLock)
   WHERE DAY_DATE = @WK4LY AND Sku_Number = T1.Sku_Number)AS LYWEEK4Dollars,
  (SELECT isnull(SUM(CURRENT_UNITS),0) FROM DssData.dbo.Weekly_Sales with (NoLock)
   WHERE DAY_DATE = @WK5ly AND Sku_Number = T1.Sku_Number)AS LYWEEK5UNITS,
  (SELECT isnull(SUM(current_dollars),0) FROM DssData.dbo.Weekly_Sales with (NoLock)
   WHERE DAY_DATE = @WK5LY AND Sku_Number = T1.Sku_Number)AS LYWEEK5Dollars,
  (SELECT isnull(SUM(CURRENT_UNITS),0) FROM DssData.dbo.Weekly_Sales with (NoLock)
   WHERE DAY_DATE >=  @TFYSTART AND Sku_Number = T1.Sku_Number)AS TYYTDUNITS,
  (SELECT isnull(SUM(current_dollars),0) FROM DssData.dbo.Weekly_Sales with (NoLock)
   WHERE DAY_DATE >= @TFYSTART AND Sku_Number = T1.Sku_Number)AS TYYTDDOLLARS,
  (SELECT isnull(SUM(CURRENT_UNITS),0) FROM DssData.dbo.Weekly_Sales with (NoLock)
   WHERE DAY_DATE >=  @LFYSTART AND DAY_DATE <= DATEADD(YY,-1,DBO.FN_DATEONLY(GETDATE())) AND Sku_Number = T1.Sku_Number)AS LYYTDUNITS,
  (SELECT isnull(SUM(current_dollars),0) FROM DssData.dbo.Weekly_Sales with (NoLock)
   WHERE DAY_DATE >= @LFYSTART AND DAY_DATE <= DATEADD(YY,-1,DBO.FN_DATEONLY(GETDATE())) AND Sku_Number = T1.Sku_Number)AS LYYTDDOLLARS,
  (SELECT isnull(SUM(current_dollars),0) FROM DssData.dbo.Weekly_Sales with (NoLock)
   WHERE DAY_DATE >= @wk13 AND DAY_DATE <= Staging.dbo.fn_dateonly(getdate()) AND Sku_Number = T1.Sku_Number)AS Week13Dollars,
  (SELECT isnull(SUM(CURRENT_UNITS),0) FROM DssData.dbo.Weekly_Sales with (NoLock)
   WHERE DAY_DATE >=  @wk13 AND DAY_DATE <= Staging.dbo.fn_dateonly(getdate()) AND Sku_Number = T1.Sku_Number)AS Week13Units
FROM DssData.dbo.Weekly_Sales T1
WHERE DAY_DATE >= @WK3LY AND DAY_DATE <= @WK1DT
GROUP BY T1.Sku_Number

insert into DssData.dbo.Five_Week_Sales
select 	t2.sku_number as Sku_Number,
		t2.d_and_w_item_number as ISBN,
		t1.Week1Units,
		t1.Week1Dollars,
		t1.Week2Units,
		t1.Week2Dollars,
		t1.Week3Units,
		t1.Week3Dollars,
		t1.Week4Units,
		t1.Week4Dollars,
		t1.Week5Units,
		t1.Week5Dollars,
		t1.lyWeek1Units,
		t1.lyWeek1Dollars,
		t1.lyWeek2Units,
		t1.lyWeek2Dollars,
		t1.lyWeek3Units,
		t1.lyWeek3Dollars,
		t1.lyWeek4Units,
		t1.lyWeek4Dollars,
		t1.lyWeek5Units,
		t1.lyWeek5Dollars,
		t1.Week13Units,
		t1.Week13Dollars,
		t1.TYYTDUnits,
		t1.TYYTDDollars,
		t1.LYYTDUnits,
		t1.LYYTDDollars,
		dbo.fn_DateOnly(GetDate()) as Load_Date
from    Staging.dbo.Work_Five_Week_Sales  t1 with (nolock),
		Reference.dbo.Item_Dim t2 with (nolock)
Where 	t1.Sku_Number = t2.Sku_Number
--
end














GO
