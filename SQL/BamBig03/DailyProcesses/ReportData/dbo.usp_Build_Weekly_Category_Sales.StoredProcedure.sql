USE [ReportData]
GO
/****** Object:  StoredProcedure [dbo].[usp_Build_Weekly_Category_Sales]    Script Date: 8/19/2022 3:44:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Create procedure [dbo].[usp_Build_Weekly_Category_Sales]
as
declare @start_date smalldatetime
declare @end_date smalldatetime
--
select @start_date = dateadd(dd,-6,staging.dbo.fn_Last_Saturday(getdate()))
select @end_date = dateadd(dd,6,@start_date)
--
-- make sure there are no rows for this date range
--
delete from ReportData.dbo.Weekly_Category_Sales
where		day_date >= @start_date
and			day_date <= @end_date
--
-- Get data for this weeks rows
--
insert into	ReportData.dbo.Weekly_Category_Sales
select	@end_date as Day_Date,
		t1.Store_Number as Store_Number,
		t2.Dept as Dept,
		t2.Dept_Name,
		t2.SDept as SDept,
		t2.SDept_Name,
		t2.Class as Class,
		t2.Class_Name,
		sum(t1.Current_Dollars) as SLSD
from	dssdata.dbo.Weekly_Sales t1,
		reference.dbo.item_Master t2
where	t1.day_date >= @Start_Date
and		t1.day_date <= @End_Date
and		t2.sku_number = t1.sku_number
group by t1.Store_Number,t2.Dept,t2.Dept_Name,t2.SDept,t2.SDept_Name,t2.Class,t2.Class_Name
order by t1.store_number,t2.dept,t2.sdept,t2.class
--
-- To be safe, rebuild the previous weeks rows
--
select @start_date = dateadd(dd,-7,@Start_Date)
select @end_date = dateadd(dd,6,@start_date)
--
-- make sure there are no rows for this date range
--
delete from ReportData.dbo.Weekly_Category_Sales
where		day_date >= @start_date
and			day_date <= @end_date
--
-- Get data for this weeks rows
--
insert into	ReportData.dbo.Weekly_Category_Sales
select	@end_date as Day_Date,
		t1.Store_Number as Store_Number,
		t2.Dept as Dept,
		t2.Dept_Name,
		t2.SDept as SDept,
		t2.SDept_Name,
		t2.Class as Class,
		t2.Class_Name,
		sum(t1.Current_Dollars) as SLSD
from	dssdata.dbo.Weekly_Sales t1,
		reference.dbo.item_Master t2
where	t1.day_date >= @Start_Date
and		t1.day_date <= @End_Date
and		t2.sku_number = t1.sku_number
group by t1.Store_Number,t2.Dept,t2.Dept_Name,t2.SDept,t2.SDept_Name,t2.Class,t2.Class_Name
order by t1.store_number,t2.dept,t2.sdept,t2.class



GO
