USE [ReportData]
GO
/****** Object:  StoredProcedure [dbo].[usp_Build_Institutional_Card_Sales_Combined]    Script Date: 8/19/2022 3:44:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[usp_Build_Institutional_Card_Sales_Combined]
as
declare @Seldate smalldatetime
declare @LW_Start smalldatetime
declare @LW_End smalldatetime
declare @Period_Start smalldatetime
declare @QTD_Start smalldatetime
declare @Fiscal_QTD varchar(10)
declare @fp int
declare @yr int
declare @yr_Start smalldatetime
declare @LS smalldatetime
declare @LY_LS smalldatetime
declare @LY_YTD_Start smalldatetime
declare @LY_YTD_End	smalldatetime
declare @LY_Period_Start smalldatetime
declare @LY_Period_End smalldatetime
declare @LY_QTD_Start smalldatetime
declare @LY_QTD_End smalldatetime
declare @LY_LW_Start smalldatetime
declare @LY_LW_End smalldatetime
--
select @Seldate = staging.dbo.fn_Last_Saturday(getdate())
select @LS = staging.dbo.fn_Last_Saturday(getdate())
select @fp = fiscal_period from reference.dbo.calendar_dim where day_date = staging.dbo.fn_DateOnly(@LS)
select @yr = fiscal_year from reference.dbo.calendar_dim where day_date = staging.dbo.fn_DateOnly(@ls)
select @Period_Start = day_date from reference.dbo.calendar_dim where fiscal_period = @fp and day_of_period = 1 and fiscal_year = @yr
--
select @yr = fiscal_year from reference.dbo.calendar_dim where day_date = staging.dbo.fn_DateOnly(@ls)
select @yr_start = day_date from reference.dbo.calendar_dim where fiscal_year = @yr and day_of_fiscal_year = 1
--
select @Fiscal_QTD = fiscal_quarter from reference.dbo.calendar_dim where day_date = staging.dbo.fn_Last_Saturday(getdate())
select @QTD_Start = min(day_date) from reference.dbo.calendar_dim where fiscal_quarter = @fiscal_QTD
--
select @LW_End = staging.dbo.fn_Last_Saturday(getdate())
select @LW_Start = dateadd(dd,-6,@LW_End)

--
-- Calculate Last Year Dates
--
select @yr = @yr - 1
select @LY_LS = staging.dbo.fn_Last_Saturday(dateadd(yy,-1,getdate()))
select @ly_ytd_start = day_date from reference.dbo.calendar_dim where fiscal_year = @yr and day_of_fiscal_year = 1
select @ly_ytd_end = staging.dbo.fn_Last_Saturday(dateadd(yy,-1,getdate()))
--
select @fp = fiscal_period from reference.dbo.calendar_dim where day_date = staging.dbo.fn_DateOnly(@ly_ls)
select @LY_Period_Start = min(day_date) from reference.dbo.calendar_dim where fiscal_period = @fp and fiscal_year = @yr
select @LY_Period_End = max(day_date) from reference.dbo.calendar_dim where fiscal_period = @fp and fiscal_year = @yr
--
select @LY_LW_End = staging.dbo.fn_last_saturday(dateadd(yy,-1,getdate()))
select @LY_LW_start = dateadd(dd,-6,@LY_LW_End)
--
select @Fiscal_QTD = fiscal_quarter from reference.dbo.calendar_dim where day_date = staging.dbo.fn_DateOnly(@ly_LS)
select @LY_QTD_Start = min(day_date) from reference.dbo.calendar_dim where fiscal_quarter = @fiscal_QTD
select @LY_QTD_End = Max(day_date) from reference.dbo.calendar_dim where fiscal_quarter = @fiscal_QTD
--
-- Truncate temp tables
--
truncate table Staging.dbo.Inst_week_total_sales
truncate table Staging.dbo.Inst_week_comm_salesC
truncate table Staging.dbo.Inst_MTD_total_sales
truncate table Staging.dbo.Inst_MTD_comm_salesC
truncate table Staging.dbo.Inst_QTD_total_sales
truncate table Staging.dbo.Inst_QTD_comm_salesC
truncate table Staging.dbo.Inst_YTD_total_sales
truncate table Staging.dbo.Inst_YTD_comm_salesC
truncate table Staging.dbo.Inst_LY_week_total_sales
truncate table Staging.dbo.Inst_LY_week_comm_salesC
truncate table Staging.dbo.Inst_LY_MTD_total_sales
truncate table Staging.dbo.Inst_LY_MTD_comm_salesC
truncate table Staging.dbo.Inst_LY_QTD_total_sales
truncate table Staging.dbo.Inst_LY_QTD_comm_salesC
truncate table Staging.dbo.Inst_LY_YTD_total_sales
truncate table Staging.dbo.Inst_LY_YTD_comm_salesC
--
-- Truncate Output Table
--
truncate table ReportData.dbo.Institutional_Card_Sales_Combined
--
-- Get Community Cards
--
truncate table staging.dbo.CommCardsC
insert into staging.dbo.commcardsC
select	mcustnumint
from	dssdata.dbo.gclu
where	(MSpecial in ('COMM','CORP','TEACHER'))
Or		PClientType = 'INS'
--
--
-- Set up Output Table with row for each store
--
insert into ReportData.dbo.Institutional_Card_Sales_Combined
select	Region_Number,
		Region_Name,
		District_Number,
		District_Name,
		Store_Number,
		Store_Name,
		0,
		0,
		0,
		0,
		0,
		0,
		0,
		0,
		0,
		0,
		0,
		0,
		0,
		0,
		0,
		0,
		0,
		0,
		0,
		0,
		0,
		0,
		0,
		0,
		0,
		0,
		0,
		0,
		0
from	Reference.dbo.active_stores
--
-- Get number of cards sold
--
 select  passignstore
        ,CS_LW = sum ( case when mcreatedate >= Dateadd(ww,-1,@LS)  then 1 else 0 end )  
        ,CS_PTD = sum ( case when mcreatedate >= @Period_Start  then 1 else 0 end )  
        ,CS_QTD = sum ( case when mcreatedate >= @QTD_Start  then 1 else 0 end )  
        ,CS_YTD = sum ( case when mcreatedate >= @yr_Start  then 1 else 0 end )
into	#CS  
from	Dssdata.dbo.GCLU
where   mcreatedate >= '2010-01-31' and mcreatedate is not null
and		(MSpecial in ('COMM','CORP','TEACHER'))
Or		PClientType = 'INS'
Group By passignstore
--
--Get Last Week numbers

--Get Week total Sales

insert into Staging.dbo.Inst_Week_Total_Sales
select	t1.store_number,
		isnull(sum(t1.Extended_price),0) as Week_Total_Sales
from	dssdata.dbo.detail_transaction_period t1
where	day_date >= @LW_Start and day_date <= @LW_End
group by t1.store_number





-- Get Week Community Card Sales

insert into Staging.dbo.Inst_Week_Comm_SalesC
select	t3.store_number,
		isnull(sum(t3.Extended_price),0) as Week_Comm_Sales
from	staging.dbo.CommCardsC t2,
		dssdata.dbo.detail_transaction_history t3
Where	t3.customer_number = t2.MCustNumint
and		t3.day_date >= @LW_Start and t3.day_date <= @LW_End
group by t3.store_number






--
-- Get Month To Date Data
--
-- Get MTD Total Sales
--
insert into Staging.dbo.Inst_MTD_Total_Sales
select	t3.store_number,
		sum(t3.extended_price) as MTD_Total_Sales
from	dssdata.dbo.detail_transaction_history t3
where	t3.day_date >= @Period_Start and t3.day_date <= @LS
group by t3.store_number



--
-- Get MTD Community Card Sales
--
insert into Staging.dbo.Inst_MTD_Comm_SalesC
select	t3.store_number,
		isnull(sum(t3.extended_price),0) as MTD_Comm_SalesC
from	staging.dbo.CommCardsC t2,
		dssdata.dbo.detail_transaction_history t3
where	t3.customer_number = t2.MCustNumint
and		t3.day_date >= @Period_Start and t3.day_date <= @LS
group by t3.store_number



--
-- Get Quarter To Date Data
--
-- Get QTD Total Sales
--
Insert into Staging.dbo.Inst_QTD_Total_Sales
select	t3.store_number,
		sum(t3.Extended_price) as QTD_Total_Sales
from	dssdata.dbo.detail_transaction_history t3
where	t3.day_date >= @QTD_Start 
and		t3.day_date <= @LS
group by t3.store_number


--
-- Get QTD Community Card Sales
--
insert into Staging.dbo.Inst_QTD_Comm_SalesC
select	t3.store_number,
		isnull(sum(t3.Extended_price),0) as QTD_Comm_SalesC
from	staging.dbo.CommCardsC t2,
		dssdata.dbo.detail_transaction_history t3
where	t3.customer_number = t2.MCustNumint
and		t3.day_date >= @QTD_Start and t3.day_date <= @LS
group by t3.store_number
--


--
-- Get Year To Date Data
--
-- Get YTD Total Sales
--
insert into	Staging.dbo.Inst_YTD_Total_Sales
select	t3.store_number,
		sum(t3.extended_price) as YTD_Total_Sales
from	dssdata.dbo.detail_transaction_history t3
where	t3.day_date >= @Yr_Start 
and		t3.day_date <= @LS
group by t3.store_number
--
-- Get YTD Community Card Sales
--
insert into Staging.dbo.Inst_YTD_Comm_SalesC
select	t3.store_number,
		isnull(sum(t3.Extended_price),0) as YTD_Comm_SalesC
from	staging.dbo.CommCardsC t2,
		dssdata.dbo.detail_transaction_history t3
where	t3.customer_number = t2.MCustNumint
and		t3.day_date >= @YR_Start and t3.day_date <= @LS
group by t3.store_number
--
--
-- Get Last Year Numbers for all categories
--
-- Get Last Week numbers
--
-- Get Week total Sales
--
insert into Staging.dbo.Inst_LY_Week_Total_Sales
select	t1.store_number,
		isnull(sum(t1.Extended_price),0) as LY_Week_Total_Sales
from	dssdata.dbo.detail_transaction_history t1
where	day_date >= @LY_LW_Start and day_date <= @LY_LW_End
group by t1.store_number
--
-- Get Week Community Card Sales
--
insert into Staging.dbo.Inst_LY_Week_Comm_SalesC
select	t3.store_number,
		isnull(sum(t3.Extended_price),0) as LY_Week_Comm_Sales
from	staging.dbo.CommCardsC t2,
		dssdata.dbo.detail_transaction_history t3
Where	t3.customer_number = t2.MCustNumint
and		t3.day_date >= @LY_LW_Start and t3.day_date <= @LY_LW_End
group by t3.store_number
--
--
-- Get Month To Date Data
--
-- Get MTD Total Sales
--
insert into Staging.dbo.Inst_LY_MTD_Total_Sales
select	t3.store_number,
		sum(t3.extended_price) as LY_MTD_Total_Sales
from	dssdata.dbo.detail_transaction_history t3
where	t3.day_date >= @LY_Period_Start and t3.day_date <= @LY_LS
group by t3.store_number
--
-- Get MTD Community Card Sales
--
insert into Staging.dbo.Inst_LY_MTD_Comm_SalesC
select	t3.store_number,
		isnull(sum(t3.extended_price),0) as LY_MTD_Comm_SalesC
from	staging.dbo.CommCardsC t2,
		dssdata.dbo.detail_transaction_history t3
where	t3.customer_number = t2.MCustNumint
and		t3.day_date >= @LY_Period_Start and t3.day_date <= @LY_LS
group by t3.store_number
--
-- Get Quarter To Date Data
--
-- Get QTD Total Sales
--
Insert into Staging.dbo.Inst_LY_QTD_Total_Sales
select	t3.store_number,
		sum(t3.Extended_price) as LY_QTD_Total_Sales
from	dssdata.dbo.detail_transaction_history t3
where	t3.day_date >= @LY_QTD_Start 
and		t3.day_date <= @LY_LS
group by t3.store_number
--
-- Get QTD Community Card Sales
--
insert into Staging.dbo.Inst_LY_QTD_Comm_SalesC
select	t3.store_number,
		isnull(sum(t3.Extended_price),0) as LY_QTD_Comm_SalesC
from	staging.dbo.CommCardsC t2,
		dssdata.dbo.detail_transaction_history t3
where	t3.customer_number = t2.MCustNumint
and		t3.day_date >= @LY_QTD_Start and t3.day_date <= @LY_LS
group by t3.store_number
--
-- Get Year To Date Data
--
-- Get YTD Total Sales
--
insert into	Staging.dbo.Inst_LY_YTD_Total_Sales
select	t3.store_number,
		sum(t3.extended_price) as LY_YTD_Total_Sales
from	dssdata.dbo.detail_transaction_history t3
where	t3.day_date >= @LY_YTD_Start 
and		t3.day_date <= @LY_LS
group by t3.store_number
--
-- Get YTD Community Card Sales
--
insert into Staging.dbo.Inst_LY_YTD_Comm_SalesC
select	t3.store_number,
		isnull(sum(t3.Extended_price),0) as LY_YTD_Comm_SalesC
from	staging.dbo.CommCardsC t2,
		dssdata.dbo.detail_transaction_history t3
where	t3.customer_number = t2.MCustNumint
and		t3.day_date >= @LY_YTD_Start and t3.day_date <= @LY_LS
group by t3.store_number
--
-- Get Week MCC Activity by Store
--
select	store_number,
		count(Customer_number) as NumTrans
into	#mcctrans
from	dssdata.dbo.Club_Card_Activity
where	day_date >= @LW_Start and day_date <= @LW_End
group by store_number
--
-- Construct Final Report Table with This Year Values
--
update reportdata.dbo.institutional_card_sales_combined 
set		CS_LW = #cs.CS_LW,
		CS_PTD = #cs.CS_PTD,
		CS_QTD = #cs.CS_QTD,
		CS_YTD = #cs.CS_YTD
from	#cs
where	#cs.passignstore = reportdata.dbo.institutional_card_sales_combined.Store_Number
and     isnumeric(#cs.passignstore) = 1

update reportdata.dbo.institutional_card_sales_combined 
set Week_Total_Sales = (select Week_total_Sales
from staging.dbo.Inst_Week_Total_Sales 
where staging.dbo.Inst_Week_Total_Sales.Store_Number = ReportData.dbo.Institutional_Card_Sales_Combined.Store_Number)
--
update reportdata.dbo.institutional_card_sales_combined 
set Week_Comm_Sales = (select Week_Comm_Sales
from staging.dbo.Inst_Week_Comm_SalesC 
where staging.dbo.Inst_Week_Comm_SalesC.Store_Number = ReportData.dbo.Institutional_Card_Sales_Combined.Store_Number)
--
--
update reportdata.dbo.institutional_card_sales_combined 
set MTD_Total_Sales = (select MTD_total_Sales
from staging.dbo.Inst_MTD_Total_Sales 
where staging.dbo.Inst_MTD_Total_Sales.Store_Number = ReportData.dbo.Institutional_Card_Sales_Combined.Store_Number)
--
update reportdata.dbo.institutional_card_sales_combined 
set MTD_Comm_Sales = (select MTD_Comm_Sales
from staging.dbo.Inst_MTD_Comm_SalesC 
where staging.dbo.Inst_MTD_Comm_SalesC.Store_Number = ReportData.dbo.Institutional_Card_Sales_Combined.Store_Number)
--
update reportdata.dbo.institutional_card_sales_combined 
set QTD_Total_Sales = (select QTD_total_Sales
from staging.dbo.Inst_QTD_Total_Sales 
where staging.dbo.Inst_QTD_Total_Sales.Store_Number = ReportData.dbo.Institutional_Card_Sales_Combined.Store_Number)
--
update reportdata.dbo.institutional_card_sales_combined 
set QTD_Comm_Sales = (select QTD_Comm_Sales
from staging.dbo.Inst_QTD_Comm_SalesC 
where staging.dbo.Inst_QTD_Comm_SalesC.Store_Number = ReportData.dbo.Institutional_Card_Sales_Combined.Store_Number)
--
update reportdata.dbo.institutional_card_sales_combined 
set YTD_Total_Sales = (select YTD_total_Sales
from staging.dbo.Inst_YTD_Total_Sales 
where staging.dbo.Inst_YTD_Total_Sales.Store_Number = ReportData.dbo.Institutional_Card_Sales_Combined.Store_Number)
--
update reportdata.dbo.institutional_card_sales_combined 
set YTD_Comm_Sales = (select YTD_Comm_Sales
from staging.dbo.Inst_YTD_Comm_SalesC 
where staging.dbo.Inst_YTD_Comm_SalesC.Store_Number = ReportData.dbo.Institutional_Card_Sales_Combined.Store_Number)
--
--
-- Construct Final Report Table with Last Year Values
--
update reportdata.dbo.institutional_card_sales_combined 
set LY_Week_Total_Sales = (select LY_Week_total_Sales
from staging.dbo.Inst_LY_Week_Total_Sales 
where staging.dbo.Inst_LY_Week_Total_Sales.Store_Number = ReportData.dbo.Institutional_Card_Sales_Combined.Store_Number)
--
update reportdata.dbo.institutional_card_sales_combined 
set LY_Week_Comm_Sales = (select LY_Week_Comm_Sales
from staging.dbo.Inst_LY_Week_Comm_SalesC 
where staging.dbo.Inst_LY_Week_Comm_SalesC.Store_Number = ReportData.dbo.Institutional_Card_Sales_Combined.Store_Number)
--
--
update reportdata.dbo.institutional_card_sales_combined 
set LY_MTD_Total_Sales = (select LY_MTD_total_Sales
from staging.dbo.Inst_LY_MTD_Total_Sales 
where staging.dbo.Inst_LY_MTD_Total_Sales.Store_Number = ReportData.dbo.Institutional_Card_Sales_Combined.Store_Number)
--
update reportdata.dbo.institutional_card_sales_combined 
set LY_MTD_Comm_Sales = (select LY_MTD_Comm_Sales
from staging.dbo.Inst_LY_MTD_Comm_SalesC 
where staging.dbo.Inst_LY_MTD_Comm_SalesC.Store_Number = ReportData.dbo.Institutional_Card_Sales_Combined.Store_Number)
--
update reportdata.dbo.institutional_card_sales_combined 
set LY_QTD_Total_Sales = (select LY_QTD_total_Sales
from staging.dbo.Inst_LY_QTD_Total_Sales 
where staging.dbo.Inst_LY_QTD_Total_Sales.Store_Number = ReportData.dbo.Institutional_Card_Sales_Combined.Store_Number)
--
update reportdata.dbo.institutional_card_sales_combined 
set LY_QTD_Comm_Sales = (select LY_QTD_Comm_Sales
from staging.dbo.Inst_LY_QTD_Comm_SalesC 
where staging.dbo.Inst_LY_QTD_Comm_SalesC.Store_Number = ReportData.dbo.Institutional_Card_Sales_Combined.Store_Number)
--
update reportdata.dbo.institutional_card_sales_combined 
set LY_YTD_Total_Sales = (select LY_YTD_total_Sales
from staging.dbo.Inst_LY_YTD_Total_Sales 
where staging.dbo.Inst_LY_YTD_Total_Sales.Store_Number = ReportData.dbo.Institutional_Card_Sales_Combined.Store_Number)
--
update reportdata.dbo.institutional_card_sales_combined 
set LY_YTD_Comm_Sales = (select LY_YTD_Comm_Sales
from staging.dbo.Inst_LY_YTD_Comm_SalesC 
where staging.dbo.Inst_LY_YTD_Comm_SalesC.Store_Number = ReportData.dbo.Institutional_Card_Sales_Combined.Store_Number)
--
update reportdata.dbo.institutional_card_sales_combined 
set Week_MCC_Sales = #MCCTrans.numtrans
from #mcctrans
where #mcctrans.store_number = ReportData.dbo.Institutional_Card_Sales_Combined.Store_Number



GO
