USE [ReportData]
GO
/****** Object:  StoredProcedure [dbo].[rpt_Misc_Sales]    Script Date: 8/19/2022 3:44:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[rpt_Misc_Sales]
@Start_Date smalldatetime = NULL,
@End_Date Smalldatetime = NULL
as
--
if @Start_Date IS NULL
    set @Start_Date = dateadd(dd,-6,staging.dbo.fn_Last_Saturday(getdate()))
if @End_Date IS NULL
	set @End_Date = dateadd(dd,6,@Start_Date)
--
truncate table staging.dbo.depts
insert into	staging.dbo.depts
select distinct Dept
from	reference.dbo.item_master
--
truncate table reportdata.dbo.tmp_Misc_Scans
insert into reportdata.dbo.tmp_Misc_Scans
select	distinct
		t2.Dept,
		sum(t1.extended_price) as MS_SLSD,
		sum(t1.item_quantity) as MS_SLSU
from	staging.dbo.Depts t2
join	dssdata.dbo.detail_transaction_history t1
on		t1.sku_number = t2.Dept
where	t1.day_date >= @Start_Date
and		t1.day_date <= @End_Date
group by t2.Dept
order by t2.Dept
--
truncate table reportdata.dbo.tmp_Total_Scans
insert into reportdata.dbo.tmp_Total_Scans
select	distinct
		t2.Dept,
		sum(t1.extended_price) as TS_SLSD,
		sum(t1.item_quantity) as TS_SLSU
from	reference.dbo.item_master t2
join	dssdata.dbo.detail_transaction_history t1
on		t1.sku_number = t2.sku_number
where	t1.day_date >= @Start_Date
and		t1.day_date <= @End_Date
group by t2.Dept
order by t2.Dept
--
select	@Start_Date as Start_Date,
		@End_Date as End_Date,
		t1.Dept,
		t1.MS_SLSU,
		t1.MS_SLSD,
		t2.TS_SLSU,
		t2.ts_SLSD
from	reportdata.dbo.tmp_Misc_Scans t1,
		reportdata.dbo.tmp_Total_Scans t2
where	t2.dept = t1.dept
order by t1.dept

GO
