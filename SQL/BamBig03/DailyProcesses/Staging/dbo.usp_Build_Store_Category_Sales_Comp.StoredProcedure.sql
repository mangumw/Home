USE [Staging]
GO
/****** Object:  StoredProcedure [dbo].[usp_Build_Store_Category_Sales_Comp]    Script Date: 8/19/2022 3:41:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Create procedure [dbo].[usp_Build_Store_Category_Sales_Comp]
as
--
-- The following variables will become parameters when this is turned into a proc.
--
declare @PTDTY_StartDate smalldatetime
declare @QTDTY_StartDate smalldatetime
declare @YTDTY_StartDate Smalldatetime
declare @PTDLY_StartDate smalldatetime
declare @QTDLY_StartDate smalldatetime
declare @YTDLY_StartDate Smalldatetime
declare @PTDLY_EndDate smalldatetime
declare @QTDLY_EndDate smalldatetime
declare @YTDLY_EndDate Smalldatetime
--
declare @fiscal_year int
declare @fiscal_qtr varchar(7)
declare @fiscal_period int
--
-- Set up This Year Date Variables
--
select @fiscal_year = fiscal_year from reference.dbo.calendar_dim where day_date = staging.dbo.fn_DateOnly(getdate())
select @fiscal_qtr = fiscal_quarter from reference.dbo.calendar_dim where day_date = staging.dbo.fn_DateOnly(getdate())
select @fiscal_period = fiscal_period from reference.dbo.calendar_dim where day_date = staging.dbo.fn_DateOnly(getdate())
--
select @YTDTY_StartDate = min(day_date) from reference.dbo.calendar_dim where fiscal_year = @fiscal_year
select @QTDTY_StartDate = min(day_date) from reference.dbo.calendar_dim where fiscal_quarter = @fiscal_qtr
select @PTDTY_StartDate = min(day_date) from reference.dbo.calendar_dim where fiscal_period = @fiscal_period and fiscal_year = @fiscal_year
--
-- Set Up Last Year Date Variables
--
select @fiscal_year = @fiscal_year - 1
select @fiscal_qtr = fiscal_quarter from reference.dbo.calendar_dim where day_date = staging.dbo.fn_DateOnly(dateadd(yy,-1,getdate()))
select @fiscal_period = fiscal_period from reference.dbo.calendar_dim where day_date = staging.dbo.fn_DateOnly(dateadd(yy,-1,getdate()))
--
select @YTDLY_StartDate = min(day_date) from reference.dbo.calendar_dim where fiscal_year = @fiscal_year
select @QTDLY_StartDate = min(day_date) from reference.dbo.calendar_dim where fiscal_quarter = @fiscal_qtr
select @PTDLY_StartDate = min(day_date) from reference.dbo.calendar_dim where fiscal_period = @fiscal_period and fiscal_year = @fiscal_year
select @YTDLY_EndDate = dateadd(yy,-1,getdate())
select @QTDLY_EndDate = max(day_date) from reference.dbo.calendar_dim where fiscal_quarter = @fiscal_qtr
select @PTDLY_EndDate = max(day_date) from reference.dbo.calendar_dim where fiscal_period = @fiscal_period and fiscal_year = @fiscal_year
select @ytdly_startDate,@ytdly_enddate

--
-- End of Date Variable setup
-- Build list of stores to run for
-- Get all stores for specified region
--
truncate table ReportData.dbo.Report_Stores_Comp
--
insert into ReportData.dbo.Report_Stores_Comp
select	Store_Number,
		Store_Name,
		Region as Region_Number,
		Region_Name,
		District as District_Number,
		District_Name
from	reference.dbo.Comp_Stores
--
-- We have the store list, now start compiling the data.
-- Get Store Period To Date TY
--
truncate table staging.dbo.TR_SPTDTY
insert into staging.dbo.TR_SPTDTY
select	t1.Store_Number,
		t3.Dept,
		t3.Dept_Name,
		t3.SDept,
		t3.SDept_Name,
		t3.Class,
		t3.Class_Name,
		isnull(sum(t2.Extended_Price),0) as SPTD_TY
from	ReportData.dbo.Report_Stores_Comp t1 left join dssdata.dbo.detail_transaction_history t2
on		t2.Store_Number = t1.Store_Number and t2.day_date >= @PTDTY_StartDate 
Left Join reference.dbo.item_master t3 on t2.sku_number = t3.sku_number
group by t1.Store_Number,t3.Dept,t3.Dept_Name,t3.SDept,t3.SDept_Name,t3.Class,t3.Class_Name
--
-- Get Store Period To Date LY
--
truncate table staging.dbo.TR_SPTDLY
insert into staging.dbo.TR_SPTDLY
select	t1.Store_Number,
		t3.Dept,
		t3.Dept_Name,
		t3.SDept,
		t3.SDept_Name,
		t3.Class,
		t3.Class_Name,
		isnull(sum(t2.Extended_Price),0) as SPTD_LY
from	ReportData.dbo.Report_Stores_Comp t1 left join dssdata.dbo.detail_transaction_history t2
on		t2.Store_Number = t1.Store_Number 
and		t2.day_date >= @PTDLY_StartDate and t2.day_date <= @PTDLY_EndDate
Left Join reference.dbo.item_master t3 on t2.sku_number = t3.sku_number
group by t1.Store_Number,t3.Dept,t3.Dept_Name,t3.SDept,t3.SDept_Name,t3.Class,t3.Class_Name
--
-- Build Store Quarter To Date TY
--
truncate table staging.dbo.TR_SQTDTY
insert into staging.dbo.TR_SQTDTY
select	t1.Store_Number,
		t3.Dept,
		t3.Dept_Name,
		t3.SDept,
		t3.SDept_Name,
		t3.Class,
		t3.Class_Name,
		isnull(sum(t2.Extended_Price),0) as SQTD_TY
from	ReportData.dbo.Report_Stores_Comp t1 left join dssdata.dbo.detail_transaction_history t2
on		t2.Store_Number = t1.Store_Number and t2.day_date >= @QTDTY_StartDate 
Left Join reference.dbo.item_master t3 on t2.sku_number = t3.sku_number
group by t1.Store_Number,t3.Dept,t3.Dept_Name,t3.SDept,t3.SDept_Name,t3.Class,t3.Class_Name
--
-- Get Store Quarter To Date LY
--
truncate table staging.dbo.TR_SQTDLY
insert into staging.dbo.TR_SQTDLY
select	t1.Store_Number,
		t3.Dept,
		t3.Dept_Name,
		t3.SDept,
		t3.SDept_Name,
		t3.Class,
		t3.Class_Name,
		isnull(sum(t2.Extended_Price),0) as SQTD_LY
from	ReportData.dbo.Report_Stores_Comp t1 left join dssdata.dbo.detail_transaction_history t2
on		t2.Store_Number = t1.Store_Number 
and		t2.day_date >= @QTDLY_StartDate and t2.day_date <= @QTDLY_EndDate
Left Join reference.dbo.item_master t3 on t2.sku_number = t3.sku_number
group by t1.Store_Number,t3.Dept,t3.Dept_Name,t3.SDept,t3.SDept_Name,t3.Class,t3.Class_Name
--
-- Build Store Year To Date TY
--
truncate table staging.dbo.TR_SYTDTY
insert into staging.dbo.TR_SYTDTY
select	t1.Store_Number,
		t3.Dept,
		t3.Dept_Name,
		t3.SDept,
		t3.SDept_Name,
		t3.Class,
		t3.Class_Name,
		isnull(sum(t2.Extended_Price),0) as SYTD_TY
from	ReportData.dbo.Report_Stores_Comp t1 left join dssdata.dbo.detail_transaction_history t2
on		t2.Store_Number = t1.Store_Number and t2.day_date >= @YTDTY_StartDate 
Left Join reference.dbo.item_master t3 on t2.sku_number = t3.sku_number
group by t1.Store_Number,t3.Dept,t3.Dept_Name,t3.SDept,t3.SDept_Name,t3.Class,t3.Class_Name
--
-- Get Store Year To Date LY
--
truncate table staging.dbo.TR_SYTDLY
insert into staging.dbo.TR_SYTDLY
select	t1.Store_Number,
		t3.Dept,
		t3.Dept_Name,
		t3.SDept,
		t3.SDept_Name,
		t3.Class,
		t3.Class_Name,
		isnull(sum(t2.Extended_Price),0) as SYTD_LY
from	ReportData.dbo.Report_Stores_Comp t1 left join dssdata.dbo.detail_transaction_history t2
on		t2.Store_Number = t1.Store_Number 
and		t2.day_date >= @YTDLY_StartDate and t2.day_date <= @YTDLY_EndDate
Left Join reference.dbo.item_master t3 on t2.sku_number = t3.sku_number
group by t1.Store_Number,t3.Dept,t3.Dept_Name,t3.SDept,t3.SDept_Name,t3.Class,t3.Class_Name
--
-- Store Data completed. Now get Chain Level information
--
-- Get Chain Period To Date TY
--
truncate table staging.dbo.TR_CPTDTY
insert into staging.dbo.TR_CPTDTY
select	t3.Dept,
		t3.Dept_Name,
		t3.SDept,
		t3.SDept_Name,
		t3.Class,
		t3.Class_Name,
		isnull(sum(t2.Extended_Price),0) as CPTD_TY
from	dssdata.dbo.detail_transaction_history t2
Left Join reference.dbo.item_master t3 on t2.sku_number = t3.sku_number and t2.day_date >= @PTDTY_StartDate 
group by t3.Dept,t3.Dept_Name,t3.SDept,t3.SDept_Name,t3.Class,t3.Class_Name
--
-- Get Chain Period To Date LY
--
truncate table staging.dbo.TR_CPTDLY
insert into staging.dbo.TR_CPTDLY
select	t3.Dept,
		t3.Dept_Name,
		t3.SDept,
		t3.SDept_Name,
		t3.Class,
		t3.Class_Name,
		isnull(sum(t2.Extended_Price),0) as CPTD_LY
from	dssdata.dbo.detail_transaction_history t2
Left Join reference.dbo.item_master t3 
on		t2.sku_number = t3.sku_number and t2.day_date >= @PTDLY_StartDate and t2.day_date <= @PTDLY_EndDate
group by t3.Dept,t3.Dept_Name,t3.SDept,t3.SDept_Name,t3.Class,t3.Class_Name
--
-- Build Chain Quarter To Date TY
--
truncate table staging.dbo.TR_CQTDTY
insert into staging.dbo.TR_CQTDTY
select	t3.Dept,
		t3.Dept_Name,
		t3.SDept,
		t3.SDept_Name,
		t3.Class,
		t3.Class_Name,
		isnull(sum(t2.Extended_Price),0) as CQTD_TY
from	dssdata.dbo.detail_transaction_history t2 Left Join reference.dbo.item_master t3 
on		t2.sku_number = t3.sku_number and t2.day_date >= @QTDTY_StartDate
group by t3.Dept,t3.Dept_Name,t3.SDept,t3.SDept_Name,t3.Class,t3.Class_Name
--
-- Get Chain Quarter To Date LY
--
truncate table staging.dbo.TR_CQTDLY
insert into staging.dbo.TR_CQTDLY
select	t3.Dept,
		t3.Dept_Name,
		t3.SDept,
		t3.SDept_Name,
		t3.Class,
		t3.Class_Name,
		isnull(sum(t2.Extended_Price),0) as CQTD_LY
from	dssdata.dbo.detail_transaction_history t2 Left Join reference.dbo.item_master t3 
on		t2.sku_number = t3.sku_number and t2.day_date >= @QTDLY_StartDate and t2.day_date <= @QTDLY_EndDate
group by t3.Dept,t3.Dept_Name,t3.SDept,t3.SDept_Name,t3.Class,t3.Class_Name
--
-- Build Chain Year To Date TY
--
truncate table staging.dbo.TR_CYTDTY
insert into staging.dbo.TR_CYTDTY
select	t3.Dept,
		t3.Dept_Name,
		t3.SDept,
		t3.SDept_Name,
		t3.Class,
		t3.Class_Name,
		isnull(sum(t2.Extended_Price),0) as CYTD_TY
from	dssdata.dbo.detail_transaction_history t2 Left Join reference.dbo.item_master t3 
on		t2.sku_number = t3.sku_number and t2.day_date >= @YTDTY_StartDate
group by t3.Dept,t3.Dept_Name,t3.SDept,t3.SDept_Name,t3.Class,t3.Class_Name
--
-- Get Chain Year To Date LY
--
truncate table staging.dbo.TR_CYTDLY
insert into staging.dbo.TR_CYTDLY
select	t3.Dept,
		t3.Dept_Name,
		t3.SDept,
		t3.SDept_Name,
		t3.Class,
		t3.Class_Name,
		isnull(sum(t2.Extended_Price),0) as CYTD_LY
from	dssdata.dbo.detail_transaction_history t2 Left Join reference.dbo.item_master t3 
on		t2.sku_number = t3.sku_number and t2.day_date >= @YTDLY_StartDate and t2.day_date <= @YTDLY_EndDate
group by t3.Dept,t3.Dept_Name,t3.SDept,t3.SDept_Name,t3.Class,t3.Class_Name
--
-- Time to join all temp tables together
--
truncate table Dssdata.dbo.Store_Category_Sales_Comp
insert into Dssdata.dbo.Store_Category_Sales_Comp
select	t1.Store_Number,
		t2.Dept,
		t2.SDept,
		t2.Class,
		t1.Store_Name,
		t1.Region_Number,
		t1.Region_Name,
		t1.District_Number,
		t1.District_Name,
		t2.Dept_Name,
		t2.SDept_Name,
		t2.Class_Name,
		t2.SPTD_TY,
		t3.SPTD_LY,
		t4.SQTD_TY,
		t5.SQTD_LY,
		t6.SYTD_TY,
		t7.SYTD_LY,
		t8.CPTD_TY,
		t9.CPTD_LY,
		t10.CQTD_TY,
		t11.CQTD_LY,
		t12.CYTD_TY,
		t13.CYTD_LY,
		staging.dbo.fn_DateOnly(Dateadd(dd,-1,getdate())) as Day_Date
from		ReportData.dbo.Report_Stores_Comp t1
left join	staging.dbo.TR_SYTDTY t6
on			t6.store_number = t1.store_number
left join	staging.dbo.TR_SPTDTY t2
on			t2.store_number = t6.store_number
and			t2.Dept = t6.Dept
and			t2.SDept = t6.SDept
and			t2.Class = t6.Class
--
left join	staging.dbo.TR_SPTDLY t3	
on			t3.store_number = t2.store_number
and			t3.Dept = t2.Dept
and			t3.SDept = t2.SDept
and			t3.Class = t2.Class
--
left join	staging.dbo.TR_SQTDTY t4	
on			t4.store_number = t3.store_number
and			t4.Dept = t3.Dept
and			t4.SDept = t3.SDept
and			t4.Class = t3.Class
--
left join	staging.dbo.TR_SQTDLY t5	
on			t5.store_number = t4.store_number
and			t5.Dept = t4.Dept
and			t5.SDept = t4.SDept
and			t5.Class = t4.Class
--
left join	staging.dbo.TR_SYTDLY t7	
on			t7.store_number = t6.store_number
and			t7.Dept = t6.Dept
and			t7.SDept = t6.SDept
and			t7.Class = t6.Class
--
left join	staging.dbo.TR_CPTDTY t8	
on			t8.Dept = t7.Dept
and			t8.SDept = t7.SDept
and			t8.Class = t7.Class
--
left join	staging.dbo.TR_CPTDLY t9	
on			t9.Dept = t8.Dept
and			t9.SDept = t8.SDept
and			t9.Class = t8.Class
--
left join	staging.dbo.TR_CQTDTY t10	
on			t10.Dept = t9.Dept
and			t10.SDept = t9.SDept
and			t10.Class = t9.Class
--
left join	staging.dbo.TR_CQTDLY t11	
on			t11.Dept = t10.Dept
and			t11.SDept = t10.SDept
and			t11.Class = t10.Class
--
left join	staging.dbo.TR_CYTDTY t12	
on			t12.Dept = t11.Dept
and			t12.SDept = t11.SDept
and			t12.Class = t11.Class
--
left join	staging.dbo.TR_CYTDLY t13	
on			t13.Dept = t12.Dept
and			t13.SDept = t12.SDept
and			t13.Class = t12.Class
--
where		t2.Dept IS NOT NULL
order by t1.Store_Number,t6.Dept,t6.SDept,t6.Class


		
		
		
GO
