USE [Staging]
GO
/****** Object:  StoredProcedure [dbo].[usp_Build_Three_Week_Sales_OLD_Feb_2014]    Script Date: 8/19/2022 3:41:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE Procedure [dbo].[usp_Build_Three_Week_Sales_OLD_Feb_2014]
as
begin
declare @wk1dt smalldatetime      	-- Declare Week Date Variables
declare @wk2dt smalldatetime
declare @wk3dt smalldatetime
declare @wk1ly smalldatetime      	-- Declare Last Year Date Variables
declare @wk2ly smalldatetime
declare @wk3ly smalldatetime
declare @Wk13 smalldatetime			-- for 13 week sales
declare @TFYStart smalldatetime
declare @LFYStart smalldatetime
declare @LY_LS smalldatetime
declare @fiscal_year int			-- Declare Current Fiscal Year
declare @day_of_week int           	-- Declare Day Of Week
declare @DIP int					-- Declare Date In Period
declare @LS smalldatetime
------------------------------------------ End Of Declarations --------------------------------------------
------------------------------------------ Create All Required Date Values --------------------------------
Set Transaction Isolation Level Read Uncommitted
					-- Get Fiscal Period and Year - This Year
select @fiscal_year = fiscal_year from Reference.dbo.Calendar_Dim where day_date = dbo.fn_DateOnly(dbo.fn_Last_Saturday(getdate()))
--
select @day_of_week = day_of_week_number from Reference.dbo.Calendar_Dim where day_date = dbo.fn_DateOnly(GETDATE())
--
select @LS = staging.dbo.fn_Last_Saturday(getdate())
select @wk1dt  = dbo.fn_dateonly(dateadd(dd,(@day_of_week*-1),getdate()))
select @wk2dt = dateadd(ww,-1,@wk1dt)
select @wk3dt = dateadd(ww,-1,@wk2dt)
					-- Get End Of Select Date - Last Year
select @day_of_week = day_of_week_number from Reference.dbo.Calendar_Dim where day_date = dbo.fn_DateOnly(dateadd(yy,-1,GETDATE()))
--
select @wk1ly  = staging.dbo.fn_Last_Saturday(dateadd(dd,-371,dateadd(dd,1,getdate()))) --dbo.fn_dateonly(dateadd(dd,(@day_of_week*-1),dateadd(yy,-1,getdate())))
--
select @wk2ly = dateadd(ww,-1,@wk1ly)
select @wk3ly = dateadd(ww,-1,@wk2ly)
--
--select @TFYStart = dateadd(dd,-6,day_date) from Reference.dbo.Calendar_Dim 
select @TFYStart = day_date from Reference.dbo.Calendar_Dim 

where  fiscal_year = @fiscal_year 
and    day_of_fiscal_year = 1
					-- Get Last Fiscal Year Start
select @LFYStart = DAY_DATE from Reference.dbo.Calendar_Dim 
where  fiscal_year = @fiscal_year -1
and    day_of_fiscal_year = 1
--
select @wk13 = dateadd(ww,-12,@wk1dt)
select @LY_LS = staging.dbo.fn_dateonly(staging.dbo.fn_Last_Saturday(dateadd(dd,-371,getdate())))
--
truncate table dssdata.dbo.Three_Week_Sales
--
truncate table staging.dbo.wrk_Three_Week_Sales_NEW
------------------------------------------ Construct Data Summaries ---------------------------------------
insert into Staging.dbo.wrk_Three_Week_Sales_New
 SELECT T1.SKU_NUMBER,
  (SELECT isnull(SUM(CURRENT_UNITS),0) FROM DssData.dbo.Weekly_Sales with (NoLock)
   WHERE SKU_Number = T1.SKU_Number and day_date = @wk1dt) AS WEEK1UNITS,
  (SELECT isnull(SUM(current_DOLLARS),0) FROM DssData.dbo.Weekly_Sales with (NoLock) 
   WHERE Sku_Number = T1.Sku_Number and day_date = @wk1dt) AS WEEK1DOLLARS,
  (SELECT isnull(SUM(CURRENT_UNITS),0) FROM DssData.dbo.Weekly_Sales with (NoLock)
   WHERE DAY_DATE = @WK2DT AND Sku_Number = T1.Sku_Number)AS WEEK2UNITS,
  (SELECT isnull(SUM(current_Dollars),0) FROM DssData.dbo.Weekly_Sales with (NoLock)
   WHERE DAY_DATE = @WK2DT AND Sku_Number = T1.Sku_Number)AS WEEK2Dollars,
  (SELECT isnull(SUM(CURRENT_UNITS),0) FROM DssData.dbo.Weekly_Sales with (NoLock)
   WHERE DAY_DATE = @WK3DT AND Sku_Number = T1.Sku_Number)AS WEEK3UNITS,
  (SELECT isnull(SUM(current_Dollars),0) FROM DssData.dbo.Weekly_Sales with (NoLock)
   WHERE DAY_DATE = @WK3DT AND Sku_Number = T1.Sku_Number)AS WEEK3Dollars,
  (SELECT isnull(SUM(CURRENT_UNITS),0) FROM DssData.dbo.Internet_Weekly_Sales with (NoLock)
   WHERE SKU_Number = T1.SKU_Number and day_date = @wk1dt) AS DCWEEK1UNITS,
  (SELECT isnull(SUM(current_DOLLARS),0) FROM DssData.dbo.Internet_Weekly_Sales with (NoLock) 
   WHERE Sku_Number = T1.Sku_Number and day_date = @wk1dt) AS DCWEEK1DOLLARS,
  (SELECT isnull(SUM(CURRENT_UNITS),0) FROM DssData.dbo.Internet_Weekly_Sales with (NoLock)
   WHERE DAY_DATE = @WK2DT AND Sku_Number = T1.Sku_Number)AS DCWEEK2UNITS,
  (SELECT isnull(SUM(current_Dollars),0) FROM DssData.dbo.Internet_Weekly_Sales with (NoLock)
   WHERE DAY_DATE = @WK2DT AND Sku_Number = T1.Sku_Number)AS DCWEEK2Dollars,
  (SELECT isnull(SUM(CURRENT_UNITS),0) FROM DssData.dbo.Internet_Weekly_Sales with (NoLock)
   WHERE DAY_DATE = @WK3DT AND Sku_Number = T1.Sku_Number)AS DCWEEK3UNITS,
  (SELECT isnull(SUM(current_Dollars),0) FROM DssData.dbo.Internet_Weekly_Sales with (NoLock)
   WHERE DAY_DATE = @WK3DT AND Sku_Number = T1.Sku_Number)AS DCWEEK3Dollars,
  (SELECT isnull(SUM(CURRENT_UNITS),0) FROM DssData.dbo.Weekly_Sales with (NoLock)
   WHERE DAY_DATE = @WK1ly AND Sku_Number = T1.Sku_Number)AS LYWEEK1UNITS,
  (SELECT isnull(SUM(current_Dollars),0) FROM DssData.dbo.Weekly_Sales with (NoLock)
   WHERE DAY_DATE = @WK1LY AND Sku_Number = T1.Sku_Number)AS LYWEEK1Dollars,
  (SELECT isnull(SUM(CURRENT_UNITS),0) FROM DssData.dbo.Weekly_Sales with (NoLock)
   WHERE DAY_DATE = @WK2ly AND Sku_Number = T1.Sku_Number)AS LYWEEK2UNITS,
  (SELECT isnull(SUM(current_Dollars),0) FROM DssData.dbo.Weekly_Sales with (NoLock)
   WHERE DAY_DATE = @WK2LY AND Sku_Number = T1.Sku_Number)AS LYWEEK2Dollars,
  (SELECT isnull(SUM(CURRENT_UNITS),0) FROM DssData.dbo.Weekly_Sales with (NoLock)
   WHERE DAY_DATE = @WK3ly AND Sku_Number = T1.Sku_Number)AS LYWEEK3UNITS,
  (SELECT isnull(SUM(current_Dollars),0) FROM DssData.dbo.Weekly_Sales with (NoLock)
   WHERE DAY_DATE = @WK3LY AND Sku_Number = T1.Sku_Number)AS LYWEEK3Dollars,
  (SELECT isnull(SUM(CURRENT_UNITS),0) FROM DssData.dbo.Internet_Weekly_Sales with (NoLock)
   WHERE DAY_DATE = @WK1ly AND Sku_Number = T1.Sku_Number)AS LYDCWEEK1UNITS,
  (SELECT isnull(SUM(current_Dollars),0) FROM DssData.dbo.Internet_Weekly_Sales with (NoLock)
   WHERE DAY_DATE = @WK1LY AND Sku_Number = T1.Sku_Number)AS LYDCWEEK1Dollars,
  (SELECT isnull(SUM(CURRENT_UNITS),0) FROM DssData.dbo.Internet_Weekly_Sales with (NoLock)
   WHERE DAY_DATE = @WK2ly AND Sku_Number = T1.Sku_Number)AS LYDCWEEK2UNITS,
  (SELECT isnull(SUM(current_Dollars),0) FROM DssData.dbo.Internet_Weekly_Sales with (NoLock)
   WHERE DAY_DATE = @WK2LY AND Sku_Number = T1.Sku_Number)AS LYDCWEEK2Dollars,
  (SELECT isnull(SUM(CURRENT_UNITS),0) FROM DssData.dbo.Internet_Weekly_Sales with (NoLock)
   WHERE DAY_DATE = @WK3ly AND Sku_Number = T1.Sku_Number)AS LYDCWEEK3UNITS,
  (SELECT isnull(SUM(current_Dollars),0) FROM DssData.dbo.Internet_Weekly_Sales with (NoLock)
   WHERE DAY_DATE = @WK3LY AND Sku_Number = T1.Sku_Number)AS LYDCWEEK3Dollars,
  (SELECT isnull(SUM(CURRENT_UNITS),0) FROM DssData.dbo.Weekly_Sales with (NoLock)
   WHERE DAY_DATE >=  @TFYSTART AND Sku_Number = T1.Sku_Number)AS TYYTDUNITS,
  (SELECT isnull(SUM(current_DOLLARS),0) FROM DssData.dbo.Weekly_Sales with (NoLock)
   WHERE DAY_DATE >= @TFYSTART AND Sku_Number = T1.Sku_Number)AS TYYTDDOLLARS,
  (SELECT isnull(SUM(CURRENT_UNITS),0) FROM DssData.dbo.Weekly_Sales with (NoLock)
   WHERE DAY_DATE >=  @LFYSTART AND DAY_DATE <= @LY_LS AND Sku_Number = T1.Sku_Number)AS LYYTDUNITS,
  (SELECT isnull(SUM(current_DOLLARS),0) FROM DssData.dbo.Weekly_Sales with (NoLock)
   WHERE DAY_DATE >= @LFYSTART AND DAY_DATE <= @LY_LS AND Sku_Number = T1.Sku_Number)AS LYYTDDOLLARS,
  (SELECT isnull(SUM(CURRENT_UNITS),0) FROM DssData.dbo.Internet_Weekly_Sales with (NoLock)
   WHERE DAY_DATE >=  @TFYSTART AND Sku_Number = T1.Sku_Number)AS DCTYYTDUNITS,
  (SELECT isnull(SUM(current_DOLLARS),0) FROM DssData.dbo.Internet_Weekly_Sales with (NoLock)
   WHERE DAY_DATE >= @TFYSTART AND Sku_Number = T1.Sku_Number)AS DCTYYTDDOLLARS,
  (SELECT isnull(SUM(CURRENT_UNITS),0) FROM DssData.dbo.Internet_Weekly_Sales with (NoLock)
   WHERE DAY_DATE >=  @LFYSTART AND DAY_DATE <= @LY_LS AND Sku_Number = T1.Sku_Number)AS DCLYYTDUNITS,
  (SELECT isnull(SUM(current_DOLLARS),0) FROM DssData.dbo.Internet_Weekly_Sales with (NoLock)
   WHERE DAY_DATE >= @LFYSTART AND DAY_DATE <= @LY_LS AND Sku_Number = T1.Sku_Number)AS DCLYYTDDOLLARS,
  (SELECT isnull(SUM(current_DOLLARS),0) FROM DssData.dbo.Weekly_Sales with (NoLock)
   WHERE DAY_DATE >= @wk13 AND DAY_DATE <= Staging.dbo.fn_dateonly(getdate()) AND Sku_Number = T1.Sku_Number)AS Week13Dollars,
  (SELECT isnull(SUM(CURRENT_UNITS),0) FROM DssData.dbo.Weekly_Sales with (NoLock)
   WHERE DAY_DATE >=  @wk13 AND DAY_DATE <= @LS AND Sku_Number = T1.Sku_Number)AS Week13Units,
  (SELECT isnull(SUM(current_DOLLARS),0) FROM DssData.dbo.Internet_Weekly_Sales with (NoLock)
   WHERE DAY_DATE >= @wk13 AND DAY_DATE <= @LS AND Sku_Number = T1.Sku_Number)AS DCWeek13Dollars,
  (SELECT isnull(SUM(CURRENT_UNITS),0) FROM DssData.dbo.Internet_Weekly_Sales with (NoLock)
   WHERE DAY_DATE >=  @wk13 AND DAY_DATE <= @LS AND Sku_Number = T1.Sku_Number)AS DCWeek13Units
FROM DssData.dbo.Weekly_Sales T1
WHERE DAY_DATE >= @WK3LY AND DAY_DATE <= @WK1DT
GROUP BY T1.Sku_Number

insert into DssData.dbo.Three_Week_Sales
select 	t2.sku_number as Sku_Number,
		t2.ISBN,
		t1.Week1Units,
		t1.Week1Dollars,
		t1.Week2Units,
		t1.Week2Dollars,
		t1.Week3Units,
		t1.Week3Dollars,
		t1.DCWeek1Units,
		t1.DCWeek1Dollars,
		t1.DCWeek2Units,
		t1.DCWeek2Dollars,
		t1.DCWeek3Units,
		t1.DCWeek3Dollars,
		t1.lyWeek1Units,
		t1.lyWeek1Dollars,
		t1.lyWeek2Units,
		t1.lyWeek2Dollars,
		t1.lyWeek3Units,
		t1.lyWeek3Dollars,
		t1.lyDCWeek1Units,
		t1.lyDCWeek1Dollars,
		t1.lyDCWeek2Units,
		t1.lyDCWeek2Dollars,
		t1.lyDCWeek3Units,
		t1.lyDCWeek3Dollars,
		t1.TYYTDUnits,
		t1.TYYTDDollars,
		t1.LYYTDUnits,
		t1.LYYTDDollars,
		t1.DCTYYTDUnits,
		t1.DCTYYTDDollars,
		t1.DCLYYTDUnits,
		t1.DCLYYTDDollars,
		t1.Week13Units,
		t1.Week13Dollars,
		t1.DCWeek13Units,
		t1.DCWeek13Dollars,
		dbo.fn_DateOnly(GetDate()) as Load_Date
from    Staging.dbo.Wrk_Three_Week_Sales_NEW  t1 with (nolock),
		Reference.dbo.Item_master t2 with (nolock)
Where 	t1.Sku_Number = t2.Sku_Number
--
end






















GO
