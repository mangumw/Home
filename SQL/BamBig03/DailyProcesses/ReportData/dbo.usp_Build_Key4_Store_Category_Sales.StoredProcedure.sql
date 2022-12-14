USE [ReportData]
GO
/****** Object:  StoredProcedure [dbo].[usp_Build_Key4_Store_Category_Sales]    Script Date: 8/19/2022 3:44:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[usp_Build_Key4_Store_Category_Sales]
as
--
--
declare @DOFY_TY int
declare @DOFY_LY int
declare @Fiscal_Diff int
--
declare @Fiscal_Year_Week int
--
declare @Fiscal_Qtr_TY varchar(10)
declare @Fiscal_Qtr_LY varchar(10)
--
Declare @TYYES smalldatetime
declare @LYYES smalldatetime
declare @LY_End_Date smalldatetime
declare @TY_End_Date smalldatetime
declare @WTY_Start_Date smalldatetime
declare @WLY_Start_Date smalldatetime
declare @PTY_Start_Date smalldatetime
declare @PLY_Start_Date smalldatetime
--
declare @QTY_Start_Date smalldatetime
declare @QLY_Start_Date smalldatetime
--
declare @YTY_Start_Date smalldatetime
declare @YLY_Start_Date smalldatetime
declare @FY int
declare @fiscal_period int
--
select @TYYES = staging.dbo.fn_dateonly(dateadd(dd,-1,getdate()))
select @LYYes = staging.dbo.fn_dateonly(dateadd(yy,-1,getdate()))
--
select @DOFY_TY = day_of_fiscal_year from reference.dbo.calendar_dim where day_date = @TYYES
select @DOFY_LY = day_of_fiscal_year from reference.dbo.calendar_dim where day_date = staging.dbo.fn_DateOnly(dateadd(yy,-1,Getdate()))
select @Fiscal_Diff = @DOFY_TY - @DOFY_LY
--
select @fiscal_qtr_ty = fiscal_quarter from reference.dbo.calendar_dim where day_date = @TYYES
select @fiscal_qtr_ly = fiscal_quarter from reference.dbo.calendar_dim where day_date = staging.dbo.fn_DateOnly(dateadd(yy,-1,getdate()))
--
select @FY = Fiscal_Year from reference.dbo.calendar_dim where day_date = @TYYES
select @fiscal_year_week = fiscal_year_week from reference.dbo.calendar_dim where day_date = @TYYES
select @TY_End_Date = max(day_date) from reference.dbo.calendar_dim where fiscal_year_week = @fiscal_year_week - 1 and fiscal_year = @fy
select @WTY_Start_Date = min(day_date) from reference.dbo.calendar_dim where fiscal_year_week = @fiscal_year_week  and fiscal_year = @fy
--
select @WLY_Start_Date = min(day_date) 
from reference.dbo.calendar_dim 
where fiscal_year_week = @fiscal_year_week and fiscal_year = @fy-1
--
select @fiscal_period = fiscal_period from reference.dbo.calendar_dim where day_date = staging.dbo.fn_DateOnly(dateadd(dd,-1,getdate()))
--
select @PTY_Start_Date = min(day_date) from reference.dbo.calendar_dim where fiscal_year = @fy and fiscal_period = @fiscal_period
select @PLY_Start_Date = min(day_date) from reference.dbo.calendar_dim where fiscal_year = @fy-1 and fiscal_period = @fiscal_period
select @LY_End_Date = staging.dbo.fn_DateOnly(dateadd(dd,2,dateadd(yy,-1,@TY_End_Date)))
--
select @QTY_Start_Date = min(day_date) from reference.dbo.calendar_dim where fiscal_quarter = @fiscal_qtr_ty
select @QLY_Start_Date = min(day_date) from reference.dbo.calendar_dim where fiscal_quarter = @fiscal_qtr_ly
--
select @YTY_Start_Date = min(day_date) from reference.dbo.calendar_dim where fiscal_year = @fy
select @YLY_Start_Date = min(day_date) from reference.dbo.calendar_dim where fiscal_year = @fy - 1
--
if exists (select * from sysobjects where name = 'Key4_Cat_Sales_YES')
  DROP TABLE reportdata.dbo.Key4_Cat_Sales_YES
if exists (select * from sysobjects where name = 'Key4_Cat_Sales_WTD')
  DROP TABLE reportdata.dbo.Key4_Cat_Sales_WTD
if exists (select * from sysobjects where name = 'Key4_Cat_Sales_PTD')
  DROP TABLE reportdata.dbo.Key4_Cat_Sales_PTD
if exists (select * from sysobjects where name = 'Key4_Cat_Sales_QTD')
  DROP TABLE reportdata.dbo.Key4_Cat_Sales_QTD
if exists (select * from sysobjects where name = 'Key4_Cat_Sales_YTD')
  DROP TABLE reportdata.dbo.Key4_Cat_Sales_YTD


--
-- End of Date Calcs
--
--
-- Get Day Category Sales
--
select	Top 10 t2.SDept,
		sum(Extended_price) as TYYES_SLSD
Into	#TYYES
from	dssdata.dbo.Detail_Transaction_History t1,
		reference.dbo.item_Master t2
where	t1.day_date = @TYYES
and		t2.sku_number = t1.sku_number
and		t2.Dept = 4
group by t2.SDept
order by sum(Extended_Price) desc
--
select	t2.SDept,
		sum(Extended_price) as LYYES_SLSD
Into	#LYYES
from	dssdata.dbo.Detail_Transaction_History t1,
		reference.dbo.item_Master t2,
		#TYYES t3
where	t1.day_date = @LYYES
and		t2.sku_number = t1.sku_number
and		t2.sdept = t3.sdept
and		t2.Dept = 4
group by t2.SDept
order by sum(Extended_Price) desc
--
-- Get WTD Cat Sales
--
select	Top 10 t2.SDept,
		sum(Extended_price) as TYWTD_SLSD
Into	#TYWTD
from	dssdata.dbo.Detail_Transaction_History t1,
		reference.dbo.item_Master t2
where	t1.day_date >= @WTY_Start_Date
and		t1.day_date <= @TYYES
and		t2.sku_number = t1.sku_number
and		t2.Dept = 4
group by t2.SDept
order by sum(Extended_Price) desc
--
select	t2.SDept,
		sum(Extended_price) as LYWTD_SLSD
Into	#LYWTD
from	dssdata.dbo.Detail_Transaction_History t1,
		reference.dbo.item_Master t2,
		#TYWTD t3
where	t1.day_date >= @WLY_Start_Date
and		t1.day_date <= @LYYES
and		t2.sku_number = t1.sku_number
and		t2.sdept = t3.sdept
and		t2.Dept = 4
group by t2.SDept
order by sum(Extended_Price) desc
--
-- Get Period To Date
--
select	Top 10 t2.SDept,
		sum(Extended_price) as TYPTD_SLSD
Into	#TYPTD
from	dssdata.dbo.Detail_Transaction_History t1,
		reference.dbo.item_Master t2
where	t1.day_date >= @PTY_Start_Date
and		t1.day_date <= @TYYES
and		t2.sku_number = t1.sku_number
and		t2.Dept = 4
group by t2.SDept
order by sum(Extended_Price) desc
--
select	t2.SDept,
		sum(Extended_price) as LYPTD_SLSD
Into	#LYPTD
from	dssdata.dbo.Detail_Transaction_History t1,
		reference.dbo.item_Master t2,
		#TYPTD t3
where	t1.day_date >= @PLY_Start_Date
and		t1.day_date <= @LYYES
and		t2.sku_number = t1.sku_number
and		t2.sdept = t3.sdept
and		t2.Dept = 4
group by t2.SDept
order by sum(Extended_Price) desc
--
-- Get Quarter To Date
--
select	Top 10 t2.SDept,
		sum(Extended_price) as TYQTD_SLSD
Into	#TYQTD
from	dssdata.dbo.Detail_Transaction_History t1,
		reference.dbo.item_Master t2
where	t1.day_date >= @QTY_Start_Date
and		t1.day_date <= @TYYES
and		t2.sku_number = t1.sku_number
and		t2.Dept = 4
group by t2.SDept
order by sum(Extended_Price) desc
--
select	t2.SDept,
		sum(Extended_price) as LYQTD_SLSD
Into	#LYQTD
from	dssdata.dbo.Detail_Transaction_History t1,
		reference.dbo.item_Master t2,
		#TYQTD t3
where	t1.day_date >= @QLY_Start_Date
and		t1.day_date <= @LYYES
and		t2.sku_number = t1.sku_number
and		t2.sdept = t3.sdept
and		t2.Dept = 4
group by t2.SDept
order by sum(Extended_Price) desc
--
-- Get Yesr To Date
--
select	Top 10 t2.SDept,
		sum(Extended_price) as TYYTD_SLSD
Into	#TYYTD
from	dssdata.dbo.Detail_Transaction_History t1,
		reference.dbo.item_Master t2
where	t1.day_date >= @YTY_Start_Date
and		t1.day_date <= @TYYES
and		t2.sku_number = t1.sku_number
and		t2.Dept = 4
group by t2.SDept
order by sum(Extended_Price) desc

--
select	t2.SDept,
		sum(Extended_price) as LYYTD_SLSD
Into	#LYYTD
from	dssdata.dbo.Detail_Transaction_History t1,
		reference.dbo.item_Master t2,
		#TYYTD t3
where	t1.day_date >= @YLY_Start_Date
and		t1.day_date <= @LYYES
and		t2.sku_number = t1.sku_number
and		t2.sdept = t3.sdept
and		t2.Dept = 4
group by t2.SDept
order by sum(Extended_Price) desc
--
-- Join Tables
--
select	t1.sdept,
		t1.TYYES_SLSD,
		t2.LYYES_SLSD
into	reportdata.dbo.Key4_Cat_Sales_Yes
from	#TYYES t1 left join
		#LYYES t2
on		t2.sdept = t1.sdept
--
select	t1.sdept,
		t1.TYWTD_SLSD,
		t2.LYWTD_SLSD
into	reportdata.dbo.Key4_Cat_Sales_WTD
from	#TYWTD t1 left join
		#LYWTD t2
on		t2.sdept = t1.sdept
--
select	t1.sdept,
		t1.TYPTD_SLSD,
		t2.LYPTD_SLSD
into	reportdata.dbo.Key4_Cat_Sales_PTD
from	#TYPTD t1 left join
		#LYPTD t2
on		t2.sdept = t1.sdept
--
select	t1.sdept,
		t1.TYQTD_SLSD,
		t2.LYQTD_SLSD
into	reportdata.dbo.Key4_Cat_Sales_QTD
from	#TYQTD t1 left join
		#LYQTD t2
on		t2.sdept = t1.sdept
--
select	t1.sdept,
		t1.TYYTD_SLSD,
		t2.LYYTD_SLSD
into	reportdata.dbo.Key4_Cat_Sales_YTD
from	#TYYTD t1 left join
		#LYYTD t2
on		t2.sdept = t1.sdept
--
--
Drop Table #TYYES
Drop Table #TYWTD
Drop Table #TYPTD
Drop Table #TYQTD
Drop Table #TYYTD
Drop Table #LYYES
Drop Table #LYWTD
Drop Table #LYPTD
Drop Table #LYQTD
Drop Table #LYYTD
GO
