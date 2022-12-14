USE [ReportData]
GO
/****** Object:  StoredProcedure [dbo].[usp_Bookscan_Class_Report]    Script Date: 8/19/2022 3:44:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[usp_Bookscan_Class_Report] @YearWeek varchar(10)
as
declare @yearnumber int
declare @weeknumber int
declare @fiscalweek int
declare @start_date smalldatetime
declare @end_date smalldatetime
--
select @yearnumber = left(@yearweek,4)
select @yearnumber = @yearnumber + 1
select @weeknumber = right(@yearweek,2)
select	@start_date = min(day_date) 
from	reference.dbo.calendar_dim 
where	fiscal_year = @yearnumber
and		calendar_week = @weeknumber
--
select @fiscalweek = fiscal_year_week from reference.dbo.calendar_dim where day_date = @Start_date
--
select	@end_date = max(day_date) 
from	reference.dbo.calendar_dim 
where	fiscal_year = @yearnumber
and		calendar_week = @weeknumber
--
select @Start_Date = DateAdd(ww,-1,@Start_Date)
select @End_Date = DateAdd(ww,-1,@End_Date)
--
truncate table staging.dbo.wrk_bookscan_rpt_BS
insert into staging.dbo.wrk_bookscan_rpt_BS
select	@weeknumber as Week,
		t2.Dept,
		t2.sdept_name,
		t2.class_name,
		sum(t1.Week_Units) as BS_Sales
from	reference.dbo.bookscan t1,
		reference.dbo.item_master t2
where	t2.isbn = t1.isbn
and		t1.yearnumber = @yearnumber
and		t1.weeknumber = @weeknumber
group by t2.Dept,t2.sdept_name,	t2.class_name
--
truncate table staging.dbo.wrk_bookscan_rpt_BAM
insert into staging.dbo.wrk_bookscan_rpt_BAM
select	@weeknumber as Week,
		t2.Dept,
		t2.sdept_name,
		t2.class_name,
		sum(t3.item_quantity) as BAM_Sales
from	reference.dbo.bookscan t1,
		reference.dbo.item_master t2,
		dssdata.dbo.detail_transaction_history t3
where	t2.isbn = t1.isbn
and		t1.yearnumber = @yearnumber
and		t1.weeknumber = @weeknumber
and		t3.isbn = t1.isbn
and		t3.day_date >= @start_date
and		t3.day_date <= @End_Date
group by t2.Dept,t2.sdept_name,	t2.class_name
--	
select	@fiscalweek as fiscal_week,
		t1.Week,
		t1.Dept,
		t1.SubDept_name,
		t1.Class_name,
		t1.BS_Sales,
		t2.BAM_Sales
from	staging.dbo.wrk_bookscan_rpt_BS t1,
		staging.dbo.wrk_bookscan_rpt_BAM t2
where	t2.week = t1.week
and		t2.dept = t1.dept
and		t2.subdept_name = t1.subdept_name
and		t2.class_name = t1.class_name
order by t1.Dept,t1.SubDept_name,t1.Class_name

GO
